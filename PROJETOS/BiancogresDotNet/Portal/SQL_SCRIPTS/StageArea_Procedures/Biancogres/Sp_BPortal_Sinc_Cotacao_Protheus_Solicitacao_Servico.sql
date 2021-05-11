alter procedure Sp_BPortal_Sinc_Cotacao_Protheus_Solicitacao_Servico
with encryption
as
begin

set nocount on

DECLARE @ID							bigint
DECLARE @EMPRESAID 					bigint
DECLARE @UNIDADEID 					bigint
DECLARE @FORNECEDORID				bigint
DECLARE @COTACAO 					VARCHAR(max)
DECLARE @COTACAOITEM				VARCHAR(max)

create table #TEMP_TAB([ID]	bigint)

declare cursor_temp1 cursor fast_forward for
select 
DISTINCT
SS.ID,
SS.EmpresaID,
SS.UnidadeID, 
f.ID 
from SolicitacaoServico SS with (nolock)
JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] SCP with (nolock) ON SS.Numero = SCP.CODIGO COLLATE  Latin1_General_BIN
JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP] SCB with (nolock) ON PROCESSO_BIZAGI = SC_YBIZAGI  
JOIN [DADOSADV].[dbo].[SC8010] SC8 with (nolock) ON C8_NUMSC = SC_NUM AND C8_ITEMSC = SC_ITEM AND SC8.D_E_L_E_T_ = ''
JOIN [DADOSADV].[dbo].[SA2010] SA2 with (nolock) ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA AND SA2.D_E_L_E_T_ = ''
JOIN Fornecedor f with (nolock) ON f.CPFCNPJ =  SA2.A2_CGC COLLATE  Latin1_General_BIN
	where not exists (
		select 1 from SolicitacaoServicoFornecedor SSF where SS.ID = SSF.SolicitacaoServicoID
	)
	

open cursor_temp1
fetch next from cursor_temp1 into 
 @ID					,
 @EMPRESAID				,
 @UNIDADEID				,
 @FORNECEDORID			
 
while @@FETCH_STATUS = 0
begin

	insert into #TEMP_TAB (ID) SELECT ID = @ID
	
	update SolicitacaoServico SET STATUS = 5 where ID = @ID
	
	insert into SolicitacaoServicoFornecedor (StatusIntegracao, EmpresaID, UnidadeID, Habilitado, Deletado, DeleteID,
			SolicitacaoServicoID, FornecedorID, AgendarVisita, Vencedor, Observacao)
		select 
		StatusIntegracao=0, 
		EmpresaID=@EMPRESAID,
		UnidadeID=@UNIDADEID, 
		Habilitado=1, 
		Deletado=0, 
		DeleteID=0,
		SolicitacaoServicoID=@ID, 
		FornecedorID=@FORNECEDORID,
		AgendarVisita=0,   
		Vencedor=0, 
		Observacao=''
	
	fetch next from cursor_temp1 into 
	 @ID					,
	 @EMPRESAID				,
	 @UNIDADEID				,
	 @FORNECEDORID			
				 
end

close cursor_temp1
deallocate cursor_temp1


declare cursor_temp2 cursor fast_forward for

select 
	DISTINCT
	ID=SSI.ID,
	COTACAO=C8_NUM,
	COTACAOITEM=C8_ITEM
	from SolicitacaoServicoItem SSI with (nolock)
	JOIN Produto Prod with (nolock) ON Prod.ID = SSI.ProdutoID
	JOIN SolicitacaoServico SS with (nolock) ON SS.ID = SSI.SolicitacaoServicoID

	JOIN [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] SCP with (nolock) ON 
		SS.Numero = SCP.CODIGO  COLLATE  Latin1_General_BIN
		AND Prod.Codigo = SCP.PRODUTO COLLATE  Latin1_General_BIN
		AND SSI.Item = SCP.ITEM COLLATE  Latin1_General_BIN

	join [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP] SOL 
		ON SOL.SC_YBIZAGI = 
		(
			select TOP 1 PROCESSO_BIZAGI from [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] A 
			where A.CODIGO = SCP.CODIGO
			AND A.PROCESSO_BIZAGI is not null
		)
		AND SOL.SC_PRODUTO = SCP.PRODUTO
		AND SOL.SC_ITEM = SCP.ITEM

	JOIN [DADOSADV].[dbo].[SC8010] SC8 with (nolock) ON 
		C8_NUMSC = SC_NUM 
		AND C8_ITEMSC = SC_ITEM 
		AND SC8.D_E_L_E_T_ = ''
	JOIN [DADOSADV].[dbo].[SA2010] SA2 with (nolock) ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA AND SA2.D_E_L_E_T_ = ''
	JOIN Fornecedor f with (nolock) ON f.CPFCNPJ =  SA2.A2_CGC COLLATE  Latin1_General_BIN
	where  exists (
		select 1 from #TEMP_TAB TEMP where SS.ID = TEMP.ID
	)
	
open cursor_temp2
fetch next from cursor_temp2 into 
 @ID					,
 @COTACAO				,
 @COTACAOITEM 			
 
while @@FETCH_STATUS = 0
begin

	print 'update'
	
	UPDATE SolicitacaoServicoItem SET 
		Cotacao = @COTACAO, 
		CotacaoItem = @COTACAOITEM
	where ID = @ID
		 	
	fetch next from cursor_temp2 into 
	 @ID					,
 @COTACAO				,
 @COTACAOITEM 			
           
	 
end

close cursor_temp2
deallocate cursor_temp2



end