#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF109
@author Tiago Rossini Coradini
@since 16/05/2018
@version 1.0
@description Rotina para reprocessamento titulos de DDA 
@obs Ticket: 4511
@type Function
/*/

User Function BIAF109()
Local aArea := GetArea()
Local oParam := TParBIAF109():New()

	If oParam:Box()
	
			U_BIAMsgRun("Reprocessamento títulos de DDA...", "Aguarde!", {|| fReprocDDA(oParam) })
			
			MsgInfo("Reprocessamento de DDA executado com sucesso!")		
	
	EndIf
	
	RestArea(aArea)

Return()


Static Function fReprocDDA(oParam)
Local cCNPJ := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT FIG_CNPJ, FIG_VENCTO, FIG_VALOR, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("FIG")
	cSQL += " WHERE FIG_FILIAL = " + ValToSQL(xFilial("FIG"))
	cSQL += " AND FIG_CONCIL = '2' "
	cSQL += " AND FIG_DATA BETWEEN " + ValToSQL(oParam:dDatDe) + " AND " + ValToSQL(oParam:dDatAte)
	cSQL += " AND FIG_VALOR > 0 "
	cSQL += " AND FIG_CODBAR <> '' "
	cSQL += " AND FIG_FORNEC = '' "
	cSQL += " AND FIG_CNPJ <> 'XXXXXXXXXXXXXX' "
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
		
		cCNPJ := U_BIAF108((cQry)->FIG_CNPJ, (cQry)->FIG_VENCTO, (cQry)->FIG_VALOR)
		
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		If SA2->(MsSeek(xFilial("SA2") + cCNPJ))
			
			DbSelectArea("FIG")
			FIG->(DbGoTo((cQry)->RECNO))
			
			RecLock("FIG", .F.)
			
				FIG->FIG_FORNEC	:= SA2->A2_COD
				FIG->FIG_LOJA	:= SA2->A2_LOJA
				FIG->FIG_NOMFOR	:= SA2->A2_NREDUZ
				FIG->FIG_CNPJ := cCNPJ				
			
			FIG->(MsUnLock())
			
		EndIf
		
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(dbCloseArea())
	
Return()