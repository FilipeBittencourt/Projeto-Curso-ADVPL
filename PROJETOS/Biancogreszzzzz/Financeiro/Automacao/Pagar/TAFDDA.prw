#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFDDA
@author Tiago Rossini Coradini
@since 04/12/2018
@project Automação Financeira
@version 1.0
@description Classe para inclusao de titulos de DDA
@type class
/*/

Class TAFDDA From TAFAbstractClass
	
	Data cEmp // Empresa
	Data cFil // Filial
	Data cCodFor // Codigo do fornecedor
	Data cLojFor // Loja do fornenedor
	Data cNomFor // Nome do fornecedor
	Data cNumero // Numero do titulo
	Data cEspecie // Especie do titulo
	Data dVencto // Data da baixa do titulo
	Data nValor // Valor do titulo
	Data cCnpj // Cnpj do fornecedor
	Data cCodBar // Codigo de barras do titulo
	Data cIDProc // Identificar do processo
	
	Method New() Constructor
	Method Insert()
	Method Update()
	Method IdSupplier()
	Method GetID()
	Method GetPartID()
	Method SetSupplier(cCodigo, cLoja, cNome)
	Method Exist()
	Method Validate()

EndClass


Method New() Class TAFDDA

	_Super:New()
	
	::cEmp := cEmpAnt
	::cFil := cFilAnt
	::cCodFor := ""
	::cLojFor := ""
	::cNomFor := ""
	::cNumero := ""
	::cEspecie := ""
	::dVencto := ""
	::nValor := 0
	::cCnpj := ""
	::cCodBar := ""
	::cIDProc := ""	
	
Return()


Method Insert() Class TAFDDA
		
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_RET_TIT_DDA"

	::oLog:Insert()

	If ::Validate() .And. !::Exist()
	
		::IdSupplier()
				
		// Grava arquivo de conciliacao DDA
		RecLock("FIG", .T.)
		
			FIG->FIG_FILIAL := ::cFil
			FIG->FIG_DATA := dDataBase
			FIG->FIG_FORNEC := ::cCodFor
			FIG->FIG_LOJA := ::cLojFor
			FIG->FIG_NOMFOR := ::cNomFor
			FIG->FIG_TITULO := ::cNumero
			FIG->FIG_TIPO := ::cEspecie
			FIG->FIG_VENCTO := ::dVencto
			FIG->FIG_VALOR	:= ::nValor
			FIG->FIG_CONCIL := "2"
			FIG->FIG_CNPJ := ::cCnpj
			FIG->FIG_CODBAR := ::cCodBar
		
		FIG->(MsUnlock())
		
		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cTabela := RetSQLName("FIG")
		::oLog:nIDTab := FIG->(RecNo())
		
		If !Empty(::cCodFor)		
			
			::oLog:cMetodo := "S_RET_TIT_DDA"
			::oLog:cEnvWF := "N"
			
		Else
			
			::oLog:cMetodo := "FOR_RET_TIT_DDA"
			::oLog:cEnvWF := "S"
			
		EndIf		
		
		::oLog:Insert()

	Else

		::oLog:cIDProc := ::cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "N_RET_TIT_DDA"
	
		::oLog:Insert()
		
	EndIf
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_RET_TIT_DDA"

	::oLog:Insert()
		
Return()


Method Update() Class TAFDDA
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT FIG_TITULO, FIG_TIPO, FIG_VENCTO, FIG_VALOR, FIG_CNPJ, FIG_CODBAR "
	cSQL += " FROM " + RetSQLName("FIG")
	cSQL += " WHERE FIG_FILIAL = " + ValToSQL(::cFil)
	cSQL += " AND FIG_VENCTO BETWEEN " + ValToSQL(dDataBase) + " AND " + ValToSQL(DaySum(dDataBase, 10))
	cSQL += " AND FIG_CONCIL = '2' "	
	cSQL += " AND FIG_VALOR > 0 "
	cSQL += " AND FIG_CODBAR <> '' "
	cSQL += " AND FIG_FORNEC = '' "
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
	
		::cNumero := (cQry)->FIG_TITULO
		::cEspecie := (cQry)->FIG_TIPO
		::dVencto := (cQry)->FIG_VENCTO
		::nValor := (cQry)->FIG_VALOR
		::cCnpj := (cQry)->FIG_CNPJ
		::cCodBar := (cQry)->FIG_CODBAR
	
		If ::Validate()

			::IdSupplier()
			
			// Se identificou o fornecedor
			If !Empty(::cCodFor)
					
				// Atualiza arquivo de conciliacao DDA
				RecLock("FIG", .F.)
				
					FIG->FIG_FORNEC := ::cCodFor
					FIG->FIG_LOJA := ::cLojFor
					FIG->FIG_NOMFOR := ::cNomFor
					FIG->FIG_CNPJ := ::cCnpj
				
				FIG->(MsUnlock())
				
			EndIf
		
		EndIf

		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return()


Method IdSupplier() Class TAFDDA

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))
	If SA2->(MsSeek(xFilial("SA2") + ::cCnpj))
	
		::SetSupplier(SA2->A2_COD, SA2->A2_LOJA, SA2->A2_NREDUZ)
		
	Else
	
		// Caso nao encontre o fornecedor pelo CNPJ do DDA, procura fornecedor pela raiz do CNJP
		::GetID()
		
	EndIf
	
Return()


Method GetID() Class TAFDDA
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(A2_CGC) AS COUNT, A2_CGC, A2_COD, A2_LOJA, A2_NREDUZ "
	cSQL += " FROM " + RetSQLName("SA2")
	cSQL += " WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " AND A2_CGC LIKE " + ValToSQL(SubStr(::cCnpj, 1, Len(::cCnpj) -6) + "%")
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY A2_CGC, A2_COD, A2_LOJA, A2_NREDUZ "
	
	TcQuery cSQL New Alias (cQry)

	// Caso encontre somente um fornecedor com a mesma raiz, assume que é o correto
	If (cQry)->COUNT == 1	
		
		::cCnpj := (cQry)->A2_CGC
		
		::SetSupplier((cQry)->A2_COD, (cQry)->A2_LOJA, (cQry)->A2_NREDUZ)
	  			
	// Caso encontre mais de um fornecedor com a mesma raiz, analisa se existe algum titulo em aberto para atribuir qual é o correto
	ElseIf (cQry)->COUNT > 1
	
		::GetPartID()
		
	Else
	
		::SetSupplier()	

	EndIf
	
	(cQry)->(DbCloseArea())
	
Return()


Method GetPartID() Class TAFDDA
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT A2_CGC, A2_COD, A2_LOJA, A2_NREDUZ "
	cSQL += " FROM " + RetSQLName("SA2")
	cSQL += " WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))		
	cSQL += " AND A2_COD IN "
	cSQL += " ( "
	cSQL += " 	SELECT E2_FORNECE "
	cSQL += " 	FROM " + RetSQLName("SE2")
	cSQL += " 	WHERE E2_FILIAL = " + ValToSQL(::cFil)
	cSQL += " 	AND (E2_VENCTO = " + ValToSQL(::dVencto) + " OR E2_VENCREA = " + ValToSQL(::dVencto) + ")"
	cSQL += " 	AND E2_SALDO > 0 "
	cSQL += " 	AND E2_VALOR = " + ValToSQL(::nValor)
	cSQL += " 	AND E2_CODBAR = '' "
	cSQL += " 	AND E2_IDCNAB = '' "
	cSQL += " 	AND E2_FORNECE IN "
	cSQL += " 	( "
	cSQL += " 		SELECT A2_COD "
	cSQL += " 		FROM " + RetSQLName("SA2")
	cSQL += " 		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " 		AND A2_CGC LIKE " + ValToSQL(SubStr(::cCnpj, 1, Len(::cCnpj) -6) + "%")
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 	) "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY A2_CGC, A2_COD, A2_LOJA, A2_NREDUZ "
		
	TcQuery cSQL New Alias (cQry)
	  			
	If !Empty((cQry)->A2_CGC)
		
		::cCnpj := (cQry)->A2_CGC
		
		::SetSupplier((cQry)->A2_COD, (cQry)->A2_LOJA, (cQry)->A2_NREDUZ)
		
	Else
	
		::SetSupplier()
			
	EndIf
	
	(cQry)->(DbCloseArea())
	
Return()


Method SetSupplier(cCodigo, cLoja, cNome) Class TAFDDA

	Default cCodigo := ""
	Default cLoja := ""
	Default cNome := ""	

	::cCodFor := cCodigo
	::cLojFor := cLoja
	::cNomFor := cNome
	
Return()


Method Exist() Class TAFDDA
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT FIG_CODBAR "
	cSQL += " FROM " + RetSQLName("FIG")
	cSQL += " WHERE FIG_FILIAL = " + ValToSQL(::cFil)
	cSQL += " AND FIG_CODBAR = " + ValToSQL(::cCodBar)
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := !Empty((cQry)->FIG_CODBAR)
	
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method Validate() Class TAFDDA
Local lRet := .T.

	lRet := !Empty(::cNumero) .And. !Empty(::cEspecie) .And. !Empty(::dVencto) .And. ::nValor > 0 .And. !Empty(::cCnpj) .And. !Empty(::cCodBar)
	
Return(lRet)