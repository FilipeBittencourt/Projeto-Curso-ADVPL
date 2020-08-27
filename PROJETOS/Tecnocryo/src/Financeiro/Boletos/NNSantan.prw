User Function NNSantan()
	Local nTam		:= Len(AllTrim(SEE->EE_FAXATU))
	Local cNumero	:= StrZero(Val(SEE->EE_FAXATU),nTam)
	Local cMod11	:= ""
	Local nCont		:= 0
	Local nTotal	:= 100
	Local lExiste	:= nil

	While !MayIUseCode(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))	// verifica se esta na memoria, sendo usado
		cNumero := Soma1(cNumero)													// busca o proximo numero disponivel 
	EndDo

	// Facile - Ticket #1119 - Luiz Soto - 2020-05-20 - Validar se numero já existe
	While .T.
		nCont++
		
		cMod11 := Modulo11(cNumero,2,9)

		lExiste := SE1valid(cNumero + cMod11)		

		If lExiste 
			cNumero := Soma1(cNumero)
		EndIf

		If !lExiste .Or. nCont == nTotal
			Exit
		EndIf
	EndDo


	If Empty(SE1->E1_NUMBCO)
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO := cNumero + cMod11
		SE1->(MsUnlock())
		
		RecLock("SEE",.F.)
			SEE->EE_FAXATU := Soma1(cNumero, nTam)
		SEE->(MsUnlock())
	EndIf	

	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
	DbSelectArea("SE1")
Return(SE1->E1_NUMBCO)

Static Function SE1valid(cNumero)
  Local lRet   := .T.
  Local cAlias := "SE1valid"

  If Select(cAlias) > 0
    dbSelectArea(cAlias)
    (cAlias)->(dbCloseArea())
  EndIf

  BeginSql Alias cAlias
    SELECT R_E_C_N_O_ AS REC
    FROM %Table:SE1% SE1
    WHERE E1_FILIAL = %xFilial:SE1%
	AND E1_NUMBCO = %Exp:cNumero%
    AND %NotDel%
  EndSql

  (cAlias)->(dbGoTop())
  If (cAlias)->(EoF())
	lRet := .F.
  EndIf
  (cAlias)->(dbCloseArea())
Return lRet
