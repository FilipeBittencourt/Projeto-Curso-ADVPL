#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} TAFComprovantePagamento
@author Wlysses Cerqueira (Facile)
@since 28/02/2019
@project Automação Financeira
@version 1.0
@description Classe para efetuar baixa automatica de pagamentos
@type class
/*/

#DEFINE NPOSRECNO	1
#DEFINE NPOSIDCNAB	2
#DEFINE NPOSCHVAUT	3
#DEFINE NPOSMSG		4
#DEFINE NPOSVLD		5

Class TAFComprovantePagamento From LongClassName

	Data cFilePrint
	Data lImprimeGeral
	Data lPosicionado
	Data lFisa095
	Data lImpBoleto

	Data cLogo
	Data oPrint
	Data oSetup

	Data lDocTed
	Data lCredito
	Data lBoleto
	Data lGnre

	Data cAutentica
	Data cNomeEmp
	Data cCgcEmp
	Data cAgContEmp

	Data cNomFavore
	Data cCpfCnpjFa
	Data cNumPag
	Data cDataPag
	Data cAgenciaFa
	Data cContaFav
	Data cFinalidad
	Data cValorPag
	Data cObs
	Data cCodBarra
	Data cBanco
	Data cDtVenc
	Data cDataDoc
	Data cTipoDoc
	Data cNumDoc
	Data cCarteira
	Data cNossoNum
	Data cNf
	Data cDescAbat
	Data cOutrasDed
	Data cMoraMulta
	Data cJuros
	Data cOutrosAcr
	Data cValorCob
	Data cCodIdTr

	Data cGuia
	Data cCodReceita
	Data cCgcFor
	Data cReferencia
	Data cUf

	Data cCaminho
	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	Data cVencrDe
	Data cVencrAte
	Data cBorDe
	Data cBorAte
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
	Data dDtBaixa

	Method New() Constructor
	Method Load(lServer)
	Method Comprovante()
	Method ImprimeTodos()
	Method ProcessaTodos()
	Method GetQuery(lCabecalho, cWhere)
	Method Processa(cWhere, lFechaArq)
	Method Pergunte()
	Method Print()
	Method CreatePath()
	Method SetProperty()
	Method RetornoZK4()
	Method GetNameFile()

EndClass


Method New() Class TAFComprovantePagamento

	::oPrint := Nil

	::SetProperty()

	::cFilePrint := ""
	::lImprimeGeral := .F.
	::lPosicionado := IsInCallStack("FINA750") .Or. IsInCallStack("FINA050") .Or. IsInCallStack("FISA095")
	::lFisa095 := IsInCallStack("FISA095")
	::lImpBoleto := .F.

	::cName := "BAF016"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.

	::cVencrDe := StoD("  /  /  ")
	::cVencrAte := StoD("  /  /  ")
	::cBorDe := Space(TamSx3("E2_NUMBOR")[1])
	::cBorAte := PADR("", TamSx3("E2_NUMBOR")[1], "Z")
	::cNumDe := Space(TamSx3("E2_NUM")[1])
	::cNumAte := PADR("", TamSx3("E2_NUM")[1], "Z")
	::cPrefDe := Space(TamSx3("E2_PREFIXO")[1])
	::cPrefAte := PADR("", TamSx3("E2_PREFIXO")[1], "Z")
	::cTipoDe := Space(TamSx3("E2_TIPO")[1])
	::cTipoAte := PADR("", TamSx3("E2_TIPO")[1], "Z")
	::cParcDe := Space(TamSx3("E2_PARCELA")[1])
	::cParcAte := PADR("", TamSx3("E2_PARCELA")[1], "Z")
	::cForneceDe := Space(TamSx3("E2_FORNECE")[1])
	::cForneceAte := PADR("", TamSx3("E2_FORNECE")[1], "Z")
	::cLojaDe := Space(TamSx3("E2_LOJA")[1])
	::cLojaAte := PADR("", TamSx3("E2_LOJA")[1], "Z")

	::cCaminho := PadR("c:\temp", 60)

	If cEmpAnt == "01"

		::cLogo := "\system\logonfe01.bmp"

	ElseIf cEmpAnt == "05"

		::cLogo := "\system\logonfe05.bmp"

	ElseIf cEmpAnt == "06"

		::cLogo := "\system\lgrl06.bmp"

	ElseIf cEmpAnt == "14"

		::cLogo := "\system\logonfe14.bmp"

	ElseIf cEmpAnt == "13"

		::cLogo := "\system\logopri13.bmp"

	ElseIf cEmpAnt == "07"

		::cLogo := "\system\logonfe07_comprovante_pag.bmp"

	Else

		::cLogo := ""

	EndIf

Return()

Method GetNameFile() Class TAFComprovantePagamento

	Local cFile := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cDataIni	:= ""
	Local cData		:= ""

	If ::lImprimeGeral

		cDataIni	:= cvaltochar(DTOS(::dDtBaixa))

		cData		:= SubStr(cDataIni, 7,2)+'-'
		cData 		+= SubStr(cDataIni, 5,2)+'-'
		cData 		+= SubStr(cDataIni, 1,4)

		cSQL := " SELECT COUNT(*) TOT
		cSQL += " FROM ( "
		cSQL += " SELECT DISTINCT ZK4_IMPRES "
		cSQL += " FROM " + RetSQLName("ZK4") + " ZK4 "
		cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
		cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
		cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
		cSQL += " AND ZK4_TIPO = 'P' "
		//cSQL += " AND ZK4_IMPRES LIKE " + ValToSQL("%" + DTOS(::cVencrAte) + "%")
		cSQL += " AND ZK4_IMPRES LIKE " + ValToSQL("%" + cData + "%")
		cSQL += " AND ZK4.D_E_L_E_T_ = '' "
		cSQL += " ) TAB1 "

		TcQuery cSQL New Alias (cQry)

		DbSelectArea("ZK4")

		//old// cFile := cEmpAnt + cFilAnt + "_Comprovante_" + DTOS(::cVencrAte) + If((cQry)->TOT > 0, "_" + Soma1(cValToChar((cQry)->TOT)), "")

		cFile := cEmpAnt +'_'+cFilAnt + "_" + cData + If((cQry)->TOT > 0, "_" + Soma1(cValToChar((cQry)->TOT)), "")

		(cQry)->(DbCloseArea())

	Else

		cFile := "Comprovante_" + DTOS(MSDate()) + StrTran(Time(), ":", "")

	EndIf

Return(cFile)

Method CreatePath(lFWMSPrinter) Class TAFComprovantePagamento

	Local lRet := .T.
	Local nTam := 0
	Local cCaminho_ := ""

	::cCaminho := AllTrim(::cCaminho)

	cCaminho_ := ::cCaminho

	nTam := Len(::cCaminho)

	If SubStr(::cCaminho, nTam, 1) <> "\"

		If SubStr(::cCaminho, nTam , 1) == "/"

			::cCaminho := SubStr(::cCaminho, 1, nTam - 1) + "\"

		Else

			::cCaminho := ::cCaminho + "\"

		EndIf

	Else

		cCaminho_ := SubStr(::cCaminho, 1, nTam - 1)

	EndIf

	If ExistDir(AllTrim(UPPER(cCaminho_)))

		//Conout("TAFComprovantePagamento - Pasta " + cCaminho_ + " ok!")

	Else

		//Conout("TAFComprovantePagamento - Criando a pasta " + ::cCaminho)

		If MakeDir( AllTrim(::cCaminho),,.F. ) <> 0

			Conout("TAFComprovantePagamento - Erro ao criar pasta " + AllTrim(::cCaminho))

			lRet := .F.

		EndIf

	EndIf

Return(lRet)

Method SetProperty() Class TAFComprovantePagamento

	::lDocTed := .F.
	::lCredito := .F.
	::lBoleto := .F.
	::lGnre := .F.

	::cAutentica := ""
	::cNomeEmp := ""
	::cCgcEmp := ""
	::cAgContEmp := ""

	::cNomFavore := ""
	::cCpfCnpjFa := ""
	::cNumPag    := ""
	::cDataPag   := ""
	::cAgenciaFa := ""
	::cContaFav  := ""
	::cFinalidad := ""
	::cValorPag  := ""
	::cObs       := ""
	::cCodBarra  := ""
	::cBanco     := ""
	::cDtVenc    := ""
	::cDataDoc	 := ""
	::cTipoDoc   := ""
	::cNumDoc    := ""
	::cCarteira  := ""
	::cNossoNum  := ""
	::cNf        := ""
	::cDescAbat  := ""
	::cOutrasDed := ""
	::cMoraMulta := ""
	::cJuros	 := ""
	::cOutrosAcr := ""
	::cValorCob  := ""
	::cCodIdTr   := ""

	::cGuia		 := ""
	::cCodReceita:= ""
	::cCgcFor	 := ""
	::cReferencia:= ""
	::cUf		 := ""

Return()

Method ImprimeTodos() Class TAFComprovantePagamento

	If ::CreatePath()

		::ProcessaTodos()

	EndIf

Return()

Method ProcessaTodos() Class TAFComprovantePagamento

	Local cSQL := ""
	Local cWhere := ""
	Local aDtBaixa := {}
	Local nPos := 0
	Local cQry := GetNextAlias()
	Local nTotReg := 0
	Local nTotAtu := 0

	::lImprimeGeral := .T.

	//cSQL := " SELECT DISTINCT E2_VENCREA "
	//cSQL := " SELECT DISTINCT E2_BAIXA "

	//cWhere := " AND E2_IDCNAB IN (SELECT ZK4_IDCNAB FROM " + RetSQLName("ZK4") + " ZK4 WHERE ZK4_IDCNAB <> '' AND E2_IDCNAB = ZK4_IDCNAB AND ZK4_IMPRES = '' AND ZK4_TIPO = 'P' AND ZK4_CHVAUT <> '' AND ZK4.D_E_L_E_T_ = '') "

	cSQL += "SELECT DISTINCT "
	cSQL += "       ZK4_DTLIQ "
	cSQL += "FROM " + RetSqlName("ZK4") + " Z "
	cSQL += "WHERE  ZK4_FILIAL = " + ValToSQL(xFilial("ZK4")) + " AND "
	cSQL += "		ZK4_EMP  = " + ValToSql(cEmpAnt) + " AND "
	cSQL += "		ZK4_FIL  = " + ValToSql(cFilAnt) + " AND "
	cSQL += "		ZK4_TIPO = " + ValToSql("P") + " AND "
	cSQL += "       Z.D_E_L_E_T_ = '' AND "
	cSQL += "       ZK4_IDCNAB IN "
	cSQL += "           ( "
	cSQL += "               SELECT "
	cSQL += "                   E2_IDCNAB "

	cWhere += "                   AND E2_IDCNAB IN "
	cWhere += "                           ( "
	cWhere += "                               SELECT ZK4_IDCNAB "
	cWhere += "                               FROM " + RetSqlName("ZK4") + " ZK4 "
	cWhere += "                               WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cWhere += "									  AND ZK4_EMP  	   = " + ValToSql(cEmpAnt)
	cWhere += "									  AND ZK4_FIL  = " + ValToSql(cFilAnt)
	cWhere += "									  AND ZK4_TIPO = " + ValToSql("P")
	cWhere += "                                   AND ZK4_IDCNAB     <> '' "
	cWhere += "                                   AND ZK4_IDCNAB 	 = E2_IDCNAB "
	cWhere += "                                   AND ZK4_IMPRES     = '' "
	cWhere += "                                   AND ZK4_CHVAUT     <> '' "
	cWhere += "                                   AND ZK4.D_E_L_E_T_ = '' "
	cWhere += "                           ) "

	::cVencrDe	:= ""
	::cVencrAte	:= "ZZZZZZZZ"
	::dDtBaixa	:= "ZZZZZZZZ"

	cSQL += ::GetQuery(.F., cWhere)

	cSQL += "           ) "
	/*
	cSQL += "	AND NOT EXISTS  "
	cSQL += "	( "
	cSQL += "		SELECT *  "
	cSQL += "		FROM " + RetSqlName("ZK4") + " B ( NOLOCK ) "
	cSQL += "		WHERE B.ZK4_FILIAL = Z.ZK4_FILIAL "
	cSQL += "		AND B.ZK4_EMP = Z.ZK4_EMP "
	cSQL += "		AND B.ZK4_FIL = Z.ZK4_FIL "
	cSQL += "		AND B.ZK4_TIPO = Z.ZK4_TIPO "
	cSQL += "		AND B.ZK4_CHVAUT = Z.ZK4_CHVAUT "
	cSQL += "		AND B.ZK4_IMPRES <> '' "
	cSQL += "		AND B.D_E_L_E_T_ = '' "
	cSQL += "	) "
				*/
	TcQuery cSQL New Alias (cQry)

	nTotReg := Contar((cQry), "!Eof()")

	(cQry)->(DBGoTop())

	While !(cQry)->(Eof())

		nTotAtu++

		nPos := aScan(aDtBaixa, {|x| x == (cQry)->ZK4_DTLIQ})

		::dDtBaixa	:= STOD((cQry)->ZK4_DTLIQ)

		If nPos == 0

			aAdd(aDtBaixa, (cQry)->ZK4_DTLIQ)

			::Load()

		EndIf

		Conout("TAFComprovantePagamento - Processando comprovante " + cValToChar(nTotAtu) + "/" + cValToChar(nTotReg) + " - " + (cQry)->ZK4_DTLIQ)

		cWhere := "                   AND E2_IDCNAB IN "
		cWhere += "                           ( "
		cWhere += "                               SELECT ZK4_IDCNAB "
		cWhere += "                               FROM " + RetSqlName("ZK4") + " ZK4 "
		cWhere += "                               WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
		cWhere += "									  AND ZK4_EMP  	   = " + ValToSql(cEmpAnt)
		cWhere += "									  AND ZK4_FIL  = " + ValToSql(cFilAnt)
		cWhere += "									  AND ZK4_TIPO = " + ValToSql("P")
		cWhere += "                                   AND ZK4_IDCNAB     <> '' "
		cWhere += "                                   AND ZK4_IDCNAB 	 = E2_IDCNAB "
		cWhere += "                                   AND ZK4_IMPRES     = '' "
		cWhere += "                                   AND ZK4_CHVAUT     <> '' "
		cWhere += "                                   AND ZK4_DTLIQ 	 = " + ValToSql((cQry)->ZK4_DTLIQ)
		cWhere += "                                   AND ZK4.D_E_L_E_T_ = '' "
		cWhere += "                           ) "

		::Processa(cWhere)

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return()

