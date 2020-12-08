#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia057()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WALIAS,WNATUR,")

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA057     � Autor � CESAR MAGNAGO         � Data � 27/09/99 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Determina que a natureza do fornecedor sera sempre analitica ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador x Base                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

wAlias   := Alias()
wNatur   := M->A2_NATUREZ
DbSelectArea("SED")
DbSeek(xFilial("SED")+wNatur,.T.)

If SED->ED_YCLASSE == "S"
   MsgAlert("Natureza Nao Pode Ser Sintetica, Tem Que Ser Analitica")
   wNatur  := SPACE(10)
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(wNatur)
Return(wNatur)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01