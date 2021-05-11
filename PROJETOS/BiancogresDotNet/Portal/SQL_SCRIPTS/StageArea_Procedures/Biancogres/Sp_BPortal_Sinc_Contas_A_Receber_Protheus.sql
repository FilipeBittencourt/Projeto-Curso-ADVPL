alter procedure Sp_BPortal_Sinc_Contas_A_Receber_Protheus
with encryption
as
begin

set nocount on

declare @EmpresaID bigint = 2
declare @UnidadeID bigint = 4

if ( not (select OBJECT_ID('tempdb.dbo.#tmp_table')) is null ) drop table #tmp_table

--INSERIR NOVOS REGISTROS
;with t_boleto as (

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)),
		EMP_CGC = '02077546000176',
		COD_CEDENTE = RTRIM(E1_PORTADO)+RTRIM(E1_AGEDEP)+RTRIM(E1_CONTA)+'001',
		CHAVE = space(500),
		CODBANCO = E1_PORTADO,
		
		NUMDOC = E1_NUM+E1_PARCELA,
		CONTROLE = rtrim(convert(varchar, SE1.R_E_C_N_O_)),
		E1_NUMBCO,
		E1_EMISSAO, 
		E1_VENCREA,
		
		E1_VALOR,
		ACRESC = 0,  --regra de negocio
		ABATIM = 0, --regra de negocio
		E1_PORCJUR, 
		JUROSPORDIA = (E1_PORCJUR/ 100) * E1_SALDO, /* - ABATIM */ 
		E1_DECRESC, 
			
		A1_CGC
		
	FROM DADOSFACILE.dbo.SE1010 SE1 (NOLOCK)
	INNER JOIN DADOSFACILE.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = '  ' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA
	WHERE 
		E1_FILIAL = '01'
		AND SE1.E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') 	
		AND SE1.E1_YFORMA NOT IN ('3', '4')	
		AND SE1.E1_CLIENTE NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
		AND SE1.E1_YSITAPI <> '4'
		AND SE1.E1_SALDO > 0
		AND SE1.E1_PORTADO <> ''
		AND SE1.D_E_L_E_T_ = ''
		AND SA1.A1_EMAIL <> ''
		AND SA1.A1_CGC <> ''
		AND (len(RTRIM(SA1.A1_CGC)) = 11 or len(RTRIM(SA1.A1_CGC)) = 14)
)
,t_bol_pend as 
(
	select *
	from t_boleto tb
	where 
	not exists (select 1 from Boleto b where b.ChaveUnica = RTRIM(tb.CHAVE) collate Latin1_General_BIN )   --valida existe na Stage
	and exists (select 1 from Sacado s (nolock) where s.CPFCNPJ = RTRIM(tb.A1_CGC) collate Latin1_General_BIN )
)

select * 
into #tmp_table
from t_bol_pend

