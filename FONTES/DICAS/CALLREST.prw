#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"

User Function CALLREST()

  Local cResponse := ""
  Local oJson     := JsonObject():New()

  Local cUrl	    := "https://servicodados.ibge.gov.br/api/v1/localidades/estados/"
  Local cMethod   := "GET" //POST, PUT, GET, DELETE, PATCH ....
  Local cQParams  := ""
  Local cBody     := "" //Vamos usar uma classe para montar nosso Json
  Local nTimeOut  := 15 //Tempo máximo sem retorno  da API em segundos
  Local aHeader   := {"Content-Type: application/json","Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."} // O cabeçalho da requisição
  Local cHRet     := "" // Retorno do cabençalho passado via referência (@)

  oJson['email']       := "pontin@aap.com.br"
  oJson['password']    := "jascsp@321"
  oJson['branch_key']  := "27340074000123"
  cBody := oJson:ToJson()

  //cResponse - Através de cResponse será retornada a String correspondendo ao documento solicitado.
  cResponse := HTTPQuote (cUrl,cMethod,cQParams,cBody,nTimeOut,aHeader,cHRet)

  oJson           := JsonObject():New()
  oJson:FromJson(cResponse)
  oJson['code']   := HttpGetStatus()

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
