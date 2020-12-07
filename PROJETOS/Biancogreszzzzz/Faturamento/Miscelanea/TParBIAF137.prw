#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF137
@author Tiago Rossini Coradini
@since 11/10/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF137
@type function
/*/

Class TParBIAF137 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data cStatus // Status
	Data dVisDe // Data de Vistoria De
	Data dVisAte // Data de Vistoria Ate
	Data cCodCliDe // Codigo do Cliente De
	Data cCodCliAte // Codigo do Cliente Ate
	Data cNumObrDe // Numero da Obra De
	Data cNumObrAte // Numero da Obra Ate
	Data cCodVenDe // Codigo do Vendedor De
	Data cCodVenAte // Codigo do Vendedor Ate
	Data cCodProDe // Codigo do Produto De
	Data cCodProAte // Codigo do Produto Ate
	Data cSigned // Termo assinado

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()
	Method AccessLevel()
	
EndClass


Method New() Class TParBIAF137
	
	::cName := "BIAF137"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .T.

	::cStatus := "Todos"
	::dVisDe := DaySub(dDataBase, 30)
	::dVisAte := DaySum(dDataBase, 30)
	::cCodCliDe := Space(TamSx3("ZKS_CLIENT")[1])
	::cCodCliAte := Replicate("Z", TamSx3("ZKS_CLIENT")[1])
	::cNumObrDe := Space(TamSx3("ZKS_NUMOBR")[1])
	::cNumObrAte := Replicate("Z", TamSx3("ZKS_NUMOBR")[1])
	::cCodVenDe := Space(TamSx3("ZKS_VEND")[1])
	::cCodVenAte := Replicate("Z", TamSx3("ZKS_VEND")[1])
	::cCodProDe := Space(TamSx3("ZKS_PRODUT")[1])
	::cCodProAte := Replicate("Z", TamSx3("ZKS_PRODUT")[1])
	::cSigned := "Todos"

	::Add()
	
Return()


Method Add() Class TParBIAF137

	If !Empty(cRepAtu)
	
		::cCodVenDe := cRepAtu 
		::cCodVenAte := cRepAtu
	
	EndIf
		
	aAdd(::aParam, {2, "Status", ::cStatus, {"Pendente", "Finalizado", "Em Aprovação", "Todos"}, 50, ".T.", .F.})
	aAdd(::aParam, {1, "Dt. Vistoria De", ::dVisDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Vistoria Ate", ::dVisAte, "@D", ".T.",,".T.",,.F.})
  aAdd(::aParam, {1, "Cliente De", ::cCodCliDe, "@!", ".T.", "SA1", ".T.",,.F.})  
  aAdd(::aParam, {1, "Cliente Ate", ::cCodCliAte, "@!", ".T.", "SA1", ".T.",,.F.})    
  aAdd(::aParam, {1, "Num. Obra De", ::cNumObrDe, "@!", ".T.", "", ".T.",,.F.})  
  aAdd(::aParam, {1, "Num. Obra Ate", ::cNumObrAte, "@!", ".T.", "", ".T.",,.F.})    
  aAdd(::aParam, {1, "Vendedor De", ::cCodVenDe, "@!", ".T.", "SA3", cValToChar(If (Empty(cRepAtu), .T., .F.)),,.F.})  
  aAdd(::aParam, {1, "Vendedor Ate", ::cCodVenAte, "@!", ".T.", "SA3", cValToChar(If (Empty(cRepAtu), .T., .F.)),,.F.})
  aAdd(::aParam, {1, "Produto De", ::cCodProDe, "@!", ".T.", "SB1", ".T.",,.F.})  
  aAdd(::aParam, {1, "Produto Ate", ::cCodProAte, "@!", ".T.", "SB1", ".T.",,.F.})
  aAdd(::aParam, {2, "Termo Assinado", ::cSigned, {"Todos", "Sim", "Não"}, 60, ".T.", .F.})      
  
Return()


Method Box() Class TParBIAF137
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::cStatus := ::aParRet[1]
		::dVisDe := ::aParRet[2]
		::dVisAte := ::aParRet[3]
		::cCodCliDe := ::aParRet[4]
		::cCodCliAte := ::aParRet[5]
		::cNumObrDe := ::aParRet[6]
		::cNumObrAte := ::aParRet[7]
		::cCodVenDe := ::aParRet[8]
		::cCodVenAte := ::aParRet[9]
		::cCodProDe := ::aParRet[10]
		::cCodProAte := ::aParRet[11]
		::cSigned := ::aParRet[12]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF137
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF137
	
Return(::lConfirm)