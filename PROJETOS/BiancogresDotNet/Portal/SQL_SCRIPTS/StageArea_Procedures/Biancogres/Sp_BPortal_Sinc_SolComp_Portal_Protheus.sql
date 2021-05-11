alter procedure Sp_BPortal_Sinc_SolComp_Portal_Protheus
with encryption
as
begin

set nocount on


if ( not (select OBJECT_ID('TEMP_TABdb.dbo.#TEMP_TAB')) is null ) drop table #TEMP_TAB

create table #TEMP_TAB
(
	[ID]						bigint,
	[EMPRESAID]					bigint,
	[CODIGO] 					varchar(max),	
	[EMPRESA] 					varchar(max),
	[FILIAL] 					varchar(max),
    [CENTRO_CUSTO]				varchar(max),
    [CLASSE_VALOR]				varchar(max),
    [ITEM_CONTA]				varchar(max),
    [SUB_ITEM_CONTA]			varchar(max),
    [DATA_EMISSAO]				datetime2,
    [DATA_NECESSIDADE]			datetime2,
    [STATUS]					varchar(max),
    [DATA_INCLUSAO]				datetime2,
	[SOLICITANTE]				varchar(max),
    [ITEM]						varchar(max),
	[CONTA]						varchar(max),
    [PRODUTO]					varchar(max),
    [DESCRICAO]					varchar(max),
    [QUANTIDADE]				decimal(30,8),
    [UNIDADE]					varchar(max),
    [APLICACAO]					varchar(max),
    [TAG]						varchar(max),
    [DRIVER]					varchar(max),
    [ARMAZEM]					varchar(max),
    [TIPO_SERVICO]				varchar(1),
    [PRIORIDADE]				varchar(max),	
    [SETOR_APROVACAO]			varchar(max),
    [CONTRATO]					varchar(max),
    [ARQUIVO_ANEXO] 			binary,
    [NOME_ANEXO]				varchar(max),
    [DESCRICAO_ANEXO] 			varchar(max),	
    [TIPO_ANEXO]				varchar(max),
	[OBSERVACAO]				varchar(MAX),
	
)
          		   
insert into #TEMP_TAB
(
		   [ID]
		   ,[EMPRESAID]
		   ,[CODIGO]
           ,[EMPRESA]
           ,[FILIAL]
           ,[CENTRO_CUSTO]
           ,[CLASSE_VALOR]
           ,[ITEM_CONTA]
		   ,[SUB_ITEM_CONTA]
		   ,[DATA_EMISSAO]
           ,[DATA_NECESSIDADE]
           ,[STATUS]
           ,[DATA_INCLUSAO]
           ,[SOLICITANTE]
           ,[ITEM]
		   ,[CONTA]
           ,[PRODUTO]
           ,[DESCRICAO]
           ,[QUANTIDADE]
           ,[UNIDADE]
           ,[APLICACAO]
           ,[TAG]
           ,[DRIVER]
           ,[ARMAZEM]
           ,[TIPO_SERVICO]
		   ,[PRIORIDADE]
		   ,[SETOR_APROVACAO]
		   ,[CONTRATO]
		   ,[ARQUIVO_ANEXO] 
		   ,[NOME_ANEXO]
		   ,[DESCRICAO_ANEXO] 
		   ,[TIPO_ANEXO]
		   ,[OBSERVACAO]
)

select 
SS.ID,
SS.EmpresaID,
Numero,
EMP=SUBSTRING(UN.Codigo, 1, 2), 
FIL=SUBSTRING(UN.Codigo, 3, 2), 
CENTRO_CUSTO = CV.CentroCusto,
CLASSE_VALOR = CV.Codigo,
ITEM_CONTA= ISNULL(IC.Codigo, ''),
SUB_ITEM_CONTA=ISNULL(SIC.Codigo, ''),
DATA_EMISSAO = GETDATE(),
DATA_NECESSIDADE = DataNecessidade,
STATUS='A',
DATA_INCLUSAO=  GETDATE(),
SOLICITANTE=ISNULL(US.Nome, ''),
ITEM = SSI.Item,
CONTA = ISNULL((select  TOP 1 B1_CONTA from [DADOSADV].[dbo].SB1010 where B1_COD = PROD.Codigo COLLATE  Latin1_General_BIN AND D_E_L_E_T_ = ''), ''),
PRODUTO	= PROD.Codigo,
DESCRICAO= SSI.Descricao,
QUANTIDADE= SSI.Quantidade,
UNIDADE= PROD.UnidadeMedida,
APLICACAO= AP.Codigo,
TAG= ISNULL(TAG.Codigo, ''),
DRIVER= DR.Codigo,
ARMAZEM= ARM.Codigo,
TIPO_SERVICO=TipoServico,
PRIORIDADE=PS.Codigo,
SETOR_APROVACAO=SA.Codigo,
CONTRATO=ISNULL(CON.Codigo, ''),
ARQUIVO_ANEXO=SS.ArquivoAnexo, 
NOME_ANEXO =SS.NomeAnexo,
DESCRICAO_ANEXO=SS.DescricaoAnexo, 
TIPO_ANEXO =SS.TipoAnexo,
OBSERVACAO=SS.Observacao
from SolicitacaoServico SS
join Unidade UN ON UN.ID = SS.UnidadeID
join Usuario US ON US.ID = SS.UsuarioID

