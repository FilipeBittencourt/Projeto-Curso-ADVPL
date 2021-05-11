alter procedure Sp_BPortal_Sinc_NotaFiscalCompra_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#TEMP_TABLE')) is null ) drop table #TEMP_TABLE

create table #TEMP_TABLE
(
	ROW 							bigint,
	FornecedorCodigo				varchar(max),
	FornecedorLoja					varchar(max),
	FornecedorCpfCnpj  				varchar(max),	
	Numero							varchar(max),
	Serie							varchar(max),
	DataEmissao						varchar(max),
	PedidoNumero					varchar(max),
	PedidoNumeroItem				varchar(max),
	ProdutoNome						varchar(max),
	ProdutoCodigo					varchar(max),
	Quantidade	    				decimal(30,8),
	Valor		    				decimal(30,8),
	ProdutoUnidade					varchar(max),
	TransportadoraCpfCnpj			varchar(max),
	NumeroControleParticipante		varchar(max),
	EmpresaID 						bigint,
	UnidadeID 						bigint,
	Deletado						int,
	ChaveNFE						varchar(max),
	Item							varchar(max)
)

declare @EmpresaID bigint = 0
declare @UnidadeID bigint = 0
declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_emp cursor for

select '01', '01' 

open c_emp
fetch next from c_emp into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select TOP 1 EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select TOP 1 UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	
	set @sql = '
	insert into 
	#TEMP_TABLE (	
			ROW 						,
			FornecedorCodigo    		,
			FornecedorLoja      		,
			FornecedorCpfCnpj   		,	
			Numero 						,
			Serie 						,
			DataEmissao					,
			PedidoNumero				,
			PedidoNumeroItem			,
			ProdutoNome					,
			ProdutoCodigo				,
			Quantidade	    			,
			Valor		    			,
			ProdutoUnidade				,
			TransportadoraCpfCnpj		,
			NumeroControleParticipante	,
			EmpresaID 					,
			UnidadeID 					,
			Deletado					,
			ChaveNFE					,
			Item						
		)
	
			select 
						ROW = (ROW_NUMBER() OVER(ORDER BY ZAA.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TABLE),0),
						A2_COD,
						A2_LOJA,
						A2_CGC, 
						ZAA_DOC, 
						ZAA_SERIE, 
						ZAA_DTEMIS,
						ZAB_PEDIDO,
						ZAB_ITEMPC,
						ZAB_DESC,
						ZAB_COD,
						ZAB_QUANT1, 
						ZAB_VUNIT,
						ZAB_UMF,
						'''',
						ID=ZAA.R_E_C_N_O_,
						'+rtrim(convert(varchar,@EmpresaID))+',
						'+rtrim(convert(varchar,@UnidadeID))+',	
						0,
						ZAA_CHAVE,
						ZAB_ITEM
			from HADES.DADOSADV.dbo.ZAA'+@Empresa+'0 ZAA (nolock)
			inner join HADES.DADOSADV.dbo.ZAB'+@Empresa+'0 ZAB (nolock) ON 
				ZAA_CHAVE			= ZAB_CHAVE 
				AND ZAA_FILIAL		= ZAB_FILIAL 
				AND ZAB.D_E_L_E_T_	= ''''
			JOIN HADES.DADOSADV.dbo.SA2010 SA2 (nolock) ON SA2.A2_COD = ZAA.ZAA_CODEMI AND SA2.A2_LOJA = ZAA.ZAA_LOJEMI AND SA2.D_E_L_E_T_ = ''''                                 	
				
			where 
			ZAA.D_E_L_E_T_	= ''''
			AND ZAA_TIPO	= ''1''
			--AND ZAB_PEDIDO	<> ''''
			AND ZAA_DTEMIS	>= ''20200101''
			AND not exists (
				select NULL from HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1 (nolock)
				where 
					SF1.D_E_L_E_T_			= ''''
					AND SF1.F1_FILIAL		= ZAA.ZAA_FILIAL
					AND SF1.F1_CHVNFE		= ZAA.ZAA_CHAVE		
			) 
			AND not exists (
				select 1 from NotaFiscalCompra t where t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and t.ChaveUnica = RTRIM(ZAA_DOC)+RTRIM(ZAA_SERIE)+RTRIM(A2_COD)+RTRIM(A2_LOJA)+RTRIM(ZAB_COD)+RTRIM(ZAB_ITEM)+''-''+convert(varchar, ZAA.R_E_C_N_O_) collate Latin1_General_BIN
			)
	'

	print @sql
	exec(@sql)
	
	set @sql = '
			insert into 
			#TEMP_TABLE (	
			ROW 						,
			FornecedorCodigo    		,
			FornecedorLoja      		,
			FornecedorCpfCnpj   		,	
			Numero 						,
			Serie 						,
			DataEmissao					,
			PedidoNumero				,
			PedidoNumeroItem			,
			ProdutoNome					,
			ProdutoCodigo				,
			Quantidade	    			,
			Valor		    			,
			ProdutoUnidade				,
			TransportadoraCpfCnpj		,
			NumeroControleParticipante	,
			EmpresaID 					,
			UnidadeID 					,
			Deletado					,
			ChaveNFE					,
			Item						
		)
		
		select 
						ROW = (ROW_NUMBER() OVER(ORDER BY ZAA.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TABLE),0),
						A2_COD,
						A2_LOJA,
						A2_CGC, 
						ZAA_DOC, 
						ZAA_SERIE, 
						ZAA_DTEMIS,
						ZAB_PEDIDO,
						ZAB_ITEMPC,
						ZAB_DESC,
						ZAB_COD,
						ZAB_QUANT1, 
						ZAB_VUNIT,
						ZAB_UMF,
						'''',
						ID=ZAA.R_E_C_N_O_,
						'+rtrim(convert(varchar,@EmpresaID))+',
						'+rtrim(convert(varchar,@UnidadeID))+',	
						1,
						ChaveNFE,
						ZAB_ITEM
			from HADES.DADOSADV.dbo.ZAA'+@Empresa+'0 ZAA (nolock)
			inner join HADES.DADOSADV.dbo.ZAB'+@Empresa+'0 ZAB (nolock) ON 
				ZAA_CHAVE			= ZAB_CHAVE 
				AND ZAA_FILIAL		= ZAB_FILIAL 
				AND ZAB.D_E_L_E_T_	= ''''
			JOIN HADES.DADOSADV.dbo.SA2010 SA2 (nolock) ON SA2.A2_COD = ZAA.ZAA_CODEMI AND SA2.A2_LOJA = ZAA.ZAA_LOJEMI AND SA2.D_E_L_E_T_ = ''''                                 	
			
			JOIN NotaFiscalCompra t on t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and t.ChaveUnica = RTRIM(ZAA_DOC)+RTRIM(ZAA_SERIE)+RTRIM(A2_COD)+RTRIM(A2_LOJA)+RTRIM(ZAB_COD)+RTRIM(ZAB_ITEM)+''-''+convert(varchar, ZAA.R_E_C_N_O_) collate Latin1_General_BIN
				
			where 
			ZAA.D_E_L_E_T_=''*''
			AND Deletado	= 0	
		'
			
	print @sql
	exec(@sql)

	
	fetch next from c_emp into @Empresa, @Filial
end
close c_emp
deallocate c_emp
  
--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(*) from #TEMP_TABLE)))
print 'processando: ' + @numrec + ' registros'


declare @ChaveUnica    					varchar(max)
declare @ROW 							bigint
declare @FornecedorCodigo 				varchar(max)
declare @FornecedorLoja   				varchar(max)
declare @FornecedorCpfCnpj				varchar(max)	
declare @Numero 						varchar(max)
declare @Serie 							varchar(max)
declare @DataEmissao					varchar(max)
declare @PedidoNumero 					varchar(max)
declare @PedidoNumeroItem				varchar(max)
declare @ProdutoNome					varchar(max)
declare @ProdutoCodigo					varchar(max)
declare @Quantidade	    				decimal(30,8)
declare @Valor		    				decimal(30,8)
declare @ProdutoUnidade					varchar(max)
declare @TransportadoraCpfCnpj			varchar(max)
declare @NumeroControleParticipante		varchar(max)
declare @Deletado						int
declare @EmpID 							bigint = 0
declare @UniID 							bigint = 0
declare @ChaveNFE						varchar(max)
declare @Item							varchar(max)


declare cursor_registros cursor fast_forward for
select * from #TEMP_TABLE 

open cursor_registros
fetch next from cursor_registros into
@ROW 						,
@FornecedorCodigo       	,
@FornecedorLoja       		,
@FornecedorCpfCnpj  		,
@Numero 					,
@Serie 						,
@DataEmissao				,
@PedidoNumero 				,
@PedidoNumeroItem			,
@ProdutoNome				,
@ProdutoCodigo				,
@Quantidade	    			,
@Valor		    			,
@ProdutoUnidade				,
@TransportadoraCpfCnpj		,
@NumeroControleParticipante	,
@EmpID 						,
@UniID 						,
@Deletado					,
@ChaveNFE					,
@Item						

while @@FETCH_STATUS = 0
begin
	
	SET @ChaveUnica = RTRIM(@Numero)+RTRIM(@Serie)+RTRIM(@FornecedorCodigo)+RTRIM(@FornecedorLoja)+RTRIM(@ProdutoCodigo)+RTRIM(@Item)+'-'+convert(varchar, @NumeroControleParticipante)
	
	print 'processando: '+ @ChaveUnica
	
	
	if (not exists (select 1 from NotaFiscalCompra where ChaveUnica = @ChaveUnica AND EmpresaID = @EmpID))
	begin

		print 'insert'
		
		INSERT INTO NotaFiscalCompra
           ([ChaveUnica]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[StatusIntegracao]
           ,[FornecedorCPFCNPJ]
           ,[FornecedorLoja]
           ,[FornecedorCodigoERP]
           ,[TransportadoraCPFCNPJ]
           ,[DataEmissao]
		   ,[Numero]
		   ,[Serie]
           ,[PedidoNumero]
		   ,[PedidoItem]
           ,[ProdutoNome]
           ,[ProdutoCodigo]
           ,[ProdutoUnidade]
           ,[Quantidade]
           ,[Valor]
           ,[NumeroControleParticipante]
           ,[Deletado]
		   ,[ChaveNFE]
		   ,[ProdutoItem])
		   
		select
		ChaveUnica					= @ChaveUnica,
		EmpresaID					= @EmpID,
		UnidadeID					= @UniID,
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ           = RTRIM(@FornecedorCPFCNPJ),         
		FornecedorLoja              = RTRIM(@FornecedorLoja),            
		FornecedorCodigoERP         = RTRIM(@FornecedorCodigo),
		TransportadoraCPFCNPJ       = RTRIM(@TransportadoraCPFCNPJ),     
		DataEmissao                 = convert(date, @DataEmissao),  
		Numero          		    = RTRIM(@Numero),      
		Serie			            = RTRIM(@Serie), 		
		PedidoNumero                = RTRIM(@PedidoNumero),      
		PedidoNumeroItem            = RTRIM(@PedidoNumeroItem),      		
		ProdutoNome                 = RTRIM(@ProdutoNome),               
		ProdutoCodigo               = RTRIM(@ProdutoCodigo),             
		ProdutoUnidade              = RTRIM(@ProdutoUnidade),            
		Quantidade                  = @Quantidade,                
		Valor                       = @Valor,                     
		NumeroControleParticipante  = @NumeroControleParticipante,
		Deletado					= @Deletado,
		ChaveNFE					= @ChaveNFE,	
		ProdutoItem					= @Item
	end
	else
	begin

		print 'update'
		
		update NotaFiscalCompra
		set	 		
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ           = RTRIM(@FornecedorCPFCNPJ),         
		FornecedorLoja              = RTRIM(@FornecedorLoja),            
		FornecedorCodigoERP         = RTRIM(@FornecedorCodigo),
		TransportadoraCPFCNPJ       = RTRIM(@TransportadoraCPFCNPJ),     
		DataEmissao                 = convert(date, @DataEmissao),  
		Numero          		    = RTRIM(@Numero),      
		Serie			            = RTRIM(@Serie), 		
		PedidoNumero                = RTRIM(@PedidoNumero),      
		PedidoItem 		           	= RTRIM(@PedidoNumeroItem),      		
		ProdutoNome                 = RTRIM(@ProdutoNome),               
		ProdutoCodigo               = RTRIM(@ProdutoCodigo),             
		ProdutoUnidade              = RTRIM(@ProdutoUnidade),            
		Quantidade                  = @Quantidade,                
		Valor                       = @Valor,                              
		NumeroControleParticipante  = @NumeroControleParticipante,
		Deletado					= @Deletado,	
		ChaveNFE					= @ChaveNFE,
		ProdutoItem					= @Item
		where ChaveUnica = @ChaveUnica AND EmpresaID = @EmpID

	end

	--next
	fetch next from cursor_registros into
		@ROW 						,
		@FornecedorCodigo       	,
		@FornecedorLoja       		,
		@FornecedorCpfCnpj  		,
		@Numero 					,
		@Serie 						,
		@DataEmissao				,
		@PedidoNumero 				,
		@PedidoNumeroItem			,
		@ProdutoNome				,
		@ProdutoCodigo				,
		@Quantidade	    			,
		@Valor		    			,
		@ProdutoUnidade				,
		@TransportadoraCpfCnpj		,
		@NumeroControleParticipante	,
		@EmpID 						,
		@UniID 						,
		@Deletado					,
		@ChaveNFE					,
		@Item						

end
close cursor_registros
deallocate cursor_registros


end