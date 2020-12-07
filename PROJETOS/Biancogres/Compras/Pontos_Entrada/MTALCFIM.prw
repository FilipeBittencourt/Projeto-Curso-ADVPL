#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} MTALCFIM
@author Tiago Rossini Coradini
@since 29/12/2017
@version 1.0
@description Ponto de entrada no final da função MaAlcDoc - Controla a alçada dos documentos
@description Permite customizações do usuário para a aprovação ou não de documentos 
@obs Ticket: 1902 - Projeto Demandas Compras - Item 2 - Complemento 2 - Ajustes
@type function
/*/

User Function MTALCFIM() 
Local aArea := GetArea()
Local nOpc := ParamIxb[3]
	
	// Atualiza data de inclusao na transferencia por ausencia temporaria  
	If nOpc == 2 .And. Empty(SCR->CR_YDTINCL)
	
		RecLock("SCR", .F.)
		
			SCR->CR_YDTINCL := fGetDatInc() 
		
		SCR->(MsUnLock())		
				
	EndIf

	RestArea(aArea)
	
Return()


Static Function fGetDatInc()
Local dRet := SCR->CR_EMISSAO
Local cSQL := ""
Local cQry := GetNextAlias()
		
	cSQL := " SELECT CR_YDTINCL "
	cSQL += " FROM " + RetSQLName("SCR")
	cSQL += " WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
	cSQL += " AND CR_NUM = " + ValToSQL(SCR->CR_NUM)
	cSQL += " AND CR_USER = " + ValToSQL(SCR->CR_USERORI)
	cSQL += " AND CR_APROV = " + ValToSQL(SCR->CR_APRORI)
	cSQL += " AND D_E_L_E_T_ = '*' "
	cSQL += " ORDER BY R_E_C_N_O_ DESC "	

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->CR_YDTINCL)
	
		dRet := sToD((cQry)->CR_YDTINCL)
	
	EndIf	
	
	(cQry)->(DbCloseArea())

Return(dRet)