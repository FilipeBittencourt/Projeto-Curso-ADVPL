#include "protheus.ch"
#Include 'RESTFUL.CH'
#Include "TopConn.ch"

#Define cEOL Chr(13)+Chr(10)

WsRestFul pedidocompra Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/pedidocompra"
End WsRestFul

WSMETHOD POST WSSERVICE pedidocompra
 
  Local cBody    := "" 
  Local oJson    := JsonObject():New() 
  Local oIMAbast := TIntegracaoMotorAbastecimentoParse():New()  
 
  ::SetContentType("application/json")   

  //|Recupera os dados do body |  
  cBody := ::GetContent()
  conOut('pedidocompra - POST METHOD')  
  oJson:FromJson(cBody)  // converte para JsonObject 
  
  nTotIten := Len(oJson["itens"])
  
  cTime := FwTimeStamp()
  cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s'+'__com_'+cvalToChar(nTotIten)+'Itens'
  //memowrite("\data\TESTE-INI_" + cTime + ".txt", "")
  
  oJson := oIMAbast:PedidoCompra(oJson)
  ::SetStatus(oJson["Status"])  
  ::SetResponse(oJson:ToJson())

  cTime := FwTimeStamp()
  cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s'+'__com_'+cvalToChar(nTotIten)+'Itens'
  //memowrite("\data\TESTE-FIM_" + cTime + ".txt", oJson:ToJson())

Return .T.



WsRestFul pedidocomprabaixatotal Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/pedidocomprabaixatotal"
End WsRestFul

WSMETHOD POST WSSERVICE pedidocomprabaixatotal
 
  Local cBody    := "" 
  Local oJson    := JsonObject():New() 
  Local oIMAbast := TIntegracaoMotorAbastecimentoParse():New()  
  Local cTime    := ""
 
  
  ::SetContentType("application/json")   

  //|Recupera os dados do body |  
  cBody := ::GetContent()
  conOut('pedidocomprabaixatotal - POST METHOD')  
  oJson:FromJson(cBody)  // converte para JsonObject 

  cTime := FwTimeStamp()
  cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s'
  memowrite("\data\TESTE-INI-ELIMINIATOTAL_" + cTime + ".txt", "")

  oJson := oIMAbast:BaixaTotalPC(oJson)
  ::SetStatus(oJson["Status"])  
  ::SetResponse(oJson:ToJson())
  
  cTime := FwTimeStamp()
  cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s'
  memowrite("\data\TESTE-FIM-ELIMINIATOTAL_" + cTime + ".txt", "")

  FreeObj(oJson)   

Return .T.



WsRestFul gerajsontestepc Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/gerajsontestepc"
End WsRestFul

