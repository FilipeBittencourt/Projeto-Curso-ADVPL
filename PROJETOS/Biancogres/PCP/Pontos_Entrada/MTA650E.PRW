#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA650E	�Autor  �Fernando Rocha      � Data � 02/04/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar a exclusao de OP									  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA650E           
Local aArea := GetArea()  
Local lRet := .T.
Local aRes, nRet
                                                                         
If lRet

	aRes := U_FRTE02LO("", "", "", SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"")
	If Len(aRes) > 0
		nRet := U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Existem reservas vinculadas a esta OP. N�o � poss�vel a exclus�o.";
								,{"Consulta","Ok"},,"Exclus�o de OP")
								
		If nRet == 1
			U_FROPTE02("", "", "", SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), "R")
		EndIf
		
		lRet := .F.	
	EndIf
	
EndIf

RestArea(aArea)
Return(lRet)