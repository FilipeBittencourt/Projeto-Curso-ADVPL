#Include "protheus.ch"
#Include 'TOPCONN.CH'


User Function BIA267R3()
	
	Local oReport	:= Nil
	Local cLoad	    := "BIA267R3" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	
	Private dDataI	:= Nil
	Private dDataF	:= NiL
	Private cProdI	:= Nil
	Private cProdF	:= Nil
	Private cCliI	:= Nil
	Private cCliF	:= Nil
	Private cNotaI	:= Nil
	Private cNotaF	:= Nil
	Private cSerie	:= Nil
	
	Private MV_PAR01 := STOD('')
	Private MV_PAR02 := STOD('')
	Private MV_PAR03 := Space(6)
	Private MV_PAR04 := Space(6)
	Private MV_PAR05 := Space(15)
	Private MV_PAR06 := Space(15)
	Private MV_PAR07 := Space(9)
	Private MV_PAR08 := Space(9)
	Private MV_PAR09 := Space(3)
	
	Private aPergs := {}
	
	aAdd( aPergs ,{1,"Da data" 	   			,MV_PAR01 ,""  ,"", ''		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até data" 	   		,MV_PAR02 ,""  ,"", '' 		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Do cliente" 	   		,MV_PAR03 ,""  ,"", 'SA1'	,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até cliente" 	   		,MV_PAR04 ,""  ,"", 'SA1'	,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Do produto" 	   		,MV_PAR05 ,""  ,"", 'SB1'	,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até produto" 	   		,MV_PAR06 ,""  ,"", 'SB1'	,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Da NF" 	   			,MV_PAR07 ,""  ,"", ''  	,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até NF" 	   			,MV_PAR08 ,""  ,"", ''  	,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Série" 	   			,MV_PAR09 ,""  ,"", ''  	,'.T.',50,.F.})
	
	
	If ParamBox(aPergs ,"Filtro devoluções.",,,,,,,,cLoad,.T.,.T.)

		MV_PAR01 := ParamLoad(cFileName,	,	1,	MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,	,	2,	MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,	,	3,	MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,	,	4,	MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,	,	5,	MV_PAR05) 
		MV_PAR06 := ParamLoad(cFileName,	,	6,	MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,	,	7,	MV_PAR07)
		MV_PAR08 := ParamLoad(cFileName,	,	8,	MV_PAR08)
		MV_PAR09 := ParamLoad(cFileName,	,	9,	MV_PAR09)
	
		
		dDataI	:= IIF(!Empty(MV_PAR01), DTOS(MV_PAR01), MV_PAR01)
		dDataF	:= IIF(!Empty(MV_PAR02), DTOS(MV_PAR02), MV_PAR02)
		cCliI	:= MV_PAR03
		cCliF	:= MV_PAR04
		cProdI	:= MV_PAR05
		cProdF	:= MV_PAR06
		cNotaI	:= MV_PAR07
		cNotaF	:= MV_PAR08
		cSerie	:= MV_PAR09
			
		oReport := reportDef()
		oReport:printDialog()
					
	EndIf
	
