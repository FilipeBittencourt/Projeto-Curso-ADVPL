#INCLUDE "TOTVS.CH"

Class TCalculoDVNossoNumero From LongClassName

	Method New() Constructor
	Method GetDVBanestes()
	Method GeraPeso()
	
EndClass


Method New() Class TCalculoDVNossoNumero

Return()


Method GetDVBanestes(cNumBco) Class TCalculoDVNossoNumero
	
	Local nCnt 		:= 0
	Local cDigito1	:= 0
	Local cDigito2	:= 0
	Local nSoma		:= 0
	Local nLin		:= 0
	Local cDev		:= ""
	Local aPeso		:= {}

	// Calculo digito 1
	nTam := Len(cNumBco)

	aPeso := ::GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1 		 

		nLin ++

		nSoma += Val(SubStr(cNumBco, nCnt, 01)) * aPeso[nLin, 1]

	Next nCnt

	cDigito1 := nSoma % 11

	If (cDigito1 <= 1, cDigito1 := 0, cDigito1 := 11 - (nSoma % 11))

	// Calculo digito 2  
	nTam++

	aPeso := ::GeraPeso(nTam, 10)

	nLin 	:= 0

	nSoma	:= 0

	cNumBco := cNumBco + Str(cDigito1, 1, 0)

	For nCnt := nTam To 1 Step -1 		 

		nLin++

		nSoma += Val(SubStr(cNumBco, nCnt, 01)) * aPeso[nLin, 1]

	Next nCnt

	cDigito2 := nSoma % 11

	If (cDigito2 <= 1, cDigito2 := 0, cDigito2 := 11 - (nSoma % 11))

	cDev := Str(cDigito1, 1, 0) + Str(cDigito2, 1, 0)

Return(cDev)


Method GeraPeso(nTamNSN, nBase) Class TCalculoDVNossoNumero
	
	Local nCount	:= 0
	Local nVal 		:= 1
	Local aPeso		:= {}

	For nCount := 1 To nTamNSN

		nVal++

		If nVal <= nBase

			aAdd(aPeso, {nVal})

		Else

			aAdd(aPeso, {2})

			nVal := 2

		EndIf

	Next 

Return(aPeso)
