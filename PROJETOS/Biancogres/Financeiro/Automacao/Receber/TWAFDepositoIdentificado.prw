#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAFDepositoIdentificado
@author Tiago Rossini Coradini
@since 15/01/2019
@project Automação Financeira
@version 1.0
@description Classe para manutencao de deposito identificado
@type class
/*/

#DEFINE TIT_WND "Depósito Identificado"
#DEFINE TIT_CAPTION "[Quantidade: @QTD]" + Space(5) + "[Vlr. Original: R$ @VLRO]" + Space(5) + "[Vlr. Total: R$ @VLRT]"

#DEFINE nP_CHECK 1
#DEFINE nP_VENCTO 9
#DEFINE nP_VLRORI 10
#DEFINE nP_VLRTOT 11
#DEFINE nP_RECNO 13

STATIC _Self := Nil

Class TWAFDepositoIdentificado From LongClassName

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

	Data cChk // Imagem de marcacao
	Data cUnChk // Imagem de marcacao
	Data oChk	// Objeto de marcacao
	Data lMarkAll // Controla marcacao de todas as linhas

	Data cGrpCli // Grupo de Clientes
	Data cCodCli // Grupo de Clientes
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate	
	Data dDeposito // Data do deposito

	Data oSaySel
	Data nQtdSel
	Data nVlrOriSel
	Data nVlrTotSel
				
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
	Method GetNextNum()
	Method GDEditableField()
	Method GDFieldProperty()
	Method GDFieldData()
	Method Mark()
	Method MarkAll()
	Method VldBank()
	Method VldCalc()	
	Method VldProrrog(cNumero)
	Method ExistMark()
	Method GetTitle()
	Method Valid()	
	Method Save()	
	Method Confirm()
	Method Cancel(lClose)
	Method CalcValue(dVencto, nVlrOri)
	Method Refresh()
	Method Sort(nCol)		
			
EndClass


Method New() Class TWAFDepositoIdentificado
		
	::oWindow := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cItemBox := ""

	::oFD := Nil
	::cFDTable := "ZK8"
	::nFDOpc := 2
	::nFDRecNo := ZK8->(RecNo())
	::oMGField := Nil

	::oGD := Nil
	::aGDAField := {}
	::oGDField := TGDField():New() 

	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	::oChk := Nil
	::lMarkAll := .F.

	::cGrpCli := Space(TamSx3("ZK8_GRPVEN")[1])
	::cCodCli := Space(TamSx3("ZK8_CODCLI")[1])	
	::dVenctoDe := cToD("")
	::dVenctoAte := cToD("")
	::dDeposito := dDataBase

	::oSaySel := Nil
	::nQtdSel := 0
	::nVlrOriSel := 0
	::nVlrTotSel := 0
	
	_Self := Self
			
Return()


Method LoadInterface() Class TWAFDepositoIdentificado
	
	::LoadWindow()
	
	::LoadContainer()	
	
	::LoadHeader()
	
	::LoadBrowser()	
			
Return()


Method LoadWindow() Class TWAFDepositoIdentificado
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


Method GetOperation() Class TWAFDepositoIdentificado
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


Method LoadContainer() Class TWAFDepositoIdentificado

	::oContainer := FWFormContainer():New()
	
	::cHeaderBox := ::oContainer:CreateHorizontalBox(30)
	
	::cItemBox := ::oContainer:CreateHorizontalBox(70)
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadHeader() Class TWAFDepositoIdentificado

	::oFD := MsMGet():New(::cFDTable, ::nFDRecNo, ::nFDOpc,,,,,{0, 0 , 0, 0},,,,,,::oContainer:GetPanel(::cHeaderBox))
	::oFD:oBox:Align := CONTROL_ALIGN_ALLCLIENT	
			
Return()


Method LoadBrowser() Class TWAFDepositoIdentificado
Local cVldDef := "AllwaysTrue"
Local nMaxLine := 1000

	RegToMemory(::cFDTable, ::nFDOpc == 3)

	If ::nFDOpc == 3 .Or. ::nFDOpc == 4
	
		::oChk := TCheckBox():Create(::oContainer:GetPanel(::cItemBox))
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
		
	EndIf
	
	::oGD := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GDEditableField(),, nMaxLine, cVldDef,, cVldDef, ::oContainer:GetPanel(::cItemBox), ::GDFieldProperty(), ::GDFieldData())
	::oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oGD:oBrowse:bLDblClick := {|| ::Mark() }
	::oGD:oBrowse:bHeaderClick := {|oBrw, nCol| ::Sort(nCol) }
	::oGD:oBrowse:lVScroll := .T.
	::oGD:oBrowse:lHScroll := .T.
	
	::oGD:oBrowse:Refresh()
	
	If ::nFDOpc == 2 .Or. ::nFDOpc == 5
		
		::oGD:Disable()
		
	EndIf	
	
	::oSaySel := TSay():Create(::oContainer:GetPanel(::cItemBox))
	::oSaySel:cName := "oSaySel"
	::oSaySel:cCaption := ::GetTitle()
	::oSaySel:nLeft := 00
	::oSaySel:nTop := 00
	::oSaySel:nWidth := 100
	::oSaySel:nHeight := 15
	::oSaySel:lReadOnly := .T.
	::oSaySel:Align := CONTROL_ALIGN_BOTTOM
	::oSaySel:nClrText := RGB(0,50,100)

Return()


Method Activate() Class TWAFDepositoIdentificado
	
	::LoadInterface()
	
	::oWindow:bInit := {|| DbSelectArea(::cFDTable), RegToMemory(::cFDTable, ::nFDOpc == 3), ::MGFieldData(), ::oFD:Refresh()}
	
	::oWindow:Activate()

	::Cancel()
		
Return()


Method MGFieldProperty() Class TWAFDepositoIdentificado
Local aRet := {}
	
Return(aRet)


Method MGFieldData() Class TWAFDepositoIdentificado	
	
	If ::nFDOpc == 3
		
		M->ZK8_GRPVEN := ::cGrpCli
		M->ZK8_CODCLI := ::cCodCli
		M->ZK8_VENCDE := ::dVenctoDe
		M->ZK8_VENCAT := ::dVenctoAte
		M->ZK8_DATDPI := ::dDeposito

	EndIf
	
Return()


Method GetNextNum() Class TWAFDepositoIdentificado
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT ISNULL(MAX(ZK8_NUMERO), '000000') AS ZK8_NUMERO "
	cSQL += " FROM " + RetSQlName("ZK8")
	cSQL += " WHERE ZK8_FILIAL = " + ValToSQL(xFilial("ZK8"))
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
		
	cRet := Soma1(AllTrim((cQry)->ZK8_NUMERO))
			 	
	(cQry)->(DbCloseArea())

Return(cRet)


Method GDEditableField() Class TWAFDepositoIdentificado
Local aRet := {}

Return(aRet)


Method GDFieldProperty() Class TWAFDepositoIdentificado
Local aRet := {}
	
	::oGDField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	::oGDField:AddField("MARK") 	
	::oGDField:FieldName("MARK"):cTitle := ""
	::oGDField:FieldName("MARK"):cPict := "@BMP"

	::oGDField:AddField("E1_PREFIXO")
	::oGDField:AddField("E1_NUM")
	::oGDField:AddField("E1_PARCELA")
	::oGDField:AddField("E1_TIPO")
	::oGDField:AddField("E1_CLIENTE")
	::oGDField:AddField("E1_LOJA")
	::oGDField:AddField("E1_NOMCLI")
	::oGDField:AddField("E1_VENCTO")
	
	::oGDField:AddField("E1_VALOR")
	::oGDField:FieldName("E1_VALOR"):cTitle := "Vlr. Original"
		
	::oGDField:AddField("E1_SALDO")
	::oGDField:FieldName("E1_SALDO"):cTitle := "Vlr Total"
			
	::oGDField:AddField("SPACE")	
	
	aRet := ::oGDField:GetHeader()
	
Return(aRet)


Method GDFieldData() Class TWAFDepositoIdentificado
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()	
Local lDepIdent := .F.

	DBSelectArea("ZKC")
	ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_

	lDepIdent := ZKC->(DBSeek(xFilial("ZKC") + M->ZK8_NUMERO))
	
	cSQL := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VENCTO, E1_SALDO, E1_YNUMDPI, "
	cSQL += " SE1.R_E_C_N_O_ AS SE1_RECNO "
	cSQL += " FROM "+ RetSQLName("SE1") + " SE1 "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 "
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	
	If ::nFDOpc == 3

		cSQL += " AND E1_SALDO > 0 "
		cSQL += " AND E1_YNUMDPI = '' "
	
	ElseIf ::nFDOpc == 4

		cSQL += " AND (E1_SALDO > 0 "+ If(lDepIdent, " AND ", " OR ") + " E1_YNUMDPI = " + ValToSQL(ZK8->ZK8_NUMERO) + ")"

	ElseIf ::nFDOpc == 2 .Or. ::nFDOpc == 5
	
		cSQL += " AND E1_YNUMDPI = " + ValToSQL(ZK8->ZK8_NUMERO)
			
	EndIf

	If !lDepIdent

		cSQL += " AND E1_VENCTO BETWEEN " + ValToSQL(::dVenctoDe) + " AND " + ValToSQL(::dVenctoAte)

	EndIf

	cSQL += " AND SE1.D_E_L_E_T_ = '' "	
	
	If !Empty(::cGrpCli)
		
		cSQL += " AND A1_GRPVEN = " + ValToSQL(::cGrpCli)
		
	ElseIf !Empty(::cCodCli)
		
		cSQL += " AND A1_COD = " + ValToSQL(::cCodCli)
		
	EndIf
	
	cSQL += " AND A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' "
	cSQL += "	ORDER BY E1_CLIENTE, E1_LOJA, E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA "
		
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		aAdd(aRet, {If (!Empty((cQry)->E1_YNUMDPI), ::cChk, ::cUnChk), (cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA,;
								(cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA, (cQry)->E1_NOMCLI, dToC(sToD((cQry)->E1_VENCTO)),;
								(cQry)->E1_SALDO, ::CalcValue(sToD((cQry)->E1_VENCTO), (cQry)->E1_SALDO), Space(1), (cQry)->SE1_RECNO, .F.})
		
		If !Empty((cQry)->E1_YNUMDPI)
			
			::nQtdSel++
			
			::nVlrOriSel += (cQry)->E1_SALDO
			
			::nVlrTotSel += ::CalcValue(sToD((cQry)->E1_VENCTO), (cQry)->E1_SALDO)
			
		EndIf
														
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aRet)


Method Mark() Class TWAFDepositoIdentificado
	
	If ::oGD:lActive

		If ::oGD:aCols[::oGD:nAt, nP_CHECK] == ::cChk
			
			::oGD:aCols[::oGD:nAt, nP_CHECK] := ::cUnChk
			
			::nQtdSel--
			
			::nVlrOriSel -= ::oGD:aCols[::oGD:nAt, nP_VLRORI]

			::nVlrTotSel -= ::oGD:aCols[::oGD:nAt, nP_VLRTOT]			
			
		Else
			
			::oGD:aCols[::oGD:nAt, nP_CHECK] := ::cChk
			
			::nQtdSel++
			
			::nVlrOriSel += ::oGD:aCols[::oGD:nAt, nP_VLRORI]

			::nVlrTotSel += ::oGD:aCols[::oGD:nAt, nP_VLRTOT]
			
		EndIf
		
		::oSaySel:cCaption := ::GetTitle()
		
	EndIf
		
Return()


Method MarkAll() Class TWAFDepositoIdentificado
Local nCount := 0

	If ::oGD:lActive
	
		If Len(::oGD:aCols) > 0
		
			::nQtdSel := 0
		
			::nVlrOriSel := 0

			::nVlrTotSel := 0						
				
			For nCount := 1 To Len(::oGD:aCols)
		
				If ::lMarkAll
					
					::oGD:aCols[nCount, nP_CHECK] := ::cChk
					
					::nQtdSel++
			
					::nVlrOriSel += ::oGD:aCols[nCount, nP_VLRORI]
					
					::nVlrTotSel += ::oGD:aCols[nCount, nP_VLRTOT]					
					
				Else
					
					::oGD:aCols[nCount, nP_CHECK] := ::cUnChk
													
				EndIf
		
			Next
				
			::oGD:oBrowse:Refresh()
			
		EndIf
		
		::oSaySel:cCaption := ::GetTitle()
		
	EndIf

Return()


Method VldBank() Class TWAFDepositoIdentificado
Local lRet := .T.
Local aArea := GetArea()
	
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6") + M->ZK8_BANCO + M->ZK8_AGENCI + M->ZK8_CONTA))
		
		lRet := .F.

		MsgAlert("Atenção, dados bancários inválidos, verifique se o Banco/Agencia/Conta existem.")
		
	EndIf

	RestArea(aArea)
	
Return(lRet)


Method VldCalc() Class TWAFDepositoIdentificado
Local lRet := .T.
Local lDescPr := .F.

	DBSelectArea("ZKC")
	ZKC->(DBSetOrder(1)) // ZKC_FILIAL, ZKC_NUMERO, ZKC_NUM, ZKC_PREFIX, ZKC_PARCEL, ZKC_TIPO, ZKC_CLIFOR, ZKC_LOJA, R_E_C_N_O_, D_E_L_E_T_

	lDescPr := ZKC->(DBSeek(xFilial("ZKC") + M->ZK8_NUMERO))

	If !lDescPr .And. M->ZK8_CALCJR == "S" .And. M->ZK8_PERCJR <= 0

		lRet := .F.

		MsgAlert("Atenção, percentual de júros inválido!")
		
	EndIf

Return(lRet)


Method ExistMark() Class TWAFDepositoIdentificado
Local lRet := .T.

	If aScan(::oGD:aCols, {|x| x[nP_CHECK] == ::cChk }) == 0
		
		lRet := .F.
		
		MsgAlert("Atenção, nenhum título foi selecionado.")
	
	EndIf
	
Return(lRet)

Method VldProrrog(cNumero) Class TWAFDepositoIdentificado
Local lRet := .T.
Local oObj := TAFProrrogacaoBoletoReceber():New(.F.)

	lRet := oObj:IsJRProrrogBx(cNumero)

	If !lRet

		MsgAlert("Atenção, O titulo encontra-se baixado. Não é possivel a exclusão do depósito identificado!")

	EndIf

Return(lRet)

Method GetTitle() Class TWAFDepositoIdentificado
Local cRet := ""

	cRet := StrTran(TIT_CAPTION, "@QTD", cValToChar(::nQtdSel))
	
	cRet := StrTran(cRet, "@VLRO", AllTrim(Transform(::nVlrOriSel, PesqPict("SE1", "E1_SALDO"))))

	cRet := StrTran(cRet, "@VLRT", AllTrim(Transform(::nVlrTotSel, PesqPict("SE1", "E1_SALDO"))))
	
Return(cRet)


Method Valid() Class TWAFDepositoIdentificado
Local lRet := .T.

	lRet := ::VldBank() .And. ::VldCalc() .And. ::ExistMark() .And. ::VldProrrog(M->ZK8_NUMERO)

Return(lRet)


Method Save() Class TWAFDepositoIdentificado
Local nCount := 0
Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	Begin Transaction
		
		If ::nFDOpc == 3 .Or. ::nFDOpc == 4 .Or. ::nFDOpc == 5
	
			RecLock("ZK8", (::nFDOpc == 3))
			
				If ::nFDOpc == 3
					
					ConfirmSx8()
					
				EndIf
				
				If ::nFDOpc == 5

					oObjDepId:ExcDepAntJR(M->ZK8_NUMERO)
					
					ZK8->(DbDelete())
				
				Else

					ZK8->ZK8_FILIAL := xFilial("ZK8")
					ZK8->ZK8_NUMERO := M->ZK8_NUMERO
					ZK8->ZK8_GRPVEN := ::cGrpCli
					ZK8->ZK8_CODCLI := ::cCodCli				
					ZK8->ZK8_VENCDE := ::dVenctoDe
					ZK8->ZK8_VENCAT := ::dVenctoAte
					ZK8->ZK8_DATDPI := ::dDeposito
					ZK8->ZK8_BANCO := M->ZK8_BANCO
					ZK8->ZK8_AGENCI := M->ZK8_AGENCI
					ZK8->ZK8_CONTA := M->ZK8_CONTA
					ZK8->ZK8_CALCJR := M->ZK8_CALCJR
					ZK8->ZK8_PERCJR := M->ZK8_PERCJR
					ZK8->ZK8_DATA := M->ZK8_DATA
					ZK8->ZK8_HORA := M->ZK8_HORA
					ZK8->ZK8_USER := M->ZK8_USER
					ZK8->ZK8_STATUS := M->ZK8_STATUS
					
				EndIf
						
			ZK8->(MsUnLock())	
				
			For nCount := 1 To Len(::oGD:aCols)
				
				SE1->(DbGoTo(::oGD:aCols[nCount, nP_RECNO]))
		      
	      		RecLock("SE1", .F.)
	      		SE1->E1_YNUMDPI := If (::oGD:aCols[nCount, nP_CHECK] == ::cChk .And. ::nFDOpc <> 5, M->ZK8_NUMERO, "")
				SE1->(MsUnLock())
	
			Next nCount
			
		EndIf		
		
	End Transaction
					
Return()


Method Confirm() Class TWAFDepositoIdentificado

	If ::Valid()
			
		U_BIAMsgRun("Salvando dados...", "Aguarde!", {|| ::Save() })
		
		::oWindow:oOwner:End()
		
	EndIf 

Return()


Method Cancel(lClose) Class TWAFDepositoIdentificado

	Default lClose := .F.

	RollBAckSx8()

	If lClose
		::oWindow:oOwner:End()
	EndIf

Return()

Method CalcValue(dVencto, nVlrOri) Class TWAFDepositoIdentificado
Local nRet := 0
Local nDay := DateDiffDay(dVencto, ::dDeposito)

	If nDay > 0 .And. M->ZK8_CALCJR == "S" .And. M->ZK8_PERCJR > 0
	
		nRet := nVlrOri + (M->ZK8_PERCJR * (nVlrOri / 100)) * nDay
	
	Else
	
		nRet := nVlrOri
		
	EndIf

Return(nRet)


Method Refresh() Class TWAFDepositoIdentificado
Local nCount := 0
Local nVlrTot := 0

	If ::oGD:lActive
	
		If Len(::oGD:aCols) > 0
		
			::nQtdSel := 0
		
			::nVlrOriSel := 0

			::nVlrTotSel := 0						
				
			For nCount := 1 To Len(::oGD:aCols)
		
				nVlrTot := ::CalcValue(cToD(::oGD:aCols[nCount, nP_VENCTO]), ::oGD:aCols[nCount, nP_VLRORI])
				
				::oGD:aCols[nCount, nP_VLRTOT] := nVlrTot
				
				If ::oGD:aCols[nCount, nP_CHECK] == ::cChk
					
					::nQtdSel++
			
					::nVlrOriSel += ::oGD:aCols[nCount, nP_VLRORI]
					
					::nVlrTotSel += nVlrTot
																		
				EndIf
		
			Next
				
			::oGD:oBrowse:Refresh()
			
		EndIf
		
		::oSaySel:cCaption := ::GetTitle()
		
	EndIf

Return()


User Function BAF020B()

	_Self:Refresh()
	
Return(.T.)


Method Sort(nCol) Class TWAFDepositoIdentificado
Local nSort := 0
Local nCount := 0

	If nCol > 1 .And. nCol < 12 .And. Len(::oGD:aCols) > 1

		For nCount := 1 To ::oGDField:Fields:GetCount()
			
			If nCount <> nCol
			
				::oGDField:Fields:GetValue(nCount):nSort := 0
			
				::oGD:oBrowse:SetHeaderImage(nCount, "")
				
			EndIf
									
		Next
		
		If ::oGDField:Fields:GetValue(nCol):nSort == 1
			
			nSort := 2
			
			aSort(::oGD:aCols,,, {|x,y| (x[nCol]) > (y[nCol])})
			
		Else
		
			nSort := 1
			
			aSort(::oGD:aCols,,, {|x,y| (x[nCol]) < (y[nCol])})
									
		EndIf
		
		::oGDField:Fields:GetValue(nCol):nSort := nSort
				
		::oGD:oBrowse:SetHeaderImage(nCol, If (nSort == 1, "COLDOWN", "COLRIGHT"))
		
		::oGD:Refresh()
		
	EndIf
	
Return()