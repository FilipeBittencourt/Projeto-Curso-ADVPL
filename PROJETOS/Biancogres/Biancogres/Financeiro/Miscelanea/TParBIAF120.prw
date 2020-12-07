#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF120
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF120 
@obs Ticket: 1937
@type Class
/*/

Class TParBIAF120 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data dDate
	Data aCompany
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBIAF120
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::dDate := dDataBase
	::aCompany := {}
	
	::Add()		
	
Return()


Method Add() Class TParBIAF120
		
	aAdd(::aParam, {1, "Data do Saldo", ::dDate, "@D", ".T.",,".T.",,.T.})
	
Return()


Method Box() Class TParBIAF120
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDate := ::aParRet[1]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF120
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF120
Local lRet := .T.
Local oObj := Nil	
	
	oObj := TWSelecaoEmpresa():New()
	oObj:Activate()
	
	If (::lConfirm := oObj:lConfirm)
	
		::aCompany := oObj:GetMark()
				
	EndIf	
		
Return(lRet)