#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia058()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	Local xxn

	SetPrvt("WALIAS,XXN,XCCAMPO,WPC,WITEMPC,WPRCANT")
	SetPrvt("WPRCPC,WFLAG,WCUSER,WCSENHA,WCNOVSENHA,GET_SENHA")

	wAlias   := Alias()
	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "D1_PEDIDO"
			wPC     := aCols[n][xxn]
		Endif
		If xcCampo == "D1_ITEMPC"
			wItemPC := aCols[n][xxn]
		Endif
		If xcCampo == "D1_VUNIT"
			wPrcAnt := aCols[n][xxn]
		Endif
	Next

	wPrcPC   := 0

	DbSelectArea("SC7")
	DbSetOrder(1)

	If cTipo <> "C"
		If !DbSeek(xFilial("SC7")+wPC+wItemPC,.T.)
			MsgAlert("Pedido de Compra Nao Existe")
			wPrcPC   := wPrcAnt
		Else
			wPrcPC   := SC7->C7_PRECO
		EndIf
	Else
		wPrcAnt := aCols[n][6]
		wPrcPC  := aCols[n][6]
	EndIf

	wFlag := .T.

	If wPrcAnt > wPrcPC
		MsgAlert("Preco Unitario Digitado Diferente do Pedido de Compra")
		wcUser  := Upper(AllTrim(cUserName))
		wcSenha := Alltrim( GetMv("MV_SENHA") )

		While wFlag

			@ 096,042 To 323,505 Dialog woDlg Title "Autorizacao p/Divergencia NFxPC"
			@ 008,010 To 084,222

			wcNovSenha := Space(10)

			@ 023,014 Say "Digite Senha autorizada : "
			@ 023,080 Get wcNovSenha PICTURE "@!" PASSWORD Object oGet

			@ 055,020 BMPBUTTON TYPE 01 ACTION fSubmit()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 055,020 BMPBUTTON TYPE 01 ACTION Execute(fSubmit)
			@ 055,060 BMPBUTTON TYPE 02 ACTION fAborta()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 055,060 BMPBUTTON TYPE 02 ACTION Execute(fAborta)

			ACTIVATE DIALOG woDlg CENTERED

		EndDo

	EndIf

	// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(wPrcAnt)
Return(wPrcAnt)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fSubmit
Static Function fSubmit()
	If Alltrim(wcSenha) == ALLTRIM(wcNovSenha)
		wFlag := .F.
		Close(woDlg)
	Else
		Get_Senha := IIf(!Empty(wcNovSenha),Space(10),Space(10))
		dlgRefresh(woDlg)
		ObjectMethod(oGet,"SetFocus(wcNovSenha)")
		ObjectMethod(oGet,"Refresh()")
		Help(1,"","Y_BIA045")
	Endif
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAborta
Static Function fAborta()
	wFlag := .T.
	Close(woDlg)
Return
