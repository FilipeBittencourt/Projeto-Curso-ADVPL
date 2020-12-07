#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF150
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para geracao automatica de Politica de Credito para Clientes da Carteira Ativa
@type class
/*/

User Function BIAF150(lSchedule)
Local cSQL := ""
Local cQry := ""

	Default lSchedule := .T.

	If lSchedule

		RpcSetType(3)
		RpcSetEnv("01", "01")
		
	EndIf

	cQry := GetNextAlias()
	
	// Ranisses ira mandar o SQL
	/*cSQL := " SELECT ZM0_CODIGO, ZM0_DATINI, ZM0_DATINI, ZM0_CLIENT, ZM0_LOJA, ZM0_GRUPO, ZM0_CNPJ, ZM0_VLSOL, ZM0_VLOBRA, ZM0_ORIGEM "
	cSQL += " FROM "+ RetSQLName("ZM0")
	cSQL += " WHERE ZM0_FILIAL = "+ ValToSQL(xFilial("ZM0"))
	cSQL += " AND ZM0_STATUS IN ('1', '2') "
	cSQL += " AND D_E_L_E_T_ = '' "*/

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		U_BIAF146(dDataBase, (cQry)->ZM0_CLIENT, (cQry)->ZM0_LOJA, (cQry)->ZM0_GRUPO, (cQry)->ZM0_CNPJ, (cQry)->ZM0_VLSOL, (cQry)->ZM0_VLOBRA, (cQry)->ZM0_ORIGEM, .F.)
	
		(cQry)->(DbSkip())
								
	EndDo()

	(cQry)->(DbCloseArea())
		
	If lSchedule	
		
		RpcClearEnv()
		
	EndIf
		
Return()