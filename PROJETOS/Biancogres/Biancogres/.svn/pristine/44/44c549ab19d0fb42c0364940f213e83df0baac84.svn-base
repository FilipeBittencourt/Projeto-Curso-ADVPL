#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF086
@author Tiago Rossini Coradini
@since 27/11/2017
@version 1.0
@description Preenchimento automatico dos campos de valor(C8_YVLDESC) e percentual(C8_YPEDESC) de desconto para todos os itens da cotação. 
@obs OS: XXXX-XX
@type function
/*/

User Function BIAF086()
Local aArea := GetArea()
Local nCount := 0
Local nAux := 0
Local nPerDes := 0 
Local cFPerDes := "C8_YPEDESC"
Local cFVlrDes := "C8_YVLDESC"
Local cFPrcOri := "C8_YPRCORI"
Local cFPrcUnt := "C8_PRECO"
Local cFVlrTot := "C8_TOTAL"
	
	If l150Propost
	
		If Type("aHeader") == "A"
						
			nAux := N
			
			nPerDes := GdFieldGet(cFPerDes)
		
			If nPerDes > 0 .And. Len(aCols) > 1
			
				If MsgYesNo("Deseja realmente replicar o desconto de " + cValToChar(nPerDes) + "% para todos os items?", "Replicação de Percentual de Desconto")						
					
					For nCount := 1 To Len(aCols)
					
						N := nCount
					
						If !GdDeleted(nCount) .And. GdFieldGet(cFPrcOri, nCount) > 0 .And. nAux <> nCount 
																												
							GdFieldPut(cFPerDes, nPerDes, nCount)
							
							GdFieldPut(cFVlrDes, NoRound(GdFieldGet(cFPrcOri, nCount) * nPerDes / 100, TamSx3(cFVlrDes)[2]), nCount)
							
							GdFieldPut(cFPrcUnt, NoRound(GdFieldGet(cFPrcOri, nCount) - GdFieldGet(cFVlrDes, nCount), TamSx3(cFPrcUnt)[2]), nCount)
							
							MaFisFound("IT", nCount)
													
							MaFisRef("IT_PRCUNI", "MT150", GdFieldGet(cFPrcUnt, nCount))
							
							If ExistTrigger("C8_PRECO")
								
								RunTrigger(2, nCount)
								
							EndIf
						
						EndIf
					
					Next
					
					N := nAux
					
				EndIf
										
			Else
			
				MsgInfo("Favor informar o percentual do item.", "Replicação de Percentual de Desconto")
			
			EndIf
		
		EndIf
	
	Else
	
		MsgInfo("A replição do percentual do item só é permitida para novas propostas.", "Replicação de Percentual de Desconto")
		
	EndIf	
	
	RestArea(aArea)		

Return()