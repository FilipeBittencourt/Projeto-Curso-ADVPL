#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAtualizaSolicitacaoCompra
@author Tiago Rossini Coradini
@since 20/08/2018
@version 1.0
@description Classe (tela) para atualizar informações da solicitação de compra
@obs Ticket: 7663
@type class
/*/

#DEFINE TIT_WND "Atualização de Produto Importado"

#DEFINE nF_IMPORT 1
#DEFINE nF_ITEM 2
#DEFINE nF_PRODUTO 3
#DEFINE nF_DESC 4

Class TWAtualizaSolicitacaoCompra From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data oBrw	
	Data oField
	Data aAField
	 
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetFieldProperty()
	Method GetFieldData()  
	Method Confirm()	
	
EndClass


Method New() Class TWAtualizaSolicitacaoCompra
	
	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::oBrw := Nil	
	::oField := TGDField():New()
	::aAField := {}
		
Return()


Method LoadInterface() Class TWAtualizaSolicitacaoCompra

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAtualizaSolicitacaoCompra
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3] / 1.5)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddOKButton({|| ::Confirm() })
	::oWindow:AddCloseButton()

Return()


Method LoadContainer() Class TWAtualizaSolicitacaoCompra

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWAtualizaSolicitacaoCompra
Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::aAField,,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWAtualizaSolicitacaoCompra	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetFieldProperty() Class TWAtualizaSolicitacaoCompra
	
	::oField:Clear()	
	::oField:AddField("C1_IMPORT")
	::oField:AddField("C1_ITEM")
	::oField:AddField("C1_PRODUTO")	
	::oField:AddField("C1_DESCRI")		
	::oField:AddField("_SPACE_")
	
	// Campos que podem ser alterados
	aAdd(::aAField, "C1_IMPORT")	

Return(::oField:GetHeader())


Method GetFieldData() Class TWAtualizaSolicitacaoCompra
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	
	
	cSQL := " SELECT C1_IMPORT, C1_ITEM, C1_PRODUTO, LTRIM(C1_DESCRI) AS C1_DESCRI " 
	cSQL += " FROM "+ RetSQLName("SC1")
	cSQL += " WHERE C1_FILIAL = "+ ValToSQL(xFilial("SC1"))
	cSQL += " AND C1_NUM = "+ ValToSQL(SC1->C1_NUM)
	cSQL += " AND C1_QUJE = 0 "
	cSQL += " AND C1_COTACAO = '' "
	cSQL += " AND C1_APROV IN ('', 'L') "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C1_ITEM " 

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())	
				
		aAdd(aRet, {(cQry)->C1_IMPORT, (cQry)->C1_ITEM, AllTrim((cQry)->C1_PRODUTO), AllTrim((cQry)->C1_DESCRI), Space(1), .F.})
								 								
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method Confirm() Class TWAtualizaSolicitacaoCompra
Local aArea := GetArea()
Local cNumSol := SC1->C1_NUM
Local nLine := 0
	
	Begin Transaction
	
		For nLine := 1 To Len(::oBrw:aCols)
	  
			DbSelectArea("SC1")
			DbSetOrder(1)
			If SC1->(DbSeek(xFilial("SC1") + cNumSol + ::oBrw:aCols[nLine, nF_ITEM] ))			
				
				RecLock("SC1", .F.)
					
					SC1->C1_IMPORT := ::oBrw:aCols[nLine, nF_IMPORT]
					If ::oBrw:aCols[nLine, nF_IMPORT] == 'S'
					SC1->C1_COTACAO = 'IMPORT'
					EndIf
					
				SC1->(MsUnLock())
	                
	    EndIf
	  
	  Next
	  
	End Transaction
			
	RestArea(aArea)
	
	::oWindow:oOwner:End()
	
Return()