#include 'totvs.ch'
#include 'topconn.ch'


/*/{Protheus.doc} PTVinilicoSessionAuth
Classe responsável por autenticar no Portal Vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
Class PTVinilicoSessionAuth From PTVinilicoAbstractAPI

  Data cUrl
  Data cLogin
  Data cSenha

  Method New() Constructor
  Method Login()
  Method GetToken()

EndClass


/*/{Protheus.doc} PTVinilicoSessionAuth::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
Method New() Class PTVinilicoSessionAuth

  _Super:New()

  ::cUrl            := SuperGetMV("ZZ_VNURL", .F., "https://vinilicobackend.appfacile.com.br")
  ::cLogin          := SuperGetMV("ZZ_VNLOGIN", .F., "admin")
  ::cSenha          := SuperGetMV("ZZ_VNSENHA", .F., "PsPr@2020")

Return Self


/*/{Protheus.doc} PTVinilicoSessionAuth::Login
Método para realizar o login
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
@param cCgcLogin, character, CGC para login
@return object, Objeto json com o retorno
/*/
Method Login( cCgcLogin ) Class PTVinilicoSessionAuth

  Local cEndpoint     := "/sessions"
  Local cError        := ""
  Local nStatus       := 0
  Local oRest         := Nil
  Local oBody         := JsonObject():New()
  Local jResult       := JsonObject():New()
  Local aHeader       := {}

  jResult["token"]    := ""
  jResult["result"]   := ""

  Default cCgcLogin   := SM0->M0_CGC

  ::cToken  := ""

  oRest := FWRest():New( ::cUrl )

  //|Endpoint |
  oRest:setPath( cEndpoint )

  //|Cabeçalho de requisição |
  aAdd(aHeader,"Accept-Encoding: UTF-8")
  aAdd(aHeader,"Content-Type: application/json; charset=utf-8")

  oBody["login"]      := ::cLogin
  oBody["password"]   := ::cSenha

  //|Seta o body |
  oRest:SetPostParams( oBody:toJson() )
  oRest:SetChkStatus(.F.)

  If oRest:Post(aHeader)

    cError  := ""
    nStatus := HTTPGetStatus(@cError)

    If nStatus >= 200 .And. nStatus <= 299

      jResult["result"]   := _Super:DecodeConvert( oRest:getResult() )

      jResult["token"]    := ::GetToken( jResult["result"] )

    Else
      jResult["result"]   := _Super:DecodeConvert( cError )
    EndIf

  Else

    jResult["result"]     := _Super:DecodeConvert( oRest:getLastError() )

  EndIf

  FreeObj(oRest)
  FreeObj(oBody)

Return jResult


/*/{Protheus.doc} PTVinilicoSessionAuth::GetToken
Pega o token no json de retorno
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
@param cJsonResp, character, Json enviado pelo portal
@return character, token retornado no login
/*/
Method GetToken( cJsonResp ) Class PTVinilicoSessionAuth

  Local cToken    := ""
  Local jJson     := JsonObject():new()

  If !Empty(cJsonResp)

    jJson:FromJson( cJsonResp )

    If ValType( jJson['token']['token'] ) == "C"
      cToken  := jJson['token']['type'] + " " + jJson['token']['token']
    EndIf

  Endif

Return cToken
