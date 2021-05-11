alter procedure Sp_BPortal_Sinc_AtendimentoMedicao_Protheus
with encryption
as
begin

set nocount on

declare @ID 					bigint

declare c_cursor cursor for

select ID From AtendimentoMedicao
where StatusIntegracao = 0 

open c_cursor
fetch next from c_cursor into @ID
while @@fetch_status = 0
begin
	
	delete from [DADOSADV].[dbo].[BZINTEGRACAO_PREAE_ANEXO] where ID = @ID
	
	INSERT INTO [DADOSADV].[dbo].[BZINTEGRACAO_PREAE_ANEXO]
           ([ID]
           ,[BZ_NUM_PROC]
           ,[NOME]
           ,[TIPO]
           ,[DESCRICAO]
           ,[ARQUIVO]
           ,[DATA])
		 select atm.[ID]
		,[Numero] 
      ,[Nome]
      ,[Tipo]
      ,[Descricao]
      ,[Arquivo]
	  ,getdate()
     From AtendimentoMedicao  atm
	 join [dbo].[Atendimento] at ON at.ID = atm.AtendimentoID where atm.ID = @ID
		   
	update AtendimentoMedicao SET 
		StatusIntegracao = 4
		where ID = @ID
	
	fetch next from c_cursor into @ID
end
close c_cursor
deallocate c_cursor
  
end

