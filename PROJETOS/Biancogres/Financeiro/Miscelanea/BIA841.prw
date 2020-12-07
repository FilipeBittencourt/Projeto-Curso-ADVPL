#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA841
@author Wlysses Cerqueira (Facile)
@since 29/01/2019
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a pagar 
@type function
/*/

User Function BIA841(cUF, nPos, cCod)

	Local aUF := {}
	Local cRet := ""
	
	Default cUF := ""
	Default nPos := 1
	Default cCod := ""
	
	aAdd(aUF, {"01", "9", "AC"})
	aAdd(aUF, {"02", "7", "AL"})
	aAdd(aUF, {"03", "5", "AP"})
	aAdd(aUF, {"04", "3", "AM"})
	aAdd(aUF, {"05", "1", "BA"})
	aAdd(aUF, {"06", "0", "CE"})
	aAdd(aUF, {"07", "8", "DF"})
	aAdd(aUF, {"08", "6", "ES"})
	aAdd(aUF, {"10", "8", "GO"})
	aAdd(aUF, {"12", "4", "MA"})
	aAdd(aUF, {"13", "2", "MT"})
	aAdd(aUF, {"28", "0", "MS"})
	aAdd(aUF, {"14", "0", "MG"})
	aAdd(aUF, {"15", "9", "PA"})
	aAdd(aUF, {"16", "7", "PB"})
	aAdd(aUF, {"17", "5", "PR"})
	aAdd(aUF, {"18", "3", "PE"})
	aAdd(aUF, {"19", "1", "PI"})
	aAdd(aUF, {"20", "5", "RN"})
	aAdd(aUF, {"21", "3", "RS"})
	aAdd(aUF, {"22", "1", "RJ"})
	aAdd(aUF, {"23", "0", "RO"})
	aAdd(aUF, {"24", "8", "RR"})
	aAdd(aUF, {"25", "6", "SC"})
	aAdd(aUF, {"26", "4", "SP"})
	aAdd(aUF, {"27", "2", "SE"})
	aAdd(aUF, {"29", "9", "TO"})
	
	If Empty(cUF)
	
		If Empty(cCod)
		
			cRet := ""
		
		Else

			nPos := aScan(aUF, {|x| x[1] + x[2] == cCod})
			
			If nPos > 0
			
				cRet := aUF[nPos][3]
			
			EndIf
		
		EndIf
	
	Else

		If nPos > 0 .And. nPos <= Len(aUF)
		
			cRet := aUF[aScan(aUF, {|x| x[3] == cUF})][nPos]
		
		EndIf
	
	EndIf

Return(cRet)

User Function BIA841A(lDigVer, lPessoa, lCnpjCpf)
	
	Local cRet := ""
	Local cChave := ""
	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaSF6 := SF6->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	
	Default lDigVer := .F.
	Default lPessoa := .F.
	Default lCnpjCpf := .F.
	
	cRet := If(lDigVer, Space(1), Space(5))
	
	If SA2->(DBSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
			
		DBSelectArea("SF6")
		SF6->(DBSetOrder(1)) // F6_FILIAL, F6_EST, F6_NUMERO, R_E_C_N_O_, D_E_L_E_T_
	
		cChave := xFilial("SF6") + SA2->A2_EST + SE2->E2_PREFIXO + SE2->E2_NUM
	
		If ( SF6->(DBSeek(cChave)) ) .Or.;
			( SF6->(DBSeek(xFilial("SF6") + SA2->A2_EST +  Space(3) + SE2->E2_NUM)) .And. SF6->F6_EST = "SP" .And. SF6->F6_SERIE == SE2->E2_PREFIXO )
		
			If lDigVer
			
				cRet := SubStr(SF6->F6_CODREC, 6, 1)
				
			ElseIf !lPessoa .And. !lCnpjCpf
			
				cRet := SubStr(SF6->F6_CODREC, 1, 5)
				
			ElseIf lPessoa
				
				DBSelectArea("SA1")
				SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
	
				If SA1->(DBSeek(xFilial("SA1") + SF6->F6_CLIFOR + SF6->F6_LOJA))
					      	  
					If SA1->A1_PESSOA == "J"
						
						cRet := "2"
					
					Else
					
						cRet := "1"
					
					EndIf
					
				Else
				
					cRet := Space(1)
					
				EndIf
				
			ElseIf lCnpjCpf
			
				DBSelectArea("SA1")
				SA1->(DBSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
	
				If SA1->(DBSeek(xFilial("SA1") + SF6->F6_CLIFOR + SF6->F6_LOJA))
					
					If SA1->A1_PESSOA == "J"
						
						cRet := SA1->A1_CGC
					
					Else
					
						cRet := "000" + SA1->A1_CGC
					
					EndIf
					
				Else 
				
					cRet := Space(14)
				
				EndIf
				
			EndIf
		
		EndIf
	
	EndIf

	RestArea(aAreaSA2)
	RestArea(aAreaSF6)
	RestArea(aAreaSA1)
	
Return(cRet)

User Function BIA841B()

	Local cRet := Space(6)
	
	If cEmpAnt == "01"
	
		cRet := "523253"
	
	ElseIf cEmpAnt == "05"
	
		cRet := "523254"

	ElseIf cEmpAnt == "07"
	
		cRet := "524498"
	
	EndIf

Return(cRet)

User Function BIA841C()

	Local cRet := Space(9)
	
	If cEmpAnt == "01"
	
		cRet := "106186059"
	
	ElseIf cEmpAnt == "05"
	
		cRet := "930253520"

	ElseIf cEmpAnt == "07"
	
		cRet := "211406858"
	
	EndIf

Return(cRet)

User Function BIA841D()

	Local cRet := Space(25)
	
	If cEmpAnt == "01"
	
		cRet := "J020775460001760000000001"
	
	ElseIf cEmpAnt == "05"
	
		cRet := "J049172320001600000000001"

	ElseIf cEmpAnt == "07"
	
		cRet := "J105248370001930000000001"
	
	EndIf

Return(cRet)

User Function BIA841E(cCodBar, cLinhaDigC, cLinhaDigP)

	Local cRet := ""
	Local nW := 0
	Local cCodigo := ""
	
	Default cCodBar := ""
	Default cLinhaDigC := "" // E2_YLINDIG
	Default cLinhaDigP := "" // E2_LINDIG
	
	If Empty(cCodBar)
		
		If Empty(cLinhaDigC)
			
			If Empty(cLinhaDigP)
				
				cCodigo := AllTrim(SE2->E2_LINDIG) // Nao coube no cnab da gnre
				
			Else
			
				cCodigo := AllTrim(cLinhaDigP)
				
			EndIf
			
		Else
		
			cCodigo := AllTrim(cLinhaDigC)
		
		EndIf
		
	Else
	
		cCodigo := AllTrim(cCodBar)
	
	EndIf
	
	If Len(cCodigo) = 48
	
		For nW := 1 To Len(cCodigo) Step 12

			cRet += SubStr(cCodigo, nW, 11)
		
		Next nW
	
	Else
	
		cRet := cCodigo
	
	EndIf

Return(cRet)