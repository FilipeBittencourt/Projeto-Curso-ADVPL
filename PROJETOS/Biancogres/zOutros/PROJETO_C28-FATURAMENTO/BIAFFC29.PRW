//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo  := "Percentual de Venda Galleria"


/*/{Protheus.doc} BIAFFC29
@description Percentual de Venda Galleria
@author FILIPE BITTENCOURT -  FACILE
@since 11/08/2021
@version 1.0
/*/

User Function BIAFFC29()
  Local aArea   := GetArea()
  Local oBrowse
  Local cFunBkp := FunName()

  SetFunName("BIAFFC29")

  //Instânciando FWMBrowse - Somente com dicionário de dados
  oBrowse := FWMBrowse():New()

  //Setando a tabela de cadastro de Autor/Interprete
  oBrowse:SetAlias("ZNB")

  //Setando a descrição da rotina
  oBrowse:SetDescription(cTitulo)

  //Ativa a Browse
  oBrowse:Activate()

  SetFunName(cFunBkp)
  RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Filipe Bittencourt - Facile                                                |
 | Data:  11/08/2021                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BIAFFC29' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1s
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BIAFFC29' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BIAFFC29' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BIAFFC29' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Filipe Bittencourt - Facile                                                |
 | Data:  11/08/2021                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
	//Blocos de código nas validações
	Local bVldPre := {|| u_ZNBbPre()} //Antes de abrir a Tela
	Local bVldPos := {|| u_ZNBbPos()} //Validação ao clicar no Confirmar
	Local bVldCom := {|| u_ZNBbCom()} //Função chamadao ao cancelar
	Local bVldCan := {|| u_ZNBbCan()} //Função chamadao ao cancelar
 
	
	//Criação do objeto do modelo de dados
	Local oModel := Nil
  Local oStZNB := Nil
	
	//Criação da estrutura de dados utilizada na interface
 
  oStZNB := FWFormStruct(1, "ZNB", { |x| AllTrim(x) $ "ZNB_MARCA|ZNB_DTINI|ZNB_DTFIM|ZNB_CLIENT|ZNB_LOJA|ZNB_GRUPO|ZNB_REDE|ZNB_TIPO|ZNB_PERC"})
  
  oModel := MPFormModel():New("BIAC29M", bVldPre, bVldPos, bVldCom, bVldCan) 	

  //Atribuindo formulários para o modelo
  oModel:AddFields("FORMZNB",/*cOwner*/,oStZNB)
 

  //Setando a chave primária da rotina
  oModel:SetPrimaryKey({'ZNB_FILIAL','ZNB_MARCA'})

  //Adicionando descrição ao modelo
  oModel:SetDescription(cTitulo)

  //Setando a descrição do formulário
  //oModel:GetModel("FORMZNB"):SetDescription(cTitulo)

  //Pode ativar?
  oModel:SetVldActive( { | oModel | fAlterar( oModel ) } )
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Filipe Bittencourt - Facile                                                |
 | Data:  11/08/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	Local aStruZNB	:= ZNB->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("BIAFFC29")

	//Criando oView como nulo
	Local oView := Nil

  	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	oStZNB := FWFormStruct(2, "ZNB", { |x| AllTrim(x) $ "ZNB_MARCA|ZNB_DTINI|ZNB_DTFIM|ZNB_CLIENT|ZNB_LOJA|ZNB_GRUPO|ZNB_REDE|ZNB_TIPO|ZNB_PERC"})
	

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZNB", oStZNB, "FORMZNB")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	//oView:EnableTitleView('VIEW_ZNB', 'Dados - '+cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZNB","TELA")
Return oView

/*/{Protheus.doc} ZNBbPre
Função chamada na criação do Modelo de Dados (pré-validação)
@type function
@author Filipe Bittencourt - Facile
@since 11/08/2021
@version 1.0
/*/

User Function ZNBbPre()
  Local oModelPad  := FWModelActive()
  Local lRet       := .T.
  //Local nOpc       := oModelPad:GetOperation()

  oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,   ".T."))
  oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))
  oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".T."))
  oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".T."))

  If !EMPTY(oModelPad:GetModel('FORMZNB'):GetValue('ZNB_CLIENT')) .OR. !EMPTY(oModelPad:GetModel('FORMZNB'):GetValue('ZNB_LOJA'))

    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_GRUPO')   := ""
    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_REDE')   := ""
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))

  ElseIf !EMPTY(oModelPad:GetModel('FORMZNB'):GetValue('ZNB_GRUPO'))

    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_CLIENT') := ""
    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_LOJA')   := ""
    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_REDE')   := ""
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_REDE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))

  ElseIf !EMPTY(oModelPad:GetModel('FORMZNB'):GetValue('ZNB_REDE'))

    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_CLIENT') := ""
    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_LOJA')   := ""
    oModelPad:GetModel('FORMZNB'):GetValue('ZNB_GRUPO')   := ""
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_CLIENT',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    ".F."))
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_LOJA',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))
    oModelPad:GetModel('FORMZNB'):GetStruct():SetProperty('ZNB_GRUPO',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,     ".F."))


  EndIf

  //FwAlertInfo('pré-validação','Info')
