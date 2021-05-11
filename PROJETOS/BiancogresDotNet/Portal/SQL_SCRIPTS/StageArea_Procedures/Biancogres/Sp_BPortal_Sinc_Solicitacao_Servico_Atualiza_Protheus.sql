alter procedure Sp_BPortal_Sinc_Solicitacao_Servico_Atualiza_Protheus
with encryption
as
begin

set nocount on

DECLARE @ID							bigint
DECLARE @VENCEDOR 					INT
DECLARE @CONTRATO 					VARCHAR(max)
DECLARE @CONTRATOITEM 				VARCHAR(max)
DECLARE @PEDIDO 					VARCHAR(max)
DECLARE @PEDIDOITEM					VARCHAR(max)

declare cursor_temp1 cursor fast_forward for
select 
	ID = SSF.ID,
	Vencedor = ISNULL(BZCP.VENCEDOR,0)
from
 SolicitacaoServicoFornecedor SSF
 join SolicitacaoServico SS ON SSF.SolicitacaoServicoID = SS.ID
 join [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL] BZCP on SS.Numero = CODIGO COLLATE  Latin1_General_BIN
 join Fornecedor FO ON SSF.FornecedorID = FO.ID AND FO.CodigoERP = BZCP.FORNE_COD COLLATE  Latin1_General_BIN
where 1=1
AND BZCP.COTACAO <> ''
AND (BZCP.CONTRATO <> '' or BZCP.PEDIDO <>'')
AND SSF.StatusIntegracao = 0


open cursor_temp1
fetch next from cursor_temp1 into 
 @ID					,
 @VENCEDOR				          
while @@FETCH_STATUS = 0
begin

	print 'update'
	
	UPDATE SolicitacaoServicoFornecedor SET 
		Vencedor = @VENCEDOR, 
		StatusIntegracao = 1
	where ID = @ID
		 	
	fetch next from cursor_temp1 into 
	@ID					,
	@VENCEDOR				    
                         
end

close cursor_temp1
deallocate cursor_temp1


declare cursor_temp2 cursor fast_forward for
select 
ID=SSI.ID,
Contrato = ISNULL(BZCP.CONTRATO,''), 
ContratoItem=ISNULL(BZCP.CONTRATO_ITEM,''), 
Pedido = ISNULL(BZCP.PEDIDO,''), 
PedidoItem= ISNULL(BZCP.PEDIDO_ITEM,'')
from
 SolicitacaoServicoItem SSI
 join SolicitacaoServico SS ON SSI.SolicitacaoServicoID = SS.ID
 join [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL] BZCP on SS.Numero = CODIGO COLLATE  Latin1_General_BIN
 join Produto PO ON SSI.ProdutoID = PO.ID AND PO.Codigo = BZCP.PRODUTO COLLATE  Latin1_General_BIN
where 1=1
AND BZCP.COTACAO <> ''
AND (BZCP.CONTRATO <> '' or BZCP.PEDIDO <>'')
AND SSI.StatusIntegracao = 0


open cursor_temp2
fetch next from cursor_temp2 into 
 @ID					,
 @CONTRATO				,
 @CONTRATOITEM 			,
 @PEDIDO				,
 @PEDIDOITEM	
 
while @@FETCH_STATUS = 0
begin

	print 'update'
	
	UPDATE SolicitacaoServicoItem SET 
		Contrato = @CONTRATO, 
		ContratoItem = @CONTRATOITEM, 
		Pedido = @PEDIDO, 
		PedidoItem = @PEDIDOITEM,
		StatusIntegracao = 1
	where ID = @ID
		 	
	fetch next from cursor_temp2 into 
	@ID					,
	 @CONTRATO				,
	 @CONTRATOITEM 			,
	 @PEDIDO				,
	 @PEDIDOITEM	          
	 
end

close cursor_temp2
deallocate cursor_temp2



end