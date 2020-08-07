#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"

User Function CallRest()

  Local aHeader   := {"Content-Type: application/json"}
  Local cHostWS	  := "http://codeauth.facilecloud.com.br"
  Local cLogin	  := "pontin@aap.com.br"
  Local cPass	    := "jascsp@321"
  Local cCNPJ	    := "27340074000123"
  Local oJson     := JsonObject():New()
  Local oRest     := Nil
  Local cResponse := ""

  oJson['email']       := AllTrim(cLogin)
  oJson['password']    := AllTrim(cPass)
  oJson['branch_key']  := AllTrim(cCNPJ)

  //                       ( |cUrl|            ,|cMethod|, [cGETParms], [cPOSTParms],  [nTimeOut], [aHeadStr], [@cHeaderRet] )
  cResponse := HTTPQuote ( cHostWS+"/SESSIONS" , "POST",       ""     , oJson:ToJson(),   005    ,    aHeader,      "" ) //Retorno: cResponse - Através de cResponse será retornada a String correspondendo ao documento solicitado.
  FWJsonDeserialize(cResponse, @oRest) // Depreciada, mas funciona
  //oJson := jsonobject()new()
  //oJson:FromJson(cResponse) // Nova , mas não funciona
  oJson           := JsonObject():New()
  oJson['code']   := HttpGetStatus()
  oJson['result'] := oRest

Return oJson




// POST  LOGIN
Static Function PLOGIN()


  Local aHeader   := {"Content-Type: application/json"}
  Local cHostWS	  := "http://codeauth.facilecloud.com.br"
  Local cLogin	  := "pontin@aap.com.br"
  Local cPass	    := "jascsp@321"
  Local cCNPJ	    := "27340074000123"
  Local oJson     := JsonObject():New()
  Local oRest     := Nil
  Local oSession     := Nil
  Local cResponse := ""

  oRest     := FWRest():New(cHostWS)
  oJson['email']       := AllTrim(cLogin)
  oJson['password']    := AllTrim(cPass)
  oJson['branch_key']  := SM0->M0_CGC

  oRest:setPath("/sessions")
  oRest:SetPostParams(oJson:ToJson())

  If oRest:Post(aHeader ) .OR. !Empty( oRest:GetResult() )
    If (oRest:ORESPONSEH:CSTATUSCODE == "200")
      cStringJS :=  oRest:GetResult()
      FWJsonDeserialize(cStringJS, @oSession)
      Aadd(aHeader,"Authorization:bearer "+oSession:token:token+"")
    else
      cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
      cMsg += "<b>Detalhes</b>: "+oRest:GetResult()+" "  + CRLF + CRLF
      Alert(cMsg)
    EndIf
  Else
    conout(oRest:GetLastError())
    cMsg := "<b>Erro</b>: Ops! Um erro inesperado aconteceu."  + CRLF + CRLF
    cMsg += "<b>Detalhes</b>: "+oRest:GetLastError()+" "  + CRLF + CRLF
    Alert(cMsg)
  Endif

Return aHeader
