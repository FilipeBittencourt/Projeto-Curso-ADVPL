#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR011
@author Tiago Rossini Coradini
@since 03/05/2017
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR011 
@obs OS: 0066-17 - Jessica Alvarenga
@type Class
/*/

Class TParBIAFR011 From LongClassName

	Data cName
	Data aParam
	
	Data cMatDe // Matricula de
	Data cMatAte // Matricula ate
	Data cSitBen // Somente ativos 1=Sim; 2-Nao; 3=Ambos
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR011
	
	::cName := "BIAFR011"
	
	::aParam := {}
	
	::cMatDe  := Space(6)
	::cMatAte := Replicate("Z", 6)
	::cSitBen := "1-Ativos"
		
	::Add()		
	
Return()


Method Add() Class TParBIAFR011
		
	aAdd(::aParam, {1, "Matricula De", ::cMatDe, "@!", ".T.", "SRA", ".T.",,.F.})
	aAdd(::aParam, {1, "Matricula Ate", ::cMatAte, "@!", ".T.", "SRA", ".T.",,.F.})
	aAdd(::aParam, {2, "Situação Beneficiários", ::cSitBen, {"1-Ativos", "2-Inativos", "3-Ambos"}, 60, ".T.", .F.})
		
Return()


Method Box() Class TParBIAFR011
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cMatDe  := aRet[1]
		::cMatAte := aRet[2]
		::cSitBen := aRet[3]
				
	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR011
	
	::aParam := {}	
	
	::Add()
	
Return()