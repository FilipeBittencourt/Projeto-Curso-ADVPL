#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAFReenvioRemessaReceber
@author Tiago Rossini Coradini
@since 15/01/2019
@version 1.0
@description Classe (tela) selecao de boletos a receber para renvio
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Reenvio de Boletos a Receber"

#DEFINE nP_MARK 1
#DEFINE nP_LEG 2
#DEFINE nP_JUROS 3
#DEFINE nP_PJUROS 4
#DEFINE nP_DTREF 5
#DEFINE nP_RECNO 22


Class TWAFReenvioRemessaReceber From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data cChk
	Data cUnChk
	Data oChk
	Data lMarkAll	
	Data oBrw	
	Data oField
	Data lConfirm
	
	Data cPrefixoDe // Prefixo De
	Data cPrefixoAte // Prefixo De
	Data cNumeroDe // Numero De
	Data cNumeroAte // Numero Ate
	Data cCliDe // Cliente De
	Data cCliAte // Cliente Ate
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dReferenca // Nova data de vencimento	
	
	Method New(oParam) Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetEditableField()
	Method GetFieldProperty()
	Method GetFieldData()
	Method GetLegend(dVencto, dDate, cCart)
	Method GetCalc(dVencto, dDate)
	Method GetFilCar()
	Method BrowserClick()
	Method Mark()
	Method MarkAll()
	Method ExistMark()
	Method GetMark()
	Method Confirm()
	Method Resend()

EndClass


Method New(oParam) Class TWAFReenvioRemessaReceber

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	::oChk := Nil
	::lMarkAll := .F.
	::oBrw := Nil	
	::oField := TGDField():New()
	::lConfirm := .F.

	::cPrefixoDe := oParam:cPrefixoDe
	::cPrefixoAte := oParam:cPrefixoAte
	::cNumeroDe := oParam:cNumeroDe
	::cNumeroAte := oParam:cNumeroAte
	::cCliDe := oParam:cCliDe
	::cCliAte := oParam:cCliAte
	::dVenctoDe := oParam:dVenctoDe
	::dVenctoAte := oParam:dVenctoAte
	::dReferenca := oParam:dReferenca

Return()


Method LoadInterface() Class TWAFReenvioRemessaReceber

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAFReenvioRemessaReceber
Local aCoors := MsAdvSize()
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddOKButton({|| ::Confirm() })
	::oWindow:AddCloseButton()

Return()


Method LoadContainer() Class TWAFReenvioRemessaReceber

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWAFReenvioRemessaReceber
Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oChk := TCheckBox():Create(::oPanel)
	::oChk:cName := 'oChk'
	::oChk:cCaption := "Marca / Desmarca todos"
	::oChk:nLeft := 0
	::oChk:nTop := 0	
	::oChk:nWidth := 300
	::oChk:nHeight := 20
	::oChk:lShowHint := .T.
	::oChk:cVariable := "::lMarkAll"
	::oChk:bSetGet := bSetGet(::lMarkAll)
	::oChk:Align := CONTROL_ALIGN_TOP	 
	::oChk:lVisibleControl := .T.
	::oChk:bChange := {|| ::MarkAll() }

	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(),,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:bLDblClick := {|| ::BrowserClick() }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWAFReenvioRemessaReceber	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetEditableField() Class TWAFReenvioRemessaReceber
Local aRet := {}

	aAdd(aRet, "E1_FLUXO")		
	aAdd(aRet, "E1_PORCJUR")	
	aAdd(aRet, "E1_DATABOR")

Return(aRet)


