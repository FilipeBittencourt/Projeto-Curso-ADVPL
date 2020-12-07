#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F260BUT
@author Tiago Rossini Coradini
@since 16/05/2018
@version 1.0
@description Ponto de entrada para adicionar rotinas no menu da conciliacao de DDA   
@obs Ticket: 4511
@type Function
/*/

User Function F260BUT()
Local aRot := ParamIxb

	aAdd(aRot, {"Reprocessamento", 'U_BIAF109', 0, 5})
	
Return(aRot)