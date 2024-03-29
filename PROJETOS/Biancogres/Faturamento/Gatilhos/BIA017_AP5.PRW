#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia017()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	Local xxn

	SetPrvt("WALIAS,WUSUARIO,LFUNCAO,WDESCONT,XXN,XCCAMPO")
	SetPrvt("WVALDESC,WPVENDA,ACOLS,")

	/*/
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � BIA017     � Autor � MICROSIGA VITORIA     � Data � 12/05/99 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇙o � Determina se o usuario podera alterar os campos de Limite SZ1낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � Interpretador x Base                                         낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
