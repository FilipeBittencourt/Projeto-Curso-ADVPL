#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} MA650BUT
@author Gabriel Rossi Mafioletti
@since 21/08/2017
@version 1.0
@description Ponto de Entrada para Inserir Itens no Menu da Rotina Ordens de Produção
@type function
/*/


User Function MA650BUT()

	aAdd(aRotina,{'Recálculo OP','U_BIAFG019()',0,6 })
	aAdd(aRotina,{'Trocar Linha','U_BIAFG080()',0,7 })

Return aRotina