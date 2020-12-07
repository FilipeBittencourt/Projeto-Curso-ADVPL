#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} BAF009
@author Wlysses Cerqueira
@since 04/10/2018
@project Automação Financeira
@version 1.0
@description Cadastro de Regras 
@type class
/*/

User Function BAF009()

	Local aArea   := GetArea()
	Local oBrowse := Nil
	Local cFunBkp := FunName()
	
	Private cTitulo := "Cadastro Receitas x Classe de Valor"

	SetFunName("BAF009")

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("ZJ0")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)

Return()

Static Function MenuDef()

	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.BAF009' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.BAF009' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.BAF009' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.BAF009' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

Static Function ModelDef()

	Local oModel   := Nil
	Local oFormPai := FWFormStruct(1, 'ZJ0', {|cCampo| AllTrim(cCampo) $ "ZJ0_NATURE|ZJ0_DESCRI"})
	Local oFormFil := FWFormStruct(1, 'ZJ0')
	Local aZJ0Rel  := {}
	
	oFormPai:SetProperty('ZJ0_DESCRI', MODEL_FIELD_INIT, {|oView| U_BAF009SG1(ZJ0->ZJ0_NATURE, "ED_DESCRIC")})
	
	oFormPai:AddTrigger("ZJ0_NATURE", "ZJ0_DESCRI", {|| .T.}, {|oView| U_BAF009SG1(oView:GetValue('ZJ0_NATURE'), "ED_DESCRIC", .T.)})
	
	oFormFil:RemoveField( 'ZJ0_NATURE' )
	
	oFormFil:RemoveField( 'ZJ0_DESCRI' )
	
	oModel := MPFormModel():New('BAF009M',{|oModel| fPreValidCad(oModel)},{|oModel| fTudoOK(oModel)},{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:AddFields("FORMCAB",/*cOwner*/,oFormPai)
	oModel:AddGrid('ZJ0DETAIL',"FORMCAB",oFormFil)

	aAdd(aZJ0Rel, {'ZJ0_NATURE', 'IIf(!INCLUI, ZJ0->ZJ0_NATURE, FWxFilial("ZJ0"))'} )
	//aAdd(aZJ0Rel, {'ZJ0_DESCRI', 'IIf(!INCLUI, ZJ0->ZJ0_DESCRI,  "")'} )

	//Criando o relacionamento
	oModel:SetRelation('ZJ0DETAIL', aZJ0Rel, ZJ0->(IndexKey(1)))

	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZJ0DETAIL'):SetUniqueLine({"ZJ0_RECPAG", "ZJ0_CLVLCR", "ZJ0_CLVLDB", "ZJ0_EMPFIL"})

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("BAF009")
	Local oFormPai 	 := FWFormStruct(2, 'ZJ0', {|cCampo| AllTrim(cCampo) $ "ZJ0_NATURE|ZJ0_DESCRI"})
	Local oFormFil   := FWFormStruct(2, 'ZJ0')
	Local oView      := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB"	, oFormPai	, "FORMCAB")
	oView:AddGrid ('VIEW_ZJ0'	, oFormFil	, "ZJ0DETAIL")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 20)
	oView:CreateHorizontalBox('GRID' , 80)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZJ0','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', 'Cabeçalho - Natureza')
	oView:EnableTitleView('VIEW_ZJ0', 'Itens - Classe de Valor')

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
	//oView:SetFieldAction( 'ZJ0_CODREG', { |oView, cIDView, cField, xValue| BAF009SG1( oView, cIDView, cField, xValue, aCampInGat)})
	
	oFormFil:RemoveField( 'ZJ0_NATURE' )
	oFormFil:RemoveField( 'ZJ0_DESCRI' )
	
Return oView

