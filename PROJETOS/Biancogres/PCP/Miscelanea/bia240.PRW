#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"

User Function BIA240()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA240
Empresa   := Biancogres Ceramica S.A.
Data      := 02/08/12
Uso       := PCP
Aplicação := Tela para lançamento dos Dados da Ficha Técnica de PA para
.            auxilio do calculo das quantidades da estrutura de produto
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Private oDlgFCH
Private oFont1 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Private oGet1
Private cGet1  := ""
Private oGet2
Private cGet2  := ""
Private oGet3
Private cGet3  := ""
Private oGet4
Private cGet4  := ""
Private oGet5
Private cGet5  := ""
Private oGet6
Private cGet6  := ""
Private oGet7
Private cGet7  := ""
Private oGet8
Private cGet8  := 0
Private oGet9
Private oGet10
Private cGet10 := ctod("  /  /  ")
Private oGroup1
Private oSay1
Private oSay2
Private oSay3
Private oSay4
Private oSay5
Private cSay5
Private oComboBox1
Private nComboBox1 := 0
Private oItemFICHA
Private xnQtdSG1   := M->G1_QUANT
Private prVolta    := .F.
Private yDadosSF   := M->G1_YDADOSF
Private cMarca     := GetMark()

If yDadosSF $ "F/P" // Como padrão e produção começam com P, pensei em usar a letra F para identificar padrão (F de Ficha)
	
	If Len(StrTokArr(cValComp,"ú")) <= 2
		
		cGet1  := cProduto
		cGet5  := Substr(Posicione("SB1", 1, xFilial("SB1")+cProduto,"B1_DESC"), 1, 50)
		cGet2  := M->G1_COMP
		cGet6  := Substr(Posicione("SB1", 1, xFilial("SB1")+M->G1_COMP,"B1_DESC"), 1, 50)
		cGet7  := M->G1_TRT
		cGet3  := M->G1_REVINI
		cGet4  := M->G1_REVFIM
		cGet10 := IIF(yDadosSF == "F", M->G1_INI, ctod("  /  /  "))
		cSay5  := IIF(yDadosSF == "F", "PADRÃO" , "PRODUÇÃO")
		
		DEFINE MSDIALOG oDlgFCH TITLE "Dados para Ficha Técnica de PA" FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL
		
		@ 019, 007 GROUP oGroup1 TO 072, 445 OF oDlgFCH COLOR 0, 16777215 PIXEL
		
		@ 043, 278 SAY oSay6 PROMPT "Emissão:"          SIZE 025, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 041, 303 MSGET oGet10 VAR cGet10              SIZE 047, 010 OF oDlgFCH COLORS 0, 16777215 PIXEL
		
		@ 058, 255 SAY oSay8 PROMPT "Área p/ Cálculo:"  SIZE 038, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 057, 300 MSGET oGet8 VAR cGet8                SIZE 050, 010 Picture "@E 99,999.9999" OF oDlgFCH COLORS 0, 16777215 PIXEL
		
		@ 045, 370 SAY oSay9 PROMPT "Regra p/ Cálculo:" SIZE 060, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 057, 370 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"Camada/Densidade","Camada/Densidade/Area","Camada/Area"} SIZE 072, 010 OF oDlgFCH COLORS 0, 16777215 PIXEL
		
		@ 029, 278 SAY oSay5 PROMPT cSay5               SIZE 058, 007 OF oDlgFCH FONT oFont1 COLORS 255, 16777215 PIXEL
		
		BIA240A()
		
		@ 029, 020 SAY oSay1 PROMPT "Produto:"          SIZE 033, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 028, 058 MSGET oGet1 VAR cGet1                SIZE 060, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		@ 028, 119 MSGET oGet5 VAR cGet5                SIZE 150, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		@ 043, 020 SAY oSay2 PROMPT "Componente:"       SIZE 033, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 042, 058 MSGET oGet2 VAR cGet2                SIZE 060, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		@ 042, 119 MSGET oGet6 VAR cGet6                SIZE 150, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		@ 058, 020 SAY oSay7 PROMPT "Sequencia:"        SIZE 039, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 057, 058 MSGET oGet7 VAR cGet7                SIZE 025, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		
		@ 058, 095 SAY oSay3 PROMPT "Revisão Inicial:"  SIZE 039, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 057, 133 MSGET oGet3 VAR cGet3                SIZE 025, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		
		@ 058, 175 SAY oSay4 PROMPT "Revisão Final:"    SIZE 038, 007 OF oDlgFCH COLORS 0, 16777215 PIXEL
		@ 057, 213 MSGET oGet4 VAR cGet4                SIZE 025, 010 OF oDlgFCH COLORS 0, 16777215 READONLY PIXEL
		
		aButtons := {}
		EnchoiceBar(oDlgFCH, {|| BIA240B(), IIF(prVolta, oDlgFCH:End(),) }, {|| BIA240C(), IIF(prVolta, oDlgFCH:End(),) },,aButtons)
		ACTIVATE MSDIALOG oDlgFCH Valid prVolta
		
	EndIf
	
