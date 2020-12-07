#include "rwmake.ch" 

/*/{Protheus.doc} FAT005I1
@author Joao Carlos Andrade
@since 20/11/00
@version 1.0
@description Contabilizacao do ICMS 
@type function
/*/

User Function FAT005I1()

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

	// Ajuste conforme OS effettivo 3096-17
	If ( SF4->F4_CREDICM == "S" .and. xGrupo <> "551" ) .or. xGrupo == "650"
		nValor := SD2->D2_VALICM
	EndIf

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
