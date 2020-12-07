#include "rwmake.ch"

/*/{Protheus.doc} FA050FIN
@description Gravar percentual no SE5 para RA  
@author Nilton Cesar Fernando Rocha
@since 15.04.03
@version revisado por Fernando Rocha em 27/10/2017 - versao 12 - retirado a parte referente aos campos E5_YPLIN1/E5_YPLIN2/E2_YPLIN1/E2_YPLIN2
@type function
/*/
User Function FA050FIN()
Local aArea := GetArea()

IF cEmpAnt <> '02'
	DbSelectArea("ZZR")
	DbSetOrder(1)
	IF !DbSeek(xFilial("ZZR")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_CLVL+SE2->E2_CCD+SE2->E2_YCONTR)
		RecLock("ZZR",.T.)
		ZZR->ZZR_FILIAL := xFilial("ZZR")
		ZZR->ZZR_PREF   := SE2->E2_PREFIXO
		ZZR->ZZR_NUM    := SE2->E2_NUM
		ZZR->ZZR_PARC   := SE2->E2_PARCELA
		ZZR->ZZR_TIPO   := SE2->E2_TIPO
		ZZR->ZZR_FORNEC := SE2->E2_FORNECE
		ZZR->ZZR_LOJA   := SE2->E2_LOJA
		ZZR->ZZR_CC     := SE2->E2_CCD
		ZZR->ZZR_CLVL   := SE2->E2_CLVL
		ZZR->ZZR_CONTR  := SE2->E2_YCONTR
		ZZR->ZZR_RATEIO := 100
		MsUnLock("ZZR")
	ENDIF
ENDIF

RestArea(aArea)
Return
