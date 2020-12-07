#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF054
@author Tiago Rossini Coradini
@since 28/11/2016
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF054
@obs OS: 3844-16 - Ranisses Corona
@type function
/*/


Class TParBIAF054 From LongClassName

	Data cName
	Data aParam
	
	Data cNumPedDe // Pedido de
	Data cNumPedAte // Pedido ate
	Data cCodPrdDe // Produto de
	Data cCodPrdAte // Produto ate	
	Data dDatEmiDe // Data de Emissão de
	Data dDatEmiAte // Data de Emissão ate	
	Data dDatResDe // Data de Eliminacao de Residuo de
	Data dDatResAte // Data de Eliminacao de Residuo ate
	Data cCodCliDe // Cliente de
	Data cCodCliAte // Cliente ate	
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAF054
	
	::cName := "BIAF054"
	
	::aParam := {}
	
	::cNumPedDe := Space(6)
	::cNumPedAte := Replicate("Z", 6)
	::cCodPrdDe := Space(15)
	::cCodPrdAte :=	Replicate("Z", 15)
	::dDatEmiDe := dDataBase
	::dDatEmiAte :=	dDataBase
	::dDatResDe := dDataBase
	::dDatResAte := dDataBase
	::cCodCliDe := Space(6)
	::cCodCliAte :=	Replicate("Z", 6)
		
	::Add()		
	
Return()


Method Add() Class TParBIAF054
			
	aAdd(::aParam, {1, "Pedido De", ::cNumPedDe, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Pedido De", ::cNumPedAte, "@!", ".T.", "", ".T.",,.F.})
	aAdd(::aParam, {1, "Produto Ate", ::cCodPrdDe, "@!", ".T.", "SB1", ".T.",,.F.})
	aAdd(::aParam, {1, "Produto Ate", ::cCodPrdAte, "@!", ".T.", "SB1", ".T.",,.F.})
	aAdd(::aParam, {1, "Dt Emiss. De", ::dDatEmiDe, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Emiss. Ate", ::dDatEmiAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Elimi. De", ::dDatResDe, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Elimi. Ate", ::dDatResAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Cliente De", ::cCodCliDe, "@!", ".T.", "SA1", ".T.",,.F.})
	aAdd(::aParam, {1, "Cliente Ate", ::cCodCliAte, "@!", ".T.", "SA1", ".T.",,.F.})				
						
Return()


Method Box() Class TParBIAF054
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações",aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::cNumPedDe := aRet[1]
		::cNumPedAte := aRet[2]
		::cCodPrdDe := aRet[3]
		::cCodPrdAte :=	aRet[4]
		::dDatEmiDe := aRet[5]
		::dDatEmiAte :=	aRet[6]
		::dDatResDe := aRet[7]
		::dDatResAte := aRet[8]
		::cCodCliDe := aRet[9]
		::cCodCliAte :=	aRet[10]	
				
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF054
	
	::aParam := {}	
	
	::Add()
	
Return()