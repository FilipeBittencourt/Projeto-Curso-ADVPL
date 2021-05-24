#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoTabelaPrecos
Classe para sincronizar as tabelas de preços com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoTabelaPrecos From PTVinilicoAbstractAPI

  Data cIdProd
  Data cCodSB1
  Data cUfCliente
  Data nPreco
  Data cMsgErro

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

EndClass


/*/{Protheus.doc} PTVinilicoTabelaPrecos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoTabelaPrecos

  _Super:New()

  ::cIdProd    := ""
  ::cCodSB1    := ""
  ::cUfCliente := ""
  ::cMsgErro   := ""
  ::nPreco     := 0

Return


/*/{Protheus.doc} PTVinilicoTabelaPrecos::Process
Método de processamento do preço
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Process() Class PTVinilicoTabelaPrecos

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  Begin Sequence

    //|Busca os dados do preço |
    oDados    := ::Get()

    //|Analisa se o titulo esta apto para envio na API |
    ::Analyze( @oDados )

    If oDados["valido"]

      //|Sincroniza o preço com o portal |
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


/*/{Protheus.doc} PTVinilicoTabelaPrecos::Get
Método responsável por reunir dados do estoque
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do estoque
/*/
Method Get() Class PTVinilicoTabelaPrecos

  Local jRet          := JsonObject():New()
  Local cBranchKey    := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  
  jRet["req_id"]              := AllTrim(::cIdProd) + AllTrim(::cUfCliente)
  jRet["legacy_code"]         := AllTrim(::cIdProd) + AllTrim(::cUfCliente)
  jRet["company_key"]         := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]          := cBranchKey
  jRet["product_uuid"]        := AllTrim(::cIdProd)
  jRet["customer_group_uuid"] := ""
  jRet["customer_uuid"]       := ""
  jRet["state_id"]            := _Super:GetUF( ::cUfCliente )
  jRet["city_id"]             := ""
  jRet["description"]         := "Vinilico " + ::cUfCliente
  jRet["price"]               := ::nPreco
  jRet["min_quantity"]        := ""
  jRet["max_quantity"]        := ""
  jRet["start_at"]            := ""
  jRet["end_at"]              := ""
  jRet["status_code"]         := 1

Return jRet


/*/{Protheus.doc} PTVinilicoTabelaPrecos::Analyze
Validação de regras de negócio para permitir sincronizar o estoque
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do estoque
/*/
Method Analyze( oObj ) Class PTVinilicoTabelaPrecos

  oObj["valido"]  := .T.

Return


/*/{Protheus.doc} PTVinilicoTabelaPrecos::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Send( oDados ) Class PTVinilicoTabelaPrecos

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jPreco        := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nZ            := 0

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/price-lists"
  oEnvio:cToken       := ::cToken
  oEnvio:jBody        := jRemessa

  ::cMsgErro    := ""

  jRetorno      := oEnvio:Post()

  //Transmite para o Portal Vinilico |
  If jRetorno["status"] == "OK"

    //|Pega a resposta |
    jJsonResp     := JsonObject():New()
    jJsonResp:FromJson( jRetorno["message"] )

    //|Processa cada registro retornado |
    For nZ := 1 To Len( jJsonResp["data"] )

      jPreco  := JsonObject():New()
      jPreco  := jJsonResp["data"][nZ]

      //|Preço sincronizado com sucesso |
      If jPreco["status"] >= 200 .And. jPreco["status"]<= 299

         _Super:Comunica("Produto: " + AllTrim(::cCodSB1) + " / " + AllTrim(::cUfCliente) + " - Preço: " + cValToChar(::nPreco) + " -> Preço atualizado com sucesso.")

      Else

        ::cMsgErro   := _Super:ErroConvert( IIf( Empty( jPreco["error"]:ToJson() ), "", jPreco["error"]:ToJson() ) )

        If !Empty(::cMsgErro)

          _Super:Comunica(::cMsgErro)

        EndIf

      EndIf

    Next nZ

  Else

    ::cMsgErro   := jRetorno["message"]

    If ::lBlind
      _Super:Comunica( "### ERRO: " + ::cMsgErro )
    Else
      Aviso( "Portal Vinilico", ::cMsgErro, {"OK"}, 3 )
    EndIf

  EndIf

  FreeObj(oEnvio)
  FreeObj(jRemessa)
  FreeObj(jJsonResp)
  FreeObj(jRetorno)

Return
