#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0043; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaNotaNfeSefaz															  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de notas da 		|
| 				| nota fiscal eletrônica 													|
|-----------------------------------------------------------|
*/

// Indices do array de notas
#DEFINE IDX_Serie 1
#DEFINE IDX_Doc 2
#DEFINE IDX_Emissao 3
#DEFINE IDX_Tipo 4
#DEFINE IDX_TipDoc 5
#DEFINE IDX_Hora 6
#DEFINE IDX_DataSaiEnt 7


Class TBiaNotaNfeSefaz From LongClassName
	
	Data aNota
	
	Data cSerie
	Data cDoc
	Data cEmissao
	Data cTipo
	Data cTipDoc
	Data cHora
	Data cDataSaiEnt
			
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaNotaNfeSefaz
	
	::aNota := aClone(aParam)
	
	::Get()
	
Return()


Method Get() Class TBiaNotaNfeSefaz

	If Len(::aNota) > 0

		::cSerie := ::aNota[IDX_Serie]
		::cDoc := ::aNota[IDX_Doc]
		::cEmissao := ::aNota[IDX_Emissao]
		::cTipo := ::aNota[IDX_Tipo]
		::cTipDoc := ::aNota[IDX_TipDoc]
		::cHora := ::aNota[IDX_Hora]
		
		// Adiciona posicao 07 ao array para tratar data de saida/entrada das notas
		::cDataSaiEnt := ::aNota[IDX_Emissao]
		aAdd(::aNota, ::cDataSaiEnt)
		
	EndIf

Return()


Method Set() Class TBiaNotaNfeSefaz
	
	If Len(::aNota) > 0
	
		::aNota[IDX_Serie] := ::cSerie
		::aNota[IDX_Doc] := ::cDoc
		::aNota[IDX_Emissao] := ::cEmissao
		::aNota[IDX_Tipo] := ::cTipo
		::aNota[IDX_TipDoc] := ::cTipDoc
		::aNota[IDX_Hora] := ::cHora
		::aNota[IDX_DataSaiEnt] := ::cDataSaiEnt
		
	EndIf

Return()


Method Update() Class TBiaNotaNfeSefaz			

	If SFT->FT_TIPOMOV == "S"			
		
		// Data de saida
		If !Empty(SF2->F2_YDES)
			::cDataSaiEnt := SF2->F2_YDES
		EndIf
		
	EndIf	
				
	::Set()
			
Return(::aNota)