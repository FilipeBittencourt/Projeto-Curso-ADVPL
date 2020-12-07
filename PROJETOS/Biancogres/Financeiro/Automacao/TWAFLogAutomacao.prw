#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAFLogAutomacao
@author Tiago Rossini Coradini
@since 11/03/2019
@version 1.0
@description Classe (tela) para visualizar log de automacao financeira
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Historico de Automação"

Class TWAFLogAutomacao From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data oBrw	
	Data oField
	Data cEmp
	Data cFil
	Data cTipo
	Data cTabela
	Data nIdTab
	
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()
	Method GetFieldProperty()
	Method GetFieldData()
	Method GetMethod(cID)
	Method GetDescription(cID)

EndClass


Method New() Class TWAFLogAutomacao

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::oBrw := Nil	
	::oField := TGDField():New()
	
	::cEmp := cEmpAnt
	::cFil := cFilAnt
	::cTipo := "P"
	::cTabela := ""
	::nIdTab := 0

Return()


Method LoadInterface() Class TWAFLogAutomacao

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAFLogAutomacao
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3] / 1.2)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()

Return()


Method LoadContainer() Class TWAFLogAutomacao

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWAFLogAutomacao
Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWAFLogAutomacao	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetFieldProperty() Class TWAFLogAutomacao

	::oField:Clear()

	::oField:AddField("ZK2_IDPROC")
	::oField:FieldName("ZK2_IDPROC"):cTitle := "Processo"
		
	::oField:AddField("ZK2_DTINI")
	::oField:AddField("ZK2_HRINI")	
	::oField:AddField("ZK2_DTFIN")
	::oField:AddField("ZK2_HRFIN")

	::oField:AddField("ZK2_RETORI")
	::oField:FieldName("ZK2_RETORI"):cTitle := "Historico"
	
	::oField:AddField("ZK2_RETMEN")
	::oField:FieldName("ZK2_RETMEN"):cTitle := "Mensagem"

	::oField:AddField("_SPACE_")	

Return(::oField:GetHeader())


Method GetFieldData() Class TWAFLogAutomacao
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT ZK2_IDPROC, ZK2_DTINI, ZK2_HRINI, ZK2_DTFIN, ZK2_HRFIN, ZK2_METODO, ZK2_RETMEN, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZK2")
	cSQL += " WHERE ZK2_FILIAL = "+ ValToSQL(xFilial("ZK2"))
	cSQL += " AND ZK2_EMP = "+ ValToSQL(::cEmp)
	cSQL += " AND ZK2_FIL = "+ ValToSQL(::cFil)
	cSQL += " AND ZK2_OPERAC = "+ ValToSQL(::cTipo)
	cSQL += " AND ZK2_IDPROC IN "
	cSQL += " ( "
	cSQL += " 	SELECT ZK2_IDPROC "
	cSQL += " 	FROM "+ RetSQLName("ZK2")
	cSQL += " 	WHERE ZK2_EMP = "+ ValToSQL(::cEmp)
	cSQL += " 	AND ZK2_FIL = "+ ValToSQL(::cFil)
	cSQL += " 	AND ZK2_OPERAC = "+ ValToSQL(::cTipo)
	cSQL += " 	AND ZK2_TABELA = "+ ValToSQL(::cTabela)
	cSQL += " 	AND ZK2_IDTAB = "+ ValToSQL(::nIdTab)
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND ZK2_TABELA = '' "
	cSQL += " AND ZK2_IDTAB = 0 "
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "
		
	cSQL += " SELECT ZK2_IDPROC, ZK2_DTINI, ZK2_HRINI, ZK2_DTFIN, ZK2_HRFIN, ZK2_METODO, ZK2_RETMEN, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZK2")
	cSQL += " WHERE ZK2_FILIAL = "+ ValToSQL(xFilial("ZK2"))
	cSQL += " AND ZK2_EMP = "+ ValToSQL(::cEmp)
	cSQL += " AND ZK2_FIL = "+ ValToSQL(::cFil)
	cSQL += " AND ZK2_OPERAC = "+ ValToSQL(::cTipo)
	cSQL += " AND ZK2_TABELA = "+ ValToSQL(::cTabela)
	cSQL += " AND ZK2_IDTAB = "+ ValToSQL(::nIdTab)
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " UNION ALL "

	cSQL += " SELECT ZK2_IDPROC, ZK2_DTINI, ZK2_HRINI, ZK2_DTFIN, ZK2_HRFIN, ZK2_METODO, ZK2_RETMEN, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM "+ RetSQLName("ZK2")
	cSQL += " WHERE ZK2_FILIAL = "+ ValToSQL(xFilial("ZK2"))
	cSQL += " AND ZK2_EMP = "+ ValToSQL(::cEmp)
	cSQL += " AND ZK2_FIL = "+ ValToSQL(::cFil)
	cSQL += " AND ZK2_OPERAC = "+ ValToSQL(::cTipo)
	cSQL += " AND ZK2_TABELA = "+ ValToSQL(RetSQLName("ZK3"))
	cSQL += " AND ZK2_IDTAB IN "
	cSQL += " ( "
	cSQL += " 	SELECT R_E_C_N_O_ "
	cSQL += " 	FROM "+ RetSQLName("ZK3")
	cSQL += " 	WHERE ZK3_EMP = "+ ValToSQL(::cEmp)
	cSQL += " 	AND ZK3_FIL = "+ ValToSQL(::cFil)
	cSQL += " 	AND ZK3_BORDE >= (SELECT E2_NUMBOR FROM "+ RetSQLName("SE2") + " WHERE R_E_C_N_O_ = "+ ValToSQL(::nIdTab) + " AND D_E_L_E_T_ = '') "
	cSQL += " 	AND ZK3_BORATE <= (SELECT E2_NUMBOR FROM "+ RetSQLName("SE2") + " WHERE R_E_C_N_O_ = "+ ValToSQL(::nIdTab) + " AND D_E_L_E_T_ = '') "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY R_E_C_N_O_ "	

	TcQuery cSQL New Alias (cQry)	
	
	While !(cQry)->(Eof())	
						
		If Len(aRet) > 0 .And. aScan(aRet, {|x| x[1] == (cQry)->ZK2_IDPROC}) == 0
			
			aAdd(aRet, {"", "", "", "", "", "", "", "", .F.})
			
		EndIf
		
		aAdd(aRet, {(cQry)->ZK2_IDPROC, dToC(sToD((cQry)->ZK2_DTINI)), (cQry)->ZK2_HRINI, dToC(sToD((cQry)->ZK2_DTFIN)), (cQry)->ZK2_HRFIN, ::GetMethod(AllTrim((cQry)->ZK2_METODO)), (cQry)->ZK2_RETMEN, "", .F.})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetMethod(cID) Class TWAFLogAutomacao
