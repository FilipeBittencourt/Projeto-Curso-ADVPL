#include "rwmake.ch"
                     

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca o campo livre do codigo de barras ou da linha digitável³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

User Function PagcLiv

_cCampoLivre := ""
_cLinDig     := SE2->E2_YLINDIG                                
                             
If Empty(SE2->E2_CODBAR)
   _cCampo1    := SubStr(_cLinDig,05,05)
   _cCampo2    := SubStr(_cLinDig,11,10)
   _cCampo3    := SubStr(_cLinDig,22,10)
   _cCampoLivre:= _cCampo1+_cCampo2+_cCampo3
Else
   _cCampoLivre:= SubStr(SE2->E2_CODBAR,20,25)
EndIf


Return(_cCampoLivre)