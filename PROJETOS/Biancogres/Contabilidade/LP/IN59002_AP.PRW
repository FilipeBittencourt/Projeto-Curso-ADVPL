#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN59002()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,WPREFIXO,WTITULO,WPARCELA,WTIPO,WCHEQUE")
SetPrvt("WRECNO,WORDER,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �IN59002   � Autor � Gustav Koblinger Jr   � Data � 31/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao 590 Cheque OffLine���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: CERAMICA INCESA                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
// Lancamento Padronizado ( Contas a Valor para Produto)
cAlias  := Alias()
wPrefixo:= SEF->EF_PREFIXO
wTitulo := SEF->EF_TITULO
wParcela:= SEF->EF_PARCELA
wTipo   := SEF->EF_TIPO
wCheque := ""

dbSelectArea("SEF")
dbSetOrder(3)
wRecno  := Recno()
wOrder  := IndexOrd()
If dbSeek(xFilial("SEF")+wPrefixo+wTitulo+wParcela+wTipo,.T.)
   wCheque := SEF->EF_NUM
EndIf

dbGoTo(wRecno)
dbSetOrder(wOrder)
dbSelectArea(cAlias)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(wCheque)
Return(wCheque)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04