#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TNFSaidaXML From LongClassName

	Data cDir
	Data cFunOri
	Data cPrexi	
	Data cChave
	
	Method New() Constructor
	Method GerarArqPorChave()
	Method GerarArq()

EndClass


Method New(_cDir, _cFunOri, cPrexi) Class TNFSaidaXML
	
	Default _cDir		:= "\P10\CNAB\"+AllTrim(cEmpAnt)+AllTrim(cFilAnt)+"\RECEBIMENTOS\SAIDA\"
	Default _cFunOri	:= "FIDC_RECEBER"
	Default _cPrexi		:= ""
	
	::cDir			:= _cDir	
	::cFunOri		:= _cFunOri
	::cPrexi		:= _cPrexi
	::cChave		:= ""
Return()

Method GerarArq(cQuery) Class TNFSaidaXML

	Local lRet       := .F.
	Local cAliasTemp := Nil
	Local cNomeArq   := ""
	Local _cDir      := ::cDir

	If !ExistDir(_cDir)
		FWMakeDir(_cDir)
	EndIf
	
	If ExistDir(_cDir)

		cAliasTemp	:= GetNextAlias()
		
		TcQuery cQuery New Alias (cAliasTemp)
		
		If !(cAliasTemp)->(Eof())
			
			If (Select("SPED050") > 0)
				SPED050->(DbCloseArea())
			EndIf
			
			If (MsOpenDbf(.T.,"TOPCONN", "SPED050", "SPED050",.T.,.F.,.T.,.F.))
				
				SPED050->(DbGoTo((cAliasTemp)->ID))
				
				If (!Empty(SPED050->DOC_CHV))
					cNomeArq := ::cPrexi+SPED050->DOC_CHV+ ".XML"
					If !File(_cDir+cNomeArq)
						lRet := MemoWrite(_cDir+cNomeArq, Alltrim(SPED050->XML_SIG) )
						If (lRet)
							Conout(::cFunOri+" SUCESSO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
						Else
							Conout(::cFunOri+" ERRO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
						EndIf
					EndIf
				EndIf
				
				SPED050->(DbCloseArea())
			EndIf
			
		Else
			Conout(::cFunOri+" ERRO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
		EndIf

		(cAliasTemp)->(DbCloseArea())
		
	Else
		Conout(::cFunOri+" ERRO - DIRETORIO ARQUIVO XML: "+_cDir)
	EndIf
	
Return lRet

Method GerarArqPorChave(_cChave) Class TNFSaidaXML

	Local cQuery    := ""
	Local lRet      := .F.
	Local _cError   := NIL
	Local cBancoTSS := SuperGetMV("MV_YBDTSS", .F., "SPED050")
	
	Private cIdEnt  := GetCfgEntidade(@_cerror)

	::cChave 		:= _cChave
	
	cQuery += " select 	ID=SPED.R_E_C_N_O_																						"			
	//cQuery += " XML=CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_SIG)),                                                  	"
	//cQuery += " CHAVE=F2_CHVNFE                                                                                              	"
	cQuery += " from " + RetSQLName("SF2")+" SF2 (NOLOCK)                                                                   	"
	cQuery += " JOIN " + cBancoTSS + " SPED (NOLOCK) ON SPED.ID_ENT = '"+cIdEnt+"' AND F2_CHVNFE = DOC_CHV AND SPED.D_E_L_E_T_ = ''    	"
	cQuery += " WHERE 1=1                                                                                                    	"
	cQuery += " AND SF2.F2_FILIAL		= '"+xFilial("SF2")+"'																	"
	cQuery += " AND SF2.F2_ESPECIE		= 'SPED'                                                                           		"
	cQuery += " AND SF2.D_E_L_E_T_		= ''                                                                                	"
	cQuery += " AND SPED.STATUS 		= '6'																					"
	cQuery += " AND SF2.F2_CHVNFE		= '"+::cChave+"'									                                    "

	lRet := ::GerarArq(cQuery)
	
Return(lRet)

User Function FIDCXMLR(_cData)
	
	Local cQuery 		:= ""
	Local cAliasTrab	:= Nil
	Local cData			:= ""
	Local cChave		:= ""
	
	Default	_cData		:= dtos(Date())
	
	//RpcSetEnv('01', '01')
	
	
	cData	:= _cData

	cQuery += " select DISTINCT F2_CHVNFE from " + RetSQLName("SE1")+"  SE1 (NOLOCK)		"
	cQuery += " JOIN " + RetSQLName("SF2")+"  SF2 (NOLOCK) ON                               "
	cQuery += " 														    				"
	cQuery += " 	SF2.F2_FILIAL		= SE1.E1_FILIAL										"
	cQuery += " AND SF2.F2_DOC		= SE1.E1_NUM											"	
	cQuery += " AND SF2.F2_SERIE		= SE1.E1_SERIE										"	
	cQuery += " AND SF2.F2_CLIENT		= SE1.E1_CLIENTE									"	
	cQuery += " AND SF2.F2_LOJA 		= SE1.E1_LOJA										"
	cQuery += " AND SF2.F2_EMISSAO	= SE1.E1_EMISSAO                    					"
	cQuery += " AND SF2.D_E_L_E_T_	= ''						        					"
	cQuery += "                                                           					"
	cQuery += " where 1=1                                                 					"
	cQuery += " AND SE1.E1_FILIAL		= '"+xFilial("SE1")+"'	         	            	"
	
	cQuery += " AND SE1.E1_NUMBOR			<> ''                           				"
	cQuery += " AND SE1.E1_DATABOR			= '"+cData+"'                           		"
	//cQuery += " AND SE1.E1_DATABOR			< '"+cData+"'                           		"
	
	cQuery += " AND SE1.D_E_L_E_T_		= ''												"
	cQuery += " AND E1_YSITAPI			= '2'												"
	cQuery += " AND exists(																	"
	cQuery += " select 1  from "+ RetSQLName("SA6") + " SA6									"
	cQuery += " where									 									"
	cQuery += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
	cQuery += " 	AND A6_COD			= SE1.E1_PORTADO 									"
	cQuery += " 	AND A6_AGENCIA		= SE1.E1_AGEDEP 									"
	cQuery += " 	AND A6_NUMCON		= SE1.E1_CONTA 										"
	cQuery += " 	AND SA6.D_E_L_E_T_	= ''												"
	cQuery += " 	AND SA6.A6_YTPINTB	= '1'												"
	cQuery += " )																			"
	
	//cQuery += " AND SE1.E1_PORTADO		= '237'         	            					"
	//cQuery += " AND SE1.E1_AGEDEP			= '3511'                        				"
	//cQuery += " AND SE1.E1_CONTA			= '1422'                        				"
	

	cAliasTrab	:= GetNextAlias()
	
	TcQuery cQuery New Alias (cAliasTrab)
	
	nI :=0
	While !(cAliasTrab)->(Eof())
		
		cChave := (cAliasTrab)->F2_CHVNFE
		
		oNFSaidaXML := TNFSaidaXML():New()
		oNFSaidaXML:GerarArqPorChave(cChave)
		
		(cAliasTrab)->(DbSkip())
		
		//nI := nI + 1
		//	If (nI == 5)
		//		Exit
		//	EndIf 
		
	EndDo

	(cAliasTrab)->(DbCloseArea())
	
	//RPCClearEnv()
	
Return 
