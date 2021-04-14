#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FROPRE01
@description RELATORIO DE ANALISE DE OP
@author Fernando Rocha
@since 26/03/2015
@version 1.0
@type function
@obs revisado 13/03/18 para usar a function CALC_SALDO_OP
/*/
User Function FROPRE01()
	Private oReport,oSection1,oSection2

	Private cPerg 		:= "FROPRE01"
	Private aRegs 		:= {}
	Private cQuery	 	:= "QUERY"

	oReport:=ReportDef()
	oReport:PrintDialog()

Return


Static Function ReportDef()
	Local cReport := "FROPRE01"
	Local cAlias1 := "QUERY"
	Local cTitulo := "Analise de OP's"
	Local cDescri := "Analise de OP's"
	Local bReport := { |oReport|	oReport:SetTitle( oReport:Title() ),	ReportPrint( oReport ) }
	Local cMoeda

	ValPerg()

	Pergunte(cPerg , .F. )
	oReport  := TReport():New( cReport, cTitulo, cPerg , bReport, cDescri )
	oReport:SetLandScape()
	//oReport:SetPortrait()

	oSection1 := TRSection():New( oReport  ,"RC",{"QUERY"} )
	TRCell():New(oSection1	,"C2_NUM"			,,"Num.Op"				,"@!", 6,/*lPixel*/,  {|| (cQUERY)->C2_NUM } )
	TRCell():New(oSection1	,"C2_PRODUTO"		,,"Produto"	  			,"@!", 15,/*lPixel*/, {|| (cQUERY)->C2_PRODUTO } )
	TRCell():New(oSection1	,"B1_DESC"			,,"Descricao"			,"@!", 30,/*lPixel*/, {|| (cQUERY)->B1_DESC } )
	TRCell():New(oSection1	,"C2_EMISSAO"  		,,"Emissão"				,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->C2_EMISSAO))  } )
	TRCell():New(oSection1	,"C2_DATPRI"  		,,"Prev.Inicio"			,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->C2_DATPRI))  } )
	TRCell():New(oSection1	,"C2_DATPRF"  		,,"Prev.Fim"			,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->C2_DATPRF))  } )
	TRCell():New(oSection1	,"C2_YDTDISP"  		,,"Disponibilidade"		,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->C2_YDTDISP))  } )
	TRCell():New(oSection1	,"C2_DATRF"  		,,"Dt.Encerramento"		,"@!", 10,/*lPixel*/, {|| DTOC(STOD((cQUERY)->C2_DATRF))  } )
	TRCell():New(oSection1	,"C2_QUANT"  		,,"Qtde"				,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->C2_QUANT  } )
	TRCell():New(oSection1	,"C2_YQTRTFC"  		,,"Qt.Retífica"			,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->C2_YQTRTFC  } )
	TRCell():New(oSection1	,"C2_QUJE"  		,,"Qt.Ja Produzida"		,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->C2_QUJE  } )
	TRCell():New(oSection1	,"C2_LINHA"			,,"Linha"				,"@!", 6,/*lPixel*/,  {|| (cQUERY)->C2_LINHA } )
	TRCell():New(oSection1	,"ZZ6_DESC"			,,"Desc"				,"@!", 10,/*lPixel*/,  {|| (cQUERY)->ZZ6_DESC } )
	TRCell():New(oSection1	,"ZZ6_FORNOP"			,,"Forno"				,"@!", 10,/*lPixel*/,  {|| (cQUERY)->ZZ6_FORNOP } )
	TRCell():New(oSection1	,"C2_OBS"			,,"Obs."				,"@!", 10,/*lPixel*/,  {|| (cQUERY)->C2_OBS } )




	TRCell():New(oSection1	,"TOT_DISPO_VENDA"  ,,"Total p/Reserva"		,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->TOT_DISPO_VENDA  } )
	TRCell():New(oSection1	,"RESERVADA"  		,,"Qt.Reservada"		,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->RESERVADA  } )
	TRCell():New(oSection1	,"SALDO_VENDA"  	,,"Saldo p/Reserva"		,"@E 999,999.99", 10,/*lPixel*/, {|| (cQUERY)->SALDO_VENDA  } )

Return oReport


