
alter procedure Sp_BPortal_Atualiza_Status_Atendimento_Protheus
with encryption
as
begin

set nocount on

declare @ID 					bigint

declare c_cursor cursor for

select ChaveUnica From Atendimento
where StatusIntegracao = 2 AND Status = 1

open c_cursor
fetch next from c_cursor into @ID
while @@fetch_status = 0
begin
	
	update DADOSADV.dbo.BZINTEGRACAO_PREAE 
		 set STATUS = 'P'
			where ID = @ID
		 
	update Atendimento SET 
		StatusIntegracao = 4
		where ID = @ID
	
	fetch next from c_cursor into @ID
end
close c_cursor
deallocate c_cursor
  

end