#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TComposicaoSaldoFinanceiro
@author Tiago Rossini Coradini
@since 23/05/2018
@version 1.0
@description Classe para vizualização de composicao de saldo financeiro
@obs Ticket: 4615
@type class
/*/

#DEFINE nP_LEG 1
#DEFINE nP_DATA 2
#DEFINE nP_HIST 3
#DEFINE nP_VALOR 4
#DEFINE nP_SALDO 5
#DEFINE nP_CHECK 6
#DEFINE nP_SPACE 7
#DEFINE nP_DATA_REF 8

Class TComposicaoSaldoFinanceiro From LongClassName

	Data cBank
	Data cAgency
	Data cAccount
	Data dStartDate
	Data dEndDate
	Data cImgCre
	Data cImgDeb
	Data cImgSalIni
	Data cImgUnChk

	Method New() Constructor
	Method GetMovBan(cBank, cAgency, cAccount) // Retorna movimento bancario
	Method GetSalIni(lNextMonth) // Retorna saldo inicial
	Method GetSQL() // Retorna SQL
	Method GetBor() // Bordero
	Method GetCob() // Cobranca
	Method GetTrfRec() // Ttransferencia a receber
	Method GetTrfPag() // Ttransferencia a pagar
	Method GetTarBan() // Tarifa bancaria
	Method GetChePag() // Cheque a pagar
	Method GetRecEmp() // Recebimento outras empresas
	Method GetRecMan() // Recebimento manual
	Method GetPagAntChe() // Pagamento antecipado cheque
	Method GetPagDarf_PA() // Pagamento DARF e PA
	Method GetPagFun() // Pagamentos de funcionarios
	Method GetPagFer() // Pagamento ferias
	Method GetPagFol() // Pagamento folha
	Method GetPagRes() // Pagamento rescisao, emprestimo e decimo terceiro
	Method GetPagDebAuto() // Pagamentos de debito automatico
	Method GetLanMan() // Pagamento lancamentos manuais
	Method Insert(dDate, cHist, nValue, cType) // Insere lancamentos manuais
	Method Delete(dDate, cHist, nValue, cType) // Deleta lancamentos manuais
	Method Generate(nValue) // Gera saldo

EndClass


Method New() Class TComposicaoSaldoFinanceiro

	::cBank := ""
	::cAgency := ""
	::cAccount := ""
	::dStartDate := dDataBase
	::dEndDate := dDataBase
	::cImgCre := "BR_VERDE"
	::cImgDeb := "BR_VERMELHO"
	::cImgSalIni := "BR_AZUL"
	::cImgUnChk := "WFUNCHK"

Return()


Method GetMovBan() Class TComposicaoSaldoFinanceiro
	Local aRet := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nSalAtu := ::GetSalIni()
	Local nSalAnt := nSalAtu
	Local cDatMov := ""
	Local cDatAnt := ""
	Local cTipMov := "C"

	aAdd(aRet, {::cImgSalIni, cDatAnt, "SALDO INICIAL", 0, nSalAnt, Space(1), Space(1), Space(1), .F.})

	cSQL := ::GetSQL()

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cTipMov := SubStr(Upper((cQry)->TIPO), 1, 1)

		If aScan(aRet, {|x| x[nP_LEG] <> ::cImgSalIni .And. x[nP_DATA] == dToC(sToD((cQry)->DATA)) }) == 0

			cDatMov := dToC(sToD((cQry)->DATA))

		Else

			cDatMov := ""

		EndIf

		If (cTipMov == "C", nSalAtu += (cQry)->VALOR, nSalAtu -= (cQry)->VALOR)

			If sToD((cQry)->DATA) >= ::dStartDate

				aAdd(aRet, {If (cTipMov == "C", ::cImgCre, ::cImgDeb), cDatMov, (cQry)->HISTORICO, (cQry)->VALOR, nSalAtu, ::cImgUnChk, Space(1), sToD((cQry)->DATA), .F.})

			Else

				cDatAnt := dToC(sToD((cQry)->DATA))

				If (cTipMov == "C", nSalAnt += (cQry)->VALOR, nSalAnt -= (cQry)->VALOR)

				EndIf

				(cQry)->(DbSkip())

			EndDo()

			(cQry)->(DbCloseArea())

			If Len(aRet) > 0

				aRet[1, nP_DATA] := If (Empty(cDatAnt), dToC(FirstDate(::dStartDate)), cDatAnt)
				aRet[1, nP_SALDO] := nSalAnt

			EndIf

			Return(aRet)


Method GetSalIni(lNextMonth) Class TComposicaoSaldoFinanceiro
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local dStartDate := ::dStartDate
	Local dStartDate := ::dStartDate

	Default lNextMonth := .F.

	cSQL := " SELECT ISNULL(ZZM_SALDO, 0) AS ZZM_SALDO "
	cSQL += " FROM "+ RetSQLName("ZZM")
	cSQL += " WHERE ZZM_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND ZZM_AGENCI = "+ ValToSQL(::cAgency)
	cSQL += " AND ZZM_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND ZZM_DATA BETWEEN "+ ValToSQL(FirstDate(If (lNextMonth, MonthSum(::dStartDate, 1), ::dStartDate))) + " AND " + ValToSQL(LastDate(If (lNextMonth, MonthSum(::dStartDate, 1), ::dStartDate)))
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->ZZM_SALDO

	(cQry)->(DbCloseArea())

Return(nRet)


Method GetSQL() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := ::GetBor()
	cSQL += ::GetCob()
	cSQL += ::GetTrfRec()
	cSQL += ::GetTrfPag()
	cSQL += ::GetTarBan()
	cSQL += ::GetChePag()
	cSQL += ::GetRecEmp()
	cSQL += ::GetRecMan()
	cSQL += ::GetPagAntChe()
	cSQL += ::GetPagDarf_PA()
	cSQL += ::GetPagFun()
	cSql += ::GetPagDebAuto()
	cSQL += ::GetLanMan()

Return(cSQL)


Method GetBor() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT 'BORDERO: ' + EA_NUMBOR AS HISTORICO, EA_DATABOR AS DATA, SUM(EA_YVALOR) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE2") + " SE2 "
	cSQL += " INNER JOIN "+ RetSQLName("SEA") + " SEA "
	cSQL += " ON E2_FILIAL = EA_FILIAL "
	cSQL += " AND E2_PREFIXO = EA_PREFIXO "
	cSQL += " AND E2_NUM = EA_NUM "
	cSQL += " AND E2_PARCELA = EA_PARCELA "
	cSQL += " AND E2_TIPO = EA_TIPO "
	cSQL += " AND E2_FORNECE = EA_FORNECE "
	cSQL += " AND E2_LOJA = EA_LOJA "
	cSQL += " WHERE EA_PORTADO = "+ ValToSQL(::cBank)
	cSQL += " AND EA_AGEDEP = "+ ValToSQL(::cAgency)
	cSQL += " AND EA_NUMCON = "+ ValToSQL(::cAccount)
	cSQL += " AND EA_CART = 'P' "
	cSQL += " AND E2_FATURA IN ('', 'NOTFAT') "
	cSQL += " AND EA_DATABOR BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND SEA.D_E_L_E_T_ = '' "
	cSQL += " AND SE2.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY EA_NUMBOR, EA_DATABOR "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetCob() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT 'COBRANCA', E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_LOTE <> '' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTrfRec() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC IN ('TR','TE') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO, E5_HISTOR "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTrfPag() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC IN ('TR','TE') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO, E5_HISTOR "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTarBan() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO, E5_HISTOR "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetChePag() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT HIST, E5_DTDISPO, SUM(VALOR), MAX(TIPO) AS TIPO "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT 'CH' + '-' + E5_BENEF AS HIST, E5_DTDISPO, "
	cSQL += " 	VALOR = CASE WHEN E5_TIPODOC = 'CH' THEN  E5_VALOR ELSE  (E5_VALOR * -1)  END, 'DEBITO' AS TIPO "
	cSQL += " 	FROM "+ RetSQLName("SE5")
	cSQL += " 	WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " 	AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " 	AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " 	AND E5_TIPODOC IN('CH', 'EC') "
	cSQL += " 	AND E5_SITUACA <> 'C' "
	cSQL += " 	AND E5_RECPAG = 'P' "
	cSQL += " 	AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " 	AND D_E_L_E_T_ = '' "

	cSQL += " 	UNION ALL "

	// CANCELAMENTOS DOS CHEQUES
	cSQL += " 	SELECT 'CH' + '-' + E5_BENEF AS HIST, E5_DTDISPO, (E5_VALOR * -1) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " 	FROM "+ RetSQLName("SE5")
	cSQL += " 	WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " 	AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " 	AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " 	AND E5_TIPODOC IN('CH', 'EC') "
	cSQL += " 	AND E5_SITUACA <> 'C' "
	cSQL += " 	AND E5_RECPAG = 'R' "
	cSQL += " 	AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) AS TMP "
	cSQL += " GROUP BY E5_DTDISPO, HIST "

	cSQL += " UNION ALL "

Return(cSQL)

/*Recebimento de Empresa: 
A SP300 (empresa 11) é uma exceção e não deve lista no Saldo F9 os lançamentos de recebimentos de outras empresas,
pois é lançado diretamente pela Tesouraria.
*/
Method GetRecEmp() Class TComposicaoSaldoFinanceiro
Local cSQL := ""
Local aEmp := {}
Local cCodFor := ""
Local nCount := 0
Local cDsc := "'
Local cSEA := ""
Local cSE2 := ""

	//Ticket 26225 - Restringir do Saldo no F9 lançamentos da SP300 referentes a recebimentos das outras empresas já feitos pela Tesouraria (Pablo Nascimento)
	if(cEmpAnt == "11")
		return cSQL
	endif
	
	If !cEmpAnt == "01"
		aAdd(aEmp, "01")
	Else
		cCodFor := "000534"
	EndIf

	If !cEmpAnt == "05"
		aAdd(aEmp, "05")
	Else
		cCodFor := "002912"
	EndIf

	If !cEmpAnt == "06"
		aAdd(aEmp, "06")
	Else
		cCodFor := "007437"
	EndIf

	If !cEmpAnt == "07"
		aAdd(aEmp, "07")
	Else
		cCodFor := "007602"
	EndIf

	If !cEmpAnt == "11"
		aAdd(aEmp, "11")
	Else
		cCodFor := "005138"
	EndIf

	If !cEmpAnt == "12"
		aAdd(aEmp, "12")
	Else
		cCodFor := "004890"
	EndIf

	If !cEmpAnt == "13"
		aAdd(aEmp, "13")
	Else
		cCodFor := "004695"
	EndIf

	If !cEmpAnt == "14"
		aAdd(aEmp, "14")
	Else
		cCodFor := "003721"
	EndIf

	For nCount := 1 To Len(aEmp)

		cDsc := Upper("Rec. "+ Capital(FWEmpName(aEmp[nCount])) + Space(1))
		cSEA := "SEA"+ aEmp[nCount] +"0"
		cSE2 := "SE2"+ aEmp[nCount] +"0"
		cSA2 := RetFullName("SA2", aEmp[nCount])

		cSQL += " SELECT HIST, EA_DATABOR, SUM(VALOR) AS VALOR, 'CREDITO' AS TIPO "
		cSQL += " FROM "
		cSQL += " ( "
		cSQL += " 	SELECT "+ ValToSQL(cDsc) +" + EA_NUMBOR AS HIST, EA_DATABOR, "
		cSQL += " 	VALOR = CASE WHEN E2_SALDO > 0 THEN E2_SALDO ELSE E2_VALOR END, 'CREDITO' AS TIPO "
		cSQL += " 	FROM "+ cSE2 +" SE2 "
		cSQL += " 	INNER JOIN "+ cSEA +" SEA "
		cSQL += " 	ON E2_FILIAL = EA_FILIAL "
		cSQL += " 	AND E2_PREFIXO = EA_PREFIXO "
		cSQL += " 	AND E2_NUM = EA_NUM "
		cSQL += " 	AND E2_PARCELA = EA_PARCELA "
		cSQL += " 	AND E2_TIPO = EA_TIPO "
		cSQL += " 	AND E2_FORNECE = EA_FORNECE "
		cSQL += " 	AND E2_LOJA = EA_LOJA "
		cSQL += " 	AND EXISTS "
		
		cSQL += " 	( "
		cSQL += "		SELECT NULL "
		cSQL += "		FROM " + cSA2 + " SA2"
		cSQL += "		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
		cSQL += " 		AND A2_COD = EA_FORNECE "
		cSQL += " 		AND A2_LOJA = EA_LOJA "
		cSQL += " 		AND A2_BCOIC = " + ValToSQL(AllTrim(::cBank))
		cSQL += " 		AND A2_AGEIC = "+ ValToSQL(::cAgency)
		cSQL += " 		AND A2_CONIC = "+ ValToSQL(::cAccount)
		cSQL += " 		AND SA2.D_E_L_E_T_ = '' "
		cSQL += " 	) "

		cSQL += "  	AND EA_FORNECE = "+ ValToSQL(cCodFor)
		cSQL += "  	AND EA_CART = 'P' "
		cSQL += " 	AND EA_DATABOR BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
		cSQL += " 	AND SEA.D_E_L_E_T_ = '' "
		cSQL += " 	AND SE2.D_E_L_E_T_ = '' "
		cSQL += " ) AS TMP "
		cSQL += " GROUP BY HIST, EA_DATABOR "

		cSQL += " UNION ALL "

	Next

	//EndIf

