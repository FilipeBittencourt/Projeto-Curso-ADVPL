#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BIA596
@author Wlysses Cerqueira (Facile)
@since 30/10/2020
@version 1.0
@Projet A-35
@description Consolidação empresas grupo para filial 90. 
@type Program
/*/

User Function BIA596()

	Local aArea   := GetArea()
	Local oBrowse := Nil
	Local cFunBkp := FunName()
	
	Private cTitulo := "Cadastro Percentual Rateio Orçamento Grupo"

	SetFunName("BIA596")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZO1")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.BIA596', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 		, 'VIEWDEF.BIA596', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 		, 'VIEWDEF.BIA596', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 		, 'VIEWDEF.BIA596', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.BIA596', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Copiar' 		, 'VIEWDEF.BIA596', 0, 9, 0, NIL } )
	aAdd( aRotina, { 'Processamento', 'U_INTRATCON()' , 0, 3, 0, NIL } )
	
Return(aRotina)

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZO1', {|cCampo| !AllTrim(cCampo) $ "ZO1_EMPFIL|ZO1_CNTPON|ZO1_PERCEN"})
	Local oFormFil := FWFormStruct(1, 'ZO1', {|cCampo| !AllTrim(cCampo) $ "ZO1_EMPFIR|ZO1_CNTPOR|ZO1_PERCER|ZO1_MESANO|ZO1_VERSAO|ZO1_REVISA|ZO1_ANOREF"})
	Local aZO1Rel  := {}
	
	//oFormPai:SetProperty('ZO1_MSBLQL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"2"'))

	//oFormFil:SetProperty('ZO1_DESCRE', MODEL_FIELD_INIT, {|oView| U_BIA596SG1(ZO1->ZO1_CODREG, "ZK1_DESCRI")})

	//oFormFil:AddTrigger("ZO1_CODREG", "ZO1_DESCRE", {|| .T.}, {|oView| U_BIA596SG1(oView:GetValue('ZO1_CODREG'), "ZK1_DESCRI", .T.)})

	oModel := MPFormModel():New('BIA596M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:AddFields("FORMCAB",/*cOwner*/,oFormPai)
	oModel:AddGrid('ZO1DETAIL',"FORMCAB",oFormFil)
	
	aAdd(aZO1Rel, {'ZO1_EMPFIR', 'IIf(!INCLUI, ZO1->ZO1_EMPFIR, FWxFilial("ZO1"))'} )
	aAdd(aZO1Rel, {'ZO1_MESANO', 'IIf(!INCLUI, ZO1->ZO1_MESANO, FWxFilial("ZO1"))'} )
	aAdd(aZO1Rel, {'ZO1_VERSAO', 'IIf(!INCLUI, ZO1->ZO1_VERSAO, FWxFilial("ZO1"))'} )
	aAdd(aZO1Rel, {'ZO1_REVISA', 'IIf(!INCLUI, ZO1->ZO1_REVISA, FWxFilial("ZO1"))'} )
	aAdd(aZO1Rel, {'ZO1_ANOREF', 'IIf(!INCLUI, ZO1->ZO1_ANOREF, FWxFilial("ZO1"))'} )
	
	//aAdd(aZO1Rel, {'ZO1_EMPFIR'	, 'ZO1_EMPFIL'} )
	//aAdd(aZO1Rel, {'ZO1_MESANO'	, 'ZO1_MESANO'} )
	//aAdd(aZO1Rel, {'ZO1_EMPFIR'	, 'ZO1_EMPFIL'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZO1DETAIL', aZO1Rel, ZO1->(IndexKey(1)))
	
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZO1DETAIL'):SetUniqueLine({"ZO1_EMPFIL", "ZO1_CNTPON"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("BIA596")
	Local oFormPai	 := FWFormStruct(2, 'ZO1', {|cCampo| !AllTrim(cCampo) $ "ZO1_EMPFIL|ZO1_CNTPON|ZO1_PERCEN"})
	Local oFormFil	 := FWFormStruct(2, 'ZO1', {|cCampo| !AllTrim(cCampo) $ "ZO1_EMPFIR|ZO1_CNTPOR|ZO1_PERCER|ZO1_MESANO|ZO1_VERSAO|ZO1_REVISA|ZO1_ANOREF"})
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMCAB")
	oView:AddGrid ('VIEW_ZO1'	, oFormFil	, "ZO1DETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZO1','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Cabeçalho - Mes')
	oView:EnableTitleView('VIEW_ZO1', 'Itens - Percentual')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	//oView:SetFieldAction( 'ZO1_CODREG', { |oView, cIDView, cField, xValue| BIA596SG1( oView, cIDView, cField, xValue, aCampInGat)})

Return oView

Static Function fLinOK(oGrid,nLine)

	Local nOpc := oGrid:GetOperation()
	Local lRet := .T.

Return(lRet)

Static Function fPreValidCad(oModel)

	Local lRet :=.T.

	Local nOpc := oModel:getoperation()

Return(lRet)

Static Function fTudoOK(oModel)

	Local lRet		 := .T.
	Local cDescGrupo := ""
	Local nX   		 := 0
	Local nLinValid  := 0
	Local nOpc 		 := oModel:GetOperation()
	Local oField     := oModel:GetModel("FORMCAB")
	Local oGrid      := oModel:GetModel("ZO1DETAIL")
	Local cCodigo	 := oField:GetValue('ZO1_MESANO')
	Local nRecno	 := ZO1->(Recno())
/*
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	
		If lRet 

			For nX := 1 To oGrid:GetQtdLine()
			
				oGrid:GoLine(nX)
				
				//cDescGrupo  := oField:GetValue('ZO1_DESCRI')

				If !oGrid:IsDeleted()
				
					lRet := fLinOK(oGrid,nX)
				
				EndIf	
				
				If !lRet
				
					Exit
				
				EndIf
				
				If lRet .And. !oGrid:IsDeleted() //.And. !Empty(cDescGrupo)
				
					nLinValid++
				
				EndIf
			
			Next nX	
			
			If lRet .And. nLinValid == 0
			
				lRet := .F.
			
				Help(NIL, NIL, "ATENCAO", NIL, "Registro ja existente!", 1, 0, NIL, NIL, NIL, NIL, NIL,{"Verifique os dados digitados."})
			
			EndIf	
		
		EndIf

	EndIf
*/
Return(lRet)

Static Function fCommit(oModel)

	Local lRet 		 := .T.
	Local oGrid		 := oModel:GetModel("ZO1DETAIL")
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oView		:= FwViewActive()
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	For nX := 1 To oGrid:GetQtdLine()
	
		oGrid:GoLine(nX)
		
		ZO1->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE
		
			//-- Deleta registro
			ZO1->(RecLock("ZO1",.F.))
			ZO1->(dbDelete())
			ZO1->(MsUnLock())
			
		Else
		
			//-- Grava inclusao/alteracao
			ZO1->(RecLock("ZO1", ZO1->(EOF())))
		
			If oGrid:IsDeleted()
		
				ZO1->(dbDelete())
		
			Else
		
				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)
		
					If ZO1->(FieldPos(aCposForm[nY,3])) > 0 
		
						ZO1->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
		
					EndIf
		
				Next nY
		
				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)
		
					If ZO1->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZO1_FILIAL"
		
						ZO1->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
		
					EndIf
		
				Next nY			
		
			EndIf
		
			ZO1->(MsUnLock())
				
			ZO1->(RecLock("ZO1",.F.))
			ZO1->ZO1_FILIAL := xFilial("ZO1")
			ZO1->(MsUnLock())

		EndIf

	Next nX

Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oGrid		 := oModel:GetModel("ZO1DETAIL")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		//RollBAckSx8()

	EndIf

Return(lRet)

Static Function GetProxSXE()

Local cProxID := ""
Local cChaveID := ""
Local aAreaZO1 := ZO1->(GetArea())
	
	RollBAckSx8()
	
	// Gera identificador do registro CNAB no titulo enviado
	cProxID := GetSXENum("ZO1", "ZO1_CODIGO")
	cChaveID := cProxID
				
	dbSelectArea("ZO1")
	dbSetOrder(1) // ZO1_FILIAL, ZO1_MESANO, ZO1_CODREG, R_E_C_N_O_, D_E_L_E_T_
	
	While ZO1->(MsSeek(xFilial("ZO1") + cChaveID))
	
		If ( __lSx8 )
		
			ConfirmSX8()
			
		EndIf
		
		cProxID := GetSXENum("ZO1", "ZO1_CODIGO")
		
		cChaveID := cProxID
		
	EndDo
			
	ConfirmSx8()
	
	RestArea(aAreaZO1)
			
Return(cProxID)
