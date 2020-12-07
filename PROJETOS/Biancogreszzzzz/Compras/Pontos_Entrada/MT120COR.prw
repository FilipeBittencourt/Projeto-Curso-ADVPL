#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120COR
@author Tiago Rossini Coradini
@since 20/07/2018
@version 1.0
@description Ponto de entrada para adicionar cores no browse do pedido de compra
@type function
/*/

// Indices das colunas do array de cores
#DEFINE _Pos 1
#DEFINE _Formula 1
#DEFINE _Cor 2

User Function MT120COR() 
Local aRet := {}
Local nCount := 0 

	aAdd(aRet, {"!Empty(C7_RESIDUO) .And. !Empty(C7_YRESAUT)", "BR_VIOLETA"})
	
	For nCount := 1 To Len(ParamIxb[_Pos])
		
		aAdd(aRet, {ParamIxb[_Pos][nCount, _Formula], ParamIxb[_Pos][nCount, _Cor]})
		
	Next
	
Return(aRet)