#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia046()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,WQUANT,WPED,WITEM,WSEQ,WC9_ORD")
SetPrvt("WC9_RECNO,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � BIA046   � Autor � SIGA Vitoria          � Data � 20/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Testa quantidade do Romaneio                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFAT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias := Alias()
wQuant := aCols [n] [7]
wPed   := aCols [n] [2]
wItem  := aCols [n] [4]
wSeq   := aCols [n] [5]
DbSelectArea("SC9")
wC9_Ord   := IndexOrd()
wC9_Recno := Recno()
DbSetOrder(1)
If DbSeek(xFilial("SC9")+wPed+wItem+wSeq,.F.)
   If wQuant > C9_QTDLIB
      Help(1," ","Y_BIA046")
      wQuant := SC9->C9_QTDLIB
   Endif
Endif
DbSetOrder(wC9_Ord)
DbGoto(wC9_Recno)
DbSelectArea(cAlias)
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(wQuant)
Return(wQuant)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01