Return lRet

/*/{Protheus.doc} ZNBbPos
Função chamada no clique do botão Ok do Modelo de Dados (pós-validação)
@type function
@author Filipe Bittencourt - Facile
@since 11/08/2021
@version 1.0
/*/

User Function ZNBbPos()
  Local oModelPad  := FWModelActive()
  Local lRet       := .T.
  /*Local cDescri    := oModelPad:GetValue('FORMZNB', 'ZNB_DESC')
  

  //Se a descrição estiver em branco
  If Empty(cDescri) .Or. Alltrim(Upper(cDescri)) == cDefault
    lRet := .F.
    Aviso('Atenção', 'Campo Descrição esta em branco!', {'OK'}, 03)
  EndIf*/
 
    FwAlertInfo('pós-validação"','Info')
Return lRet

/*/{Protheus.doc} ZNBbCom
Função chamada após validar o ok da rotina para os dados serem salvos
@type function
@author Filipe Bittencourt - Facile
@since 11/08/2021
@version 1.0
/*/
User Function ZNBbCom()
  Local oModelPad  := FWModelActive()
  Local nOpc       := oModelPad:GetOperation()
  Local lRet       := .T.
  Local lAcao      := .F. //update

  If !MODEL_OPERATION_DELETE

    If nOpc == MODEL_OPERATION_INSERT
      lAcao := .T. //insert
    EndIf

    RecLock('ZNB', lAcao)
    ZNB_FILIAL := ''
    ZNB_MARCA  := oModelPad:GetValue('FORMZNB', 'ZNB_MARCA')
    ZNB_DTINI  := oModelPad:GetValue('FORMZNB', 'ZNB_DTINI')
    ZNB_DTFIM  := oModelPad:GetValue('FORMZNB', 'ZNB_DTFIM')
    ZNB_CLIENT := oModelPad:GetValue('FORMZNB', 'ZNB_CLIENT')
    ZNB_LOJA   := oModelPad:GetValue('FORMZNB', 'ZNB_LOJA')
    ZNB_GRUPO  := oModelPad:GetValue('FORMZNB', 'ZNB_GRUPO')
    ZNB_REDE   := oModelPad:GetValue('FORMZNB', 'ZNB_REDE')
    ZNB_TIPO   := oModelPad:GetValue('FORMZNB', 'ZNB_TIPO')
    ZNB_PERC   := oModelPad:GetValue('FORMZNB', 'ZNB_PERC')
    ZNB->(MsUnlock())

  Else

    RecLock('ZNB', .F.)
    DbDelete()
    ZNB->(MsUnlock())

  EndIf

Return lRet

/*/{Protheus.doc} ZNBbCan
Função chamada ao cancelar as informações do Modelo de Dados (botão Cancelar)
@type function
@author Filipe Bittencourt - Facile
@since 11/08/2021
@version 1.0
/*/

User Function ZNBbCan()
  Local oModelPad  := FWModelActive()
  Local lRet       := .T.

  //Somente permite cancelar se o usuário confirmar
  lRet := MsgYesNo("Deseja cancelar a operação?", "Atenção")
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fAlterar                                                     |
 | Autor: Filipe Bittencourt - Facile                                                |
 | Data:  11/08/2021                                                   |
 | Desc:  Define se pode abrir o Modelo de Dados                       |
 *---------------------------------------------------------------------*/

Static Function fAlterar( oModel )
	Local lRet       := .T.
	Local nOperation := oModel:GetOperation()
/*
	//Se for exclusão
  If nOperation == MODEL_OPERATION_DELETE
		//Se não for o Administrador
    If RetCodUsr() != '000000'
			lRet := .F.
			Aviso('Atenção', 'Somente o Administrador pode excluir registros!', {'OK'}, 03)
    EndIf
  EndIf*/

 
  FwAlertInfo('Alterar','Info')
 
Return lRet


User function ViewC29()
 
 local lRet := .T.

  If !EMPTY(M->ZNB_CLIENT) .OR. !EMPTY(M->ZNB_CLIENT)
      lRet := .F.
  ElseIf !EMPTY(M->ZNB_GRUPO)
    lRet := .F.
  ElseIf !EMPTY(M->ZNB_REDE)
    lRet := .F.
  EndIf

Return lRet
