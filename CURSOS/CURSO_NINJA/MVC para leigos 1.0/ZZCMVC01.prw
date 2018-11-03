#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cCadastro := "Cadastro de tipo de chamados"
//-------------------------------------------------------------------
/*/{Protheus.doc} ZZCMVC01
@author Filipe Vieira
@since 27/10/2018 
@version 
/*/
//-------------------------------------------------------------------
User Function ZZCMVC01()

	Local aArea  := GetArea()
	Local oBrw := FwMBrowse():New()
	oBrw:SetDescription(cCadastro) 
	oBrw:SetAlias("ZZC")
	oBrw:Activate()
	RestArea(aArea)

Return()

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
@author Filipe Vieira 
@since 27/10/2018 
@version 
/*/
//----------------------------------------------------------
Static Function MenuDef()

   // 1 opção
	Local oMenu := FWMVCMenu( "ZZCMVC01" )
	
	// 2 opção
	/*Local aRot := {}	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMod1Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	*/
 
Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model
@return oModel - Objeto do Modelo MVC
@author Filipe Vieira
@since 27/10/2018 
@version 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruZZC  := FwFormStruct(1,"ZZC")// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel := MPFormModel():New("ZZCMVC_M")// Cria o objeto do Modelo de Dados		
	
	oModel:AddFields("ZZCMASTER",/*cOwner*/, oStruZZC)// 01 - Adiciona ao modelo um componente de formulário
	oModel:SetPrimaryKey({'ZZC_FILIAL','ZZC_COD'})// 02 -Setando a chave primária da rotina ou campos do indice
	oModel:SetDescription(cCadastro)// 03 - Adiciona UM nome/descrição do Modelo de Dados 
	oModel:GetModel("ZZCMASTER" ):SetDescription(cCadastro)// 04 Adiciona um nome/descrição do formulário QUE esse nome SERÁ USADO na VIEWDEF()
	
	// Retorna o Modelo de dados 
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Filipe Vieira 
@since 27/10/2018 
@version 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()


	Local oModel   := FwLoadModel("ZZCMVC01")// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado (nome do arquivo)
	Local oStruZZC := FwFormStruct(2,"ZZC") // Cria a estrutura a ser usada na View
	Local oView // Interface de visualização construída
	
	oView := FWFormView():New() // Cria o objeto de View
	oView:SetModel(oModel)// Define qual o Modelo de dados será utilizado na View
	oView:AddField("VIEW_ZZC",oStruZZC,"ZZCMASTER") // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice) 
	oView:CreateHorizontalBox("TELA",100) // Criar um "box" horizontal para receber algum elemento da view
	oView:SetOwnerView( 'VIEW_ZZC', 'TELA' )// Relaciona o identificador (ID) da View com o "box" para exibição 

// Retorna o objeto de View criado
Return(oView)