WSMETHOD POST WSSERVICE gerajsontestepc

  Local oJSTest  := JsonObject():New()
  Local oJson    := JsonObject():New()
  Local aItem    := {}    
  Local nI       := 0
  Local cQuery   := ""
  Local cBody    := ""
  
  conOut('Gerar JSON - POST METHOD') 

  ::SetContentType("application/json") 

  //|Recupera os dados do body |  
  cBody := ::GetContent()     
  oJson:FromJson(cBody)  // converte para JsonObject 

 
 
  /*
  If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	 
  */ 

  cQuery += " SELECT SA2.A2_CGC, SB1.B1_YCOMPRA, SB1.B1_MSBLQL , SC7.C7_PRODUTO,SC7.C7_QUANT,SC7.C7_PRECO  "
  cQuery += " FROM SB1010 SB1 "
  cQuery += " INNER JOIN SC7080 SC7 ON SC7.C7_PRODUTO = SB1.B1_COD "
  cQuery += " INNER JOIN SA2010 SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA "
  cQuery += " WHERE SB1.B1_YCOMPRA = '1' "
  cQuery += " AND   SB1.B1_MSBLQL  = '2' "
  cQuery += " AND   SC7.C7_NUM     = "+ValToSql(oJson["numeroPedido"])+" " 
   

  //cQuery += " SELECT C7_PRODUTO,C7_QUANT,C7_PRECO FROM SC7080 WHERE C7_NUM IN ('427005' )"
  //oJSTest["fornecedor"]        :=  "60860681000432" // C7_NUM IN ('427005' )

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  While __TRZ->(!Eof())
    nI++
    AADD(aItem,   JsonObject():New())
    aItem[nI]["produto"]          := AllTrim(__TRZ->C7_PRODUTO)
    aItem[nI]["quantidade"]       := __TRZ->C7_QUANT
    aItem[nI]["preco"]            := __TRZ->C7_PRECO   
  __TRZ->(DbSkip())

  EndDo  

  oJSTest["codigoEmpresa"]     :=  oJson["codigoEmpresa"]   
  oJSTest["codigoComprador"]   :=  oJson["codigoComprador"]
  oJSTest["condicaoPagamento"] :=  oJson["condicaoPagamento"]
  oJSTest["dataEntrega"]       :=  oJson["dataEntrega"]
  oJSTest["dataFaturamento"]   :=  oJson["dataFaturamento"]
  oJSTest["numeroPedido"]      :=  oJson["numeroPedido"]
  oJSTest["fornecedor"]        :=  oJson["fornecedor"]
  oJSTest["itens"]             :=  aItem

  ::SetStatus(200)  
  ::SetResponse(oJSTest:ToJson())

Return .T.




WsRestFul gerapcviajob Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/gerapcviajob"
End WsRestFul