Return(cSQL)


Method GetRecMan() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO , SUM(E5_VALOR) AS VALOR, 'CREDITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_LOTE = '' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_HISTOR, E5_DTDISPO "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagAntChe() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPODOC = 'PA' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_NUMCHEQ <> '' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_HISTOR, E5_DTDISPO "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagDarf_PA() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E5_HISTOR, E5_DTDISPO, SUM(E5_VALOR) AS VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE5")
	cSQL += " WHERE E5_BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND E5_AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND E5_CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND E5_TIPO NOT IN ('','PA') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_CLIFOR = 'DARF' "
	cSQL += " AND E5_LOTE = '' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_NUMCHEQ = '' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO, E5_HISTOR "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagFun() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""
	Local cBankData := ""

	cBankData := Alltrim(::cBank) + Alltrim(::cAgency) + Alltrim(::cAccount)
	cBankData := Replace(cBankData, ".", Space(0))
	cBankData := Replace(cBankData, "-", Space(0))

	// Controle de pagamento de funcionarios
	If (cEmpAnt == "01" .And. cBankData == "00134312550973") .Or. ; // Folha de pagamento da Biancogress somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.097-3
		(cEmpAnt == "05" .And. cBankData == "02155210532885") .Or. ; // Folha de pagamento da Incesa somente sera executado para o banco Banestes na agencia: 552 e conta: 10532885
		(cEmpAnt == "06" .And. cBankData == "00134312550981") .Or. ; // Folha de pagamento da JK somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.098-1
		(cEmpAnt == "07" .And. cBankData == "0013431252868") .Or. ; // Folha de pagamento da LM somente sera executado para o banco do brasil na agencia: 34312 e conta: 52868
		(cEmpAnt == "11" .And. cBankData == "021055231457237") .Or. ; // Folha de pagamento da SP300 somente sera executado para o banco do Banestes na agencia: 0552 e conta: 31457237
		(cEmpAnt == "12" .And. cBankData == "0013431254968") .Or. ; // Folha de pagamento da ST Gestão somente sera executado para o banco do brasil na agencia: 34312 e conta: 54968
		(cEmpAnt == "13" .And. cBankData == "0013431254666") .Or. ; // Folha de pagamento da Mundi somente sera executado para o banco do brasil na agencia: 34312 e conta: 54666
		(cEmpAnt == "14" .And. cBankData == "001343148755") // Folha de pagamento da Vitcer somente sera executado para o banco do brasil na agencia: 3431 e conta: 48755

		cSQL := ::GetPagFer()
		cSQL += ::GetPagFol()
		cSQL += ::GetPagRes()

	EndIf

