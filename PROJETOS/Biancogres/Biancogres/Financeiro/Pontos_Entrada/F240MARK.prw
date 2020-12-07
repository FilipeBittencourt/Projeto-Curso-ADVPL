#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F240MARK
@author Tiago Rossini Coradini
@since 04/01/2016
@version 1.0
@description Ponto de entrada para alterar a posição dos campos do bordero de pagamentos. 
@obs OS: 4576-16 - Ranisses Corona - Bloqueio de Empresa LM, liberação somente via ValOper.
@type function
/*/

User Function F240MARK()
Local aArea := GetArea()
Local aFields := ParamIxb 
Local aFRet := {}
Local nCount := 0

	//If MV_PAR05 == 1
	
		For nCount := 1 To Len(aFields)		

			aAdd(aFRet, {aFields[nCount, 1], aFields[nCount, 2], aFields[nCount, 3], aFields[nCount, 4]})		
		
			If "E2_PARCELA" == AllTrim(aFields[nCount, 1])								
				
				nPos := aScan(aFields, {|x| AllTrim(x[1]) == "E2_YNFGUIA"})
				
				If nPos > 0				
					
					aAdd(aFRet, {aFields[nPos, 1], aFields[nPos, 2], aFields[nPos, 3], aFields[nPos, 4]})
					
				EndIf
				
			EndIf				
			
		Next
		
	//EndIf

	RestArea(aArea)
	
Return(aFRet)