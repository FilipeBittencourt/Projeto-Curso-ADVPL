alter procedure Sp_BPortal_Atualiza_Contas_A_Receber_Protheus
with encryption
as
begin

set nocount on

declare @sql varchar(max)

if not (select Object_Id('tempdb.dbo.#tmp_tab_tiulos')) is null drop table dbo.#tmp_tab_tiulos

create table #tmp_tab_tiulos
(
	ROW int,
	EmpresaId bigint,
	ChaveTitulo varchar(max),
	Valor decimal(30,8),
	Vencimento Date,
	Recebimento Date null,
	Deletado int,
)

declare @Cedente_Empresa varchar(2)
declare @Cedente_CPFCNPJ varchar(max)
declare @Cedente_Codigo varchar(max)

declare c_cedentes cursor for

select '01', '02077546000176', '0013431255.097-3007' union all 
select '01', '02077546000176', '237351110.599-6001' union all
select '01', '02077546000176', '0215526.280.424001' union all
select '01', '02077546000176', '23735111422001' union all
select '07', '10524837000193', '0013431252868001' union all
select '07', '10524837000193', '2373511955001' union all
select '07', '10524837000193', '021055227978170001' union all
select '05', '04917232000160', '001343125.666-9003' union all
select '14', '08930868000100', '001343148755003' 


