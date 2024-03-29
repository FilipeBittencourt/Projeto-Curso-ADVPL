#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia013()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	Local xxn

	SetPrvt("WALIAS,CARQSB1,LFUNCAO,XXN")
	SetPrvt("XCCAMPO,WCOD,WVALDESC,WDESC,WCOND,WCLIENTE")
	SetPrvt("WLOJA,WLIMMIN,WLIMMAX,CINDSB1,CREGSB1,WREFER")
	SetPrvt("CINDSA1,CREGSA1,WEST,WUSUARIO")

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSA1	:= ""
	Private cIndSA1	:= 0
	Private cRegSA1	:= 0

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	/*/
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � BIA013     � Autor � MICROSIGA VITORIA     � Data � 12/05/99 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇙o � Determina se o usuario podera alterar o Desconto do Item SC6 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � Interpretador x Base                                         낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/

	wAlias  := Alias()
	wDesc   := 0

	IF ALLTRIM(FUNNAME()) <> "EECAP100"
		For xxn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "C6_PRODUTO"
				wCod    := aCols[n][xxn]
			Endif
			If xcCampo == "C6_VALDESC"
				wValDesc:= aCols[n][xxn]
			Endif
			If xcCampo == "C6_DESCONT"
				wDesc   := aCols[n][xxn]
			Endif
		Next

		If wDesc <> 0
			wCond   := M->C5_CONDPAG
			wCliente:= M->C5_CLIENTE
			wLoja   := M->C5_LOJAENT
			wLimMin := wLimMax := 0

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Cadastro do Produto                                                   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			DbSelectArea("SB1")
			DbSetOrder(1)
			If dbSeek(xFilial("SB1")+wCod,.f.)
				wRefer := SB1->B1_YREFPV
			Else
				msgBox("Produto nao cadastrado no SB1","Produto nao cadastrado","ALERT")
			EndIf

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Cadastro do Cliente                                                   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			DbSelectArea("SA1")
			DbSetOrder(1)
			If dbSeek(xFilial("SA1")+wCliente+wLoja,.f.)
				wEst := SA1->A1_EST
				//If wEst <> "EX" .And. wEst <> "ES"
				If !wEst $ ("ES_EX")
					wEst := "SP"
				EndIF
			Else
				msgBox("Cliente nao cadastrado no SA1","Cliente nao cadastrado","ALERT")
			EndIf

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Cadastro do Preco de Vendas                                           �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//DbSelectArea("SZ1")
			//DbSetOrder(1)
			//If dbSeek(xFilial("SZ1")+wRefer+wEst+wCond,.f.)
			//	wLimMin := SZ1->Z1_LIMMIN
			//	wLimMax := SZ1->Z1_LIMMAX
			//Else
			//	msgBox("Referencia nao cadastrado no SZ1","Referencia nao cadastrada","ALERT")
			//EndIf

			wUsuario := alltrim(upper(cUserName))

			Do Case
				Case wUsuario == "ADMINISTRADOR"
				lFuncao := "D"
				Case wUsuario == "MARCELO"
				lFuncao := "G"
				Case wUsuario == "CAMERINO"
				lFuncao := "D"
				Case wUsuario == "VALMIR"
				lFuncao := "D"
				Case wUsuario == "KELMER"
				lFuncao := "D"
				Case wUsuario == "DCASOTTI"
				lFuncao := "D"
				Case wUsuario == "DIRCOM"
				lFuncao := "D"
				OtherWise
				lFuncao := "F"
			EndCase

			If lFuncao == "G"
				Do Case
					Case wDesc < wLimMin
					msgBox("Atencao. Desconto Concedido menor que o Desconto Minimo Permitido","Desconto Concedido","ALERT")
					wDesc := 0
					Case wDesc > wLimMax
					msgBox("Atencao. Desconto Concedido maior que o Desconto Maximo Permitido","Desconto Concedido","ALERT")
					wDesc := 0
				EndCase
			EndIf
		EndIf

		dbSelectArea(wAlias)
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(wDesc)
