#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF174
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Manutenção de Despesas de importação 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF174()
Private LALTFORN := .T.

		AxCadastro("SWD", "Despesas de Importação")

Return()