#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG019
@author Gabriel Rossi Mafioletti
@since 21/08/2017
@version 1.0
@description Rotina para forçar recálculo da OP
@type function
/*/


User Function BIAFG019()

	Local _cAlias	:=	GetNextAlias()
	Local _aArea	:=	GetArea()
	
	BeginSql Alias _cAlias
		SELECT  *
		FROM    %TABLE:SC2% SC2
		WHERE   SC2.C2_FILIAL = %Exp:SC2->C2_FILIAL%
		        AND SC2.C2_NUM = %Exp:SC2->C2_NUM%
		        AND SC2.C2_ITEM = %Exp:SC2->C2_ITEM%
		        AND SC2.C2_SEQUEN <> '001'
		        AND SC2.%NotDel%
	EndSql
	
	If (_cAlias)->(!EOF())
		MsgInfo("É Necessário Excluir as OP's Secundárias!'","BIAFG019")
		Return
	EndIf

	(_cAlias)->(DbCloseArea())

	DbSelectArea("SD4")
	SD4->(DbSetOrder(2))
	If SD4->(DbSeek(SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
		While SD4->(!EOF()) .And. SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM $ SD4->D4_FILIAL + D4_OP
			Reclock("SD4",.F.)
			SD4->(DbDelete())
			SD4->(MsUnlock())
			SD4->(DbSkip())
		EndDo 
	EndIf

	Reclock('SC2',.F.)
	SC2->C2_BATCH	:=	""
	SC2->C2_BATUSR	:=	__cUserID
	SC2->(MsUnlock())
	MsgInfo("OP Marcada para Recálculo, Favor sair da Rotina para que Sejam calculadas as OP's Secundárias!'","BIAFG019")
	RestArea(_aArea)
Return