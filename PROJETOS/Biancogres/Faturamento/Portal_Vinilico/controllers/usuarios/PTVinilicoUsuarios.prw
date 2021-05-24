#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoUsuarios
Classe para sincronizar os usuários com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoUsuarios From PTVinilicoAbstractAPI

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

EndClass


/*/{Protheus.doc} PTVinilicoUsuarios::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoUsuarios

  _Super:New()

Return


/*/{Protheus.doc} PTVinilicoUsuarios::Process
Método de processamento do usuário
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param nRecno, numeric, Recno no cliente
/*/
Method Process( nRecno ) Class PTVinilicoUsuarios

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local aAreaSA1      := SA1->(GetArea())
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  dbSelectArea("SA1")
  SA1->( dbSetOrder(1) )
  SA1->( dbGoTo( nRecno ) )

  Begin Sequence

    If !SA1->( EoF() ) .And. SA1->( Recno() ) == nRecno

      //|Busca os dados do cliente |
      oDados    := ::Get()

      //|Analisa se o titulo esta apto para envio na API |
      ::Analyze( @oDados )

      If oDados["valido"]

        //|Sincroniza o cliente com o portal |
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

  RestArea(aAreaSA1)
  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoUsuarios::Get
Método responsável por reunir dados do cliente para criação do usuário
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method Get() Class PTVinilicoUsuarios

  Local jRet          := JsonObject():New()
  Local cBranchKey    := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cTpPessoa     := ""
  
  If SA1->A1_PESSOA $ "F/J"
    cTpPessoa   := SA1->A1_PESSOA
  Else
    cTpPessoa   := IIf( Len( AllTrim(SA1->A1_CGC) ) == 14, "J", "F" )
  EndIf

  jRet["uuid"]               := AllTrim(SA1->A1_YUSEVIN)
  jRet["req_id"]             := cValToChar( SA1->( Recno() ) )
  jRet["legacy_code"]        := SA1->A1_COD + SA1->A1_LOJA
  jRet["company_key"]        := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]         := cBranchKey
  jRet["type"]               := cTpPessoa
  jRet["cpf_cnpj"]           := SA1->A1_CGC
  jRet["login"]              := AllTrim(SA1->A1_CGC)
  jRet["email"]              := fGetEmail(SA1->A1_EMAIL)
  jRet["name"]               := SA1->A1_NOME
  jRet["is_eula_readed"]     := "false"
  jRet["image"]              := "1607443853861_noImage.png"
  jRet["customer_uuid"]      := AllTrim(SA1->A1_YIDVINI)

Return jRet


/*/{Protheus.doc} fGetEmail
Tratamento do campo email
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 21/12/2020
@param cEmail, character, email cadastrado
@return character, email a ser enviado para o portal
/*/
Static Function fGetEmail(cEmail)

  Local cDefault := ""
  Local nPos     := 0

  Do Case 

    Case Empty( cEmail )
      cEmail  := cDefault
    
    Case At( ";", cEmail ) > 0
      nPos   := At( ";", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)
    
    Case At( ",", cEmail ) > 0
      nPos   := At( ",", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)

    Case At( "/", cEmail ) > 0
      nPos   := At( "/", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)

  EndCase

  If !IsEmail( cEmail )

    cEmail  := cDefault

  EndIf

Return cEmail


/*/{Protheus.doc} PTVinilicoUsuarios::Analyze
Validação de regras de negócio para permitir sincronizar o usuários
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do cliente
/*/
Method Analyze( oObj ) Class PTVinilicoUsuarios

  oObj["valido"]  := .T.

  If !Empty( oObj["uuid"] )
    oObj["valido"]  := .F.
  EndIf

Return


/*/{Protheus.doc} PTVinilicoUsuarios::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oDados, object, JsonObject com dados do usuário
/*/
Method Send( oDados ) Class PTVinilicoUsuarios

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jUsuario      := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nRecnoSA1     := 0
  Local nZ            := 0
  Local cMsgRet       := ""

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o usuário para o portal vinilico |
  oEnvio:cEndPoint    := "/users"
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

      jUsuario  := JsonObject():New()
      jUsuario  := jJsonResp["data"][nZ]

      nRecnoSA1 := Val(jUsuario["user"]["req_id"])

      SA1->( dbGoTo(nRecnoSA1) )

      If !SA1->( EoF() ) .And. SA1->( Recno() ) == nRecnoSA1

        //|Cliente sincronizado com sucesso |
        If jUsuario["status"] >= 200 .And. jUsuario["status"]<= 299

          If Empty(SA1->A1_YUSEVIN)

            RecLock("SA1", .F.)
            SA1->A1_YUSEVIN   := jUsuario["user"]["uuid"]
            SA1->( MsUnLock() )

          EndIf

        Else

          cMsgRet   := _Super:ErroConvert( IIf( Empty( jUsuario["error"]:ToJson() ), "", jUsuario["error"]:ToJson() ) )

          //|Caso o cliente já exista no portal, atualiza no Protheus |
          If jUsuario["status"] == 400

            If Upper("CAMPO: legacy_code") $ Upper(cMsgRet) .And. ValType(jUsuario["user"]["uuid"]) != "U"

              RecLock("SA1", .F.)
              SA1->A1_YIDVINI   := jUsuario["user"]["uuid"]
              SA1->( MsUnLock() )

              cMsgRet := ""

            EndIf

          EndIf

          //|Significa que deu erro na inclusao e nao é referente a duplicidade de cliente |
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
