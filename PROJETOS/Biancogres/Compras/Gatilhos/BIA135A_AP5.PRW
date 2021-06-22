#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ BIA135     ³ Autor ³ Cesar Magnago         ³ Data ³ 25/09/00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Verifica se a Conta do SB1 esta correta em funcao do C.Custo ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador xBase                                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Alteracoes³ Incluida a validacao para que todos os tipos MD utilizem a   ³±±
	±±³          ³ a conta de materiais (B1_CONTA). 02/12/02                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

User Function bia135A()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	Local xxn

	SetPrvt("WSCONTADIG,WALIAS,XXN,XCCAMPO,WSCONTA,WSCOD")
	SetPrvt("WSCLVL,CMSG,")
	
	wsConta := SPACE(20)
	wAlias   := Alias()

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C1_CONTA"
			wsConta := aCols[n][xxn]
		Endif
		If xcCampo == "C1_PRODUTO"
			wsCod   := aCols[n][xxn]
		Endif
		If xcCampo == "C1_CLVL"
			wsCLVL  := aCols[n][xxn]
		Endif
	Next

	If UPPER(ALLTRIM(FUNNAME())) == "MATA110"

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wsCod,.F.)

		If Subs(wsCod,4,4) == "0000"
			wsConta := SB1->B1_CONTA
		Else
			If Subs(wsCLVL,1,1) $ "1_2_4_5_6_7_8"
				If !Empty(SB1->B1_YCTRADM)
					wsConta := SB1->B1_YCTRADM
				Else
					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += "BIA135A - Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)
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
						cMsg += "BIA135A - Este produto exige a Conta de Resultado Industrial que esta "+chr(13)
						cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
						alert(cMsg)
						AutoGrLog(cMsg)
						wsCLVL := Space(10)
					Endif
				EndIf
			Elseif !Subs(wsCLVL,1,1) $ "1_2_3_4_5_6_7_8"
				Help(" ",1," - BIA135A")
				wsCLVL := Space(10)
			Endif
		EndIf
		For xxn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "C1_CONTA"
				aCols[n][xxn] := wsConta
			Endif

			If xcCampo == "C1_PRODUTO"
				aCols[n][xxn] := wsCod
			Endif

			If xcCampo == "C1_CLVL"
				aCols[n][xxn] := wsCLVL
			Endif
		Next

		CT1->(DbSetOrder(1))
		If !CT1->(DbSeek(xFilial("CT1")+wsConta))		
			MsgAlert("BIA135A - Conta Contabil nao cadastrada ["+wsConta+"] ou Classe Valor Digitada nao pode ser aplicada a este PRODUTO", "ATENCAO")
			AutoGrLog("BIA135A - Conta Contabil nao cadastrada ["+wsConta+"] ou Classe Valor Digitada nao pode ser aplicada a este PRODUTO")
			wsConta := SPACE(20)
		EndIf

		If SB1->B1_TIPO == "MD"    //Alterado por Adam em 02/12/02 por solicitacao do Sr. Marcelo.
			wsConta := SB1->B1_CONTA
		EndIf
	Endif
	DbSelectArea(wAlias)
Return(wsConta)
