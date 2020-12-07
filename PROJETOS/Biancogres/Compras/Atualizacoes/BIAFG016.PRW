#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG016
@author Gabriel Rossi Mafioletti
@since 14/08/2017
@version 1.0
@description Validação referente ao campo D1_OP 
@type function
/*/

User Function BIAFG016()

	Local _lRet		:=	.T.
	Local _aArea	:= GetArea()	
	Local _nI
	Local _nQtdTe	:=	0
	Local _nSaldo	:=	0
	Local _cAlias	:=	GetNextAlias()
	Local _cOp		

	If GetNewPar("MV_YFATGRP",.F.) .And.  cEmpAnt == "05"  .And. cA100For == '000534'

		_cTipProd := Posicione("SB1", 1, xFilial("SB1") + GdFieldGet("D1_COD",n), "B1_TIPO" ) 
		If _cTipProd == "PP"

			For _nI	:=	1 to Len(aCols)

				_cTipProd := Posicione("SB1", 1, xFilial("SB1") + GdFieldGet("D1_COD",_nI), "B1_TIPO" ) 
				If _nI <> n .And. !GdDeleted(_nI) .And. !Empty(GdFieldGet("D1_OP",_nI)) .AND. GdFieldGet("D1_OP",_nI) == M->D1_OP .AND. _cTipProd == "PP"
					_nQtdTe	+= GdFieldGet("D1_QUANT",_nI)	
				EndIf

			Next _nI

			_cOp	:=	M->D1_OP

			BeginSql Alias _cAlias

			SELECT ISNULL(SUM(C2_QUANT - C2_QUJE),0) AS QTD
			FROM %TABLE:SC2% SC2
			WHERE C2_FILIAL = %XFILIAL:SC2%
			AND C2_NUM + C2_ITEM+ C2_SEQUEN + C2_ITEMGRD  = %Exp:_cOp%
			AND SC2.%NotDel%
			EndSql

			If (_cAlias)->QTD - _nQtdTe < GdFieldGet("D1_QUANT",n)
				MsgInfo("Não Há Saldo Suficiente na OP para o Produto! Verifique se o Mesmo não foi Digitado na Nota Atual!")
				_lRet	:=	.F.
			EndIf

			(_cAlias)->(DbCloseArea())

		EndIf

	EndIf

	RestArea(_aArea)

Return _lRet