Static Function fLinOK(oGrid, oField, nLine)

	Local nOpc := oGrid:GetOperation()
	Local lRet := .T.
	Local nRecno := ZJ0->(Recno())
	Local cChave := ""
	
	If nOpc == MODEL_OPERATION_INSERT //.Or. nOpc == MODEL_OPERATION_UPDATE
	
		ZJ0->(dbSetOrder(1))
		
		oGrid:GoLine(nLine)
		
		cChave := xFilial("ZJ0") + oField:GetValue('ZJ0_NATURE') + oGrid:GetValue('ZJ0_EMPFIL') + oGrid:GetValue('ZJ0_RECPAG')
		
		If lRet .And.  ZJ0->(DbSeek(cChave, .T.))
	
			lRet := .F.

			Help(NIL, NIL, "ATENCAO", NIL, "Registro ja existente!", 1, 0, NIL, NIL, NIL, NIL, NIL,{"Verifique os dados digitados."})
					
		EndIf

		ZJ0->(DbGoTo(nRecno))
		
	EndIf
	
Return(lRet)

Static Function fPreValidCad(oModel)

	Local lRet := .T.

Return(lRet)

Static Function fTudoOK(oModel)

	Local lRet		 := .T.
	Local cDescGrupo := ""
	Local nX   		 := 0
	Local nLinValid  := 0
	Local nOpc 		 := oModel:GetOperation()
	Local oField     := oModel:GetModel("FORMCAB")
	Local oGrid      := oModel:GetModel("ZJ0DETAIL")

	If nOpc == MODEL_OPERATION_INSERT .or. nOpc == MODEL_OPERATION_UPDATE

		If lRet 

			For nX := 1 To oGrid:GetQtdLine()
			
				oGrid:GoLine(nX)
				
				//cDescGrupo  := oField:GetValue('ZJ0_DESCRI')

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
	Local oGrid		 := oModel:GetModel("ZJ0DETAIL")
	Local oForm		 := oModel:GetModel("FORMCAB")
	Local nX   		 := 0
	Local nY		 := 0
	Local nOpc 		 := oModel:GetOperation()
	Local aCposForm  := oForm:GetStruct():GetFields()
	Local aCposGrid  := oGrid:GetStruct():GetFields()

	If nOpc == MODEL_OPERATION_INSERT
	
		ConfirmSX8()
		
	EndIf

	For nX := 1 To oGrid:GetQtdLine()
	
		oGrid:GoLine(nX)
		
		ZJ0->(dbGoTo(oGrid:GetDataID()))

		If nOpc == MODEL_OPERATION_DELETE
		
			//-- Deleta registro
			ZJ0->(RecLock("ZJ0",.F.))
			ZJ0->(dbDelete())
			ZJ0->(MsUnLock())
			
		Else
		
			//-- Grava inclusao/alteracao
			ZJ0->(RecLock("ZJ0", ZJ0->(EOF())))
		
			If oGrid:IsDeleted()
		
				ZJ0->(dbDelete())
		
			Else
		
				//-- Grava campos do cabecalho
				For nY := 1 To Len(aCposForm)
		
					If ZJ0->(FieldPos(aCposForm[nY,3])) > 0 
		
						ZJ0->&(aCposForm[nY,3]) := oForm:GetValue(aCposForm[nY,3])
		
					EndIf
		
				Next nY
		
				//-- Grava campos do grid
				For nY := 1 To Len(aCposGrid)
		
					If ZJ0->(FieldPos(aCposGrid[nY,3])) > 0 .And. aCposGrid[nY,3] <> "ZJ0_FILIAL"
		
						ZJ0->&(aCposGrid[nY,3]) := oGrid:GetValue(aCposGrid[nY,3])
		
					EndIf
		
				Next nY			
		
			EndIf
		
			ZJ0->(MsUnLock())
				
			ZJ0->(RecLock("ZJ0",.F.))
			ZJ0->ZJ0_FILIAL := xFilial("ZJ0")
			ZJ0->(MsUnLock())

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
	Local oGrid		 := oModel:GetModel("ZJ0DETAIL")
	Local nOpc 		 := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_INSERT

		RollBAckSx8()

	EndIf

Return(lRet)

User Function BAF009SG1(cConteudo, cCampoDest, lTrigger)

	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FwViewActive()
	Local cRetorno	:= ""
	
	Default lTrigger := .F.
	
	If (!oView:IsActive() .And. !INCLUI) .Or. lTrigger
	
		cRetorno := PadL(Posicione("SED", 1, xFilial("SED") + cConteudo, cCampoDest), TamSx3(cCampoDest)[1])
	
	EndIf
	
Return(cRetorno)