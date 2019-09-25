User Function M410AGRV()
Local aArea       := GetArea()
Local aAreaSB1    := SB1->(GetArea())
Local aParams     := PARAMIXB
Local nPosProduto := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRODUTO" })
Local nPosYRef    := aScan(aHeader, { |x| AllTrim(x[2]) == "C6_YREF" })

	For nX := 1 To Len(aCols)
		If SB1->(DbSeek(xFilial("SB1") + aCols[nX, nPosProduto]))
			If !Empty(SB1->B1_YREF)
				aCols[nX, nPosYRef] := SB1->B1_YREF
			End If
		End If
	Next nX

	RestArea(aAreaSB1)
	RestArea(aArea)
Return