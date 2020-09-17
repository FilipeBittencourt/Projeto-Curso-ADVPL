#include "protheus.ch"


/*/{Protheus.doc} MT120ALT
PE que Valida o registro do PC e retorna andamento do processo. Apos o usuario clicar em alterar o registro posicionado
@author Filipe - Facile
@programa inicial em 14/09/2020
@Fonte/Link://https://tdn.totvs.com/display/public/PROT/MT120ALT+-+Valida+o+registro+do+PC+e+retorna+andamento+do+processo
@return boolean
*/

User Function MT120ALT()

	Local lExecuta := .T.	
    Local lCitel   :=  SuperGetMv("MV_YCITEL1",.F.,.F.)  //Parametro CITEL ON/OFF inserir, edicao, exclusao  do pedido de compra gerados pelo motor de abastecimento via WS 
    
	//INICIO - Condição para pedidos feitos pelo motor de abastecimento CITEL em TELA    
    If !IsBlind() .AND. lCitel .AND. Paramixb[1] == 4
		If !Empty(SC7->C7_YIDCITE)
            FwAlertWarning('Não é possivel modificar pedido de compra criado pelo motor de abastecimento CITEL.','ATENÇÃO - MT120ALT')
            return lExecuta := .F.
        Endif
    Endif
    //FIM  -  Condição para pedidos feitos pelo motor de abastecimento CITEL em TELA

return lExecuta
