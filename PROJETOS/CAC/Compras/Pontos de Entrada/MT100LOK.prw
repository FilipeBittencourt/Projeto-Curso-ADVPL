User Function MT100LOK()
Local nPosRateio := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_RATEIO"})
Local nPosCC     := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CC"})
Local cRateio    := aCols[n, nPosRateio]
Local cCC        := aCols[n, nPosCC]
Local lRet       := ParaMixB[1]

	If lRet
		If (Empty(cCC) .And. cRateio <> "1")
			lRet := .F.
			MsgStop("Centro de Custo não informado.", "NFE")
		Else
			lRet := .T.
		EndIf
	EndIf
Return lRet
