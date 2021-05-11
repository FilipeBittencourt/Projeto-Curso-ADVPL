alter procedure Sp_BPortal_Sinc_PedidoCompra_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#TEMP_PC')) is null ) drop table #TEMP_PC

create table #TEMP_PC
(
	ROW 							bigint,
	FornecedorCodigo				varchar(max),
	FornecedorLoja					varchar(max),
	FornecedorCpfCnpj  				varchar(max),	
	Numero 							varchar(max),
	Item 							varchar(max),
	ProdutoNome						varchar(max),
	ProdutoCodigo					varchar(max),
	Quantidade	    				decimal(30,8),
	Saldo		    				decimal(30,8),
	ProdutoUnidade					varchar(max),
	TransportadoraCpfCnpj			varchar(max),
	NumeroControleParticipante		varchar(max),
	EmpresaID 						bigint,
	UnidadeID 						bigint,
	Deletado						int,
	TipoFrete						varchar(max)
)

declare @EmpresaID bigint = 0
declare @UnidadeID bigint = 0
declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_pc cursor for

select '01', '01' 

open c_pc
fetch next from c_pc into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select TOP 1 EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select TOP 1 UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	
	set @sql = '
	insert into 
	#TEMP_PC (	
			ROW 						,
			FornecedorCodigo    		,
			FornecedorLoja      		,
			FornecedorCpfCnpj   		,	
			Numero 						,
			Item 						,
			ProdutoNome					,
			ProdutoCodigo				,
			Quantidade	    			,
			Saldo		    			,
			ProdutoUnidade				,
			TransportadoraCpfCnpj		,
			NumeroControleParticipante	,
			EmpresaID 					,
			UnidadeID 					,
			Deletado					,
			TipoFrete
		)
	
		 SELECT							
			ROW = (ROW_NUMBER() OVER(ORDER BY SC7.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_PC),0),
			A2_COD,
			A2_LOJA,
			A2_CGC, 
			C7_NUM,
			C7_ITEM,
			C7_DESCRI,
			C7_PRODUTO,
			C7_QUANT,
			SALDO=SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA,
			C7_UM,
			A4_CGC,
			ID=SC7.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',	
			0,                                                    
			C7_TPFRETE
			FROM	HADES.DADOSADV.dbo.SC7'+@Empresa+'0 SC7 (NOLOCK)            
			JOIN HADES.DADOSADV.dbo.SA2010 SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ = ''''                                 	
			JOIN HADES.DADOSADV.dbo.SA4010 SA4 ON SA4.A4_COD = SC7.C7_YTRANSP AND SA4.D_E_L_E_T_ = ''''                                 	
	
			WHERE	SC7.C7_FILIAL		= '''+@Filial+'''                                             	
				AND SC7.C7_ENCER		= ''''                                                	
				AND SC7.C7_RESIDUO		<> ''S''                                              	
				AND SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA > 0                             	
				AND SC7.D_E_L_E_T_		= ''''       
				AND not exists (
					select 1 from PedidoCompra pc where ChaveUnica = RTRIM(C7_NUM)+''-''+convert(varchar, SC7.R_E_C_N_O_) collate Latin1_General_BIN 
					pc.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
				)
    '

	print @sql
	exec(@sql)
	
		set @sql = '
			insert into 
			#TEMP_PC (	
			ROW 						,
			FornecedorCodigo    		,
			FornecedorLoja      		,
			FornecedorCpfCnpj   		,	
			Numero 						,
			Item 						,
			ProdutoNome					,
			ProdutoCodigo				,
			Quantidade	    			,
			Saldo		    			,
			ProdutoUnidade				,
			TransportadoraCpfCnpj		,
			NumeroControleParticipante	,
			EmpresaID 					,
			UnidadeID 					,
			Deletado					,
			TipoFrete
			)
	
		 SELECT							
			ROW = (ROW_NUMBER() OVER(ORDER BY SC7.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_PC),0),
			A2_COD,
			A2_LOJA,
			A2_CGC, 
			C7_NUM,
			C7_ITEM,
			C7_DESCRI,
			C7_PRODUTO,
			C7_QUANT,
			SALDO=SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA,
			C7_UM,
			A4_CGC,
			ID=SC7.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',	
			0,
			C7_TPFRETE	
			FROM	HADES.DADOSADV.dbo.SC7'+@Empresa+'0 SC7 (NOLOCK)            
			JOIN HADES.DADOSADV.dbo.SA2010 SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ = ''''                                 	
			JOIN HADES.DADOSADV.dbo.SA4010 SA4 ON SA4.A4_COD = SC7.C7_YTRANSP AND SA4.D_E_L_E_T_ = ''''                                 	
	
			JOIN PedidoCompra pc on pc.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and pc.ChaveUnica = RTRIM(C7_NUM)+''-''+convert(varchar, SC7.R_E_C_N_O_) collate Latin1_General_BIN
			WHERE	
			SC7.D_E_L_E_T_='' ''
			AND Deletado	= 0	
			AND 
			(
				(	
					(SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA) > 0
					AND 
					Round(Saldo, 2)		<> Round((SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA), 2)
				)
			)	
    '

	print @sql
	exec(@sql)

			set @sql = '
			insert into 
			#TEMP_PC (	
			ROW 						,
			FornecedorCodigo    		,
			FornecedorLoja      		,
			FornecedorCpfCnpj   		,	
			Numero 						,
			Item 						,
			ProdutoNome					,
			ProdutoCodigo				,
			Quantidade	    			,
			Saldo		    			,
			ProdutoUnidade				,
			TransportadoraCpfCnpj		,
			NumeroControleParticipante	,
			EmpresaID 					,
			UnidadeID 					,
			Deletado					,
			TipoFrete	
			)
	
		 SELECT							
			ROW = (ROW_NUMBER() OVER(ORDER BY SC7.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_PC),0),
			A2_COD,
			A2_LOJA,
			A2_CGC, 
			C7_NUM,
			C7_ITEM,
			C7_DESCRI,
			C7_PRODUTO,
			C7_QUANT,
			SALDO=SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA,
			C7_UM,
			A4_CGC,
			ID=SC7.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',	
			1,
			C7_TPFRETE	
			FROM	HADES.DADOSADV.dbo.SC7'+@Empresa+'0 SC7 (NOLOCK)            
			JOIN HADES.DADOSADV.dbo.SA2010 SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SA2.A2_LOJA = SC7.C7_LOJA AND SA2.D_E_L_E_T_ = ''''                                 	
			JOIN HADES.DADOSADV.dbo.SA4010 SA4 ON SA4.A4_COD = SC7.C7_YTRANSP AND SA4.D_E_L_E_T_ = ''''                                 	
	
			JOIN PedidoCompra pc on pc.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and pc.ChaveUnica = RTRIM(C7_NUM)+''-''+convert(varchar, SC7.R_E_C_N_O_) collate Latin1_General_BIN
			WHERE	
			SC7.D_E_L_E_T_=''*''
			AND Deletado	= 0	
				
    '

	print @sql
	exec(@sql)

	
	fetch next from c_pc into @Empresa, @Filial
