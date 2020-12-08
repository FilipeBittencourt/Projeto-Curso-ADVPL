#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI53206X()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CIND,CRECNO,NVALOR,XVALOR,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 53206X   � Autor � Cesar Magnago         � Data � 23/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao do valor do pagto ���
���          � a fornecedores no parametro FIN090-05.                     ���
���          � Lancamento Padronizado 53206                               ���
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
xValor  := MV_PAR05
nValor  := If(xValor > 0,xValor,0)

DbSelectArea(cAlias)
DbSetOrder(cInd)
DbGoTo(cRecNo)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nValor)        
Return(nValor)                // incluido pelo assistente de conversao do AP6 IDE em 08/03/04