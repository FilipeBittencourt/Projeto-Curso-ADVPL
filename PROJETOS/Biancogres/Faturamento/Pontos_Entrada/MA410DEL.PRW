#INCLUDE "PROTHEUS.CH"
                                                              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA410DEL  ºAutor  ³Facile              º Data ³  13/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PE: Após deletar o registro do SC6						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA410DEL()
Local aArea 	:= GetArea()
Local cPedido	:= SC5->C5_NUM
Local cChave 	:= SUBSTR(SC6->C6_NUMORC, 1, Len(SC6->C6_NUMORC)-2)
Local lExistPd := .F.
Local cAliasQry
Local cQuery                 

//TESTAR SE NAO EXISTE MAIS NENHUM ITEM GERADO PELO ORCAMENTO E LIBERAR O MESMO PARA EFETIVAR NOVAMENTE
cAliasQry := (GetNextAlias())
BeginSql Alias cAliasQry
	SELECT CONT = COUNT(*) FROM %TABLE:SC6% WHERE C6_FILIAL = %xFilial:SC6% AND C6_NUM = %EXP:cPedido% AND %NOTDEL%
EndSql
(cAliasQry)->(DbGoTop())

IF (cAliasQry)->CONT > 0
	lExistPd := .T.
ENDIF
(cAliasQry)->(DbCloseArea())

//Exclui as Parcelas de Contratos, caso seja excluido o Pedido de Venda
Z60->(DbSetOrder(1))
If Z60->(dbSeek(xFilial("Z60")+cPedido))
	RecLock("Z60",.F.)		
	Z60->(DBDelete())
	Z60->(MsUnlock())			
EndIf

	// Envia workflow caso o pedido esteja associado ao um RA
	U_BIAF018(SC5->C5_NUM, SC5->C5_YCLIORI)
			
	// Tiago Rossini Coradini - 09/08/2017 - OS: 4538-16 - Exclui bloqueio comercial do pedido de venda 
	U_BIAF083(SC5->C5_NUM)

RestArea(aArea)

Return()