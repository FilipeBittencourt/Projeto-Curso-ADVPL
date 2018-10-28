#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cCadastro := "Cadastro de chamados"
//-------------------------------------------------------------------
/*/{Protheus.doc} ZZDMVC01
@author Filipe Vieira
@since 27/10/2018 
@version 
/*/
//-------------------------------------------------------------------
User Function ZZDMVC01()

	Local aArea  := GetArea()
	Local oBrw := FWMBrowse():New()
	oBrw:SetDescription(cCadastro) 
	oBrw:SetAlias("ZZD")	
	
	oBrw:AddLegend( "ZZD->ZZD_STATUS == '1 ' ", "GREEN"  , "Aberto" )
	oBrw:AddLegend( "ZZD->ZZD_STATUS == '2 ' ", "BLUE"   , "Em Atendimento" ) 
	oBrw:AddLegend( "ZZD->ZZD_STATUS == '3 ' ", "YELLOW" , "Aguardando") 
	oBrw:AddLegend( "ZZD->ZZD_STATUS == '4 ' ", "BLACK"  , "Encerrado" ) 
	oBrw:AddLegend( "ZZD->ZZD_STATUS == '5 ' ", "RED"    , "Em Atraso" )	
	
	
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
	//Local oMenu := FWMVCMenu( "ZZDMVC01" )
	
	// 2 opção
	Local aRot := {}	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMod1Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel1' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	
 
Return aRot

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

	Local oStruZZD  := FwFormStruct(1,"ZZD")// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel := MPFormModel():New("ZZDMVC_M")// Cria o objeto do Modelo de Dados		
	
	oModel:AddFields("ZZDMASTER",/*cOwner*/, oStruZZD)// 01 - Adiciona ao modelo um componente de formulário
	oModel:SetPrimaryKey({'ZZD_FILIAL','ZZD_COD'})// 02 -Setando a chave primária da rotina ou campos do indice
	oModel:SetDescription(cCadastro)// 03 - Adiciona UM nome/descrição do Modelo de Dados 
	oModel:GetModel("ZZDMASTER" ):SetDescription(cCadastro)// 04 Adiciona um nome/descrição do formulário QUE esse nome SERÁ USADO na VIEWDEF()
	
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


	Local oModel   := FwLoadModel("ZZDMVC01")// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado (nome do arquivo)
	Local oStruZZD := FwFormStruct(2,"ZZD") // Cria a estrutura a ser usada na View
	Local oView // Interface de visualização construída
	
	oView := FWFormView():New() // Cria o objeto de View
	oView:SetModel(oModel)// Define qual o Modelo de dados será utilizado na View
	oView:AddField("VIEW_ZZD",oStruZZD,"ZZDMASTER") // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice) 
	oView:CreateHorizontalBox("TELA",100) // Criar um "box" horizontal para receber algum elemento da view
	oView:SetOwnerView( 'VIEW_ZZD', 'TELA' )// Relaciona o identificador (ID) da View com o "box" para exibição 

// Retorna o objeto de View criado
Return(oView)

