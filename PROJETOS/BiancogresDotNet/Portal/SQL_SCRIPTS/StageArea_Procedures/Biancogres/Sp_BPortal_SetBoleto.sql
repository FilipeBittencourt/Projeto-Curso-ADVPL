alter procedure Sp_BPortal_SetBoleto
(
	@User varchar(max),
	@ChaveEmpresa varchar(max),
	@CodigoBanco varchar(3),
	@Cedente_CPFCNPJ varchar(max),
	@Cedente_Codigo varchar(max),
	@Sacado_CPFCNPJ varchar(max),		
	@NumeroDocumento varchar(max),
	@NumeroControleParticipante varchar(max),
	@NossoNumero varchar(max),
	@DataEmissao varchar(8),
	@DataVencimento varchar(8),
	@ValorTitulo decimal(30,8),
	@ValorOutrosAcrescimos decimal(30,8),
	@ValorDesconto decimal(30,8),
	@PercentualJurosDia decimal(30,8),
	@ValorJurosDia decimal(30,8),	
	@MensagemLivreLinha1 varchar(max),			
	@MensagemLivreLinha2 varchar(max),
	@MensagemLivreLinha3 varchar(max)
)
with encryption
as
begin

set nocount on

declare @out_result varchar(10)
declare @out_mensagem varchar(200)

declare @IdEmp bigint = isnull((select ID from EmpresaInterface where ChaveUnica = @ChaveEmpresa),0)

declare @EmpresaID bigint = isnull((select EmpresaID from EmpresaInterface where ID = @IdEmp),0)
declare @UnidadeID bigint = isnull((select UnidadeID from EmpresaInterface where ID = @IdEmp),0)

if (@EmpresaID <= 0 or @UnidadeID <= 0)
begin
	--print 'EMPRESA/UNIDADE NAO CONFIGURADA'
	set @out_result = 'ERRO'
	set @out_mensagem = 'EMPRESA/UNIDADE NAO CONFIGURADA - Chave: '+@ChaveEmpresa
	select RESULT = @out_result, MENSAGEM = @out_mensagem
	return
end

declare @ChaveTitulo varchar(max) = RTRIM(@Cedente_Codigo)+RTRIM(@NossoNumero)

--ADICIONAR TIPO AOS TITULOS RA e FATURA
if (@UnidadeID = 4)
begin

	if (select count(1) from HADES.DADOSADV.dbo.SE1010 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='') > 0
	begin
	
		set @NumeroDocumento = (select top 1 RTRIM(case when E1_TIPO = 'BOL' then 'PR' else E1_TIPO end)+'-'+RTRIM(E1_NUM)+RTRIM(E1_PARCELA) from HADES.DADOSADV.dbo.SE1010 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='')

	end

end
else if (@UnidadeID = 5)
begin

	if (select count(1) from HADES.DADOSADV.dbo.SE1070 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='') > 0
	begin
	
		set @NumeroDocumento = (select top 1 RTRIM(case when E1_TIPO = 'BOL' then 'PR' else E1_TIPO end)+'-'+RTRIM(E1_NUM)+RTRIM(E1_PARCELA) from HADES.DADOSADV.dbo.SE1070 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='')

	end

end
else if (@UnidadeID = 6)
begin

	if (select count(1) from HADES.DADOSADV.dbo.SE1050 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='') > 0
	begin
	
		set @NumeroDocumento = (select top 1 RTRIM(case when E1_TIPO = 'BOL' then 'PR' else E1_TIPO end)+'-'+RTRIM(E1_NUM)+RTRIM(E1_PARCELA) from HADES.DADOSADV.dbo.SE1050 SE1 where SE1.R_E_C_N_O_ = @NumeroControleParticipante and SE1.E1_TIPO in ('BOL','FT') and SE1.D_E_L_E_T_='')

	end

end

	
if (not exists (select 1 from Boleto where EmpresaID = @EmpresaID and ChaveUnica = @ChaveTitulo))
begin

	print 'insert'
		
	insert into Boleto (
	EmpresaID,
	UnidadeID,
	InsertDate,
	InsertUser,
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
	InsertDate					= GetDate(),
	InsertUser					= @User,
	StatusIntegracao			= 0,

	CodigoBanco					= @CodigoBanco,
	Cedente_CPFCNPJ				= @Cedente_CPFCNPJ,
	Cedente_Codigo				= @Cedente_Codigo,
	ChaveUnica					= @ChaveTitulo,

	Sacado_CPFCNPJ				= @Sacado_CPFCNPJ,
		
	NumeroDocumento				= @NumeroDocumento,
	NumeroControleParticipante	= @NumeroControleParticipante,
	NossoNumero					= @NossoNumero,
		
	DataEmissao					= convert(date, @DataEmissao),
	DataVencimento				= convert(date, @DataVencimento),
		
	ValorTitulo					= @ValorTitulo,
	ValorOutrosAcrescimos		= @ValorOutrosAcrescimos,
	ValorDesconto				= @ValorDesconto,
	PercentualJurosDia			= @PercentualJurosDia,
	ValorJurosDia				= @ValorJurosDia,
		
	EspecieDocumento			= '00',
	MensagemLivreLinha1			= @MensagemLivreLinha1,
	MensagemLivreLinha2			= @MensagemLivreLinha2,
	MensagemLivreLinha3			= @MensagemLivreLinha3


	If (@@ROWCOUNT = 0)
	begin
		set @out_result = 'ERRO'
		set @out_mensagem = 'ERRO inserindo linha na stage area - Boleto: '+@ChaveTitulo
	end
	Else
	begin
		set @out_result = 'Ok'
		set @out_mensagem = 'Insert Ok - Boleto: '+@ChaveTitulo
	end

end
else
begin

	print 'update'

	update Boleto

	set
	LastEditDate				= GetDate(),
	LastEditUser				= @User,
	StatusIntegracao			= 0,

	CodigoBanco					= @CodigoBanco,
	Cedente_CPFCNPJ				= @Cedente_CPFCNPJ,
	Cedente_Codigo				= @Cedente_Codigo,
	ChaveUnica					= @ChaveTitulo,

	Sacado_CPFCNPJ				= @Sacado_CPFCNPJ,
		
	NumeroDocumento				= @NumeroDocumento,
	NumeroControleParticipante	= @NumeroControleParticipante,
	NossoNumero					= @NossoNumero,
		
	DataEmissao					= convert(date, @DataEmissao),
	DataVencimento				= convert(date, @DataVencimento),
		
	ValorTitulo					= @ValorTitulo,
	ValorOutrosAcrescimos		= @ValorOutrosAcrescimos,
	ValorDesconto				= @ValorDesconto,
	PercentualJurosDia			= @PercentualJurosDia,
	ValorJurosDia				= @ValorJurosDia,
		
	EspecieDocumento			= '00',
	MensagemLivreLinha1			= @MensagemLivreLinha1,
	MensagemLivreLinha2			= @MensagemLivreLinha2,
	MensagemLivreLinha3			= @MensagemLivreLinha3
		
	where EmpresaID = @EmpresaID and ChaveUnica = @ChaveTitulo


	If (@@ROWCOUNT = 0)
	begin
		set @out_result = 'ERRO'
		set @out_mensagem = 'ERRO atualizando linha na stage area - Boleto: '+@ChaveTitulo
	end
	Else
	begin
		set @out_result = 'OK'
		set @out_mensagem = 'Update Ok - Boleto: '+@ChaveTitulo
	end
		
end

	select RESULT = @out_result, MENSAGEM = @out_mensagem

end