#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA290
@author Wlysses Cerqueira (Facile)
@since 23/04/2019
@project Automação Financeira
@version 1.0
@description Ponto de entrada executado durante a gravação dos dados da fatura 
no SE2 (esta dentro de um FOR em cada titulo da fatura) e antes da contabilização e DENTRO DE UMA TRANSAÇÃO.
@type PE
/*/

Static nContador_ := Nil

User Function FA290()

	Local oObj := TFaturaReceberIntercompany():New()
	
	If nContador_ == Nil // Primeira vez na tela
		
		nContador_ := GetTotAcols()
		
	ElseIf nContador_ == 0 // Ja abriu a tela e processou alguma fatura, porem a variavel ainda esta carregada

		nContador_ := GetTotAcols()
				
	EndIf
	
	nContador_--
	
	If nContador_ == 0
		
		oObj:FaturaReceberDestino()
		
	EndIf

Return()

Static Function GetTotAcols()

	Local nW_ := 0
	Local nTot_ := 0
	
	For nW_ := 1 To Len(aCols)
		
		If !aCols[nW_, Len(aCols[1])]
			
			nTot_++
			
		EndIf
		
	Next nW_
		
Return(nTot_)