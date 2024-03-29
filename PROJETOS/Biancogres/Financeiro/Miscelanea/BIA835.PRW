#include "rwmake.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BIA835   � Autor � Ranisses A. Corona � Data �  23/11/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Conta Corrente - CNAB A Pagar Bradesco [105 a 119]         ���
�������������������������������������������������������������������������͹��
���Uso       � Financeiro                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA835()
	Local nConta := ""

	If SEA->EA_MODELO $ "01_03_08"				//CREDITO EM CONTA / TED / DOC
	
		nConta := StrZero(Val(SA2->A2_NUMCON),13)+SA2->A2_YDVCTA
	
	ElseIf SEA->EA_MODELO == "31"				//PAGAMENTO DE TITULOS MESMO BANCO / OUTROS BANCOS
	
		If !Empty(Alltrim(SE2->E2_CODBAR))
		
			If Substr(SE2->E2_CODBAR,1,3) == "237"
			
				nConta := StrZero(Val(Substr(SE2->E2_CODBAR,37,7)),13)+U_DigitoRR("00000000",Substr(SE2->E2_CODBAR,37,7))
				
			Else
			
				nConta := "000000000000000"
				
			EndIf
		ElseIf !Empty(Alltrim(SE2->E2_YLINDIG))
	
			If Substr(SE2->E2_YLINDIG,1,3) == "237"
			
				nConta := StrZero(Val(Substr(SE2->E2_YLINDIG,24,7)),13)+U_DigitoRR("00000000",Substr(SE2->E2_YLINDIG,24,7))
				
			Else
			
				nConta := "000000000000000"
				
			EndIf
		ElseIf !Empty(Alltrim(SE2->E2_LINDIG))
	
			If Substr(SE2->E2_LINDIG,1,3) == "237"
			
				nConta := StrZero(Val(Substr(SE2->E2_LINDIG,24,7)),13)+U_DigitoRR("00000000",Substr(SE2->E2_LINDIG,24,7))
				
			Else
			
				nConta := "000000000000000"
				
			EndIf
		Else
		
			//MsgBox("Modalidade de Pagamento n�o � valida para Opera��es no Banco Bradesco. O arquivo ser� gerado com ERRO!","ATEN��O","STOP")
			
			Help(NIL, NIL, "Modalidade invalida", NIL,;
				"Modalidade de Pagamento n�o � valida para Opera��es no Banco Bradesco. O arquivo ser� gerado com ERRO!", 1, 0, NIL, NIL, NIL, NIL, NIL,;
				{"Verifique a modalidade " + SEA->EA_MODELO})
			
		EndIf
	Else
	
		//MsgBox("Modalidade de Pagamento n�o � valida para Opera��es no Banco Bradesco. O arquivo ser� gerado com ERRO!","ATEN��O","STOP")
			
		Help(NIL, NIL, "Modalidade invalida", NIL,;
			"Modalidade de Pagamento n�o � valida para Opera��es no Banco Bradesco. O arquivo ser� gerado com ERRO!", 1, 0, NIL, NIL, NIL, NIL, NIL,;
			{"Verifique a modalidade " + SEA->EA_MODELO})
				
	EndIf

Return(nConta)