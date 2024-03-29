#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia133()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	Local xxn
	SetPrvt("WALIAS,CARQSB1,CARQSA1,CARQSA3,LFUNCAO,XXN")
	SetPrvt("XCCAMPO,WTES,WYNFDEL,WDUPLI,")

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSF4	:= ""
	Private cIndSF4	:= 0
	Private cRegSF4	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SF4")
	cArqSF4 := Alias()
	cIndSF4 := IndexOrd()
	cRegSF4 := Recno()

	/*/
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � BIA133     � Autor � CESAR MAGNAGO         � Data � 25/07/00 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇙o � So pode usar TES sem gerar duplicata para o Del-Credere      낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � Interpretador x Base                                         낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/

	wAlias  := Alias()
	cArqSB1 := cArqSA1 := cArqSA3 := lFuncao := " "
	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C6_TES"
			wTes    := aCols[n][xxn]
		Endif
	Next

	wYNfDel   := M->C5_YNFDEL
	wYTipo    := M->C5_TIPO

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Cadastro de TES                                                       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	DbSelectArea("SF4")
	DbSetOrder(1)
	If dbSeek(xFilial("SF4")+wTes,.F.)
		wDupli := SF4->F4_DUPLIC
	Else
		msgBox("TES nao cadastrada, Favor verificar ...","ALERT")
	EndIf

	//If !Empty(wYNfDel)
	//If wDupli == "S"
	//	wTes  := ""
	//	msgBox("TES usada Gera Duplicata favor verificar ...","ALERT")
	//EndIf
	//EndIf

	//If wTes == "502"
	//	wTes := ""
	//	msgBox("TES bloqueada... - Favor Entrar em Contato Com o Setor Fiscal ...","ALERT")
	//EndIf

	//If wYTipo == "B"
	//	If !wTes $("538_553_895_896_897_898_902_903_906_909_914_916_996_997_999")
	//		wTes := ""
	//		msgBox("TES Usada Invalida - Favor Entrar em Contato Com o Setor Fiscal ...","ALERT")
	//	EndIf
	//EndIf

	// Informa a Mensagem Padrao do Pedido conforme a TES - Modificado conf. solicitacao da Sr. Sueli
	Do Case
		Case wTes $ '519/5B9'
		M->C5_MENPAD := "007"
		Case wTes $ '997/9J7' .and. Alltrim(cempant) == "01" //TES BLOQUEADA
		M->C5_MENPAD := "001"
		Case wTes $ '503/5A3'
		M->C5_MENPAD := "016"
		Case wTes $ '507/5A7'
		M->C5_MENPAD := "002"
		Case !wTes $ ("519","5B9","997","9J7","503","5A3","507","5A7")
		M->C5_MENPAD := "   "
	EndCase

	If cArqSF4 <> ""
		dbSelectArea(cArqSF4)
		dbSetOrder(cIndSF4)
		dbGoTo(cRegSF4)
		RetIndex("SF4")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(wTes)
