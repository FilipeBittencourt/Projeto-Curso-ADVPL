#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} tAcessosOrcamento
@description Classe com ferramentas para Acesso ao Orçamento
@author Gabriel Mafioletti
@since 23/07/2019
@version 1.0
@type class
/*/

Class tAcessosOrcamento From LongClassName

	Data aAcessos

	Method New() Constructor
	Method GetAcessos(_cVersao,_cRevisao,_cAnoRef,_cTipo,_cUser)

EndClass

Method New() Class tAcessosOrcamento

	::aAcessos	:=	{}

Return

Method GetAcessos(_cVersao,_cRevisao,_cAnoRef,_cTipo,_cUser) Class tAcessosOrcamento

	Local _cAlias	:=	GetNextAlias()

	::aAcessos	:=	{}
	
	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZB9% ZB9
		WHERE ZB9_FILIAL = %XFILIAL:ZB9%
			AND ZB9_VERSAO = %Exp:_cVersao%
			AND ZB9_REVISA = %Exp:_cRevisao%
			AND ZB9_ANOREF = %Exp:_cAnoRef%
			AND ZB9_USER = %Exp:_cUser%
			AND ZB9_TPORCT = %Exp:_cTipo%
			AND %NotDel%

	EndSql
	
	While (_cAlias)->(!EOF())
	
		(_cAlias)->(aAdd(::aAcessos,{;
							ZB9_CLVL,;
							ZB9_VISUAL == '1',;
							ZB9_DIGIT == '1';
						}))
	
		(_cAlias)->(DbSkip())
	EndDo
Return