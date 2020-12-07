#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0030; Return()

/*/{Protheus.doc} TParBIAFR005
@author Tiago Rossini Coradini
@since 18/01/2016
@version 2.0
@description Classe para manipulação de parametros da rotina BIAFR005 
@obs OS: 0687-14 - Francine Araujo
@obs OS: 3983-16 - Claudia Mara
@type Class
/*/

Class TParBIAFR005 From LongClassName

	Data cName
	Data aParam
	
	Data cClvlDe // Classe de Valor de
	Data cClvlAte // Classe de Valor ate	
	Data cMatDe // Matricula de
	Data cMatAte // Matricula ate
	Data dDatDe // Data de
	Data dDatAte // Data ate
	Data cMailSup // E-mail do Supervisor	
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAFR005
	
	::cName := "BIAFR005"
	
	::aParam := {}
	
	::cClvlDe := Space(9)
	::cClvlAte := Replicate("Z", 9)	
	::cMatDe  := Space(6)
	::cMatAte := Replicate("Z", 6)
	::dDatDe := dDataBase
	::dDatAte := dDataBase
	::cMailSup := Space(20)	
	
	::Add()
	
Return()


Method Add() Class TParBIAFR005	
		
	aAdd(::aParam, {1, "Cl. Valor De", ::cClvlDe, "@!", ".T.", "CTH", ".T.",,.F.})
	aAdd(::aParam, {1, "Cl. Valor Ate", ::cClvlAte, "@!", ".T.", "CTH", ".T.",,.F.})	
	aAdd(::aParam, {1, "Matricula De", ::cMatDe, "@!", ".T.", "SRA", ".T.",,.F.})
	aAdd(::aParam, {1, "Matricula Ate", ::cMatAte, "@!", ".T.", "SRA", ".T.",,.F.})
	aAdd(::aParam, {1, "Data De", ::dDatDe, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Date Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "E-mail Sup.", ::cMailSup, "@!",".T.",,".T.",,.F.})
				
Return()


Method Box() Class TParBIAFR005
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Funcionários",aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::cClvlDe := aRet[1]
		::cClvlAte := aRet[2]	
		::cMatDe  := aRet[3]
		::cMatAte := aRet[4]
		::dDatDe := aRet[5]
		::dDatAte := aRet[6]
		::cMailSup := aRet[7]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR005
	
	::aParam := {}	
	
	::Add()
	
Return()