#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR016
@author Tiago Rossini Coradini
@since 01/08/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR016 
@obs Ticket: 7049
@type Class
/*/

Class TParBIAFR016 From LongClassName

	Data cName
	Data aParam
	
	Data dEmiDe // Data de emissao de
	Data dEmiAte // Data de emissao ate	
	Data cPedDe // Pedido de
	Data cPedAte // Pedido ate
	Data cCotDe // Cotacao de
	Data cCotAte // Cotacao Ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR016
	
	::cName := "BIAFR016"
	
	::aParam := {}

	::dEmiDe := dDataBase
	::dEmiAte := dDataBase	
	::cPedDe := Space(6)
	::cPedAte := Replicate("Z", 6)
	::cCotDe := Space(6)
	::cCotAte := Replicate("Z", 6)

	::Add()		
	
Return()


Method Add() Class TParBIAFR016
		
	aAdd(::aParam, {1, "Dt Emissão De", ::dEmiDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Emissão Ate", ::dEmiAte, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Pedido De", ::cPedDe, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Pedido Ate", ::cPedAte, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Cotação De", ::cCotDe, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Cotação Ate", ::cCotAte, "@!", ".T.", "", ".T.",,.F.})
	
Return()


Method Box() Class TParBIAFR016
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dEmiDe := aRet[1]
		::dEmiAte := aRet[2]	
		::cPedDe := aRet[3]
		::cPedAte := aRet[4]
		::cCotDe := aRet[5]
		::cCotAte := aRet[6]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR016
	
	::aParam := {}	
	
	::Add()
	
Return()