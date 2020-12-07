#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Funcao: 	| BIA585										|
| Autor:	| Luana Marin Ribeiro							|
| Data:		| 11/07/16										|
|-----------------------------------------------------------|
| Desc.:	|	ValidaÁ„o de campos tipo texto com caracter |
| 			|	especial e acento 							|
|-----------------------------------------------------------|
| OS:		|	2130-16										|
|-----------------------------------------------------------|
*/

User Function BIA585(cTexto, Origem) //Origem - para poder utilizar essa funÁ„o para v·rias validaÁıes diferentes.
Local lRet := .T.
Local cAux := cTexto
Local nCount := 0
Local aEsp := {}
Local cAce := "·ÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ı‰ÎÔˆ¸ÁÒˇ˝¡…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’ƒÀœ÷‹«—ü›"

	If Origem == "FIN_HIST"
		If ValType(INCLUI) == "L" .Or. ValType(ALTERA) == "L"
	
			cTexto := AllTrim(cTexto)
			
			cAux := cTexto
			
			cTexto := FwNoAccent(cTexto)
			
			If cTexto == cAux
				//* # & $ ì î ; : < > \ / 
				//ÿ ß
				//(  ) @ { } [ ]
				
				// Adiciona caracteres sspeciais no array
				// aAdd(aEsp, {"!", "Exclamacao"})
				
				aAdd(aEsp, {"ÿ", "Simbolo"})
				aAdd(aEsp, {"ß", "Simbolo"})
				aAdd(aEsp, {"@", "Arroba"})
				aAdd(aEsp, {"#", "Sustenido"})
				aAdd(aEsp, {"$", "Cifrao"})
				// aAdd(aEsp, {"%", "Porcentagem"})
				aAdd(aEsp, {"*", "Asterisco"})
				//aAdd(aEsp, {"/", "Barra"})
				aAdd(aEsp, {"\", "Barra Invertida"})
				aAdd(aEsp, {"(", "Parentese"})
				aAdd(aEsp, {")", "Parentese"})
				// aAdd(aEsp, {"+", "Mais"})
				// aAdd(aEsp, {"=", "Igual"})
				aAdd(aEsp, {"]", "Chave"})
				aAdd(aEsp, {"[", "Chave"})
				aAdd(aEsp, {"{", "Colchete"})
				aAdd(aEsp, {"}", "Colchete"})
				aAdd(aEsp, {";", "Ponto e Virgula"})
				
				If !Alltrim(FunName()) $ "EICPO400"
					

				Endif
				
				
				aAdd(aEsp, {">", "Maior"})
				aAdd(aEsp, {"<", "Menor"})
				// aAdd(aEsp, {"?", "Interrogacao"})
				// aAdd(aEsp, {"_", "Underline"})
				// aAdd(aEsp, {",", "Virgula"})
				//aAdd(aEsp, {"'", "Aspas Simples"})
				aAdd(aEsp, {'"', "Aspas Dupla"})
				//aAdd(aEsp, {"¥", "Acento Agudo"})
				//aAdd(aEsp, {"^", "Acento Circunflexo"})
				//aAdd(aEsp, {"`", "Crase"})
				//aAdd(aEsp, {"®", "Trema"})
				aAdd(aEsp, {"&", "E Comercial"})
				//aAdd(aEsp, {"~", "Til"})
				//aAdd(aEsp, {"|", "Barra Vertical"})
				
				For nCount := 1 To Len(cTexto)
					
					If (nPos := aScan(aEsp, {|x| x[1] == SubStr(cTexto, nCount, 1)}) ) > 0
					
						lRet := .F.
						
						MsgAlert("AtenÁ„o, o caracter especial: "+ aEsp[nPos, 2] + " ' " + aEsp[nPos, 1] + " ' n„o È permitido, favor ajustar o texto.")
					
					EndIf
							
				Next
				
			Else		
		
				For nCount := 1 To Len(cAux)
					
					If (nPos := At(SubStr(cAux, nCount, 1), cAce)) > 0
						
						lRet := .F.
					
						MsgAlert("AtenÁ„o, o caracter com acento: ' "+ SubStr(cAce, nPos, 1) +" ' n„o È permitido, favor ajustar o texto.")
					
					EndIf
							
				Next
		
			EndIf	
			
			If !lRet
				ConOut("BLOQUEIO DE CARACTER ESPECIAL - USER FUNCTION: BIA585")
			EndIf
			
		EndIf
	EndIf
	
Return(lRet)