#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF171
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para tratamento de cotacoes de moedas 
@type Function
/*/

User Function BIAF171()
Local oObj := Nil

	RpcSetType(3)
	RpcSetEnv("01", "01")

		oObj := TAFCotacaoMoeda():New()
		
		oObj:Insert()
		
	RpcClearEnv()
				
Return()