open c_cedentes
fetch next from c_cedentes into @Cedente_Empresa, @Cedente_CPFCNPJ, @Cedente_Codigo
while @@fetch_status = 0
begin

	print @Cedente_CPFCNPJ
	print @Cedente_Codigo

	declare @EmpresaID bigint = isnull((select EmpresaID from EmpresaInterface where ChaveUnica = @Cedente_CPFCNPJ),0)


	set @sql = '
	insert into #tmp_tab_tiulos (ROW, EmpresaId, ChaveTitulo, Valor, Vencimento, Recebimento, Deletado)

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #tmp_tab_tiulos),0),
		EmpresaId = '+rtrim(convert(varchar,@EmpresaID))+',
		ChaveTitulo = '''+@Cedente_Codigo+'''+RTRIM(E1_NUMBCO),
		Valor		= Round(E1_SALDO,2),
		Vencimento	= convert(date, E1_VENCTO),
		Recebimento	= case when E1_SALDO > 0 then null else convert(date, E1_BAIXA) end,
		Deletado	= 0			
		FROM DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN DADOSADV.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = ''  '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA  
		INNER JOIN Boleto bol (NOLOCK) on bol.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and bol.ChaveUnica = '''+@Cedente_Codigo+'''+RTRIM(E1_NUMBCO) collate Latin1_General_BIN
		and NumeroControleParticipante = convert(varchar(50), SE1.R_E_C_N_O_ )
		WHERE
		SE1.D_E_L_E_T_='' ''
		AND SE1.E1_TIPO IN (''NF'', ''FT'', ''BOL'', ''ST'') 
		AND SE1.E1_YFORMA NOT IN (''3'', ''4'')
		AND
		(
			convert(date,DataVencimento) <> convert(date, E1_VENCTO) or
			Round(ValorTitulo,2)		 <> Round(E1_SALDO,2) or
			(E1_SALDO <= 0 and DataRecebimento is null)
		)
		AND bol.StatusIntegracao <> 3
		AND bol.Deletado	= 0	
	'

	print @sql
	exec(@sql)

	--INSERINDO REGISTRO PELA CHAVE COM O CAMPO E1_YNUMBCO  - PR BOL ANTIGOS
	set @sql = '
	insert into #tmp_tab_tiulos (ROW, EmpresaId, ChaveTitulo, Valor, Vencimento, Recebimento, Deletado)

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #tmp_tab_tiulos),0),
		EmpresaId = '+rtrim(convert(varchar,@EmpresaID))+',
		ChaveTitulo = '''+@Cedente_Codigo+'''+RTRIM(E1_YNUMBCO),
		Valor		= Round(E1_SALDO,2),
		Vencimento	= convert(date, E1_VENCTO),
		Recebimento	= case when E1_SALDO > 0 then null else convert(date, E1_BAIXA) end,
		Deletado	= 0		
		FROM DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN DADOSADV.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = ''  '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA  
		INNER JOIN Boleto bol (NOLOCK) on bol.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and bol.ChaveUnica = '''+@Cedente_Codigo+'''+RTRIM(E1_YNUMBCO) collate Latin1_General_BIN
		and NumeroControleParticipante = convert(varchar(50), SE1.R_E_C_N_O_ ) 
		WHERE 
		SE1.D_E_L_E_T_='' ''
		AND SE1.E1_TIPO IN (''NF'', ''FT'', ''BOL'', ''ST'') 
		AND SE1.E1_YFORMA NOT IN (''3'', ''4'')
		AND
		(
			convert(date,DataVencimento) <> convert(date, E1_VENCTO) or
			Round(ValorTitulo,2)		 <> Round(E1_SALDO,2) or
			(E1_SALDO <= 0 and DataRecebimento is null)
		)
		AND bol.StatusIntegracao <> 3
		AND bol.Deletado	= 0
	'

	print @sql
	exec(@sql)
	
	
	--deletados
	set @sql = '
	insert into #tmp_tab_tiulos (ROW, EmpresaId, ChaveTitulo, Valor, Vencimento, Recebimento, Deletado)

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #tmp_tab_tiulos),0),
		EmpresaId = '+rtrim(convert(varchar,@EmpresaID))+',
		ChaveTitulo = '''+@Cedente_Codigo+'''+RTRIM(E1_NUMBCO),
		Valor		= Round(E1_SALDO,2),
		Vencimento	= convert(date, E1_VENCTO),
		Recebimento	= case when E1_SALDO > 0 then null else convert(date, E1_BAIXA) end,
		Deletado	= 1			
		FROM DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN DADOSADV.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = ''  '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA  
		INNER JOIN Boleto bol (NOLOCK) on bol.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and bol.ChaveUnica = '''+@Cedente_Codigo+'''+RTRIM(E1_NUMBCO) collate Latin1_General_BIN
		and NumeroControleParticipante = convert(varchar(50), SE1.R_E_C_N_O_ ) 
		WHERE
		SE1.D_E_L_E_T_=''*''
		AND Deletado	= 0		
		AND bol.StatusIntegracao <> 3
	'
	print @sql
	exec(@sql)
	
	--INSERINDO REGISTRO PELA CHAVE COM O CAMPO E1_YNUMBCO  - PR BOL ANTIGOS
	set @sql = '
	insert into #tmp_tab_tiulos (ROW, EmpresaId, ChaveTitulo, Valor, Vencimento, Recebimento, Deletado)

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)) + isnull((select max(ROW) from #tmp_tab_tiulos),0),
		EmpresaId = '+rtrim(convert(varchar,@EmpresaID))+',
		ChaveTitulo = '''+@Cedente_Codigo+'''+RTRIM(E1_YNUMBCO),
		Valor		= Round(E1_SALDO,2),
		Vencimento	= convert(date, E1_VENCTO),
		Recebimento	= case when E1_SALDO > 0 then null else convert(date, E1_BAIXA) end,
		Deletado	= 1		
		FROM DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN DADOSADV.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = ''  '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA 
		INNER JOIN Boleto bol (NOLOCK) on bol.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and bol.ChaveUnica = '''+@Cedente_Codigo+'''+RTRIM(E1_YNUMBCO) collate Latin1_General_BIN
		and NumeroControleParticipante = convert(varchar(50), SE1.R_E_C_N_O_ )
		WHERE 
		SE1.D_E_L_E_T_=''*''
		AND Deletado	= 0
		AND bol.StatusIntegracao <> 3
	'
	print @sql
	exec(@sql)
	
	
	set @sql = '
	insert into #tmp_tab_tiulos (ROW, EmpresaId, ChaveTitulo, Valor, Vencimento, Recebimento, Deletado)

	SELECT
		ROW = ID + isnull((select max(ROW) from #tmp_tab_tiulos),0),
		EmpresaId=EmpresaID,
		ChaveTitulo=ChaveUnica,
		Valor		= 0,
		DataVencimento,
		Recebimento	= GetDate(),
		Deletado	= 1		
		from Boleto bol (NOLOCK)
		
		WHERE 
		bol.DataRecebimento			is null 
		AND bol.Deletado			= 0
		and bol.EmpresaID 			= '+rtrim(convert(varchar,@EmpresaID))+'
		and bol.Cedente_Codigo		= '''+@Cedente_Codigo+'''
		and not exists 
		(
			SELECT
				1
				FROM DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
				WHERE
				'''+@Cedente_Codigo+'''+RTRIM(E1_NUMBCO) collate Latin1_General_BIN = bol.ChaveUnica 
				and NumeroControleParticipante = convert(varchar(50), SE1.R_E_C_N_O_ )
				and SE1.D_E_L_E_T_		= ''''
				--and SE1.E1_YNUMBCO		= ''''
				
		)

	'
	print @sql
	exec(@sql)

	
	--print @sql
	--exec(@sql)
	
	
	
	fetch next from c_cedentes into @Cedente_Empresa, @Cedente_CPFCNPJ, @Cedente_Codigo
end
close c_cedentes
deallocate c_cedentes

--select * from #tmp_tab_tiulos


--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(1) from #tmp_tab_tiulos)))
print 'processando: ' + @numrec + ' registros'

declare @ROW bigint
declare c_tabcursor cursor fast_forward for
select ROW from #tmp_tab_tiulos

open c_tabcursor
fetch next from c_tabcursor into @ROW

while @@fetch_status = 0
begin

	print 'proc row: '+ convert(varchar,@ROW)

	set @EmpresaID = (select EmpresaID from #tmp_tab_tiulos where ROW = @ROW)
	declare @ChaveUnica varchar(max) = (select ChaveTitulo from #tmp_tab_tiulos where ROW = @ROW)

	declare @Valor decimal(30,8) = (select Valor from #tmp_tab_tiulos where ROW = @ROW)
	declare @Vencimento date = (select Vencimento from #tmp_tab_tiulos where ROW = @ROW)
	declare @Recebimento date = (select Recebimento from #tmp_tab_tiulos where ROW = @ROW)
	declare @Deletado int = (select Deletado from #tmp_tab_tiulos where ROW = @ROW)
	
	print 'update '+@ChaveUnica
	print @Valor
	print @Vencimento
	print @Recebimento
	
	
	update Boleto

		set
		StatusIntegracao			= 0,

		DataVencimento				= convert(date, @Vencimento),
		DataRecebimento				= convert(date, @Recebimento),
		ValorTitulo					= @Valor,
		Deletado					= @Deletado,
		LastEditDate				= GetDate()
			
		where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica
		

	fetch next from c_tabcursor into @ROW
end

close c_tabcursor
deallocate c_tabcursor

end