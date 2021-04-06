#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAFProrrogacaoBoletoReceber
@author Tiago Rossini Coradini
@since 16/05/2019
@version 1.0
@description Classe (tela) para prorrogacao de boletos a receber
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Prorrogação de Boletos a Receber"

#DEFINE nP_MARK 1
#DEFINE nP_LEG 2
#DEFINE nP_DTREF 3
#DEFINE nP_CLIENTE 8
#DEFINE nP_VENCTO 12
#DEFINE nP_SALDO 15
#DEFINE nP_RECNO 20


Class TWAFProrrogacaoBoletoReceber From LongClassName

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
	Data oParam
	Data oParCalc
	Data lCalc // Calcula ou nao juros
	Data nPerc // Percentual de juros negociado
	Data dVencto // Data de vencimento De
	Data nValor // Valor do juros calculado
	
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
	Method GetFilCar()
	Method BrowserClick()
	Method Mark()
	Method MarkAll()
	Method GetMark()
	Method Validate()
	Method VldMark()	
	Method VldCalc()
	Method CalcVal()
	Method Confirm()
	Method CancDepIdPro()
	Method Extend()
	Method Refresh()
	Method Sort(nCol)
	
EndClass


Method New(oParam) Class TWAFProrrogacaoBoletoReceber

	Default oParam := Nil

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

	::oParam := oParam
	::oParCalc := TAFParProrrogacaoBoletoReceber():New()

	::lCalc := .F.
	::nPerc := 0
	::dVencto := dDataBase
	::nValor := 0
	
Return()


Method LoadInterface() Class TWAFProrrogacaoBoletoReceber

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAFProrrogacaoBoletoReceber
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	If !Empty(::oParam:cProcesso)
	
		::oWindow:AddButton("Canc. Prorrogação", {|| ::CancDepIdPro() },,, .T., .F., .T.)

	EndIf

	::oWindow:AddOKButton({|| ::Confirm() })
	::oWindow:AddCloseButton()

	::oWindow:AddButton("Pesquisar", {|| GdSeek(::oBrw,,,,.F.) },,, .T., .F., .T.)
	
Return()


Method LoadContainer() Class TWAFProrrogacaoBoletoReceber

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWAFProrrogacaoBoletoReceber
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
	::oBrw:oBrowse:bHeaderClick := {|oBrw, nCol| ::Sort(nCol) }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWAFProrrogacaoBoletoReceber	

	::LoadInterface()
		
	::oWindow:Activate()

Return()


Method GetEditableField() Class TWAFProrrogacaoBoletoReceber
Local aRet := {}
	
	aAdd(aRet, "E1_DATABOR")
	aAdd(aRet, "E1_NUMBCO")

Return(aRet)


Method GetFieldProperty() Class TWAFProrrogacaoBoletoReceber

	::oField:Clear()

	::oField:AddField("MARK")
	::oField:FieldName("MARK"):cTitle := ""
	::oField:FieldName("MARK"):cPict := "@BMP"
	
	::oField:AddField("LEG")
	::oField:FieldName("LEG"):cTitle := ""
	::oField:FieldName("LEG"):cPict := "@BMP"
		
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


