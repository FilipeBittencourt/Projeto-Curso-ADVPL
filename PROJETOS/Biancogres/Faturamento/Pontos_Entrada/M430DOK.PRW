#include "PROTHEUS.CH" 
#include "rwmake.ch"
#INCLUDE "ACESSOS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M430DOK	�Autor  �Fernando Rocha      � Data � 20/01/2015  ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar exclusao de linha na reserva						  ���
�������������������������������������������������������������������������͹��
���Uso       � BIANCOGRES												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function M430DOK           
//Local aArea := GetArea()  
Local _lRet := .T.

if _lRet .And. !INCLUI .And. !ALTERA

	If (!Empty(SC0->C0_YPEDIDO) .And. !Empty(SC0->C0_YITEMPV) .And. !Empty(SC0->C0_YHORA) .And. (SC0->C0_YTEMP <> "S"))
	
		msg := ""
		msg += "EXCLUSAO NAO PERMITIDA!"+chr(13)+chr(13)
		msg += "N�o � poss�vel excluir reservas autom�ticas de pedido por esta tela."+chr(13)+chr(13)
		msg += "Favor usar a tela do Pedido de Vendas."+chr(13)+chr(13)
		msgbox(msg)
		
		_lRet := .F.
	
	endif
	
endif

//RestArea(aArea)      

Return _lRet