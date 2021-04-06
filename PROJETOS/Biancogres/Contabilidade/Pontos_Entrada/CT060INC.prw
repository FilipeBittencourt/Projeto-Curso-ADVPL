#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*/{Protheus.doc} CT060INC
@author Marcelo Sousa - Facile Sistemas
@since 16/10/18
@version 1.0
@description O ponto de entrada CT060INC é executado na inclusao da classe de valor
@obs Criado para que no momento da criação de uma classe de valor, o sistema crie também um departamento com mesmo código e descrição
@type function
/*/

User Function CT060INC()

	cExiste := ""

	// Verificando se já existe o departamento criado
	DBSELECTAREA("SQB")
	SQB->(DBGOTOP())
	cExiste := SQB->(DBSEEK(CTH->CTH_FILIAL+CTH->CTH_CLVL))	
	
	If INCLUI .AND. !cExiste
		
		RECLOCK("SQB",.T.)
		
			SQB->QB_DEPTO := CTH->CTH_CLVL
			SQB->QB_DESCRIC := CTH->CTH_DESC01
		
		SQB->(MSUNLOCK())
			
	ELSEIF ALTERA .AND. !cExiste
	
		RECLOCK("SQB",.T.)
		
			SQB->QB_DEPTO := CTH->CTH_CLVL
			SQB->QB_DESCRIC := CTH->CTH_DESC01
		
		SQB->(MSUNLOCK())
	
	ENDIF
	
	If Inclui 
	
		If SubStr(CTH->CTH_CLVL, 1, 1) == "8"
	
			fAddItem(CTH->CTH_CLVL)
			
		EndIf
	
	EndIf
	
Return()


Static Function fAddItem(cClvl)
	
	Begin Transaction
	
		fAdd(cClvl)
	
	End Transaction

Return()


Static Function fAdd(cClvl)
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * "
	cSQL += " FROM _SUBITEM_PADRAO "
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		UpdateItem(cClvl, (cQry)->ITEMCT, (cQry)->SUBITE, (cQry)->DESCR)

		(cQry)->(DbSkip())
		
	EndDo()
				
	(cQry)->(DbCloseArea())
			
Return()


Static Function UpdateItem(cClvl, cItem, cSubitem, cDesc)
Local lInsert := .T.
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	If !Empty(cClvl) .And. !Empty(cItem) .And. !Empty(cSubitem) .And. !Empty(cDesc)
	
		cSQL := " SELECT ISNULL(ZMA_CODIGO, '') AS ZMA_CODIGO "
		cSQL += " FROM "+ RetSQLName("ZMA")
		cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA")) 
		cSQL += " AND ZMA_CLVL = " + ValToSQL(cClvl)
		cSQL += " AND ZMA_ITEMCT = " + ValToSQL(cItem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->ZMA_CODIGO)
		
		If lInsert

			RecLock("ZMA", lInsert)			
			
				cCodRef := GETSXENUM('ZMA', 'ZMA_CODIGO')
	
				ZMA->ZMA_FILIAL := xFilial("ZMA")
				ZMA->ZMA_CODIGO := cCodRef
				ZMA->ZMA_CLVL := cClvl
				ZMA->ZMA_ITEMCT := cItem
				
			ZMA->(MsUnLock())
		
		Else
				
			cCodRef := (cQry)->ZMA_CODIGO
				 
		EndIf
	
		UpdateSubitem(cCodRef, cSubitem, cDesc)
					
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()


Static Function UpdateSubitem(cCodRef, cSubitem, cDesc)
Local lInsert := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	If !Empty(cCodRef) .And. !Empty(cSubitem) .And. !Empty(cDesc)
	
		cSQL := " SELECT R_E_C_N_O_ AS RECNO "
		cSQL += " FROM "+ RetSQLName("ZMB")
		cSQL += " WHERE ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB")) 
		cSQL += " AND ZMB_CODREF = " + ValToSQL(cCodRef)
		cSQL += " AND ZMB_SUBITE = " + ValToSQL(cSubitem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->RECNO)
		
		If !lInsert
			
			ZMB->(DbGoTo((cQry)->RECNO))
			
		EndIf
		
		RecLock("ZMB", lInsert)
		
			ZMB->ZMB_FILIAL := xFilial("ZMB")
			ZMB->ZMB_CODREF := cCodRef
			ZMB->ZMB_SUBITE := cSubitem
			ZMB->ZMB_DESC := cDesc

		ZMB->(MsUnLock())
						
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()