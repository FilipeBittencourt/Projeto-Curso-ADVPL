#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA553
@author Marcos Alberto Soprani
@since 01/07/15
@version 1.0
@description Contabilização do CMV de Insumos
@type function
/*/

User Function BIA553()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hr
	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA553"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA553 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA553 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA553",fPerg)

	fgLanPad := "D01"
	fgLotCtb := "009001"
	fgVetCtb := {}
	fgVetEXC := {}
	fgPermDg := .T.

	// Saidas Normais
	CT007 := " SELECT 'SD2' ORIGEM,
	CT007 += "        '41602001' DEBITO,
	CT007 += "        B1_CONTA CREDIT,
	CT007 += "        SUM(D2_QUANT) QUANT,
	CT007 += "        SUM(D2_CUSTO1) CUSTO,
	CT007 += "        'VLR CUSTO OUTRAS VENDAS N/MES' HIST,
	CT007 += "        '' CCUSTO,
	CT007 += "        CASE
	CT007 += "          WHEN RTRIM(C5_YSUBTP) = 'A' THEN 'I0301'
	CT007 += "          WHEN RTRIM(C5_YSUBTP) = 'B' THEN 'I0302'
	CT007 += "          WHEN RTRIM(C5_YSUBTP) = 'G' THEN 'I0303'
	CT007 += "          WHEN RTRIM(C5_YSUBTP) = 'D' THEN 'I0304'
	CT007 += "          ELSE '         '
	CT007 += "        END ITEMCTA,
	CT007 += "        '' CLVL,
	CT007 += "        C5_YSUBTP
	CT007 += "   FROM " + RetSqlName("SD2") + " SD2
	CT007 += "  INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '" + xFilial("SF4") + "'
	CT007 += "                       AND F4_CODIGO = D2_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND F4_PODER3 = 'N'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'
	CT007 += "                       AND B1_COD = D2_COD
	CT007 += "                       AND B1_GRUPO BETWEEN '101 ' AND '220Z'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = '" + xFilial("SC5") + "'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN " + RetSqlName("SX5") + " SX5 ON X5_FILIAL = '" + xFilial("SX5") + "'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON F2_FILIAL = D2_FILIAL
	CT007 += "                       AND F2_DOC = D2_DOC
	CT007 += "                       AND F2_EMISSAO = D2_EMISSAO
	CT007 += "                       AND F2_CLIENTE = D2_CLIENTE
	CT007 += "                       AND F2_LOJA = D2_LOJA
	CT007 += "                       AND F2_SERIE = D2_SERIE
	CT007 += " 						 AND F2_TIPO <> 'D'
	CT007 += "                       AND SF2.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D2_FILIAL = '" + xFilial("SD2") + "'
	CT007 += "    AND D2_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	CT007 += "    AND D2_TES <> '660'
	CT007 += "    AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY B1_CONTA,
	CT007 += "           C5_YSUBTP,
	CT007 += "           X5_DESCRI
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.T.,.T.)
	aStru1 := ("CT07")->(dbStruct())
	dbSelectArea("CT07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		hjCLVL   := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CLVL)
		hjCCUSTO := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CCUSTO)

		// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
		Aadd(fgVetCtb, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, CT07->CUSTO, CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, "", "" })

		Aadd(fgVetEXC, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, Transform(CT07->QUANT,"@E 999,999,999.99"), Transform(CT07->CUSTO,"@E 999,999,999.99"), CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM })

		dbSelectArea("CT07")
		dbSkip()

	End
	CT07->(dbCloseArea())
	Ferase(cIndex+GetDBExtension())
	Ferase(cIndex+OrdBagExt())

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

	U_BIAxExcel(fgVetEXC, xCamp, "BIA553"+strzero(seconds()%3500,5) )

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
