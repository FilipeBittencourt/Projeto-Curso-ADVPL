User Function NNSantan()

  Local nTam    := 0
  Local cNumero := ""
  Local cNumNew := ""
  Local cMod11  := ""

  If Empty(SE1->E1_NUMBCO)

    nTam    := Len(AllTrim(SEE->EE_FAXATU))
    cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)

    While !MayIUseCode(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
      cNumero := Soma1(cNumero)										// busca o proximo numero disponivel
    EndDo

    cMod11  := Modulo11(cNumero,2,9)
    cNumNew := cNumero + cMod11

    RecLock("SE1",.F.)
    SE1->E1_NUMBCO := cNumNew
    SE1->(MsUnlock())

    RecLock("SEE",.F.)
    SEE->EE_FAXATU := Soma1(cNumero, nTam)
    SEE->(MsUnlock())

  EndIf

  /*
  Local nTam    := Len(AllTrim(SEE->EE_FAXATU))
  Local cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)
  Local cMod11  := ""

  While !MayIUseCode(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
    cNumero := Soma1(cNumero)										// busca o proximo numero disponivel
  EndDo

  cMod11 := Modulo11(cNumero,2,9)

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
  */
Return(SE1->E1_NUMBCO)


/*

 
SELECT DISTINCT 
   E1_FILIAL,   
   E1_NUMBCO,
   SUBSTRING(E1_NUMBCO, 1, 7) AS NNSANTA,
   E1_PORTADO,
   E1_AGEDEP,
   E1_CONTA,
   E1_EMISSAO
  
   
FROM
   SE1010 AS SE1 
    INNER JOIN SEE010 SEE 
	ON 	SE1.E1_PORTADO     = SEE.EE_CODIGO    
	AND SE1.E1_AGEDEP      = SEE.EE_AGENCIA
    AND SE1.E1_CONTA       = SEE.EE_CONTA
    AND SEE.EE_SUBCTA      = '101'
	AND SEE.EE_FILIAL      = '01'
	 
    AND SEE.D_E_L_E_T_ = ''  
   
WHERE 0=0	
   AND SE1.D_E_L_E_T_ = ' ' 
   AND SE1.E1_FILIAL = '0101' 
   AND SUBSTRING(E1_NUMBCO, 1, 7) = SEE.EE_FAXATU	
  --AND  E1_EMISSAO >= '20200301' 
  --AND E1_SALDO > 0
  --AND E1_NUMBCO = ''

   ORDER BY  E1_NUMBCO DESC

   
*/
