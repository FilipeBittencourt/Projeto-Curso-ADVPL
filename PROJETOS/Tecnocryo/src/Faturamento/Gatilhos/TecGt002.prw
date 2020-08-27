#Include "Totvs.ch"
#Include "Protheus.ch"

User Function TecGt002()
Local cLj  := M->A1_LOJA
Local nCgc := Len(AllTrim(M->A1_CGC))

	If Inclui
		If nCgc > 11 	
			cLj := SubStr(M->A1_CGC,9,4)
		Else
			cLj := SubStr(M->A1_CGC,10,2) + "00"
		EndIf
	EndIf
Return(cLj)