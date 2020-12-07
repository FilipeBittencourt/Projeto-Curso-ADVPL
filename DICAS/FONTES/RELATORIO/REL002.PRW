#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RWMAKE.CH"

/*
------------------------------------------------------------------------------------------------------------
Função	: REL001
Tipo		: Conferência de expedição
DescriÃ§Ã£o	: 
Retorno	: Nil
------------------------------------------------------------------------------------------------------------
*/

//ADMIN

Class BRARELATORIO002 From LongClassName

	
	//1. Colunas: 


	Data cContrat //1.1. Contrato (Número do contrato - Buscar da CN9)
	Data nPesoINI //1.2. Peso inicial (Somatório do peso do tipo de planilha "Total do contrato" - Buscar da CNA/CNB)
	Data nPesoFIM //1.3. Valor inicial (Somatório do valor do tipo de planilha "Total do contrato" - Buscar da CNA/CNB)
	
	Data nPeTotPV //1.4. Peso total em pedido de venda (Somatório de peso dos pedidos de venda - Buscar quantidade vendida da SC6 e multiplicar pelo peso da SB1)
	Data nVlTotPV //1.5. Valor total em pedido de venda (Somatório de peso dos pedidos de venda - Buscar valor total da SC6)
	Data nPeTotFT //1.6. Peso total faturado (Somatório do peso faturado dos pedidos de venda do contrato - Buscar peso da SD2 das notas fiscais emitidas)
	Data nVlTotFT //1.7. Valor total faturado (Somatório do valor faturado dos pedidos de venda do contrato - Buscar valor da SD2 das notas fiscais emitidas)
	Data nSldPeso //1.8. Saldo a gerar em peso (Coluna 1.2 menos a coluna 1.4)
	Data nSldVlor //1.9. Saldo a gerar em valor (Coluna 1.3 menos a coluna 1.5)
	Data nSldPeFT //1.10. Saldo a faturar em peso (Coluna 1.2 menos a coluna 1.6)
	Data nSldVlFT //1.11. Saldo a faturar em valor (Coluna 1.2 menos a coluna 1.7)

	/*
	
		2. Regras:
		2.1. Para os pedidos de venda que tiver resíduo eliminado, deverá considerar apenas a quantidade entregue e não a quantidade vendida
		2.2. Não considerar pedidos de venda excluídos
		2.3. Não considerar notas fiscais excluídas/canceladas

		Filtros
			Número do contrato (formato hífen/ ponto e vírgula)
			Data da vigência (formato de - até)
			Número do pedido de venda (formato hífen/ ponto e vírgula)
	*/

	
	Method New() Constructor

EndClass

Method New() Class BRARELATORIO002 	

Return Self


User Function REL002()

	Local oReport
	Local oModel	:= BRARELATORIO002():New()  
	
Return
