#include "rwmake.ch"

User Function BIA926()

	Local xxn

	SetPrvt("WALIAS,CARQSB1,CARQSA1,LFUNCAO,XXN")
	SetPrvt("XCCAMPO,WTES,WCOD,WDUPLI,")

	wAlias  := Alias()
	cArqSB1 := cArqSA1 := lFuncao := " "
	
	If IsInCallStack("U_TACLNFJB") .Or. IsInCallStack("U_BACP0012") .Or. IsInCallStack("U_PNFM0002") .Or. IsInCallStack("U_PNFM0005") .Or. IsInCallStack("U_JOBFATPARTE")
		Return M->D1_TES
	EndIf

	If IsInCallStack("U_COPYDOCE") .And. IsBlind()

		Return(M->D1_TES)

	EndIf

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "D1_TES"
			wTes    := aCols[n][xxn]
		Endif
		If xcCampo == "D1_COD"
			wCod   := aCols[n][xxn]
		Endif
		if xcCampo == "D1_CLVL"
			cCLVL  := aCols[n][xxn]
		endif
		if xcCampo == "D1_YREGRA"
			cREGRA  := aCols[n][xxn]
		endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cadastro de TES                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek(xFilial("SF4")+wTes,.F.)

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+wCod,.F.)

	dbSelectArea("SBZ")
	dbSetOrder(1)
	dbSeek(xFilial("SBZ")+wCod,.F.)

	dbSelectArea("SBM")
	dbSetOrder(1)
	dbSeek(xFilial("SBM")+SB1->B1_GRUPO,.F.) 

	//Fernando/Facile em 14/07/15 - retirar mensagem de TES sem estoque para produto comum
	_lComum := .F.
	SBZ->(DbSetOrder(1))
	If SBZ->(DbSeek(xFilial("SBZ")+wCod)) .And. SBZ->BZ_YCOMUM == "S"
		_lComum := .T.
	EndIf 

	//Verifica se a TES utilizada confere com o Tipo de Venda
	If Subs(cCLVL,1,1) = "8" .and. Alltrim(SF4->F4_ESTOQUE) == "S"
		MsgBox("TES Usada Inválida. Este material é do tipo MD e não deverá atualizar estoque!","Atencao","ALERT")
		lretorno := .F.
	Else
		//If SM0->M0_CODIGO = "01"
		If cREGRA = "N"
			If Alltrim(SBZ->BZ_YMD) == "S"
				If SBM->BM_YCON_MD = "N"
					//Para Produto MD so pode utilizar TES que nao atualiza Estoque
					If Alltrim(SF4->F4_ESTOQUE) == "S"
						MsgBox("TES Usada Inválida. Este material é do tipo MD e não deverá atualizar estoque!","Atencao","ALERT")
						wTes := ""
					EndIf
				Else
					If Alltrim(SF4->F4_ESTOQUE) == "N"
						MsgBox("TES Usada Inválida. Este material é do tipo MD deverá atualizar estoque!","Atencao","ALERT")
						wTes := ""
					EndIf
				EndIf

			ElseIf Alltrim(SB1->B1_TIPO) == "MP" .OR. Alltrim(SB1->B1_TIPO) == "MC" .OR. Alltrim(SB1->B1_TIPO) == "ME" .OR. Alltrim(SB1->B1_TIPO) == "OI"
				If Alltrim(SF4->F4_ESTOQUE) <> "S" .And. !_lComum
					msgBox("TES Usada Inválida. Este material é do tipo MP, MC, ME ou OI e deverá atualizar estoque.","ALERT")
					wTes := ""
				EndIf
			EndIf
		EndIf
		//EndIf
	EndIf

	// Por Marcos Alberto Soprani. Inicialmente (em 10/09/12) havia criado um outro gatinho, mas em 29/10/12 observando melhor, retirei o outro gatilho e incorporei todo neste.
	If ( Alltrim(Gdfieldget("D1_COD",n)) >= "3060091" .and. Alltrim(Gdfieldget("D1_COD",n)) <= "3060106" ) .or. ( Alltrim(Gdfieldget("D1_COD",n)) >= "3060220" .and. Alltrim(Gdfieldget("D1_COD",n)) <= "3060165" )
		MsgINFO("Favor confirmar as informções fiscais, pois o produto se trata de LOCAÇÃO!!!","Atenção. (BIAXFUN)")
	EndIf

Return(wTes)
