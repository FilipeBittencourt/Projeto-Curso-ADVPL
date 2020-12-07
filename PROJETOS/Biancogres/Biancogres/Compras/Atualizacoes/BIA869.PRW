#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA869
@author Ranisses A. Corona
@since 21/11/2016
@version 1.0
@description Utilizado para retornar o nome do Fornecedor, no campo virtual F1_YNOMEF 
@type function
/*/

User Function BIA869()
Local cNome := ""

SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

cNome := SA2->A2_NOME 

Return(cNome)