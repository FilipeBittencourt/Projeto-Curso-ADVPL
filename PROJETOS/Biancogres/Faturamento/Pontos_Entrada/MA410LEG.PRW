#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA410LEG	�Autor  �Fernando Rocha      � Data � 15/12/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Criar legendas para pedido de vendas						  ���
���          � Tem que ser usado em conjunto com o PE MA410COR			  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA410LEG
	Local aArea := GetArea()
	Local aCores := PARAMIXB
	Local aCoresNew := {}
	Local I

	AAdd(aCoresNew, {"BR_CINZA","Pedido N�o Conferido"} )
	AAdd(aCoresNew, {"BR_PINK","Pedido de Engenharia com Bloqueio de Cr�dito"} )

	For I := 1 To Len(aCores)

		AAdd(aCoresNew, aCores[I]) 

	Next I

	RestArea(aArea)
Return(aCoresNew)
