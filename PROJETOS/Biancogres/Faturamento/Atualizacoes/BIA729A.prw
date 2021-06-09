//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} BIA729A
@description Tela para cadastro da tabela ZDL, Metas da LOISTICA
@author  Filipe - Facile
@since 07/06/2021
@version 1.0
@type function
@Anotations: O fonte é chamado pelo BIA729
/*/

User Function BIA729A(cTPDash,cTPNome)

	Local aArea       := GetArea()
	Local cFunBkp     := FunName()
	Local aRet        := {}
	Local lParam      := .T.

	Private oJSTela   := JsonObject():New()
	Private aParamBox := {}
	Private cTitulo   := " "
	Private cDash     := cTPDash
	Private cTPDesc   := ""

	aAdd(aParamBox,{1,"Tipo de cadastros:",SPACE(4),"","U_BIA729A1()","DASHLO","",0,.T.}) // Tipo caractere
	aAdd(aParamBox,{1,"Selecionado:",SPACE(15),"","","",".F.",0,.T.}) // Tipo caractere


	while lParam == .T.

		If ParamBox(aParamBox,"Escolha o tipo de Meta que deseja cadastrar",@aRet)

			oJSTela["CodigoSX3"]  := RIGHT(aRet[1],2)
			oJSTela["NomeOpcao"]  := aRet[2]


			cTitulo := "Dashboard "+UPPER(cTPNome)+" do tipo: "+UPPER(oJSTela["NomeOpcao"])

			FwMsgRun(NIL, {|| Main() }, "Aguarde!", "Carregando dashboard "+cTPNome+" do tipo: "+UPPER(oJSTela["NomeOpcao"]+""))



		Else

			lParam := .F.

		Endif

	endDo


	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil



USER Function BIA729A1()

	Local lRet   := .T.
	&("MV_PAR02") := ""

	SX5->(DbSetOrder(1))//X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
	If SX5->(DbSeek(XFilial("SX5")+"X7"+&("MV_PAR01")))
		If LEFT(&("MV_PAR01"),2) == cDash
			&("MV_PAR02") := SX5->X5_DESCRI
		EndIf
	else
		&("MV_PAR02") := ""
	EndIf


RETURN lRet

Static Function Main()

	Local oBrowse   := Nil


	SetFunName("BIA729A")

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZDL")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)


	If oJSTela["CodigoSX3"] == "01"
		oBrowse:SetOnlyFields({'ZDL_TIPO','ZDL_DTINI','ZDL_DTFIM','ZDL_META','ZDL_MODVEI'})
	ElseIf oJSTela["CodigoSX3"] == "02" .OR. oJSTela["CodigoSX3"] == "03"
		oBrowse:SetOnlyFields({'ZDL_TIPO','ZDL_DTINI','ZDL_DTFIM','ZDL_META'})
	ElseIf oJSTela["CodigoSX3"] == "04" .OR. oJSTela["CodigoSX3"] == "05"
		oBrowse:SetOnlyFields({'ZDL_TIPO','ZDL_DTINI','ZDL_DTFIM','ZDL_META','ZDL_FORNO'})
	EndIf

	//Filtros
	oBrowse:SetFilterDefault("ZDL->ZDL_TIPO   == "+UPPER(oJSTela["CodigoSX3"])+" .AND. ZDL->ZDL_TPDASH == "+cDash+"")

	//Ativa a Browse
	oBrowse:Activate()

Return



Static Function MenuDef()

	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BIA729A' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMod1Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BIA729A' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BIA729A' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BIA729A' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	//Criação do objeto do modelo de dados

	Local oModel  := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStZDL := NIL

	If oJSTela["CodigoSX3"] == "01"
		oStZDL := FWFormStruct(1, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META|ZDL_MODVEI|ZDL_TPDASH'})
	ElseIf oJSTela["CodigoSX3"] == "02" .OR. oJSTela["CodigoSX3"] == "03"
		oStZDL := FWFormStruct(1, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META|ZDL_TPDASH'})
	ElseIf oJSTela["CodigoSX3"] == "04" .OR. oJSTela["CodigoSX3"] == "05"
		oStZDL := FWFormStruct(1, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META|ZDL_FORNO|ZDL_TPDASH'})
	EndIf

	oStZDL:SetProperty('ZDL_TIPO' , MODEL_FIELD_INIT, {|oView | oJSTela["CodigoSX3"]})
	oStZDL:SetProperty('ZDL_TIPO' , MODEL_FIELD_WHEN,{|oView | .F. } ) // BLOQUEIA O CAMPO

	oStZDL:SetProperty('ZDL_TPDESC' , MODEL_FIELD_INIT, {|oView | oJSTela["NomeOpcao"]})
	oStZDL:SetProperty('ZDL_TPDESC' , MODEL_FIELD_WHEN,{|oView | .F. } ) // BLOQUEIA O CAMPO


	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres

	oModel := MPFormModel():New("BIA729AM",/*bPreValid*/,{|oModel| fTdOk(oModel, cDash)},/*<bCommit >*/,/*bCancel*/)


	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZDL",/*cOwner*/,oStZDL)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZDL_FILIAL','ZDL_TIPO'})

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMZDL"):SetDescription(cTitulo)



