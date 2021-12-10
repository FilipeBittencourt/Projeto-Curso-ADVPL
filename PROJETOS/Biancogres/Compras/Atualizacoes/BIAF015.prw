#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*
|------------------------------------------------------------|
| Função:	| BIAF015																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 09/03/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina para preenchimento da data de chegada da	 |
| 				|	mercadoria na Nota Fiscal de Entrada						 |
|------------------------------------------------------------|
| OS:			|	N/A - Usuário: Wanisay William 									 |
|------------------------------------------------------------|
*/

User Function BIAF015(nOpc, nConfirm)

	If (SF1->F1_TIPO == "N") .And. (nConfirm == 1) .And. (nOpc >= 3 .And. nOpc <= 4)

		// Se não for nota fiscal de serviço
		If !fNfeSer()
			
			If (CheckZLL() .And. TicketInformado())
				Return()
			EndIf
				
			// Retirada tratamento para a empresa JK (06) filial Colatina (03) conforme OS 3089-15. Por Marcos Alberto Soprani em 01/09/15 - Ref dia 31/08/15
			If cEmpAnt+cFilAnt <> "0603"
				fSetDtChe()
			EndIf
		EndIf	
	
	EndIf
	
Return()

// Verifica se é uma nota fiscal de serviço ou produto acabado.
Static Function fNfeSer()
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSD1 := RetSQLName("SD1")

	cSQL := " SELECT COUNT(D1_COD) AS COUNT "
	cSQL += " FROM "+ cSD1
	cSQL += " WHERE D1_FILIAL = "+ ValToSQL(xFilial("SD1"))
	cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)	
	cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
	cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
	cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
	cSQL += " AND (SUBSTRING(D1_COD,1, 3) = '306' OR D1_TP = 'PA') " // Identifica o produto como um serviço ou produto acabado
	cSQL += " AND D_E_L_E_T_='' "
	
	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0
	
	(cQry)->(DbCloseArea())
		
Return(lRet)


// Set Data de Entrega
Static Function fSetDtChe()

Local aCoors := FWGetDialogSize(oMainWnd)	
Local oDlg := Nil
Local oSayDtChe := Nil
Local oGetDtChe := Nil
Local oSayNumTk := Nil
Local oGetNumTk := Nil
Private dDtChe := sToD("  /  /    ")
Private cNumTk := Space(TamSx3("D1_YNUMTK")[1])
Private lExibe := .F.
//Private oMsgBar := Nil


	oDlg := MsDialog():New(aCoors[1], aCoors[2], aCoors[3]/6, aCoors[4]/8, "Informe a Data de Chegada",,,,DS_MODALFRAME,,,,,.T.)
	oDlg:cName := "oDlg"
	oDlg:lShowHint := .F.
	oDlg:lCentered := .T.
	oDlg:lEscClose := .F.
	oDlg:bValid := {|| .F. }
		
	oSayDtChe := TSay():Create(oDlg)
	oSayDtChe:cName := "oSayDtChe"
	oSayDtChe:cCaption := "Data de Chegada"
	oSayDtChe:nLeft := 06
	oSayDtChe:nTop := 08
	oSayDtChe:nWidth := 85
	oSayDtChe:nHeight := 30	
	oSayDtChe:lReadOnly := .T.
	oSayDtChe:nClrText := CLR_HBLUE
	oSayDtChe:cToolTip := "Data de Chegada da Mercadoria"
	
	oGetDtChe:= TGet():Create(oDlg)
	oGetDtChe:cName := "oGetDtChe"
	oGetDtChe:nLeft := 95
	oGetDtChe:nTop := 08
	oGetDtChe:nWidth := 80
	oGetDtChe:nHeight := 20
	oGetDtChe:cVariable := "dDtChe"
	oGetDtChe:bSetGet := bSetGet(dDtChe)
	oGetDtChe:cToolTip := "Data de Chegada da Mercadoria"
	oGetDtChe:bValid := {|| fVldDtChe() }
	
	// Somente exibe o Get do numero do ticket para os produtos com os grupos 101 a 107
	If fGrpNfe()
		
		lExibe := .T.
		
		oSayNumTk := TSay():Create(oDlg)
		oSayNumTk:cName := "oSayNumTk"
		oSayNumTk:cCaption := "Número do Ticket"
		oSayNumTk:nLeft := 06
		oSayNumTk:nTop := 42
		oSayNumTk:nWidth := 85
		oSayNumTk:nHeight := 30	
		oSayNumTk:lReadOnly := .T.
		oSayNumTk:nClrText := CLR_HBLUE
		oSayNumTk:cToolTip := "Número do Ticket"
		
		oGetNumTk:= TGet():Create(oDlg)
		oGetNumTk:cName := "oGetNumTk"
		oGetNumTk:nLeft := 95
		oGetNumTk:nTop := 42
		oGetNumTk:nWidth := 80
		oGetNumTk:nHeight := 20
		oGetNumTk:cVariable := "cNumTk"
		oGetNumTk:bSetGet := bSetGet(cNumTk)
		oGetNumTk:cToolTip := "Número do Ticket"
	
	EndIf		
	
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	
	oBtnBar:AddBtnText("OK", "OK", {|| fConfirma(oDlg) },,,CONTROL_ALIGN_RIGHT,.T.)

    oFont := TFont():New('Courier new',,-14,.T.)

    //oMsgBar := TMsgBar():New(oDlg, '',.F.,.F.,.F.,.F., CLR_HRED,,oFont,.F.)
	
	oDlg:Activate()
	