Method GetFieldData() Class TWAFProrrogacaoBoletoReceber
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local cFilOri := ""
Local dVencAux := Nil
Local lDepAnt := .F.
Local dDtVenc := dDataBase

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
	cSQL += " ) = '' THEN 'N' ELSE 'S' END AS CART, CONVERT(VARCHAR, GETDATE(), 112) DATE, "

	cSQL += " CASE WHEN "
	cSQL += " EXISTS ( "
	cSQL += " 			SELECT NULL "
	cSQL += " 			FROM " + RetSQLName("ZKC") + " ZKC (NOLOCK) "
	cSQL += " 			WHERE ZKC_FILIAL	= " + ValToSQL(xFilial("ZKC"))
	cSQL += " 			AND ZKC_NUM			= E1_NUM "
	cSQL += " 			AND ZKC_PREFIX		= E1_PREFIXO "
	cSQL += " 			AND ZKC_PARCEL		= E1_PARCELA "
	cSQL += " 			AND ZKC_TIPO		= E1_TIPO "
	cSQL += " 			AND ZKC_CLIFOR		= E1_CLIENTE "
	cSQL += " 			AND ZKC_LOJA		= E1_LOJA "
	cSQL += " 			AND ZKC_STATUS NOT IN ('B', 'C') "
	cSQL += " 			AND ZKC.D_E_L_E_T_ 	= '' "
	cSQL += " 		 ) "
	cSQL += " THEN 'S' ELSE 'N' END DEPIDENT "

	cSQL += " FROM "+ RetSQLName("SE1") + " SE1 "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 "
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_SALDO > 0 "

	cSQL += " AND NOT exists(															"
	cSQL += " select 1  from "+ RetSQLName("SA6") + " SA6								"
	cSQL += " where									 									"
	cSQL += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
	cSQL += " 	AND A6_COD			= SE1.E1_PORTADO 									"
	cSQL += " 	AND A6_AGENCIA		= SE1.E1_AGEDEP 									"
	cSQL += " 	AND A6_NUMCON		= SE1.E1_CONTA 										"
	cSQL += " 	AND SA6.D_E_L_E_T_	= ''												"
	cSQL += " 	AND SA6.A6_YTPINTB	= '1'												"
	cSQL += " )																			"
	

	If Empty(::oParam:cProcesso)

		// Ticket: 23214 - Retirado devido prorrogacao COVID-19, alguns cliente pagam via deposito
		//cSQL += " AND E1_NUMBCO <> '' "
		//cSQL += " AND E1_YSITAPI = '2' "
		cSQL += " AND E1_TIPO IN ('NF', 'FT', 'ST', 'BOL') "

		cSQL += " AND E1_PREFIXO BETWEEN " + ValToSQL(::oParam:cPrefixoDe) + " AND " + ValToSQL(::oParam:cPrefixoAte)
		cSQL += " AND E1_NUM BETWEEN " + ValToSQL(::oParam:cNumeroDe) + " AND " + ValToSQL(::oParam:cNumeroAte)
		cSQL += " AND E1_VENCTO BETWEEN " + ValToSQL(::oParam:dVenctoDe) + " AND " + ValToSQL(::oParam:dVenctoAte)
		cSQL += " AND SE1.D_E_L_E_T_ = '' "
		cSQL += " AND A1_FILIAL = "+ ValToSQL(xFilial("SA1"))

		If !Empty(::oParam:cGrpCli)
			
			cSQL += " AND A1_GRPVEN = " + ValToSQL(::oParam:cGrpCli)
		
		ElseIf !Empty(::oParam:cCodCli)
			
			cSQL += " AND A1_COD = " + ValToSQL(::oParam:cCodCli)
			
		EndIf

	Else

		cSQL += " AND EXISTS ( "
		cSQL += " 				SELECT NULL "
		cSQL += " 				FROM   " + RetSQLName("ZKC") + " A (NOLOCK) "
		cSQL += " 				WHERE  SE1.E1_FILIAL = A.ZKC_FILIAL "
		cSQL += " 				AND  SE1.E1_NUM      = A.ZKC_NUM "
		cSQL += " 				AND  SE1.E1_PREFIXO  = A.ZKC_PREFIX "
		cSQL += " 				AND  SE1.E1_PARCELA  = A.ZKC_PARCEL "
		cSQL += " 				AND  SE1.E1_CLIENTE  = A.ZKC_CLIFOR "
		cSQL += " 				AND  SE1.E1_LOJA     = A.ZKC_LOJA "
		cSQL += " 				AND  A.ZKC_NUMERO 	 = " + ValToSQL(::oParam:cProcesso)
		cSQL += " 				AND  A.D_E_L_E_T_  = '' "
		cSQL += " 			) "

		cSQL += " AND EXISTS ( "
		cSQL += " 				SELECT NULL "
		cSQL += " 				FROM   " + RetSQLName("ZKC") + " A (NOLOCK) "
		cSQL += " 				WHERE  SE1.E1_FILIAL = A.ZKC_FILIAL "
		cSQL += " 				AND  SE1.E1_SALDO    > 0 "
		cSQL += " 				AND  A.ZKC_STATUS 	 = 'J' "
		cSQL += " 				AND  A.ZKC_NUMERO 	 = " + ValToSQL(::oParam:cProcesso)
		cSQL += " 				AND  A.D_E_L_E_T_  = '' "
		cSQL += " 			) "
				
	EndIf

	cSQL += " AND SA1.D_E_L_E_T_ = '' "	
	cSQL += " ORDER BY E1_CLIENTE, E1_LOJA, E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		lDepAnt := .F.

		If (cQry)->DEPIDENT == "S"

			lDepAnt := .T.

		EndIf

		If ::oParam:lDepAnt

			dVencAux := DataValida(sToD((cQry)->E1_VENCTO) + ::oParam:nQtdRef, .T.)
			dDtVenc := dVencAux

		Else

			dVencAux := ::oParam:dReferenca
			dDtVenc := sToD((cQry)->E1_VENCTO)

		EndIf

		aAdd(aRet, {::cUnChk, ::GetLegend(dDtVenc, sToD((cQry)->DATE), (cQry)->CART, lDepAnt), dVencAux,;
								(cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA, AllTrim((cQry)->A1_NOME),;
								dToC(sToD((cQry)->E1_EMISSAO)), dToC(sToD((cQry)->E1_VENCTO)), dToC(sToD((cQry)->E1_VENCREA)), (cQry)->E1_VALOR, (cQry)->E1_SALDO,; 
								(cQry)->E1_NUMBCO, (cQry)->E1_PORTADO, (cQry)->E1_AGEDEP, (cQry)->E1_CONTA, (cQry)->SE1_RECNO, .F.})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetLegend(dVencto, dDate, cCart, lDepAnt) Class TWAFProrrogacaoBoletoReceber
Local cRet := ""
Default lDepAnt := .F.

	If lDepAnt .And. dVencto > dDate // Eh dep ant e NAO esta vencido

		cRet := "BR_AMARELO"

	ElseIf dVencto < dDate // Esta vencido
		
		If cCart == "S"
			
			cRet := "BR_PRETO"
			
		Else
			
			cRet := "BR_VERMELHO"
		
		EndIf
	
	Else	
		
		cRet := "BR_VERDE"
	
	EndIf

Return(cRet)


Method GetFilCar() Class TWAFProrrogacaoBoletoReceber
Local cRet := ""

		If cEmpAnt == "01"
			
			cRet := "BI"
			
		ElseIf cEmpAnt == "05"
			
			cRet := "IN"
			
		ElseIf cEmpAnt == "07"
			
			cRet := "LM"
			
		EndIf

Return(cRet)


Method BrowserClick() Class TWAFProrrogacaoBoletoReceber

	If ::oBrw:oBrowse:nColPos == 3 .Or. ::oBrw:oBrowse:nColPos == 16
		
		::oBrw:EditCell()
		
	Else
	
		::Mark()
		
	EndIf

Return()


Method Mark() Class TWAFProrrogacaoBoletoReceber

	If ::oBrw:aCols[::oBrw:nAt, nP_MARK] == ::cChk
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cUnChk
		
	Else
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cChk
		
	EndIf			

Return()


Method MarkAll() Class TWAFProrrogacaoBoletoReceber
Local nCount := 0

	If Len(::oBrw:aCols) > 0
		
		For nCount := 1 To Len(::oBrw:aCols)
	
			If ::lMarkAll
				::oBrw:aCols[nCount, nP_MARK] := ::cChk
			Else
				::oBrw:aCols[nCount, nP_MARK] := ::cUnChk
			EndIf
	
		Next
			
		::oBrw:Refresh()
		
	EndIf

Return()


Method GetMark() Class TWAFProrrogacaoBoletoReceber
Local aRet := {}

	//aEval(::oBrw:aCols, {|aPar| If (aPar[nP_MARK] == ::cChk, aAdd(aRet, {aPar[nP_DTREF], aPar[nP_RECNO]}), Nil) })
	
	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_MARK] == ::cChk, aAdd(aRet, aPar), Nil) })

