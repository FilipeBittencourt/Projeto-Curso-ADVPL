alter procedure Sp_BPortal_Sinc_SolComp_Portal_Integrada_Protheus
with encryption
as
begin

set nocount on


if ( not (select OBJECT_ID('TEMP_TABdb.dbo.#TEMP_TAB')) is null ) drop table #TEMP_TAB

create table #TEMP_TAB
(
	[ID]						bigint,
	[EMPRESAID]					bigint,
	[STATUS]					int
)
          		   
insert into #TEMP_TAB
(
		   [ID]
		   ,[EMPRESAID]
		   ,[STATUS]
)

select 
SS.ID,
SS.EmpresaID,
Status = (case when BZ.STATUS = 'P' or BZ.STATUS = 'A'  then 2 else 3 end)
FROM SolicitacaoServico SS
INNER JOIN  [DADOSADV].[dbo].[BZINTEGRACAO_SOLCOMP_PORTAL]  BZ ON CODIGO  COLLATE  Latin1_General_BIN = Numero
WHERE 
PROCESSO_BIZAGI IS NOT NULL
AND Status = 1




--------------------PROCESSAMENTO DA CARGA----------------------------------
declare @numrec varchar(100) = rtrim(convert(varchar,(select count(1) from #TEMP_TAB)))
print 'processando: ' + @numrec + ' registros'

DECLARE @ID							bigint
DECLARE @EMPRESAID					bigint
DECLARE @STATUS 					INT

declare cursor_temp cursor fast_forward for
select 	
			[ID]
			,[EMPRESAID]
		   ,[STATUS] 			
from #TEMP_TAB

open cursor_temp
fetch next from cursor_temp into 
 
 
 @ID					,
 @EMPRESAID				,
 @STATUS 				
                    
while @@FETCH_STATUS = 0
begin

		print 'update'
		
	UPDATE SolicitacaoServico SET Status = @STATUS WHERE ID = @ID
 


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
           ,'Solicitação serviço integrada com bizagi'
           , 0) 
		   
		  
 

	
	fetch next from cursor_temp into 
			
  @ID					,
 @EMPRESAID				,
 @STATUS 				
                        
end

close cursor_temp
deallocate cursor_temp

end


