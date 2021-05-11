
alter procedure Sp_BPortal_Sinc_Fornecedores_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#TEMP_FORNECEDOR')) is null ) drop table #TEMP_FORNECEDOR



create table #TEMP_FORNECEDOR
(
	Codigo       	varchar(max),
	Loja       		varchar(max),
	CpfCnpj       	varchar(max),	
	Nome 			varchar(max),
	Email 			varchar(max),
	EmailWorkflow	varchar(max),
	Obs				varchar(max),
	CEP 			varchar(max),
	Logradouro		varchar(max),
	Numero			varchar(max),
	Complemento		varchar(max),
	Bairro 			varchar(max),
	UF 				varchar(max),
	Cidade 			varchar(max),
	Habilitado		varchar(max),
	TipoAntecipacao varchar(1),
	Taxa		    decimal(30,8),
	EmpresaID 		bigint,
	UnidadeID 		bigint	
)

declare @EmpresaID bigint = 0
declare @UnidadeID bigint = 0
declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_fornecedores cursor for

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

open c_fornecedores
fetch next from c_fornecedores into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	
	set @sql = '
	insert into 
	#TEMP_FORNECEDOR (	
	
	Codigo       	,
	Loja       		,
	CpfCnpj       	,	
	Nome 			,
	Email 			,
	EmailWorkflow	,
	Obs				,
	CEP 			,
	Logradouro		,
	Numero			,
	Complemento		,
	Bairro 			,
	UF 				,
	Cidade 			,
	Habilitado		,
	TipoAntecipacao ,
	Taxa		    ,
	EmpresaID		,
	UnidadeID								
	)

	select  
			 A2_COD	,
			 A2_LOJA,
			 A2_CGC, 
			 A2_NOME, 
			 A2_EMAIL, 
			 A2_YEMAFIN,	
			 OBS='''',
			 A2_CEP,
			 A2_END,
			 A2_NR_END,
			 A2_COMPLEM,
			 A2_BAIRRO,
			 A2_EST,
			 A2_MUN,
			 A2_MSBLQL,
			 A2_YTPANTE,
			 A2_YTXANTE,
			 '+rtrim(convert(varchar,@EmpresaID))+',
			 '+rtrim(convert(varchar,@UnidadeID))+'
			from HADES.DADOSADV.dbo.SA2010 SA2_1 (NOLOCK)
			INNER JOIN 
			(
				SELECT DISTINCT E2_FORNECE, E2_LOJA FROM (
				
				SELECT E2_FORNECE, E2_LOJA
				FROM HADES.DADOSADV.dbo.SE2'+@Empresa+'0 SE2 (NOLOCK)
				WHERE 
					E2_FILIAL = '+@Filial+'
					AND E2_SALDO > 0
					AND D_E_L_E_T_ = ''''
					AND E2_TIPO IN (''NF'') 	
					AND E2_NUMBOR	= ''''
				UNION ALL
				select C7_FORNECE, C7_LOJA from HADES.DADOSADV.dbo.SC7'+@Empresa+'0 SC7 (NOLOCK)
				WHERE 
				SC7.C7_FILIAL = '+@Filial+'
				AND D_E_L_E_T_ = ''''
				AND SC7.C7_ENCER		= ''''                                                	
				AND SC7.C7_RESIDUO		<> ''S''                                              	
				AND SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA > 0                             	
				AND SC7.D_E_L_E_T_		= ''''    	
				) A 
			) SA2_2 ON SA2_1.A2_COD = SA2_2.E2_FORNECE AND SA2_1.A2_LOJA = SA2_2.E2_LOJA
			where 
			D_E_L_E_T_ = ''''
			and A2_MSBLQL <> ''1''
			and A2_TIPO = ''J''
			AND A2_COD NOT IN (''PIS'')
			and A2_CGC <> ''''
			and not exists (
				select 1 from Fornecedor t where CpfCnpj = RTRIM(A2_CGC) collate Latin1_General_BIN 
			)
	'

	--print @sql
	exec(@sql)
	
	
	fetch next from c_fornecedores into @Empresa, @Filial
end
close c_fornecedores
deallocate c_fornecedores
  

