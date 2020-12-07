#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 22/08/02

User Function BIA608()        // incluido pelo assistente de conversao do AP5 IDE em 22/08/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WFIM,WNOME,CNOTA,CPREF,CPARC,CCLIENT")
SetPrvt("CLOJA,NPORCJUR,WLOJA,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA608     ³ Autor ³ Cesar Magnago         ³ Data ³ 22/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz acerto no campo F2_YDTINT e F2_YRESINT no arquivo SF2    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

wFim := .T.
While wFim
	wNome    := SPACE(25)
	cNota    := SPACE(9)
	cPref    := "1 "
	cRespInt := SPACE(20)
	cObsInt  := SPACE(100)
	cClient  := SPACE(6)
	cLoja    := SPACE(2)
	dDtInt   := dDataBase
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbGoTop()
	@ 00,0  TO 180,575 DIALOG oEntra TITLE "Dados da NF Saida"
	@ 03,08 TO 70,282
	@ 15,10  SAY "Nr NF       "
	@ 27,10  SAY "Serie   "
	@ 15,45  GET cNota    Picture "@!"
	@ 27,45  GET cPref    Picture "@!"
	@ 075,213 BMPBUTTON TYPE 1 ACTION fSubmit()// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==>        @ 075,213 BMPBUTTON TYPE 1 ACTION Execute(fSubmit)
	@ 075,243 BMPBUTTON TYPE 2 ACTION Entrada()// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==>        @ 075,243 BMPBUTTON TYPE 2 ACTION Execute(Entrada)
	ACTIVATE DIALOG oEntra CENTERED
End
Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function fSubmit
Static Function fSubmit()
@ 00,0  TO 220,775 DIALOG oSaida TITLE "Dados da NF Saida"
@ 03,08 TO 86,382
@ 15,10  SAY "Nr NF       "
@ 27,10  SAY "Serie   "
@ 39,10  SAY "Cliente "
@ 56,10  SAY "Dt Internacao "
@ 71,10  SAY "Resp. Intern. "
@ 88,10  SAY "OBS.  Intern. "
@ 15,65  SAY cNota
@ 27,65  SAY cPref
_Cliente()
@ 39,65  GET cClient  When Empty(cClient)
@ 39,96  GET cLOJA    When Empty(cLoja)
@ 39,114 GET wNome    Size 100,10 When Empty(wNome)
@ 56,65  GET dDtInt   Size 40,10 When !Empty(SA1->A1_SUFRAMA) Picture "@D"
@ 71,65  GET cRespInt Size 80,10 When !Empty(SA1->A1_SUFRAMA) Picture "@!"
@ 88,65  GET cObsInt  Size 150,10 When !Empty(SA1->A1_SUFRAMA) Picture "@S40"
@ 88,283 BMPBUTTON TYPE 1 ACTION fGrava()// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==>        @ 075,213 BMPBUTTON TYPE 1 ACTION Execute(fGrava)
@ 88,313 BMPBUTTON TYPE 2 ACTION Saida()// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==>        @ 075,243 BMPBUTTON TYPE 2 ACTION Execute(Saida)
ACTIVATE DIALOG oSaida CENTERED
Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function _Cliente
Static Function _Cliente()
_Nota()
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
cClient := SA1->A1_COD
cLoja   := SA1->A1_LOJA
wNome   := Subs(SA1->A1_NOME,1,25)
wLoja   := SA1->A1_LOJA
If Empty(SA1->A1_SUFRAMA)
	MsgAlert("Nr NF "+cPref+" "+cNota+" Nao Pode Ser Alterada. Cliente Nao e SUFRAMA.")
	Return .F.
EndIf

Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function _Nota
Static Function _Nota()
DbSelectArea("SF2")
DbSetOrder(1)
If !dbSeek(xFilial("SF2")+cNota+cPref,.F.)
	MsgAlert("Nr NF "+cNota+" "+cPref+" Nao Existe")
	Return .F.
EndIf
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
If !Empty(SA1->A1_SUFRAMA)
	If Empty(SF2->F2_YDTINT)
		dDtInt   := dDataBase
	Else
		MsgAlert("Nr NF  "+cNota+" "+cPref+" Ja Foi Alterada...")
		dDtInt   := SF2->F2_YDTINT
	EndIf
	If Empty(SF2->F2_YRESINT)
		cRespInt := cUserName
	Else
		cRespInt := SF2->F2_YRESINT
	EndIf
	If Empty(SF2->F2_YOBSINT)
		cRespInt := SPACE(100)
	Else
		cRespInt := SF2->F2_YOBSINT
	EndIf
Else
	dDtInt   := SF2->F2_YDTINT
	cRespInt := SF2->F2_YRESINT
	cObsInt  := SF2->F2_YOBSINT
EndIf

Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function fGrava
Static Function fGrava()
DbSelectArea("SF2")
DbSetOrder(1)
If !DbSeek(xFilial("SF2")+cNota+cPref,.F.)
	MsgAlert("Nr NF Para Este Cliente Nao Existe")
	Return
Else
	RecLock("SF2",.F.)
	If !Empty(SA1->A1_SUFRAMA)
		SF2->F2_YDTINT   := dDtInt
		SF2->F2_YRESINT  := cRespInt
		SF2->F2_YOBSINT  := cObsInt
		MsUnLock()
		MsgAlert("Nr NF Do Cliente Selecionado Alterado Com Sucesso")
		
		//Libera o credito di cliente que estava bloqueado devido ao prazo de entrega da declaração ser superior a 120 dias 
		//Este bloqueio é realizado pelo programa BIA492 - Workflow
		cQuery  := ""
		cQuery  += "UPDATE SA1010 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)
		
		cQuery  := ""
		cQuery  += "UPDATE SA1050 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)

		cQuery  := ""
		cQuery  += "UPDATE SA1070 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)

		cQuery  := ""
		cQuery  += "UPDATE SA1130 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)

		cQuery  := ""
		cQuery  += "UPDATE SA1120 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)

		cQuery  := ""
		cQuery  += "UPDATE SA1140 "
		cQuery  += "SET A1_RISCO = 'D', A1_MSEXP = '' "
		cQuery  += "WHERE "
		cQuery  += " A1_COD   = '"+SF2->F2_CLIENTE+"' AND "
		cQuery  += " A1_LOJA  = '"+SF2->F2_LOJA+"' AND "
		cQuery  += " D_E_L_E_T_ = '' "
		TCSQLExec(cQuery)

	EndIf
	Close(oEntra)
	Close(oSaida)
	Return
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function Entrada
Static Function Entrada()
Close(oEntra)
wFim := .F.
Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function Saida
Static Function Saida()
Close(oSaida)
Close(oEntra)
Return