Else
	
	MsgINFO("Somente são permitidos informar neste campo F=Ficha e P=Produção.","Atenção")
	
EndIf

Return ( xnQtdSG1 )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA240A    ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 02/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA240A()

Local nX, iT
Local aFds := {}
Local cTmp
Local aHeaderEx    := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aFields      := {"Z17_ITEM","Z17_DESCRI","Z17_INTVDE","Z17_INTVAT","Z17_UNICO"}
Local aAlterFields := {"Z17_ITEM","Z17_INTVDE","Z17_INTVAT","Z17_UNICO"}
Private oDlg1p

// Define field properties
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For nX := 1 to Len(aFields)
	If SX3->(dbSeek(aFields[nX]))
		Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	Endif
Next nX
Aadd(aHeaderEx, {"Registro", "REQZ17", "99999999999999", 14, 0, , SX3->X3_USADO, "N", , , , })

// Define field values
gyDtRef := dtos(M->G1_INI)
If yDadosSF == "P"                     // Busca na base se teve informações ref. produção
	*************************************************************************************
	
	Aadd( aFds , {"OK"      ,"C",002,000} )
	Aadd( aFds , {"DTREF"   ,"D",008,000} )
	
	cTmp := CriaTrab( aFds, .T. )
	Use (cTmp) Alias MARK New Exclusive
	
	gtDtPrd := .F.
	TR001 := " SELECT DISTINCT Z17_DTREF
	TR001 += "   FROM " + RetSqlName("Z17")
	TR001 += "  WHERE Z17_FILIAL = '"+xFilial("Z17")+"'
	TR001 += "    AND Z17_COD = '"+cGet1+"'
	TR001 += "    AND Z17_COMP = '"+cGet2+"'
	TR001 += "    AND Z17_REVINI <= '"+cGet3+"'
	TR001 += "    AND Z17_REVFIM >= '"+cGet4+"'
	TR001 += "    AND Z17_QUADRO = '"+yDadosSF+"'
	TR001 += "    AND D_E_L_E_T_ = ' '
	TCQUERY TR001 New Alias "TR01"
	dbSelectArea("TR01")
	dbGotop()
	While !Eof()
		gtDtPrd := .T.
		dbSelectArea("MARK")
		RecLock("MARK",.T.)
		MARK->DTREF  := stod(TR01->Z17_DTREF)
		MsUnLock()
		dbSelectArea("TR01")
		dbSkip()
	End
	TR01->(dbCloseArea())
	
	If gtDtPrd
		fh_Esc   := .F.
		nCol := oMainWnd:nClientWidth
		nLin := oMainWnd:nClientHeight
		oDlg1p     := MSDialog():New( nLin*.001, nCol*.001, nLin*.47, nCol*.145, "Datas de Produção",,,.F.,,,,,,.T.,,,.T. )
		
		dbSelectArea("MARK")
		dbGoTop()
		ky_Vet := {{"OK"     ,"" ,"Ok"          ,"@!"},;
		{           "DTREF"  ,"" ,"Data Ref"    ,"@!"} }
		oBrw1      := MsSelect():New( "MARK","OK","",ky_Vet,.F.,@cMarca,{nLin*.008,nCol*.005,nLin*.200,nCol*.070},,,oDlg1p )
		oBtn1      := TButton()  :New( nLin*.210,nCol*.050,"Ok"           ,oDlg1p,{|| fh_Esc := .T., oDlg1p:End()                      },nLin*.040,nCol*.008,,,,.T.,,"",,,,.F. )
		ACTIVATE MSDIALOG oDlg1p CENTERED VALID fh_Esc
		
		dbSelectArea("MARK")
		dbGoTop()
		While !Eof()
			If MARK->OK == cMarca
				gyDtRef := dtos(MARK->DTREF)
				Exit
			EndIf
			dbSelectArea("MARK")
			dbSkip()
		End
	Else
		gyDtRef := dtos(ctod("  /  /  "))
	EndIf
	MARK->(dbCloseArea())
	
