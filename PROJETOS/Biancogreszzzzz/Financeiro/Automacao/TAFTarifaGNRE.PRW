#INCLUDE "TOTVS.CH"

Class TAFTarifaGNRE From LongClassName

	Data nValor
	
	Method New() Constructor
	Method TarifaPorEstado()
	Method GetUFSubTrib()

EndClass


Method New() Class TAFTarifaGNRE

	::nValor		:= 0	
	
Return()


Method GetUFSubTrib() Class TAFTarifaGNRE

	Local aLista	:= {}
	Local aNLista	:= {}		
	Local nI		:= 0
	Local cSubTrib	:= GetMv("MV_SUBTRIB")
	
	aLista := StrTokArr(cSubTrib, "/")	
	
	For nI :=1 To Len (aLista)
		Aadd(aNLista, SUBSTR (aLista[nI], 1, 2))
	Next nI
	
Return(aNLista)


Method TarifaPorEstado(cUF) Class TAFTarifaGNRE

	Local nTafUFCC		:= GetMv("MV_YTUFCC")//tarifa uf com convenio
	Local nTafUFSC		:= GetMv("MV_YTUFSC")//tarifa uf sem conveio
	Local aListUFSub	:= ::GetUFSubTrib()
	
	Local nExite 		:= AScan(aListUFSub, {|x| AllTrim(x) == AllTrim(cUF) } )
	
	If (nExite > 0) // caso existe 
		::nValor := nTafUFCC
	Else	//caso não exista
		::nValor := nTafUFSC
	EndIf
	
Return(::nValor)

