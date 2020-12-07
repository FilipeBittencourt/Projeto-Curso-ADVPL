#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF110
@author Tiago Rossini Coradini
@since 17/05/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF110 
@obs Ticket: 4615
@type Class
/*/

Class TParBIAF110 From LongClassName

	Data cName

	Data aParam // Vetor com as configurações dos parametros
	Data aBkpParam	// Vetor com os valores do MV_PAR padroes
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data dStartDate 
	Data dEndDate
	Data aBank
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Backup()
	Method Restore()		
	Method Update()
	Method Confirm()
	
EndClass


Method New() Class TParBIAF110
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aBkpParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	
	::dStartDate := dDataBase
	::dEndDate := dDataBase
	::aBank := {}

	::Add()		
	
Return()


Method Add() Class TParBIAF110
		
	aAdd(::aParam, {1, "Data De", ::dStartDate, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Data Ate", ::dEndDate, "@D", ".T.",,".T.",,.T.})
	
Return()


Method Box() Class TParBIAF110
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	::Backup()
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dStartDate := ::aParRet[1]
		::dEndDate := ::aParRet[2]

	EndIf
	
	::Restore()
	
Return(lRet)


Method Backup() Class TParBIAF110
Local nCount := {}
	
	For nCount := 1 To Len(::aParam)
	
		aAdd(::aBkpParam, &("MV_PAR" + StrZero(nCount, 2)))
		
	Next

Return()


Method Restore() Class TParBIAF110
Local nCount := 0

	For nCount := 1 To Len(::aBkpParam)
		
		&("MV_PAR" + StrZero(nCount, 2)) := ::aBkpParam[nCount]
	
	Next
	
Return()


Method Update() Class TParBIAF110
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF110
Local lRet := .T.
Local oObj := Nil		
	
	oObj := TWSelecaoContaBanco():New()	
	oObj:Activate()
	
	If (::lConfirm := oObj:lConfirm)
	
		::aBank := oObj:GetMark()
				
	EndIf
		
Return(lRet)