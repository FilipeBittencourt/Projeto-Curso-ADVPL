#include "rwmake.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BIA836   � Autor � Ranisses A. Corona � Data �  23/11/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Carteira - CNAB A Pagar Bradesco [136 a 138]               ���
�������������������������������������������������������������������������͹��
���Uso       � Financeiro                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA836()
Local nCart := ""

If SEA->EA_MODELO $ "31"				//PAGAMENTO DE TITULOS 
	If !Empty(Alltrim(SE2->E2_CODBAR))
		If Substr(SE2->E2_CODBAR,1,3) == "237"
			nCart := "0" + SUBS(SE2->E2_CODBAR,24,2)
		Else
			nCart := "000"
		EndIf
	Else
		If Substr(SE2->E2_YLINDIG,1,3) == "237"
			nCart := "0" + Substr(SE2->E2_YLINDIG,09,1)+Substr(SE2->E2_YLINDIG,11,1)
		Else
			nCart := "000"
		EndIf
	EndIf
Else													//PAGAMENTO DE TITULOS 
	nCart := "000"
EndIf

Return(nCart)