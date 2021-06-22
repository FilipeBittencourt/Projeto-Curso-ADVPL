#include "rwmake.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ BIA134	  ³ Autor ³ Cesar Magnago			 ³ Data ³ 25/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Conta do SB1 esta correta em funcao do C.Custo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Interpretador xBase														 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function Bia134A()

	Local xxn

	SetPrvt("XXN,XCCAMPO,WSCONTA,WSCOD,WSCLVL,WSCONTADIG,CMSG,")

	aArea := GetArea()

	wsConta := SPACE(20)
	wAlias   := Alias()

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C7_CONTA"
			wsConta := aCols[n][xxn]
		Endif
		If xcCampo == "C7_PRODUTO"
			wsCod   := aCols[n][xxn]
		Endif
		If xcCampo == "C7_CLVL"
			wsCLVL  := aCols[n][xxn]
		Endif
		If xcCampo == "C7_ITEMCTA"
			wItemCta  := aCols[n][xxn]
		Endif
	Next

	// Tiago Rossini Coradini - 14/06/2016
	If Empty(wsCLVL) .And. FunName() == "EICPO400"
		wsCLVL := SW2->W2_YCLVL
	EndIf
	// Por Marcos Alberto Em 14/12/16
	If Empty(wItemCta) .And. FunName() == "EICPO400"
		SW3->(dbSetOrder(1))
		SW3->(dbSeek(xFilial("SW3") + SW2->W2_PO_NUM))
		wItemCta := SW3->W3_YITEMCT
	EndIf

	// Tiago Rossini Coradini - 14/06/2016 - Rodolfo Stanke - Problema na alteração de PO
	If UPPER(ALLTRIM(FUNNAME())) $ "MATA121/EICPO400"

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wsCod,.F.)

		If Subs(wsCLVL,1,1) $ "1_2_4_6_8"
			If !Empty(SB1->B1_YCTRADM)
				wsConta := SB1->B1_YCTRADM
			Else
				cMsg := ""
				cMsg += "AVISO!!"+chr(13)
				cMsg += "BIA134A - Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)
				cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
				alert(cMsg)
				AutoGrLog(cMsg)
				wsCLVL := Space(10)
			Endif

		Elseif Subs(wsCLVL,1,1) == "3"

			If SB1->B1_TIPO <> "PI" // Por Marcos Alberto Soprani em 18/05/12
				If !Empty(SB1->B1_YCTRIND)
					wsConta := SB1->B1_YCTRIND
				Else
					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += "BIA134A - Este produto exige a Conta de Resultado Industrial que esta "+chr(13)
					cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
					alert(cMsg)
					AutoGrLog(cMsg)
					wsCLVL := Space(10)
				Endif
			EndIf

		Elseif !Subs(wsCLVL,1,1) $ "1_2_3_4_6_8"

			Help(" ",1,"CONTNF02 - BIA134A")
			wsCLVL := Space(10)

		Endif

		For xxn := 1 to Len(aHeader)

			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "C7_CONTA"
				aCols[n][xxn] := wsConta
			Endif

			If xcCampo == "C7_PRODUTO"
				aCols[n][xxn] := wsCod
			Endif

			If xcCampo == "C7_CLVL"
				aCols[n][xxn] := wsCLVL
			Endif

			If xcCampo == "C7_ITEMCTA"
				aCols[n][xxn] := wItemCta
			Endif

		Next

		If !Empty(wsConta)
			DbSelectArea("CT1")
			DbSetOrder(1)
			If !DbSeek(xFilial("CT1")+wsConta,.F.)
				MsgAlert("BIA134A - Classe de Valor Digitada nao pode ser aplicado a este PRODUTO", "ATENCAO")
				AutoGrLog("BIA134A - Classe de Valor Digitada nao pode ser aplicado a este PRODUTO")
				wsConta := SPACE(20)
			EndIf
		EndIf

	Endif

	If Subs(wsCod,1,1) == "2" .And. Subs(wsCod,4,4) <> "0000"
		wsConta := SB1->B1_CONTA
	EndIf

	RestArea(aArea)

	DbSelectArea(wAlias)

Return(wsConta)
