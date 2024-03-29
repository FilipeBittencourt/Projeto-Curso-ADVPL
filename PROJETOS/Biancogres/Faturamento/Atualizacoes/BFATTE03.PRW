#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BFATTE03
@description Tela para cadastro da tabela "Condicao X Cliente/Grupo/Rede" Z07
@author Fernando Rocha
@since 10/03/2017
@version undefined
@type function
/*/
User Function BFATTE03()
	/*Declarando as vari�veis que ser�o utilizadas*/
	Local lRet := .T.
	Local aArea := Z07->(GetArea())
	Private oBrowse
	Private cTitle := "Condicao X Cliente/Grupo/Rede"

	//Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("Z07")          

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
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.BFATTE03" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.BFATTE03" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.BFATTE03" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.BFATTE03" OPERATION 5 ACCESS 0
Return aRotina


Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'Z07')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'CamposZ07')

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
	Local oStr1:= FWFormStruct( 1, 'Z07', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'Z07_FILIAL' )                       

	oStr1:AddTrigger('Z07_CODENT', 'Z07_NOME', NIL, {||GetNome()})

	//oStr1:SetProperty("Z07_ENT"  , MODEL_FIELD_VALID,{|oModel| U_F3Z07ENT() })

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:addFields('CamposZ07',,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	//Data 23/11/2020: Remo��o do campo Marca por solicita��o do CLaudeir (Ticket 28117).
	oModel:SetPrimaryKey({'Z07_FILIAL', 'Z07_COND'}) 

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposZ07'):SetDescription('CamposZ07')


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
	Local oModel	:= oModel:GetModel( 'CamposZ07' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	//Capturar o conteudo dos campos
	Local cChave	:= oModel:GetValue('Z07_COND')
	//Local cMarca	:= oModel:GetValue('Z07_MARCA')

	if nOpc == 3

		dbSelectArea("Z07")
		Z07->(dbSetOrder(1))
		If(Z07->(dbSeek(xFilial("Z07")+cChave))) //.And. Z07->Z07_MARCA == cMarca
			SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","BFATTE03")
			lRet := .F.
		Endif

	Endif

	RestArea(aArea)

Return lRet      


Static Function MVC001C( oModel )

	FWFormCommit( oModel )

Return .T.


/*/{Protheus.doc} F3Z07ENT
@description Consulta F3 conforme sele��o da Entidade
@author Fernando Rocha
@since 14/03/2017
@version undefined
@type function
/*/
User Function F3Z07ENT

	Local aArea		:= GetArea()
	Local cQuery
	Local oModel 	:= FwModelActive()
	Local cEntid 	:= oModel:getModel('CamposZ07'):getValue("Z07_ENT")
	Local oViewAux 	:= FWViewActive()
	Local oView		:= oViewAux:GetViewStruct('Formulario')
	Local lRet
	Local cRetorno

	Public uCRet1 := Space(8)

	If cEntid == "SA1"
		lRet 		:= ConPad1(,,,"SA1","uCRet1")
		cRetorno 	:= SA1->A1_COD+SA1->A1_LOJA
		cRetNome 	:= SA1->A1_NOME
	ElseIf cEntid == "ACY"
		lRet 		:= ConPad1(,,,"ACY","uCRet1")
		cRetorno 	:= ACY->ACY_GRPVEN
		cRetNome 	:= ACY->ACY_DESCRI
	ElseIf cEntid == "Z79"
		lRet 		:= ConPad1(,,,"Z79","uCRet1")
		cRetorno 	:= Z79->Z79_REDE
		cRetNome 	:= Z79->Z79_DESCR
	EndIF

	If lRet

		uCRet1 := cRetorno
		oModel:getModel('CamposZ07'):SetValue("Z07_CODENT",cRetorno)
		oModel:getModel('CamposZ07'):SetValue("Z07_NOME",cRetNome)

	EndIf

	oViewAux:Refresh()
	RestArea( aArea )
Return .T.


Static Function GetNome()

	Local oModel	:= FwModelActive()
	Local cEntid	:= oModel:getModel('CamposZ07'):getValue("Z07_ENT")
	Local cCodEnt	:= oModel:getModel('CamposZ07'):getValue("Z07_CODENT")
	Local cRetNome	:= Space(30)

	If cEntid == "SA1"
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+cCodEnt))
			cRetNome := Left(Padr(SA1->A1_NOME,30),30)
		EndIf
	ElseIf cEntid == "ACY"
		ACY->(DbSetOrder(1))
		If ACY->(DbSeek(XFilial("ACY")+cCodEnt))
			cRetNome := Left(Padr(ACY->ACY_DESCRI,30),30)
		EndIf
	ElseIf cEntid == "Z79"
		Z79->(DbSetOrder(1))
		If Z79->(DbSeek(XFilial("Z79")+cCodEnt))
			cRetNome := Left(Padr(Z79->Z79_DESCR,30),30)
		EndIf
	EndIF

Return(cRetNome)


/*/{Protheus.doc} Z07CPVLD
@description Validacao do campo C5_CONDPAG no pedido de venda
@author Fernando Rocha
@since 15/03/2017
@version undefined
@type function
/*/
User Function Z07CPVLD()

	Local lRet := .T.
	Local cCliente
	Local cGrupo
	Local cRede
	Local cAliasTmp
	Local cCond
	Local aArea := GetArea()
	
	Local cCliOri, cLojOri
	
	cCliOri := M->C5_CLIENTE
	cLojOri := M->C5_LOJACLI
	
	If AllTrim(M->C5_CLIENTE) == "010064"
	
		cCliOri := M->C5_YCLIORI
		cLojOri := M->C5_YLOJORI
	
	EndIf

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1")+cCliOri+cLojOri))

		cCliente	:= SA1->A1_COD+SA1->A1_LOJA
		cGrupo		:= SA1->A1_GRPVEN
		cRede		:= SA1->A1_YREDCOM

		cCond 		:= M->C5_CONDPAG

		Z07->(DbSetOrder(1))
		If Z07->(DbSeek(XFilial("Z07")+cCond)) //.And. Z07->Z07_MARCA == M->C5_YLINHA

			If 	(Z07->Z07_ENT == "SA1" .And. Z07->Z07_CODENT <> cCliente) .Or.;
				(Z07->Z07_ENT == "ACY" .And. Z07->Z07_CODENT <> cGrupo) .Or.;
				(Z07->Z07_ENT == "Z79" .And. Z07->Z07_CODENT <> cRede)
				
				MsgAlert("Condi��o de Pagamento n�o pode ser usada para este cliente.","ATEN��O - Clientes x Condi��o (BFATTE03)")
				lRet := .F.

			EndIf

		EndIf

	EndIf
	
	RestArea(aArea)

Return(lRet)