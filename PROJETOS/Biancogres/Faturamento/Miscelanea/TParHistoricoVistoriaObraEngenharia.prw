#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TParHistoricoVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 20/11/2019
@version 1.0
@description Classe de parametros para controle do Comprovante de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/


Class TParHistoricoVistoriaObraEngenharia From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data dSurveyForecast // Data de previsao da vistoria
	Data dSurveySuggestion // Data de sugestão da vistoria
	Data cJustification // Justificativa
			
	Method New() Constructor
	Method Update()
	Method Add()
	Method Box()
	Method Validate()
	Method Confirm()	
	
EndClass


Method New() Class TParHistoricoVistoriaObraEngenharia
	
	::cName := "TParHistoricoVistoriaObraEngenharia"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	
	::dSurveyForecast := dDataBase
	::dSurveySuggestion := dDataBase
	::cJustification := ""
	
Return()


Method Update() Class TParHistoricoVistoriaObraEngenharia
	
	::aParam := {}
	
	::cJustification := ""
		
Return()


Method Add() Class TParHistoricoVistoriaObraEngenharia
		
	aAdd(::aParam, {9, "Informe os dados para alteração da vistoria.", 200,, .T.})	
	aAdd(::aParam, {1, "Dt. Previsão", ::dSurveyForecast, "@D", ".T.",,".F.",,.T.})
	aAdd(::aParam, {1, "Dt. Sugestão", ::dSurveySuggestion, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {11, "Justificativa", ::cJustification, ".T.", ".T.", .T.})
	
Return()


Method Box() Class TParHistoricoVistoriaObraEngenharia
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::Update()
	
	::Add()
	
	::bConfirm := {|| ::Confirm() }
		
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::dSurveyForecast := ::aParRet[2]
		::dSurveySuggestion := ::aParRet[3]
		::cJustification := ::aParRet[4]

	EndIf
	
Return(lRet)


Method Validate() Class TParHistoricoVistoriaObraEngenharia
Local lRet := .T.
	
	If MV_PAR03 < MV_PAR02 .Or. MV_PAR03 <> DataValida(MV_PAR03) .Or. MV_PAR03 > MonthSum(::dSurveySuggestion, 3)
			
		lRet := .F.
		
		MsgStop("Atenção, data de sugestão da vistoria inválida.")
			
	ElseIf Empty(MV_PAR04)
		
		lRet := .F.
		
		MsgStop("Atenção, justificativa inválida.")
		
	EndIf			
	
Return(lRet)


Method Confirm() Class TParHistoricoVistoriaObraEngenharia
	
	::lConfirm := ::Validate()
		
Return(::lConfirm)