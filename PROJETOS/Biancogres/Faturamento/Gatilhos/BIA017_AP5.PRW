#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia017()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local xxn

	SetPrvt("WALIAS,WUSUARIO,LFUNCAO,WDESCONT,XXN,XCCAMPO")
	SetPrvt("WVALDESC,WPVENDA,ACOLS,")

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ BIA017     ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 12/05/99 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Determina se o usuario podera alterar os campos de Limite SZ1³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador x Base                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	wAlias   := Alias()
	wUsuario := cUserName
	lFuncao  := ""
	wDescont := 0

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C6_DESCONT"
			wDescont := aCols[n][xxn]
		Endif
		If xcCampo == "C6_VALDESC"
			wValdesc := aCols[n][xxn]
		Endif
		If xcCampo == "C6_PRCVEN"
			wPVenda  := aCols[n][xxn]
		Endif
	Next

	Do Case
		Case Alltrim(wUsuario) == "FERNANDA"
		lFuncao := "F"
		Case Alltrim(wUsuario) == "LEIA"
		lFuncao := "F"
		Case Alltrim(wUsuario) == "ANA"
		lFuncao := "F"
		Case Alltrim(wUsuario) == "CLAUDIA"
		lFuncao := "F"
		Case Alltrim(wUsuario) == "CINTIA"
		lFuncao := "F"
	EndCase
	If lFuncao == "F" .and. Inclui
		msgBox("Atencao. Usuario nao autorizado para alterar este campo","Usuario nao autorizado","ALERT")
		wDescont := 0
		For xxn := 1 to Len(aHeader)
			xcCampo := Trim(aHeader[xxn][2])
			If xcCampo == "C6_DESCONT"
				aCols[n][xxn] := 0
			Endif
			If xcCampo == "C6_VALDESC"
				aCols[n][xxn] := 0
			Endif
			If xcCampo == "C6_PRCVEN"
				aCols[n][xxn] := wPVenda
			Endif
		Next
	EndIf

	dbSelectArea(wAlias)

	// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(wDescont)
Return(wDescont)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
