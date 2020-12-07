#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0038; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaEntregaNfeSefaz															|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de entrega     |
| 				| da nota fiscal eletrônica 											|
|-----------------------------------------------------------|
*/


// Indices do array de Entregas
#DEFINE IDX_Cgc 1
#DEFINE IDX_End 2
#DEFINE IDX_Num 3
#DEFINE IDX_Compl 4
#DEFINE IDX_Bairro 5
#DEFINE IDX_CodMun 6
#DEFINE IDX_Mun 7
#DEFINE IDX_Uf 8
#DEFINE IDX_Nome 9
#DEFINE IDX_Insc 10


Class TBiaEntregaNfeSefaz From LongClassName	
	
	Data aEntrega
	
	Data cCgc	
	Data cEnd
	Data cNum
	Data cCompl
	Data cBairro
	Data cCodMun
	Data cMun
	Data cUf
	Data cNome	
	Data cInsc

	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaEntregaNfeSefaz
	
	::aEntrega := aClone(aParam)
	
	::Get()
		
Return()


Method Get() Class TBiaEntregaNfeSefaz
	
	If Len(::aEntrega) > 0
	
		::cCgc := ::aEntrega[IDX_Cgc]
		::cEnd := ::aEntrega[IDX_End]
		::cNum := ::aEntrega[IDX_Mun]
		::cCompl := ::aEntrega[IDX_Compl]
		::cBairro := ::aEntrega[IDX_Bairro]
		::cCodMun := ::aEntrega[IDX_CodMun]
		::cMun := ::aEntrega[IDX_Mun]
		::cUf := ::aEntrega[IDX_Uf]
		::cNome := ::aEntrega[IDX_Nome]
		::cInsc := ::aEntrega[IDX_Insc]
	
	EndIf

Return()


Method Set() Class TBiaEntregaNfeSefaz

	If Len(::aEntrega) > 0
	
		::aEntrega[IDX_Cgc] := ::cCgc
		::aEntrega[IDX_End] := ::cEnd
		::aEntrega[IDX_Mun] := ::cNum
		::aEntrega[IDX_Compl] := ::cCompl
		::aEntrega[IDX_Bairro] := ::cBairro
		::aEntrega[IDX_CodMun] := ::cCodMun
		::aEntrega[IDX_Mun] := ::cMun
		::aEntrega[IDX_Uf] := ::cUf
		::aEntrega[IDX_Nome] := ::cNome
		::aEntrega[IDX_Insc] := ::cInsc
	
	EndIf

Return()


Method Update() Class TBiaEntregaNfeSefaz

	::Set()

Return(::aEntrega)