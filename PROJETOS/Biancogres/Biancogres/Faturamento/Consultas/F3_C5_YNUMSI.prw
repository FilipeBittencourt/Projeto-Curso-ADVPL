#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F3_C5_YNUMSI
@description Consulta Padrao customizada para escolha da AI na tela do pedido de venda
@author Fernando Rocha
@since 17/02/2017
@version undefined

@type function
/*/
User Function F3_C5_YNUMSI()

	Local aArea   := GetArea()

	Private oDlgTab
	Private oGet1
	Private cGet1 := Space(45)
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx := {}
	Private aColsEx := {}
	Private aFieldFill := {}
	Private aFields := {"ZO_SI","ZO_VALOR","ZO_DESCR","ZO_STATUS"}
	Private oMSNewGetDados1 

	Private aTipoPedido 

	Private oComboBox
	Private nComboBox := "Codigo"

	Private lOutAI	:= .F.

	Public hk_Retur1 := ""

	If "C5_YNOUTAI" $ AllTrim(ReadVar())
		lOutAI := .T.
	EndIf



	DEFINE MSDIALOG oDlgTab TITLE "Solicitações de Investimento" FROM 000, 000  TO 398, 480 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()

	@ 005, 005 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Codigo","Descrição","Status","Saldo"} SIZE 160, 012 OF oDlgTab COLORS 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 020, 005 MSGET oGet1 VAR cGet1 SIZE 160, 010 OF oDlgTab COLORS 0, 16777215 PIXEL                                                                                    
	@ 005, 185 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 040, 015 OF oDlgTab ACTION( wRetCodCl() ) PIXEL

	@ 180, 005 BUTTON Pesquisar PROMPT "OK" SIZE 040, 015 OF oDlgTab ACTION( wRtCodSel() ) PIXEL
	@ 180, 050 BUTTON Pesquisar PROMPT "Cancelar" SIZE 040, 015 OF oDlgTab ACTION( oDlgTab:End() ) PIXEL
	@ 180, 095 BUTTON Pesquisar PROMPT "Visualizar" SIZE 040, 015 OF oDlgTab ACTION( fVisualizar() ) PIXEL

	ACTIVATE MSDIALOG oDlgTab

	n := 1
	RestArea( aArea )

Return .T.

/*
##############################################################################################################
# PROGRAMA...: fMSNewGetDados1
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/07/2014
# DESCRICAO..: MONTAR MsNewGetDados
##############################################################################################################
*/
Static Function fMSNewGetDados1()
	Local _cTabSZO
	Local _cEmp

	Local nX

	//{"ZO_SI","ZO_VALOR","ZO_DESCR","ZO_STATUS"}
	aAdd(aHeaderEx,{"No.AI"		,"ZO_SI"	, "@!"					, 6	, 0	,,"€€€€€€€€€€€€€€","C",,})
	aAdd(aHeaderEx,{"Saldo"		,"ZO_VALOR"	, "@E 999,999,999.99"	, 14, 2	,,"€€€€€€€€€€€€€€","N",,})
	aAdd(aHeaderEx,{"Descrição" ,"ZO_DESCR"	, "@!"					, 20, 0	,,"€€€€€€€€€€€€€€","C",,})
	aAdd(aHeaderEx,{"Status"	,"ZO_STATUS", "@!"					, 20, 0	,,"€€€€€€€€€€€€€€","C",,})


	If Alltrim(M->C5_YLINHA) $ "2#3" .And. AllTrim(CEMPANT) $ "05_07"  //ticket 10958 marreta provisoria AI Incesa na Bianco
		_cTabSZO	:= "SZO050"
		_cEmp		:= "05"	
	Else                    
		_cTabSZO	:= "SZO010"
		_cEmp		:= "01"
	EndIf


	If (AllTrim(CEMPANT) == "07")
		If ((ValType(aCols) <> "U" .And. Len(aCols) < 1) .Or. Empty(M->C5_YEMPPED))
			Aviso("AUTORIZAÇÃO DE INVESTIMENTO","Atenção: Na Empresa - LM, é necessario preencher uma linha do pedido, para depois informado o código da AI.",{"OK"},2,"")
		EndIf

		If (!Empty(M->C5_YEMPPED))
			_cEmp		:= AllTrim(M->C5_YEMPPED)
			_cTabSZO 	:= "SZO"+_cEmp+"0"		
		EndIf			
	EndIf


	If SC5->(FieldPos("C5_YNOUTAI")) > 0
		cAliasTmp := GetNextAlias()
		cQUERY := "exec SP_AI_COM_SALDO_CLIENTE_"+_cEmp+" '"+SA1->A1_COD+"','"+SA1->A1_LOJA+"', "+IIF(lOutAI,"1","0")+"  "
		TcQuery cQUERY New Alias (cAliasTmp)
	Else
		cAliasTmp := GetNextAlias()
		cQUERY := "exec SP_AI_COM_SALDO_CLIENTE_"+_cEmp+" '"+SA1->A1_COD+"','"+SA1->A1_LOJA+"' "
		TcQuery cQUERY New Alias (cAliasTmp)
	EndIf

	(cAliasTmp)->(dbGoTop())
	ProcRegua(RecCount())
	While !(cAliasTmp)->(Eof())
		Aadd(aFieldFill, {(cAliasTmp)->NUM_AI, (cAliasTmp)->SALDO , (cAliasTmp)->DESCR, (cAliasTmp)->STATUS, .F. })

		(cAliasTmp)->(dbSkip())
	End
	(cAliasTmp)->(dbCloseArea())
	dbSelectArea("SX3")
	SX3->(DbSetOrder(2))//X3_CAMPO

	If Len(aFieldFill) == 0
		For nX := 1 to Len(aFields)
			If SX3->(dbSeek(aFields[nX]))
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aColsEx := aFieldFill
	EndIf

	oMSNewGetDados1 := MsNewGetDados():New( 040, 005, 170, 240, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }

