#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cCadastro := "Cadastro de SLA"
//-------------------------------------------------------------------
/*/{Protheus.doc} ZZAMVC01
@author Filipe Vieira
@since 27/10/2018 
@version 
/*/
//-------------------------------------------------------------------
User Function ZZBMVC01()

	Local aArea  := GetArea()
	Local oBrw := FwMBrowse():New()
	oBrw:SetDescription(cCadastro) 
	oBrw:SetAlias("ZZB")
	oBrw:Activate()
	RestArea(aArea)

Return MenuDef()

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
@author Filipe Vieira 
@since 27/10/2018 
@version 
/*/
//----------------------------------------------------------
Static Function MenuDef()

   // 1 opção
	//Local oMenu := FWMVCMenu( "ZZBMVC01" )
	
	// 2 opção
	Local aRot := {}	
	//Adicionando opções
	ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.ZAZDMVC3' OPERATION 2 ACCESS 0 //OPERATION 2 - MODEL_OPERATION_VIEW	
	ADD OPTION aRot Title 'Incluir'    Action 'VIEWDEF.ZAZDMVC3' OPERATION 3 ACCESS 0 //OPERATION 3 - MODEL_OPERATION_INSERT 
	ADD OPTION aRot Title 'Alterar'    Action 'VIEWDEF.ZAZDMVC3' OPERATION 4 ACCESS 0 //OPERATION 4 - MODEL_OPERATION_UPDATE		
	ADD OPTION aRot Title 'Excluir'    Action 'VIEWDEF.ZAZDMVC3' OPERATION 5 ACCESS 0 //OPERATION 5 - MODEL_OPERATION_DELETE (OUTRAS AÇOES)
	
 
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

	Local oStruZZB  := FwFormStruct(1,"ZZB")// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel := MPFormModel():New("ZZBMVC_M", /*bPreValidacao*/, {|oModel| POSVLDZZB(oModel)},/*bCommit*/,/*bCancel*/ )// Cria o objeto do Modelo de Dados		
	
	oModel:AddFields("ZZBMASTER",/*cOwner*/, oStruZZB)// 01 - Adiciona ao modelo um componente de formulário
	oModel:SetPrimaryKey({'ZZB_FILIAL','ZZB_COD'})// 02 -Setando a chave primária da rotina ou campos do indice
	oModel:SetDescription(cCadastro)// 03 - Adiciona UM nome/descrição do Modelo de Dados 
	oModel:GetModel("ZZBMASTER" ):SetDescription(cCadastro)// 04 Adiciona um nome/descrição do formulário QUE esse nome SERÁ USADO na VIEWDEF()
	
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


	Local oModel   := FwLoadModel("ZZBMVC01")// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado (nome do arquivo)
	Local oStruZZB := FwFormStruct(2,"ZZB") // Cria a estrutura a ser usada na View
	Local oView // Interface de visualização construída
	
	oView := FWFormView():New() // Cria o objeto de View
	oView:SetModel(oModel)// Define qual o Modelo de dados será utilizado na View
	oView:AddField("VIEW_ZZB",oStruZZB,"ZZBMASTER") // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice) 
	oView:CreateHorizontalBox("TELA",100) // Criar um "box" horizontal para receber algum elemento da view
	oView:SetOwnerView( 'VIEW_ZZB', 'TELA' )// Relaciona o identificador (ID) da View com o "box" para exibição 

// Retorna o objeto de View criado
Return(oView)



Static Function POSVLDZZB(oModel)
	Local oModZZB := oModel:GetModel("ZZBMASTER")
	Local lRet    := .T.

	If(Empty(oModZZB:GetValue("ZZB_DESC")))
		lRet := .F.
		Help(,,"POSVLDZZB","xx","Favor preencher o nome da SLA.",1,0)
	EndIf

Return ()

