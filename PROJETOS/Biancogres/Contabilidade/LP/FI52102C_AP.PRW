#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function fi52102c()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CALIAS,CIND,CRECNO,NVALOR,CPREF,CNUM")
SetPrvt("CPARC,XVALOR,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ 52102C   ³ Autor ³ Cesar Magnago         ³ Data ³ 23/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Execblock para permitir a contabilizacao do valor exato    ³±±
±±³          ³ dos Cheques que substituem os Titulos a Receber.           ³±±
±±³          ³ Lancamento Padronizado 52102 ( Conta a Credito )           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico: INCESA                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  

Private aArea := GetArea()

cAlias  := Alias()
cInd    := IndexOrd()
cRecNo  := RecNo()
nValor  := 0

If SE5->E5_PREFIXO <> "CHQ" 
   nValor  := 0
   cPref   := SE5->E5_PREFIXO
   cNum    := SE5->E5_NUMERO
   cParc   := SE5->E5_PARCELA

   DbSelectArea("SE1")                
   aAreaSE1 := GetArea()
   DbSetOrder(1)
   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      While !Eof() .And. SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA == cPref+cNum+cParc
         If AllTrim(SE1->E1_TIPO) <> "JR"
            nValor := SE1->E1_VALLIQ-SE1->E1_JUROS-SE1->E1_MULTA+SE1->E1_DESCONT
         EndIf
         DbSkip()
      EndDo
   EndIf

   DbSelectArea(cAlias)
   DbSetOrder(cInd)
   DbGoTo(cRecNo)       
   
   RestArea(aAreaSE1)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==>    __Return(nValor)
Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

EndIf

If AllTrim(SE5->E5_TIPO) == "CH"
   nValor  := 0
   cPref   := SE5->E5_PREFIXO
   cNum    := SE5->E5_NUMERO
   cParc   := SE5->E5_PARCELA
   xValor  := SE5->E5_VALOR

   DbSelectArea("SE1")
   DbSetOrder(1)

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      cPref   := SE1->E1_YPREFOR
      cNum    := SE1->E1_YNUMOR
      cParc   := SE1->E1_YPARCOR
   EndIf

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      fCalcLiq()
   Else
      nValor := xValor
   Endif

   DbSelectArea(cAlias)
   DbSetOrder(cInd)
   DbGoTo(cRecNo)
EndIf

RestArea(aArea)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nValor)
Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> Function fCalcLiq
Static Function fCalcLiq()

   If SE1->E1_VALLIQ > xValor
      nValor := xValor-SE1->E1_JUROS-SE1->E1_MULTA+SE1->E1_DESCONT
   EndIf
   If SE1->E1_VALLIQ == xValor
      nValor := xValor-SE1->E1_JUROS-SE1->E1_MULTA+SE1->E1_DESCONT
   EndIf
   If SE1->E1_VALLIQ < xValor
      nValor := xValor-SE1->E1_VALLIQ
   EndIf

Return

