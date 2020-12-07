/*/{Protheus.doc} M461SER
@author Ranisses A. Corona
@since 16/11/2018
@version 1.0
@description Gera Série e Numero NF automaticamente de acordo com a regra - Projeto Consolidacao CNPJ
@type function
/*/

User Function M461SER()
	Local aArea	:= GetArea()
	Local cSer	:= cSerie

	If IsInCallStack("U_BACP0010")
		cSerie	:= cSer												//Atualiza Série, de acordo com a regra.
		cNumero := NxtSX5Nota(cSer,.T.,SuperGetMV("MV_TPNRNFS"))	//Gera Numero da NF automatico, conforme Série.
		Return
	EndIf

	If cEmpAnt == "01" //Biancogres

		If Alltrim(SC5->C5_YEMP) == "0101" .Or. (SC5->C5_CLIENTE) == "004536" 
			cSer := "1  "		
		ElseIf Alltrim(SC5->C5_YEMP) == "0501"
			cSer := "2  "
		ElseIf Alltrim(SC5->C5_YEMP) == "0599"
			cSer := "3  "
		ElseIf AllTrim(SC5->C5_YEMP) == '0199'
			cSer := "4  "
		EndIf

	ElseIf cEmpAnt == "05" //Incesa

		If Alltrim(SC5->C5_YEMP) $ "0101_0501"
			cSer := "1  "
		ElseIf Alltrim(SC5->C5_YEMP) == "0599"
			cSer := "2  "
		EndIf	

	ElseIf cEmpAnt == "07" //LM

		If Alltrim(SC5->C5_YEMP) == "0101"
			cSer := "1  "
		ElseIf Alltrim(SC5->C5_YEMP) == "0501"
			cSer := "2  "
		ElseIf Alltrim(SC5->C5_YEMP) == "0599"
			cSer := "3  "
		ElseIf Alltrim(SC5->C5_YEMP) == "1399"
			cSer := "4  "
		ElseIf AllTrim(SC5->C5_YEMP) == '0199'
			cSer := "6  "
		ElseIf AllTrim(SC5->C5_YEMP) == '1302'
			cSer := "7  "	
		EndIf
		
		If (cEmpAnt == "07" .And. cFilAnt == '05')
			
			If AllTrim(SC5->C5_YEMP) == '1302'
				cSer := "1  "	
			EndIf
			
		EndIf

	ElseIf cEmpAnt == "13" //Mundi

		If Alltrim(SC5->C5_YEMP) == "1301"
			cSer := "1  "
		ElseIf Alltrim(SC5->C5_YEMP) == "1302"
			cSer := "2  "
		EndIf		

	EndIf

	cSerie	:= cSer												//Atualiza Série, de acordo com a regra.
	cNumero := NxtSX5Nota(cSer,.T.,SuperGetMV("MV_TPNRNFS"))	//Gera Numero da NF automatico, conforme Série.

	RestArea(aArea)
Return 