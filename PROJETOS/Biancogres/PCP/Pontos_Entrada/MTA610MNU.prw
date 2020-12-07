#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} MTA610MNU
@author Gabriel Rossi Mafioletti
@since 19/06/2019
@version 1.0
@description Ponto de Entrada para inserir itens nas ações relacionadas do cadastro de recurso
@type function
/*/

User Function MTA610MNU()

	aAdd(aRotina,{"Integra MES","U_BIAFG094", 0 , 6, 0, nil})

Return