
alter procedure Sp_BPortal_Sinc_Protheus_Cotacao_Portal
with encryption
as
begin

set nocount on

DECLARE @ID									bigint
DECLARE @FORNECEDOR_ID						bigint
DECLARE @EMPRESA_ID 						bigint
DECLARE @UNIDADE_ID 						bigint

DECLARE @ITEM	 							VARCHAR(max)
DECLARE @PRODUTO 							VARCHAR(max)
DECLARE @QUANT								decimal(30,8)
DECLARE @PRECO 								decimal(30,8)
DECLARE @PRAZO								int
DECLARE @FORNECEDOR							VARCHAR(max)
DECLARE @LOJA								VARCHAR(max)
DECLARE @TIPO_FRETE							VARCHAR(max)
DECLARE @DATA_VALIDADE						VARCHAR(max)
DECLARE @ORCAMENTO							VARCHAR(max)
DECLARE @COTACAO							VARCHAR(max)
DECLARE @REVISAO							VARCHAR(max)
		
DECLARE @SOLICITACAO_SERVICO_COTACAO_ID 	bigint
DECLARE @SOLICITACAO_SERVICO_ITEM_ID		bigint
DECLARE @OBSERVACAO							VARCHAR(max)

declare cursor_temp1 cursor fast_forward for

select 
	C8_NUM,
	SS.ID, 
	f.ID, 
	SS.EmpresaID,
	SS.UnidadeID, 
	C8_FORNECE, 
	C8_LOJA,
	MAX(C8_VALIDA), 
	MAX(C8_ORCFOR),
	MAX(C8_NUMPRO),
	MAX(C8_TPFRETE)	
from SolicitacaoServico SS with (nolock)
JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] SCP with (nolock) ON SS.Numero = SCP.CODIGO COLLATE  Latin1_General_BIN
JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP] SCB with (nolock) ON PROCESSO_BIZAGI = SC_YBIZAGI  
JOIN [DADOSADV].[dbo].[SC8010] SC8 with (nolock) ON C8_NUMSC = SC_NUM AND C8_ITEMSC = SC_ITEM AND SC8.D_E_L_E_T_ = ''
JOIN [DADOSADV].[dbo].[SA2010] SA2 with (nolock) ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA AND SA2.D_E_L_E_T_ = ''
JOIN Fornecedor f with (nolock) ON f.CPFCNPJ =  SA2.A2_CGC COLLATE  Latin1_General_BIN
where C8_NUM <> '' AND C8_PRECO > 0
and not exists (
		select 1 from SolicitacaoServicoCotacao SSC where SSC.SolicitacaoServicoID = SS.ID
		AND SSC.FornecedorID = f.ID AND SSC.Deletado = 0
		AND SSC.Revisao = MAX(C8_NUMPRO)
)
and (select COUNT(*) from SolicitacaoServicoItem SSI where SSI.SolicitacaoServicoID = SS.ID AND SSI.Deletado = 0) > 0
group by  
	C8_NUM,
	SS.ID,
	f.ID, 
	SS.EmpresaID,
	SS.UnidadeID, 
	C8_FORNECE, 
	C8_LOJA
order by SS.ID

	
open cursor_temp1
fetch next from cursor_temp1 into 
@COTACAO				,
@ID						,
@FORNECEDOR_ID	 		,
@EMPRESA_ID 			,
@UNIDADE_ID 			,
@FORNECEDOR				,
@LOJA					,
@DATA_VALIDADE			,
@ORCAMENTO				,
@REVISAO				,
@TIPO_FRETE				
                        

