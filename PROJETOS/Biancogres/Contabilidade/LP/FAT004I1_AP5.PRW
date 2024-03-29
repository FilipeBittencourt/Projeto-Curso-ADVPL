#include "rwmake.ch" 

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � FAT004I1   � Autor � Joao Carlos Andrade   � Data � 20/11/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Contabilizacao do IPI                                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Sigafat                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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