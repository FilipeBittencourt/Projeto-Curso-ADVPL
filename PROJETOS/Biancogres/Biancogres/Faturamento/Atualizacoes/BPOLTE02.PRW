#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BPOLTE02	ºAutor  ³Fernando Rocha      º Data ³ 20/07/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interface MVC para cadastro da tabela ZA2				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BPOLTE02()
/*Declarando as variáveis que serão utilizadas*/
Local lRet := .T.
Local aArea := ZA2->(GetArea())
Private oBrowse
Private cTitle := "Tipos de Descontos Política Comercial"

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()

//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("ZA2")          

//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription(cTitle)

//Desliga a exibição dos detalhes
oBrowse:DisableDetails()         

//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)
Return
//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.BPOLTE02" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.BPOLTE02" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.BPOLTE02" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.BPOLTE02" OPERATION 5 ACCESS 0
Return aRotina


Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZA2')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('Formulario' , oStr1, 'CamposZA2')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('Formulario','PAI')
oView:EnableTitleView('Formulario' , cTitle )
oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return oView


Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct( 1, 'ZA2', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

//Cria o objeto do Modelo de Dados
//Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
oModel:SetDescription(cTitle)

oStr1:RemoveField( 'ZA2_FILIAL' )                       

//setar campos nao alteraveis
oStr1:SetProperty("ZA2_COD"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:addFields('CamposZA2',,oStr1,{|oModel|MVC001T(oModel)},,)

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'ZA2_FILIAL', 'ZA2_COD'})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:getModel('CamposZA2'):SetDescription('CamposZA2')

Return oModel

//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function MVC001T( oModel )
Local lRet      := .T.

Return(lRet)

//-------------------------------------------------------------------
// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function MVC001V( oModel )
Local lRet      := .T.
Local oModel	:= oModel:GetModel( 'CamposZA2' )
Local nOpc      := oModel:GetOperation()
Local aArea     := GetArea()

//Capturar o conteudo dos campos
Local cChave	:= oModel:GetValue('ZA2_COD')

if nOpc == 3
	
	dbSelectArea("ZA2")
	ZA2->(dbSetOrder(1))
	If(ZA2->(dbSeek(xFilial("ZA2")+cChave)))
		SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","BPOLTE02")
		lRet := .F.
	Endif
	
Endif

RestArea(aArea)

Return lRet      


Static Function MVC001C( oModel )

FWFormCommit( oModel )

Return .T.
