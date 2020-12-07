#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SPCOBREC
@author Ranisses A. Corona
@since 31/01/2017
@version 1.0
@description Grava o campo F6_COBREC de acordo com o Tipo de Imposto da Guia 
@type function
/*/

User Function SPCOBREC()
//Paramixb[1] => Tipo da GNRE
//Paramixb[2] => UF da GNRE
Local cTipoImp	:= Paramixb[1]	// Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
Local cEstado	:= Paramixb[2]	// UF da GNRE
Local cCod 		:= "" 			// Codigo a ser gravado no campo F6_COBREC

If cTipoImp == "B"
	cCod := "090"
Else 
	cCod := "999" 
EndIf

Return cCod