GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[FNC_GET_GRUPO]
(
	@COD  varchar(6),
	@EMP varchar(2)
)
RETURNS varchar(2)
AS
BEGIN

	DECLARE @RET VARCHAR(2)
	
	IF (
		select COUNT(*) from HADES.DADOSADV.dbo.SA2010 
			where A2_COD = @COD 
			and D_E_L_E_T_= ''
			and A2_MSBLQL <> '1'
			and A2_TIPO = 'J'
			and A2_CGC <> ''
	) > 1
		SET @RET = '01'
	ELSE
		SET @RET = (
					select A2_LOJA from HADES.DADOSADV.dbo.SA2010 
					where	A2_COD = @COD 
					and D_E_L_E_T_= ''
					and D_E_L_E_T_= ''
					and A2_MSBLQL <> '1'
					and A2_TIPO = 'J'
					and A2_CGC <> ''
					)
		
	RETURN @RET

END