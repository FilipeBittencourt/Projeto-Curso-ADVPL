//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Contatos da empresa"
User Function CONTATO()	   

	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()
	
	SetFunName("CONTATO")
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZXV")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "ZXV->ZXV_STATUS == '1'", "GREEN",	"Ativo" )
	oBrowse:AddLegend( "ZXV->ZXV_STATUS == '2'", "RED",	"Bloqueado" )
	
	//Filtrando LOGO QUANDO ABRE A TELA
	//oBrowse:SetFilterDefault("ZXV->ZXV_COD >= '000000' .And. ZXV->ZXV_COD <= 'ZZZZZZ'")
	
	//Ativa a Browse
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)


/*
	Local aArea       := GetArea() 
	Local oBrowse     := nil
	private aRotina   := fMenuDef()
	private cCadastro := "Contatos" 	
   

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZXV')
	oBrowse:SetDescription(cCadastro)
	oBrowse:AddLegend("ZXV_STATUS = 'N'", "GREEN", "Novo") 
	oBrowse:AddLegend("ZXV_STATUS = 'A'", "RED"  , "Aprovado")
	oBrowse:Activate() 
	RestArea(aArea)*/
Return 

//menu
Static Function MenuDef()
	local aRotina := {}	
	//Adicionando opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CONTATO' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1	
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CONTATO' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CONTATO' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CONTATO' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRotina TITLE 'Legenda'    ACTION 'U_CONTALEG'      OPERATION 6                      ACCESS 0 //OPERATION X	
return aRotina


Static Function ModelDef()

	//Blocos de código nas validações
	//Local bPre := {|| u_zM1bPre()} //Antes de abrir a Tela
	//Local bPos := {|| u_zM1bPos()} //Validação ao clicar no Confirmar
	//Local bCom := {|| u_zM1bCom()} //Função chamadao ao commit/salvar
	//Local bCan := {|| u_zM1bCan()} //Função chamadao ao cancelar

	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZXV := FWFormStruct(1, "ZXV")
	
	//Editando características do dicionário
	oStZXV:SetProperty('ZXV_ID',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	oStZXV:SetProperty('ZXV_ID',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZXV", "ZXV_ID")'))          //Ini Padrão
	//oStZXV:SetProperty('ZXV_NOME', MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZXV_NOME), .F., .T.)'))  //Validação de Campo
	
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	//oModel := MPFormModel():New("MODCONTAT",/*bPre*/, /*u_zM1bPos*/, /*bCom*/, /*bCan*/) 
	 oModel := MPFormModel():New('MODCONTAT', { |oModel| CONCA01AAA(oModel)} , { |oModel| CONCA01VLD(oModel)})
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZXV",/*cOwner*/,oStZXV)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZXV_FILIAL','ZXV_ID'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZXV"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel 



Static Function ViewDef()
	Local aStruZXV	:= ZXV->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro
	Local oModel := FWLoadModel("CONTATO")
	
	// o 2 É PARA VISUALIZAR NA VIEWDEF
	//Criação da estrutura de dados utilizada na interface
	Local oStZXV := FWFormStruct(2, "ZXV")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZXV_NOME|ZXV_CPF|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZXV", oStZXV, "FORMZXV")  //ESSE FORMZXV é da função  ModelDef ***PRECISA SER IGUAL***
	
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


User Function CONTALEG()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Ativo"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Bloqueado"})
	
	BrwLegenda(cTitulo, "Status", aLegenda)
Return





//----------------------------------------
//Validações das ações da enchoice (crud)
//----------------------------------------


Static Function CONCA01AAA(oModel)
	Local aArea      := GetArea()		
	Local nOpc       := oModel:GetOperation()
	Local lRet       := .T.
	
	//ALERT("ENTROU NO PRE")
 
 	RestArea(aArea)
Return lRet


Static Function CONCA01VLD(oModel)   
	Local aArea      := GetArea()		
	Local nOpc       := oModel:GetOperation()
	Local lRet       := .T.
		 
	ALERT(oModel:GetValue('FORMZXV','ZXV_NOME'))
	 
	If (Empty(oModel:GetValue('FORMZXV','ZXV_NOME')) .Or. Alltrim(Upper(oModel:GetValue('FORMZXV','ZXV_NOME'))) == "")
		ALERT("aQUI") 
	EndIf
	
	//Se for Inclusão		
	/*If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE 		 	
		If Alltrim(Upper(Empty(oModel:GetValue('FORMZXV','ZXV_NOME'))))
			lRet := .F.
			Aviso('Atenção', 'Campo nome esta em branco!', {'OK'}, 03)
		Else
			Aviso('Atenção', 'Operação realizada com sucesso!', {'OK'}, 03)
			//ConfirmSX8() //Confirma a utilzação da sequencia numerica definida
		EndIf
	EndIf*/
	RestArea(aArea)
	
Return lRet



 




 