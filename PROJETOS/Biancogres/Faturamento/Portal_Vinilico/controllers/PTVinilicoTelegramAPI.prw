#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoTelegramAPI
Classe para integração com o Telegram
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Class PTVinilicoTelegramAPI From FwRest

  Data cUrl       As String
  Data cToken     As String
  Data aHeadOut   As Array
  Data cPath      As String
  Data cEndPoint  As String
  Data cChatId    As String

  Method New() Constructor
  Method SetChat()
  Method GetChat()
  Method Send()
  Method GetUpdates()
  Method GetMe()

  Method SendMessage()

EndClass

/*/{Protheus.doc} PTVinilicoTelegramAPI::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Method New() Class PTVinilicoTelegramAPI

  Local cUrl	 	:= "https://api.telegram.org"
  Local cToken	:= "1399474496:AAHz13QPXn_ZH_ykeucHiQvFz5vqftZzf0I"

  _Super:New(cUrl) // Inicializa metodo da classe pai

  Self:cURL		        := cUrl
  Self:cToken 	      := cToken
  Self:cPath          := "/bot" + ::cToken
  Self:cChatId        := "-487297503"
  Self:aHeadOut 	    := {}
  Self:cEndPoint      := ""

Return Self


Method SetChat( cChatId ) Class PTVinilicoTelegramAPI

  // ::cChatId := cChatId

Return ::cChatId

Method GetChat() Class PTVinilicoTelegramAPI
Return ::cChatId


/*/{Protheus.doc} PTVinilicoTelegramAPI::Send
Faz o envio da mensagem para o telegram configurado
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
@param cMessage, character, Mensagem a ser enviada
@param lHtml, logical, se envia em formato html
@return logical, Indica se conseguiu enviar a mensagem
/*/
Method Send( cMessage, lHtml ) Class PTVinilicoTelegramAPI

  Local cParseMode    := ""
  Local lRet          := .F.

  Default cMessage    := ""
  Default lHtml       := .F.

  ::New()

  //-- Determina se a msg será no formato HTML ou normal
  cParseMode  := "parse_mode="
  cParseMode  += IIF( lHtml, "HTML", "markdown" )
  ::cEndPoint := ::cPath + "/sendMessage?"  + cParseMode  + "&use_aliases=true&chat_id=" + ::cChatId + "&text=" + cMessage

  _Super:SetPath( ::cEndPoint )

  lRet := _Super:Get()

Return lRet


// ------------------------------------------------------------------------------------------------------------+
//  Se precisarmos do chat_id de uma pessoa que envia uma mensagem para o nosso bot, use o método getUpdates . |
// ------------------------------------------------------------------------------------------------------------+
Method GetUpdates() Class PTVinilicoTelegramAPI

  Local cRet := ""

  ::cEndPoint := ::cPath + "/getUpdates"

  _Super:SetPath( ::cEndPoint )

  If _Super:Get()
    cRet := _Super:GetResult()
  EndIf

Return cRet
// -------------------------------------------------------------------------------+
//  informações básicas sobre o bot recém criado, precisamos usar o método getMe  |
// -------------------------------------------------------------------------------+
Method GetMe() Class PTVinilicoTelegramAPI

  Local cRet := ""

  ::cEndPoint := ::cPath  + "/getMe"

  _Super:SetPath( ::cEndPoint )

  If _Super:Get()
    cRet := _Super:GetResult()
  EndIf

Return cRet


/*/{Protheus.doc} PTVinilicoTelegramAPI::SendMessage
Faz tratativas na mensagem e envia para o telegram
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 04/09/2020
/*/
Method SendMessage(cMsg) Class PTVinilicoTelegramAPI

  Local lRet      := .F.
  Local cPulaLn   := "%0A"

  Default cMsg    := ""

  //|Remove caracteres invalidos e acentos |
  cMsg  := StrTran(cMsg, "<", "")
  cMsg  := StrTran(cMsg, ">", "")
  cMsg  := FwNoAccent(cMsg)

  //|Quebra de linhas |
  cMsg  := StrTran( cMsg, CRLF, cPulaLn )
  cMsg  := StrTran( cMsg, "#", "" )
  cMsg  := StrTran( cMsg, "HOUVE", "OCORREU" )

  //|Envio o Texto |
  lRet := ::Send( AllTrim(cMsg), .T. /* lHtml */ )

Return lRet
