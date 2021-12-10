#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TLiberacaoFinanceiro
@author Wlysses Cerqueira (Facile)
@since 20/05/2019
@project Automação Financeira
@version 1.0
@description Classe com regras de negocio da tela de liberacao financeira
@type class
/*/

Class TLiberacaoFinanceiro From TAFAbStractClass

	Data cChk // Imagem de marcacao
	Data cUnChk // Imagem de marcacao

	Data lFinalizados
	Data lSolicitante
	Data lAprovador
	Data lFinanceiro
	Data cCcClaVL

	Data lReceber
	Data lPagar

	Data cCliExc
	Data cVencrDe
	Data cVencrAte
	Data cNumDe
	Data cNumAte
	Data cPrefDe
	Data cPrefAte
	Data cTipoDe
	Data cTipoAte
	Data cParcDe
	Data cParcAte
	Data cForneceDe
	Data cForneceAte
	Data cLojaDe
	Data cLojaAte

	Data cErro

	Method New() ConStructor

	Method GDFieldData(lReceber, lPagar)

	Method GetQueryReceber()
	Method GetQueryPagar()

	Method SetPergLC(cYesNo)
	Method GetErrorLog(aError)
	Method Baixar(nValor, cBanco, cAgencia, cConta)

EndClass


Method New() Class TLiberacaoFinanceiro

	_Super:New()

	::cCliExc := GetNewPar("MV_YAPICEX", "000481|005885|999999|022551|026423|026308|007871|004536|010083|008615|010064|025633|025634|025704|018410|014395|001042")
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"

	::lFinalizados := .F.
	::lSolicitante := .F.
	::lAprovador := .F.
	::lFinanceiro := .F.
	::cCcClaVL := ""

	::lReceber := .F.
	::lPagar := .F.

	::cNumDe := Space(TamSx3("E2_NUM")[1])
	::cNumAte := Space(TamSx3("E2_NUM")[1])
	::cVencrDe := StoD("  /  /  ")
	::cVencrAte := StoD("  /  /  ")
	::cPrefDe := Space(TamSx3("E2_PREFIXO")[1])
	::cPrefAte := Space(TamSx3("E2_PREFIXO")[1])
	::cTipoDe := Space(TamSx3("E2_TIPO")[1])
	::cTipoAte := Space(TamSx3("E2_TIPO")[1])
	::cParcDe := Space(TamSx3("E2_PARCELA")[1])
	::cParcAte := Space(TamSx3("E2_PARCELA")[1])
	::cForneceDe := Space(TamSx3("E2_FORNECE")[1])
	::cForneceAte := Space(TamSx3("E2_FORNECE")[1])
	::cLojaDe := Space(TamSx3("E2_LOJA")[1])
	::cLojaAte := Space(TamSx3("E2_LOJA")[1])

	::cErro := ""

Return()

Method GetQueryReceber() Class TLiberacaoFinanceiro

	Local cSQL := ""
	Local cStatus := ""
	Local cUserLog := RetCodUsr()

	If ::lAprovador

		cStatus += If(Empty(cStatus), "", "/") + "2"

		If ::lFinalizados

			cStatus += If(Empty(cStatus), "", "/") + "4/5"

		EndIf

	EndIf

	If ::lSolicitante

		cStatus += If(Empty(cStatus), "", "/") + "2/3"

		If ::lFinalizados

			cStatus += If(Empty(cStatus), "", "/") + "4/5"

		EndIf

	EndIf

	If ::lFinanceiro

		cStatus += If(Empty(cStatus), "", "/") + "2/3"

		If ::lFinalizados

			cStatus += If(Empty(cStatus), "", "/") + "4/5"

		EndIf

	EndIf

	If ::lSolicitante .Or. ::lAprovador .Or. ::lFinanceiro

		If ::lSolicitante

			cSQL := " SELECT '1' ZL0_STATUS, "
			cSQL += " E1_NUM, "
			cSQL += " E1_PREFIXO, "
			cSQL += " E1_PARCELA, "
			cSQL += " E1_TIPO, "
			cSQL += " E1_NATUREZ, "
			cSQL += " E1_CLIENTE, "
			cSQL += " E1_LOJA, "
			cSQL += " E1_NOMCLI NOME, "
			cSQL += " E1_EMISSAO, "
			cSQL += " E1_VENCTO, "
			cSQL += " E1_VENCREA, "
			cSQL += " E1_VALOR, "
			cSQL += " E1_SALDO, "
			cSQL += " 0 ZL0_DESCON, "
			cSQL += " '' ZL0_OBSLIB, "
			cSQL += " '' ZL0_ITEMD, "
			cSQL += " '' ZL0_DEBITO, "
			cSQL += " '' ZL0_CLVLDB, "
			cSQL += " '' ZL0_CCD, "
			cSQL += " '' ZL0_CTRVER "

			cSQL += " FROM " + RetSQLName("SE1") + " SE1 "
			cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))

			cSQL += " AND E1_SALDO > 0 "
			//cSQL += " AND E1_NUMBOR = '' "
			cSQL += " AND E1_YBLQ IN ('', 'XX') "
			//cSQL += " AND E1_TIPO NOT IN ('BOL', 'NCC', 'NDC', 'RA') " -- ticket 21762

			//Ticket 28366 - titulos do tipo BOL devem ser incluidos na selação, solicitação Nadine.
			cSQL += " AND E1_TIPO NOT IN ('NCC', 'RA') "
			cSQL += " AND E1_CLIENTE NOT IN " + FormatIn(::cCliExc, "|")

			cSQL += " AND E1_CLIENTE	BETWEEN " + ValToSQL(::cForneceDe)	+ " AND " + ValToSQL(::cForneceAte)
			cSQL += " AND E1_LOJA		BETWEEN " + ValToSQL(::cLojaDe)		+ " AND " + ValToSQL(::cLojaAte)
			cSQL += " AND E1_NUM 		BETWEEN " + ValToSQL(::cNumDe)		+ " AND " + ValToSQL(::cNumAte)
			cSQL += " AND E1_PREFIXO 	BETWEEN " + ValToSQL(::cPrefDe)		+ " AND " + ValToSQL(::cPrefAte)
			cSQL += " AND E1_PARCELA 	BETWEEN " + ValToSQL(::cParcDe)		+ " AND " + ValToSQL(::cParcAte)
			cSQL += " AND E1_TIPO 		BETWEEN " + ValToSQL(::cTipoDe)		+ " AND " + ValToSQL(::cTipoAte)
			cSQL += " AND E1_VENCREA	BETWEEN " + ValToSQL(::cVencrDe)	+ " AND " + ValToSQL(::cVencrAte)

			cSQL += " AND NOT EXISTS
			cSQL += " ( "
			cSQL += " 	SELECT * FROM " + RetSQLName("ZL0") + " ZL0 "
			cSQL += " 	WHERE ZL0_FILIAL = " + ValToSQL(xFilial("ZL0"))
			cSQL += "		  AND ZL0_CODEMP = " + ValToSQL(cEmpAnt)
			cSQL += " 		  AND ZL0_CODFIL = " + ValToSQL(cFilAnt)
			cSQL += " 		  AND ZL0_CART 	 = 'R' "
			cSQL += " 		  AND ZL0_PREFIX = E1_PREFIXO "
			cSQL += " 		  AND ZL0_NUM	 = E1_NUM "
			cSQL += " 		  AND ZL0_PARCEL = E1_PARCELA "
			cSQL += " 		  AND ZL0_TIPO 	 = E1_TIPO "
			cSQL += " 		  AND ZL0_CLIFOR = E1_CLIENTE "
			cSQL += " 		  AND ZL0_LOJA   = E1_LOJA "
			cSQL += " 		  AND ZL0_STATUS IN ( '2', '3' ) "
			cSQL += " 	AND ZL0.D_E_L_E_T_   = '' "
			cSQL += " ) "

			cSQL += " AND SE1.D_E_L_E_T_ = '' "

			//|DESATIVADO REMOÇÃO DOS TITULOS FIDCS |
			// cSQL += " AND NOT exists(															"
			// cSQL += " select 1  from "+ RetSQLName("SA6") + " SA6								"
			// cSQL += " where									 									"
			// cSQL += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
			// cSQL += " 	AND A6_COD			= SE1.E1_PORTADO 									"
			// cSQL += " 	AND A6_AGENCIA		= SE1.E1_AGEDEP 									"
			// cSQL += " 	AND A6_NUMCON		= SE1.E1_CONTA 										"
			// cSQL += " 	AND SA6.D_E_L_E_T_	= ''												"
			// cSQL += " 	AND SA6.A6_YTPINTB	= '1'												"
			// cSQL += " )																			"


		EndIf

		If ::lAprovador .Or. ::lFinanceiro .Or. ::lSolicitante

			cSQL += If(Empty(cSQL), " ", " UNION ")

			cSQL += " SELECT ZL0_STATUS, "
			cSQL += " ZL0_NUM E1_NUM, "
			cSQL += " ZL0_PREFIX E1_PREFIXO, "
			cSQL += " ZL0_PARCEL E1_PARCELA, "
			cSQL += " ZL0_TIPO E1_TIPO, "
			cSQL += " E1_NATUREZ, "
			cSQL += " ZL0_CLIFOR E1_CLIENTE, "
			cSQL += " ZL0_LOJA E1_LOJA, "
			cSQL += " E1_NOMCLI NOME, "
			cSQL += " ZL0_EMISSA E1_EMISSAO, "
			cSQL += " ZL0_VENCTO E1_VENCTO, "
			cSQL += " ZL0_VENCRE E1_VENCREA, "
			cSQL += " ZL0_VALOR E1_VALOR, "
			cSQL += " E1_SALDO, "
			cSQL += " ZL0_DESCON, "
			cSQL += " ZL0_OBSLIB, "
			cSQL += " ZL0_ITEMD, "
			cSQL += " ZL0_DEBITO, "
			cSQL += " ZL0_CLVLDB, "
			cSQL += " ZL0_CCD, "
			cSQL += " ZL0_CTRVER "
			cSQL += " FROM " + RetSQLName("ZL0") + " ZL0 "

			cSQL += " JOIN " + RetSQLName("SE1") + " SE1 "
			cSQL += " ON "
			cSQL += " ( "
			cSQL += "		E1_FILIAL = " + ValToSQL(xFilial("SE1"))
			cSQL += " 		AND ZL0_PREFIX = E1_PREFIXO "
			cSQL += " 		AND ZL0_NUM	 = E1_NUM "
			cSQL += " 		AND ZL0_PARCEL = E1_PARCELA "
			cSQL += " 		AND ZL0_TIPO 	 = E1_TIPO "
			cSQL += " 		AND ZL0_CLIFOR = E1_CLIENTE "
			cSQL += " 		AND ZL0_LOJA   = E1_LOJA "
			//cSQL += " 		AND ZL0_STATUS <> '4' "
			cSQL += " 		AND SE1.D_E_L_E_T_   = '' "
			cSQL += " ) "

			cSQL += " WHERE ZL0.D_E_L_E_T_ = '' AND ZL0_STATUS IN " + FormatIn(cStatus, "/")
			cSQL += " AND ZL0_CART = 'R' "
			cSQL += " AND ZL0_CODEMP = " + ValToSQL(cEmpAnt)
			cSQL += " AND ZL0_CODFIL = " + ValToSQL(cFilAnt)


			If ::lSolicitante

				cSQL += " AND ZL0_CLIFOR	BETWEEN " + ValToSQL(::cForneceDe)	+ " AND " + ValToSQL(::cForneceAte)
				cSQL += " AND ZL0_LOJA		BETWEEN " + ValToSQL(::cLojaDe)		+ " AND " + ValToSQL(::cLojaAte)
				cSQL += " AND ZL0_NUM 		BETWEEN " + ValToSQL(::cNumDe)		+ " AND " + ValToSQL(::cNumAte)
				cSQL += " AND ZL0_PREFIX 	BETWEEN " + ValToSQL(::cPrefDe)		+ " AND " + ValToSQL(::cPrefAte)
				cSQL += " AND ZL0_PARCEL 	BETWEEN " + ValToSQL(::cParcDe)		+ " AND " + ValToSQL(::cParcAte)
				cSQL += " AND ZL0_TIPO 		BETWEEN " + ValToSQL(::cTipoDe)		+ " AND " + ValToSQL(::cTipoAte)
				cSQL += " AND E1_VENCREA	BETWEEN " + ValToSQL(::cVencrDe)	+ " AND " + ValToSQL(::cVencrAte)

			EndIf

			If ::lAprovador

				If !FWIsAdmin(__cUserID)

					//cSQL += " AND RTRIM(LTRIM(ZL0_CCD)) + SUBSTRING(ZL0_CLVLDB, 1, 1) IN " + FormatIn(::cCcClaVL, "|")
					cSQL += " AND EXISTS 	(

					cSQL += " SELECT 1 "
					cSQL += " from  " + RetSQLName("ZDK") +  " ZDK "
					cSQL += " where LTRIM(RTRIM(ZDK.ZDK_CLVLR))  = ZL0.ZL0_CLVLDB "
					cSQL += " AND  LTRIM(RTRIM(ZDK.ZDK_CCONTA))  = ZL0.ZL0_DEBITO "
					cSQL += " AND ZDK.ZDK_APROVA = '"+cUserLog+"' or (ZDK.ZDK_APROVT = '"+cUserLog+"' and  ZDK.ZDK_DTAPTF >= convert(varchar, getdate(), 112) ) "
					cSQL += " AND ZL0_DESCON  BETWEEN  ZDK.ZDK_VLAPIN AND ZDK.ZDK_VLAPFI  "
					cSQL += " AND ZDK.ZDK_STATUS =  'A' "
					cSQL += " AND ZDK.D_E_L_E_T_ = '' "

					cSQL += " ) "

				EndIf

			EndIf

		EndIf

		cSQL += If(Empty(cSQL), " ", " UNION ")

		cSQL += " SELECT '2' ZL0_STATUS, "
		cSQL += " E1_NUM, "
		cSQL += " E1_PREFIXO, "
		cSQL += " E1_PARCELA, "
		cSQL += " E1_TIPO, "
		cSQL += " E1_NATUREZ, "
		cSQL += " E1_CLIENTE, "
		cSQL += " E1_LOJA, "
		cSQL += " E1_NOMCLI NOME, "
		cSQL += " E1_EMISSAO, "
		cSQL += " E1_VENCTO, "
		cSQL += " E1_VENCREA, "
		cSQL += " E1_VALOR, "
		cSQL += " E1_SALDO, "
		cSQL += " E1_YVLDESC ZL0_DESCON, "
		cSQL += " CASE WHEN E1_YBLQ = '01' THEN 'PA' WHEN E1_YBLQ = '02' THEN 'DESCONTO' ELSE '' END ZL0_OBSLIB, "
		cSQL += " '' ZL0_ITEMD, "
		cSQL += " '' ZL0_DEBITO, "
		cSQL += " '' ZL0_CLVLDB, "
		cSQL += " '' ZL0_CCD, "
		cSQL += " '' ZL0_CTRVER  "
		cSQL += " FROM "+ RetSQLName("SE1") + " SE1 "
		cSQL += " WHERE E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
		cSQL += " AND (E1_YBLQ <> 'XX' AND E1_YBLQ <> '') "
		//cSQL += " AND E1_YOBSLIB = '' "
		//cSQL += " AND E1_NUMBOR = '' "
		//cSQL += " AND E1_TIPO NOT IN ('BOL', 'NCC', 'NDC', 'RA') " -- ticket 21762

		//Ticket 28366 - titulos do tipo BOL devem ser incluidos na selação, solicitação Nadine.
		cSQL += " AND E1_TIPO NOT IN ('NCC', 'RA') "
		cSQL += " AND E1_CLIENTE NOT IN " + FormatIn(::cCliExc, "|")
		cSQL += " AND E1_CLIENTE	BETWEEN " + ValToSQL(::cForneceDe)	+ " AND " + ValToSQL(::cForneceAte)
		cSQL += " AND E1_LOJA		BETWEEN " + ValToSQL(::cLojaDe)		+ " AND " + ValToSQL(::cLojaAte)
		cSQL += " AND E1_NUM 		BETWEEN " + ValToSQL(::cNumDe)		+ " AND " + ValToSQL(::cNumAte)
		cSQL += " AND E1_PREFIXO 	BETWEEN " + ValToSQL(::cPrefDe)		+ " AND " + ValToSQL(::cPrefAte)
		cSQL += " AND E1_PARCELA 	BETWEEN " + ValToSQL(::cParcDe)		+ " AND " + ValToSQL(::cParcAte)
		cSQL += " AND E1_TIPO 		BETWEEN " + ValToSQL(::cTipoDe)		+ " AND " + ValToSQL(::cTipoAte)
		cSQL += " AND E1_VENCREA	BETWEEN " + ValToSQL(::cVencrDe)	+ " AND " + ValToSQL(::cVencrAte)
		cSQL += " AND E1_SALDO > 0 "
		cSQL += " AND SE1.D_E_L_E_T_ = '' "

		//|DESATIVADO REMOÇÃO DOS TITULOS FIDCS |
		// cSQL += " AND NOT exists(															"
		// cSQL += " select 1  from "+ RetSQLName("SA6") + " SA6								"
		// cSQL += " where									 									"
		// cSQL += " 	A6_FILIAL			= '"+xFilial("SA6")+"'	 							"
		// cSQL += " 	AND A6_COD			= SE1.E1_PORTADO 									"
		// cSQL += " 	AND A6_AGENCIA		= SE1.E1_AGEDEP 									"
		// cSQL += " 	AND A6_NUMCON		= SE1.E1_CONTA 										"
		// cSQL += " 	AND SA6.D_E_L_E_T_	= ''												"
		// cSQL += " 	AND SA6.A6_YTPINTB	= '1'												"
		// cSQL += " )																			"


		cSQL += " AND NOT EXISTS
		cSQL += " ( "
		cSQL += " 	SELECT * FROM " + RetSQLName("ZL0") + " ZL0 "
		cSQL += " 	WHERE ZL0_FILIAL = " + ValToSQL(xFilial("ZL0"))
		cSQL += "		  AND ZL0_CODEMP = " + ValToSQL(cEmpAnt)
		cSQL += " 		  AND ZL0_CODFIL = " + ValToSQL(cFilAnt)
		cSQL += " 		  AND ZL0_CART 	 = 'R' "
		cSQL += " 		  AND ZL0_PREFIX = E1_PREFIXO "
		cSQL += " 		  AND ZL0_NUM	 = E1_NUM "
		cSQL += " 		  AND ZL0_PARCEL = E1_PARCELA "
		cSQL += " 		  AND ZL0_TIPO 	 = E1_TIPO "
		cSQL += " 		  AND ZL0_CLIFOR = E1_CLIENTE "
		cSQL += " 		  AND ZL0_LOJA   = E1_LOJA "
		cSQL += " 	AND ZL0.D_E_L_E_T_   = '' "
		cSQL += " ) "

		cSQL += " ORDER BY 2, 3, 4 , 5, 6, 7 "

	EndIf

Return(cSQL)

Method GetQueryPagar() Class TLiberacaoFinanceiro

	Local cSQL := ""
	Local cStatus := ""


	If ::lAprovador

		cStatus += If(Empty(cStatus), "", "/") + "2"

		If ::lFinalizados

			cStatus += If(Empty(cStatus), "", "/") + "3/4/5"

		EndIf

	EndIf

	If ::lAprovador

		If ::lAprovador

			cSQL += If(Empty(cSQL), " ", " UNION ")

			cSQL += " SELECT ZL0_STATUS, "
			cSQL += " ZL0_NUM E2_NUM, "
			cSQL += " ZL0_PREFIX E2_PREFIXO, "
			cSQL += " ZL0_PARCEL E2_PARCELA, "
			cSQL += " ZL0_TIPO E2_TIPO, "
			cSQL += " E2_NATUREZ, "
			cSQL += " ZL0_CLIFOR E2_FORNECE, "
			cSQL += " ZL0_LOJA E2_LOJA, "
			cSQL += " E2_NOMFOR NOME, "
			cSQL += " ZL0_EMISSA E2_EMISSAO, "
			cSQL += " ZL0_VENCTO E2_VENCTO, "
			cSQL += " ZL0_VENCRE E2_VENCREA, "
			cSQL += " ZL0_VALOR E2_VALOR, "
			cSQL += " E2_SALDO, "
			cSQL += " ZL0_OBSLIB "
			cSQL += " FROM " + RetSQLName("ZL0") + " ZL0 "

			cSQL += " JOIN " + RetSQLName("SE2") + " SE2 "
			cSQL += " ON "
			cSQL += " ( "
			cSQL += "		E2_FILIAL = " + ValToSQL(xFilial("SE2"))
			cSQL += " 		AND ZL0_PREFIX = E2_PREFIXO "
			cSQL += " 		AND ZL0_NUM	 = E2_NUM "
			cSQL += " 		AND ZL0_PARCEL = E2_PARCELA "
			cSQL += " 		AND ZL0_TIPO 	 = E2_TIPO "
			cSQL += " 		AND ZL0_CLIFOR = E2_FORNECE "
			cSQL += " 		AND ZL0_LOJA   = E2_LOJA "
			//cSQL += " 		AND ZL0_STATUS <> '4' "
			cSQL += " 		AND SE2.D_E_L_E_T_   = '' "
			cSQL += " ) "

			cSQL += " WHERE ZL0.D_E_L_E_T_ = '' AND ZL0_STATUS IN " + FormatIn(cStatus, "/")
			cSQL += " AND ZL0_CODEMP = " + ValToSQL(cEmpAnt)
			cSQL += " AND ZL0_CODFIL = " + ValToSQL(cFilAnt)
			cSQL += " AND ZL0_CART 	 = 'P' "

		EndIf

		cSQL += If(Empty(cSQL), " ", " UNION ")

		cSQL += " SELECT '2' ZL0_STATUS, "
		cSQL += " E2_NUM, "
		cSQL += " E2_PREFIXO, "
		cSQL += " E2_PARCELA, "
		cSQL += " E2_TIPO, "
		cSQL += " E2_NATUREZ, "
		cSQL += " E2_FORNECE, "
		cSQL += " E2_LOJA, "
		cSQL += " E2_NOMFOR NOME, "
		cSQL += " E2_EMISSAO, "
		cSQL += " E2_VENCTO, "
		cSQL += " E2_VENCREA, "
		cSQL += " E2_VALOR, "
		cSQL += " E2_SALDO, "
		cSQL += " CASE WHEN E2_YBLQ = '01' THEN 'PA' WHEN E2_YBLQ = '02' THEN 'DESCONTO' ELSE '' END ZL0_OBSLIB "
		cSQL += " FROM "+ RetSQLName("SE2") + " SE2 "
		cSQL += " WHERE E2_FILIAL = "+ ValToSQL(xFilial("SE2"))
		cSQL += " AND (E2_YBLQ <> 'XX' AND E2_YBLQ <> '') "
		cSQL += " AND E2_TIPO <> 'PA' "
		//cSQL += " AND E2_YOBSLIB = '' "
		//cSQL += " AND E2_NUMBOR = '' "
		cSQL += " AND E2_SALDO > 0 "
		cSQL += " AND SE2.D_E_L_E_T_ = '' "

		cSQL += " AND NOT EXISTS
		cSQL += " ( "
		cSQL += " 	SELECT * FROM " + RetSQLName("ZL0") + " ZL0 "
		cSQL += " 	WHERE ZL0_FILIAL = " + ValToSQL(xFilial("ZL0"))
		cSQL += "		  AND ZL0_CODEMP = " + ValToSQL(cEmpAnt)
		cSQL += " 		  AND ZL0_CODFIL = " + ValToSQL(cFilAnt)
		cSQL += " 		  AND ZL0_CART 	 = 'P' "
		cSQL += " 		  AND ZL0_PREFIX = E2_PREFIXO "
		cSQL += " 		  AND ZL0_NUM	 = E2_NUM "
		cSQL += " 		  AND ZL0_PARCEL = E2_PARCELA "
		cSQL += " 		  AND ZL0_TIPO 	 = E2_TIPO "
		cSQL += " 		  AND ZL0_CLIFOR = E2_FORNECE "
		cSQL += " 		  AND ZL0_LOJA   = E2_LOJA "
		cSQL += " 	AND ZL0.D_E_L_E_T_   = '' "
		cSQL += " ) "

		cSQL += " ORDER BY 2, 3, 4 , 5, 6, 7 "

	EndIf

Return(cSQL)

Method GDFieldData(lReceber, lPagar) Class TLiberacaoFinanceiro

	Local aRet := {}
	Local cSQL := ""
	Local cStatus := ""
	Local cQry := GetNextAlias()

	DBSelectArea("ZL0")

	If lReceber

		cSQL := ::GetQueryReceber()

	ElseIf lPagar

		cSQL := ::GetQueryPagar()

	EndIf

	If ! Empty(cSQL)

		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(Eof())

			cStatus := "" // 1=Normal;2=Aguardando aprov;3=Aprovado;4=Rejeitado;5=Finalizado

			If (cQry)->ZL0_STATUS == "1"

				cStatus := "BR_VERDE"

			ElseIf (cQry)->ZL0_STATUS == "2"

				cStatus := "BR_AMARELO"

			ElseIf (cQry)->ZL0_STATUS == "3"

				cStatus := "BR_AZUL"

			ElseIf (cQry)->ZL0_STATUS == "4"

				cStatus := "BR_VERMELHO"

			ElseIf (cQry)->ZL0_STATUS == "5"

				cStatus := "BR_PRETO"

			EndIf

			If lReceber

				aAdd(aRet, { ::cUnChk,;
					cStatus,;
					(cQry)->E1_NUM,;
					(cQry)->E1_PREFIXO,;
					(cQry)->E1_PARCELA,;
					(cQry)->E1_TIPO,;
					(cQry)->E1_NATUREZ,;
					(cQry)->E1_CLIENTE,;
					(cQry)->E1_LOJA,;
					(cQry)->NOME,;
					STOD((cQry)->E1_EMISSAO),;
					STOD((cQry)->E1_VENCTO),;
					STOD((cQry)->E1_VENCREA),;
					(cQry)->E1_VALOR,;
					(cQry)->E1_SALDO,;
					(cQry)->ZL0_DESCON,;
					If(Empty((cQry)->ZL0_CLVLDB), Space(TAMSX3("ZL0_CLVLDB")[1]), (cQry)->ZL0_CLVLDB),;
						If(Empty((cQry)->ZL0_CCD), Space(TAMSX3("ZL0_CCD")[1]), (cQry)->ZL0_CCD),;
							If(Empty((cQry)->ZL0_ITEMD), Space(TAMSX3("ZL0_ITEMD")[1]), (cQry)->ZL0_ITEMD),;
								If(Empty((cQry)->ZL0_DEBITO), Space(TAMSX3("ZL0_DEBITO")[1]), (cQry)->ZL0_DEBITO),;
									If(Empty((cQry)->ZL0_CTRVER), Space(TAMSX3("ZL0_CTRVER")[1]), (cQry)->ZL0_CTRVER),;
										If(Empty((cQry)->ZL0_OBSLIB), Space(TAMSX3("ZL0_OBSLIB")[1]), (cQry)->ZL0_OBSLIB),;
											.F.})

									ElseIf lPagar

										aAdd(aRet, { ::cUnChk,;
											cStatus,;
											(cQry)->E2_NUM,;
											(cQry)->E2_PREFIXO,;
											(cQry)->E2_PARCELA,;
											(cQry)->E2_TIPO,;
											(cQry)->E2_NATUREZ,;
											(cQry)->E2_FORNECE,;
											(cQry)->E2_LOJA,;
											(cQry)->NOME,;
											STOD((cQry)->E2_EMISSAO),;
											STOD((cQry)->E2_VENCTO),;
											STOD((cQry)->E2_VENCREA),;
											(cQry)->E2_VALOR,;
											(cQry)->E2_SALDO,;
											(cQry)->ZL0_OBSLIB,;
											.F.})

									EndIf

									(cQry)->(DbSkip())

								EndDo

								(cQry)->(DbCloseArea())

							EndIf

							Return(aRet)

Method Baixar(nValor, cBanco, cAgencia, cConta) Class TLiberacaoFinanceiro

	Local aTit := {}
	Local cLogTxt := ""
	Local cMotBx := "NOR"
	Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	::SetPergLC(2)

	aAdd(aTit, {"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil})
	aAdd(aTit, {"E1_NUM"		, SE1->E1_NUM		, Nil})
	aAdd(aTit, {"E1_PARCELA"	, SE1->E1_PARCELA	, Nil})
	aAdd(aTit, {"E1_TIPO"		, SE1->E1_TIPO		, Nil})
	aAdd(aTit, {"AUTMOTBX"		, cMotBx			, Nil})
	aAdd(aTit, {"AUTBANCO"		, cBanco			, Nil})
	aAdd(aTit, {"AUTAGENCIA"	, cAgencia			, Nil})
	aAdd(aTit, {"AUTCONTA"		, cConta			, Nil})
	aAdd(aTit, {"AUTDTBAIXA"	, dDataBase			, Nil})
	aAdd(aTit, {"AUTDTCREDITO"	, dDataBase			, Nil})
	aAdd(aTit, {"AUTDESCONT"	, nValor			, Nil, .T.})
	aAdd(aTit, {"AUTJUROS"		, 0					, Nil, .T.})
	aAdd(aTit, {"AUTMULTA"		, 0					, Nil, .T.})
	aAdd(aTit, {"AUTACRESC"		, 0					, Nil, .T.})
	aAdd(aTit, {"AUTVALREC"		, 0					, Nil, .T.})

	::cErro := ""

	MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)

	If lMsErroAuto

		cLogTxt += ::GetErrorLog()

		::cErro := cLogTxt

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_TIT_INC"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Baixa Desconto: " + cLogTxt
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(Recno())

		::oLog:Insert()

	Else

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_TIT_INC"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Baixa desconto efetuada"
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("SE1")
		::oLog:nIDTab := SE1->(Recno())

		::oLog:Insert()

		If SE1->E1_PREFIXO = "JR" .And. SE1->E1_SALDO == 0

			oObjDepId:BaixaDepAntJR(.T.)

		ElseIf SE1->E1_PREFIXO = "JR"

			If MsgYesNo("Deseja prorrogar os titulos referentes?")

				oObjDepId:BaixaDepAntJR(.T.)

			EndIf

		EndIf

	EndIf

	::SetPergLC(1)

Return(!lMsErroAuto)

Method SetPergLC(cYesNo) Class TLiberacaoFinanceiro

	Local aPerg := {}

	Pergunte("FIN070", .F.,,,,, @aPerg)

	MV_PAR01 := cYesNo

	__SaveParam("FIN070", aPerg)

Return()

Method GetErrorLog() Class TLiberacaoFinanceiro

	Local cRet := ""
	Local nX := 1
	Local aError := GETAUTOGRLOG()

	For nX := 1 To Len(aError)

		cRet += aError[nX] + CRLF

	Next nX

Return(cRet)
