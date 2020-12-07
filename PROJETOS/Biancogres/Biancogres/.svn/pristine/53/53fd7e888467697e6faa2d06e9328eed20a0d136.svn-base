#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA474
@author Marcos Alberto Soprani
@since 12/02/14
@version 1.0
@description Contabilização do Custo de Exaustão
@type function
/*/

User Function BIA474()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA474"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA474 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA474",fPerg)

	kjDtINI   := MV_PAR01
	kjDtFIM   := MV_PAR02
	kjCtExast := MV_PAR03

	RF003 := " SELECT COUNT(*) CONTAD "
	RF003 += " FROM " + RetSqlName("CT2") + " "
	RF003 += " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' "
	RF003 += "       AND CT2_DATA BETWEEN '" + dtos(kjDtINI) + "' AND '" + dtos(kjDtFIM) + "' "
	RF003 += "       AND CT2_DEBITO = '61502003' "
	RF003 += "       AND D_E_L_E_T_ = ' ' "
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF003),'RF03',.T.,.T.)
	dbSelectArea("RF03")
	dbGoTop()
	ProcRegua(RecCount())
	xValidCt := Round(RF03->CONTAD,2)
	RF03->(dbCloseArea())

	cfContinua := .T.
	If xValidCt <> 0
		cfContinua := MsgNOYES("Encontrado lançamento de exaustão para o período informado. Deseja Prosseguir?","Atenção - BIA474")
	EndIf

	If cfContinua

		fgLanPad := "D01"
		fgLotCtb := "009004"
		fgVetCtb := {}
		fgVetEXC := {}
		fgPermDg := .T.

		CT007 := " SELECT 'BIA474' ORIGEM, "
		CT007 += "        '61502003' DEBITO, "
		CT007 += "        '16850006' CREDIT, "
		CT007 += "        SUM(D3_QUANT) QUANT, "
		CT007 += "        SUM(D3_QUANT) * " + Alltrim(Str(kjCtExast)) + " CUSTO, "
		CT007 += "        'VLR CUSTO DE EXAUSTAO N/MES' HIST, "
		CT007 += "        '3000' CCUSTO, "
		CT007 += "        ' ' ITEMCTA, "
		CT007 += "        '3805' CLVL, "
		CT007 += "        '' C5_YSUBTP, "
		CT007 += "        '' C5_YSI "
		CT007 += " FROM " + RetSqlName("SD3") + " "
		CT007 += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		CT007 += "       AND D3_EMISSAO BETWEEN '" + dtos(kjDtINI) + "' AND '" + dtos(kjDtFIM) + "' "
		CT007 += "       AND D3_COD <> 'J0701001       ' "
		CT007 += "       AND D3_TM = '010' "
		CT007 += "       AND D3_TIPO = 'PA' "
		CT007 += "       AND D3_ESTORNO = ' ' "
		CT007 += "       AND D_E_L_E_T_ = ' ' "
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.T.,.T.)
		aStru1 := ("CT07")->(dbStruct())
		dbSelectArea("CT07")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			hjCLVL   := CT07->CLVL
			hjCCUSTO := CT07->CCUSTO
			hjCliAiD := CT07->C5_YSI
			hjCliAiC := CT07->C5_YSI

			// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM,  CT2_ATIVDE, CT2_ATIVCR
			Aadd(fgVetCtb, { CT07->DEBITO, CT07->CREDIT, hjCLVL, "", "", "", CT07->CUSTO, CT07->HIST, hjCCUSTO, "", CT07->ORIGEM, hjCliAiD, "" })

			Aadd(fgVetEXC, { CT07->DEBITO, CT07->CREDIT, hjCLVL, "", "", "", Transform(CT07->QUANT,"@E 999,999,999.99"), Transform(CT07->CUSTO,"@E 999,999,999.99"), CT07->HIST, hjCCUSTO, "", CT07->ORIGEM, hjCliAiD, "" })

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
		AADD(xCamp,{ "CLI_AID"    ,"C",06,0 } )
		AADD(xCamp,{ "CLI_AIC"    ,"C",06,0 } )

		U_BIAxExcel(fgVetEXC, xCamp, "BIA474"+strzero(seconds()%3500,5) )

	Else

		MsgSTOP("Os valores do Custo Contábil não estão totalmente apropriados ao Kardex: "+Alltrim(Str(xValidCt))+"!!!","Atenção - BIA474")

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
	aAdd(aRegs,{cPerg,"03","Custo Unitário Exaustão?","","","mv_ch3","N",15,2,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
