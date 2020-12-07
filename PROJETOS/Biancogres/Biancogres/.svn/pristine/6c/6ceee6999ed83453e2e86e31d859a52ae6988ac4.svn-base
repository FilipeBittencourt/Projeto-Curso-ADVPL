#include "rwmake.ch"
User Function BIA895()
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA895     ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 28/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho na solicitacao do cliente no SC5                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
	Return("N")
EndIf

Private aRadio := {"SIM   ","NAO   "}
Private	nRadio := 2
Private	wFim := .T., lret := "N"

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSA1	:= ""
Private cIndSA1	:= 0
Private cRegSA1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SA1")
cArqSA1 := Alias()
cIndSA1 := IndexOrd()
cRegSA1 := Recno()
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE))
If M->C5_YLINHA == "1" .and. SA1->A1_YRECR == "1"
	While wfim
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente é Distribuidor '(S/N) ?'"
		@ 000,010 TO 30,70 TITLE "Opcoes"
		@ 007,020 RADIO aRadio VAR nRadio
		@ 010,087 BMPBUTTON TYPE 1 ACTION fSC5()
		ACTIVATE DIALOG oDlg1 CENTER
	EndDo
EndIf
If M->C5_YLINHA == "2" .and. SA1->A1_YRECR == "2"
	While wfim
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente é Distribuidor '(S/N) ?'"
		@ 000,010 TO 30,70 TITLE "Opcoes"
		@ 007,020 RADIO aRadio VAR nRadio
		@ 010,087 BMPBUTTON TYPE 1 ACTION fSC5()
		ACTIVATE DIALOG oDlg1 CENTER
	EndDo
EndIf
If M->C5_YLINHA $ "1_2" .and. SA1->A1_YRECR == "3"
	While wfim
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente é Distribuidor '(S/N) ?'"
		@ 000,010 TO 30,70 TITLE "Opcoes"
		@ 007,020 RADIO aRadio VAR nRadio
		@ 010,087 BMPBUTTON TYPE 1 ACTION fSC5()
		ACTIVATE DIALOG oDlg1 CENTER
	EndDo
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(lret)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizar os campos do arquivo SC5                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fSC5()
If nradio == 1
	lret := "S"
Else
	lret := "N"
EndIf
Close(oDlg1)
wFim := .F.
Return
