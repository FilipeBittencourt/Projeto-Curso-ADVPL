#Include 'Protheus.ch'

/*/{Protheus.doc} SFStruJs
Converte string em formato noSQL documental (AAAA-MM-DD)
para formatos de data reconhecidos pelo Protheus
@type      function
@author    Giovani
@since     11/10/2017
@version   1.0
@param
	cParam, character, string de entrada
	cToken, character, caractere separador
	cOutput, character, determina o tipo de saida, onde:
		C - 14-12-1987
		S - 19871412
		D - 14/12/87 (data)
@return xDate, retorno conforme cOutput informado
@example u_SFDate('1987-12-14','-','C')
/*/
User Function SFDate(cParam,cToken,cOutput)

	Local nI := 0
	Local aDate := {}
	Local cYear, cMonth, cDay := ''
	Local xDate := nil // retorno da função
	Local lOK := .T.

	// Determina comportamento padrão da função
	Default cOutput := 'C'

	// Converte para array
	aDate := StrToKarr(cParam,cToken)

	For nI:=1 to Len(aDate)
		If nI == 1
			cYear := aDate[nI] // 'AAAA'
		ElseIf nI == 2
			cMonth := IIF(Len(aDate[nI])==1,'0'+aDate[nI],aDate[nI]) // 'MM'
		ElseIf nI == 3
			cDay := IIF(Len(aDate[nI])==1,'0'+aDate[nI],aDate[nI]) // 'DD'
		Else
			lOK := .F.
		EndIf
	Next

	If lOK
		Do Case
		Case cOutput == 'C'
			xDate := cDay + '/' + cMonth + '/' + cYear // 'DD/MM/AAAA'

		Case cOutput == 'S'
			xDate := cYear+cMonth+cDay // 'AAAMMDD'

		Case cOutput == 'D'
			xDate := sToD(cYear+cMonth+cDay) // DD/MM/AAAA

		EndCase
	EndIf

Return(xDate)
