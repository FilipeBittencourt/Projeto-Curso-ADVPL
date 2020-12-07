#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR014
@author Tiago Rossini Coradini
@since 02/05/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR014 
@obs Ticket: 3598
@type class
/*/

Class TParBIAFR014 From LongClassName

	Data cName
	Data aParam
	
	Data cMarca // Marca do produto 1=Biancogres; 2-Incesa; 3=Ambas
	Data dDtEmiDe // Data de emissao de
	Data dDtEmiAte // Data de emissao ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR014
	
	::cName := "BIAFR014"
	
	::aParam := {}

	::cMarca := "1=Biancogres"
	::dDtEmiDe := dDataBase
	::dDtEmiAte := dDataBase

	::Add()		
	
Return()


Method Add() Class TParBIAFR014
		
	aAdd(::aParam, {2, "Marca", ::cMarca, {"1-Biancogres", "2-Incesa", "3-Ambas"}, 60, ".T.", .F.})
	aAdd(::aParam, {1, "Emissão De", ::dDtEmiDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Emissão Ate", ::dDtEmiAte, "@D", ".T.",,".T.",,.F.})
	
Return()


Method Box() Class TParBIAFR014
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cMarca := aRet[1]
		::dDtEmiDe := aRet[2]
		::dDtEmiAte := aRet[3]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR014
	
	::aParam := {}	
	
	::Add()
	
Return()