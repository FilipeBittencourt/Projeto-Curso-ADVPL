#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 27/04/01

User Function Bia612()        // incluido pelo assistente de conversao do AP5 IDE em 27/04/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WLOJA,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA612   � Autor � Cesar Magnago         � Data � 10/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para nao permitir que se digite um codigo de loja���
���          � do cadastro de forncedores com 1 caracter.                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: BIANCOGRES S/A                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

wLoja := M->A2_LOJA 

If Len(AllTrim(wLoja)) < 2
      MsgAlert("Este Codigo de Loja Nao e Valido - Favor Alterar")
      wLoja := SPACE(2)
Endif

// Substituido pelo assistente de conversao do AP5 IDE em 27/04/01 ==> __Return(wLoja)
Return(wLoja)   // incluido pelo assistente de conversao do AP5 IDE em 27/04/01