Static Function ReportPrint( oReport )
	Local cChave
	Local cWhere	:= ""
	Local cQuebra	:= .T.
	Local CSQL 		:= ""
	Local nOrder 	:= MV_PAR09

	//oSection1:BeginQuery()

	CSQL := ""
	CSQL += " WITH TAB_OP AS "+CRLF
	CSQL += " ( "+CRLF
	CSQL += " SELECT "+CRLF
	CSQL += " C2_NUM, "+CRLF
	CSQL += " C2_PRODUTO, "+CRLF
	CSQL += " SB1.B1_DESC, "+CRLF
	CSQL += " C2_EMISSAO, "+CRLF
	CSQL += " C2_DATPRI, "+CRLF
	CSQL += " C2_DATPRF, "+CRLF
	CSQL += " C2_YDTDISP, "+CRLF
	CSQL += " C2_DATRF, "+CRLF
	CSQL += " C2_QUANT, "+CRLF
	CSQL += " C2_YQTRTFC, "+CRLF

	CSQL += " C2_QUJE, "+CRLF
	CSQL += " C2_LINHA,"+CRLF
	CSQL += " C2_OBS,"+CRLF
	CSQL += " ZZ6.ZZ6_DESC,"+CRLF
	CSQL += " ZZ6.ZZ6_FORNOP,"+CRLF

	CSQL += " RESERVADA = isnull((select sum(PZ0_QUANT) from "+RetSQLName("PZ0")+" PZ0 where PZ0_FILIAL = C2_FILIAL and PZ0_OPNUM = C2_NUM  "+CRLF
	CSQL += " 				and PZ0_OPITEM = C2_ITEM and PZ0_OPSEQ = C2_SEQUEN and PZ0.D_E_L_E_T_=''),0), "+CRLF
	CSQL += " TOT_DISPO_VENDA = ROUND([dbo].[FNC_ROP_CALC_SALDO_OP_"+AllTrim(CEMPANT)+"](SC2.C2_FILIAL,SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,'','',0),2) "+CRLF
	CSQL += " FROM "+RetSQLName("SC2")+" SC2 (nolock) "+CRLF
	CSQL += " JOIN "+RetSQLName("SB1")+" SB1 (nolock) ON B1_COD = C2_PRODUTO "+CRLF
	CSQL += " JOIN "+RetSQLName("ZZ6")+" ZZ6 (nolock) ON ZZ6_COD = B1_YFORMAT "+CRLF
	CSQL += " WHERE "+CRLF
	CSQL += " C2_FILIAL = '"+XFilial("SC2")+"' "+CRLF
	CSQL += " and B1_TIPO = 'PA' "+CRLF
	CSQL += " and C2_PRODUTO between '"+MV_PAR03+"' and '"+MV_PAR04+"' "+CRLF
	CSQL += " and C2_EMISSAO between '"+DTOS(MV_PAR05)+"' and '"+DTOS(MV_PAR06)+"' "+CRLF
	CSQL += " and B1_YCLASSE between '"+MV_PAR07+"' and '"+MV_PAR08+"' "+CRLF

	If MV_PAR01 == 1
		CSQL += " and C2_DATRF = '' "+CRLF
	ElseIf	MV_PAR01 == 2
		CSQL += " and C2_DATRF <> '' "+CRLF
	EndIf

	CSQL += " and SC2.D_E_L_E_T_='' "+CRLF
	CSQL += " and SB1.D_E_L_E_T_='' "+CRLF
	CSQL += " and ZZ6.D_E_L_E_T_='' "+CRLF
	CSQL += " ) "+CRLF
	CSQL += " SELECT "+CRLF
	CSQL += " C2_NUM, "+CRLF
	CSQL += " C2_PRODUTO, "+CRLF

	CSQL += " SB1.B1_DESC, "+CRLF //

	CSQL += " C2_EMISSAO, "+CRLF
	CSQL += " C2_DATPRI, "+CRLF
	CSQL += " C2_DATPRF, "+CRLF
	CSQL += " C2_YDTDISP, "+CRLF
	CSQL += " C2_DATRF, "+CRLF
	CSQL += " C2_QUANT, "+CRLF
	CSQL += " C2_YQTRTFC, "+CRLF
	CSQL += " C2_QUJE, "+CRLF

	CSQL += " C2_LINHA, "+CRLF
	CSQL += " C2_OBS, "+CRLF
	CSQL += " ZZ6.ZZ6_DESC,"+CRLF
	CSQL += " ZZ6.ZZ6_FORNOP, "+CRLF

	CSQL += " TOT_DISPO_VENDA, "+CRLF
	CSQL += " RESERVADA, "+CRLF
	CSQL += " SALDO_VENDA = (TOT_DISPO_VENDA - C2_QUJE - RESERVADA) "+CRLF
	CSQL += " FROM TAB_OP "+CRLF

	CSQL += " JOIN "+RetSQLName("SB1")+" SB1 (nolock) ON SB1.B1_COD = C2_PRODUTO "+CRLF
	CSQL += " JOIN "+RetSQLName("ZZ6")+" ZZ6 (nolock) ON ZZ6_COD = SB1.B1_YFORMAT "+CRLF
	CSQL += " WHERE "+CRLF

	CSQL += " 1 = 1 "+CRLF
	If MV_PAR02 == 2
		CSQL += " and (TOT_DISPO_VENDA - C2_QUJE - RESERVADA) > 0 "+CRLF
	ElseIf MV_PAR02 == 3
		CSQL += " and (TOT_DISPO_VENDA - C2_QUJE - RESERVADA) <= 0 "+CRLF
	EndIf

	If nOrder = 1
		CSQL += " ORDER BY C2_PRODUTO "+CRLF
	ElseIf nOrder = 2
		CSQL += " ORDER BY C2_YDTDISP "+CRLF
	Else
		CSQL += " ORDER BY C2_NUM "+CRLF
	EndIf

	TCQUERY CSQL New Alias "QUERY"

	oSection1:Init()
	oSection1:Print()
	oSection1:Finish()

	IF Select("QUERY") > 0
		QUERY->(DbCloseArea())
	ENDIF

