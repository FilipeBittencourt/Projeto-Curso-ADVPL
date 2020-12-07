#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} FCOMTE01
@description Interface MVC para cadastro da tabela PZ8 -reg.inc.Comissao
@author Fernando Rocha
@since 24/06/2015
@version 1.0
@type function
@obs revisao OS 3862-16 em 19/10/2016
/*/
User Function FCOMTE01()
	/*Declarando as variáveis que serão utilizadas*/
	Local lRet := .T.
	Local aArea := PZ8->(GetArea())
	Private oBrowse
	Private cTitle := "Regras de Incremento de Comissao"
	Private cF3SXHZH

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("PZ8")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cTitle)

	//Desliga a exibição dos detalhes
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
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.FCOMTE01" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.FCOMTE01" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.FCOMTE01" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.FCOMTE01" OPERATION 5 ACCESS 0
Return aRotina

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'PZ8')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'CamposPZ8')

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , cTitle )
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'PZ8', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'PZ8_FILIAL' )

	//setar campos nao alteraveis
	oStr1:SetProperty("PZ8_VEND"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	oStr1:SetProperty("PZ8_TPSEG"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	oStr1:SetProperty("PZ8_MARCA"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('CamposPZ8',,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'PZ8_FILIAL', 'PZ8_VEND', 'PZ8_TPSEG' })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposPZ8'):SetDescription('CamposPZ8')

Return oModel

//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function MVC001T( oModel )
	Local lRet      := .T.

Return(lRet)

//-------------------------------------------------------------------
// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function MVC001V( oModel )
	Local lRet      := .T.
	Local oModel	:= oModel:GetModel( 'CamposPZ8' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()
	Local cAliasTmp

	//Capturar o conteudo dos campos
	Local cVend		:= oModel:GetValue('PZ8_VEND')
	Local cTpSeg	:= oModel:GetValue('PZ8_TPSEG')
	Local cMarca	:= oModel:GetValue('PZ8_MARCA')
	Local dPerIni	:= oModel:GetValue('PZ8_PERINI')
	Local dPerFim	:= oModel:GetValue('PZ8_PERFIM')
	
	Local cExpRec

	if nOpc == 3
		cExpRec := "% 1=1 %"
	elseif nOpc == 4
		cExpRec := "% R_E_C_N_O_ <> "+AllTrim(Str(PZ8->(RecNo())))+" %"
	endif
		
	If nOpc == 3 .Or. nOpc == 4

		//Verificando se tem registro com conflito de chave e data
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%

		select 1 from %Table:PZ8%
		where PZ8_FILIAL = '  '
		and PZ8_VEND = %Exp:cVend%
		and PZ8_TPSEG = %Exp:cTpSeg%
		and PZ8_MARCA = %Exp:cMarca%
		and (	(%Exp:DTOS(dPerIni)% >= PZ8_PERINI and %Exp:DTOS(dPerIni)% <= PZ8_PERFIM) or
		(%Exp:DTOS(dPerFim)% >= PZ8_PERINI  and %Exp:DTOS(dPerFim)% <= PZ8_PERFIM) or
		(%Exp:DTOS(dPerIni)% < PZ8_PERINI  and %Exp:DTOS(dPerFim)% > PZ8_PERFIM))
		and %Exp:cExpRec%

		EndSql

		If !(cAliasTmp)->(Eof())

			SFCMsgErro("A chave "+Alltrim(cVend+cTpSeg+cMarca)+" ja existe com período conflitante!","FCOMTE01")
			lRet := .F.

		Endif

	Endif

	RestArea(aArea)

Return lRet

Static Function MVC001C( oModel )

	FWFormCommit( oModel )

Return .T.
