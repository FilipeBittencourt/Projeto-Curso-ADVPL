#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


User Function BIAFPH02()

	Local lEnd			:= .F.
	Local aPergs		:= {}
	Local cRefPer	  	:= 'BIAFPH02' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private oExcel
	Private cArqXML    	:= "RELATORIO_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	Private cTitulo		:= "Relatório"

	Private cEmpresa   	:= StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.") 

	Private cFonte1	 	:= 'Calibri'
	Private nTamFont1	:= 12   
	Private cCorFont1  	:= '#FFFFFF'
	Private cCorFun1	:= '#000066'

	Private cFonte2	 	:= 'Calibri' 
	Private nTamFont2	:= 12   
	Private cCorFont2  	:= '#FFFFFF'
	Private cCorFun2	:= '#3333FF'

	Private cFonte3	 	:= 'Calibri'
	Private nTamFont3	:= 8   
	Private cCorFont3  	:= '#000000'
	Private cCorFun3	:= '#FFFFFF'

	Private cWhite		:= '#FFFFFF'
	Private cLGray		:= '#9494E7'

	Private aColsAnt	:= {}
	Private aColsProx	:= {}

	//Privates para ParamBox
	Private aRetPerg   := {ctod(" "), ctod(" "), "",}
	
	Private cDataIni	:= STOD('')                                  
	Private cDataFim	:= STOD('')   
	Private cDirDest	:= Space(200)
	
	aAdd( aPergs ,{1, "Date de:"					,cDataIni  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1, "Date até:"				,cDataFim  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{6, "Pasta Destino: " 			,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )


	If !ParamBox(aPergs ,"", aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	cDataIni			:= DTOS(ParamLoad(cFileName,,1 	, cDataIni)) 
	cDataFim   			:= DTOS(ParamLoad(cFileName,,2 	, cDataFim)) 
	cDirDest			:= ParamLoad(cFileName,, 3	, cDirDest)

	oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
	oProcess:Activate()

Return


Static Function fImprime(lEnd)

	Local cQuery	:= ""
	Private oExcel	:= ARSexcel():New()
	
	If Empty(cDirDest) .or. !ExistDir(cDirDest)	
		cDirDest := Alltrim(GetTempPath()) 
	EndIf

	MontaCabP1()
	MontaLinP1()
	
	MontaCabPR("Req. - Polimento e Ret. Umido")
	cQuery := MontaQP2()
	MontaLinPR(cQuery)
	
	//---------------------------------//
	

	MontaCabPR("Prod. - Retifica Seca E1A")
	cQuery := MontaQP3('E1A')
	MontaLinPR(cQuery)
	
	MontaCabPR("Req. - Retifica Seca E1A")
	cQuery := MontaQP4('E1A',  '107A/107E', '3135')
	MontaLinPR(cQuery)
	
	//---------------------------------//
	
	MontaCabPR("Prod. - Retifica Seca E3A")
	cQuery := MontaQP3('E3A')
	MontaLinPR(cQuery)
	
	MontaCabPR("Req. - Retifica Seca E3A")
	cQuery := MontaQP4('E3A',  '107A/107E', '3117')
	MontaLinPR(cQuery)
	
	
	MontaAbaPar()

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

Return


Static Function MontaCabP1()

	Local aColLen := {100, 100, 100, 100, 200, 100, 100, 100, 100, 100, 100, 100, 100, 100}
	Local cDescTi := ""
	
	oExcel:AddPlanilha('Producao - Polimento e Ret. Umido',aColLen)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1)  

	oExcel:AddLinha(30)
	oExcel:AddLinha(12) 

	
	oExcel:AddCelula("Filial"							,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Almoxarifado"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Dia"								,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod. Produto"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome Produto"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Qtd. Produzida"					,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	
	oExcel:AddCelula("Custo M2 Abrasivo" 				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo Total Abrasivo"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo M2 Impermeabilizante"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo Total Impermeabilizante"	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo Ferramentas M2"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Total Ferramentas M2"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo ETE M2"	   	   				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo Total ETE"	   	   			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 

Return


Static Function MontaLinP1()

	Local cAliasTrab	:= GetNextAlias()
	Local cCorF 		:= cWhite
	Local cQuery		:= MontaQP1()
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	While !(cAliasTrab->(Eof()))

		oExcel:AddLinha(12)
		
		oExcel:AddCelula(cAliasTrab->FILIAL											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(cAliasTrab->ALMOX											,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(DTOC(STOD(cAliasTrab->DT_EMIS))							,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->COD_PROD										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NOME_PROD										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM(cAliasTrab->QUANTIDADE,"@E 999,999,999.99")										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		
		
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO_ABRA	,"@E 999,999,999.99")									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM((cAliasTrab->QUANTIDADE * cAliasTrab->CUSTO_ABRA)	,"@E 999,999,999.99")		,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO_IMP		,"@E 999,999,999.99")								,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM((cAliasTrab->QUANTIDADE * cAliasTrab->CUSTO_IMP)	,"@E 999,999,999.99")			,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO_FERR	,"@E 999,999,999.99")									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM((cAliasTrab->QUANTIDADE * cAliasTrab->CUSTO_FERR)	,"@E 999,999,999.99")		,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO_ETE	,"@E 999,999,999.99")									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM((cAliasTrab->QUANTIDADE * cAliasTrab->CUSTO_ETE)	,"@E 999,999,999.99")			,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		
		cAliasTrab->(DbSkip())
	EndDo
	cAliasTrab->(DbCloseArea())

Return


Static Function MontaQP1()
	
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	
	cQuery += "	SELECT *,									"+ Enter 
	cQuery += "	CASE WHEN TOTAL_ABRA <> 0 THEN (QUANTIDADE/TOTAL_ABRA)	ELSE 0 END	AS CUSTO_ABRA, 	"+ Enter 
	cQuery += "	CASE WHEN TOTAL_IMP <> 0 THEN (QUANTIDADE/TOTAL_IMP)	ELSE 0 END	AS CUSTO_IMP, 	"+ Enter 
	cQuery += "	CASE WHEN TOTAL_FERR <> 0 THEN (QUANTIDADE/TOTAL_FERR)	ELSE 0 END	AS CUSTO_FERR, 	"+ Enter 
	cQuery += "	CASE WHEN TOTAL_ETE <> 0 THEN (QUANTIDADE/TOTAL_ETE)	ELSE 0 END	AS CUSTO_ETE	"+ Enter 
	cQuery += "	FROM (										"+ Enter 
	cQuery += "	SELECT 										"+ Enter 
	cQuery += "		D3_FILIAL			AS FILIAL, 			"+ Enter 
	cQuery += "		D3_LOCAL			AS ALMOX, 			"+ Enter 
	cQuery += "		D3_EMISSAO			AS DT_EMIS, 		"+ Enter 
	cQuery += "		D3_COD				AS COD_PROD, 		"+ Enter 
	cQuery += "		B1_DESC				AS NOME_PROD,		"+ Enter 
	cQuery += "		SUM(D3_QUANT)		AS QUANTIDADE,		"+ Enter 
	cQuery += "												"+ Enter 
	cQuery += "		ISNULL((SELECT SUM(D3_QUANT) FROM SD3010 SD3_I"+ Enter 
	
	cQuery += "	JOIN SC2010 SC2 ON "+ Enter 
	cQuery += "		SC2.C2_NUM					= SUBSTRING(SD3_I.D3_OP,1,6)				"+ Enter 
	cQuery += "		AND SC2.C2_ITEM				= SUBSTRING(SD3_I.D3_OP,7,2)				"+ Enter 
	cQuery += "		AND SC2.C2_SEQUEN			= SUBSTRING(SD3_I.D3_OP,9,3)				"+ Enter 
	cQuery += "		AND SC2.D_E_L_E_T_			= ''										"+ Enter 
	cQuery += "		AND SC2.C2_LINHA			= 'E3B'										"+ Enter 
	
	cQuery += "		WHERE "+ Enter 
	cQuery += "		--SD3_I.D3_LOCAL			= '07'		"+ Enter 
	cQuery += "		SD3_I.D_E_L_E_T_			= ''		"+ Enter 
	cQuery += "		AND SD3_I.D3_ESTORNO		= ''		"+ Enter 
	cQuery += "		AND SD3_I.D3_EMISSAO		= SD3.D3_EMISSAO"+ Enter 
	cQuery += "		AND SD3_I.D3_GRUPO				= '107B'), 0) AS TOTAL_ABRA,"+ Enter 
	cQuery += "		0	AS TOTAL_IMP,										"+ Enter 
	cQuery += "		ISNULL((SELECT SUM(D3_QUANT) FROM SD3010 SD3_I			"+ Enter 
	
	cQuery += "	JOIN SC2010 SC2 ON "+ Enter 
	cQuery += "		SC2.C2_NUM					= SUBSTRING(SD3_I.D3_OP,1,6)				"+ Enter 
	cQuery += "		AND SC2.C2_ITEM				= SUBSTRING(SD3_I.D3_OP,7,2)				"+ Enter 
	cQuery += "		AND SC2.C2_SEQUEN			= SUBSTRING(SD3_I.D3_OP,9,3)				"+ Enter 
	cQuery += "		AND SC2.D_E_L_E_T_			= ''										"+ Enter 
	cQuery += "		AND SC2.C2_LINHA			= 'E3B'										"+ Enter 
	
	cQuery += "		WHERE "+ Enter 
	cQuery += "		--SD3_I.D3_LOCAL			= '07'						"+ Enter 
	cQuery += "		SD3_I.D_E_L_E_T_			= ''						"+ Enter 
	cQuery += "		AND SD3_I.D3_ESTORNO		= ''						"+ Enter 
	cQuery += "		AND SD3_I.D3_EMISSAO		= SD3.D3_EMISSAO			"+ Enter 
	cQuery += "		AND SD3_I.D3_GRUPO			IN ('107A', '107E')			"+ Enter 
	cQuery += "		AND SD3_I.D3_CLVL			= '3136'), 0)  AS TOTAL_FERR,"+ Enter 
	cQuery += "		0	AS TOTAL_ETE"+ Enter 
	cQuery += "	"+ Enter 
	cQuery += "	FROM SD3010 SD3"+ Enter 
	cQuery += "	JOIN SB1010 SB1 ON "+ Enter 
	cQuery += "		SD3.D3_COD			= SB1.B1_COD "+ Enter 
	cQuery += "		AND SB1.D_E_L_E_T_	= ''"+ Enter 
	cQuery += "	JOIN SC2010 SC2 ON "+ Enter 
	cQuery += "		SC2.C2_NUM					= SUBSTRING(SD3.D3_OP,1,6)"+ Enter 
	cQuery += "		AND SC2.C2_ITEM				= SUBSTRING(SD3.D3_OP,7,2)"+ Enter 
	cQuery += "		AND SC2.C2_SEQUEN			= SUBSTRING(SD3.D3_OP,9,3)"+ Enter 
	cQuery += "		AND SC2.D_E_L_E_T_		= ''"+ Enter 
	cQuery += "		"+ Enter 
	cQuery += "	WHERE "+ Enter 
	
	cQuery += "		SD3.D_E_L_E_T_		= ''						"+ Enter 
	cQuery += "		AND SD3.D3_ESTORNO		= ''					"+ Enter 
	cQuery += "		AND SD3.D3_TM			= '010'					"+ Enter 
	cQuery += "		AND SB1.B1_TIPO			= 'PA'					"+ Enter 
	cQuery += "		AND SC2.C2_LINHA		= 'E3B'					"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND D3_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 		"+ Enter
	EndIf
	
	
	cQuery += "	GROUP BY D3_FILIAL, D3_LOCAL, D3_COD, B1_DESC, D3_EMISSAO"+ Enter 
	cQuery += "	"+ Enter 
	cQuery += "	) A"+ Enter 
	cQuery += "	ORDER BY DT_EMIS, NOME_PROD"+ Enter 
	
Return cQuery



Static Function MontaQP2()
	
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	
	cQuery += " SELECT *, 	 	 	"+ Enter 
	cQuery += " CASE WHEN QUANTIDADE <> 0 THEN (CUSTO_TOT/QUANTIDADE)	ELSE 0 END	AS CUSTO"+ Enter 
	cQuery += " FROM (	 	 																"+ Enter 
	cQuery += " SELECT  	 	 															"+ Enter 
	cQuery += " D3_FILIAL			AS FILIAL, 			 									"+ Enter 
	cQuery += " D3_LOCAL			AS ALMOX, 			 									"+ Enter 
	cQuery += " D3_EMISSAO			AS DT_EMIS, 		 									"+ Enter 
	cQuery += " D3_COD				AS COD_PROD,	 	 									"+ Enter 
	cQuery += " B1_DESC				AS NOME_PROD,	 	 									"+ Enter 
	cQuery += " D3_CUSTO1			AS CUSTO_TOT,	 	 									"+ Enter 
	cQuery += " D3_GRUPO			AS GRUPO,		 	 									"+ Enter 
	cQuery += " SUM(D3_QUANT)		AS QUANTIDADE,	 	 									"+ Enter 
	cQuery += " 	 	 																	"+ Enter 
	cQuery += " ISNULL((SELECT TOP 1 B9_CM1 FROM SB9010 SB9									"+ Enter 
	cQuery += " WHERE 	 	 																"+ Enter 
	cQuery += " SB9.B9_COD			 = D3_COD	 	 										"+ Enter 
	cQuery += " AND CONVERT(date, SB9.B9_DATA) = EOMONTH (DATEADD (m, -1, D3_EMISSAO ))	 	"+ Enter 
	cQuery += " AND SB9.B9_LOCAL	= D3_LOCAL	 	 										"+ Enter 
	cQuery += " AND B9_FILIAL		= D3_FILIAL	 	 										"+ Enter 
	cQuery += " AND SB9.D_E_L_E_T_	= ''	 	 											"+ Enter 
	cQuery += " ), 0) AS CUSTO_ULT	 	 													"+ Enter 
	cQuery += " 	 	 																	"+ Enter 
	cQuery += " FROM (	 	 																"+ Enter 
	cQuery += " SELECT * FROM SD3010 SD3	 	 											"+ Enter 
	cQuery += " 		WHERE	 	 														"+ Enter 
	cQuery += " 		SD3.D_E_L_E_T_			= ''			 	 						"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND SD3.D3_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 			"+ Enter
	EndIf
	
	cQuery += " 		AND SD3.D3_ESTORNO			= ''			 	 					"+ Enter 
	cQuery += " 		AND SD3.D3_GRUPO			= '107B'	 	 						"+ Enter 
	cQuery += " 		AND SD3.D3_CF				= 'RE0'		 	 						"+ Enter 
	
	cQuery += " UNION ALL	 	 															"+ Enter 
	cQuery += " SELECT * FROM SD3010 SD3													"+ Enter 
	
	cQuery += " 		WHERE	 	 														"+ Enter 
	cQuery += " 		SD3.D_E_L_E_T_		= ''											"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND SD3.D3_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 				"+ Enter
	EndIf

	cQuery += " 		AND SD3.D3_ESTORNO		= ''					 	 					"+ Enter 
	cQuery += " 		AND SD3.D3_GRUPO		IN ('107A', '107E')								"+ Enter 
	cQuery += " 		AND SD3.D3_CLVL			= '3136'	 	 								"+ Enter 
	cQuery += " 		AND SD3.D3_CF			= 'RE0'		 	 								"+ Enter 
	
	
	cQuery += " ) A	 	 																		"+ Enter 
	cQuery += " JOIN SB1010 SB1 ON 	 	 														"+ Enter 
	cQuery += " 	A.D3_COD			= SB1.B1_COD 	 	 									"+ Enter 
	cQuery += " 	AND SB1.D_E_L_E_T_	= ''	 	 											"+ Enter 
	
	
	
	cQuery += " GROUP BY D3_FILIAL, D3_LOCAL, D3_COD, B1_DESC, D3_EMISSAO, D3_CUSTO1,D3_GRUPO	"+ Enter 
	cQuery += " ) B	 	 	"+ Enter 
	
			
Return cQuery


Static Function MontaQP3(cTipo)
	
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	
	cQuery += " SELECT *,																			 		 	 	"+ Enter 
	cQuery += " CASE WHEN QUANTIDADE <> 0 THEN (CUSTO_TOT/QUANTIDADE)	ELSE 0 END	AS CUSTO	 	 		 	 	"+ Enter 
	cQuery += " FROM (	 	 		 	 										"+ Enter 
	cQuery += " SELECT										 	 		 	 	"+ Enter 
	cQuery += " D3_FILIAL			AS FILIAL, 				 	 		 	 	"+ Enter 
	cQuery += " D3_LOCAL			AS ALMOX, 				 	 		 	 	"+ Enter 
	cQuery += " D3_EMISSAO			AS DT_EMIS, 			 	 		 	 	"+ Enter 
	cQuery += " D3_COD				AS COD_PROD, 	 	 				 	 	"+ Enter 
	cQuery += " B1_DESC				AS NOME_PROD,	 	 				 	 	"+ Enter 
	cQuery += " D3_CUSTO1			AS CUSTO_TOT,	 	 				 	 	"+ Enter 
	cQuery += " D3_GRUPO			AS GRUPO,	 	 		 			 		"+ Enter 
	cQuery += " SUM(D3_QUANT)		AS QUANTIDADE,	 	 				 	 	"+ Enter 
	cQuery += " 	 	 		 	 											"+ Enter 		
	cQuery += " ISNULL((SELECT TOP 1 B9_CM1 FROM SB9010 SB9	 			 		"+ Enter 
	cQuery += " WHERE 	 	 		 	 										"+ Enter 		
	cQuery += " SB9.B9_COD			 = D3_COD	 	 		 			 		"+ Enter 
	cQuery += " AND CONVERT(date, SB9.B9_DATA) = EOMONTH (DATEADD (m, -1, D3_EMISSAO ))	 	 		 	 	"+ Enter 
	cQuery += " AND SB9.B9_LOCAL	= D3_LOCAL	 	 		 	 						"+ Enter 
	cQuery += " AND B9_FILIAL		= D3_FILIAL), 0) AS CUSTO_ULT	 	 		 	 	"+ Enter 
	cQuery += " 	 	 		 	 											"+ Enter 
	cQuery += " 	 	 		 	 											"+ Enter 
	cQuery += " FROM SD3010 SD3	 	 		 	 								"+ Enter 
	cQuery += " JOIN SB1010 SB1 ON 	 	 		 	 							"+ Enter 
	cQuery += " 	SD3.D3_COD = SB1.B1_COD	 	 		 	 					"+ Enter 
	cQuery += " 	AND SB1.D_E_L_E_T_ = ''	 	 		 	 					"+ Enter 
	cQuery += " 	 	 		 	 											"+ Enter 
	cQuery += " JOIN SC2010 SC2 ON 	 	 		 	 							"+ Enter 
	cQuery += " 	C2_NUM				= SUBSTRING(SD3.D3_OP,1,6)	 	 		"+ Enter 
	cQuery += " 	AND C2_ITEM			= SUBSTRING(SD3.D3_OP,7,2)	 	 		"+ Enter 
	cQuery += " 	AND C2_SEQUEN		= SUBSTRING(SD3.D3_OP,9,3)	 	 		"+ Enter 
	cQuery += " 	AND SC2.D_E_L_E_T_	= ''	 	 		 	 				"+ Enter 
	cQuery += " 	 	 		 	 											"+ Enter 
	cQuery += " WHERE 													 	 	"+ Enter 
	cQuery += " 	SD3.D_E_L_E_T_		= ''	 		 		 	 			"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND SD3.D3_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 				"+ Enter
	EndIf
	
	cQuery += " 	AND SD3.D3_ESTORNO		= ''	 	 		 	 			"+ Enter 
	cQuery += " 	AND SD3.D3_TM			= '010'	 	 		 	 			"+ Enter 
	cQuery += " 	AND SB1.B1_TIPO			= 'PA'	 	 		 	 			"+ Enter 
	cQuery += " 	AND SC2.C2_LINHA		= '"+cTipo+"'	 	 		 	 			"+ Enter 
	cQuery += " GROUP BY D3_FILIAL, D3_LOCAL, D3_COD, B1_DESC, D3_EMISSAO, D3_CUSTO1,D3_GRUPO	 	 		 	 	"+ Enter 
	cQuery += " ) A	 	 		 	 							"+ Enter 
	cQuery += " ORDER BY DT_EMIS, NOME_PROD	 	 		 	 	"+ Enter 
			
Return cQuery


Static Function MontaQP4(cTipo, cGrupos, cClVl)
	
	Local cQuery		:= ""
	Local Enter			:= CHR(13)+CHR(10)
	
	cQuery += " SELECT *, 	 	 	"+ Enter 
	cQuery += " CASE WHEN QUANTIDADE <> 0 THEN (CUSTO_TOT/QUANTIDADE)	ELSE 0 END	AS CUSTO"+ Enter 
	cQuery += " FROM (	 	 																"+ Enter 
	cQuery += " SELECT  	 	 															"+ Enter 
	cQuery += " D3_FILIAL			AS FILIAL, 			 									"+ Enter 
	cQuery += " D3_LOCAL			AS ALMOX, 			 									"+ Enter 
	cQuery += " D3_EMISSAO			AS DT_EMIS, 		 									"+ Enter 
	cQuery += " D3_COD				AS COD_PROD,	 	 									"+ Enter 
	cQuery += " B1_DESC				AS NOME_PROD,	 	 									"+ Enter 
	cQuery += " D3_CUSTO1			AS CUSTO_TOT,	 	 									"+ Enter 
	cQuery += " D3_GRUPO			AS GRUPO,		 	 									"+ Enter 
	cQuery += " SUM(D3_QUANT)		AS QUANTIDADE,	 	 									"+ Enter 
	cQuery += " 	 	 																	"+ Enter 
	cQuery += " ISNULL((SELECT TOP 1 B9_CM1 FROM SB9010 SB9									"+ Enter 
	cQuery += " WHERE 	 	 																"+ Enter 
	cQuery += " SB9.B9_COD			 = D3_COD	 	 										"+ Enter 
	cQuery += " AND CONVERT(date, SB9.B9_DATA) = EOMONTH (DATEADD (m, -1, D3_EMISSAO ))	 	"+ Enter 
	cQuery += " AND SB9.B9_LOCAL	= D3_LOCAL	 	 										"+ Enter 
	cQuery += " AND B9_FILIAL		= D3_FILIAL	 	 										"+ Enter 
	cQuery += " AND SB9.D_E_L_E_T_	= ''	 	 											"+ Enter 
	cQuery += " ), 0) AS CUSTO_ULT	 	 													"+ Enter 
	cQuery += " 	 	 																	"+ Enter 
	cQuery += " FROM (	 	 																"+ Enter 
	
	cQuery += " SELECT * FROM SD3010 SD3													"+ Enter 
	
	cQuery += " 		WHERE	 	 														"+ Enter 
	cQuery += " 		SD3.D_E_L_E_T_		= ''											"+ Enter 
	
	If (!Empty(cDataIni) .And. !Empty(cDataFim))
		cQuery += "	AND SD3.D3_EMISSAO BETWEEN  '"+cDataIni+"' AND '"+cDataFim+"' 				"+ Enter
	EndIf
				
	cQuery += " 		AND SD3.D3_GRUPO		IN " + FormatIn(cGrupos, "/") + "				"+ Enter 
	cQuery += " 		AND SD3.D3_CLVL			= '"+cClVl+"' 	 								"+ Enter 
	cQuery += " 		AND SD3.D3_CF			= 'RE0'		 	 								"+ Enter 
	cQuery += " 		AND SD3.D3_ESTORNO		= ''			 	 					"+ Enter 
	
	cQuery += " ) A	 	 																		"+ Enter 
	cQuery += " JOIN SB1010 SB1 ON 	 	 														"+ Enter 
	cQuery += " 	A.D3_COD			= SB1.B1_COD 	 	 									"+ Enter 
	cQuery += " 	AND SB1.D_E_L_E_T_	= ''	 	 											"+ Enter 
	
	
	
	cQuery += " GROUP BY D3_FILIAL, D3_LOCAL, D3_COD, B1_DESC, D3_EMISSAO, D3_CUSTO1,D3_GRUPO	"+ Enter 
	cQuery += " ) B	 	 	"+ Enter 
	
			
Return cQuery


Static Function MontaCabPR(cNTitulo)

	Local aColLen := {100, 100, 100, 100, 200, 100, 100, 100}
	Local cDescTi := ""
	
	oExcel:AddPlanilha(cNTitulo,aColLen)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1)  

	oExcel:AddLinha(30)
	oExcel:AddLinha(12) 

	oExcel:AddCelula("Dia"								,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Almoxarifado"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Grupo"							,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod. Produto"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome Produto"						,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Qtd. Produzida"					,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo" 							,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Custo do último Fechamento"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	
Return

Static Function MontaLinPR(cQuery)

	Local cAliasTrab	:= GetNextAlias()
	Local cCorF 		:= cWhite
	
	TCQUERY cQuery NEW ALIAS cAliasTrab	
	
	While !(cAliasTrab->(Eof()))

		oExcel:AddLinha(12)
		
		oExcel:AddCelula(DTOC(STOD(cAliasTrab->DT_EMIS))						,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->ALMOX										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->GRUPO										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->COD_PROD									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(cAliasTrab->NOME_PROD									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM(cAliasTrab->QUANTIDADE,"@E 999,999,999.99")									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO,"@E 999,999,999.99")										,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(TRANSFORM(cAliasTrab->CUSTO_ULT,"@E 999,999,999.99")									,0,'L',cFonte3,nTamFont3,cCorFont3,.F.,.F.,cCorF  ,.T.,.T.,.T.,.T.)
	
		cAliasTrab->(DbSkip())
	EndDo
	cAliasTrab->(DbCloseArea())

Return


Static Function MontaAbaPar()

	oExcel:AddPlanilha('Parametros',{100})
	oExcel:AddLinha(12)

	oExcel:AddCelula("Data de: "+DTOC(STOD(cDataIni)))
	oExcel:AddLinha(12)		
	oExcel:AddCelula("Data até: "+DTOC(STOD(cDataFim)))
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Pasta Destino: "+cDirDest)
	oExcel:AddLinha(12)	

Return