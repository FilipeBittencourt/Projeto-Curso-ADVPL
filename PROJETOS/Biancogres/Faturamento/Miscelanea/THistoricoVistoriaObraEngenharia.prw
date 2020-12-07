#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} THistoricoVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para controle de Historico de alteracoes de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/

Class THistoricoVistoriaObraEngenharia From LongClassName 
	
	Data oParam

	Data dSurveyForecast // Data de previsao da vistoria
	Data dSurveySuggestion // Data de sugestão da vistoria
	Data cJustification // Justificativa
	Data lApprove // Aprovacao
	
	Method New() Constructor
	Method Validate()
	Method Exist(cNumero)
	Method GetDateSuggestion(cNumero)
	Method GetFirstDate(cNumero)
	Method Insert(aSurvey)
	
EndClass


Method New() Class THistoricoVistoriaObraEngenharia

	::oParam := TParHistoricoVistoriaObraEngenharia():New()

	::dSurveyForecast := dDataBase
	::dSurveySuggestion := dDataBase
	::cJustification := ""
	::lApprove := .F.

Return()


Method Validate() Class THistoricoVistoriaObraEngenharia
Local lRet := .T. 

	::oParam:dSurveyForecast := ::dSurveyForecast
	::oParam:dSurveySuggestion := ::dSurveySuggestion
	
	If (lRet := ::oParam:Box())

		::dSurveySuggestion := ::oParam:dSurveySuggestion
		::cJustification := ::oParam:cJustification

	EndIf

Return(lRet)


Method Exist(cNumero) Class THistoricoVistoriaObraEngenharia
Local lRet := .T. 
Local cSQL := ""
Local cQry := GetNextAlias()

	DbSelectArea("ZKT")

	cSQL := " SELECT COUNT(ZKT_NUMVIS) AS COUNT "
	cSQL += " FROM " + RetSQLName("ZKT")
	cSQL += " WHERE ZKT_FILIAL = " + ValToSQL(xFilial("ZKT"))
	cSQL += " AND ZKT_NUMVIS = " + ValToSQL(cNumero)
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT >= 1

	(cQry)->(DbCloseArea())						
	
Return(lRet)


Method GetDateSuggestion(cNumero) Class THistoricoVistoriaObraEngenharia
Local dRet := dDataBase 
Local cSQL := ""
Local cQry := GetNextAlias()

	DbSelectArea("ZKT")

	cSQL := " SELECT MAX(ZKT_DATVIS) ZKT_DATVIS "
	cSQL += " FROM " + RetSQLName("ZKT")
	cSQL += " WHERE ZKT_FILIAL = " + ValToSQL(xFilial("ZKT"))
	cSQL += " AND ZKT_NUMVIS = " + ValToSQL(cNumero)
	cSQL += " AND ZKT_STATUS = '3' "	
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	dRet := SToD((cQry)->ZKT_DATVIS)

	(cQry)->(DbCloseArea())						
	
Return(dRet)


Method GetFirstDate(cNumero) Class THistoricoVistoriaObraEngenharia
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	DbSelectArea("ZKT")

	cSQL := " SELECT ISNULL(MIN(ZKT_DATPRE),'') AS ZKT_DATPRE "
	cSQL += " FROM " + RetSQLName("ZKT")
	cSQL += " WHERE ZKT_FILIAL = " + ValToSQL(xFilial("ZKT"))
	cSQL += " AND ZKT_NUMVIS = " + ValToSQL(cNumero)
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	cRet := (cQry)->ZKT_DATPRE

	(cQry)->(DbCloseArea())						
	
Return(cRet)


Method Insert(aSurvey) Class THistoricoVistoriaObraEngenharia
Local aArea := GetArea()
Local nCount := 0
Local num := 0

	Begin Transaction
	
		For nCount := 1 To Len(aSurvey)
	
			DbSelectArea("ZKS")
			
			num := aSurvey[nCount, 2]
			
			if(VALTYPE(num) == 'C')
				num := VAL(num)
			endif
			
			ZKS->(DbGoTo(num))
		
			RecLock("ZKS", .F.)
		
			If !::lApprove .And. ::Exist(ZKS->ZKS_NUMERO)

				ZKS->ZKS_STATUS := "3"
							
			Else
			
				ZKS->ZKS_STATUS := "1"
								
			EndIf
			
			ZKS->ZKS_DATPRE := ::dSurveySuggestion
			
			ZKS->(MsUnLock())
			
			DbSelectArea("ZKT")
			
			RecLock("ZKT", .T.)
			
				ZKT->ZKT_FILIAL := xFilial("ZKT")
				ZKT->ZKT_NUMVIS := ZKS->ZKS_NUMERO
				ZKT->ZKT_DATA := dDataBase
				ZKT->ZKT_STATUS := ZKS->ZKS_STATUS
				ZKT->ZKT_CODUSU := __cUserId
				ZKT->ZKT_NOME := cUserName 
				ZKT->ZKT_DATPRE := ::dSurveyForecast
				ZKT->ZKT_DATVIS := ::dSurveySuggestion
				ZKT->ZKT_OBS := ::cJustification
				
			ZKT->(MsUnLock())
			
		Next
	
	End Transaction

	RestArea(aArea)

Return()