end
close c_pc
deallocate c_pc
  
--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(*) from #TEMP_PC)))
print 'processando: ' + @numrec + ' registros'

declare @ChaveUnica    					varchar(max)
declare @ROW 							bigint
declare @FornecedorCodigo 				varchar(max)
declare @FornecedorLoja   				varchar(max)
declare @FornecedorCpfCnpj				varchar(max)	
declare @Numero 						varchar(max)
declare @Item 							varchar(max)
declare @ProdutoNome					varchar(max)
declare @ProdutoCodigo					varchar(max)
declare @Quantidade	    				decimal(30,8)
declare @Saldo		    				decimal(30,8)
declare @ProdutoUnidade					varchar(max)
declare @TransportadoraCpfCnpj			varchar(max)
declare @NumeroControleParticipante		varchar(max)
declare @Deletado						int
declare @EmpID 							bigint = 0
declare @UniID 							bigint = 0
declare @TipoFrete						varchar(max)

declare cursor_pc cursor fast_forward for
select * from #TEMP_PC 

open cursor_pc
fetch next from cursor_pc into
@ROW 						,
@FornecedorCodigo       	,
@FornecedorLoja       		,
@FornecedorCpfCnpj  		,
@Numero 					,
@Item 						,
@ProdutoNome				,
@ProdutoCodigo				,
@Quantidade	    			,
@Saldo		    			,
@ProdutoUnidade				,
@TransportadoraCpfCnpj		,
@NumeroControleParticipante	,
@EmpID 						,
@UniID 						,
@Deletado					,
@TipoFrete

