#include "rwmake.ch"        
User Function BIA911()        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³BIA911    ³ Autor ³ Nilton Cesar          ³ Data ³ 28.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Filtrar as notas fiscais originais                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                              
Local aArea:=GetArea(),cRet:=M->C5_TIPO,ndias := 50, Odlg1

Local cArq    	:= ""
Local cInd    	:= 0
Local cReg	    := 0

Local cArqSD1	:= ""
Local cIndSD1	:= 0
Local cRegSD1	:= 0

Local cArqSF1	:= ""
Local cIndSF1	:= 0
Local cRegSF1	:= 0

If !(Isblind())

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()
	
	DbSelectArea("SD1")
	cArqSD1 := Alias()
	cIndSD1 := IndexOrd()
	cRegSD1 := Recno()
	
	DbSelectArea("SF1")
	cArqSF1 := Alias()
	cIndSF1 := IndexOrd()
	cRegSF1 := Recno()
	
	If Alltrim(Funname()) <> "RPC"
	
	@ 96,42 TO 200,505 DIALOG oDlg1 TITLE "Entrada de Dados"
	@ 10,10  SAY "Quantidade de dias para pesquisa da nota original: "
	@ 10,160 GET ndias  PICTURE "9999"
	@ 40,180 BMPBUTTON TYPE 1 ACTION Close(oDlg1)
	ACTIVATE DIALOG oDlg1 CENTERED
	
	EndIf	
	
	
	DbSelectArea("SF1")
	Set Filter to F1_DTDIGIT >= (ddatabase - ndias)
	DbSelectArea("SD1")
	Set Filter to D1_DTDIGIT >= (ddatabase - ndias)
	
	If cArqSD1 <> ""
		dbSelectArea(cArqSD1)
		dbSetOrder(cIndSD1)
		dbGoTo(cRegSD1)
		RetIndex("SD1")
	EndIf
	
	If cArqSF1 <> ""
		dbSelectArea(cArqSF1)
		dbSetOrder(cIndSF1)
		dbGoTo(cRegSF1)
		RetIndex("SF1")
	EndIf
	
	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)
	
	RestArea(aArea)

EndIf


Return(cRet)
