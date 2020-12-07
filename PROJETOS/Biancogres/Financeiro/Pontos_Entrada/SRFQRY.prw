#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} SRFQRY
@author Wlysses Cerqueira (Facile)
@since 28/01/2020
@version 1.0
@description Chamado na montagem da query - FINA373
@type class
/*/

Static cUltDarf := ""

User Function SRFQRY()

	Local cQuery := PARAMIXB[1]
    Local aAreaFI9 := FI9->(GetArea())

    DBSelectArea("FI9")
    FI9->(DBSetOrder(0))

    FI9->(DBGoBottom())

    cUltDarf := FI9->FI9_IDDARF

    RestArea(aAreaFI9)

Return(cQuery)

User Function XXSRFQRY()
Return(cUltDarf)