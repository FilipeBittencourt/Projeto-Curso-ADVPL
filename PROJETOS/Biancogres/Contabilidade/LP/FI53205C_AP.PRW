#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI53205C()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CIND,CRECNO,NVALOR,CPREF,CNUM")
SetPrvt("CPARC,NVLRTIT,CTIPO,XVALOR,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 53205C   � Autor � Cesar Magnago         � Data � 23/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao do valor do des-  ���
���          � conto obtido que e digitado no campo E2_YDESCON.           ���
���          � Lancamento Padronizado 53205 ( Conta a Credito )           ���
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
cPref   := SE2->E2_PREFIXO 
cNum    := SE2->E2_NUM    
cParc   := SE2->E2_PARCELA 
nVlrTit := SE2->E2_VALOR
cTipo   := "AB-"
xValor  := IF(SE2->E2_YDESCON>0,SE2->E2_YDESCON,SE2->E2_DESCONT)

DbSelectArea("SE2")
DbSetOrder(1)

If DbSeek(xFilial("SE2")+cPref+cNum+cParc+cTipo,.F.)
   nValor := SE2->E2_VALOR
Else
   nValor := xValor
Endif

DbSelectArea(cAlias)
DbSetOrder(cInd)
DbGoTo(cRecNo)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nValor)
Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04