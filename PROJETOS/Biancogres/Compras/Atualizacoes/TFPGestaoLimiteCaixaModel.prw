#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFPGestaoLimiteCaixaModel
Classe responsavel por montar o modelo de dados do pedido de compra
Projeto: Request to Pay - Gestão do Limite de Caixa
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 24/11/2020
/*/
Class TFPGestaoLimiteCaixaModel From LongClassName

  //|Dados do Pedido |
  Data cFilPed
  Data cPedido
  Data dEmissao
  Data dDtChegada
  Data cFornecedor
  Data cLoja
  Data cStatusLimCaixa
  Data cStatusClassVlr

  //|Dados do Grupo de Produtos |
  Data cProduto
  Data cArmazem
  Data cCodGrupo
  Data cDescGrupo
  Data cDtCalculo
  Data nMetaGrupo
  Data nRealizado
  Data nSaldo
  Data nVlrPedido
  Data nNovoSaldo
  Data nPercGatilho
  Data nPercMeta
  Data nPercRealizado

  //|Dados do aprovador |
  Data cEmpAprovador
  Data cMatAprovador
  Data cNomeAprovador
  Data cCodDeptoAprov
  Data cDescDeptoAprov
  Data cClvlAprovador
  Data cEmailAprovador
  Data cDtAprovacao
  Data cCor
  Data cEmailAprovClsV
  Data cCorClsV

  // Dados do Departamento/Classe de Valor.
  Data cCodClassVl
  Data cDescClasVl
  Data nMetaClasVl
  Data nRealClasVl
  Data nSaldoClsVl
  Data nNvSaldoClV
  Data nPerGatClsV
  Data nPerMetaClV
  Data cDtCalcClsV
  Data nPerRealClV

  Method New() Constructor

EndClass


Method New() Class TFPGestaoLimiteCaixaModel

  //|Dados do Pedido |
  ::cFilPed         := ""
  ::cPedido         := ""
  ::dEmissao        := CtoD("")
  ::dDtChegada      := CtoD("")
  ::cFornecedor     := ""
  ::cLoja           := ""
  ::cStatusLimCaixa := ""
  //|Dados do Grupo de Prod
  ::cProduto        := ""
  ::cArmazem        := ""
  ::cCodGrupo       := ""
  ::cDescGrupo      := ""
  ::cDtCalculo      := ""
  ::nMetaGrupo      := 0
  ::nRealizado      := 0
  ::nSaldo          := 0
  ::nVlrPedido      := 0
  ::nNovoSaldo      := 0
  ::nPercGatilho    := 0
  ::nPercMeta       := 0
  ::nPercRealizado  := 0
  //|Dados do aprovador |
  ::cEmpAprovador   := ""
  ::cMatAprovador   := ""
  ::cNomeAprovador  := ""
  ::cCodDeptoAprov  := ""
  ::cDescDeptoAprov := ""
  ::cClvlAprovador  := ""
  ::cEmailAprovador := ""
  ::cDtAprovacao    := ""
  ::cCor            := ""
  
  ::cEmailAprovClsV := ""
  ::cCorClsV        := ""
  // Dados do Departamento/Classe de Valor.
  ::cCodClassVl     := ""
  ::cDescClasVl     := ""
  ::cDtCalcClsV     := ""
  ::nMetaClasVl     := 0
  ::nRealClasVl     := 0
  ::nSaldoClsVl     := 0
  ::nNvSaldoClV     := 0
  ::nPerGatClsV     := 0
  ::nPerMetaClV     := 0
  ::nPerRealClV     := 0

Return
