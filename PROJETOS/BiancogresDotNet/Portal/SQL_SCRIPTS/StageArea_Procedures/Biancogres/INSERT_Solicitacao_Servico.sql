USE [BPORTAL]
GO

INSERT INTO [dbo].[Produto]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Nome])
select 
			0
		   ,2
           ,0
           ,0
           ,0, 
		   B1_COD, 
		   B1_DESC 
from DADOSADV.dbo.SB1010 where B1_COD LIKE '306%' 


INSERT INTO [dbo].[ClasseValor]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao]
		   ,[CentroCusto])
   													 
select 0
           ,2
           ,0
           ,0
           ,0, CODIGO, DESCRICAO, CC from DADOSADV.dbo.VW_BZ_CLASSE_VALOR


INSERT INTO [dbo].[Driver]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao]
		   ,[ClasseValorID])
					 
select 0
           ,2
           ,0
           ,0
           ,0
           ,
		   DRIVER, DESCRIC, (select  ID from ClasseValor where Codigo  COLLATE Latin1_General_BIN  = CLVL) 
from DADOSADV.dbo.VW_BZ_DRIVER
where 
exists (
 select  ID from ClasseValor where Codigo  COLLATE Latin1_General_BIN  = CLVL
)		   
		   

	INSERT INTO [dbo].[TAG]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao]
		   ,[ClasseValorID])
    select
           0
           ,2
           ,0
           ,0
           ,0
           ,
 CODIGO, TAG, (select  ID from ClasseValor where Codigo  COLLATE Latin1_General_BIN  = CV) 
from DADOSADV.dbo.VW_BZ_TAG
where 
exists (
 select  ID from ClasseValor where Codigo  COLLATE Latin1_General_BIN  = CV
)
          		   


			INSERT INTO [dbo].[Aplicacao]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao]
		   )
    select
           0
           ,2
           ,0
           ,0
           ,0
           ,
 CODIGO, APLICACAO
from DADOSADV.dbo.VW_BZ_APLICACAO				   


			INSERT INTO [dbo].[Armazem]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao]
		   )
    select
           0
           ,2
           ,0
           ,0
           ,0
           ,
 CODIGO, DESCRICAO
from DADOSADV.dbo.VW_BZ_ARMAZEM
	

INSERT INTO [dbo].[PrioridadeServico]
           ([StatusIntegracao]
           ,[EmpresaID]
           ,[Habilitado]
           ,[Deletado]
           ,[DeleteID]
           ,[Codigo]
           ,[Descricao])
     VALUES
           (0, 2, 0, 0, 0 ,'N','Normal'), (0, 2, 0, 0, 0 ,'U','Urgente'), (0, 2, 0, 0, 0 ,'E','Emergencial'), (0, 2, 0, 0, 0 ,'P','Parada')
GO


