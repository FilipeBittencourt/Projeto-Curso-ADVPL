#include "rwmake.ch"
#include "topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BIA921    �Autor  �Ranisses            � Data �  10/03/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � AJUSTAR O VENCIMENTO REAL DOS TITULOS                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BIA921()
Processa({|| fPrior()})    
Return                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fPrior    �Autor  �Ranissses           � Data �  10/03/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � AJUSTAR O VENCIMENTO REAL DOS TITULOS                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function fPrior()
Private cSql, ctrab, cnf
cSql := "SELECT E1_PREFIXO, E1_SITUACA, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR, E1_SALDO"
cSql += " FROM " + retsqlname("SE1") + " SE1"
cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
cSql += " AND E1_SALDO > 0           "
cSql += " AND E1_VENCREA < E1_VENCTO "
cSql += " AND D_E_L_E_T_ = ''        "
TCQUERY cSql NEW ALIAS "ctrab"        
DbSelectArea("ctrab")
DbGotop()
ProcRegua(SE1->(RecCount()))
Do while .not. eof()              
	cnf    := ctrab->E1_PREFIXO+ctrab->E1_NUM+ctrab->E1_PARCELA
	Do while !eof() .and. ctrab->E1_PREFIXO+ctrab->E1_NUM+ctrab->E1_PARCELA == cnf
	    Incproc("Prefixo+NF+Parcela: "+ cnf)
		//����������������������������������������������
		//�Posicionar SE1 para gravar o Vencimento Real�
		//����������������������������������������������
		DbSelectArea("SE1")
		DbSetOrder(1)                 
		If DbSeek(xFilial("SE1")+ctrab->E1_PREFIXO+ctrab->E1_NUM+ctrab->E1_PARCELA)
			If Reclock("SE1")
				If SE1->E1_SITUACA == "0"
					SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO)
				ElseIf SE1->E1_SITUACA == "1"
					SE1->E1_VENCREA := DATAVALIDA(SE1->E1_VENCTO+1)
				EndIf
				MsUnlock()
			EndIf
		EndIf		                   
		DbSelectArea("ctrab")
		DbSkip()                   
	EndDo
EndDo
DbCloseArea("ctrab")
Return		