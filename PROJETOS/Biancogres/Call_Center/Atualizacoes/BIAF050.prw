#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF050
@author Tiago Rossini Coradini
@since 25/10/2016
@version 1.0
@description Inclusão da rotina de Histórico de Tarifas na tela de Telecobrança. 
@obs OS: 3762-16 - Clebes Jose
@type function
/*/

User Function BIAF050()
Local cEmpOri := GdFieldGet("ACG_FILORI")
Local cEmpresa := "01"

	If cEmpOri == "BI"
		cEmpresa := "01"
	ElseIf cEmpOri == "IN"
		cEmpresa := "05"
	ElseIf cEmpOri == "LM"
		cEmpresa := "07"
	ElseIf cEmpOri == "VC"
		cEmpresa := "14"		
	EndIf	
	
	U_BIAF051(cEmpresa, GdFieldGet("ACG_PREFIX"), GdFieldGet("ACG_TITULO"), GdFieldGet("ACG_PARCEL"), GdFieldGet("ACG_TIPO"))
	
Return()