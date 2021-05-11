#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF150
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para geracao automatica de Politica de Credito para Clientes da Carteira Ativa
@type class
/*/

User Function BIAF150()
Local cSQL := ""
Local cQry := ""

	RpcSetType(3)
	RpcSetEnv("01", "01")
		
	cQry := GetNextAlias()
	
	cSQL := " SELECT * "
	cSQL += " FROM VW_ROCKET_CARTEIRAATIVA "
	cSQL += " ORDER BY TIPOLC, CLIENTE, GRUPOCLI "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		U_BIAF146(dDataBase, (cQry)->CLIENTE, (cQry)->LOJA, (cQry)->GRUPOCLI, (cQry)->CNPJ, (cQry)->LC, If ((cQry)->TPSEG == "Ë", (cQry)->LC, 0), "4", .F.)
	
		(cQry)->(DbSkip())
								
	EndDo()

	(cQry)->(DbCloseArea())		
		
	RpcClearEnv()
		
Return()
