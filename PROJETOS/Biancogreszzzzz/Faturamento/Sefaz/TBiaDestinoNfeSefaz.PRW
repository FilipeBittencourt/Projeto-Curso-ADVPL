#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0036; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaDestinoNfeSefaz															|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/01/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação do array de destino     |
| 				| da nota fiscal eletrônica 											|
|-----------------------------------------------------------|
*/

// Indices do array de Destinos
#DEFINE IDX_Cgc 1
#DEFINE IDX_Nome 2
#DEFINE IDX_End 3
#DEFINE IDX_Num 4
#DEFINE IDX_Compl 5
#DEFINE IDX_Bairro 6
#DEFINE IDX_CodMun 7
#DEFINE IDX_Mun 8
#DEFINE IDX_Uf 9
#DEFINE IDX_Cep 10
#DEFINE IDX_CodPais 11
#DEFINE IDX_Pais 12
#DEFINE IDX_Tel 13
#DEFINE IDX_Insc 14
#DEFINE IDX_Suframa 15
#DEFINE IDX_Email 16
#DEFINE IDX_Contrib 17
#DEFINE IDX_IenCont 18
#DEFINE IDX_InscR 19
#DEFINE IDX_Tipo 20
#DEFINE IDX_Pfisica 21


Class TBiaDestinoNfeSefaz From LongClassName	
			
	Data aDestino
	
	Data cCgc
	Data cNome
	Data cEnd
	Data cNum
	Data cCompl
	Data cBairro
	Data cCodMun
	Data cMun
	Data cUf
	Data cCep
	Data cCodPais
	Data cPais
	Data cTel
	Data cInsc
	Data cSuframa
	Data cEmail
	Data cContrib
	Data cIenCont
	Data cInscR
	Data cTipo
	Data cPfisica

	Method New(aParam) Constructor
	Method Get()
	Method Set()
	Method Update()
	
EndClass


Method New(aParam) Class TBiaDestinoNfeSefaz

	::aDestino := aClone(aParam)
	
	::Get()
	
Return()


Method Get() Class TBiaDestinoNfeSefaz

	If Len(::aDestino) > 0
	
		::cCgc := ::aDestino[IDX_Cgc]
		::cNome := ::aDestino[IDX_Nome]
		::cEnd := ::aDestino[IDX_End]
		::cNum := ::aDestino[IDX_Mun]
		::cCompl := ::aDestino[IDX_Compl]
		::cBairro := ::aDestino[IDX_Bairro]
		::cCodMun := ::aDestino[IDX_CodMun]
		::cMun := ::aDestino[IDX_Mun]
		::cUf := ::aDestino[IDX_Uf]
		::cCep := ::aDestino[IDX_Cep]
		::cCodPais := ::aDestino[IDX_CodPais]
		::cPais := ::aDestino[IDX_Pais]
		::cTel := ::aDestino[IDX_Tel]
		::cInsc := ::aDestino[IDX_Insc]
		::cSuframa := ::aDestino[IDX_Suframa]
		::cEmail := ::aDestino[IDX_Email]
		::cContrib := ::aDestino[IDX_Contrib]
		::cIenCont := ::aDestino[IDX_IenCont]
		::cInscR := ::aDestino[IDX_InscR]
		::cTipo := ::aDestino[IDX_Tipo]
		::cPfisica := ::aDestino[IDX_Pfisica]
		
	EndIf

Return()


Method Set() Class TBiaDestinoNfeSefaz

	If Len(::aDestino) > 0
	
		::aDestino[IDX_Cgc]		:= ::cCgc
		::aDestino[IDX_Nome]	:= ::cNome
		::aDestino[IDX_End]		:= ::cEnd
		::aDestino[IDX_Mun]		:= ::cNum
		::aDestino[IDX_Compl]	:= ::cCompl
		::aDestino[IDX_Bairro]	:= ::cBairro
		::aDestino[IDX_CodMun]	:= ::cCodMun
		::aDestino[IDX_Mun]		:= ::cMun
		::aDestino[IDX_Uf]		:= ::cUf
		::aDestino[IDX_Cep]		:= ::cCep
		::aDestino[IDX_CodPais]	:= ::cCodPais
		::aDestino[IDX_Pais]	:= ::cPais
		::aDestino[IDX_Tel]		:= ::cTel
		::aDestino[IDX_Insc]	:= ::cInsc
		::aDestino[IDX_Suframa]	:= ::cSuframa
		::aDestino[IDX_Email] 	:= ::cEmail
		::aDestino[IDX_Contrib] := ::cContrib
		::aDestino[IDX_IenCont] := ::cIenCont
		::aDestino[IDX_InscR] 	:= ::cInscR
		::aDestino[IDX_Tipo] 	:= ::cTipo
		::aDestino[IDX_Pfisica]	:= ::cPfisica
			
	EndIf
	
Return()


Method Update() Class TBiaDestinoNfeSefaz

If SFT->FT_TIPOMOV == "S" .And. !SFT->FT_TIPO $ "DB"		
	If Empty(SA1->A1_YMAILNF)
		::cEmail := SA1->A1_EMAIL
	Else
		::cEmail := SA1->A1_YMAILNF
	EndIf
EndIf

//Retira caracteres especiais - Problema na NF 4.0
::cNome		:= U_fDelTab(::cNome)
::cEnd		:= U_fDelTab(::cEnd)
::cCompl	:= U_fDelTab(::cCompl)
::cEmail	:= U_fDelTab(::cEmail)

::Set()
						
Return(::aDestino)