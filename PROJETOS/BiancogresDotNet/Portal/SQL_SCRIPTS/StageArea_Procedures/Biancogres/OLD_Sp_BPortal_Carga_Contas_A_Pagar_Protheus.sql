alter procedure Sp_BPortal_Sinc_Contas_A_Pagar_Protheus
with encryption
as
begin

set nocount on


if ( not (select OBJECT_ID('tempdb.dbo.#TEMP_TITULO_PAGAR')) is null ) drop table #TEMP_TITULO_PAGAR

declare @EmpresaID bigint = 0
declare @UnidadeID bigint = 0


create table #TEMP_TITULO_PAGAR
(
	FornecedorCPFCNPJ                   varchar(max)    ,
	Serie                               varchar(max)    ,
	NumeroDocumento                     varchar(max)    ,
	Parcela                             varchar(max)    ,
	DataEmissao                         varchar(8)      ,
	DataVencimento                      varchar(8)      ,
	DataBaixa                           varchar(8)      ,
	FormaPagamento                      varchar(max)    ,
	DataPagamento                       varchar(8)      ,
	ValorTitulo                         decimal(30,8)   ,
	Saldo                               decimal(30,8)   ,
	NumeroControleParticipante          varchar(max),
	EmpresaID 							bigint,
	UnidadeID 							bigint	
)

declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_titulopagar cursor for

select '01', '01' union all 
select '06', '01' union all
select '06', '02' union all
select '06', '03' union all
select '06', '04' union all
select '06', '05' union all
select '06', '06' union all
select '06', '07' union all
select '06', '08' union all
select '13', '01' 

