#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} TFPGestaoLimiteCaixa
Classe responsável por gerenciar o limite de caixa nos pedidos de compras
Projeto: Request to pay
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 24/11/2020
/*/
Class TFPGestaoLimiteCaixa From LongClassName

  Data oLst
  Data oLstGrupo
  Data oLstDepto
  Data cFilPed
  Data cPedido
  Data cGrpIgnora

  Method New() Constructor

  Method Valid()
  Method ProductValid()
  
  Method GetPedido()
  Method GetClassDept()

  Method GetMetas()
  Method GetClsVMeta()
  Method CalcRealizado()
  Method GetColor()
  Method GetAprovador()
  Method GetEmailAprov()
  Method DefineAprov()
  Method MountData()

  Method SendMail()
  Method GetInfo()
  Method Calculate()
  Method CalcGrupo()
  Method CalcDepto()
  Method Save()  

  Method Comunica()

EndClass


/*/{Protheus.doc} TFPGestaoLimiteCaixa::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 24/11/2020
/*/
Method New() Class TFPGestaoLimiteCaixa

  ::oLst       := ArrayList():New()
  ::oLstGrupo  := ArrayList():New()
  ::oLstDepto  := ArrayList():New()

  ::cFilPed    := ""
  ::cPedido    := ""
  ::cGrpIgnora := SuperGetMV("MV_YGRULCX",.F.,"306/307/308/309/306A/309A/306B/306C/308A")

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::Process
Processa o calculo
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 24/11/2020
/*/
Method Calculate() Class TFPGestaoLimiteCaixa

  Local cClvl      := ""

  // Local oError     := Nil
  Local cError     := ""
  // Local bError         := ErrorBlock({|oError| cError := oError:Description})
  Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})

  If ::Valid()

    Begin Sequence

    //|Busca os dados do pedido a ser calculado |
    ::GetInfo()

    //|Processa dados por grupo de produto |
    ::CalcGrupo()

    //|Processa dados por departamento |
    cNivelMaior := ::CalcDepto()

    If ::oLstDepto:GetCount() > 0

      cClvl   := ::oLstDepto:GetItem(1):cCodClassVl

      //|Analisa o resultado e define o aprovador |
      ::DefineAprov(cNivelMaior, cClvl)
      ::Save()

      //|Envia o e-mail informando para o aprovador |
      If !Empty( ::oLstDepto:GetItem(1):cEmailAprovador ) .And. ::oLstDepto:GetItem(1):cStatusLimCaixa == "B"

        ::SendMail( ::oLstDepto:GetItem(1):cEmailAprovador )

      EndIf

    EndIf
      
    End Sequence

    // ErrorBlock(bError)
    ErrorBlock(oLastError)

    If (!Empty(cError))
      ::Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError )
    EndIf
  
  EndIf

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::CalcGrupo
Calcula limite de caixa por grupo de produto
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/03/2021
/*/
Method CalcGrupo() Class TFPGestaoLimiteCaixa

  Local nI             := 0
  Local aPercMetas     := {}
  Local cNivelMaior    := "verde"
  Local nNovoRealizado := 0

  For nI := 1 To ::oLstGrupo:GetCount()

    //|Busca dados da meta |
    aPercMetas  := ::GetMetas( ::oLstGrupo:GetItem(nI):cCodGrupo, ::oLstGrupo:GetItem(nI):dDtChegada )

    //|Dados do grupo de produto |
    ::oLstGrupo:GetItem(nI):nPercGatilho   := aPercMetas[1]
    ::oLstGrupo:GetItem(nI):nPercMeta      := aPercMetas[2]
    ::oLstGrupo:GetItem(nI):nRealizado     := aPercMetas[3]
    ::oLstGrupo:GetItem(nI):nMetaGrupo     := aPercMetas[4]
    ::oLstGrupo:GetItem(nI):nSaldo         := ::oLstGrupo:GetItem(nI):nMetaGrupo - ::oLstGrupo:GetItem(nI):nRealizado
    ::oLstGrupo:GetItem(nI):nNovoSaldo     := ::oLstGrupo:GetItem(nI):nSaldo - ::oLstGrupo:GetItem(nI):nVlrPedido
    ::oLstGrupo:GetItem(nI):cDtCalculo     := DtoC( dDataBase ) + " " + SubStr( Time(), 1, 5 )

    nNovoRealizado  := ::oLstGrupo:GetItem(nI):nRealizado + ::oLstGrupo:GetItem(nI):nVlrPedido
    ::oLstGrupo:GetItem(nI):nPercRealizado := ::CalcRealizado( nNovoRealizado, ::oLstGrupo:GetItem(nI):nMetaGrupo )
    ::oLstGrupo:GetItem(nI):cCor           := ::GetColor( ::oLstGrupo:GetItem(nI):nPercRealizado, ::oLstGrupo:GetItem(nI):nPercGatilho, ::oLstGrupo:GetItem(nI):nPercMeta )

    If cNivelMaior != "vermelho"

      If ::oLstGrupo:GetItem(nI):cCor != "verde"
        cNivelMaior := ::oLstGrupo:GetItem(nI):cCor
      EndIf

    EndIf
    
  Next nI

Return 


/*/{Protheus.doc} TFPGestaoLimiteCaixa::CalcDepto
Calcula limite de caixa por departamento
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/03/2021
/*/
Method CalcDepto() Class TFPGestaoLimiteCaixa

  Local nI             := 0
  Local aPercMetas     := {}
  Local cNivelMaior    := "verde"
  Local nNovoRealizado := 0

  For nI := 1 To ::oLstDepto:GetCount()

    // Buscar dados da meta.
    aPercMetas := ::GetClsVMeta( ::oLstDepto:GetItem(nI):cCodClassVl, ::oLstDepto:GetItem(nI):dDtChegada )

    //|Dados do grupo de produto |
    ::oLstDepto:GetItem(nI):nPerGatClsV    := aPercMetas[1]
    ::oLstDepto:GetItem(nI):nPerMetaClV    := aPercMetas[2]
    ::oLstDepto:GetItem(nI):nRealClasVl    := aPercMetas[3]
    ::oLstDepto:GetItem(nI):nMetaClasVl    := aPercMetas[4]
    ::oLstDepto:GetItem(nI):nSaldoClsVl    := ::oLstDepto:GetItem(nI):nMetaClasVl - ::oLstDepto:GetItem(nI):nRealClasVl
    ::oLstDepto:GetItem(nI):nNvSaldoClV    := ::oLstDepto:GetItem(nI):nSaldoClsVl - ::oLstDepto:GetItem(nI):nVlrPedido
    ::oLstDepto:GetItem(nI):cDtCalcClsV    := DtoC( dDataBase ) + " " + SubStr( Time(), 1, 5 )

    nNovoRealizado  := ::oLstDepto:GetItem(nI):nRealClasVl + ::oLstDepto:GetItem(nI):nVlrPedido
    ::oLstDepto:GetItem(nI):nPerRealClV := ::CalcRealizado( nNovoRealizado, ::oLstDepto:GetItem(nI):nMetaClasVl )
    ::oLstDepto:GetItem(nI):cCorClsV    := ::GetColor( ::oLstDepto:GetItem(nI):nPerRealClV, ::oLstDepto:GetItem(nI):nPerGatClsV, ::oLstDepto:GetItem(nI):nPerMetaClV )

    If cNivelMaior != "vermelho"

      If ::oLstDepto:GetItem(nI):cCorClsV != "verde"
        cNivelMaior := ::oLstDepto:GetItem(nI):cCorClsV
      EndIf

    EndIf

  Next nI

Return cNivelMaior


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetInfo
Metódo responsável por buscar os dados do pedido de compras
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
/*/
Method GetInfo() Class TFPGestaoLimiteCaixa

  Local _cAlias        := GetNextAlias()
  Local _cTabDpt       := ""
  Local cClVl          := ""
  Local oObj           := Nil

  ::oLst:Clear()
  ::oLstGrupo:Clear()
  ::oLstDepto:Clear()

  If ::Valid()

    //|Busca os dados do pedido de compras |
    ::GetPedido(_cAlias)

    (_cAlias)->( dbGoTop() )

    While !(_cAlias)->( EoF() )

      oObj  := TFPGestaoLimiteCaixaModel():New()

      //|Tratamento para pedidos com classe de valor em branco em alguns itens |
      If Empty(cClVl) 
        cClVl   := (_cAlias)->C7_CLVL
      EndIf

      //|Dados do Pedido |
      oObj:cFilPed         := (_cAlias)->C7_FILIAL
      oObj:cPedido         := (_cAlias)->C7_NUM
      oObj:dEmissao        := StoD( (_cAlias)->C7_EMISSAO )
      oObj:dDtChegada      := StoD( (_cAlias)->C7_YDATCHE )
      oObj:cFornecedor     := (_cAlias)->C7_FORNECE
      oObj:cLoja           := (_cAlias)->C7_LOJA
      oObj:cStatusLimCaixa := (_cAlias)->C7_YSTLCX

      //|Dados do Grupo de Produtos (apenas informativo) |
      oObj:cProduto        := (_cAlias)->C7_PRODUTO
      oObj:cArmazem        := (_cAlias)->C7_LOCAL
      oObj:cCodGrupo       := (_cAlias)->BM_GRUPO
      oObj:cCodGrupo       := (_cAlias)->BM_GRUPO
      oObj:cDescGrupo      := (_cAlias)->BM_DESC
      oObj:nMetaGrupo      := (_cAlias)->C7_YMETLCX
      oObj:nRealizado      := (_cAlias)->C7_YREALCX
      oObj:nSaldo          := oObj:nMetaGrupo - oObj:nRealizado
      oObj:nVlrPedido      := (_cAlias)->C7_TOTAL
      oObj:nPercGatilho    := (_cAlias)->C7_YPGALCX
      oObj:nPercMeta       := (_cAlias)->C7_YPMELCX
      oObj:cDtCalculo      := (_cAlias)->C7_YDTCLCX

      //|Dados do aprovador |
      oObj:cEmpAprovador   := SubStr( (_cAlias)->C7_YAPRLCX, 1, 2 )
      oObj:cMatAprovador   := SubStr( (_cAlias)->C7_YAPRLCX, 3, 6 )
      oObj:cNomeAprovador  := (_cAlias)->C7_YNAPLCX
      oObj:cCodDeptoAprov  := ""
      oObj:cDescDeptoAprov := ""
      oObj:cClvlAprovador  := cClVl
      oObj:cEmailAprovador := ::GetEmailAprov( oObj:cEmpAprovador + oObj:cMatAprovador, cClVl )[1]
      oObj:cDtAprovacao    := (_cAlias)->C7_YDTALCX

      
      //|Buscar os dados referentes ao Departamento |
      _cTabDpt            := GetNextAlias()

      ::GetClassDept(cClVl, _cTabDpt)
      oObj:cCodClassVl    := (_cTabDpt)->CODCLASV
      oObj:cDescClasVl    := (_cTabDpt)->DSCCLASV
      oObj:nMetaClasVl    := (_cAlias)->C7_YMETLDP
      oObj:nRealClasVl    := (_cAlias)->C7_YREALDP
      oObj:nSaldoClsVl    := oObj:nMetaClasVl - oObj:nRealClasVl
      oObj:nPerGatClsV    := (_cAlias)->C7_YPGALDP
      oObj:nPerMetaClV    := (_cAlias)->C7_YPMELDP
      oObj:cDtCalcClsV    := (_cAlias)->C7_YDTCLDP
      
      (_cAlias)->( dbSkip() )

      ::oLst:Add(oObj)

    EndDo

    ::MountData()

  EndIf

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::CalcRealizado
Calcula o percentual já realizado da meta
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param nSaldo, numeric, Saldo atual
@param nMeta, numeric, Valor da meta
@return numeric, Percentual realizado
/*/
Method CalcRealizado(nSaldo, nMeta) Class TFPGestaoLimiteCaixa

  Local nRealizado    := 0

  nRealizado  := nSaldo / nMeta
  nRealizado  := nRealizado * 100

  nRealizado  := Round(nRealizado, 2)

Return nRealizado


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetPedido
Busca os dados do pedido de compra
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param cAliasQry, character, Alias da query
/*/
Method GetPedido(cAliasQry) Class TFPGestaoLimiteCaixa

  Local cQuery        := ""

  cQuery += " SELECT SC7.C7_FILIAL, "
  cQuery += "       SC7.C7_NUM, "
  cQuery += "       SC7.C7_EMISSAO, "
  cQuery += "       SC7.C7_YAPRLCX, "
  cQuery += "       SC7.C7_YNAPLCX, "
  cQuery += "       SC7.C7_YDTALCX, "
  cQuery += "       SC7.C7_YSTLCX, "
  cQuery += "       SC7.C7_FORNECE, "
  cQuery += "       SC7.C7_LOJA, "
  cQuery += "       SC7.C7_PRODUTO, "
  cQuery += "       SC7.C7_LOCAL, "
  cQuery += "       SC7.C7_CLVL, "
  cQuery += "       SC7.C7_YDATCHE, "
  cQuery += "       SC7.C7_YDTCLCX, "
  cQuery += "       SBM.BM_GRUPO, "
  cQuery += "       SBM.BM_DESC, "
  cQuery += "       ((SC7.C7_QUANT - SC7.C7_QUJE) * SC7.C7_PRECO) AS C7_TOTAL, "
  cQuery += "       SC7.C7_YPMELCX AS C7_YPMELCX, "
  cQuery += "       SC7.C7_YPGALCX AS C7_YPGALCX, "
  cQuery += "       SC7.C7_YMETLCX AS C7_YMETLCX, "
  cQuery += "       SC7.C7_YREALCX AS C7_YREALCX, "
  cQuery += "       SC7.C7_YDTCLDP, "
  cQuery += "       SC7.C7_YMETLDP AS C7_YMETLDP, "
  cQuery += "       SC7.C7_YPGALDP AS C7_YPGALDP, "
  cQuery += "       SC7.C7_YREALDP AS C7_YREALDP, "
  cQuery += "       SC7.C7_YPMELDP AS C7_YPMELDP "
  cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
  cQuery += "     JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery += "         ON SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "           AND SB1.B1_COD = SC7.C7_PRODUTO "
  cQuery += "           AND SB1.D_E_L_E_T_ = '' "
  cQuery += "     JOIN " + RetSqlName("SBM") + " SBM "
  cQuery += "         ON SBM.BM_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "           AND SBM.BM_GRUPO = SB1.B1_GRUPO "
  cQuery += "           AND SBM.D_E_L_E_T_ = '' "
  cQuery += " WHERE SC7.C7_FILIAL = " + ValToSql( ::cFilPed )
  cQuery += "       AND SC7.C7_NUM = " + ValToSql( ::cPedido )
  cQuery += "       AND SC7.D_E_L_E_T_ = '' "

  cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .T., .T. )

