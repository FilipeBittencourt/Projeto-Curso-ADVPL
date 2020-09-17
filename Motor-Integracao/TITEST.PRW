#Include 'TOTVS.CH'
#Include "TopConn.ch"

//U_TITEST
User Function TITEST()
 

    Local oJSTest  := JsonObject():New()
    Local aItem    := {}
    Local cC7NUM   := "427005"
    Local nI       := 0
    Local cQuery   := ""

      oJSTest["codigoEmpresa"]     :=  "12377080000188"   
      oJSTest["codigoComprador"]   :=  "50254873073"
      oJSTest["condicaoPagamento"] :=  "03030060090"
      oJSTest["dataEntrega"]       :=  "2020-09-15"
      oJSTest["dataFaturamento"]   :=  "2020-09-30"
      oJSTest["numeroPedido"]      :=  "1234567"
 
  If Select("SX6") <= 0	
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})	
  EndIf	  


   cQuery := U_NAOCOMPRAR()

  cQuery += " SELECT C7_PRODUTO,C7_QUANT,C7_PRECO FROM SC7080 WHERE C7_NUM IN ('427005' )"
  oJSTest["fornecedor"]        :=  "60860681000432" // C7_NUM IN ('427005' )

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

Return oJSTest
