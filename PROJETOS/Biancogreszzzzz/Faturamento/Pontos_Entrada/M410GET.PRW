#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"


/*/{Protheus.doc} M410GET
@description ANTES DE MONTAR A TELA DE ALTERAÇÃO
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
User Function M410GET()

    //Funcao de Reajuste de Preco
    IF (IsInCallStack("U_M410RPRC")) .And.  !(AllTrim(FunName()) == "RPC")

        LjMsgRun("Aguarde... carregando reajustes de preço.",,{|| PrcReajuste() })

    ENDIF

Return

Static Function PrcReajuste()

    Local nX
    Local oObj

    oObj := TPedidoVendaReajustePreco():New()
    oObj:GetTabAtual()

    For nX := 1 To Len(ACOLS)

        oObj:GetPrecoAtual(nX)

    Next nX

Return
