#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0039; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaEspecieVolumeNfeSefaz												|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 07/04/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array especie/volume |
| 				| da nota fiscal eletrônica 											|
|-----------------------------------------------------------|
*/

// Indices do array de notas
#DEFINE IDX_Especie 1
#DEFINE IDX_Volume 2
#DEFINE IDX_PLiquido 3
#DEFINE IDX_PBruto 4
#DEFINE IDX_Marca 5


// Classe de Interface
Class TIEspecieVolumeNfeSefaz From LongClassName
	
	Data cEspecie
	Data nVolume
	Data nPLiquido
	Data nPBruto
	Data cMarca
	
	Method New() Constructor
	
EndClass


Method New() Class TIEspecieVolumeNfeSefaz

Return()
	

Class TBiaEspecieVolumeNfeSefaz From LongClassName
	
	Data aEspVol
	
	Data oLst
	
	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaEspecieVolumeNfeSefaz

	::aEspVol := aClone(aParam)
	
	::oLst := ArrayList():New()
	
	::Get()
		
Return()


Method Get() Class TBiaEspecieVolumeNfeSefaz
Local nCount := 0
Local oObj := Nil

	If Len(::aEspVol) > 0

		For nCount := 1 To Len(::aEspVol)
		
			oObj := TIEspecieVolumeNfeSefaz():New()

			oObj:cEspecie := ::aEspVol[nCount, IDX_Especie]
			oObj:nVolume := ::aEspVol[nCount, IDX_Volume]
			oObj:nPLiquido := ::aEspVol[nCount, IDX_PLiquido]
			oObj:nPBruto := ::aEspVol[nCount, IDX_PBruto]
			oObj:cMarca := ""

			// Adiciona posicao 05 ao array para tratar a marca produto
			aAdd(::aEspVol[nCount], oObj:cMarca)
			
			::oLst:Add(oObj)
			
		Next

	EndIf

Return()


Method Set() Class TBiaEspecieVolumeNfeSefaz
Local nCount := 0

	If Len(::aEspVol) > 0
	
		For nCount := 1 To ::oLst:GetCount()

			::aEspVol[nCount, IDX_Especie] := ::oLst:GetItem(nCount):cEspecie
			::aEspVol[nCount, IDX_Volume] := ::oLst:GetItem(nCount):nVolume
			::aEspVol[nCount, IDX_PLiquido] := ::oLst:GetItem(nCount):nPLiquido
			::aEspVol[nCount, IDX_PBruto] := ::oLst:GetItem(nCount):nPBruto
			::aEspVol[nCount, IDX_Marca] := ::oLst:GetItem(nCount):cMarca
			
		Next

	EndIf

Return()


Method Update() Class TBiaEspecieVolumeNfeSefaz
Local nCount := 0
	
	For nCount := 1 To ::oLst:GetCount()
		
		If SFT->FT_TIPOMOV == "S"			
			::oLst:GetItem(nCount):cMarca := SF2->F2_YMARCA
		Else
			::oLst:GetItem(nCount):cMarca := ""
		EndIf
		
	Next
	
	::Set()
		
Return(::aEspVol)