#include "protheus.ch"


/*/{Protheus.doc} MT410ACE
Ponto de entrada 'MT410ACE' criado para verificar o acesso dos usu�rios nas rotinas: Excluir, Visualizar, Res�duo, Copiar e Alterar.
@author Filipe - Facile
@programa inicial em 09/10/2020
@Fonte - https://tdn.engpro.totvs.com.br/pages/releaseview.action?pageId=6784346
@return boolean
*/

User Function MT410ACE()

	Local lExecuta := .T.
    Local lBlind   := IsBlind()   
    Local nOpc     := Paramixb[1]

    lExecuta := MT410001(lBlind, nOpc) 

return lExecuta


Static Function MT410001(lBlind, nOpc)

	Local lExecuta := .T.	
    Local lMOTOR   :=  SuperGetMv("MV_YMOTOR1",.F.,.F.)  //Parametro MOTOR ON/OFF inserir, edicao, exclusao  do pedido gerados pelo motor de abastecimento via WS 
    
	//INICIO - Condi��o para pedidos feitos pelo motor de abastecimento MOTOR em TELA    
    If !lBlind .AND. lMOTOR .AND. nOpc == 4 .OR. nOpc == 1
		If !Empty(SC5->C5_YIDCITE)
            FwAlertWarning('N�o � possivel modificar pedido de venda criado pelo motor de abastecimento.','ATEN��O - PE MT410ACE')
            return lExecuta := .F.
        Endif
    Endif
    //FIM  -  Condi��o para pedidos feitos pelo motor de abastecimento MOTOR em TELA

return lExecuta