Method GetFieldProperty() Class TWAFReenvioRemessaReceber

	::oField:Clear()
	
	::oField:AddField("LEG")
	::oField:FieldName("LEG"):cTitle := ""
	::oField:FieldName("LEG"):cPict := "@BMP"
	
	::oField:AddField("MARK")
	::oField:FieldName("MARK"):cTitle := "Reenvia"
	::oField:FieldName("MARK"):cPict := "@BMP"
	
	::oField:AddField("E1_FLUXO")
	::oField:FieldName("E1_FLUXO"):cTitle := "Calc. Juros"
	
	::oField:AddField("E1_PORCJUR")
	::oField:FieldName("E1_PORCJUR"):cTitle := "% Juros"

	::oField:AddField("E1_DATABOR")
	::oField:FieldName("E1_DATABOR"):cTitle := "Dt. Referencia"
	
	::oField:AddField("E1_PREFIXO")
	::oField:AddField("E1_NUM")
	::oField:AddField("E1_PARCELA")
	::oField:AddField("E1_TIPO")
	::oField:AddField("E1_CLIENTE")
	::oField:AddField("E1_LOJA")
	::oField:AddField("A1_NOME")
	::oField:AddField("E1_EMISSAO")
	::oField:AddField("E1_VENCTO")
	::oField:AddField("E1_VENCREA")
	::oField:AddField("E1_VALOR")
	::oField:AddField("E1_SALDO")	
	::oField:AddField("E1_NUMBCO")
	::oField:AddField("E1_PORTADO")
	::oField:AddField("E1_AGEDEP")
	::oField:AddField("E1_CONTA")

Return(::oField:GetHeader())


Method GetFieldData() Class TWAFReenvioRemessaReceber
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local cFilOri := ""

	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, A1_NOME, E1_VALOR, E1_SALDO, E1_EMISSAO, E1_VENCTO, E1_VENCREA, "
	cSQL += " E1_NUMBCO, E1_PORTADO, E1_AGEDEP, E1_CONTA, SE1.R_E_C_N_O_ AS SE1_RECNO, "
	cSQL += " CASE WHEN "
	cSQL += " ( "
	cSQL += " 	ISNULL(
	cSQL += " 	( "
	cSQL += "			SELECT ACG_TITULO "
	cSQL += " 		FROM ACG010 "
	cSQL += " 		WHERE ACG_FILIAL = '01' "
	cSQL += " 		AND ACG_PREFIX = E1_PREFIXO "
	cSQL += " 		AND ACG_TITULO = E1_NUM "
	cSQL += " 		AND ACG_PARCEL = E1_PARCELA "
	cSQL += " 		AND ACG_TIPO = E1_TIPO "
	cSQL += " 		AND ACG_FILORI = "+ ValToSQL(::GetFilCar())
	cSQL += " 		AND ACG_YSTAT = '3' "
	cSQL += " 		AND D_E_L_E_T_ = '') "
	cSQL += "		,'') "
	cSQL += " ) = '' THEN 'N' ELSE 'S' END AS CART, CONVERT(VARCHAR, GETDATE(), 112) DATE "
	cSQL += " FROM "+ RetSQLName("SE1") + " SE1 "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 "
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND E1_NUMBCO <> '' "
	cSQL += " AND E1_YSITAPI = '2' "	
	cSQL += " AND E1_PREFIXO BETWEEN " + ValToSQL(::cPrefixoDe) + " AND " + ValToSQL(::cPrefixoAte)
	cSQL += " AND E1_NUM BETWEEN " + ValToSQL(::cNumeroDe) + " AND " + ValToSQL(::cNumeroAte)
	cSQL += " AND E1_CLIENTE BETWEEN " + ValToSQL(::cCliDe) + " AND " + ValToSQL(::cCliAte)	

	// Permite a impressao de boletos vencidos somente para o contas a receber
	If U_VALOPER("021", .F.)
		
		cSQL += " AND E1_VENCTO BETWEEN " + ValToSQL(::dVenctoDe) + " AND " + ValToSQL(::dVenctoAte)
		
	Else
	
		cSQL += " AND E1_VENCTO BETWEEN " + ValToSQL(dDataBase) + " AND " + ValToSQL(::dVenctoAte)
		
		If !Empty(Alltrim(cRepAtu))
		
			cSQL += " AND E1_VEND1 = " + ValToSQL(cRepAtu)
		
		EndIf
				
		cSQL += " AND E1_NUM NOT IN "
		cSQL += " ( "
		cSQL += " 	SELECT ACG_TITULO "
		cSQL += " 	FROM ACG010 "
		cSQL += " 	WHERE ACG_FILIAL = '01' "
		cSQL += " 	AND ACG_PREFIX = E1_PREFIXO "
		cSQL += " 	AND ACG_TITULO = E1_NUM "
		cSQL += " 	AND ACG_PARCEL = E1_PARCELA "
		cSQL += " 	AND ACG_TIPO = E1_TIPO "
		cSQL += " 	AND ACG_FILORI = "+ ValToSQL(::GetFilCar())
		cSQL += " 	AND ACG_YSTAT = '3' "
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " ) "
		
	EndIf
		
	cSQL += " AND SE1.D_E_L_E_T_ = '' "
	cSQL += " AND A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' "	
	cSQL += " ORDER BY E1_CLIENTE, E1_LOJA, E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {::cUnChk, ::GetLegend(sToD((cQry)->E1_VENCTO), sToD((cQry)->DATE), (cQry)->CART), ::GetCalc(sToD((cQry)->E1_VENCTO), sToD((cQry)->DATE)), 6, ::dReferenca,;
								(cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA, AllTrim((cQry)->A1_NOME),;
								dToC(sToD((cQry)->E1_EMISSAO)), dToC(sToD((cQry)->E1_VENCTO)), dToC(sToD((cQry)->E1_VENCREA)), (cQry)->E1_VALOR, (cQry)->E1_SALDO,; 
								(cQry)->E1_NUMBCO, (cQry)->E1_PORTADO, (cQry)->E1_AGEDEP, (cQry)->E1_CONTA, (cQry)->SE1_RECNO, .F.})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetLegend(dVencto, dDate, cCart) Class TWAFReenvioRemessaReceber
