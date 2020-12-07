#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG080
@author Gabriel Rossi Mafioletti
@since 06/03/2019
@version 1.0
@description Ponto de entrada após a inclusão da op e explosão das op's filhas
@type function
/*/

User Function MTA650I()

	Local _cClVl	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	Local _cLinha	:=	""
	Local _cClVl	:=	""

	If SC2->C2_SEQUEN == "001" //OP Mãe
		U_BFG73CVM(SC2->C2_LINHA, SC2->C2_PRODUTO,@_cClvl,@_cLinha)
	Else //OP's Filhas
		BeginSql Alias _cAlias
			%NoParser%
			SELECT *
			FROM %TABLE:SC2% (NOLOCK)
			WHERE C2_FILIAL = %XFILIAL:SC2%
				AND C2_NUM = %Exp:SC2->C2_NUM%
				AND C2_ITEM = %Exp:SC2->C2_ITEM%
				AND C2_SEQUEN = '001'
				AND %NotDel%
		
		EndSql
		U_BFG73CVI(SC2->C2_PRODUTO,(_cAlias)->C2_PRODUTO,(_cAlias)->C2_LINHA,@_cClvl,@_cLinha)
		(_cAlias)->(DbCloseArea())
	EndIf

	

	Reclock("SC2",.F.)
	SC2->C2_CLVL	:=	_cClvl
	SC2->C2_LINHA	:=	_cLinha
	SC2->(MsUnlock())		

Return