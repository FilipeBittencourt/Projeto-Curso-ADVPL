#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIAFUGMR(_cOrigem)
	
	Local cAliasTmp			:= Nil
	Local cSequeAtiva		:= ""
	Local cQuery			:= ""
	
	If (!Empty(mv_par01) .And. !Empty(mv_par02) .And. !Empty(mv_par03))
		
		cAliasTmp			:= GetNextAlias()
		cQuery := " SELECT TOP 1 ZBM_SEQUEN FROM " + RetSqlName("ZBM") + " 																		"
		cQuery += " WHERE ZBM_VERSAO = '"+mv_par01+"' AND ZBM_REVISA = '"+mv_par02+"' AND ZBM_ANOREF = '"+mv_par03+"' AND D_E_L_E_T_ = ''		"
		cQuery += " AND ZBM_FILIAL = '"+xFilial('ZBM')+"'																						"
		cQuery += " AND (ZBM_ATIVO = 'S')																										"
		
		TcQuery cQuery New Alias (cAliasTmp)

		If !(cAliasTmp)->(Eof()) 
			cSequeAtiva := (cAliasTmp)->ZBM_SEQUEN
		EndIf
		
		If (Empty(cSequeAtiva))
			MsgAlert("Não foi encontrado sequência habilitada.", "")
		Else
			//MsgAlert("Sequência habilitada: "+cSequeAtiva+".", "")
			If (_cOrigem == '1') 
				mv_par04 := cSequeAtiva
			Else
				mv_par05 := cSequeAtiva
			EndIf
			
		EndIf
		
		(cAliasTmp)->(DbCloseArea())
		
	EndIf
		
Return .T.
