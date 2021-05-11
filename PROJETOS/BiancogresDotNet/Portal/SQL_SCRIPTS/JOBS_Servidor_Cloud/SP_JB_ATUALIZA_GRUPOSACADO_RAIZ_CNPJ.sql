alter procedure SP_JB_ATUALIZA_GRUPOSACADO_RAIZ_CNPJ

with encryption
as
begin

declare @EmpresaID bigint
declare @raiz varchar(8)
declare @grupo_atu bigint
declare @first_nome varchar(max)

declare tab_raiz cursor fast_forward for

select
	EMPRESA_ID = EmpresaID,
	RAIZ = substring(CPFCNPJ,1,8),
	GRUPO = Min(isnull(GrupoSacadoID,0)),
	FIRSTNOME = Min(Nome)

	from Sacado
	where Len(RTrim(CPFCNPJ)) = 14
	group by EmpresaID, substring(CPFCNPJ,1,8)
	having count(1) > 1

open tab_raiz
fetch next from tab_raiz into @EmpresaID, @raiz, @grupo_atu, @first_nome

while @@FETCH_STATUS = 0
begin

	begin transaction

	print @raiz
	print @grupo_atu

	--criar novo grupo de sacado pela raiz do CNPJ
	if (@grupo_atu = 0)
	begin

		print 'insert new grupo'

		insert into GrupoSacado(InsertUser, InsertDate, EmpresaID, CodigoUnico, Nome, Habilitado, Deletado, DeleteID, StatusIntegracao)

		select
		InsertUser = 'JB_ATUALIZA_GRUPOSACADO_RAIZ_CNPJ', 
		InsertDate = GetDate(), 
		EmpresaID = @EmpresaID, 
		CodigoUnico = 'CNPJ'+@raiz,
		Nome = @first_nome,
		Habilitado = 1, 
		Deletado = 0, 
		DeleteID = 0, 
		StatusIntegracao = 0

		set @grupo_atu = @@IDENTITY

	end
	else
	begin

		print 'update grupo sacados'

	end

	if (@grupo_atu is null or @grupo_atu <= 0)
	begin

		rollback
		print 'ERRO GET IDENTITY GRUPO'
		return

	end

	update Sacado

	set GrupoSacadoID = @grupo_atu,
	LastEditDate = GETDATE(),
	LastEditUser = 'JB_ATUALIZA_GRUPOSACADO_RAIZ_CNPJ'

	where EmpresaID = @EmpresaID 
	and Habilitado = 1 
	and substring(CPFCNPJ,1,8) = @raiz
	and GrupoSacadoID is null

	commit

	fetch next from tab_raiz into @EmpresaID, @raiz, @grupo_atu, @first_nome
end
close tab_raiz
deallocate tab_raiz

end