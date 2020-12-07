#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG093
@author Gabriel Rossi Mafioletti
@since 28/05/2019
@version 1.0
@description Consulta Padrão de Aprovadores
@type function
/*/

User Function BIAFG093()

	Local aArea   		:= GetArea()

	Private oDlgTab
	Private oGet1
	Private cGet1 		:= Iif(Empty(Alltrim(&(Alltrim(__ReadVar)))),Space(45),Alltrim(&(Alltrim(__ReadVar)))+REPLICATE(" ",45-Len(Alltrim(&(Alltrim(__ReadVar))))) )
	Private oRadMenu1
	Private nRadMenu1 	:= 1
	Private Pesquisar
	Private Retornar
	Private nX
	Private aHeaderEx 	:= {}
	Private aColsEx 	:= {}
	Private aFieldFill	:= {}
	Private oMSNewGetDados1

	Private aTipoPedido

	Private oComboBox
	Private nComboBox := "Nome"   

	Public hk_Retur1 := Space(9)

	DEFINE MSDIALOG oDlgTab TITLE "Consulta Aprovadores" FROM 000, 000  TO 398, 650 COLORS 0, 16777215 PIXEL

	fMSNewGetDados1()

	@ 005, 005 MSCOMBOBOX oComboBox VAR nComboBox ITEMS {"Nome","Matricula"} SIZE 160, 012 OF oDlgTab COLORS 0, 16777215 ON CHANGE wMudOrd() PIXEL
	@ 020, 005 MSGET oGet1 VAR cGet1 SIZE 160, 010 OF oDlgTab COLORS 0, 16777215 PIXEL
	@ 005, 185 BUTTON Pesquisar PROMPT "Pesquisar" SIZE 040, 015 OF oDlgTab ACTION( wRetCodCl() ) PIXEL

	@ 180, 005 BUTTON Pesquisar PROMPT "OK" 		SIZE 040, 015 OF oDlgTab ACTION( wRtCodSel()   ) PIXEL
	@ 180, 050 BUTTON Pesquisar PROMPT "Cancelar" 	SIZE 040, 015 OF oDlgTab ACTION( nComboBox := "Nome", oDlgTab:End() ) PIXEL
	//@ 180, 095 BUTTON Pesquisar PROMPT "Visualizar"	SIZE 040, 015 OF oDlgTab ACTION( wVisual() 	   ) PIXEL	

	ACTIVATE MSDIALOG oDlgTab Centered

	RestArea( aArea )

Return .T.

Static Function fMSNewGetDados1()

	aAdd(aHeaderEx,{"Nome"         ,"NOME"   ,"@S40"             , 40  , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"Matrícula"    ,"MATRIC" ,"@!"               , 8   , 0,,, "C",, })      	// 1
	aAdd(aHeaderEx,{"ID"           ,"ID"     ,"@!"               , 9   , 0,,, "N",, })      	// 1

	cQUERY := "SELECT NOME, MATRICULA MAT,CAST(IDUSERBZ AS VARCHAR(9)) USERID FROM ZEUS.BIZAGIPRD.DBO.VW_USUARIOS "
	TcQuery cQUERY New Alias "QRY"
	dbSelectArea("QRY")
	dbGoTop()
	While !Eof()
		Aadd(aFieldFill, {QRY->NOME,QRY->MAT,QRY->USERID, .F. })
		dbSkip()
	End
	QRY->(dbCloseArea())

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, {"","","", .F. })
	EndIf

	aColsEx := aFieldFill

	oMSNewGetDados1 := MsNewGetDados():New( 040, 005, 170, 325, , , , , , , 999, , , , oDlgTab, aHeaderEx, aColsEx)

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }

Return 

Static Function wRetCodCl()

	cQUERY := "SELECT NOME, MATRICULA MAT,CAST(IDUSERBZ AS VARCHAR(9)) USERID FROM ZEUS.BIZAGIPRD.DBO.VW_USUARIOS "

	If nComboBox == "Nome"
		cQUERY += " WHERE NOME  LIKE '"+Alltrim(cGet1)+"%' "
	ElseIf nComboBox == "Matricula"
		cQUERY += " WHERE MATRICULA LIKE '%"+Alltrim(cGet1)+"%' " 
	EndIf
	If nComboBox == "Nome"
		cQUERY += " ORDER BY NOME  "
	ElseIf nComboBox == "Matricula"
		cQUERY += " ORDER BY MATRICULA		  "
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
		Aadd(aFieldFill, {QRY->NOME,QRY->MAT,QRY->USERID, .F. })
		dbSkip()
	End
	QRY->(dbCloseArea())

	If Len(aFieldFill) == 0
		Aadd(aFieldFill, {"","","", .F. })
	EndIf
	aColsEx := aFieldFill

	oMSNewGetDados1:aHeader := aHeaderEx
	oMSNewGetDados1:aCols := aColsEx

	oMsNewGetDados1:oBrowse:bLDblClick := {||wRtCodSel() }
	oMSNewGetDados1:oBrowse:Refresh()
	oMSNewGetDados1:oBrowse:SetFocus()

Return

Static Function wMudOrd()

	If Len(aColsEx) > 1
		If nComboBox == "Nome"
			aColsEx := aSort(aColsEx,,,{|x,y| x[1] < y[1] })
		ElseIf nComboBox == "Matricula"
			aColsEx := aSort(aColsEx,,,{|x,y| x[2] < y[2] })
		EndIf
		oMSNewGetDados1:ACOLS	:= aColsEx
		oMSNewGetDados1:oBrowse:Refresh()
		oMSNewGetDados1:oBrowse:SetFocus()
	EndIf

Return

Static Function wRtCodSel()

	hk_Retur1	:= oMSNewGetDados1:ACOLS[oMSNewGetDados1:oBrowse:nAt][3]

	If Upper(Alltrim(FunName())) == "BIA846"

		hk_Retur1    := Alltrim(hk_Retur1)
		M->ZZY_IDBIZ := hk_Retur1 + Replicate(" ", 9 - Len(hk_Retur1))

	Else 

		_cCodBiz	:=	hk_Retur1
		_oGetCod:Refresh()

	EndIf

	oDlgTab:End()

Return