Return


Method MountData() Class TFPGestaoLimiteCaixa

  Local nI             := 0
  Local nNovoRealizado := 0
  Local nPos           := 0
  Local oObj           := Nil
  Local oObj2          := Nil

  For nI := 1 To ::oLst:GetCount()

    oObj    := ::oLst:GetItem(nI)
    oObj2   := ::oLst:GetItem(nI)

    //|Processsa grupo de produtos |
    If .F. // PONTIN - Desativado processo por grupo de produto a pedido da Barbara: !oObj:cCodGrupo $ ::cGrpIgnora

      If ( nPos := aScan( ::oLstGrupo:ToArray(), { |e| e:cCodGrupo == oObj:cCodGrupo } ) ) > 0
      
        ::oLstGrupo:GetItem(nPos):nNovoSaldo -= oObj:nVlrPedido
        ::oLstGrupo:GetItem(nPos):nVlrPedido += oObj:nVlrPedido

        //|Calcula o realizado do grupo de produtos |
        nNovoRealizado      := oObj:nRealizado + ::oLstGrupo:GetItem(nPos):nVlrPedido

        ::oLstGrupo:GetItem(nPos):nPercRealizado := ::CalcRealizado( nNovoRealizado, oObj:nMetaGrupo )
        ::oLstGrupo:GetItem(nPos):cCor           := ::GetColor( ::oLstGrupo:GetItem(nPos):nPercRealizado, oObj:nPercGatilho, oObj:nPercMeta )
      
      Else

        oObj:nNovoSaldo := oObj:nSaldo - oObj:nVlrPedido

        //|Calcula o realizado do grupo de produtos |
        nNovoRealizado      := oObj:nRealizado + oObj:nVlrPedido

        oObj:nPercRealizado := ::CalcRealizado( nNovoRealizado, oObj:nMetaGrupo )
        oObj:cCor           := ::GetColor( oObj:nPercRealizado, oObj:nPercGatilho, oObj:nPercMeta )

        ::oLstGrupo:Add(oObj)

      EndIf

    EndIf

    //|Processa os departamentos |
    If ::ProductValid( oObj2:cProduto, oObj2:cArmazem ) .And. !Empty(oObj2:cCodClassVl)

      If ( nPos := aScan( ::oLstDepto:ToArray(), { |e| e:cCodClassVl == oObj2:cCodClassVl } ) ) > 0
      
        ::oLstDepto:GetItem(nPos):nNvSaldoClV -= oObj2:nVlrPedido
        ::oLstDepto:GetItem(nPos):nVlrPedido  += oObj2:nVlrPedido

        //|Calcula o realizado do grupo de produtos |
        nNovoRealizado      := oObj2:nRealClasVl + ::oLstDepto:GetItem(nPos):nVlrPedido

        ::oLstDepto:GetItem(nPos):nPerRealClV := ::CalcRealizado( nNovoRealizado, oObj2:nMetaClasVl )
        ::oLstDepto:GetItem(nPos):cCorClsV    := ::GetColor( ::oLstDepto:GetItem(nPos):nPerRealClV, oObj2:nPerGatClsV, oObj2:nPerMetaClV )
      
      Else

        oObj2:nNvSaldoClV   := oObj2:nSaldoClsVl - oObj2:nVlrPedido

        //|Calcula o realizado do grupo de produtos |
        nNovoRealizado      := oObj2:nRealClasVl + oObj2:nVlrPedido

        oObj2:nPerRealClV   := ::CalcRealizado( nNovoRealizado, oObj2:nMetaClasVl )
        oObj2:cCorClsV      := ::GetColor( oObj2:nPerRealClV, oObj2:nPerGatClsV, oObj2:nPerMetaClV )

        ::oLstDepto:Add(oObj2)

      EndIf

    EndIf

  Next nI

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetPedido
Busca os dados do pedido de compra
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param cAliasQry, character, Alias da query
/*/
Method GetClassDept(cClVl, cAliasQry) Class TFPGestaoLimiteCaixa
Local cQuery := ""

  cQuery += " SELECT "
  cQuery += "     ZCA_ENTID   AS CODCLASV "
  cQuery += "   , ZCA_DESCRI  AS DSCCLASV "
  cQuery += " FROM " + RetSqlName("CTH") + " AS CTH "
  cQuery += "     JOIN "+ RetSqlName("ZCA") +" AS ZCA ON "
	cQuery += "         	    ZCA.ZCA_ENTID = CTH.CTH_YENTID "
  cQuery += "           AND ZCA.D_E_L_E_T_ = ' ' "
  cQuery += " WHERE "
  cQuery += "           CTH.CTH_CLVL = " + ValToSql( cClVl )
  cQuery += "       AND CTH.D_E_L_E_T_ = ' ' "

  cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

Return

/*/{Protheus.doc} TFPGestaoLimiteCaixa::Comunica
Método para centralizar a interface de mensagens
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 24/11/2020
@param cMsg, character, Mensagem a ser enviada
/*/
Method Comunica(cMsg) Class TFPGestaoLimiteCaixa

  Local cTitulo     := "Gestão Limite de Caixa "
  Local cPreMsg     := DtoC( Date() ) + " - " + Time() + ' #TFPGestaoLimiteCaixa - ' + cEmpAnt + '/' + cFilAnt + ' - ' + CRLF

  Default lNotifica  := .F.

  If IsBlind()
    FwLogMsg( "INFO", /*cTransactionId*/, cTitulo, FunName(), "", "01", cPreMsg + Upper(cMsg), 0, 0, {} )
    ConOut( cTitulo + cPreMsg + Upper(cMsg) )
  Else
    Aviso( cTitulo, cMsg, {"OK"}, 3 )
  EndIf

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetMetas
Busca a meta para o grupo e período
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param cCodGrupo, character, Codigo do grupo
@param dDataChegada, date, Data de Chegada
@return array, Meta e gatilho
/*/
Method GetMetas( cCodGrupo, dDataChegada ) Class TFPGestaoLimiteCaixa

  Local aMeta   := { 0, 0, 0, 0 }
  Local cAnoMes := AnoMes(dDataChegada)
  Local cQuery  := ""

  cQuery += " SELECT "

  cQuery += " ISNULL(CODGRUPO, '') AS CODGRUPO, "
  cQuery += " ISNULL(DESCGRUPO, '') AS DESCGRUPO, "
  cQuery += " ISNULL(ANOMES, '') AS ANOMES, "
  cQuery += " ISNULL(PERCMETA, 0) AS PERCMETA, "
  cQuery += " ISNULL(PERCGATILHO, 0) AS PERCGATILHO, "
  cQuery += " ISNULL(PERCTRIBUTO, 0) AS PERCTRIBUTO, "
  // cQuery += " ISNULL(DATAVENCIMENTO, '') AS DATAVENCIMENTO, "
  cQuery += " ISNULL(REALIZADO, 0) AS REALIZADO, "
  cQuery += " ISNULL(CUSTO_MES,  0) AS CUSTO_MES "

  cQuery += " FROM VW_BZ_META_CONSUMO "
  cQuery += " WHERE CODGRUPO = " + ValToSql( cCodGrupo )
  cQuery += "       AND ANOMES = " + ValToSql( cAnoMes )

  If Select("_META") > 0
    _META->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "_META"

  _META->( dbGoTop() )

  If !_META->( EoF() )

    aMeta[1]  := _META->PERCGATILHO
    aMeta[2]  := _META->PERCMETA
    aMeta[3]  := _META->REALIZADO
    aMeta[4]  := _META->CUSTO_MES

  EndIf

Return aMeta

/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetClsVMeta
Busca a meta para o grupo e período
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param cCodGrupo, character, Codigo do grupo
@param dDataChegada, date, Data de Chegada
@return array, Meta e gatilho
/*/
Method GetClsVMeta( cCodClassVl, dDataChegada ) Class TFPGestaoLimiteCaixa

  Local aMeta   := { 0, 0, 0, 0 }
  Local cAnoMes := AnoMes(dDataChegada)
  Local cQuery  := ""

  cQuery += " SELECT "

  cQuery += " ISNULL(CODENTID, '') AS CODGRUPO, "
  cQuery += " ISNULL(DESCENTID, '') AS DESCGRUPO, "
  cQuery += " ISNULL(ANOMES, '') AS ANOMES, "
  cQuery += " ISNULL(PERCMETA, 0) AS PERCMETA, "
  cQuery += " ISNULL(PERCGATILHO, 0) AS PERCGATILHO, "
  cQuery += " ISNULL(PERCTRIBUTO, 0) AS PERCTRIBUTO, "
  // cQuery += " ISNULL(DATAVENCIMENTO, '') AS DATAVENCIMENTO, "
  cQuery += " ISNULL(REALIZADO, 0) AS REALIZADO, "
  cQuery += " ISNULL(CUSTO_MES,  0) AS CUSTO_MES "

  cQuery += " FROM VW_BZ_META_CONSUMO2 "
  cQuery += " WHERE "    
  cQuery += "           CODENTID = " + ValToSql( cCodClassVl )
  cQuery += "       AND ANOMES = " + ValToSql( cAnoMes )

  If Select("_META") > 0
    _META->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "_META"

  _META->( dbGoTop() )

  If !_META->( EoF() )

    aMeta[1]  := _META->PERCGATILHO
    aMeta[2]  := _META->PERCMETA
    aMeta[3]  := _META->REALIZADO
    aMeta[4]  := _META->CUSTO_MES

  EndIf

