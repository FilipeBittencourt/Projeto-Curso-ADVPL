#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCompensacaoPagar
@author Wlysses Cerqueira (Facile)
@since 26/03/2019
@project Automação Financeira
@version 1.0
@description Classe de compensação de titulos a receber com NCC  
@type class
/*/
 
#DEFINE NPOSTIT	1
#DEFINE NPOSPRF	2
#DEFINE NPOSPAR	3
#DEFINE NPOSTIP	4
#DEFINE NPOSCLI	5
#DEFINE NPOSLOJ	6
#DEFINE NPOSVLR	7
#DEFINE NPOSEMI	8
#DEFINE NPOSVNR	9
#DEFINE NPOSSAL	10
#DEFINE NPOSREC	11
						
Class TCompensacaoPagar From TAFAbstractClass
	
	Data lEnabled
		
	Method New() Constructor
	Method Compensar(aTitPagar, aTitCredito, nValorComp, nValorTit, lComisNCC, cMensagem) // Muita atencao no parametro lComisNCC, pois indica se gera comissao
	Method Devolucao()
	Method GetTitPagar(cNum, cPrefixo, cFornece, cLoja)
	
EndClass

Method New() Class TCompensacaoPagar
	
	_Super:New()
	
	::lEnabled := GetNewPar("MV_YCOAUTP", .T.)
			
Return()

Method Devolucao() Class TCompensacaoPagar

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nSaldoTit := 0
	Local nW := 0
	Local aTitPagar := {}
	Local aTitCredito := {}
	Local oEmp := TLoadEmpresa():New()
	Local oObj := TAFMovimentoRemessaReceber():New()
		
	If ::lEnabled
	
		oEmp:GetCodigos()
	
		::oPro:Start()
	
		cSQL := " SELECT E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, "
		cSQL += " E2_FORNECE, E2_LOJA, E2_SALDO, E2_EMISSAO, E2_VENCREA, R_E_C_N_O_ AS RECNO "
		cSQL += " FROM " + RetSQLName("SE2") + " A ( NOLOCK ) "
		cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2")) + " "
		cSQL += " AND E2_TIPO = 'NDF' "
		cSQL += " AND E2_SALDO > 0 "
		cSQL += " AND E2_FORNECE IN " + FormatIn(oEmp:cCodigosFor, "/")
		cSQL += " AND A.D_E_L_E_T_ = '' "
		cSQL += " ORDER BY E2_NUM, E2_PREFIXO, E2_PARCELA "

		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(EOF())

			//If oObj:IsGreater24Hour((cQry)->E2_PREFIXO, (cQry)->E2_NUM, (cQry)->E2_FORNECE, (cQry)->E2_LOJA, (cQry)->E2_PARCELA)
				
				aTitPagar := ::GetTitPagar((cQry)->E2_NUM, (cQry)->E2_PREFIXO, (cQry)->E2_FORNECE, (cQry)->E2_LOJA)
				
				nSaldoTit := 0
				
				For nW := 1 To Len(aTitPagar)
				
					nSaldoTit += aTitPagar[nW][NPOSSAL]
				
				Next nW
			
				If nSaldoTit == (cQry)->E2_SALDO
			
					For nW := 1 To Len(aTitPagar)
				
						::Compensar({aTitPagar[nW][NPOSREC]}, {(cQry)->RECNO}, (cQry)->E2_SALDO, aTitPagar[nW][NPOSSAL], .F., "DEVOLUCAO")
				
					Next nW
			
				Else
			
					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cOperac := "P"
					::oLog:cMetodo := "CP_TIT_INC"
					::oLog:cHrFin := Time()
					::oLog:cRetMen := "Baixa por compensacao não efetuada [Saldo Credito (NDF): " + AllTrim(Transform((cQry)->E2_SALDO, "@e 999,999,999.99")) + "] [Saldo titulos: " + AllTrim(Transform(nSaldoTit, "@e 999,999,999.99")) + "]"
					::oLog:cEnvWF := "S"
					::oLog:cTabela := RetSQLName("SE2")
					::oLog:nIDTab := (cQry)->RECNO
					
					::oLog:Insert()
			
				EndIf
				
			//EndIf
		
			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())
	
		::oPro:Finish()
	
	EndIf
	
Return()

Method GetTitPagar(cNum, cPrefixo, cFornece, cLoja) Class TCompensacaoPagar
	
	Local aTitPagar := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()
	
	cSQL := " SELECT E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, "
	cSQL += " E2_FORNECE, E2_LOJA, E2_SALDO, E2_EMISSAO, E2_VENCREA, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE2") + " A ( NOLOCK ) "
	cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2")) + " "
	cSQL += " AND E2_TIPO <> 'NDF' "
	cSQL += " AND EXISTS ( "
	cSQL += " 				SELECT NULL FROM " + RetSQLName("SD2") + " SD2 "
	cSQL += " 				WHERE D2_FILIAL  = E2_FILIAL AND "
	cSQL += " 					  D2_DOC	 = " + ValToSQL(cNum) + " AND "
	cSQL += " 					  D2_SERIE	 = " + ValToSQL(cPrefixo) + " AND "
	cSQL += " 					  D2_CLIENTE = " + ValToSQL(cFornece) + " AND "
	cSQL += " 					  D2_LOJA 	 = " + ValToSQL(cLoja) + " AND "
	cSQL += " 					  D2_NFORI	 = E2_NUM AND "
	cSQL += " 					  D2_SERIORI = E2_PREFIXO AND "
	cSQL += " 					  D2_CLIENTE = E2_FORNECE AND "
	cSQL += " 					  D2_LOJA 	 = E2_LOJA AND "
	cSQL += " 					  SD2.D_E_L_E_T_ = '' "
	cSQL += " 			 ) "
	cSQL += " AND E2_SALDO > 0 "
	cSQL += " AND E2_NUMBOR = '' "
	cSQL += " AND A.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E2_NUM, E2_PREFIXO, E2_PARCELA "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(EOF())
	
		aAdd(aTitPagar, {(cQry)->E2_NUM,;
						(cQry)->E2_PREFIXO,;
						(cQry)->E2_PARCELA,;
						(cQry)->E2_TIPO,;
						(cQry)->E2_FORNECE,;
						(cQry)->E2_LOJA,;
						(cQry)->E2_SALDO,;
						(cQry)->E2_EMISSAO,;
						(cQry)->E2_VENCREA,;
						(cQry)->E2_SALDO,;
						(cQry)->RECNO})
		
		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())
	
Return(aTitPagar)

Method Compensar(aTitPagar, aTitCredito, nValorComp, nValorTit, lComisNCC, cMensagem) Class TCompensacaoPagar

	Local lRet := .F.
	Local lContabiliza := .F.
	Local lAglutina := .F.
	Local lDigita := .F.
			
	Default aTitPagar := {}
	Default aTitCredito := {}
	Default nValorComp := 0
	Default lComisNCC := .F.
	Default cMensagem := ""
	
	Pergunte("AFI340", .F.)
		
	lContabiliza	:= MV_PAR09 == 1
	lAglutina		:= MV_PAR08 == 1
	lDigita			:= MV_PAR09 == 1
	
	Begin Transaction
	
		If MaIntBxCP(2,aTitPagar,,aTitCredito,,{lContabiliza,lAglutina,lDigita,.F.,.F.,lComisNCC},,,,,dDataBase)
		                                       
			lRet := .T.
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa [" + cMensagem + "] por compensacao efetuada"
			::oLog:cEnvWF := "N"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := aTitPagar[1]
		
			::oLog:Insert()
	
		Else
		
			lRet := .F.
		
		EndIf
		
		If !lRet
			
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_TIT_INC"
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Baixa por compensacao não efetuada [Saldo Credito (NCC/RA): " + AllTrim(Transform(nValorComp, "@e 999,999,999.99")) + "] [Saldo titulos: " + AllTrim(Transform(nValorTit, "@e 999,999,999.99")) + "]"
			::oLog:cEnvWF := "S"
			::oLog:cTabela := RetSQLName("SE2")
			::oLog:nIDTab := aTitPagar[1]
			
			::oLog:Insert()
					
		EndIf
	
	End Transaction
	
Return(lRet)