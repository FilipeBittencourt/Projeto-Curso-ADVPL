

User Function F300VALID()
	Local lRet	:= .T.
	Local _cID	:= SE1->(Recno())
	
	If (!IsBlind())
		oBlqCR	:= TBloqueioContaReceber():New()
		_lRet	:= oBlqCR:CheckPorRecno(_cID)
		If(_lRet)
			MsgAlert('<p style="color:red">Titulo FIDC não e possivel realizar "Compensação".</p>', 'F300VALID')
			lRet := .F.
		EndIf
	EndIf
Return lRet