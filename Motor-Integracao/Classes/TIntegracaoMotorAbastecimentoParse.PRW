#Include 'TOTVS.CH'
#Include "TopConn.ch"

CLASS TIntegracaoMotorAbastecimentoParse From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method PedidoCompra(oJson) 
    Method PedidoVenda(oJson) 	
    Method ParseEmpresa(oJson) 
    Method ParseFornecedor(oJson) 
    Method ParseCliete(oJson) 
    Method ParseProduto(oJson)
	Method MontaPCompra(oJson)
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoParse
    ::oJSon := JsonObject():New() 
Return self

METHOD PedidoCompra(oJson) CLASS TIntegracaoMotorAbastecimentoParse

	Local oIMADAO := TIntegracaoMotorAbastecimentoDAO():New()
	Local oJSPC   := JsonObject():New() 
	Local oJSRet  := JsonObject():New()
	Local aError  := {}
	Local lError  := .F.
	Local nI      := 0 	
	Local nW      := 0 	
	Local cMsg    := ""
 


	oJSPC["empresa"]    := ::ParseEmpresa(oJson)
	//Validando empresa enviada 
	If Empty(oJSPC["empresa"]["empresaCnpj"])

		lError := .T.
		nI++
		AADD(aError,   JsonObject():New())
		aError[nI]["field"]          := "codigoEmpresa"
		aError[nI]["rejectedValue"]  := oJson["codigoEmpresa"]
		aError[nI]["defaultMessage"] := EncodeUtf8("O CNPJ da empresa informada não foi locaizado.")
		
	EndIf


	If 	lError == .F.		

		//Fornecedor
		oJSPC["fornecedor"] := ::ParseFornecedor(oJson)
		If Empty(oJSPC["fornecedor"]["A2_COD"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "fornecedor"
			aError[nI]["rejectedValue"]  := oJson["fornecedor"]
			aError[nI]["defaultMessage"] := EncodeUtf8("O CNPJ do fornecedor informado não foi locaizado.")
		EndIf

		//Data de entrega
		oJSPC["dataEntrega"] := StrTran(oJson["dataEntrega"],"-","")
		If Empty(oJSPC["dataEntrega"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "dataEntrega"
			aError[nI]["rejectedValue"]  := oJson["dataEntrega"]
			aError[nI]["defaultMessage"] := EncodeUtf8("A data de entrega não foi informada.")
		EndIf

		//Data de faturamento	
		oJSPC["dataFaturamento"] := StrTran(oJson["dataEntrega"],"-","")
		If Empty(oJSPC["dataEntrega"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "dataFaturamento"
			aError[nI]["rejectedValue"]  := oJson["dataFaturamento"]
			aError[nI]["defaultMessage"] := EncodeUtf8("A data do Faturamento não foi informada corretamente.")
		EndIf	

		// Pedido de compra da CITEL
		oJSPC["numeroPedido"] := oJson["numeroPedido"] // CRIAR campo na C7_YIDCITE
		If Empty(oJSPC["numeroPedido"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "numeroPedido"
			aError[nI]["rejectedValue"]  := oJson["numeroPedido"]
			aError[nI]["defaultMessage"] := EncodeUtf8("O numero do Pedido CITEL não foi informada corretamente.")
		EndIf
	

		//Produtos
		oJSPC["itens"]      := ::ParseProduto(oJson)						
		For nW := 1 To Len(oJSPC["itens"]) 

			If oJSPC["itens"][nW]["achou"] == .F.

				lError := .T.
				nI++
				AADD(aError,   JsonObject():New())
				aError[nI]["field"]          := "itens["+cValToChar(nW)+"].produto"
				aError[nI]["rejectedValue"]  := oJSPC["itens"][nW]["produto"]
				aError[nI]["defaultMessage"] := EncodeUtf8("O código do produto informado não foi encontrado")	

			EndIf 

		Next nI

	EndIf

  	oJSRet["Status"] := 200
	
	If lError //EXECUTAR VERIFICAÇÃO DOS RETORNOS DOS JSON ANTES  DO EXECAUTO TRATAR ERROS COMO NA DESC		

		oJSRet["Status"] := 400
		oJSRet["Erros"] := aError

	Else
		
		oJSPC := ::MontaPCompra(oJSPC)		
		oJSRet :=  oIMADAO:ExecAutoPCompra(oJSPC)		 

	EndIf
		
    
Return oJSRet

// Função para montar o ambiente
User Function MontaEnv(cJSonTxt) 

	Local oJSEnv := JsonObject():New()
	Local lRet   := .F.
	oJSEnv:FromJson(cJSonTxt)	  
	RpcSetType( 3 )	
	lRet := RPCSetEnv( oJSEnv["empresa"]["empresaCodigo"], oJSEnv["empresa"]["empresaFilial"], NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"}) 

Return lRet
 
Method PedidoVenda(oJson) Class TIntegracaoMotorAbastecimentoParse
	Local oJSon      := JsonObject():New()
Return oJSon

Method ParseEmpresa(oJson) Class TIntegracaoMotorAbastecimentoParse 
   
	Local oJSEmp  := JsonObject():New()
	Local nI      := 1

 	//Retorna um ARRAY com as informações das filiais disponíveis no arquivo SIGAMAT.EMP  - 
 	//https://tdn.totvs.com/display/public/PROT/FWLoadSM0 e https://tdn.totvs.com/display/public/PROT/FWSM0Util
	Local aSM0	  := FWLoadSM0() 
	

	If Len(aSM0) > 0

		For nI := 1 To Len(aSM0)

			If AllTrim(aSM0[nI][18]) == AllTrim(oJson["codigoEmpresa"])	 

				oJSEmp["empresaCodigo"]      := ALLTRIM(aSM0[nI][1])   //aSM0[nI][1]:"99"
				oJSEmp["empresaFilial"]      := ALLTRIM(aSM0[nI][2])   //aSM0[nI][2]:"01"
				oJSEmp["empresaRazaoSocial"] := ALLTRIM(aSM0[nI][6])   //aSM0[nI][6]:"TESTE"
				oJSEmp["empresaGrupoNome"]   := ALLTRIM(aSM0[nI][7])   //aSM0[nI][7]:"MATRIZ"
				oJSEmp["empresaCnpj"]        := ALLTRIM(aSM0[nI][18])  //aSM0[nI][18]:"99949078000199"

				Exit 

			EndIf

		Next nI		
		
	EndIf	

Return oJSEmp

Method ParseFornecedor(oJson) Class TIntegracaoMotorAbastecimentoParse 
   
    Local cQuery     := "" 
    Local oJSFor      := JsonObject():New()

    cQuery += " SELECT                            " + CRLF
    cQuery += "      A2_COD                       " + CRLF
    cQuery += "     ,A2_LOJA                      " + CRLF
    cQuery += "     ,A2_NOME                      " + CRLF
    cQuery += "     ,A2_CGC                       " + CRLF
	cQuery += "     ,A2_COND                      " + CRLF
    cQuery += " FROM                              " + CRLF
		cQuery += "  " + RetSqlName("SA2") + "        " + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ''             " + CRLF
    cQuery += " AND A2_CGC = "+ValToSql(oJson["fornecedor"])+"   " + CRLF
		

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  If (! __TRZ->(EoF()) )
    oJSFor["A2_COD"]  := __TRZ->A2_COD
    oJSFor["A2_LOJA"] := __TRZ->A2_LOJA
    oJSFor["A2_NOME"] := __TRZ->A2_NOME
    oJSFor["A2_CGC"]  := __TRZ->A2_CGC   
	oJSFor["A2_COND"] := __TRZ->A2_COND  
  Else    

   // Criar Json de retorno 
  EndIf

  __TRZ->(DbCloseArea())

Return oJSFor

Method ParseCliete(oJson) Class TIntegracaoMotorAbastecimentoParse
	Local oJSon      := JsonObject():New()
Return oJSon

Method ParseProduto(oJson) Class TIntegracaoMotorAbastecimentoParse
 
    
	Local aJSPro      := {}
	Local nI          := 1

	If Len(oJson["itens"]) > 0 

		For nI := 1 To Len(oJson["itens"])

			AADD(aJSPro,   JsonObject():New())				

			If SB1->(dbSeek(FWxFilial("SB1")+oJson["itens"][nI]["produto"] ))  

				aJSPro[nI]["produto"]    := SB1->B1_COD
				aJSPro[nI]["descricao"]  := SB1->B1_DESC
				aJSPro[nI]["quantidade"] := oJson["itens"][nI]["quantidade"]
				aJSPro[nI]["preco"]      := oJson["itens"][nI]["preco"]
				aJSPro[nI]["achou"]      := .T.

			Else

				aJSPro[nI]["produto"]    := oJson["itens"][nI]["produto"]
				aJSPro[nI]["descricao"]  := ""
				aJSPro[nI]["quantidade"] := 0
				aJSPro[nI]["preco"]      := 0
				aJSPro[nI]["achou"]      := .F.

			EndIf

		Next nI

	EndIf     

Return aJSPro

Method MontaPCompra(oJson) Class TIntegracaoMotorAbastecimentoParse
 
	Local aJSPC      := {}
	Local oJSPC      := JsonObject():New()	
	Local cFil       := FWxFilial('SC7')
	Local nI         := 1					

	oJSPC["pedidoCompra"]                      := JsonObject():New()
	oJSPC["pedidoCompra"]["cab"]               := JsonObject():New()
	oJSPC["pedidoCompra"]["cab"]["C7_FILIAL"]  :=  cFil	
	oJSPC["pedidoCompra"]["cab"]["C7_NUM"]     :=  ""                                // Numero do Pedido				
	oJSPC["pedidoCompra"]["cab"]["C7_EMISSAO"] :=  Date()                            // Data de Emissao 
	oJSPC["pedidoCompra"]["cab"]["C7_CONTATO"] :=  ""                                // Contato 
	oJSPC["pedidoCompra"]["cab"]["C7_COND"]    :=  oJson["fornecedor"]["A2_COND"]    // Condicao de Pagamento
	oJSPC["pedidoCompra"]["cab"]["C7_FORNECE"] :=  oJson["fornecedor"]["A2_COD"]     // Fornecedor 	codigo		  
	oJSPC["pedidoCompra"]["cab"]["C7_LOJA"]    :=  oJson["fornecedor"]["A2_LOJA"]    // Loja do Fornecedor    
	oJSPC["pedidoCompra"]["cab"]["C7_FILENT"]  :=  cFil         	                 // Filial de Entrega
	oJSPC["pedidoCompra"]["cab"]["C7_FILCEN"]  :=  cFil	                             // Filial de Entrega
	oJSPC["pedidoCompra"]["cab"]["C7_FRETE"]   :=  0                           	     // Frete
	oJSPC["pedidoCompra"]["cab"]["C7_DESPESA"] :=  0                           	     // Despesa
	oJSPC["pedidoCompra"]["cab"]["C7_SEGURO"]  :=  0                           	     // Seguro
	oJSPC["pedidoCompra"]["cab"]["C7_MSG"]     :=  "COMPRA REALIZADA PELO MOTOR DE ABASTECIMENTO CITEL VIA WEBSERVICE" // Mensagem
	oJSPC["pedidoCompra"]["cab"]["C7_REAJUST"] :=  0                                 // Reajuste	
	oJSPC["pedidoCompra"]["cab"]["C7_YIDCITE"] :=  oJson["numeroPedido"]             // ID pedido da CITEL 

	For nI := 1 To Len(oJson["itens"])

		AADD(aJSPC,   JsonObject():New())	

		aJSPC[nI]["achou"]      := .T.
		aJSPC[nI]["C7_ITEM"]    := StrZero(nI, 4)
		aJSPC[nI]["C7_PRODUTO"] := oJson["itens"][nI]["produto"]
		aJSPC[nI]["C7_QUANT"]   := oJson["itens"][nI]["quantidade"]
		aJSPC[nI]["C7_PRECO"]   := oJson["itens"][nI]["preco"] 
		aJSPC[nI]["C7_TOTAL"]   := (oJson["itens"][nI]["quantidade"])*(oJson["itens"][nI]["preco"])		
		aJSPC[nI]["C7_DESC"]    := 0                          //Desconto
		aJSPC[nI]["C7_IPI"]     := 0                          //IPI
		aJSPC[nI]["C7_IPIBRUT"] := ""                         //IPI bruto
		aJSPC[nI]["C7_REAJUST"] := 0                          //REAJUSTE
		aJSPC[nI]["C7_FRETE"]   := 0                          //FRETE
		aJSPC[nI]["C7_DATPRF"]  := oJson["dataEntrega"]       //Data de entrega
		aJSPC[nI]["C7_LOCAL"]   := "01"	                      //LOCAL  OU ARMAZEM
		aJSPC[nI]["C7_TPFRETE"] := ""                         //TIPO FRETE
		aJSPC[nI]["C7_OBS"]     := "COMPRA REALIZADA PELO MOTOR DE ABASTECIMENTO CITEL VIA WEBSERVICE" // Mensagem
		aJSPC[nI]["C7_CONTA"]   := ""                         //CONTA CONTABIL
		aJSPC[nI]["C7_CC"]      := ""                         //CENTRO DE CUSTO
		aJSPC[nI]["C7_OP"]      := ""                         //ORDEM DE PRODUCAO
		aJSPC[nI]["C7_TIPO"]    := ""                         //TIPO  DE PRODUCAO	 	 

	Next nI
	
	oJSPC["pedidoCompra"]["itens"] := JsonObject():New()
	oJSPC["pedidoCompra"]["itens"] := aJSPC
   

Return oJSPC