join ClasseValor CV  ON CV.ID = SS.ClasseValorID
join SolicitacaoServicoItem SSI  ON SS.ID = SSI.SolicitacaoServicoID
join Produto PROD  ON PROD.ID = SSI.ProdutoID
join Aplicacao AP  ON AP.ID = SSI.AplicacaoID
join Driver DR  ON DR.ID = SSI.DriverID
left join TAG TAG  ON TAG.ID = SSI.TAGID
join Armazem ARM  ON ARM.ID = SSI.ArmazemID
join PrioridadeServico PS ON PS.ID= PrioridadeServicoID
join SetorAprovacao SA ON SA.ID= SetorAprovacaoID
left join ContaContabil CC ON CC.ID= SSI.ContaContabilID
left join ItemConta IC ON IC.ID= ItemContaID
left join SubItemConta SIC ON SIC.ID= SubItemContaID
left join Contrato CON ON CON.ID= ContratoID
where 
 not exists(
select 1 from [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL] 
	where CODIGO  COLLATE  Latin1_General_BIN = Numero
)
And SS.Status = 1




--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from #TEMP_TAB)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ID							bigint
DECLARE @EMPRESAID					bigint
DECLARE @CODIGO 					varchar(20)	
DECLARE @EMPRESA 					varchar(10)
DECLARE @FILIAL 					varchar(10)
DECLARE @CENTRO_CUSTO				varchar(10)
DECLARE @CLASSE_VALOR				varchar(20)
DECLARE @ITEM_CONTA					varchar(20)
DECLARE @SUB_ITEM_CONTA				varchar(20)
DECLARE @DATA_EMISSAO				datetime2
DECLARE @DATA_NECESSIDADE			datetime2
DECLARE @STATUS						varchar(10)
DECLARE @DATA_INCLUSAO				datetime2
DECLARE @SOLICITANTE				varchar(40)
DECLARE @ITEM						varchar(10)
DECLARE @CONTA						varchar(40)
DECLARE @PRODUTO					varchar(40)
DECLARE @DESCRICAO					varchar(200)
DECLARE @QUANTIDADE					decimal(30,8)
DECLARE @UNIDADE					varchar(10)
DECLARE @APLICACAO					varchar(20)
DECLARE @TAG						varchar(20)
DECLARE @DRIVER						varchar(20)
DECLARE @ARMAZEM					varchar(10)
DECLARE @TIPO_SERVICO				varchar(1)
DECLARE @PRIORIDADE					varchar(10)	
DECLARE @SETOR_APROVACAO			varchar(10)
DECLARE @CONTRATO					varchar(10)
DECLARE @ARQUIVO_ANEXO 				binary
DECLARE @NOME_ANEXO					varchar(200)
DECLARE @DESCRICAO_ANEXO 			varchar(200)	
DECLARE @TIPO_ANEXO					varchar(100)
DECLARE @OBSERVACAO					varchar(max)

	
declare cursor_temp cursor fast_forward for
select 	
 [ID]
		   ,[EMPRESAID]
		   ,[CODIGO]
           ,[EMPRESA]
           ,[FILIAL]
           ,[CENTRO_CUSTO]
           ,[CLASSE_VALOR]
           ,[ITEM_CONTA]
		   ,[SUB_ITEM_CONTA]
		   ,[DATA_EMISSAO]
           ,[DATA_NECESSIDADE]
           ,[STATUS]
           ,[DATA_INCLUSAO]
           ,[SOLICITANTE]
           ,[ITEM]
		   ,[CONTA]
           ,[PRODUTO]
           ,[DESCRICAO]
           ,[QUANTIDADE]
           ,[UNIDADE]
           ,[APLICACAO]
           ,[TAG]
           ,[DRIVER]
           ,[ARMAZEM]
           ,[TIPO_SERVICO]
		   ,[PRIORIDADE]
		   ,[SETOR_APROVACAO]
		   ,[CONTRATO]
		   ,[ARQUIVO_ANEXO] 
		   ,[NOME_ANEXO]
		   ,[DESCRICAO_ANEXO] 
		   ,[TIPO_ANEXO] 		
		 ,[OBSERVACAO]	
from #TEMP_TAB