Return(cSQL)


Method GetPagFer() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE2")
	cSQL += " WHERE E2_TIPO = 'FER' "
	cSQL += " AND E2_NUMBCO = '' "
	cSQL += " AND E2_NUMBOR = '' "
	cSQL += " AND E2_VENCREA BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagFol() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT RTRIM(E2_FORNECE) + ' - ' + E2_NOMFOR AS HIST, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO  "
	cSQL += " FROM "+ RetSQLName("SE2")
	cSQL += " WHERE E2_TIPO = 'FOL' "
	cSQL += " AND E2_NUMBCO = '' "
	cSQL += " AND E2_NUMBOR = '' "
	cSQL += " AND E2_VENCREA BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagRes() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E2_FORNECE, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM "+ RetSQLName("SE2")
	cSQL += " WHERE E2_TIPO IN ('RES', 'ADI', '132', 'INS', '131') "
	cSQL += " AND E2_NUMBCO = '' "
	cSQL += " AND E2_NUMBOR = '' "
	cSQL += " AND E2_FORNECE IN ('PARC13', 'RESCIS', 'EMPRES', 'ADTOSL') "
	cSQL += " AND E2_VENCREA BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagDebAuto() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""

	cSQL := " SELECT E2_FORNECE + ' - ' + E2_NOMFOR AS HIST, E2_VENCREA, E2_VALOR, 'DEBITO' AS TIPO "
	cSQL += " FROM " + RetSQLName("SE2")
	cSQL += " WHERE E2_VENCREA BETWEEN " + ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " AND EXISTS "
	cSQL += " ( "
	cSQL += " 	SELECT ZK1_CODREG "
	cSQL += " 	FROM " + RetSQLName("ZK1")
	cSQL += " 	WHERE ZK1_CODREG = E2_YCDGREG "
	cSQL += " 	AND ZK1_FORMPG = '3' "
	cSQL += " 	AND (ZK1_CODEMP IN ('', " + ValToSQL(cEmpAnt) + ") AND ZK1_CODFIL IN ('', " + ValToSQL(cFilAnt) + "))"
	cSQL += "		AND ZK1_BANCO = " + ValToSQL(::cBank)
	cSQL += "		AND ZK1_AGENCI = " + ValToSQL(::cAgency)
	cSQL += "		AND ZK1_CONTA = " + ValToSQL(::cAccount)
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetLanMan() Class TComposicaoSaldoFinanceiro
	Local cSQL := ""
	Local cEmp := If (cEmpAnt $ "01/05", cEmpAnt, "07")

	cSQL := " SELECT HISTORICO, DATA, VALOR, TIPO "
	cSQL += " FROM TBL_COMP_SALDO_" + cEmp
	cSQL += " WHERE BANCO = "+ ValToSQL(::cBank)
	cSQL += " AND AGENCIA = "+ ValToSQL(::cAgency)
	cSQL += " AND CONTA = "+ ValToSQL(::cAccount)
	cSQL += " AND DATA BETWEEN "+ ValToSQL(FirstDate(::dStartDate)) + " AND " + ValToSQL(::dEndDate)

	cSQL += " ORDER BY DATA, TIPO, HISTORICO "

