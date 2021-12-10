#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA746
@author Marcos Alberto Soprani
@since 11/02/14
@version 1.0
@description Contabilização do Custo de Produção
@obs Em 06/03/17... Ajuste na linha R09
@type function
/*/

User Function BIA746()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA746"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.", "BIA746 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.", "BIA746 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA746",fPerg)

	kjDtINI := MV_PAR01
	kjDtFIM := MV_PAR02
	kjTipoP := MV_PAR03

	msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
	msNomeTMP  := "##TMPBIA747" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

	xValidCt := 0
	RF003 := U_B185CHKF( kjDtINI, kjDtFIM, kjTipoP )
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF003),'RF03',.T.,.T.)
	aStru1 := ("RF03")->(dbStruct())
	dbSelectArea("RF03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		IncProc()
		xValidCt += Round(RF03->CUSTO,2)
		dbSelectArea("RF03")
		dbSkip()
	End
	RF03->(dbCloseArea())

	cfContinua := .T.
	If xValidCt <> 0
		cfContinua := MsgNOYES("Os valores do Custo Contábil não estão totalmente apropriados ao Kardex: "+Alltrim(Str(xValidCt))+"!!!","Atenção - BIA746")
	EndIf

	If cfContinua

		fgLanPad := "D01"
		fgLotCtb := "009008"
		fgVetCtb := {}
		fgVetEXC := {}
		fgPermDg := .T.
		fgclvl  := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))

		fgConta := ""
		fgHist  := ""
		If cEmpAnt == "01"
			If MV_PAR03 == "PP"
				fgConta := "11307001"
				fgHist  := "CUSTO PRODUCAO PRODUTO EM PROCESSO N/MES"
			ElseIf MV_PAR03 == "PA"
				fgConta := "11306001"
				fgHist  := "CUSTO PRODUCAO PRODUTO ACABADO N/MES"
			EndIf

		ElseIf cEmpAnt == "06"
			If MV_PAR03 == "MP"
				fgConta  := "11301001"
				fgCtabtf := "11301001"
				fgHist   := "CUSTO PRODUCAO MATERIA-PRIMA N/MES"
				fgHstbtf := "CUSTO PRODUCAO MATERIA-PRIMA N/MES"
			ElseIf MV_PAR03 == "PI"
				fgConta  := "11307001"
				fgCtabtf := "11307001"
				fgHist   := "CUSTO PRODUCAO PROD.INTERMEDIARIO N/MES"
				fgHstbtf := "CUSTO PRODUCAO PROD.INTERMEDIARIO N/MES"
			ElseIf MV_PAR03 == "PA"
				fgConta  := "11306005"
				fgCtabtf := "11307010"
				fgHist   := "CUSTO PRODUCAO P.A. DE MINERIO N/MES"
				fgHstbtf := "CUSTO PRODUCAO BOTA FORA N/MES"
			EndIf

		ElseIf cEmpAnt == "14"
			If MV_PAR03 == "PA"
				fgConta := "11306001"
				fgHist  := "CUSTO PRODUCAO PRODUTO ACABADO N/MES"
			EndIf

		EndIf

		If cEmpAnt == "01"

			// Producao
			CT007 := " SELECT 'CT2' ORIGEM, "
			CT007 += "        DEBITO = '" + fgConta + "', "
			CT007 += "        CREDIT = '6210100'+SUBSTRING(CTA,3,1), "
			CT007 += "        0 QUANT, "
			CT007 += "        ROUND(SUM(VALOR),2) CUSTO, "
			CT007 += "        '" + fgHist + "' HIST, "
			CT007 += "        '3000' CCUSTO, "
			CT007 += "        ' ' ITEMCTA, "
			CT007 += "        '" + fgclvl + "' CLVL "
			CT007 += "   FROM " + msNomeTMP + " " 
			CT007 += "  WHERE CONTRAP = '" + MV_PAR03 + "' "
			CT007 += "  GROUP BY SUBSTRING(CTA,3,1)

			If MV_PAR03 == "PA"
				CT007 += "  UNION ALL "
				CT007 += " SELECT 'SD3' ORIGEM, "
				CT007 += "        DEBITO = '" + fgConta + "', "
				CT007 += "        CREDIT = '11307001', "
				CT007 += "        0 QUANT, "
				CT007 += "        ROUND(SUM(D3_CUSTO1),2) CUSTO, "
				CT007 += "        '" + fgHist + "' HIST, "
				CT007 += "        '3000' CCUSTO, "
				CT007 += "        ' ' ITEMCTA, "
				CT007 += "        '" + fgclvl + "' CLVL "
				CT007 += "   FROM " + RetSqlName("SD3") + " SD3 "
				CT007 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
				CT007 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
				CT007 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
				CT007 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
				CT007 += "                       AND SC2.D_E_L_E_T_ = ' ' "
				CT007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
				CT007 += "                       AND B1_COD = C2_PRODUTO "
				CT007 += "                       AND B1_TIPO = '" + MV_PAR03 + "' "
				CT007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
				CT007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
				CT007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
				CT007 += "    AND D3_OP <> '             ' "
				CT007 += "    AND D3_TM <> '010' "
				CT007 += "    AND D3_TIPO = 'PP' "
				CT007 += "    AND D3_ESTORNO = ' ' "
				CT007 += "    AND SD3.D_E_L_E_T_ = ' ' "

			EndIf

		ElseIf cEmpAnt == "06"

			// Producao
			CT007 := " SELECT 'CT2' ORIGEM, "
			CT007 += "        DEBITO = CASE WHEN CLVL = '3804' THEN '" + fgCtabtf + "' ELSE '" + fgConta + "' END, "
			CT007 += "        CREDIT = '6210100'+SUBSTRING(CTA,3,1), "
			CT007 += "        0 QUANT, "
			CT007 += "        ROUND(SUM(VALOR),2) CUSTO, "
			CT007 += "        HIST = CASE WHEN CLVL = '3804' THEN '" + fgHstbtf + "' ELSE '" + fgHist + "' END, "
			CT007 += "        '3000' CCUSTO, "
			CT007 += "        ' ' ITEMCTA, "
			CT007 += "        CLVL "
			CT007 += "   FROM " + msNomeTMP + " " 
			CT007 += "  WHERE CONTRAP = '" + MV_PAR03 + "' "
			CT007 += "  GROUP BY SUBSTRING(CTA,3,1), "
			CT007 += "           CLVL "

			If MV_PAR03 == "PI"
				CT007 += "  UNION ALL "
				CT007 += " SELECT 'SD3' ORIGEM, "
				CT007 += "        DEBITO = CASE "
				CT007 += "                   WHEN D3_TM < '500' THEN '11301001' " 
				CT007 += "                   ELSE '" + fgConta + "' "
				CT007 += "                 END, "
				CT007 += "        CREDIT = CASE "
				CT007 += "                   WHEN D3_TM >= '500' THEN '11301001' " 
				CT007 += "                   ELSE '" + fgConta + "' "
				CT007 += "                 END, "
				CT007 += "        0 QUANT, "
				CT007 += "        ROUND(SUM(D3_CUSTO1),2) CUSTO, "
				CT007 += "        '" + fgHist + "' HIST, "
				CT007 += "        '3000' CCUSTO, "
				CT007 += "        ' ' ITEMCTA, "
				CT007 += "        D3_CLVL CLVL "
				CT007 += "   FROM " + RetSqlName("SD3") + " SD3 "
				CT007 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
				CT007 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
				CT007 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
				CT007 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
				CT007 += "                       AND SC2.D_E_L_E_T_ = ' ' "
				CT007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
				CT007 += "                       AND B1_COD = C2_PRODUTO "
				CT007 += "                       AND B1_TIPO = '" + MV_PAR03 + "' "
				CT007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
				CT007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
				CT007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
				CT007 += "    AND D3_OP <> '             ' "
				CT007 += "    AND D3_TM <> '010' "
				CT007 += "    AND D3_TIPO = 'MP' "
				CT007 += "    AND D3_CUSTO1 <> 0 "
				CT007 += "    AND D3_ESTORNO = ' ' "
				CT007 += "    AND SD3.D_E_L_E_T_ = ' ' "
				CT007 += "  GROUP BY D3_TM, D3_CLVL "

			ElseIf MV_PAR03 == "PA"
				CT007 += "  UNION ALL "
				CT007 += " SELECT 'SD3' ORIGEM, "
				CT007 += "        DEBITO = CASE "
				CT007 += "                   WHEN D3_TM < '500' THEN ( CASE WHEN D3_TIPO = 'MP' THEN '11301001' WHEN D3_TIPO = 'PI' THEN '11307001' END ) " 
				CT007 += "                   ELSE '" + fgConta + "' "
				CT007 += "                 END, "
				CT007 += "        CREDIT = CASE "
				CT007 += "                   WHEN D3_TM >= '500' THEN ( CASE WHEN D3_TIPO = 'MP' THEN '11301001' WHEN D3_TIPO = 'PI' THEN '11307001' END ) " 
				CT007 += "                   ELSE '" + fgConta + "' "
				CT007 += "                 END, "
				CT007 += "        0 QUANT, "
				CT007 += "        ROUND(SUM(D3_CUSTO1),2) CUSTO, "
				CT007 += "        '" + fgHist + "' HIST, "
				CT007 += "        '3000' CCUSTO, "
				CT007 += "        ' ' ITEMCTA, "
				CT007 += "        D3_CLVL CLVL "
				CT007 += "   FROM " + RetSqlName("SD3") + " SD3 "
				CT007 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
				CT007 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
				CT007 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
				CT007 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
				CT007 += "                       AND SC2.D_E_L_E_T_ = ' ' "
				CT007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
				CT007 += "                       AND B1_COD = C2_PRODUTO "
				CT007 += "                       AND B1_TIPO = '" + MV_PAR03 + "' "
				CT007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
				CT007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
				CT007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
				CT007 += "    AND D3_OP <> '             ' "
				CT007 += "    AND D3_TM <> '010' "
				CT007 += "    AND D3_TIPO IN('MP','PI') "
				CT007 += "    AND D3_CUSTO1 <> 0 "
				CT007 += "    AND D3_ESTORNO = ' ' "
				CT007 += "    AND SD3.D_E_L_E_T_ = ' ' "
				CT007 += "  GROUP BY D3_TM, D3_CLVL, D3_TIPO "

			EndIf

		ElseIf cEmpAnt == "14"

			// Producao
			CT007 := " SELECT 'CT2' ORIGEM, "
			CT007 += "        DEBITO = '" + fgConta + "', "
			CT007 += "        CREDIT = '6210100'+SUBSTRING(CTA,3,1), "
			CT007 += "        0 QUANT, "
			CT007 += "        ROUND(SUM(VALOR),2) CUSTO, "
			CT007 += "        '" + fgHist + "' HIST, "
			CT007 += "        '3000' CCUSTO, "
			CT007 += "        ' ' ITEMCTA, "
			CT007 += "        '" + fgclvl + "' CLVL "
			CT007 += "   FROM " + msNomeTMP + " " 
			CT007 += "  WHERE CONTRAP = '" + MV_PAR03 + "' "
			CT007 += "  GROUP BY SUBSTRING(CTA,3,1)

			If MV_PAR03 == "PA"
				CT007 += "  UNION ALL "
				CT007 += " SELECT 'SD3' ORIGEM, "
				CT007 += "        DEBITO = '" + fgConta + "', "
				CT007 += "        CREDIT = '11307001', "
				CT007 += "        0 QUANT, "
				CT007 += "        ROUND(SUM(D3_CUSTO1),2) CUSTO, "
				CT007 += "        '" + fgHist + "' HIST, "
				CT007 += "        '3000' CCUSTO, "
				CT007 += "        ' ' ITEMCTA, "
				CT007 += "        '" + fgclvl + "' CLVL "
				CT007 += "   FROM " + RetSqlName("SD3") + " SD3 "
				CT007 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
				CT007 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
				CT007 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
				CT007 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
				CT007 += "                       AND SC2.D_E_L_E_T_ = ' ' "
				CT007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
				CT007 += "                       AND B1_COD = C2_PRODUTO "
				CT007 += "                       AND B1_TIPO = '" + MV_PAR03 + "' "
				CT007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
				CT007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
				CT007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
				CT007 += "    AND D3_OP <> '             ' "
				CT007 += "    AND D3_TM <> '010' "
				CT007 += "    AND D3_TIPO <> 'PP' "
				CT007 += "    AND D3_ESTORNO = ' ' "
				CT007 += "    AND SD3.D_E_L_E_T_ = ' ' "

			EndIf

		Else

			MsgINFO("A empresa " + cEmpAnt + " não está configurada para Contabilização do Custo de Produção", "BIA746")
			Return

		End

		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.T.,.T.)
		aStru1 := ("CT07")->(dbStruct())
		dbSelectArea("CT07")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
			Aadd(fgVetCtb, { CT07->DEBITO, CT07->CREDIT, CT07->CLVL, CT07->CLVL, CT07->ITEMCTA, CT07->ITEMCTA, CT07->CUSTO, CT07->HIST, CT07->CCUSTO, CT07->CCUSTO, CT07->ORIGEM })

			Aadd(fgVetEXC, { CT07->DEBITO, CT07->CREDIT, CT07->CLVL, CT07->CLVL, CT07->ITEMCTA, CT07->ITEMCTA, Transform(CT07->QUANT,"@E 999,999,999.99"), Transform(CT07->CUSTO,"@E 999,999,999.99"), CT07->HIST, CT07->CCUSTO, CT07->CCUSTO, CT07->ORIGEM })

			dbSelectArea("CT07")
			dbSkip()
		End
		CT07->(dbCloseArea())

		//                                     Contabilização
		*****************************************************

		U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

		//                                              Excel
		*****************************************************

		xCamp := {}
		AADD(xCamp,{ "DEBITO"     ,"C",20,0 } )
		AADD(xCamp,{ "CREDITO"    ,"C",20,0 } )
		AADD(xCamp,{ "CLVLD"      ,"C",09,0 } )
		AADD(xCamp,{ "CVVLC"      ,"C",09,0 } )
		AADD(xCamp,{ "ITEMD"      ,"C",09,0 } )
		AADD(xCamp,{ "ITEMC"      ,"C",09,0 } )
		AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
		AADD(xCamp,{ "CUSTO"      ,"N",18,2 } )
		AADD(xCamp,{ "HISTOR"     ,"C",40,0 } )
		AADD(xCamp,{ "CCUSTOD"    ,"C",09,0 } )
		AADD(xCamp,{ "CCUSTOC"    ,"C",09,0 } )
		AADD(xCamp,{ "ORIGEM"     ,"C",90,0 } )

		U_BIAxExcel(fgVetEXC, xCamp, "BIA746"+strzero(seconds()%3500,5) )

	EndIf

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo de Produto        ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
