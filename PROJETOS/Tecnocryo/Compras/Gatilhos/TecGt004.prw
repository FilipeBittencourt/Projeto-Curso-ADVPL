#Include "Totvs.ch"
#Include "Protheus.ch"

User Function TecGt004()
Local cLj  := M->A2_LOJA
Local nCgc := Len(AllTrim(M->A2_CGC))

	If Inclui
		If nCgc > 11 	
			cLj := SubStr(M->A2_CGC,9,4)
		Else
			cLj := SubStr(M->A2_CGC,10,2) + "00"
		EndIf
	EndIf
Return(cLj)