Return(cSQL)


Method Insert(dDate, cHist, nValue, cType) Class TComposicaoSaldoFinanceiro
	Local cSQL := ""
	Local cEmp := If (cEmpAnt $ "01/05", cEmpAnt, "07")

	cSQL := " INSERT INTO TBL_COMP_SALDO_" + cEmp
	cSQL += " VALUES (" + ValToSQL(dDate) + ", " + ValToSQL("*****" + Space(1) + cHist) + ", " + ValToSQL(nValue) + ", " + ValToSQL(cType) + ", " + ValToSQL(::cBank) + ", " + ValToSQL(::cAgency) + ", " + ValToSQL(::cAccount) + ")"

	TcSQLExec(cSQL)

Return()


Method Delete(dDate, cHist, nValue, cType) Class TComposicaoSaldoFinanceiro
	Local cSQL := ""
	Local cEmp := If (cEmpAnt $ "01/05", cEmpAnt, "07")

	cSQL := " DELETE TBL_COMP_SALDO_" + cEmp
	cSQL += " WHERE DATA = " + ValToSQL(dDate)
	cSQL += " AND HISTORICO = " + ValToSQL(cHist)
	cSQL += " AND VALOR = " + ValToSQL(nValue)
	cSQL += " AND SUBSTRING(TIPO, 1, 1) = " + ValToSQL(cType)
	cSQL += " AND BANCO = " + ValToSQL(::cBank)
	cSQL += " AND AGENCIA = " + ValToSQL(::cAgency)
	cSQL += " AND CONTA = " + ValToSQL(::cAccount)

	TcSQLExec(cSQL)

Return()


Method Generate(nValue) Class TComposicaoSaldoFinanceiro

	RecLock("ZZM", .T.)

	ZZM->ZZM_FILIAL := xFilial("ZZM")
	ZZM->ZZM_BANCO := ::cBank
	ZZM->ZZM_AGENCI	:= ::cAgency
	ZZM->ZZM_CONTA := ::cAccount
	ZZM->ZZM_DATA	:= FirstDate(MonthSum(::dStartDate, 1))
	ZZM->ZZM_SALDO := nValue

	ZZM->(MsUnLock())

Return()