Return oModel



Static Function ViewDef()

	Local oModel := FWLoadModel("BIA729A")	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oView := Nil //Criando oView como nulo
	Local oStZDL := NIL //Criação da estrutura de dados utilizada na interface do cadastro

	If oJSTela["CodigoSX3"] == "01"
		oStZDL := FWFormStruct(2, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META|ZDL_MODVEI'})
	ElseIf oJSTela["CodigoSX3"] == "02" .OR. oJSTela["CodigoSX3"] == "03"
		oStZDL := FWFormStruct(2, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META'})
	ElseIf oJSTela["CodigoSX3"] == "04" .OR. oJSTela["CodigoSX3"] == "05"
		oStZDL := FWFormStruct(2, "ZDL", { |x| AllTrim(x) $ 'ZDL_DTINI|ZDL_DTFIM|ZDL_TIPO|ZDL_TPDESC|ZDL_META|ZDL_FORNO'})
	EndIf


	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZDL", oStZDL, "FORMZDL")  //ESSE FORMZDL é da função  ModelDef ***PRECISA SER IGUAL***

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	//oView:EnableTitleView('VIEW_ZDL', 'Dados - '+cTitulo )

	//Força o fechamento da janela na confirmação
	//oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZDL","TELA")

Return oView


Static Function fTdOk(oModel, cDash)

	Local lRet   := .T.
	Local cQuery := ""
	Local nOpc 	 := oModel:GetOperation()
	Local dDTINI := oModel:GetModel("FORMZDL"):GetValue('ZDL_DTINI')
	Local dDTFIM := oModel:GetModel("FORMZDL"):GetValue('ZDL_DTFIM')
	Local cQry   := GetNextAlias()

	If nOpc != MODEL_OPERATION_DELETE
		If  EMPTY(dDTINI) .OR.EMPTY(dDTINI)
			Help(,,"Help",,"Favor informar as datas de inicio e fim.", 1, 0,,,,,,{" "})
			RETURN .F.
		EndIf

		If oJSTela["CodigoSX3"] == "01"
			If EMPTY(oModel:GetModel("FORMZDL"):GetValue('ZDL_MODVEI'))
				Help(,,"Help",,"Favor informar o modelo do veículo.", 1, 0,,,,,,{" "})
				RETURN .F.
			EndIf
		EndIf

		If oJSTela["CodigoSX3"] $ "04#05"
			If EMPTY(oModel:GetModel("FORMZDL"):GetValue('ZDL_FORNO'))
				Help(,,"Help",,"Favor informar o tipo do forno.", 1, 0,,,,,,{" "})
				RETURN .F.
			EndIf
		EndIf

		cQuery += " select * , R_E_C_N_O_ as RECNO from ZDL010 "  + CRLF
		cQuery += " WHERE D_E_L_E_T_ = '' "  + CRLF
		cQuery += " AND ZDL_TIPO = "+ValToSql(oJSTela["CodigoSX3"])+ " "+ CRLF
		//	cQuery += " AND ZDL_DTFIM BETWEEN  "+ValToSql(dDTINI)+" AND " +ValToSql(dDTFIM)+" " + CRLF
		cQuery += " AND "+ValToSql(dDTINI)+" BETWEEN  ZDL_DTINI AND ZDL_DTFIM " + CRLF
		cQuery += " AND ZDL_TPDASH = "+ValToSql(cDash)+ " "+ CRLF


		If oJSTela["CodigoSX3"] $ '04#05'

			cQuery += " AND ZDL_FORNO = "+ValToSql(oModel:GetModel("FORMZDL"):GetValue('ZDL_FORNO'))+ " "+ CRLF

		ElseIf oJSTela["CodigoSX3"] $ '01'

			cQuery += " AND ZDL_MODVEI = "+ValToSql(oModel:GetModel("FORMZDL"):GetValue('ZDL_MODVEI'))+ " "+ CRLF

		EndIf

		TcQuery cQuery New Alias (cQry)

		If !EMPTY((cQry)->ZDL_TIPO)
			lRet := .F.
			Help(NIL, NIL, "Help", NIL, "Já existe dados cadastrados com essas informações.", 1, 0,,,,,,{"Mude as datas de inicio e fim"})
		EndIf

		//SETANDO O VALOR DO TIPO DE DASH BOARD
		oModel:GetModel("FORMZDL"):SetValue('ZDL_TPDASH',cDash)

	EndIf

Return (lRet)