#include "rwmake.ch"
User Function BIA895()
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA895     � Autor � MICROSIGA VITORIA     � Data � 28/04/04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Gatilho na solicitacao do cliente no SC5                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente � Distribuidor '(S/N) ?'"
		@ 000,010 TO 30,70 TITLE "Opcoes"
		@ 007,020 RADIO aRadio VAR nRadio
		@ 010,087 BMPBUTTON TYPE 1 ACTION fSC5()
		ACTIVATE DIALOG oDlg1 CENTER
	EndDo
EndIf
If M->C5_YLINHA == "2" .and. SA1->A1_YRECR == "2"
	While wfim
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente � Distribuidor '(S/N) ?'"
		@ 000,010 TO 30,70 TITLE "Opcoes"
		@ 007,020 RADIO aRadio VAR nRadio
		@ 010,087 BMPBUTTON TYPE 1 ACTION fSC5()
		ACTIVATE DIALOG oDlg1 CENTER
	EndDo
EndIf
If M->C5_YLINHA $ "1_2" .and. SA1->A1_YRECR == "3"
	While wfim
		@ 0,0 TO 070,500 DIALOG oDlg1 TITLE "O Cliente � Distribuidor '(S/N) ?'"
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Atualizar os campos do arquivo SC5                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Static Function fSC5()
If nradio == 1
	lret := "S"
Else
	lret := "N"
EndIf
Close(oDlg1)
wFim := .F.
Return
