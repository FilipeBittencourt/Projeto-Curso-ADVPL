//=======================================================================================================================================| 
// Progama   : PVFret01                                                 															 	 |	    
// Tipo      : Ponto de Entrada                                             															 | 
// Autor     : Marcelo Secate                                                															 |
// Data      : xx/xx/xxxx                                                   															 |
//=======================================================================================================================================|
// Descrição : Gerencia o processo de contabilização do Valor do Frete no ato do lançamento do Pedido de Venda 						     |
//=======================================================================================================================================|
User Function PVFret01()

	Local lRet        := .T.
	Local nValFrete   := 0
	Local nTotFrete   := 0
	Local nPosProduto := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRODUTO" })
	Local nPosQtdVen  := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_QTDVEN" })
	Local nPosYFrete  := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_YFRETE" })

	If !Empty(M->C5_TABELA)
		DA1->(DbSetOrder(1))
		DA1->(DbGoTop())

		If DA1->(DbSeek(xFilial("DA1") + M->C5_TABELA + aCols[n, nPosProduto]))
			While DA1->(DA1_FILIAL + DA1_CODTAB + DA1_CODPROD) == xFilial("DA1") + M->C5_TABELA + aCols[n, nPosProduto]
				If DA1->DA1_ATIVO == "1" .And. DA1->DA1_DATVIG <= dDataBase
					nValFrete := DA1->DA1_FRETE
				End If
				DA1->(DbSkip())
			End
		End If

		aCols[n, nPosYFrete] := Round(aCols[n, nPosQtdVen] * nValFrete, 2)

		//============================================================================|
		// Aciona a atualização do Valor do Frete                                     |                                       
		//============================================================================|
		CalcTotFrt()
	Else	
		M->C5_FRETE := 0
	End If                                                                

Return lRet

//=======================================================================================================================================| 
// Tipo      	: Rotina                                             															 		 | 
// Autor     	: Marcelo Secate                                                														 |
// Adaptado por : Jessé Augusto                                                                                                          |
// Data      	: xx/xx/xxxx                                                   															 |
//=======================================================================================================================================|
// Descrição    : Atualiza a contabilização do Valor do Frete         																	 |
//=======================================================================================================================================|

Static Function CalcTotFrt()

	Local nTotal     := 0
	Local nX         := 0
	Local nQtdLin    := Len(aCols)
	Local nPosYFrete := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_YFRETE" })

	For nX := 1 To nQtdLin

		If !GdDeleted(nX)

			nTotal += aCols[nX, nPosYFrete]
		End If
	Next nX

	M->C5_FRETE := nTotal

	IF Type("oGetPV") == "O"
		oGetPV:Refresh()
	ENDIF
	
Return 