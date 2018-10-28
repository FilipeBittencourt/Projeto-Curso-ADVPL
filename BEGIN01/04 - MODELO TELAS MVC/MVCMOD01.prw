#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#include "fwmvcdef.ch"

// https://www.youtube.com/watch?v=R3yjwYMkAhA        - AdvPL 017 - MVC
// https://www.youtube.com/watch?v=03fZSQpR3Rs&t=42s  - AdvPL 018 - Modelo 1 em MVC
// https://www.youtube.com/watch?v=iG1WClMfMiQ        - AdvPL 019 - Validações em MVC


//Variáveis Estáticas
Static cTitulo := "test"

User Function MVCMOD01()

	Local oBrowse
	Local aArea := GetAera()
	Local cFunBkp := FunName()
	
	SetFunName("MVCMOD01")
	
	oBrowse := FWMBrowse():New() // Fornece um objeto do tipo grid, botões laterais e detalhes das colunas baseado no dicionário de dados
	oBrowse:SetAlias('ZXV') // SELECINA A TABELA QUE IRÁ SER EXIBIDA
	oBrowse:SetDescription(cTitulo) // NOME DO TITULO Que aparece no topo
	
	
	oBrowse:AddLegend("ZXV->ZXV_STATUS == 'A'" ,"GREEN","Ativo")
	oBrowse:AddLegend("ZXV->ZXV_STATUS == 'B'" ,"RED","Bloqueado")
	oBrowse:AddLegend("ZXV->ZXV_STATUS != 'B' .Or. ZXV->ZXV_STATUS != 'A'" ,"BLACK","XXX")			
	oBrowse:Activate() // ativa  a função para aparecer
	
	SetFunName(cFunBkp)
	RestArea(aArea)
	
Return Nil


//------------------------------
//Definição do menu da rotina
//------------------------------
Static Function MenuDef()
	
	Local aRotina := {}	
	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.MVCMOD01' OPERATION 1 ACCESS 0
	//ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.MVCMOD01' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.MVCMOD01' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.MVCMOD01' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.MVCMOD01' OPERATION 5 ACCESS 0	
	ADD OPTION aRotina Title 'Legenda'    Action 'U_MVC01LEG' OPERATION 6 ACCESS 0                                                                                             

Return(aRotina)



//------------------------------
//Definição do modelo de dados
//------------------------------
Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZXV := FWFormStruct(1, "ZXV")
	
	//Editando características do dicionário
	oStZXV:SetProperty('ZXV_ID',   MODEL_FIELD_WHEN,  FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.')) //Modo de Edição
	oStZXV:SetProperty('ZXV_ID',   MODEL_FIELD_INIT,  FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZXV", "ZXV_ID")'))         //Ini Padrão
	//oStZXV:SetProperty('ZXV_CPF',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZXV_DESC), .F., .T.)'))   //Validação de Campo
	//oStZXV:SetProperty('ZXV_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zModel1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZXV",/*cOwner*/,oStZXV)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZXV_FILIAL'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZXV"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel


Static Function ViewDef()
	Local aStruZXV	:= ZXV->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("MVCMOD01")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZXV := FWFormStruct(2, "ZXV")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZXV_NOME|SZXV_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZXV", oStZXV, "FORMZXV")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_ZXV', 'Dados - '+cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZXV","TELA")
	
	/*
	//Tratativa para remover campos da visualização
	For nAtual := 1 To Len(aStruZXV)
		cCampoAux := Alltrim(aStruZXV[nAtual][01])
		
		//Se o campo atual não estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZXV_COD;"
			oStZXV:RemoveField(cCampoAux)
		EndIf
	Next
	*/
Return oView


User Function U_MVC01LEG()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Ativo"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Bloqueado"})
	AADD(aLegenda,{"BR_PRETO",	"INDEFINIDO"})
	
	BrwLegenda(cTitulo, "Status", aLegenda)
Return



