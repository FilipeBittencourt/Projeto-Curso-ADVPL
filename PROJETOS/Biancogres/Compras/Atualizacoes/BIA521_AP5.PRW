#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia521()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CFLAG,CPEDIDO,CQUJE,CENCER,CQUANT,")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � GERENCIAL  � Autor � Cesar Magnago         � Data � 18/05/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Coloca Residuo na Autorizacao de Entrega SC7                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Interpretador xBase                                          낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Dbselectarea("SC7")
Dbsetorder(1)
Dbgotop()
cFlag    := "S"

While cFlag == "S"

    cPedido  := SPACE(6)
    cQuje    := 0
    cEncer   := SPACE(1)

    @ 96,42 TO 300,505 DIALOG oDlg1 TITLE "Entrada de Dados"

    @ 05,30 SAY "Nr.Autoriz: "
    @ 05,70 GET cPedido  PICTURE "@!R"

    @ 83,200 BMPBUTTON TYPE 1 ACTION Close(oDlg1)
    ACTIVATE DIALOG oDlg1 CENTERED

    DbSeek(xFilial("SC7")+cPedido,.T.)

    If !Found()
       Alert("N꼘 Encontrou a Autorizacao")
       cFlag := "N"
       LOOP
    Endif

    If !RecLock("SC7",.F.)
       Alert("Registro em Uso por Outra Esta뇙o")
       LOOP
    Endif

    @ 96,42 TO 300,505 DIALOG oDlg1 TITLE "Entrada de Dados"


    @ 05,30 SAY "Nr.Autoriz: "
    @ 05,70 SAY cPedido  PICTURE "@!R"

    @ 83,170 BMPBUTTON TYPE 1 ACTION Fgrava()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     @ 83,170 BMPBUTTON TYPE 1 ACTION Execute(Fgrava)
    @ 83,200 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    ACTIVATE DIALOG oDlg1 CENTERED

End

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura Tela e Set's                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//Set Device To
//RestScreen(3,0,24,79,cSavScr1)

Return( NIL )

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � FGrava   � Autor � Cesar Magnago         � Data � 18/05/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Grava SC7                                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Generico RDMAKE                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Fgrava
Static Function Fgrava()

While C7_NUM == cPedido

    RecLock("SC7")

    If C7_QUANT - C7_QUJE <> 0
       Replace C7_RESIDUO  With "S"
    Endif

    Dbunlock()
    Dbskip()

End

Close(oDlg1)
Return
