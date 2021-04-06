

User Function F040BLQ()
	Local lRet := .T.
	Local _cID	:= SE1->(Recno())
	
	If (ALTERA .And. !IsBlind())
		oBlqCR	:= TBloqueioContaReceber():New()
		_lRet	:= oBlqCR:CheckPorRecno(_cID)
		If(_lRet)
			MsgAlert('<p style="color:red">Titulo FIDC não e possivel "Alterar".</p>', 'F040BLQ')
			lRet := .F.
		EndIf
	EndIf
	
Return lRet