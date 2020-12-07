#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TContaContabil
@author Wlysses Cerqueira (Facile)
@since 15/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

User Function F340MKTIT()
	
	Local oContaCont := TContaContabil():New()
	Local nPos := 0
	Local nW := 0
	
	For nW := 1 To Len(aTitulos)
		
		If aTitulos[nW][8]
			
			oContaCont:SetContContab("F", aTitulos[nW][14], aTitulos[nW][15], "PA")
		
		EndIf
		
	Next nW
	
Return(aTitulos)

User Function BF340CMP()
	
	Local cConta := ""
	Local aAreaSA2 := SA2->(GetArea())
	
	If PARAMIXB[1] == 1 // Inclusao da compensacao - Debito
		
		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		
		If SA2->(DBSeek(xFilial("SA2") + SE5->E5_CLIFOR + SE5->E5_LOJA))

			cConta := SA2->A2_CONTA
					
		EndIf
	
	ElseIf PARAMIXB[1] == 2 // Inclusao da compensacao - Credito
	
		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		
		If SA2->(DBSeek(xFilial("SA2") + SE5->E5_FORNADT + SE5->E5_LOJAADT))
			
			cConta := SA2->A2_YCTAADI
		
		EndIf
	
	ElseIf PARAMIXB[1] == 3 // Estorno da compensacao - Debito
	
		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		
		If SA2->(DBSeek(xFilial("SA2") + SE5->E5_CLIFOR + SE5->E5_LOJA))

			cConta := SA2->A2_YCTAADI
					
		EndIf
		
	ElseIf PARAMIXB[1] == 4 // Estorno da compensacao - Credito

		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		
		If SA2->(DBSeek(xFilial("SA2") + SE5->E5_FORNADT + SE5->E5_LOJAADT))

			cConta := SA2->A2_CONTA
					
		EndIf		
		
	EndIf
	
	RestArea(aAreaSA2)
	
Return(cConta)