Method Comprovante() Class TAFComprovantePagamento

	If ::lPosicionado

		If MsgYesNo("Deseja imprimir o comprovante do titulo posicionado?")

			::lPosicionado := .T.

		Else

			::lPosicionado := .F.

		EndIf

	EndIf

	If ::Pergunte()

		::Load(.T.)

		Processa( {|| ::Processa() }, "Aguarde...", "Gerando comprovantes...",.F.)

	EndIf

Return()

Method GetQuery(lCabecalho, cWhere) Class TAFComprovantePagamento

	Local cSQL := ""

	Default lCabecalho := .T.
	Default cWhere := ""

	If lCabecalho

		cSQL := " SELECT SE2.R_E_C_N_O_ RECNO_SE2 "

	EndIf

	cSQL += " FROM "+ RetSQLName("SE2") + " SE2 "
	cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))

	If ::lPosicionado

		If ::lFisa095

			If Empty(SF6->F6_CDBARRA)

				cSQL += " AND 1 = 2 "

			Else

				cSQL += " AND E2_CODBAR = " + ValToSQL(SF6->F6_CDBARRA)

			EndIf

		Else

			cSQL += " AND SE2.R_E_C_N_O_ = " + cValToChar(SE2->(Recno()))

		EndIf

	Else

		cSQL += " AND E2_FORNECE	BETWEEN " + ValToSQL(::cForneceDe)	+ " AND " + ValToSQL(::cForneceAte)
		cSQL += " AND E2_LOJA		BETWEEN " + ValToSQL(::cLojaDe)		+ " AND " + ValToSQL(::cLojaAte)
		cSQL += " AND E2_NUM 		BETWEEN " + ValToSQL(::cNumDe)		+ " AND " + ValToSQL(::cNumAte)
		cSQL += " AND E2_PREFIXO 	BETWEEN " + ValToSQL(::cPrefDe)		+ " AND " + ValToSQL(::cPrefAte)
		cSQL += " AND E2_NUMBOR 	BETWEEN " + ValToSQL(::cBorDe)		+ " AND " + ValToSQL(::cBorAte)
		cSQL += " AND E2_PARCELA 	BETWEEN " + ValToSQL(::cParcDe)		+ " AND " + ValToSQL(::cParcAte)
		cSQL += " AND E2_TIPO 		BETWEEN " + ValToSQL(::cTipoDe)		+ " AND " + ValToSQL(::cTipoAte)

		If !::lImprimeGeral

			cSQL += " AND E2_VENCREA	BETWEEN " + ValToSQL(::cVencrDe)	+ " AND " + ValToSQL(::cVencrAte)

		EndIf

		//cSQL += " AND E2_VENCREA	BETWEEN " + ValToSQL(::cVencrDe)	+ " AND " + ValToSQL(::cVencrAte)

	EndIf

	cSql += cWhere
	cSQL += " AND SE2.D_E_L_E_T_ = '' "

