alter procedure Sp_BPortal_Sinc_Cotacao_Portal_Protheus
with encryption
as
begin

set nocount on


if ( not (select OBJECT_ID('TEMP_TABdb.dbo.#TEMP_TAB')) is null ) drop table #TEMP_TAB

create table #TEMP_TAB
(
	[ID]						bigint,
	[EMPRESAID]					bigint,
	[EMPRESA] 					varchar(10),
	[FILIAL] 					varchar(10),
	[FORNE_COD] 				varchar(10),
	[FORNE_LOJA] 				varchar(10),
	[CONTATO] 					varchar(10),
	[MOEDA] 					varchar(10),
	[DATA_EMISSAO] 				datetime2,
	[TIPO_FRETE] 				varchar(10),
	[NUMERO_SC] 				varchar(10),
	[ITEM_SC] 					varchar(10),
	[PROPOSTA] 					varchar(10),
	[PRODUTO] 					varchar(20),
	[ITEM] 						varchar(10),
	[UNIDADE] 					varchar(10),
	[QUANTIDADE] 				decimal(30,8),
	[PRECO] 					decimal(30,8),
	[MARCA] 					varchar(max),
	[ALIQ_IPI] 					decimal(30,8),
	[OBSERVACAO] 				varchar(max),
	[PRAZO] 					int,
	[FORNE_ORCAMENTO] 			varchar(max),
	[COND_PAG] 					varchar(max),
	[DATA_VALIDADE] 			datetime,
	[VALOR_SUB] 				decimal(30,8),
	[STATUS] 					varchar(10),
	[CODIGO]					varchar(20),
	[TIPO_SERVICO]				varchar(10),
	[DATA_INICIO_CONTRATO]		datetime2,
	[DATA_FINAL_CONTRATO]		datetime2, 
	[DATA_NECESSIDADE]			datetime2,
	[COTACAO]					varchar(max),
	[COTACAO_ITEM] 				varchar(max),
	[ORIGEM]					int
)

insert into #TEMP_TAB
(
	[ID]						,
	[EMPRESAID] 				,
	[EMPRESA] 					,
	[FILIAL] 					,
	[FORNE_COD] 				,
	[FORNE_LOJA] 				,
	[CONTATO] 					,
	[MOEDA] 					,
	[DATA_EMISSAO] 				,
	[TIPO_FRETE] 				,
	[NUMERO_SC] 				,
	[ITEM_SC] 					,
	[PROPOSTA] 					,
	[PRODUTO] 					,
	[ITEM] 						,
	[UNIDADE] 					,
	[QUANTIDADE] 				,
	[PRECO] 					,
	[MARCA] 					,
	[ALIQ_IPI] 					,
	[OBSERVACAO] 				,
	[PRAZO] 					,
	[FORNE_ORCAMENTO] 			,
	[COND_PAG] 					,
	[DATA_VALIDADE] 			,
	[VALOR_SUB] 				,
	[STATUS] 					,
	[CODIGO]					,
	[TIPO_SERVICO]				,
	[DATA_INICIO_CONTRATO]		,
	[DATA_FINAL_CONTRATO]		,
	[DATA_NECESSIDADE]			,
	[COTACAO]					,
	[COTACAO_ITEM] 				,
	[ORIGEM]
)

