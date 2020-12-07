#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF161
@author Tiago Rossini Coradini
@since 11/10/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF161
@type function
/*/

Class TParBIAF161 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data cContratoDe
	Data cContratoAte
	Data cClvlDe
	Data cClvlAte
	Data cItemDe
	Data cItemAte
	Data cSubitemDe
	Data cSubitemAte
	Data cCodForDe 
	Data cCodForAte
	Data dDataDe
	Data dDataAte	

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()
	
EndClass


Method New() Class TParBIAF161
	
	::cName := "BIAF161"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .T.

	::cContratoDe := Space(TamSx3("C3_NUM")[1])
	::cContratoAte := Replicate("Z", TamSx3("C3_NUM")[1])
	::cClvlDe := Space(TamSx3("C3_YCLVL")[1])
	::cClvlAte := Replicate("Z", TamSx3("C3_YCLVL")[1])
	::cItemDe := Space(TamSx3("C3_YITEMCT")[1])
	::cItemAte := Replicate("Z", TamSx3("C3_YITEMCT")[1])
	::cSubitemDe := Space(TamSx3("C3_YSUBITE")[1])
	::cSubitemAte := Replicate("Z", TamSx3("C3_YSUBITE")[1])
	::cCodForDe := Space(TamSx3("A2_COD")[1])
	::cCodForAte := Replicate("Z", TamSx3("A2_COD")[1])
	::dDataDe:= dDataBase
	::dDataAte := dDataBase

	::Add()
	
Return()


Method Add() Class TParBIAF161
	
  aAdd(::aParam, {1, "Contrato De", ::cContratoDe, "@!", ".T.", "SC3", ".T.",,.F.})  
  aAdd(::aParam, {1, "Contrato Ate", ::cContratoAte, "@!", ".T.", "SC3", ".T.",,.F.})
  aAdd(::aParam, {1, "Clvl De", ::cClvlDe, "@!", ".T.", "CTH", ".T.",,.F.})  
  aAdd(::aParam, {1, "Clvl Ate", ::cClvlAte, "@!", ".T.", "CTH", ".T.",,.F.})
  aAdd(::aParam, {1, "Item De", ::cItemDe, "@!", ".T.", "CTH", ".T.",,.F.})  
  aAdd(::aParam, {1, "Item Ate", ::cItemAte, "@!", ".T.", "CTH", ".T.",,.F.})
  aAdd(::aParam, {1, "SubItem De", ::cSubitemDe, "@!", ".T.", "", ".T.",,.F.})  
  aAdd(::aParam, {1, "SubItem Ate", ::cSubitemAte, "@!", ".T.", "", ".T.",,.F.})  
  aAdd(::aParam, {1, "Fornecedor De", ::cCodForDe, "@!", ".T.", "SA2", ".T.",,.F.})  
  aAdd(::aParam, {1, "Fornecedor Ate", ::cCodForAte, "@!", ".T.", "SA2", ".T.",,.F.})    
	aAdd(::aParam, {1, "Data De", ::dDataDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Data Ate", ::dDataAte, "@D", ".T.",,".T.",,.F.})

Return()


Method Box() Class TParBIAF161
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cContratoDe := ::aParRet[1]
		::cContratoAte := ::aParRet[2]
		::cClvlDe := ::aParRet[3]
		::cClvlAte := ::aParRet[4]
		::cItemDe := ::aParRet[5]
		::cItemAte := ::aParRet[6]
		::cSubitemDe := ::aParRet[7]
		::cSubitemAte := ::aParRet[8]
		::cCodForDe := ::aParRet[9]
		::cCodForAte := ::aParRet[10]
		::dDataDe:= ::aParRet[11]
		::dDataAte := ::aParRet[12]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF161
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF161
	
Return(::lConfirm)