
alter procedure Sp_BPortal_Sinc_Atendimento_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#Temp_Table')) is null ) drop table #Temp_Table


create table #Temp_Table
(
	NumeroControleParticipante	varchar(max),
	FornecedorCPFCNPJ       	varchar(max),
	NumeroContrato       		varchar(max),
	Item				       	varchar(max),	
	CodigoProduto 				varchar(max),
	NomeProduto		 			varchar(max),
	QuantidadeProduto			numeric(14,2),
	Contato						varchar(max),
	Email			 			varchar(max),
	Observacao					varchar(max),
	DataLiberacao				varchar(max),
	EmpresaID 					bigint,
	UnidadeID 					bigint,
	Deletado					int,
	NomeReclamante				varchar(max),
	CepReclamante				varchar(max),
	EnderecoReclamante			varchar(max),
	EstadoReclamante			varchar(max),
	BairroReclamante			varchar(max),
	CidadeReclamante			varchar(max),
	TelefoneReclamante			varchar(max),
	ContatoReclamante			varchar(max),
	HorarioContatoReclamante	varchar(max),
	Numero						varchar(max),
	ValorProduto				numeric(14,2),
	Termo						varbinary(max)
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

	SET @EmpresaID = isnull((select TOP 1 EmpresaID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)
	SET @UnidadeID = isnull((select TOP 1 UnidadeID from EmpresaInterface where CodEmpresaERP = @Empresa And CodUnidadeERP = @Filial),0)

	
	set @sql = '
	insert into 
	#Temp_Table (	
		NumeroControleParticipante	,
		FornecedorCPFCNPJ			,
		NumeroContrato      		,
		Item						,
		CodigoProduto 				,
		NomeProduto					,
		QuantidadeProduto			,
		Contato						,
		Email			 			,
		Observacao					,
		DataLiberacao				,
		EmpresaID 					,
		UnidadeID 					,
		Deletado					,
		NomeReclamante				,
		CepReclamante				,
		EnderecoReclamante			,
		EstadoReclamante			,
		BairroReclamante			,
		CidadeReclamante			,
		TelefoneReclamante			,
		ContatoReclamante			,
		HorarioContatoReclamante	,
		Numero						,
		ValorProduto				,
		Termo
	)

	select  
					PRE_AE.ID,	
				 A2_CGC,
				 C3_NUM,
				 PRE_AE.ITEM, 
				 PRE_AE.COD_PRODUTO, 
				 PRE_AE.NOME_PRODUTO,
				 PRE_AE.QUANT,
				 PRE_AE.CONTATO,
				 PRE_AE.EMAIL,
				 PRE_AE.OBSERVACAO,
				 PRE_AE.DATA_LIBERACAO,
				'+rtrim(convert(varchar,@EmpresaID))+',
				'+rtrim(convert(varchar,@UnidadeID))+',
				0,
				 PRE_AE.NOME_RECLAMANTE,
				 PRE_AE.CEP_RECLAMANTE,
				 PRE_AE.ENDERECO_RECLAMANTE,
				 PRE_AE.ESTADO_RECLAMANTE,
				 PRE_AE.BAIRRO_RECLAMANTE,
				 PRE_AE.CIDADE_RECLAMANTE,
				 PRE_AE.TELEFONE_RECLAMANTE,
				 PRE_AE.CONTATO_RECLAMANTE,
				 PRE_AE.HORARIO_CONTATO_RECLAMANTE,
				 PRE_AE.BZ_NUM_PROC,
				 PRE_AE.VALOR,
				 PRE_AE.TERMO
				from DADOSADV.dbo.BZINTEGRACAO_PREAE PRE_AE WITH (nolock)
				INNER JOIN DADOSADV.dbo.SC3010 SC3  WITH (nolock) ON 
					PRE_AE.CONTRATO			= SC3.C3_NUM 
					AND PRE_AE.ITEM 		= SC3.C3_ITEM 
					AND PRE_AE.COD_PRODUTO	= SC3.C3_PRODUTO
					AND SC3.D_E_L_E_T_ 		= ''''
				INNER JOIN DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_COD+A2_LOJA = C3_FORNECE+C3_LOJA AND SA2.D_E_L_E_T_ = ''''
				WHERE 1=1
				and not exists (
				select 1 from Atendimento t where ChaveUnica = RTRIM(PRE_AE.ID) collate Latin1_General_BIN
				)
	'

	--print @sql
	exec(@sql)
	

	
	fetch next from c_table into @Empresa, @Filial
end
close c_table
deallocate c_table
  

INSERT INTO #Temp_Table(
	NumeroControleParticipante	,
	FornecedorCPFCNPJ			,
	NumeroContrato      		,
	Item						,
	CodigoProduto 				,
	NomeProduto					,
	QuantidadeProduto			,
	Contato						,
	Email			 			,
	Observacao					,
	DataLiberacao				,
	EmpresaID 					,
	UnidadeID 					,
	Deletado					,
	NomeReclamante				,
	CepReclamante				,
	EnderecoReclamante			,
	EstadoReclamante			,
	BairroReclamante			,
	CidadeReclamante			,
	TelefoneReclamante			,
	ContatoReclamante			,
	HorarioContatoReclamante	,
	Numero						,
	ValorProduto				,
	Termo
)


