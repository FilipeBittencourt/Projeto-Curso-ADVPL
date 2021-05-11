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
	Cedente_CNPJ bigint,
	TipoTitulo varchar(3),
	SaldoTitulo decimal(30,2),
	Vencimento date,
)

declare @Cedente_Empresa varchar(2)
declare @Cedente_CPFCNPJ varchar(max)
declare @Cedente_Codigo varchar(max)

declare c_cedentes cursor for

select '01', '02077546000176', '23735111422001' 
--select '01', '02077546000176', '0013431255.097-3007' union all 
--select '01', '02077546000176', '237351110.599-6001' union all
--select '01', '02077546000176', '23735111422' union all
--select '07', '10524837000193', '0013431252868001' union all
--select '07', '10524837000193', '2373511955001' union all
--select '05', '04917232000160', '001343125.666-9003' union all
--select '14', '08930868000100', '001343148755003' 


declare @ApiEmpresaID bigint = 2

open c_cedentes
fetch next from c_cedentes into @Cedente_Empresa, @Cedente_CPFCNPJ, @Cedente_Codigo
while @@fetch_status = 0
begin

	print @Cedente_CPFCNPJ
	print @Cedente_Codigo

	declare @EmpresaID bigint = isnull((select EmpresaID from EmpresaInterface where ChaveUnica = @Cedente_CPFCNPJ),0)


	set @sql = '
	insert into #tmp_tab_tiulos (BoletoID, Cedente_CNPJ, TipoTitulo, SaldoTitulo, Vencimento)
	
	SELECT
		BoletoID = bol.ID,
		Cedente_CNPJ = '''+@Cedente_CPFCNPJ+''',
		TipoTitulo = RTRIM(SE1.E1_TIPO),
		SaldoTitulo = ROUND(SE1.E1_SALDO,2),
		Vencimento = convert(date, SE1.E1_VENCREA)
		FROM HADES.DADOSADV.dbo.SE1'+@Cedente_Empresa+'0 SE1 (NOLOCK)
		INNER JOIN HADES.DADOSADV.dbo.SA1010 SA1 (NOLOCK) ON A1_FILIAL = '' '' AND E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA
		INNER JOIN HADES.APIFINANCEIRO.dbo.Cedente ced on ced.EmpresaID = '+rtrim(convert(varchar,@ApiEmpresaID))+' and ced.Codigo = '''+@Cedente_Codigo+'''
		INNER JOIN HADES.APIFINANCEIRO.dbo.Boleto bol 
			on bol.EmpresaID = '+rtrim(convert(varchar,@ApiEmpresaID))+' 
			and bol.CedenteID = ced.ID and bol.NossoNumero = RTRIM(SE1.E1_NUMBCO) collate Latin1_General_BIN
			and bol.NumeroControleParticipante = RTRIM(SE1.R_E_C_N_O_)
		INNER JOIN Sacado sacportal on sacportal.EmpresaID = '+rtrim(convert(varchar,@EmpresaID))+' and RTRIM(sacportal.CPFCNPJ) = RTRIM(SA1.A1_CGC) collate Latin1_General_BIN
	
		WHERE 
			E1_SALDO > 0
			and SE1.D_E_L_E_T_='' ''
			and SE1.E1_NUMBOR IN (''010500'', ''010502'')
			
			--AND (Convert(date, Bol.InsertDate) = ''2021-03-01'' or Convert(date, Bol.InsertDate) = ''2021-03-01'')
			--and Bol.ChaveNFE <> ''''
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
declare @TipoTitulo varchar(3)
declare @SaldoTitulo decimal(30,2)
declare @Vencimento date
declare @ApiUnidadeID bigint

declare c_tabcursor cursor fast_forward for
select ROW = BoletoID,
CNPJ = Cedente_CNPJ,
TipoTitulo,
SaldoTitulo,
Vencimento
from #tmp_tab_tiulos

open c_tabcursor
fetch next from c_tabcursor into @ROW, @Cedente_CPFCNPJ, @TipoTitulo, @SaldoTitulo, @Vencimento

while @@fetch_status = 0
begin

	print 'proc row: '+ convert(varchar,@ROW)
	
	set @ApiUnidadeID = isnull((select UnidadeID from EmpresaInterface where ChaveUnica = @Cedente_CPFCNPJ),0)

	--gerar chave unica do boleto
	declare @ChaveTitulo varchar(max) = 
	
			(Select RTRIM(ced.Codigo)+RTRIM(bol.NossoNumero)
	  		from HADES.APIFINANCEIRO.dbo.Boleto bol
			join HADES.APIFINANCEIRO.dbo.Sacado sac on sac.ID = bol.SacadoID
			join HADES.APIFINANCEIRO.dbo.Cedente ced on ced.ID = bol.CedenteID
			where bol.ID = @ROW)
			
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

			from HADES.APIFINANCEIRO.dbo.Boleto bol
			join HADES.APIFINANCEIRO.dbo.Sacado sac on sac.ID = bol.SacadoID
			join HADES.APIFINANCEIRO.dbo.Cedente ced on ced.ID = bol.CedenteID

			where bol.ID = @ROW

	end

	fetch next from c_tabcursor into @ROW, @Cedente_CPFCNPJ, @TipoTitulo, @SaldoTitulo, @Vencimento
end

close c_tabcursor
deallocate c_tabcursor

end