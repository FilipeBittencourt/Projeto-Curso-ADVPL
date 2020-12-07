#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParA120PIDF
@author Tiago Rossini Coradini
@since 19/01/2018
@version 1.0
@description Classe para manipulação de parametros da rotina A120PIDF 
@obs Ticket: 1449 - Projeto Demandas Compras - Item 3
@type Class
/*/

Class TParA120PIDF From LongClassName

	Data cName
	Data aParam
	Data aAuxPar
	
	Data cFilSC // Filtra SC 
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method BkpMvPar() // Backup das variaves MV_PAR
	Method ResMvPar() // Restaura variaves MV_PAR	
	
EndClass


Method New() Class TParA120PIDF
	
	::cName := "A120PIDF"
	
	::aParam := {}
	::aAuxPar := {}

	::cFilSC := "Todas"
	
	::Add()		
	
Return()


Method Add() Class TParA120PIDF
		
	aAdd(::aParam, {2, "Filtro de Solicitação de Compra", ::cFilSC, {"Todas", "Com Tabela", "Sem Tabela"}, 60, ".T.", .F.})

Return()


Method Box() Class TParA120PIDF
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	::BkpMvPar()
	
	If ParamBox(::aParam, "Solicitação de Compra", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cFilSC := aRet[1]

	EndIf
	
	::ResMvPar()
	
Return(lRet)


Method BkpMvPar(nPar) Class TParA120PIDF
Local nCount := {}
	
	For nCount := 1 To Len(::aParam)
	
		aAdd(::aAuxPar, &("MV_PAR" + StrZero(nCount, 2)))
		
	Next
	
Return()


Method ResMvPar() Class TParA120PIDF
Local nCount := 0

	For nCount := 1 To Len(::aAuxPar)
		
		&("MV_PAR" + StrZero(nCount, 2)) := ::aAuxPar[nCount]
	
	Next

Return()