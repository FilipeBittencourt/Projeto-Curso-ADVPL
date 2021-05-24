#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoProdutos
Classe para sincronizar os produtos com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoProdutos From PTVinilicoAbstractAPI

  Method New() Constructor

  Method Process()
  Method Get()
  Method Valid()
  Method Analyze()
  Method Send()

  Method GetMultiPallet()
  Method GetGroup()
  Method GetUnit()

EndClass


/*/{Protheus.doc} PTVinilicoProdutos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoProdutos

  _Super:New()

Return


/*/{Protheus.doc} PTVinilicoProdutos::Process
Método de processamento do produto
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param nRecno, numeric, Recno no cliente
/*/
Method Process( nRecno ) Class PTVinilicoProdutos

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local aAreaSB1      := SB1->(GetArea())
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  dbSelectArea("SB1")
  SB1->( dbSetOrder(1) )
  SB1->( dbGoTo( nRecno ) )

  Begin Sequence

    If !SB1->( EoF() ) .And. SB1->( Recno() ) == nRecno

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

  RestArea(aAreaSB1)
  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoProdutos::Get
Método responsável por reunir dados do produto
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method Get() Class PTVinilicoProdutos

  Local jRet              := JsonObject():New()
  Local cBranchKey        := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cLinhaPortal      := U_PTVLINHA( SB1->B1_YLINHA )
  Local cTitulo           := ""
  Local cDescric          := ""

  //|Busca o titulo |
  If !Empty( SB1->B1_YTITVIN )
    cTitulo   := EncodeUtf8( SB1->B1_YTITVIN )
  Else
    cTitulo   := Capital( SB1->B1_DESC )
  EndIf

  //|Busca a descrição |
  If !Empty( SB1->B1_YDESVIN )
    cDescric   := EncodeUtf8( SB1->B1_YDESVIN )
  Else
    cDescric   := "Linha " + Capital(cLinhaPortal)
  EndIf
  
  jRet["uuid"]                := AllTrim(SB1->B1_YIDVINI)
  jRet["req_id"]              := cValToChar( SB1->( Recno() ) )
  jRet["legacy_code"]         := AllTrim(SB1->B1_COD)
  jRet["company_key"]         := SubStr(cBranchKey, 1, 8)
  jRet["branch_key"]          := cBranchKey
  jRet["name"]                := cTitulo
  jRet["description"]         := cDescric
  jRet["manufacturer"]        := "Biancogres"
  jRet["price"]               := 0
  jRet["multiple"]            := SB1->B1_CONV
  jRet["stock_balance"]       := 0
  jRet["ipi_percentage"]      := 0
  jRet["gross_weight"]        := SB1->B1_PESO
  jRet["net_weight"]          := SB1->B1_PESO
  jRet["deadline"]            := 0
  // jRet["status_code"]         := Val( IIf(SB1->B1_MSBLQL == "1", "2", "1") )
  jRet["multiple_per_pallet"] := ::GetMultiPallet( SB1->B1_COD, SB1->B1_CONV )

  //|Busca dados do grupo/linha |
  jRet["product_group"]       := JsonObject():New()
  jRet["product_group"]       := ::GetGroup( cLinhaPortal )

  //|Busca unidade de medida |
  jRet["unit_of_measure"]     := JsonObject():New()
  jRet["unit_of_measure"]     := ::GetUnit( SB1->B1_UM )
  
Return jRet


/*/{Protheus.doc} PTVinilicoProdutos::GetGroup
Busca dados do grupo/linha do produto
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cLinha, character, Código da linha
@return object, Objeto com os dados do grupo
/*/
Method GetGroup( cLinhaPortal ) Class PTVinilicoProdutos

  Local jGroup       := JsonObject():New()
  Local cBranchKey   := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )

  jGroup["req_id"]               := cLinhaPortal
  jGroup["legacy_code"]          := cLinhaPortal
  jGroup["company_key"]          := SubStr(cBranchKey, 1, 8)
  jGroup["branch_key"]           := cBranchKey
  jGroup["name"]                 := cLinhaPortal
  jGroup["description"]          := Capital(cLinhaPortal)

Return jGroup


/*/{Protheus.doc} PTVinilicoProdutos::GetUnit
Monta o objeto da unidade de medida
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cUnidMed, character, Unidade de medida
@return object, Objeto
/*/
Method GetUnit( cUnidMed ) Class PTVinilicoProdutos

  Local jUnit      := JsonObject():New()
  Local cBranchKey := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local cDescric   := ""
  Local nRecUnit   := 0

  dbselectArea("SAH")
  SAH->( dbSetOrder(1) )
  If SAH->( dbSeek( xFilial("SAH") + cUnidMed ) )

    cDescric    := Capital(SAH->AH_DESCPO)
    nRecUnit    := SAH->( Recno() )

  EndIf

  jUnit["req_id"]      := cValToChar( nRecUnit )
  jUnit["legacy_code"] := cUnidMed
  jUnit["company_key"] := SubStr(cBranchKey, 1, 8)
  jUnit["branch_key"]  := cBranchKey
  jUnit["name"]        := AllTrim(cDescric)
  jUnit["initials"]    := IIf( cUnidMed == "M2", EncodeUtf8( "m²" ), cUnidMed )

Return jUnit


/*/{Protheus.doc} PTVinilicoProdutos::Analyze
Validação de regras de negócio para permitir sincronizar o produto
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do produto
/*/
Method Analyze( oObj ) Class PTVinilicoProdutos

  oObj["valido"]  := .T.

Return


/*/{Protheus.doc} PTVinilicoProdutos::Send
Método responsável por enviar os dados para a API
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Send( oDados ) Class PTVinilicoProdutos

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jProduct      := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nRecnoSB1     := 0
  Local nZ            := 0
  Local cMsgRet       := ""

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { oDados }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/products"
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

      jProduct  := JsonObject():New()
      jProduct  := jJsonResp["data"][nZ]

      nRecnoSB1 := Val(jProduct["product"]["req_id"])

      SB1->( dbGoTo(nRecnoSB1) )

      If !SB1->( EoF() ) .And. SB1->( Recno() ) == nRecnoSB1

        //|Cliente sincronizado com sucesso |
        If jProduct["status"] >= 200 .And. jProduct["status"]<= 299

          If Empty(SB1->B1_YIDVINI)

            RecLock("SB1", .F.)
            SB1->B1_YIDVINI   := jProduct["product"]["uuid"]
            SB1->( MsUnLock() )

          EndIf

        Else

          cMsgRet   := _Super:ErroConvert( IIf( Empty( jProduct["error"]:ToJson() ), "", jProduct["error"]:ToJson() ) )

          //|Caso o produto já exista no portal, atualiza no Protheus |
          If jProduct["status"] == 400

            If Upper("CAMPO: legacy_code") $ Upper(cMsgRet) .And. ValType(jProduct["product"]["uuid"]) != "U"

              RecLock("SB1", .F.)
              SB1->B1_YIDVINI   := jProduct["product"]["uuid"]
              SB1->( MsUnLock() )

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