select 
SS.ID,
SS.EmpresaID,
EMP=SUBSTRING(UN.Codigo, 1, 2), 
FIL=SUBSTRING(UN.Codigo, 3, 2), 
FORNE_COD=FO.CodigoERP,
FORNE_LOJA='01',
CONTATO= '',
MOEDA=Moeda,
DATA_EMISSAO=GetDate(),
TIPO_FRETE=TipoFrete,
NUMERO_SC=ISNULL(SC_NUM, ''),
ITEM_SC=ISNULL(SC_ITEM, ''),
PROPOSTA=SSC.Revisao,
PRODUTO=PROD.Codigo,
ITEM=SSI.Item,
UNIDADE=PROD.UnidadeMedida,
QUANTIDADE=Quantidade,
PRECO=Preco,
MARCA=Marca,
ALIQ_IPI=IPI,
OBSERVACAO=SSCI.Observacao,
PRAZO=PrazoEntrega,
FORNE_ORCAMENTO=SUBSTRING(NumeroOrcamento, 1, 20),
COND_PAG=CondicaoPagamento,
DATA_VALIDADE=(CASE  WHEN DataValidade > GETDATE() THEN DataValidade ELSE GETDATE() END),
VALOR_SUB=ValorSubstituicao,
STATUS='A',
SOLICITACAOSERVICO_PORTAL= SS.Numero,
TIPO_SERVICO=SS.TipoServico,
DataInicioContrato,
DataFinalContrato,
DataNecessidade,
Cotacao=ISNULL(SSI.Cotacao, ''),
CotacaoItem=ISNULL(SSI.CotacaoItem, ''),
ORIGEM=SSC.Origem
from [BPORTAL].[dbo].SolicitacaoServico SS
join [BPORTAL].[dbo].Unidade UN ON UN.ID = SS.UnidadeID
join [BPORTAL].[dbo].SolicitacaoServicoItem SSI ON SS.ID = SSI.SolicitacaoServicoID
join [BPORTAL].[dbo].SolicitacaoServicoFornecedor SSF ON SS.ID = SSF.SolicitacaoServicoID
join [BPORTAL].[dbo].Fornecedor FO ON FO.ID = SSF.FornecedorID
join [BPORTAL].[dbo].SolicitacaoServicoCotacao SSC ON 
	SS.ID = SSC.SolicitacaoServicoID 
	AND SS.ID = SSC.SolicitacaoServicoID
	AND SSF.FornecedorID = SSC.FornecedorID

join [BPORTAL].[dbo].SolicitacaoServicoCotacaoItem SSCI ON 
	SSC.ID = SSCI.SolicitacaoServicoCotacaoID 
	AND  SSI.ID = SSCI.SolicitacaoServicoItemID
join [BPORTAL].[dbo].Produto PROD ON PROD.ID = SSI.ProdutoID

join [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] SOLPORTAL ON 
	SOLPORTAL.CODIGO COLLATE  Latin1_General_BIN = SS.Numero 
	AND SOLPORTAL.PRODUTO COLLATE Latin1_General_BIN = PROD.Codigo
	AND SOLPORTAL.ITEM COLLATE Latin1_General_BIN = SSI.Item

join [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP] SOL 
	ON SOL.SC_YBIZAGI = 
	(
		select TOP 1 PROCESSO_BIZAGI from [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] A 
		where A.CODIGO = SOLPORTAL.CODIGO
		AND A.PROCESSO_BIZAGI is not null
	)
	AND SOL.SC_PRODUTO = SOLPORTAL.PRODUTO
AND SOL.SC_ITEM = SOLPORTAL.ITEM
where Aprovado=1
and SC_NUM <> ''
and SSC.Habilitado=1 
And not exists (

select 1 from 
	 [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL]
	where CODIGO COLLATE  Latin1_General_BIN = SS.Numero
)



--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from #TEMP_TAB)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ID							bigint
DECLARE @EMPRESAID					bigint
DECLARE @EMPRESA 					varchar(10)
DECLARE @FILIAL 					varchar(10)
DECLARE @FORNE_COD 					varchar(10)
DECLARE @FORNE_LOJA 				varchar(10)
DECLARE @CONTATO					varchar(10)
DECLARE @MOEDA	 					varchar(10)
DECLARE @DATA_EMISSAO 				datetime2
DECLARE @TIPO_FRETE 				varchar(10)
DECLARE @NUMERO_SC	 				varchar(10)
DECLARE @ITEM_SC 					varchar(10)
DECLARE @PROPOSTA 					varchar(10)
DECLARE @PRODUTO 					varchar(20)
DECLARE @ITEM 						varchar(10)
DECLARE @UNIDADE 					varchar(10)
DECLARE @QUANTIDADE 				decimal(30,8)
DECLARE @PRECO	 					decimal(30,8)
DECLARE @MARCA 						varchar(max)
DECLARE @ALIQ_IPI 					decimal(30,8)
DECLARE @OBSERVACAO 				varchar(max)
DECLARE @PRAZO	 					int
DECLARE @FORNE_ORCAMENTO 			varchar(max)
DECLARE @COND_PAG 					varchar(max)
DECLARE @DATA_VALIDADE	 			datetime
DECLARE @VALOR_SUB	 				decimal(30,8)
DECLARE @STATUS 					varchar(10)
DECLARE @CODIGO						varchar(20)
DECLARE @TIPO_SERVICO				varchar(10)
DECLARE @DATA_INICIO_CONTRATO		datetime2
DECLARE @DATA_FINAL_CONTRATO		datetime2
DECLARE @DATA_NECESSIDADE			datetime2
DECLARE @COTACAO					varchar(max)
DECLARE @COTACAO_ITEM 				varchar(max)
DECLARE @ORIGEM		 				int


