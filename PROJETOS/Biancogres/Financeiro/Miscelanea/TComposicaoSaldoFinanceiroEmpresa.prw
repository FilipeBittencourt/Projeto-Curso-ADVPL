#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TComposicaoSaldoFinanceiroEmpresa
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Classe para vizualização de composicao de saldo financeiro por empresa
@obs Ticket: 1937
@type class
/*/

// Profile
#DEFINE nPrf_EMP 1
#DEFINE nPrf_BANCO 2
#DEFINE nPrf_AGENCIA 3
#DEFINE nPrf_CONTA 4

Class TComposicaoSaldoFinanceiroEmpresa From LongClassName

	Data cCompany
	Data dDate
	Data cImgCre
	Data cImgDeb
	Data cChk
	Data cUnChk

	Method New() Constructor
	Method GetMovBan(aProfile) // Retorna movimento bancario
	Method GetSQL() // Retorna SQL
	Method GetSalIni() // Retorna saldo inicial
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
	Method GetPagDebAuto() // Pagamentos de debito automatico
	Method GetLanMan() // Pagamento Lancamentos manuais

EndClass


Method New() Class TComposicaoSaldoFinanceiroEmpresa

	::cCompany := ""
	::dDate := dDataBase
	::cImgCre := "BR_VERDE"
	::cImgDeb := "BR_VERMELHO"
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"

Return()

Method GetMovBan(aProfile) Class TComposicaoSaldoFinanceiroEmpresa
	Local aRet := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nValor := 0
	Local lCheck := .F.

	cSQL := ::GetSQL()

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		//nValor := (cQry)->VALOR + ::GetRecEmp((cQry)->BANCO, (cQry)->AGENCIA, (cQry)->CONTA) + ::GetPagFun((cQry)->BANCO, (cQry)->AGENCIA, (cQry)->CONTA)

		nValor := (cQry)->VALOR + ::GetRecEmp( (cQry)->BANCO, (cQry)->AGENCIA, (cQry)->CONTA )

		lCheck := (aScan(aProfile, {|x| x[nPrf_EMP] == ::cCompany .And. x[nPrf_BANCO] == (cQry)->BANCO .And. x[nPrf_AGENCIA] == (cQry)->AGENCIA .And. x[nPrf_CONTA] == (cQry)->CONTA}) > 0)

		aAdd(aRet, {If (nValor >= 0, ::cImgCre, ::cImgDeb), (cQry)->BANCO, (cQry)->AGENCIA, (cQry)->CONTA, (cQry)->NOME, ::dDate, nValor, If (lCheck, ::cChk, ::cUnChk), Space(1), .F.})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetSQL() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT BANCO, AGENCIA, CONTA, A6_NOME AS NOME, SUM(VALOR) AS VALOR "
	cSQL += " FROM ( "

	cSQL += ::GetSalIni()
	cSQL += ::GetBor()
	cSQL += ::GetPagFun()
	cSQL += ::GetCob()
	cSQL += ::GetTrfRec()
	cSQL += ::GetTrfPag()
	cSQL += ::GetTarBan()
	cSQL += ::GetChePag()
	cSQL += ::GetRecMan()
	cSQL += ::GetPagAntChe()
	cSQL += ::GetPagDarf_PA()
	cSql += ::GetPagDebAuto()
	cSQL += ::GetLanMan()

	cSQL += " ) AS TMP "
	cSQL += " INNER JOIN "+ RetFullName("SA6", ::cCompany)
	cSQL += " ON BANCO = A6_COD "
	cSQL += " AND AGENCIA = A6_AGENCIA "
	cSQL += " AND CONTA = A6_NUMCON "
	cSQL += " GROUP BY BANCO, AGENCIA, CONTA, A6_NOME "
	cSQL += " ORDER BY BANCO, AGENCIA, CONTA "

Return(cSQL)


Method GetSalIni() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""
	Local cZZM := RetFullName("ZZM", ::cCompany)

	If !Empty(cZZM)

		cSQL := " SELECT ZZM_BANCO AS BANCO, ZZM_AGENCI AS AGENCIA, ZZM_CONTA AS CONTA, ZZM_SALDO AS VALOR"
		cSQL += " FROM "+ cZZM
		cSQL += " WHERE ZZM_DATA = "+ ValToSQL(FirstDate(::dDate))
		cSQL += " AND D_E_L_E_T_ = '' "

		cSQL += " UNION ALL "

	EndIf

Return(cSQL)


Method GetBor() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT EA_PORTADO AS BANCO, EA_AGEDEP AS AGENCIA, EA_NUMCON AS CONTA, EA_YVALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE2", ::cCompany) + " SE2 "
	cSQL += " INNER JOIN "+ RetFullName("SEA", ::cCompany) + " SEA "
	cSQL += " ON E2_FILIAL = EA_FILIAL "
	cSQL += " AND E2_PREFIXO = EA_PREFIXO "
	cSQL += " AND E2_NUM = EA_NUM "
	cSQL += " AND E2_PARCELA = EA_PARCELA "
	cSQL += " AND E2_TIPO = EA_TIPO "
	cSQL += " AND E2_FORNECE = EA_FORNECE "
	cSQL += " AND E2_LOJA = EA_LOJA "
	cSQL += " WHERE EA_CART = 'P' "
	cSQL += " AND E2_FATURA IN ('', 'NOTFAT') "
	cSQL += " AND EA_DATABOR BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND SEA.D_E_L_E_T_ = '' "
	cSQL += " AND SE2.D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetCob() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_LOTE <> '' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTrfRec() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC IN ('TR', 'TE') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTrfPag() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC IN ('TR', 'TE') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetTarBan() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetChePag() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, VALOR * -1 "
	cSQL += " FROM ( "

	cSQL += " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, "
	cSQL += " VALOR = CASE WHEN E5_TIPODOC = 'CH' THEN E5_VALOR ELSE E5_VALOR * -1 END "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC IN ('CH', 'EC') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

	cSQL += " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC IN ('CH', 'EC') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " ) AS TMP "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetRecEmp(cBanco, cAgencia, cConta) Class TComposicaoSaldoFinanceiroEmpresa
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aEmp := {}
	Local cCodFor := ""
	Local nCount := 0
	Local cSEA := ""
	Local cSE2 := ""
	Local cBankData := ""

	cBankData := Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta)
	cBankData := Replace(cBankData, ".", Space(0))
	cBankData := Replace(cBankData, "-", Space(0))

	//Ticket 26225 - Restringir do Saldo no F9 lançamentos da SP300 referentes a recebimentos das outras empresas já feitos pela Tesouraria (Pablo Nascimento)
	if(::cCompany == "11")
		return nRet
	endif

// Ticket: 26873 e 27297 
	// Controle de recebimentos entre as empresas do grupo
	//If (::cCompany == "01" .And. cBankData == "00134312550973") .Or. ; // Recebimento da Biancogress somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.097-3
//		 (::cCompany == "05" .And. cBankData == "0013431256669") .Or. ; // Recebimento da Incesa somente sera executado para o banco do brasil na agencia: 34312 e conta: 5.666-9
//		 (::cCompany == "06" .And. cBankData == "00134312550981") .Or. ; // Recebimento da JK somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.098-1
//		 (::cCompany == "07" .And. cBankData == "0013431252868") .Or. ; // Recebimento da LM somente sera executado para o banco do brasil na agencia: 34312 e conta: 52868
//		 (::cCompany == "11" .And. cBankData == "0013431253295") .Or. ; // Folha de pagamento da SP300 somente sera executado para o banco do brasil na agencia: 34312 e conta: 53295
//		 (::cCompany == "12" .And. cBankData == "0013431254968") .Or. ; // Recebimento da ST Gestão somente sera executado para o banco do brasil na agencia: 34312 e conta: 54968
//		 (::cCompany == "13" .And. cBankData == "0013431254666") .Or. ; // Recebimento da Mundi somente sera executado para o banco do brasil na agencia: 34312 e conta: 54666
//		 (::cCompany == "14" .And. cBankData == "001343148755") // Recebimento da Vitcer somente sera executado para o banco do brasil na agencia: 3431 e conta: 48755

	If !::cCompany == "01"
		aAdd(aEmp, "01")
	Else
		cCodFor := "000534"
	EndIf

	If !::cCompany == "05"
		aAdd(aEmp, "05")
	Else
		cCodFor := "002912"
	EndIf

	If !::cCompany == "06"
		aAdd(aEmp, "06")
	Else
		cCodFor := "007437"
	EndIf

	If !::cCompany == "07"
		aAdd(aEmp, "07")
	Else
		cCodFor := "007602"
	EndIf

	If !::cCompany == "11"
		aAdd(aEmp, "11")
	Else
		cCodFor := "005138"
	EndIf

	If !::cCompany == "12"
		aAdd(aEmp, "12")
	Else
		cCodFor := "004890"
	EndIf

	If !::cCompany == "13"
		aAdd(aEmp, "13")
	Else
		cCodFor := "004695"
	EndIf

	If !::cCompany == "14"
		aAdd(aEmp, "14")
	Else
		cCodFor := "003721"
	EndIf

	cSQL := " SELECT ISNULL(SUM(VALOR), 0) AS VALOR "
	cSQL += " FROM ( "

	For nCount := 1 To Len(aEmp)

		cSEA := "SEA"+ aEmp[nCount] +"0"
		cSE2 := "SE2"+ aEmp[nCount] +"0"
		cSA2 := RetFullName("SA2", aEmp[nCount])

		cSQL += " SELECT CASE WHEN E2_SALDO > 0 THEN E2_SALDO ELSE E2_VALOR END AS VALOR "
		cSQL += " FROM "+ cSE2 +" SE2 "
		cSQL += " INNER JOIN "+ cSEA +" SEA "
		cSQL += " ON E2_FILIAL = EA_FILIAL "
		cSQL += " AND E2_PREFIXO = EA_PREFIXO "
		cSQL += " AND E2_NUM = EA_NUM "
		cSQL += " AND E2_PARCELA = EA_PARCELA "
		cSQL += " AND E2_TIPO = EA_TIPO "
		cSQL += " AND E2_FORNECE = EA_FORNECE "
		cSQL += " AND E2_LOJA = EA_LOJA "
		cSQL += " WHERE 1=1 "
		//cSQL += " WHERE EA_PORTADO = "+ ValToSQL(cBanco)

		// Tratamento especifico para Vitcer, pois a agencia é diferente das demais empresas do grupo
		//If ::cCompany == "14"

		//	cSQL += " AND EA_AGEDEP = '34312' "

		//ElseIf aEmp[nCount] == "14"

		//	cSQL += " AND EA_AGEDEP = '3431' "

		//Else

		//	cSQL += " AND EA_AGEDEP = "+ ValToSQL(cAgencia)

		//EndIf

		// Ticket: 26873 - Da forma que estava, fazia a query de titulos pagos na filial origem passando apenas banco e agencia.
		// que no caso eram todas banco do brasil, agora tem outros bancos.

		cSQL += " 	AND EXISTS "
		cSQL += " 	( "
		cSQL += "		SELECT NULL "
		cSQL += "		FROM " + cSA2 + " SA2"
		cSQL += "		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))
		cSQL += " 		AND A2_COD = EA_FORNECE "
		cSQL += " 		AND A2_LOJA = EA_LOJA "
		cSQL += " 		AND REPLICATE('0', 20 - LEN(REPLACE(REPLACE(RTRIM(LTRIM(A2_BANCO))		, '.', ''), '-', ''))) + REPLACE(REPLACE(RTRIM(LTRIM(A2_BANCO))		, '.', ''), '-', '') = " + ValToSQL(PADL(Replace(Replace(AllTrim(cBanco)		, ".", Space(0)), "-", Space(0)), 20, '0'))
		cSQL += " 		AND REPLICATE('0', 20 - LEN(REPLACE(REPLACE(RTRIM(LTRIM(A2_AGENCIA))	, '.', ''), '-', ''))) + REPLACE(REPLACE(RTRIM(LTRIM(A2_AGENCIA))	, '.', ''), '-', '') = " + ValToSQL(PADL(Replace(Replace(AllTrim(cAgencia)		, ".", Space(0)), "-", Space(0)), 20, '0'))
		cSQL += " 		AND REPLICATE('0', 20 - LEN(REPLACE(REPLACE(RTRIM(LTRIM(A2_NUMCON))		, '.', ''), '-', ''))) + REPLACE(REPLACE(RTRIM(LTRIM(A2_NUMCON))	, '.', ''), '-', '') = " + ValToSQL(PADL(Replace(Replace(AllTrim(cConta)		, ".", Space(0)), "-", Space(0)), 20, '0'))
		cSQL += " 		AND SA2.D_E_L_E_T_ = '' "
		cSQL += " 	) "

		cSQL += " AND EA_FORNECE = "+ ValToSQL(cCodFor)
		cSQL += " AND EA_CART = 'P' "
		cSQL += " AND EA_DATABOR BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
		cSQL += " AND SEA.D_E_L_E_T_ = '' "
		cSQL += " AND SE2.D_E_L_E_T_ = '' "

		If nCount < Len(aEmp)

			cSQL += " UNION ALL "

		EndIf

	Next

	cSQL += " ) AS TMP "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->VALOR

//	EndIf

Return(nRet)


Method GetRecMan() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC = '' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_LOTE = '' "
	cSQL += " AND E5_RECPAG = 'R' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagAntChe() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPODOC = 'PA' "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_NUMCHEQ <> '' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagDarf_PA() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR * -1 AS VALOR "
	cSQL += " FROM "+ RetFullName("SE5", ::cCompany)
	cSQL += " WHERE E5_TIPO NOT IN ('', 'PA') "
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_CLIFOR = 'DARF' "
	cSQL += " AND E5_LOTE = '' "
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_NUMCHEQ = '' "
	cSQL += " AND E5_DTDISPO BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetPagFun() Class TComposicaoSaldoFinanceiroEmpresa

	Local lExist    := .F.
	Local cSQL      := ""
	Local cQry      := ""
	Local cBankData := ""

	/*cBankData := Alltrim(cBanco) + Alltrim(cAgencia) + Alltrim(cConta)
	cBankData := Replace(cBankData, ".", Space(0))
	cBankData := Replace(cBankData, "-", Space(0))

	// Controle de pagamento de funcionarios
	If (::cCompany == "01" .And. cBankData == "00134312550973") .Or. ; // Folha de pagamento da Biancogress somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.097-3
	(::cCompany == "05" .And. cBankData == "0013431256669") .Or. ; // Folha de pagamento da Incesa somente sera executado para o banco do brasil na agencia: 34312 e conta: 5.666-9
	(::cCompany == "06" .And. cBankData == "00134312550981") .Or. ; // Folha de pagamento da JK somente sera executado para o banco do brasil na agencia: 34312 e conta: 55.098-1
	(::cCompany == "07" .And. cBankData == "0013431252868") .Or. ; // Folha de pagamento da LM somente sera executado para o banco do brasil na agencia: 34312 e conta: 52868
	(::cCompany == "11" .And. cBankData == "0013431253295") .Or. ; // Folha de pagamento da SP300 somente sera executado para o banco do brasil na agencia: 34312 e conta: 53295
	(::cCompany == "12" .And. cBankData == "0013431254968") .Or. ; // Folha de pagamento da ST Gestão somente sera executado para o banco do brasil na agencia: 34312 e conta: 54968
	(::cCompany == "13" .And. cBankData == "0013431254666") .Or. ; // Folha de pagamento da Mundi somente sera executado para o banco do brasil na agencia: 34312 e conta: 54666
	(::cCompany == "14" .And. cBankData == "001343148755") // Folha de pagamento da Vitcer somente sera executado para o banco do brasil na agencia: 3431 e conta: 48755
	*/
		cQry := GetNextAlias()

		iF (::cCompany == "01")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '55.097-3' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "05")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '5.666-9' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "06")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '55.098-1' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "07")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '52868' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "11")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '53295' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "12")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '54968' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "13")
			cSQL := " SELECT '001' BANCO,  '34312' AGENCIA, '54666' CONTA, E2_VALOR *-1  "
			lExist := .T.
		ElseiF (::cCompany == "14")
			cSQL := " SELECT '001' BANCO,  '3431' AGENCIA, '48755' CONTA, E2_VALOR *-1  "
			lExist := .T.
		EndIf

		If lExist

			cSQL += " FROM "+ RetFullName("SE2", ::cCompany)
			cSQL += " WHERE (E2_TIPO IN ('FOL', 'FER') OR (E2_TIPO IN ('RES', 'ADI', '132', 'INS', '131') AND E2_FORNECE IN ('PARC13', 'RESCIS', 'EMPRES', 'ADTOSL')))"
			cSQL += " AND E2_NUMBCO = '' "
			cSQL += " AND E2_NUMBOR = '' "
			cSQL += " AND E2_VENCREA BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
			cSQL += " AND D_E_L_E_T_ = '' "

			cSQL += " UNION ALL "

		EndIf

		Return cSQL


