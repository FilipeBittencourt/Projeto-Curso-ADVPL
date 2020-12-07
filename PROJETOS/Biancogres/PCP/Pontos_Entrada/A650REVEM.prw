#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} A650REVEM
@author Marcos Alberto Soprani
@since 03/08/18
@version 1.0
@description Informa qual revisão é utilizada para o produto intermediário
@type function
/*/

User Function A650REVEM()

	Local smArea    := GetArea()
	Local smRevUse  := ParamIxb[1]

	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + SB1->B1_COD ) )
	smRevUse := {SB1->B1_REVATU} 

	RestArea( smArea )

Return ( smRevUse )
