#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWPainelPoliticaCredito
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe (Tela) Painel de Política de Crédito
@type class
/*/

#DEFINE TIT_WND "Painel de Política de Crédito"


Class TWPainelPoliticaCredito From LongClassName
	
	Data oWindow // Janela principal - FWDialogModal 
	Data oContainer	// Divisor de janelas - FWFormContainer 
	Data cPolBox // Identificador do cabecalho da janela de Politica de credito
	Data cVarBox // Identificador dos itens da janela de variaveis
	Data cProBox // Identificador dos itens da janela de processos Rocket
	Data cRetBox // Identificador dos itens da janela de retono de processos Rocket

	Data oFD // Field editor - MsMGet
	Data cFDTable // Tabela
	Data nFDOpc // Opcao do menu
	Data nFDRecNo // RecNo
	Data oMGField // Estrutura dos campos do MsMGet - TMGField
	Data cCodPro	
	
	Data oGDVar // Grid - MsNewGetDados
	Data oGDVarField // Estrutura dos campos do grid - TGDField

	Data oGDPro // Grid - MsNewGetDados
	Data oGDProField // Estrutura dos campos do grid - TGDField

	Data oGDRet // Grid - MsNewGetDados
	Data oGDRetField // Estrutura dos campos do grid - TGDField
	
	Data lF10 // Consulta F10

	Method New() Constructor
	Method LoadInterface()	
	Method LoadWindow()
	Method LoadContainer()
	Method LoadHeader(oWnd)
	Method LoadBrowser(oWnd)
	Method Activate()	
	Method EditableField()
	Method VarFieldProperty()
	Method VarFieldData()
	Method ProFieldProperty()
	Method ProFieldData()
	Method RetFieldProperty()
	Method RetFieldData()	
			
EndClass


Method New() Class TWPainelPoliticaCredito
		
	::oWindow := Nil
	::oContainer := Nil
	::cPolBox := ""
	::cVarBox := ""
	::cProBox := ""
	::cRetBox := ""

	::oFD := Nil
	::cFDTable := "ZM0"
	::nFDOpc := 2
	::nFDRecNo := ZM0->(RecNo())
	::oMGField := Nil
	::cCodPro := ZM0->ZM0_CODIGO

	::oGDVar := Nil
	::oGDVarField := TGDField():New()

	::oGDPro := Nil
	::oGDProField := TGDField():New()

	::oGDRet := Nil
	::oGDRetField := TGDField():New()	 

	::lF10 := .F.

Return()


Method LoadInterface() Class TWPainelPoliticaCredito
	
	::LoadWindow()
	
	::LoadContainer()	
	
	::LoadHeader()
	
	::LoadBrowser()	
			
Return()


Method LoadWindow() Class TWPainelPoliticaCredito
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()
							
Return()


Method LoadContainer() Class TWPainelPoliticaCredito

	::oContainer := FWFormContainer():New()
	
	::cPolBox := ::oContainer:CreateHorizontalBox(20)
	
	If !::lF10
	
		::cVarBox := ::oContainer:CreateHorizontalBox(25)
		
		::cProBox := ::oContainer:CreateHorizontalBox(35)
	
		::cRetBox := ::oContainer:CreateHorizontalBox(20)
	
	Else
	
		::cVarBox := ::oContainer:CreateHorizontalBox(60)
	
		::cRetBox := ::oContainer:CreateHorizontalBox(20)		
	
	EndIf	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadHeader() Class TWPainelPoliticaCredito

	::oFD := MsMGet():New(::cFDTable, ::nFDRecNo, ::nFDOpc,,,,,{0, 0 , 0, 0},,,,,,::oContainer:GetPanel(::cPolBox))
	::oFD:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
			
Return()


Method LoadBrowser() Class TWPainelPoliticaCredito
Local cVldDef := "AllwaysTrue"
Local nMaxLine := 1000

	::oGDVar := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::EditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cVarBox), ::VarFieldProperty(), ::VarFieldData())
	::oGDVar:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oGDVar:oBrowse:lVScroll := .T.
	::oGDVar:oBrowse:lHScroll := .T.
	
	::oGDVar:Disable()

	If !::lF10
	
		::oGDPro := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::EditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cProBox), ::ProFieldProperty(), ::ProFieldData())
		::oGDPro:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		::oGDPro:oBrowse:lVScroll := .T.
		::oGDPro:oBrowse:lHScroll := .T.
		
		::oGDPro:Disable()
		
	EndIf
	
	::oGDREt := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::EditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cREtBox), ::RetFieldProperty(), ::RetFieldData())
	::oGDREt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oGDREt:oBrowse:lVScroll := .T.
	::oGDREt:oBrowse:lHScroll := .T.
	
	::oGDREt:Disable()
			
Return()


Method Activate() Class TWPainelPoliticaCredito
	
	::LoadInterface()
	
	::oWindow:Activate()
		
Return()


Method EditableField() Class TWPainelPoliticaCredito
Local aRet := {}

Return(aRet)


Method VarFieldProperty() Class TWPainelPoliticaCredito
Local aRet := {}
	
	::oGDVarField:Clear()

	::oGDVarField:AddField("ZM1_CLIENT")
	::oGDVarField:AddField("ZM1_LOJA")
	::oGDVarField:AddField("ZM1_CNPJ")
	::oGDVarField:AddField("ZM1_DTPRCO")
	::oGDVarField:AddField("ZM1_LCATU")
	::oGDVarField:AddField("ZM1_QTVA07")
	::oGDVarField:AddField("ZM1_VLVA08")
	::oGDVarField:AddField("ZM1_QTVA09")	
	::oGDVarField:AddField("ZM1_VLVA10")
	::oGDVarField:AddField("ZM1_QTVA11")
	::oGDVarField:AddField("ZM1_VLVA12")
	::oGDVarField:AddField("ZM1_QTVA13")
	::oGDVarField:AddField("ZM1_VLVA14")
	::oGDVarField:AddField("ZM1_QTVA15")
	::oGDVarField:AddField("ZM1_VLVA16")
	::oGDVarField:AddField("ZM1_QTVA17")
	::oGDVarField:AddField("ZM1_VLVA18")
	::oGDVarField:AddField("ZM1_VLVA19")
	::oGDVarField:AddField("ZM1_QTVA20")
	::oGDVarField:AddField("ZM1_VLVA21")
	::oGDVarField:AddField("ZM1_QTVA22")
	::oGDVarField:AddField("ZM1_VLVA23")
	::oGDVarField:AddField("ZM1_VARC01")
	::oGDVarField:AddField("ZM1_VARC02")
	::oGDVarField:AddField("ZM1_VARC03")
	::oGDVarField:AddField("ZM1_VARC04")
	::oGDVarField:AddField("ZM1_VARC05")
	::oGDVarField:AddField("ZM1_VARC06")
	::oGDVarField:AddField("ZM1_VARC07")
	::oGDVarField:AddField("ZM1_VARC08")
	::oGDVarField:AddField("ZM1_VARC09")
	::oGDVarField:AddField("ZM1_VARC10")
	::oGDVarField:AddField("ZM1_VARC11")			

	::oGDVarField:AddField("SPACE")	
	
	aRet := ::oGDVarField:GetHeader()
	
Return(aRet)


Method VarFieldData() Class TWPainelPoliticaCredito
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT * "
	cSQL += " FROM "+ RetSQLName("ZM1")
	cSQL += " WHERE ZM1_FILIAL = "+ ValToSQL(xFilial("ZM1"))
	cSQL += " AND ZM1_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "		
	cSQL += " ORDER BY R_E_C_N_O_ "		
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->ZM1_CLIENT, (cQry)->ZM1_LOJA, (cQry)->ZM1_CNPJ, dToC(sToD((cQry)->ZM1_DTPRCO)), (cQry)->ZM1_LCATU, (cQry)->ZM1_QTVA07, (cQry)->ZM1_VLVA08, (cQry)->ZM1_QTVA09,; 	
								(cQry)->ZM1_VLVA10, (cQry)->ZM1_QTVA11, (cQry)->ZM1_VLVA12, (cQry)->ZM1_QTVA13, (cQry)->ZM1_VLVA14, (cQry)->ZM1_QTVA15, (cQry)->ZM1_VLVA16, (cQry)->ZM1_QTVA17,; 
								(cQry)->ZM1_VLVA18, (cQry)->ZM1_VLVA19, (cQry)->ZM1_QTVA20, (cQry)->ZM1_VLVA21, (cQry)->ZM1_QTVA22, (cQry)->ZM1_VLVA23, (cQry)->ZM1_VARC01, (cQry)->ZM1_VARC02,; 
								(cQry)->ZM1_VARC03, (cQry)->ZM1_VARC04, (cQry)->ZM1_VARC05, (cQry)->ZM1_VARC06, (cQry)->ZM1_VARC07, (cQry)->ZM1_VARC08, (cQry)->ZM1_VARC09, (cQry)->ZM1_VARC10,; 
								(cQry)->ZM1_VARC11, Space(1), .F.})
																
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method ProFieldProperty() Class TWPainelPoliticaCredito
Local aRet := {}
	
	::oGDProField:Clear()
	
	::oGDProField:AddField("ZM3_DATA")
	::oGDProField:AddField("ZM3_HORA")
	::oGDProField:AddField("ZM3_HASH")
	::oGDProField:AddField("ZM3_TICKET")
	
	::oGDProField:AddField("ZM3_STATUS")
	::oGDProField:FieldName("ZM3_STATUS"):cCbox := "ER=Erro no Processamento;PR=Em Processamento;PD=Processo Disponível;PF=Processo Finalizad;NE=Ticke não Existente;URL=Mesa de Análise"
	
	::oGDProField:AddField("ZM3_TIPO")

	::oGDProField:AddField("SPACE")	
	
	aRet := ::oGDProField:GetHeader()
	
Return(aRet)


Method ProFieldData() Class TWPainelPoliticaCredito
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT * "
	cSQL += " FROM "+ RetSQLName("ZM3")
	cSQL += " WHERE ZM3_FILIAL = "+ ValToSQL(xFilial("ZM3"))
	cSQL += " AND ZM3_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "		
	cSQL += " ORDER BY R_E_C_N_O_ "		
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {dToC(sToD((cQry)->ZM3_DATA)), (cQry)->ZM3_HORA, (cQry)->ZM3_HASH, (cQry)->ZM3_TICKET, AllTrim((cQry)->ZM3_STATUS), (cQry)->ZM3_TIPO, Space(1), .F.})

		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method RetFieldProperty() Class TWPainelPoliticaCredito
Local aRet := {}
	
	::oGDRetField:Clear()

	::oGDRetField:AddField("ZM4_DATA")
	::oGDRetField:AddField("ZM4_HORA")
	::oGDRetField:AddField("ZM4_VLLCA")
	::oGDRetField:AddField("ZM4_VLLCS")
	::oGDRetField:AddField("ZM4_VLLCAA")
	::oGDRetField:AddField("ZM4_VLLCSA")
	::oGDRetField:AddField("ZM4_VLRIS")
	::oGDRetField:AddField("ZM4_VLRIA")	
	::oGDRetField:AddField("ZM4_VLRAC")
	::oGDRetField:AddField("ZM4_VLRAA")
	::oGDRetField:AddField("ZM4_VLMC")
	::oGDRetField:AddField("ZM4_VLVA")
	::oGDRetField:AddField("ZM4_DTVLC")
	::oGDRetField:AddField("ZM4_PAC")

	::oGDRetField:AddField("SPACE")	
	
	aRet := ::oGDRetField:GetHeader()
	
Return(aRet)


Method RetFieldData() Class TWPainelPoliticaCredito
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT * "
	cSQL += " FROM "+ RetSQLName("ZM4")
	cSQL += " WHERE ZM4_FILIAL = "+ ValToSQL(xFilial("ZM4"))
	cSQL += " AND ZM4_CODPRO = "+ ValToSQL(::cCodPro)
	cSQL += " AND D_E_L_E_T_ = '' "		
	cSQL += " ORDER BY R_E_C_N_O_ "		
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {dToC(sToD((cQry)->ZM4_DATA)), (cQry)->ZM4_HORA, (cQry)->ZM4_VLLCA, (cQry)->ZM4_VLLCS, (cQry)->ZM4_VLLCAA, (cQry)->ZM4_VLLCSA, (cQry)->ZM4_VLRIS, (cQry)->ZM4_VLRIA,; 	
								(cQry)->ZM4_VLRAC, (cQry)->ZM4_VLRAA, (cQry)->ZM4_VLMC, (cQry)->ZM4_VLVA, dToC(sToD((cQry)->ZM4_DTVLC)), (cQry)->ZM4_PAC, Space(1), .F.})

		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)
