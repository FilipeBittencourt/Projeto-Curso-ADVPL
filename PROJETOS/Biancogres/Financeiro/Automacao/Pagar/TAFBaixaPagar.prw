#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBaixaPagar
@author Tiago Rossini Coradini
@since 03/12/2018
@project Automação Financeira
@version 1.0
@description Classe para efetuar baixa automatica de pagamentos
@type class
/*/

Class TAFBaixaPagar From TAFAbstractClass
	
	Method New() Constructor
	Method Process()
	Method Analyze()
	Method Validate(oObj)
	Method Exist(oObj)
	Method VldBankReceipt(oObj)	
	Method Confirm(oObj)
	Method BankReceipt(oObj)
	Method VldAdvancePayment()
	Method VldBankTransaction()
	Method AddAdvancePayment(oObj)
	Method GetDescOc(oObj)
	Method UpdStatus(nID, cStatus, cErro)
	Method GetErrorLog()
	Method SetConsoleLog(cError)

EndClass


Method New() Class TAFBaixaPagar
	
	_Super:New()

Return()


Method Process(cIDProc) Class TAFBaixaPagar
	
	::oPro:Start()
		
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_BAI_TIT"

	::oLog:Insert()
	
	::Analyze()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_BAI_TIT"

	::oLog:Insert()
		
	::oPro:Finish()
	
Return()


Method Analyze() Class TAFBaixaPagar
Local cSQL := ""
Local cQry := GetNextAlias()
Local dDtIni := GetNewPar("MV_YULMES", FirstDate(dDatabase))

	cSQL := " SELECT ZK4_DATA, ZK4_TIPO, ZK4_BANCO, ZK4_AGENCI, ZK4_CONTA, ZK4_IDCNAB, ZK4_CODBAR, ZK4_VLORI, ZK4_VLPAG, "
	cSQL += " ZK4_DTLIQ, ZK4_OCORET, ZK4_STATUS, ZK4_FILE, ZK4_IDPROC, ZK4_CHVAUT, ZK4_IDGUIA, R_E_C_N_O_ AS RECNO, ZK4_CODOCO "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
	cSQL += " AND ZK4_TIPO IN ('P', 'F') "
	cSQL += " AND ZK4_DTLIQ BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDatabase)
	cSQL += " AND ZK4_STATUS = '1' " // Integrado
	cSQL += " AND D_E_L_E_T_ = ''	"
	cSQL += " ORDER BY ZK4_DATA, ZK4_IDCNAB, ZK4_CODBAR, ZK4_OCORET, ZK4_FILE, ZK4_IDPROC "

	conout(cSQL)
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
	
		oObj := TIAFRetornoBancario():New()
		
		oObj:dData := sToD((cQry)->ZK4_DATA)
		oObj:cTipo := (cQry)->ZK4_TIPO
		oObj:cBanco := (cQry)->ZK4_BANCO
		oObj:cAgencia := (cQry)->ZK4_AGENCI
		oObj:cConta := (cQry)->ZK4_CONTA
		oObj:cIdCnab := AllTrim((cQry)->ZK4_IDCNAB)
		oObj:cCodBar := AllTrim((cQry)->ZK4_CODBAR)
		oObj:nVlOri := (cQry)->ZK4_VLORI
		oObj:nVlPag := (cQry)->ZK4_VLPAG
		oObj:dDtLiq := sToD((cQry)->ZK4_DTLIQ)
		oObj:cCodOco := SubStr((cQry)->ZK4_OCORET, 1, 2)
		oObj:cStatus := (cQry)->ZK4_STATUS
		oObj:cFile := (cQry)->ZK4_FILE
		oObj:cIDProcAPI := (cQry)->ZK4_IDPROC
		oObj:cChvAut := (cQry)->ZK4_CHVAUT
		oObj:cIDGuia := (cQry)->ZK4_IDGUIA
		
		If (oObj:cTipo == 'F')
			oObj:cCodOco := AllTrim((cQry)->ZK4_CODOCO)
		EndIf
		
		oObj:nID := (cQry)->RECNO

		If ::Validate(oObj)
	
			Begin Transaction
				
				::Confirm(oObj)
			
			End Transaction
					
		EndIf
		
		(cQry)->(DbSkip())
			
	EndDo()

	(cQry)->(DbCloseArea())
			
Return()


Method Validate(oObj) Class TAFBaixaPagar
Local lRet := .F.
				
	lRet := ::Exist(oObj) .And. ::VldBankReceipt(oObj)

Return(lRet)


Method Exist(oObj) Class TAFBaixaPagar
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cIdCnab := If (Empty(oObj:cIdCnab), "NOIDCNAB", oObj:cIdCnab)
Local cCodBar := If (Empty(oObj:cCodBar), "NOCODBAR", oObj:cCodBar)

	cSQL := " SELECT E2_SALDO, R_E_C_N_O_ AS RECNO"
	cSQL += " FROM " + RetSQLName("SE2")
	cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))
	
	If (oObj:cTipo == 'F')//FIDC Antecipação
		cSQL += " AND R_E_C_N_O_ = " + ValToSQL(cIdCnab)+" 		"		
	Else
		cSQL += " AND (E2_IDCNAB = " + ValToSQL(cIdCnab) + If("GNRESP" $ oObj:cIdGUIA, ") " , " OR E2_CODBAR = " + ValToSQL(cCodBar) + ") " )
	EndIf
	
	cSQL += " AND	D_E_L_E_T_ = '' "
	
	conout(cSQL)
	TcQuery cSQL New Alias (cQry)

	If (cQry)->RECNO > 0
	
		If (lRet := (cQry)->E2_SALDO > 0)
	
			DbSelectArea("SE2")
			SE2->(DbGoTo((cQry)->RECNO))
			
		Else
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Título baixado anteriormente"
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_BAI_TIT"
			::oLog:cEnvWF := "N"
			
			::oLog:Insert()

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)			
			
		EndIf
	
	Else
	
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Título não encontrado"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cEnvWF := "N"
		
		::oLog:Insert()
		
		::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)		
			
	EndIf
			
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method VldBankReceipt(oObj) Class TAFBaixaPagar
Local lRet := .F.

	If oObj:cBanco == "001"
	
		// IDCANB = 0000000000 - Titulo enviado diretamente pelo aplicativo do banco
		
		If oObj:cIdCnab <> "0000000000"
			
			// 00=CREDITO OU DEBITO EFETUADO 
					
			If oObj:cCodOco == "00" .Or. (!Empty(oObj:cChvAut) .And. !Empty(oObj:cIDGuia) .And. !("REJEITADO" $ oObj:cChvAut))

				lRet := .T.

				If !Empty(oObj:cIDGuia)

					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cTabela := RetSQLName("ZK4")
					::oLog:nIDTab := oObj:nID
					::oLog:cHrFin := Time()
					::oLog:cRetMen := "Pagamento efetuado"
					::oLog:cOperac := "P"
					::oLog:cMetodo := "CP_BAI_TIT_GNRE"
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()

				EndIf
			
			Else

				If !Empty(oObj:cIDGuia)

					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cTabela := RetSQLName("ZK4")
					::oLog:nIDTab := oObj:nID
					::oLog:cHrFin := Time()
					::oLog:cRetMen := ::GetDescOc(oObj, .T.)
					::oLog:cOperac := "P"
					::oLog:cMetodo := "CP_BAI_TIT_GNRE"
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()
					
					::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)					

				Else

					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cTabela := RetSQLName("ZK4")
					::oLog:nIDTab := oObj:nID
					::oLog:cHrFin := Time()
					::oLog:cRetMen := ::GetDescOc(oObj)
					::oLog:cOperac := "P"
					::oLog:cMetodo := "CP_BAI_TIT"
					::oLog:cEnvWF := "S"
					
					::oLog:Insert()
					
					::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

				EndIf
													
			EndIf
		
		Else
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Titulo enviado diretamente pelo aplicativo do banco"
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_BAI_TIT"
			::oLog:cEnvWF := "S"
					
			::oLog:Insert()
			
			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)			
					
		EndIf
	
	ElseIf oObj:cBanco == "237"
			
		// 00=CREDITO OU DEBITO EFETUADO 
				
		If oObj:cCodOco == "00"
		
			lRet := .T.
			
		ElseIf oObj:cCodOco == "02" .And. oObj:cTipo == 'F'  //FIDC PAGAR
		
			lRet := .T.
		Else
		
			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := ::GetDescOc(oObj)
			::oLog:cOperac := "P"
			::oLog:cMetodo := "CP_BAI_TIT"
			::oLog:cEnvWF := "S"
			
			::oLog:Insert()
			
			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)			
					
		EndIf
		
	EndIf

Return(lRet)


Method Confirm(oObj) Class TAFBaixaPagar
	
	dAuxAux := dDataBase
	
	dDataBase := oObj:dDtLiq

	If ::VldAdvancePayment()
		
		If ::VldBankTransaction()
							
			::AddAdvancePayment(oObj)
		
		EndIf
		
	Else			
		
		::BankReceipt(oObj)
	
	EndIf
	
	dDataBase := dAuxAux
	
Return()


Method BankReceipt(oObj) Class TAFBaixaPagar
	
	Local aArea := GetArea()
	Local aTit := {}
	Local cLogTxt := ""
	Local cJSONOrigem
	
	local nSA2RecNo
	local nSE2RecNo

	local oCPLoad
	local oCPStruct
	local oJSONOrigem

	Private lMsErroAuto := .F.

	nSE2RecNo:=SE2->(Recno())

	// Posiciona no banco da baixa para o identificacao no lancamento contabil
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	SA6->(MsSeek(xFilial("SA6") + oObj:cBanco + oObj:cAgencia + oObj:cConta))	
	
	SA2->(dbSetOrder(1))
	SA6->(MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,.F.))
	nSA2RecNo:=SA2->(RecNo())

	aAdd(aTit, {"E2_PREFIXO", SE2->E2_PREFIXO, Nil})
	aAdd(aTit, {"E2_NUM", SE2->E2_NUM, Nil})
	aAdd(aTit, {"E2_PARCELA", SE2->E2_PARCELA, Nil})
	aAdd(aTit, {"E2_TIPO", SE2->E2_TIPO, Nil})
	aAdd(aTit, {"E2_FORNECE", SE2->E2_FORNECE, NIL})
	aAdd(aTit, {"E2_LOJA", SE2->E2_LOJA, NIL})

	//FIDC Antecipacao
	If oObj:cCodOco == "02" .And. oObj:cTipo == 'F' 
		aAdd(aTit, {"AUTMOTBX", "FDC", Nil})
	Else
		aAdd(aTit, {"AUTMOTBX", "DEBITO CC", Nil})	
	EndIf

	aAdd(aTit, {"AUTBANCO", oObj:cBanco, Nil})
	aAdd(aTit, {"AUTAGENCIA", oObj:cAgencia, Nil})
	aAdd(aTit, {"AUTCONTA", oObj:cConta, Nil})
	aAdd(aTit, {"AUTDTBAIXA", oObj:dDtLiq, Nil})

	//FIDC Antecipacao
	If oObj:cCodOco == "02" .And. oObj:cTipo == 'F' 
		aAdd(aTit, {"AUTVLRPG", SE2->E2_SALDO, Nil})
	Else
		aAdd(aTit, {"AUTVLRPG", oObj:nVlPag, Nil})
	EndIf

	//Efetua a Baixa do titulo Original ((nOpc==3).or.(nOpc==4))
	MsExecAuto({|x,y|FINA080(x,y)},aTit,3)

	SE2->(MsGoTo(nSE2RecNo))

	If (!lMsErroAuto)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cRetMen := "Baixa automatica - [OK]"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "N"
		
		::oLog:Insert()
		
		::UpdStatus(oObj:nID, "2")
		
		//FIDC Antecipacao
		If oObj:cCodOco == "02" .And. oObj:cTipo == 'F' 
			
			oCPLoad:=TContaPagarLoad():New()
			oCPStruct:=oCPLoad:BuscarPorRecno(nSE2RecNo)

			SE2->(MsGoTo(nSE2RecNo))

            oCPStruct:cPrefixo:=SE2->E2_PREFIXO
            oCPStruct:cNumero:=SE2->E2_NUM
            oCPStruct:cParcela:=SE2->E2_PARCELA
            oCPStruct:cTipo:=SE2->E2_TIPO
            oCPStruct:cNatureza:=SE2->E2_NATUREZ
            oCPStruct:cFornecedor:=SE2->E2_FORNECE
            oCPStruct:cLoja:=SE2->E2_LOJA
            oCPStruct:dEmissao:=SE2->E2_EMISSAO
            oCPStruct:dVencto:=SE2->E2_VENCTO

            oJSONOrigem:=JSONArray():New()
			cJSONOrigem:=oJSONOrigem:toJSON(oCPStruct)			
			oJSONOrigem:fromJSON(cJSONOrigem)
            
			cacheData():Set("FIDC0001","ORIGEM",oJSONOrigem)
			cacheData():Set("FIDC0001","nSA2RecNoOrigem",nSA2RecNo)
			cacheData():Set("FIDC0001","nSE2RecNoOrigem",nSE2RecNo)

			_lOk:=U_FIDC0001(nSE2RecNo)
			
			cacheData():delSection("FIDC0001")

			If (!_lOk)
				
				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "P"
				::oLog:cMetodo := "CP_BAI_TIT"
				::oLog:cRetMen := "Baixa automatica - [ERRO]"
				::oLog:cTabela := RetSQLName("ZK4")
				::oLog:nIDTab := oObj:nID
				::oLog:cHrFin := Time()
				::oLog:cEnvWF := "S"
				
				::oLog:Insert()
				
				::UpdStatus(oObj:nID, "1", 'Titulo FIDC Pagar - Erro criação titulos automatico para FIDC')
		
				DisarmTransaction()
			EndIf
		EndIf
		
		::SetConsoleLog()		

	Else
						
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cRetMen := "Baixa automatica - [ERRO]"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "S"
		
		::oLog:Insert()
				
		cLogTxt := ::GetErrorLog()

		::UpdStatus(oObj:nID, "1", cLogTxt)
		
		::SetConsoleLog(cLogTxt)
		
		DisarmTransaction()
				
	EndIf

	RestArea(aArea)

Return()


Method VldAdvancePayment() Class TAFBaixaPagar
Local lRet := .T.
	
	lRet := SE2->E2_TIPO $ MVPAGANT
		
Return(lRet)


Method VldBankTransaction() Class TAFBaixaPagar
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT R_E_C_N_O_ AS RECNO"
	cSQL += " FROM " + RetSQLName("SE5")
	cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_PREFIXO = " + ValToSQL(SE2->E2_PREFIXO)
	cSQL += " AND E5_NUMERO = " + ValToSQL(SE2->E2_NUM)
	cSQL += " AND E5_PARCELA = " + ValToSQL(SE2->E2_PARCELA)
	cSQL += " AND E5_TIPO = " + ValToSQL(SE2->E2_TIPO)
	cSQL += " AND E5_CLIFOR = " + ValToSQL(SE2->E2_FORNECE)
	cSQL += " AND E5_LOJA = " + ValToSQL(SE2->E2_LOJA)	
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_TIPODOC = 'PA' "
	cSQL += " AND E5_MOTBX IN ( 'DEB', 'NOR' ) "
	cSQL += " AND E5_SITUACA = '' "
	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->RECNO == 0
		
		lRet := .T.
		
	Else
	
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Movimento Bancário - PA - Gerado anteriormente"
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cEnvWF := "S"

		::oLog:Insert()		
		
		::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)
		
		::SetConsoleLog()
		
	EndIf
				
	(cQry)->(DbCloseArea())
	
Return(lRet)


Method AddAdvancePayment(oObj) Class TAFBaixaPagar
Local aArea := GetArea()
Local aMovBan := {}
Local cLogTxt := ""
Private lMsErroAuto := .F.

	// Posiciona no banco da baixa para o identificacao no lancamento contabil
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6") + oObj:cBanco + oObj:cAgencia + oObj:cConta))

	aAdd(aMovBan, {"E5_FILIAL", xFilial("SE5"), Nil})
	aAdd(aMovBan, {"E5_DATA", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDIGIT", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDISPO", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_VALOR", oObj:nVlPag, Nil})
	aAdd(aMovBan, {"E5_NATUREZ", SE2->E2_NATUREZ, Nil})
	aAdd(aMovBan, {"E5_HISTOR", SE2->E2_HIST, Nil})
	aAdd(aMovBan, {"E5_RECPAG", "P", Nil})
	aAdd(aMovBan, {"E5_MOEDA", "M1", Nil})
	aAdd(aMovBan, {"E5_TXMOEDA", 0, Nil})
	aAdd(aMovBan, {"E5_BANCO", oObj:cBanco, Nil})
	aAdd(aMovBan, {"E5_AGENCIA", oObj:cAgencia, Nil})
	aAdd(aMovBan, {"E5_CONTA", oObj:cConta, Nil})
	aAdd(aMovBan, {"E5_CNABOC", oObj:cCodOco, Nil})
	aAdd(aMovBan, {"E5_TIPODOC", "PA", Nil})
	aAdd(aMovBan, {"E5_MOTBX", "DEB", Nil})
	aAdd(aMovBan, {"E5_PREFIXO", SE2->E2_PREFIXO, Nil})
	aAdd(aMovBan, {"E5_NUMERO", SE2->E2_NUM, Nil})
	aAdd(aMovBan, {"E5_PARCELA", SE2->E2_PARCELA, Nil})
	aAdd(aMovBan, {"E5_TIPO", SE2->E2_TIPO, Nil})
	aAdd(aMovBan, {"E5_CLIFOR", SE2->E2_FORNECE, Nil})
	aAdd(aMovBan, {"E5_LOJA", SE2->E2_LOJA, Nil})	
	aAdd(aMovBan, {"E5_FILORIG", cFilAnt, Nil})

	aMovBan := FWVetByDic(aMovBan, "SE5", .F., 1)

	MsExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aMovBan, 3)
	
	If !lMsErroAuto

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cRetMen := "Movimento Bancário PA - [OK]"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "N"
		
		::oLog:Insert()
		
		::UpdStatus(oObj:nID, "2")
		
		::SetConsoleLog()		

	Else
						
		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "P"
		::oLog:cMetodo := "CP_BAI_TIT"
		::oLog:cRetMen := "Movimento Bancário - PA - [ERRO]"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cEnvWF := "S"
		
		::oLog:Insert()
				
		cLogTxt := ::GetErrorLog()

		::UpdStatus(oObj:nID, "1", cLogTxt)
		
		::SetConsoleLog(cLogTxt)
		
		DisarmTransaction()
				
	EndIf
	
	RestArea(aArea)
	
Return()


Method GetDescOc(oObj, lGnre) Class TAFBaixaPagar
Local cRet := ""
Local cSQL := ""
Local cQry := ""
Local cRetBanco := ""

Default lGnre := .F.

	If lGnre

		cRetBanco := Replace(Replace(AllTrim(oObj:cChvAut), " ", ""), "REJEITADO", "")

		If cRetBanco == "01"
			cRet := "Rejeicao " + cRetBanco + " - " + "Campo não numérico"
		ElseIf cRetBanco == "02"
			cRet := "Rejeicao " + cRetBanco + " - " + "Valor maior do que o permitido"
		ElseIf cRetBanco == "03"
			cRet := "Rejeicao " + cRetBanco + " - " + "Campo com dígito verificador inválido"
		ElseIf cRetBanco == "04"
			cRet := "Rejeicao " + cRetBanco + " - " + "Identificador do produto inválido"
		ElseIf cRetBanco == "05"
			cRet := "Rejeicao " + cRetBanco + " - " + "Código de segmento inválido"
		ElseIf cRetBanco == "06"
			cRet := "Rejeicao " + cRetBanco + " - " + "Código de moeda inválido"
		ElseIf cRetBanco == "07"
			cRet := "Rejeicao " + cRetBanco + " - " + "Ano inválido no campo data"
		ElseIf cRetBanco == "08"
			cRet := "Rejeicao " + cRetBanco + " - " + "Barra Secretaria da Fazenda inválido"
		ElseIf cRetBanco == "09"
			cRet := "Rejeicao " + cRetBanco + " - " + "Convênio não ativo"
		ElseIf cRetBanco == "10"
			cRet := "Rejeicao " + cRetBanco + " - " + "Quantidade de dias maior do que o limite"
		ElseIf cRetBanco == "11"
			cRet := "Rejeicao " + cRetBanco + " - " + "Erro no cálculo do valor"
		ElseIf cRetBanco == "12"
			cRet := "Rejeicao " + cRetBanco + " - " + "Código de incidência de multa inválido"
		ElseIf cRetBanco == "13"
			cRet := "Rejeicao " + cRetBanco + " - " + "Valor do dígito difere do valor do código de barra"
		ElseIf cRetBanco == "14"
			cRet := "Rejeicao " + cRetBanco + " - " + "Erro na depuração da barra"
		ElseIf cRetBanco == "15"
			cRet := "Rejeicao " + cRetBanco + " - " + "Erro na recuperação de índice"
		ElseIf cRetBanco == "16"
			cRet := "Rejeicao " + cRetBanco + " - " + "Erro na recuperação de feriado"
		ElseIf cRetBanco == "17"
			cRet := "Rejeicao " + cRetBanco + " - " + "Documento vencido"
		ElseIf cRetBanco == "18"
			cRet := "Rejeicao " + cRetBanco + " - " + "Recebimento indevido pelo auto-atendimento"
		ElseIf cRetBanco == "19"
			cRet := "Rejeicao " + cRetBanco + " - " + "Erro no sistema DB2"
		ElseIf cRetBanco == "20"
			cRet := "Rejeicao " + cRetBanco + " - " + "Sem comunicação com o sistema de contas correntes"
		ElseIf cRetBanco == "21"
			cRet := "Rejeicao " + cRetBanco + " - " + "Data do pagamento vencida"
		ElseIf cRetBanco == "22"
			cRet := "Rejeicao " + cRetBanco + " - " + "Convênio não autorizado"
		ElseIf cRetBanco == "23"
			cRet := "Rejeicao " + cRetBanco + " - " + "Ausência de autorização de débito"
		ElseIf cRetBanco == "24"
			cRet := "Rejeicao " + cRetBanco + " - " + "Autorização de débito inválida"
		ElseIf cRetBanco == "25"
			cRet := "Rejeicao " + cRetBanco + " - " + "Autorização de débito irregular"
		ElseIf cRetBanco == "88"
			cRet := "Rejeicao " + cRetBanco + " - " + "Número sequencial da remessa duplicado"
		ElseIf cRetBanco == "93"
			cRet := "Rejeicao " + cRetBanco + " - " + "Problemas no campo Ocorrências de Retorno"
		ElseIf cRetBanco == "94"
			cRet := "Rejeicao " + cRetBanco + " - " + "Convenio remetente em situação irregular"
		ElseIf cRetBanco == "95"
			cRet := "Rejeicao " + cRetBanco + " - " + "Saldo insuficiente"
		ElseIf cRetBanco == "96"
			cRet := "Rejeicao " + cRetBanco + " - " + "Convenio destinatário da Receita em situação irregular"
		ElseIf cRetBanco == "97"
			cRet := "Rejeicao " + cRetBanco + " - " + "Sem comunicação com o sistema de contas correntes"
		ElseIf cRetBanco == "99"
			cRet := "Rejeicao " + cRetBanco + " - " + "Débito não autorizado"
		Else
			cRet := "Erro desconhecido"
		EndIf

	Else

		cQry := GetNextAlias()

		cSQL := " SELECT EB_DESCRI "
		cSQL += " FROM " + RetSQLName("SEB")
		cSQL += " WHERE EB_FILIAL = " + ValToSQL(xFilial("SEB"))
		cSQL += " AND EB_BANCO = " + ValToSQL(oObj:cBanco)
		cSQL += " AND EB_REFBAN = " + ValToSQL(SubStr(oObj:cCodOco, 1, 2))
		cSQL += " AND EB_TIPO = 'P' "
		cSQL += " AND D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		If !Empty((cQry)->EB_DESCRI)
			
			cRet := SubStr(oObj:cCodOco, 1, 2) + "-" + Capital(AllTrim((cQry)->EB_DESCRI))
			
		Else
			
			If !Empty(oObj:cChvAut) .And. !Empty(oObj:cIDGuia) .And. ("REJEITADO" $ oObj:cChvAut)
					
				cRet := "GNRE - REJEITADO"		
			
			ElseIf !Empty(SubStr(oObj:cCodOco, 1, 2))
			
				cRet := SubStr(oObj:cCodOco, 1, 2) + "-Ocorrência não identificada"
				
			Else
			
				cRet := "Ocorrência não retornada"
			
			EndIf
			
		EndIf	
			
		(cQry)->(DbCloseArea())

	EndIf
	
Return(cRet)


Method UpdStatus(nID, cStatus, cErro) Class TAFBaixaPagar

	Default cStatus := ""
	Default cErro := ""
		
	DbSelectArea("ZK4")
	ZK4->(DbGoTo(nID))

	RecLock("ZK4", .F.)

	ZK4->ZK4_STATUS := cStatus
	ZK4->ZK4_ERRO := cErro

	ZK4->(MsUnLock())

Return()


Method GetErrorLog() Class TAFBaixaPagar
Local cRet := ""
Local nCount := 1
	
	aError := GetAutoGrLog()
	
	For nCount := 1 To Len(aError)
	
		cRet += aError[nCount] + CRLF
		
	Next
	
Return(cRet)


Method SetConsoleLog(cError) Class TAFBaixaPagar
Local cLog := ""
Local lError := .F.

	Default cError := ""
	
	lError := If (!Empty(cError), .T., .F.)

	cLog := Replicate("-", 120) + Chr(13)
	cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- Baixa Automatica -- [" + If (lError, "ERRO", "OK") + "]" + Chr(13)
	cLog += "[Thread: " + AllTrim(cValToChar(ThreadId())) + "]" + Chr(13)
	cLog += "[Empresa: " + cEmpAnt + "]" + Chr(13)
	cLog += "[Filial: " + cFilAnt + "]" + Chr(13)
	cLog += "[Processo: " + ::oPro:cIDProc + "]" + Chr(13)
	cLog += "[Prefixo: " + AllTrim(SE2->E2_PREFIXO) + "]" + Chr(13)
	cLog += "[Numero: " + AllTrim(SE2->E2_NUM) + "]" + Chr(13)
	cLog += "[Parcela: " + AllTrim(SE2->E2_PARCELA) + "]" + Chr(13)
	cLog += "[Nosso Numero: " + AllTrim(SE2->E2_NUMBCO) + "]" + Chr(13)
	cLog += "[Codigo Barras: " + AllTrim(SE2->E2_CODBAR) + "]" + Chr(13)
	cLog += "[Id Cnab: " + AllTrim(SE2->E2_IDCNAB) + "]" + Chr(13)
	
	If lError
		
		cLog += "[Erro: " + AllTrim(cError) + "]" + Chr(13)
		
	EndIf

	cLog += Replicate("-", 120)
	
	ConOut(Chr(13) + cLog)

Return()