Return(cSQL)

Method Processa(cWhere, lFechaArq) Class TAFComprovantePagamento

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nTotReg := 0
	Local nTotAtu := 0
	Local cMsg := ""
	Local lAchou := .F.
	Local lXml := .F.
	Local nVlrPago := 0
	Local nW := 0
	Local aRetorno := {}
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaSX5 := SX5->(GetArea())
	Local aAreaSF6 := SF6->(GetArea())

	Default cWhere := ""
	Default lFechaArq := .T.

	cSQL += ::GetQuery(, cWhere)

	TcQuery cSQL New Alias (cQry)

	nTotReg := Contar((cQry), "!Eof()")

	Procregua(nTotReg + 1)

	(cQry)->(DBGoTop())

	DbSelectArea("SX5")
	SX5->(DBSetOrder(1)) // X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_

	DbSelectArea("SE2")

	DbSelectArea("SA2")
	SA2->(DBSetOrder(1)) // A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_

	While !(cQry)->(Eof())

		nTotAtu++

		IncProc()

		SE2->(DBGoto((cQry)->RECNO_SE2))

		SA2->(DBSeek(xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA)))

		::SetProperty()

		aRetorno := ::RetornoZK4()

		If ::lImpBoleto

			If Empty(SF6->F6_XMLENV)

				Conout(cEmpAnt + cFilAnt + " " + SF6->F6_NUMERO + " não contem XML")

			Else

				lXml := .T.

				Private PixelX := ::oPrint:nLogPixelX()
				Private PixelY := ::oPrint:nLogPixelY()
				Private lLote := .T.

				cCodbar_ := SF6->F6_CDBARRA
				cXml_ := SF6->F6_XMLENV
				cCtrl := SF6->F6_NUMCTRL
				oobjj := @::oPrint

				StaticCall(FISA119, ImpDetGnre, oobjj, cCodbar_, cXml_, cCtrl)

			EndIf

		EndIf

		For nW := 1 To Len(aRetorno)

			ZK4->(DBGoTo(aRetorno[nW][NPOSRECNO]))

			If !aRetorno[nW][NPOSVLD]

				cMsg += aRetorno[nW][NPOSMSG]

				If ::lImprimeGeral

					If !("REJEITADO" $ UPPER(cMsg))

						Conout("TAFComprovantePagamento - [ RECNO SE2 = " + cValTochar(SE2->(Recno())) + " RECNO ZK4 = " + cValTochar(ZK4->(Recno())) + " ]" + " - VERIFICAR NÃO IMPRESSÃO DO TITULO!" + " [ AUTENTICACAO: " + ZK4->ZK4_CHVAUT + " ]")

					EndIf

				EndIf

			Else

				Conout("TAFComprovantePagamento - [ RECNO SE2 = " + cValTochar(SE2->(Recno())) + " RECNO ZK4 = " + cValTochar(ZK4->(Recno())) + " ]" + " - OK!")

				SX5->(DBSeek(xFilial("SX5") + "05" + SE2->E2_TIPO))

				lAchou := .T.

				nVlrPago := If(ZK4->ZK4_VLPAG > 0, ZK4->ZK4_VLPAG, ZK4->ZK4_VLTOT)

				::cAutentica := ZK4->ZK4_CHVAUT
				::cNomeEmp   := Capital(AllTrim(SM0->M0_NOMECOM))
				::cCgcEmp	  := AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))
				::cAgContEmp := "Agência: " + ZK4->ZK4_AGENCI + " | Conta: " + ZK4->ZK4_CONTA

				::cNomFavore := ZK4->ZK4_FNOME
				::cCpfCnpjFa := If(Len(AllTrim(SA2->A2_CGC)) == 11, AllTrim(Transform(SA2->A2_CGC, "@R 999.999.999-99")), If(Len(AllTrim(SA2->A2_CGC)) == 14, AllTrim(Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")), ""))
				::cNumPag    := SE2->E2_NUMBOR
				::cDataPag   := DTOC(ZK4->ZK4_DTLIQ)
				::cAgenciaFa := If(Empty(ZK4->ZK4_FAGENC), "", ZK4->ZK4_FAGENC + "-" + ZK4->ZK4_FDVAGE)
				::cContaFav  := If(Empty(ZK4->ZK4_FCONTA), "", ZK4->ZK4_FCONTA + "-" + ZK4->ZK4_FDVCTA)
				::cValorPag  := AllTrim(Transform(nVlrPago, "@e 999,999,999.99"))
				::cValorCob  := AllTrim(Transform(nVlrPago + SE2->E2_CNABACR - SE2->E2_CNABDES, "@e 999,999,999.99"))
				::cObs       := ""
				::cCodBarra  := AllTrim(ZK4->ZK4_CODBAR)
				::cDtVenc    := DTOC(ZK4->ZK4_DTVENC)
				::cDataDoc	  := ""
				::cTipoDoc   := UPPER(SX5->X5_DESCRI)
				::cNumDoc    := SE2->E2_NUM
				::cCarteira  := ""
				::cNossoNum  := ZK4->ZK4_NOSNUM
				::cNf        := SE2->E2_NUM
				::cDescAbat  := AllTrim(Transform(ZK4->ZK4_VLABAT + ZK4->ZK4_VLDESC, "@e 999,999,999.99"))
				::cOutrasDed := AllTrim(Transform(SE2->E2_CNABDES, "@e 999,999,999.99"))
				::cMoraMulta := AllTrim(Transform(ZK4->ZK4_VLMULT, "@e 999,999,999.99"))
				::cJuros 	 := AllTrim(Transform(ZK4->ZK4_VLJURO, "@e 999,999,999.99"))
				::cOutrosAcr := AllTrim(Transform(SE2->E2_CNABACR, "@e 999,999,999.99"))
				::cCodIdTr   := "0"

				::cGuia 	 := ZK4->ZK4_IDGUIA

				If !EMPTY(ZK4->ZK4_CODREC)

					::cCodReceita := Transform(ZK4->ZK4_CODREC, "@R 99999-9")

				else

					::cCodReceita := U_BIA841A(.F.,.F.,.F.)

				ENdif

				::cCgcFor	 := U_BIA841A(,,.T.)
				::cCgcFor	 := If(Len(AllTrim(::cCgcFor)) == 11, AllTrim(Transform(::cCgcFor, "@R 999.999.999-99")), If(Len(AllTrim(::cCgcFor)) == 14, AllTrim(Transform(::cCgcFor, "@R 99.999.999/9999-99")), ""))
				::cReferencia:= Transform(ZK4->ZK4_PERREF, "@R 99/9999")
				::cUf		 := U_BIA841(,,ZK4->ZK4_CODUF)

				::lDocTed := If(Empty(::cCodBarra), If(ZK4->ZK4_BANCO <> ZK4->ZK4_FBANCO, .T., .F.), .F.)
				::lCredito := If(Empty(::cCodBarra), If(ZK4->ZK4_BANCO == ZK4->ZK4_FBANCO, .T., .F.), .F.)
				::lBoleto := If(! Empty(::cCodBarra) .And. Empty(::cGuia), .T., .F.)
				::lGnre := If(! Empty(::cCodBarra) .And. ! Empty(::cGuia), .T., .F.)

				::cFinalidad := If(::lCredito .Or. ::lDocTed, "CREDITO EM CONTA", "")

				::cBanco     := If(::lBoleto, SubStr(ZK4->ZK4_CODBAR, 1, 3), ZK4->ZK4_FBANCO)

				::oPrint:StartPage()
				::Print()
				::oPrint:EndPage()

				If ::lImprimeGeral

					RecLock("ZK4", .F.)
					ZK4->ZK4_IMPRES := ::cFilePrint
					ZK4->(MSUnLock())

				EndIf

			EndIf

		Next nW

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

	If lAchou .And. lFechaArq

		IncProc()

		::oPrint:Preview()

	EndIf

	If lFechaArq

		FreeObj(::oPrint)

		::oPrint := Nil

		::oSetup := Nil

	EndIf

	If ! Empty(cMsg)

		Aviso("ATENCAO", "Verifique os titulos abaixo: " + CRLF + cMsg, {"OK"},3)

	EndIf

	If nTotReg == 0

		If ::lPosicionado

			cMsg := "Não existe comprovante para o titulo posicionado!"

		Else

			cMsg := "Não existem comprovantes referente o filtro informado!"

		EndIf

		MsgAlert(cMsg, "ATENCAO")

	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSA2)
	RestArea(aAreaSX5)
	RestArea(aAreaSF6)

Return(lXml)

Method RetornoZK4() Class TAFComprovantePagamento

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aZK4 := {}
	Local aAux := {}
	Local nPos := 0
	Local nW := 0

	cSQL := " SELECT ZK4.R_E_C_N_O_ RECNO_ZK4 "
	cSQL += " FROM " + RetSQLName("ZK4") + " ZK4 "
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
	cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
	cSQL += " AND ZK4_TIPO = 'P' "

	If ::lImprimeGeral

		cSQL += " AND ( "
		cSQL += " 		( ZK4_IDCNAB = " + ValToSQL(SE2->E2_IDCNAB) + " AND ZK4_IDCNAB <> '' ) OR "
		cSQL += " 		( ZK4_CODBAR = " + ValToSQL(SE2->E2_CODBAR) + " AND ZK4_CODBAR <> '' ) "
		cSQL += " 	  ) "

		cSQL += " AND ZK4_IMPRES = '' "
		cSQL += " AND ZK4_DTLIQ = " + ValToSQL(::dDtBaixa)

	Else

		cSQL += " AND ( "
		cSQL += " 		( ZK4_IDCNAB = " + ValToSQL(SE2->E2_IDCNAB) + " AND ZK4_IDCNAB <> '' ) "

		If !"GNRESP" $ SE2->E2_FORNECE

			cSQL += " OR ( ZK4_CODBAR = " + ValToSQL(SE2->E2_CODBAR) + " AND ZK4_CODBAR <> '' ) "

		EndIf

		cSQL += " 	  ) "

	EndIf

	//cSQL += " AND ZK4_CHVAUT NOT LIKE " + ValToSQL("%REJEITADO%")
	cSQL += " AND ZK4_CHVAUT <> '' "
	cSQL += " AND ZK4.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	DbSelectArea("ZK4")

	While !(cQry)->(Eof())

		ZK4->(DBGoTo((cQry)->RECNO_ZK4))

		nPos := aScan(aZK4, {|x| x[NPOSIDCNAB] == ZK4->ZK4_IDCNAB .And. x[NPOSCHVAUT] == ZK4->ZK4_CHVAUT})

		If nPos == 0

			aAdd(aZK4, {ZK4->(Recno()), ZK4->ZK4_IDCNAB, ZK4->ZK4_CHVAUT, "", .F.})

		EndIf

		nPos := If(nPos == 0, Len(aZK4), nPos)

		If Empty(ZK4->ZK4_IDGUIA) // Outros pagamentos

			If Empty(ZK4->ZK4_CODBAR)

				aZK4[nPos][NPOSVLD] := .T. // Nao tem amarracao perfeita se o IDCNAB esta duplicado, quando nao for codigo de barras.

			Else

				If ( AllTrim(ZK4->ZK4_CODBAR) == AllTrim(SE2->E2_CODBAR) ) .Or.;
						( AllTrim(ZK4->ZK4_CODBAR) == AllTrim(SE2->E2_LINDIG) ) .Or.;
						( AllTrim(ZK4->ZK4_CODBAR) == U_BIA841E(AllTrim(SE2->E2_LINDIG)) ) .Or.;
						( AllTrim(ZK4->ZK4_CODBAR) == AllTrim(SE2->E2_YLINDIG) ) .Or.;
						( AllTrim(ZK4->ZK4_CODBAR) == U_BIA841E(AllTrim(SE2->E2_YLINDIG)) )


					aZK4[nPos][NPOSVLD] := .T.

				EndIf

			EndIf

		Else // GNR-e

			If ( AllTrim(ZK4->ZK4_CODBAR) == AllTrim(SE2->E2_CODBAR) ) .Or.;
					( AllTrim(ZK4->ZK4_CODBAR) == U_BIA841E(AllTrim(SE2->E2_CODBAR)) ) .Or.;
					( AllTrim(ZK4->ZK4_CODBAR) == U_BIA841E(AllTrim(SE2->E2_LINDIG)) ) .Or.;
					( AllTrim(ZK4->ZK4_CODBAR) == U_BIA841E(AllTrim(SE2->E2_YLINDIG)) )

				aZK4[nPos][NPOSVLD] := .T.

			Else

				aZK4[nPos][NPOSVLD] := .F.

			EndIf

		EndIf

		If "REJEITADO" $ ZK4->ZK4_CHVAUT

			aZK4[nPos][NPOSVLD] := .F.

			aZK4[nPos][NPOSMSG] := "Titulo: " + SE2->E2_NUM +;
				" parc.: " + SE2->E2_PARCELA +;
				" tipo: " + SE2->E2_TIPO +;
				" Forn.: " + SE2->E2_FORNECE + "-" + SE2->E2_LOJA +;
				" - Rejeitado pelo banco" + CRLF

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

	If Len(aZK4) > 1

		For nW := 1 To Len(aZK4)

			If aZK4[nW][NPOSVLD]

				aAdd(aAux, aZK4[nW])

			EndIf

		Next nW

	EndIf

	If Len(aAux) > 0

		aZK4 := aAux

	EndIf

Return(aZK4)

Method Load(lServer) Class TAFComprovantePagamento

	Default lServer := .F.

	If Empty(::cFilePrint)

		::cFilePrint := ::GetNameFile()

	EndIf

	lAdjustToLegacy := .F.
	lDisableSetup  := .T.
	/*
	::oSetup := FWPrintSetup():New(nFlags, "Comprovante de pagamento")
	
	::oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	::oSetup:SetPropert(PD_ORIENTATION , 1)
	::oSetup:SetPropert(PD_DESTINATION , nLocal)
	::oSetup:SetPropert(PD_MARGIN      , {10,10,10,10})
	::oSetup:SetPropert(PD_PAPERSIZE   , 2)
	::oSetup:SetPropert(PD_PREVIEW	 ,.T.)
	*/
	::oPrint := FWMSPrinter():New(::cFilePrint, IMP_PDF , lAdjustToLegacy, ::cCaminho, lDisableSetup,,,,.T.,.F.,,.F.)

	::oPrint:SetResolution(78) //Tamanho estipulado para a Danfe
	::oPrint:SetPortrait()
	::oPrint:SetPaperSize(DMPAPER_A4)
	::oPrint:SetMargin(60,60,60,60)
	::oPrint:lServer := .T.

	::oPrint:SetCopies(1)

	::oPrint:SetViewPDF(lServer)

	::oPrint:cPathPDF := ::cCaminho

Return()


Method Print() Class TAFComprovantePagamento

	Local oFont08_  := TFont():New('Tahoma',,-10,.T.)
	Local oFont08N_ := TFont():New('Tahoma',,-12,.T., .T.)

	nRow := 040
	nCol := 040
	nBottom := 370
	nRight := 550
	nLinha01 := 100
	nColuna01 := 130

	::oPrint:Line(nRow,nCol,nRow,nRight)

	//::oPrint:Box(nRow,nCol,nBottom,nRight)

	//-----------//
	// Cabecalho //
	//-----------//
	nLinha01 := 15
	::oPrint:SayBitmap(nRow+nLinha01,nRow+nLinha01,::cLogo,100,045)

	nLinha01 := 30
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Comprovante de Pagamento", oFont08N_)

	nLinha01 += 10
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, If(::lBoleto, "Boleto de Cobrança", If(::lDocTed, "Transferência Interbancária - TED", If(::lCredito, "Crédito em Conta", If(::lGnre, "GNRE", "")))), oFont08_)

	If ::lGnre

		nLinha01 += 10
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Data da operação: " + ::cDataPag, oFont08_)

	EndIf

	nLinha01 += 10
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Autenticação Bancária: " + ::cAutentica, oFont08_)

	nLinha01 += 30
	::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

	//------------------//
	// Dados da empresa //
	//------------------//
	nLinha01 += 20
	nColuna01 := 30
	nColuna02 := 85

	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Empresa: ", oFont08_)
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, If(Len(::cNomeEmp) < 33, ::cNomeEmp + " | Cnpj: " + ::cCgcEmp, ::cNomeEmp), oFont08N_)
	nLinha01 += 10
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, If(Len(::cNomeEmp) > 33, "Cnpj: " + ::cCgcEmp, ""), oFont08N_)

	nLinha01 += 20
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Conta de Débito: ", oFont08_)
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cAgContEmp, oFont08N_)

	nLinha01 += 20
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Pagador: ", oFont08_)
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, If(Len(::cNomeEmp) < 33, ::cNomeEmp + " | Cnpj: " + ::cCgcEmp, ::cNomeEmp), oFont08N_)
	nLinha01 += 10
	::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, If(Len(::cNomeEmp) > 33, "Cnpj: " + ::cCgcEmp, ""), oFont08N_)

	nLinha01 += 20
	::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

	If ::lDocTed

		//--------------------//
		//Dados do fornecedor //
		//--------------------//

		nLinha01 += 20
		nColuna02 := 85
		nColuna03 := 270
		nColuna04 := 350

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Favorecido: ", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNomFavore, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, If(Len(::cCpfCnpjFa) == 18, "CNPJ: ", "CPF:"), oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cCpfCnpjFa, oFont08N_)
/*
		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Nº documento", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNumDoc, oFont08N_)
		*/
		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Banco de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Destino: ", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cBanco, oFont08N_)

		nLinha01 -= 6
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Número de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cNumPag, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Tipo de", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "documento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cTipoDoc, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Nº NF/FAT/DUP:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cNf, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Agência:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cAgenciaFa, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Conta:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cContaFav, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Data de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cDataPag, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Valor R$:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cValorPag, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Finalidade:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cFinalidad, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Cód. Id.", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Transf.:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cCodIdTr, oFont08N_)

		nLinha01 += 20
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Uso da Empresa:", oFont08_)
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cObs , oFont08N_)

		//----------//
		//  Rodape  //
		//----------//
		nLinha01 += 30
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "A Transação acima foi realizada com sucesso.", oFont08_)

		nLinha01 += 20
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		::oPrint:Line(nRow,nRow,nRow+nLinha01,nRow)

		::oPrint:Line(nCol,nRight,nCol+nLinha01,nRight)

	ElseIf ::lCredito

		//--------------------//
		//Dados do fornecedor //
		//--------------------//

		nLinha01 += 20
		nColuna02 := 85
		nColuna03 := 270
		nColuna04 := 350

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Favorecido: ", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNomFavore, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, If(Len(::cCpfCnpjFa) == 18, "CNPJ: ", "CPF:"), oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cCpfCnpjFa, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Número de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Pagamento: ", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNumPag, oFont08N_)

		nLinha01 -= 6
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Data de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cDataPag, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Tipo de", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "documento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cTipoDoc, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Nº NF/FAT/DUP:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cNf, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Agência:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cAgenciaFa, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Conta:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cContaFav, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Finalidade:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cFinalidad, oFont08N_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Valor R$:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cValorPag, oFont08N_)

		nLinha01 += 20
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Uso da Empresa:", oFont08_)
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cObs , oFont08N_)

		//----------//
		//  Rodape  //
		//----------//
		nLinha01 += 30
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "A Transação acima foi realizada com sucesso.", oFont08_)

		nLinha01 += 20
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		::oPrint:Line(nRow,nRow,nRow+nLinha01,nRow)

		::oPrint:Line(nCol,nRight,nCol+nLinha01,nRight)

	ElseIf ::lBoleto

		//--------------------//
		//Dados do fornecedor //
		//--------------------//

		nLinha01 += 20
		nColuna02 := 85
		nColuna03 := 270
		nColuna04 := 350

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Beneficiário: ", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNomFavore, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, If(Len(::cCpfCnpjFa) == 18, "CNPJ: ", "CPF:"), oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cCpfCnpjFa, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Agência:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cAgenciaFa, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Conta:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cContaFav, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Nº de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "identificação:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cCodBarra, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Banco Destino:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cBanco, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Data ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "de Vencimento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cDtVenc, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Número de ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNumPag, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Data de", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cDataPag, oFont08N_)
/*	
		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Nº documento", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cNumDoc, oFont08N_)
*/
		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Tipo de", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "documento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cTipoDoc, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Nº NF/FAT/DUP:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cNf, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "(=) Valor", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Documento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cValorCob, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "(-) Desconto/", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Abatimento", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cDescAbat, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "(-) Outras ", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Deduções:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cOutrasDed, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "(+) Mora/", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Multa:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cMoraMulta, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "(+) Outros", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Acrécimos:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cOutrosAcr, oFont08N_)

		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "(=) Valor", oFont08_)
		nLinha01 += 7
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna03, "Pago:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna04, ::cValorPag, oFont08N_)

		nLinha01 += 20
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Uso da Empresa:", oFont08_)
		//::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cObs , oFont08N_)

		//----------//
		//  Rodape  //
		//----------//
		nLinha01 += 30
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "A Transação acima foi realizada com sucesso.", oFont08_)

		nLinha01 += 20
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		::oPrint:Line(nRow,nRow,nRow+nLinha01,nRow)

		::oPrint:Line(nCol,nRight,nCol+nLinha01,nRight)

	ElseIf ::lGnre

		//--------------------//
		//Dados do fornecedor //
		//--------------------//

		nLinha01 += 6
		nColuna02 := 100
		nColuna03 := 270
		nColuna04 := 350

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Código de barras:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cCodBarra, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Empresa / Órgão:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cUF + "-" + "SEFAZ/GNRE", oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Descrição:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, "GNRE", oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Uf favorecida:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cUF, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Código da receita:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cCodReceita, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, If(Len(::cCgcFor) == 18, "CNPJ: ", "CPF:"), oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cCgcFor, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Juros:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cJuros, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Multa:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cMoraMulta, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Referência:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cReferencia, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Valor de pagamento:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, "R$ " + ::cValorPag, oFont08N_)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "Data do débito:", oFont08_)
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01 + nColuna02, ::cDataPag, oFont08N_)

		//----------//
		//  Rodape  //
		//----------//
		nLinha01 += 20
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		nLinha01 += 20
		::oPrint:Say(nRow + nLinha01, nCol + nColuna01, "A Transação acima foi realizada com sucesso.", oFont08_)

		nLinha01 += 20
		::oPrint:Line(nRow+nLinha01,nCol,nRow+nLinha01,nRight)

		::oPrint:Line(nRow,nRow,nRow+nLinha01,nRow)

		::oPrint:Line(nCol,nRight,nCol+nLinha01,nRight)

	EndIf

