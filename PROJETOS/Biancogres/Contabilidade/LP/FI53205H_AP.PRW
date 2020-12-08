#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI53205H()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CIND,CRECNO,NVALOR,CPREF,CNUM")
SetPrvt("CPARC,NVLRTIT,CTIPO,XHIST,CFORNECE,CLOJA")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 53205H   � Autor � Cesar Magnago         � Data � 25/09/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para trazer o historico dos titulos com desconto ���
���          � obtido da Nacional Gas Butano.                             ���
���          � Lancamento Padronizado 53205 ( Conta a Credito )           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: INCESA                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias   := Alias()
cInd     := IndexOrd()
cRecNo   := RecNo()
nValor   := 0
cPref    := SE2->E2_PREFIXO 
cNum     := SE2->E2_NUM    
cParc    := SE2->E2_PARCELA 
nVlrTit  := SE2->E2_VALOR
cTipo    := "AB-"
xHist    := ""
cFornece := SE2->E2_FORNECE
cLoja    := SE2->E2_LOJA

DbSelectArea("SE2")
DbSetOrder(1)

If DbSeek(xFilial("SE2")+cPref+cNum+cParc+cTipo,.F.)
   xHist  := AllTrim(SE2->E2_TIPO)+" "+AllTrim(SE2->E2_NUM)+"/"+SE2->E2_PARCELA
Endif

If cFornece+cLoja == "00139601"
   xHist  := cTipo+" "+AllTrim(SE2->E2_NUM)+"/"+SE2->E2_PARCELA
Endif

DbSelectArea(cAlias)
DbSetOrder(cInd)
DbGoTo(cRecNo)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(xHist)
Return(xHist)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04