#INCLUDE "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Funcao: 	| BIAF031										|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas		|
| Data:		| 21/03/16										|
|-----------------------------------------------------------|
| Desc.:	| Fltro de Serie na Nota Fiscas de Saida 		|
| 			| especifico para LM							|
|-----------------------------------------------------------|
| OS:		| 4329-15 - Dalvina Maria						|
|-----------------------------------------------------------|
*/

User Function BIAF031(cNumPed)
Local lRet := .F.
Local aArea := GetArea()

	DbSelectArea("SC5")
	DbSetOrder(1)
	If SC5->(MsSeek(xFilial("SC5") + cNumPed))
		
		If AllTrim(SC5->C5_YLINHA) $ U_BIAF032()
			lRet := .T.
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return(lRet)