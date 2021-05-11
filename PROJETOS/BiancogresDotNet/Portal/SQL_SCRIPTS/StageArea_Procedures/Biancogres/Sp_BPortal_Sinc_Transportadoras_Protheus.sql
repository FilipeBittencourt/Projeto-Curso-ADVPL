
alter procedure Sp_BPortal_Sinc_Transportadores_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#Temp_Table')) is null ) drop table #Temp_Table



create table #Temp_Table
(
	Codigo       	varchar(max),
	Loja       		varchar(max),
	CpfCnpj       	varchar(max),	
	Nome 			varchar(max),
	Email 			varchar(max),
	Obs				varchar(max),
	CEP 			varchar(max),
	Logradouro		varchar(max),
	Numero			varchar(max),
	Complemento		varchar(max),
	Bairro 			varchar(max),
	UF 				varchar(max),
	Cidade 			varchar(max),
	Habilitado		varchar(max),
	EmpresaID 		bigint,
	UnidadeID 		bigint	
)

declare @EmpresaID bigint = 0
declare @UnidadeID bigint = 0
declare @Empresa varchar(2)
declare @Filial varchar(max)
declare @sql varchar(max)

declare c_table cursor for

select '01', '01' 

open c_table
fetch next from c_table into @Empresa, @Filial
while @@fetch_status = 0
begin

	SET @EmpresaID = isnull((select EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	
	set @sql = '
	insert into 
	#Temp_Table (	
	
	Codigo       	,
	Loja       		,
	CpfCnpj       	,	
	Nome 			,
	Email 			,
	Obs				,
	CEP 			,
	Logradouro		,
	Numero			,
	Complemento		,
	Bairro 			,
	UF 				,
	Cidade 			,
	Habilitado		,
	EmpresaID		,
	UnidadeID								
	)

	select  
			 A4_COD	,
			 '''',
			 A4_CGC, 
			 A4_NOME, 
			 A4_EMAIL, 
			 OBS='''',
			 A4_CEP,
			 A4_END,
			 '''',
			 A4_COMPLEM,
			 A4_BAIRRO,
			 A4_EST,
			 A4_MUN,
			 A4_MSBLQL,
			 '+rtrim(convert(varchar,@EmpresaID))+',
			 '+rtrim(convert(varchar,@UnidadeID))+'
			from HADES.DADOSADV.dbo.SA4010 SA4_1 (NOLOCK)
			WHERE
			D_E_L_E_T_ = ''''
			and A4_MSBLQL <> ''1''
			and A4_CGC <> ''''
			and LEN(RTRIM(A4_CGC)) = 14
			and not exists (
				select 1 from Transportadora t where CpfCnpj = RTRIM(A4_CGC) collate Latin1_General_BIN 
			)
	'

	--print @sql
	exec(@sql)
	
	
	fetch next from c_table into @Empresa, @Filial
end
close c_table
deallocate c_table
  

INSERT INTO #Temp_Table(
	Codigo       	,
	Loja       		,
	CpfCnpj       	,	
	Nome 			,
	Email 			,
	Obs				,
	CEP 			,
	Logradouro		,
	Numero			,
	Complemento		,
	Bairro 			,
	UF 				,
	Cidade 			,
	Habilitado		,
	EmpresaID		,
	UnidadeID				
)

SELECT 
	A4_COD,
	'',
	A4_CGC, 
	A4_NOME, 
	A4_EMAIL, 
	OBS = '',
	A4_CEP,
	A4_END,
	'',
	A4_COMPLEM,
	A4_BAIRRO,
	A4_EST,
	A4_MUN, 
	A4_MSBLQL,
	f.EmpresaID,
	f.UnidadeID				
	FROM HADES.DADOSADV.dbo.SA4010 SA4 (nolock)
	INNER JOIN Transportadora f (nolock) on f.CpfCnpj = RTRIM(A4_CGC) collate Latin1_General_BIN
	WHERE 
	D_E_L_E_T_ = ''
	and A4_MSBLQL <> '1'
	and A4_CGC <> ''
	and LEN(RTRIM(A4_CGC)) = 14
	and not exists (select 1 from HADES.DADOSADV.dbo.SA4010 X (nolock) where RTRIM(X.A4_CGC) =  RTRIM(SA4.A4_CGC) and X.D_E_L_E_T_='' and X.A4_MSBLQL <> '1' and X.R_E_C_N_O_ > SA4.R_E_C_N_O_)
	and (
		RTRIM(f.Nome)				<>  RTRIM(A4_NOME)     collate Latin1_General_BIN
		or RTRIM(f.Logradouro)		<>  RTRIM(A4_END)   	collate Latin1_General_BIN
		or RTRIM(f.Complemento)		<>  RTRIM(A4_COMPLEM)  collate Latin1_General_BIN
		or RTRIM(f.Bairro)			<>  RTRIM(A4_BAIRRO)  	collate Latin1_General_BIN
		or RTRIM(f.UF)				<>  RTRIM(A4_EST) 	   collate Latin1_General_BIN
		or RTRIM(f.Cidade)			<>  RTRIM(A4_MUN) 	   collate Latin1_General_BIN
		or RTRIM(f.CEP)				<>  RTRIM(A4_CEP) 	   	collate Latin1_General_BIN
		or RTRIM(f.Habilitado)		<>  case when RTRIM(A4_MSBLQL) = '1' then 0 else 1 end
	)

--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(*) from #Temp_Table)))
print 'processando: ' + @numrec + ' registros'


declare @ChaveUnica    	varchar(max)
declare @Codigo       	varchar(max)
declare @Loja       	varchar(max)
declare @CpfCnpj       	varchar(max)	
declare @Nome 			varchar(max)
declare @Email 			varchar(max)
declare @Obs			varchar(max)
declare @CEP 			varchar(max)
declare @Logradouro		varchar(max)
declare @Numero			varchar(max)
declare @Complemento	varchar(max)
declare @Bairro 		varchar(max)
declare @UF 			varchar(max)
declare @Cidade 		varchar(max)
declare @Habilitado		varchar(max)
declare @EmpID 			bigint = 0
declare @UniID 			bigint = 0

declare cursor_registros cursor fast_forward for
select * from #Temp_Table 

open cursor_registros
fetch next from cursor_registros into
@Codigo       	,
@Loja			,
@CpfCnpj       	,	
@Nome 			,
@Email 			,
@Obs			,
@CEP 			,
@Logradouro		,
@Numero			,
@Complemento	,
@Bairro 		,
@UF 			,
@Cidade 		,
@Habilitado		,
@EmpID			,
@UniID					

while @@FETCH_STATUS = 0
begin

	print 'processando: '+ @CpfCnpj
	
	SET @ChaveUnica = RTRIM(@CpfCnpj)
	
	if (not exists (select 1 from Transportadora where ChaveUnica = @ChaveUnica ))
	begin

		print 'insert'
		
		insert into Transportadora
		(
			[EmpresaID]
		   ,[UnidadeID]
		   ,[ChaveUnica]
		   ,[StatusIntegracao]
		   ,[CodigoERP]
		   ,[CPFCNPJ]
		   ,[Nome]
		   ,[Email]
		   ,[Observacoes]
		   ,[CEP]
		   ,[Logradouro]
		   ,[Numero]
		   ,[Complemento]
		   ,[Bairro]
		   ,[UF]
		   ,[Cidade]
		   ,[Habilitado]
		   ,[CriarUsuario]
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
		Observacoes			= RTRIM(@Obs),
		CEP 				= RTRIM(@CEP),
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(@Numero),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end,
		CriarUsuario		= 0
	end
	else
	begin

		print 'update'
		
		update Transportadora
		set	 		
		StatusIntegracao	= 0,
		ChaveUnica			= RTRIM(@CpfCnpj),
		CodigoERP			= RTRIM(@Codigo),
		CpfCnpj				= RTRIM(@CpfCnpj),
		Nome 				= RTRIM(@Nome),
		Email				= RTRIM(@Email),
		Observacoes			= RTRIM(@Obs),	
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(@Numero),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		CEP 				= RTRIM(@CEP),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end
			
		where ChaveUnica = @ChaveUnica

	end

	--next
	fetch next from cursor_registros into
		@Codigo       	,
		@Loja			,
		@CpfCnpj       	,	
		@Nome 			,
		@Email 			,
		@Obs			,
		@CEP 			,
		@Logradouro		,
		@Numero			,
		@Complemento	,
		@Bairro 		,
		@UF 			,
		@Cidade 		,
		@Habilitado		,
		@EmpID			,
		@UniID					

end
close cursor_registros
deallocate cursor_registros


end