Local cRet := ""

	If dVencto < dDate
	
		If cCart == "S"
			
			cRet := "BR_PRETO"
			
		Else
			
			cRet := "BR_VERMELHO"
		
		EndIf
	
	Else	
	
		cRet := "BR_VERDE"
	
	EndIf

Return(cRet)


Method GetCalc(dVencto, dDate) Class TWAFReenvioRemessaReceber
Local cRet := ""

	If dVencto < dDate
	
		cRet := "S"
	
	Else
	
		cRet := "N"
	
	EndIf

Return(cRet)


Method GetFilCar() Class TWAFReenvioRemessaReceber
Local cRet := ""

		If cEmpAnt == "01"
			
			cRet := "BI"
			
		ElseIf cEmpAnt == "05"
			
			cRet := "IN"
			
		ElseIf cEmpAnt == "07"
			
			cRet := "LM"
			
		EndIf

Return(cRet)


Method BrowserClick() Class TWAFReenvioRemessaReceber

	If ::oBrw:oBrowse:nColPos >= 3 .And. ::oBrw:oBrowse:nColPos <= 5
		
		::oBrw:EditCell()
		
	Else
	
		::Mark()
		
	EndIf

Return()


Method Mark() Class TWAFReenvioRemessaReceber

	If ::oBrw:aCols[::oBrw:nAt, nP_MARK] == ::cChk
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cUnChk
		
	Else
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cChk
		
	EndIf			

Return()


Method MarkAll() Class TWAFReenvioRemessaReceber
Local nCount := 0

	If Len(::oBrw:aCols) > 0
		
		For nCount := 1 To Len(::oBrw:aCols)
	
			If ::lMarkAll
				::oBrw:aCols[nCount, nP_MARK] := ::cChk
			Else
				::oBrw:aCols[nCount, nP_MARK] := ::cUnChk
			EndIf
	
		Next
			
		::oBrw:oBrowse:Refresh()
		
	EndIf

Return()


Method ExistMark() Class TWAFReenvioRemessaReceber
Local lRet := .F.

	lRet := aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk }) > 0

Return(lRet)


Method GetMark() Class TWAFReenvioRemessaReceber
Local aRet := {}

	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_MARK] == ::cChk, aAdd(aRet, {aPar[nP_JUROS], aPar[nP_PJUROS], aPar[nP_DTREF], aPar[nP_RECNO]}), Nil) })

Return(aRet)


Method Confirm() Class TWAFReenvioRemessaReceber

	If ::ExistMark()
						
		U_BIAMsgRun("Reenviando boleto(s)...", "Aguarde!", {|| ::Resend() })
		
		::oWindow:oOwner:End()
		
		::lConfirm := .T.
	
	Else
	
		MsgStop("Não existem itens selecionados!")
		
	EndIf 

Return()


Method Resend() Class TWAFReenvioRemessaReceber
Local oObj := Nil
		
	oObj := TAFReenvioRemessaReceber():New()
	
	oObj:aTit := ::GetMark()
	
	oObj:Resend()

Return()