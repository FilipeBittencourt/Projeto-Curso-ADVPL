#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia139A()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

If UPPER(ALLTRIM(FUNNAME())) == "EICDI154"
	Return ( "" )
EndIf

If IsInCallStack("MATA140")
	Return ( "" )
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("XXN,XCCAMPO,WPROD,WCLVL,")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 � BIA139	  � Autor � MICROSIGA VITORIA 	  � Data � 11/06/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Obriga a digitacao da Classe de Valor Solicitacao/Pedido 	낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � Interpretador x Base 										낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Private nPosProd, nPosCC

nPosProd := Ascan(aHeader,{|x| x[2] == "D1_COD    "})
nPosCLVL := Ascan(aHeader,{|x| x[2] == "D1_CLVL   "})

wProd := aCols[n,nPosProd]
wCLVL := aCols[n,nPosCC]

if Len(Alltrim(wProd)) == 7 .and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0	
        MsgStop("Para este Produto e obrigatorio a Classe de Valor...")
	    wCLVL := ""
endif
Return(wCLVL)