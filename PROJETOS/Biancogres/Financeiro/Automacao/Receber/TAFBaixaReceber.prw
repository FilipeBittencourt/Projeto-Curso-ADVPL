#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBaixaReceber
@author Tiago Rossini Coradini
@since 03/12/2018
@project Automa��o Financeira
@version 1.0
@description Classe para efetuar baixa automatica de recebimentos
@type class
/*/

Class TAFBaixaReceber From TAFAbstractClass

	Data lErro

	Method New() Constructor
	Method Process()
	Method Analyze()
	Method Validate(oObj)
	Method VldBankRate(oObj)
	Method VldOfficeExpenses(oObj)
	Method VldBankReceipt(oObj)
	Method Confirm(oObj)
	Method Exist(oObj)
	Method AddBankRate(oObj)
	Method BankReceipt(oObj)
	Method GetDescOc(oObj)
	Method UpdStatus(nID, cStatus, cErro)
	Method GetErrorLog(aError)
	Method AjusteCliSE5(oObj)
	Method ExecBaixaCR(oObj, cMotBx)
	Method ExecMovFin(oObj, nValor, cNat, cHist)

EndClass


Method New() Class TAFBaixaReceber

	_Super:New()

	::lErro := .F.

Return()


Method Process() Class TAFBaixaReceber

	::oPro:Start()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_BAI_TIT"

	::oLog:Insert()

	::Analyze()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_BAI_TIT"

	::oLog:Insert()

	::oPro:Finish()

Return()


Method Analyze() Class TAFBaixaReceber
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aErroProc := {}
	Local dDtIni := GetNewPar("MV_YULMES", FirstDate(dDatabase))

	cSQL := " SELECT ZK4_DATA, ZK4_TIPO, ZK4_BANCO, ZK4_AGENCI, ZK4_CONTA, ZK4_NOSNUM, ZK4_VLORI, ZK4_VLREC, ZK4_VLDESP, ZK4_VLDESC, ZK4_VLABAT, ZK4_VLJURO, "
	cSQL += " ZK4_VLMULT, ZK4_VLTAR, ZK4_VLIOF, ZK4_VLOCRE, ZK4_DTLIQ, ZK4_DTCRED, ZK4_CODOCO, ZK4_STATUS, ZK4_FILE, ZK4_IDPROC, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
	//TICKET 23719 - comentado para cada empresa processar todas as filiais  (LM SP), os nossos numeros devem ser unicos
	//TICKET 26749 - Descomentado, pois agora a ZK4_FIL esta sendo gravado com a filial correta.
	cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
	cSQL += " AND ZK4_TIPO = 'R' "
	cSQL += " AND ZK4_DTLIQ BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDatabase)
	cSQL += " AND ZK4_STATUS = '1' " // Integrado
	cSQL += " AND D_E_L_E_T_ = ''	"
	cSQL += " ORDER BY ZK4_DATA, ZK4_NOSNUM, ZK4_CODOCO, ZK4_FILE, ZK4_IDPROC "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		oObj := TIAFRetornoBancario():New()

		// --If para N�o deixar realizar a baixa de tarifa diaria quando for banco do brasil - Ticket 28034
		// As baixas do BB ser�o realizadas pelo JOB BIAF167
		if (cQry)->ZK4_BANCO == '001' .AND. (cQry)->ZK4_VLTAR > 0
			(cQry)->(DbSkip())
			loop
		EndIf

		oObj:dData := sToD((cQry)->ZK4_DATA)
		oObj:cTipo := (cQry)->ZK4_TIPO
		oObj:cBanco := (cQry)->ZK4_BANCO
		oObj:cAgencia := (cQry)->ZK4_AGENCI
		oObj:cConta := (cQry)->ZK4_CONTA
		oObj:cNosNum := (cQry)->ZK4_NOSNUM
		oObj:nVlOri := (cQry)->ZK4_VLORI
		oObj:nVlRec := (cQry)->ZK4_VLREC
		oObj:nVlDesp := (cQry)->ZK4_VLDESP
		oObj:nVlDesc := (cQry)->ZK4_VLDESC
		oObj:nVlAbat := (cQry)->ZK4_VLABAT
		oObj:nVlJuro := (cQry)->ZK4_VLJURO
		oObj:nVlMult := (cQry)->ZK4_VLMULT
		oObj:nVlTar := (cQry)->ZK4_VLTAR
		oObj:nVlIOF := (cQry)->ZK4_VLIOF
		oObj:nVlOCre := (cQry)->ZK4_VLOCRE
		oObj:dDtLiq := sToD((cQry)->ZK4_DTLIQ)
		oObj:dDtCred := sToD((cQry)->ZK4_DTCRED)
		oObj:cCodOco := (cQry)->ZK4_CODOCO
		oObj:cStatus := (cQry)->ZK4_STATUS
		oObj:cFile :=(cQry)->ZK4_FILE
		oObj:cIDProcAPI :=(cQry)->ZK4_IDPROC
		oObj:nID := (cQry)->RECNO

		::lErro := .F.

		If ::Validate(oObj) .And. ( aScan(aErroProc, {|x| x == oObj:cNosNum}) ) == 0

			Begin Transaction

				::Confirm(oObj)

				If ::lErro

					aAdd(aErroProc, oObj:cNosNum)

					::oPro:Finish()

					DisarmTransaction()

					::oPro:Start()

				EndIf

			End Transaction

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return()

Method Validate(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If ::Exist(oObj)

		If ::VldBankRate(oObj)

			lRet := .T.

		ElseIf ::VldOfficeExpenses(oObj)

			lRet := .T.

		ElseIf ::VldBankReceipt(oObj)

			lRet := .T.

		Else

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := ::GetDescOc(oObj)
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

			::oLog:Insert()

		EndIf

	EndIf

Return(lRet)


Method VldBankRate(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf
	ElseIf oObj:cBanco == "021"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method VldOfficeExpenses(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 23=TITULO ENCAMINHADO AO CARTORIO
		// 96=DESPESA DE PROTESTO
		// 98=DEBITO DE CUSTAS ANTECIPADAS
		// 28=TITULO DESPESAS CARTORIO

		If oObj:cCodOco $ "23/96/98/28"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 28=DEBITO TARIFAS/CUSTAS

		If oObj:cCodOco == "28"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "021"

		// 28=DEBITO TARIFAS/CUSTAS

		If oObj:cCodOco == "23/28"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method VldBankReceipt(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 05=LIQUIDACAO SEM REGISTRO
		// 06=LIQUIDACAO NORMA
		// 08=LIQUIDACAO POR SALDO
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "05/06/08/15"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 06=LIQUIDACAO NORMAL
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "06/15"

			lRet := .T.

		EndIf
	ElseIf oObj:cBanco == "021"

		// 06=LIQUIDACAO NORMAL
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "06/15"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method Exist(oObj) Class TAFBaixaReceber
	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 E1_SALDO, R_E_C_N_O_ AS RECNO, E1_YTXCOBR "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL <> '  ' " //" WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND ((E1_NUMBCO = " + ValToSQL(oObj:cNosNum) + ")"
	cSQL += " OR (E1_NUMBCO = LEFT(" + ValToSQL(oObj:cNosNum) + ", len(" + ValToSQL(oObj:cNosNum) + ")-1)) "
	cSQL += " OR (E1_YNUMBCO = " + ValToSQL(oObj:cNosNum) + " AND SUBSTRING(E1_PREFIXO, 1, 2) IN ('PR', 'CT')))"
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY RECNO DESC "

	TcQuery cSQL New Alias (cQry)

	If (lRet := (cQry)->RECNO > 0)

		//Solicitacao da Nadine em 30/04/19 - titulo que tinha desconto mas o cliente pagou o valor integral
		//SE o valor pago for maior que o saldo n�o baixar e gerar workflow
		If (cQry)->E1_SALDO > 0 .And. ( oObj:nVlRec > ROUND((cQry)->E1_SALDO + (cQry)->E1_YTXCOBR, 2) ) .And. oObj:nVlJuro == 0 .And. oObj:nVlOCre == 0

			lRet := .F.

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Valor Recebido MAIOR que o SALDO do t�tulo"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::oLog:Insert()

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

		ElseIf (lRet := (cQry)->E1_SALDO > 0)

			DbSelectArea("SE1")
			SE1->(DbGoTo((cQry)->RECNO))

		ElseIf (lRet := ::VldOfficeExpenses(oObj))

			DbSelectArea("SE1")
			SE1->(DbGoTo((cQry)->RECNO))

			//TICKET 23719 - apenas registro de tarifa de cobranca que ficaram pendentes
		ElseIf (lRet := (::VldBankRate(oObj) .And. oObj:nVlTar > 0 .And. oObj:nVlRec == 0))

			DbSelectArea("SE1")
			SE1->(DbGoTo((cQry)->RECNO))

		Else

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "T�tulo baixado anteriormente"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::oLog:Insert()

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

		EndIf

	Else

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "T�tulo n�o encontrado"
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cEnvWF := "S"

		::oLog:Insert()

		::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)


Method Confirm(oObj) Class TAFBaixaReceber

	dAuxAux := dDataBase

	dDataBase := oObj:dDtLiq

	::AddBankRate(oObj)

	::BankReceipt(oObj)

	dDataBase := dAuxAux

Return()


Method AddBankRate(oObj) Class TAFBaixaReceber
	Local cNat := ""
	Local cHist := ""
	Local nValor := 0

	If ::VldBankRate(oObj)

		cNat := "2915"
		cHist := "TAR. ENVIO COBRANCA " + Alltrim(SE1->E1_NUM) + Space(1) + Alltrim(SE1->E1_PARCELA)
		nValor := oObj:nVlTar

	ElseIf ::VldOfficeExpenses(oObj)

		cNat := "2938"
		cHist := "DESP. CART. COBRANCA " + Alltrim(SE1->E1_NUM) + Space(1) + Alltrim(SE1->E1_PARCELA)
		nValor := oObj:nVlTar + oObj:nVlDesp

	EndIf

	If !Empty(cNat) .And. !Empty(cHist) .And. nValor > 0

		::ExecMovFin(oObj, nValor, cNat, cHist)

	Else

		::UpdStatus(oObj:nID, "2")

	EndIf

Return()


Method BankReceipt(oObj) Class TAFBaixaReceber
	Local aVar := Array(1, 14)
	Local oRecAnt := TRecebimentoAntecipado():New()
	Local lRA := .F.
	Local cMotBx := "NOR"
	Local nAuxTxCart := 0
	Local nAuxVlRec := 0
	Local nAuxTarGnr := 0
	Local nAuxTxCob := 0
	Local lRet := .T.

	// Variaveis utilizadas para lancamento contabil na classe de recebimento antecipado
	Private nHdlPrv 	:= 0
	Private cLote		:= "008850"
	Private aFlagCTB	:= {}
	Private cArquivo := ""

	If ::VldBankReceipt(oObj)

		oRecAnt:lJob := .T.

		aVar[1] := {,,,SE1->E1_NUMBCO, oObj:nVlTar, 0,, oObj:nVlRec,,,,,oObj:dDtCred, oObj:cCodOco}

		//Verificando se eh recebimento antecipado
		lRA := oRecAnt:TituloRecBan(aVar)

		ConOut("TAFBaixaReceber >>> INICIANDO BAIXA AUTOMATICA - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+" VLREC =  "+AllTrim(Str(oObj:nVlRec))+", VLJUROS = "+AllTrim(Str(oObj:nVlJuro))+", VLMULTA = "+AllTrim(Str(oObj:nVlMult)))

		//Desconto previamente baixado
		If ((oObj:nVlRec + oObj:nVlDesc) > SE1->E1_SALDO)

			oObj:nVlDesc := 0

		EndIf

		If oObj:nVlRec > SE1->E1_VALOR .And. Alltrim(SE1->E1_NATUREZ) == "1230" .And. (oObj:cBanco $ "001|237|021" .Or. oObj:cCodOco $ "05")

			nAuxTarGnr := Round(oObj:nVlRec - SE1->E1_VALOR - oObj:nVlJuro - oObj:nVlOCre - oObj:nVlMult, 2)

			nAuxTxCob := Round(SE1->E1_YTXCOBR, 2)

			If nAuxTarGnr > 0 .And. (nAuxTarGnr == nAuxTxCob .Or. nAuxTxCob == 0)

				lRet := .T.

				oObj:nVlMult := oObj:nVlMult + nAuxTarGnr

				// Entende-se que veio do processo antigo
				If nAuxTxCob == 0

					RecLock("SE1", .F.)

					// Atualizo pois utiliza na contabilizacao
					SE1->E1_YTXCOBR := nAuxTarGnr

					SE1->(MSUnlock())

				EndIf

			ElseIf nAuxTarGnr > 0 .And. nAuxTxCob > 0

				lRet := .F.

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_BAI_TIT"
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Titulo ST com falha no calculo"
				::oLog:cEnvWF := "S"
				::oLog:cTabela := RetSQLName("ZK4")
				::oLog:nIDTab := oObj:nID

				::oLog:Insert()

			EndIf

		EndIf

		If lRet

			// Baixa Cartorio
			If oObj:cCodOco == "15" .And. ( oObj:nVlOCre > 0 .Or. oObj:nVlJuro > 0 )

				nAuxVlRec := oObj:nVlRec

				If oObj:nVlOCre > 0 .And. oObj:nVlJuro == 0

					nAuxTxCart := oObj:nVlOCre

					oObj:nVlRec := oObj:nVlOCre

					oObj:nVlJuro := oObj:nVlOCre

					oObj:nVlOCre := 0

				ElseIf oObj:nVlOCre == 0 .And. oObj:nVlJuro > 0

					nAuxTxCart := oObj:nVlJuro

					oObj:nVlRec := oObj:nVlJuro

					oObj:nVlOCre := 0

				ElseIf oObj:nVlOCre > 0 .And. oObj:nVlJuro > 0

					lRet := .F. // Verificar como veio no arquivo para ser tratado

					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_BAI_TIT"
					::oLog:cHrFin := Time()
					::oLog:cRetMen := "Titulo com despesa de cartorio com falha no calculo"
					::oLog:cEnvWF := "S"
					::oLog:cTabela := RetSQLName("ZK4")
					::oLog:nIDTab := oObj:nID

					::oLog:Insert()

				EndIf

				If lRet

					// Baixa Cartorio
					cMotBx := "DESP.CART."

					lRet := ::ExecBaixaCR(oObj, cMotBx)

					If lRet

						// Baixa Titulo
						cMotBx := "NOR"

						oObj:nVlRec := nAuxVlRec - nAuxTxCart

						oObj:nVlJuro := 0

						If !lRA

							lRet := ::ExecBaixaCR(oObj, cMotBx)

						EndIf

					EndIf

				EndIf

				//Tratamento feito para os casos que o retorno vem com codigo 15
				//porem nao trata-se especificamente de desp de cartorio
				//e sim do recebimento, pois a despesa foi cobrada no cartorio,
				//recebido o valor do titulo e repassado para a empresa.
			ElseIf ( oObj:cCodOco <> "15" ) .Or. ( oObj:cCodOco == "15" .And. ( oObj:nVlOCre == 0 .And. oObj:nVlJuro == 0 ) )

				cMotBx := "NOR"

				If lRet .And. !lRA

					lRet := ::ExecBaixaCR(oObj, cMotBx)

				EndIf

			EndIf

		EndIf

		If lRA .And. lRet

			ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA (RECEBIMENTO ANTECIPADO) NN - "+oObj:cNosNum+" - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+" VLREC =  "+AllTrim(Str(oObj:nVlRec))+", VLJUROS = "+AllTrim(Str(oObj:nVlJuro))+", VLMULTA = "+AllTrim(Str(oObj:nVlMult)))

			oRecAnt:cNossoNum := oObj:cNosNum
			oRecAnt:nVlJuros := oObj:nVlJuro

			If oRecAnt:BaixarPr()

				ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA - SUCESSO - (RECEBIMENTO ANTECIPADO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

				::UpdStatus(oObj:nID, "2")

			Else

				ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA - ERRO - (RECEBIMENTO ANTECIPADO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) + CRLF + CRLF + oRecAnt:cErro)

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cTabela := RetSQLName("ZK4")
				::oLog:nIDTab := oObj:nID
				::oLog:cHrFin := Time()
				::oLog:cRetMen := oRecAnt:cErro
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_BAI_TIT"
				::oLog:cEnvWF := "S"

				::oLog:Insert()

				::lErro := .T.

				::UpdStatus(oObj:nID, "1", oRecAnt:cErro)

			EndIf

		EndIf

	EndIf

Return()


Method ExecMovFin(oObj, nValor, cNat, cHist) Class TAFBaixaReceber
	
	Local aMovBan := {}
	Local aAutoErro := {}
	Local cLogTxt := ""
	Local dDataDisp := If(oObj:cBanco $ "237", If(Empty(oObj:dDtCred), DataValida(oObj:dDtLiq + 1), oObj:dDtCred), oObj:dDtLiq)
	Local _cFilBkp := cFilAnt

	Local cPadrao
	Local nSE1RecNo

	Local cSA1IdxKey

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	If ( cFilAnt <> SE1->E1_FILIAL )
		cFilAnt := SE1->E1_FILIAL
	EndIf

	aAdd(aMovBan, {"E5_FILIAL", xFilial("SE5"), Nil})
	aAdd(aMovBan, {"E5_DATA", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDIGIT", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDISPO", dDataDisp, Nil})
	aAdd(aMovBan, {"E5_VALOR", nValor, Nil})
	aAdd(aMovBan, {"E5_NATUREZ", cNat, Nil})
	aAdd(aMovBan, {"E5_HISTOR", cHist, Nil})
	aAdd(aMovBan, {"E5_RECPAG", "P", Nil})
	aAdd(aMovBan, {"E5_MOEDA", "M1", Nil})
	aAdd(aMovBan, {"E5_TXMOEDA", 0, Nil})
	aAdd(aMovBan, {"E5_BANCO", oObj:cBanco, Nil})
	aAdd(aMovBan, {"E5_AGENCIA", oObj:cAgencia, Nil})
	aAdd(aMovBan, {"E5_CONTA", oObj:cConta, Nil})
	aAdd(aMovBan, {"E5_CNABOC", oObj:cCodOco, Nil})
	aAdd(aMovBan, {"E5_TIPODOC", "DB", Nil})
	aAdd(aMovBan, {"E5_MOTBX", "NOR", Nil})
	aAdd(aMovBan, {"E5_PREFIXO", SE1->E1_PREFIXO, Nil})
	aAdd(aMovBan, {"E5_NUMERO", SE1->E1_NUM, Nil})
	aAdd(aMovBan, {"E5_PARCELA", SE1->E1_PARCELA, Nil})
	aAdd(aMovBan, {"E5_TIPO", SE1->E1_TIPO, Nil})
	//aAdd(aMovBan, {"E5_CLVLDB", If (cEmpAnt == "01", "1215", If (cEmpAnt == "05", "1003", If (cEmpAnt == "06", "1055", If (cEmpAnt == "07", "1219", If (cEmpAnt == "12", "1090", If (cEmpAnt == "13", "1080", If (cEmpAnt == "14", "1500", "0"))))))), Nil})
	aAdd(aMovBan, {"E5_CLVLDB", U_BIA478G("ZJ0_CLVLDB", cNat, "P"), Nil})

	aAdd(aMovBan, {"E5_CCD", "1000", Nil})
	aAdd(aMovBan, {"E5_FILORIG", cFilAnt, Nil})

	aMovBan := FWVetByDic(aMovBan, "SE5", .F., 1)

	MsExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aMovBan, 3)

	If !lMsErroAuto

		// Ticket: 25060
		RecLock("SE5", .F.)
		SE5->E5_TIPODOC := "DB"
		SE5->(MSUnlock())

		//Gravar campos adicionais SE5
		::AjusteCliSE5(oObj)

		ConOut("BAIXA RECEBER AUTOMATICA (TARIFA - SUCESSO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		//Atualizar Status ZK4
		::UpdStatus(oObj:nID, "2")

		if (FIDC():isFIDCEnabled())
			cSA1IdxKey:="A1_FILIAL+A1_COD+A1_LOJA"
			SA1->(dbSetOrder(retOrder("SA1",cSA1IdxKey)))
			if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
				//Contabilizacao FIDC
				cPadrao:=FIDC():getBiaPar("FIDC_LP_MOVFIN",""/*FMF*/)
				if (!empty(cPadrao))
					nSE1RecNo:=SE1->(recNo())
					FIDC():setFIDCVar("lCTBFIDC",.T.)
					FIDC():setFIDCVar("cCTBStack","ExecMovFin")
					FIDC():setFIDCVar("cPadrao",cPadrao)
					FIDC():setFIDCVar("nSE1RecNo",nSE1RecNo)
					FIDC():setFIDCVar("nSA1RecNo",SA1->(recNo()))
					FIDC():setFIDCVar("cBanco",SE1->E1_PORTADO)
					FIDC():setFIDCVar("cAgencia",SE1->E1_AGEDEP)
					FIDC():setFIDCVar("cConta",SE1->E1_CONTA)
					FIDC():setFIDCVar("cCodOco",oObj:cCodOco)
					FIDC():setFIDCVar("lUsaFlag",SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/))
					if (FIDC():getFIDCVar("lUsaFlag",.F.))
						FIDC():setFIDCVar("aFlagCTB",{"E1_LA","S","SE1",nSE1RecNo,0,0,0})
					endif
					FIDC():setFIDCVar("lDiario",(FindFunction("UsaSeqCor").and.UsaSeqCor()))
					if (FIDC():getFIDCVar("lDiario",.F.))
						FIDC():setFIDCVar("aDiario",{"SE1",nSE1RecNo,SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
					endif
					SE1->(FIDC():ctbFIDC())
					FIDC():resetFIDCVars()
				endif
			endif
		endif

	Else

		::lErro := .T.

		::UpdStatus(oObj:nID, "1", cLogTxt)

		//DisarmTransaction()

		//Grava log de erro para consulta posterior
		aAutoErro := GETAUTOGRLOG()

		cLogTxt += ::GetErrorLog(aAutoErro)

		ConOut("ERRO BAIXA RECEBER AUTOMATICA (TARIFA - ERRO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+": ERRO: "+cLogTxt)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := cLogTxt
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID

		::oLog:Insert()

	EndIf

	If ( cFilAnt <> _cFilBkp )
		cFilAnt := _cFilBkp
	EndIf

Return(!lMsErroAuto)


Method ExecBaixaCR(oObj, cMotBx) Class TAFBaixaReceber
	
	Local aTit := {}
	Local aAutoErro := {}
	Local cLogTxt := ""
	Local aPerg := {}
	Local _cFilBkp := cFilAnt

	Local cPadrao
	Local cSA1IdxKey
	Local nSE1RecNo

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	If ( cFilAnt <> SE1->E1_FILIAL )
		cFilAnt := SE1->E1_FILIAL
	EndIf

	Pergunte("FIN070", .F.,,,,, @aPerg)

	MV_PAR03 := 1
	MV_PAR05 := 1

	__SaveParam("FIN070", aPerg)


	aAdd(aTit, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
	aAdd(aTit, {"E1_NUM", SE1->E1_NUM, Nil})
	aAdd(aTit, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
	aAdd(aTit, {"E1_TIPO", SE1->E1_TIPO, Nil})
	aAdd(aTit, {"AUTMOTBX", cMotBx, Nil})
	aAdd(aTit, {"AUTBANCO", oObj:cBanco, Nil})
	aAdd(aTit, {"AUTAGENCIA", oObj:cAgencia, Nil})
	aAdd(aTit, {"AUTCONTA", oObj:cConta, Nil})
	aAdd(aTit, {"AUTDTBAIXA", oObj:dDtLiq, Nil})
	aAdd(aTit, {"AUTDTCREDITO", oObj:dDtCred, Nil})
	aAdd(aTit, {"AUTDESCONT", oObj:nVlDesc, Nil,.T.})
	aAdd(aTit, {"AUTJUROS", oObj:nVlJuro, Nil,.T.})
	aAdd(aTit, {"AUTMULTA", oObj:nVlMult, Nil,.T.})
	aAdd(aTit, {"AUTACRESC", oObj:nVlOCre, Nil})
	aAdd(aTit, {"AUTVALREC", oObj:nVlRec, Nil})

	MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)

	If !lMsErroAuto

		ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA (BAIXA - SUCESSO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		::UpdStatus(oObj:nID, "2")

		if (FIDC():isFIDCEnabled())
			cSA1IdxKey:="A1_FILIAL+A1_COD+A1_LOJA"
			SA1->(dbSetOrder(retOrder("SA1",cSA1IdxKey)))
			if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
				//Contabilizacao FIDC
				cPadrao:=FIDC():getBiaPar("FIDC_LP_BAIXA","FBX")
				if (!empty(cPadrao))
					nSE1RecNo:=SE1->(recNo())
					FIDC():setFIDCVar("cPadrao",cPadrao)
					FIDC():setFIDCVar("nSE1RecNo",nSE1RecNo)
					FIDC():setFIDCVar("nSA1RecNo",SA1->(recNo()))
					FIDC():setFIDCVar("cBanco",SE1->E1_PORTADO)
					FIDC():setFIDCVar("cAgencia",SE1->E1_AGEDEP)
					FIDC():setFIDCVar("cConta",SE1->E1_CONTA)
					FIDC():setFIDCVar("cCodOco",oObj:cCodOco)
					FIDC():setFIDCVar("lUsaFlag",SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/))
					if (FIDC():getFIDCVar("lUsaFlag",.F.))
						FIDC():setFIDCVar("aFlagCTB",{"E1_LA","S","SE1",nSE1RecNo,0,0,0})
					endif
					FIDC():setFIDCVar("lDiario",(FindFunction("UsaSeqCor").and.UsaSeqCor()))
					if (FIDC():getFIDCVar("lDiario",.F.))
						FIDC():setFIDCVar("aDiario",{"SE1",nSE1RecNo,SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
					endif
					SE1->(FIDC():ctbFIDC())
					FIDC():resetFIDCVars()
				endif
			endif
		endif

	Else

		::lErro := .T.

		//Grava log de erro para consulta posterior
		aAutoErro := GETAUTOGRLOG()

		cLogTxt += ::GetErrorLog(aAutoErro)

		::UpdStatus(oObj:nID, "1", cLogTxt)

		ConOut("TAFBaixaReceber >>> ERRO BAIXA AUTOMATICA (BAIXA - ERRO)- (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+": ERRO: "+cLogTxt)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := cLogTxt
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID

		::oLog:Insert()

	EndIf

	If ( cFilAnt <> _cFilBkp )
		cFilAnt := _cFilBkp
	EndIf

Return(!lMsErroAuto)


Method AjusteCliSE5(oObj) Class TAFBaixaReceber
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 REC = R_E_C_N_O_ "
	cSQL += " FROM " + RetSqlName("SE5")
	cSQL += " WHERE E5_FILIAL	= " + ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_PREFIXO	= " + ValToSQL(SE1->E1_PREFIXO)
	cSQL += " AND E5_NUMERO	= " + ValToSQL(SE1->E1_NUM)
	cSQL += " AND E5_PARCELA	= " + ValToSQL(SE1->E1_PARCELA)
	cSQL += " AND E5_TIPO 	  	= " + ValToSQL(SE1->E1_TIPO)
	cSQL += " AND E5_TIPODOC	= 'DB' "
	cSQL += " AND E5_MOTBX 	= 'NOR' "
	cSQL += " AND E5_RECPAG	= 'P' "
	cSQL += " AND E5_DATA 	  	= " + ValToSQL(DTOS(oObj:dDtLiq))
	cSQL += " AND D_E_L_E_T_	= '' "
	cSQL += " ORDER BY R_E_C_N_O_ DESC "

	TcQuery cSQL New Alias (cQry)

	(cQry)->(DbGoTop())

	If !(cQry)->(Eof())

		SE5->(DbSetOrder(0))
		SE5->(DbGoTo((cQry)->REC))

		If !SE5->(EOF())

			lRet := .T.

			RecLock("SE5", .F.)

			SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
			SE5->E5_LOJA	:= SE1->E1_LOJA

			SE5->(MSUnlock())

		EndIf

	EndIf

	(cQry)->(DBCloseArea())

Return(lRet)


Method GetDescOc(oObj) Class TAFBaixaReceber
	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT EB_DESCRI "
	cSQL += " FROM " + RetSQLName("SEB")
	cSQL += " WHERE EB_FILIAL = " + ValToSQL(xFilial("SEB"))
	cSQL += " AND EB_BANCO = " + ValToSQL(oObj:cBanco)
	cSQL += " AND EB_REFBAN = " + ValToSQL(SubStr(oObj:cCodOco, 1, 2))
	cSQL += " AND EB_TIPO = 'R' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->EB_DESCRI)

		cRet := SubStr(oObj:cCodOco, 1, 2) + "-" + Capital(AllTrim((cQry)->EB_DESCRI))

	Else

		cRet := SubStr(oObj:cCodOco, 1, 2) + "-Ocorr�ncia n�o identificada"

	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)


Method UpdStatus(nID, cStatus, cErro) Class TAFBaixaReceber

	Default cStatus := ""
	Default cErro := ""

	DbSelectArea("ZK4")
	ZK4->(DbGoTo(nID))

	RecLock("ZK4", .F.)

	ZK4->ZK4_STATUS := cStatus
	ZK4->ZK4_ERRO := If(Empty(ZK4->ZK4_ERRO), cErro, " - " + cErro)

	ZK4->(MsUnLock())

Return()


Method GetErrorLog(aError) Class TAFBaixaReceber

	Local cRet := ""
	Local nX := 1

	Default aError := {}

	For nX := 1 To Len(aError)

		cRet += aError[nX] + CRLF

	Next nX

Return(cRet)
