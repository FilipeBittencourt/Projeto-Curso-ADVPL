#include "protheus.ch"


/*/{Protheus.doc} MT500ANT
PE executado antes da eliminação de resíduo por registro do SC6
@author Filipe - Facile
@programa inicial em 09/10/2020
@Fonte/Link://https://tdn.totvs.com/display/public/PROT/MT500ANT
@return boolean
*/

User Function MT500ANT()


	Local lExecuta := .T.
    Local lBlind   := IsBlind()   
    Local nOpc     := Paramixb[1]

    lExecuta := MT500001(lBlind, nOpc) 

Return lExecuta


Static Function MT500001(lBlind)

	Local lExecuta := .T.	
    Local lMOTOR   :=  SuperGetMv("MV_YMOTOR1",.F.,.F.)  //Parametro MOTOR ON/OFF inserir, edicao, exclusao  do pedido gerados pelo motor de abastecimento via WS 
    
	//INICIO - Condição para pedidos feitos pelo motor de abastecimento MOTOR em TELA    
    If lBlind .AND. lMOTOR 
		If !Empty(SC5->C5_YIDCITE)
            FwAlertWarning('Não é possivel modificar pedido de venda criado pelo motor de abastecimento.','ATENÇÃO - PE MT500ANT')
            return lExecuta := .F.
        Endif
    Endif
    //FIM  -  Condição para pedidos feitos pelo motor de abastecimento MOTOR em TELA

Return lExecuta
