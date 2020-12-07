#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} FCOMTE02
@description Interface MVC para cadastro da tabela PZ9 -reg.inc.Comissao
@author Fernando Rocha
@since 24/06/2015
@version 1.0
@type function
@obs revisao OS 3862-16 em 19/10/2016
/*/
User Function FCOMTE02()

	Local aArea := PZ9->(GetArea())
	Private oBrowse
	Private cTitle := "Rateio de Comissao"
	Private cF3SXHZH

	ValidPercent()

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("PZ9")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cTitle)

	//Desliga a exibição dos detalhes
	oBrowse:DisableDetails()

	//Ativamos a classe
	oBrowse:Activate()

	ValidPercent()

	RestArea(aArea)
Return
//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.FCOMTE02" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.FCOMTE02" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.FCOMTE02" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.FCOMTE02" OPERATION 5 ACCESS 0
Return aRotina

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'PZ9')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1, 'CamposPZ9')

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
	Local oStr1:= FWFormStruct( 1, 'PZ9', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma função MVC001V que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New(cTitle, /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , { | oMdl | MVC001C( oModel ) } ,, /*bCancel*/ )
	oModel:SetDescription(cTitle)

	oStr1:RemoveField( 'PZ9_FILIAL' )

	//setar campos nao alteraveis
	oStr1:SetProperty("PZ9_VEND"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	oStr1:SetProperty("PZ9_MARCA"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('CamposPZ9',,oStr1,{|oModel|MVC001T(oModel)},,)

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'PZ9_FILIAL', 'PZ9_VEND' })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposPZ9'):SetDescription('CamposPZ9')

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
	Local oModel	:= oModel:GetModel( 'CamposPZ9' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()
	Local cAliasTmp

	//Capturar o conteudo dos campos
	Local cVendPad	:= oModel:GetValue('PZ9_VENDPA')
	Local cVend		:= oModel:GetValue('PZ9_VEND')
	Local cMarca	:= oModel:GetValue('PZ9_MARCA')
	Local dPerIni	:= oModel:GetValue('PZ9_PERINI')
	Local dPerFim	:= oModel:GetValue('PZ9_PERFIM')
	Local nMaxVend	:= 999 // fa440CntVen()

	Local cExpRec

	if nOpc == 3
		cExpRec := "% 1=1 %"
	elseif nOpc == 4
		cExpRec := "% R_E_C_N_O_ <> "+AllTrim(Str(PZ9->(RecNo())))+" %"
	endif
		
	If nOpc == 3 .Or. nOpc == 4

		//Verificando se tem registro com conflito de chave e data
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%

		select 1 from %Table:PZ9%
		where PZ9_FILIAL = %Exp:xFilial("PZ9")%
		and PZ9_VENDPA = %Exp:cVendPad%
		and PZ9_VEND = %Exp:cVend%
		and PZ9_MARCA = %Exp:cMarca%
		and (	(%Exp:DTOS(dPerIni)% >= PZ9_PERINI and %Exp:DTOS(dPerIni)% <= PZ9_PERFIM) or
		(%Exp:DTOS(dPerFim)% >= PZ9_PERINI  and %Exp:DTOS(dPerFim)% <= PZ9_PERFIM) or
		(%Exp:DTOS(dPerIni)% < PZ9_PERINI  and %Exp:DTOS(dPerFim)% > PZ9_PERFIM))
		and %Exp:cExpRec%
		and D_E_L_E_T_ = ''

		EndSql

		If !(cAliasTmp)->(Eof())

			SFCMsgErro("A chave "+Alltrim(cVendPad+cMarca)+" ja existe com período conflitante!","FCOMTE02")
			lRet := .F.

		Endif

		(cAliasTmp)->(DBCloseArea())

		If lRet .And. nOpc == 3

			//Verificando se tem registro com conflito de chave e data
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
			%NoParser%

			select COUNT(*) TOT from %Table:PZ9%
			where PZ9_FILIAL = %Exp:xFilial("PZ9")%
			and PZ9_VENDPA = %Exp:cVendPad%
			and PZ9_MARCA = %Exp:cMarca%
			and (	(%Exp:DTOS(dPerIni)% >= PZ9_PERINI and %Exp:DTOS(dPerIni)% <= PZ9_PERFIM) or
			(%Exp:DTOS(dPerFim)% >= PZ9_PERINI  and %Exp:DTOS(dPerFim)% <= PZ9_PERFIM) or
			(%Exp:DTOS(dPerIni)% < PZ9_PERINI  and %Exp:DTOS(dPerFim)% > PZ9_PERFIM))
			and D_E_L_E_T_ = ''

			EndSql

			If (cAliasTmp)->TOT + 1 > nMaxVend

				SFCMsgErro("Quantidade máxima permitida é de " + AllTrim(cValTochar(nMaxVend)) + " vendedores!", "FCOMTE02")
				lRet := .F.

			Endif

			(cAliasTmp)->(DBCloseArea())

		EndIf

		If lRet

			//Verificando se tem registro com conflito de chave e data
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
			%NoParser%

			select SUM(PZ9_PERCEN) PZ9_PERCEN from %Table:PZ9%
			where PZ9_FILIAL = %Exp:xFilial("PZ9")%
			and PZ9_VENDPA = %Exp:cVendPad%
			and PZ9_MARCA = %Exp:cMarca%
			and (	(%Exp:DTOS(dPerIni)% >= PZ9_PERINI and %Exp:DTOS(dPerIni)% <= PZ9_PERFIM) or
			(%Exp:DTOS(dPerFim)% >= PZ9_PERINI  and %Exp:DTOS(dPerFim)% <= PZ9_PERFIM) or
			(%Exp:DTOS(dPerIni)% < PZ9_PERINI  and %Exp:DTOS(dPerFim)% > PZ9_PERFIM))
			and %Exp:cExpRec%
			and D_E_L_E_T_ = ''

			EndSql

			If oModel:GetValue('PZ9_PERCEN') + (cAliasTmp)->PZ9_PERCEN > 100

				SFCMsgErro("Valor informado ultrapassou 100%, o saldo restante é de " + AllTrim(cValTochar(100 - (cAliasTmp)->PZ9_PERCEN)) + "% !", "FCOMTE02")
				lRet := .F.

			Endif

			(cAliasTmp)->(DBCloseArea())

		EndIf

	Endif

	RestArea(aArea)

Return lRet

Static Function MVC001C( oModel )

	FWFormCommit( oModel )

Return .T.

Static Function ValidPercent()

	Local lRet := .F.
	Local cAliasTmp := GetNextAlias()
	Local cMsg := ""

	BeginSql Alias cAliasTmp
	
		%NoParser%

		SELECT	PZ9_FILIAL, PZ9_VENDPA, PZ9_MARCA, PZ9_PERINI, PZ9_PERFIM, SUM(PZ9_PERCEN) PZ9_PERCEN
		FROM 	%Table:PZ9%
		WHERE PZ9_FILIAL = %Exp:xFilial("PZ9")%
		AND D_E_L_E_T_ = ''
		GROUP BY PZ9_FILIAL, PZ9_VENDPA, PZ9_MARCA, PZ9_PERINI, PZ9_PERFIM
		HAVING SUM(PZ9_PERCEN) <> 100

	EndSql

	While (cAliasTmp)->(!EOF())

		lRet := .T.

		cMsg += "O Vend. padrão " + (cAliasTmp)->PZ9_VENDPA + " - marca " + (cAliasTmp)->PZ9_MARCA + " - periodo " + DTOC(STOD((cAliasTmp)->PZ9_PERINI)) + " a " + DTOC(STOD((cAliasTmp)->PZ9_PERFIM)) + " esta com " + AllTrim(cValTochar((cAliasTmp)->PZ9_PERCEN)) + "% e não atingiu 100% de rateio!" + CRLF + CRLF

		(cAliasTmp)->(DBSkip())

	EndDo

	If lRet

		cMsg += CRLF + CRLF + "Corrija o cadastro para que não tenha a comissão calculada errada!"

		Aviso("**ATENÇÃO**", cMsg, {"Estou ciente"}, 3)

	EndIf

	(cAliasTmp)->(DBCloseArea())

Return(lRet)