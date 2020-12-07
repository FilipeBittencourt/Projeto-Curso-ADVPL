#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 11/04/06

User Function INC115()        // incluido pelo assistente de conversao do AP6 IDE em 11/04/06

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WOK,CDTENTI,CDTENTF,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ INC115     ³ Autor ³ Cesar Magnago         ³ Data ³ 28/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz acerto no campo F3_OBSERV                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
DbSelectArea("SF3")
DbSetOrder(1)
DbGoTop()

wOk      := .T.

While wOk
       @ 0,0 TO 250,450 DIALOG oEntra TITLE "Dados da NF de Entrada"

       cDtEntI  := CTOD("")
       cDtEntF  := CTOD("")
       @ 25,10 SAY "Da  Dt Entrada "
       @ 25,70 GET cDtEntI   PICT "@D"
       @ 40,10 SAY "Ate Dt Entrada "
       @ 40,70 GET cDtEntF   PICT "@D"

       @ 100,80  BUTTON "_Ok"       SIZE 30,15 ACTION fSubmit()// Substituido pelo assistente de conversao do AP6 IDE em 11/04/06 ==>        @ 100,80  BUTTON "_Ok"       SIZE 30,15 ACTION Execute(fSubmit)
       @ 100,120 BUTTON "_Abortar"  SIZE 30,15 ACTION fAborta()// Substituido pelo assistente de conversao do AP6 IDE em 11/04/06 ==>        @ 100,120 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)
       ACTIVATE DIALOG oEntra CENTERED
EndDo

Return

// Substituido pelo assistente de conversao do AP6 IDE em 11/04/06 ==> Function fSubmit
Static Function fSubmit()

DbSeek(xFilial("SF3")+DTOS(cDtEntI),.T.)

While !EOF() .And. SF3->F3_ENTRADA <= cDtEntF

   If !Empty(F3_IPIOBS)
      RecLock("SF3")
      Replace F3_IPIOBS With 0
      DbUnLock()
      DbSkip()
      Loop
   EndIf

   If Subst(F3_OBSERV,1,28) == "AQUIS.COMERC.NAO-CONTRIB.IPI"
      fGrava()
   EndIf

   If Subst(F3_OBSERV,1,14) == "COMPL.PC.N.F.:"
      fGrava()
   EndIf

   If Subst(F3_OBSERV,1,11) == "COMPL.N.F.:"
      fGrava()
   EndIf

   If Subst(F3_OBSERV,1,5)  == "FRETE"
      fGrava()
   EndIf

   DbSkip()
EndDo

MsgAlert("Acerto Efetuado Com Sucesso...")
cDtEntI  := CTOD("")
cDtEntF  := CTOD("")

Return

// Substituido pelo assistente de conversao do AP6 IDE em 11/04/06 ==> Function fGrava
Static Function fGrava()

   RecLock("SF3")
   Replace F3_OBSERV  With Space(30)
   DbUnLock()

Return

// Substituido pelo assistente de conversao do AP6 IDE em 11/04/06 ==> Function fAborta
Static Function fAborta()

  wOk    := .F.
  Close( oEntra )

Return