EndIf

iT := 0
H0001 := " SELECT Z17_ITEM, Z17_INTVDE, Z17_INTVAT, Z17_UNICO, Z17_AREA, Z17_TPCALC, Z17_DTREF, R_E_C_N_O_ REGZ17
H0001 += "   FROM " + RetSqlName("Z17")
H0001 += "  WHERE Z17_FILIAL = '"+xFilial("Z17")+"'
H0001 += "    AND Z17_COD = '"+cGet1+"'
H0001 += "    AND Z17_COMP = '"+cGet2+"'
H0001 += "    AND Z17_REVINI <= '"+cGet3+"'
H0001 += "    AND Z17_REVFIM >= '"+cGet4+"'
H0001 += "    AND Z17_QUADRO = '"+yDadosSF+"'
H0001 += "    AND Z17_DTREF = '"+gyDtRef+"'
H0001 += "    AND D_E_L_E_T_ = ' '
TCQUERY H0001 New Alias "H001"
dbSelectArea("H001")
dbGoTop()
While !Eof()
	cGet8      := H001->Z17_AREA
	nComboBox1 := H001->Z17_TPCALC
	cGet10     := stod(H001->Z17_DTREF)
	Aadd(aFieldFill, {H001->Z17_ITEM, TABELA("ZG", H001->Z17_ITEM), H001->Z17_INTVDE, H001->Z17_INTVAT, H001->Z17_UNICO, H001->REGZ17, .F. })
	dbSelectArea("H001")
	dbSkip()
End
H001->(dbCloseArea())

If Len(aFieldFill) == 0
	H0002 := " SELECT X5_CHAVE, X5_DESCRI
	H0002 += "   FROM " + RetSqlName("SX5")
	H0002 += "  WHERE X5_FILIAL = '"+xFilial("SX5")+"'
	H0002 += "    AND X5_TABELA = 'ZG'
	H0002 += "    AND D_E_L_E_T_ = ' '
	TCQUERY H0002 New Alias "H002"
	dbSelectArea("H002")
	dbGoTop()
	While !Eof()
		Aadd(aFieldFill, {H002->X5_CHAVE, H002->X5_DESCRI, 0, 0, 0, 0, .F. })
		dbSelectArea("H002")
		dbSkip()
	End
	H002->(dbCloseArea())
EndIf

If Len(aFieldFill) == 0
	For nX := 1 to Len(aFields)
		If dbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, 0)
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)
Else
	aColsEx := aFieldFill
EndIf

