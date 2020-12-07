#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR015
@author Tiago Rossini Coradini
@since 04/06/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR015 
@obs Ticket: 2626
@type Class
/*/

Class TParBIAFR015 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de 
	Data dDatAte // Data de
	Data cPedDe // Pedido de
	Data cPedAte // PEedido ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR015
	
	::cName := "BIAFR015"
	
	::aParam := {}
	
	::dDatDe := FirstDate(dDataBase)	
	::dDatAte := dDataBase
	::cPedDe := Space(6)
	::cPedAte := Replicate("Z", 6)

	::Add()		
	
Return()


Method Add() Class TParBIAFR015
		
	aAdd(::aParam, {1, "Emissão De", ::dDatDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Emissão Ate", ::dDatAte, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Pedido De", ::cPedDe, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Pedido Ate", ::cPedAte, "@!", ".T.", "", ".T.",,.F.})	
	
Return()


Method Box() Class TParBIAFR015
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDatDe := aRet[1]
		::dDatAte := aRet[2]
		::cPedDe := aRet[3]
		::cPedAte := aRet[4]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR015
	
	::aParam := {}	
	
	::Add()
	
Return()