while @@FETCH_STATUS = 0
begin
	
	print 'processando: '+ @Numero
	
	SET @ChaveUnica = RTRIM(@Numero)+'-'+@NumeroControleParticipante
	
	if (not exists (select 1 from PedidoCompra where ChaveUnica = @ChaveUnica AND EmpresaID = @EmpID))
	begin

		print 'insert'
		
		INSERT INTO PedidoCompra
           ([ChaveUnica]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[StatusIntegracao]
           ,[FornecedorCPFCNPJ]
           ,[FornecedorLoja]
           ,[FornecedorCodigoERP]
           ,[TransportadoraCPFCNPJ]
           ,[DataEntrega]
           ,[Pedido]
		   ,[PedidoItem]
           ,[ProdutoNome]
           ,[ProdutoCodigo]
           ,[ProdutoUnidade]
           ,[Quantidade]
           ,[Saldo]
           ,[NumeroControleParticipante]
           ,[Deletado]
		   ,[TipoFrete])
		   
		select
		ChaveUnica					= @ChaveUnica,
		EmpresaID					= @EmpID,
		UnidadeID					= @UniID,
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ           = RTRIM(@FornecedorCPFCNPJ),         
		FornecedorLoja              = RTRIM(@FornecedorLoja),            
		FornecedorCodigoERP         = RTRIM(@FornecedorCodigo),
		TransportadoraCPFCNPJ       = RTRIM(@TransportadoraCPFCNPJ),     
		DataEntrega                 = Null,--@DataEntrega,               
		Pedido                      = RTRIM(@Numero),      
		PedidoItem                  = RTRIM(@Item),      		
		ProdutoNome                 = RTRIM(@ProdutoNome),               
		ProdutoCodigo               = RTRIM(@ProdutoCodigo),             
		ProdutoUnidade              = RTRIM(@ProdutoUnidade),            
		Quantidade                  = @Quantidade,                
		Saldo                       = @Saldo,                     
		NumeroControleParticipante  = @NumeroControleParticipante,
		Deletado					= @Deletado,
		TipoFrete					= Case when RTRIM(@TipoFrete)='C' then 1 else 2 end 	
		
	end
	else
	begin

		print 'update'
		
		update PedidoCompra
		set	 		
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ           = RTRIM(@FornecedorCPFCNPJ),         
		FornecedorLoja              = RTRIM(@FornecedorLoja),            
		FornecedorCodigoERP         = RTRIM(@FornecedorCodigo),
		TransportadoraCPFCNPJ       = RTRIM(@TransportadoraCPFCNPJ),     
		DataEntrega                 = null,--@DataEntrega,               
		Pedido                      = RTRIM(@Numero),       
		PedidoItem                  = RTRIM(@Item),  		
		ProdutoNome                 = RTRIM(@ProdutoNome),               
		ProdutoCodigo               = RTRIM(@ProdutoCodigo),             
		ProdutoUnidade              = RTRIM(@ProdutoUnidade),            
		Quantidade                  = @Quantidade,                
		Saldo                       = @Saldo,                     
		NumeroControleParticipante  = @NumeroControleParticipante,
		Deletado					= @Deletado,	
		TipoFrete					= Case when RTRIM(@TipoFrete)='C' then 1 else 2 end 
		where ChaveUnica = @ChaveUnica AND EmpresaID = @EmpID

	end

	--next
	fetch next from cursor_pc into
		@ROW 						,
		@FornecedorCodigo       	,
		@FornecedorLoja       		,
		@FornecedorCpfCnpj  		,
		@Numero 					,
		@Item 						,
		@ProdutoNome				,
		@ProdutoCodigo				,
		@Quantidade	    			,
		@Saldo		    			,
		@ProdutoUnidade				,
		@TransportadoraCpfCnpj		,
		@NumeroControleParticipante	,
		@EmpID 						,
		@UniID						, 						
		@Deletado					,
		@TipoFrete
		
end
close cursor_pc
deallocate cursor_pc


end