Return()


Method Pergunte() Class TAFComprovantePagamento

	Local lRet := .F.
	Local nTam := 0

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	If ::lImprimeGeral

		lRet := .T.

	Else

		aAdd(::aParam, {6, "Salvar em"		, ::cCaminho	,"@!"	  ,".T." , ".T.", 60, .T., , "c:\", ( GETF_RETDIRECTORY + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_SHAREAWARE )})

		If !::lPosicionado

			aAdd(::aParam, {1, "Venc. Real de"	, ::cVencrDe	, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Venc. Real ate"	, ::cVencrAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Bordero de"		, ::cBorDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Bordero ate"	, ::cBorAte		, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Num. Titulo de"	, ::cNumDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Num. Titulo ate", ::cNumAte		, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Prefixo de"		, ::cPrefDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Prefixo ate"	, ::cPrefAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Tipo de"		, ::cTipoDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Tipo ate"		, ::cTipoAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Parcela de"		, ::cParcDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Parcela ate"	, ::cParcAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Fornecedor de"	, ::cForneceDe	, "@!", ".T.","SA2",".T.",,.F.})
			aAdd(::aParam, {1, "Fornecedor ate"	, ::cForneceAte, "@!", ".T.","SA2",".T.",,.F.})

			aAdd(::aParam, {1, "Loja de"		, ::cLojaDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Loja ate"		, ::cLojaAte	, "@!", ".T.",		,".T.",,.F.})

		EndIf

		If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)

			lRet := .T.

			nTam++

			::cCaminho		:= ::aParRet[nTam++]

			If !::lPosicionado

				::cVencrDe 	    := ::aParRet[nTam++]
				::cVencrAte		:= ::aParRet[nTam++]
				::cBorDe 	    := ::aParRet[nTam++]
				::cBorAte       := ::aParRet[nTam++]
				::cNumDe 	    := ::aParRet[nTam++]
				::cNumAte       := ::aParRet[nTam++]
				::cPrefDe       := ::aParRet[nTam++]
				::cPrefAte      := ::aParRet[nTam++]
				::cTipoDe       := ::aParRet[nTam++]
				::cTipoAte      := ::aParRet[nTam++]
				::cParcDe       := ::aParRet[nTam++]
				::cParcAte      := ::aParRet[nTam++]
				::cForneceDe    := ::aParRet[nTam++]
				::cForneceAte	:= ::aParRet[nTam++]
				::cLojaDe 		:= ::aParRet[nTam++]
				::cLojaAte 		:= ::aParRet[nTam++]

			EndIf

		EndIf

	EndIf

	::CreatePath()

Return(lRet)