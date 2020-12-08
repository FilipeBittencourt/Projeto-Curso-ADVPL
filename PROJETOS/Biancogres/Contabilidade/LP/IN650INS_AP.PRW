#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN650INS()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_CALIAS,_NINDIC,_NRECNO,_VALINS,")

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � IN650IRF � Autor � MICROSIGA VITORIA     � Data � 26/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lancto 650 - IRRF                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
_cAlias := Alias()
_nIndic := indexOrd()
_nRecno := Recno()
_valins := 0

DbSelectArea("SE2")
DbSetOrder(6)

If SD1->D1_ITEM == "01"
   IF DbSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC)
      While .not. eof() .and. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
                              xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC
          If  SE2->E2_INSS > 0
              _valins := _valins + SE2->E2_INSS
          EndIf
          DbSkip()
       End
   EndIf
EndIf

dbSelectArea(_cAlias)
dbSetOrder(_nIndic)
dbGoTo(_nRecno)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(_valins)
Return(_valins)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04