#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0045; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaTransportadorNfeSefaz												|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de  					  |
| 				| Transportadores da nota fiscal eletrônica 		  |
|-----------------------------------------------------------|
*/

// Indices do array de Transportadors
#DEFINE IDX_Cgc 1
#DEFINE IDX_Nome 2
#DEFINE IDX_Insc 3
#DEFINE IDX_End 4
#DEFINE IDX_Mun 5
#DEFINE IDX_Uf 6
#DEFINE IDX_Email 6


Class TBiaTransportadorNfeSefaz From LongClassName
	
	Data aTransportador
	
	Data cCgc
	Data cNome
	Data cInsc
	Data cEnd
	Data cMun
	Data cUf
	Data cEmail
			
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaTransportadorNfeSefaz
  
	::aTransportador := aClone(aParam)
	
	::Get()
		
Return()


Method Get() Class TBiaTransportadorNfeSefaz
	
	If Len(::aTransportador) > 0
	
		::cCgc := ::aTransportador[IDX_Cgc]
		::cNome := ::aTransportador[IDX_Nome]
		::cInsc := ::aTransportador[IDX_Insc]
		::cEnd := ::aTransportador[IDX_End]
		::cMun := ::aTransportador[IDX_Mun]
		::cUf := ::aTransportador[IDX_Uf]
		::cEmail := ::aTransportador[IDX_Email]
	
	EndIf

Return()


Method Set() Class TBiaTransportadorNfeSefaz

	If Len(::aTransportador) > 0
	
		::aTransportador[IDX_Cgc] := ::cCgc
		::aTransportador[IDX_Nome] := ::cNome
		::aTransportador[IDX_Insc] := ::cInsc
		::aTransportador[IDX_End] := ::cEnd
		::aTransportador[IDX_Mun] := ::cMun
		::aTransportador[IDX_Uf] := ::cUf
		::aTransportador[IDX_Email] := ::cEmail
	
	EndIf

Return()


Method Update() Class TBiaTransportadorNfeSefaz

	//Retira caracteres especiais - Problema na NF 4.0
	If ::cNome <> Nil
		::cNome		:= U_fDelTab(::cNome)
		::cEnd		:= U_fDelTab(::cEnd)
		::cEmail	:= U_fDelTab(::cEmail)
	EndIf

	::Set()
	
Return(::aTransportador)