Return Nil

Static Function ValPerg()
	Local i,j,nX
	Local aTRegs := {}
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}

	cPerg := PADR(cPerg,10)

	//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
	aAdd(aTRegs,{"Quanto ao Status da OP?"		,"N", 1,0,0,"C","","Somente Abertas","Encerradas","Todas","","","",""})
	aAdd(aTRegs,{"Quanto ao Saldo da OP?"		,"N", 1,0,0,"C","","Todas","Disponivel","Encerrado","","","",""})
	aAdd(aTRegs,{"Produto De?"			,"C", 15,0,0,"G","","","","","","","SB1",""})
	aAdd(aTRegs,{"Produto Ate?"			,"C", 15,0,0,"G","","","","","","","SB1",""})
	aAdd(aTRegs,{"Emissao De?"			,"D", 8,0,0,"G","","","","","","","",""})
	aAdd(aTRegs,{"Emissao Ate?"			,"D", 8,0,0,"G","","","","","","","",""})
	aAdd(aTRegs,{"Classe Produto De?"	,"C", 1,0,0,"G","","","","","","","ZZ8",""})
	aAdd(aTRegs,{"Classe Produto Ate?"	,"C", 1,0,0,"G","","","","","","","ZZ8",""})
	aAdd(aTRegs,{"Ordenar Por:"			,"N", 1,0,0,"C","","Produto","Disponibilidade","OP","","","",""})

	//Criar aRegs na ordem do vetor Temporario
	aRegs := {}
	For I := 1 To Len(aTRegs)
		aAdd(aRegs,{cPerg, StrZero(I,2), aTRegs[I][1], aTRegs[I][1], aTRegs[I][1],;
			"mv_ch"+Alltrim(Str(I)), aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],;
			aTRegs[I][6],aTRegs[I][7],"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",;
			aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","",;
			"",aTRegs[I][12],"","","",aTRegs[I][13],""})
	Next I

	//Grava no SX1 se ja nao existir
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)

		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Else
			RecLock("SX1",.F.)
			For j:=3 to FCount()
				If j <= Len(aRegs[i])
					If SubStr(FieldName(j),1,6) <> "X1_CNT"
						FieldPut(j,aRegs[i,j])
					EndIf
				Endif
			Next
			MsUnlock()
		EndIf

		//HELP DAS PERGUNTAS
		aHelpPor := {}
		__aRet := STRTOKARR(aTRegs[I][14],"#")
		FOR nX := 1 To Len(__aRet)
			AADD(aHelpPor,__aRet[nX])
		NEXT nX
		PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)

	Next

RETURN
