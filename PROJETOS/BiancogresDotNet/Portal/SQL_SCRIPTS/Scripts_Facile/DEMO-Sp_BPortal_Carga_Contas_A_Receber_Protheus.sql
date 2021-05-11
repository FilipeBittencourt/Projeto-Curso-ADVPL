alter procedure Sp_BPortal_Carga_Contas_A_Receber_Protheus
with encryption
as
begin

set nocount on

declare @sql varchar(max)

if not (select Object_Id('dbo.#tmp_tab_tiulos')) is null drop table dbo.#tmp_tab_tiulos

create table #tmp_tab_tiulos
(
	BoletoID bigint,
	NossoNumero varchar(20),
	Cedente_CNPJ bigint,
	TipoTitulo varchar(3),
	SaldoTitulo decimal(30,2),
	Vencimento date,
)

declare @Cedente_Empresa varchar(2)
declare @Cedente_CPFCNPJ varchar(max)
declare @Cedente_Codigo varchar(max)

declare c_cedentes cursor for

select '01', '11790500000190', '0019999999999001' 


declare @ApiEmpresaID bigint = 2

open c_cedentes
fetch next from c_cedentes into @Cedente_Empresa, @Cedente_CPFCNPJ, @Cedente_Codigo
while @@fetch_status = 0
begin

	print @Cedente_CPFCNPJ
	print @Cedente_Codigo

	declare @EmpresaID bigint = isnull((select EmpresaID from EmpresaInterface where ChaveUnica = @Cedente_CPFCNPJ),0)


	set @sql = '
	insert into #tmp_tab_tiulos (BoletoID, NossoNumero, Cedente_CNPJ, TipoTitulo, SaldoTitulo, Vencimento)
	
	SELECT
		BoletoID = bol.ID,
		NossoNumero = RTRIM(E1_NUMBCO),
		Cedente_CNPJ = '''+@Cedente_CPFCNPJ+''',
		TipoTitulo = RTRIM(SE1.E1_TIPO),
		SaldoTitulo = ROUND(SE1.E1_SALDO,2),
		Vencimento = convert(date, SE1.E1_VENCREA)
		FROM P12AUT.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN P12AUT.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = '' '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA
		INNER JOIN Sacado sacportal on sacportal.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and RTRIM(sacportal.CPFCNPJ) = RTRIM(SA1.A1_CGC) collate Latin1_General_BIN
	
		WHERE 
			E1_SALDO > 0
			and SE1.D_E_L_E_T_='' ''
	'

	print @sql
	exec(@sql)


	fetch next from c_cedentes into @Cedente_Empresa, @Cedente_CPFCNPJ, @Cedente_Codigo
end
close c_cedentes
deallocate c_cedentes

--select * from #tmp_tab_tiulos
--return

--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(1) from #tmp_tab_tiulos)))
print 'processando: ' + @numrec + ' registros'

declare @ROW bigint
declare @NossoNumero varchar(20)
declare @TipoTitulo varchar(3)
declare @SaldoTitulo decimal(30,2)
declare @Vencimento date
declare @ApiUnidadeID bigint

declare c_tabcursor cursor fast_forward for
select ROW = BoletoID,
NossoNumero,
CNPJ = Cedente_CNPJ,
TipoTitulo,
SaldoTitulo,
Vencimento
from #tmp_tab_tiulos

open c_tabcursor
fetch next from c_tabcursor into @ROW, @NossoNumero, @Cedente_CPFCNPJ, @TipoTitulo, @SaldoTitulo, @Vencimento

while @@fetch_status = 0
begin

	print 'proc row: '+ convert(varchar,@ROW)
	
	set @ApiUnidadeID = isnull((select UnidadeID from EmpresaInterface where ChaveUnica = @Cedente_CPFCNPJ),0)

	--gerar chave unica do boleto
	declare @ChaveTitulo varchar(max) = '0019999999999001'+@NossoNumero
			
	declare @exist int = case when (select count(1) 
		from Boleto where EmpresaID = @ApiEmpresaID 
		and ChaveUnica = @ChaveTitulo) > 0 then 1 else 0 end


	If (@exist = 0)
	begin

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
		MensagemLivreLinha1
		)
	
		Select
			EmpresaID			= @ApiEmpresaID,
			UnidadeID			= @ApiUnidadeID,
			InsertDate			= GetDate(),
			InsertUser			= 'SP_CARGA_ERP',
			StatusIntegracao	= 0,
			CodigoBanco			= bol.CodigoBanco,
			Cedente_CPFCNPJ		= ced.CPFCNPJ,
			Cedente_Codigo		= ced.Codigo,
			ChaveUnica			= @ChaveTitulo,
			Sacado_CPFCNPJ		= sac.CPFCNPJ,
			NumeroDocumento		= case when @TipoTitulo in ('FT','BOL') then rtrim(@TipoTitulo)+'-'+NumeroDocumento else NumeroDocumento end,
			NumeroControleParticipante 	   ,
			NossoNumero					   ,
			DataEmissao					   ,
			DataVencimento		= @Vencimento,
			ValorTitulo			= @SaldoTitulo,
			ValorOutrosAcrescimos		   ,
			ValorDesconto				   ,
			PercentualJurosDia			   ,
			ValorJurosDia				   ,
			EspecieDocumento		 = '00',
			MensagemLivreLinha1 = MensagemInstrucoesCaixa		  


	end

	fetch next from c_tabcursor into @ROW, @Cedente_CPFCNPJ, @TipoTitulo, @SaldoTitulo, @Vencimento
end

close c_tabcursor
deallocate c_tabcursor

end