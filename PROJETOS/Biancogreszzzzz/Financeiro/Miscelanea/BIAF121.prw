#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF121
@author Tiago Rossini Coradini
@since 17/09/2018
@version 1.0
@description Rotina para calculo do nosso numero do banco Banestes 
@obs Ticket: 7873
@type Function
/*/

User Function BIAF121()
	Local cNumBco := ""

	If Empty(SE1->E1_NUMBCO)

		DbSelectArea("SEE")
		DbSetOrder(1)
		If SEE->(DbSeek(xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA))

			cNumBco := StrZero(Val(NossoNum()), 8)

			cNumBco += BaneCDigV(cNumBco)

		EndIf

	Else

		cNumBco := SubStrtr(AllTrim(SE1->E1_NUMBCO), 3, 10)

	EndIf

Return(cNumBco)



// Calcula digitos verificadores do Banco Banestes
Static Function BaneCDigV(cNumBco)
	Local nCnt := 0
	Local cDigito1 := 0
	Local cDigito2 := 0
	Local nSoma := 0
	Local nLin := 0
	Private aPeso := {}

	// Calculo digito 1
	nTam := Len(cNumBco)

	GeraPeso(nTam, 9)

	For nCnt := nTam To 1 Step -1 		 

		nLin ++

		nSoma += Val(SubStr(cNumBco, nCnt, 01)) * aPeso[nLin, 1]

	Next nCnt

	cDigito1 := nSoma % 11

	If (cDigito1 <= 1, cDigito1 := 0, cDigito1 := 11 - (nSoma % 11))

	// Calculo digito 2  
	nTam++

	GeraPeso(nTam, 10)

	nLin := 0

	nSoma	:= 0

	cNumBco := cNumBco + Str(cDigito1, 1, 0)

	For nCnt := nTam To 1 Step -1 		 

		nLin++

		nSoma += Val(SubStr(cNumBco, nCnt, 01)) * aPeso[nLin, 1]

	Next nCnt

	cDigito2 := nSoma % 11

	If (cDigito2 <= 1, cDigito2 := 0, cDigito2 := 11 - (nSoma % 11))

Return(Str(cDigito1, 1, 0) + Str(cDigito2, 1, 0))


Static Function GeraPeso(nTamNSN, nBase)
	Local nCount
	Local nVal := 1

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