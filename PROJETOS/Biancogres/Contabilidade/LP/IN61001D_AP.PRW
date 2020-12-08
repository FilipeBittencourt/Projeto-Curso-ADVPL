#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN61001D()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WALIAS,CNUM,WCONTA,")

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IN61001D � Autor � MICROSIGA - VITORIA   � Data � 15/12/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lancto 610 - Cliente - Debito                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
wAlias   := Alias()
cNum     := SD2->D2_PEDIDO
wConta   := ""

dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial("SC5")+cNum,.F.)
   If SC5->C5_CONDPAG == "500" // Antecipado
      //wConta := "211060001"
      wConta := "112010001"
   Else
      wConta := SA1->A1_CONTA
   EndIf
EndIf
dbSelectArea(wAlias)
RetIndex("SC5")
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(wConta)
Return(wConta)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04