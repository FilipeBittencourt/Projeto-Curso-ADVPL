#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	/*/
	北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
	北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
	北矲un噭o    � BIA135     � Autor � Cesar Magnago         � Data � 25/09/00 潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
	北矰escri噭o � Verifica se a Conta do SB1 esta correta em funcao do C.Custo 潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
	北� Uso      � Interpretador xBase                                          潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
	北矨lteracoes� Incluida a validacao para que todos os tipos MD utilizem a   潮�
	北�          � a conta de materiais (B1_CONTA). 02/12/02                    潮�
	北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
	北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
	哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
	/*/


User Function bia135()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

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
			If Subs(wsCLVL,1,1) $ "1_2_4_5_6_8"
				If !Empty(SB1->B1_YCTRADM)
					wsConta := SB1->B1_YCTRADM
				Else
					cMsg := ""
					cMsg += "AVISO!!"+chr(13)
					cMsg += "BIA135 - Este produto exige a Conta de Resultado Administrativa que esta "+chr(13)
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
						cMsg += "BIA135 - Este produto exige a Conta de Resultado Industrial que est� "+chr(13)
						cMsg += "vazia no cadastro do produto! Favor verificar antes de prosseguir."
						alert(cMsg)
						AutoGrLog(cMsg)
						wsCLVL := Space(10)
					Endif
				EndIf
			Elseif !Subs(wsCLVL,1,1) $ "1_2_3_4_5_6_8"
				Help(" ",1,"CONTNF02 - BIA135")
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
			MsgAlert("BIA135 - Conta Contabil nao cadastrada ["+wsConta+"] ou Classe de Valor Digitada nao pode ser aplicada a este PRODUTO", "ATENCAO")
			AutoGrLog("BIA135 - Conta Contabil nao cadastrada ["+wsConta+"] ou Classe de Valor Digitada nao pode ser aplicada a este PRODUTO")
			wsConta := SPACE(20)
		EndIf

		If SB1->B1_TIPO == "MD"    //Alterado por Adam em 02/12/02 por solicitacao do Sr. Marcelo.
			wsConta := SB1->B1_CONTA
		EndIf
	Endif
	DbSelectArea(wAlias)
Return(wsConta)
