#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR009
@author Tiago Rossini Coradini
@since 05/12/2016
@version 2.0
@description Classe para manipulação de parametros da rotina BIAFR009 
@obs OS: 3753-16 - Claudeir Fadini
@type Class
/*/

Class TParBIAFR009 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de
	Data dDatAte // Data ate
	Data cPrdDe // Produto de
	Data cPrdAte // Produto ate
	Data cCliDe // Cliente de
	Data cCliAte // Cliente ate
	Data cVenDe // Vendedor de
	Data cVenAte // Vendedor ate
	Data cDupl // Duplicata 1-Todos; 2=Sim; 3-Nao
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR009
	
	::cName := "BIAFR009"
	
	::aParam := {}
	
	::dDatDe := dDataBase
	::dDatAte := dDataBase
	::cPrdDe := Space(15)
	::cPrdAte := Replicate("Z", 15)
	::cCliDe := Space(6)
	::cCliAte := Replicate("Z", 6)
	::cVenDe := Space(6)
	::cVenAte := Replicate("Z", 6)
	::cDupl := "1-Todos"	
	
	::Add()		
	
Return()


Method Add() Class TParBIAFR009
		
	aAdd(::aParam, {1, "Data De", ::dDatDe, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Data Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Produto De", ::cPrdDe, "@!", ".T.", "SB1", ".T.",,.F.})
	aAdd(::aParam, {1, "Produto Ate", ::cPrdAte, "@!", ".T.", "SB1", ".T.",,.F.})
	
	IF alltrim(cRepAtu) <> ""
		//aAdd(::aParam, {1, "Cliente De", ::cCliDe, "@!", ".T.", "SA1SC5", ".T.",,.F.})
		//aAdd(::aParam, {1, "Cliente Ate", ::cCliAte, "@!", ".T.", "SA1SC5", ".T.",,.F.})
		aAdd(::aParam, {1, "Cliente De", ::cCliDe, "@!", ".T.", "SA1REP", ".T.",,.F.})
		aAdd(::aParam, {1, "Cliente Ate", ::cCliAte, "@!", ".T.", "SA1REP", ".T.",,.F.})
		
		aAdd(::aParam, {1, "Vendedor De", cRepAtu, "@!", ".T.", "", ".F.",,.F.})
		aAdd(::aParam, {1, "Vendedor Ate", cRepAtu, "@!", ".T.", "", ".F.",,.F.})
	ELSE
		aAdd(::aParam, {1, "Cliente De", ::cCliDe, "@!", ".T.", "SA1", ".T.",,.F.})
		aAdd(::aParam, {1, "Cliente Ate", ::cCliAte, "@!", ".T.", "SA1", ".T.",,.F.})
		aAdd(::aParam, {1, "Vendedor De", ::cVenDe, "@!", ".T.", "SA3", ".T.",,.F.})
	    aAdd(::aParam, {1, "Vendedor Ate", ::cVenAte, "@!", ".T.", "SA3", ".T.",,.F.})
	END IF
	
	
	
	
	
	
	
	
	aAdd(::aParam, {2, "Gera Duplicata?", ::cDupl, {"1-Todos", "2-Sim", "3-Não"}, 60, ".T.", .F.})
		
Return()


Method Box() Class TParBIAFR009
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações",aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDatDe := aRet[1]
		::dDatAte := aRet[2]
		::cPrdDe := aRet[3]
		::cPrdAte := aRet[4]
		::cCliDe := aRet[5]
		::cCliAte := aRet[6]
		IF alltrim(cRepAtu) <> ""
		   ::cVenDe := cRepAtu
		   ::cVenAte := cRepAtu
		ELSE
		   ::cVenDe := aRet[7]
		   ::cVenAte := aRet[8]
		END IF
		::cDupl := aRet[9]		
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR009
	
	::aParam := {}	
	
	::Add()
	
Return()