select  
			 PRE_AE.ID,	
			 A2_CGC,
			 C3_NUM,
			 PRE_AE.ITEM, 
			 PRE_AE.COD_PRODUTO, 
			 PRE_AE.NOME_PRODUTO,
			 PRE_AE.QUANT,
			 PRE_AE.CONTATO,
			 PRE_AE.EMAIL,
			 PRE_AE.OBSERVACAO,
			  PRE_AE.DATA_LIBERACAO,
			 f.EmpresaID,
			 f.UnidadeID,		
			 0,
			 PRE_AE.NOME_RECLAMANTE,
			 PRE_AE.CEP_RECLAMANTE,
			 PRE_AE.ENDERECO_RECLAMANTE,
			 PRE_AE.ESTADO_RECLAMANTE,
			 PRE_AE.BAIRRO_RECLAMANTE,
			 PRE_AE.CIDADE_RECLAMANTE,
			 PRE_AE.TELEFONE_RECLAMANTE,
			 PRE_AE.CONTATO_RECLAMANTE,
			 PRE_AE.HORARIO_CONTATO_RECLAMANTE,
			 PRE_AE.BZ_NUM_PROC,
			 PRE_AE.VALOR,
			 PRE_AE.TERMO
			from DADOSADV.dbo.BZINTEGRACAO_PREAE PRE_AE WITH (nolock)
			INNER JOIN DADOSADV.dbo.SC3010 SC3  WITH (nolock) ON 
					PRE_AE.CONTRATO			= SC3.C3_NUM 
					AND PRE_AE.ITEM 		= SC3.C3_ITEM 
					AND PRE_AE.COD_PRODUTO	= SC3.C3_PRODUTO
					AND SC3.D_E_L_E_T_ 		= ''
			INNER JOIN DADOSADV.dbo.SA2010 SA2  WITH (nolock) ON A2_COD+A2_LOJA = C3_FORNECE+C3_LOJA AND SA2.D_E_L_E_T_ = ''
			INNER JOIN Atendimento f WITH (nolock) on f.ChaveUnica = RTRIM(PRE_AE.ID) collate Latin1_General_BIN
			WHERE 1=1
			and (
				RTRIM(f.CodigoProduto)				<>  RTRIM(COD_PRODUTO)     	collate Latin1_General_BIN
				or RTRIM(f.NomeProduto)				<>  RTRIM(NOME_PRODUTO)   	collate Latin1_General_BIN
				or RTRIM(f.Termo)					<>  RTRIM(PRE_AE.TERMO)   	collate Latin1_General_BIN
				
			)


--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(*) from #Temp_Table)))
print 'processando: ' + @numrec + ' registros'


