#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M410LDEL	�Autor  �Fernando Rocha      � Data � 13/03/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar a exlcusao de linha de Pedidos de venda			  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M410LDEL
Local aArea 	:= GetArea()
Local aOpc 		:= PARAMIXB
Local lRetorno	:= .T.
Local __nProd	:= Gdfieldget("C6_PRODUTO",1)
     
If M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4"

	If (AllTrim(CEMPANT) == "14") .And. !U_CHKRODA(__nProd)
		lRetorno := .T.
		RestArea(aArea)
		Return(lRetorno)
	EndIf
	
	lRetorno := U_FRRT03VL()
EndIf

RestArea(aArea)
Return(lRetorno)