Return(aRet)


Method Validate() Class TWAFProrrogacaoBoletoReceber
Local lRet := .T.

	lRet := ::VldMark() .And. ::VldCalc()

Return(lRet)


Method VldMark() Class TWAFProrrogacaoBoletoReceber
Local lRet := .F.

	If !(lRet := aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk }) > 0)
		
		MsgStop("Não existem itens selecionados!")
	
	EndIf
	
Return(lRet)


Method VldCalc() Class TWAFProrrogacaoBoletoReceber
Local lRet := .F.
	
	::oParCalc:lDepAnt := ::oParam:lDepAnt

	If ::oParCalc:Box()

		If Upper(SubStr(::oParCalc:cCalc, 1, 1)) == "S" .And. (::nValor := ::CalcVal(::oParCalc:nPerc)) > 0
					
			::lCalc := .T.
			::nPerc := ::oParCalc:nPerc
			::dVencto := ::oParCalc:dVencto		
														
			If MsgYesNo("Confirma a geração do título de juros no valor de R$ " + Alltrim(Transform(::nValor, "@E 99,999,999.99")) +;
									" com vencimento no dia " + dToC(::oParCalc:dVencto) + "?", TIT_WND)
				
				lRet := .T.
				
			EndIf
				
		Else
			
			lRet := .T.
			
		EndIf
		
	EndIf

