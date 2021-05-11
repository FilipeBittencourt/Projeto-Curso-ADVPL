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
	ROW 								bigint			,
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
	UnidadeID 							bigint,
	Loja                             	varchar(02),    
	Deletado							int,
	Codigo                             	varchar(6), 
	TipoDocumento                      	int, 	
)

declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_titulopagar cursor for

select '01', '01' union all 
select '01', '02' union all 
select '06', '01' union all
select '06', '02' union all
select '06', '03' union all
select '06', '04' union all
select '06', '05' union all
select '06', '06' union all
select '06', '07' union all
select '06', '08' union all
select '06', '09' union all
select '13', '01' union all
select '14', '01' union all
select '07', '05' 


open c_titulopagar
fetch next from c_titulopagar into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	--novos 
	set @sql = '
	insert into 
	#TEMP_TITULO_PAGAR (	
		ROW									,
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
		UnidadeID							,
		DataPagamento						,
		Loja								,
		Deletado							,
		Codigo								,
		TipoDocumento
	)

	select
		ROW = (ROW_NUMBER() OVER(ORDER BY SE2.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TITULO_PAGAR),0),	
		A2_CGC,
		--F1_SERIE,
		E2_PREFIXO,
		E2_NUM, 
		E2_PARCELA,
		E2_EMISSAO,
		E2_VENCTO,
		'''',
		E2_VALOR,
		E2_SALDO,
		ID=SE2.R_E_C_N_O_,
		'+rtrim(convert(varchar,@EmpresaID))+',
		'+rtrim(convert(varchar,@UnidadeID))+',
		null,
		E2_LOJA,
		0,
		Codigo=E2_FORNECE,
		TipoDocumento=case when RTRIM(F1_ESPECIE) != ''NFS'' then 1 else 2 end
		from HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2  WITH (nolock)
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA  AND SA2.D_E_L_E_T_ = ''''
		INNER JOIN HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1  WITH (nolock) ON F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+E2_LOJA = E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA AND SF1.D_E_L_E_T_ = ''''

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
			select 1 from TituloPagar t  WITH (nolock) where 
				EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
				AND UnidadeID = '+rtrim(convert(varchar,@UnidadeID))+'
				AND NumeroControleParticipante = SE2.R_E_C_N_O_
				AND Deletado = 0
			--	t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(E2_NUM)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA)+(case when E2_LOJA <> ''01'' then E2_LOJA else ''''  end)+''-''+convert(varchar, SE2.R_E_C_N_O_) collate Latin1_General_BIN 
				
		)  
		and exists (
			select 1 from Fornecedor f  WITH (nolock) where 
			f.CodigoERP = RTRIM(E2_FORNECE) collate Latin1_General_BIN 
		)
		AND E2_FORNECE NOT IN (''PIS'')	
	'

	print @sql
	exec(@sql)
	
	--atualizados
	set @sql = '
		INSERT INTO #TEMP_TITULO_PAGAR (	
			ROW									,
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
			UnidadeID							,
			DataPagamento						,
			Loja								,
			Deletado							,
			Codigo								,
			TipoDocumento
		)

		SELECT 
			ROW = (ROW_NUMBER() OVER(ORDER BY SE2.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TITULO_PAGAR),0),	
			A2_CGC,
		--	F1_SERIE,
		E2_PREFIXO,
			E2_NUM, 
			E2_PARCELA,
			E2_EMISSAO,
			E2_VENCTO,
			'''',
			E2_VALOR,
			E2_SALDO,
			ID=SE2.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',
			case when E2_SALDO > 0 then null else E2_BAIXA end,
			E2_LOJA,
			0,--case when E2_NUMBOR <> '''' then 1 else 0 end,
			Codigo=E2_FORNECE,
			TipoDocumento=t.TipoDocumento
		FROM HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2  WITH (nolock)
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''''
		--INNER JOIN HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1  WITH (nolock) ON F1_FORNECE = E2_FORNECE AND E2_LOJA = F1_LOJA AND F1_DOC = E2_NUM AND E2_PREFIXO = F1_SERIE AND SF1.D_E_L_E_T_ = ''''
		INNER JOIN TituloPagar t  WITH (nolock) on 
				t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
				AND t.UnidadeID = '+rtrim(convert(varchar,@UnidadeID))+'
				AND t.NumeroControleParticipante = SE2.R_E_C_N_O_
				AND t.Deletado = 0
		--INNER JOIN TituloPagar t on t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(E2_NUM)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA)+(case when E2_LOJA <> ''01'' then E2_LOJA else ''''  end)+''-''+convert(varchar, SE2.R_E_C_N_O_) collate Latin1_General_BIN
		WHERE 
		SE2.D_E_L_E_T_='' ''
	--	AND Deletado	= 0
		AND 
		(
			convert(date, DataVencimento)				<> convert(date, E2_VENCTO) or		
			(E2_SALDO > 0 /*AND Saldo > 0*/ AND Round(Saldo,2)		<> Round(E2_SALDO,2))  or
			(E2_SALDO <= 0 and DataPagamento is null)
			-- or (E2_NUMBOR	<> '''')
			
		)
		AND E2_FORNECE NOT IN (''PIS'')		
	'

	print @sql
	exec(@sql)
	
	--deletados
	set @sql = '
		INSERT INTO #TEMP_TITULO_PAGAR (	
			ROW									,
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
			UnidadeID							,
			DataPagamento						,
			Loja								,
			Deletado							,
			Codigo								,
			TipoDocumento
		)

		SELECT 
			ROW = (ROW_NUMBER() OVER(ORDER BY SE2.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TITULO_PAGAR),0),	
			A2_CGC,
			--F1_SERIE,
			E2_PREFIXO,
			E2_NUM, 
			E2_PARCELA,
			E2_EMISSAO,
			E2_VENCTO,
			'''',
			E2_VALOR,
			E2_SALDO,
			ID=SE2.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',
			case when E2_SALDO > 0 then null else E2_BAIXA end,
			E2_LOJA,
			1,
			Codigo=E2_FORNECE,
			TipoDocumento=t.TipoDocumento
		FROM HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2  WITH (nolock)
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''''
	--	INNER JOIN HADES.DADOSADV.dbo.SF1'+@Empresa+'0 SF1  WITH (nolock) ON F1_FORNECE = E2_FORNECE AND E2_LOJA = F1_LOJA AND F1_DOC = E2_NUM AND E2_PREFIXO = F1_SERIE AND SF1.D_E_L_E_T_ = ''''

		--INNER JOIN TituloPagar t on t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(E2_NUM)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA)+(case when E2_LOJA <> ''01'' then E2_LOJA else ''''  end)+''-''+convert(varchar, SE2.R_E_C_N_O_) collate Latin1_General_BIN
		INNER JOIN TituloPagar t  WITH (nolock) on 
				t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
				AND t.UnidadeID = '+rtrim(convert(varchar,@UnidadeID))+'
				AND t.NumeroControleParticipante = SE2.R_E_C_N_O_
				AND t.Deletado = 0
		WHERE 
		SE2.D_E_L_E_T_=''*''
	--	AND Deletado	= 0
		AND E2_FORNECE NOT IN (''PIS'')		
	'

	print @sql
	exec(@sql)
	
	--estão em borderor deletar do portal
	set @sql = '
		INSERT INTO #TEMP_TITULO_PAGAR (	
			ROW									,
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
			UnidadeID							,
			DataPagamento						,
			Loja								,
			Deletado							,
			Codigo								,
			TipoDocumento
		)

		SELECT 
			ROW = (ROW_NUMBER() OVER(ORDER BY SE2.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #TEMP_TITULO_PAGAR),0),	
			A2_CGC,
		--	F1_SERIE,
		E2_PREFIXO,
			E2_NUM, 
			E2_PARCELA,
			E2_EMISSAO,
			E2_VENCTO,
			'''',
			E2_VALOR,
			0,
			ID=SE2.R_E_C_N_O_,
			'+rtrim(convert(varchar,@EmpresaID))+',
			'+rtrim(convert(varchar,@UnidadeID))+',
			null,
			E2_LOJA,
			0,
			Codigo=E2_FORNECE,
			TipoDocumento=t.TipoDocumento
		FROM HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2  WITH (nolock)
		INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_FILIAL = '' '' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''''
		INNER JOIN TituloPagar t  WITH (nolock) on 
				t.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
				AND t.UnidadeID = '+rtrim(convert(varchar,@UnidadeID))+'
				AND t.NumeroControleParticipante = SE2.R_E_C_N_O_
				AND t.Deletado = 0
		WHERE 
		SE2.D_E_L_E_T_		='' ''
		AND E2_NUMBOR		<> ''''
		AND Convert(Date, SE2.E2_VENCTO) BETWEEN  Convert(Date, GETDATE()) AND Convert(Date, GETDATE())
		AND Saldo > 0
		AND E2_SALDO > 0
		AND DataPagamento is null
		AND E2_FORNECE NOT IN (''PIS'')		
	'
	           
	
	print @sql
	exec(@sql)
	
	
	--recnos que estão na base do portal mas não existe no protheus
	set @sql = '
		
		update [TituloPagar]

		set Deletado = 1, 
		LastEditDate = GETDATE()
		WHERE ID IN (
			select
			ID
			
			from TituloPagar t  WITH (nolock)
			where 
			EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+'
			AND UnidadeID = '+rtrim(convert(varchar,@UnidadeID))+'
			and not exists (
				select 1 from HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2 WITH (nolock) where 
					t.NumeroControleParticipante = SE2.R_E_C_N_O_
			)
			and Saldo > 0
			and Deletado=0
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

DECLARE @ROW							 	 bigint
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
DECLARE @Loja						         varchar(02)
DECLARE @Deletado 							 int
DECLARE @Codigo 							 varchar(6)
DECLARE @TipoDocumento						 int

declare cursor_titulo_pagar cursor fast_forward for
select 	ROW, 
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
		UnidadeID							,
		DataPagamento						,
		Loja								,
		Deletado 							,
		Codigo 								,
		TipoDocumento from #TEMP_TITULO_PAGAR

open cursor_titulo_pagar
fetch next from cursor_titulo_pagar into 
@ROW,
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
@UnidadeID							 ,	
@DataPagamento						 ,
@Loja							 	 ,
@Deletado							 ,
@Codigo 		          			 ,
@TipoDocumento							
while @@FETCH_STATUS = 0
begin

	If ((select COUNT(*) from HADES.DADOSADV.dbo.SA2010  WITH (nolock)
			where A2_COD = @Codigo 
			and D_E_L_E_T_= ''
			and A2_MSBLQL <> '1'
			and A2_TIPO = 'J'
			and A2_CGC <> '') > 1)
	begin
		select @FornecedorCPFCNPJ=A2_CGC from HADES.DADOSADV.dbo.SA2010  WITH (nolock)
			where A2_COD = @Codigo 
			and D_E_L_E_T_= ''
			and A2_MSBLQL <> '1'
			and A2_TIPO = 'J'
			and A2_LOJA = '01'
			and A2_CGC <> ''	
	End

	/*if (@Loja = '01')
	Begin
		set @ChaveUnica = RTRIM(@FornecedorCPFCNPJ)+RTRIM(@NumeroDocumento)+RTRIM(@Serie)+RTRIM(@Parcela)+'-'+convert(varchar, @NumeroControleParticipante)
	End
	else
	Begin
		set @ChaveUnica = RTRIM(@FornecedorCPFCNPJ)+RTRIM(@NumeroDocumento)+RTRIM(@Serie)+RTRIM(@Parcela)+RTRIM(@Loja)+'-'+convert(varchar, @NumeroControleParticipante)
	End
	*/
	set @ChaveUnica = RTRIM(@Codigo)+RTRIM(@NumeroDocumento)+RTRIM(@Serie)+RTRIM(@Parcela)+RTRIM(@Loja)+convert(varchar, @Deletado)+'-'+convert(varchar, @NumeroControleParticipante)
	
	print 'proc row: '+ @ChaveUnica
	
	/*if (
		@Deletado= 1 And 
		(select count(*) from TituloPagar  WITH (nolock)
			where 
				EmpresaID = @EmpresaID 
				AND UnidadeID = @UnidadeID 
				AND NumeroControleParticipante = @NumeroControleParticipante
				AND Deletado	= @Deletado
			) >= 1
		)
	BEGIN
		delete from TituloPagar
			where 
				EmpresaID = @EmpresaID 
				AND UnidadeID = @UnidadeID 
				AND NumeroControleParticipante = @NumeroControleParticipante
				AND Deletado	= @Deletado
	END
	*/
	
	--if (not exists (select 1 from TituloPagar where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica AND Deletado	= @Deletado))
	if (not exists (select 1 from TituloPagar  WITH (nolock)
			where 
				EmpresaID = @EmpresaID 
				AND UnidadeID = @UnidadeID 
				AND NumeroControleParticipante = @NumeroControleParticipante
				AND Deletado	= 0
				)		
		)
	
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
           ,[NumeroControleParticipante]
		   ,[Deletado]
		   ,[InsertDate]
		   ,[TipoDocumento])
		
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
		NumeroControleParticipante	= @NumeroControleParticipante,
		Deletado					= @Deletado,
		InsertDate					= GETDATE(),
		TipoDocumento				= @TipoDocumento
			
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
		NumeroControleParticipante	= @NumeroControleParticipante,
		DataPagamento				= convert(date, @DataPagamento),
		Deletado					= @Deletado,
		LastEditDate				= GETDATE(),
		ChaveUnica					= @ChaveUnica
		where EmpresaID = @EmpresaID 
				AND UnidadeID = @UnidadeID 
				AND NumeroControleParticipante = @NumeroControleParticipante
			--	AND Deletado	= @Deletado
		--where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica and Deletado = @Deletado
		
	end

	fetch next from cursor_titulo_pagar into 
			@ROW,
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
			@UnidadeID							 ,	
			@DataPagamento						 ,	
			@Loja							 	 ,
			@Deletado							 ,	
			@Codigo 							 ,
			@TipoDocumento		

end

close cursor_titulo_pagar
deallocate cursor_titulo_pagar

end