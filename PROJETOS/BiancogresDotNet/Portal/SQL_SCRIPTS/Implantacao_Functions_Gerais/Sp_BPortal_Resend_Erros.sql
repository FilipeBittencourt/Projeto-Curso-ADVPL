create procedure Sp_BPortal_Resend_Erros
as
begin

update Sacado set StatusIntegracao = 0 where StatusIntegracao = 3

update Boleto set StatusIntegracao = 0 where StatusIntegracao = 3

end