Return aMeta

/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetColor
Retorna o nível de bloqueio de acordo com as metas
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param nPercRealizado, numeric, Percentual realizado
@param nPercGatilho, numeric, Percentual de Gatilho
@param nPercMeta, numeric, Percentual de meta
@return character, cor de bloqueio
/*/
Method GetColor( nPercRealizado, nPercGatilho, nPercMeta ) Class TFPGestaoLimiteCaixa

  Local cColor    := "verde"

  If nPercRealizado >= nPercMeta
    cColor  := "vermelho"
  ElseIf nPercRealizado >= nPercGatilho .And. nPercRealizado < nPercMeta
    cColor  := "amarelo"
  EndIf

Return cColor


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetAprovador
Busca o aprovador do pedido de compra
@type method
@version 1.0
@author japon
@since 24/11/2020
@param cCor, character, cor
@param cClvlAprovador, character, classe de valor do aprovador
@return array, dados do aprovador
/*/
Method GetAprovador( cCor, cClvl, cMatricula ) Class TFPGestaoLimiteCaixa

  Local aDados       := {}
  Local cQuery       := ""
  Local cEmpAprov    := ""
  Local cMatAprov    := ""
  Local cNomeAprov   := ""
  Local cDeptoAprov  := ""
  Local cDescAprov   := ""
  Local cClvlAprov   := ""
  Local cEmailAprov  := ""
  Local cEmailSuper  := ""

  Default cMatricula := ""
  
  If cCor != "verde"

    cQuery += " SELECT "
    cQuery += " CODDEPTO, "
    cQuery += " DESCDEPTO, "
    cQuery += " MATRAPRGATILHO AS MATGATILHO, "
    cQuery += " NOMEAPRGATILHO AS NOMGATILHO, "
    cQuery += " EMAILAPRGATILHO AS MAILGATILH, "
    cQuery += " MATRAPRMETA AS MATMETA, "
    cQuery += " NOMEAPRMETA AS NOMEMETA, "
    cQuery += " EMAILAPRMETA AS EMAILMETA, "
    cQuery += " CLVL "
    cQuery += " FROM VW_BZ_APROVADOR_LIMITE_CONSUMO "
    cQuery += " WHERE CODDEPTO = " + ValToSql( cClvl )

    If !Empty(cMatricula)

      If cCor == "amarelo"
        cQuery += " AND MATRAPRGATILHO = " + ValToSql( cMatricula )
      Else
        cQuery += " AND MATRAPRMETA = " + ValToSql( cMatricula )
      EndIf

    EndIf

    If Select("_APROV") > 0
      _APROV->( dbCloseArea() )
    EndIf

    TcQuery cQuery New Alias "_APROV"

    _APROV->( dbGoTop() )

    If !_APROV->( EoF() )

      If cCor == "amarelo"

        cEmpAprov   := SubStr( _APROV->MATGATILHO, 1, 2 )
        cMatAprov   := SubStr( _APROV->MATGATILHO, 3, 6 )
        cNomeAprov  := _APROV->NOMGATILHO
        cEmailAprov := _APROV->MAILGATILH
        cEmailSuper := _APROV->EMAILMETA

      ElseIf cCor == "vermelho"

        cEmpAprov   := SubStr( _APROV->MATMETA, 1, 2 )
        cMatAprov   := SubStr( _APROV->MATMETA, 3, 6 )
        cNomeAprov  := _APROV->NOMEMETA
        cEmailAprov := _APROV->EMAILMETA
        cEmailSuper := _APROV->EMAILMETA

      EndIf

      cDeptoAprov := _APROV->CODDEPTO
      cDescAprov  := _APROV->DESCDEPTO
      cClvlAprov  := _APROV->CLVL

    EndIf
  
  EndIf

  aAdd( aDados, cEmpAprov ) 
  aAdd( aDados, cMatAprov ) 
  aAdd( aDados, cNomeAprov )
  aAdd( aDados, cDeptoAprov )
  aAdd( aDados, cDescAprov ) 
  aAdd( aDados, cClvlAprov ) 
  aAdd( aDados, cEmailAprov )
  aAdd( aDados, cEmailSuper )

