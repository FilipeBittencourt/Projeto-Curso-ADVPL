#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GFEA1185
OCORRE NO FINAL DA GRAVACAO DAS TABELAS GXG e GXH DO FRETE EMBARCADOR (IMPORATACAO DO CTE).
@type function
@author WLYSSES CERQUEIRA / FILIPE VIEIRA (FACILE)
@since 11/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function _GFEA1185()


	Local lRet := .T.
	Local oObjXml := VIXA258():New()
	
	lRet := oObjXml:ValidCte()
	
Return(lRet)
