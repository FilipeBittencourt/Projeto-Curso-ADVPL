#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH" 

/*/{Protheus.doc} CUSTOMERVENDOR
PE APÓS A GRAVAÇÃO DO FORNECEDOR NO BANCO DE DADOS.
PARAMETROS -> INCLUIR = 3 ALTERAR = 4 EXCLUIR = 5
O PONTO DE ENTRADA MT20FOPOS NAO FUNCIONA MAIS COM MVC.
@type function
@author WLYSSES CERQUEIRA (FACILE)
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function CUSTOMERVENDOR()

	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()

	If PARAMIXB <> NIL
		
		If PARAMIXB[2] == "MODELCOMMITTTS"

			If oModel:GetOperation() == MODEL_OPERATION_DELETE

				U_VIX256E(oModel)
				
			EndIf

		EndIf

	Endif

Return(lRet)