open cursor_temp
fetch next from cursor_temp into 
 
 
 @ID					,
 @EMPRESAID				,
 @CODIGO 				,
 @EMPRESA 				,
 @FILIAL 				,
 @CENTRO_CUSTO			,
 @CLASSE_VALOR			,
 @ITEM_CONTA			,
 @SUB_ITEM_CONTA		,
 @DATA_EMISSAO			,
 @DATA_NECESSIDADE		,
 @STATUS				,
 @DATA_INCLUSAO			,
 @SOLICITANTE			,
 @ITEM					,
 @CONTA					,
 @PRODUTO				,
 @DESCRICAO				,
 @QUANTIDADE			,
 @UNIDADE				,
 @APLICACAO				,
 @TAG					,
 @DRIVER				,
 @ARMAZEM				,
 @TIPO_SERVICO			,
 @PRIORIDADE			,
 @SETOR_APROVACAO		,
 @CONTRATO				,
 @ARQUIVO_ANEXO 		,
 @NOME_ANEXO			,
 @DESCRICAO_ANEXO 		,
 @TIPO_ANEXO			,
 @OBSERVACAO                       


while @@FETCH_STATUS = 0
begin

		print 'insert'
		
INSERT INTO [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL]
           ([CODIGO]
           ,[EMPRESA]
           ,[FILIAL]
           ,[CENTRO_CUSTO]
           ,[CLASSE_VALOR]
           ,[ITEM_CONTA]
		   ,[SUB_ITEM_CONTA]
		   ,[DATA_EMISSAO]
           ,[DATA_NECESSIDADE]
           ,[STATUS]
           ,[DATA_INCLUSAO]
           ,[SOLICITANTE]
           ,[ITEM]
		   ,[CONTA]
           ,[PRODUTO]
           ,[DESCRICAO]
           ,[QUANTIDADE]
           ,[UNIDADE]
           ,[APLICACAO]
           ,[TAG]
           ,[DRIVER]
           ,[ARMAZEM]
           ,[TIPO_SERVICO]
		   ,[PRIORIDADE]
		   ,[SETOR_APROVACAO]
		   ,[CONTRATO]
		   ,[ARQUIVO_ANEXO] 
		   ,[NOME_ANEXO]
		   ,[DESCRICAO_ANEXO] 
			,[TIPO_ANEXO]
			,[OBSERVACAO]
		   )
		select		

 CODIGO=@CODIGO 						,
 EMPRESA=@EMPRESA 						,
 FILIAL=@FILIAL 						,
 CENTRO_CUSTO=@CENTRO_CUSTO				,
 CLASSE_VALOR=@CLASSE_VALOR				,
 ITEM_CONTA=@ITEM_CONTA					,
 SUB_ITEM_CONTA=@SUB_ITEM_CONTA			,
 DATA_EMISSAO=@DATA_EMISSAO				,
 DATA_NECESSIDADE=@DATA_NECESSIDADE		,
 STATUS=@STATUS							,
 DATA_INCLUSAO=@DATA_INCLUSAO			,
 SOLICITANTE=@SOLICITANTE				,
 ITEM=@ITEM								,
 CONTA=@CONTA							,
 PRODUTO=@PRODUTO						,
 DESCRICAO=@DESCRICAO					,
 QUANTIDADE=@QUANTIDADE					,
 UNIDADE=@UNIDADE						,
 APLICACAO=@APLICACAO					,
 TAG=@TAG								,
 DRIVER=@DRIVER							,
 ARMAZEM=@ARMAZEM						,
 TIPO_SERVICO=@TIPO_SERVICO				,
 PRIORIDADE=@PRIORIDADE					,
 SETOR_APROVACAO=@SETOR_APROVACAO		,
 CONTRATO=@CONTRATO						,
 ARQUIVO_ANEXO=@ARQUIVO_ANEXO 			,
 NOME_ANEXO=@NOME_ANEXO					,
 DESCRICAO_ANEXO=@DESCRICAO_ANEXO 		,
 TIPO_ANEXO=@TIPO_ANEXO					,
 OBSERVACAO=@OBSERVACAO                                     



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
           ,'Solicitação serviço inserida na tabela integradora do bizagi'
           , 0) 
		   
		  
 

	
	fetch next from cursor_temp into 
			
 @ID					,
 @EMPRESAID				,
 @CODIGO 				,
 @EMPRESA 				,
 @FILIAL 				,
 @CENTRO_CUSTO			,
 @CLASSE_VALOR			,
 @ITEM_CONTA			,
 @SUB_ITEM_CONTA		,
 @DATA_EMISSAO			,
 @DATA_NECESSIDADE		,
 @STATUS				,
 @DATA_INCLUSAO			,
 @SOLICITANTE			,
 @ITEM					,
 @CONTA					,
 @PRODUTO				,
 @DESCRICAO				,
 @QUANTIDADE			,
 @UNIDADE				,
 @APLICACAO				,
 @TAG					,
 @DRIVER				,
 @ARMAZEM				,
 @TIPO_SERVICO			,
 @PRIORIDADE			,
 @SETOR_APROVACAO		,
 @CONTRATO				,
 @ARQUIVO_ANEXO 		,
 @NOME_ANEXO			,
 @DESCRICAO_ANEXO 		,
 @TIPO_ANEXO			
                        
end

close cursor_temp
deallocate cursor_temp

end