Method GetPagDebAuto() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""

	cSQL := " SELECT ZK1_BANCO BANCO, ZK1_AGENCI AGENCIA, ZK1_CONTA CONTA, E2_VALOR * -1 AS VALOR "
	cSQL += " FROM " + RetFullName("SE2", ::cCompany) + " SE2 "
	cSQL += " JOIN " + RetFullName("ZK1", ::cCompany) + " ZK1 "
	cSQL += " ON ZK1_CODREG = E2_YCDGREG "
	cSQL += " WHERE E2_VENCREA BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)
	cSQL += " AND SE2.D_E_L_E_T_ = '' "
	cSQL += " AND ZK1_FORMPG = '3' "
	cSQL += " AND (ZK1_CODEMP IN ('', " + ValToSQL(::cCompany) + ") AND ZK1_CODFIL IN ('', " + ValToSQL(cFilAnt) + "))"
	cSQL += " AND ZK1.D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

Return(cSQL)


Method GetLanMan() Class TComposicaoSaldoFinanceiroEmpresa
	Local cSQL := ""
	Local cEmp := If (::cCompany $ "01/05", ::cCompany, "07")

	cSQL := " SELECT BANCO, AGENCIA, CONTA, CASE WHEN SUBSTRING(UPPER(TIPO), 1, 1) = 'D' THEN VALOR * -1 ELSE VALOR END AS VALOR "
	cSQL += " FROM TBL_COMP_SALDO_" + cEmp
	cSQL += " WHERE DATA BETWEEN "+ ValToSQL(FirstDate(::dDate)) + " AND " + ValToSQL(::dDate)

Return(cSQL)