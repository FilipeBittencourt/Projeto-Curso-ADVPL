#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT161CPO
@author Tiago Rossini Coradini
@since 08/09/2021
@version 1.0
@description Ponto de entrada para incluir campos customizados no MATA161 
@type function
/*/

User Function MT161CPO()
Local aPropostas := PARAMIXB[1] // Array com os dados das propostas dos Fornecedores
Local aItens := PARAMIXB[2] // Array com os dados da grid "Produtos"
	
	SetKey(VK_F10, {|| U_BIAF176() })
	
Return()