declare @ChaveUnica    				varchar(max)
declare @FornecedorCPFCNPJ       	varchar(max)
declare @NumeroContrato       		varchar(max)
declare @Item				       	varchar(max)	
declare @CodigoProduto 				varchar(max)
declare @NomeProduto		 		varchar(max)
declare @QuantidadeProduto			numeric(14,2)
declare @Contato					varchar(max)
declare @Email			 			varchar(max)
declare @Observacao					varchar(max)
declare @DataLiberacao				varchar(max)
declare @EmpID 						bigint = 0
declare @UniID 						bigint = 0
declare @Deletado					int
declare @NomeReclamante				varchar(max)
declare @CepReclamante				varchar(max)
declare @EnderecoReclamante			varchar(max)
declare @EstadoReclamante			varchar(max)
declare @BairroReclamante			varchar(max)
declare @CidadeReclamante			varchar(max)
declare @TelefoneReclamante			varchar(max)
declare @ContatoReclamante			varchar(max)
declare @HorarioContatoReclamante	varchar(max)
declare @Numero					  	varchar(max)
declare @ValorProduto				numeric(14,2)
declare @Termo						varbinary(max)

declare cursor_registros cursor fast_forward for
select 
	NumeroControleParticipante	,
	FornecedorCPFCNPJ			,
	NumeroContrato      		,
	Item						,
	CodigoProduto 				,
	NomeProduto					,
	QuantidadeProduto			,
	Contato						,
	Email			 			,
	Observacao					,
	DataLiberacao				,
	EmpresaID 					,
	UnidadeID 					,
	Deletado					,
	NomeReclamante				,
	CepReclamante				,
	EnderecoReclamante			,
	EstadoReclamante			,
	BairroReclamante			,
	CidadeReclamante			,
	TelefoneReclamante			,
	ContatoReclamante			,
	HorarioContatoReclamante	,
	Numero						,
	ValorProduto				,
	Termo

 from #Temp_Table 

open cursor_registros
fetch next from cursor_registros into
@ChaveUnica       				,
@FornecedorCPFCNPJ				,
@NumeroContrato       			,	
@Item 							,
@CodigoProduto 					,
@NomeProduto 					,
@QuantidadeProduto				,
@Contato						,
@Email 							,
@Observacao						,
@DataLiberacao					,
@EmpID							,
@UniID							,
@Deletado						,
@NomeReclamante					,
@CepReclamante					,
@EnderecoReclamante				,
@EstadoReclamante				,
@BairroReclamante				,
@CidadeReclamante				,
@TelefoneReclamante				,
@ContatoReclamante				,
@HorarioContatoReclamante		,
@Numero							,
@ValorProduto					,
@Termo

