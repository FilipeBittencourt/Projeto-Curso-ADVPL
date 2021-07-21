#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRegraComunicacaoBancariaReceber
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe com as regras de comunicação bancaria a receber
@type class
/*/

Class TAFRegraComunicacaoBancariaReceber From LongClassName
		
	Data cOpc // E=Envio; R=Retorno
	Data oLst // Lista de titulos a analisar
	Data cIDProc // Identificar do processo
	Data oLog // Objeto de Log
			
	Method New() Constructor
	Method Set()
	Method Get()
	Method GetRule(cGroup)
	Method IsMultiple(cGroup)
	Method ValidGroup(cGroup)
	Method ValidRule(cRule, lMultiple)
	Method Validate()
	Method ValidEmail(cEmail)
	Method GetTotTitFat(cFatura, cPrefFat, cParcFat)
	
EndClass


Method New() Class TAFRegraComunicacaoBancariaReceber

	::cOpc := "E"
	::oLst := Nil
	::cIDProc := ""
	::oLog := TAFLog():New()
	
Return()


Method Set() Class TAFRegraComunicacaoBancariaReceber
	
	Local nCount := 0
	Local nTotTitFat := 0
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_RCB"
	
	::oLog:Insert()

	For nCount := 1 To ::oLst:GetCount()
					
		If ::cOpc == "E"
			
			If "	" $ ::oLst:GetItem(nCount):cEmail .Or. "	" $ ::oLst:GetItem(nCount):cEmail
			
				::oLst:GetItem(nCount):lValid := .F.
				
				::oLog:cIDProc := ::cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_TIT_INC"
				::oLog:cRetMen := "(Contém o caracter 'TAB') " + "E-mail invalido: " + If(Empty(::oLst:GetItem(nCount):cEmail), "Não informado", AllTrim(::oLst:GetItem(nCount):cEmail))
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "S"
				
				::oLog:Insert()
			
			ElseIf !Empty(::oLst:GetItem(nCount):cEmail) .And. ::ValidEmail(::oLst:GetItem(nCount):cEmail)
			
				// Valida grupo de regras
				If ::ValidGroup(::oLst:GetItem(nCount):cGRCB)
								
					::oLog:cIDProc := ::cIDProc
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_VG_RCB"
					::oLog:cTabela := RetSQLName("SE1")
					::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					::oLog:cHrFin := Time()
				
					::oLog:Insert()
				
					// Regra multipla
					If ::IsMultiple(::oLst:GetItem(nCount):cGRCB)
				
						::oLst:GetItem(nCount):lMRCB := .T.
				
					Else
				
						::oLst:GetItem(nCount):cRCB := ::GetRule(::oLst:GetItem(nCount):cGRCB)
			
					EndIf
				
					// Valida regra
					If ::ValidRule(::oLst:GetItem(nCount):cRCB, ::oLst:GetItem(nCount):lMRCB)
				
						::oLog:cIDProc := ::cIDProc
						::oLog:cOperac := "R"
						::oLog:cMetodo := "CR_VR_RCB"
						::oLog:cTabela := RetSQLName("SE1")
						::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
						::oLog:cHrFin := Time()
				
						::oLog:Insert()
					
						// Varificar regras por empresa e filial
						DbSelectArea("ZK1")
						DbSetOrder(1)
						If ZK1->(DbSeek(xFilial("ZK1") + ::oLst:GetItem(nCount):cRCB))
											
							::oLst:GetItem(nCount):cBanco := ZK1->ZK1_BANCO
							::oLst:GetItem(nCount):cAgencia := ZK1->ZK1_AGENCI
							::oLst:GetItem(nCount):cConta := ZK1->ZK1_CONTA
							::oLst:GetItem(nCount):cSubCta := ZK1->ZK1_SUBCTA
							::oLst:GetItem(nCount):cTpCom := ZK1->ZK1_TPCOM
						
							// Caso seja sem integracao, nao processa
							If ::oLst:GetItem(nCount):cTpCom $ "0"
							
								::oLst:GetItem(nCount):lValid := .F.
							
								DbSelectArea("SE1")
								SE1->(DbGoTo(::oLst:GetItem(nCount):nRecNo))
							
								RecLock("SE1", .F.)
								SE1->E1_YSITAPI := "4"
								SE1->(MsUnlock())
						
							EndIf
						
							::oLog:cIDProc := ::cIDProc
							::oLog:cOperac := "R"
							::oLog:cMetodo := "S_RCB"
							::oLog:cTabela := RetSQLName("SE1")
							::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
							::oLog:cHrFin := Time()
						
							::oLog:Insert()
										
						EndIf
				
					Else
				
						::oLst:GetItem(nCount):lValid := .F.
				
						::oLog:cIDProc := ::cIDProc
						::oLog:cOperac := "R"
						::oLog:cMetodo := "CR_NVR_RCB"
						::oLog:cTabela := RetSQLName("SE1")
						::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
						::oLog:cHrFin := Time()
						::oLog:cEnvWF := "S"
						
						::oLog:Insert()
										
					EndIf
						
				Else
					
					::oLst:GetItem(nCount):lValid := .F.
					
					::oLog:cIDProc := ::cIDProc
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_NVG_RCB"
					::oLog:cTabela := RetSQLName("SE1")
					::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					::oLog:cHrFin := Time()
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()
									
				EndIf
					
			Else
				
				::oLst:GetItem(nCount):lValid := .F.
				
				::oLog:cIDProc := ::cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_TIT_INC"
				::oLog:cRetMen := "E-mail invalido: " + If(Empty(::oLst:GetItem(nCount):cEmail), "Não informado", AllTrim(::oLst:GetItem(nCount):cEmail))
				::oLog:cTabela := RetSQLName("SE1")
				::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "S"
				
				::oLog:Insert()
			
			EndIf
			
			DbSelectArea("SE1")
			SE1->(DbGoTo(::oLst:GetItem(nCount):nRecNo))
			
			If AllTrim(SE1->E1_TIPO) == "FT"
				
				nTotTitFat := ::GetTotTitFat(SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA)
				
				If SE1->E1_VALOR <> nTotTitFat
					
					::oLst:GetItem(nCount):lValid := .F.
					
					::oLog:cIDProc := ::cIDProc
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_TIT_INC"
					::oLog:cRetMen := "Bordero não será gerado - Total fatura " + AllTrim(Transform(SE1->E1_VALOR, "@e 999,999,999.99")) + " Total titulos: " + AllTrim(Transform(nTotTitFat, "@e 999,999,999.99"))
					::oLog:cTabela := RetSQLName("SE1")
					::oLog:nIDTab := ::oLst:GetItem(nCount):nRecNo
					::oLog:cHrFin := Time()
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()
				
				EndIf
				
			EndIf
			
		ElseIf ::cOpc == "R"
		
		EndIf
		
	Next
	
	::oLog:cIDProc := ::cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_RCB"
	::oLog:cHrFin := Time()
	
	::oLog:Insert()
	
Return()


Method Get() Class TAFRegraComunicacaoBancariaReceber
	Local cSQL := ""
	Local cQry := GetNextAlias()

	::oLst := ArrayList():New()

	cSQL := " SELECT ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "
	cSQL += " FROM " + RetSQLName("ZK1")
	cSQL += " WHERE ZK1_FILIAL = " + ValToSQL(xFilial("ZK1"))
	cSQL += " AND ZK1_CODEMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK1_OPERAC = '2' "
	cSQL += " AND ZK1_BANCO <> '' "
	cSQL += " AND ZK1_AGENCI <> '' "
	cSQL += " AND ZK1_CONTA <> '' "
	cSQL += " AND ZK1_SUBCTA <> '' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "
	cSQL += " ORDER BY ZK1_BANCO, ZK1_AGENCI, ZK1_CONTA, ZK1_SUBCTA "

	TcQuery cSQL New Alias (cQry)
		
	While !(cQry)->(Eof())
		
		oObj := TIAFBanco():New()
	
		oObj:cBanco := (cQry)->ZK1_BANCO
		oObj:cAgencia := (cQry)->ZK1_AGENCI
		oObj:cConta := (cQry)->ZK1_CONTA
		oObj:cSubCta := (cQry)->ZK1_SUBCTA

		::oLst:Add(oObj)
				
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())

Return(::oLst)


Method GetRule(cGroup) Class TAFRegraComunicacaoBancariaReceber
	Local cRet := ""
	
	DbSelectArea("ZK0")
	ZK0->(DbSetOrder(1))
	
	DbSelectArea("ZK1")
	ZK1->(DbSetOrder(1))
	
	If ZK0->(DbSeek(xFilial("ZK0") + cGroup))
	
		While ZK0->(! EOF()) .And. ZK0->(ZK0_FILIAL + ZK0_CODGRU) == xFilial("ZK0") + cGroup
		
			If ZK1->(DbSeek(xFilial("ZK1") + ZK0->ZK0_CODREG))
			
				If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
						(ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
						(ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)
				   
					cRet := ZK0->ZK0_CODREG
	
				EndIf
			
			EndIf
			
			ZK0->(DBSkip())
		
		EndDo
	
	EndIf
	
Return(cRet)


Method IsMultiple(cGroup) Class TAFRegraComunicacaoBancariaReceber

	Local lRet := .F.
	Local cSQL := ""
	Local cQry := ""

	If !lRet

		cQry := GetNextAlias()

		cSQL := " SELECT COUNT(ZK0_CODGRU) AS COUNT "
		cSQL += " FROM " + RetSQLName("ZK0") + " ZK0 "
		cSQL += " WHERE ZK0_FILIAL = "+ ValToSQL(xFilial("ZK0"))
		cSQL += " AND ZK0_CODGRU = "+ ValToSQL(cGroup)
		cSQL += " AND EXISTS ( "
		cSQL += "				SELECT * FROM " + RetSQLName("ZK1") + " ZK1 "
		cSQL += "				WHERE 	ZK1.ZK1_FILIAL = " + ValToSQL(xFilial("ZK1")) + " AND "
		cSQL += "						ZK1.ZK1_CODREG = ZK0_CODREG "
		cSQL += "						AND ZK1.ZK1_CODEMP = '" + cEmpAnt + "' AND ZK1.ZK1_CODFIL = '" + cFilAnt + "'
		cSQL += "						AND ZK1.D_E_L_E_T_ = '' "
		cSQL += "	   		 ) "
		cSQL += " AND ZK0.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		lRet := (cQry)->COUNT > 1
		
		(cQry)->(DbCloseArea())

	EndIf

	If !lRet

		cQry := GetNextAlias()

		cSQL := " SELECT COUNT(ZK0_CODGRU) AS COUNT "
		cSQL += " FROM " + RetSQLName("ZK0") + " ZK0 "
		cSQL += " WHERE ZK0_FILIAL = "+ ValToSQL(xFilial("ZK0"))
		cSQL += " AND ZK0_CODGRU = "+ ValToSQL(cGroup)
		cSQL += " AND EXISTS ( "
		cSQL += "				SELECT * FROM " + RetSQLName("ZK1") + " ZK1 "
		cSQL += "				WHERE 	ZK1.ZK1_FILIAL = " + ValToSQL(xFilial("ZK1")) + " AND "
		cSQL += "						ZK1.ZK1_CODREG = ZK0_CODREG "
		cSQL += "						AND ZK1.ZK1_CODEMP = '" + cEmpAnt + "' AND ZK1.ZK1_CODFIL = '' "
		cSQL += "						AND ZK1.D_E_L_E_T_ = '' "
		cSQL += "	   		 ) "
		cSQL += " AND ZK0.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		lRet := (cQry)->COUNT > 1
		
		(cQry)->(DbCloseArea())

	EndIf

	If !lRet

		cQry := GetNextAlias()

		cSQL := " SELECT COUNT(ZK0_CODGRU) AS COUNT "
		cSQL += " FROM " + RetSQLName("ZK0") + " ZK0 "
		cSQL += " WHERE ZK0_FILIAL = "+ ValToSQL(xFilial("ZK0"))
		cSQL += " AND ZK0_CODGRU = "+ ValToSQL(cGroup)
		cSQL += " AND EXISTS ( "
		cSQL += "				SELECT * FROM " + RetSQLName("ZK1") + " ZK1 "
		cSQL += "				WHERE 	ZK1.ZK1_FILIAL = " + ValToSQL(xFilial("ZK1")) + " AND "
		cSQL += "						ZK1.ZK1_CODREG = ZK0_CODREG "
		cSQL += "						AND ZK1.ZK1_CODEMP = '' AND ZK1.ZK1_CODFIL = '' "
		cSQL += "						AND ZK1.D_E_L_E_T_ = '' "
		cSQL += "	   		 ) "
		cSQL += " AND ZK0.D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		lRet := (cQry)->COUNT > 1
		
		(cQry)->(DbCloseArea())

	EndIf

Return(lRet)


Method ValidGroup(cGroup) Class TAFRegraComunicacaoBancariaReceber
	Local lRet := .F.
	Local oLog := TAFLog():New()
	
	If !Empty(cGroup)

		// Verifica se grupo de regra existe
		DbSelectArea("ZK0")
		ZK0->(DbSetOrder(1)) // ZK0_FILIAL, ZK0_CODGRU, ZK0_CODREG, R_E_C_N_O_, D_E_L_E_T_
		
		DbSelectArea("ZK1")
		ZK1->(DbSetOrder(1)) // ZK1_FILIAL, ZK1_CODREG, R_E_C_N_O_, D_E_L_E_T_
		
		If ZK0->(DbSeek(xFilial("ZK0") + cGroup))
		
			While ZK0->(! EOF()) .And. ZK0->(ZK0_FILIAL + ZK0_CODGRU) == xFilial("ZK0") + cGroup
			
				If ZK1->(DbSeek(xFilial("ZK1") + ZK0->ZK0_CODREG))
				
					If (Empty(ZK1->ZK1_CODEMP) .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							(ZK1->ZK1_CODEMP == cEmpAnt .And. Empty(ZK1->ZK1_CODFIL)) .Or.;
							(ZK1->ZK1_CODEMP == cEmpAnt .And. ZK1->ZK1_CODFIL == cFilAnt)
					   
						lRet := .T.

					EndIf
				
				EndIf
				
				ZK0->(DBSkip())
			
			EndDo
		
		Else
		
			// Regra inexistente, envia workflow informativo
			lRet := .F.
			
			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_NVG_RCB"
			
			::oLog:Insert()
		
		EndIf

	// Cliente/Fornecedor sem grupo de regra definido, envia workflow informativo
	Else
		
		lRet := .F.
						
	EndIf

Return(lRet)


Method ValidRule(cRule, lMultiple) Class TAFRegraComunicacaoBancariaReceber
	Local lRet := .T.

	If !Empty(cRule)

		// Verifica se grupo de regra existe
		DbSelectArea("ZK1")
		DbSetOrder(1)
		If !ZK1->(DbSeek(xFilial("ZK1") + cRule))

			// Regra inexistente, envia workflow informativo
			lRet := .F.
		
		EndIf

	// Titulo sem regra definida, envia workflow informativo
	ElseIf lMultiple
	
		lRet := .F.
	
	// Cliente/Fornecedor sem regra definida, envia workflow informativo
	Else
		
		lRet := .F.
		
	EndIf

Return(lRet)


Method ValidEmail(cEmail) Class TAFRegraComunicacaoBancariaReceber

	Local aEmail := StrToKarr(AllTrim(cEmail), ";")
	Local nW := 0
	Local lRet := .T.
	
	For nW := 1 To Len(aEmail)

		If Upper(AllTrim(getenvserver())) == "DEV-FIDC"

			lRet := .T.
			
		Else

			If !IsEmail(aEmail[nW])
					
				lRet := .F.
				
			EndIf
		
		EndIf
	
	Next nW
	
Return(lRet)

Method Validate() Class TAFRegraComunicacaoBancariaReceber
	Local lRet := .F.
	Local nCount := 1
	
	lRet := aScan(::oLst:ToArray(), {|x| !Empty(x:cBanco) }) > 0

Return(lRet)

Method GetTotTitFat(cFatura, cPrefFat, cParcFat) Class TAFRegraComunicacaoBancariaReceber

	Local nTot := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT SUM(E1_VALOR) TOT "
	cSQL += " FROM " + RetSQLName("SE1") + " SE1 ( NOLOCK ) "
	cSQL += " WHERE E1_FILIAL	= " + ValToSQL(cFilAnt)
	cSQL += " AND E1_FATURA 	= " + ValToSQL(cFatura)
	cSQL += " AND E1_FATPREF 	= " + ValToSQL(cPrefFat)
	cSQL += " AND E1_YPARCFT 	= " + ValToSQL(cParcFat)
	cSQL += " AND D_E_L_E_T_ 	= '' "

	TcQuery cSQL New Alias (cQry)

	nTot := (cQry)->TOT
	
	(cQry)->(DbCloseArea())
	
Return(nTot)
