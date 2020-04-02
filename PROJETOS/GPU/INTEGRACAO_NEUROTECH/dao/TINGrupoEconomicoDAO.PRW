#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINGrupoEconomicoDAO
@description Classe para buscar grupo economico do cliente
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/
Class TINGrupoEconomicoDAO From LongClassName

    Data oGrpEco

    Method New() Constructor
	Method GrpEcoCli(oCliente)
	Method GrpNeurot(cCodGrp) 

EndClass


//|Metódo construtor da classe |
Method New() Class TINGrupoEconomicoDAO

	::oGrpEco := ""

Return Self


Method GrpEcoCli(oCliente) Class TINGrupoEconomicoDAO

	Local cAlias  := GetNextAlias()

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	BeginSql Alias cAlias

		SELECT SZ9.Z9_FILIAL,
			SZ9.Z9_CODIGO,
			SZ9.Z9_DESC,
			SZ9.Z9_LCGRUPO,
			SZ9.Z9_CODCLI,
			SZ9.Z9_LOJA,
			SZ9.Z9_ORIGEM,
			(
				SELECT ISNULL(MAX(B.Z9_LCGRUPO) - SUM(SA1.A1_LC - SA1.A1_SALDUP), 0)
				FROM %Table:SZ9% B
					JOIN %Table:SA1% SA1
						ON SA1.A1_FILIAL = %xFilial:SA1%
							AND SA1.A1_COD = B.Z9_CODCLI
							AND SA1.A1_LOJA = B.Z9_LOJA
							AND SA1.%NotDel%
				WHERE B.Z9_FILIAL = SZ9.Z9_FILIAL
						AND B.Z9_CODIGO = SZ9.Z9_CODIGO
						AND B.%NotDel%
				GROUP BY B.Z9_FILIAL,
							B.Z9_CODIGO
			) AS 'SALDO_GRUPO'
		FROM %Table:SZ9% SZ9
		WHERE SZ9.Z9_FILIAL = %xFilial:SZ9%
			AND SZ9.Z9_CODCLI = %Exp:oCliente:cCodigo%
			AND SZ9.Z9_LOJA = %Exp:oCliente:cLoja%
			AND SZ9.%NotDel%

	EndSql

	(cAlias)->(dbGoTop())

    ::oGrpEco  := TINGrupoEconomicoModel():New()


		::oGrpEco:cFilialx    := (cAlias)->Z9_FILIAL
		::oGrpEco:cCodigo     := (cAlias)->Z9_CODIGO
		::oGrpEco:cDesc       := (cAlias)->Z9_DESC
		::oGrpEco:nLimiteGrp  := (cAlias)->Z9_LCGRUPO
		::oGrpEco:nSaldoGrp   := Round((cAlias)->SALDO_GRUPO,2)
		::oGrpEco:cCodCli     := (cAlias)->Z9_CODCLI
		::oGrpEco:cLoja       := (cAlias)->Z9_LOJA
		::oGrpEco:cOrigem     := (cAlias)->Z9_ORIGEM


	(cAlias)->(dbCloseArea())


Return ::oGrpEco





