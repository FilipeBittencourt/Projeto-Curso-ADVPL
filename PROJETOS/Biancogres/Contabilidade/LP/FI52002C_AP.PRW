#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI52002C()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CPREF,CNUM,CPARC,CDESC,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 52002C   � Autor � Cesar Magnago         � Data � 23/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao do valor exato    ���
���          � dos Cheques que substituem os Titulos a Receber.           ���
���          � Lancamento Padronizado 52002 ( Conta a Credito )           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: INCESA                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias  := Alias()

cPref   := SE5->E5_PREFIXO
cNum    := SE5->E5_NUMERO
cParc   := SE5->E5_PARCELA

DbSelectArea("SE1")
DbSetOrder(1)

If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
   cPref   := SE1->E1_YPREFOR
   cNum    := SE1->E1_YNUMOR
   cParc   := SE1->E1_YPARCOR
EndIf

cDesc := SE1->E1_YNUMOR+"/"+SE1->E1_YPARCOR

DbSelectArea(cAlias)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(cDesc)
Return(cDesc)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
