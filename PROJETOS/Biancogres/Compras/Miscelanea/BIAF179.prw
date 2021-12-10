#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF179
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Funcao para tratamento de Tipos de Negociacoes de Taxa de Cambio
@obs Projeto: A-69 - Taxa de Câmbio
@type Function
/*/

User Function BIAF179(cCodigo, nMoeda)
Local nRet := 0
Local oObj := TTipoNegociacaoTaxaCambio():New() 

	oObj:cCodigo := cCodigo
	oObj:nMoeda := nMoeda
	
	oObj:Process()
	
	nRet := oObj::nCotacao
			
Return(nRet)