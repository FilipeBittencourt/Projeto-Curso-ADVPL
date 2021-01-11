#include "PROTHEUS.CH"

User Function FROPGA04() 

	Local _nPosQtdV	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	Local _cNRESER	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YNRESER"})]
	
	If (!Empty(_cNRESER))
		MsgAlert('O campo quantidade foi zerado.')
		aCols[N][_nPosQtdV] := 0
	EndIf

Return _cNRESER

