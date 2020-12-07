#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFConciliacaoDDA
@author Tiago Rossini Coradini
@since 03/12/2018
@project Automação Financeira
@version 1.0
@description Classe para efetuar conciliacao automatica de DDA
@type class
/*/

Class TAFConciliacaoDDA From TAFAbstractClass

	Data dVenctoDe // Periodo inicial
	Data dVenctoAte // Periodo final
	Data nID // Identificador do titulo	

	Method New() Constructor
	Method Process()
	Method Reconcile()
	Method NotReconcile()
	Method Exist(cCnpj, dVencto, nValor, cNumero)
	Method ExistNum(cNumero, nRecNo)
	Method ExistLog()

EndClass


Method New() Class TAFConciliacaoDDA

	_Super:New()

	::dVenctoDe := dDataBase
	::dVenctoAte := DataValida(DaySum(::dVenctoDe, 3), .T.)
	::nID := 0

Return()


Method Process() Class TAFConciliacaoDDA
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_CON_DDA"
	
	::oLog:Insert()
		
	::Reconcile()
	
	If !::ExistLog()

		::NotReconcile()
		
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_CON_DDA"

	::oLog:Insert()
	
	::oPro:Finish()
	
Return()


Method Reconcile() Class TAFConciliacaoDDA
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cKey := ""

	cSQL := " SELECT FIG_CNPJ, FIG_VENCTO, FIG_VALOR, FIG_TITULO, FIG_CODBAR, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("FIG")
	cSQL += " WHERE FIG_FILIAL = " + ValToSQL(xFilial("FIG"))
	cSQL += " AND FIG_VENCTO BETWEEN " + ValToSQL(::dVenctoDe) + " AND " + ValToSQL(::dVenctoAte)
	cSQL += " AND FIG_CONCIL = '2' "
	cSQL += " AND FIG_VALOR > 0 "
	cSQL += " AND FIG_CODBAR <> '' "
	cSQL += " AND FIG_FORNEC <> '' "
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		If ::Exist((cQry)->FIG_CNPJ, (cQry)->FIG_VENCTO, (cQry)->FIG_VALOR, AllTrim((cQry)->FIG_TITULO))
						
			DbSelectArea("SE2")
			SE2->(DbGoto(::nID))			
			If RecLock("SE2", .F.)
				
				SE2->E2_CODBAR := (cQry)->FIG_CODBAR
				
				cKey := SE2->E2_FILIAL +"|"+ SE2->E2_PREFIXO +"|"+ SE2->E2_NUM +"|"+ SE2->E2_PARCELA +"|"+ SE2->E2_TIPO +"|"+ SE2->E2_FORNECE +"|"+ SE2->E2_LOJA +"|"
				
				SE2->(MsUnLock())
				
			EndIf
			
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "P"			
			::oLog:cMetodo := "S_CON_DDA"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := SE2->(RecNo())
			::oLog:cEnvWF := "N"
			
			::oLog:Insert()

			DbSelectArea("FIG")
			FIG->(DbGoto((cQry)->RECNO))
			If RecLock("FIG", .F.)

				FIG->FIG_DDASE2	:= cKey
				FIG->FIG_CONCIL	:= "1"
				FIG->FIG_DTCONC	:= dDatabase
				FIG->FIG_USCONC	:= cUsername
				
				FIG->(MsUnLock())
				
			EndIf
		
		EndIf
			
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
	
	RestArea(aArea)
	
Return()


Method NotReconcile() Class TAFConciliacaoDDA
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("FIG")
	cSQL += " WHERE FIG_FILIAL = " + ValToSQL(xFilial("FIG"))
	cSQL += " AND FIG_VENCTO BETWEEN " + ValToSQL(::dVenctoDe) + " AND " + ValToSQL(::dVenctoAte)
	cSQL += " AND FIG_CONCIL = '2' "
	cSQL += " AND FIG_VALOR > 0 "
	cSQL += " AND FIG_CODBAR <> '' "
	cSQL += " AND FIG_FORNEC <> '' "
	cSQL += " AND	D_E_L_E_T_ = '' "	
	cSQL += " AND "
	cSQL += " ( "
	cSQL += " 	SELECT COUNT(E2_NUM) "
	cSQL += " 	FROM " + RetSQLName("SE2")
	cSQL += " 	WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))
	cSQL += " 	AND E2_FORNECE IN "
	cSQL += " 	( "
	cSQL += " 		SELECT A2_COD "
	cSQL += " 		FROM " + RetSQLName("SA2")
	cSQL += " 		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " 		AND A2_CGC LIKE SUBSTRING(FIG_CNPJ, 1, 8) + '%' "
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 		GROUP BY A2_COD "
	cSQL += " 	) "
	cSQL += " 	AND (E2_VENCTO = FIG_VENCTO OR E2_VENCREA = FIG_VENCTO) "
	cSQL += " 	AND E2_SALDO = 0 "
	cSQL += " 	AND E2_VALOR = FIG_VALOR "
	cSQL += " 	AND E2_CODBAR = '' "
	cSQL += " 	AND E2_IDCNAB = '' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) = 0 "	

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"			
		::oLog:cMetodo := "N_CON_DDA_FIN"
		::oLog:cTabela := RetSQLName("FIG")
		::oLog:nIDTab := (cQry)->RECNO		
		::oLog:cEnvWF := "S"
		
		::oLog:Insert()
													
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
	
	RestArea(aArea)
	
Return()


Method Exist(cCnpj, dVencto, nValor, cNumero) Class TAFConciliacaoDDA
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	::nID := 0
	
	cSQL := " SELECT COUNT(E2_NUM) AS COUNT, E2_NUM, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE2")
	cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))
	cSQL += " AND E2_FORNECE IN "
	cSQL += " ( "
	cSQL += " 	SELECT A2_COD "
	cSQL += " 	FROM " + RetSQLName("SA2")
	cSQL += " 	WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " 	AND A2_CGC LIKE " + ValToSQL(SubStr(cCnpj, 1, Len(cCnpj) -6) + "%")
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " 	GROUP BY A2_COD "
	cSQL += " ) "
	cSQL += " AND (E2_VENCTO = "+ ValToSQL(dVencto) + " OR E2_VENCREA = "+ ValToSQL(dVencto) +")"
	cSQL += " AND E2_SALDO > 0 "
	cSQL += " AND E2_VALOR = " + ValToSQL(nValor)
	cSQL += " AND E2_CODBAR = '' "
	cSQL += " AND E2_IDCNAB = '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E2_NUM, R_E_C_N_O_ "	

	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT > 1
	
		While !(cQry)->(Eof()) .And. ::nID == 0
					
			nCount := Len(cNumero)
			
			While nCount > 0 .And. ::nID == 0
			
				If ::ExistNum(SubStr(cNumero, 1, nCount), (cQry)->RECNO)
				
					::nID := (cQry)->RECNO
				
				EndIf
				
				nCount--
				
			EndDo()
			
			(cQry)->(DbSkip())
		
		EndDo()
	
	ElseIf (cQry)->COUNT == 1
		
		::nID := (cQry)->RECNO
		
	EndIf
	
	lRet := ::nID > 0
	
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method ExistNum(cNumero, nRecNo) Class TAFConciliacaoDDA
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT E2_NUM "
	cSQL += " FROM " + RetSQLName("SE2")
	cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))
	cSQL += " AND E2_NUM LIKE '%' " + ValToSQL(cNumero)
	cSQL += " AND R_E_C_N_O_ = " + ValToSQL(nRecNo)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := !Empty((cQry)->E2_NUM)

	(cQry)->(DbCloseArea())
	
Return(lRet)


Method ExistLog() Class TAFConciliacaoDDA
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT COUNT(ZK2_IDPROC) AS COUNT "
	cSQL += " FROM " + RetSQLName("ZK2")
	cSQL += " WHERE ZK2_EMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK2_FIL = " + ValToSQL(cFilAnt)
	cSQL += " AND ZK2_OPERAC = 'P' "
	cSQL += " AND ZK2_DTINI = " + ValToSQL(dDataBase)
	cSQL += " AND ZK2_METODO = 'N_CON_DDA_FIN' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())
	
Return(lRet)