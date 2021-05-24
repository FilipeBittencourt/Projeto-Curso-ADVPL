#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoCondPagamentos
Classe para sincronizar as condições de pagamento com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoCondPagamentos From PTVinilicoAbstractAPI

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

EndClass


/*/{Protheus.doc} PTVinilicoCondPagamentos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoCondPagamentos

  _Super:New()

Return


/*/{Protheus.doc} PTVinilicoCondPagamentos::Process
Método de processamento da condição de pagamento
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param nRecno, numeric, Recno da condição de pagamento
/*/
Method Process( nRecno ) Class PTVinilicoCondPagamentos

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local aAreaSE4      := SE4->(GetArea())
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  dbSelectArea("SE4")
  SE4->( dbSetOrder(1) )
  SE4->( dbGoTo( nRecno ) )

  Begin Sequence

    If !SE4->( EoF() ) .And. SE4->( Recno() ) == nRecno

      //|Busca os dados da condição de pagamento |
      oDados    := ::Get()

      //|Analisa se o titulo esta apto para envio na API |
      ::Analyze( @oDados )

      If oDados["valido"]

        //|Sincroniza a condição de pagamento com o portal |
        ::Send( oDados )

      EndIf

    EndIf

  End Sequence

  ErrorBlock(bError)

  If (!Empty(cError))
    _Super:Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError, .T. )
  EndIf

  FreeObj(oError)
  FreeObj(oDados)

  RestArea(aAreaSE4)
  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoCondPagamentos::Get
Método responsável por reunir dados da condição de pagamento
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados da condição de pagamento
/*/
Method Get() Class PTVinilicoCondPagamentos

  Local jRet          := JsonObject():New()
  Local cBranchKey    := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  
  jRet["uuid"]                 := AllTrim(SE4->E4_YIDVINI)
  jRet["req_id"]               := cValToChar( SE4->( Recno() ) )
  jRet["legacy_code"]          := AllTrim(SE4->E4_CODIGO)
  jRet["company_key"]          := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]           := cBranchKey
  jRet["name"]                 := Capital(AllTrim(SE4->E4_DESCRI))
  jRet["type"]                 := "cash"
  jRet["quantity_installment"] := 0
  jRet["min_per_installment"]  := 0
  jRet["interest_percentage"]  := 0
  jRet["financial_factor"]     := SE4->E4_YMAXDES
  jRet["is_specific"]          := "false"

Return jRet


/*/{Protheus.doc} PTVinilicoCondPagamentos::Analyze
Validação de regras de negócio para permitir sincronizar a condição de pagamento
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject
/*/
Method Analyze( oObj ) Class PTVinilicoCondPagamentos

  oObj["valido"]  := .T.

Return


/*/{Protheus.doc} PTVinilicoCondPagamentos::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Send( oDados ) Class PTVinilicoCondPagamentos

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jPagto        := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nRecnoSE4     := 0
  Local nZ            := 0
  Local cMsgRet       := ""

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/payment-methods"
  oEnvio:cToken       := ::cToken
  oEnvio:jBody        := jRemessa

  If Empty( oDados["uuid"] )
    jRetorno  := oEnvio:Post()
  Else
    jRetorno  := oEnvio:Put()
  EndIf

  //Transmite para o Portal Vinilico |
  If jRetorno["status"] == "OK"

    //|Pega a resposta |
    jJsonResp     := JsonObject():New()
    jJsonResp:FromJson( jRetorno["message"] )

    //|Processa cada registro retornado |
    For nZ := 1 To Len( jJsonResp["data"] )

      jPagto  := JsonObject():New()
      jPagto  := jJsonResp["data"][nZ]

      nRecnoSE4 := Val(jPagto["payment_method"]["req_id"])

      SE4->( dbGoTo(nRecnoSE4) )

      If !SE4->( EoF() ) .And. SE4->( Recno() ) == nRecnoSE4

        //|Condição de pagamento sincronizado com sucesso |
        If jPagto["status"] >= 200 .And. jPagto["status"]<= 299

          If Empty(SE4->E4_YIDVINI)

            RecLock("SE4", .F.)
            SE4->E4_YIDVINI   := jPagto["payment_method"]["uuid"]
            SE4->( MsUnLock() )

          EndIf

        Else

          cMsgRet   := _Super:ErroConvert( IIf( Empty( jPagto["error"]:ToJson() ), "", jPagto["error"]:ToJson() ) )

          //|Caso a condição de pagamento já exista no portal, atualiza no Protheus |
          If jPagto["status"] == 400

            If Upper("CAMPO: legacy_code") $ Upper(cMsgRet) .And. ValType(jPagto["payment_method"]["uuid"]) != "U"

              RecLock("SE4", .F.)
              SE4->E4_YIDVINI   := jPagto["payment_method"]["uuid"]
              SE4->( MsUnLock() )

              cMsgRet := ""

            EndIf

          EndIf

          //|Significa que deu erro na inclusao e nao é referente a duplicidade |
          If !Empty(cMsgRet)

            _Super:Comunica(cMsgRet)

          EndIf

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
