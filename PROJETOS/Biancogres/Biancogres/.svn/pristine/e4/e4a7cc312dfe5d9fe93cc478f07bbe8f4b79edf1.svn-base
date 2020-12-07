#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT150ENV
@author Tiago Rossini Coradini
@since 21/12/2016
@version 1.0
@description Ponto de entrada que permite ou bloqueia acesso à proposta ou atualização da cotação de compras  
@description Utilizado para adicionar tecla de atalho na manutenção da cotação
@obs OS: 4533-16 - Claudia Carvalho
@obs Ticket: 833 - Projeto Demandas Compras - Item 11
@type function
/*/

User Function MT150ENV()
	
	SetKey(VK_F8, {|| U_BIAF059('C') })
	SetKey(VK_F9, {|| U_BIAF086() })
	
Return(.T.)