Return aDados


/*/{Protheus.doc} TFPGestaoLimiteCaixa::GetEmailAprov
Busca o endereço de email do aprovador
@type method
@version 1.0
@author Facile - Pontin
@since 24/11/2020
@param cEmpAprovador, character, Empresa do aprovador
@param cMatAprovador, character, Matricula do aprovador
@return character, endereço de email
/*/
Method GetEmailAprov(cMatricula, cClvl) Class TFPGestaoLimiteCaixa

  Local cCorMaior   := "verde"
  Local cEmail      := ""
  Local cEmailSuper := ""
  Local nI          := 0
  Local aEmails     := {}
  Local aAprovador  := {}

  //|Busco o nível do bloqueio |
  For nI := 1 To ::oLstDepto:GetCount()

    //|Encontrou um vermelho já finaliza |
    If ::oLstDepto:GetItem(nI):cCor == "vermelho"
      cCorMaior   := "vermelho"
      Exit
    EndIf

    If ::oLstDepto:GetItem(nI):cCor == "amarelo"
      cCorMaior   := "amarelo"
    EndIf

  Next nI

  //|Dados do aprovador |
  aAprovador  := ::GetAprovador( cCorMaior, cClvl, cMatricula )

  If Len( aAprovador ) > 0

    cEmail      := aAprovador[7]
    cEmailSuper := aAprovador[8]

  EndIf

  aAdd( aEmails, cEmail )
  aAdd( aEmails, cEmailSuper )

