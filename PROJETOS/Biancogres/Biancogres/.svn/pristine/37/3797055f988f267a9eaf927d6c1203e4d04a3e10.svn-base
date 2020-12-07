#Include "PROTHEUS.CH"
#Include "topconn.ch"

User Function MTA500PROC()

	LimpaC5Ori()
	
Return 

Static Function LimpaC5Ori()

	Local cAliasTmp 	:= Nil
	Local cQuery		:= ""
	Local cId			:= ""
	
	If (!Empty(MV_PAR04) .And. !Empty(MV_PAR05))
	
		cAliasTmp 	:= GetNextAlias()
			
		cQuery := " SELECT ID=R_E_C_N_O_													" 
		cQuery += " FROM "+RetSqlName("SC5")+"			  									" 
		cQuery += " WHERE C5_NUM >= '"+MV_PAR04+"'	AND	C5_NUM <= '"+MV_PAR05+"'	AND		"
		cQuery += " D_E_L_E_T_ = ''										 					"		
		
		TcQuery cQuery New Alias (cAliasTmp)
		
		While (!(cAliasTmp)->(Eof()))
			
			cId := (cAliasTmp)->ID
			
			If (!Empty(cId))
				
				SC5->(DbSetOrder(0))
				SC5->(DbGoto(cId))
				
				RecLock("SC5",.F.)
					SC5->C5_ORIGEM := ''
				SC5->(MsUnlock())
			
			EndIf
			
			(cAliasTmp)->(DbSkip())	
			
		EndDo	
		(cAliasTmp)->(DbCloseArea())	
	
	EndIf

Return 