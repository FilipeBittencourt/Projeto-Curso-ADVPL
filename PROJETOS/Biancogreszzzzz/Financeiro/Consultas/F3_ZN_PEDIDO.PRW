#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: F3_ZN_PEDIDO
# AUTOR......: Ranisses A. Corona
# DATA.......: 01/01/2015
# DESCRICAO..: CONSULTA PADRAO CUSTOMIZADA DOS PEDIDOS DE VENDA
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function F3_ZN_PEDIDO()

	Local aArea   		:= GetArea()

	Private oDlgTab
	Private oGet1
	Private cGet1 		:= Iif(Empty(Alltrim(&(Alltrim(__ReadVar)))),Space(45),Alltrim(&(Alltrim(__ReadVar)))+REPLICATE(" ",45-Len(Alltrim(&(Alltrim(__ReadVar))))) )  //Iif(Empty(Alltrim(&(Alltrim(__ReadVar)))),Space(45),Alltrim(&(Alltrim(__ReadVar))) ) 
	Private oRadMenu1
	Private nRadMenu1 	:= 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx 	:= {}
	Private aColsEx 	:= {}
	Private aFieldFill	:= {}
	Private aFields 	:= {"C5_NUM","C5_CLIENTE","C5_LOJACLI","C5_EMISSAO","C5_VEND1","C5_YVLTOTP"}
	Private oMSNewGetDados1

	Private aTipoPedido

	Private oComboBox
	Private nComboBox := "Num. Pedido"                  

	Private cCadastro := "Consulta Pedido de Venda"

	Public hk_Retur1 := ""
	Public hk_Retur2 := ""
	Public hk_Retur3 := ""
	Public hk_Retur4 := ""

	DEFINE MSDIALOG oDlgTab TITLE "Consulta Pedido de Venda" FROM 000, 000  TO 398, 650 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()

	@ 005, 005 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Num.Pedido"} SIZE 160, 012 OF oDlgTab COLORS 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 020, 005 MSGET oGet1 VAR cGet1 SIZE 160, 010 OF oDlgTab COLORS 0, 16777215 PIXEL
	@ 005, 185 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 040, 015 OF oDlgTab ACTION( wRetCodCl() ) PIXEL

	@ 180, 005 BUTTON Pesquisar PROMPT "OK" 		SIZE 040, 015 OF oDlgTab ACTION( wRtCodSel()   ) PIXEL
	@ 180, 050 BUTTON Pesquisar PROMPT "Cancelar" 	SIZE 040, 015 OF oDlgTab ACTION( oDlgTab:End() ) PIXEL
	@ 180, 095 BUTTON Pesquisar PROMPT "Visualizar"	SIZE 040, 015 OF oDlgTab ACTION( wVisual() 	   ) PIXEL	

	ACTIVATE MSDIALOG oDlgTab Centered

	n := 1
	RestArea( aArea )

Return .T.

/*
##############################################################################################################
# PROGRAMA...: fMSNewGetDados1
# AUTOR......: Ranisses A. Corona
# DATA.......: 01/01/2015
# DESCRICAO..: MONTAR MsNewGetDados
##############################################################################################################
*/
Static Function fMSNewGetDados1()
	Local nX
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(dbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})

			If AllTrim(SX3->X3_CAMPO) == "C5_NUM"
				aHeaderEx[Len(aHeaderEx)][3] := "@X"
			ElseIf AllTrim(SX3->X3_CAMPO) == "C5_CLIENTE"
				aHeaderEx[Len(aHeaderEx)][3] := "@!"
			EndIf

		Endif
	Next nX

	cQUERY := "SELECT TOP 500 C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_VEND1, C5_YVLTOTP FROM "+RetSqlName("SC5")+" WITH (NOLOCK) "
	cQUERY += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	If !Empty(Alltrim(cGet1))
		cQUERY += " AND C5_NUM LIKE '"+Alltrim(cGet1)+"%' "
	Else
		cQUERY += " AND C5_EMISSAO >= CONVERT(VARCHAR,GETDATE(),112)-90  "
	EndIf
	cQUERY += " AND D_E_L_E_T_ = ' '  "
	cQUERY += "ORDER BY C5_NUM, C5_CLIENTE "
	TcQuery cQUERY New Alias "QRY"
	dbSelectArea("QRY")
	dbGoTop()
	While !Eof()
		Aadd(aFieldFill, {QRY->C5_NUM,QRY->C5_CLIENTE,QRY->C5_LOJACLI,STOD(QRY->C5_EMISSAO),QRY->C5_VEND1,QRY->C5_YVLTOTP, .F. })
		dbSkip()
	End
	QRY->(dbCloseArea())

	If Len(aFieldFill) == 0
		SX3->(DbSetOrder(2))
		aAux := {}
		For nX := 1 to Len(aFields)
			If SX3->(dbSeek(aFields[nX]))
				Aadd(aAux, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aAux, .F.)
		Aadd(aFieldFill, aAux)
	EndIf
	aColsEx := aFieldFill

	oMSNewGetDados1 := MsNewGetDados():New( 040, 005, 170, 325, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }

Return

//*******************************************************
//**  SubFunction2 ref: BIAConsultPer()                **
//*******************************************************
Static Function wRetCodCl()

	Local nX

	cQUERY := "SELECT TOP 500 C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_EMISSAO, C5_VEND1, C5_YVLTOTP FROM "+RetSqlName("SC5")+" WITH (NOLOCK) "
	cQUERY += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	If !Empty(Alltrim(cGet1))
		cQUERY += " AND C5_NUM LIKE '"+Alltrim(cGet1)+"%' "
	Else
		cQUERY += " AND C5_EMISSAO >= CONVERT(VARCHAR,GETDATE(),112)-90  "
	EndIf
	cQUERY += " AND D_E_L_E_T_ = ' '  "
	cQUERY += " ORDER BY C5_NUM, C5_CLIENTE "
	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	TcQuery cQUERY New Alias "QRY"
	dbSelectArea("QRY")
	dbGoTop()

	aFieldFill := {}
	While !Eof()
		Aadd(aFieldFill, {QRY->C5_NUM,QRY->C5_CLIENTE,QRY->C5_LOJACLI,Stod(QRY->C5_EMISSAO),QRY->C5_VEND1,QRY->C5_YVLTOTP, .F. })
		dbSkip()
	End
	QRY->(dbCloseArea())

	If Len(aFieldFill) == 0
		SX3->(DbSetOrder(2))
		aAux := {}
		For nX := 1 to Len(aFields)
			If SX3->(dbSeek(aFields[nX]))
				Aadd(aAux, CriaVar(SX3->X3_CAMPO))
			Endif
		Next nX
		Aadd(aAux, .F.)
		Aadd(aFieldFill, aAux)
	EndIf
	aColsEx := aFieldFill

	//oMSNewGetDados1 := MsNewGetDados():New( 040, 005, 170, 240, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

	oMSNewGetDados1:aHeader := aHeaderEx
	oMSNewGetDados1:aCols := aColsEx

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }
	oMSNewGetDados1:oBrowse:Refresh()
	oMSNewGetDados1:oBrowse:SetFocus()


Return

//*******************************************************
//**  SubFunction3 ref: BIAConsultPer()                **
//*******************************************************
Static Function wMudOrd()

	If Len(aColsEx) > 1
		aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		oMSNewGetDados1:ACOLS	:= aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

//*******************************************************
//**  SubFunction3 ref: wRtCodSel()                    **
//*******************************************************
Static Function wRtCodSel()

	hk_Retur1	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]
	hk_Retur2	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][2]
	hk_Retur3	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][3]
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+hk_Retur2+hk_Retur3))              
	hk_Retur4	:= SA1->A1_NOME
	oDlgTab:End()

Return


//*******************************************************
//**  wVisual()						                   **
//*******************************************************
Static Function wVisual()

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(XFilial("SC5")+oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1]))              
	A410Visual("SC5",SC5->(RecNo()),2)

Return