Local cRet := ""	

	If "CON_DDA" $ cID
			
		If cID == "I_CON_DDA"
		
			cAux := "Início"
		
		ElseIf cID == "F_CON_DDA"
		
			cAux := "Fim"
		
		ElseIf cID == "S_CON_DDA"
		
			cAux := "Conciliado"
			
		EndIf
		
		cRet := "Conciliação DDA - [" + cAux + "]"

	ElseIf cID $ "I_REM_LOT/F_REM_LOT"
		
		cRet := "Remessa Automatica - [" + If (SubStr(cID, 1, 1) == "I", "Início", "Fim") + "]"
		
	ElseIf "SEL_TIT" $ cID
			
		If cID == "I_SEL_TIT"
		
			cAux := "Início"
		
		ElseIf cID == "F_SEL_TIT"
		
			cAux := "Fim"
		
		ElseIf cID == "S_SEL_TIT"
		
			cAux := "OK"
			
		EndIf
		
		cRet := "Seleção de Título - [" + cAux + "]"
	
	ElseIf "_RCB" $ cID
			
		If cID == "I_RCB"
		
			cAux := "Início"
		
		ElseIf cID == "F_RCB"
		
			cAux := "Fim"
		
		ElseIf cID == "VG_RCB"
		
			cAux := "Valida Grupo"
		
		ElseIf cID == "VR_RCB"
			
			cAux := "Valida Regra"
			
		ElseIf cID == "S_RCB"
		
			cAux := "Regra Válida"

		ElseIf cID == "CP_NVG_RCB" .Or. cID == "CP_NVR_RCB"
		
			cAux := "Regra Inválida"
		
		Else
		
			cAux := "NDA"
		
		EndIf
		
		cRet := "Regra Comuniação - [" + cAux + "]"
		
	ElseIf "_BOR" $ cID
			
		If cID == "I_BOR"
		
			cAux := "Início"
		
		ElseIf cID == "F_BOR"
		
			cAux := "Fim"
		
		ElseIf cID == "CP_S_BOR"
		
			cAux := "Gerado"
			
		EndIf
		
		cRet := "Bordero - [" + cAux + "]"
		
	ElseIf "CP_TIT_" $ cID
	
		cRet := "Ocorrência"

	Else
		
		cRet := "NDA"
		
	EndIf
	
Return(cRet)


Method GetDescription(cID) Class TWAFLogAutomacao
Local cRet := ""


Return(cRet)