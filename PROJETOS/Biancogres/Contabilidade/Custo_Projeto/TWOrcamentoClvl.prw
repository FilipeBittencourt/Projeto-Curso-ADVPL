#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWOrcamentoClvl
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar Orçamento Clvl 
@obs Projeto: D-01 - Custos dos Projetos
@type Class
/*/

#DEFINE TIT_WND "Orçamento Clvl"

#DEFINE nP_SUBITEM 1
#DEFINE nP_DESC 2

Class TWOrcamentoClvl From LongClassName

	Data oWindow // Janela principal - FWDialogModal 
	Data oContainer	// Divisor de janelas - FWFormContainer 
	Data cHeaderBox // Identificador do cabecalho da janela
	Data cItemBox // Identificador dos itens da janela

	Data oFD // Field editor - MsMGet
	Data cFDTable // Tabela
	Data nFDOpc // Opcao do menu
	Data nFDRecNo // RecNo
	Data oMGField // Estrutura dos campos do MsMGet - TMGField
	
	Data oGD // Grid - MsNewGetDados
	Data aGDAField // Array com os campos que podem ser alterados no grid
	Data oGDField // Estrutura dos campos do grid - TGDField
	Data aGDRecNo // Array com RecNo do grid, utilziado para controle de alterações	

	Data cCodigo // Codigo interno
	Data cClvl // Classe de valor
	Data cItemCta // Item contabil
				
	Method New() Constructor
	Method LoadInterface()	
	Method LoadWindow()
	Method GetOperation()
	Method LoadContainer()
	Method LoadHeader(oWnd)
	Method LoadBrowser(oWnd)
	Method Activate()	
	Method MGFieldProperty()
	Method MGFieldData()
	Method GDEditableField()
	Method GDFieldProperty()
	Method GDFieldData()
	Method Valid()
	Method ValidField()	
	Method Save()	
	Method Confirm()
	Method Cancel(lClose)
			
EndClass


Method New() Class TWOrcamentoClvl
		
	::oWindow := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cItemBox := ""

	::oFD := Nil
	::cFDTable := "ZMC"
	::nFDOpc := 2
	::nFDRecNo := ZMC->(RecNo())
	::oMGField := Nil

	::oGD := Nil
	::aGDAField := {}
	::oGDField := TGDField():New()
	::aGDRecNo := {}

	::cCodigo := Space(TamSx3("ZMC_CODIGO")[1])
	::cClvl := Space(TamSx3("ZMC_CLVL")[1])	
	::cItemCta := Space(TamSx3("ZMC_ITEMCT")[1])

Return()


Method LoadInterface() Class TWOrcamentoClvl
	
	::LoadWindow()
	
	::LoadContainer()	
	
	::LoadHeader()
	
	::LoadBrowser()	
			
Return()


Method LoadWindow() Class TWOrcamentoClvl
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND + " - " + ::GetOperation())
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddOKButton({|| ::Confirm() })
	::oWindow:AddCloseButton( {|| ::Cancel(.T.)})

	::oWindow:AddButton("Pesquisar", {|| GdSeek(::oGD,,,,.F.) },,, .T., .F., .T.)
							
Return()


Method GetOperation() Class TWOrcamentoClvl
Local cRet := ""

	If ::nFDOpc == 2
	
		cRet := "Visualizar"
	
	ElseIf ::nFDOpc == 3
	
		cRet := "Incluir"
	
	ElseIf ::nFDOpc == 4
	
		cRet := "Alterar"
	
	ElseIf ::nFDOpc == 5
		
		cRet := "Excluir"
		
	EndIf
	
Return(cRet)


Method LoadContainer() Class TWOrcamentoClvl

	::oContainer := FWFormContainer():New()
	
	::cHeaderBox := ::oContainer:CreateHorizontalBox(20)
	
	::cItemBox := ::oContainer:CreateHorizontalBox(80)
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadHeader() Class TWOrcamentoClvl

	::oFD := MsMGet():New(::cFDTable, ::nFDRecNo, ::nFDOpc,,,,,{0, 0 , 0, 0},,,,,,::oContainer:GetPanel(::cHeaderBox))
	::oFD:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
			
Return()


Method LoadBrowser() Class TWOrcamentoClvl
Local cVldDef := "AllwaysTrue"
Local nMaxLine := 1000

	//RegToMemory(::cFDTable, ::nFDOpc == 3)
	
	::oGD := MsNewGetDados():New(0, 0, 0, 0, GD_INSERT + GD_UPDATE + GD_DELETE, cVldDef, cVldDef, "", ::GDEditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cItemBox), ::GDFieldProperty(), ::GDFieldData())
	::oGD:bFieldOk := {|| ::ValidField() }
	::oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oGD:oBrowse:lVScroll := .T.
	::oGD:oBrowse:lHScroll := .T.
	
	::oGD:oBrowse:Refresh()
	
	If ::nFDOpc == 2 .Or. ::nFDOpc == 5
		
		::oGD:Disable()
		
	EndIf	
	
Return()


Method Activate() Class TWOrcamentoClvl
	
	::LoadInterface()
	
	::oWindow:bInit := {|| DbSelectArea(::cFDTable), RegToMemory(::cFDTable, ::nFDOpc == 3), ::MGFieldData(), ::oFD:Refresh()}
	
	::oWindow:Activate()

	::Cancel()
		
Return()


Method MGFieldProperty() Class TWOrcamentoClvl
Local aRet := {}
	
Return(aRet)


Method MGFieldData() Class TWOrcamentoClvl	
	
	
Return()


Method GDEditableField() Class TWOrcamentoClvl
Local aRet := {}

	aAdd(aRet, "ZMD_SUBITE")
	aAdd(aRet, "ZMD_DESC")
	aAdd(aRet, "ZMD_UNIDAD")
	aAdd(aRet, "ZMD_QUANT")
	aAdd(aRet, "ZMD_MOEDA")
	aAdd(aRet, "ZMD_VALOR")
	aAdd(aRet, "ZMD_CPENC")

Return(aRet)


Method GDFieldProperty() Class TWOrcamentoClvl
Local aRet := {}
	
	::oGDField:Clear()

	::oGDField:AddField("ZMD_SUBITE")
	
	::oGDField:AddField("ZMD_DESC")
	::oGDField:FieldName("ZMD_DESC"):nSize := 100
	::oGDField:FieldName("ZMD_DESC"):cWhen := ".F."
	
	::oGDField:AddField("ZMD_UNIDAD")
	::oGDField:AddField("ZMD_QUANT")
	
	::oGDField:AddField("ZMD_MOEDA")
	::oGDField:FieldName("ZMD_MOEDA"):cValid := "U_BIAF169B()
	
	::oGDField:AddField("ZMD_VALOR")
	::oGDField:AddField("ZMD_TOTAL")
	::oGDField:AddField("ZMD_CPENC")

	::oGDField:AddField("SPACE")	
	
	aRet := ::oGDField:GetHeader()
	
Return(aRet)


Method GDFieldData() Class TWOrcamentoClvl
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	DBSelectArea("ZMD")
	
	::aGDRecNo := {}
	
	cSQL := " SELECT ZMD_CODREF, ZMD_SUBITE, ZMD_DESC, ZMD_UNIDAD, ZMD_QUANT, ZMD_MOEDA, ZMD_VALOR, ZMD_TOTAL, ZMD_CPENC, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZMD")
	cSQL += " WHERE ZMD_FILIAL = "+ ValToSQL(xFilial("ZMD"))
	
	If ::nFDOpc == 3

		cSQL += " AND ZMD_CODREF = '' "
	
	ElseIf ::nFDOpc == 2 .Or. ::nFDOpc == 4 .Or. ::nFDOpc == 5
	
		cSQL += " AND ZMD_CODREF = " + ValToSQL(::cCodigo)
			
	EndIf

	cSQL += " AND D_E_L_E_T_ = '' "	
	
	cSQL += "	ORDER BY ZMD_SUBITE "
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->ZMD_SUBITE, (cQry)->ZMD_DESC, (cQry)->ZMD_UNIDAD, (cQry)->ZMD_QUANT, (cQry)->ZMD_MOEDA, (cQry)->ZMD_VALOR, (cQry)->ZMD_TOTAL, (cQry)->ZMD_CPENC, Space(1), .F.})
		
		aAdd(::aGDRecNo, (cQry)->RECNO)
																
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method Valid() Class TWOrcamentoClvl
Local lRet := .T.
Local lExist := .T.
	
	lExist := aScan(::oGD:aCols, {|x| !Empty(x[nP_SUBITEM]) .And. x[Len(x)] == .F.}) > 0
	
	If lExist
	
		lRet := ::oGD:TudoOK()
			
	Else
	
		lRet := .F.
		
		MsgStop("É necessário informar ao menos um Subitem no cadastro.")
	
	EndIf
		
Return(lRet)


Method ValidField() Class TWOrcamentoClvl
Local lRet := .T.
Local cMField := ReadVar()
Local cMoeda := GdFieldGet("ZMD_MOEDA", n, .T.)
Local nValor := GdFieldGet("ZMD_VALOR", n, .T.)
Local nQuant := GdFieldGet("ZMD_QUANT", n, .T.)
Local nTotal := 0

	If cMField == "M->ZMD_VALOR" .Or. cMField == "M->ZMD_QUANT" .Or. cMField == "M->ZMD_MOEDA"
				
		If cMoeda == "2"
			
			nValor := nValor * M->ZMC_DOLAR
		
		ElseIf cMoeda == "3"
		
			nValor := nValor * M->ZMC_LIBRA
			
		ElseIf cMoeda == "4"
		
			nValor := nValor * M->ZMC_EURO	
		
		EndIf
		
		If nValor > 0
		
			nTotal := Round(nValor * nQuant, TamSX3("ZMD_TOTAL")[2])
			
			GdFieldPut("ZMD_TOTAL", nTotal, n)
			
		EndIf
		
	ElseIf cMField == "M->ZMD_SUBITE"

		oObjSub := TSubitemProjeto():New()

		oObjSub:cClvl := M->ZMC_CLVL
		oObjSub:cItemCta := M->ZMC_ITEMCT
		oObjSub:cSubItem := GdFieldGet("ZMD_SUBITE", n, .T.)
	
		If oObjSub:Validate()
			
			GdFieldPut("ZMD_DESC", oObjSub:GetDesc(), n)
			
		Else
			
			lRet := .F.
		
		EndIf
		
	EndIf	
			
Return(lRet)


Method Save() Class TWOrcamentoClvl
Local nLine := 0
Local nField := 0
	
	Begin Transaction

		If ::nFDOpc == 3 .Or. ::nFDOpc == 4
					
			If ::nFDOpc == 3
				
				ConfirmSx8()
				
				RecLock("ZMC", .T.)
				
					ZMC->ZMC_FILIAL := xFilial("ZMC")
					ZMC->ZMC_CODIGO := M->ZMC_CODIGO
					ZMC->ZMC_CLVL := M->ZMC_CLVL
					ZMC->ZMC_ITEMCT := M->ZMC_ITEMCT
					ZMC->ZMC_DOLAR := M->ZMC_DOLAR
					ZMC->ZMC_LIBRA := M->ZMC_LIBRA
					ZMC->ZMC_EURO := M->ZMC_EURO
									
				ZMC->(MsUnLock())
			
			EndIf					
			
			For nLine := 1 To Len(::oGD:aCols)
				
				If nLine <= Len(::aGDRecNo)
				
					ZMD->(DbGoTo(::aGDRecNo[nLine]))
		      
		      RecLock("ZMD", .F.)
		
						If ::oGD:aCols[nLine][Len(::oGD:aHeader)+1]
			   			
			   			ZMD->(DbDelete())
			   			
			      Else
			      	
			      	For nField := 1 To Len(::oGD:aHeader)			       		
			      					      		
		   					FieldPut(FieldPos(AllTrim(::oGD:aHeader[nField][2])), ::oGD:aCols[nLine][nField])
			       		
			       	Next
			       	
			      EndIf
		
					ZMD->(MsUnLock())
				
				Else
	
					If !::oGD:aCols[nLine][Len(::oGD:aHeader)+1] .And. !Empty(::oGD:aCols[nLine][nP_SUBITEM])
		   			
		   			RecLock("ZMD", .T.)
		      	
							ZMD->ZMD_FILIAL := xFilial("ZMD")
							ZMD->ZMD_CODREF := M->ZMC_CODIGO
		   				
		   				For nField := 1 To Len(::oGD:aHeader)
			       				   					
		   					FieldPut(FieldPos(AllTrim(::oGD:aHeader[nField][2])), ::oGD:aCols[nLine][nField])
			       		
			       	Next
			       								
						ZMD->(MsUnLock())
		                
		      EndIf
	
		   	EndIf
	
			Next
			
		ElseIf ::nFDOpc == 5
		
			DbSelectArea("ZMD")
			DbSetOrder(1)
			If ZMD->(DbSeek(xFilial("ZMD") + ::cCodigo))
			
				While !ZMD->(Eof()) .And. ZMD->ZMD_FILIAL == xFilial("ZMD") .And. ZMD->ZMD_CODREF == ::cCodigo
				
					RecLock("ZMD", .F.)
					
						ZMD->(DbDelete())
						
					ZMD->(MsUnLock())
					
					ZMD->(DbSkip())
				
				EndDo()
			
			EndIf
			
			DbSelectArea("ZMC")
			DbSetOrder(1)
			If ZMC->(DbSeek(xFilial("ZMC") + ::cCodigo))
				
				RecLock("ZMC", .F.)
				
					ZMC->(DbDelete())
					
				ZMC->(MsUnLock())
					
			EndIf

		EndIf
		
	End Transaction
					
Return()


Method Confirm() Class TWOrcamentoClvl

	If ::Valid()
			
		U_BIAMsgRun("Salvando dados...", "Aguarde!", {|| ::Save() })
		
		::oWindow:oOwner:End()
		
	EndIf 

Return()


Method Cancel(lClose) Class TWOrcamentoClvl

	Default lClose := .F.

	//If ::nFDOpc == 3

		//RollBackSx8()
		
	//EndIf

	If lClose
		
		::oWindow:oOwner:End()
		
	EndIf

Return()
Return()