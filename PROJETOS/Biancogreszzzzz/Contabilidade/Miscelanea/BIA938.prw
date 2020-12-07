#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BIA938
@author Wlysses Cerqueira
@since 04/10/2018
@project Automação Financeira
@version 1.0
@description Cadastro de Regras 
@type class
/*/

User Function BIA938()

	Local aArea   := GetArea()
	Local oBrowse := Nil
	Local cFunBkp := FunName()
	
	Private cTitulo := "Cadastro Percentual Rateio Despesas Grupo"

	SetFunName("BIA938")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZL1")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.BIA938', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 		, 'VIEWDEF.BIA938', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 		, 'VIEWDEF.BIA938', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 		, 'VIEWDEF.BIA938', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.BIA938', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Copiar' 		, 'VIEWDEF.BIA938', 0, 9, 0, NIL } )
	aAdd( aRotina, { 'Processamento', 'U_INTRATCON()' , 0, 3, 0, NIL } )
	
Return(aRotina)

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZL1', {|cCampo| !AllTrim(cCampo) $ "ZL1_EMPFIL|ZL1_CNTPON"})
	Local oFormFil := FWFormStruct(1, 'ZL1', {|cCampo| !AllTrim(cCampo) $ "ZL1_EMPFIR|ZL1_CNTPOR|ZL1_PERCER|ZL1_MESANO"})
	Local aZL1Rel  := {}
	
	//oFormPai:SetProperty('ZL1_MSBLQL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"2"'))

	//oFormFil:SetProperty('ZL1_DESCRE', MODEL_FIELD_INIT, {|oView| U_BIA938SG1(ZL1->ZL1_CODREG, "ZK1_DESCRI")})

	//oFormFil:AddTrigger("ZL1_CODREG", "ZL1_DESCRE", {|| .T.}, {|oView| U_BIA938SG1(oView:GetValue('ZL1_CODREG'), "ZK1_DESCRI", .T.)})

	oModel := MPFormModel():New('BIA938M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:AddFields("FORMCAB",/*cOwner*/,oFormPai)
	oModel:AddGrid('ZL1DETAIL',"FORMCAB",oFormFil)
	
	aAdd(aZL1Rel, {'ZL1_EMPFIR', 'IIf(!INCLUI, ZL1->ZL1_EMPFIR, FWxFilial("ZL1"))'} )
	aAdd(aZL1Rel, {'ZL1_MESANO', 'IIf(!INCLUI, ZL1->ZL1_MESANO, FWxFilial("ZL1"))'} )
	
	//aAdd(aZL1Rel, {'ZL1_EMPFIR'	, 'ZL1_EMPFIL'} )
	//aAdd(aZL1Rel, {'ZL1_MESANO'	, 'ZL1_MESANO'} )
	//aAdd(aZL1Rel, {'ZL1_EMPFIR'	, 'ZL1_EMPFIL'} )
	
	//Criando o relacionamento
	oModel:SetRelation('ZL1DETAIL', aZL1Rel, ZL1->(IndexKey(1)))
	
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZL1DETAIL'):SetUniqueLine({"ZL1_EMPFIL", "ZL1_CNTPON"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("BIA938")
	Local oFormPai	 := FWFormStruct(2, 'ZL1', {|cCampo| !AllTrim(cCampo) $ "ZL1_EMPFIL|ZL1_CNTPON|ZL1_PERCEN"})
	Local oFormFil	 := FWFormStruct(2, 'ZL1', {|cCampo| !AllTrim(cCampo) $ "ZL1_EMPFIR|ZL1_CNTPOR|ZL1_PERCER|ZL1_MESANO"})
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMCAB")
	oView:AddGrid ('VIEW_ZL1'	, oFormFil	, "ZL1DETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZL1','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Cabeçalho - Mes')
	oView:EnableTitleView('VIEW_ZL1', 'Itens - Percentual')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	//oView:SetFieldAction( 'ZL1_CODREG', { |oView, cIDView, cField, xValue| BIA938SG1( oView, cIDView, cField, xValue, aCampInGat)})

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
	Local oGrid      := oModel:GetModel("ZL1DETAIL")
	Local cCodigo	 := oField:GetValue('ZL1_MESANO')
	Local nRecno	 := ZL1->(Recno())
/*
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
	
		If lRet 

			For nX := 1 To oGrid:GetQtdLine()
			
				oGrid:GoLine(nX)
				
				//cDescGrupo  := oField:GetValue('ZL1_DESCRI')

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
	Local oGrid		 := oModel:GetModel("ZL1DETAIL")
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oView		:= FwViewActive()
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	For nX := 1 To oGrid:GetQtdLine()
	
		oGrid:GoLine(nX)
		
		ZL1->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE
		
			//-- Deleta registro
			ZL1->(RecLock("ZL1",.F.))
			ZL1->(dbDelete())
			ZL1->(MsUnLock())
			
		Else
		
			//-- Grava inclusao/alteracao
			ZL1->(RecLock("ZL1", ZL1->(EOF())))
		
			If oGrid:IsDeleted()
		
				ZL1->(dbDelete())
		
			Else
		
				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)
		
					If ZL1->(FieldPos(aCposForm[nY,3])) > 0 
		
						ZL1->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
		
					EndIf
		
				Next nY
		
				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)
		
					If ZL1->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZL1_FILIAL"
		
						ZL1->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
		
					EndIf
		
				Next nY			
		
			EndIf
		
			ZL1->(MsUnLock())
				
			ZL1->(RecLock("ZL1",.F.))
			ZL1->ZL1_FILIAL := xFilial("ZL1")
			ZL1->(MsUnLock())

		EndIf

	Next nX

Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oGrid		 := oModel:GetModel("ZL1DETAIL")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		//RollBAckSx8()

	EndIf

Return(lRet)

Static Function GetProxSXE()

Local cProxID := ""
Local cChaveID := ""
Local aAreaZL1 := ZL1->(GetArea())
	
	RollBAckSx8()
	
	// Gera identificador do registro CNAB no titulo enviado
	cProxID := GetSXENum("ZL1", "ZL1_CODIGO")
	cChaveID := cProxID
				
	dbSelectArea("ZL1")
	dbSetOrder(1) // ZL1_FILIAL, ZL1_MESANO, ZL1_CODREG, R_E_C_N_O_, D_E_L_E_T_
	
	While ZL1->(MsSeek(xFilial("ZL1") + cChaveID))
	
		If ( __lSx8 )
		
			ConfirmSX8()
			
		EndIf
		
		cProxID := GetSXENum("ZL1", "ZL1_CODIGO")
		
		cChaveID := cProxID
		
	EndDo
			
	ConfirmSx8()
	
	RestArea(aAreaZL1)
			
Return(cProxID)