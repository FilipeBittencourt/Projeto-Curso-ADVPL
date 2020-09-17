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
  Local oIMADAO := TIntegracaoMotorAbastecimentoDAO():New()
  
  ::SetContentType("application/json")   

  //|Recupera os dados do body |  
  cBody := ::GetContent()
  conOut('pedidocompra - POST METHOD')  
  oJson:FromJson(cBody)  // converte para JsonObject 

  //oIMADAO:EliminaResiduoPC(oJson)
  memowrite("\data\TESTE-" + FwTimeStamp() + ".txt", "")

  oJson := oIMAbast:PedidoCompra(oJson)
  ::SetStatus(oJson["Status"])  
  ::SetResponse(oJson:ToJson())

  memowrite("\data\TESTE-" + FwTimeStamp() + ".txt", oJson:ToJson())

Return .T.



WsRestFul pedidocomprabaixatotal Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/pedidocomprabaixatotal"
End WsRestFul

WSMETHOD POST WSSERVICE pedidocomprabaixatotal
 
  Local cBody    := "" 
  Local oJson    := JsonObject():New() 
  Local oIMAbast := TIntegracaoMotorAbastecimentoParse():New()
  Local oIMADAO := TIntegracaoMotorAbastecimentoDAO():New()
  
  ::SetContentType("application/json")   

  //|Recupera os dados do body |  
  cBody := ::GetContent()
  conOut('pedidocomprabaixatotal - POST METHOD')  
  oJson:FromJson(cBody)  // converte para JsonObject 

  //oIMADAO:EliminaResiduoPC(oJson)
  oJson := oIMAbast:BaixaTotalPC(oJson)
  ::SetStatus(oJson["Status"])  
  ::SetResponse(oJson:ToJson())

  FreeObj(oJson)   

Return .T.



WsRestFul gerajsontestepc Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD POST DESCRIPTION "Session Motor de Integração" WSSYNTAX "/gerajsontestepc"
End WsRestFul

WSMETHOD POST WSSERVICE gerajsontestepc
 
    Local oJSTest  := JsonObject():New()
    Local aItem    := {}    
    Local nI       := 0
    Local cQuery   := ""

 ::SetContentType("application/json") 
 
      oJSTest["codigoEmpresa"]     :=  "12377080000188"   
      oJSTest["codigoComprador"]   :=  "50254873073"
      oJSTest["condicaoPagamento"] :=  "03030060090"
      oJSTest["dataEntrega"]       :=  "2020-09-30"
      oJSTest["dataFaturamento"]   :=  "2020-09-30"
      oJSTest["numeroPedido"]      :=  "1234567"
 
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
  cQuery += " AND   SC7.C7_NUM in ('341244') "

  
  oJSTest["fornecedor"]        :=  "09388615000292"  

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

  oJSTest["itens"] := aItem

  ::SetStatus(200)  
  ::SetResponse(oJSTest:ToJson())

Return .T.
