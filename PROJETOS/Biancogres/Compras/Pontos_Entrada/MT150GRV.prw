#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT150GRV
@author Wlysses Cerqueira (Facile)
@since 22/06/2020  
@project 24427 - PE Dentro da transacao no final da inclusão / alteracao
@version 1.0
@description 
@type function
/*/

User Function MT150GRV()

    U_fGrvPdFr(SC8->C8_FORNECE, SC8->C8_LOJA, SC8->C8_PRODUTO, SC8->C8_YPRDFOR)

Return()