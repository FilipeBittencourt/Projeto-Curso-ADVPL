
alter procedure Sp_BPortal_Cancela_Antecipacao
with encryption
as
begin

set nocount on

declare @ID 					bigint
declare @EmpresaID				bigint
declare @UnidadeID				bigint
declare @UsuarioID				bigint

declare c_cursor cursor for

select ID, EmpresaID, UnidadeID from [dbo].[Antecipacao]
where convert(date, DataRecebimento) <  convert(date, GETDATE())
and Status = 1 and Origem = 0

open c_cursor
fetch next from c_cursor into @ID, @EmpresaID, @UnidadeID
while @@fetch_status = 0
begin
	
	update [dbo].[Antecipacao] SET Status = 9 where ID = @ID

	SET @UsuarioID = (select TOP 1 UsuarioID from [AntecipacaoHistorico] where AntecipacaoID = @ID)
	
	INSERT INTO [dbo].[AntecipacaoHistorico]
           ([InsertUser]
           ,[InsertDate]
           ,[EmpresaID]
           ,[UnidadeID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[AntecipacaoID]
           ,[UsuarioID]
           ,[DataEvento]
           ,[Observacao]
           ,[Status]
           ,[StatusIntegracao]
           )
     VALUES
           ('procedure'
           ,GETDATE()
           ,@EmpresaID
           ,@UnidadeID
           ,1
           ,0
           ,0
           ,@ID
           ,@UsuarioID
           ,GETDATE()
           ,'Cancelamento interno antecipação procedure'
           ,9
           ,0
           )
		   
	
	fetch next from c_cursor into  @ID, @EmpresaID, @UnidadeID
end
close c_cursor
deallocate c_cursor
  

end