#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF079
@author Tiago Rossini Coradini
@since 13/06/2017
@version 1.0
@description Rotina generica para atualização de parametros do sistema
@obs OS: 1297-17 - Claudeir Fadini
@type function
/*/

User Function BIAF079(cParam, cValOper)
Local aArea := GetArea()
Local oParBox := Nil

	Default cParam := ""
	Default cValOper := ""
	
	If !Empty(cValOper) .And. fVldOpe(cValOper) .And. U_VALOPER(cValOper)
		
		oParBox := TWParamBox():New(cParam)
		
		If !Empty(oParBox:cName)
		
			oParBox:Activate()
			
		EndIf
		
	End
	
	RestArea(aArea)
	
Return()


Static Function fVldOpe(cValOper)
Local lRet := .T.

	DbSelectArea("ZZ0")
	DbSetOrder(1)
	If ZZ0->(DbSeek(xFilial('ZZ0') + cValOper))
		
		If Empty(Alltrim(ZZ0->ZZ0_ACESSO))
			
			lRet := .F.
			
			MsgAlert("Nenhum usuário cadastrado para esta operação!" + CRLF + AllTrim(UPPER(ZZ0->ZZ0_DESC)), "Validação de Acesso!")
		
		EndIf

	Else
	
		lRet := .F.
		
		MsgAlert("Operação: " + cValOper + " não cadastrada.", "Validação de Acesso!")
	
	EndIf

Return(lRet)