Return()


// Confirma
Static Function fConfirma(oDlg)
Local lRet := .F.

	If fVldDtChe() .And. fVldNumTk()
		lRet := .T.
		oDlg:bValid := {|| .T. }
		oDlg:End()
		
		fUpdDtChe()
		
	EndIf
		
Return(lRet)


// Valida se a data esta preenchida
Static Function fVldDtChe()
Local bRetorno := .T.

	//oMsgBar:SetMsg("")

	if Empty(dDtChe)
	  bRetorno := .F.	 
	  //oMsgBar:SetMsg("Informe a data de chegada!")
	  MsgBox("Informe a data de chegada!","INFO")
	else
		if dDtChe < SF1->F1_EMISSAO  
			bRetorno := .F.
			//oMsgBar:SetMsg("Data de chegada inferior a data de emissão!")
			MsgBox("Data de chegada inferior a data de emissão!","INFO")	
		elseif dDtChe > dDataBase
			bRetorno := .F.
			//oMsgBar:SetMsg("Data de chegada superior a data base!")	
		    MsgBox("Data de chegada superior a data base!","INFO")
		endIf  
	endIf 
   // if  bRetorno == .F.	
   //   oGetDtChe:SetFocus()
   // endif
Return(bRetorno)


// Valida numero do ticket
Static Function fVldNumTk()
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
Local Z11BIA := "Z11010"
Local Z11INC := "Z11050"
	
	If lExibe

		If !Empty(AllTrim(cNumTk))
		
			cSQL := " SELECT TOP 1 TICKET, DATAIN "
			cSQL += " FROM ( "

			cSQL += " SELECT SUBSTRING(Z11_GUARDI, 1, 6) AS TICKET, Z11_DATAIN AS DATAIN "
			cSQL += " FROM "+ Z11BIA
			cSQL += " WHERE D_E_L_E_T_ = '' "

			cSQL += " UNION ALL "
			
			cSQL += " SELECT Z11_PESAGE AS TICKET, Z11_DATAIN AS DATAIN "
			cSQL += " FROM "+ Z11BIA
			cSQL += " WHERE D_E_L_E_T_ = '' "

			cSQL += " UNION ALL "
			
			cSQL += " SELECT Z11_PESAGE AS TICKET, Z11_DATAIN AS DATAIN "
			cSQL += " FROM "+ Z11INC
			cSQL += " WHERE D_E_L_E_T_ = '' "
			
			cSQL += " ) PESAGEM "
			cSQL += " WHERE TICKET = "+ ValToSQL(AllTrim(cNumTk))
			cSQL += " ORDER BY DATAIN DESC "
			
			TcQuery cSQL New Alias (cQry)			
			
			If AllTrim(cNumTk) == AllTrim((cQry)->TICKET)
			
				If dDtChe <> sToD((cQry)->DATAIN)
					//oMsgBar:SetMsg("Data de chegada difere da data do ticket!")
					MsgBox("Data de chegada difere da data do ticket!","INFO")
				EndIf                    
			
			Else			
				lRet := .F.			
				//oMsgBar:SetMsg("Número do ticket inválido!")
				MsgBox("Número do ticket inválido!","INFO")
			EndIf
	
			(cQry)->(DbCloseArea())
		
		Else
			lRet := .F.
			//oMsgBar:SetMsg("Número do ticket inválido!")
			MsgBox("Número do ticket inválido!","INFO")
		EndIf
		
	EndIf
			
