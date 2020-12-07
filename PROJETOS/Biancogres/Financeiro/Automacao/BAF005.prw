#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BAF005
@author Wlysses Cerqueira
@since 04/10/2018
@project Automação Financeira
@version 1.0
@description Cadastro de Regras 
@type class
/*/

User Function BAF005()

	Local aArea   := GetArea()
	Local oBrowse := Nil
	Local cFunBkp := FunName()
	
	Private cTitulo := "Cadastro Grupo de Regras - Automacao Financeira"

	SetFunName("BAF005")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZK0")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.BAF005', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir' 	, 'VIEWDEF.BAF005', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 	, 'VIEWDEF.BAF005', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 	, 'VIEWDEF.BAF005', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.BAF005', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Copiar' 		, 'VIEWDEF.BAF005', 0, 9, 0, NIL } )

Return(aRotina)

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZK0', {|cCampo| AllTrim(cCampo) $ "ZK0_CODGRU|ZK0_DESCRI|ZK0_MSBLQL"})
	Local oFormFil := FWFormStruct(1, 'ZK0', {|cCampo| AllTrim(cCampo) $ "ZK0_CODREG|ZK0_CODEMP|ZK0_CODFIL|ZK0_DESCRE"})
	Local aZK0Rel  := {}
	
	oFormPai:SetProperty('ZK0_MSBLQL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"2"'))

	oFormFil:SetProperty('ZK0_DESCRE', MODEL_FIELD_INIT, {|oView| U_BAF005SG1(ZK0->ZK0_CODREG, "ZK1_DESCRI")})
	oFormFil:SetProperty('ZK0_CODEMP', MODEL_FIELD_INIT, {|oView| U_BAF005SG1(ZK0->ZK0_CODREG, "ZK1_CODEMP")})
	oFormFil:SetProperty('ZK0_CODFIL', MODEL_FIELD_INIT, {|oView| U_BAF005SG1(ZK0->ZK0_CODREG, "ZK1_CODFIL")})
	
	oFormFil:AddTrigger("ZK0_CODREG", "ZK0_DESCRE", {|| .T.}, {|oView| U_BAF005SG1(oView:GetValue('ZK0_CODREG'), "ZK1_DESCRI", .T.)})
	oFormFil:AddTrigger("ZK0_CODREG", "ZK0_CODEMP", {|| .T.}, {|oView| U_BAF005SG1(oView:GetValue('ZK0_CODREG'), "ZK1_CODEMP", .T.)})
	oFormFil:AddTrigger("ZK0_CODREG", "ZK0_CODFIL", {|| .T.}, {|oView| U_BAF005SG1(oView:GetValue('ZK0_CODREG'), "ZK1_CODFIL", .T.)})
	
	oModel := MPFormModel():New('BAF005M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:AddFields("FORMCAB",/*cOwner*/,oFormPai)
	oModel:AddGrid('ZK0DETAIL',"FORMCAB",oFormFil)

	aAdd(aZK0Rel, {'ZK0_CODGRU', 'IIf(!INCLUI, ZK0->ZK0_CODGRU, FWxFilial("ZK0"))'} )
	aAdd(aZK0Rel, {'ZK0_DESCRI', 'IIf(!INCLUI, ZK0->ZK0_DESCRI,  "")'} )

	//Criando o relacionamento
	oModel:SetRelation('ZK0DETAIL', aZK0Rel, ZK0->(IndexKey(1)))

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZK0DETAIL'):SetUniqueLine({"ZK0_CODREG"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("BAF005")
	Local oFormPai	 := FWFormStruct(2, 'ZK0', {|cCampo| AllTrim(cCampo) $ "ZK0_CODGRU|ZK0_DESCRI|ZK0_MSBLQL"})
	Local oFormFil	 := FWFormStruct(2, 'ZK0', {|cCampo| AllTrim(cCampo) $ "ZK0_CODREG|ZK0_CODEMP|ZK0_CODFIL|ZK0_DESCRE"})
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMCAB")
	oView:AddGrid ('VIEW_ZK0'	, oFormFil	, "ZK0DETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZK0','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Cabeçalho - Grupo')
	oView:EnableTitleView('VIEW_ZK0', 'Itens - Regra')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	//oView:SetFieldAction( 'ZK0_CODREG', { |oView, cIDView, cField, xValue| BAF005SG1( oView, cIDView, cField, xValue, aCampInGat)})

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
	Local oGrid      := oModel:GetModel("ZK0DETAIL")
	Local cCodigo	 := oField:GetValue('ZK0_CODGRU')
	Local nRecno	 := ZK0->(Recno())

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		If lRet 

			For nX := 1 To oGrid:GetQtdLine()
			
				oGrid:GoLine(nX)
				
				cDescGrupo  := oField:GetValue('ZK0_DESCRI')

				If !oGrid:IsDeleted()
				
					lRet := fLinOK(oGrid,nX)
				
				EndIf	
				
				If !lRet
				
					Exit
				
				EndIf
				
				If lRet .And. !oGrid:IsDeleted() .And. !Empty(cDescGrupo)
				
					nLinValid++
				
				EndIf
			
			Next nX	
			
			If lRet .And. nLinValid == 0
			
				lRet := .F.
			
				Help(" ",1, "BIAFA00602")
			
			EndIf	
		
		EndIf

	EndIf

Return(lRet)

Static Function fCommit(oModel)

	Local lRet 		 := .T.
	Local oGrid		 := oModel:GetModel("ZK0DETAIL")
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oView		:= FwViewActive()
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	If oView:GetBrowseOpc() == 6 .Or. nOpc == MODEL_OPERATION_INSERT
		
		oForm:SetValue("ZK0_CODGRU", GetProxSXE())
		
	EndIf

	For nX := 1 To oGrid:GetQtdLine()
	
		oGrid:GoLine(nX)
		
		ZK0->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE
		
			//-- Deleta registro
			ZK0->(RecLock("ZK0",.F.))
			ZK0->(dbDelete())
			ZK0->(MsUnLock())
			
		Else
		
			//-- Grava inclusao/alteracao
			ZK0->(RecLock("ZK0", ZK0->(EOF())))
		
			If oGrid:IsDeleted()
		
				ZK0->(dbDelete())
		
			Else
		
				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)
		
					If ZK0->(FieldPos(aCposForm[nY,3])) > 0 
		
						ZK0->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
		
					EndIf
		
				Next nY
		
				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)
		
					If ZK0->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZK0_FILIAL"
		
						ZK0->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
		
					EndIf
		
				Next nY			
		
			EndIf
		
			ZK0->(MsUnLock())
				
			ZK0->(RecLock("ZK0",.F.))
			ZK0->ZK0_FILIAL := xFilial("ZK0")
			ZK0->(MsUnLock())

		EndIf

	Next nX

Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local oGrid		 := oModel:GetModel("ZK0DETAIL")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		RollBAckSx8()

	EndIf

