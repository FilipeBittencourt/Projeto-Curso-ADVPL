#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BPOLTE04
@description Interface MVC para cadastro da tabela ZA3
@author Fernando Rocha
@since 20/07/2015
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function BPOLTE04()

/*Declarando as vari�veis que ser�o utilizadas*/
Local lRet := .T.
Local aArea := ZA3->(GetArea())
Private oBrowse
Private cTitle := "Solicitacao de Verba para Pol�tica Comercial"

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()

//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("ZA3")          

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
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.BPOLTE04" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.BPOLTE04" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.BPOLTE04" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.BPOLTE04" OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Aprovar"    	ACTION "U_BPTE04AP()" OPERATION 6 ACCESS 0
Return aRotina


Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZA3')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('Formulario' , oStr1, 'CamposZA3')

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
Local oStr1:= FWFormStruct( 1, 'ZA3', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

//Cria o objeto do Modelo de Dados
//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
oModel:SetDescription(cTitle)

oStr1:RemoveField( 'ZA3_FILIAL' )                       

//setar campos nao alteraveis
oStr1:SetProperty("ZA3_COD"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })


oStr1:AddTrigger("ZA3_GCLI", "ZA3_DGCLI"	, {|| .T.}, {|a| GetDescr(a, 1) })
oStr1:AddTrigger("ZA3_LOJCLI", "ZA3_NOMCLI"	, {|| .T.}, {|a| GetDescr(a, 2) })
oStr1:AddTrigger("ZA3_REDE", "ZA3_DREDE"	, {|| .T.}, {|a| GetDescr(a, 3) })


// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:addFields('CamposZA3',,oStr1,{|oModel|MVC001T(oModel)},,)

	

//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'ZA3_FILIAL', 'ZA3_COD'})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:getModel('CamposZA3'):SetDescription('CamposZA3')

Return oModel


Static Function GetDescr(oModel, cOpcao)
	Local _cDes		:= ""
	Local _cCod		:= "" 
	Local _cLoja	:= ""	
	
	If (cOpcao == 1)
		_cCod := oModel:GetValue("ZA3_GCLI")
		_cDes := POSICIONE("ACY",1,XFILIAL("ACY")+_cCod,"ACY_DESCRI")
		
	ElseIf(cOpcao == 2)
		_cCod 	:= oModel:GetValue("ZA3_CODCLI")
		_cLoja	:= oModel:GetValue("ZA3_LOJCLI")
		_cDes := POSICIONE("SA1",1,XFILIAL("SA1")+_cCod+_cLoja,"A1_NOME")
	ElseIf(cOpcao == 3)
		_cCod := oModel:GetValue("ZA3_REDE")
		_cDes := POSICIONE("Z79",1,XFILIAL("Z79")+_cCod,"Z79_DESCR")
	EndIf

Return(_cDes)

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
Local oModel	:= oModel:GetModel( 'CamposZA3' )
Local nOpc      := oModel:GetOperation()
Local aArea     := GetArea()

//Capturar o conteudo dos campos
Local cChave	:= oModel:GetValue('ZA3_COD')

if nOpc == 3
	
	
Endif

RestArea(aArea)

Return lRet      


Static Function MVC001C( oModel )
Local nOpc      := oModel:GetOperation()

FWFormCommit( oModel ) 

If (nOpc == 3)
	
	RecLock("ZA3",.F.)
	ZA3->ZA3_CADUSU := cUserName
	ZA3->ZA3_CADDAT := dDataBase
	ZA3->ZA3_CADHOR := SubStr(Time(),1,5)
	ZA3->(MsUnlock())	
	
EndIf

Return .T.   
            
//Aprovacao 
User Function BPTE04AP()

If !MsgNoYes("Tem certeza que deseja aprovar a Solicita��o de Verba?","BPOLTE04 - Aprovar")
	Return
EndIf   

RecLock("ZA3",.F.)
ZA3->ZA3_STATUS := "A"
ZA3->(MsUnlock())

Return
