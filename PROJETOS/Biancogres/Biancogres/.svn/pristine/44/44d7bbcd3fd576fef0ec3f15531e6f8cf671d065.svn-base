#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF122
@author Tiago RossinPos CoradinPos
@since 19/09/2018
@version 1.0
@description Rotina para calculo dos digitos verificadores da linha digitavel do banco Banestes 
@obs Ticket: 7873
@type Function
/*/

User Function BIAF122(cNossNum, cConta, cTipCob, cBanco)
Local cChave := ""
Local nPos := 0
Local cPesoD1 := "21212121212121212121212"
Local cPesoD2 := "765432765432765432765432"
Local cDig1 := ""
Local cDig2 := ""
Local nSoma := 0
Local nTotal := 0
Local nResto := 0
	
	// Composicao da chave ASBACE 
	cChave := SubStr(cNossNum, 1, 8) + PadL(AllTrim(cConta), 11, "0") + cTipCob + cBanco	
		
	// Calculo do primeiro digito verificador
	cDig1 := Modulo10(cChave, 2, 1)
	
	cChave += cDig1
	
	
	// Calculo do segundo digito verificador	
	nSoma := 0
		
	For nPos := 1 To Len(cChave)
		
		nSoma += Val(Substr(cChave, nPos, 1)) * Val(Substr(cPesoD2, nPos, 1))
		
	Next
	
	nResto := 1
	
	While nResto == 1	
		
		nResto := Mod(nSoma, 11)
		
		If nResto == 0
		
			cDig2 := "0"
			
		ElseIf nResto == 1
			
			cDig1 := Alltrim(Str(Val(cDig1) + 1))
			
			If cDig1 == "10"
				
				cDig1 == "0"
				
			EndIf
			
			cChave := Substr(cChave, 1, 23)
			cChave += cDig1
			
			nSoma := 0
			
			For nPos := 1 To Len(cChave)
				
				nSoma += Val(Substr(cChave, nPos, 1)) * Val(Substr(cPesoD2, nPos, 1))
				
			Next
			
		ElseIf nResto > 1
			
			cDig2 := Alltrim(Str(11 - nResto))
			
		EndIf
		
	EndDo
	
	cChave += cDig2
	
Return(cChave)