INSERT INTO #TEMP_FORNECEDOR(
	Codigo       	,
	Loja       		,
	CpfCnpj       	,	
	Nome 			,
	Email 			,
	EmailWorkflow	,
	Obs				,
	CEP 			,
	Logradouro		,
	Numero			,
	Complemento		,
	Bairro 			,
	UF 				,
	Cidade 			,
	Habilitado		,
	TipoAntecipacao ,
	Taxa		    ,
	EmpresaID		,
	UnidadeID				
)

SELECT 
	A2_COD,
	A2_LOJA,
	A2_CGC, 
	A2_NOME, 
	A2_EMAIL, 
	A2_YEMAFIN,	
	OBS = '',
	A2_CEP,
	A2_END,
	A2_NR_END,
	A2_COMPLEM,
	A2_BAIRRO,
	A2_EST,
	A2_MUN, 
	A2_MSBLQL,
	A2_YTPANTE,
	A2_YTXANTE,
	f.EmpresaID,
	f.UnidadeID				
	FROM HADES.DADOSADV.dbo.SA2010 SA2 (nolock)
	INNER JOIN Fornecedor f (nolock) on 
		f.CpfCnpj = RTRIM(A2_CGC) collate Latin1_General_BIN
	WHERE 
	D_E_L_E_T_ = ''
	and A2_MSBLQL <> '1'
	and A2_TIPO = 'J'
	AND A2_COD NOT IN ('PIS')
	and A2_CGC <> ''
	and not exists (select 1 from HADES.DADOSADV.dbo.SA2010 X (nolock) where RTRIM(X.A2_CGC) =  RTRIM(SA2.A2_CGC) and X.D_E_L_E_T_='' and X.A2_MSBLQL <> '1' and X.R_E_C_N_O_ > SA2.R_E_C_N_O_)
	and (
		RTRIM(f.Nome)				<>  RTRIM(A2_NOME)     collate Latin1_General_BIN
		or RTRIM(f.Logradouro)		<>  RTRIM(A2_END)   	collate Latin1_General_BIN
		or RTRIM(f.Numero)			<>  RTRIM(A2_NR_END)   collate Latin1_General_BIN
		or RTRIM(f.Complemento)		<>  RTRIM(A2_COMPLEM)  collate Latin1_General_BIN
		or RTRIM(f.Bairro)			<>  RTRIM(A2_BAIRRO)  	collate Latin1_General_BIN
		or RTRIM(f.UF)				<>  RTRIM(A2_EST) 	   collate Latin1_General_BIN
		or RTRIM(f.Cidade)			<>  RTRIM(A2_MUN) 	   collate Latin1_General_BIN
		or RTRIM(f.CEP)				<>  RTRIM(A2_CEP) 	   	collate Latin1_General_BIN
		or RTRIM(f.EmailWorkflow)	<>  RTRIM(A2_YEMAFIN) 	   collate Latin1_General_BIN
		or RTRIM(f.TipoAntecipacao)		<>  case when RTRIM(A2_YTPANTE) = 'A'  then 1 else 0 end
		or ROUND( CONVERT(decimal(14, 4),f.PercentualPorDia), 2)	<>  ROUND(CONVERT(decimal(14, 4), A2_YTXANTE), 2)
		or RTRIM(f.Habilitado)		<>  case when RTRIM(A2_MSBLQL) = '1' then 0 else 1 end
	)

--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(*) from #TEMP_FORNECEDOR)))
print 'processando: ' + @numrec + ' registros'


declare @ChaveUnica    	varchar(max)
declare @Codigo       	varchar(max)
declare @Loja       	varchar(max)
declare @CpfCnpj       	varchar(max)	
declare @Nome 			varchar(max)
declare @Email 			varchar(max)
declare @EmailWorkflow	varchar(max)
declare @Obs			varchar(max)
declare @CEP 			varchar(max)
declare @Logradouro		varchar(max)
declare @Numero			varchar(max)
declare @Complemento	varchar(max)
declare @Bairro 		varchar(max)
declare @UF 			varchar(max)
declare @Cidade 		varchar(max)
declare @Habilitado		varchar(max)
declare @TipoAntecipacao varchar(1)
declare	@Taxa		    decimal(30,8)
declare @EmpID 			bigint = 0
declare @UniID 			bigint = 0

declare cursor_fornecedores cursor fast_forward for
select * from #TEMP_FORNECEDOR 

