#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02

User Function bia311()        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	local i
	SetPrvt("WN,LERRO1,LERRO2,WERRO,WI,WDOCS")
	SetPrvt("WQTD,I,N,")

	/*/
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un눯o    � BIA311   � Autor � MICROSIGA Vitoria     � Data � 28.07.00 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri눯o � Cadastro de Precos - atualizacao                           낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � RDMAKE                                                     낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifique duplicidade                                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	wn     := n
	lErro1 := .F.
	lErro2 := .F.
	wErro  := .F.

	If  ! aCols[n,nUsado+1]
		If  Empty(aCols[n,1]) .Or. ;
		Empty(aCols[n,2]) .Or. ;
		Empty(aCols[n,3])
			lErro1 := .T.
		Endif
		wi     := i
		wDocs  := aCols[n,1]+aCols[n,2]
		wQtd   := 0
		For  i := 1 to len(aCols)
			If  ! aCols[i,nUsado+1]
				If  aCols[i,1]+aCols[i,2] == wDocs
					wQtd := wQtd + 1
				Endif
			Endif 
		Next
		If  wQtd > 1
			lErro2 := .T.
		Endif
		i := wi
	Endif
	If  lErro1 .or. lErro2
		If  lErro1
			MsgBox("Verifique se todos os campos estao preenchidos nesta linha.","BIA311 - Preenchimento de Campos","STOP")
			wErro := .T.
		Endif
		If  lErro2
			MsgBox("Linha repetida. Verifique.","BIA311 - Duplicidade","STOP")
			wErro := .T.
		Endif
	Endif
	n := wn

	If wErro 
		// Substituido pelo assistente de conversao do AP5 IDE em 17/05/02 ==>    __Return(.F.)
		Return(.F.)        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02
	Else
		// Substituido pelo assistente de conversao do AP5 IDE em 17/05/02 ==>    __Return(.T.)
		Return(.T.)        // incluido pelo assistente de conversao do AP5 IDE em 17/05/02
	EndIf

Return

