#include "rwmake.ch"

User Function BI66001()

/*�����������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BI66601    � Autor � MICROSIGA VITORIA     � Data � 16/01/03 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Historico da requisicao no lcto padrao 66001                 ���
���������������������������������������������������������������������������Ĵ��
��� Altera��o� Marcos Alberto Soprani - 31/01/12                            ���
���          � - Tratamento condicionado a existencia da Chave na Tabela    ���
���          � SD1                                                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/

chist := "UTILIZACAO N/DATA CONF REQ "+SD3->D3_DOC

If !Empty(SD3->D3_YCHAVE)
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(xFilial("SD1")+SD3->D3_YCHAVE))
		chist += " REF. NF " +SD1->D1_SERIE+"-"+ALLTRIM(SD1->D1_DOC)+" DE "+DTOC(SD1->D1_DTDIGIT)
	EndIf
EndIf

Return(chist)