#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoEstoques
Classe para sincronizar o estoque dos produtos com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoEstoques From PTVinilicoAbstractAPI

  Data cIdProd
  Data cCodSB1
  Data cLocEst
  Data nSaldo

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

EndClass


/*/{Protheus.doc} PTVinilicoEstoques::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoEstoques

  _Super:New()

  ::cIdProd := ""
  ::cCodSB1 := ""
  ::cLocEst := ""
  ::nSaldo  := 0

Return


/*/{Protheus.doc} PTVinilicoEstoques::Process
Método de processamento do estoque
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Process() Class PTVinilicoEstoques

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  Begin Sequence

    //|Busca os dados do cliente |
    oDados    := ::Get()

    //|Analisa se o titulo esta apto para envio na API |
    ::Analyze( @oDados )

    If oDados["valido"]

      //|Sincroniza o cliente com o portal |
      ::Send( oDados )

    EndIf

  End Sequence

  ErrorBlock(bError)

  If (!Empty(cError))
    _Super:Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError, .T. )
  EndIf

  FreeObj(oError)
  FreeObj(oDados)

  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoEstoques::Get
Método responsável por reunir dados do estoque
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do estoque
/*/
Method Get() Class PTVinilicoEstoques

  Local jRet          := JsonObject():New()
  Local cBranchKey    := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  
  jRet["req_id"]       := AllTrim(::cIdProd) + AllTrim(::cLocEst)
  jRet["legacy_code"]  := AllTrim(::cIdProd) + AllTrim(::cLocEst)
  jRet["company_key"]  := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]   := cBranchKey
  jRet["product_uuid"] := AllTrim(::cIdProd)
  jRet["location"]     := AllTrim(::cLocEst)
  jRet["quantity"]     := ::nSaldo
  
Return jRet


/*/{Protheus.doc} PTVinilicoEstoques::Analyze
Validação de regras de negócio para permitir sincronizar o estoque
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do estoque
/*/
Method Analyze( oObj ) Class PTVinilicoEstoques

  oObj["valido"]  := .T.

Return


/*/{Protheus.doc} PTVinilicoEstoques::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Send( oDados ) Class PTVinilicoEstoques

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jEstoque      := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nZ            := 0
  Local cMsgRet       := ""

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/stocks"
  oEnvio:cToken       := ::cToken
  oEnvio:jBody        := jRemessa

  jRetorno  := oEnvio:Post()

  //Transmite para o Portal Vinilico |
  If jRetorno["status"] == "OK"

    //|Pega a resposta |
    jJsonResp     := JsonObject():New()
    jJsonResp:FromJson( jRetorno["message"] )

    //|Processa cada registro retornado |
    For nZ := 1 To Len( jJsonResp["data"] )

      jEstoque  := JsonObject():New()
      jEstoque  := jJsonResp["data"][nZ]

      //|Cliente sincronizado com sucesso |
      If jEstoque["status"] >= 200 .And. jEstoque["status"]<= 299

         _Super:Comunica("Produto: " + AllTrim(::cCodSB1) + " / " + AllTrim(::cLocEst) + " - Preço: " + cValToChar(::nSaldo) + " -> Estoque atualizado com sucesso.")

      Else

        cMsgRet   := _Super:ErroConvert( IIf( Empty( jEstoque["error"]:ToJson() ), "", jEstoque["error"]:ToJson() ) )

        If !Empty(cMsgRet)

          _Super:Comunica(cMsgRet)

        EndIf

      EndIf

    Next nZ

  Else

    If ::lBlind
      _Super:Comunica( "### ERRO: " + jRetorno["message"] )
    Else
      Aviso( "Portal Vinilico", jRetorno["message"], {"OK"}, 3 )
    EndIf

  EndIf

  FreeObj(oEnvio)
  FreeObj(jRemessa)
  FreeObj(jJsonResp)
  FreeObj(jRetorno)

Return