/*/{Protheus.doc} PTVinilicoProdutos::GetMultiPallet
Busca a quantidade multipla por palete
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 08/01/2021
@param cProduto, character, Código do Produto
@param nConv, numeric, Fator de conversão para caixa
@return numeric, metros quadrados por palete
/*/
Method GetMultiPallet( cProduto, nConv ) Class PTVinilicoProdutos

  Local nMultiplo   := 0
  Local cQuery      := ""
  Local aArea       := GetArea()

  cQuery += " SELECT ZZ9_DIVPA "
  cQuery += " FROM " + RetSqlName("ZZ9") + " ZZ9 "
  cQuery += " WHERE ZZ9.ZZ9_FILIAL = " + ValToSql( xFilial("ZZ9") )
  cQuery += "       AND ZZ9.ZZ9_PRODUT = " + ValToSql( cProduto )
  cQuery += "       AND ZZ9.ZZ9_LOTE = '' "
  cQuery += "       AND ZZ9.ZZ9_MSBLQL <> '1' "
  cQuery += "       AND ZZ9.D_E_L_E_T_ = '' "

  If Select("__ZZ9") > 0
    __ZZ9->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__ZZ9"

  If !__ZZ9->( EoF() )

    nMultiplo := __ZZ9->ZZ9_DIVPA * nConv

  EndIf

  RestArea(aArea)

Return nMultiplo
