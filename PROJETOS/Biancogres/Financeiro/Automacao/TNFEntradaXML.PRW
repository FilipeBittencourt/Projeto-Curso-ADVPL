#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Class TNFEntradaXML From LongClassName

	Data cDir
	Data cFunOri
	Data cPrexi	
	Data cChave
	
	Method New() Constructor
	Method GerarArqPorChave()
	Method GerarArq()

EndClass


Method New(_cDir, _cFunOri, cPrexi) Class TNFEntradaXML
	
	Default _cDir		:= "\P10\CNAB\"+AllTrim(cEmpAnt)+AllTrim(cFilAnt)+"\PAGAMENTOS\SAIDA\"
	Default _cFunOri	:= "FIDC_PAGAR"
	Default _cPrexi		:= ""
	
	::cDir			:= _cDir	
	::cFunOri		:= _cFunOri
	::cPrexi		:= _cPrexi
	::cChave		:= ""
Return()

Method GerarArq(cQuery) Class TNFEntradaXML

	Local lRet 			:= .F.
	Local cAliasTemp	:= Nil
	Local cNomeArq		:= ""

	If ExistDir(::cDir)
	
		cAliasTemp	:= GetNextAlias()
		
		TcQuery cQuery New Alias (cAliasTemp)
		
		If !(cAliasTemp)->(Eof())
			
			If (Select("ZAA") > 0)
				ZAA->(DbCloseArea())
			EndIf
			
			If (MsOpenDbf(.T.,"TOPCONN", RetSQLName("ZAA"), "ZAA",.T.,.F.,.T.,.F.))
				
				ZAA->(DbGoTo((cAliasTemp)->ID))
				
				If (!Empty(ZAA->ZAA_CHAVE))
					cNomeArq := ::cPrexi+ZAA->ZAA_CHAVE+ ".XML"
					If !File(::cDir+cNomeArq)
						lRet := MemoWrite(::cDir+cNomeArq, Alltrim(ZAA->ZAA_XML) )
						If (lRet)
							Conout(::cFunOri+" SUCESSO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
						Else
							Conout(::cFunOri+" ERRO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
						EndIf
					EndIf
				EndIf
				
				ZAA->(DbCloseArea())
			EndIf
			
		Else
			Conout(::cFunOri+" ERRO - GERACAO ARQUIVO XML - CHAVE NFE: "+::cChave+",  DATA/HORA: "+dtos(date())+"/"+substr(time(), 1, 5))
		EndIf

		(cAliasTemp)->(DbCloseArea())
		
	Else
		Conout(::cFunOri+" ERRO - DIRETORIO ARQUIVO XML: "+::cDir)
	EndIf
	
Return lRet

Method GerarArqPorChave(_cChave) Class TNFEntradaXML

	Local cQuery 	:= ""
	Local lRet 		:= .F.

	::cChave 		:= _cChave
	
	cQuery += " select 	ID=ZAA.R_E_C_N_O_																						"			
	cQuery += " from " + RetSQLName("ZAA")+" ZAA (NOLOCK)                                                                   	"
	cQuery += " WHERE 1=1                                                                                                    	"
	cQuery += " AND ZAA.ZAA_FILIAL		= '"+xFilial("ZAA")+"'																	"
	cQuery += " AND ZAA.ZAA_CHAVE		= '"+::cChave+"'									                                    "

	lRet := ::GerarArq(cQuery)
	
Return(lRet)

User Function FIDCXMLP(_cListBor, _cData)
	
	Local cQuery 		:= ""
	Local cAliasTrab	:= Nil
	Local cData			:= ""
	Local cChave		:= ""
	Local nI			:= 0
	Local cFiltro		:= ""
	
	Default	_cData		:= dtos(Date())
	Default _cListBor	:= {}
	
//	RpcSetEnv('01', '01')
	
	cData	:=  _cData

	cQuery += " select DISTINCT F1_CHVNFE from " + RetSQLName("SE2")+"  SE2 (NOLOCK)		"
	cQuery += " JOIN " + RetSQLName("SF1")+"  SF1 (NOLOCK) ON                               "
	cQuery += " 														    				"
	cQuery += " 	SF1.F1_FILIAL		= SE2.E2_FILIAL										"
	cQuery += " AND SF1.F1_DOC			= SE2.E2_NUM										"	
	cQuery += " AND SF1.F1_SERIE		= SE2.E2_PREFIXO									"	
	cQuery += " AND SF1.F1_FORNECE		= SE2.E2_FORNECE									"	
	cQuery += " AND SF1.F1_LOJA 		= SE2.E2_LOJA										"
	cQuery += " AND SF1.F1_EMISSAO		= SE2.E2_EMISSAO                   					"
	cQuery += " AND SF1.D_E_L_E_T_	= ''						        					"
	cQuery += "                                                           					"
	cQuery += " where 1=1                                                 					"
	cQuery += " AND SE2.E2_FILIAL		= '"+xFilial("SE2")+"'	         	            	"
	
	//cQuery += " AND SE2.R_E_C_N_O_		= '923444'											"
			 
	cQuery += " AND SE2.E2_NUMBOR			<> ''                           				"
	cQuery += " AND SE2.E2_DTBORDE			= '"+cData+"'                           		"
	
	cQuery += " AND SE2.D_E_L_E_T_		= ''												"
	cQuery += " AND E2_YSITAPI			= '2'												"
	cQuery += " AND E2_YANTTX > 0															"
	cQuery += " AND E2_YANTDES > 0															"
	
	cFiltro := ""
	For nI :=1 To Len(_cListBor)
		If (!Empty(cFiltro))
			cFiltro += ", "
		EndIf
		cFiltro += "'"+_cListBor[nI]+"'"
	Next nI
	
	If (!Empty(cFiltro))
		cQuery += " AND SE2.E2_NUMBOR IN ("+cFiltro+")                           				"
	EndIf
	
	conout(cQuery)
	
	/*cQuery += " AND exists(																	"
	cQuery += " select 1  from "+ RetSQLName("SA6") + " SA6									"
	cQuery += " where									 									"
	cQuery += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
	cQuery += " 	AND A6_COD			= SE2.E2_PORTADO 									"
	cQuery += " 	AND A6_AGENCIA		= SE2.E2_AGEDEP 									"
	cQuery += " 	AND A6_NUMCON		= SE2.E2_CONTA 										"
	cQuery += " 	AND SA6.D_E_L_E_T_	= ''												"
	cQuery += " 	AND SA6.A6_YTPINTB	= '1'												"
	cQuery += " )																			"
	*/
	

	cAliasTrab	:= GetNextAlias()
	
	TcQuery cQuery New Alias (cAliasTrab)
	
	nI :=0
	While !(cAliasTrab)->(Eof())
		
		cChave := (cAliasTrab)->F1_CHVNFE
		
		oNFSaidaXML := TNFEntradaXML():New()
		oNFSaidaXML:GerarArqPorChave(cChave)
		
		(cAliasTrab)->(DbSkip())
		
	EndDo

	(cAliasTrab)->(DbCloseArea())
	
	//RPCClearEnv()
	
Return 
