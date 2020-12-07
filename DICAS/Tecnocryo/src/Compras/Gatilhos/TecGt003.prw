#Include "Totvs.ch"
#Include "Protheus.ch"

User Function TecGt003()
Local cCod := M->A2_COD
Local nCgc := Len(AllTrim(M->A2_CGC))

	If Inclui 
		If nCgc > 11 
			cCod := "0" + SubStr(M->A2_CGC,1,8)
		Else
			cCod := SubStr(M->A2_CGC,1,9)
		EndIf
	EndIf
Return(cCod)