oItemFICHA := MsNewGetDados():New( 079, 007, 230, 445, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgFCH, aHeaderEx, aColsEx)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA240B   ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 02/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA240B()

Local _r
Local nxDens := 0
Local nxCama := 0
Local nxArea := cGet8

prVolta := .T.

If !Empty(cGet10)
	
	If yDadosSF == "F"
		
		For _r := 1 To Len(oItemFICHA:Acols)           // Monta dados para Cálculo
			**********************************************************************
			
			If Alltrim(oItemFICHA:ACOLS[_r][1]) == "10"
				If oComboBox1:NAT == 2 .or. oComboBox1:NAT == 3
					nxDens := Val(Alltrim(TABELA("ZO", Alltrim(Str(oItemFICHA:ACOLS[_r][4])))))
				Else
					nxDens := oItemFICHA:ACOLS[_r][5]
				EndIf
			EndIf
			If Alltrim(oItemFICHA:ACOLS[_r][1]) == "05"
				If oComboBox1:NAT == 2 .or. oComboBox1:NAT == 3
					nxCama := oItemFICHA:ACOLS[_r][4]
				Else
					nxCama := oItemFICHA:ACOLS[_r][5]
				EndIf
			EndIf
			
		Next _r
		
		If oComboBox1:NAT == 1                                  //Camada/Densidade
			**********************************************************************
			If nxDens == 0 .or. nxCama == 0
				prVolta := .F.
			Else
				xnQtdSG1 := nxDens * nxCama / 1000
			EndIf
			
		ElseIf oComboBox1:NAT == 2                         //Camada/Densidade/Area
			**********************************************************************
			If nxDens == 0 .or. nxCama == 0 .or. nxArea == 0
				prVolta := .F.
			Else
				xnQtdSG1 := ( nxDens/100 ) * nxCama * nxArea / 1000
			EndIf
			
		ElseIf oComboBox1:NAT == 3                                   //Camada/Area
			**********************************************************************
			If nxCama == 0 .or. nxArea == 0
				prVolta := .F.
			Else
				xnQtdSG1 := nxCama * nxArea / 1000
			EndIf
			
		Else
			prVolta := .F.
		EndIf
		
		If !prVolta
			
			MsgSTOP("Favor verificar pois está faltando dados para compor a fórmula do cálculo do PESO s/m2(kg).","Atenção")
			
		Else
			
			For _r := 1 To Len(oItemFICHA:Acols)              // Grava dados se Ok
				******************************************************************
				
				dbSelectArea("Z17")
				If oItemFICHA:ACOLS[_r][6] == 0
					RecLock("Z17",.T.)
				Else
					dbGoTo(oItemFICHA:ACOLS[_r][6])
					RecLock("Z17",.F.)
				EndIf
				Z17_FILIAL := xFilial("Z17")
				Z17_COD    := cGet1
				Z17_COMP   := cGet2
				Z17_TRT    := cGet7
				Z17_REVINI := cGet3
				Z17_REVFIM := cGet4
				Z17_ITEM   := oItemFICHA:ACOLS[_r][1]
				Z17_INTVDE := oItemFICHA:ACOLS[_r][3]
				Z17_INTVAT := oItemFICHA:ACOLS[_r][4]
				Z17_UNICO  := oItemFICHA:ACOLS[_r][5]
				Z17_AREA   := cGet8
				Z17_TPCALC := oComboBox1:NAT
				Z17_QUADRO := yDadosSF
				Z17_DTREF  := cGet10
				MsUnLock()
				
			Next _r
			
		EndIf
	EndIf
	
Else
	
	MsgSTOP("É necessário informar uma data para confirmar o lançamento","Atenção")
	
EndIf

Return ( prVolta )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA240C   ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 02/08/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA240C()

prVolta := .T.

If !MsgNOYES("Você está prestes a perder possíveis alterações efetuadas. Confirma cancelamento?")
	prVolta := .F.
EndIf

Return ( prVolta )
