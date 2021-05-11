alter procedure Sp_BPortal_Sinc_Clientes_Protheus
with encryption
as
begin

set nocount on

if ( not (select OBJECT_ID('tempdb.dbo.#tmp_Sacado')) is null ) drop table #tmp_Sacado

--INSERIR NOVOS REGISTROS

;WITH TTIT AS (

SELECT DISTINCT E1_CLIENTE, E1_LOJA FROM (
SELECT E1_CLIENTE, E1_LOJA
FROM DADOSADV.dbo.SE1010 SE1 (NOLOCK)
WHERE 
	E1_FILIAL = '01'
	AND E1_CLIENTE NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
	AND E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') 	
	AND E1_YFORMA NOT IN ('3', '4')	
	AND E1_YSITAPI <> '4'
	AND E1_SALDO > 0
	--AND E1_VENCREA >= convert(varchar(8),getdate(),112)
	--AND E1_PORTADO <> ''
	AND E1_NUMBCO <> ''
	AND D_E_L_E_T_ = ''

union all

SELECT E1_CLIENTE, E1_LOJA
FROM DADOSADV.dbo.SE1070 SE1 (NOLOCK)
WHERE 
	E1_FILIAL = '01'
	AND E1_CLIENTE NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
	AND E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') 	
	AND E1_YFORMA NOT IN ('3', '4')	
	AND E1_YSITAPI <> '4'
	AND E1_SALDO > 0
	--AND E1_VENCREA >= convert(varchar(8),getdate(),112)
	--AND E1_PORTADO <> ''
	AND E1_NUMBCO <> ''
	AND D_E_L_E_T_ = ''

union all

SELECT E1_CLIENTE, E1_LOJA
FROM DADOSADV.dbo.SE1050 SE1 (NOLOCK)
WHERE 
	E1_FILIAL = '01'
	AND E1_CLIENTE NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
	AND E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') 	
	AND E1_YFORMA NOT IN ('3', '4')	
	AND E1_YSITAPI <> '4'
	AND E1_SALDO > 0
	--AND E1_VENCREA >= convert(varchar(8),getdate(),112)
	--AND E1_PORTADO <> ''
	AND E1_NUMBCO <> ''
	AND D_E_L_E_T_ = ''


	union all

SELECT E1_CLIENTE, E1_LOJA
FROM DADOSADV.dbo.SE1140 SE1 (NOLOCK)
WHERE 
	E1_FILIAL = '01'
	AND E1_CLIENTE NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
	AND E1_TIPO IN ('NF', 'FT', 'BOL', 'ST') 	
	AND E1_YFORMA NOT IN ('3', '4')	
	AND E1_YSITAPI <> '4'
	AND E1_SALDO > 0
	--AND E1_VENCREA >= convert(varchar(8),getdate(),112)
	--AND E1_PORTADO <> ''
	AND E1_NUMBCO <> ''
	AND D_E_L_E_T_ = ''
	
) AS TTIT

),

TCLI as (

SELECT 
	RAIZ = substring(A1_CGC,1,8),
	ROW = (ROW_NUMBER() OVER(ORDER BY A1_CGC, R_E_C_N_O_ DESC)),
	A1_CGC, 
	A1_NOME, 
	A1_YEMABOL, 
	A1_ENDCOB, 
	A1_COMPLEM, 
	A1_BAIRROC, 
	A1_ESTC, 
	A1_MUNC, 
	A1_CEPC, 
	A1_MSBLQL,
	A1_COD
		
	FROM DADOSADV.dbo.SA1010 SA1 (nolock)
	INNER JOIN TTIT X on X.E1_CLIENTE = A1_COD and X.E1_LOJA = A1_LOJA
	WHERE SA1.D_E_L_E_T_ = ''
	and A1_COD NOT IN ('000481','005885','999999','022551','026423','026308','007871','004536','010083','008615','010064','025633','025634','025704','018410','014395','001042')
	and A1_YEMABOL <> ''
	and A1_CGC <> ''	
	and A1_MSBLQL <> '1'
	and (len(RTRIM(A1_CGC)) = 14)	
	and not exists (select 1 from Sacado s (nolock) where s.CpfCnpj = RTRIM(A1_CGC) collate Latin1_General_BIN)	
)

select
RAIZ,
ROW,
A1_CGC, 
A1_NOME, 
A1_YEMABOL, 
A1_ENDCOB, 
A1_COMPLEM, 
A1_BAIRROC, 
A1_ESTC, 
A1_MUNC, 
A1_CEPC,
A1_MSBLQL,
A1_COD,
CUSER = 1

into #tmp_Sacado
from TCLI A


