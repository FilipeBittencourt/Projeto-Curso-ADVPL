#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'


#Define cEOL Chr(13)+Chr(10)

WsRestFul FILIPE Description "Facile Sistemas Webservices - Motor de Integração"
  WSMETHOD GET DESCRIPTION "Session Motor de Integração" WSSYNTAX "/FILIPE"
End WsRestFul
//----------------------------------------
// POST
//----------------------------------------
WSMETHOD GET WSSERVICE FILIPE

  Local cResponse := ""
  Local cBody     := ""
  Local aHeader   := {"Content-Type: application/json"}
  Local oJson     := JsonObject():New()  
  Local cHost	    := "http://localhost:9999"
  Local cAPI	    := "/api/oauth2/v1/token?grant_type=password"
  
  self:SetContentType("application/json")

  //|Recupera os dados do body |
  /*
 
  oJson:FromJson(cBody)
  cAPI += "&username="+oJson["login"]+"&password="+oJson["password"]+"" 
  cResponse := HTTPQuote(cHost+cAPI,"POST","","",10,aHeader,cHRet)

  oJson:FromJson(cResponse)
  */
    cBody := ::GetContent()
    conOut('FILIPE - POST METHOD')

   self:SetStatus(500)
   oJson:FromJson(cBody)
   
   self:SetResponse(oJson:ToJson())

Return 

 