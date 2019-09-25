User Function FCliAtOS()
Local aArea    := GetArea()
Local aAreaAB6 := AB6->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local cRet := ""

	AB6->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	
	If AB6->(DbSeek(xFilial("AB6") + SubStr(AB9->AB9_NUMOS, 1, 6)))
		If SA1->(DbSeek(xFilial("SA1") + AB6->(AB6_CODCLI + AB6_LOJA)))
			cRet := SA1->A1_NOME
		End If
	End If

	RestArea(aAreaSA1)
	RestArea(aAreaAB6)	
	RestArea(aArea)
Return cRet