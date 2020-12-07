#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} BIA158A
@author Joao Carlos Andrade
@since 20/12/00
@version 1.0
@description Gatilho para identificar a conta contabil que sera gravado
.            no campo D1_CONTA na digitacao da Nota Fiscal de Entrada
@obs Em 22/02/17... Por Marcos Alberto Soprani... Ajuste na regra de gravação da conta contábil - D1_CONTA
@type function
/*/

USER FUNCTION BIA158A()

	Local cProduto 	:= ""
	Local cConta 	:= ""
	Local cCLVL		:= ""
	Local cTES		:= ""
	Local xxn

	cAlias := Alias()

	If UPPER(ALLTRIM(FUNNAME())) $ "EICDI154"
		Return ( "" )
	EndIf

	If IsInCallStack("U_BACP0012")
		Return("")
	EndIf
	If IsInCallStack("U_COPYDOCE") .And. IsBlind()

		Return("")

	EndIf

	If UPPER(ALLTRIM(FUNNAME())) $ "MATA103/MATA116/FAXML02/BIA296/U_GATI001/MATA140"

		For xxn := 1 to Len(aHeader)
			If Trim(aHeader[xxn][2]) == "D1_COD"
				cProduto := aCols[n][xxn]
			Endif
			If Trim(aHeader[xxn][2]) == "D1_CONTA"
				cConta := aCols[n][xxn]
			Endif
			If Trim(aHeader[xxn][2]) == "D1_CLVL"
				cCLVL    := aCols[n][xxn]
			Endif
			If Trim(aHeader[xxn][2]) == "D1_TES"
				cTES    := aCols[n][xxn]
			Endif
			If IsInCallStack("MATA140")
				If Trim(aHeader[xxn][2]) == "D1_YTESPN"
					cTES    := aCols[n][xxn]
				Endif
			Endif
		Next

	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + cProduto, .F.)

	dbSelectArea("SBZ")
	dbSetOrder(1)
	dbSeek(xFilial("SBZ") + cProduto, .F.)

	DbSelectArea("SBM")
	DbSetOrder(1)
	DbSeek(xFilial("SBM") + SB1->B1_GRUPO, .F.)

	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4") + cTES, .F.)

	// Retirada regra que gerar ambiguidade no preenchimento do campo conta em 01/06/20 por Marcos Alberto Soprani
	lkAplCta := U_B478RTCC(cCLVL)[2]

	If Alltrim(SBZ->BZ_YMD) <> "S"
		cConta := SB1->B1_CONTA

	ElseIf SF4->F4_ESTOQUE == "S"
		cConta := SB1->B1_CONTA

	ElseIf Alltrim(SBZ->BZ_YMD) == "S" .and. SBM->BM_YCON_MD == "S" .and. SF4->F4_ESTOQUE == "S"
		cConta := SB1->B1_CONTA

	ElseIf SF4->F4_ESTOQUE == "N" .And. lkAplCta == "D"

		If !Empty(SB1->B1_YCTRADM)
			cConta := SB1->B1_YCTRADM
		Else
			cMsg := ""
			cMsg += "AVISO!!"+chr(13)+Chr(10)
			cMsg += "Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)+Chr(10)
			cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
			alert(cMsg)
			cCLVL := Space(10)
		Endif

	Elseif SF4->F4_ESTOQUE == "N" .And. lkAplCta == "C"

		If SB1->B1_TIPO <> "PI"
			If !Empty(SB1->B1_YCTRIND)
				cConta := SB1->B1_YCTRIND
			Else
				cMsg := ""
				cMsg += "AVISO!!"+chr(13)+Chr(10)
				cMsg += "Este produto exige a Conta de Resultado Industrial que esta "+chr(13)+Chr(10)
				cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
				alert(cMsg)
				cCLVL := Space(10)
			Endif
		EndIf

	ElseIf SB1->B1_TIPO <> "MD"

		cConta := SB1->B1_CONTA

	ElseIf SF4->F4_ESTOQUE == "S"

		cConta := SB1->B1_CONTA

	ElseIf SB1->B1_TIPO == "MD" .AND. SBM->BM_YCON_MD == "S" .And. SF4->F4_ESTOQUE == "S"

		cConta := SB1->B1_CONTA

	ElseIf lkAplCta == "D"

		If !Empty(SB1->B1_YCTRADM)
			cConta := SB1->B1_YCTRADM
		Else
			cMsg := ""
			cMsg += "AVISO!!"+chr(13)+Chr(10)
			cMsg += "Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)+Chr(10)
			cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
			alert(cMsg)
			cCLVL := Space(10)
		Endif

	Elseif lkAplCta == "C"

		If SB1->B1_TIPO <> "PI"
			If !Empty(SB1->B1_YCTRIND)
				cConta := SB1->B1_YCTRIND
			Else
				cMsg := ""
				cMsg += "AVISO!!"+chr(13)+Chr(10)
				cMsg += "Este produto exige a Conta de Resultado Industrial que esta "+chr(13)+Chr(10)
				cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
				alert(cMsg)
				cCLVL := Space(10)
			Endif

		EndIf

	ElseIf lkAplCta $ "A/I"

		cConta := "16503" + Substr(cCLVL,2,8)

	Elseif !Subs(cCLVL,1,1) $ "1_2_3_4_8"

		cCLVL    := Space(10)

	Endif

	CT1->(dbSetOrder(1))
	If CT1->(dbSeek(xFilial("CT1") + cConta))
		If CT1->CT1_BLOQ == "1"
			cConta := Space(20)
		EndIf
	EndIf

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "D1_CONTA"
			aCols[n][xxn] := cConta
		Endif
		If xcCampo == "D1_CLVL"
			aCols[n][xxn] := cCLVL
		Endif
	Next

	DbSelectArea(cAlias)

Return(cConta)