declare cursor_temp cursor fast_forward for
select 	
 [ID]						,
 [EMPRESAID]				,
 [EMPRESA] 					,
 [FILIAL] 					,
 [FORNE_COD] 				,
 [FORNE_LOJA] 				,
 [CONTATO] 					,
 [MOEDA] 					,
 [DATA_EMISSAO] 			,
 [TIPO_FRETE] 				,
 [NUMERO_SC] 				,
 [ITEM_SC] 					,
 [PROPOSTA] 				,
 [PRODUTO] 					,
 [ITEM] 					,
 [UNIDADE] 					,
 [QUANTIDADE] 				,
 [PRECO] 					,
 [MARCA] 					,
 [ALIQ_IPI] 				,
 [OBSERVACAO] 				,
 [PRAZO] 					,
 [FORNE_ORCAMENTO] 			,
 [COND_PAG] 				,
 [DATA_VALIDADE] 			,
 [VALOR_SUB] 				,
 [STATUS] 					,
 [CODIGO]					,
 [TIPO_SERVICO]				,
 [DATA_INICIO_CONTRATO]		,
 [DATA_FINAL_CONTRATO]		,
 [DATA_NECESSIDADE]			,
 [COTACAO]					,
 [COTACAO_ITEM] 			,
 [ORIGEM]
from #TEMP_TAB

open cursor_temp
fetch next from cursor_temp into 
 
 @ID					,
 @EMPRESAID				,
 @EMPRESA 				,
 @FILIAL 				,
 @FORNE_COD 			,
 @FORNE_LOJA 			,
 @CONTATO				,
 @MOEDA	 				,
 @DATA_EMISSAO 			,
 @TIPO_FRETE 			,
 @NUMERO_SC	 			,
 @ITEM_SC 				,
 @PROPOSTA 				,
 @PRODUTO 				,
 @ITEM 					,
 @UNIDADE 				,
 @QUANTIDADE 			,
 @PRECO	 				,
 @MARCA 				,
 @ALIQ_IPI 				,
 @OBSERVACAO 			,
 @PRAZO	 				,
 @FORNE_ORCAMENTO 		,
 @COND_PAG 				,
 @DATA_VALIDADE	 		,
 @VALOR_SUB	 			,
 @STATUS 				,
 @CODIGO				,
 @TIPO_SERVICO			,
 @DATA_INICIO_CONTRATO	,
 @DATA_FINAL_CONTRATO	,
 @DATA_NECESSIDADE		,
 @COTACAO				,
 @COTACAO_ITEM 			,
 @ORIGEM	

while @@FETCH_STATUS = 0
begin

		print 'insert'
		
		
		
