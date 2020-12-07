#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0040; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaInfoItemNfeSefaz														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de informações |
| 				| do item da nota fiscal eletrônica 							|
|-----------------------------------------------------------|
*/

// Indices do array de InfoItems
#DEFINE IDX_NumPed 1
#DEFINE IDX_ItPed 2
#DEFINE IDX_Tes 3
#DEFINE IDX_ItNf 4


// Classe de interface
Class TIInfoItemNfeSefaz From LongClassName

	Data cNumPed
	Data cItPed
	Data cTes
	Data cItNf
	
	Method New() Constructor
	
EndClass


Method New() Class TIInfoItemNfeSefaz

Return()



Class TBiaInfoItemNfeSefaz From LongClassName
	
	Data aInfoItem
	
	Data oLst
			
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaInfoItemNfeSefaz
	
	::aInfoItem := aClone(aParam)
	
	::oLst := ArrayList():New()
	
	::Get()
	
Return()


Method Get() Class TBiaInfoItemNfeSefaz
Local nCount := 0
Local oObj := Nil

	If Len(::aInfoItem) > 0
	
		For nCount := 1 To Len(::aInfoItem)
		
			oObj := TIInfoItemNfeSefaz():New()
	
			oObj:cNumPed := ::aInfoItem[nCount, IDX_NumPed]
			oObj:cItPed := ::aInfoItem[nCount, IDX_ItPed]
			oObj:cTes := ::aInfoItem[nCount, IDX_Tes]
			oObj:cItNf := ::aInfoItem[nCount, IDX_ItNf]
					
			::oLst:Add(oObj)
			
		Next
		
	EndIf
	
Return()


Method Set() Class TBiaInfoItemNfeSefaz
Local nCount := 0

	If Len(::aInfoItem) > 0
		
		For nCount := 1 To ::oLst:GetCount()

			::aInfoItem[nCount, IDX_NumPed] := ::oLst:GetItem(nCount):cNumPed
			::aInfoItem[nCount, IDX_ItPed] := ::oLst:GetItem(nCount):cItPed
			::aInfoItem[nCount, IDX_Tes] := ::oLst:GetItem(nCount):cTes
			::aInfoItem[nCount, IDX_ItNf] := ::oLst:GetItem(nCount):cItNf
		
		Next
			
	EndIf
	
Return()


Method Update() Class TBiaInfoItemNfeSefaz

	::Set()
	
Return(::aInfoItem)