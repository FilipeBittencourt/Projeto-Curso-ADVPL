#INCLUDE "PROTHEUS.CH"

User Function DTGARANTIA

Local dVenda := M->AA3_DTVEND
Local dInst := M->AA3_DTINST
Local nYears, nMonth
Local dGVend, dGInst, dRet

If ((Month(dVenda) + 18)/12) > 2
	nYears := 2
Else
	nYears := 1
EndIf

If Month(dVenda) + 6 > 12
	nMonth := Month(dVenda) + 6 - 12
Else
	nMonth := Month(dVenda) + 6
EndIf

dGVend := STOD( STRZERO(Year(dVenda) + nYears,4)  + STRZERO(nMonth,2) +  STRZERO(Day(dVenda),2) )

IF !Empty(dInst)

	dGInst := STOD( STRZERO(Year(dInst) + 1,4)  + STRZERO(Month(dInst),2) +  STRZERO(Day(dInst),2) )
	
ELSE
	
	dGInst := CTOD(" ")
	
ENDIF

If dGInst < dGVend
	dRet := dGInst
Else
	dRet := dGVend
EndIf

Return dRet
