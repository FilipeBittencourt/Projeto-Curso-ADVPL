#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA656
@description Valid C7_PRODUTO
@author Luana Marin Ribeiro
@since 06/12/2018
@version undefined
@type function
/*/

User Function BIA656()

	Local lRet := .T.
	Local auxPos := 0
	Local auxProd := ""
	Local auxNumSc := ""
	Local auxLocal := ""
	
	Do Case
		// MATA121: pedido de compra
		Case Upper(AllTrim(FunName())) == "MATA121"
			auxPos := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRODUTO"})
			auxProd := aCols[n,auxPos]
			
			auxPos := aScan(aHeader,{|x| AllTrim(x[2])=="C7_NUMSC"})
			auxNumSc := aCols[n,auxPos]
			
			auxPos := aScan(aHeader,{|x| AllTrim(x[2])=="C7_LOCAL"})
			auxLocal := aCols[n,auxPos]			
			
			If !Empty(auxNumSc)
				SC1->(DbSetOrder(2))
				If SC1->(DbSeek(XFilial("SC1") + auxProd + auxNumSc))
					auxPos := aScan(aHeader,{|x| AllTrim(x[2])=="C7_LOCAL"})
					aCols[n,auxPos] := SC1->C1_LOCAL
				Else
					auxPos := aScan(aHeader,{|x| AllTrim(x[2])=="C7_LOCAL"})
					aCols[n,auxPos] := auxLocal
				EndIf
			EndIf
	EndCase

Return lRet