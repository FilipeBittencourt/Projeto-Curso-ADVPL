#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} A200RVPI
@author Marcos Alberto Soprani
@since 03/08/18
@version 1.0
@description Informa qual revisão é utilizada para o produto intermediário
@type function
/*/

User Function A200RVPI()

	Local smArea    := GetArea()
	Local smVetEst  := PARAMIXB
	Local smRevUse  := smVetEst[3]

	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + smVetEst[3] ) )
	smRevUse := SB1->B1_REVATU 

	RestArea( smArea )

Return ( smRevUse )
