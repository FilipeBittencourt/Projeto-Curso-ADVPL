#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG022
@author Gabriel Rossi Mafioletti
@since 29/08/2017
@version 1.0
@description Relatório de Pedidos em Aberto
@type function
/*/

User Function BIAFG022()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

	fQryDados()

return

Static Function ValidPerg()

	local cLoad	    := "BIAFG022" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 := SPACE(100)
	
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR01 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Pedidos em Aberto",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

		if empty(MV_PAR01) 
			MV_PAR01 := AllTrim(GetTempPath()) 	
		endif

	EndIf

Return lRet

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	local nRegAtu   := 0

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG022_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	BeginSql Alias _cAlias
		%NoParser%

		WITH PEDIDOSABERTOS
		AS ( SELECT DISTINCT '01' EMPR ,
		            C7_EMISSAO EMISSAO ,
		            C7_NUM NUMPC ,
		            C7_ITEM ITEMPC ,
		            C7_FORNECE FORNEC ,
		            C7_LOJA LOJA ,
		            C7_PRODUTO PRODUTO ,
		            RTRIM(C7_DESCRI) DESCR ,
		            C7_CLVL CLVL,
		            C7_CC CC,
		            C7_QUANT QUANT ,
		            C7_PRECO VLRUNIT ,
		            C7_TOTAL VLRTOTAL ,
		            C7_QUJE QUJE ,
		            C7_YDATCHE DTCHEG ,
		            C7_YDTNECE DTNECE ,
		            C7_YDTENV DTENV ,
		            C7_DATPRF ENTREG ,
		            C7_YDATEMA DTFUP ,
		            C7_YQUAEMA QTDFUP ,
		            C7_NUMSC NUMSC ,
		            C7_ITEMSC ITEMSC ,
		            C7_RESIDUO RESIDUO ,
		            SCR.CR_APROV APROV ,
		            SAK.AK_NOME NM_APR ,
		            C7_CONAPRO _STATUS ,
		            SC7.C7_USER USUARIO ,
		            CR_DATALIB DTLIB ,
		            C1_EMISSAO ,
		            C1_SOLICIT ,
		            C7_YFOLLOW,
					C7_LOCAL,
					C7_YTRANSP
		     FROM   SC7010 SC7
		            LEFT JOIN dbo.SCR010 SCR ON SCR.CR_FILIAL = SC7.C7_FILIAL
		                                        AND SCR.CR_NUM = SC7.C7_NUM
												AND SCR.CR_STATUS <> '06'
		                                        AND SCR.D_E_L_E_T_ = ''
		            LEFT JOIN SAK010 SAK ON SAK.AK_FILIAL = SCR.CR_FILIAL
		                                    AND SAK.AK_COD = SCR.CR_APROV
		                                    AND SAK.D_E_L_E_T_ = ''
		            LEFT JOIN SC1010 SC1 ON C1_FILIAL = '01'
		                                    AND C1_NUM = C7_NUMSC
		                                    AND C1_ITEM = C7_ITEMSC
		                                    AND SC1.D_E_L_E_T_ = ' '
		     WHERE  C7_FILIAL = '01'
		            AND C7_QUANT - C7_QUJE > 0
		            AND C7_RESIDUO = ' '
					AND C7_CONAPRO <> 'R'
		            AND SC7.D_E_L_E_T_ = ' '
		     UNION ALL
		     SELECT DISTINCT '05' EMPR ,
		            C7_EMISSAO EMISSAO ,
		            C7_NUM NUMPC ,
		            C7_ITEM ITEMPC ,
		            C7_FORNECE FORNEC ,
		            C7_LOJA LOJA ,
		            C7_PRODUTO PRODUTO ,
		            RTRIM(C7_DESCRI) DESCR ,
		            C7_CLVL CLVL,
		            C7_CC CC,
		            C7_QUANT QUANT ,
		            C7_PRECO VLRUNIT ,
		            C7_TOTAL VLRTOTAL ,
		            C7_QUJE QUJE ,
		            C7_YDATCHE DTCHEG ,
		            C7_YDTNECE DTNECE ,
		            C7_YDTENV DTENV ,
		            C7_DATPRF ENTREG ,
		            C7_YDATEMA DTFUP ,
		            C7_YQUAEMA QTDFUP ,
		            C7_NUMSC NUMSC ,
		            C7_ITEMSC ITEMSC ,
		            C7_RESIDUO RESIDUO ,
		            SCR.CR_APROV APROV ,
		            SAK.AK_NOME NM_APR ,
		            C7_CONAPRO _STATUS ,
		            SC7.C7_USER USUARIO ,
		            CR_DATALIB DTLIB ,
		            C1_EMISSAO ,
		            C1_SOLICIT ,
		            C7_YFOLLOW,
					C7_LOCAL,
					C7_YTRANSP
		     FROM   SC7050 SC7
		            LEFT JOIN dbo.SCR050 SCR ON SCR.CR_FILIAL = SC7.C7_FILIAL
		                                        AND SCR.CR_NUM = SC7.C7_NUM
												AND SCR.CR_STATUS <> '06'
		                                        AND SCR.D_E_L_E_T_ = ''
		            LEFT JOIN SAK050 SAK ON SAK.AK_FILIAL = SCR.CR_FILIAL
		                                    AND SAK.AK_COD = SCR.CR_APROV
		                                    AND SAK.D_E_L_E_T_ = ''
		            LEFT JOIN SC1050 SC1 ON C1_FILIAL = '01'
		                                    AND C1_NUM = C7_NUMSC
		                                    AND C1_ITEM = C7_ITEMSC
		                                    AND SC1.D_E_L_E_T_ = ' '
		     WHERE  C7_FILIAL = '01'
		            AND C7_QUANT - C7_QUJE > 0
		            AND C7_RESIDUO = ' '
					AND C7_CONAPRO <> 'R'
		            AND SC7.D_E_L_E_T_ = ' ' )
		SELECT PCA.* ,
		       B1_GRUPO ,
		       BM_DESC ,
		       A2_NOME NOMFOR ,
		       Y1_NOME COMPRAD ,
		       A2_TEL TEL ,
		       A2_EMAIL EMAIL ,
		       C1_EMISSAO EMIS_SC ,
		       C1_SOLICIT SOLICITANTE ,
		       C7_YFOLLOW OBS_FOLLOW ,
		       DATEDIFF(DD, EMISSAO, GETDATE()) DEmissao ,
		       (CASE WHEN DTCHEG = '' THEN 9999
		            ELSE DATEDIFF(DD, DTCHEG, GETDATE())
		       END) DChegada ,
		       (CASE WHEN DTNECE = '' THEN 9999
		            ELSE DATEDIFF(DD, DTNECE, GETDATE())
		       END) DNecessidade ,
		       (CASE WHEN ENTREG = '' THEN 9999
		            ELSE DATEDIFF(DD, ENTREG, GETDATE())
		       END) DEntrega ,
		       (CASE WHEN DTCHEG = '' THEN 9999
		            ELSE DATEDIFF(DD, EMISSAO, DTCHEG)
		       END) DchegadaDemissao,
				C7_LOCAL AS ALMOX,
				C7_YTRANSP AS TRANSP
		FROM   PEDIDOSABERTOS PCA
		       LEFT JOIN SY1010 SY1 ON Y1_FILIAL = '  '
		                               AND Y1_USER = USUARIO
		                               AND SY1.D_E_L_E_T_ = ' '
		       LEFT JOIN SA2010 SA2 ON A2_FILIAL = '  '
		                               AND A2_COD = PCA.FORNEC
		                               AND A2_LOJA = LOJA
		                               AND SA2.D_E_L_E_T_ = ' '
		       LEFT JOIN SB1010 SB1 ON B1_FILIAL = '  '
		                               AND B1_COD = PRODUTO
		                               AND SB1.D_E_L_E_T_ = ' '
		       LEFT JOIN SBM010 SBM ON BM_FILIAL = '  '
		                               AND BM_GRUPO = B1_GRUPO
		                               AND SBM.D_E_L_E_T_ = ' '
	EndSql

	(_cAlias)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(_cAlias)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{20,75,30,200,75,48,400,75,45,45,64,400,47,33,65,65,65,65,45,65,65,65,65,65,65,75,65,45,53,160,42,48,150,65,200,200,300,75,200,85,85,85,85,85,60,60},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,44) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,44) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Pedidos em Aberto ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,44)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Fornecedor"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Loja"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome Fornecedor"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tel.Fornecedor"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Num. Ped."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("FollowUp" 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Emissão"					    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Entrega"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Item Ped."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Prod."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Produto"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Classe Valor"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("C. Custo"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Grupo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Vlr. Unit."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Vlr. Total"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant. Entregue"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Empresa"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Chegada"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Necess."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Envio"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Followup"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant. Followup"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Num. Solic. Compra"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("It. Solic. Compra"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Resíduo"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Aprov."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome Aprov."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Status"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Usuário"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome Usuário"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Lib."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc. Grupo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Comprador"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Email Fornec"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Emissão SC"  					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Solicitante"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Dias Emissão"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Dias Chegada"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Dias Necessidade"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Dias Entrega"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Data chegada - data emissão"  ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Almox."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Transp."  					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	
	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( (_cAlias)->FORNEC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->LOJA		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NOMFOR		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->TEL	    ,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NUMPC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->OBS_FOLLOW	  ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->EMISSAO))	,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->ENTREG))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ITEMPC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->PRODUTO	,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DESCR		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CLVL		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CC			,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->B1_GRUPO	,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->QUANT		,TAMSX3("C7_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->VLRUNIT	,TAMSX3("C7_PRECO")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->VLRTOTAL	,TAMSX3("C7_TOTAL")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->QUJE		,TAMSX3("C7_QUJE")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->EMPR		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->DTCHEG))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->DTNECE))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->DTENV))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->DTFUP))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->QTDFUP		,TAMSX3("C7_YQUAEMA")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NUMSC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ITEMSC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->RESIDUO	,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->APROV		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NM_APR		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->_STATUS	,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->USUARIO	,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( UsrFullName((_cAlias)->USUARIO)	,0				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->DTLIB))		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->BM_DESC	,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->COMPRAD	,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->EMAIL	    ,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( dtoc(stod((_cAlias)->EMIS_SC))	  ,0		 	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->SOLICITANTE  ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DEmissao	  ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DChegada	  ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DNecessidade ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DEntrega	  ,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DchegadaDemissao ,0	 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ALMOX	  ,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->TRANSP ,0	 							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR01),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	(_cAlias)->(dbCloseArea())

Return

//Gera parametros
Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ''
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	aPergs[1,3] := MV_PAR01 

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs

Return 
