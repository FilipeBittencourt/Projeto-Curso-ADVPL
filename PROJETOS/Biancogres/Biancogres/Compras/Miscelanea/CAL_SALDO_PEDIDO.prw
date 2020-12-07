#include "rwmake.ch"
#Include "TopConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAL_SALDO_PEDIDO  �Autor  � MADALENO   � Data �  28/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � CALCULANDO O                     O SALDO DO PEDIDO  DE     ���
���          � COMPRA                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP7 - COMPRAS                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER FUNCTION CAL_SALDO_PEDIDO()
LOCAL cMSM := ""

cMSM += "O SALDO DO ITEM "+SC7->C7_ITEM+ " DO PEDIDO " + ALLTRIM(SC7->C7_NUM) + " � DE   "
cMSM += IIF(ALLTRIM(STR(SC7->C7_QUANT - SC7->C7_QUJE))= "","0.00",ALLTRIM(STR(SC7->C7_QUANT - SC7->C7_QUJE)) )
msgBox(cMSM,"SALDO POR ITEM DO PEDIDO","INFO")

RETURN