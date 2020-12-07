#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH" 

/*/{Protheus.doc} FISA095MOD
PE DO MODEL DA ROTINA FISA095
@type function
@author WLYSSES CERQUEIRA (FACILE)
@since 12/04/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function FISA095MOD()

	Local xRet := .T.	

	If PARAMIXB <> NIL
		
		If PARAMIXB[2] == "BUTTONBAR"
						
			xRet := {{"Imprimir comprovante", "SALVAR", {|| U_BAF016()}}}		

		EndIf

	Endif

Return(xRet)