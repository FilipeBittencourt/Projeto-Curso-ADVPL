#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

/*/{Protheus.doc} BAF005
@author Wlysses Cerqueira
@since 04/10/2018
@project Automação Financeira
@version 1.0
@description Cadastro de Regras 
@type class
/*/

User Function BAF006()

	Local oBrowse

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('ZK1')
	oBrowse:SetDescription('Cadatro de Regras - Automacao Fiscal')
	oBrowse:Activate()

Return()

Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { 'Visualizar'	, 'VIEWDEF.BAF006', 0, 2, 0, NIL } ) 
	aAdd( aRotina, { 'Incluir' 	, 'VIEWDEF.BAF006', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar' 	, 'VIEWDEF.BAF006', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir' 	, 'VIEWDEF.BAF006', 0, 5, 0, NIL } )
	aAdd( aRotina, { 'Imprimir' 	, 'VIEWDEF.BAF006', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Copiar' 		, 'VIEWDEF.BAF006', 0, 9, 0, NIL } )

Return(aRotina)

Static Function ModelDef()

	Local oModel
	Local oStruZK1 := FWFormStruct(1,"ZK1")

	oModel := MPFormModel():New('MD_REGRA',{|oModel| fPreValidCad(oModel)},,{|oModel| fCommit(oModel)},{|oModel| fCancel(oModel)} )

	oModel:addFields('MASTERZK1',,oStruZK1)

	oModel:SetPrimaryKey({"ZK0_CODGRU"})

Return(oModel)

Static Function ViewDef()

	Local oModel := ModelDef()
	Local oView
	Local oStrZK1:= FWFormStruct(2, 'ZK1')

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('FORM_REGRA' , oStrZK1,'MASTERZK1' ) 

	oView:CreateHorizontalBox( 'BOX_FORM_REGRA', 100)
	oView:SetOwnerView('FORM_REGRA','BOX_FORM_REGRA')

Return(oView)

Static Function fPreValidCad(oModel)

	Local lRet :=.T.

	Local nOpc := oModel:getoperation()

Return(lRet)

Static Function fCancel(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("MASTERZK1")
	Local nOpc 		 := oModel:GetOperation()
	Local oView		:= FwViewActive()
	
	If nOpc == MODEL_OPERATION_INSERT .Or. oView:GetBrowseOpc() == 6

		RollBAckSx8()

	EndIf

Return(lRet)

Static Function fCommit(oModel)

	Local lRet 		 := .T.
	Local oForm		 := oModel:GetModel("MASTERZK1")
	Local oView		:= FwViewActive()
	Local nOpc 		 := oModel:GetOperation()
	Local aCpos  := oForm:GetStruct():GetFields()
	Local nY := 0
	
	If oView:GetBrowseOpc() == 6 .Or. nOpc == MODEL_OPERATION_INSERT
		
		oForm:SetValue("ZK1_CODREG", GetProxSXE())
		
		ZK1->(RecLock("ZK1", .T.))
		
	EndIf
	
	If nOpc == MODEL_OPERATION_DELETE
	
		ZK1->(RecLock("ZK1",.F.))
		ZK1->(dbDelete())
		ZK1->(MsUnLock())
		
	Else
		
		For nY := 1 To Len(aCpos)
		
			If ZK1->(FieldPos(aCpos[nY,3])) > 0 .And. aCpos[nY,3] <> "ZK1_FILIAL"
		
				ZK1->&(aCpos[nY,3]) := oForm:GetValue(aCpos[nY,3])
		
			EndIf
		
		Next nY
	
		ZK1->(MsUnLock())
		
		ZK1->(RecLock("ZK1",.F.))
		ZK1->ZK1_FILIAL := xFilial("ZK1")
		ZK1->(MsUnLock())
	
	EndIf

Return(lRet)

Static Function GetProxSXE()

Local cProxID := ""
Local cChaveID := ""
Local aAreaZK1 := ZK1->(GetArea())
	
	RollBAckSx8()
	
	// Gera identificador do registro CNAB no titulo enviado
	cProxID := GetSXENum("ZK1", "ZK1_CODREG")
	cChaveID := cProxID
				
	dbSelectArea("ZK1")
	dbSetOrder(1) // ZK1_FILIAL, ZK1_CODREG, R_E_C_N_O_, D_E_L_E_T_
	
	While ZK1->(MsSeek(xFilial("ZK1") + cChaveID))
	
		If ( __lSx8 )
		
			ConfirmSX8()
			
		EndIf
		
		cProxID := GetSXENum("ZK1", "ZK1_CODREG")
		
		cChaveID := cProxID
		
	EndDo
			
	ConfirmSx8()
	
	RestArea(aAreaZK1)
			
Return(cProxID)

User Function BAF006XV(lMsg, cTab)

	Local cFielVar 	:= AllTrim(ReadVar())
	Local lRet 		:= .F.
	Local aArea 	:= GetArea()
	Local cCodRegra := If(lMsg, &(cFielVar), If(cTab == "ZK0GRU", ZK0->ZK0_CODREG, ZK1->ZK1_CODREG)) // Nao posiciono ZK1, estará posicionado no loop do SXB
	Local cCodGrupo := If(lMsg, &(cFielVar), If(cTab == "ZK0GRU", ZK0->ZK0_CODGRU, ZK1->ZK1_CODREG)) // Nao posiciono ZK0, estará posicionado no loop do SXB

	Default lMsg := .F.

	If IsInCallStack("U_BAF005")

		lRet := .T.

	ElseIf cFielVar == "M->E1_YCDGREG"

		If SA1->(DBSeek(xFilial("SA1") + M->E1_CLIENTE + M->E1_LOJA))

			If ValidRule(SA1->A1_YCDGREG, cCodRegra, lMsg, cFielVar, cTab)

				lRet := .T.

			EndIf		

		EndIf

	ElseIf cFielVar == "M->E2_YCDGREG"

		If SA2->(DBSeek(xFilial("SA2") + M->E2_FORNECE + M->E2_LOJA))

			If ValidRule(SA2->A2_YCDGREG, cCodRegra, lMsg, cFielVar, cTab)

				lRet := .T.

			EndIf		

		EndIf

	ElseIf cFielVar == "M->A1_YCDGREG"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf

	ElseIf cFielVar == "M->A2_YCDGREG"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		
	ElseIf cFielVar == "M->A3_YCDGREG"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		

	ElseIf cFielVar == "M->ACY_YCDGRE"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		

	ElseIf cFielVar == "M->A6_YCDGREG"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		

	ElseIf cFielVar == "M->E5_YCDGREG"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		

	ElseIf cFielVar == "M->Z79_YCDGRE"

		If ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

			lRet := .T.

		EndIf		

	EndIf

	RestArea(aArea)

Return(lRet)

Static Function ValidRule(cCodGrupo, cCodRegra, lMsg, cFielVar, cTab)

	Local lRet := .F.
	//Local aArea_ := ZK1->(GetArea())

	Default cCodGrupo := ""
	Default cCodRegra := ""
	Default lMsg	  := .F.
	Default cFielVar  := ""
	Default cTab	  := ""

	If cTab == "ZK0"

		If Empty(cCodGrupo) 

			lRet := .T.		

		Else

			DBSelectArea("ZK0")
			ZK0->(DBSetOrder(1)) // ZK0_FILIAL, ZK0_CODGRU, ZK0_CODREG, R_E_C_N_O_, D_E_L_E_T_

			If ZK0->(DBSeek(xFilial("ZK0") + cCodGrupo))

				While ! ZK0->(EOF()) .And. ZK0->(ZK0_FILIAL + ZK0_CODGRU) == xFilial("ZK0") + cCodGrupo

					If ZK0->ZK0_MSBLQL <> '1'

						If ZK1->(DBSeek(xFilial("ZK1") + ZK0->ZK0_CODREG))

							If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							   (ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							   (ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)

								lRet := .T.

								Exit

							EndIf

						EndIf

					EndIf

					ZK0->(DBSkip())

				EndDo

				If !lRet

					BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 5)

				EndIf

			Else

				BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 6)

			EndIf

		EndIf

	Else

		If Empty(cCodRegra) .And. lMsg

			lRet := .T.

		ElseIf Empty(cCodGrupo) 

			BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 4)

		ElseIf ZK0->(DBSeek(xFilial("ZK0") + cCodGrupo + cCodRegra))

			If ZK0->ZK0_MSBLQL <> '1'

				If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
				   (ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
				   (ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)
							   
					lRet := .T.

				Else

					BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 3)

				EndIf

			Else

				BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 2)

			EndIf

		Else

			BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, 1)

		EndIf

	EndIf

	//RestArea(aArea_)

