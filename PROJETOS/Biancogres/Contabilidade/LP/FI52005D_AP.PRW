#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI52005D()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CIND,CRECNO,NVALOR,CPREF,CNUM")
SetPrvt("CPARC,NVLRTIT,XVALOR,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 52005D   � Autor � Cesar Magnago         � Data � 23/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao do valor exato    ���
���          � dos Desc. dos Cheques que substituem os Titulos a Receber. ���
���          � Lancamento Padronizado 52005 ( Conta a Debito )            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: INCESA                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias  := Alias()
cInd    := IndexOrd()
cRecNo  := RecNo()
nValor  := 0
cPref   := SE1->E1_YPREFOR
cNum    := SE1->E1_YNUMOR
cParc   := SE1->E1_YPARCOR
nVlrTit := SE1->E1_VALOR
xValor  := SE1->E1_DESCONT

DbSelectArea("SE1")
DbSetOrder(1)

If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
   If SE1->E1_DESCONT > 0
      nValor := SE1->E1_DESCONT
   EndIf
Else
   nValor := xValor
Endif

DbSelectArea(cAlias)
DbSetOrder(cInd)
DbGoTo(cRecNo)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nValor)
Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04