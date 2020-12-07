#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF159
@author Tiago Rossini Coradini
@since 11/10/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF159
@type function
/*/

Class TParBIAF159 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data cClvlOri
	Data cClvlDes

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Validate()	
	Method Confirm()
	
EndClass


Method New() Class TParBIAF159
	
	::cName := "BIAF159"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .T.

	::cClvlOri := Space(TamSx3("C3_YCLVL")[1])
	::cClvlDes := Replicate("Z", TamSx3("C3_YCLVL")[1])

	::Add()
	
Return()


Method Add() Class TParBIAF159
	
  aAdd(::aParam, {1, "Clvl Origem", ::cClvlOri, "@!", ".T.", "CTH", ".T.",,.T.})  
  aAdd(::aParam, {1, "Clvl Destino", ::cClvlDes, "@!", ".T.", "CTH", ".T.",,.T.})

Return()


Method Box() Class TParBIAF159
Local lRet := .F.
Private cCadastro := "Parametros"
		
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cClvlOri := ::aParRet[1]
		::cClvlDes := ::aParRet[2]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF159
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Validate() Class TParBIAF159
Local lRet := .T.
Local lExiOri := If (!Empty(Posicione("ZMA", 2, xFilial("ZMA") + MV_PAR01, "ZMA_CODIGO")), .T., .F.)
Local lExiDes := If (!Empty(Posicione("ZMA", 2, xFilial("ZMA") + MV_PAR02, "ZMA_CODIGO")), .T., .F.)
	
	If MV_PAR01 == MV_PAR02
			
		lRet := .F.
		
		MsgStop("Atenção, as classes de valor de Origem e Destino devem ser diferentes.")
			
	ElseIf !lExiOri
		
		lRet := .F.
		
		MsgStop("Atenção, classe de valor de Origem não possui subitem cadastrado.")
	
	ElseIf lExiDes
		
		lRet := .F.
		
		MsgStop("Atenção, classe de valor de Destino já possui subitem cadastrado.")
				
	EndIf
	
Return(lRet)


Method Confirm() Class TParBIAF159
	
	::lConfirm := ::Validate()
		
Return(::lConfirm)