#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BPOLTE01	�Autor  �Fernando Rocha      � Data � 20/07/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Interface MVC para cadastro da tabela ZA1				  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES 												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BPOLTE01()
/*Declarando as vari�veis que ser�o utilizadas*/
Local lRet := .T.
Local aArea := ZA1->(GetArea())
Private oBrowse
Private cTitle := "Tipos de Descontos Pol�tica Comercial"

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()

//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("ZA1")          

//Definimos o t�tulo que ser� exibido como m�todo SetDescription
oBrowse:SetDescription(cTitle)

//Desliga a exibi��o dos detalhes
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
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.BPOLTE01" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.BPOLTE01" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.BPOLTE01" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.BPOLTE01" OPERATION 5 ACCESS 0
Return aRotina


Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZA1')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('Formulario' , oStr1, 'CamposZA1')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('Formulario','PAI')
oView:EnableTitleView('Formulario' , cTitle )
oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})

Return oView


Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct( 1, 'ZA1', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

//Cria o objeto do Modelo de Dados
//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
oModel:SetDescription(cTitle)

oStr1:RemoveField( 'ZA1_FILIAL' )                       

//setar campos nao alteraveis
oStr1:SetProperty("ZA1_COD"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:addFields('CamposZA1',,oStr1,{|oModel|MVC001T(oModel)},,)

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'ZA1_FILIAL', 'ZA1_COD'})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:getModel('CamposZA1'):SetDescription('CamposZA1')

Return oModel

//Esta fun��o ser� executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa vari�vel o conteudo de um campo
Static Function MVC001T( oModel )
Local lRet      := .T.

Return(lRet)

//-------------------------------------------------------------------
// Valida��es ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou n�o
//-------------------------------------------------------------------
Static Function MVC001V( oModel )
Local lRet      := .T.
Local oModel	:= oModel:GetModel( 'CamposZA1' )
Local nOpc      := oModel:GetOperation()
Local aArea     := GetArea()

//Capturar o conteudo dos campos
Local cChave	:= oModel:GetValue('ZA1_COD')

if nOpc == 3
	
	dbSelectArea("ZA1")
	ZA1->(dbSetOrder(2))
	If(ZA1->(dbSeek(xFilial("ZA1")+cChave)))
		SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","BPOLTE01")
		lRet := .F.
	Endif
	
Endif

RestArea(aArea)

Return lRet      


Static Function MVC001C( oModel )

FWFormCommit( oModel )

Return .T.
