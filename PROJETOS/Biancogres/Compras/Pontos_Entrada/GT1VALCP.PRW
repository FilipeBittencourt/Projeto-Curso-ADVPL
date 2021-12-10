#include 'protheus.ch'
#include 'parmtype.ch'
//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} GT1VALCP
// Ponto de entrada do Importador XML para preencher algum campo automáticamente
@author ConexãoNF-e
@since 15/08/2018
@version undefined
@type user function
/*/
//----------------------------------------------------------------------------------------------
User Function GT1VALCP()

	Local aItens 		:= PARAMIXB[1]
	Local nLinha 		:= PARAMIXB[2]
	Local nTipoXML 		:= PARAMIXB[3] // 1=NFE;2=Devolução/Retorno/Beneficiamento;3=Compl.Preço/ICMS/IPI;4=NF Serviço
	Local _nPosTES 		:= 0
	Local _nPosCF 		:= 0
	Local _nPosLocal 	:= 0
	Local _nPosprod 	:= 0
	Local _nLote		:= ""
	
	Local kjTES 		:= ""

	Local sNota 		:= ""
	Local sSerie 		:= ""
	Local sForn 		:= ""
	Local sLoja 		:= ""
	Local sProd			:= ""

	If nTipoXML == "1"
	
		sNota 		:= ZAA->ZAA_DOC
		sSerie 		:= ZAA->ZAA_SERIE
		sForn 		:= ZAA->ZAA_CODEMI
		sLoja 		:= ZAA->ZAA_LOJEMI
		_nPosTES 	:= AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_TES"  , 10)})
		_nPosCF 	:= AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CF"  , 10)})
		_nPosLocal 	:= AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_LOCAL"  , 10)})
		_nPosprod	:= AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_COD"  , 10)})
		_nLote		:= AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_LOTECT"  , 10)})

		If sForn $ "007602/002912/000534/004695"

			aInfOri	:= U_GetInfO2(sNota,sSerie,sForn,sLoja,"","",cEmpAnt)
			zp_Empr := aInfOri[1]

			//Define o TES
			kjTES := "003"
			If Alltrim(aInfOri[15]) == 'B'
				kjTES := '0A5'
			Else
				If zp_Empr == '01' .or. zp_Empr == '05'
				kjTES := '3A4'
					If cEmpAnt = '05'
						kjTES := '2A3'
					EndIf
				ElseIf zp_Empr == '07'
					If cFilAnt == "01"
						kjTES := "001"
					ElseIf cFilAnt == "02"
						kjTES := "001"
					ElseIf cFilAnt == "03"
						kjTES := "001"
					ElseIf cFilAnt == "04"
						kjTES := "001"
					EndIf
				ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) <> 'A'
					//kjTES := '0A3'
					kjTES := '0A4'
				ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) == 'A'
					kjTES := '1C6'
				ElseIf cEmpAnt == '14' .and. zp_Empr == '01'
					kjTES := '001'	
				ElseIf zp_Empr == '14'
					kjTES := '4J7'
				EndIf
			EndIf

			If _nPosTES > 0
				aCols[nLinha, _nPosTES] := kjTES
			EndIf
			If _nPosCF > 0
				aCols[nLinha, _nPosCF] := Posicione("SF4", 1, xFilial("SF4") + kjTES, "F4_CF")
			EndIf
			
			If (_nPosLocal > 0 .And. _nPosprod > 0 .And. _nLote > 0)
				
				sProd := aCols[nLinha, _nPosprod]
				
				If (U_CAMTMUND(sForn, sNota, sSerie, sProd))
					
					aCols[nLinha, _nPosLocal]	:= '05'
					//aCols[nLinha, _nLote] 		:= 'AMT'
					
				EndIf
								
			EndIf
			
		EndIf
	EndIf

Return
