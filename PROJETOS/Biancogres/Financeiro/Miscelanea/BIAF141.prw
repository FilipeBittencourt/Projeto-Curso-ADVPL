#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF141
@author Tiago Rossini Coradini
@since 13/01/2020
@version 1.0
@description Função para gravacoes adicionais apos o confirmacao da Cotação de Moedas  
@obs Ticket: 21417
@type function
/*/

User Function BIAF141(nOpc)

	// Atualiza Moeda Dolar
	If M->YE_MOEDA == 'US$'
		
		// Financeiro - Compras
		DbSelectArea("SM2")
		SM2->(DbSetOrder(1))
		If SM2->(DbSeek(dToS(M->YE_DATA)))
			
			RecLock("SM2", .F.)
			
				SM2->M2_MOEDA2 := M->YE_VLCON_C
				
			SM2->(MsUnLock())
			
		Else
		
			RecLock("SM2", .T.)
				
				SM2->M2_DATA := M->YE_DATA
				SM2->M2_MOEDA2 := M->YE_VLCON_C
				
			SM2->(MsUnLock())

		EndIf
		
		// Contabilidade
		DbSelectArea("CTP")
		CTP->(DbSetOrder(1))
		If CTP->(DbSeek(xFilial("CTP") + dToS(M->YE_DATA) + "02"))
			
			RecLock("CTP", .F.)
				
				CTP->CTP_TAXA := M->YE_VLCON_C
				
			CTP->(MsUnLock())

		Else

			RecLock("CTP", .T.)

				CTP->CTP_FILIAL := xFilial("CTP")
				CTP->CTP_DATA := M->YE_DATA
				CTP->CTP_MOEDA := "02" 
				CTP->CTP_TAXA := M->YE_VLCON_C
				CTP->CTP_BLOQ := "2"
			
			CTP->(MsUnLock())
			
		EndIf
		
	EndIf
	
	// Atualiza Moeda em EURO
	If M->YE_MOEDA == 'EUR'
		
		// Financeiro - Compras
		DbSelectArea("SM2")
		SM2->(DbSetOrder(1))
		If SM2->(DbSeek(dToS(M->YE_DATA)))
			
			RecLock("SM2", .F.)
			
				SM2->M2_MOEDA5 := M->YE_VLCON_C
				
			SM2->(MsUnLock())
			
		Else
		
			RecLock("SM2", .T.)
				
				SM2->M2_DATA := M->YE_DATA
				SM2->M2_MOEDA5 := M->YE_VLCON_C
				
			SM2->(MsUnLock())

		EndIf

		// Contabilidade
		DbSelectArea("CTP")
		CTP->(DbSetOrder(1))
		If CTP->(DbSeek(xFilial("CTP") + dToS(M->YE_DATA) + "05"))
			
			RecLock("CTP", .F.)
				
				CTP->CTP_TAXA := M->YE_VLCON_C
				
			CTP->(MsUnLock())

		Else

			RecLock("CTP", .T.)

				CTP->CTP_FILIAL := xFilial("CTP")
				CTP->CTP_DATA := M->YE_DATA
				CTP->CTP_MOEDA := "05" 
				CTP->CTP_TAXA := M->YE_VLCON_C
				CTP->CTP_BLOQ := "2"
			
			CTP->(MsUnLock())
			
		EndIf
		
	EndIf

Return()