#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia008()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CFLAG,CPEDIDO,CQUJE,CENCER,CQUANT,")

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � GERENCIAL  � Autor � Cesar Magnago         � Data � 18/05/99 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Encerra Pedido de Compra em Aberto Arquivo SC7               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

    @ 05,30 SAY "Nr.Pedido : "
    @ 05,70 GET cPedido  PICTURE "@!R"

    @ 83,200 BMPBUTTON TYPE 1 ACTION Close(oDlg1)
    ACTIVATE DIALOG oDlg1 CENTERED

    DbSeek(xFilial("SC7")+cPedido,.T.)

    If !Found()
       Alert("N�o Encontrou o Nr. Pedido ")
       cFlag := "N"
       LOOP
    Endif

    If !RecLock("SC7",.F.)
       Alert("Registro em Uso por Outra Esta��o")
       LOOP
    Endif

    @ 96,42 TO 300,505 DIALOG oDlg1 TITLE "Entrada de Dados"


    @ 05,30 SAY "Nr.Pedido : "
    @ 05,70 SAY cPedido  PICTURE "@!R"

    @ 83,170 BMPBUTTON TYPE 1 ACTION Fgrava()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     @ 83,170 BMPBUTTON TYPE 1 ACTION Execute(Fgrava)
    @ 83,200 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    ACTIVATE DIALOG oDlg1 CENTERED

End

//������������������������������������������������������������������������Ŀ
//� Restaura Tela e Set's                                                  �
//��������������������������������������������������������������������������
//Set Device To
//RestScreen(3,0,24,79,cSavScr1)

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FGrava   � Autor � Cesar Magnago         � Data � 18/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava SC7                                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico RDMAKE                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Fgrava
Static Function Fgrava()

While C7_NUM == cPedido

    RecLock("SC7")

    cQuant   := C7_QUANT
    cEncer   := "E"

    If C7_QUANT - C7_QUJE <> 0
       Replace C7_QUJE  With cQuant
       Replace C7_ENCER With cEncer 
    Endif

    Dbunlock()
    Dbskip()

End

Close(oDlg1)
Return