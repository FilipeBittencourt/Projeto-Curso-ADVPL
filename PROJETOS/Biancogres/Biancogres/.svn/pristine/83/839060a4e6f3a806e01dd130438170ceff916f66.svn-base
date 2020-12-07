#include "rwmake.ch"

/*/{Protheus.doc} BIA788
@author Joao Carlos Andrade
@since 18/12/00
@version 1.0
@description Execblock para permitir a contabilizacao baseado no grupo
.            contabil do arquivo de tipo de entrada/saida (tes)
@Obs Em 23/08/17... Por Marcos Alberto Soprani... Convertido cabeçalho de documentação 
@type function
/*/

User Function FAT001I1()

	//Variaveis de Posicionamento
	//--------------------------------
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

	//Grava variaveis
	cTes   := SD2->D2_TES
	nValor := 0
	xGrupo := ""

	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de saida
		xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
	Endif

	DO CASE
		CASE xGrupo $ "501/530" .AND. SD2->D2_TIPO <> "P"
		nValor := SD2->D2_TOTAL+SD2->D2_VALIPI+SD2->D2_ICMSRET
		CASE xGrupo == "710"
		nValor := SD2->D2_ICMSRET
		CASE xGrupo == "590"
		nValor := SD2->D2_ICMSRET
		CASE xGrupo == "501" .AND. SD2->D2_TIPO == "P"
		nValor := SD2->D2_TOTAL
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
