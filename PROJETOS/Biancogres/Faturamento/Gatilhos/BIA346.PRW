#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

User Function BIA346()        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WSVLRFRE,WSMV,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � BIA346   � Autor � Ranisses A. Corona    � Data � 20/01/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Bloqueia o Valor do Seguro se for maior que o Parametro    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RDMAKE                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

wsVlrFre := M->C5_VLRFRET
wsMV     := GetMv("MV_YMAXFRE")

If wsVlrFre > wsMV
   MsgAlert("O Valor do Seguro do Frete e Maior do que o Limite de "+Str(wsMV)+" centavos.")
   wsVlrFre := 0
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 24/05/02 ==> __Return(wsYoutDsc)
Return(wsVlrFre)        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02