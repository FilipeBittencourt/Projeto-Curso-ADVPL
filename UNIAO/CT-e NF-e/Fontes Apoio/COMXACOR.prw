#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} COMXACOR
PE APÓS A GRAVAÇÃO DO FORNECEDOR NO BANCO DE DADOS.
PARAMETROS -> INCLUIR = 3 ALTERAR = 4 EXCLUIR = 5
@type function
@author WLYSSES CERQUEIRA (FACILE)
@since 13/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function _COMXACOR()

	Local aCores := PARAMIXB[1]
	
	aIns(aCores, 1)
	
	aCores[1] := {'DS_YVLDXML == "S"', 'BR_BRANCO'}

Return(aCores)