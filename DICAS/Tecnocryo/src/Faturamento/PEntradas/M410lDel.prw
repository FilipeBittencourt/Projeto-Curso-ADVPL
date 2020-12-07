User Function M410lDel()
Local lRet       := .T.
Local nTotal     := 0
Local nX         := 0
Local nQtdLin    := Len(aCols)
Local nPosYFrete := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_YFRETE" })
Local cAcao      := If(GdDeleted(n), "Restaurar", "Deletar")

	If lRet
		
		 If !Empty(M->C5_TABELA)
		 
				Do Case
					Case cAcao == "Deletar"
						For nX := 1 To nQtdLin
							If ((!GdDeleted(nX) .And. nX <> n) .Or. nX == n)
								nTotal += aCols[nX, nPosYFrete]
							End If
						Next nX
					Case cAcao == "Restaurar"
						For nX := 1 To nQtdLin
							If !GdDeleted(nX) .And. nX <> n
								nTotal += aCols[nX, nPosYFrete]
							End If
						Next nX
		        End Case
				M->C5_FRETE := nTotal
				
		 Else  
		     //==========================================================================================|
			 // Caso a tabela de Preço não esteja preenchida, o Valor do Frete  deve ser igual a 0(Zero) |                                       
			 //==========================================================================================|
		     M->C5_FRETE := 0
		 Endif 			
		 oGetPV:Refresh()
	End If
Return lRet