#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA280QRY
@author Tiago Rossini Coradini
@since 13/03/2017
@version 2.0
@description Adiciona filtro SQL na montagem da fatura a receber 
@obs OS: 4031-15 - Clebes Jose
@obs OS: 0089-17 - Clebes Jose
@type function
/*/
 

User Function FA280QRY() 
Local cRet := ""
	
	cPar01  := MV_PAR01
	cPar02  := MV_PAR02
	cPar03  := MV_PAR03
	cPar04  := MV_PAR04
	cPar05  := MV_PAR05
	cPar06  := MV_PAR06
	cPar07  := MV_PAR07
	cPar08  := MV_PAR08
  
	cRet := U_BIAF066()

	MV_PAR01 := cPar01
	MV_PAR02 := cPar02
	MV_PAR03 := cPar03
	MV_PAR04 := cPar04
	MV_PAR05 := cPar05
	MV_PAR06 := cPar06
	MV_PAR07 := cPar07
	MV_PAR08 := cPar08

Return(cRet)