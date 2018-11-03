//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Composição de CDs"

/*/{Protheus.doc} zModel3
Função para cadastro de Composição de CDs (Exemplo de Modelo 3 - WW2 x WW3)
@author Atilio
@since 03/09/2016
@version 1.0
	@return Nil, Função não tem retorno
	@example
	u_zModel3()
/*/

User Function zModel3()
	Local aArea   := GetArea()
	Local oBrowse
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de CDs
	oBrowse:SetAlias("WW2")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'WW2')
	Local oStFilho 	:= FWFormStruct(1, 'WW3')
	Local aWW3Rel		:= {}
	
	//Definições dos campos
	oStPai:SetProperty('WW2_CODCD',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStPai:SetProperty('WW2_CODCD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("WW2", "WW2_CODCD")'))       //Ini Padrão
	oStPai:SetProperty('WW2_CODART',   MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'ExistCpo("ZZ1", M->WW2_CODART)'))      //Validação de Campo
	oStFilho:SetProperty('WW3_CODCD',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStFilho:SetProperty('WW3_CODCD',  MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigatório
	oStFilho:SetProperty('WW3_CODART', MODEL_FIELD_OBRIGAT, .F. )                                                                          //Campo Obrigatório
	oStFilho:SetProperty('WW3_CODMUS', MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'u_zIniMus()'))                         //Ini Padrão
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('zModel3M')
	oModel:AddFields('WW2MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('WW3DETAIL','WW2MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aWW3Rel, {'WW3_FILIAL','WW2_FILIAL'} )
	aAdd(aWW3Rel, {'WW3_CODCD',	'WW2_CODCD'})
	aAdd(aWW3Rel, {'WW3_CODART','WW2_CODART'}) 
	
	oModel:SetRelation('WW3DETAIL', aWW3Rel, WW3->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('WW3DETAIL'):SetUniqueLine({"WW3_DESC"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Grupo de Produtos - Mod. 3")
	oModel:GetModel('WW2MASTER'):SetDescription('Cadastro')
	oModel:GetModel('WW3DETAIL'):SetDescription('CDs')
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  03/09/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('zModel3')
	Local oStPai		:= FWFormStruct(2, 'WW2')
	Local oStFilho	:= FWFormStruct(2, 'WW3')
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_WW2',oStPai,'WW2MASTER')
	oView:AddGrid('VIEW_WW3',oStFilho,'WW3DETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_WW2','CABEC')
	oView:SetOwnerView('VIEW_WW3','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_WW2','Cabeçalho - Cadastro')
	oView:EnableTitleView('VIEW_WW3','Grid - CDs')
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//Remove os campos de Código do Artista e CD
	oStFilho:RemoveField('WW3_CODART')
	oStFilho:RemoveField('WW3_CODCD')
Return oView

/*/{Protheus.doc} zIniMus
Função que inicia o código sequencial da grid
@type function
@author Atilio
@since 03/09/2016
@version 1.0
/*/

User Function zIniMus()
	Local aArea := GetArea()
	Local cCod  := StrTran(Space(TamSX3('WW3_CODMUS')[1]), ' ', '0')
	Local oModelPad  := FWModelActive()
	Local oModelGrid := oModelPad:GetModel('WW3DETAIL')
	Local nOperacao  := oModelPad:nOperation
	Local nLinAtu    := oModelGrid:nLine
	Local nPosCod    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("WW3_CODMUS")})
	
	//Se for a primeira linha
	If nLinAtu < 1
		cCod := Soma1(cCod)
	
	//Senão, pega o valor da última linha
	Else
		cCod := oModelGrid:aCols[nLinAtu][nPosCod]
		cCod := Soma1(cCod)
	EndIf
	
	RestArea(aArea)
Return cCod