open c_titulopagar
fetch next from c_titulopagar into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	 
	set @sql = '
	insert into 
	#TEMP_TITULO_PAGAR (	
		FornecedorCPFCNPJ                   ,
		Serie                               ,
		NumeroDocumento                     ,
		Parcela                             ,
		DataEmissao                         ,
		DataVencimento                      ,
		FormaPagamento                      ,
		ValorTitulo                         ,
		Saldo                               ,
		NumeroControleParticipante         	,
		EmpresaID							,
		UnidadeID								
	)

	select  
		A2_CGC,
		F1_SERIE,
		E2_NUM, 
		E2_PARCELA,
		E2_EMISSAO,
		E2_VENCORI,
		'''',
		E2_VALOR,
		E2_SALDO,
		ID=SE2.R_E_C_N_O_,
		'+rtrim(convert(varchar,@EmpresaID))+',
		'+rtrim(convert(varchar,@UnidadeID))+'
		from HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2 (NOLOCK) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''''
		INNER JOIN HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1 (NOLOCK) ON F1_FORNECE = E2_FORNECE AND E2_LOJA = F1_LOJA AND F1_DOC = E2_NUM AND E2_PREFIXO = F1_SERIE AND SF1.D_E_L_E_T_ = ''''

		where 

		SE2.E2_FILIAL = '''+@Filial+'''
		and SE2.E2_SALDO > 0
		and SE2.D_E_L_E_T_ = ''''
		AND SE2.E2_TIPO IN (''NF'')
		AND E2_NUMBOR	= ''''
		and A2_MSBLQL <> ''1''
		and A2_TIPO = ''J''
		and A2_CGC <> ''''	
		and not exists (
			select 1 from TituloPagar t where 
				t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(E2_NUM)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA) collate Latin1_General_BIN 
		)  
		and exists (
			select 1 from Fornecedor f (nolock) where 
			f.ChaveUnica = RTRIM(A2_CGC) collate Latin1_General_BIN 
		)
			
	'

	print @sql
	exec(@sql)
	
	set @sql = '
		INSERT INTO #TEMP_TITULO_PAGAR (	
			FornecedorCPFCNPJ                   ,
			Serie                               ,
			NumeroDocumento                     ,
			Parcela                             ,
			DataEmissao                         ,
			DataVencimento                      ,
			FormaPagamento                      ,
			ValorTitulo                         ,
			Saldo                               ,
			NumeroControleParticipante          ,
			EmpresaID							,
			UnidadeID								
		)

		SELECT 
			A2_CGC,
			F1_SERIE,
			E2_NUM, 
			E2_PARCELA,
			E2_EMISSAO,
			E2_VENCORI,
			'''',
			E2_VALOR,
			E2_SALDO,
			ID=SE2.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+'
		FROM HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2 (NOLOCK)
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2 (NOLOCK) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''''
		INNER JOIN HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1 (NOLOCK) ON F1_FORNECE = E2_FORNECE AND E2_LOJA = F1_LOJA AND F1_DOC = E2_NUM AND E2_PREFIXO = F1_SERIE AND SF1.D_E_L_E_T_ = ''''

		INNER JOIN TituloPagar t on t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(E2_NUM)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA) collate Latin1_General_BIN
		WHERE 
		(
			DataVencimento				<> convert(date, E2_VENCORI) or		
			ValorTitulo					<> E2_VALOR
		)
			
	'

	print @sql
	exec(@sql)
	
	

	
	fetch next from c_titulopagar into @Empresa, @Filial
end
close c_titulopagar
deallocate c_titulopagar



--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from #TEMP_TITULO_PAGAR)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ChaveUnica							 varchar(max)
DECLARE @FornecedorCPFCNPJ                   varchar(max)
DECLARE @Serie                               varchar(max)
DECLARE @NumeroDocumento                     varchar(max)
DECLARE @Parcela                             varchar(max)
DECLARE @DataEmissao                         varchar(8)
DECLARE @DataVencimento                      varchar(8)
DECLARE @DataBaixa                           varchar(8)
DECLARE @FormaPagamento                      varchar(max)
DECLARE @DataPagamento                       varchar(8)
DECLARE @ValorTitulo                         decimal(30,8)
DECLARE @Saldo                               decimal(30,8)
DECLARE @NumeroControleParticipante          varchar(max)


declare cursor_titulo_pagar cursor fast_forward for
select FornecedorCPFCNPJ                   ,
		Serie                               ,
		NumeroDocumento                     ,
		Parcela                             ,
		DataEmissao                         ,
		DataVencimento                      ,
		FormaPagamento                      ,
		ValorTitulo                         ,
		Saldo                               ,
		NumeroControleParticipante         	,
		EmpresaID							,
		UnidadeID		 from #TEMP_TITULO_PAGAR

open cursor_titulo_pagar
fetch next from cursor_titulo_pagar into 
@FornecedorCPFCNPJ                   ,
@Serie                               ,
@NumeroDocumento                     ,
@Parcela                             ,
@DataEmissao                         ,
@DataVencimento                      ,
@FormaPagamento						 ,
@ValorTitulo                         ,
@Saldo                               ,
@NumeroControleParticipante          ,	 
@EmpresaID							 ,	
@UnidadeID			

while @@FETCH_STATUS = 0
begin


	set @ChaveUnica = RTRIM(@FornecedorCPFCNPJ)+RTRIM(@NumeroDocumento)+RTRIM(@Serie)+RTRIM(@Parcela)
	
	print 'proc row: '+ @ChaveUnica
	
	
	if (not exists (select 1 from TituloPagar where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica))
	begin

		print 'insert'
		
		
		INSERT INTO [TituloPagar]
           ([ChaveUnica]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[StatusIntegracao]
           ,[FornecedorCPFCNPJ]
           ,[Serie]
           ,[NumeroDocumento]
           ,[Parcela]
           ,[DataEmissao]
           ,[DataVencimento]
		   ,[FormaPagamento]
           ,[ValorTitulo]
           ,[Saldo]
           ,[NumeroControleParticipante])
		
		select		
		ChaveUnica					= @ChaveUnica,
		EmpresaID					= @EmpresaID,
		UnidadeID					= @UnidadeID,
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ			= @FornecedorCPFCNPJ,
		Serie                       = @Serie,
		NumeroDocumento             = @NumeroDocumento,
		Parcela                     = @Parcela,
		DataEmissao                 = convert(date, @DataEmissao),
		DataVencimento              = convert(date, @DataVencimento),
		FormaPagamento              = '',
		ValorTitulo                 = @ValorTitulo,
		Saldo                       = @Saldo,
		NumeroControleParticipante	= @NumeroControleParticipante
		

	end
	else
	begin

		print 'update'

		update [TituloPagar]

		set
		StatusIntegracao			= 0,
		FornecedorCPFCNPJ			= @FornecedorCPFCNPJ,
		Serie                       = @Serie,
		NumeroDocumento             = @NumeroDocumento,
		Parcela                     = @Parcela,
		DataEmissao                 = convert(date, @DataEmissao),
		DataVencimento              = convert(date, @DataVencimento),
		FormaPagamento              = '',
		ValorTitulo                 = @ValorTitulo,
		Saldo                       = @Saldo,
		NumeroControleParticipante	= @NumeroControleParticipante
		
		where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica
		
	end

	fetch next from cursor_titulo_pagar into 
			@FornecedorCPFCNPJ                   ,
			@Serie                               ,
			@NumeroDocumento                     ,
			@Parcela                             ,
			@DataEmissao                         ,
			@DataVencimento                      ,
			@FormaPagamento						 ,
			@ValorTitulo                         ,
			@Saldo                               ,
			@NumeroControleParticipante          ,	 
			@EmpresaID							 ,	
			@UnidadeID			


end

close cursor_titulo_pagar
deallocate cursor_titulo_pagar

end