#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF066
@author Tiago Rossini Coradini
@since 09/02/2017
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF066 
@obs OS: 4031-15 - Clebes Jose
@obs OS: 0089-17 - Clebes Jose
@type Class
/*/

Class TParBIAF066 From LongClassName

	Data cName
	Data aParam
	
	Data cNumFat // Numero da fatura
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAF066
	
	::cName := "BIAF066"
	
	::aParam := {}
	
	::cNumFat := Space(9)
	
	::Add()		
	
Return()


Method Add() Class TParBIAF066
		
	aAdd(::aParam, {1, "Número Fatura", ::cNumFat, "@!",".T.",,".T.",,.F.})
		
Return()


Method Box() Class TParBIAF066
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cNumFat := aRet[1]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF066
	
	::aParam := {}	
	
	::Add()
	
Return()