Return(lRet)

Static Function BAF006AV(cCodGrupo, cCodRegra, lMsg, cFielVar, nCodErro)

	Local cEntidade := ""

	Default nCodErro := 0

	If cFielVar == "M->E1_YCDGREG"

		cEntidade := "Cliente"

	ElseIf cFielVar == "M->E2_YCDGREG"

		cEntidade := "Fornecedor"

	ElseIf cFielVar == "A3_YCDGREG"

		cEntidade := "Fornecedor"

	ElseIf cFielVar == "ACY_YCDGRE"

		cEntidade := "Grupo de clientes"

	Elseif cFielVar == "A6_YCDGREG"

		cEntidade := "Banco"

	Elseif cFielVar == "E5_YCDGREG"

		cEntidade := "Movimento Bancario"

	Elseif cFielVar == "Z79_YCDGRE"

		cEntidade := "Rede de Compras"

	Else

		cEntidade := "Cadastro"

	EndIf

	If lMsg

		If nCodErro == 1

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "Não existe cadastro do grupo " + cCodGrupo + " e regra " + cCodRegra + " para o " + cEntidade + "!", {"Ok"}, 3)

		ElseIf nCodErro == 2

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "O grupo " + cCodGrupo + " referente a regra " + cCodRegra + " esta bloqueado!", {"Ok"}, 3)

		ElseIf nCodErro == 3

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "O grupo " + cCodGrupo + " referente a regra " + cCodRegra + " não pertence ao " + cEntidade + "!", {"Ok"}, 3)

		ElseIf nCodErro == 4

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "O " + cEntidade + " informado não possui grupo de regra cadastrado!", {"Ok"}, 3)

		ElseIf nCodErro == 5

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "O grupo informado não possui regra valida!", {"Ok"}, 3)

		ElseIf nCodErro == 6

			Aviso("ATENCAO - AUTOMACAO FINANCEIRA", "O grupo informado não existe!", {"Ok"}, 3)

		EndIf

	EndIf

Return()