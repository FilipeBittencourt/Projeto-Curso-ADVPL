#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RESGER         ºAutor  ³BRUNO MADALENO      º Data ³  23/08/06   º±±
±±º          ³                ºAlter. ³RANISSES A. CORONA  º      ³  28/05/09   º±±
±±º          ³                ºAlter. ³RANISSES A. CORONA  º      ³  15/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RESUMO GERENCIAL                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RESGER()
	Local Enter := CHR(13)+CHR(10)
	Local nEmp	:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private cSQL
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := ""
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "RES_GE"
	cPerg      := "RES_GE"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "RES_GE"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "RES_GE"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria parametros se nao existir e chama os parametros na tela           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     							 ³
	//³ Verifica Posicao do Formulario na Impressora.				             				 ³
	//³ Solicita os parametros para a emissao do relatorio			             		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	//Armazena Paramentros
	Datade 	= DTOS(MV_PAR01)
	DataAte	= DTOS(MV_PAR02)
	//Define a Empresa
	If cEmpAnt == "01"
		Do Case
			Case MV_PAR05 == 1 	//BIANCOGRES
			nEmp	:= "0101"
			Case MV_PAR05 == 2 	//INCESA
			nEmp	:= "0501"
			Case MV_PAR05 == 3 	//BELLACASA
			nEmp	:= "0599"
			Case MV_PAR05 == 4		//INCESA/BELLACASA
			nEmp	:= "05"
		EndCase
	Else
		Do Case
			Case MV_PAR05 == 1 	//INCESA
			nEmp	:= "0501"
			Case MV_PAR05 == 2 	//BELLACASA
			nEmp	:= "0599"
			Case MV_PAR05 == 3		//INCESA/BELLACASA
			nEmp	:= "05"
		EndCase
	EndIf


	//ALTERA VIEW1, PARA TRATAR FORMATO PORCELANICO - 44X44 - OK
	//Seleciona os formatos validos para Resumo Gerencial
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW1 AS									" + Enter
	cSQL += "SELECT ZZC_FORMAT+ZZC_CLASSE AS CHAVE,			" + Enter
	cSQL += "       ZZC_FORMAT AS BITOLA,								" + Enter
	cSQL += "				ZZC_CLASSE AS CLASSE,								" + Enter
	cSQL += "	   		ZZC_DESC AS FORMATO,								" + Enter
	cSQL += "	   		ZZ6_MSBLQL AS BLQ,									" + Enter	
	cSQL += "	   		LINHA = CASE												" + Enter
	If cEmpAnt == "01"
		cSQL += "									WHEN ZZ6_EMP IN ('B','A') THEN 'L1' ELSE 'L2'	" + Enter
	Else
		cSQL += "									WHEN ZZ6_EMP IN ('B') THEN 'L1' ELSE 'L2'	" + Enter
	EndIf
	cSQL += "								END,																						" + Enter
	cSQL += "	   		EMP = CASE																							" + Enter
	/*If cEmpAnt == "01"
	cSQL += "				  				WHEN ZZ6_EMP IN ('B','A') THEN '01' ELSE '05'	" + Enter
	Else
	cSQL += "				  				WHEN ZZ6_EMP IN ('B') THEN '01' ELSE '05'	" + Enter
	EndIf*/
	If nEmp	== "0101"
		cSQL += "				  				WHEN ZZ6_EMP IN ('B','A') THEN '0101' ELSE '0501'	" + Enter
	ElseIf nEmp	== "0501"
		cSQL += "				  				WHEN ZZ6_EMP IN ('B') THEN '0101' ELSE '0501'	" + Enter
	ElseIf nEmp	== "0599"
		cSQL += "				  				WHEN ZZ6_EMP IN ('B') THEN '0101' ELSE '0599'	" + Enter
	Else
		cSQL += "				  				WHEN ZZ6_EMP IN ('B') THEN '0101' ELSE '05'	" + Enter
	EndIf
	cSQL += "								END																							" + Enter
	cSQL += "FROM	ZZC010 ZZC, ZZ6010 ZZ6														" + Enter
	cSQL += "WHERE	ZZC.ZZC_FORMAT = ZZ6.ZZ6_COD AND								" + Enter
	cSQL += "		ZZC.ZZC_FORMAT <> 'AC' AND 													" + Enter  	 //NAO IMPRIME ACESSORIOS NO RG
	//cSQL += "		--ZZ6_EMP = 'B'		AND " ALTERACAO PARA CONTEMPLAR O FATURAMENTO DA INCESA NA BIANCOGRES EM 23/09/08
	//cSQL += "		ZZ6.ZZ6_MSBLQL <> '1' AND 													" + Enter  //FOI DESATIVADO 
	cSQL += "		ZZ6.ZZ6_COD NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "		ZZC.D_E_L_E_T_ = '' AND															" + Enter
	cSQL += "		ZZ6.D_E_L_E_T_ = ''																	" + Enter
	TcSQLExec(cSQL)


	//VIEW DO RELATORIO PRINCIPAL DO PRAZO MEDIO - OK
	//Calcula o Prazo Medio 
	/*cSQL := ""
	cSQL += "ALTER  VIEW VW_RG_PRAZOMEDIO AS " + Enter
	cSQL += "SELECT CONVERT(FLOAT(8), SUM(DATEDIFF (DAY, E1_EMISSAO, E1_VENCTO)*E1_VALOR)/SUM(E1_VALOR)) as PRAZO, " + Enter
	cSQL += "      (SELECT MAX(Z1_NDDMPZM) 									" + Enter
	cSQL += "       FROM "+RetSqlName("UZ1")+", VW_RG_VIEW1					" + Enter
	cSQL += "       WHERE	Z1_FILIAL			= '"+xFilial("UZ1")+"'	AND	" + Enter
	cSQL += "				Z1_FORMATO+Z1_TIPO	= VW_RG_VIEW1.CHAVE 	AND	" + Enter
	cSQL += "				VW_RG_VIEW1.EMP			= '"+cempant+"'				AND " + Enter
	cSQL += "				Z1_DATA							>= '"+Datade+"'				AND	" + Enter
	cSQL += "				Z1_DATA							<= '"+DataAte+"'			AND	" + Enter
	cSQL += "				D_E_L_E_T_					= '' ) AS META -- META PRAZO MEDIO	" + Enter
	cSQL += "FROM	VW_SE1 SE1,										" + Enter
	cSQL += "		(SELECT D2_DOC, D2_SERIE, D2_CLIENTE 			" + Enter
	cSQL += "		FROM	VW_SD2									" + Enter
	cSQL += "		WHERE	D2_FILIAL	= '"+xFilial("SD2")+"' AND	" + Enter
	cSQL += "				D2_GRUPO		= 'PA' 						AND		" + Enter
	cSQL += "				D2_YEMP			= '"+cempant+"' 	AND		" + Enter
	cSQL += "				D2_EMISSAO 	>= '"+Datade+"' 	AND		" + Enter
	cSQL += "				D2_EMISSAO	<= '"+DataAte+"'	AND		" + Enter
	cSQL += "				SUBSTRING(D2_COD,1,1) >= 'A' 	AND		" + Enter
	cSQL += "				SUBSTRING(D2_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') " + Enter
	cSQL += "		GROUP BY D2_DOC, D2_SERIE, D2_CLIENTE ) AS SD2	" + Enter
	cSQL += "WHERE	SE1.E1_FILIAL	= 	'"+xFilial("SE1")+"' AND	" + Enter
	cSQL += "			SE1.E1_PREFIXO	= 	SD2.D2_SERIE		AND			" + Enter
	cSQL += "			SE1.E1_NUM			= 	SD2.D2_DOC			AND			" + Enter
	cSQL += "			SE1.E1_CLIENTE	= 	SD2.D2_CLIENTE	AND			" + Enter
	cSQL += "			SE1.E1_YEMP			= 	'"+cempant+"'		AND			" + Enter
	cSQL += "			SE1.E1_NATUREZ	<>	'1230'					AND -- NAO CONSIDERA TITULOS ST	" + Enter
	cSQL += "			SE1.E1_TIPO			=		'NF'						AND			" + Enter
	cSQL += "			SE1.E1_EMISSAO	>=	'"+Datade+"'		AND			" + Enter
	cSQL += "			SE1.E1_EMISSAO	<=	'"+DataAte+"'				*/

	cSQL := ""
	cSQL += "ALTER  VIEW VW_RG_PRAZOMEDIO AS 																				" + Enter
	cSQL += "SELECT CONVERT(FLOAT(8), SUM(PRAZO*E1_VALOR)/SUM(E1_VALOR)) as PRAZO,	" + Enter
	cSQL += "      (SELECT ISNULL(MAX(Z1_NDDMPZM),0)								" + Enter
	cSQL += "       FROM "+RetSqlName("UZ1")+", VW_RG_VIEW1					" + Enter
	cSQL += "       WHERE	Z1_FILIAL			= '"+xFilial("UZ1")+"'	AND	" + Enter
	cSQL += "				Z1_FORMATO+Z1_TIPO	= VW_RG_VIEW1.CHAVE 	AND		" + Enter
	//cSQL += "				VW_RG_VIEW1.EMP			= '"+cempant+"'				AND 	" + Enter

	If Len(Alltrim(nEmp)) == 4
		cSQL += "				VW_RG_VIEW1.EMP			= '"+nEmp+"'					AND 	" + Enter     //RANISSES
		cSQL += "				UZ1_EMP							= '"+nEmp+"'					AND 	" + Enter     //RANISSES
	Else
		cSQL += "				SUBSTRING(VW_RG_VIEW1.EMP,1,2) 	= '"+nEmp+"'	AND 	" + Enter     //RANISSES
		cSQL += "				SUBSTRING(UZ1_EMP,1,2)					= '"+nEmp+"'	AND 	" + Enter     //RANISSES
	EndIf

	cSQL += "				Z1_DATA							>= '"+Datade+"'				AND		" + Enter            
	cSQL += "				Z1_DATA							<= '"+DataAte+"'			AND		" + Enter
	cSQL += "				D_E_L_E_T_					= '' ) AS META -- META PRAZO MEDIO	" + Enter
	cSQL += "FROM   (SELECT ISNULL((SELECT dbo.FN_PRAZOMEDIO_V1(E1_YEMPORI,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_YEMP,E1_CLIENTE,E1_LOJA)),0) PRAZO, * FROM VW_SE1	) SE1 " + Enter
	cSQL += "WHERE	SE1.E1_FILIAL		=  '"+xFilial("SE1")+"'	AND	" + Enter

	//cSQL += "				SE1.E1_YEMP			=  '"+cEmpAnt+"'	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				SE1.E1_YEMP			=  '"+nEmp+"'			AND	" + Enter
	Else
		cSQL += "				SUBSTRING(SE1.E1_YEMP,1,2)=  '"+nEmp+"'			AND	" + Enter
	EndIf

	cSQL += "				SE1.E1_NATUREZ	<> '1230'					AND -- NAO CONSIDERA TITULOS ST	" + Enter
	cSQL += "				SE1.E1_TIPO			=  'NF'					 	AND	" + Enter
	cSQL += "				SE1.E1_EMISSAO	>= '"+Datade+"'	 	AND	" + Enter
	cSQL += "				SE1.E1_EMISSAO	<= '"+DataAte+"' 	AND	" + Enter
	cSQL += "				SE1.E1_YTPPD    =  'PA'								" + Enter
	TcSQLExec(cSQL)

	/*
	cSQL += "				SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_CLIENTE+E1_LOJA IN (	" + Enter
	cSQL += "				SELECT D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA			" + Enter
	cSQL += "				FROM	VW_SD2																	" + Enter
	cSQL += "				WHERE	D2_FILIAL		=  '"+xFilial("SD2")+"'	AND " + Enter
	cSQL += "							D2_GRUPO		=  'PA' 								AND	" + Enter

	//cSQL += "							D2_YEMP			=  '"+cEmpAnt+"'				AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
	cSQL += "							D2_YEMP			=  '"+nEmp+"'						AND	" + Enter
	Else
	cSQL += "							SUBSTRING(D2_YEMP,1,2) = '"+nEmp+"'	AND	" + Enter
	EndIf

	cSQL += "							D2_EMISSAO 	>= '"+Datade+"' 				AND	" + Enter
	cSQL += "							D2_EMISSAO	<= '"+DataAte+"'				AND	" + Enter
	cSQL += "							SUBSTRING(D2_COD,1,1) >= 'A' 				AND	" + Enter
	cSQL += "							SUBSTRING(D2_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') " + Enter
	cSQL += "				GROUP BY D2_SERIE, D2_DOC, D2_CLIENTE, D2_LOJA )	" + Enter
	TcSQLExec(cSQL)                                                            */


	//ATUALIZA VIEWS PARA SUBRELATORIO1         
	//Monta Metas
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW0 AS														" + Enter
	cSQL += "SELECT BITOLA,						 								-- BITOLA	" + Enter
	cSQL += "	   SUM(MQTD_PRO)			AS MQTD_PRO,			-- META QTD PRODUZIDA	" + Enter
	cSQL += "	   SUM(MQTD_LIB)			AS MQTD_LIB,			-- META QTD LIBERADA	" + Enter
	cSQL += "	   SUM(MQTD_PRO_MES)	AS MQTD_PRO_MES,	-- META TOTAL QTD PRODUZIDA		" + Enter
	cSQL += "	   SUM(MQTD_LIB_MES)	AS MQTD_LIB_MES,	-- META TOTAL QTD LIBERADA   	" + Enter
	cSQL += "	   SUM(MQTD)					AS MQTD,					-- META QTD FATURADA	" + Enter
	cSQL += "	   SUM(MVLR)					AS MVLR,					-- META VLR FATURADA	" + Enter
	cSQL += "	   SUM(MQTD_FAT_MES)	AS MQTD_FAT_MES,	-- META TOTAL QTD FATURADA		" + Enter
	cSQL += "	   SUM(MVLR_FAT_MES)	AS MVLR_FAT_MES		-- META TOTAL VLR FATURADA		" + Enter
	cSQL += "FROM																			" + Enter
	cSQL += "(SELECT CT_YFORMAT AS BITOLA,													" + Enter
	cSQL += "			0 AS MQTD_PRO,														" + Enter
	cSQL += "			0 AS MQTD_LIB,														" + Enter
	cSQL += "			0 AS MQTD_PRO_MES,													" + Enter
	cSQL += "			0 AS MQTD_LIB_MES,													" + Enter
	cSQL += "	   (SUM(CT_QUANT)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MQTD,			" + Enter
	cSQL += "	   (SUM(CT_VALOR)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MVLR,			" + Enter
	cSQL += "	   (SUM(CT_QUANT)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)) AS MQTD_FAT_MES,	" + Enter
	cSQL += "	   (SUM(CT_VALOR)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)) AS MVLR_FAT_MES		" + Enter
	cSQL += "FROM "+RetSqlName("SCT")+"																			" + Enter
	cSQL += "WHERE	CT_FILIAL = '"+xFilial("SCT")+"'	AND										" + Enter                  
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				CT_YEMP = '"+nEmp+"'	AND	" + Enter
	Else
		cSQL += "				SUBSTRING(CT_YEMP,1,2) = '"+nEmp+"'	AND	" + Enter
	EndIf
	cSQL += "				SUBSTRING(CT_DATA,1,6) >= '"+Substr(Datade,1,6)+"'	AND										" + Enter
	cSQL += "				SUBSTRING(CT_DATA,1,6) <= '"+Substr(DataAte,1,6)+"'	AND D_E_L_E_T_ = ''		" + Enter
	cSQL += "GROUP BY CT_YFORMAT																						" + Enter
	cSQL += "UNION ALL																											" + Enter
	cSQL += "SELECT Z1_FORMATO 			AS BITOLA,				 											" + Enter
	cSQL += "  			SUM(Z1_QTMPRO) 	AS MQTD_PRO,           									" + Enter
	cSQL += "				SUM(Z1_QTMLIB) 	AS MQTD_LIB,           									" + Enter
	cSQL += "				0 AS MQTD_PRO_MES,																			" + Enter
	cSQL += "				0 AS MQTD_LIB_MES,																			" + Enter
	cSQL += "				0 AS MQUANT,							 															" + Enter
	cSQL += "				0 AS MVLR,							 																" + Enter
	cSQL += "				0 AS MQTD_FAT_MES,							 												" + Enter			
	cSQL += "				0 AS MVLR_FAT_MES																				" + Enter
	cSQL += "FROM "+RetSqlName("UZ1")+"																			" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "WHERE Z1_FILIAL = '"+xFilial("UZ1")+"' AND Z1_DATA BETWEEN '"+Datade+"' AND '"+DataAte+"' AND UZ1_EMP = '"+nEmp+"' AND D_E_L_E_T_ = '' " + Enter
	Else
		cSQL += "WHERE Z1_FILIAL = '"+xFilial("UZ1")+"' AND Z1_DATA BETWEEN '"+Datade+"' AND '"+DataAte+"' AND SUBSTRING(UZ1_EMP,1,2) = '"+nEmp+"' AND D_E_L_E_T_ = '' " + Enter
	EndIf
	cSQL += "GROUP BY Z1_FORMATO																						" + Enter
	cSQL += "UNION ALL																											" + Enter
	cSQL += "SELECT Z1_FORMATO	AS BITOLA,				 													" + Enter
	cSQL += "				0 AS MQTD_PRO,           																" + Enter
	cSQL += "				0 AS MQTD_LIB,           																" + Enter
	cSQL += "				SUM(Z1_QTMPRO) 	AS MQTD_PRO_MES,           							" + Enter		
	cSQL += "				SUM(Z1_QTMLIB) 	AS MQTD_LIB_MES,												" + Enter
	cSQL += "				0 AS MQTD_FAT,           																" + Enter
	cSQL += "				0 AS MVLR_FAT,           																" + Enter
	cSQL += "				0 AS MQTD_FAT_MES,							 												" + Enter			
	cSQL += "				0 AS MVLR_FAT_MES							 													" + Enter			
	cSQL += "FROM "+RetSqlName("UZ1")+"																			" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "WHERE Z1_FILIAL = '"+xFilial("UZ1")+"' AND SUBSTRING(Z1_DATA,1,6) = '"+Substr(Datade,1,6)+"' AND UZ1_EMP = '"+nEmp+"' AND D_E_L_E_T_ = '' " + Enter
	Else
		cSQL += "WHERE Z1_FILIAL = '"+xFilial("UZ1")+"' AND SUBSTRING(Z1_DATA,1,6) = '"+Substr(Datade,1,6)+"' AND SUBSTRING(UZ1_EMP,1,2) = '"+nEmp+"' AND D_E_L_E_T_ = '' " + Enter
	EndIf
	cSQL += "GROUP BY Z1_FORMATO ) TTT																			" + Enter
	cSQL += "GROUP BY BITOLA																								" + Enter
	TcSQLExec(cSQL)

	//Quantidade Produzida
	If cEmpAnt == "01"
		cSQL := ""
		cSQL += "ALTER VIEW VW_RG_VIEW2 AS  															" + Enter
		cSQL += "SELECT Z4_FORMATO AS BITOLA,    	-- BITOLA								" + Enter
		cSQL += "       Z4_TIPO AS CLASSE,      	-- CLASSE								" + Enter
		cSQL += "       SUM(Z4_QTPRO) AS QUANT_PRO		-- QUANTIDADE PRODUZIDA	" + Enter
		cSQL += "FROM UZ4010 UZ4																					" + Enter
		cSQL += "WHERE	Z4_FILIAL  		= '"+xFilial("UZ4")+"'	AND					" + Enter
		cSQL += "				Z4_DATA 			>= '"+Datade+"' 	AND " + Enter 
		cSQL += "				Z4_DATA		 		<= '"+DataAte+"'	AND " + Enter
		If Len(Alltrim(nEmp)) == 4
			cSQL += "				UZ4_EMP	= '"+nEmp+"'	AND " + Enter
		Else
			cSQL += "				SUBSTRING(UZ4_EMP,1,2)	= '"+nEmp+"'	AND " + Enter
		EndIf
		cSQL += "				UZ4.D_E_L_E_T_ 	= ''								" + Enter
		cSQL += "GROUP BY Z4_FORMATO, Z4_TIPO								" + Enter
		cSQL += "UNION ALL																	" + Enter
		cSQL += "SELECT Z4_FORMATO AS BITOLA,    	-- BITOLA	" + Enter
		cSQL += "       Z4_TIPO AS CLASSE,      	-- CLASSE	" + Enter
		cSQL += "       SUM(Z4_QTPRO) AS QUANT_PRO		-- QUANTIDADE PRODUZIDA	" + Enter
		cSQL += "FROM UZ4050 UZ4																					" + Enter
		cSQL += "WHERE	Z4_FILIAL  			= '"+xFilial("UZ4")+"'	AND				" + Enter
		cSQL += "				Z4_FORMATO 			= 'B5'			 			AND	" + Enter
		cSQL += "				Z4_DATA 				>= '"+Datade+"' 	AND " + Enter 
		cSQL += "				Z4_DATA		 			<= '"+DataAte+"'	AND " + Enter
		If Len(Alltrim(nEmp)) == 4
			cSQL += "				UZ4_EMP	= '"+nEmp+"'	AND " + Enter
		Else
			cSQL += "				SUBSTRING(UZ4_EMP,1,2)	= '"+nEmp+"'	AND " + Enter
		EndIf
		cSQL += "				UZ4.D_E_L_E_T_ 	= ''									" + Enter
		cSQL += "GROUP BY Z4_FORMATO, Z4_TIPO" + Enter
		TcSQLExec(cSQL)
	Else
		cSQL := ""
		cSQL += "ALTER VIEW VW_RG_VIEW2 AS  									" + Enter
		cSQL += "SELECT Z4_FORMATO AS BITOLA,   	-- BITOLA		" + Enter
		cSQL += "       Z4_TIPO AS CLASSE,      	-- CLASSE		" + Enter
		cSQL += "       SUM(Z4_QTPRO) AS QUANT_PRO		-- QUANTIDADE PRODUZIDA	" + Enter
		cSQL += "FROM "+RetSqlName("UZ4")+" UZ4																" + Enter
		cSQL += "WHERE	Z4_FILIAL  			= '"+xFilial("UZ4")+"'	AND						" + Enter
		cSQL += "				Z4_FORMATO 			<> 'B5'			 			AND	" + Enter
		cSQL += "				Z4_DATA 				>= '"+Datade+"' 	AND " + Enter 
		cSQL += "				Z4_DATA		 			<= '"+DataAte+"'	AND " + Enter
		If Len(Alltrim(nEmp)) == 4
			cSQL += "				UZ4_EMP	= '"+nEmp+"'	AND " + Enter
		Else
			cSQL += "				SUBSTRING(UZ4_EMP,1,2)	= '"+nEmp+"'	AND " + Enter
		EndIf
		cSQL += "				UZ4.D_E_L_E_T_ 	= ''									" + Enter
		cSQL += "GROUP BY Z4_FORMATO, Z4_TIPO									" + Enter
		TcSQLExec(cSQL)
	EndIf

	//Quantidade Liberada
	If cEmpAnt == "01"
		cSQL := ""
		cSQL += "ALTER VIEW VW_RG_VIEW6 AS 									" + Enter
		cSQL += "SELECT B1_YFORMAT AS BITOLA,		-- BITOLA		" + Enter
		cSQL += "       B1_YCLASSE AS CLASSE,		-- CLASSE 	" + Enter
		cSQL += "       SUM(QUANT) AS QUANT_LIB	-- QUANTIDADE LIBERADA	" + Enter
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		cSQL += "FROM	(SELECT *, QUANT = CASE WHEN D3_TM > '500' THEN D3_QUANT*-1 ELSE D3_QUANT END FROM SD3010 ) SD3,	" + Enter
		cSQL += "			SB1010 SB1, ZZ7010 ZZ7	" + Enter
		cSQL += "WHERE	SD3.D3_FILIAL	= '"+xFilial("SD3")+"'	AND			" + Enter
		cSQL += "	  	SB1.B1_FILIAL	= '"+xFilial("SB1")+"'  AND			" + Enter
		cSQL += "	  	SD3.D3_COD		  = SB1.B1_COD 				AND	" + Enter
		cSQL += "			SB1.B1_YLINHA	  = ZZ7.ZZ7_COD				AND	" + Enter
		cSQL += "			SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ		AND	" + Enter
		If nEmp == "0101"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0501"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0599"
			cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
		EndIf
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		//cSQL += "    	SD3.D3_TM			  IN ('500','501')		AND	" + Enter
		cSQL += "    	( SD3.D3_TM	IN ('500','501') OR SD3.D3_YORIMOV = 'PR0' )		AND	" + Enter
		cSQL += "    	SD3.D3_ESTORNO	<> 'S'							AND	" + Enter
		cSQL += "			SD3.D3_EMISSAO	>= '"+Datade+"'		  AND	" + Enter
		cSQL += "			SD3.D3_EMISSAO	<= '"+DataAte+"'	  AND	" + Enter
		cSQL += " 	  SD3.D_E_L_E_T_	= ''				AND		" + Enter
		cSQL += "	  	SB1.D_E_L_E_T_	= ''				AND		" + Enter
		cSQL += " 	  ZZ7.D_E_L_E_T_	= ''				      " + Enter
		cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE	 			" + Enter
		cSQL += "UNION ALL" + Enter
		cSQL += "SELECT B1_YFORMAT AS BITOLA,		-- BITOLA				" + Enter
		cSQL += "       B1_YCLASSE AS CLASSE,		-- CLASSE 			" + Enter
		cSQL += "       SUM(D3_QUANT) AS QUANT_LIB	-- QUANTIDADE LIBERADA	" + Enter
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		cSQL += "FROM (SELECT *, QUANT = CASE WHEN D3_TM > '500' THEN D3_QUANT*-1 ELSE D3_QUANT END FROM SD3050) SD3,	" + Enter
		cSQL += "			SB1010 SB1, ZZ7010 ZZ7	" + Enter
		cSQL += "WHERE	SD3.D3_FILIAL	= '"+xFilial("SD3")+"'	AND			" + Enter
		cSQL += "	  	SB1.B1_FILIAL	= '"+xFilial("SB1")+"'  AND			" + Enter
		cSQL += "	  	SD3.D3_COD		= SB1.B1_COD 				AND		" + Enter
		cSQL += "			SB1.B1_YLINHA	  = ZZ7.ZZ7_COD				AND	" + Enter
		cSQL += "			SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ		AND	" + Enter
		If nEmp == "0101"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0501"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0599"
			cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
		EndIf
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		//cSQL += "    	SD3.D3_TM				IN ('500','501')	AND		" + Enter
		cSQL += "    	( SD3.D3_TM	IN ('500','501') OR SD3.D3_YORIMOV = 'PR0' )		AND	" + Enter
		cSQL += "    	SD3.D3_ESTORNO	<> 'S'						AND		" + Enter
		cSQL += "			SD3.D3_EMISSAO	>= '"+Datade+"'		AND		" + Enter
		cSQL += "			SD3.D3_EMISSAO	<= '"+DataAte+"'	AND		" + Enter
		cSQL += "			SB1.B1_YFORMAT	= 'B5'						AND		" + Enter	//CONSIDERA PRODUCAO NA INCESA
		cSQL += " 	  SD3.D_E_L_E_T_	= ''							AND		" + Enter
		cSQL += "	  	SB1.D_E_L_E_T_	= ''							AND		" + Enter
		cSQL += " 	  ZZ7.D_E_L_E_T_	= ''				      			" + Enter
		cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE	 						" + Enter
		TcSQLExec(cSQL)
	Else
		cSQL := ""
		cSQL += "ALTER VIEW VW_RG_VIEW6 AS 												" + Enter
		cSQL += "SELECT B1_YFORMAT AS BITOLA,		-- BITOLA					" + Enter
		cSQL += "       B1_YCLASSE AS CLASSE,		-- CLASSE 				" + Enter
		cSQL += "       SUM(QUANT) AS QUANT_LIB	-- QUANTIDADE LIBERADA	" + Enter
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		cSQL += "FROM (SELECT *, QUANT = CASE WHEN D3_TM > '500' THEN D3_QUANT*-1 ELSE D3_QUANT END FROM "+RetSqlName("SD3")+") SD3,	" + Enter
		cSQL += "				"+RetSqlName("SB1")+" SB1, ZZ7010 ZZ7 " + Enter
		cSQL += "WHERE	SD3.D3_FILIAL	= '"+xFilial("SD3")+"'	AND	 " + Enter
		cSQL += "	  	SB1.B1_FILIAL		= '"+xFilial("SB1")+"'  AND	 " + Enter
		cSQL += "	  	SD3.D3_COD			= SB1.B1_COD 				AND	" + Enter
		cSQL += "			SB1.B1_YLINHA	  = ZZ7.ZZ7_COD				AND	" + Enter
		cSQL += "			SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ		AND	" + Enter
		If nEmp == "0101"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0501"
			cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
		ElseIf nEmp == "0599"
			cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
		EndIf
		// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		//cSQL += "    	SD3.D3_TM				IN ('500','501')	AND		" + Enter
		cSQL += "    	( SD3.D3_TM	IN ('500','501') OR SD3.D3_YORIMOV = 'PR0' )		AND	" + Enter
		cSQL += "    	SD3.D3_ESTORNO	<> 'S'						AND		" + Enter
		cSQL += "			SD3.D3_EMISSAO	>= '"+Datade+"'		AND		" + Enter
		cSQL += "			SD3.D3_EMISSAO	<= '"+DataAte+"'	AND		" + Enter
		cSQL += "			SB1.B1_YFORMAT	<> 'B5'						AND		" + Enter	 //NAO CONSIDERA PRODUCAO NA INCESA
		cSQL += " 	  SD3.D_E_L_E_T_	= ''							AND		" + Enter
		cSQL += "	  	SB1.D_E_L_E_T_	= ''							AND  	" + Enter
		cSQL += " 	  ZZ7.D_E_L_E_T_	= ''				      			" + Enter
		cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
		TcSQLExec(cSQL)
	EndIf

	//Pedidos Emitidos dentro do Periodo - QP - C5_EMISSAO
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW10 AS 											" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   " + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(C6_QTDVEN) AS QUANT_PED,	-- QUANTIDADE M2		" + Enter
	cSQL += "       SUM(C6_VALOR) AS VLR_PED			-- VALOR 						" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1		" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SC5.C5_EMISSAO	>= '"+Datade+"'		AND		" + Enter
	cSQL += "			SC5.C5_EMISSAO	<= '"+DataAte+"'	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A' 	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	TcSQLExec(cSQL)


	//Pedidos Emitidos para Entrega dentro do Mes - QPA - C6_ENTREG
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW3 AS 												" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   " + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(C6_QTDVEN) AS QUANT_PED,	-- QUANTIDADE M2		" + Enter
	cSQL += "       SUM(C6_VALOR) AS VLR_PED			-- VALOR 						" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1		" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SC6.C6_BLQ			<> 'R'						AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SUBSTRING(SC5.C5_EMISSAO,1,6) >= '"+Substr(DataDe,1,6)+"'			AND		" + Enter
	cSQL += "			SUBSTRING(SC5.C5_EMISSAO,1,6) <= '"+Substr(DataAte,1,6)+"'		AND		" + Enter
	cSQL += "			SUBSTRING(SC6.C6_ENTREG,1,6)  >= '"+Substr(DataDe,1,6)+"'			AND		" + Enter
	cSQL += "			SUBSTRING(SC6.C6_ENTREG,1,6)  <= '"+Substr(DataAte,1,6)+"'		AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A' 	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	TcSQLExec(cSQL)


	//Pedidos Emitidos para Entrega Futura - QPF - C6_ENTREG
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW4 AS 												" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   " + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(C6_QTDVEN) AS QUANT_PED,	-- QUANTIDADE M2		" + Enter
	cSQL += "       SUM(C6_VALOR) AS VLR_PED			-- VALOR 						" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1		" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SC6.C6_BLQ			<> 'R'						AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SUBSTRING(SC5.C5_EMISSAO,1,6) >= '"+Substr(DataDe,1,6)+"'		AND	" + Enter
	cSQL += "			SUBSTRING(SC5.C5_EMISSAO,1,6) <= '"+Substr(DataAte,1,6)+"'	AND	" + Enter
	cSQL += "			SUBSTRING(SC6.C6_ENTREG,1,6)  >	 '"+Substr(DataAte,1,6)+"'	AND	" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A' 	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND	" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	TcSQLExec(cSQL)


	//Pedidos Eliminados por Residuo
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW11 AS 										" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   		" + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE			" + Enter
	cSQL += "       SUM(C6_QTDVEN)  AS QTDPED_R,			-- QUANTIDADE M2	" + Enter
	cSQL += "       SUM(C6_VALOR)	AS VLRPED_R		   		-- VALOR 			" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1	   			" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' 	AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' 	AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.C6_BLQ			= 'R'							AND		" + Enter //CONSIDERA APENAS OS PEDIDOS ELIMINADOS POR RESIDUO
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SC6.C6_YDTRESI	>= '"+Datade+"'		AND		" + Enter //CONSIDERA A DATA DE ELIMINACAO POR RESIDUO
	cSQL += "			SC6.C6_YDTRESI	<= '"+DataAte+"'	AND		" + Enter //CONSIDERA A DATA DE ELIMINACAO POR RESIDUO
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	TcSQLExec(cSQL)


	//Pedidos Eliminados por Residuo - QPA - DESATIVADO
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW12 AS 											" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   " + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(C6_QTDVEN) AS QTDPED_R		-- QUANTIDADE M2		" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1		" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' 	AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' 	AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.C6_BLQ			= 'R'							AND		" + Enter //CONSIDERA APENAS OS PEDIDOS ELIMINADOS POR RESIDUO
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SUBSTRING(SC6.C6_YDTRESI,1,6) >= '"+Substr(Datade,1,6)+"'		AND		" + Enter
	cSQL += "			SUBSTRING(SC6.C6_YDTRESI,1,6) <= '"+Substr(DataAte,1,6)+"'		AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	//TcSQLExec(cSQL)

	//Pedidos Eliminados por Residuo - QPF - DESATIVADO
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW13 AS 											" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA   " + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(C6_QTDVEN) AS QTDPED_R		-- QUANTIDADE M2		" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, "+RetSqlName("SB1")+" SB1		" + Enter
	cSQL += "WHERE 	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' 	AND	" + Enter
	cSQL += "			SC6.C6_FILIAL		= '"+xFilial("SC6")+"' 	AND	" + Enter
	cSQL += "			SC5.C5_NUM			= SC6.C6_NUM 			AND		" + Enter
	cSQL += "			SC5.C5_CLIENTE	= SC6.C6_CLI 			AND		" + Enter
	cSQL += "	  	SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP 		AND		" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND		" + Enter
	cSQL += "			SC6.C6_PRODUTO	= SB1.B1_COD 			AND		" + Enter
	//cSQL += "			SC5.C5_YEMP			= '"+cempant+"'		AND 	" + Enter //DETERMINA A EMPRESA	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "			SC5.C5_YEMP			= '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	Else
		cSQL += "			SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'		AND 	" + Enter  //DETERMINA A EMPRESA	
	EndIf
	cSQL += "			SC5.C5_TIPO			= 'N'							AND 	" + Enter
	cSQL += "			SC6.C6_BLQ			= 'R'							AND		" + Enter //CONSIDERA APENAS OS PEDIDOS ELIMINADOS POR RESIDUO
	cSQL += "			SC6.F4_DUPLIC		= 'S'							AND		" + Enter
	cSQL += "			SB1.B1_TIPO			= 'PA'						AND		" + Enter
	cSQL += "			SUBSTRING(SC6.C6_YDTRESI,1,6) >	'"+Substr(DataAte,1,6)+"'		AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND		" + Enter
	cSQL += "	  	SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND		" + Enter
	cSQL += "			SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter
	//TcSQLExec(cSQL)

	//GRAVAR TABELA TEMPORARIO AKI

	//View Principal SubRelatorio 1
	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RG_1 AS				" + Enter
	//cSQL += "SELECT VW_RG_VIEW1.BITOLA,		" + Enter
	//cSQL += "       VW_RG_VIEW1.CLASSE,		" + Enter
	//cSQL += "       VW_RG_VIEW1.FORMATO,	" + Enter                             
	//cSQL += "       VW_RG_VIEW1.LINHA,		" + Enter
	//cSQL += "       VW_RG_VIEW1.BLQ,			" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW2.QUANT_PRO),0)		AS QUANT_PRO,		-- 02		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_PRO),0)		AS MQUANT_PRO,	-- 04 	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW6.QUANT_LIB),0)		AS QUANT_LIB,   -- 06		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_LIB),0)		AS MQUANT_LIB,	-- 08 	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW10.QUANT_PED),0)	AS QUANT_PED,		-- 10		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW11.QTDPED_R),0)		AS QTDPED_R,		-- 11		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW10.QUANT_PED),0)-ISNULL((VW_RG_VIEW11.QTDPED_R),0)	AS QPL,		-- 12	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD),0)				AS MQTD_PED,		-- 13		" + Enter
	////cSQL += "				ISNULL((VW_RG_VIEW3.QUANT_PED),0)-ISNULL((VW_RG_VIEW12.QTDPED_R),0)	AS QUANT_PED_A,	-- 15	" + Enter
	////cSQL += "				ISNULL((VW_RG_VIEW4.QUANT_PED),0)-ISNULL((VW_RG_VIEW13.QTDPED_R),0)	AS QUANT_PED_F,	-- 16	" + Enter
	//cSQL += "				ISNULL((VW_RG_VIEW3.QUANT_PED),0)		AS QUANT_PED_A,	-- 15	" + Enter
	//cSQL += "				ISNULL((VW_RG_VIEW4.QUANT_PED),0)		AS QUANT_PED_F,	-- 16	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW10.VLR_PED),0)-ISNULL((VW_RG_VIEW11.VLRPED_R),0)	AS VPL,			-- 17			" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MVLR),0)					AS MVLR_PED,		 -- 18	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_FAT_MES),0)	AS MQTD_MES,		 --   	" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MVLR_FAT_MES),0)	AS MVLR_MES,		 -- 		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_PRO_MES),0)	AS MQTD_PRO_MES, -- 		" + Enter
	//cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_LIB_MES),0)	AS MQTD_LIB_MES	 -- 		" + Enter
	//cSQL += "FROM VW_RG_VIEW0,  -- METAS																				" + Enter
	//cSQL += "     VW_RG_VIEW1,  -- BITOLA E CLASSE														  " + Enter
	//cSQL += "     VW_RG_VIEW2,  -- QUANTIDADE PRODUZIDA													" + Enter
	//cSQL += "     VW_RG_VIEW6,  -- QUANTIDADE LIBERADA													" + Enter
	//cSQL += "     VW_RG_VIEW10, -- QUANTIDADE E VALOR DE PEDIDOS								" + Enter
	//cSQL += "     VW_RG_VIEW11, -- QTD E VLR PEDIDO RESIDUOS										" + Enter
	//cSQL += "     VW_RG_VIEW3,  -- QTD PEDIDOS ATUAL														" + Enter
	//cSQL += "     VW_RG_VIEW4  -- QTD PEDIDOS FUTURO														" + Enter
	////cSQL += "     VW_RG_VIEW12, -- QTD PEDIDOS RESIDUOS - QPA										" + Enter
	////cSQL += "     VW_RG_VIEW13  -- QTD PEDIDOS RESIDUOS -	QPF										" + Enter
	//cSQL += "WHERE VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW0.BITOLA		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW2.BITOLA		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW2.CLASSE		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW6.BITOLA		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW6.CLASSE		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW10.BITOLA	AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW10.CLASSE	AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW11.BITOLA	AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW11.CLASSE	AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW3.BITOLA		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW3.CLASSE		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW4.BITOLA		AND								" + Enter
	//cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW4.CLASSE		AND								" + Enter
	////cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW12.BITOLA	AND								" + Enter
	////cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW12.CLASSE	AND								" + Enter
	////cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW13.BITOLA	AND								" + Enter
	////cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW13.CLASSE	AND								" + Enter
	////cSQL += "      VW_RG_VIEW1.EMP		= '"+cempant+"'														" + Enter
	//If Len(Alltrim(nEmp)) == 4
	//	cSQL += "      VW_RG_VIEW1.EMP		= '"+nEmp+"'														" + Enter
	//Else
	//	cSQL += "      SUBSTRING(VW_RG_VIEW1.EMP,1,2) = '"+nEmp+"'														" + Enter
	//EndIf



	//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_1 AS				" + Enter
	cSQL += "SELECT VW_RG_VIEW1.BITOLA,		" + Enter
	cSQL += "       VW_RG_VIEW1.CLASSE,		" + Enter
	cSQL += "       VW_RG_VIEW1.FORMATO,	" + Enter                             
	cSQL += "       VW_RG_VIEW1.LINHA,		" + Enter
	cSQL += "       VW_RG_VIEW1.BLQ,			" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW2.QUANT_PRO),0)		AS QUANT_PRO,		-- 02		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_PRO),0)		AS MQUANT_PRO,	-- 04 	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW6.QUANT_LIB),0)		AS QUANT_LIB,   -- 06		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_LIB),0)		AS MQUANT_LIB,	-- 08 	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW10.QUANT_PED),0)	AS QUANT_PED,		-- 10		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW11.QTDPED_R),0)		AS QTDPED_R,		-- 11		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW10.QUANT_PED),0)-ISNULL((VW_RG_VIEW11.QTDPED_R),0)	AS QPL,		-- 12	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD),0)				AS MQTD_PED,		-- 13		" + Enter
	//cSQL += "				ISNULL((VW_RG_VIEW3.QUANT_PED),0)-ISNULL((VW_RG_VIEW12.QTDPED_R),0)	AS QUANT_PED_A,	-- 15	" + Enter
	//cSQL += "				ISNULL((VW_RG_VIEW4.QUANT_PED),0)-ISNULL((VW_RG_VIEW13.QTDPED_R),0)	AS QUANT_PED_F,	-- 16	" + Enter
	cSQL += "				ISNULL((VW_RG_VIEW3.QUANT_PED),0)		AS QUANT_PED_A,	-- 15	" + Enter
	cSQL += "				ISNULL((VW_RG_VIEW4.QUANT_PED),0)		AS QUANT_PED_F,	-- 16	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW10.VLR_PED),0)-ISNULL((VW_RG_VIEW11.VLRPED_R),0)	AS VPL,			-- 17			" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MVLR),0)					AS MVLR_PED,		 -- 18	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_FAT_MES),0)	AS MQTD_MES,		 --   	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MVLR_FAT_MES),0)	AS MVLR_MES,		 -- 		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_PRO_MES),0)	AS MQTD_PRO_MES, -- 		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD_LIB_MES),0)	AS MQTD_LIB_MES	 -- 		" + Enter
	cSQL += " " + Enter
	cSQL += "FROM VW_RG_VIEW1  -- BITOLA E CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW0 -- METAS " + Enter
	cSQL += "		ON  VW_RG_VIEW1.BITOLA = VW_RG_VIEW0.BITOLA " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW2 -- QUANTIDADE PRODUZIDA " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW2.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW2.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW6 " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW6.BITOLA " + Enter
	cSQL += "			AND	VW_RG_VIEW1.CLASSE = VW_RG_VIEW6.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW10 -- QUANTIDADE E VALOR DE PEDIDOS " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW10.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW10.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW11 -- QTD E VLR PEDIDO RESIDUOS " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW11.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW11.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW3 -- QTD PEDIDOS ATUAL " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW3.BITOLA " + Enter
	cSQL += "			AND	VW_RG_VIEW1.CLASSE = VW_RG_VIEW3.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW4  -- QTD PEDIDOS FUTURO " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW4.BITOLA " + Enter
	cSQL += "			AND	VW_RG_VIEW1.CLASSE = VW_RG_VIEW4.CLASSE " + Enter
	If Len(Alltrim(nEmp)) == 4			
		cSQL += "WHERE VW_RG_VIEW1.EMP = '" + nEmp + "' " + Enter
	Else
		cSQL += "WHERE SUBSTRING(VW_RG_VIEW1.EMP,1,2) = '" + nEmp + "' " + Enter
	EndIf


	TcSQLExec(cSQL)    


	//ATUALIZA VIEWS PARA SUBRELATORIO2         
	//QUANTIDADE E VALOR FATURADOS
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW16 AS 											" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA		" + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE		" + Enter
	cSQL += "       SUM(D2_QUANT) AS QUANT_FAT,		-- QUANTIDADE FATURADA					" + Enter
	cSQL += "       SUM(D2_TOTAL) AS VLR_FAT,			-- VALOR FATURADO SEM IMPOSTOS	" + Enter 
	cSQL += "       SUM(D2_VALICM+D2_VALIMP5+D2_VALIMP6) AS VLR_IMP, 	-- VALOR FATURADO SEM IMPOSTOS	" + Enter
	cSQL += "       SUM(D2_TOTAL*D2_COMIS1/100) AS VLR_COM,			 			-- VALOR DA COMISSAO 				" + Enter
	cSQL += "       SUM(D2_QUANT*B1_YVLCVP)	AS VLR_CUSVAR  			 			-- VALOR DO CUSTO VARIAVEL	" + Enter
	cSQL += "FROM VW_SD2 SD2, "+RetSqlName("SB1")+" SB1							" + Enter
	cSQL += "WHERE 	SD2.D2_FILIAL  	= '"+xFilial("SD2")+"'	AND			" + Enter
	cSQL += "	  		SD2.D2_COD	 		= SB1.B1_COD				AND			" + Enter
	cSQL += "      	SD2.F4_DUPLIC  	= 'S'								AND			" + Enter
	cSQL += "      	SD2.D2_GRUPO   	= 'PA'							AND			" + Enter
	//cSQL += "	  		SD2.D2_YEMP	 		= '"+cempant+"' 		AND			" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SD2.D2_YEMP	 		= '"+nEmp+"' 		AND			" + Enter
	Else
		cSQL += "	  		SUBSTRING(SD2.D2_YEMP,1,2) = '"+nEmp+"' AND	 " + Enter
	EndIf
	cSQL += "	  		SD2.D2_EMISSAO	>= '"+DataDe+"' 		AND			" + Enter
	cSQL += "	  		SD2.D2_EMISSAO 	<= '"+DataAte+"' 		AND			" + Enter
	cSQL += "				SB1.D_E_L_E_T_ 	= ''												" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE										" + Enter
	TcSQLExec(cSQL)	

	//DEVOLUCOES
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW35 AS						" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA, B1_YCLASSE AS CLASSE, SUM(D1_QUANT) AS QUANT_DEV, SUM(D1_TOTAL) AS VLR_DEV, " + Enter
	cSQL += "				ROUND(SUM(((D2_COMIS1 * D2_TOTAL )/100)),2) AS COM_DEV, ROUND(SUM(D1_VALICM+D1_VALIMP5+D1_VALIMP6),2) AS IMP_DEV " + Enter
	cSQL += "FROM VW_SD1 SD1, VW_SD2 SD2									" + Enter
	cSQL += "WHERE	SD1.D1_FILIAL		= '"+xFilial("SD1")+"'	AND " + Enter
	cSQL += "				SD2.D2_DOC			= SD1.D1_NFORI		AND " + Enter
	cSQL += "				SD2.D2_SERIE		= SD1.D1_SERIORI	AND " + Enter
	cSQL += "				SD2.D2_CLIENTE	= SD1.D1_FORNECE	AND " + Enter
	cSQL += "				SD2.D2_LOJA			= SD1.D1_LOJA			AND " + Enter
	cSQL += "				SD2.D2_COD			= SD1.D1_COD			AND " + Enter
	cSQL += "				SD2.D2_ITEM			= SD1.D1_ITEMORI	AND " + Enter
	cSQL += "				SD2.D2_YEMP			= SD1.D1_YEMP			AND " + Enter
	cSQL += "				SD2.D2_YEMPORI	= SD1.D1_YEMPORI	AND " + Enter
	//cSQL += "				SD1.D1_YEMP			= '"+cempant+"'		AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SD2.D2_YEMP	 		= '"+nEmp+"' 		AND			" + Enter
	Else
		cSQL += "	  		SUBSTRING(SD2.D2_YEMP,1,2) = '"+nEmp+"' AND	 " + Enter
	EndIf
	cSQL += "				SD1.F4_ESTOQUE	= 'S'							AND	" + Enter
	cSQL += "				SD1.B1_YCLASSE	<> ''							AND	" + Enter
	cSQL += "				SD1.D1_CF				IN ('1201','2201','1202','2202','1203','2203','1410','2410')	AND	" + Enter
	cSQL += "				SD1.D1_TP				= 'PA'						AND	" + Enter 
	cSQL += "				SD1.B1_YFORMAT NOT IN ('AB','AC','AD','AE','AF') AND " + Enter 
	cSQL += "				SD1.D1_DTDIGIT	>= '"+DataDe+"'		AND	" + Enter
	cSQL += "				SD1.D1_DTDIGIT	<= '"+DataAte+"'		" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE			" + Enter
	TcSQLExec(cSQL)

	//GRAVA INFORMACOES EM TABELA TEMPORARIA
	cSQL := ""
	cSQL += "if exists (select 1 from dbo.sysobjects where id = object_id('TB_RG_2') and type = 'U') drop table TB_RG_2 " + Enter
	TcSQLExec(cSQL)

	cSQL := ""
	cSQL += "CREATE TABLE dbo.TB_RG_2 " + Enter
	cSQL += "(	BITOLA VARCHAR(2) COLLATE database_default, " + Enter
	cSQL += "		CLASSE VARCHAR(1) COLLATE database_default, " + Enter
	cSQL += "		FORMATO VARCHAR(30) COLLATE database_default, " + Enter
	cSQL += "		LINHA VARCHAR(2) COLLATE database_default, " + Enter
	cSQL += "		BLQ VARCHAR(1) COLLATE database_default, " + Enter
	cSQL += "		EMP VARCHAR(4) COLLATE database_default, " + Enter
	cSQL += "		MQTD_PRO float DEFAULT 0, " + Enter
	cSQL += "		MQTD_LIB float DEFAULT 0, " + Enter
	cSQL += "		MQTD_PRO_MES float DEFAULT 0, " + Enter
	cSQL += "		MQTD_LIB_MES float DEFAULT 0, " + Enter
	cSQL += "		MQTD float DEFAULT 0, " + Enter
	cSQL += "		MVLR float DEFAULT 0, " + Enter
	cSQL += "		MQTD_FAT_MES float DEFAULT 0, " + Enter
	cSQL += "		MVLR_FAT_MES float DEFAULT 0, " + Enter
	cSQL += "		QUANT_FAT float DEFAULT 0, " + Enter
	cSQL += "		VLR_FAT float DEFAULT 0, " + Enter
	cSQL += "		VLR_IMP float DEFAULT 0, " + Enter
	cSQL += "		VLR_COM float DEFAULT 0, " + Enter
	cSQL += "		VLR_CUSVAR float DEFAULT 0, " + Enter
	cSQL += "		QUANT_DEV float DEFAULT 0, " + Enter
	cSQL += "		VLR_DEV float DEFAULT 0, " + Enter
	cSQL += "		COM_DEV	float DEFAULT 0, " + Enter
	cSQL += "		IMP_DEV	float DEFAULT 0) " + Enter
	TcSQLExec(cSQL)

	If Len(Alltrim(nEmp)) == 4
		cSQL := "INSERT INTO TB_RG_2 (BITOLA, CLASSE, FORMATO, BLQ, LINHA, EMP, MQTD_PRO,MQTD_LIB,MQTD_PRO_MES,MQTD_LIB_MES,MQTD,MVLR,MQTD_FAT_MES,MVLR_FAT_MES) SELECT A.BITOLA, CLASSE, FORMATO, BLQ, LINHA, EMP, MQTD_PRO,MQTD_LIB,MQTD_PRO_MES,MQTD_LIB_MES,MQTD,MVLR,MQTD_FAT_MES,MVLR_FAT_MES FROM VW_RG_VIEW1 A, VW_RG_VIEW0 B  WHERE A.BITOLA = B.BITOLA AND EMP = '"+nEmp+"' " + Enter
	Else
		cSQL := "INSERT INTO TB_RG_2 (BITOLA, CLASSE, FORMATO, BLQ, LINHA, EMP, MQTD_PRO,MQTD_LIB,MQTD_PRO_MES,MQTD_LIB_MES,MQTD,MVLR,MQTD_FAT_MES,MVLR_FAT_MES) SELECT A.BITOLA, CLASSE, FORMATO, BLQ, LINHA, EMP, MQTD_PRO,MQTD_LIB,MQTD_PRO_MES,MQTD_LIB_MES,MQTD,MVLR,MQTD_FAT_MES,MVLR_FAT_MES FROM VW_RG_VIEW1 A, VW_RG_VIEW0 B  WHERE A.BITOLA = B.BITOLA AND SUBSTRING(EMP,1,2) = '"+nEmp+"' " + Enter
	EndIf
	TcSQLExec(cSQL)

	cSQL := "INSERT INTO TB_RG_2 (BITOLA, CLASSE, FORMATO, BLQ, LINHA, EMP, QUANT_FAT, VLR_FAT, VLR_IMP, VLR_COM, VLR_CUSVAR) SELECT A.BITOLA, A.CLASSE, FORMATO, BLQ, LINHA, EMP, QUANT_FAT, VLR_FAT, VLR_IMP, VLR_COM, VLR_CUSVAR FROM  VW_RG_VIEW16 A, VW_RG_VIEW1 B WHERE  A.BITOLA = B.BITOLA 	AND	  A.CLASSE = B.CLASSE " + Enter
	TcSQLExec(cSQL)

	cSQL := "INSERT INTO TB_RG_2 (BITOLA, CLASSE, QUANT_DEV, VLR_DEV, COM_DEV, IMP_DEV) SELECT BITOLA, CLASSE, QUANT_DEV, VLR_DEV, COM_DEV, IMP_DEV FROM  VW_RG_VIEW35 A " + Enter
	TcSQLExec(cSQL)

	cSQL := ""
	cSQL += "UPDATE TB_RG_2  SET FORMATO = B.FORMATO, LINHA = B.LINHA, BLQ = B.BLQ, EMP = B.EMP  " + Enter
	cSQL += "FROM TB_RG_2 A, VW_RG_VIEW1 B  " + Enter
	cSQL += "WHERE  A.BITOLA = B.BITOLA 	AND A.CLASSE = B.CLASSE  " + Enter
	TcSQLExec(cSQL)

	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_2 AS				" + Enter
	cSQL += "SELECT BITOLA,		" + Enter
	cSQL += "       CLASSE,		" + Enter
	cSQL += "       FORMATO,	" + Enter
	cSQL += "       LINHA,		" + Enter
	cSQL += "       BLQ,			" + Enter
	cSQL += "       SUM(QUANT_FAT)				AS QUANT_FAT,  	-- 2	" + Enter
	cSQL += "       SUM(QUANT_DEV)				AS QUANT_DEV, 	-- 3	" + Enter
	cSQL += "       SUM(QUANT_FAT-QUANT_DEV)	AS QFL,			-- 4	" + Enter
	cSQL += "       SUM(VLR_FAT)					AS VLR_FAT,    	-- 		" + Enter
	cSQL += "       SUM(VLR_FAT-VLR_DEV)	AS QVL,					-- 		" + Enter
	cSQL += "       MAX(MVLR)							AS MVLR_FAT,		-- 		" + Enter
	cSQL += "       MAX(MQTD)							AS MQTD_FAT,		-- 		" + Enter
	cSQL += "       SUM(VLR_IMP)					AS VLR_IMP,   	-- 13	" + Enter
	cSQL += "       SUM(VLR_IMP-IMP_DEV)	AS VLR_IMP_L,   -- 13	" + Enter
	cSQL += "       SUM(VLR_FAT-VLR_IMP)	AS VLR_FSI,			-- 14	" + Enter
	cSQL += "       SUM(VLR_FAT-VLR_DEV-VLR_IMP-IMP_DEV)	AS VLR_FSI_L,	-- 		" + Enter
	cSQL += "       SUM(VLR_COM)					AS VLR_COM,     -- 15	" + Enter
	cSQL += "       SUM(VLR_COM-COM_DEV)	AS VLR_COM_L,   -- 15	" + Enter
	cSQL += "       SUM(VLR_FAT-VLR_IMP-VLR_COM-VLR_DEV-IMP_DEV-COM_DEV) AS VLR_LIQ, -- 16	" + Enter
	cSQL += "       SUM(VLR_DEV)					AS VLR_DEV      -- 		" + Enter
	cSQL += "from TB_RG_2 " + Enter
	cSQL += "GROUP BY BITOLA, CLASSE, FORMATO, LINHA, BLQ " + Enter
	TcSQLExec(cSQL)

	/*
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_2 AS				" + Enter
	cSQL += "SELECT VW_RG_VIEW1.BITOLA,		" + Enter
	cSQL += "       VW_RG_VIEW1.CLASSE,		" + Enter
	cSQL += "       VW_RG_VIEW1.FORMATO,	" + Enter
	cSQL += "       VW_RG_VIEW1.LINHA,		" + Enter
	cSQL += "       VW_RG_VIEW1.BLQ,			" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.QUANT_FAT),0)	AS QUANT_FAT,  	-- 2	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW35.QUANT_DEV),0)	AS QUANT_DEV, 	-- 3	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.QUANT_FAT),0)-ISNULL((VW_RG_VIEW35.QUANT_DEV),0)	AS QFL,	-- 4	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT),0)		AS VLR_FAT,    	-- 		" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT),0)-ISNULL((VW_RG_VIEW35.VLR_DEV),0)		AS QVL,		-- 		" + Enter
	cSQL += "				ISNULL((VW_RG_VIEW0.MVLR),0)			AS MVLR_FAT,	-- 				" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW0.MQTD),0)			AS MQTD_FAT,	-- 				" + Enter

	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_IMP),0)		AS VLR_IMP,   	-- 13	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_IMP),0)-ISNULL((VW_RG_VIEW35.IMP_DEV),0)	AS VLR_IMP_L,   	-- 13	" + Enter

	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT)-(VW_RG_VIEW16.VLR_IMP),0) AS VLR_FSI, -- 14	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT),0)-ISNULL((VW_RG_VIEW35.VLR_DEV),0)-ISNULL((VW_RG_VIEW16.VLR_IMP),0)-ISNULL((VW_RG_VIEW35.IMP_DEV),0)	AS VLR_FSI_L,	-- 		" + Enter

	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_COM),0)		AS VLR_COM,     -- 15	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_COM),0)-ISNULL((VW_RG_VIEW35.COM_DEV),0)	AS VLR_COM_L,   -- 15	" + Enter

	//cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT)-(VW_RG_VIEW16.VLR_IMP)-(VW_RG_VIEW16.VLR_COM),0)-ISNULL((VW_RG_VIEW35.VLR_DEV),0) AS VLR_LIQ, -- 16	" + Enter
	cSQL += "       ISNULL((VW_RG_VIEW16.VLR_FAT)-(VW_RG_VIEW16.VLR_IMP)-(VW_RG_VIEW16.VLR_COM),0)-ISNULL((VW_RG_VIEW35.VLR_DEV),0)-ISNULL((VW_RG_VIEW35.IMP_DEV),0)-ISNULL((VW_RG_VIEW35.COM_DEV),0) AS VLR_LIQ, -- 16	" + Enter

	cSQL += "       ISNULL((VW_RG_VIEW35.VLR_DEV),0)		AS VLR_DEV      -- 		" + Enter

	cSQL += "FROM VW_RG_VIEW0,	-- METAS							" + Enter
	cSQL += "     VW_RG_VIEW1,	-- BITOLA E CLASSE		" + Enter
	cSQL += "     VW_RG_VIEW16, -- QUANTIDADE E VALOR FATURADOS 	" + Enter
	cSQL += "     VW_RG_VIEW35  -- DEVOLUCOES			" + Enter
	cSQL += "WHERE VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW0.BITOLA		AND	" + Enter
	cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW16.BITOLA 	AND	" + Enter
	cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW16.CLASSE 	AND	" + Enter
	cSQL += "      VW_RG_VIEW1.BITOLA	*= VW_RG_VIEW35.BITOLA 	AND	" + Enter
	cSQL += "      VW_RG_VIEW1.CLASSE	*= VW_RG_VIEW35.CLASSE 	AND	" + Enter
	//cSQL += "	   	 VW_RG_VIEW1.EMP		= '"+cempant+"'							" + Enter
	If Len(Alltrim(nEmp)) == 4
	cSQL += "      VW_RG_VIEW1.EMP		= '"+nEmp+"'														" + Enter
	Else
	cSQL += "      SUBSTRING(VW_RG_VIEW1.EMP,1,2) = '"+nEmp+"'														" + Enter
	EndIf
	TcSQLExec(cSQL)*/


	//ATUALIZA VIEWS PARA SUBRELATORIO3         
	//QUANTIDADE EXPEDIDA
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW30 AS 														" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,					-- BITOLA					" + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,					-- CLASSE      		" + Enter
	cSQL += "				SUM(D2_QUANT) AS QUANT_EXP		-- QUANTIDADE EXPEDIDA	" + Enter
	cSQL += "FROM VW_SF2 SF2, VW_SD2 SD2, SB1010 SB1					" + Enter
	cSQL += "WHERE 	SF2.F2_FILIAL	= '"+xFilial("SF2")+"'	AND			" + Enter
	cSQL += "		SD2.D2_FILIAL  	= '"+xFilial("SD2")+"'	AND			" + Enter
	cSQL += "		SF2.F2_SERIE   	= SD2.D2_SERIE			AND			" + Enter
	cSQL += "		SF2.F2_DOC     	= SD2.D2_DOC			AND			" + Enter
	cSQL += "		SF2.F2_CLIENTE 	= SD2.D2_CLIENTE		AND			" + Enter
	cSQL += "		SF2.F2_LOJA		= SD2.D2_LOJA			AND			" + Enter
	cSQL += "		SF2.F2_YEMP		= SD2.D2_YEMP			AND 		" + Enter
	cSQL += "		SF2.F2_YEMPORI	= SD2.D2_YEMPORI		AND 		" + Enter
	cSQL += "		SD2.D2_COD		= SB1.B1_COD			AND 		" + Enter
	cSQL += "       SD2.F4_DUPLIC  	= 'S'					AND			" + Enter
	cSQL += "     	SD2.D2_GRUPO   	= 'PA'					AND			" + Enter
	//cSQL += "	  	SF2.F2_YEMP	 		= '"+cempant+"' 		AND			" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  	SF2.F2_YEMP	 		= '"+nEmp+"' 		AND			" + Enter
	Else
		cSQL += "	  	SUBSTRING(SF2.F2_YEMP,1,2) = '"+nEmp+"' AND	" + Enter
	EndIf
	cSQL += "	  	SF2.F2_YDES			>= '"+DataDe+"' 		AND			" + Enter
	cSQL += "	  	SF2.F2_YDES			<= '"+DataAte+"' 		AND			" + Enter
	cSQL += "	  	SB1.D_E_L_E_T_ 	= ''								" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE 				" + Enter
	TcSQLExec(cSQL)

	//Nome temporário para SB2
	nNomeSB2	:= "TMPRAC_RESGERSB2"+strzero(seconds()*3500,10)
	cSQL := ""
	cSQL += "SELECT * INTO "+nNomeSB2+" FROM (	" + Enter
	cSQL += "SELECT B2_FILIAL, B2_COD, B2_LOCAL, SUM(B2_QATU) AS B2_QATU " + Enter
	cSQL += "FROM (	" + Enter
	If cEmpAnt $ "01_05"
		cSQL += "SELECT '01' EMPRESA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + Enter
		cSQL += "FROM SB2010 " + Enter
		cSQL += "WHERE B2_FILIAL = '01' AND B2_COD >= 'A' AND SUBSTRING(B2_COD,4,4) NOT IN ('0000','000C') AND B2_QATU <> 0 AND D_E_L_E_T_ = '' " + Enter
		cSQL += "UNION ALL " + Enter
		cSQL += "SELECT '05' EMPRESA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + Enter
		cSQL += "FROM SB2050 " + Enter
		cSQL += "WHERE B2_FILIAL = '01' AND B2_COD >= 'A' AND SUBSTRING(B2_COD,4,4) NOT IN ('0000','000C') AND B2_QATU <> 0 AND D_E_L_E_T_ = '' " + Enter
		cSQL += "UNION ALL " + Enter
		cSQL += "SELECT '13' EMPRESA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + Enter
		cSQL += "FROM SB2130 " + Enter
		cSQL += "WHERE B2_FILIAL = '01' AND B2_COD >= 'A' AND SUBSTRING(B2_COD,4,4) NOT IN ('0000','000C') AND B2_QATU <> 0 AND D_E_L_E_T_ = ''  " + Enter
		cSQL += "UNION ALL " + Enter
		cSQL += "SELECT '13' EMPRESA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + Enter
		cSQL += "FROM "+RetSqlName("SB2")+"  " + Enter
		cSQL += "WHERE B2_FILIAL = '01' AND B2_COD >= 'A' AND SUBSTRING(B2_COD,4,4) IN ('0000','000C') AND B2_QATU <> 0 AND D_E_L_E_T_ = '' " + Enter
	Else
		cSQL += "SELECT '"+cEmpAnt+"' EMPRESA, B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU " + Enter
		cSQL += "FROM "+RetSqlName("SB2")+" " + Enter
		cSQL += "WHERE B2_FILIAL = '01' AND B2_COD >= 'A' AND B2_QATU <> 0 AND D_E_L_E_T_ = '' " + Enter
	EndIf
	cSQL += ")TMP " + Enter
	cSQL += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL " + Enter
	cSQL += ")TMP2  " + Enter
	TcSQLExec(cSQL)


	//QUANTIDADE ESTOQUE
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW33 AS								" + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA,		-- BITOLA			" + Enter
	cSQL += "       B1_YCLASSE AS CLASSE,		-- CLASSE			" + Enter
	cSQL += "       SUM(B2_QATU) AS QUANT_ATU	-- QUANTIDADE ATUAL	" + Enter
	//cSQL += "FROM SB1010 SB1, "+RetSqlName("SB2")+" SB2, ZZ7010 ZZ7 " + Enter	
	cSQL += "FROM SB1010 SB1, "+nNomeSB2+" SB2, ZZ7010 ZZ7 " + Enter	
	cSQL += "WHERE 	SB1.B1_FILIAL  = '"+xFilial("SB1")+"'	AND	" + Enter
	cSQL += "      	SB2.B2_FILIAL  = '"+xFilial("SB2")+"'	AND	" + Enter
	cSQL += "      	SB1.B1_COD     = SB2.B2_COD 			AND	" + Enter
	cSQL += "      	SB1.B1_YLINHA  = ZZ7.ZZ7_COD			AND	" + Enter
	cSQL += "      	SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ			AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "      	ZZ7.ZZ7_EMP = '"+nEmp+"' AND  "  + Enter
	Else
		cSQL += "      	SUBSTRING(ZZ7.ZZ7_EMP,1,2) = '"+nEmp+"' AND  "  + Enter
	EndIf
	//EndIf
	/*If nEmp == "0101"
	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	ElseIf nEmp == "0501"
	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	ElseIf nEmp == "0599"
	cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
	EndIf*/
	cSQL += "      	SB1.B1_TIPO    = 'PA' 	 		AND " + Enter
	cSQL += "		SB1.D_E_L_E_T_ = '' 			AND	" + Enter
	//cSQL += "		SB2.D_E_L_E_T_ = ''				AND " + Enter
	cSQL += "		ZZ7.D_E_L_E_T_ = ''										" + Enter
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE	" + Enter
	TcSQLExec(cSQL)

	//PEDIDOS EM CARTEIRA
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW34 AS																		" + Enter
	cSQL += "SELECT SUBSTRING(C6_PRODUTO,1,2) AS BITOLA,       -- BITOLA	" + Enter
	cSQL += "       SUBSTRING(C6_PRODUTO,8,1) AS CLASSE,       -- CLASSE 	" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART -- QUANTIDADE DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "	  	SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "      	SC5.C5_NUM			= SC6.C6_NUM	AND			" + Enter
	cSQL += "      	SC5.C5_CLIENTE	= SC6.C6_CLI	AND			" + Enter
	cSQL += "	  	SC5.C5_YEMP			= SC6.C6_YEMP	AND			" + Enter
	cSQL += "	  	SC5.C5_YEMPORI	= SC6.C6_YEMPORI AND	" + Enter
	//cSQL += "	  	SC5.C5_YEMP			= '"+cempant+"' AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"' AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"' AND	" + Enter
	EndIf
	cSQL += "     	SC5.C5_TIPO			= 'N'			AND				" + Enter
	cSQL += "      	SC6.F4_DUPLIC		= 'S'			AND				" + Enter
	cSQL += "      	SC6.C6_QTDVEN-SC6.C6_QTDENT > 0	AND	" + Enter
	cSQL += "	  	SC6.C6_BLQ			<> 'R' 							" + Enter
	cSQL += "GROUP BY SUBSTRING(C6_PRODUTO,1,2), SUBSTRING(C6_PRODUTO,8,1)	" + Enter           
	TcSQLExec(cSQL)                                                                            

	//
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW25_1 AS														" + Enter
	cSQL += "SELECT B1_COD AS COD,																	" + Enter
	cSQL += "       SUM(B2_QATU) AS QUANT_ATU	-- QUANTIDADE ATUAL		" + Enter
	//cSQL += "FROM SB1010 SB1, "+RetSqlName("SB2")+" SB2, ZZ7010 ZZ7 	" + Enter
	cSQL += "FROM SB1010 SB1, "+nNomeSB2+" SB2, ZZ7010 ZZ7 	" + Enter
	cSQL += "WHERE 	SB1.B1_FILIAL  = '"+xFilial("SB1")+"'		AND			" + Enter
	cSQL += "      	SB2.B2_FILIAL  = '"+xFilial("SB2")+"'		AND			" + Enter
	cSQL += "      	SB1.B1_COD     = SB2.B2_COD 		AND	" + Enter
	cSQL += "      	SB1.B1_YLINHA  = ZZ7.ZZ7_COD		AND	" + Enter
	cSQL += "      	SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "      	ZZ7.ZZ7_EMP = '"+nEmp+"' AND  "  + Enter
	Else
		cSQL += "      	SUBSTRING(ZZ7.ZZ7_EMP,1,2) = '"+nEmp+"' AND  "  + Enter
	EndIf
	/*If nEmp == "0101"
	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	ElseIf nEmp == "0501"
	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	ElseIf nEmp == "0599"
	cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
	EndIf                                                        */
	cSQL += "      	SB1.B1_TIPO    = 'PA' 				AND	" + Enter
	cSQL += "		SB1.D_E_L_E_T_ = '' 				AND	" + Enter
	//cSQL += "		SB2.D_E_L_E_T_ = ''					AND " + Enter
	cSQL += "		ZZ7.D_E_L_E_T_ = ''						" + Enter
	cSQL += "GROUP BY B1_COD 								" + Enter
	TcSQLExec(cSQL)

	//
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW25_2 AS												" + Enter
	cSQL += "SELECT C6_PRODUTO AS COD,													" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART -- QUANTIDADE DE PEDIDOS EM CARTEIRA		" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "		  	SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "    		SC5.C5_NUM			= SC6.C6_NUM						AND	" + Enter
	cSQL += "    		SC5.C5_CLIENTE	= SC6.C6_CLI						AND	" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP						AND	" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI 				AND	" + Enter
	//cSQL += "	  		SC5.C5_YEMP			= '"+cempant+"' 				AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"' 				AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"' AND	" + Enter
	EndIf
	cSQL += "    		SC5.C5_TIPO			= 'N'										AND	" + Enter
	cSQL += "    		SC6.F4_DUPLIC		= 'S'										AND	" + Enter
	cSQL += "   		SC6.C6_QTDVEN-SC6.C6_QTDENT > 0					AND	" + Enter
	cSQL += "	  		SC6.C6_BLQ			<> 'R'											" + Enter
	cSQL += "GROUP BY C6_PRODUTO                               	" + Enter
	TcSQLExec(cSQL)


	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RG_VIEW25 AS																							" + Enter
	//cSQL += "SELECT B1_YFORMAT AS BITOLA, B1_YCLASSE AS CLASSE, SUM(SALDO) SALDO		" + Enter
	//cSQL += "FROM 																																	" + Enter
	//cSQL += "(SELECT B1_YFORMAT, B1_YLINHA, B1_YCLASSE, SUM(QUANT_ATU-QUANT_PEDCART) SALDO	" + Enter
	//cSQL += "FROM 																																	" + Enter
	//cSQL += "(SELECT B1_COD, B1_YFORMAT, B1_YLINHA, B1_YCLASSE, ISNULL(QUANT_ATU,0) QUANT_ATU, ISNULL(QUANT_PEDCART,0) QUANT_PEDCART	" + Enter
	//cSQL += "FROM SB1010 SB1, ZZ7010 ZZ7, VW_RG_VIEW25_1, VW_RG_VIEW25_2	" + Enter
	//cSQL += "WHERE 	SB1.B1_COD  	*= VW_RG_VIEW25_1.COD	AND 	" + Enter
	//cSQL += "      	SB1.B1_COD  	*= VW_RG_VIEW25_2.COD	AND  	" + Enter
	//cSQL += "      	SB1.B1_YLINHA	  = ZZ7.ZZ7_COD				AND	" + Enter
	//cSQL += "      	SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ		AND	" + Enter
	//If nEmp == "0101"
	//	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	//ElseIf nEmp == "0501"
	//	cSQL += "			ZZ7.ZZ7_TIPO	<> 'B'	AND	" + Enter
	//ElseIf nEmp == "0599"
	//	cSQL += "			ZZ7.ZZ7_TIPO	= 'B'	AND	" + Enter
	//EndIf
	//cSQL += "				SB1.B1_RASTRO  = 'L'								AND		" + Enter
	//cSQL += "	  	 	SB1.B1_COD	 	>= 'A'								AND	  " + Enter
	//cSQL += "	  		SB1.D_E_L_E_T_ = '' AND ZZ7.D_E_L_E_T_ = '') WWW " + Enter
	//cSQL += "WHERE QUANT_ATU > 0 OR QUANT_PEDCART > 0			" + Enter
	//cSQL += "GROUP BY B1_YFORMAT, B1_YLINHA, B1_YCLASSE		" + Enter
	//cSQL += "HAVING SUM(QUANT_ATU-QUANT_PEDCART) < 0) WW	" + Enter
	//cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE							" + Enter


	//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW25 AS " + Enter
	cSQL += "SELECT B1_YFORMAT AS BITOLA, B1_YCLASSE AS CLASSE, SUM(SALDO) SALDO		
	cSQL += "FROM 																																	
	cSQL += "	(SELECT B1_YFORMAT, B1_YLINHA, B1_YCLASSE, SUM(QUANT_ATU-QUANT_PEDCART) SALDO	
	cSQL += "	FROM 																																	
	cSQL += "		(SELECT B1_COD, B1_YFORMAT, B1_YLINHA, B1_YCLASSE, ISNULL(QUANT_ATU,0) QUANT_ATU, ISNULL(QUANT_PEDCART,0) QUANT_PEDCART	
	cSQL += "		FROM SB1010 SB1
	cSQL += "			INNER JOIN ZZ7010 ZZ7
	cSQL += "				ON SB1.B1_YLINHA = ZZ7.ZZ7_COD
	cSQL += "					AND SB1.B1_YLINSEQ  = ZZ7.ZZ7_LINSEQ
	If nEmp == "0101"
		cSQL += "					AND ZZ7.ZZ7_TIPO	<> 'B'
	ElseIf nEmp == "0501"
		cSQL += "					AND ZZ7.ZZ7_TIPO	<> 'B'
	ElseIf nEmp == "0599"
		cSQL += "					AND ZZ7.ZZ7_TIPO	= 'B'
	EndIf
	cSQL += "					AND ZZ7.D_E_L_E_T_ = ''
	cSQL += "			LEFT JOIN VW_RG_VIEW25_1
	cSQL += "				ON SB1.B1_COD = VW_RG_VIEW25_1.COD
	cSQL += "			LEFT JOIN VW_RG_VIEW25_2
	cSQL += "				ON SB1.B1_COD = VW_RG_VIEW25_2.COD
	cSQL += "		WHERE SB1.B1_RASTRO  = 'L' AND		
	cSQL += "	  	 			SB1.B1_COD	 	>= 'A' AND	  
	cSQL += "	  				SB1.D_E_L_E_T_ = '') WWW 
	cSQL += "	WHERE QUANT_ATU > 0 OR QUANT_PEDCART > 0			
	cSQL += "	GROUP BY B1_YFORMAT, B1_YLINHA, B1_YCLASSE		
	cSQL += "	HAVING SUM(QUANT_ATU-QUANT_PEDCART) < 0) WW	
	cSQL += "GROUP BY B1_YFORMAT, B1_YCLASSE

	TcSQLExec(cSQL)


	//PEDIDOS PENDENTES PARA O MES ATUAL
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW36 AS																		" + Enter
	cSQL += "SELECT SUBSTRING(C6_PRODUTO,1,2) AS BITOLA,       -- BITOLA	" + Enter
	cSQL += "       SUBSTRING(C6_PRODUTO,8,1) AS CLASSE,       -- CLASSE 	" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART_MES -- QUANTIDADE DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "	  		SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "      	SC5.C5_NUM			= SC6.C6_NUM	AND			" + Enter
	cSQL += "      	SC5.C5_CLIENTE	= SC6.C6_CLI	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND	" + Enter
	//cSQL += "	  		SC5.C5_YEMP			= '"+cempant+"'	 	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "     	SC5.C5_TIPO			= 'N'							AND	" + Enter
	cSQL += "      	SC6.F4_DUPLIC		= 'S'							AND	" + Enter
	cSQL += "				SUBSTRING(SC6.C6_ENTREG,1,6) <= '"+Substr(DataDe,1,6)+"'	AND " + Enter
	cSQL += "      	SC6.C6_QTDVEN-SC6.C6_QTDENT > 0		AND	" + Enter
	cSQL += "	  		SC6.C6_BLQ			<> 'R' 								" + Enter
	cSQL += "GROUP BY SUBSTRING(C6_PRODUTO,1,2), SUBSTRING(C6_PRODUTO,8,1)	" + Enter           
	TcSQLExec(cSQL)                                                                            

	//PEDIDOS PENDENTES PARA O MES 2
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW37 AS																		" + Enter
	cSQL += "SELECT SUBSTRING(C6_PRODUTO,1,2) AS BITOLA,       -- BITOLA	" + Enter
	cSQL += "       SUBSTRING(C6_PRODUTO,8,1) AS CLASSE,       -- CLASSE 	" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART_MES2 -- QUANTIDADE DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "	  		SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "      	SC5.C5_NUM			= SC6.C6_NUM		AND		" + Enter
	cSQL += "      	SC5.C5_CLIENTE	= SC6.C6_CLI		AND		" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP		AND		" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI	AND	" + Enter
	//cSQL += "	  		SC5.C5_YEMP			= '"+cempant+"' 	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "     	SC5.C5_TIPO			= 'N'							AND	" + Enter
	cSQL += "      	SC6.F4_DUPLIC		= 'S'							AND	" + Enter
	cSQL += "		SUBSTRING(SC6.C6_ENTREG,1,6) = '"+SUBST(DTOS(STOD(SUBST(DTOS(MV_PAR01),1,6)+"10")+30),1,6)+"'	AND " + Enter
	cSQL += "      	SC6.C6_QTDVEN-SC6.C6_QTDENT > 0	AND		" + Enter
	cSQL += "	  	SC6.C6_BLQ			<> 'R' 								" + Enter
	cSQL += "GROUP BY SUBSTRING(C6_PRODUTO,1,2), SUBSTRING(C6_PRODUTO,8,1)	" + Enter           
	TcSQLExec(cSQL)                                                                            

	//PEDIDOS PENDENTES PARA O MES 3
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW38 AS																		" + Enter
	cSQL += "SELECT SUBSTRING(C6_PRODUTO,1,2) AS BITOLA,       -- BITOLA	" + Enter
	cSQL += "       SUBSTRING(C6_PRODUTO,8,1) AS CLASSE,       -- CLASSE 	" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART_MES3 -- QUANTIDADE DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "	  		SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "      	SC5.C5_NUM			= SC6.C6_NUM	AND			" + Enter
	cSQL += "      	SC5.C5_CLIENTE	= SC6.C6_CLI	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI AND	" + Enter
	//cSQL += "	  		SC5.C5_YEMP			= '"+cempant+"' AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "     	SC5.C5_TIPO			= 'N'			AND				" + Enter
	cSQL += "      	SC6.F4_DUPLIC		= 'S'			AND				" + Enter
	cSQL += "				SUBSTRING(SC6.C6_ENTREG,1,6) = '"+SUBST(DTOS(STOD(SUBST(DTOS(MV_PAR01),1,6)+"10")+60),1,6)+"'	AND " + Enter
	cSQL += "      	SC6.C6_QTDVEN-SC6.C6_QTDENT > 0	AND	" + Enter
	cSQL += "	  		SC6.C6_BLQ			<> 'R' 							" + Enter
	cSQL += "GROUP BY SUBSTRING(C6_PRODUTO,1,2), SUBSTRING(C6_PRODUTO,8,1)	" + Enter           
	TcSQLExec(cSQL)                                                                            

	//PEDIDOS PENDENTES COM MAIS DE 4 MESES
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW39 AS																		" + Enter
	cSQL += "SELECT SUBSTRING(C6_PRODUTO,1,2) AS BITOLA,       -- BITOLA	" + Enter
	cSQL += "       SUBSTRING(C6_PRODUTO,8,1) AS CLASSE,       -- CLASSE 	" + Enter
	cSQL += "       SUM(C6_QTDVEN-C6_QTDENT)  AS QUANT_PEDCART_MESFUT -- QUANTIDADE DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6												" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "	  		SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "      	SC5.C5_NUM			= SC6.C6_NUM	AND			" + Enter
	cSQL += "      	SC5.C5_CLIENTE	= SC6.C6_CLI	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP	AND			" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI AND	" + Enter
	//cSQL += "	  		SC5.C5_YEMP			= '"+cempant+"' AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "     	SC5.C5_TIPO			= 'N'			AND				" + Enter
	cSQL += "      	SC6.F4_DUPLIC		= 'S'			AND				" + Enter
	cSQL += "				SUBSTRING(SC6.C6_ENTREG,1,6) >= '"+SUBST(DTOS(STOD(SUBST(DTOS(MV_PAR01),1,6)+"10")+90),1,6)+"'	AND " + Enter
	cSQL += "      	SC6.C6_QTDVEN-SC6.C6_QTDENT > 0	AND	" + Enter
	cSQL += "	  		SC6.C6_BLQ			<> 'R' 							" + Enter
	cSQL += "GROUP BY SUBSTRING(C6_PRODUTO,1,2), SUBSTRING(C6_PRODUTO,8,1)	" + Enter           
	TcSQLExec(cSQL)                                                                            

	//Nome temporário para TMP1
	/*nNomeTMP1 := "TMPRAC_RESGERTMP1"+strzero(seconds()*3500,10)
	cSQL := ""
	cSQL += "SELECT * INTO "+nNomeTMP1+" FROM (	" + Enter
	cSQL += "SELECT BITOLA, CLASSE " + Enter
	cSQL += "FROM " + Enter
	cSQL += "(SELECT BITOLA, CLASSE FROM VW_RG_VIEW30" + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW33 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW34 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW25 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW36 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW37 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW38 " + Enter
	cSQL += "UNION " + Enter
	cSQL += "SELECT BITOLA, CLASSE FROM VW_RG_VIEW39) TMP " + Enter
	cSQL += "GROUP BY BITOLA, CLASSE " + Enter
	cSQL += ")TMP2  " + Enter
	TcSQLExec(cSQL)*/

	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RG_3 AS				" + Enter
	//cSQL += "SELECT VW_RG_VIEW1.BITOLA,  	" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE, 	" + Enter
	//cSQL += "      	VW_RG_VIEW1.FORMATO, 	" + Enter
	//cSQL += "      	VW_RG_VIEW1.LINHA,		" + Enter
	//cSQL += "       VW_RG_VIEW1.BLQ,			" + Enter
	//cSQL += "      	ISNULL((VW_RG_VIEW30.QUANT_EXP),0)				AS QUANT_EXP,		-- 30 										" + Enter
	//cSQL += "      	ISNULL(QUANT_ATU,0)								AS QUANT_ATU,		-- QUANTIDADE ATUAL DO ESTOQUE				" + Enter
	//cSQL += "      	ISNULL(QUANT_PEDCART,0)							AS QUANT_PEDCART,	-- QUANTIDADE ATUAL DE PEDIDOS EM CARTEIRA	" + Enter
	//cSQL += "      	ISNULL(QUANT_ATU,0)-ISNULL(QUANT_PEDCART,0)	AS QUANT_DISPON, 		-- QUANTIDADE DISPONIVEL					" + Enter
	//cSQL += "	   	ISNULL(SALDO,0)									AS QUANT_PEDSEST,		--		" + Enter
	//cSQL += "	   	ISNULL(QUANT_PEDCART_MES,0)						AS PED_MESATU,			--		" + Enter
	//cSQL += "	   	ISNULL(QUANT_PEDCART_MES2,0)					AS PED_MES2,			--		" + Enter
	//cSQL += "	   	ISNULL(QUANT_PEDCART_MES3,0)					AS PED_MES3,			--		" + Enter
	//cSQL += "		ISNULL(QUANT_PEDCART_MESFUT,0)					AS PED_MESFUT			--		" + Enter
	//cSQL += "FROM VW_RG_VIEW1,	-- BITOLA E CLASSE						" + Enter
	////cSQL += "FROM "+nNomeTMP1+",	-- BITOLA E CLASSE						" + Enter
	//cSQL += "     VW_RG_VIEW30,	-- QUANTIDADE EXPEDIDA					" + Enter
	//cSQL += "     VW_RG_VIEW33,	-- ESTOQUE ATUAL						" + Enter
	//cSQL += "     VW_RG_VIEW34, -- PEDIDOS EM CARTEIRA					" + Enter
	//cSQL += "     VW_RG_VIEW25,	-- PEDIDOS SEM ESTOQUE					" + Enter
	//cSQL += "     VW_RG_VIEW36,	-- PEDIDOS EM CARTEIRA MES ATUAL		" + Enter
	//cSQL += "     VW_RG_VIEW37,	-- PEDIDOS EM CARTEIRA MES SEGUINTE		" + Enter
	//cSQL += "     VW_RG_VIEW38,	-- PEDIDOS EM CARTEIRA MES SEGUINTE		" + Enter
	//cSQL += "     VW_RG_VIEW39	-- PEDIDOS EM CARTEIRA MESES FUTUROS	" + Enter	
	//cSQL += "WHERE	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW30.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW30.CLASSE	AND		" + Enter
	//cSQL += "  		VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW33.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW33.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW34.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW34.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW25.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW25.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW36.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW36.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW37.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW37.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW38.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW38.CLASSE	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.BITOLA 	*= VW_RG_VIEW39.BITOLA	AND		" + Enter
	//cSQL += "      	VW_RG_VIEW1.CLASSE 	*= VW_RG_VIEW39.CLASSE	AND		" + Enter
	////cSQL += "	   		VW_RG_VIEW1.EMP			= '"+cempant+"'								" + Enter
	//If Len(Alltrim(nEmp)) == 4
	//	cSQL += "	   		VW_RG_VIEW1.EMP			= '"+nEmp+"'								" + Enter
	//Else
	//	cSQL += "	   		VW_RG_VIEW1.EMP			= '"+nEmp+"'								" + Enter
	//EndIf


	//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_3 AS				" + Enter
	cSQL += "SELECT VW_RG_VIEW1.BITOLA,  	" + Enter
	cSQL += "      	VW_RG_VIEW1.CLASSE, 	" + Enter
	cSQL += "      	VW_RG_VIEW1.FORMATO, 	" + Enter
	cSQL += "      	VW_RG_VIEW1.LINHA,		" + Enter
	cSQL += "       VW_RG_VIEW1.BLQ,			" + Enter
	cSQL += "      	ISNULL((VW_RG_VIEW30.QUANT_EXP),0)				AS QUANT_EXP,		-- 30 										" + Enter
	cSQL += "      	ISNULL(QUANT_ATU,0)								AS QUANT_ATU,		-- QUANTIDADE ATUAL DO ESTOQUE				" + Enter
	cSQL += "      	ISNULL(QUANT_PEDCART,0)							AS QUANT_PEDCART,	-- QUANTIDADE ATUAL DE PEDIDOS EM CARTEIRA	" + Enter
	cSQL += "      	ISNULL(QUANT_ATU,0)-ISNULL(QUANT_PEDCART,0)	AS QUANT_DISPON, 		-- QUANTIDADE DISPONIVEL					" + Enter
	cSQL += "	   	ISNULL(SALDO,0)									AS QUANT_PEDSEST,		--		" + Enter
	cSQL += "	   	ISNULL(QUANT_PEDCART_MES,0)						AS PED_MESATU,			--		" + Enter
	cSQL += "	   	ISNULL(QUANT_PEDCART_MES2,0)					AS PED_MES2,			--		" + Enter
	cSQL += "	   	ISNULL(QUANT_PEDCART_MES3,0)					AS PED_MES3,			--		" + Enter
	cSQL += "		ISNULL(QUANT_PEDCART_MESFUT,0)					AS PED_MESFUT			--		" + Enter
	cSQL += " " + Enter
	cSQL += "FROM VW_RG_VIEW1 -- BITOLA E CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW30 -- QUANTIDADE EXPEDIDA " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW30.BITOLA  " + Enter
	cSQL += "      		AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW30.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW33 -- ESTOQUE ATUAL " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW33.BITOLA " + Enter
	cSQL += "			AND	VW_RG_VIEW1.CLASSE = VW_RG_VIEW33.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW34 -- PEDIDOS EM CARTEIRA " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW34.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE= VW_RG_VIEW34.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW25 -- PEDIDOS SEM ESTOQUE " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW25.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW25.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW36 -- PEDIDOS EM CARTEIRA MES ATUAL " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW36.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW36.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW37 -- PEDIDOS EM CARTEIRA MES SEGUINTE " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW37.BITOLA " + Enter
	cSQL += "		AND VW_RG_VIEW1.CLASSE = VW_RG_VIEW37.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW38 -- PEDIDOS EM CARTEIRA MES SEGUINTE " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW38.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE= VW_RG_VIEW38.CLASSE " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW39 -- PEDIDOS EM CARTEIRA MESES FUTUROS " + Enter
	cSQL += "		ON VW_RG_VIEW1.BITOLA = VW_RG_VIEW39.BITOLA " + Enter
	cSQL += "			AND VW_RG_VIEW1.CLASSE= VW_RG_VIEW39.CLASSE " + Enter
	cSQL += "WHERE " + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	VW_RG_VIEW1.EMP			= '" + nEmp + "' " + Enter
	Else
		cSQL += "	VW_RG_VIEW1.EMP			= '" + nEmp + "' " + Enter
	EndIf
	TcSQLExec(cSQL)



	//Quantidade Faturada, por Tipo de Segmento
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW40 AS								" + Enter
	cSQL += "SELECT A1_YTPSEG 		AS CATEGORIA , 			" + Enter
	cSQL += "       SUM(D2_QUANT)	AS QUANT_FAT,		-- QUANTIDADE FATURADA					" + Enter
	cSQL += "       SUM(D2_TOTAL)	AS VLR_FAT			-- VALOR FATURADO SEM IMPOSTOS	" + Enter
	cSQL += "FROM VW_SD2 SD2, SB1010 SB1, SA1010	SA1	" + Enter
	cSQL += "WHERE 	SD2.D2_FILIAL = '"+xFilial("SD2")+"'	AND	" + Enter
	cSQL += "  		SD2.D2_COD	 		= SB1.B1_COD		AND	" + Enter
	cSQL += "  		SD2.D2_CLIENTE  = SA1.A1_COD		AND	" + Enter
	cSQL += "  		SD2.D2_LOJA			= SA1.A1_LOJA		AND	" + Enter
	cSQL += "			SD2.F4_DUPLIC  	= 'S'						AND	" + Enter
	cSQL += "			SD2.D2_GRUPO   	= 'PA'					AND	" + Enter
	//cSQL += "  		SD2.D2_YEMP	 		= '"+cempant+"'	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "  		SD2.D2_YEMP	 		= '"+nEmp+"'	AND	" + Enter
	Else
		cSQL += "  		SUBSTRING(SD2.D2_YEMP,1,2) = '"+nEmp+"'	AND	" + Enter
	EndIf
	cSQL += "  		SD2.D2_EMISSAO	>= '"+Datade+"'		AND	" + Enter
	cSQL += "  		SD2.D2_EMISSAO 	<= '"+DataAte+"'	AND	" + Enter
	//cSQL += "  		SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "			SB1.D_E_L_E_T_ 	= ''						AND	" + Enter
	cSQL += "			SA1.D_E_L_E_T_  = ''								" + Enter
	cSQL += "GROUP BY A1_YTPSEG												" + Enter
	TcSQLExec(cSQL)

	//Quantidade Devolvida, por Tipo de Segmento
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW41 AS	" + Enter
	cSQL += "SELECT A1_YTPSEG AS CATEGORIA, SUM(D1_QUANT) AS QUANT_DEV, SUM(D1_TOTAL) AS VLR_DEV	" + Enter
	cSQL += "FROM VW_SD1, SA1010 SA1		" + Enter
	cSQL += "WHERE	D1_FILIAL			= '"+xFilial("SD1")+"'	AND " + Enter
	cSQL += "				D1_FORNECE  	= A1_COD 				AND					" + Enter
	cSQL += "				D1_LOJA     	= A1_LOJA 			AND					" + Enter
	//cSQL += "				D1_YEMP				= '"+cempant+"'	AND					" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				D1_YEMP				= '"+nEmp+"'	AND					" + Enter
	Else
		cSQL += "				SUBSTRING(D1_YEMP,1,2) = '"+nEmp+"'	AND					" + Enter
	EndIf
	cSQL += "				F4_ESTOQUE		= 'S'						AND					" + Enter
	cSQL += "				D1_CF					IN ('1201','2201','1202','2202','1203','2203','1410','2410')	AND	" + Enter
	cSQL += "				D1_TP					= 'PA'						AND				" + Enter
	cSQL += "				D1_DTDIGIT		>= '"+Datade+"'		AND				" + Enter
	cSQL += "				D1_DTDIGIT		<= '"+DataAte+"'	AND				" + Enter
	//cSQL += "  			SUBSTRING(D1_COD,1,2) IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SA1.D_E_L_E_T_ = ''												" + Enter
	cSQL += "GROUP BY A1_YTPSEG 															" + Enter
	TcSQLExec(cSQL)

	//Pedido Emitidos, por Tipo de Segmento
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW42 AS 																	" + Enter
	cSQL += "SELECT A1_YTPSEG AS CATEGORIA, SUM(C6_QTDVEN) AS QUANT_PED		" + Enter
	cSQL += "FROM 																												" + Enter
	cSQL += "(SELECT C5_CLIENTE, C5_LOJACLI, C6_QTDVEN, C6_VALOR,					" + Enter
	cSQL += "		(SELECT A1_YTPSEG FROM SA1010 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND D_E_L_E_T_ = '') A1_YTPSEG " + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, SB1010 SB1					" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "				SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "				SC5.C5_NUM			= SC6.C6_NUM 						AND	" + Enter
	cSQL += "				SC5.C5_CLIENTE	= SC6.C6_CLI 						AND	" + Enter
	cSQL += "				SC5.C5_LOJACLI	= SC6.C6_LOJA 					AND	" + Enter
	cSQL += "				SC5.C5_YEMP			= SC6.C6_YEMP 					AND	" + Enter
	cSQL += "				SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND	" + Enter
	cSQL += "				SC6.C6_PRODUTO	= SB1.B1_COD 			AND	" + Enter
	//cSQL += "				SC5.C5_YEMP			= '"+cempant+"'		AND " + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "				SC5.C5_TIPO			= 'N'							AND " + Enter
	cSQL += "				SC6.F4_DUPLIC		= 'S'							AND	" + Enter
	cSQL += "				SB1.B1_TIPO			= 'PA'						AND	" + Enter
	cSQL += "				SC5.C5_EMISSAO	>= '"+Datade+"'		AND	" + Enter
	cSQL += "				SC5.C5_EMISSAO	<= '"+DataAte+"'	AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND	" + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_	= '' ) WWW						" + Enter
	cSQL += "GROUP BY A1_YTPSEG														" + Enter
	TcSQLExec(cSQL)

	//Pedidos Eliminados por Residuo, por Tipo de Segmento
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW43 AS																			" + Enter
	cSQL += "SELECT A1_YTPSEG AS CATEGORIA, SUM(C6_QTDVEN) AS QUANT_PED_R		" + Enter
	cSQL += "FROM 																													" + Enter
	cSQL += "(SELECT C5_CLIENTE, C5_LOJACLI, C6_QTDVEN, C6_VALOR,						" + Enter
	cSQL += "		(SELECT A1_YTPSEG FROM SA1010 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND D_E_L_E_T_ = '') A1_YTPSEG " + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, SB1010 SB1						" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "				SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "				SC5.C5_NUM			= SC6.C6_NUM 			AND	" + Enter
	cSQL += "				SC5.C5_CLIENTE	= SC6.C6_CLI 			AND	" + Enter
	cSQL += "	  		SC5.C5_LOJACLI	= SC6.C6_LOJA 		AND	" + Enter
	cSQL += "	  		SC5.C5_YEMP			= SC6.C6_YEMP 		AND	" + Enter
	cSQL += "	  		SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND	" + Enter
	cSQL += "				SC6.C6_PRODUTO	= SB1.B1_COD 			AND	" + Enter
	//cSQL += "				SC5.C5_YEMP			= '"+cempant+"'		AND " + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "				SC5.C5_TIPO			= 'N'							AND " + Enter
	cSQL += "				SC6.C6_BLQ			= 'R'							AND	" + Enter
	cSQL += "				SC6.F4_DUPLIC		= 'S'							AND	" + Enter
	cSQL += "				SB1.B1_TIPO			= 'PA'						AND	" + Enter
	cSQL += "				SC6.C6_YDTRESI	>= '"+Datade+"'		AND	" + Enter
	cSQL += "				SC6.C6_YDTRESI	<= '"+DataAte+"'	AND " + Enter
	cSQL += "	  		SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND	" + Enter
	cSQL += "	  		SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND	" + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_	= '' ) WW							" + Enter
	cSQL += "GROUP BY A1_YTPSEG														" + Enter
	TcSQLExec(cSQL)

	//Metas por Tipo de Segmento
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW44 AS				" + Enter
	cSQL += "SELECT SCT.CT_CATEGO AS CATEGORIA,		" + Enter
	cSQL += "	   (SUM(CT_QUANT)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MQTD, " + Enter
	cSQL += "	   (SUM(CT_VALOR)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MVLR	 " + Enter
	cSQL += "FROM "+RetSqlName("SCT")+" SCT		" + Enter
	cSQL += "WHERE	SCT.CT_FILIAL = '"+xFilial("SCT")+"'	AND	" + Enter
	cSQL += "				SUBSTRING(SCT.CT_DATA,1,6) >= '"+Substr(Datade,1,6)+"'	AND	" + Enter
	cSQL += "				SUBSTRING(SCT.CT_DATA,1,6) <= '"+Substr(DataAte,1,6)+"'	AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				SCT.CT_YEMP = '"+nEmp+"' AND " + Enter
	Else
		cSQL += "				SUBSTRING(SCT.CT_YEMP,1,2) = '"+nEmp+"' AND " + Enter
	EndIf
	cSQL += "				SCT.CT_YFORMAT IN (SELECT BITOLA FROM VW_RG_VIEW1 GROUP BY BITOLA) AND " + Enter
	cSQL += "				SCT.D_E_L_E_T_ = ''										" + Enter
	cSQL += "GROUP BY SCT.CT_CATEGO														" + Enter
	TcSQLExec(cSQL)


	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RG_4 AS														" + Enter
	//cSQL += "SELECT	A1_YTPSEG, 																" + Enter
	//cSQL += "				SUM(ISNULL(QUANT_FAT,0)-ISNULL(QUANT_DEV,0))	AS QUANT_FAT, 	" + Enter
	//cSQL += "				SUM(ISNULL(VLR_FAT,0)-ISNULL(VLR_DEV,0)) 		AS VLR_FAT, 			" + Enter
	//cSQL += "				SUM(ISNULL(QUANT_PED,0)-ISNULL(QUANT_PED_R,0))	AS QUANT_PED,	" + Enter
	//cSQL += "				SUM(ISNULL(MQTD,0)) AS MQTD,	" + Enter
	//cSQL += "				SUM(ISNULL(MVLR,0)) AS MVLR		" + Enter
	//cSQL += "FROM (SELECT A1_YTPSEG FROM SA1010 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_ = '' GROUP BY A1_YTPSEG) SA1, " + Enter
	//cSQL += "     VW_RG_VIEW40, --FATURAMENTO			" + Enter
	//cSQL += "     VW_RG_VIEW41, --DEVOLUCAO FAT		" + Enter
	//cSQL += "     VW_RG_VIEW42, --PEDIDOS 				" + Enter
	//cSQL += "     VW_RG_VIEW43, --PEDIDOS RESIDUO	" + Enter
	//cSQL += "     VW_RG_VIEW44  --METAS 					" + Enter
	//cSQL += "WHERE	SA1.A1_YTPSEG *= VW_RG_VIEW40.CATEGORIA AND	" + Enter
	//cSQL += "				SA1.A1_YTPSEG *= VW_RG_VIEW41.CATEGORIA AND	" + Enter
	//cSQL += "				SA1.A1_YTPSEG *= VW_RG_VIEW42.CATEGORIA AND	" + Enter
	//cSQL += "				SA1.A1_YTPSEG *= VW_RG_VIEW43.CATEGORIA AND	" + Enter
	//cSQL += "				SA1.A1_YTPSEG *= VW_RG_VIEW44.CATEGORIA 		" + Enter
	//cSQL += "GROUP BY A1_YTPSEG																	" + Enter



	//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_4 AS														" + Enter
	cSQL += "SELECT	A1_YTPSEG, 																" + Enter
	cSQL += "				SUM(ISNULL(QUANT_FAT,0)-ISNULL(QUANT_DEV,0))	AS QUANT_FAT, 	" + Enter
	cSQL += "				SUM(ISNULL(VLR_FAT,0)-ISNULL(VLR_DEV,0)) 		AS VLR_FAT, 			" + Enter
	cSQL += "				SUM(ISNULL(QUANT_PED,0)-ISNULL(QUANT_PED_R,0))	AS QUANT_PED,	" + Enter
	cSQL += "				SUM(ISNULL(MQTD,0)) AS MQTD,	" + Enter
	cSQL += "				SUM(ISNULL(MVLR,0)) AS MVLR		" + Enter
	cSQL += "FROM (SELECT A1_YTPSEG FROM SA1010 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND D_E_L_E_T_ = '' GROUP BY A1_YTPSEG) SA1 " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW40 --FATURAMENTO " + Enter
	cSQL += "		ON SA1.A1_YTPSEG = VW_RG_VIEW40.CATEGORIA " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW41 --DEVOLUCAO FAT " + Enter
	cSQL += "		ON SA1.A1_YTPSEG = VW_RG_VIEW41.CATEGORIA " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW42 --PEDIDOS " + Enter
	cSQL += "		ON SA1.A1_YTPSEG = VW_RG_VIEW42.CATEGORIA " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW43 --PEDIDOS RESIDUO " + Enter
	cSQL += "		ON SA1.A1_YTPSEG = VW_RG_VIEW43.CATEGORIA " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW44 --METAS " + Enter
	cSQL += "		ON SA1.A1_YTPSEG = VW_RG_VIEW44.CATEGORIA " + Enter
	cSQL += "GROUP BY A1_YTPSEG " + Enter
	TcSQLExec(cSQL)             


	//Quantidade Faturada por Tipo Produto
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW60 AS						" + Enter
	cSQL += "SELECT B1_YTPPROD		AS TPPROD , 		" + Enter
	cSQL += "       SUM(D2_QUANT)	AS QUANT_FAT		-- QUANTIDADE FATURADA " + Enter
	cSQL += "FROM VW_SD2 SD2, SB1010 SB1					" + Enter
	cSQL += "WHERE	SD2.D2_FILIAL  	= '"+xFilial("SD2")+"'	AND	" + Enter
	cSQL += "  			SD2.D2_COD	 		= SB1.B1_COD			AND	" + Enter
	cSQL += "      	SD2.F4_DUPLIC  	= 'S'							AND	" + Enter
	cSQL += "      	SD2.D2_GRUPO   	= 'PA'						AND	" + Enter
	//cSQL += "  			SD2.D2_YEMP	 		= '"+cempant+"'		AND	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "  			SD2.D2_YEMP	 		= '"+nEmp+"'		AND	" + Enter
	Else
		cSQL += "  			SUBSTRING(SD2.D2_YEMP,1,2) = '"+nEmp+"'		AND	" + Enter
	EndIf
	cSQL += "  			SD2.D2_EMISSAO	>= '"+Datade+"' 	AND	" + Enter
	cSQL += "  			SD2.D2_EMISSAO 	<= '"+DataAte+"' 	AND	" + Enter
	cSQL += "  			SB1.B1_YTPPROD  = 'RE'						AND	" + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_ 	= ''									" + Enter
	cSQL += "GROUP BY B1_YTPPROD                    			" + Enter
	TcSQLExec(cSQL)             


	//Quantidade Devolvida por Tipo Produto
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW61 AS 										" + Enter
	cSQL += "SELECT B1_YTPPROD AS TPPROD, SUM(D1_QUANT) AS QUANT_DEV " + Enter
	cSQL += "FROM VW_SD1, SB1010 SB1												" + Enter
	cSQL += "WHERE	D1_FILIAL		= '"+xFilial("SD1")+"'	AND " + Enter
	//cSQL += "				D1_YEMP			= '"+cempant+"'		AND	" + Enter	
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				D1_YEMP			= '"+nEmp+"'		AND	" + Enter	
	Else
		cSQL += "				SUBSTRING(D1_YEMP,1,2) = '"+nEmp+"'		AND	" + Enter	
	EndIf
	cSQL += "				D1_COD			= B1_COD					AND	" + Enter
	cSQL += "				F4_ESTOQUE	= 'S'							AND	" + Enter
	cSQL += "				D1_CF			IN ('1201','2201','1202','2202','1203','2203','1410','2410')	AND	" + Enter 
	cSQL += "				D1_TP				= 'PA'						AND	" + Enter
	cSQL += "				D1_DTDIGIT	>= '"+Datade+"'		AND	" + Enter
	cSQL += "				D1_DTDIGIT	<= '"+DataAte+"'	AND " + Enter
	cSQL += "				SB1.B1_YTPPROD	= 'RE'				AND " + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_	= ''							" + Enter
	cSQL += "GROUP BY B1_YTPPROD  										" + Enter
	TcSQLExec(cSQL)             


	//Pedidos Emitidos por Tipo de Produto
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW62 AS 														" + Enter
	cSQL += "SELECT B1_YTPPROD AS TPPROD, SUM(C6_QTDVEN) QUANT_PED	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, SB1010 SB1						" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "				SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "				SC5.C5_NUM			= SC6.C6_NUM			AND	" + Enter
	cSQL += "				SC5.C5_CLIENTE	= SC6.C6_CLI			AND	" + Enter
	cSQL += "				SC5.C5_LOJACLI	= SC6.C6_LOJA			AND	" + Enter
	cSQL += "				SC5.C5_YEMP			= SC6.C6_YEMP			AND	" + Enter
	cSQL += "				SC5.C5_YEMPORI	= SC6.C6_YEMPORI 	AND	" + Enter
	cSQL += "				SC6.C6_PRODUTO	= SB1.B1_COD 			AND	" + Enter
	//cSQL += "				SC5.C5_YEMP			= '"+cempant+"'		AND " + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "				SC5.C5_TIPO			= 'N'							AND " + Enter
	cSQL += "				SC6.F4_DUPLIC		= 'S'							AND	" + Enter
	cSQL += "				SB1.B1_TIPO			= 'PA'						AND	" + Enter
	cSQL += "				SB1.B1_YTPPROD  = 'RE'						AND	" + Enter
	cSQL += "				SC5.C5_EMISSAO	>= '"+Datade+"'		AND	" + Enter
	cSQL += "				SC5.C5_EMISSAO	<= '"+DataAte+"'	AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,1) >= 'A'	AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND	" + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_	= ''									" + Enter
	cSQL += "GROUP BY B1_YTPPROD 													" + Enter
	TcSQLExec(cSQL)             

	//Pedidos Eliminados por Residuo por Tipo de Produto
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW63 AS 															" + Enter
	cSQL += "SELECT B1_YTPPROD AS TPPROD, SUM(C6_QTDVEN) QUANT_PED_R	" + Enter
	cSQL += "FROM VW_SC5 SC5, VW_SC6 SC6, SB1010 SB1						" + Enter
	cSQL += "WHERE	SC5.C5_FILIAL		= '"+xFilial("SC5")+"'	AND	" + Enter
	cSQL += "				SC6.C6_FILIAL		= '"+xFilial("SC6")+"'	AND	" + Enter
	cSQL += "				SC5.C5_NUM			= SC6.C6_NUM 				AND	" + Enter
	cSQL += "				SC5.C5_CLIENTE	= SC6.C6_CLI 				AND	" + Enter
	cSQL += "				SC5.C5_LOJACLI	= SC6.C6_LOJA 			AND	" + Enter
	cSQL += "				SC5.C5_YEMP			= SC6.C6_YEMP 			AND	" + Enter
	cSQL += "				SC5.C5_YEMPORI	= SC6.C6_YEMPORI 		AND	" + Enter
	cSQL += "				SC6.C6_PRODUTO	= SB1.B1_COD 				AND	" + Enter
	//cSQL += "				SC5.C5_YEMP			= '"+cempant+"'			AND " + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "	  		SC5.C5_YEMP			= '"+nEmp+"'	 	AND	" + Enter
	Else
		cSQL += "	  		SUBSTRING(SC5.C5_YEMP,1,2) = '"+nEmp+"'	 	AND	" + Enter
	EndIf
	cSQL += "				SC5.C5_TIPO			= 'N'								AND " + Enter
	cSQL += "				SC6.C6_BLQ			= 'R'								AND	" + Enter
	cSQL += "				SC6.F4_DUPLIC		= 'S'								AND	" + Enter
	cSQL += "				SB1.B1_TIPO			= 'PA'							AND	" + Enter
	cSQL += "				SC6.C6_YDTRESI	>= '"+Datade+"'			AND	" + Enter
	cSQL += "				SC6.C6_YDTRESI	<= '"+DataAte+"'		AND	" + Enter
	cSQL += "				SB1.B1_YTPPROD	= 'RE'							AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,1) >= 'A'		AND	" + Enter
	cSQL += "				SUBSTRING(SB1.B1_COD,1,2) NOT IN ('AB','AC','AD','AE','AF') AND	" + Enter
	//cSQL += "  		  SB1.B1_YFORMAT  IN (SELECT DISTINCT(BITOLA) FROM VW_RG_VIEW1 WHERE EMP = '"+cempant+"') AND " + Enter
	cSQL += "				SB1.D_E_L_E_T_	= ''										" + Enter
	cSQL += "GROUP BY B1_YTPPROD														" + Enter
	TcSQLExec(cSQL)             


	//Metas por Tipo de Produto
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_VIEW64 AS				" + Enter
	cSQL += "SELECT ZZ6_TPPROD AS TPPROD,			" + Enter
	cSQL += "	   (SUM(CT_QUANT)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MQTD, " + Enter
	cSQL += "	   (SUM(CT_VALOR)/(SELECT dbo.FN_DIAS_UTEIS('"+Substr(Datade,1,6)+"01"+"', DATEADD(MONTH,1,'"+Substr(DataAte,1,6)+"01"+"' )-1)))*(SELECT dbo.FN_DIAS_UTEIS('"+Datade+"',  '"+DataAte+"' )) AS MVLR	 " + Enter
	cSQL += "FROM "+RetSqlName("SCT")+" SCT, "+RetSqlName("ZZ6")+" ZZ6 	" + Enter
	cSQL += "WHERE	CT_FILIAL	  = '"+xFilial("SCT")+"'	AND								" + Enter
	cSQL += "		SCT.CT_YFORMAT	= ZZ6.ZZ6_COD			AND											" + Enter
	cSQL += "		ZZ6.ZZ6_TPPROD 	= 'RE'					AND 										" + Enter
	cSQL += "		SUBSTRING(CT_DATA,1,6) >= '"+Substr(Datade,1,6)+"'	AND		" + Enter
	cSQL += "		SUBSTRING(CT_DATA,1,6) <= '"+Substr(DataAte,1,6)+"'	AND 	" + Enter
	If Len(Alltrim(nEmp)) == 4
		cSQL += "				CT_YEMP = '"+nEmp+"' AND " + Enter
	Else
		cSQL += "				SUBSTRING(CT_YEMP,1,2) = '"+nEmp+"' AND " + Enter
	EndIf
	cSQL += "		SCT.D_E_L_E_T_ 	= ''							AND	" + Enter
	cSQL += "		ZZ6.D_E_L_E_T_ 	= ''								" + Enter
	cSQL += "GROUP BY ZZ6_TPPROD										" + Enter
	TcSQLExec(cSQL)             


	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RG_6 AS												" + Enter
	//cSQL += "SELECT	ZZ6_TPPROD, 													" + Enter
	//cSQL += "		SUM(ISNULL(QUANT_FAT,0)-ISNULL(QUANT_DEV,0)) AS QUANT_FAT, 		" + Enter
	//cSQL += "		SUM(ISNULL(QUANT_PED,0)-ISNULL(QUANT_PED_R,0)) AS QUANT_PED,	" + Enter
	//cSQL += "		SUM(ISNULL(MQTD,0)) AS MQTD,	" + Enter
	//cSQL += "		SUM(ISNULL(MVLR,0)) AS MVLR		" + Enter
	//cSQL += "FROM (SELECT ZZ6_TPPROD FROM "+RetSqlName("ZZ6")+" WHERE ZZ6_FILIAL = '"+xFilial("ZZ6")+"' AND ZZ6_TPPROD = 'RE' AND D_E_L_E_T_ = '' GROUP BY ZZ6_TPPROD) ZZ6, 	" + Enter
	//cSQL += "     VW_RG_VIEW60, --FATURAMENTO				" + Enter
	//cSQL += "     VW_RG_VIEW61, --DEVOLUCAO FAT			" + Enter
	//cSQL += "     VW_RG_VIEW62, --PEDIDOS 					" + Enter
	//cSQL += "     VW_RG_VIEW63, --PEDIDOS REDIDUO		" + Enter
	//cSQL += "     VW_RG_VIEW64  --METAS 						" + Enter
	//cSQL += "WHERE ZZ6.ZZ6_TPPROD *= VW_RG_VIEW60.TPPROD AND	" + Enter
	//cSQL += "	  ZZ6.ZZ6_TPPROD *= VW_RG_VIEW61.TPPROD AND			" + Enter
	//cSQL += "	  ZZ6.ZZ6_TPPROD *= VW_RG_VIEW62.TPPROD AND			" + Enter
	//cSQL += "	  ZZ6.ZZ6_TPPROD *= VW_RG_VIEW63.TPPROD AND			" + Enter
	//cSQL += "	  ZZ6.ZZ6_TPPROD *= VW_RG_VIEW64.TPPROD 				" + Enter
	//cSQL += "GROUP BY ZZ6_TPPROD															" + Enter



	//ATUALIZAÇÃO QUERY - SQL ATUAL - 20/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RG_6 AS												" + Enter
	cSQL += "SELECT	ZZ6_TPPROD, 													" + Enter
	cSQL += "		SUM(ISNULL(QUANT_FAT,0)-ISNULL(QUANT_DEV,0)) AS QUANT_FAT, 		" + Enter
	cSQL += "		SUM(ISNULL(QUANT_PED,0)-ISNULL(QUANT_PED_R,0)) AS QUANT_PED,	" + Enter
	cSQL += "		SUM(ISNULL(MQTD,0)) AS MQTD,	" + Enter
	cSQL += "		SUM(ISNULL(MVLR,0)) AS MVLR		" + Enter
	cSQL += "FROM (SELECT ZZ6_TPPROD FROM " + RetSqlName("ZZ6") + " WHERE ZZ6_FILIAL = '" + xFilial("ZZ6") + "' AND ZZ6_TPPROD = 'RE' AND D_E_L_E_T_ = '' GROUP BY ZZ6_TPPROD) ZZ6 " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW60 --FATURAMENTO " + Enter
	cSQL += "		ON ZZ6.ZZ6_TPPROD = VW_RG_VIEW60.TPPROD " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW61 --DEVOLUCAO FAT " + Enter
	cSQL += "		ON ZZ6.ZZ6_TPPROD = VW_RG_VIEW61.TPPROD " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW62 --PEDIDOS " + Enter
	cSQL += "		ON ZZ6.ZZ6_TPPROD = VW_RG_VIEW62.TPPROD " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW63 --PEDIDOS REDIDUO " + Enter
	cSQL += "		ON ZZ6.ZZ6_TPPROD = VW_RG_VIEW63.TPPROD " + Enter
	cSQL += "	LEFT JOIN VW_RG_VIEW64 --METAS " + Enter
	cSQL += "		ON ZZ6.ZZ6_TPPROD = VW_RG_VIEW64.TPPROD " + Enter
	cSQL += "GROUP BY ZZ6_TPPROD " + Enter
	TcSQLExec(cSQL)             



	If aReturn[5]==1
		//Parametros Crystal Em Disco
		cOpcao:="1;0;1;Resumo Gerencial"
	Else
		//Direto Impressora
		cOpcao:="3;0;1;Resumo Gerencial"
	Endif

	//Chama Relatorio em Crystal
	callcrys("RESGER_NEW",DTOC(MV_PAR01)+";"+DTOC(MV_PAR02)+';'+Alltrim(Str(MV_PAR03))+";"+Alltrim(Str(MV_PAR04)),cOpcao)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 	 ³ValidPerg    ³ Autor ³ Bruno Madaleno                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	Local _j, _i
	lOCAL _aPerguntas := {}

	//"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP"
	aAdd(_aPerguntas,{cPerg,"01","Data De ?"  ,"Data De ?"  ,"Data De ?"  ,"MV_CH0","D",8,9,0,"G","","MV_PAR01",""  ,""  ,""  ,"","",""  ,""  ,""  ,"","","","","","","","","","","","","","","","","","","",""})
	aAdd(_aPerguntas,{cPerg,"02","Data Ate ?" ,"Data Ate ?" ,"Data Ate ?" ,"MV_CH0","D",8,0,0,"G","","MV_PAR02",""  ,""  ,""  ,"","",""  ,""  ,""  ,"","","","","","","","","","","","","","","","","","","",""})

	//RES_GE
	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return