Return(lRet)

Static Function CheckZLL()
	
	Local lRet 			:= .F.
	Local cQuery 		:= ""
	Local cAliasTemp 	:= GetNextAlias()
	Local cChave		:= SF1->F1_DOC+'#'+SF1->F1_FORNECE+'#'+SF1->F1_LOJA+'%'
	Local tabela		:= RetSQLName("ZLL")

	IF(!Empty(tabela))
		cQuery := " SELECT *						 															"
		cQuery += " FROM "+ RetSQLName("ZLL")+"																	"			
		cQuery += " WHERE ZLL_FILIAL = "+ ValToSQL(xFilial("ZLL"))+"											"
		cQuery += " AND cast(ZLL_NFSERV as varchar(max)) LIKE '"+cChave+"'										"	
		cQuery += " AND D_E_L_E_T_ = '' 																		"
		
		TcQuery cQuery New Alias (cAliasTemp)
		
		If (!(cAliasTemp)->(Eof()))
			lRet := .T.
		EndIf
		(cAliasTemp)->(DbCloseArea())
	ENDIF
		
Return(lRet)

Static Function TicketInformado()
	
	Local lRet 			:= .T.
	Local cQuery 		:= ""
	Local cAliasTemp 	:= GetNextAlias()
	
	cQuery := " SELECT *						 						"
	cQuery += " FROM "+ RetSQLName("SD1")+"								"			
	cQuery += " WHERE D1_FILIAL = "+ ValToSQL(xFilial("SD1"))+"			"
	cQuery += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)+"					"
	cQuery += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)+"				"
	cQuery += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)+"			"
	cQuery += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)+"				"
	cQuery += " AND D1_YNUMTK = '' 										"
	cQuery += " AND D_E_L_E_T_='' 										"
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	If (!(cAliasTemp)->(Eof()))
		lRet := .F.
	EndIf
	(cAliasTemp)->(DbCloseArea())
		
Return(lRet)



// Verifica se a nota possui os grupos 101 a 107
Static Function fGrpNfe()
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSD1 := RetSQLName("SD1")

	cSQL := " SELECT COUNT(D1_COD) AS COUNT "
	cSQL += " FROM "+ cSD1
	cSQL += " WHERE D1_FILIAL = "+ ValToSQL(xFilial("SD1"))
	cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)	
	cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
	cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
	cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
	cSQL += " AND D1_GRUPO BETWEEN '101' AND '102' "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0
	
	(cQry)->(DbCloseArea())
		
Return(lRet)


// Atualiza data da chegada nos itens da nota de entrada
Static Function fUpdDtChe()
Local lRet := .F.
Local cSQL := ""
Local cSD1 := RetSQLName("SD1")

	cSQL := " UPDATE "+ cSD1
	cSQL += " SET D1_YDTENT = "+ ValToSQL(dDtChe)

	If !Empty(AllTrim(cNumTk))
	
		cSQL += ", D1_YNUMTK = "+ ValToSQL(cNumTk)
	
	EndIf
		
	cSQL += " WHERE D1_FILIAL = "+ ValToSQL(xFilial("SD1"))
	cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)
	cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
	cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
	cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
	cSQL += " AND D_E_L_E_T_='' "
	
	TcSQLExec(cSQL)

Return()
