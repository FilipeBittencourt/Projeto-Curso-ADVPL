#include "rwmake.ch"
#include "TOTVS.ch"

/*/{Protheus.doc} BIA571
@description Recurso para preenchimentos complementares da Contabilização TXT
@author Marcos Alberto Soprani
@since 28/06/20
@version 1.0
@type Function
/*/
User Function BIA571( msOrig, msConteud )

	Local msRetConteud := ""
	Local msAreaAtu    := GetArea()

	//                                                        Contabilização TXT
	//--------------------------------------------------------------------------
	If IsInCallStack('CTBA500')

		//                                   Lançamento Padrão para Folha Senior
		//----------------------------------------------------------------------
		If CT5->CT5_LANPAD == "200"

			//                   Origem do Recurso = 1, retornar Centro de Custo
			//------------------------------------------------------------------
			If msOrig == "1"

				CTH->( dbSetOrder(1) )
				CTH->( dbSeek( xFilial("CTH") + msConteud))

				msRetConteud := CTH->CTH_YCC

			EndIf

		EndIf

	EndIf

	RestArea( msAreaAtu )

Return ( msRetConteud )
