#include "rwmake.ch"

/*/{Protheus.doc} BIA154A
@author Joao Carlos Andrade
@since 20/12/00
@version 1.0
@description Gatilho para identificar a conta contabil que sera gravado
.            no campo D3_CONTA na digitacao da Movimentacao Interna
@obs Em 22/02/17... Por Marcos Alberto Soprani... Ajuste na regra de gravação da conta contábil - D3_CONTA
@type function
/*/

User Function BIA154A()

	Local cProduto
	Local xxn

	cAlias := Alias()
	lOK    := .T.
	cConta := ""

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO
	IF Type("_IViaEAuto") <> "U"
		cConta   := M->D3_CONTA
		Return(cConta)
	ENDIF

	//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	IF Type("_ExecAutoII") <> "U"
		cConta := Gdfieldget("D3_CONTA",n)
		RETURN(cConta)
	ENDIF

	//Por Marcos Alberto Soprani em 25/05/12 para atender a integração com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		cConta := SB1->B1_YCTRIND
		Return(cConta)
	EndIf

	// Alteração efetuada em 28/09/11 por Marcos Alberto em virtude da obrigatoriedade de digitação da classe de valor amarrada ao centro de custo.
	If Upper(AllTrim(FunName())) $ "MATA241/BIA271/BIA292/BIA294/BIA701/BIA742/BIA570" .Or. IsInCallsTack("U_BIAFG120")

		If Upper(AllTrim(FunName())) == "MATA241"     // Implementado por Marcos Alberto Soprani em 26/03/13
			************************************************************************************************
			If SB1->B1_TIPO == "PI" .and. CTM $ "120/720"
				cConta := SB1->B1_YCTRIND
				Return(cConta)
			EndIf
		EndIf

		If SB1->B1_TIPO == "PA"
			cConta := SB1->B1_CONTA
			Return(cConta)
		Else
			cConta := M->D3_CONTA
			Return(cConta)
		EndIf

	EndIf

	If UPPER(ALLTRIM(FUNNAME())) == "MATA241"

		For xxn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "D3_COD"
				cProduto := aCols[n][xxn]
			Endif
			If xcCampo == "D3_CONTA"
				cConta := aCols[n][xxn]
			Endif
			If xcCampo == "D3_CC"
				cCC := CCC
			Endif
			If xcCampo == "D3_CLVL"
				cCLVL := aCols[n][xxn]
			Endif
		Next

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cProduto,.f.)

		lkAplCta := U_B478RTCC(cCLVL)[2]
		If lkAplCta == "D"

			If !Empty(SB1->B1_YCTRADM)

				cConta := SB1->B1_YCTRADM

			Else

				cMsg := ""
				cMsg += "AVISO!!"+chr(13)
				cMsg += "BIA154A - Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)
				cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
				alert(cMsg)
				AutoGrLog(cMsg)
				cCC := Space(10)

			Endif

		ElseIf lkAplCta == "C"

			If SB1->B1_TIPO <> "PI" // Por Marcos Alberto Soprani em 18/05/12

				If !Empty(SB1->B1_YCTRIND)

					cConta := SB1->B1_YCTRIND

				Else

					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += "BIA154A - Este produto exige a Conta de Resultado Industrial que esta "+chr(13)
					cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
					alert(cMsg)
					AutoGrLog(cMsg)
					cCC := Space(10)

				Endif

			EndIf

		ElseIf lkAplCta $ "A/I"

			cConta := "16503" + Substr(cCLVL,2,8)

		Elseif !Subs(cCC,1,1) $ "1_2_3_4_6_8"

			Help(" ",1,"CONTNF02 - BIA154A")
			cCC := Space(10)

		Endif

		For xxn := 1 to Len(aHeader)

			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "D3_CONTA"
				aCols[n][xxn] := cConta
			Endif
			If xcCampo == "D3_COD"
				aCols[n][xxn] := cProduto
			Endif

		Next

	ElseIf UPPER(ALLTRIM(FUNNAME())) == "MATA240" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"

		cConta := M->D3_CONTA

	Endif

	DbSelectArea(cAlias)

Return(cConta)
