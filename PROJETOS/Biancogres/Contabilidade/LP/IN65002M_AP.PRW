#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN65002M()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WALIAS,_VALTIT,_PERC,")

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BI65002M � Autor � MICROSIGA - VITORIA   � Data � 03/05/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lancto 650 - Valor ICMS                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
wAlias   := Alias()
_valtit := 0
DbSelectArea("SE2")
DbSetOrder(6)
DbSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC)
Do while .not. eof() .and. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
                           xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC
   _valtit := _valtit + xMoeda(SE2->E2_VALOR,1,4,SE2->E2_VENCREA)
   DbSkip()
EndDo
_perc := (SD1->D1_VALICM / SF1->F1_VALICM) 
_valtit := xMoeda(SD1->D1_VALICM,1,4,ddatabase)
If SF4->F4_CREDICM == "N"
   _valtit := 0
EndIf
dbSelectArea(wAlias)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(_valtit)
Return(_valtit)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04