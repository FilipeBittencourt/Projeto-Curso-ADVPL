#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: F3_C5_CLIENTE
# AUTOR......: Fernando Rocha (FACILE SISTEMAS)
# DATA.......: 14/07/2014
# DESCRICAO..: CONSULTA PADRAO CUSTOMIZADA DE CLIENTES
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function F3_C5_CLIENTE()

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
	Private aFields 	:= {"A1_COD","A1_LOJA","A1_NOME","A1_CGC","A1_MUN","A1_BAIRRO","A1_EST"}
	Private oMSNewGetDados1

	Private aTipoPedido

	Private oComboBox
	Private nComboBox := "Codigo"                  

	Private cCadastro := "Cadastro de Cliente"

	Public hk_Retur1 := ""
	Public hk_Retur2 := ""

	DEFINE MSDIALOG oDlgTab TITLE "Consulta Clientes" FROM 000, 000  TO 398, 650 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()

	@ 005, 005 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Codigo","Descrição","CNPJ"} SIZE 160, 012 OF oDlgTab COLORS 0, 16777215 ON CHANGE wMudOrd() PIXEL
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
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/07/2014
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

			If AllTrim(SX3->X3_CAMPO) == "A1_NOME"
				aHeaderEx[Len(aHeaderEx)][3] := "@S40"
			ElseIf AllTrim(SX3->X3_CAMPO) == "A1_MUN"
				aHeaderEx[Len(aHeaderEx)][3] := "@S20
			EndIf

		Endif
	Next nX

	cQUERY := "SELECT TOP 500 A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_MUN,A1_BAIRRO,A1_EST FROM "+RetSqlName("SA1")+" WITH (NOLOCK) "
	cQUERY += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	If(!Empty(cRepAtu))	
		If AllTrim(FunName()) == "MATA410"
			If Alltrim(M->C5_YLINHA) == "1" //BIANCOGRES
				cQUERY += " AND (A1_VEND = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "2" //INCESA
				cQUERY += " AND (A1_YVENDI = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA
				cQUERY += " AND (A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "4" //MUNDIALLI
				cQUERY += " AND (A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "5" //PEGASUS
				cQUERY += " AND (A1_YVENPEG = '"+cRepAtu+"' )  "
			ElseIf Alltrim(M->C5_YLINHA) == "6" //VINILICO
				cQUERY += " AND (A1_YVENVI1 = '"+cRepAtu+"' )  "
			EndIf
		Else
			cQUERY += " AND (A1_VEND    = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENDI  = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENVT1 = '"+cRepAtu+"' OR A1_YVENVT2 = '"+cRepAtu+"' OR A1_YVENVT3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENPEG = '"+cRepAtu+"' OR A1_YVENVI1 = '"+cRepAtu+"')    "
		EndIf

	EndIf  
	If !Empty(Alltrim(cGet1))
		If nComboBox == "Codigo"
			cQUERY += " AND A1_COD  LIKE '"+Alltrim(cGet1)+"%' "
		ElseIf nComboBox == "Descrição"
			cQUERY += " AND A1_NOME LIKE '%"+Alltrim(cGet1)+"%' " //PARA DESCRIÇÃO PESQUISA NO MEIO DO NOME TAMBÉM
		Else
			cQUERY += " AND A1_CGC  LIKE '"+Alltrim(cGet1)+"%' "
		EndIf
	EndIf
	cQUERY += " AND A1_MSBLQL <> '1'  "
	cQUERY += " AND D_E_L_E_T_ = ' '  "
	cQUERY += " ORDER BY A1_COD, A1_LOJA  "
	TcQuery cQUERY New Alias "QRY"
	dbSelectArea("QRY")
	dbGoTop()
	While !Eof()
		Aadd(aFieldFill, {QRY->A1_COD,QRY->A1_LOJA,QRY->A1_NOME,QRY->A1_CGC,QRY->A1_MUN,QRY->A1_BAIRRO,QRY->A1_EST, .F. })
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

	cQUERY := "SELECT TOP 500 A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_MUN,A1_BAIRRO,A1_EST FROM "+RetSqlName("SA1")+" WITH (NOLOCK) "
	cQUERY += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
	If(!Empty(cRepAtu))	
		If AllTrim(FunName()) == "MATA410"		
			If Alltrim(M->C5_YLINHA) == "1" //BIANCOGRES
				cQUERY += " AND (A1_VEND = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "2" //INCESA
				cQUERY += " AND (A1_YVENDI = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA
				cQUERY += " AND (A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "4" //MUNDIALLI
				cQUERY += " AND (A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"')  "
			ElseIf Alltrim(M->C5_YLINHA) == "5" //PEGASUS
				cQUERY += " AND (A1_YVENPEG = '"+cRepAtu+"' )  "
			ElseIf Alltrim(M->C5_YLINHA) == "6" //VINILICO
				cQUERY += " AND (A1_YVENVI1 = '"+cRepAtu+"' )  "
			Else
				cQUERY += " AND (A1_VEND    = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENDI  = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENVT1 = '"+cRepAtu+"' OR A1_YVENVT2 = '"+cRepAtu+"' OR A1_YVENVT3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENPEG = '"+cRepAtu+"' OR A1_YVENVI1 = '"+cRepAtu+"')    "
			EndIf
		Else
			cQUERY += " AND (A1_VEND    = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENDI  = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENVT1 = '"+cRepAtu+"' OR A1_YVENVT2 = '"+cRepAtu+"' OR A1_YVENVT3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"' OR  "
			cQUERY += "      A1_YVENPEG = '"+cRepAtu+"' OR A1_YVENVI1 = '"+cRepAtu+"' )    "
		EndIf		
	EndIf
	If nComboBox == "Codigo"
		cQUERY += " AND A1_COD  LIKE '"+Alltrim(cGet1)+"%' "
	ElseIf nComboBox == "Descrição"
		cQUERY += " AND A1_NOME LIKE '%"+Alltrim(cGet1)+"%' " //PARA DESCRIÇÃO PESQUISA NO MEIO DO NOME TAMBÉM
	Else
		cQUERY += " AND A1_CGC  LIKE '"+Alltrim(cGet1)+"%' "
	EndIf
	cQUERY += " AND A1_MSBLQL <> '1'  "
	cQUERY += " AND D_E_L_E_T_ = ' '  "
	If nComboBox == "Codigo"
		cQUERY += " ORDER BY A1_COD, A1_LOJA  "
	ElseIf nComboBox == "Descrição"
		cQUERY += " ORDER BY A1_NOME		  "
	Else
		cQUERY += " ORDER BY A1_CGC			  "
	EndIf
	If chkfile("QRY")
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	TcQuery cQUERY New Alias "QRY"
	dbSelectArea("QRY")
	dbGoTop()

	aFieldFill := {}
	While !Eof()
		Aadd(aFieldFill, {QRY->A1_COD,QRY->A1_LOJA,QRY->A1_NOME,QRY->A1_CGC,QRY->A1_MUN,QRY->A1_BAIRRO,QRY->A1_EST, .F. })
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
		If nComboBox == "Codigo"
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nComboBox == "Descrição"
			aColsEx := aSort(aColsEx,,,{|x,y| x[2] < y[2] })
		ElseIf nComboBox == "CNPJ"
			aColsEx := aSort(aColsEx,,,{|x,y| x[3] < y[3] })
		EndIf
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
	If Alltrim(Funname()) == "SOLI_CRE"
		//retorna o NOME DO CLIENTE
		hk_Retur2	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][3]
	Else
		//retorna a LOJA DO CLIENTE
		hk_Retur2	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][2]
	EndIf

	oDlgTab:End()

Return


//*******************************************************
//**  wVisual()						                   **
//*******************************************************
Static Function wVisual()

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][1],.F.)

	AxVisual("SA1",RECNO(),2,,,,,)

Return
