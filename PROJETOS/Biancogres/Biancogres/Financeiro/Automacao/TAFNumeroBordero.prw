#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFNumeroBordero
@author Wlysse Cerqueira (Facile)
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras para geração de borderos de recebimento, agrupados por regras/banco
@type class
/*/

Class TAFNumeroBordero From LongClassName

	Data oLog // Objeto de log de processamento
	Data cIDProc // Identificar do processo
		
	Method New() Constructor
	Method GetNumBorReceber()
	Method GetNumBorPagar()
	
EndClass


Method New() Class TAFNumeroBordero
	
	::oLog := TAFLog():New()
	::cIDProc := ""
	
Return()

Method GetNumBorReceber() Class TAFNumeroBordero
Local cRet := ""

	cRet := Soma1(GetMV("MV_NUMBORR"), 6)
	
	cRet := Replicate("0", 6 - Len(Alltrim(cRet))) + Alltrim(cRet)
	
	While !MayIUseCode("SE1" + xFilial("SE1") + cRet)
		
		cRet := Soma1(cRet)
		
	EndDo
	
	PutMv("MV_NUMBORR", cRet)

Return(cRet)

Method GetNumBorPagar() Class TAFNumeroBordero
Local cRet := ""
	
	Local nTamBor := TamSx3("E2_NUMBOR")[1]
	
	DbSelectArea("SX6")
	
	cRet := Soma1(Pad(GetMV("MV_NUMBORP"), nTamBor), nTamBor)

	While !MayIUseCode( "E2_NUMBOR" + SX6->X6_FIL + cRet)  //verifica se esta na memoria, sendo usado

		cRet := Soma1(cRet) // busca o proximo numero disponivel

	EndDo
	
	PutMv("MV_NUMBORP", cRet)
	
Return(cRet)