Return
 
 
Static Function reportDef()
	
	Local oReport	:= Nil	
	Local oSection1	:= Nil
	Local oSection2	:= NIl
	Local oSection3	:= NIl
	Local cTitulo 	:= 'DEVOLUÇÕES'
 
	oReport := TReport():New('BIA267R3', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir os devoluções.")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "Devoluções_1",{})
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1, "DATA"				, , 'Data'					, , TamSX3("Z25_DTINI")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "NUM_DEV1"			, , 'Nº Devol Bianco'		, , TamSX3("Z25_NUM")[1]+10		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "NUM_DEV2"			, , 'Nº Devol LM'			, , TamSX3("Z25_NUM")[1]+10		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "CLIENTE"			, , 'Cliente'				, , TamSX3("A1_NOME")[1]+20		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "REPRE"				, , 'Representante'			, , TamSX3("A3_NOME")[1]		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "RETORNO"			, , 'Retorno'				, , TamSX3("Z25_RETMRC")[1]+20	,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)		
	TRCell():New(oSection1, "PROD"				, , 'Produto'				, , 100							,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "QUANT"				, , 'Quantidade'			, , TamSX3("Z26_QTDORI")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , 'CENTER', , , , , , .T.)	
	TRCell():New(oSection1, "PRECO"				, , 'Preço'					, , TamSX3("Z26_QTDORI")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , 'CENTER', , , , , , .T.)	
	TRCell():New(oSection1, "TOTAL"				, , 'Total'					, , TamSX3("Z26_QTDORI")[1]+10	,/*lPixel*/,/*{|| code-block de impressao }*/, , , 'CENTER', , , , , , .T.)	
	
	
	oSection2 := TRSection():New(oSection1, "Devoluções_2",{})
	oSection2:SetTotalInLine(.F.)
	
	TRCell():New(oSection2, "TRANS"				, , 'Transportador'				, , TamSX3("A4_NOME")[1]+50		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection2, "MOTIVO_1"			, , 'Motivo'					, , 100		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection2, "MOTIVO_2"			, , 'Motivo Detalhado'			, , 300		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	
	oSection3 := TRSection():New(oSection1, "Devoluções_3",{})
	oSection3:SetTotalInLine(.F.)
	
	TRCell():New(oSection3, "ORIENTACAO"			, , 'Orientações'			, , 300		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
		
		
Return (oReport)
 
 
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(1):Section(1)
	Local oSection3 	:= oReport:Section(1):Section(2)
	
	
	Local cQuery		:= MontaQuery()
	Local cAliasTrab	:= GetNextAlias()
	Local cCodDev		:= ""
	Local aLista		:= GetSX5Tab("XD")
	Local nIndice		:= 0
	Local lExcel		:= (oReport:CXLSFILE <> NIL .Or. oReport:NEXCELPRINTTYPE == 3) 
	
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	oReport:SetMeter(cAliasTrab->(RecCount()))
	
	While !(cAliasTrab->(Eof()))
		
		If (oReport:Cancel())
			Exit
		EndIf
		
		
		oSection1:Init()
		oSection2:Init()
		oSection3:Init()
		
		
		oReport:IncMeter()
		
		cCodDev	:= cAliasTrab->NUM_DEV1
		
		oSection1:Cell("DATA"):SetValue(cvaltochar(DToC(cAliasTrab->DATA)))
		oSection1:Cell("NUM_DEV1"):SetValue(AllTrim(cAliasTrab->NUM_DEV1))
		oSection1:Cell("NUM_DEV2"):SetValue(AllTrim(cAliasTrab->NUM_DEV2))
		oSection1:Cell("CLIENTE"):SetValue(AllTrim(cAliasTrab->COD_CLI)+" - "+AllTrim(cAliasTrab->NOME_CLI))
		oSection1:Cell("REPRE"):SetValue(AllTrim(cAliasTrab->COD_VEN)+" - "+AllTrim(cAliasTrab->NOME_VEN))
		oSection1:Cell("RETORNO"):SetValue(GetDescRet(cAliasTrab->RETORNO))
		oSection1:Cell("PROD"):SetValue(AllTrim(cAliasTrab->COD_PROD)+" - "+AllTrim(cAliasTrab->NOME_PROD))		
		oSection1:Cell("QUANT"):SetValue(TRANSFORM(cAliasTrab->QUANT,"@E 999,999,999.99"))
		oSection1:Cell("QUANT"):SetAlign("CENTER")
		oSection1:Cell("PRECO"):SetValue(TRANSFORM(cAliasTrab->PRECO,"@E 999,999,999.99"))
		oSection1:Cell("PRECO"):SetAlign("CENTER")
		oSection1:Cell("TOTAL"):SetValue(TRANSFORM((cAliasTrab->QUANT*cAliasTrab->PRECO),"@E 999,999,999.99"))
		oSection1:Cell("TOTAL"):SetAlign("CENTER")
		
		
		oSection2:Cell("TRANS"):SetValue(AllTrim(cAliasTrab->COD_TRAN)+" - "+AllTrim(cAliasTrab->NOME_TRAN))
				
				
		nIndice = aScan(aLista, {|x| AllTrim(x[1]) == AllTrim(cAliasTrab->COD_MOTP)})
		If (nIndice > 0 .And. !Empty(cAliasTrab->COD_MOTP))
			oSection2:Cell("MOTIVO_1"):SetValue(aLista[nIndice][2])
		Else
			oSection2:Cell("MOTIVO_1"):SetValue("")
		EndIf
		oSection1:Printline()
	
		oSection2:Cell("MOTIVO_2"):SetValue(AllTrim(cAliasTrab->DESC_MOT))
		oSection2:Printline()
		
		If (!Empty(cAliasTrab->ORIENTACAO))
			oSection3:Cell("ORIENTACAO"):SetValue(AllTrim(cAliasTrab->ORIENTACAO))
			oSection3:Printline()
		EndIf		
						
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
		
		oReport:SkipLine()
		oReport:SkipLine() 
 		
 		cAliasTrab->(DbSkip())		
	EndDo
	
	cAliasTrab->(DbCloseArea())
	
Return

Static Function GetDescRet(cVal)
	
	If (AllTrim(cVal) == "S")
		Return "Sim"
	ElseIf(AllTrim(cVal) == "N")
		Return "Não"
	EndIf
	
Return ""


Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	
	cQuery += "	SELECT 						 	* FROM (					"+ Enter
	
	cQuery += "	SELECT  													"+ Enter
	cQuery += "	CONVERT(DATE, Z25_DTINI)		AS DATA,					"+ Enter
	cQuery += "	Z25_NUM							AS NUM_DEV1,        	    "+ Enter
	cQuery += "	ISNULL(NUMPRC, '')				AS NUM_DEV2,            	"+ Enter
	cQuery += "	ISNULL(A1_COD, '')				AS COD_CLI,					"+ Enter
	cQuery += "	ISNULL(A1_NOME, '')				AS NOME_CLI,    	        "+ Enter
	cQuery += "	ISNULL(A3_COD, '')				AS COD_VEN,		          	"+ Enter
	cQuery += "	ISNULL(A3_NOME, '')				AS NOME_VEN,	           	"+ Enter
	cQuery += "	ISNULL(A4_COD,'')				AS COD_TRAN,				"+ Enter
	cQuery += "	ISNULL(A4_NOME,'')				AS NOME_TRAN,       	    "+ Enter
	cQuery += "	B1_COD							AS COD_PROD,            	"+ Enter
	cQuery += "	B1_DESC							AS NOME_PROD,           	"+ Enter
	cQuery += "	Z26_NFISC						AS NFISCAL,             	"+ Enter
	cQuery += "	Z26_SERIE						AS SERIE,               	"+ Enter
	cQuery += "	Z26_QTDORI						AS QUANT,               	"+ Enter
	cQuery += "	Z25_RETMRC						AS RETORNO,		        	"+ Enter
	cQuery += "	D2_PRCVEN						AS PRECO,			 		"+ Enter
	
	cQuery += "	ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024), Z25_MOTIVO)),'') AS DESC_MOT,             "+ Enter
	cQuery += "	ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024), Z25_ORIENT)),'') AS ORIENTACAO,             "+ Enter
	
	cQuery += "	Z25_MOTIVP		AS COD_MOTP             					"+ Enter
	cQuery += "	                                        					"+ Enter
	cQuery += "	FROM "+RetSQLName("Z25")+" Z25          					"+ Enter
	cQuery += "	INNER	JOIN	"+RetSQLName("Z26")+"	Z26 ON	Z25.Z25_NUM		= Z26.Z26_NUMPRC	AND Z26.D_E_L_E_T_ = ''				"+ Enter
	cQuery += "	INNER	JOIN	"+RetSQLName("SB1")+"	SB1 ON	Z26.Z26_PROD	= SB1.B1_COD  		AND SB1.D_E_L_E_T_ = ''				"+ Enter
	
	cQuery += "	INNER	JOIN	"+RetSQLName("SD2")+"	SD2 ON	SD2.D2_DOC 		= Z26_NFISC 		AND SD2.D2_SERIE 	= Z26_SERIE		"+ Enter
	cQuery += " 											AND SD2.D2_COD 		= Z26_PROD			AND SD2.D2_ITEM 	= Z26_ITEMNF	"+ Enter
	cQuery += " 											AND SD2.D_E_L_E_T_ 	= '' 												 	"+ Enter
	
	
	cQuery += "	INNER 	JOIN 	"+RetSQLName("SA1")+"	SA1 ON	SA1.A1_COD		= Z25.Z25_CODCLI 	AND SA1.A1_LOJA	=	Z25.Z25_LOJCLI AND SA1.D_E_L_E_T_	= ''"+ Enter
	
	cQuery += " LEFT	JOIN	"+RetSQLName("SC5")+"	SC5 ON	SC5.C5_NOTA		= Z26.Z26_NFISC		AND SC5.C5_SERIE	= Z26.Z26_SERIE	AND SC5.D_E_L_E_T_	= ''"+ Enter
	cQuery += "	LEFT 	JOIN	"+RetSQLName("SA3")+"	SA3 ON	SC5.C5_VEND1	= SA3.A3_COD  		AND SA3.D_E_L_E_T_ = '' "+ Enter
	
	cQuery += "	LEFT	JOIN	"+RetSQLName("SA4")+"	SA4 ON	Z25.Z25_TRANSP	= SA4.A4_COD  		AND SA4.D_E_L_E_T_ = '' "+ Enter
	
	cQuery += " LEFT	JOIN (														"+ Enter
	cQuery += "		SELECT	 TOP 1  												"+ Enter
	cQuery += "			C5_YPEDORI AS PEDORI,										"+ Enter
	cQuery += "			Z26_NUMPRC AS NUMPRC  										"+ Enter
	cQuery += "		FROM SC5070 SC5_I												"+ Enter
	cQuery += "		INNER JOIN Z26070 Z26_I	ON Z26_I.Z26_NFISC = SC5_I.C5_NOTA AND Z26_I.Z26_SERIE = SC5_I.C5_SERIE AND Z26_I.D_E_L_E_T_ = ''	"+ Enter
	cQuery += "		WHERE															"+ Enter
	cQuery += "			Z26_I.Z26_PROD <> ''										"+ Enter
	cQuery += "		AND SC5_I.D_E_L_E_T_ = ''										"+ Enter
	cQuery += ") DLM ON (SC5.C5_NUM = PEDORI)										"+ Enter
	
	
	/*If (AllTrim(CEMPANT) $ '01_05')
		cQuery += " LEFT JOIN (														"+ Enter
		cQuery += "		SELECT  													"+ Enter
		cQuery += "			C5_YPEDORI AS PEDORI,									"+ Enter
		cQuery += "			Z26_NUMPRC AS NUMPRC,  									"+ Enter
		cQuery += "			C5_VEND1,			  									"+ Enter
		cQuery += "			A1_COD,													"+ Enter			
		cQuery += "			A1_NOME 												"+ Enter
		cQuery += "		FROM SC5070 SC5_I											"+ Enter
		cQuery += "		INNER JOIN Z26070 Z26_I	ON Z26_I.Z26_NFISC = SC5_I.C5_NOTA AND Z26_I.Z26_SERIE = SC5_I.C5_SERIE AND Z26_I.D_E_L_E_T_ = ''	"+ Enter
		cQuery += "		INNER JOIN SA1010 SA1_I	ON									"+ Enter
		cQuery += "									SA1_I.A1_COD			= (CASE WHEN SC5_I.C5_YCLIORI <> '' THEN SC5_I.C5_YCLIORI ELSE SC5_I.C5_CLIENTE END ) "+ Enter 
		cQuery += "									AND SA1_I.A1_LOJA		= (CASE WHEN SC5_I.C5_YCLIORI <> '' THEN SC5_I.C5_YLOJORI ELSE SC5_I.C5_LOJACLI END ) "+ Enter
		cQuery += "									AND SA1_I.D_E_L_E_T_	= ''	"+ Enter
		cQuery += "		WHERE														"+ Enter
		cQuery += "			Z26_I.Z26_PROD <> ''									"+ Enter
		cQuery += "		AND SC5_I.D_E_L_E_T_ = ''									"+ Enter
		cQuery += ") DLM ON (SC5.C5_NUM = PEDORI)									"+ Enter
		cQuery += "	LEFT JOIN "+RetSQLName("SA3")+" SA3 ON DLM.C5_VEND1	= SA3.A3_COD  		AND SA3.D_E_L_E_T_ = '' "+ Enter
	
	Else
		cQuery += "	INNER JOIN SA1010 SA1	ON									"+ Enter
		cQuery += "									SA1.A1_COD			= (CASE WHEN SC5.C5_YCLIORI <> '' THEN SC5.C5_YCLIORI ELSE SC5.C5_CLIENTE END ) "+ Enter 
		cQuery += "									AND SA1.A1_LOJA		= (CASE WHEN SC5.C5_YCLIORI <> '' THEN SC5.C5_YLOJORI ELSE SC5.C5_LOJACLI END ) "+ Enter
		cQuery += "									AND SA1.D_E_L_E_T_	= ''		"+ Enter
		cQuery += "	LEFT JOIN "+RetSQLName("SA3")+" SA3 ON SC5.C5_VEND1	= SA3.A3_COD  		AND SA3.D_E_L_E_T_ = '' "+ Enter
	EndIf*/
	
	
	cQuery += "	WHERE Z25.D_E_L_E_T_ = '' "+ Enter
	
		
	If (!Empty(dDataI) .And. !Empty(dDataF))
		cQuery += "	AND Z25_DTINI BETWEEN  '"+dDataI+"' AND '"+dDataF+"' 				"+ Enter
	EndIf
	
	If (!Empty(cProdI) .And. !Empty(cProdF))
		cQuery += "	AND B1_COD BETWEEN  '"+cProdI+"' AND '"+cProdF+"' 					"+ Enter
	EndIf
	
	If (!Empty(cCliI) .And. !Empty(cCliF))
		cQuery += "	AND A1_COD	BETWEEN  '"+cCliI+"' AND '"+cCliF+"' 					"+ Enter
	EndIf
	
	If (!Empty(cNotaI) .And. !Empty(cNotaF))
		cQuery += "	AND Z26_NFISC BETWEEN  '"+cNotaI+"' AND '"+cNotaI+"' 				"+ Enter
	EndIf
		
	If (!Empty(cSerie))
		cQuery += "	AND Z26_SERIE = '"+cSerie+"'	 			 						"+ Enter
	EndIf
		
	
	cQuery += "	) A																		"+ Enter	
	cQuery += "	ORDER BY DATA, NOME_CLI						 							"+ Enter	
		
Return cQuery


Static Function GetSX5Tab(cTabela)
	
	Local aAreaSX5 	:= SX5->(GetArea())
	Local _aLista	:= {}
		
	DbSelectArea('SX5')
	SX5->(DbSetOrder(1))
	If (SX5->(DbSeek(xFilial('SX5')+cTabela)))
		While (!SX5->(Eof()) .And. SX5->X5_TABELA == cTabela)
			Aadd(_aLista, {AllTrim(SX5->X5_CHAVE), AllTrim(SX5->X5_DESCRI)})
			SX5->(DbSkip())
		EndDo
	EndIf
	
	SX5->(DbCloseArea())
	
	SX5->(RestArea(aAreaSX5))
		
Return _aLista
