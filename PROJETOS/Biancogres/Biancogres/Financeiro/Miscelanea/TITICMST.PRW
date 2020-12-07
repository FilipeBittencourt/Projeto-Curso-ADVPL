
/*/{Protheus.doc} TITICMST
@author Fernando Rocha - Facile
@since 19/09/16
@version 1.0
@description P.E. para ajustar Prefixo/Número no Contas a Pagar, referente a ICMS ST e DIFAL 
@obs OS: 4641-15 - Mikaelly
@type function
/*/

User Function TITICMST
Local	cOrigem		:=	PARAMIXB[1]
Local	cTipoImp	:=  PARAMIXB[2]
Local 	cAliasTmp

If AllTrim(cOrigem)='MATA460A'

	//pesquisa se nao existe titulo com a mesma chave
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%
	
	SELECT 1 FROM %Table:SE2% (nolock) 
		WHERE 	E2_FILIAL 	= %XFilial:SE2% 
			AND E2_PREFIXO 	= %Exp:SF2->F2_SERIE%
			AND E2_NUM		= %Exp:SF2->F2_DOC%
			AND E2_PARCELA	= %Exp:SE2->E2_PARCELA%
			AND E2_TIPO		= %Exp:SE2->E2_TIPO%
			AND E2_FORNECE	= %Exp:SE2->E2_FORNECE%
			AND E2_LOJA		= %Exp:SE2->E2_LOJA%   
	
	EndSql
	
	(cAliasTmp)->(DbGoTop())
	If (cAliasTmp)->(Eof())

		//Altera titulo de imposto para ter o numero da nf
		//SE2->E2_PREFIXO	:= SF2->F2_SERIE
		//SE2->E2_NUM		:= SF2->F2_DOC
		
		//A CHAVE SERA GRAVA EM UM NOVO CAMPO, POIS O SISTEMA NAO ACEITA MUDAR O CAMPO E2_PREFIXO - ERRO NA EXCLUSÃO DA NF 
		SE2->E2_YNFGUIA	:= SF2->F2_SERIE+SF2->F2_DOC 	
	
	EndIf
	(cAliasTmp)->(DbCloseArea())
	
EndIf

Return {SE2->E2_NUM,SE2->E2_VENCTO}