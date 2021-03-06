#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M410INIC	�Autor  �Fernando Rocha      � Data � 07/01/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Antes da inclusao de pedido de venda						  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M410INIC
Local aArea := GetArea()

Public _FROPCHVTEMPRES

_FROPCHVTEMPRES := AllTrim(__CUSERID)+DTOS(dDataBase)+StrZero(Randomize(1,999999),6)

//Campo para salvar a chave temporaria usada para criar reservas - Fernando em 08/05/15 - para posterior uso para efetivar reservas com problema
If SC5->(FieldPos("C5_YCHVRES")) > 0
	If Type("M->C5_YCHVRES") <> "U"
		M->C5_YCHVRES := _FROPCHVTEMPRES
	EndIf
EndIf

If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQPED",.F.)
	MsgInfo("Inclus�o de pedidos temporariamente bloqueada pelo departamento comercial","M410INIC")
EndIf

__lRep := Type("CREPATU") <> "U" .And. !Empty(CREPATU)
If (__lRep)
	DbSelectArea('SA3')
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(XFilial("SA3")+CREPATU))
		If (SA3->A3_YBLQPED == 'S')
			MsgInfo("Inclus�o de pedidos temporariamente bloqueada pelo departamento comercial","M410INIC")
		EndIf
	EndIf		
EndIf


RestArea(aArea)
Return()
