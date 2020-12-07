#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoMES
@description Classe com ferramentas para integração com o MES
@author Gabriel Mafioletti
@since 22/07/2019
@version 1.0
@type class
/*/

Class TIntegracaoMES From LongClassName

	Data aLinhas

	Method New() Constructor
	Method GetLinha()

EndClass

Method New() Class TIntegracaoMES

	::aLinhas	:=	{}

Return

Method GetLinha() Class TIntegracaoMES

	Local _cAlias	:=	GetNextAlias()

	::aLinhas	:=	{} //Caso Seja Chamado de uma classe já instanciada zera as linhas

	BeginSql Alias _cAlias
		%NoParser%
		SELECT DISTINCT ZCO_LINHA LINHA
		FROM %TABLE:ZCO% ZCO WITH(NOLOCK)
		WHERE ZCO_FILIAL = %XFILIAL:ZCO%
		AND ZCO_ITGMES = '1'
		AND %NotDel%
	EndSql

	While (_cAlias)->(!EOF())

		aAdd(::aLinhas,(_cAlias)->LINHA)
		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return
