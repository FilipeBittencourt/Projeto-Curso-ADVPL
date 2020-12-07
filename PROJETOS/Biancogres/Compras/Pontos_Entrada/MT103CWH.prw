#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT103CWH
@author Tiago Rossini Coradini
@since 28/03/2018
@version 1.0
@description Ponto de entrada que permite alterar o WHEN dos campos da Pré-Nota e NFE
@description Utilizado para tratar BUG de refresh da aba de duplicatas na condicao de pagamento para conhecimento de frete 
@obs OS: 2070-17
@type Function
/*/

User Function MT103CWH()
Local lRet := .T.
	U_BIAF100()
	
	//CONEXÃO NFE
	lRet := U_GTPE006()

Return(lRet)