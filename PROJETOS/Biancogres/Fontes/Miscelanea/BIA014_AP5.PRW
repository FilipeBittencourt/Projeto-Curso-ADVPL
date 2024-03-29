#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia014()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	Local xxn
	SetPrvt("WALIAS,CARQSB1,CARQSA1,LFUNCAO,XXN")
	SetPrvt("XCCAMPO,WCOD,WQTDVEN,WVALDESC,WDESC,WPRUNIT")
	SetPrvt("WCOND,WCLIENTE,WLOJA,WLIMMIN,WLIMMAX,CINDSB1")
	SetPrvt("CREGSB1,WREFER,CINDSA1,CREGSA1,WEST")
	SetPrvt("WUSUARIO,")

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

	wAlias   := Alias()
	cArqSB1  := cArqSA1 := lFuncao := " "
	wValDesc := 0

	IF ALLTRIM(FUNNAME()) <> "EECAP100"
		//If M->C5_TIPOCLI <> "X"  MADALENO

		For xxn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "C6_PRODUTO"
				wCod    := aCols[n][xxn]
			Endif
			If xcCampo == "C6_QTDVEN"
				wQtdVen := aCols[n][xxn]
			Endif
			If xcCampo == "C6_VALDESC"
				wValDesc:= aCols[n][xxn]
			Endif
			If xcCampo == "C6_DESCONT"
				wDesc   := aCols[n][xxn]
			Endif
			If xcCampo == "C6_PRUNIT"
				wPrunit := aCols[n][xxn]
			Endif
		Next
		wCond   := M->C5_CONDPAG
		wCliente:= M->C5_CLIENTE
		wLoja   := M->C5_LOJAENT
		wLimMin := wLimMax := 0

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Cadastro do Produto                                                   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		DbSelectArea("SB1")
		cArqSB1 := Alias()
		cIndSB1 := IndexOrd()
		cRegSB1 := Recno()
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
		cArqSA1 := Alias()
		cIndSA1 := IndexOrd()
		cRegSA1 := Recno()
		DbSetOrder(1)
		If dbSeek(xFilial("SA1")+wCliente+wLoja,.f.)
			wEst := SA1->A1_EST
			// wEst <> "EX" .And. wEst <> "ES"
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
		//cArqSZ1 := Alias()
		//cIndSZ1 := IndexOrd()
		//cRegSZ1 := Recno()
		//DbSetOrder(1)
		//If dbSeek(xFilial("SZ1")+wRefer+wEst+wCond,.f.)
		//	wLimMin := SZ1->Z1_LIMMIN
		//	wLimMax := SZ1->Z1_LIMMAX
		//Else
		//	msgBox("Referencia nao cadastrado no SZ1","Referencia nao cadastrado","ALERT")
		//EndIf

		wUsuario := alltrim(upper(cUserName))

		Do Case
			Case wUsuario == "ADMINISTRADOR"
			lFuncao := "D"
			Case wUsuario == "MARCELO"
			lFuncao := "G"
			Case wUsuario == "MARTINELLI"
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

		wDesc := Round(((wValDesc * 100) / (wQtdVen * wPrunit)),2)

		//ALERT("wDesc "+str(wDesc,10,2)+" wValDesc "+str(wValDesc,10,2))

		If wDesc <> 0
			If lFuncao == "G"
				Do Case
					Case wDesc < wLimMin
					msgBox("Atencao. Desconto Concedido menor que o Desconto Minimo Permitido","Desconto Concedido","ALERT")
					wValDesc := 0
					Case wDesc > wLimMax
					msgBox("Atencao. Desconto Concedido maior que o Desconto Maximo Permitido","Desconto Concedido","ALERT")
					wValDesc := 0
				EndCase
			EndIf

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Finaliza o Programa                                                      �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If alltrim(cArqSA1) <> ""
				dbSelectArea(cArqSA1)
				dbSetOrder(cIndSA1)
				dbGoTo(cRegSA1)
			EndIf
			If alltrim(cArqSB1) <> ""
				dbSelectArea(cArqSB1)
				dbSetOrder(cIndSB1)
				dbGoTo(cRegSB1)
			EndIf
		EndIf

		dbSelectArea(wAlias)

	EndIf

Return(wValDesc) 
