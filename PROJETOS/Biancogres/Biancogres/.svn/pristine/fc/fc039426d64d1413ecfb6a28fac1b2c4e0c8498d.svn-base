#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Funcao: | BIAF027																					|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 01/03/16																				|
|-----------------------------------------------------------|
| Desc.:	|	Validação de campos tipo texto com caracter  		|
| 				|	especial e acento 															|
|-----------------------------------------------------------|
| OS:			|	2709-15 - Wanisay William												|
|-----------------------------------------------------------|
*/

User Function BIAF027(cTexto)
Local lRet := .T.
Local cAux := cTexto
Local nCount := 0
Local aEsp := {}
Local cAce := "áéíóúàèìòùâêîôûãõäëïöüçñÿýÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇÑŸÝ"

	If (ValType(INCLUI) == "L" .Or. ValType(ALTERA) == "L") .And. !IsBlind()

		cTexto := AllTrim(cTexto)
		
		cAux := cTexto
		
		cTexto := FwNoAccent(cTexto)
		
		If cTexto == cAux
	
			// Adiciona caracteres sspeciais no array
			aAdd(aEsp, {"!", "Exclamacao"})
			aAdd(aEsp, {"@", "Arroba"})
			aAdd(aEsp, {"#", "Sustenido"})
			// aAdd(aEsp, {"$", "Cifrao"})
			// aAdd(aEsp, {"%", "Porcentagem"})
			// aAdd(aEsp, {"*", "Asterisco"})
			// aAdd(aEsp, {"/", "Barra"})
			// aAdd(aEsp, {"\", "Barra Invertida"})
			// aAdd(aEsp, {"(", "Parentese"})
			// aAdd(aEsp, {")", "Parentese"})
			// aAdd(aEsp, {"+", "Mais"})
			// aAdd(aEsp, {"=", "Igual"})
			// aAdd(aEsp, {"]", "Chave"})
			// aAdd(aEsp, {"[", "Chave"})
			// aAdd(aEsp, {"{", "Colchete"})
			// aAdd(aEsp, {"}", "Colchete"})
			// aAdd(aEsp, {";", "Ponto e Virgula"})
			// aAdd(aEsp, {":", "Dois Pontos"})
			// aAdd(aEsp, {">", "Maior"})
			// aAdd(aEsp, {"<", "Menor"})
			// aAdd(aEsp, {"?", "Interrogacao"})
			// aAdd(aEsp, {"_", "Underline"})
			// aAdd(aEsp, {",", "Virgula"})
			aAdd(aEsp, {"'", "Aspas Simples"})
			aAdd(aEsp, {'"', "Aspas Dupla"})
			aAdd(aEsp, {"´", "Acento Agudo"})
			aAdd(aEsp, {"^", "Acento Circunflexo"})
			aAdd(aEsp, {"`", "Crase"})
			aAdd(aEsp, {"¨", "Trema"})
			aAdd(aEsp, {"&", "E Comercial"})
			aAdd(aEsp, {"~", "Til"})
			aAdd(aEsp, {"|", "Barra Vertical"})
			
			For nCount := 1 To Len(cTexto)
				
				If (nPos := aScan(aEsp, {|x| x[1] == SubStr(cTexto, nCount, 1)}) ) > 0
				
					lRet := .F.
					
					MsgAlert("Atenção, o caracter especial: "+ aEsp[nPos, 2] + " ' " + aEsp[nPos, 1] + " ' não é permitido, favor ajustar o texto.")
					AutoGrLog("Atenção, o caracter especial: "+ aEsp[nPos, 2] + " ' " + aEsp[nPos, 1] + " ' não é permitido, favor ajustar o texto.")

				EndIf
						
			Next
			
		Else		
	
			For nCount := 1 To Len(cAux)
				
				If (nPos := At(SubStr(cAux, nCount, 1), cAce)) > 0
					
					lRet := .F.
				
					MsgAlert("Atenção, o caracter com acento: ' "+ SubStr(cAce, nPos, 1) +" ' não é permitido, favor ajustar o texto.")
					AutoGrLog("Atenção, o caracter com acento: ' "+ SubStr(cAce, nPos, 1) +" ' não é permitido, favor ajustar o texto.")

				EndIf
						
			Next
	
		EndIf	
		
		If !lRet
			
			ConOut("BLOQUEIO DE CARACTER ESPECIAL - USER FUNCTION: BIAF027")
			AutoGrLog("BLOQUEIO DE CARACTER ESPECIAL - USER FUNCTION: BIAF027")

		EndIf
		
	EndIf
	
Return(lRet)