Return(lRet)


Method CalcVal(nPerc) Class TWAFProrrogacaoBoletoReceber
Local nRet := 0
Local nCount := 0
Local nDay := 0

	For nCount := 1 To Len(::oBrw:aCols)
		
		If ::oBrw:aCols[nCount, nP_MARK] == ::cChk

			If ::oParam:lDepAnt

				nDay := ::oParam:nQtdRef
			
			Else
				
				nDay := DateDiffDay(cToD(::oBrw:aCols[nCount, nP_VENCTO]), ::oBrw:aCols[nCount, nP_DTREF])
			
			EndIf

			If nDay > 0
				
				nRet += (nPerc / 30) * (::oBrw:aCols[nCount, nP_SALDO] / 100) * nDay
			
			EndIf
				
		EndIf

	Next

Return(nRet)


Method Confirm() Class TWAFProrrogacaoBoletoReceber

	If ::Validate()
								
		U_BIAMsgRun("Prorrogando boleto(s)...", "Aguarde!", {|| ::Extend() })
		
		U_BIAMsgRun("Atualizando dados...", "Aguarde!", {|| ::Refresh() })
					
	EndIf 

Return()

Method CancDepIdPro() Class TWAFProrrogacaoBoletoReceber

	Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	If Empty(::oBrw:aCols[::oBrw:nAt, nP_CLIENTE])

		Alert("Não existem dados!")

	Else

		If MsgYesNo("Confirma o cancelamento do processo " + ::oParam:cProcesso + " ?", TIT_WND)

			oObjDepId:ExcDepAntJR(::oParam:cProcesso, .T.)

			U_BIAMsgRun("Atualizando dados...", "Aguarde!", {|| ::Refresh() })

		EndIf

	EndIf
				
Return()


Method Extend() Class TWAFProrrogacaoBoletoReceber
Local oObj := Nil
		
	oObj := TAFProrrogacaoBoletoReceber():New()
	
	oObj:lCalc := ::lCalc
	oObj:nPerc := ::nPerc
	oObj:dVencto := ::dVencto
	oObj:nValor := ::nValor
	oObj:aTit := ::GetMark()

	oObj:lDepAnt := ::oParam:lDepAnt
	oObj:cBanco := ::oParCalc:cBanco
	oObj:cAgencia := ::oParCalc:cAgencia
	oObj:cConta  := ::oParCalc:cConta
	oObj:cObs := ::oParCalc:cObs
	oObj:nDias := ::oParam:nQtdRef

	If oObj:Process() .And. ::lCalc

		MsgInfo("Título de juros criado com sucesso: " + Chr(13) + Chr(10) +;
						"Número: " + Alltrim(oObj:oCR:cNumero) + Chr(13) + Chr(10) +;
						"Valor: " + Alltrim(Transform(oObj:oCR:nValor, "@E 99,999,999.99")) + Chr(13) + Chr(10) +;
						"Vencimento: " + dToC(oObj:oCR:dVencto) + Chr(13) + Chr(10) +;
						"Cliente: " + oObj:oCR:cCliente + "-" + oObj:oCR:cLoja + "-" +;
						AllTrim(Posicione("SA1", 1, xFilial("SA1") + oObj:oCR:cCliente + oObj:oCR:cLoja, "A1_NOME")), TIT_WND)
																
	EndIf
		
Return()


Method Refresh() Class TWAFProrrogacaoBoletoReceber

	::oBrw:SetArray(::GetFieldData())
	
	::oBrw:Refresh()

Return()


Method Sort(nCol) Class TWAFProrrogacaoBoletoReceber
Local nSort := 0
Local nCount := 0

	If nCol > 2 .And. Len(::oBrw:aCols) > 1

		If ::oField:Fields:GetValue(nCol):nSort == 1
			
			nSort := 2
			
			aSort(::oBrw:aCols,,, {|x,y| (x[nCol]) > (y[nCol])})
			
		Else
		
			nSort := 1
			
			aSort(::oBrw:aCols,,, {|x,y| (x[nCol]) < (y[nCol])})
									
		EndIf
		
		::oField:Fields:GetValue(nCol):nSort := nSort
						
		::oBrw:Refresh()
				
	EndIf
	
Return()