Return

//*******************************************************
//**  SubFunction2 ref: BIAConsultPer()                **
//*******************************************************
Static Function wRetCodCl()

	jk_Tam := Len(Alltrim(cGet1))
	nPos   := 0

	If Len(aColsEx) > 1
		If nComboBox == "Codigo"
			nPos := aScan(aColsEx,{|x| Substr(x[1], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		ElseIf nComboBox == "Descrição"
			nPos := aScan(aColsEx,{|x| Substr(x[2], 1, jk_Tam) == Substr(cGet1, 1, jk_Tam) })
		EndIf
		If nPos <> 0
			n:=nPos
			oMSNewGetDados1:oBrowse:nAt:=nPos
			oMSNewGetDados1:oBrowse:Refresh()
			oMSNewGetDados1:oBrowse:SetFocus()
		EndIf
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: BIAConsultPer()                **
//*******************************************************
Static Function wMudOrd()

	If Len(aColsEx) > 1
		If nComboBox == "Codigo"
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nComboBox == "Descrição"
			aColsEx := aSort(aColsEx,,,{|x,y| x[2] < y[2] })
		EndIf
		oMSNewGetDados1:ACOLS := aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: wRtCodSel()                    **
//*******************************************************
Static Function wRtCodSel()

	hk_Retur1 := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]

	oDlgTab:End()

Return

// Visualiza dados da SI abrindo tabela em outra empresa
Static Function fVisualizar()
	Local aArea := GetArea()
	Local cNumSI := oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]
	Local aAreaSZO := SZO->(GetArea()) 
	Local cSvFilAnt := cFilAnt 
	Local cSvEmpAnt := cEmpAnt 
	Local cSvArqTab := cArqTab
	Local cEmp := ""
	Local cModo := ""

	If !Empty(cNumSI)

		If Alltrim(M->C5_YLINHA) $ "2/3"

			cEmp := "05"

		Else                    

			cEmp := "01"

		EndIf	

		If cEmp <> cEmpAnt

			EmpOpenFile("SZO", "SZO", 1, .T., cEmp, @cModo)

		EndIf

		DbSelectArea("SZO")
		DbSetOrder(5)
		If SZO->(DbSeek(xFilial("SZO") + cNumSI))

			AxVisual("SZO", SZO->(Recno()), 1)

		EndIf

	EndIf

	SZO->(DbCloseArea())

	cFilAnt := cSvFilAnt 
	cEmpAnt := cSvEmpAnt 
	cArqTab := cSvArqTab

	ChkFile("SZO") 

	RestArea(aAreaSZO) 
	RestArea(aArea)		

Return()