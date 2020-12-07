#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF072
@author Tiago Rossini Coradini
@since 20/08/2018
@version 1.1
@description Ponto de entrada para adicionar rotinas na solicitação de compra 
@obs Ticket: 7663
@type function
/*/

User Function MTA110MNU()

	aAdd(aRotina, {"Observação", "U_OBS_SOLI()" , 0 , 7, 0, nil})
	aAdd(aRotina, {"Produto Importado", "U_BIAF072()" , 0 , 7, 0, nil})
	aAdd(aRotina, {"Receb. Almoxarifado", "U_BIAV005()" , 0 , 7, 0, nil})
	aAdd(aRotina, {"Coleta Fornecedor", "U_BIAV006()" , 0 , 7, 0, nil})

Return()