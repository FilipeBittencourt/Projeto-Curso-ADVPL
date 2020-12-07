#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120GET
@author Tiago Rossini Coradini
@since 21/12/2016
@version 1.0
@description Ponto de entrada para inserir/alterar dados do item da pedido de compras,
@description Utilizado para adicionar tecla de atalho na manutenção do pedido   
@obs OS: 4533-16 - Claudia Carvalho
@type function
/*/

User Function MT120GET()
	
	SetKey(VK_F8, {|| U_BIAF059('P') })	
	
Return()