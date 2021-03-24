#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA742
@description Aprovadores de descontos financeiro via limites estabelecidos.
@author Filipe Bittencourt
@since 19/03/2021
@version 1.0
@type function
/*/

Static cTitulo := "Aprovadores de descontos financeiro"

// u_BIA742()
User Function BIA742()

  Local oBrowse
  //Local aArea := GetAera()
  Local cFunBkp := FunName()

  SetFunName("BIA742")

  oBrowse := FWMBrowse():New() // Fornece um objeto do tipo grid, botões laterais e detalhes das colunas baseado no dicionário de dados
  oBrowse:SetAlias('ZDK') // SELECINA A TABELA QUE IRÁ SER EXIBIDA
  oBrowse:SetDescription(cTitulo) // NOME DO TITULO Que aparece no topo


  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'A'" ,"GREEN","Ativo")
  oBrowse:AddLegend("ZDK->ZDK_STATUS == 'B'" ,"RED","Bloqueado")

  oBrowse:Activate() // ativa  a função para aparecer

  SetFunName(cFunBkp)
  //RestArea(aArea)

Return Nil


//------------------------------
//Definição do menu da rotina
//------------------------------
Static Function MenuDef()

  Local aRotina := {}
  ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.BIA742' OPERATION 1 ACCESS 0
  //ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.BIA742' OPERATION 2 ACCESS 0
  ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.BIA742' OPERATION 3 ACCESS 0
  ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.BIA742' OPERATION 4 ACCESS 0
  ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.BIA742' OPERATION 5 ACCESS 0
  ADD OPTION aRotina Title 'Legenda'    Action 'U_ZDKLEG' OPERATION 6 ACCESS 0

Return(aRotina)




//------------------------------
//Definição do modelo de dados
//------------------------------
Static Function ModelDef()
  //Criação do objeto do modelo de dados
  Local oModel := Nil

  //Criação da estrutura de dados utilizada na interface
  Local oStZDK := FWFormStruct(1, "ZDK")


  //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
  oModel := MPFormModel():New("BIA742M",/*bPreValid*/,{|oModel| fTdOk(oModel)},/*<bCommit >*/,/*bCancel*/)

  //Atribuindo formulários para o modelo
  oModel:AddFields("FORMZDK",/*cOwner*/,oStZDK)

  //Setando a chave primária da rotina
  oModel:SetPrimaryKey({'ZDK_FILIAL'})

  //Adicionando descrição ao modelo
  oModel:SetDescription(cTitulo)

  //Setando a descrição do formulário
  oModel:GetModel("FORMZDK"):SetDescription(cTitulo)
Return oModel


Static Function ViewDef()
  Local aStruZDK	:= ZDK->(DbStruct())

  //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
  Local oModel := FWLoadModel("BIA742")

  //Criação da estrutura de dados utilizada na interface do cadastro de Autor
  Local oStZDK := FWFormStruct(2, "ZDK")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZDK_NOME|SZDK_DTAFAL|'}

  //Criando oView como nulo
  Local oView := Nil

  //Criando a view que será o retorno da função e setando o modelo da rotina
  oView := FWFormView():New()
  oView:SetModel(oModel)

  //Atribuindo formulários para interface
  oView:AddField("VIEW_ZDK", oStZDK, "FORMZDK")

  //Criando um container com nome tela com 100%
  oView:CreateHorizontalBox("TELA",100)

  //Colocando título do formulário
  oView:EnableTitleView('VIEW_ZDK',cTitulo )

  //Força o fechamento da janela na confirmação
  oView:SetCloseOnOk({||.T.})

  //O formulário da interface será colocado dentro do container
  oView:SetOwnerView("VIEW_ZDK","TELA")


Return oView


User Function ZDKLEG()
  Local aLegenda := {}

  //Monta as cores
  AADD(aLegenda,{"GREEN",		"Ativo"  })
  AADD(aLegenda,{"RED",	"Bloqueado"})
  BrwLegenda(cTitulo, "Status", aLegenda)

Return

Static Function fTdOk(oModel)

  Local lRet    := .T.
  Local cQuery  := ""
  Local cCLVLR  := oModel:GetModel("FORMZDK"):GetValue('ZDK_CLVLR')
  Local cAPROV1 := oModel:GetModel("FORMZDK"):GetValue('ZDK_APROV1')
  Local cCCONTA := oModel:GetModel("FORMZDK"):GetValue('ZDK_CCONTA')
  Local cSTATUS := oModel:GetModel("FORMZDK"):GetValue('ZDK_STATUS')
  Local cQry    := GetNextAlias()

  cQuery += " select * from ZDK010 "  + CRLF
  cQuery += " WHERE D_E_L_E_T_ = '' "  + CRLF
  cQuery += " AND ZDK_CLVLR    = '"+AllTrim(cCLVLR)+"' "+ CRLF
  cQuery += " AND ZDK_APROV1   = '"+AllTrim(cAPROV1)+"' "+ CRLF
  cQuery += " AND ZDK_CCONTA   = '"+AllTrim(cCCONTA)+"' "+ CRLF
  cQuery += " AND ZDK_STATUS   = '"+AllTrim(cStatus)+"' "+ CRLF


  TcQuery cQuery New Alias (cQry)

  If !EMPTY((cQry)->ZDK_APROV1);
      .and. oModel:GetModel("FORMZDK"):GetValue('ZDK_VLAPIN') == (cQry)->ZDK_VLAPIN;
      .and. oModel:GetModel("FORMZDK"):GetValue('ZDK_VLAPFI') == (cQry)->ZDK_VLAPFI
    lRet := .F.
    Help(NIL, NIL, "Help", NIL, "Já existe dados cadastrados com essas informações.", 1, 0,,,,,,{""})
  EndIf


Return (lRet)



