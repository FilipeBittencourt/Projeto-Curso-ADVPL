#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} GT1ITEM
// Ponto de entrada do Importador XML.
@author
@since 07/06/2017
@version undefined

@type function
/*/
User Function GT1ITEM()


	Local aParam  := PARAMIXB
	Local aAdItem := {}

	Local _nPosLote   := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_LOTECT"  , 10)})
	Local _nPosValid   := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_DTVALI"  , 10)})
	Local _nPosClvl  := AScan(aHeader, {|x| x[2] == PadR(_cCmp2 + "_CLVL"  , 10)})

	If _nPosLote > 0
		If !Empty(aParam[_nPosLote])
			AAdd(aAdItem, {"D1_LOTECTL", aParam[_nPosLote], Nil})  //NF LOTE
		EndIf
	EndIf

	If _nPosValid > 0
		If !Empty(aParam[_nPosValid])
			AAdd(aAdItem, {"D1_DTVALID", aParam[_nPosValid], Nil})  //Data Validade
		EndIf
	EndIf
	
	If _nPosClvl > 0
		If !Empty(aParam[_nPosClvl])
			AAdd(aAdItem, {"D1_CLVL", aParam[_nPosClvl], Nil})  //Classe de Valor
		EndIf
	EndIf
	
	


Return(aAdItem)