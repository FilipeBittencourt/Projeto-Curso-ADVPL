#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} SFPType

Relacionamento entre Tipos de Produto conforme:
   1. Padrão adotado pelo Camalion, regulamentado pela Secretaria da Fazenda (SEFAZ) do Brasil.
   2. Padrão adotado pelo ERP TOTVS Protheus.

@type      function
@author    Giovani
@since     24/09/2017
@version   1.0
/*/
User Function SFPType()

	Local oBrowse

	oBrowse:= FWmBrowse():New()
	oBrowse:SetAlias('ZW2')
	oBrowse:SetDescription('Relacionamento entre Tipos de Produto Protheus X Camalion')
	oBrowse:Activate()

Return()


//------------------------------
// Definição do menu da rotina
//------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.SFPType' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.SFPType' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.SFPType' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.SFPType' OPERATION 5 ACCESS 0

Return(aRotina)


//------------------------------
// Definição estr. da interface
//------------------------------
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrZW2:= FWFormStruct(2, 'ZW2')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetModel(ModelDef())
	oView:AddField('VIEW_ZW2' , oStrZW2,'ZW2MASTER' )

	oStrZW2:AddGroup('GROUP01','Tipo de Produto - Protheus','', 2)
	oStrZW2:SetProperty('ZW2_TPPROT' ,MVC_VIEW_GROUP_NUMBER,'GROUP01')
	oStrZW2:SetProperty('ZW2_DSPROT' ,MVC_VIEW_GROUP_NUMBER,'GROUP01')

	oStrZW2:AddGroup('GROUP02','Tipo de Produto - Camalion','', 2)
	oStrZW2:SetProperty('ZW2_TPCAMA' ,MVC_VIEW_GROUP_NUMBER,'GROUP02')
	oStrZW2:SetProperty('ZW2_DSCAMA' ,MVC_VIEW_GROUP_NUMBER,'GROUP02')

	oView:CreateHorizontalBox( 'Tela', 100)
	oView:SetOwnerView('VIEW_ZW2', 'Tela')

Return(oView)


//------------------------------
// Definição do modelo de dados
//------------------------------
Static Function ModelDef()

	Local oModel
	Local oStrZW2:= FWFormStruct(1,'ZW2')

	oModel := MPFormModel():New('MODEL', , { |oModel| ModelValidation(oModel)})
	oModel:SetDescription('Modelo de Dados')

	oStrZW2:AddTrigger( 'ZW2_TPPROT', 'ZW2_DSPROT', { || .T. }, {|| ModelTrigger("ZW2_TPPROT") } )
	oModel:addFields('ZW2MASTER',,oStrZW2)

	oModel:SetPrimaryKey({ 'ZW2_FILIAL', 'ZW2_TPPROT', 'ZW2_TPCAMA' })
	oModel:getModel('ZW2MASTER'):SetDescription('Tipo Produto Protheus X Camalion')

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
		Case cCampo == 'ZW2_TPPROT'
			xContent := FwFldGet(cCampo) //oModel:GetValue('ZW2MASTER',cCampo)
			If !Empty(xContent)
				xReturn := Posicione('SX5',1,xFilial('SX5')+'02'+xContent,'X5_DESCRI')
				If Select('SX5') > 0
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
	Local cTipo,cSinc := ''
	Local lReturn := .T.

	Do Case

		//------------------------------
		// Inclusão / Alteração
		//------------------------------
		Case nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

			cTipo := oModel:GetValue('ZW2MASTER','ZW2_TPCAMA')
			cSinc := oModel:GetValue('ZW2MASTER','ZW2_SINCRO')

			DbSelectArea('ZW2')
			ZW2->(DbSetOrder(3))
			ZW2->(DbGoTop())

			If cSinc == '1' .And. MsSeek(xFilial('ZW2')+cTipo+'1',.T.,.F.)
				lReturn := .F.
				Help(,'','Help','','Não foi possível concluir a operação. ' +;
					'O Tipo de Produto "' + AllTrim(oModel:GetValue('ZW2MASTER','ZW2_TPCAMA')) + '" ' +;
					'já possui relacionamento com sincronismo ativado. ' , 1, 0) //+ chr(10) +;
					//'Obs.:Os Tipos de Produto correspondentes ao Camalion podem se repetir. ' +;
					//'Porém, apenas 1(um) pode ser definido para sincronização.' , 1, 0)
			EndIf

		Otherwise

	EndCase

	RestArea(aArea)

Return(lReturn)