INSERT INTO [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL](
	[EMPRESA] 				,
	[FILIAL] 				,
	[FORNE_COD] 			,
	[FORNE_LOJA] 			,
	[CONTATO] 				,
	[MOEDA] 				,
	[DATA_EMISSAO] 			,
	[TIPO_FRETE] 			,
	[NUMERO_SC] 			,
	[ITEM_SC] 				,
	[PROPOSTA] 				,
	[PRODUTO] 				,
	[ITEM] 					,
	[UNIDADE] 				,
	[QUANTIDADE] 			,
	[PRECO] 				,
	[MARCA] 				,
	[ALIQ_IPI] 				,
	[OBSERVACAO] 			,
	[PRAZO] 				,
	[FORNE_ORCAMENTO] 		,
	[COND_PAG] 				,
	[DATA_VALIDADE] 		,
	[VALOR_SUB] 			,
	[STATUS] 				,
	[CODIGO]				,
	[TIPO_SERVICO]			,
	[DATA_INICIO_CONTRATO]	,
	[DATA_FINAL_CONTRATO]	, 
	[DATA_NECESSIDADE]		,
	[COTACAO]				,
	[COTACAO_ITEM]			,			
	[ORIGEM]
)     
		select		

 EMPRESA=@EMPRESA 						,
 FILIAL=@FILIAL 							,
 FORNE_COD=@FORNE_COD 						,
 FORNE_LOJA=@FORNE_LOJA 					,
 CONTATO=@CONTATO							,
 MOEDA= @MOEDA	 							,
 DATA_EMISSAO=@DATA_EMISSAO 				,
 TIPO_FRETE=@TIPO_FRETE 					,
 NUMERO_SC=@NUMERO_SC	 					,
 ITEM_SC=@ITEM_SC 							,
 PROPOSTA=@PROPOSTA 						,
 PRODUTO=@PRODUTO 							,
 ITEM=@ITEM 								,
 UNIDADE=@UNIDADE 							,
 QUANTIDADE=@QUANTIDADE 					,
 PRECO=@PRECO	 							,
 MARCA=@MARCA 								,
 ALIQ_IPI=@ALIQ_IPI 						,
 OBSERVACAO=@OBSERVACAO 					,
 PRAZO=@PRAZO	 							,
 FORNE_ORCAMENTO=@FORNE_ORCAMENTO 			,
 COND_PAG=@COND_PAG 						,
 DATA_VALIDADE=@DATA_VALIDADE	 			,
 VALOR_SUB=@VALOR_SUB	 					,
 STATUS=@STATUS 							,
 CODIGO=@CODIGO								,
 TIPO_SERVICO=@TIPO_SERVICO					,
 DATA_INICIO_CONTRATO=@DATA_INICIO_CONTRATO	,
 DATA_FINAL_CONTRATO=@DATA_FINAL_CONTRATO	,
 DATA_NECESSIDADE=@DATA_NECESSIDADE			,
 COTACAO=@COTACAO							,
 COTACAO_ITEM=@COTACAO_ITEM 				,	
 ORIGEM=@ORIGEM	


INSERT INTO [dbo].[SolicitacaoServicoHistorico]
           ([InsertUser]
           ,[InsertDate]
           ,[StatusIntegracao]
           ,[DataHoraIntegracao]
           ,[MensagemRetorno]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[IDProcesso]
           ,[StageID]
           ,[SolicitacaoServicoID]
           ,[UsuarioID]
           ,[DataEvento]
           ,[Observacao]
           ,[Status])
     VALUES
           ('JOB',
		   getdate()
           ,0
           ,NULL
           ,''
           ,@EMPRESAID
           ,NULL
           ,1
           ,0
           ,0
           ,NULL
           ,NULL
           ,@ID
           ,null
           ,getDate()
           ,'Cotação inserida na tabela integradora do protheus'
           , 0) 
	
	fetch next from cursor_temp into 
			@ID					,
			@EMPRESAID				,
			 @EMPRESA 				,
			 @FILIAL 				,
			 @FORNE_COD 			,
			 @FORNE_LOJA 			,
			 @CONTATO				,
			 @MOEDA	 				,
			 @DATA_EMISSAO 			,
			 @TIPO_FRETE 			,
			 @NUMERO_SC	 			,
			 @ITEM_SC 				,
			 @PROPOSTA 				,
			 @PRODUTO 				,
			 @ITEM 					,
			 @UNIDADE 				,
			 @QUANTIDADE 			,
			 @PRECO	 				,
			 @MARCA 				,
			 @ALIQ_IPI 				,
			 @OBSERVACAO 			,
			 @PRAZO	 				,
			 @FORNE_ORCAMENTO 		,
			 @COND_PAG 				,
			 @DATA_VALIDADE	 		,
			 @VALOR_SUB	 			,
			 @STATUS 				,
			 @CODIGO				,
			 @TIPO_SERVICO			,
			 @DATA_INICIO_CONTRATO	,
			 @DATA_FINAL_CONTRATO	,
			 @DATA_NECESSIDADE		,
			 @COTACAO				,
			 @COTACAO_ITEM 			,
			 @ORIGEM
end

close cursor_temp
deallocate cursor_temp

end