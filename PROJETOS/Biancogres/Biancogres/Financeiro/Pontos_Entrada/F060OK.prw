#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F060OK
@author Tiago Rossini Coradini
@since 13/02/2017
@version 1.0
@description Ponto de entrada na confirmação da transferencia de borderos do contas a receber 
@obs OS: 4521-16 - Clebes Jose
@type function
/*/

Static __cNossNum

User Function F060OK()
Local aArea := GetArea()

	__cNossNum := ""
	
	If !Empty(SE1->E1_NUMBCO) .And. cSituacao == "0"
		
		__cNossNum := SE1->E1_NUMBCO

	EndIf
	
	RestArea(aArea)
	
Return(.T.)


/*/{Protheus.doc} F060OK
@author Tiago Rossini Coradini
@since 13/02/2017
@version 1.0
@description Ponto de entrada executado ao final da rotina de transferência de contas a receber, após gravação de dados e da contabilização. 
@obs OS: 4521-16 - Clebes Jose
@type function
/*/

User Function FA60TRAN()
Local aArea := GetArea()
	
	If !Empty(__cNossNum) .And. SE1->E1_YNUMBCO <> __cNossNum
	
		RecLock("SE1", .F.)
			
			SE1->E1_YNUMBCO := __cNossNum
			
		SE1->(MsUnlock())
		
		__cNossNum := ""
	
	EndIf
	
	RestArea(aArea)
	
Return()