open cursor_fornecedores
fetch next from cursor_fornecedores into
@Codigo       	,
@Loja			,
@CpfCnpj       	,	
@Nome 			,
@Email 			,
@EmailWorkflow	,
@Obs			,
@CEP 			,
@Logradouro		,
@Numero			,
@Complemento	,
@Bairro 		,
@UF 			,
@Cidade 		,
@Habilitado		,
@TipoAntecipacao,
@Taxa			,
@EmpID			,
@UniID					

while @@FETCH_STATUS = 0
begin

	If ((select COUNT(*) from HADES.DADOSADV.dbo.SA2010 nolock
			where A2_COD = @Codigo 
			and D_E_L_E_T_= ''
			and A2_MSBLQL <> '1'
			and A2_TIPO = 'J'
			and A2_CGC <> '') > 1)
	begin
		select @CpfCnpj=A2_CGC, @Loja=A2_LOJA  from HADES.DADOSADV.dbo.SA2010 nolock
			where A2_COD = @Codigo 
			and D_E_L_E_T_= ''
			and A2_MSBLQL <> '1'
			and A2_TIPO = 'J'
			and A2_LOJA = '01'
			and A2_CGC <> ''	
	End
	
	print 'processando: '+ @CpfCnpj
	
	SET @ChaveUnica = RTRIM(@CpfCnpj)
	
	if (not exists (select 1 from Fornecedor where ChaveUnica = @ChaveUnica ))
	begin

		print 'insert'
		
		insert into Fornecedor
		(
			[EmpresaID]
		   ,[UnidadeID]
		   ,[ChaveUnica]
		   ,[StatusIntegracao]
		   ,[CodigoERP]
		   ,[CPFCNPJ]
		   ,[Nome]
		   ,[Email]
		   ,[EmailWorkflow]
		   ,[Observacoes]
		   ,[CEP]
		   ,[Logradouro]
		   ,[Numero]
		   ,[Complemento]
		   ,[Bairro]
		   ,[UF]
		   ,[Cidade]
		   ,[Habilitado]
		   ,[TipoAntecipacao]
		   ,[PercentualPorDia]
		)

		select
		EmpresaID			= @EmpID,
		UnidadeID			= @UniID,
		ChaveUnica			= @ChaveUnica,
		StatusIntegracao	= 0,
		CodigoERP			= RTRIM(@Codigo),
		CpfCnpj				= RTRIM(@CpfCnpj),
		Nome 				= RTRIM(@Nome),
		Email				= RTRIM(@Email),
		EmailWorkflow		= RTRIM(@EmailWorkflow),
		Observacoes			= RTRIM(@Obs),
		CEP 				= RTRIM(@CEP),
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(@Numero),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end,
		TipoAntecipacao 	= case when @TipoAntecipacao = 'A' then 1 else 0 end,
		PercentualPorDia	= @Taxa	
		
	end
	else
	begin

		print 'update'
		
		update Fornecedor
		set	 		
		StatusIntegracao	= 0,
		ChaveUnica			= RTRIM(@CpfCnpj),
		CodigoERP			= RTRIM(@Codigo),
		CpfCnpj				= RTRIM(@CpfCnpj),
		Nome 				= RTRIM(@Nome),
		Email				= RTRIM(@Email),
		EmailWorkflow		= RTRIM(@EmailWorkflow),
		Observacoes			= RTRIM(@Obs),	
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(@Numero),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		CEP 				= RTRIM(@CEP),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end,
		TipoAntecipacao 	= case when @TipoAntecipacao = 'A' then 1 else 0 end,
		PercentualPorDia	= @Taxa	
		
		where ChaveUnica = @ChaveUnica

	end

	--next
	fetch next from cursor_fornecedores into
		@Codigo       	,
		@Loja			,
		@CpfCnpj       	,	
		@Nome 			,
		@Email 			,
		@EmailWorkflow	,
		@Obs			,
		@CEP 			,
		@Logradouro		,
		@Numero			,
		@Complemento	,
		@Bairro 		,
		@UF 			,
		@Cidade 		,
		@Habilitado		,
		@TipoAntecipacao,
		@Taxa			,
		@EmpID			,
		@UniID					

end
close cursor_fornecedores
deallocate cursor_fornecedores


end