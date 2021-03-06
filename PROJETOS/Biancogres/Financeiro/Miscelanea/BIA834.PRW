#include "rwmake.ch"
#include "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BIA834    � Autor � Ranisses A. Corona � Data �  23/11/10   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo do Agencia - CNAB A Pagar Bradesco [099 a 104]      ���
�������������������������������������������������������������������������͹��
���Uso       � Financeiro                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BIA834()
	Local nAgencia	:= ""

	If SEA->EA_MODELO $ "01_03_08"			//CREDITO EM CONTA / TED / DOC
	
	//nAgencia := Replicate("0",5-LEN(SA2->A2_AGENCIA))+SA2->A2_AGENCIA+SA2->A2_YDVAG
		nAgencia := StrZero(Val(SA2->A2_AGENCIA),5)+SA2->A2_YDVAG
		
	ElseIf SEA->EA_MODELO == "31"				//PAGAMENTO DE TITULOS MESMO BANCO / OUTROS BANCOS
	
		If !Empty(Alltrim(SE2->E2_CODBAR))
		
			If Substr(SE2->E2_CODBAR,1,3) == "237"
			
				nAgencia := StrZero(Val(Substr(SE2->E2_CODBAR,20,4)),5)+U_DigitoRR("0",Substr(SE2->E2_CODBAR,20,4))
				
			Else
			
				nAgencia := "000000"
				
			EndIf
			
		ElseIf !Empty(Alltrim(SE2->E2_LINDIG))
		
			If Substr(SE2->E2_LINDIG,1,3) == "237"
			
				nAgencia := StrZero(Val(Substr(SE2->E2_LINDIG,5,4)),5)+U_DigitoRR("0",Substr(SE2->E2_LINDIG,5,4))
				
			Else
			
				nAgencia := "000000"
				
			EndIf

		ElseIf !Empty(Alltrim(SE2->E2_YLINDIG))
		
			If Substr(SE2->E2_YLINDIG,1,3) == "237"
			
				nAgencia := StrZero(Val(Substr(SE2->E2_YLINDIG,5,4)),5)+U_DigitoRR("0",Substr(SE2->E2_YLINDIG,5,4))
				
			Else
			
				nAgencia := "000000"
				
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

Return(nAgencia)