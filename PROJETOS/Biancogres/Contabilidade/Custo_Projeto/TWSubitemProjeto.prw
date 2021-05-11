#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWSubitemProjeto
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar os custos dos projetos - Tabela de cadastro de Subitem de Projeto
@obs Projeto: D-01 - Custos dos Projetos
@type Class
/*/

#DEFINE TIT_WND "Subitem Projeto"

#DEFINE nP_SUBITEM 1
#DEFINE nP_DESC 2

Class TWSubitemProjeto From LongClassName

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
	Method ValidItem()
	Method ValidSubitem()	
	Method Save()	
	Method Confirm()
	Method Cancel(lClose)
			
EndClass


Method New() Class TWSubitemProjeto
		
	::oWindow := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cItemBox := ""

	::oFD := Nil
	::cFDTable := "ZMA"
	::nFDOpc := 2
	::nFDRecNo := ZMA->(RecNo())
	::oMGField := Nil

	::oGD := Nil
	::aGDAField := {}
	::oGDField := TGDField():New()
	::aGDRecNo := {}

	::cCodigo := Space(TamSx3("ZMA_CODIGO")[1])
	::cClvl := Space(TamSx3("ZMA_CLVL")[1])	
	::cItemCta := Space(TamSx3("ZMA_ITEMCT")[1])

Return()


Method LoadInterface() Class TWSubitemProjeto
	
	::LoadWindow()
	
	::LoadContainer()	
	
	::LoadHeader()
	
	::LoadBrowser()	
			
Return()


Method LoadWindow() Class TWSubitemProjeto
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


Method GetOperation() Class TWSubitemProjeto
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


Method LoadContainer() Class TWSubitemProjeto

	::oContainer := FWFormContainer():New()
	
	::cHeaderBox := ::oContainer:CreateHorizontalBox(20)
	
	::cItemBox := ::oContainer:CreateHorizontalBox(80)
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadHeader() Class TWSubitemProjeto

	::oFD := MsMGet():New(::cFDTable, ::nFDRecNo, ::nFDOpc,,,,,{0, 0 , 0, 0},,,,,,::oContainer:GetPanel(::cHeaderBox))
	::oFD:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
			
Return()


Method LoadBrowser() Class TWSubitemProjeto
Local cVldDef := "AllwaysTrue"
Local nMaxLine := 1000

	//RegToMemory(::cFDTable, ::nFDOpc == 3)
	
	::oGD := MsNewGetDados():New(0, 0, 0, 0, GD_INSERT + GD_UPDATE + GD_DELETE, cVldDef, cVldDef, "", ::GDEditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cItemBox), ::GDFieldProperty(), ::GDFieldData())
	::oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oGD:oBrowse:lVScroll := .T.
	::oGD:oBrowse:lHScroll := .T.
	
	::oGD:oBrowse:Refresh()
	
	If ::nFDOpc == 2 .Or. ::nFDOpc == 5
		
		::oGD:Disable()
		
	EndIf	
	
Return()


Method Activate() Class TWSubitemProjeto
	
	::LoadInterface()
	
	::oWindow:bInit := {|| DbSelectArea(::cFDTable), RegToMemory(::cFDTable, ::nFDOpc == 3), ::MGFieldData(), ::oFD:Refresh()}
	
	::oWindow:Activate()

	::Cancel()
		
Return()


Method MGFieldProperty() Class TWSubitemProjeto
Local aRet := {}
	
Return(aRet)


Method MGFieldData() Class TWSubitemProjeto	
	
	
Return()


Method GDEditableField() Class TWSubitemProjeto
Local aRet := {}

	aAdd(aRet, "ZMB_SUBITE")
	aAdd(aRet, "ZMB_DESC")

Return(aRet)


Method GDFieldProperty() Class TWSubitemProjeto
Local aRet := {}
	
	::oGDField:Clear()

	::oGDField:AddField("ZMB_SUBITE")
	::oGDField:AddField("ZMB_DESC")

	::oGDField:AddField("SPACE")	
	
	aRet := ::oGDField:GetHeader()
	
Return(aRet)


Method GDFieldData() Class TWSubitemProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	DBSelectArea("ZMB")
	
	::aGDRecNo := {}
	
	cSQL := " SELECT ZMB_CODREF, ZMB_SUBITE, ZMB_DESC, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZMB")
	cSQL += " WHERE ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB"))
	
	If ::nFDOpc == 3

		cSQL += " AND ZMB_CODREF = '' "
	
	ElseIf ::nFDOpc == 2 .Or. ::nFDOpc == 4 .Or. ::nFDOpc == 5
	
		cSQL += " AND ZMB_CODREF = " + ValToSQL(::cCodigo)
			
	EndIf

	cSQL += " AND D_E_L_E_T_ = '' "	
	
	cSQL += "	ORDER BY ZMB_SUBITE "
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->ZMB_SUBITE, (cQry)->ZMB_DESC, Space(1), .F.})
		
		aAdd(::aGDRecNo, (cQry)->RECNO)
																
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method Valid() Class TWSubitemProjeto
Local lRet := .T.
Local nCount := 0
Local lExist := .T.

	lRet := ::ValidItem() .And. ::ValidSubitem()
	
	If lRet

		lExist := aScan(::oGD:aCols, {|x| !Empty(x[nP_SUBITEM]) .And. x[Len(x)] == .F.}) > 0
		
		If lExist
		
			lRet := ::oGD:TudoOK()
				
		Else
		
			lRet := .F.
			
			MsgStop("É necessário informar ao menos um Subitem no cadastro.")
		
		EndIf
		
	EndIf
			
Return(lRet)


Method ValidItem() Class TWSubitemProjeto
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
	
	If ::nFDOpc == 3

		cSQL := " SELECT ISNULL(ZMA_CODIGO, '') AS ZMA_CODIGO "
		cSQL += " FROM "+ RetSQLName("ZMA")
		cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA")) 
		cSQL += " AND ZMA_CLVL = " + ValToSQL(M->ZMA_CLVL)
		cSQL += " AND ZMA_ITEMCT = " + ValToSQL(M->ZMA_ITEMCT)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		If !Empty((cQry)->ZMA_CODIGO)
	
			lRet := .F.
			
			MsgStop("A classe de valor: "+ AllTrim(M->ZMA_CLVL) +" e o Item: "+ AllTrim(M->ZMA_ITEMCT) +" já foram cadastrados, favor verificar o código: " + (cQry)->ZMA_CODIGO)
			
		EndIf
		
		(cQry)->(DbCloseArea())
		
	EndIf

Return(lRet)


Method ValidSubitem() Class TWSubitemProjeto
Local lRet := .T.
Local nCount := 1
		
	While lRet .And. nCount <= Len(::oGD:aCols)

		If !GdDeleted(nCount, ::oGD:aHeader, ::oGD:aCols)

			lRet := aScan(::oGD:aCols, {|x| Upper(AllTrim(x[nP_SUBITEM])) == Upper(AllTrim(::oGD:aCols[nCount, nP_SUBITEM])) .And. x[Len(x)] == .F.}) == nCount
			
		EndIf
		
		nCount++
	
	EndDo()
	
	If !lRet
			
		MsgStop("Existem Subitens duplicados, favor verificar.")
	
	EndIf

Return(lRet)


Method Save() Class TWSubitemProjeto
Local nLine := 0
Local nField := 0
	
	Begin Transaction

		If ::nFDOpc == 3 .Or. ::nFDOpc == 4
					
			If ::nFDOpc == 3
				
				ConfirmSx8()
				
				RecLock("ZMA", .T.)
				
					ZMA->ZMA_FILIAL := xFilial("ZMA")
					ZMA->ZMA_CODIGO := M->ZMA_CODIGO
					ZMA->ZMA_CLVL := M->ZMA_CLVL
					ZMA->ZMA_ITEMCT := M->ZMA_ITEMCT
				
				ZMA->(MsUnLock())
			
			EndIf					
			
			For nLine := 1 To Len(::oGD:aCols)
				
				If nLine <= Len(::aGDRecNo)
				
					ZMB->(DbGoTo(::aGDRecNo[nLine]))
		      
		      RecLock("ZMB", .F.)
		
						If ::oGD:aCols[nLine][Len(::oGD:aHeader)+1]
			   			
			   			ZMB->(DbDelete())
			   			
			      Else
			      	
			      	For nField := 1 To Len(::oGD:aHeader)			       		
			      					      		
		   					FieldPut(FieldPos(AllTrim(::oGD:aHeader[nField][2])), ::oGD:aCols[nLine][nField])
			       		
			       	Next
			       	
			      EndIf
		
					ZMB->(MsUnLock())
				
				Else
	
					If !::oGD:aCols[nLine][Len(::oGD:aHeader)+1] .And. !Empty(::oGD:aCols[nLine][nP_SUBITEM])
		   			
		   			RecLock("ZMB", .T.)
		      	
							ZMB->ZMB_FILIAL := xFilial("ZMB")
							ZMB->ZMB_CODREF := M->ZMA_CODIGO
		   				
		   				For nField := 1 To Len(::oGD:aHeader)
			       				   					
		   					FieldPut(FieldPos(AllTrim(::oGD:aHeader[nField][2])), ::oGD:aCols[nLine][nField])
			       		
			       	Next
			       								
						ZMB->(MsUnLock())
		                
		      EndIf
	
		   	EndIf
	
			Next
			
		ElseIf ::nFDOpc == 5
		
			DbSelectArea("ZMB")
			DbSetOrder(1)
			If ZMB->(DbSeek(xFilial("ZMB") + ::cCodigo))
			
				While !ZMB->(Eof()) .And. ZMB->ZMB_FILIAL == xFilial("ZMB") .And. ZMB->ZMB_CODREF == ::cCodigo
				
					RecLock("ZMB", .F.)
					
						ZMB->(DbDelete())
						
					ZMB->(MsUnLock())
					
					ZMB->(DbSkip())
				
				EndDo()
			
			EndIf
			
			DbSelectArea("ZMA")
			DbSetOrder(1)
			If ZMA->(DbSeek(xFilial("ZMA") + ::cCodigo))
				
				RecLock("ZMA", .F.)
				
					ZMA->(DbDelete())
					
				ZMA->(MsUnLock())
					
			EndIf

		EndIf
		
	End Transaction
					
Return()


Method Confirm() Class TWSubitemProjeto

	If ::Valid()
			
		U_BIAMsgRun("Salvando dados...", "Aguarde!", {|| ::Save() })
		
		::oWindow:oOwner:End()
		
	EndIf 

Return()


Method Cancel(lClose) Class TWSubitemProjeto

	Default lClose := .F.

	//If ::nFDOpc == 3

		//RollBackSx8()
		
	//EndIf

	If lClose
		
		::oWindow:oOwner:End()
		
	EndIf

Return()