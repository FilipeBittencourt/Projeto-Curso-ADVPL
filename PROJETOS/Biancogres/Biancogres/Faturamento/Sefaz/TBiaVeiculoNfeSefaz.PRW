#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0046; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaVeiculoNfeSefaz															|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 04/02/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array veiculo da 		|
| 				| nota fiscal eletrônica 													|
|-----------------------------------------------------------|
*/

// Indices do array de notas
#DEFINE IDX_Placa 1
#DEFINE IDX_Uf 2
#DEFINE IDX_Rntc 3


Class TBiaVeiculoNfeSefaz From LongClassName
	
	Data aVeiculo
	
	Data cPlaca
	Data cUf
	Data cRntc
			
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaVeiculoNfeSefaz

	::aVeiculo := aClone(aParam)
	
	::Get()
		
Return()


Method Get() Class TBiaVeiculoNfeSefaz

	If Len(::aVeiculo) > 0

		::cPlaca := ::aVeiculo[IDX_Placa]
		::cUf := ::aVeiculo[IDX_Uf]
		::cRntc := ::aVeiculo[IDX_Rntc]
		
	EndIf

Return()


Method Set() Class TBiaVeiculoNfeSefaz

	If Len(::aVeiculo) > 0

		::aVeiculo[IDX_Placa] := ::cPlaca
		::aVeiculo[IDX_Uf] := ::cUf
		::aVeiculo[IDX_Rntc] := ::cRntc
	
	// Tratamento quando o array vem vazio
	ElseIf !Empty(::cPlaca)
		
		aAdd(::aVeiculo, ::cPlaca)
		aAdd(::aVeiculo, ::cUf)
		aAdd(::aVeiculo, ::cRntc)

	EndIf

Return()


Method Update() Class TBiaVeiculoNfeSefaz
	
	If SFT->FT_TIPOMOV == "S"
			
		If !Empty(SF2->F2_YPLACA)
			
			::cPlaca := SubStr(SF2->F2_YPLACA, 1, 8)
			::cUf := Upper(SF2->F2_YUF)
			::cRntc := ""
			
		EndIf 
			
	EndIf
				
	::Set()
	
Return(::aVeiculo)