#include "rwmake.ch"
#include "topconn.ch"


/*/{Protheus.doc} MT120MAK
@description PE MT120MAK - revisado na V12 - cabecalho errado
@author Fernando Rocha
@since 02/10/2017
@version undefined
@type function
/*/

User Function MT120MAK()

	Local cOrigem		:= ParamIxb[1]
	Local aRetTitle 	:= {}
	
	If(AllTrim(cOrigem) == 'SC1')
		aRetTitle := {"C1_YSTATUS"}
	EndIf
	

Return(aRetTitle)