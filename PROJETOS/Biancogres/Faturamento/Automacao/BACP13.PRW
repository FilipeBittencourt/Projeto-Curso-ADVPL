#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BACP13
@author Wlysses Cerqueira
@since 20/09/2019
@project Automação Faturamento
@version 1.0
@description Cadastro de Regras
@type class
/*/
 
User Function BACP13()

	Local aArea   := GetArea()
	Local oBrowse := Nil
	Local cFunBkp := FunName()

	Private cTitulo := "Cadastro Rota UF Fronteira - MDF-e"
	Private aRotina   := MenuDef()

	SetFunName("BACP13")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZL3")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.BACP13', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 		, 'VIEWDEF.BACP13', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 		, 'VIEWDEF.BACP13', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 		, 'VIEWDEF.BACP13', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.BACP13', 0, 8, 0, NIL } )

Return(aRotina)

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZL3', {|cCampo| AllTrim(cCampo) == "ZL3_UFORI" .Or. AllTrim(cCampo) == "ZL3_UFDES"})
	Local oFormFil := FWFormStruct(1, 'ZL3', {|cCampo| AllTrim(cCampo) == "ZL3_ROTA" .Or. AllTrim(cCampo) == "ZL3_UF"})
	Local aZL3Rel  := {}

	oModel := MPFormModel():New('BACP13M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:AddFields("FORMCAB",/*cOwner*/,oFormPai)
	oModel:AddGrid('ZL3DETAIL',"FORMCAB",oFormFil)

	aAdd(aZL3Rel, {'ZL3_UFORI', 'IIf(!INCLUI, ZL3->ZL3_UFORI, "")'} )
	aAdd(aZL3Rel, {'ZL3_UFDES', 'IIf(!INCLUI, ZL3->ZL3_UFDES, "")'} )

	//Criando o relacionamento
	oModel:SetRelation('ZL3DETAIL', aZL3Rel, ZL3->(IndexKey(1)))

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZL3DETAIL'):SetUniqueLine({"ZL3_UF"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("BACP13")
	Local oFormPai 	 := FWFormStruct(2, 'ZL3', {|cCampo| AllTrim(cCampo) == "ZL3_UFORI" .Or. AllTrim(cCampo) == "ZL3_UFDES"})
	Local oFormFil   := FWFormStruct(2, 'ZL3', {|cCampo| AllTrim(cCampo) == "ZL3_ROTA" .Or. AllTrim(cCampo) == "ZL3_UF"})
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMCAB")
	oView:AddGrid ('VIEW_ZL3'	, oFormFil	, "ZL3DETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZL3','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Cabeçalho - Uf Carregamento x Uf Descarregamento')
    oView:EnableTitleView('VIEW_ZL3', 'Itens - Rota Estados Fronteira')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	//oView:SetFieldAction( 'ZL3_CODREG', { |oView, cIDView, cField, xValue| BACP13SG1( oView, cIDView, cField, xValue, aCampInGat)})

    oView:addIncrementField("ZL3DETAIL", "ZL3_ROTA")

Return oView

Static Function fLinOK(oGrid, oField, nLine)

	Local nOpc := oGrid:GetOperation()
	Local lRet := .T.
	Local nRecno := ZL3->(Recno())
	Local cChave := ""

	If nOpc == MODEL_OPERATION_INSERT //.Or. nOpc == MODEL_OPERATION_UPDATE

		ZL3->(dbSetOrder(1))

		oGrid:GoLine(nLine)

		cChave := xFilial("ZL3") + oField:GetValue('ZL3_UFORI') + oField:GetValue('ZL3_UFDES') + oGrid:GetValue('ZL3_UF')

		If lRet .And.  ZL3->(DbSeek(cChave, .T.))

			lRet := .F.

			Help(NIL, NIL, "ATENCAO", NIL, "Registro ja existente!", 1, 0, NIL, NIL, NIL, NIL, NIL,{"Verifique os dados digitados."})

		EndIf

		ZL3->(DbGoTo(nRecno))

	EndIf

Return(lRet)

Static Function fPreValidCad(oModel)

	Local lRet := .T.

Return(lRet)

Static Function fTudoOK(oModel)

	Local lRet		 := .T.
	Local nX   		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local oField     := oModel:GetModel("FORMCAB")
	Local oGrid      := oModel:GetModel("ZL3DETAIL")

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		If lRet

			For nX := 1 To oGrid:GetQtdLine()

				oGrid:GoLine(nX)

				//cDescGrupo  := oField:GetValue('ZL3_DESCRI')

				If !oGrid:IsDeleted()

					lRet := fLinOK(oGrid, oField, nX)

				EndIf

				If !lRet

					Exit

				EndIf

			Next nX

		EndIf

	EndIf

Return(lRet)

Static Function fCommit(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oGrid		 := oModel:GetModel("ZL3DETAIL")
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	If nOpc == MODEL_OPERATION_INSERT

		//ConfirmSX8()

	EndIf

	For nX := 1 To oGrid:GetQtdLine()

		oGrid:GoLine(nX)

		ZL3->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE

			//-- Deleta registro
			ZL3->(RecLock("ZL3",.F.))
			ZL3->(dbDelete())
			ZL3->(MsUnLock())

		Else

			//-- Grava inclusao/alteracao
			ZL3->(RecLock("ZL3", ZL3->(EOF())))

			If oGrid:IsDeleted()

				ZL3->(dbDelete())

			Else

				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)

					If ZL3->(FieldPos(aCposForm[nY,3])) > 0

						ZL3->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])

					EndIf

				Next nY

				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)

					If ZL3->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZL3_FILIAL"

						ZL3->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])

					EndIf

				Next nY

			EndIf

			ZL3->(MsUnLock())

			ZL3->(RecLock("ZL3",.F.))
			ZL3->ZL3_FILIAL := xFilial("ZL3")
			ZL3->(MsUnLock())

		EndIf

	Next nX
/*
	If nOpc == MODEL_OPERATION_UPDATE

		MsgInfo('Informações Gravadas com Sucesso!')

	EndIf
*/
Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oGrid		 := oModel:GetModel("ZL3DETAIL")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		//RollBAckSx8()

	EndIf

Return(lRet)