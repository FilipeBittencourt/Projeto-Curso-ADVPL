#Include "Totvs.ch"
#Include "Protheus.ch"

User Function TecGt001()
Local cCod := M->A1_COD
Local nCgc := Len(AllTrim(M->A1_CGC))

	If Inclui 
		If nCgc > 11 
			cCod := "0" + SubStr(M->A1_CGC,1,8)
		Else
			cCod := SubStr(M->A1_CGC,1,9)
		EndIf
	EndIf
Return(cCod)