Return aEmails


/*/{Protheus.doc} TFPGestaoLimiteCaixa::Save
Salva o calculo no pedido de compra
@type method
@version 1.0
@author Facile - Pontin
@since 25/11/2020
/*/
Method Save() Class TFPGestaoLimiteCaixa

  Local nI        := 0
  Local cGrupo    := ""
  Local oDados    := Nil
  Local aArea     := GetArea()
  Local aAreaSC7  := SC7->( GetArea() )
  Local aAreaSB1  := SB1->( GetArea() )

  dbSelectArea("SB1")
  SB1->( dbSetOrder(1) )

  dbSelectArea("SC7")
  SC7->( dbSetOrder(1) )
  SC7->( dbSeek( ::cFilPed + ::cPedido ) )

  While !SC7->( EoF() ) .And. SC7->C7_FILIAL == ::cFilPed .And. SC7->C7_NUM == ::cPedido

    SB1->( dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ) )
    cGrupo    := SB1->B1_GRUPO

    RecLock("SC7", .F.)

      //|Grava os dados do grupo de produto |
      For nI := 1 To ::oLstGrupo:GetCount()

        oDados    := ::oLstGrupo:GetItem(nI)

        If AllTrim(cGrupo) == AllTrim( oDados:cCodGrupo )

          SC7->C7_YMETLCX := oDados:nMetaGrupo
          SC7->C7_YREALCX := oDados:nRealizado
          SC7->C7_YDTCLCX := IIf( Empty(oDados:cDtCalculo), oDados:cDtCalcClsV, oDados:cDtCalculo )
          SC7->C7_YPMELCX := oDados:nPercMeta
          SC7->C7_YPGALCX := oDados:nPercGatilho
          SC7->C7_YDTALCX := ""
          
          Exit

        EndIf

      Next nI

      //|Grava os dados do departamento |
      oDados    := ::oLstDepto:GetItem(1)

      SC7->C7_YAPRLCX := oDados:cEmpAprovador + oDados:cMatAprovador
      SC7->C7_YNAPLCX := oDados:cNomeAprovador
      SC7->C7_YSTLCX  := oDados:cStatusLimCaixa
      SC7->C7_YMETLDP := oDados:nMetaClasVl
      SC7->C7_YREALDP := oDados:nRealClasVl
      SC7->C7_YPMELDP := oDados:nPerMetaClV
      SC7->C7_YPGALDP := oDados:nPerGatClsV
      SC7->C7_YDTCLDP := oDados:cDtCalcClsV

      SC7->( MsUnLock() )

    SC7->( dbSkip() )

  EndDo

  RestArea(aAreaSC7)
  RestArea(aAreaSB1)
  RestArea(aArea)

Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::Valid
Método para validar o uso da classe
@type method
@version 1.0
@author japon
@since 25/11/2020
@return logical, indica se é valido
/*/
Method Valid() Class TFPGestaoLimiteCaixa

  Local lValido   := .T.
  Local cMsgErro  := ""

  If Empty(::cFilPed) .Or. Empty(::cPedido)
    lValido   := .F.
    cMsgErro  := "Obrigatório informar a filial e o número do pedido de compra!"
  EndIf


  If !lValido
    ::Comunica(cMsgErro)
  EndIf

Return lValido


/*/{Protheus.doc} TFPGestaoLimiteCaixa::DefineAprov
Define Status e o aprovador em caso de bloqueio
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 27/11/2020
@param cNivelMaior, character, Maior nível de bloqueio encontrado no pedido
@param cClvl, character, Classe de valor do pedido
/*/
Method DefineAprov( cNivelMaior, cClvl ) Class TFPGestaoLimiteCaixa

  Local nI          := 0
  Local aAprovador  := {}
  Local cStatus     := IIf( cNivelMaior == "verde", "A", "B" )

  //|Dados do aprovador |
  aAprovador  := ::GetAprovador( cNivelMaior, cClvl )

  //|Atualiza informações de status e aprovador em todos os itens |
  For nI := 1 To ::oLstDepto:GetCount()

    ::oLstDepto:GetItem(nI):cEmpAprovador   := aAprovador[1]
    ::oLstDepto:GetItem(nI):cMatAprovador   := aAprovador[2]
    ::oLstDepto:GetItem(nI):cNomeAprovador  := aAprovador[3]
    ::oLstDepto:GetItem(nI):cCodDeptoAprov  := aAprovador[4]
    ::oLstDepto:GetItem(nI):cDescDeptoAprov := aAprovador[5]
    ::oLstDepto:GetItem(nI):cClvlAprovador  := aAprovador[6]
    ::oLstDepto:GetItem(nI):cEmailAprovador := aAprovador[7]

    //|Status do pedido no limite de caixa |
    ::oLstDepto:GetItem(nI):cStatusLimCaixa  := cStatus

  Next nI


Return


/*/{Protheus.doc} TFPGestaoLimiteCaixa::ProductValid
Verifica se o produto deve ser analisado
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/03/2021
@param cCodProd, character, código do produto
@param cLocal, character, armazém
@return logical, indica se é valido
/*/
Method ProductValid( cCodProd, cLocal ) Class TFPGestaoLimiteCaixa

  Local lValido   := .F.
  Local cQuery    := ""

  cQuery += " SELECT ZCN_POLIT "
  cQuery += " FROM " + RetSqlName("ZCN") + " ZCN "
  cQuery += " WHERE ZCN.ZCN_FILIAL = " + ValToSql( xFilial("ZCN") )
  cQuery += "       AND ZCN.ZCN_COD = " + ValToSql( cCodProd )
  cQuery += "       AND ZCN.ZCN_LOCAL = " + ValToSql( cLocal )
  // cQuery += "       AND ZCN.ZCN_SEQUEN = '1' "
  cQuery += "       AND ZCN.ZCN_POLIT IN ( '4', '8' ) "
  cQuery += "       AND ZCN.D_E_L_E_T_ = '' "

  If Select("__ZCN") > 0
    __ZCN->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__ZCN"

  __ZCN->( dbGoTop() )

  If !__ZCN->( EoF() )

    lValido   := .T.

  EndIf

Return lValido


/*/{Protheus.doc} TFPGestaoLimiteCaixa::SendMail
Envia e-mail informando o bloqueio do pedido
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 30/11/2020
@param cDestinatario, character, endereço de e-mail do destinatario
/*/
Method SendMail( cDestinatario ) Class TFPGestaoLimiteCaixa

  Local cHtml     := ""

  cHtml := GetHeader()
	
  cHtml += '<p><div class = "headTexto1"><b>Pedido de compra citado abaixo foi bloqueado pelas regras de Gestão do Limite de Caixa '
  cHtml += ' e precisa de aprovação.</b></div></p>'
	cHtml += '<br/>'

  cHtml += '<p><div class = "cabtab"><b>Empresa: </b></div></p>'
  cHtml += '<p><div class = "style12"> ' + cEmpAnt + '/' + ::cFilPed + ' - ' + FWEmpName(cEmpAnt) + '/' + FWFilialName(cEmpAnt, ::cFilPed, 1) + ' </div></p>'

  cHtml += '<p><div class = "cabtab"><b>Pedido de Compra: </b></div></p>'
  cHtml += '<p><div class = "style12"> ' + ::cPedido + ' </div></p>'
  cHtml += '<br/>'

  cHtml += GetFooter()

  Enviar(cHtml, cDestinatario, ::cPedido)

Return


/*/{Protheus.doc} Enviar
Dispara o e-mail para o aprovador
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 30/11/2020
@param cHtml, character, Html do texto a ser enviado
@return Logical, Informa se foi enviado com sucesso
/*/
Static Function Enviar(cHtml, cDestinatario, cNumPed)
	
	Local _lRet     := .F.
	Local _cTo      := ""
	Local _cSubject := ""
	Local _cBody    := ""
	Local _cCC      := ""
  Local lAmbTeste := AllTrim(GetEnvServer()) $ "DEV-PONTIN/COMP-PONTIN" .And. Upper(cUserName) == "FACILE"

	_cSubject := "Bloqueio por Limite de Caixa - " + cNumPed
	
	_cTo := cDestinatario
	_cCC := ""

  If lAmbTeste
    _cTo  := "japontin@gmail.com"
  EndIf
	
	_cBody := cHtml      
	
	_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC)

Return(_lRet)


/*/{Protheus.doc} GetHeader
Monta o cabeçalho do e-mail
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 30/11/2020
@return character, Html do cabeçalho
/*/
Static Function GetHeader()
	
	Local cHtml := ""
	
	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '      <head>
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtml += '         <title>cabtitpag</title>
	cHtml += '         <style type="text/css">
	cHtml += '			<!--
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			-->
	cHtml += '         </style>
	cHtml += '      </head>
	cHtml += '      <body>

Return cHtml


/*/{Protheus.doc} GetFooter
Monta o rodapé
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 30/11/2020
@return character, Html do rodape
/*/
Static Function GetFooter()
	
	Local cHtml := ""
	
	cHtml := "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
	cHtml += "          <tr>"
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (TFPGestaoLimiteCaixa).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"
	cHtml += "      </body>"
	cHtml += "   </html>"

Return cHtml

