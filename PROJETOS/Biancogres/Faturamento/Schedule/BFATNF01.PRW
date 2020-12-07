#Include "Protheus.CH"
#Include "TOTVS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"


User Function BFATNF01()
	
	Local oReport	:= Nil
	Local cLoad	    := "BFATNF01" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	
	Private dDataI	:= Nil
	Private dDataF	:= NiL
	Private cCliI	:= Nil
	Private cCliF	:= Nil
	Private cNotaI	:= Nil
	Private cNotaF	:= Nil
	Private cSerie	:= Nil
	
	Private MV_PAR01 := STOD('')
	Private MV_PAR02 := STOD('')
	Private MV_PAR03 := Space(6)
	Private MV_PAR04 := Space(6)
	Private MV_PAR05 := Space(9)
	Private MV_PAR06 := Space(9)
	Private MV_PAR07 := Space(3)
	
	Private aPergs := {}
	
	aAdd( aPergs ,{1,"Da data" 	   			,MV_PAR01 ,""  ,"", ''		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até data" 	   		,MV_PAR02 ,""  ,"", '' 		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Do cliente" 	   		,MV_PAR03 ,""  ,"", 'SA1'	,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até cliente" 	   		,MV_PAR04 ,""  ,"", 'SA1'	,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Da NF" 	   			,MV_PAR05 ,""  ,"", ''  	,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Até NF" 	   			,MV_PAR06 ,""  ,"", ''  	,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Série" 	   			,MV_PAR07 ,""  ,"", ''  	,'.T.',50,.F.})
	
	If ParamBox(aPergs ,"Filtro de nota fiscal.",,,,,,,,cLoad,.T.,.T.)

		MV_PAR01 := ParamLoad(cFileName,	,	1,	MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,	,	2,	MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,	,	3,	MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,	,	4,	MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,	,	5,	MV_PAR05) 
		MV_PAR06 := ParamLoad(cFileName,	,	6,	MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,	,	7,	MV_PAR07)
		
		dDataI	:= IIF(!Empty(MV_PAR01), DTOS(MV_PAR01), MV_PAR01)
		dDataF	:= IIF(!Empty(MV_PAR02), DTOS(MV_PAR02), MV_PAR02)
		cCliI	:= MV_PAR03
		cCliF	:= MV_PAR04
		cNotaI	:= MV_PAR05
		cNotaF	:= MV_PAR06
		cSerie	:= MV_PAR07
			
		oReport := reportDef()
		oReport:printDialog()
					
	EndIf
		
Return 


