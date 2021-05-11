alter procedure Sp_BPortal_Sinc_Contas_A_Pagar_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.##TEMP_TITULO_PAGAR_ATU')) is null ) drop table ##TEMP_TITULO_PAGAR_ATU

declare @EmpresaID bigint = 2

SELECT * INTO ##TEMP_TITULO_PAGAR_ATU FROM (
	SELECT 
		EmpresaId,
		ChaveUnica,
		E2_VENCREA,
		E2_BAIXA,
		E2_VALOR
	FROM HADES.DADOSADV.dbo.SE2010 SE2 (NOLOCK)
	INNER JOIN HADES.DADOSADV.dbo.SA2010 SA2 (NOLOCK) ON A2_FILIAL = '  ' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''
	INNER JOIN HADES.DADOSADV.dbo.SF1010 SF1 (NOLOCK) ON F1_FORNECE = E2_FORNECE AND E2_LOJA = F1_LOJA AND F1_DOC = E2_NUM AND SF1.D_E_L_E_T_ = ''

	INNER JOIN TituloPagar t on t.EmpresaID = @EmpresaID and t.ChaveUnica = RTRIM(A2_CGC)+RTRIM(F1_DOC)+RTRIM(F1_SERIE)+RTRIM(E2_PARCELA) collate Latin1_General_BIN
	WHERE 
	(
		DataVencimento				<> convert(date, E2_VENCREA) or		
		ValorTitulo					<> E2_VALOR or
		(E2_BAIXA 					<> '' and DataPagamento is null)
	)

) TAB


--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from ##TEMP_TITULO_PAGAR_ATU)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ChaveUnica							varchar(max)
DECLARE @DataVencimento                     varchar(8)
DECLARE @DataBaixa                          varchar(8)
DECLARE @DataPagamento                      varchar(8)
DECLARE @ValorTitulo                        decimal(30,8)


declare cursor_titulo_pagar cursor fast_forward for
select * from ##TEMP_TITULO_PAGAR_ATU

open cursor_titulo_pagar
fetch next from cursor_titulo_pagar into 
@EmpresaID					  ,
@ChaveUnica                   ,
@DataVencimento               ,
@DataBaixa                    ,
@ValorTitulo                         


while @@FETCH_STATUS = 0
begin

	print 'proc row: '+ @ChaveUnica

	update [TituloPagar]

	set
	StatusIntegracao			= 0,
	DataPagamento             	= convert(date, @DataBaixa),
	DataBaixa     		        = convert(date, @DataBaixa),
	DataVencimento				= convert(date, @DataVencimento),
	ValorTitulo                 = @ValorTitulo
	
	where EmpresaID = @EmpresaID and ChaveUnica = @ChaveUnica

	fetch next from cursor_titulo_pagar into 
			@EmpresaID					  ,
			@ChaveUnica                   ,
			@DataVencimento               ,
			@DataBaixa                    ,
			@ValorTitulo                


end

close cursor_titulo_pagar
deallocate cursor_titulo_pagar

end