while @@FETCH_STATUS = 0
begin
	
	BEGIN TRANSACTION  

	BEGIN TRY  
	
		update SolicitacaoServicoFornecedor SET Habilitado=0 
			WHERE 
				FornecedorID 				= @FORNECEDOR_ID
				AND SolicitacaoServicoID	= @ID
				AND Revisao					<> Revisao
		
		insert into SolicitacaoServicoCotacao (
			StatusIntegracao, 
			EmpresaID, 
			UnidadeID, 
			Habilitado, 
			Deletado, 
			DeleteID,
			SolicitacaoServicoID, 
			FornecedorID, 
			DataValidade, 
			NumeroOrcamento, 
			TipoFrete, 
			Revisao, 
			AtendeCotacao,
			Origem)
		
		select 
		StatusIntegracao		= 0, 
		EmpresaID				= @EMPRESA_ID,
		UnidadeID				= @UNIDADE_ID, 
		Habilitado				= 1, 
		Deletado				= 0, 
		DeleteID				= 0,
		SolicitacaoServicoID	= @ID, 
		FornecedorID			= @FORNECEDOR_ID,
		DataValidade			= CONVERT(DATETIME, @DATA_VALIDADE, 102), 
		NumeroOrcamento			= @ORCAMENTO, 
		TipoFrete				= (case when @TIPO_FRETE='C' then 1 else 2 end), 
		Revisao					= @REVISAO, 
		AtendeCotacao			= 1,
		Origem					= 2
		
		update SolicitacaoServicoFornecedor SET Aprovado=1 
			WHERE 
				FornecedorID 				= @FORNECEDOR_ID
				AND SolicitacaoServicoID	= @ID
				
		SET @SOLICITACAO_SERVICO_COTACAO_ID	= ISNULL((SELECT SCOPE_IDENTITY()), 0)
	
		declare cursor_temp2 cursor fast_forward for
		select 
			C8_ITEM, 
			C8_PRODUTO, 
			C8_QUANT, 
			C8_PRECO, 
			C8_PRAZO,
			C8_YOBSCOM	
		from SolicitacaoServico SS with (nolock)
		JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] SCP with (nolock) ON SS.Numero = SCP.CODIGO COLLATE  Latin1_General_BIN
		JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP] SCB with (nolock) ON PROCESSO_BIZAGI = SC_YBIZAGI  
		JOIN [DADOSADV].[dbo].[SC8010] SC8 with (nolock) ON C8_NUMSC = SC_NUM AND C8_ITEMSC = SC_ITEM AND SC8.D_E_L_E_T_ = ''
		JOIN [DADOSADV].[dbo].[SA2010] SA2 with (nolock) ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA AND SA2.D_E_L_E_T_ = ''
		JOIN Fornecedor f with (nolock) ON f.CPFCNPJ =  SA2.A2_CGC COLLATE  Latin1_General_BIN
		where 1=1
		AND f.ID 		= @FORNECEDOR_ID
		AND SS.ID		= @ID
		AND C8_NUMPRO	= @REVISAO
		AND C8_NUM		= @COTACAO

		open cursor_temp2
		fetch next from cursor_temp2 into 
		@ITEM	 		,
		@PRODUTO 		,
		@QUANT			,
		@PRECO 			,
		@PRAZO			,
		@OBSERVACAO
		while @@FETCH_STATUS = 0
		begin
				
				SET @SOLICITACAO_SERVICO_ITEM_ID = ISNULL((
						select TOP 1 SolicitacaoServicoItem.ID from SolicitacaoServicoItem
						join Produto ON Produto.ID = ProdutoID
						where 
							SolicitacaoServicoID		= @ID
							AND Produto.Codigo 			= @PRODUTO
							AND Item 					= @ITEM
							--AND ROUND(Quantidade, 4)	= ROUND(@QUANT, 4)
					), 0)
					
					print 'SOLICITACAO_SERVICO_COTACAO_ID '+convert(varchar, @SOLICITACAO_SERVICO_COTACAO_ID)
					print 'SOLICITACAO_SERVICO_ITEM_ID '+convert(varchar, @SOLICITACAO_SERVICO_ITEM_ID)
	
					If (@SOLICITACAO_SERVICO_ITEM_ID <> 0 And @SOLICITACAO_SERVICO_COTACAO_ID <> 0)
					BEGIN
										
						insert into SolicitacaoServicoCotacaoItem (
						StatusIntegracao, 
						EmpresaID, 
						UnidadeID, 
						Habilitado, 
						Deletado, 
						DeleteID,
						SolicitacaoServicoCotacaoID, 
						SolicitacaoServicoItemID, 
						Observacao, 
						Preco, 
						PrazoEntrega, 
						AtendeTotalmente, 
						AtendeItem,
						IPI,
						ValorSubstituicao)
			
						select 
						StatusIntegracao				= 0, 
						EmpresaID						= @EMPRESA_ID,
						UnidadeID						= @UNIDADE_ID, 
						Habilitado						= 1, 
						Deletado						= 0, 
						DeleteID						= 0,
						SolicitacaoServicoCotacaoID		= @SOLICITACAO_SERVICO_COTACAO_ID, 
						SolicitacaoServicoItemID		= @SOLICITACAO_SERVICO_ITEM_ID,
						Observacao						= @OBSERVACAO, 
						Preco							= @PRECO, 
						PrazoEntrega					= @PRAZO, 
						AtendeTotalmente				= 1, 
						AtendeItem						= 1,
						IPI								= 0,
						ValorSubstituicao				= 0
					END
					
					
			
			fetch next from cursor_temp2 into 
				@ITEM	 		,
				@PRODUTO 		,
				@QUANT			,
				@PRECO 			,
				@PRAZO			,
				@OBSERVACAO
		end

		close cursor_temp2
		deallocate cursor_temp2
			
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState  
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_LINE() AS ErrorLine  
			,ERROR_MESSAGE() AS ErrorMessage
	  
		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION  
	END CATCH  
	  
	IF @@TRANCOUNT > 0  
		COMMIT TRANSACTION  
	
	
	
	fetch next from cursor_temp1 into 
		@COTACAO				,
		@ID						,
		@FORNECEDOR_ID	 		,
		@EMPRESA_ID 			,
		@UNIDADE_ID 			,
		@FORNECEDOR				,
		@LOJA					,
		@DATA_VALIDADE			,
		@ORCAMENTO				,
		@REVISAO				,
		@TIPO_FRETE				

end

close cursor_temp1
deallocate cursor_temp1


end