Return(lRet)

Static Function GetProxSXE()

Local cProxID := ""
Local cChaveID := ""
Local aAreaZK0 := ZK0->(GetArea())
	
	RollBAckSx8()
	
	// Gera identificador do registro CNAB no titulo enviado
	cProxID := GetSXENum("ZK0", "ZK0_CODGRU")
	cChaveID := cProxID
				
	dbSelectArea("ZK0")
	dbSetOrder(1) // ZK0_FILIAL, ZK0_CODGRU, ZK0_CODREG, R_E_C_N_O_, D_E_L_E_T_
	
	While ZK0->(MsSeek(xFilial("ZK0") + cChaveID))
	
		If ( __lSx8 )
		
			ConfirmSX8()
			
		EndIf
		
		cProxID := GetSXENum("ZK0", "ZK0_CODGRU")
		
		cChaveID := cProxID
		
	EndDo
			
	ConfirmSx8()
	
	RestArea(aAreaZK0)
			
Return(cProxID)

User Function BAF005SG1(cConteudo, cCampoDest, lTrigger)

	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FwViewActive()
	Local cRetorno	:= ""
	
	Default lTrigger := .F.
	
	If (!oView:IsActive() .And. !INCLUI) .Or. lTrigger
	
		cRetorno := PadL(Posicione("ZK1", 1, xFilial("ZK1") + cConteudo, cCampoDest), TamSx3(cCampoDest)[1])
	
	EndIf
	
Return(cRetorno)