Static Function reportDef()
	
	Local oReport	:= Nil	
	Local oSection1	:= Nil
	Local cTitulo 	:= 'NFe Canceladas'
 
	oReport := TReport():New('BFATNF01', cTitulo, , {|oReport| PrintReport(oReport)},"Este relatorio ira imprimir as notas canceladas.")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "NFE_CANCELADAS",{})
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1, "NUMERO_NF"			, , 'Número'				, , TamSX3("F3_NFISCAL")[1]+5		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "SERIE"				, , 'Série'					, , TamSX3("F3_SERIE")[1]+5			,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "CLIENTE"			, , 'Cliente'				, , TamSX3("A1_NOME")[1]+10			,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "LOJA"				, , 'Loja'					, , TamSX3("A1_LOJA")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "VALOR"				, , 'Valor'					, , TamSX3("F2_VALBRUT")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/, , , 'CENTER', , , , , , .T.)	
	TRCell():New(oSection1, "ESTADO"			, , 'Estado'				, , TamSX3("F3_ESTADO")[1]			,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "TIPO"				, , 'Tipo'					, , TamSX3("F2_TIPO")[1]+5			,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "MOTIVO"			, , 'Motivo'				, , 60								,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "CHAVE"				, , 'Chave'					, , TamSX3("F3_CHVNFE")[1]+10		,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
	TRCell():New(oSection1, "USUARIO"			, , 'Usuário'				, , 50								,/*lPixel*/,/*{|| code-block de impressao }*/, , , , , , , , , .T.)	
		
	
Return (oReport)
 
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	Local cQuery		:= MontaQuery()
	Local cAliasTrab	:= GetNextAlias()
	Local aLista		:= GetSX5Tab("ZY")
	Local cCodUser		:= ""
	Local cNomeUser		:= ""
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	oReport:SetMeter(cAliasTrab->(RecCount()))
	oSection1:Init()
	
	While !(cAliasTrab->(Eof()))
		
		If (oReport:Cancel())
			Exit
		EndIf
		
		oReport:IncMeter()
		
		oSection1:Cell("NUMERO_NF"):SetValue(AllTrim(cAliasTrab->NUMERO_NF))
		oSection1:Cell("SERIE"):SetValue(AllTrim(cAliasTrab->SERIE))
		oSection1:Cell("CLIENTE"):SetValue(AllTrim(cAliasTrab->COD_CLI)+" - "+AllTrim(cAliasTrab->NOME_CLI))
		oSection1:Cell("LOJA"):SetValue(AllTrim(cAliasTrab->LOJA_CLI))
		
		oSection1:Cell("VALOR"):SetValue(cvaltochar(TRANSFORM(cAliasTrab->VALOR,"@E 999,999,999.99")))
		oSection1:Cell("VALOR"):SetAlign("CENTER")
			
		oSection1:Cell("ESTADO"):SetValue(AllTrim(cAliasTrab->ESTADO))
		oSection1:Cell("TIPO"):SetValue(AllTrim(cAliasTrab->TIPO))
		
		nIndice = aScan(aLista, {|x| AllTrim(x[1]) == AllTrim(cAliasTrab->MOTIVO)})
		oSection1:Cell("MOTIVO"):SetValue("")
		If (nIndice > 0 .And. !Empty(cAliasTrab->MOTIVO))
			oSection1:Cell("MOTIVO"):SetValue(aLista[nIndice][2])
		EndIf
		
		oSection1:Cell("CHAVE"):SetValue(cAliasTrab->CHAVE)
		
		cCodUser	:= SUBSTR(EMBARALHA(cAliasTrab->USUARIO_A,1),3,6)
		cNomeUser	:= USRFULLNAME(cCodUser)
		cUsuario	:= AllTrim(cNomeUser)
		
		oSection1:Cell("USUARIO"):SetValue("")
		If (!Empty(cCodUser))
			oSection1:Cell("USUARIO"):SetValue(cvaltochar(cUsuario))
		EndIf
		
		oSection1:Printline()
		oReport:SkipLine() 
 		
		cAliasTrab->(DbSkip())
		
	EndDo
	
	oSection1:Finish()
		
	cAliasTrab->(DbCloseArea())
	
Return



Static Function MontaQuery()
	
	Local cQuery	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	Local nI		:= 0
	Local aEmpresa  := {'01','05','07'}
	Local cCodEmp	:= ""
	
	cQuery += " SELECT 	* FROM ( 													"+ Enter						
	
	For nI:=1 To Len (aEmpresa)
		
		cCodEmp := 	aEmpresa[nI]
		
		cQuery += " SELECT 		 															"+ Enter						
		cQuery += " '"+cCodEmp+"' 				AS EMPRESA,									"+ Enter
		cQuery += " F3_EMISSAO					AS DATA_EMI,								"+ Enter
		cQuery += " F3_NFISCAL					AS NUMERO_NF,								"+ Enter
		cQuery += " F3_SERIE					AS SERIE,									"+ Enter
		cQuery += " A1_COD						AS COD_CLI,									"+ Enter
		cQuery += " A1_NOME						AS NOME_CLI,								"+ Enter	
		cQuery += " A1_LOJA						AS LOJA_CLI,								"+ Enter	
		cQuery += " F3_USERLGA					AS USUARIO_A,								"+ Enter
		cQuery += " F3_ESTADO					AS ESTADO,									"+ Enter
		cQuery += " F3_CHVNFE					AS CHAVE,									"+ Enter
		cQuery += " F3_YMOTIVO					AS MOTIVO,									"+ Enter
		cQuery += " F2_TIPO						AS TIPO,									"+ Enter
		cQuery += " F2_VALBRUT					AS VALOR									"+ Enter
				
		cQuery += " FROM SF3"+cCodEmp+"0 SF3												"+ Enter	
		
		cQuery += " INNER JOIN SF2"+cCodEmp+"0 SF2 ON (										"+ Enter
		cQuery += "			F3_FILIAL 	= F2_FILIAL		AND									"+ Enter
		cQuery += "			F3_NFISCAL 	= F2_DOC		AND 								"+ Enter
		cQuery += "			F3_SERIE 	= F2_SERIE		AND 								"+ Enter
		cQuery += "			F3_CLIEFOR 	= F2_CLIENTE 	AND									"+ Enter
		cQuery += "			F3_LOJA 	= F2_LOJA		 									"+ Enter
		cQuery += "			)																"+ Enter
		
		cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_COD = SF3.F3_CLIEFOR AND SA1.A1_LOJA = SF3.F3_LOJA "+ Enter 
		cQuery += " WHERE 																	"+ Enter			
		cQuery += "	SF3.D_E_L_E_T_ 		= '' 												"+ Enter
		cQuery += " AND SF3.F3_DTCANC	<> ''												"+ Enter
		cQuery += " AND SF3.F3_CHVNFE	<> ''												"+ Enter	
		cQuery += " AND SA1.A1_COD NOT IN ('000481', '004536', '018410', '014395', '008615')	"+ Enter						
	
		If (nI < Len(aEmpresa))
			cQuery += " UNION ALL	 												"+ Enter						
		EndIf
	Next nI
	
	cQuery += " ) A		 															"+ Enter						
	
	cQuery += " WHERE 1=1															"+ Enter						
	
	If (!Empty(dDataI) .And. !Empty(dDataF))
		cQuery += "	AND DATA_EMI BETWEEN  '"+dDataI+"' AND '"+dDataF+"' 			"+ Enter
	EndIf
	
	If (!Empty(cCliI) .And. !Empty(cCliF))
		cQuery += "	AND COD_CLI BETWEEN  '"+cCliI+"' AND '"+cCliF+"' 				"+ Enter
	EndIf
	
	If (!Empty(cNotaI) .And. !Empty(cNotaF))
		cQuery += "	AND NUMERO_NF BETWEEN  '"+cNotaI+"' AND '"+cNotaI+"' 			"+ Enter
	EndIf
		
	If (!Empty(cSerie))
		cQuery += "	AND SERIE = '"+cSerie+"'	 			 						"+ Enter
	EndIf
	
	cQuery += " ORDER BY EMPRESA, NOME_CLI											"+ Enter						
	
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