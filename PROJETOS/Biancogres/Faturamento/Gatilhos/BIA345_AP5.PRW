#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

User Function BIA345()        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("WSYOUTDSC,WSMV,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un눯o    � BIA345   � Autor � Magnago               � Data � 09/07/01 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri눯o � Bloqueia a Liberacao dos Pedidos de Vendas                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � RDMAKE                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
IF ALLTRIM(FUNNAME()) <> "EECAP100"
	wsYoutDsc := M->C5_YPERC
	wLinha    := M->C5_YLINHA
	
	If wLinha == "1"
	   wsMV := GetMv("MV_YMAXPER")
	else
	   wsMV := GetMv("MV_YMXPER2")
	endif
	
	If wsYoutDsc > wsMV
	   MsgAlert("O Percentual Digitado e Maior do que o Limite de "+Str(wsMV)+"%")
	   wsYoutDsc := 0
	EndIf
ELSE
	wsYoutDsc := M->EE7_YPERC
	wLinha    := M->EE7_YLINHA
	
	If wLinha == "1"
	   wsMV := GetMv("MV_YMAXPER")
	else
	   wsMV := GetMv("MV_YMXPER2")
	endif
	
	If wsYoutDsc > wsMV
	   MsgAlert("O Percentual Digitado e Maior do que o Limite de "+Str(wsMV)+"%")
	   wsYoutDsc := 0
	EndIf

END IF
// Substituido pelo assistente de conversao do AP5 IDE em 24/05/02 ==> __Return(wsYoutDsc)
Return(wsYoutDsc)        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02
