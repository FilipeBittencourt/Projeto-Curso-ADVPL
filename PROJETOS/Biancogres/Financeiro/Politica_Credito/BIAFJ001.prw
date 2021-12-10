#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIAFJ001()
//Verifica a situação do CPF, idenpendente do CNPJ que esteja vinculado
@author Wellington Coelho - Facile
@type function
@since 23/09/2021
@version 1.0
@obs Rotina especifica para a BIANCOGRES
@return Nil
/*/
//-------------------------------------------------------------------
User Function BIAFJ001()

Local oBrowse

Local bMenuDef    := {|| MenuDef() }	//Apenas para nao entrar em Warning de Compilacao
Local bModelDef   := {|| ModelDef() }	//Apenas para nao entrar em Warning de Compilacao
Local bViewDef    := {|| ViewDef() }	//Apenas para nao entrar em Warning de Compilacao

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'ZRY' )
oBrowse:SetDescription( 'Cadastro de CNPJs bloqueados' )

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional
@author Wellington Coelho - Facile
@type function
@since 23/09/2021
@version 1.0
@obs Rotina especifica para a BIANCOGRES
@return Nil
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.BIAFJ001' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.BIAFJ001' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.BIAFJ001' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.BIAFJ001' OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados do Cadastro
@author Wellington Coelho - Facile
@type function
@since 23/09/2021
@version 1.0
@obs Rotina especifica para a BIANCOGRES
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZRY := FWFormStruct( 1, 'ZRY', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruZRZ := FWFormStruct( 1, 'ZRZ', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'BIAFJ00M', /*bPreValidacao*/, /*{ |oModel| BIAFJ001PVal( oModel ) }*//*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
                                                                                       	
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZRYMASTER', /*cOwner*/, oStruZRY )

// Adiciona ao modelo um grid
oModel:AddGrid( 'ZRZDETAIL', 'ZRYMASTER' /*cOwner*/, oStruZRZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Cadastro de CPFs bloqueados' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZRYMASTER' ):SetDescription( 'Cadastro do CNPJ' )
oModel:GetModel( 'ZRZDETAIL' ):SetDescription( 'Cadastro do CPFs dos Socios' )

// Cria relacionamento entre as tabelas
oModel:SetRelation( "ZRZDETAIL", { { "ZRZ_FILIAL", "XFILIAL('ZRZ')" }, { "ZRZ_CNPJ" , "ZRY_CNPJ" } }, ZRZ->( IndexKey( 1 ) ) )

// Seta chave primaria
oModel:SetPrimaryKey( { "ZRY_FILIAL", "ZRY_CNPJ" } )

// Seta Linha Unica
oModel:GetModel( 'ZRZDETAIL' ):SetUniqueLine( { 'ZRZ_CPF' } )

// Seta os itens como opcional
//oModel:GetModel( 'ZRZDETAIL' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View de dados do Cadastro
@author Wellington Coelho - Facile
@type function
@since 23/09/2021
@version 1.0
@obs Rotina especifica para a BIANCOGRES
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruZRY := FWFormStruct( 2, 'ZRY' ) 
Local oStruZRZ := FWFormStruct( 2, 'ZRZ' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'BIAFJ001' )
Local oView

oStruZRZ:RemoveField( "ZRZ_CNPJ" )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZRY', oStruZRY, 'ZRYMASTER' )
oView:AddGrid(  'VIEW_ZRZ', oStruZRZ, 'ZRZDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 70 )
oView:CreateHorizontalBox( 'INFERIOR', 30 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZRY', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZRZ', 'INFERIOR' )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_ZRY','Cadastro do CNPJ')
oView:EnableTitleView('VIEW_ZRZ','Cadastro do CPFs dos Socios')

// Campo Incremental
//oView:AddIncrementField( 'VIEW_ZRY', 'ZRY_ORDEM' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BIAFJ001PVal()
Validação
@author Wellington Coelho - Facile
@type function
@since 23/09/2021
@version 1.0
@obs Rotina especifica para a BIANCOGRES
@return Nil
/*/
//-------------------------------------------------------------------
/*
Static Function BIAFJ001PVal( oModel )

Local aAreaAtu   := GetArea()
Local lRetFun    := .T.
Local nCntFor    := 0
Local oModelZRZ  := oModel:GetModel( "ZRYMASTER" )
Local nOperation := oModel:GetOperation()
Local cQuery	 := ""

If nOperation == 5

EndIf

RestArea( aAreaAtu ) 

Return lRetFun
*/
