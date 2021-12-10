#include "rwmake.ch"

/*/{Protheus.doc} BIA154
@author Joao Carlos Andrade
@since 20/12/00
@version 1.0
@description Gatilho para identificar a conta contabil que sera gravado
.            no campo D3_CONTA na digitacao da Movimentacao Interna
@obs Em 22/02/17... Por Marcos Alberto Soprani... Ajuste na regra de gravação da conta contábil - D3_CONTA
@type function
/*/

User Function BIA154()

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
		cProduto := M->D3_COD
		cCC      := "3000"
	EndIf

	// Alteração efetuada em 28/09/11 por Marcos Alberto em virtude da obrigatoriedade de digitação da classe de valor amarrada ao centro de custo.
	If Upper(AllTrim(FunName())) $ "MATA241"
		If SB1->B1_TIPO $ "PA/PP"
			cConta := Gdfieldget("D3_CONTA",n)
			Return(cConta)
		EndIf
		If SB1->B1_TIPO == "PI" .and. CTM $ "120/720" // Implementado por Marcos Alberto Soprani em 26/03/13
			************************************************************************************************
			cConta := SB1->B1_YCTRIND
			Return(cConta)
		EndIf
	EndIf

	// Alteração efetuada em 29/05/12 por Marcos Alberto
	If Upper(AllTrim(FunName())) $ "MATA240"
		cConta := M->D3_CONTA
		Return(cConta)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a rotina atual e' a Transferenciam Modelo II                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Upper(AllTrim(FunName())) == "MATA261"
		lOK := .F.

	Else

		If Upper(AllTrim(FunName())) <> "MATA240" .AND. Upper(AllTrim(FunName())) <> "MATA250" .and. UPPER(ALLTRIM(FUNNAME())) <> "BIA294"

			For xxn := 1 to Len(aHeader)

				xcCampo := Trim(aHeader[xxn][2])
				If xcCampo == "D3_COD"
					cProduto := aCols[n][xxn]
				Endif
				If xcCampo == "D3_CONTA"
					cConta := aCols[n][xxn]
				Endif
				If xcCampo == "D3_CC"
					cCC  := aCols[n][xxn]
				Endif
				If xcCampo == "D3_CLVL"
					cCLVL := aCols[n][xxn]
				Endif

			Next

			If Upper(AllTrim(FunName())) == "MATA241"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o tipo de movimento foi digitado.                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if (M->CTM$"502,005") .AND. empty(M->CCC)
					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += ""+chr(13)
					cMsg += "E obrigatorio a digitacao do Centro de Custo para este tipo de movimento!"+chr(13)
					alert(cMsg)
					AutoGrLog(cMsg)
				endif

			endif

		else

			cProduto := M->D3_COD
			cConta   := M->D3_CONTA
			cCC      := AllTrim(M->CCC)

		endif

	endif

	If lOK .AND. Upper(AllTrim(FunName())) <> "MATA250"

		// Regra incluida por Marcos Alberto em 24/08/11 para atender o apontamento automático do Esmalte - Rotina BIA257
		If Upper(AllTrim(FunName())) $ "BIA257/BIA271/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120")
			cProduto := M->D3_COD
			cConta   := M->D3_CONTA
			cCC      := "3000"
			cCLVL 	 := SC2->C2_CLVL
		EndIf

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cProduto,.f.)

		lkAplCta := U_B478RTCC(cCLVL)[2]
		If lkAplCta == "D"

			if !Empty(SB1->B1_YCTRADM)
				cConta := SB1->B1_YCTRADM
			else
				cMsg := ""
				cMsg += "AVISO!!"+chr(13)
				cMsg += "BIA154 - Este produto exige a Conta de Resultado Administrativo que esta "+chr(13)
				cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
				alert(cMsg)
				AutoGrLog(cMsg)
				cCC := Space(10)
			endif

		ElseIf lkAplCta == "C"

			If SB1->B1_TIPO <> "PI" // Por Marcos Alberto Soprani em 18/05/12
				If SB1->B1_TIPO $ "PA/PP"
					cConta := ""
				Elseif !Empty(SB1->B1_YCTRIND)
					cConta := SB1->B1_YCTRIND
				else
					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += "BIA154 - Este produto exige a Conta de Resultado Industrial que esta "+chr(13)
					cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
					alert(cMsg)
					AutoGrLog(cMsg)
					cCC := Space(10)
				endif
			EndIf

		ElseIf lkAplCta  $ "A/I"
			cConta := "16503" + Substr(cCLVL,2,8)

		Else

			if !(Subs(cCC,1,1) $ "1,2,3,4,6,8") .AND. !((M->CTM$"502,005") .AND. empty(M->CCC)) .AND. (Upper(AllTrim(FunName())) == "MATA241" )
				Help(" ",1,"CONTNF02 - BIA154")
				cCC := Space(10)
			endif

		EndIf

		// Emerson Salvador - 01/09/2021 - Ticket 34058								
		If Alltrim(cCLVL) == "6212"
			cConta := "16503104"
		EndIf

		If UPPER(ALLTRIM(FUNNAME())) <> "MATA240" .and. UPPER(ALLTRIM(FUNNAME())) <> "BIA294"

			For xxn := 1 to Len(aHeader)

				xcCampo := Trim(aHeader[xxn][2])
				If xcCampo == "D3_CONTA"
					aCols[n][xxn] := cConta
				Endif
				If xcCampo == "D3_CC"
					aCols[n][xxn] := cCC
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Apaga o codigo do produto caso o tipo do movimento seja '502' ou '005'...³
				//³ e o Classe de Valor nao tenha sido digitada.                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (xcCampo == "D3_COD") .AND. (M->CTM$"502,005") .AND. empty(M->CCC) .AND. (Upper(AllTrim(FunName())) == "MATA241" )
					MsgAlert("TESTE 123", "ATENCAO")
					AutoGrLog("TESTE 123")
					aCols[n][xxn] := ""
				endif

			Next

		Endif

		DbSelectArea(cAlias)

	EndIf

Return(cConta)
