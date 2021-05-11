alter procedure Sp_BPortal_Sinc_Solicitacao_Servico_Medicao_Protheus
with encryption
as
begin

set nocount on

DECLARE @ID							bigint
DECLARE @EMPRESAID 					bigint
DECLARE @MEDICAOID					bigint
DECLARE @EMPRESA 					VARCHAR(max)
DECLARE @FILIAL						VARCHAR(max)
DECLARE @CONTRATO					VARCHAR(max)
DECLARE @ITEM						VARCHAR(max)
DECLARE @PRODUTO					VARCHAR(max)
DECLARE @NOME_PRODUTO				VARCHAR(max)
DECLARE @QUANTIDADE					numeric(30,8)
DECLARE @VALOR						numeric(30,8)
DECLARE @APLICACAO					VARCHAR(max)
DECLARE @TAG						VARCHAR(max)


declare cursor_temp1 cursor fast_forward for

SELECT 
	MEDICAOID=convert(varchar,SSIM.ID),
	EMP=SUBSTRING(UN.Codigo, 1, 2) ,
	FIL=SUBSTRING(UN.Codigo, 3, 2),
	CONTRATO=ISNULL(SSI.Contrato, ''),
	ITEM=ISNULL(SSI.ContratoItem, SSI.Item) ,
	COD_PRODUTO=PROD.Codigo,
	NOME_PRODUTO=SSI.Descricao,
	QUANT=(CASE WHEN  SSIM.UnidadeMedicao=1 then (((Medicao/100)*SaldoMedicao) / (SSIM.Quantidade*ValorServico) )  else Medicao END),
	VALOR=(CASE WHEN  SSIM.UnidadeMedicao=1 then SSIM.Quantidade*ValorServico  else PRECO END),
	APLICACAO=APL.Codigo,
	TAG=T.Codigo

FROM 
SolicitacaoServicoCotacao SSC
join Unidade UN ON UN.ID = SSC.UnidadeID
join SolicitacaoServicoFornecedor SSF ON 
	SSC.FornecedorID = SSF.FornecedorID	
	AND SSC.SolicitacaoServicoID = SSF.SolicitacaoServicoID	
	AND SSF.Vencedor = 1
join SolicitacaoServicoCotacaoItem SSCI ON SSC.ID = SSCI.SolicitacaoServicoCotacaoID 
join SolicitacaoServicoItem SSI ON SSCI.SolicitacaoServicoItemID = SSI.ID
left join Aplicacao APL ON APL.ID = SSI.AplicacaoID
left join TAG T ON T.ID = SSI.TAGID

join Produto PROD  ON PROD.ID = SSI.ProdutoID
join SolicitacaoServicoMedicaoItem SSIM ON SSI.ID = SSIM.SolicitacaoServicoItemID

where 1=1
AND SSIM.Status = 2
AND CONTRATO <> ''
And not exists (

select 1 from 
	 [DADOSADV].[dbo].[BZINTEGRACAO_PREAE]
	where CODIGO COLLATE  Latin1_General_BIN = convert(varchar,SSIM.ID)
)


open cursor_temp1
fetch next from cursor_temp1 into 
 @MEDICAOID			,
 @EMPRESA 			,
 @FILIAL			,
 @CONTRATO			,
 @ITEM				,
 @PRODUTO			,
 @NOME_PRODUTO		,
 @QUANTIDADE		,
 @VALOR				,
 @APLICACAO			,
 @TAG				
 
while @@FETCH_STATUS = 0
begin

	
 
 INSERT INTO [DADOSADV].[dbo].[BZINTEGRACAO_PREAE]
           ([EMPRESA]
           ,[FILIAL]
           ,[CONTRATO]
           ,[ITEM]
           ,[COD_PRODUTO]
           ,[NOME_PRODUTO]
           ,[QUANT]
           ,[DATA_HORA_INCLUSAO]
           ,[USUARIO_INCLUSAO]
           ,[DATA_HORA_PORTAL]
           ,[USUARIO_PORTAL]
           ,[USUARIO_PROTHEUS]
           ,[STATUS]
		   ,[VALOR],
		   [CODIGO],
		   [APLICACAO],
		   [TAG]
          )


SELECT 
EMPRESA=@EMPRESA,
FILIAL=@FILIAL,
CONTRATO=@CONTRATO,
ITEM=@ITEM,
COD_PRODUTO=@PRODUTO,
NOME_PRODUTO=@NOME_PRODUTO,
QUANTIDADE=@QUANTIDADE,
DATA_HORA_INCLUSAO=GETDATE(),
USUARIO_INCLUSAO='',
DATA_HORA_PORTAL='',
USUARIO_PORTAL='',
USUARIO_PROTHEUS='',
STATUS='P',
VALOR=@VALOR,
MEDICAOID=@MEDICAOID,
APLICACAO=@APLICACAO,
TAG=@TAG
	
	fetch next from cursor_temp1 into 
	 @MEDICAOID			,
 @EMPRESA 			,
 @FILIAL			,
 @CONTRATO			,
 @ITEM				,
 @PRODUTO			,
 @NOME_PRODUTO		,
 @QUANTIDADE		,
 @VALOR				,
 @APLICACAO			,
 @TAG				
 		
				 
end

close cursor_temp1
deallocate cursor_temp1



end