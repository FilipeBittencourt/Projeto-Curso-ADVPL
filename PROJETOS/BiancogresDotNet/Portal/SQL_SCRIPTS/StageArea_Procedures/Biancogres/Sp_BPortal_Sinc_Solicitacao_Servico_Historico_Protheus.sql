alter procedure Sp_BPortal_Sinc_Solicitacao_Servico_Historico_Protheus
with encryption
as
begin

set nocount on


if ( not (select OBJECT_ID('TEMP_TABdb.dbo.#TEMP_TAB')) is null ) drop table #TEMP_TAB

create table #TEMP_TAB
(
	[ID]						bigint,
	[EMPRESAID]					bigint,
	[MENSAGEM]					VARCHAR(MAX),
	[STATUS]					int
)
          		   
insert into #TEMP_TAB
(
	[ID]
	,[EMPRESAID]
	,[MENSAGEM]
	,[STATUS]
)

select 
distinct
SS.ID,
SS.EmpresaID,
'Geração da Cotação: '+COTACAO,
4
FROM SolicitacaoServico SS
join [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL] COT_PORTAL
	on CODIGO COLLATE  Latin1_General_BIN = SS.Numero
WHERE 1=1
and COT_PORTAL.STATUS = 'P'
AND not exists(
select 1 from  [dbo].[SolicitacaoServicoHistorico] SSH
where SolicitacaoServicoID = SS.ID
AND SSH.EmpresaID = SS.EmpresaID 
AND SSH.Status = 4
)

insert into #TEMP_TAB
(
	[ID]
	,[EMPRESAID]
	,[MENSAGEM]
	,[STATUS]
)

select 
distinct
SS.ID,
SS.EmpresaID,
'Geração do Pedido: '+PEDIDO,
5
FROM SolicitacaoServico SS
join [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL] COT_PORTAL
	on CODIGO COLLATE  Latin1_General_BIN = SS.Numero
WHERE 1=1
and COT_PORTAL.STATUS = 'P'
AND PEDIDO <> ''
AND not exists(
select 1 from  [dbo].[SolicitacaoServicoHistorico] SSH
where SolicitacaoServicoID = SS.ID
AND SSH.EmpresaID = SS.EmpresaID 
AND SSH.Status = 5
)

insert into #TEMP_TAB
(
	[ID]
	,[EMPRESAID]
	,[MENSAGEM]
	,[STATUS]
)

select 
distinct
SS.ID,
SS.EmpresaID,
'Geração do Contrato: '+CONTRATO,
6
FROM SolicitacaoServico SS
join [DADOSADV].[dbo].[BZINTEGRACAO_COTACAO_PORTAL] COT_PORTAL
	on CODIGO COLLATE  Latin1_General_BIN = SS.Numero
WHERE 1=1
and COT_PORTAL.STATUS = 'P'
AND CONTRATO <> ''
AND not exists(
select 1 from  [dbo].[SolicitacaoServicoHistorico] SSH
where SolicitacaoServicoID = SS.ID
AND SSH.EmpresaID = SS.EmpresaID 
AND SSH.Status = 6
)

--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from #TEMP_TAB)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ID							bigint
DECLARE @EMPRESAID					bigint
DECLARE @MENSAGEM 					VARCHAR(max)
DECLARE @STATUS 					INT


declare cursor_temp cursor fast_forward for
select 	
			[ID]
			,[EMPRESAID]
		   ,[MENSAGEM] 			
		   ,[STATUS]
from #TEMP_TAB

open cursor_temp
fetch next from cursor_temp into 
 
 
 @ID					,
 @EMPRESAID				,
 @MENSAGEM 				,
@STATUS	
                    
while @@FETCH_STATUS = 0
begin

		print 'update'
	
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
           ,@MENSAGEM
           , @STATUS) 
		   
		  
 

	
	fetch next from cursor_temp into 
		
 @ID					,
 @EMPRESAID				,
 @MENSAGEM 				,
@STATUS	
                         
end

close cursor_temp
deallocate cursor_temp

end


