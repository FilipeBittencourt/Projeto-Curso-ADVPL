#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} SFMUnit

Relacionamento entre Unidades de Medida conforme:
   1. Padrão adotado pelo Camalion, regulamentado pela Secretaria da Fazenda (SEFAZ) do Brasil.
   2. Padrão adotado pelo ERP TOTVS Protheus.

@type      function
@author    Giovani
@since     24/09/2017
@version   1.0
/*/

User Function SFMUnit()

	Local oBrowse

	oBrowse:= FWmBrowse():New()
	oBrowse:SetAlias('ZW1')
	oBrowse:SetDescription('Relacionamento entre Unidades de Medida Protheus X Camalion')
	oBrowse:Activate()

Return()


//------------------------------
// Definição do menu da rotina
//------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.SFMUNIT' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.SFMUNIT' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.SFMUNIT' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.SFMUNIT' OPERATION 5 ACCESS 0

Return(aRotina)


//------------------------------
// Definição estr. da interface
//------------------------------
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrZW1:= FWFormStruct(2, 'ZW1')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetModel(ModelDef())
	oView:AddField('VIEW_ZW1' , oStrZW1,'ZW1MASTER' )

	oStrZW1:AddGroup('GROUP01','Unidade de Medida - Protheus','', 2)
	oStrZW1:SetProperty('ZW1_UMPROT' ,MVC_VIEW_GROUP_NUMBER,'GROUP01')
	oStrZW1:SetProperty('ZW1_DSPROT' ,MVC_VIEW_GROUP_NUMBER,'GROUP01')

	oStrZW1:AddGroup('GROUP02','Unidade de Medida - Camalion','', 2)
	oStrZW1:SetProperty('ZW1_UMCAMA' ,MVC_VIEW_GROUP_NUMBER,'GROUP02')
	oStrZW1:SetProperty('ZW1_DSCAMA' ,MVC_VIEW_GROUP_NUMBER,'GROUP02')

	oView:CreateHorizontalBox( 'Tela', 100)
	oView:SetOwnerView('VIEW_ZW1', 'Tela')

Return(oView)


//------------------------------
// Definição do modelo de dados
//------------------------------
Static Function ModelDef()

	Local oModel
	Local oStrZW1:= FWFormStruct(1,'ZW1')

	oModel := MPFormModel():New('MODEL', , { |oModel| ModelValidation(oModel)})
	oModel:SetDescription('Modelo de Dados')

	oStrZW1:AddTrigger( 'ZW1_UMPROT', 'ZW1_DSPROT', { || .T. }, {|| ModelTrigger("ZW1_UMPROT") } )
	oModel:addFields('ZW1MASTER',,oStrZW1)

	//oStrZW1:AddTrigger( 'ZW1_UMPROT', 'ZW1_DSPROT', nil, {|| ModelTrigger("ZW1_UMPROT") }  )
	//oStrZW1:AddTrigger( 'ZW1_UMPROT', 'ZW1_DSPROT', nil, {|| 'teste' }  )

	oModel:SetPrimaryKey({ 'ZW1_FILIAL', 'ZW1_UMPROT', 'ZW1_UMCAMA' })
	oModel:getModel('ZW1MASTER'):SetDescription('UM Protheus X Camalion')

Return(oModel)


//------------------------------
// Gatilhos
//------------------------------
Static Function ModelTrigger(cCampo)

	Local xContent := nil
	Local xReturn := nil

	Default cCampo := ""

	If !Empty(cCampo)
		Do Case
		Case cCampo == 'ZW1_UMPROT'
			xContent := FwFldGet(cCampo) //oModel:GetValue('ZW1MASTER',cCampo)
			If !Empty(xContent)
				xReturn := Posicione('SAH',1,xFilial('SAH')+xContent,'AH_DESCPO')
				If Select('SAH') > 0
					SAH->(DbCloseArea())
				EndIf
			EndIf
		EndCase
	EndIf

Return(xReturn)


//------------------------------
// Validacao
//------------------------------
Static Function ModelValidation(oModel)

	Local aArea := GetArea()
	Local nOperation := oModel:GetOperation()
	Local cUM,cSinc := ''
	Local lReturn := .T.

	Do Case

		//------------------------------
		// Inclusão / Alteração
		//------------------------------
		Case nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

			cUM := oModel:GetValue('ZW1MASTER','ZW1_UMCAMA')
			cSinc := oModel:GetValue('ZW1MASTER','ZW1_SINCRO')

			DbSelectArea('ZW1')
			ZW1->(DbSetOrder(3))
			ZW1->(DbGoTop())

			If cSinc == '1' .And. MsSeek(xFilial('ZW1')+cUM+'1',.T.,.F.)
				lReturn := .F.
				Help(,'','Help','','Não foi possível concluir a operação. ' +;
					'A Unidade de Medida "' + AllTrim(oModel:GetValue('ZW1MASTER','ZW1_UMCAMA')) + '" ' +;
					'já possui relacionamento com sincronismo ativado. ' , 1, 0) //+ chr(10) +;
					//'Obs.:Os Tipos de Produto correspondentes ao Camalion podem se repetir. ' +;
					//'Porém, apenas 1(um) pode ser definido para sincronização.' , 1, 0)
			EndIf

		Otherwise

	EndCase

	RestArea(aArea)

Return(lReturn)
