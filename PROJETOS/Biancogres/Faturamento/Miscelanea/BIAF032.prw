#INCLUDE "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Funcao: | BIAF032																					|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 25/04/16																				|
|-----------------------------------------------------------|
| Desc.:	|	Retorna Series por usuario, utilizado nos pontos|
| 				|	de entreda M460QRY e M460FIL										|
|-----------------------------------------------------------|
| OS:			|	4329-15 - Dalvina Maria													|
|-----------------------------------------------------------|
*/

User Function BIAF032()
Local cRet := ""
Local aArea := GetArea()

	// Serie 1
	If U_ValOper("025", .F.)
		cRet += "1/"
	EndIf
	
	// Serie 2
	If U_ValOper("026", .F.)
		cRet += "2/"
	EndIf
	
	// Serie 3
	If U_ValOper("027", .F.)
		cRet += "3/"
	EndIf
	
	// Serie 4
	If U_ValOper("028", .F.)
		cRet += "4/"
	EndIf
	
	// Serie 5 - MDF - Manifesto Eletrônico de Documentos
	If U_ValOper("030", .F.)
		cRet += "5/"
	EndIf	
		
	RestArea(aArea)
	
Return(cRet)