#include "rwmake.ch" 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LP610030   ³ Autor ³ Microsiga             ³ Data ³ 10/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contabilizacao do Valor                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigafat                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP610030()
//Armazena area de Trabalho
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0 

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0 

Private cArqSD2	:= ""
Private cIndSD2	:= 0
Private cRegSD2	:= 0    

Private nValor  := SD2->D2_TOTAL

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()
                   
DbSelectArea("SD2")
cArqSD2 := Alias()
cIndSD2 := IndexOrd()
cRegSD2 := Recno()

DbSelectArea("SF4")
DbSeek(xFilial("SF4")+SD2->D2_TES,.T.)
                                     
IF SF4->F4_YCCONT == '540'
    IF SF4->F4_CREDICM == 'S'
  	   nValor := nValor - SD2->D2_VALICM
    ENDIF
    IF SF4->F4_PISCOF $ '1,2,3' .AND. SF4->F4_PISCRED == '2'
       nValor := nValor - (SD2->D2_VALIMP6 + SD2->D2_VALIMP5)
    ENDIF      
    IF SF4->F4_COMPL == 'S' .AND. SF2->F2_EST <> 'ES'
       nValor := nValor + (SD2->D2_BASEICM * 10 / 100)
    ENDIF
ELSE
    nValor := 0
ENDIF

//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
	RetIndex("SD2")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(nValor)