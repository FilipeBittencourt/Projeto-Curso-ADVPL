#include "topconn.ch"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} BIAFG039
@author Gabriel Rossi Mafioletti
@since 26/04/2018
@version 1.0
@description Gatilho para verifica��o de Tabela de Custo de Produtos de OP
@type function
/*/
//Ticket 30466 - RETIRAR A TRAVA QUE BLOQUEIA O LAN�AMENTO DE ORDEM DE PRODU��O CASO O PA N�O TENHA CUSTO PADR�O CADASTRADO.

User Function BIAFG039()

	Local _lRet	:=	.T.
/*
	Local _aArea	:=	GetArea()
	
	DbSelectArea("ZZ5")
	ZZ5->(DbSetOrder(2))
	
	If ZZ5->(DbSeek(xFilial("ZZ5")+ SUBSTR(M->C2_PRODUTO,1,7)))
			_lRet	:=	.T.
	Else
		MsgInfo("Produto n�o possui cadastro na tabela de custos!")
	EndIf	
	
	RestArea(_aArea)
*/
Return _lRet
