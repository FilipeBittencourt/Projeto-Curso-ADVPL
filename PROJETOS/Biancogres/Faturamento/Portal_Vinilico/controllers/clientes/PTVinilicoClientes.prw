#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoClientes
Classe para sincronizar os clientes com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoClientes From PTVinilicoAbstractAPI

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

  Method GetGroup()
  Method GetPayment()
  Method GetLocalEst()
  Method GetDiscount()

EndClass


/*/{Protheus.doc} PTVinilicoClientes::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoClientes

  _Super:New()

Return


/*/{Protheus.doc} PTVinilicoClientes::Process
Método de processamento do cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param nRecno, numeric, Recno no cliente
/*/
Method Process( nRecno ) Class PTVinilicoClientes

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


/*/{Protheus.doc} PTVinilicoClientes::Get
Método responsável por reunir dados do cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method Get() Class PTVinilicoClientes

  Local jRet          := JsonObject():New()
  Local cBranchKey    := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cVencLC       := ""
  Local cTpPessoa     := ""
  
  If SA1->A1_PESSOA $ "F/J"
    cTpPessoa   := SA1->A1_PESSOA
  Else
    cTpPessoa   := IIf( Len( AllTrim(SA1->A1_CGC) ) == 14, "J", "F" )
  EndIf

  jRet["uuid"]                := AllTrim(SA1->A1_YIDVINI)
  jRet["req_id"]              := cValToChar( SA1->( Recno() ) )
  jRet["legacy_code"]         := SA1->A1_COD + SA1->A1_LOJA
  jRet["company_key"]         := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]          := cBranchKey
  jRet["type"]                := cTpPessoa
  jRet["cpf_cnpj"]            := SA1->A1_CGC
  jRet["state_inscription"]   := SA1->A1_INSCR
  jRet["first_name"]          := Capital(SA1->A1_NOME)
  jRet["last_name"]           := ""
  jRet["email"]               := U_PTVEMAIL(SA1->A1_EMAIL)
  jRet["ddd1"]                := IIf( Empty(SA1->A1_DDD), "00", SA1->A1_DDD)
  jRet["telephone1"]          := IIf( Empty(SA1->A1_TEL), "999999999", SA1->A1_TEL)
  jRet["ddd2"]                := ""
  jRet["telephone2"]          := SA1->A1_FAX
  jRet["zip_code"]            := SA1->A1_CEP
  jRet["state_id"]            := _Super:GetUF( SA1->A1_EST )
  jRet["city_id"]             := jRet["state_id"] + IIf( Empty(SA1->A1_COD_MUN), "00000", AllTrim( SA1->A1_COD_MUN ) )
  jRet["neighborhood"]        := SA1->A1_BAIRRO
  jRet["address"]             := Capital(SA1->A1_END)
  jRet["number"]              := ""
  jRet["complement"]          := SA1->A1_COMPLEM
  jRet["credit_limit"]        := SA1->A1_LC
  jRet["stock_location"]      := ::GetLocalEst( SA1->A1_YLOCEST )
  jRet["status_code"]         := Val( IIf(SA1->A1_MSBLQL == "1", "2", "1") )
  jRet["discount_percentage"] := ::GetDiscount( SA1->A1_COD, SA1->A1_LOJA )

  cVencLC   := _Super:Format( SA1->A1_VENCLC )
  jRet["credit_maturity_at"] := IIf( SubStr(cVencLC,1,4) == "0000", "2040-12-31T10:00:00-03:00", cVencLC )

  If !Empty(SA1->A1_GRPTRIB)
    jRet["customer_group"]     := JsonObject():New()
    jRet["customer_group"]     := ::GetGroup( SA1->A1_GRPTRIB )
  EndIf

  If !Empty(SA1->A1_COND)
    jRet["payment_method"]     := JsonObject():New()
    jRet["payment_method"]     := ::GetPayment( SA1->A1_COND )
  EndIf

Return jRet


/*/{Protheus.doc} PTVinilicoClientes::GetGroup
Busca o grupo de clientes
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cGrpTrib, character, Código do grupo
@return object, Objeto do grupo
/*/
Method GetGroup( cGrpTrib ) Class PTVinilicoClientes

  Local jGrupo     := JsonObject():New()
  Local cBranchKey := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cDescric   := ""
  Local nRecGrupo  := 0

  dbselectArea("SX5")
  SX5->( dbSetOrder(1) )
  If SX5->( dbSeek( xFilial("SX5") + "21" + cGrpTrib ) )

    cDescric   := SX5->X5_DESCRI
    nRecGrupo  := SX5->( Recno() )

  EndIf

  jGrupo["req_id"]      := cValToChar( nRecGrupo )
  jGrupo["legacy_code"] := cGrpTrib
  jGrupo["company_key"] := SubStr(cBranchKey, 1, 8)
  jGrupo["branch_key"]  := cBranchKey
  jGrupo["name"]        := cDescric

Return jGrupo


