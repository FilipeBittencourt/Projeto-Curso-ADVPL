#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0037; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaDuplicataNfeSefaz														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de duplicatas  |
| 				| da nota fiscal eletrônica 											|
|-----------------------------------------------------------|
*/


// Indices do array de Duplicatas
#DEFINE IDX_NumTit 1
#DEFINE IDX_DatVen 2
#DEFINE IDX_Valor 3


// Classe de interface
Class TIDuplicataNfeSefaz From LongClassName
	
	Data cNumTit // Prefixo + Numero + Parcela
	Data dDatVen
	Data nValor
			
	Method New() Constructor
	
EndClass


Method New() Class TIDuplicataNfeSefaz

Return()



Class TBiaDuplicataNfeSefaz From LongClassName	
	
	Data aDuplicata
	
	Data oLst
			
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaDuplicataNfeSefaz
	
	::aDuplicata := aClone(aParam)
	
	::oLst := ArrayList():New()	
	
	::Get()
	
Return()


Method Get() Class TBiaDuplicataNfeSefaz
Local nCount := 0
Local oObj := Nil

	If Len(::aDuplicata) > 0
	
		For nCount := 1 To Len(::aDuplicata)
		
			oObj := TIDuplicataNfeSefaz():New()
	
			oObj:cNumTit := ::aDuplicata[nCount, IDX_NumTit]
			oObj:dDatVen := ::aDuplicata[nCount, IDX_DatVen]
			oObj:nValor := ::aDuplicata[nCount, IDX_Valor]
					
			::oLst:Add(oObj)
			
		Next
	
	EndIf
		
Return()


Method Set() Class TBiaDuplicataNfeSefaz
Local nCount := 0

	If Len(::aDuplicata) > 0

		For nCount := 1 To ::oLst:GetCount()
	
			::aDuplicata[nCount, IDX_NumTit] := ::oLst:GetItem(nCount):cNumTit
			::aDuplicata[nCount, IDX_DatVen] := ::oLst:GetItem(nCount):dDatVen
			::aDuplicata[nCount, IDX_Valor] := ::oLst:GetItem(nCount):nValor
	
		Next
		
	EndIf

Return()


Method Update() Class TBiaDuplicataNfeSefaz
Local nCount := 0

	If SFT->FT_TIPOMOV == "S"
	
		For nCount := 1 To ::oLst:GetCount()
		
			DbSelectArea("SE1")
			DbSetOrder(1)
			If SE1->(DbSeek(xFilial("SE1") + ::oLst:GetItem(nCount):cNumTit + MVNOTAFIS))
				
				::oLst:GetItem(nCount):dDatVen := SE1->E1_VENCTO
				
			EndIf
		
		Next

	EndIf
	
	::Set()
		
Return(::aDuplicata)