WSMETHOD POST WSSERVICE gerapcviajob

  Local aCab      := {}
  Local aItem     := {}		
  Local aIClone   := {}
  Local cNumPC    := ""	 
  Local nI        := 1   
  Local cFilialX  := ""
  Local cQuery    := ""   
  Local cError    := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})

	Private lMsErroAuto := .F.
   
  /*If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF2","Z42"})	
  EndIf*/

  cFilialX := FWxFilial("SC7")

  cQuery += " SELECT R_E_C_N_O_ AS RECNO ,  * " + CRLF
  cQuery += " FROM " + RetSqlName("Z42")  + CRLF
  cQuery += " WHERE  Z42_FILIAL = "+ValToSql(cFilialX)  + CRLF
  cQuery += " AND D_E_L_E_T_  = '' "  + CRLF
  cQuery += " AND  Z42_SYCSC7 != 'S' " + CRLF
  cQuery += " AND  Z42_NUM = '456028' " + CRLF
  cQuery += " ORDER BY Z42_ITEM ASC "    + CRLF
 

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cQuery New Alias "__TRZ"
  __TRZ->(dbGoTop())

  
  If (! __TRZ->(EoF()) )

    cNumPC := __TRZ->Z42_NUM
    aAdd(aCab,	{"C7_NUM"       ,__TRZ->Z42_NUM      ,Nil}) // Numero do Pedido
    aAdd(aCab,  {"C7_EMISSAO"	  ,dDataBase           ,Nil})
    aAdd(aCab,  {"C7_FORNECE"	  ,__TRZ->Z42_FORNEC   ,NIL}) // Fornecedor
    aAdd(aCab,  {"C7_LOJA"	    ,__TRZ->Z42_LOJA     ,NIL}) // Loja do Fornecedor
    aAdd(aCab,  {"C7_COND"	    ,__TRZ->Z42_COND     ,NIL}) // Condicao de Pagamento   
    aAdd(aCab,  {"C7_FILENT"	  ,__TRZ->Z42_FILENT   ,NIL}) // Filial de Entrega    
    aAdd(aCab,	{"C7_YIDCITE"	  ,__TRZ->Z42_YIDCIT	 ,NIL}) // ID CITEL
     
    While __TRZ->(!Eof())
      
      aItem := {}            
      aAdd(aItem, {"C7_ITEM"        ,__TRZ->Z42_ITEM                      ,NIL})
      aAdd(aItem, {"C7_PRODUTO"     ,__TRZ->Z42_PRODUT                    ,NIL})
      aAdd(aItem, {"C7_QUANT"	      ,__TRZ->Z42_QUANT                     ,NIL})
      aAdd(aItem, {"C7_LOCAL"	      ,"01"                                 ,NIL})
      aAdd(aItem, {"C7_PRECO"	      ,__TRZ->Z42_PRECO                     ,NIL})            
      aAdd(aItem, {"C7_TOTAL"	      ,__TRZ->Z42_PRECO * __TRZ->Z42_QUANT  ,NIL})            
      aAdd(aItem, {"C7_QTDSOL"	    ,__TRZ->Z42_QUANT                     ,NIL})
      aAdd(aItem, {"C7_DATPRF"	    ,StoD(__TRZ->Z42_DATPRF)              ,NIL})
      aAdd(aItem, {"C7_OPER"	      ,"01"			                            ,Nil})
      aAdd(aItem, {"C7_YTIPCMP"     ,__TRZ->Z42_YTIPCMP		                ,Nil})                            
      aAdd(aItem,	{"C7_YIDCITE"	    ,__TRZ->Z42_YIDCIT	                  ,NIL})
      aAdd(aIClone, AClone(aItem))       

      __TRZ->(DbSkip())

    EndDo 

  EndIf

 
  If Len(aCab) > 0
 
    SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
    
    If SC7->(dbSeek(FWxFilial("SC7")+AllTrim(cNumPC)))

      ConOut("*******************************************************************************") 
      ConOut(" ") 
      ConOut("O codigo " + AllTrim(cNumPC)+ " do pedido de compra ja existe na SC7  na Filial: "+FWxFilial("SC7")) 
      ConOut(" ") 
      ConOut("*******************************************************************************") 

      return .F.

    EndIf

    Begin Transaction
                                 
        ConOut("INICIO MsExecAuto Mata120")
        MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aIClone,3,.F.) // 3 - Inclusao, 4 - Alterao, 5 - Excluso                   

        If !lMsErroAuto

            ConOut("Incluido com sucesso o PEDIDO: " + cNumPC )

            // Logica abaixo para ja alterar os PC para Liberado, PARA NÃO CONFLITAR COM REGRAS DE LIBERAÇÃO EXISTENTES 

            If SC7->(dbSeek(FWxFilial("SC7")+cNumPC))  

                While SC7->(!Eof()) .AND. FWxFilial("SC7")+cNumPC == SC7->C7_FILIAL+ SC7->C7_NUM               

                    SC7->(RecLock('SC7', .F.))
                        SC7->C7_CONAPRO := 'L'                        
                    SC7->(MsUnlock())

                    SC7->(DbSkip())

                EndDo   

            EndIf 

           
          __TRZ->(dbGoTop())                 
          While __TRZ->(!Eof())
 
            Z42->(dbGoTo(__TRZ->RECNO))

            Z42->(RecLock('Z42', .F.))
              Z42->Z42_SYCSC7 := 'S'                        
            Z42->(MsUnlock())           

            __TRZ->(DbSkip())

          EndDo 

          ErrorBlock(oError) 

        Else                     	
            
            cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
            ConOut(PadC("Automatic routine ended with error", 80))
            ConOut("Error: "+ cError)                
            ::EnviaError(oJSPC, cError, "JOB EXECAUTO - Pedido de Compra CITEL - "+ cNumPC)                 

        EndIf       		

    End Transaction
    
    ConOut("FIM MsExecAuto Mata120") 
  
  Else  

    ConOut("*******************************************************************************") 
    ConOut(" ") 
    ConOut("Nao ha dados para serem processados pelo JOB EXECAUTO - Pedido de Compra CITEL ") 
    ConOut(" ") 
    ConOut("*******************************************************************************") 

  EndIf 

  ::SetStatus(200)  
  ::SetResponse(oJSTest:ToJson())

Return .T.