/*/{Protheus.doc} PTVinilicoClientes::GetPayment
Busca dados da condição de pagamento exclusiva
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cCondPgto, character, Código da condição de pagamento
@return object, Objeto com os dados da condição de pagamento
/*/
Method GetPayment( cCondPgto ) Class PTVinilicoClientes

  Local jPgto      := JsonObject():New()
  Local cBranchKey := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cDescric   := ""
  Local nRecPagto  := 0

  dbselectArea("SE4")
  SE4->( dbSetOrder(1) )
  If SE4->( dbSeek( xFilial("SE4") + cCondPgto ) )

    cDescric   := SE4->E4_DESCRI
    nRecPagto  := SE4->( Recno() )

  EndIf

  jPgto["req_id"]               := cValToChar( nRecPagto )
  jPgto["legacy_code"]          := cCondPgto
  jPgto["company_key"]          := SubStr(cBranchKey, 1, 8)
  jPgto["branch_key"]           := cBranchKey
  jPgto["name"]                 := cDescric
  jPgto["type"]                 := "cash"
  jPgto["quantity_installment"] := 0
  jPgto["min_per_installment"]  := 0
  jPgto["interest_percentage"]  := 0
  jPgto["is_specific"]          := "true"

Return jPgto


/*/{Protheus.doc} PTVinilicoClientes::GetLocalEst
Busca o local de estoque do cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cLocEst, character, local de estoque
@return character, Local de estoque do cliente
/*/
Method GetLocalEst( cLocEst ) Class PTVinilicoClientes

  Local cRet    := cLocEst
  Local cOpcoes := AllTrim( GetSx3Cache( "A1_YLOCEST", "X3_CBOX" ) )

  If Empty(cLocEst)

    If AllTrim(SA1->A1_EST) $ cOpcoes
      
      cRet  := AllTrim(SA1->A1_EST)

    Else

      cRet  := "ES"

    EndIf

  EndIf

Return cRet


/*/{Protheus.doc} PTVinilicoClientes::Analyze
Validação de regras de negócio para permitir sincronizar o cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do cliente
/*/
Method Analyze( oObj ) Class PTVinilicoClientes

  oObj["valido"]  := .T.

Return


/*/{Protheus.doc} PTVinilicoClientes::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oDados, object, JsonObject com dados do cliente
/*/
Method Send( oDados ) Class PTVinilicoClientes

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jCliente      := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nRecnoSA1     := 0
  Local nZ            := 0
  Local cMsgRet       := ""

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/customers"
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

      jCliente  := JsonObject():New()
      jCliente  := jJsonResp["data"][nZ]

      nRecnoSA1 := Val(jCliente["customer"]["req_id"])

      SA1->( dbGoTo(nRecnoSA1) )

      If !SA1->( EoF() ) .And. SA1->( Recno() ) == nRecnoSA1

        //|Cliente sincronizado com sucesso |
        If jCliente["status"] >= 200 .And. jCliente["status"]<= 299

          If Empty(SA1->A1_YIDVINI)

            RecLock("SA1", .F.)
            SA1->A1_YIDVINI   := jCliente["customer"]["uuid"]
            SA1->( MsUnLock() )

          EndIf

        Else

          cMsgRet   := _Super:ErroConvert( IIf( Empty( jCliente["error"]:ToJson() ), "", jCliente["error"]:ToJson() ) )

          //|Caso o cliente já exista no portal, atualiza no Protheus |
          If jCliente["status"] == 400

            If Upper("CAMPO: legacy_code") $ Upper(cMsgRet) .And. ValType(jCliente["customer"]["uuid"]) != "U"

              RecLock("SA1", .F.)
              SA1->A1_YIDVINI   := jCliente["customer"]["uuid"]
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


/*/{Protheus.doc} PTVinilicoClientes::GetDiscount
Método para buscar o desconto gerencial do cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 08/01/2021
@param cCodCli, character, Código do cliente
@param cLojaCli, character, Loja do cliente
@return numeric, Valor do desconto
/*/
Method GetDiscount( cCodCli, cLojaCli ) Class PTVinilicoClientes

  Local nDesconto   := 0
  Local cQuery      := ""
  Local aArea       := GetArea()

  cQuery += " SELECT ZA0_PDESC "
  cQuery += " FROM " + RetSqlName("ZA0") + " ZA0 "
  cQuery += " WHERE ZA0.ZA0_FILIAL = " + ValToSql( xFilial("ZA0") )
  cQuery += "     AND ZA0.ZA0_TIPO = 'DCAT' "
  cQuery += "     AND ZA0.ZA0_MARCA = '1302' "
  cQuery += "     AND ZA0.ZA0_CAT = 'GOLD' "
  cQuery += "     AND ZA0.ZA0_STATUS = 'A' "
  cQuery += "     AND ZA0.ZA0_VIGFIM >= " + ValToSql( dDataBase )
  cQuery += "     AND ZA0.D_E_L_E_T_ = '' "

  If Select("__ZA0") > 0
    __ZA0->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__ZA0"

  If !__ZA0->( EoF() )

    nDesconto   := __ZA0->ZA0_PDESC

  EndIf

  RestArea(aArea)

Return nDesconto