while @@FETCH_STATUS = 0
begin

	print 'processando: '+ @ChaveUnica
	
	if (not exists (select 1 from Atendimento where ChaveUnica = @ChaveUnica ))
	begin

		print 'insert'
		
		
		INSERT INTO [dbo].[Atendimento]
           ([ChaveUnica]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[StatusIntegracao]
           ,[FornecedorCPFCNPJ]
           ,[NumeroContrato]
           ,[Item]
           ,[CodigoProduto]
           ,[NomeProduto]
           ,[QuantidadeProduto]
           ,[Contato]
           ,[Email]
           ,[Observacao]
           ,[DataLiberacao]
           ,[NumeroControleParticipante]
           ,[Deletado]
           ,[Status]
		   ,[NomeReclamante]
		,[CepReclamante]
		,[EnderecoReclamante]
		,[EstadoReclamante]
		,[BairroReclamante]
		,[CidadeReclamante]
		,[TelefoneReclamante]
		,[ContatoReclamante]
		,[HorarioContatoReclamante]
		,[Numero]
		,[ValorProduto]
		,[Termo])
		   
		select
		ChaveUnica						= @ChaveUnica,
		EmpresaID						= @EmpID,
		UnidadeID						= @UniID,
		StatusIntegracao				= 0,
		FornecedorCPFCNPJ				= RTRIM(@FornecedorCPFCNPJ),
		NumeroContrato					= RTRIM(@NumeroContrato),
		Item 							= RTRIM(@Item),
		CodigoProduto					= RTRIM(@CodigoProduto),
		NomeProduto						= RTRIM(@NomeProduto),
		QuantidadeProduto				= @QuantidadeProduto,
		Contato							= RTRIM(@Contato),
		Email 							= RTRIM(@Email),
		Observacao						= RTRIM(@Observacao),
		DataLiberacao					= convert(date, @DataLiberacao),
		NumeroControleParticipante 		= RTRIM(@ChaveUnica),
		Deletado 						= @Deletado,
		Status							= 0,
		NomeReclamante					= RTRIM(@NomeReclamante),					
		CepReclamante					= RTRIM(@CepReclamante),					
		EnderecoReclamante				= RTRIM(@EnderecoReclamante),				
		EstadoReclamante				= RTRIM(@EstadoReclamante),				
		BairroReclamante				= RTRIM(@BairroReclamante),				
		CidadeReclamante				= RTRIM(@CidadeReclamante),				
		TelefoneReclamante				= RTRIM(@TelefoneReclamante),				
		ContatoReclamante				= RTRIM(@ContatoReclamante),				
		HorarioContatoReclamante		= RTRIM(@HorarioContatoReclamante)	,
		Numero							= RTRIM(@Numero)	,
		ValorProduto					= (case when @ValorProduto is null then 0 else @ValorProduto end),
		Termo							= @Termo			
	end
	else
	begin

		print 'update'
		
		update [dbo].[Atendimento]
		set	 		
		
		StatusIntegracao				= 0,
		FornecedorCPFCNPJ				= RTRIM(@FornecedorCPFCNPJ),
		NumeroContrato					= RTRIM(@NumeroContrato),
		Item 							= RTRIM(@Item),
		CodigoProduto					= RTRIM(@CodigoProduto),
		NomeProduto						= RTRIM(@NomeProduto),
		QuantidadeProduto				= @QuantidadeProduto,
		Contato							= RTRIM(@Contato),
		Email 							= RTRIM(@Email),
		Observacao						= RTRIM(@Observacao),
		DataLiberacao					= convert(date, @DataLiberacao),
		NumeroControleParticipante 		= RTRIM(@ChaveUnica),
		Deletado 						= @Deletado,
		NomeReclamante					= RTRIM(@NomeReclamante),					
		CepReclamante					= RTRIM(@CepReclamante),					
		EnderecoReclamante				= RTRIM(@EnderecoReclamante),				
		EstadoReclamante				= RTRIM(@EstadoReclamante),				
		BairroReclamante				= RTRIM(@BairroReclamante),				
		CidadeReclamante				= RTRIM(@CidadeReclamante),				
		TelefoneReclamante				= RTRIM(@TelefoneReclamante),				
		ContatoReclamante				= RTRIM(@ContatoReclamante),				
		HorarioContatoReclamante		= RTRIM(@HorarioContatoReclamante),	
		Numero							= RTRIM(@Numero),
		ValorProduto					= (case when @ValorProduto is null then 0 else @ValorProduto end) ,
		Termo							= @Termo	
			
		where ChaveUnica = @ChaveUnica

	end

	--next
	fetch next from cursor_registros into
		@ChaveUnica       				,
		@FornecedorCPFCNPJ				,
		@NumeroContrato       			,			
		@Item 							,
		@CodigoProduto 					,
		@NomeProduto 					,
		@QuantidadeProduto				,
		@Contato						,
		@Email 							,
		@Observacao						,
		@DataLiberacao					,
		@EmpID							,
		@UniID							,
		@Deletado						,
		@NomeReclamante					,
		@CepReclamante					,
		@EnderecoReclamante				,
		@EstadoReclamante				,
		@BairroReclamante				,
		@CidadeReclamante				,
		@TelefoneReclamante				,
		@ContatoReclamante				,
		@HorarioContatoReclamante	    ,
		@Numero							,
		@ValorProduto					,
		@Termo

end
close cursor_registros
deallocate cursor_registros


end