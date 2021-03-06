#include "rwmake.ch"

User Function BIA048()

SetPrvt("CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1,WOK,CNOTA")
SetPrvt("CPREF,CFORNEC,NUMID,NTICKET,CNREDUZ,")

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � BIA048     � Autor � Cesar Magnago         � Data � 09/09/99 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Faz acerto no campo D1_YUMID e D1_YTICKET no arquivo SD1     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador xBase                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

DbSelectArea("SD1")
DbSetOrder(1)
DbGoTop()

wOk      := .T.

While wOk

	@ 0,0 TO 270,450 DIALOG oEntra TITLE "Dados da NF de Entrada"
	
	cNota := SPACE(9)
	cPref := SPACE(3)
	cFornec := SPACE(6)
	cLoja := SPACE(2)
	@ 25,10 SAY "Nota Fiscal "
	@ 25,40 GET cNota PICT "@!R"
	@ 45,10 SAY "Prefixo "
	@ 45,40 GET cPref PICT "@!R"
	@ 65,10 SAY "Fornec. "
	@ 65,40 GET cFornec PICT "@!R"
	@ 85,10 SAY "Loja "
	@ 85,40 GET cLoja PICT "@!R"
	
	@ 120,80  BUTTON "_Ok"       SIZE 30,15 ACTION fSubmit()
	@ 120,120 BUTTON "_Abortar"  SIZE 30,15 ACTION fAborta()

	ACTIVATE DIALOG oEntra CENTERED

EndDo

Return

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun鏰o    � fSubmit  � Autor �                       � Data �   .  .   Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function fSubmit()

nUmid   := 0
nTicket := 0

If !DbSeek(xFilial("SD1")+cNota+cPref+cFornec+cLoja,.T.)
	MsgAlert("Nao Encontrou a Nota Fiscal")
	Return
EndIf

If !RecLock("SD1",.F.)
	MsgAlert("Registro em uso por outra esta噭o")
	Return
EndIf

If SD1->D1_YUMID <> 0
	nUmid   := SD1->D1_YUMID
	MsgAlert("Umidade Ja Atualizada")
EndIf

If SD1->D1_YTICKET <> 0
	nTicket := SD1->D1_YTICKET
	MsgAlert("Ticket Ja Atualizado")
EndIf

@ 0,0 TO 250,450 DIALOG oDigit TITLE "Alteracao da Umidade"

@ 015,010 SAY "Nota Fiscal "
@ 015,040 SAY cNota
@ 025,010 SAY "Prefixo "
@ 025,040 SAY cPref
@ 045,010 SAY "Fornec. "
@ 045,040 SAY cFornec
@ 045,070 SAY cLoja
DbSelectArea("SA2")
DbSeek(xFilial("SA2")+cFornec+cLoja)
cNreduz := SA2->A2_NREDUZ
@ 045,095 SAY Alltrim(cNreduz)  PICT "@!"
DbSelectArea("SD1")
@ 065,010 SAY "Umidade "
@ 065,040 GET nUmid    PICT "@E 999.99"
@ 065,095 SAY "Em Percentual"
@ 085,010 SAY "Ticket  "
@ 085,040 GET nTicket  PICT "@E 99,999.99"
@ 085,095 SAY "Em Toneladas"

@ 100,80  BMPBUTTON TYPE 1 ACTION fGrava()
@ 100,120 BMPBUTTON TYPE 2 ACTION gAborta()

ACTIVATE DIALOG oDigit CENTERED

Return

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun鏰o    � fGrava  � Autor �                        � Data �   .  .   Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function fGrava()

cNota := SPACE(9)
cPref := SPACE(3)
cFornec := SPACE(6)
cLoja := SPACE(6)
RecLock("SD1")
Replace D1_YUMID   With nUmid
Replace D1_YTICKET With nTicket
DbUnLock()
Close(oDigit)
Close(oEntra)
Return

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun鏰o    � fAborta  � Autor �                       � Data �   .  .   Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function fAborta()

wOk    := .F.
Close( oEntra )

Return

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun鏰o    � gAborta  � Autor �                       � Data �   .  .   Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
Static Function gAborta()

Close( oDigit )
Close( oEntra )

Return
