
alter procedure Sp_BPortal_Atualiza_Taxa_Fornecedores_Protheus
with encryption
as
begin

set nocount on

declare @ID 					bigint
declare @Taxa 					decimal(30,8)
declare @FornecedorCPFCNPJ 		varchar(max)
declare @CodigoERP 				varchar(max)


declare c_taxas cursor for

select ID , Taxa , FornecedorCPFCNPJ, CodigoERP  From TaxaAntecipacao
where StatusIntegracao = 2 AND Taxa > 0

open c_taxas
fetch next from c_taxas into @ID, @Taxa, @FornecedorCPFCNPJ, @CodigoERP
while @@fetch_status = 0
begin
	
	update HADES.DADOSADV.dbo.SA2010 
		 set A2_YTXANTE = @Taxa
			where A2_COD = @CodigoERP AND  A2_CGC = @FornecedorCPFCNPJ
		 
	update TaxaAntecipacao SET 
		StatusIntegracao = 4
		where ID = @ID
	
	fetch next from c_taxas into @ID, @Taxa, @FornecedorCPFCNPJ, @CodigoERP
end
close c_taxas
deallocate c_taxas
  

end