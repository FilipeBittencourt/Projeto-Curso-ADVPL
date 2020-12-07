#include "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIA562()   

	Private oDlgPrinc
	Private oButtonCanc1
	Private oButtonOk1
	Private oGetNrNF
	Private cGetNrNF := ""
	Private oGetSerie
	Private cGetSerie := ""
	Private oGroupNF1
	Private oSayNrNF
	Private oSaySerie
	
	Private iTemData := 1


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WFIM,WNOME,CNOTA,CPREF,CPARC,CCLIENT")
SetPrvt("CLOJA,NPORCJUR,WLOJA,")

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA562     ³ Autor ³ LUANA MARIN RIBEIRO   ³ Data ³ 28/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz acerto no campo F2_YDTINT e F2_YRESINT no arquivo SF2    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

wFim := .T.
While wFim
	wNome    := SPACE(25)
	cNota    := SPACE(9)
	cPref    := "1 "
	cClient  := SPACE(6)
	cLoja    := SPACE(2)
	dDtExp   := dDataBase
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbGoTop()
	
		
	  DEFINE MSDIALOG oEntra TITLE "Dados da NF Saída" FROM 000, 000  TO 145, 345 COLORS 0, 16777215 PIXEL
	  
	    @ 007, 007 GROUP oGroupNF1 TO 052, 164 OF oDlgPrinc COLOR 0, 16777215 PIXEL
	    @ 020, 019 SAY oSayNrNF PROMPT "Nr NF" SIZE 025, 007 OF oDlgPrinc COLORS 0, 16777215 PIXEL
	    @ 020, 093 SAY oSaySerie PROMPT "Série:" SIZE 025, 007 OF oDlgPrinc COLORS 0, 16777215 PIXEL
	    @ 029, 019 MSGET cNota SIZE 060, 010 Picture "@!" OF oDlgPrinc COLORS 0, 16777215 PIXEL
	    @ 029, 093 MSGET cPref SIZE 060, 010 Picture "@!" OF oDlgPrinc COLORS 0, 16777215 PIXEL
	    @ 056, 087 BUTTON oButtonOk1 PROMPT "OK" SIZE 037, 012 OF oDlgPrinc ACTION fSubmit() PIXEL
	    @ 056, 127 BUTTON oButtonCanc1 PROMPT "Cancelar" SIZE 037, 012 OF oDlgPrinc ACTION Entrada() PIXEL
	  ACTIVATE MSDIALOG oEntra CENTERED
End
Return

Static Function fSubmit()
Private oSaida
Private oButtonCanc2
Private oButtonOK2
Private oGroup2
Private oSayCliente2
Private oSayData2
Private oSayNrNF2
Private oSaySerie2
Private iTemData

  DEFINE MSDIALOG oSaida TITLE "Dados da NF Saida" FROM 000, 000  TO 300, 345 COLORS 0, 16777215 PIXEL

    @ 006, 007 GROUP oGroup2 TO 127, 164 OF oSaida COLOR 0, 16777215 PIXEL
    @ 016, 018 SAY oSayNrNF2 PROMPT "Nr. NF" SIZE 050, 007 OF oSaida COLORS 0, 16777215 PIXEL
    @ 026, 018 SAY oSayNrNFResp2 PROMPT cNota SIZE 060, 010 OF oSaida COLORS 0, 16777215 PIXEL
    @ 016, 093 SAY oSaySerie2 PROMPT "Série" SIZE 050, 007 OF oSaida COLORS 0, 16777215 PIXEL
    @ 025, 093 SAY oSaySerieResp2 PROMPT cPref SIZE 060, 010 OF oSaida COLORS 0, 16777215 PIXEL
    @ 041, 018 SAY oSayCliente2 PROMPT "Cliente" SIZE 050, 007 OF oSaida COLORS 0, 16777215 PIXEL
    _Cliente()
    @ 050, 018 MSGET oGetCliente2 VAR cClient SIZE 020, 010 WHEN Empty(cClient) OF oSaida COLORS 0, 16777215 PIXEL
    @ 050, 043 MSGET oGetLoja2 VAR cLoja SIZE 020, 010 WHEN Empty(cLoja) OF oSaida COLORS 0, 16777215 PIXEL
    @ 050, 068 MSGET oGetNome2 VAR wNome SIZE 086, 010 WHEN Empty(wNome) OF oSaida COLORS 0, 16777215 PIXEL
    @ 067, 018 SAY oSayData2 PROMPT "Dt. Liberação" SIZE 050, 007 OF oSaida COLORS 0, 16777215 PIXEL
    @ 076, 018 MSGET oGetData2 VAR dDtExp SIZE 060, 010 WHEN iTemData=0 Picture "@D" OF oSaida COLORS 0, 16777215 PIXEL
    @ 132, 085 BUTTON oButtonOK2 PROMPT "OK" SIZE 037, 012 OF oSaida ACTION fGrava() PIXEL
    @ 132, 127 BUTTON oButtonCanc2 PROMPT "Cancelar" SIZE 037, 012 OF oSaida ACTION Saida() PIXEL
  ACTIVATE MSDIALOG oSaida
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

Return

// Substituido pelo assistente de conversao do AP5 IDE em 22/08/02 ==> Function _Nota
Static Function _Nota()
DbSelectArea("SF2")
DbSetOrder(1)
If !dbSeek(xFilial("SF2")+cNota+cPref,.F.)
	MsgAlert("Nr NF "+cNota+" "+cPref+" Nao Existe")
	Return .F.
EndIf

iExisteItem := 0

cNfExp := "SELECT * "
cNfExp += "FROM " + RetSqlName("SD2") + " SD2 "
cNfExp += "WHERE D2_FILIAL='" + xFilial("SD2") + "' "
cNfExp += "	AND D2_DOC='" + cNota + "' "
cNfExp += "	AND D2_SERIE='" + cPref + "' "
cNfExp += "	AND D2_CLIENTE='" + SF2->F2_CLIENTE + "' "
cNfExp += "	AND D2_LOJA='" + SF2->F2_LOJA + "' "
cNfExp += "	AND D2_ITEM='01' "
cNfExp += "	AND D2_CF IN ('5501','5502','7101','7102') "
cNfExp += "	AND SD2.D_E_L_E_T_ = '' "


TCQUERY cNfExp New Alias "cSql"
dbSelectArea("cSql")
dbGoTop()

While !Eof()
	iExisteItem := 1
	If Empty(SF2->F2_YDTEXP)
		dDtExp   := dDataBase
		iTemData := 0
	Else
		MsgAlert("Nr NF  "+cNota+" "+cPref+" Ja Foi Alterada...")
		dDtExp   := SF2->F2_YDTEXP
		iTemData := 1
	EndIf
	
	DbSelectArea("cSql")
	DbSkip()
End
cSql->(dbCloseArea())

If iExisteItem == 0
	MsgAlert("Nr NF "+cNota+" "+cPref+" não possui item com CFOP 5501, 5502, 7101, 7102")
	iTemData := 1
	Return .F.
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
	If iTemData=0
		SF2->F2_YDTEXP   := dDtExp
		MsUnLock()
		MsgAlert("Nr NF Do Cliente Selecionado Alterado Com Sucesso")
		
		//Libera o credito di cliente que estava bloqueado devido ao prazo de entrega da declaração ser superior a 120 dias 
		//Este bloqueio é realizado pelo programa BIAF024 - Workflow
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