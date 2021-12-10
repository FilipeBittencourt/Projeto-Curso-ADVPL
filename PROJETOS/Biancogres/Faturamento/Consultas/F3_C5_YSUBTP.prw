#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
##############################################################################################################
# PROGRAMA...: F3_C5_YSUBTP
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/07/2014
# DESCRICAO..: CONSULTA PADRAO CUSTOMIZADA
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function F3_C5_YSUBTP()

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
	Private aFields := {"X5_CHAVE","X5_DESCRI"}
	Private oMSNewGetDados1 

	Private aTipoPedido 

	Private oComboBox
	Private nComboBox := "Codigo"

	Public hk_Retur1 := ""

	DEFINE MSDIALOG oDlgTab TITLE "Tipos de Venda" FROM 000, 000  TO 398, 480 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()

	@ 005, 005 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Codigo","Descrição"} SIZE 160, 012 OF oDlgTab COLORS 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 020, 005 MSGET oGet1 VAR cGet1 SIZE 160, 010 OF oDlgTab COLORS 0, 16777215 PIXEL                                                                                    
	@ 005, 185 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 040, 015 OF oDlgTab ACTION( wRetCodCl() ) PIXEL

	@ 180, 005 BUTTON Pesquisar PROMPT "OK" SIZE 040, 015 OF oDlgTab ACTION( wRtCodSel() ) PIXEL
	@ 180, 050 BUTTON Pesquisar PROMPT "Cancelar" SIZE 040, 015 OF oDlgTab ACTION( oDlgTab:End() ) PIXEL

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

	Local nX
	Local nI

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	cQUERY := "SELECT X5_CHAVE, X5_DESCRI FROM "+RetSqlName("SX5")+" WHERE X5_TABELA = 'DJ' AND D_E_L_E_T_=''  "    
	If(!Empty(cRepAtu)) 
		aTipoPedido := StrTokArr (GetNewPar("MV_YSUBTP",''), '/')
		cQUERY += " AND X5_CHAVE IN ("
		For nI := 1 to Len(aTipoPedido)
			cQUERY += "'"+aTipoPedido[nI]+ "'"
			If (Len(aTipoPedido) != nI)
				cQUERY += ","		
			EndIf
		Next nI                               
		cQUERY += ")"
	EndIf
	TcQuery cQUERY New Alias "QRY"

	dbSelectArea("QRY")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()
		Aadd(aFieldFill, {QRY->X5_CHAVE, QRY->X5_DESCRI, .F. })
		dbSelectArea("QRY")
		dbSkip()
	End
	QRY->(dbCloseArea())

	If Len(aFieldFill) == 0
		For nX := 1 to Len(aFields)
			If dbSeek(aFields[nX])
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
