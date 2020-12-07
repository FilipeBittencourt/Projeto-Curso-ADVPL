#Include "protheus.ch"
#Include 'TOPCONN.CH'



User Function BFATRE02()
	
	Local oReport	:= Nil
	Local cPerg 	:= PadR('BFATRE02',10)
	Local cLoad	    := "BFATRE02" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	
	Private dDataI	:= Nil
	Private dDataF	:= NiL
	Private cProdI	:= Nil
	Private cProdF	:= Nil
	Private cMarca	:= Nil
	Private cTpSeg	:= Nil
	Private cUF		:= Nil
	Private cLoteI	:= Nil
	Private cLoteF	:= Nil
	
	Private MV_PAR01 := STOD('')
	Private MV_PAR02 := STOD('')
	Private MV_PAR03 := Space(15)
	Private MV_PAR04 := Space(15)
	Private MV_PAR05 := ""
	Private MV_PAR06 := Space(1)
	Private MV_PAR07 := Space(100)
	Private MV_PAR08 := Space(10)
	Private MV_PAR09 := Space(10)
	
	
	Private aPergs := {}
	
	aAdd( aPergs ,{1,"Da data" 	   			,MV_PAR01 ,""  ,"", ''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até data" 	   		,MV_PAR02 ,""  ,"", ''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Do produto" 	   		,MV_PAR03 ,""  ,"", 'SB1'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até produto" 	   		,MV_PAR04 ,""  ,"", 'SB1'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{2,"Marca"  				,MV_PAR05 ,{"","Biacogres","Incesa","Bellacasa", "Incesa/Bellacasa", "Todas"},50,'.T.',.F.})
	aAdd( aPergs ,{1,"Segmento" 	   		,MV_PAR06 ,""  ,"", 'Z41'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"UF" 	   				,MV_PAR07 ,""  ,"", "ESTADO"  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Do lote" 	   			,MV_PAR08 ,""  ,"", ''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até lote" 	   		,MV_PAR09 ,""  ,"", ''  ,'.T.',50,.F.})	
	
	If ParamBox(aPergs ,"Filtro faturamento cliente x produto.",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05) 
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)
		MV_PAR08 := ParamLoad(cFileName,,8,MV_PAR08)
		MV_PAR09 := ParamLoad(cFileName,,9,MV_PAR09)
	
		
		dDataI	:= IIF(!Empty(MV_PAR01), DTOS(MV_PAR01), MV_PAR01)
		dDataF	:= IIF(!Empty(MV_PAR02), DTOS(MV_PAR02), MV_PAR02)
		cProdI	:= MV_PAR03
		cProdF	:= MV_PAR04
		
		Do Case
			Case MV_PAR05 == "" 	//TODAS
				cMarca	:= ""
			Case MV_PAR05 == "Biacogres" 	//BIANCO
				cMarca	:= "0101"
			Case MV_PAR05 == "Incesa" 	//INCESA
				cMarca	:= "0501"
			Case MV_PAR05 == "Bellacasa"	//BELLACASA
				cMarca	:= "0599"
			Case MV_PAR05 == "Incesa/Bellacasa"	//INCESA/BELLACASA
				cMarca	:= "0501/0599"
			Case MV_PAR05 == "Todas"	//Todas
				cMarca	:= "0101/0501/0599/1399"				
		EndCase  
		
		cTpSeg	:= MV_PAR06
		cUF 	:= FormataUF(MV_PAR07)
		cLoteI	:= MV_PAR08
		cLoteF	:= MV_PAR09
		
		oReport := reportDef()
		oReport:printDialog()
					
	EndIf
	
	
	/*
	If (Pergunte(cPerg,.T.))
	
		dDataI	:= IIF(!Empty(MV_PAR01), DTOS(MV_PAR01), MV_PAR01)
		dDataF	:= IIF(!Empty(MV_PAR02), DTOS(MV_PAR02), MV_PAR02)
		cProdI	:= MV_PAR03
		cProdF	:= MV_PAR04
		
		Do Case
			Case MV_PAR05 == 1 	//TODAS
				cMarca	:= "0101/0501/0599/1399"
			Case MV_PAR05 == 2 	//BIANCO
				cMarca	:= "0101"
			Case MV_PAR05 == 3 	//INCESA
				cMarca	:= "0501"
			Case MV_PAR05 == 4	//BELLACASA
				cMarca	:= "0599"
			Case MV_PAR05 == 5	//INCESA/BELLACASA
				cMarca	:= "0501/0599"
		EndCase  
		
		cTpSeg	:= MV_PAR06
		cUF 	:= cvaltochar(MV_PAR07)
		cLoteI	:= MV_PAR08
		cLoteF	:= MV_PAR09
		
		
		oReport := reportDef()
		oReport:printDialog()
	Else
		
	EndIf	
	*/
Return
 
 
Static Function reportDef()
	
	Local oReport	:= Nil	
	Local oSection1	:= Nil
	Local oSection2	:= NIl
	Local cTitulo 	:= 'FATURAMENTO CLIENTE X PRODUTO'
 
	oReport := TReport():New('BFATRE02', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir o faturamento cliente x produto.")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "Produtos",{})
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "MARCA_PROD"	, , 'MARCA'			, , 18,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "NOME_PROD"		, , 'PRODUTO'		, , TamSX3("B1_DESC")[1]+TamSX3("B1_COD")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T1"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T2"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T3"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T4"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T5"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "T6"				, , ''				, , 10,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	
	//oBreak := TRBreak():New(oSection1,oSection1:Cell("MARCA_PROD"),,.F.)
 	
	oSection2 := TRSection():New(oSection1, "Clientes",{})
	oSection2:SetTotalInLine(.F.)
	
	TRCell():New(oSection2, "NOME_CLI"	, , 'CLIENTE'		, , TamSX3("A1_NOME")[1]+TamSX3("A1_COD")[1]+20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "MUNI_CLI"	, , 'MUNICÍPIO'		, , TamSX3("A1_MUN")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "UF_CLI"	, , 'UF'			, , TamSX3("A1_EST")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "TEL_CLI"	, , 'TELEFONE'		, , TamSX3("A1_TEL")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "DATA_EMI"	, , 'EMISSÃO'		, , TamSX3("D2_EMISSAO")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/, , ,'CENTER')
	TRCell():New(oSection2, "NUM"		, , 'SÉRIE/NF'		, , TamSX3("D2_DOC")[1]+TamSX3("D2_SERIE")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2, "QUANT"		, , 'QUANT/M2'		, , TamSX3("D2_QUANT")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/, , ,'CENTER')
	TRCell():New(oSection2, "LOTE"		, , 'LOTE'			, , TamSX3("D2_LOTECTL")[1]+10,/*lPixel*/,/*{|| code-block de impressao }*/, , ,'CENTER')
	

Return (oReport)
 
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(1):Section(1) //oReport:Section(2)	
	Local cQuery		:= MontaQuery()
	Local cAliasTrab	:= GetNextAlias()
	Local cCodProd		:= ""
	Local lExcel		:= (oReport:CXLSFILE <> NIL .Or. oReport:NEXCELPRINTTYPE == 3) 
	
		
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	oReport:SetMeter(cAliasTrab->(RecCount()))
	
	
	If (!lExcel)
		oSection1:Init()
		oSection2:Init()
		oSection1:Printline()
		oSection2:Printline()
	EndIf
	
	
	While !(cAliasTrab->(Eof()))
		
	
		If (oReport:Cancel())
			Exit
		EndIf
		
		If (lExcel)
			oSection1:Init()
			oSection2:Init()
			oSection1:ACELL[1]:NSIZE := 0
			oSection1:ACELL[2]:NSIZE := 0
			//oSection1:ACELL[3]:NSIZE := 0
			oSection1:ACELL[4]:NSIZE := 0
			oSection1:ACELL[5]:NSIZE := 0
			
			oSection1:Cell("MARCA"):ResetWidth() 
			oSection1:Cell("NOME_PROD"):ResetWidth() 
			//oSection1:Cell("T1"):ResetWidth() 
			oSection1:Cell("T2"):ResetWidth() 
			oSection1:Cell("T3"):ResetWidth() 
			
		EndIf
		
		oReport:IncMeter()
		
		cCodProd := cAliasTrab->COD_PROD
		oSection1:Cell("MARCA"):SetValue(GetNEmp(AllTrim(cAliasTrab->MARCA)))
		oSection1:Cell("NOME_PROD"):SetValue(AllTrim(cAliasTrab->COD_PROD)+" - "+AllTrim(cAliasTrab->NOME_PROD))
		
		oSection1:Printline()
	
		While (AllTrim(cAliasTrab->COD_PROD) == AllTrim(cCodProd))
			oReport:IncMeter()		
		
			oSection2:Cell("NOME_CLI"):SetValue(AllTrim(cAliasTrab->COD_CLI)+" - "+AllTrim(cAliasTrab->NOME_CLI))
			oSection2:Cell("MUNI_CLI"):SetValue(AllTrim(cAliasTrab->MUNI_CLI))
			oSection2:Cell("UF_CLI"):SetValue(AllTrim(cAliasTrab->UF_CLI))			
			oSection2:Cell("TEL_CLI"):SetValue(AllTrim(cAliasTrab->TEL_CLI))
			
			oSection2:Cell("DATA_EMI"):SetValue(AllTrim(cvaltochar(DToC(cAliasTrab->DATA_EMI))))
			oSection2:Cell("DATA_EMI"):SetAlign("CENTER")	
			
			oSection2:Cell("NUM"):SetValue(AllTrim(cAliasTrab->SERIE)+" - "+AllTrim(cAliasTrab->NUM_DOC))		
			
			oSection2:Cell("QUANT"):SetValue(TRANSFORM(cAliasTrab->QUANT,"@E 999,999,999.99"))
			oSection2:Cell("QUANT"):SetAlign("CENTER")
			oSection2:Cell("LOTE"):SetValue(AllTrim(cAliasTrab->LOTE))
			oSection2:Cell("LOTE"):SetAlign("CENTER")
				
				
			oSection2:Printline()
	
 			cAliasTrab->(DbSkip())
 		EndDo	
 		
 		If (lExcel)
 			oSection2:Finish()
 			oSection1:Finish()	
		EndIf
 		
 		oReport:SkipLine() 
 		
	EndDo
	
	If (!lExcel)
		oSection2:Finish()
		oSection1:Finish()	
	EndIf
	
	cAliasTrab->(DbCloseArea())
	
Return




Static Function GetNEmp(cCod)
	Local cNome := ""
	
	If (AllTrim(cCod) == '0101')
		cNome := "Biancogres"
	ElseIf (AllTrim(cCod) == '0501')
		cNome := "Incesa"
	ElseIf (AllTrim(cCod) == '0599')
		cNome := "Bellacasa"
	ElseIf (AllTrim(cCod) == '1399')
		cNome := "Mundi"
	EndIf
		
Return cNome

Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += "	SELECT 						 	* FROM (				"+ Enter
	
	cQuery += "	SELECT 						 						"+ Enter
	cQuery += "	A1_COD							AS COD_CLI,			"+ Enter
	cQuery += "	A1_NOME							AS NOME_CLI,		"+ Enter
	cQuery += "	A1_EST							AS UF_CLI,			"+ Enter
	cQuery += "	A1_MUN							AS MUNI_CLI,		"+ Enter
	cQuery += "	A1_TEL							AS TEL_CLI,			"+ Enter
	cQuery += "	B1_COD							AS COD_PROD,		"+ Enter
	cQuery += "	B1_DESC							AS NOME_PROD,		"+ Enter
	cQuery += "	CONVERT(DATE, D2_EMISSAO)		AS DATA_EMI,		"+ Enter
	cQuery += "	D2_DOC							AS NUM_DOC,			"+ Enter
	cQuery += "	D2_SERIE						AS SERIE,			"+ Enter
	cQuery += "	D2_QUANT						AS QUANT,			"+ Enter
	cQuery += "	D2_LOTECTL						AS LOTE,			"+ Enter
	cQuery += "	D2_YEMP							AS MARCA			"+ Enter
	cQuery += "	FROM VW_SD2 SD2"+ Enter
	cQuery += "	INNER JOIN SB1010 SB1 ON SD2.D2_COD = SB1.B1_COD		AND SB1.D_E_L_E_T_ = ''"+ Enter
	cQuery += "	INNER JOIN SA1010 SA1 ON SD2.D2_CLIENTE = SA1.A1_COD	AND SD2.D2_LOJA = SA1.A1_LOJA		AND SA1.D_E_L_E_T_ = ''"+ Enter
	cQuery += "	WHERE "+ Enter
	
	cQuery += "	SD2.D2_COD 		>= 'A'			AND "+ Enter
	cQuery += "	SD2.D2_CLIENTE 	NOT IN ('010064', '000481', '004536')		AND "+ Enter
	cQuery += "	SD2.F4_DUPLIC	= 'S'			AND "+ Enter
	cQuery += "	SD2.D2_TP    	= 'PA'			 "+ Enter
	
	If (!Empty(cMarca))
		cQuery += " AND	SD2.D2_YEMP  IN "+FormatIn(cMarca, "/")+" 		"+ Enter
	EndIf
	
	If (!Empty(dDataI) .And. !Empty(dDataF))
		cQuery += "	AND D2_EMISSAO BETWEEN  '"+dDataI+"' AND '"+dDataF+"' 				"+ Enter
	EndIf
	
	If (!Empty(cProdI) .And. !Empty(cProdF))
		cQuery += "	AND D2_COD BETWEEN  '"+cProdI+"' AND '"+cProdF+"' 					"+ Enter
	EndIf
	
	If (!Empty(cLoteI) .And. !Empty(cLoteF))
		cQuery += "	AND D2_LOTECTL BETWEEN  '"+cLoteI+"' AND '"+cLoteF+"' 					"+ Enter
	EndIf
	
	If (!Empty(cUF))
		cQuery += "	AND D2_EST IN "+FormatIn(cUF,"/")+"	  		 					"+ Enter
	EndIf
	
	
	If (!Empty(cTpSeg))
		cQuery += "	AND SA1.A1_YTPSEG = '"+cTpSeg+"' 			 						"+ Enter
	EndIf
		
	
	cQuery += "	) A																		"+ Enter	
	cQuery += "	ORDER BY MARCA, COD_PROD, DATA_EMI, NOME_CLI 							"+ Enter	
		
Return cQuery

Static Function FormataUF(cValor)
	Local nI		:= 0
	Local cNovoVal	:= ""
	
	For nI	:=	1 to Len(cValor) STEP 2
		If (Substr(cValor, nI, 2) <> '**')
			If (!Empty(Substr(cValor ,nI, 2)))
				cNovoVal +=	"" + Substr(cValor ,nI, 2) + "/"
			EndIf
		EndIf
	Next nI

Return cNovoVal


User Function BFATREUF
	
	Local aAreaSX5 	:= SX5->(GetArea())
	Local MvPar		:= Nil
	Local MvParDef	:= ""
	Local _aEstados	:= {}
	Local _nElemen	:= 0
	Local lRet		:= .F.
	Public hk_RetUF := Nil                                                                                                                                                                                                                                                  
	
	DbSelectArea('SX5')
	SX5->(DbSetOrder(1))
	If (SX5->(DbSeek(xFilial('SX5')+"12")))
		While (!SX5->(Eof()) .And. SX5->X5_TABELA == '12')
			Aadd(_aEstados, AllTrim(SX5->X5_CHAVE))
			MvParDef += AllTrim(SX5->X5_CHAVE)
			SX5->(DbSkip())
		EndDo
	EndIf
	
	SX5->(DbCloseArea())
	
	_nElemen	:= Len(_aEstados)
	MvPar 		:= &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	MvRet		:= Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
		
	If f_Opcoes(@MvPar, "Seleção de Estados", _aEstados, MvParDef, , , .F., 2, _nElemen)
		lRet	:= .T.
		&MvRet	:= mvpar

		IF TYPE ("hk_RetUF") != "U" 
			If !Empty(hk_RetUF) 
				hk_RetUF := mvpar
			EndIf
		EndIf  				
	EndIf
	
	SX5->(RestArea(aAreaSX5))
		
Return lRet

