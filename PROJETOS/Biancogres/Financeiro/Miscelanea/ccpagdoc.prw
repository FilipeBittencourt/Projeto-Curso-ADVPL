#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

User Function ccPagdoc()        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_Doc,_Mod,_Banco")

/////  PROGRAMA GRAVAR AS INFORMACOES COMPLEMENTARES
/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (374-413)
_Banco :=SUBSTR(SE2->E2_CODBAR,1,3)
_Doc := ""
_Mod := SE2->E2_CODBAR


IF _Mod == "                                                            "
   IF SUBSTR(SE2->E2_YLINDIG,1,3) == "237"
      _Mod :=SE2->E2_YLINDIG  
      _Banco:=SUBSTR(SE2->E2_YLINDIG,1,3)
   ENDIF
ENDIF

IF _Mod <> "                                                            "
If _Mod = SE2->E2_CODBAR
  	_Doc:= SUBSTR(_Mod,20,25) 
  	_Doc:= _Doc + SUBSTR(_Mod,5,1) 
  	_Doc:= _Doc + SUBSTR(_Mod,4,1) 
//  	_Doc:= _Doc + SUBSTR(_Mod,33,1) // Agencia   	
//  	_Doc:= _Doc + SUBSTR(_Mod,4,1)  // Moeda
  	_Doc:= _Doc + "             "
Endif
Endif


If _Mod = SE2->E2_YLINDIG
  	_Doc:= SUBSTR(_Mod,20,44) 
  	_Doc:= _Doc + SUBSTR(_Mod,11,10) 
  	_Doc:= _Doc + SUBSTR(_Mod,22,10) 
  	_Doc:= _Doc + SUBSTR(_Mod,33,1) // Agencia   	
  	_Doc:= _Doc + SUBSTR(_Mod,4,1)
  	_Doc:= _Doc + "             "
Endif

IF _Banco<>"237"
	IF _Mod == "                                                            "
	_Doc:= SUBSTR(SE2->E2_YLINDIG,05,05)
	_Doc:= _Doc + SUBSTR(SE2->E2_YLINDIG,11,10)
	_Doc:= _Doc + SUBSTR(SE2->E2_YLINDIG,22,10)	
	_Doc:= _Doc + SUBSTR(SE2->E2_YLINDIG,33,01)		
	_Doc:= _Doc + "9"	
//	_Doc:= SUBSTR(SE2->E2_YLINDIG,20,44)	
//  	_Doc:= _Doc + "0000000000000"    
	Endif
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_DOC)
Return(_Doc)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
           
