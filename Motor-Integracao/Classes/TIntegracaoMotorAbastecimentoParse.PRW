#Include 'TOTVS.CH'
#Include "TopConn.ch"

CLASS TIntegracaoMotorAbastecimentoParse From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method PedidoCompra(oJson) 
    Method PedidoVenda(oJson) 	
    Method ParseEmpresa() 
    Method ParseFornecedor() 
    Method ParseCliete() 
    Method ParseProduto()
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoParse
    ::oJSon := JsonObject():New() 
Return self

METHOD PedidoCompra(oJson) CLASS TIntegracaoMotorAbastecimentoParse

	Local oIMADAO := TIntegracaoMotorAbastecimentoParse():New()
	Local oJSPC   := JsonObject():New() 
	Local oJSRet  := JsonObject():New()
	Local aError  := {}
	Local lError  := .F.
	Local nI      := 0 
	
	Local cEmp     := ""
	Local cFil     := ""
	Local lRpcSet  := ""
	Local lRecursa := ""
	Local cMsg     := ""
	Local aMsg     := {}


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

		//Monta ambiente
		
    cEmp     := oJSPC["empresa"]["empresaCodigo"]
    cFil     := oJSPC["empresa"]["empresaFilial"]
    lRpcSet  := GetEnvServer()       

		cTst	:= oJSPC:tojson()



		cMsg     := StartJob( "U_MontaEnv" , GetEnvServer(), .T. , cTst) //https://tdn.totvs.com/display/tec/StartJob
		
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


		//oJSPC["codigoComprador"] := ::ParseFornecedor(oJson)
		If Empty(oJSPC["codigoComprador"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "codigoComprador"
			aError[nI]["rejectedValue"]  := oJson["codigoComprador"]
			aError[nI]["defaultMessage"] := EncodeUtf8("O código do comprador informado não foi locaizado.")
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

		oJSPC["numeroPedido"] := oJson["numeroPedido"] // Precisa criar campo na C7
		If Empty(oJSPC["numeroPedido"])
			lError := .T.
			nI++
			AADD(aError,   JsonObject():New())
			aError[nI]["field"]          := "numeroPedido"
			aError[nI]["rejectedValue"]  := oJson["numeroPedido"]
			aError[nI]["defaultMessage"] := EncodeUtf8("O numero do Pedido CITEL não foi informada corretamente.")
		EndIf
 

		//Produtos
		oJSPC["itens"]      := ""//::ParseProduto(oJson)
	  oJSPC["info"]       := ""//EncodeUtf8("Criar função para reunir dados, TES, FRETE e etc...")  

	EndIf

  
	If lError
		//eXECUTAR VERIFICAÇÃO DOS RETORNOS DOS JSON ANTES  DO EXECAUTO
		//TRATAR ERROS COMO NA DOSC
		//oJSRet retorna Erros em lista
		oJSRet["Status"] := 400
		oJSRet["Erros"] := aError
	Else
		//oJSRet :=  oIMADAO:ExecAutoPedidoCompra(oJSPC)
		oJSRet["Status"] := 200
		oJSRet := oJSPC
	EndIf
		
    
Return oJSRet
 
Method PedidoVenda(oJson) Class TIntegracaoMotorAbastecimentoParse
		Local oJSon      := JsonObject():New()
Return oJSon


User Function MontaEnv(cTst) 

	Local oteste := JsonObject():New()

	oTeste:FromJson(cTst)
	  
	RpcSetType( 3 )	
	RPCSetEnv( cEmp, cFil, NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	
/*
	IF ( lRpcSet )
        RpcSetType( 3 )
        RpcSetEnv( cEmp , cFil )
    EndIF
		*/
	//StartJob( < cName >, < cEnv >, < lWait >, [ parm1,parm2,...parm25 ] )
	//https://tdn.totvs.com/display/public/PROT/FWSM0Util
	//https://tdn.totvs.com/display/tec/StartJob

Return .T.

Method ParseEmpresa(oJson) Class TIntegracaoMotorAbastecimentoParse 
   
	Local oJSEmp  := JsonObject():New()
	Local aSM0	  := FWLoadSM0() // Retorna um ARRAY com as informações das filiais disponíveis no arquivo SIGAMAT.EMP  - https://tdn.totvs.com/display/public/PROT/FWLoadSM0
	Local nI      := 1

	If Len(aSM0) > 0

		For nI := 1 To Len(aSM0)

			If AllTrim(aSM0[nI][18]) == AllTrim(oJson["codigoEmpresa"])

				oJSEmp["empresaCodigo"]      := aSM0[nI][1]   //aSM0[nI][1]:"99"
				oJSEmp["empresaFilial"]      := aSM0[nI][2]   //aSM0[nI][2]:"01"
				oJSEmp["empresaRazaoSocial"] := aSM0[nI][6]   //aSM0[nI][6]:"TESTE"
				oJSEmp["empresaGrupoNome"]   := aSM0[nI][7]   //aSM0[nI][7]:"MATRIZ"
				oJSEmp["empresaCnpj"]        := aSM0[nI][18]  //aSM0[nI][18]:"99949078000199"

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
  Else    

   // Criar Json de retorno 
  EndIf

  __TRZ->(DbCloseArea())

Return oJSFor

Method ParseCliete(oJson) Class TIntegracaoMotorAbastecimentoParse
		Local oJSon      := JsonObject():New()
Return oJSon

Method ParseProduto(oJson) Class TIntegracaoMotorAbastecimentoParse
		Local oJSon      := JsonObject():New()
Return oJSon

 