--;with TROW as (
--select
--RAIZ,
--MROW = MIN(ROW)
--from #tmp_Sacado
--group by RAIZ
--) 

--Criar USUARIO AUTOMATICO para primeiro CNPJ da RAIZ
--update #tmp_Sacado
--set CUSER = 1
--where exists (select 1 from TROW R where R.RAIZ = #tmp_Sacado.RAIZ and R.MROW = #tmp_Sacado.ROW)


--select * from #tmp_Sacado
--return


-----------INSERI REGISTROS ALTERADOS----------------------

INSERT INTO #tmp_Sacado
	(
	A1_CGC, 
	A1_NOME, 
	A1_YEMABOL, 
	A1_ENDCOB, 
	A1_COMPLEM, 
	A1_BAIRROC, 
	A1_ESTC, 
	A1_MUNC, 
	A1_CEPC, 
	A1_MSBLQL,
	A1_COD,
	CUSER
	)

SELECT 

	A1_CGC, 
	A1_NOME, 
	A1_YEMABOL, 
	A1_ENDCOB, 
	A1_COMPLEM, 
	A1_BAIRROC, 
	A1_ESTC, 
	A1_MUNC, 
	A1_CEPC, 
	A1_MSBLQL,
	A1_COD,
	CUSER = 0
		
	FROM DADOSADV.dbo.SA1010 SA1 (nolock)
	INNER JOIN Sacado s (nolock) on s.CpfCnpj = RTRIM(A1_CGC) collate Latin1_General_BIN
	
	WHERE SA1.D_E_L_E_T_ = ''
	and A1_YEMABOL <> ''
	and A1_CGC <> ''

	and A1_MSBLQL <> '1'
	and not exists (select 1 from DADOSADV.dbo.SA1010 X (nolock) where RTRIM(X.A1_CGC) =  RTRIM(SA1.A1_CGC) and X.D_E_L_E_T_='' and X.A1_MSBLQL <> '1' and X.R_E_C_N_O_ > SA1.R_E_C_N_O_)

	and (
		RTRIM(isnull(s.Nome,''))				<>  RTRIM(A1_NOME)     collate Latin1_General_BIN
		or RTRIM(isnull(s.EmailWorkflow,''))	<>  RTRIM(A1_YEMABOL)  collate Latin1_General_BIN
		or RTRIM(isnull(s.Logradouro,''))		<>  RTRIM(A1_ENDCOB)   collate Latin1_General_BIN
		or RTRIM(isnull(s.Complemento,''))		<>  RTRIM(A1_COMPLEM)  collate Latin1_General_BIN
		or RTRIM(isnull(s.Bairro,''))			<>  RTRIM(A1_BAIRROC)  collate Latin1_General_BIN
		or RTRIM(isnull(s.UF,''))				<>  RTRIM(A1_ESTC) 	   collate Latin1_General_BIN
		or RTRIM(isnull(s.Cidade,''))			<>  RTRIM(A1_MUNC) 	   collate Latin1_General_BIN
		or RTRIM(isnull(s.CEP,''))				<>  RTRIM(A1_CEPC) 	   collate Latin1_General_BIN
		or RTRIM(isnull(s.CodigoERP,''))		<>  RTRIM(A1_COD) 	   collate Latin1_General_BIN
		or s.Habilitado							<>  case when RTRIM(A1_MSBLQL) = '1' then 0 else 1 end
	)

	


-----------INSERI REGISTROS QUE EXISTEM BOLETOS E POR VENTURA NAO SAIAM NA PRIMEIRA QUERY POR QUE OS TITULOS PODEM JA ESTAR BAIXADOS----------------------
INSERT INTO #tmp_Sacado
	(
	A1_CGC, 
	A1_NOME, 
	A1_YEMABOL, 
	A1_ENDCOB, 
	A1_COMPLEM, 
	A1_BAIRROC, 
	A1_ESTC, 
	A1_MUNC, 
	A1_CEPC, 
	A1_MSBLQL,
	A1_COD,
	CUSER
	)
	
SELECT 
	A1_CGC, 
	A1_NOME, 
	A1_YEMABOL, 
	A1_ENDCOB, 
	A1_COMPLEM, 
	A1_BAIRROC, 
	A1_ESTC, 
	A1_MUNC, 
	A1_CEPC, 
	A1_MSBLQL,
	A1_COD,
	CUSER = 1
		
	FROM DADOSADV.dbo.SA1010 SA1 (nolock)
	INNER JOIN Boleto b (nolock) on b.Sacado_CPFCNPJ = RTRIM(A1_CGC) collate Latin1_General_BIN
	LEFT JOIN Sacado s (nolock) on s.CPFCNPJ = b.Sacado_CPFCNPJ
	
	WHERE 
	s.ID is null
	and SA1.D_E_L_E_T_ = ''
	and A1_YEMABOL <> ''
	and A1_CGC <> ''
	and A1_MSBLQL <> '1'
	and not exists (select 1 from DADOSADV.dbo.SA1010 X (nolock) where RTRIM(X.A1_CGC) =  RTRIM(SA1.A1_CGC) and X.D_E_L_E_T_='' and X.A1_MSBLQL <> '1' and X.R_E_C_N_O_ > SA1.R_E_C_N_O_)





--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(50) = rtrim(convert(varchar,(select count(1) from #tmp_Sacado)))
print 'processando: ' + @numrec + ' registros'


declare @CpfCnpj       	varchar(max)	
declare @Nome 			varchar(max)
declare @Email 			varchar(max)
declare @Logradouro		varchar(max)
declare @Complemento	varchar(max)
declare @Bairro 		varchar(max)
declare @UF 			varchar(max)
declare @Cidade 		varchar(max)
declare @CEP 			varchar(max)
declare @Habilitado		varchar(max)
declare @CodigoERP		varchar(max)
declare @CUSER			int

declare c_cli cursor fast_forward for
select
A1_CGC, 
A1_NOME, 
A1_YEMABOL, 
A1_ENDCOB, 
A1_COMPLEM, 
A1_BAIRROC, 
A1_ESTC, 
A1_MUNC, 
A1_CEPC, 
A1_MSBLQL,
A1_COD,
CUSER

from #tmp_Sacado 

open c_cli
fetch next from c_cli into
@CpfCnpj       	,
@Nome 			,
@Email 			,
@Logradouro		,
@Complemento	,
@Bairro 		,
@UF 			,
@Cidade 		,
@CEP 			,
@Habilitado		,
@CodigoERP		,
@CUSER


while @@FETCH_STATUS = 0
begin

	print 'processando: '+ @CpfCnpj

	declare @mail1 varchar(max) = dbo.Fnc_Get_First_Mail(@Email)

	if (not exists (select 1 from Sacado where CpfCnpj = @CpfCnpj))
	begin

		print 'insert'
		
		insert into Sacado
		(
		EmpresaID		,
		UnidadeID		,
		ChaveUnica		,
		StatusIntegracao,
		CpfCnpj			,
		Nome 			,
		EmailUsuario	,
		EmailWorkflow	,
		Logradouro		,
		Numero 			,
		Complemento		,
		Bairro 			,
		UF 				,
		Cidade 			,
		CEP 			,
		Habilitado		,
		CodigoERP		,
		CriarUsuario
		)

		select
		EmpresaID			= 2,
		UnidadeID			= 4,
		ChaveUnica			= RTRIM(@CpfCnpj),
		StatusIntegracao	= 0,
		CpfCnpj				= RTRIM(@CpfCnpj),
		Nome 				= RTRIM(@Nome),
		EmailUsuario		= RTRIM(@mail1),
		EmailWorkflow		= RTRIM(@Email),	
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(''),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		CEP 				= RTRIM(@CEP),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end,
		CodigoERP			= RTRIM(@CodigoERP),
		CriarUsuario		= @CUSER

	end
	else
	begin

		print 'update'
		
		update Sacado
		set	 		
		StatusIntegracao	= 0,
		ChaveUnica			= RTRIM(@CpfCnpj),
		CpfCnpj				= RTRIM(@CpfCnpj),
		Nome 				= RTRIM(@Nome),
		EmailUsuario		= RTRIM(@mail1),
		EmailWorkflow		= RTRIM(@Email),	
		Logradouro			= RTRIM(@Logradouro),
		Numero 				= RTRIM(''),
		Complemento			= RTRIM(@Complemento),
		Bairro 				= RTRIM(@Bairro),
		UF 					= RTRIM(@UF),
		Cidade 				= RTRIM(@Cidade),
		CEP 				= RTRIM(@CEP),
		Habilitado			= case when @Habilitado = '1' then 0 else 1 end,
		CodigoERP			= RTRIM(@CodigoERP)

		where CpfCnpj = @CpfCnpj

	end

	--next
	fetch next from c_cli into
		@CpfCnpj       	,
		@Nome 			,
		@Email 			,
		@Logradouro		,
		@Complemento	,
		@Bairro 		,
		@UF 			,
		@Cidade 		,
		@CEP 			,
		@Habilitado		,
		@CodigoERP		,
		@CUSER

end
close c_cli
deallocate c_cli


end