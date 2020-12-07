#include "rwmake.ch" 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAT004I1   ³ Autor ³ Joao Carlos Andrade   ³ Data ³ 20/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contabilizacao do IPI                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigafat                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FAT004I1()
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

//Armazena variaveis
cTes     := SD2->D2_TES
nValor   := 0

DbSelectArea("SF4")
DbSeek(xFilial("SF4")+cTes,.T.)
xGrupo := F4_YCCONT

//Define valor a ser contabilizado 
/*
If xGrupo == "510"
  nValor := SD2->D2_VALIPI
EndIf
If SF4->F4_CREDIPI == "S" .or. xGrupo == "650"
  nValor := SD2->D2_VALIPI
EndIf
If xGrupo == "570" .and. SD2->D2_TES=="510"
  nValor := SD2->D2_VALIPI
EndIf
*/
                               
DO CASE
   CASE SF4->F4_CREDIPI == "S" .or. xGrupo == "650"
	  nValor := SD2->D2_VALIPI
ENDCASE

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