-----------INSERI REGISTROS ALTERADOS----------------------
INSERT INTO #tmp_table

	SELECT
		ROW = (ROW_NUMBER() OVER(ORDER BY SE1.R_E_C_N_O_ ASC)) + (select max(ROW) from #tmp_table),
		EMP_CGC = '02077546000176',
		COD_CEDENTE = RTRIM(E1_PORTADO)+RTRIM(E1_AGEDEP)+RTRIM(E1_CONTA)+'001',
		CHAVE = space(500),
		CODBANCO = E1_PORTADO,
		
		NUMDOC = E1_NUM+E1_PARCELA,
		CONTROLE = rtrim(convert(varchar, SE1.R_E_C_N_O_)),
		E1_NUMBCO,
		E1_EMISSAO, 
		E1_VENCREA,
		
		E1_VALOR,
		ACRESC = 0,  --regra de negocio
		ABATIM = 0, --regra de negocio
		E1_PORCJUR, 
		JUROSPORDIA = (E1_PORCJUR/ 100) * E1_SALDO, /* - ABATIM */ 
		E1_DECRESC, 
			
		A1_CGC
		
	FROM DADOSFACILE.dbo.SE1010 SE1 (NOLOCK)
	INNER JOIN DADOSFACILE.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = '  ' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA
	INNER JOIN Boleto bol on bol.EmpresaID = @EmpresaID and bol.ChaveUnica = RTRIM(E1_PORTADO)+RTRIM(E1_AGEDEP)+RTRIM(E1_CONTA)+'001'+E1_NUMBCO collate Latin1_General_BIN
	WHERE 
	
	(
		DataVencimento				<> convert(date, E1_VENCREA) or		
		ValorTitulo					<> E1_VALOR or
		--ValorOutrosAcrescimos		<> @ValorOutrosAcrescimos
		--ValorDesconto				<> @ValorDesconto
		PercentualJurosDia			<> E1_PORCJUR 
		--ValorJurosDia				<> @ValorJurosDia
	)



--select * from #tmp_table

--SETAR CHAVE UNICA DO REGISTRO 
UPDATE #tmp_table set CHAVE = COD_CEDENTE+E1_NUMBCO


--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(1) from #tmp_table)))
print 'processando: ' + @numrec + ' registros'

declare @ROW bigint
declare c_tabcursor cursor fast_forward for
select ROW from #tmp_table

open c_tabcursor
fetch next from c_tabcursor into @ROW


while @@FETCH_STATUS = 0
begin

	print 'proc row: '+ convert(varchar,@ROW)

	declare @ChaveUnica varchar(max) = (select CHAVE from #tmp_table where ROW = @ROW)
	declare @CodigoBanco varchar(3) = (select CODBANCO from #tmp_table where ROW = @ROW)
	declare @EmpCgc varchar(14) = (select EMP_CGC from #tmp_table where ROW = @ROW)
	declare @CodigoCedente varchar(max) = (select COD_CEDENTE from #tmp_table where ROW = @ROW)
	
	declare @Cgc varchar(14) = (select A1_CGC from #tmp_table where ROW = @ROW)

	declare @NumeroDocumento varchar(max) = (select NUMDOC from #tmp_table where ROW = @ROW)
	declare @NumeroControleParticipante varchar(max) = (select CONTROLE from #tmp_table where ROW = @ROW)
	declare @NossoNumero varchar(max) = (select E1_NUMBCO from #tmp_table where ROW = @ROW)

	declare @Emissao varchar(8) = (select E1_EMISSAO from #tmp_table where ROW = @ROW)
	declare @Vencimento varchar(8) = (select E1_VENCREA from #tmp_table where ROW = @ROW)

	declare @Valor decimal(30,8) = (select E1_VALOR from #tmp_table where ROW = @ROW)
	declare @ValorOutrosAcrescimos decimal(30,8) = (select ACRESC from #tmp_table where ROW = @ROW)
	declare @ValorDesconto decimal(30,8) = (select ABATIM from #tmp_table where ROW = @ROW)
	declare @PercentualJurosDia decimal(30,8) = (select E1_PORCJUR from #tmp_table where ROW = @ROW)
	declare @ValorJurosDia decimal(30,8) = (select JUROSPORDIA from #tmp_table where ROW = @ROW)

	if (not exists (select 1 from Boleto where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica))
	begin

		print 'insert'
		
		insert into Boleto (
		EmpresaID,
		UnidadeID,
		StatusIntegracao,
		CodigoBanco,
		Cedente_CPFCNPJ,
		Cedente_Codigo,	
		ChaveUnica,
		Sacado_CPFCNPJ,		
		NumeroDocumento,
		NumeroControleParticipante,
		NossoNumero,		
		DataEmissao,
		DataVencimento,		
		ValorTitulo,
		ValorOutrosAcrescimos,
		ValorDesconto,
		PercentualJurosDia,
		ValorJurosDia,		
		EspecieDocumento,		
		MensagemLivreLinha1,			
		MensagemLivreLinha2,			
		MensagemLivreLinha3
		)

		select		
		EmpresaID					= @EmpresaID,
		UnidadeID					= @UnidadeID,
		StatusIntegracao			= 0,

		CodigoBanco					= @CodigoBanco,
		Cedente_CPFCNPJ				= @EmpCgc,
		Cedente_Codigo				= @CodigoCedente,
		ChaveUnica					= @ChaveUnica,

		Sacado_CPFCNPJ				= @Cgc,
		
		NumeroDocumento				= @NumeroDocumento,
		NumeroControleParticipante	= @NumeroControleParticipante,
		NossoNumero					= @NossoNumero,
		
		DataEmissao					= convert(date, @Emissao),
		DataVencimento				= convert(date, @Vencimento),
		
		ValorTitulo					= @Valor,
		ValorOutrosAcrescimos		= @ValorOutrosAcrescimos,
		ValorDesconto				= @ValorDesconto,
		PercentualJurosDia			= @PercentualJurosDia,
		ValorJurosDia				= @ValorJurosDia,
		
		EspecieDocumento			= '00',
		MensagemLivreLinha1			= '',
		MensagemLivreLinha2			= '',
		MensagemLivreLinha3			= ''

	end
	else
	begin

		print 'update'

		update Boleto

		set
		StatusIntegracao			= 0,

		CodigoBanco					= @CodigoBanco,
		Cedente_CPFCNPJ				= @EmpCgc,
		Cedente_Codigo				= @CodigoCedente,
		ChaveUnica					= @ChaveUnica,

		Sacado_CPFCNPJ				= @Cgc,
		
		NumeroDocumento				= @NumeroDocumento,
		NumeroControleParticipante	= @NumeroControleParticipante,
		NossoNumero					= @NossoNumero,
		
		DataEmissao					= convert(date, @Emissao),
		DataVencimento				= convert(date, @Vencimento),
		
		ValorTitulo					= @Valor,
		ValorOutrosAcrescimos		= @ValorOutrosAcrescimos,
		ValorDesconto				= @ValorDesconto,
		PercentualJurosDia			= @PercentualJurosDia,
		ValorJurosDia				= @ValorJurosDia,
		
		EspecieDocumento			= '00',
		MensagemLivreLinha1			= '',
		MensagemLivreLinha2			= '',
		MensagemLivreLinha3			= ''
		
		where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica
		
	end

	fetch next from c_tabcursor into @ROW
end

close c_tabcursor
deallocate c_tabcursor

end