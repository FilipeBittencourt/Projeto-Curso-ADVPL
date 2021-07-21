#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA677
@author Marcos Alberto Soprani
@since 11/03/21
@version 1.0
@description Processa RAC AJUSTADA
@obs Esta rotina substitui o Processamento da RAC / BPC / SAP
@type function
/*/

User Function BIA677()

	Private msEnter     := CHR(13) + CHR(10)

	cCadastro := "RAC Ajustada"
	aRotina   := { {"Pesquisar"          ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"         ,"AxVisual"                          ,0,2},;
	{               "Processar RAC"      ,'ExecBlock("BIA677P",.F.,.F.)'      ,0,3},;
	{               "Imprimir Unit RAC"  ,'ExecBlock("BIA677I",.F.,.F.)'      ,0,3} }

	dbSelectArea("ZN8")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZN8")

	dbSelectArea("ZN8")

Return

// Processando
User Function BIA677P()

	Private ms1TbTemp   := '##TMP_AR1_BIA677' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""
	Private msMsg       := "Processando RAC Ajustada..."

	cHInicio := Time()
	fPerg := "BIA677P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		msGravaErr := "Cancelamento ainda nos parâmetros"
		Return
	EndIf

	If !U_BiaULRAC(MV_PAR01) .and. 1 = 2
		msGravaErr := "Erro MV_YULMES"
		Return
	Endif

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA677",fPerg)

	cDatIni := dtos(MV_PAR01)
	cDatFin := dtos(MV_PAR02) 
	cVersao := MV_PAR03
	cRevisa := MV_PAR04
	cAnoRef := MV_PAR05
	cUltDia := substr(cDatFin, 7, 2)
	cMesRef := substr(cDatFin, 5, 2) 

	xVerRet := .F.
	Processa({ || ExistThenD() }, "Aguarde!", "Deletando dados...", .F.)
	If xVerRet

		Processa({ || RptDetail() }, "Aguarde!", msMsg, .F.)

	Else

		msGravaErr := "Não foi confirmada a limpeza da base de dados"

	EndIf

	oLogProc:LogFimProc()

	If !Empty(msGravaErr)

		MsgSTOP("Erro de processamento: " + msEnter + msEnter + msGravaErr)

	Else

		MsgINFO("Fim do Processamento com Sucesso!!!")

	EndIf

Return

Static Function RptDetail()

	ProcRegua(0)

	If cEmpAnt $ "01"

		msQry01 := U_BIA677N1()

	ElseIf cEmpAnt == "06"

		msQry01 := U_BJZ677N1()

	Else

		MsgALERT("Empresa não configurada para cálculo da RAC")
		Return

	EndIf

	U_BIAMsgRun("Aguarde... Criando arquivo de Trabalho... ",,{|| msStaExcQy := TcSQLExec(msQry01) })
	If msStaExcQy < 0
		mslOk := .F.
	EndIf

	If mslOk

		// Custo Fixo
		If cEmpAnt $ "01"

			msQry02 := U_BIA677N2()

		ElseIf cEmpAnt == "06"

			msQry02 := U_BJZ677N2()

		Else

			MsgALERT("Empresa não configurada para cálculo da RAC")
			Return

		EndIf

		QRIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry02),'QR02',.T.,.T.)
		dbSelectArea("QR02")
		QR02->(dbGoTop())
		ProcRegua(RecCount())
		While !QR02->(Eof())

			msMsg := "Custo Fixo - " + QR02->PRODUT
			IncProc("Custo Fixo - " + QR02->PRODUT)

			Reclock("ZN8",.T.)
			ZN8->ZN8_FILIAL := xFilial("ZN8")
			ZN8->ZN8_DTREF  := stod(QR02->DTREF)
			ZN8->ZN8_TPPROD := QR02->TPPROD
			ZN8->ZN8_PRODUT := QR02->PRODUT
			ZN8->ZN8_LINHA  := QR02->LINHA
			ZN8->ZN8_LNH209 := QR02->LNH209
			ZN8->ZN8_LNH222 := QR02->LNH222
			ZN8->ZN8_LNH233 := QR02->LNH233
			ZN8->ZN8_PSECO  := QR02->PSECO
			ZN8->ZN8_ITCUS  := QR02->ITCUS
			ZN8->ZN8_TPCUS  := QR02->TIPO
			ZN8->ZN8_CUS200 := QR02->CUS200
			ZN8->ZN8_CUS201 := QR02->CUS201
			ZN8->ZN8_CUS202 := QR02->CUS202
			ZN8->ZN8_CUS203 := QR02->CUS203
			ZN8->ZN8_CUS204 := QR02->CUS204
			ZN8->ZN8_CUS205 := QR02->CUS205
			ZN8->ZN8_CUS206 := QR02->CUS206
			ZN8->ZN8_CUS207 := QR02->CUS207
			ZN8->ZN8_CUS208 := QR02->CUS208
			ZN8->ZN8_CUS209 := QR02->CUS209
			ZN8->ZN8_CUS222 := QR02->CUS222
			ZN8->ZN8_CUS233 := QR02->CUS233
			ZN8->ZN8_CUS210 := QR02->CUS210
			ZN8->ZN8_CUS211 := QR02->CUS211
			ZN8->ZN8_CUS234 := QR02->CUS234
			ZN8->ZN8_CUS212 := QR02->CUS212
			ZN8->ZN8_CUS213 := QR02->CUS213
			ZN8->ZN8_CUS235 := QR02->CUS235
			ZN8->ZN8_CUS214 := QR02->CUS214
			ZN8->ZN8_CUS215 := QR02->CUS215
			ZN8->ZN8_CUS236 := QR02->CUS236
			ZN8->ZN8_CUS216 := QR02->CUS216
			ZN8->ZN8_CUS217 := QR02->CUS217
			ZN8->ZN8_CUS223 := QR02->CUS223
			ZN8->ZN8_CUS224 := QR02->CUS224
			ZN8->(MsUnlock())

			QR02->(dbSkip())

		End

		QR02->(dbCloseArea())
		Ferase(QRIndex+GetDBExtension())
		Ferase(QRIndex+OrdBagExt())

		// Custo Variável
		msQry03 := U_BIA677N3()

		QYIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry03),'QR03',.T.,.T.)
		dbSelectArea("QR03")
		QR03->(dbGoTop())
		ProcRegua(RecCount())
		While !QR03->(Eof())

			msMsg := "Custo Variável - " + QR03->PRODUT
			IncProc("Custo Variável - " + QR03->PRODUT)

			Reclock("ZN8",.T.)
			ZN8->ZN8_FILIAL := xFilial("ZN8")
			ZN8->ZN8_DTREF  := stod(QR03->DTREF)
			ZN8->ZN8_TPPROD := QR03->TPPROD
			ZN8->ZN8_PRODUT := QR03->PRODUT
			ZN8->ZN8_ITCUS  := QR03->ITCUS
			ZN8->ZN8_TPCUS  := QR03->TIPO
			ZN8->ZN8_CUS223 := QR03->CUS223
			ZN8->ZN8_CUS224 := QR03->CUS224
			ZN8->(MsUnlock())

			QR03->(dbSkip())

		End

		QR03->(dbCloseArea())
		Ferase(QYIndex+GetDBExtension())
		Ferase(QYIndex+OrdBagExt())

		If cEmpAnt $ "01"

			// Custo C1 para B9/BO/C6
			msQry04 := U_BIA677N4()

			Q4Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry04),'QR04',.T.,.T.)
			dbSelectArea("QR04")
			QR04->(dbGoTop())
			ProcRegua(RecCount())
			While !QR04->(Eof())

				msMsg := "C1 para B9/BO/C6 - " + QR04->ZN8_PRODUT
				IncProc("C1 para B9/BO/C6 - " + QR04->ZN8_PRODUT)

				Reclock("ZN8",.T.)
				ZN8->ZN8_FILIAL := xFilial("ZN8")
				ZN8->ZN8_DTREF  := stod(QR04->ZN8_DTREF)
				ZN8->ZN8_TPPROD := "PA"
				ZN8->ZN8_PRODUT := QR04->ZN8_PRODUT
				ZN8->ZN8_ITCUS  := "065"
				ZN8->ZN8_TPCUS  := "CV"
				ZN8->ZN8_CUS223 := QR04->CUS223
				ZN8->ZN8_CUS224 := QR04->CUS224
				ZN8->(MsUnlock())

				QR04->(dbSkip())

			End

			QR04->(dbCloseArea())
			Ferase(Q4Index+GetDBExtension())
			Ferase(Q4Index+OrdBagExt())

			// Custo C1 para B9/BO/C6 para registros sem custo no mês corrente
			msQry05 := U_BIA677N5()

			Q5Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry05),'QR05',.T.,.T.)
			dbSelectArea("QR05")
			QR05->(dbGoTop())
			ProcRegua(RecCount())
			While !QR05->(Eof())

				msMsg := "C1 para B9/BO/C6 - p2" + QR05->ZN8_PRODUT
				IncProc("C1 para B9/BO/C6 - p2" + QR05->ZN8_PRODUT)

				ZN8->(dbGoTo(QR05->REGZN8))
				Reclock("ZN8",.F.)
				ZN8->ZN8_CUS224 := ZN8->ZN8_CUS223 * QR05->MEDIO
				ZN8->(MsUnlock())

				QR05->(dbSkip())

			End

			QR05->(dbCloseArea())
			Ferase(Q5Index+GetDBExtension())
			Ferase(Q5Index+OrdBagExt())

			// Redutor de Utilização placa, ItCus 065, Produto = Z1000071
			msQry06 := U_BIA677N6()

			Q6Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry06),'QR06',.T.,.T.)
			dbSelectArea("QR06")
			QR06->(dbGoTop())
			ProcRegua(RecCount())
			While !QR06->(Eof())

				msMsg := "ItCus 065, Produto = Z1000071"
				IncProc("ItCus 065, Produto = Z1000071")

				Reclock("ZN8",.T.)
				ZN8->ZN8_FILIAL := xFilial("ZN8")
				ZN8->ZN8_DTREF  := stod(QR06->DTREF)
				ZN8->ZN8_TPPROD := "PA"
				ZN8->ZN8_PRODUT := "Z1000071"
				ZN8->ZN8_ITCUS  := "065"
				ZN8->ZN8_TPCUS  := "CV"
				ZN8->ZN8_CUS223 := QR06->CUS223
				ZN8->ZN8_CUS224 := QR06->CUS224
				ZN8->(MsUnlock())

				QR06->(dbSkip())

			End

			QR06->(dbCloseArea())
			Ferase(Q6Index+GetDBExtension())
			Ferase(Q6Index+OrdBagExt())

			// Redutores de quebra, ItCus 071, Produto = Z1000071
			msQry07 := U_BIA677N7()

			Q7Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry07),'QR07',.T.,.T.)
			dbSelectArea("QR07")
			QR07->(dbGoTop())
			ProcRegua(RecCount())
			While !QR07->(Eof())

				msMsg := "ItCus 071, Produto = Z1000071"
				IncProc("ItCus 071, Produto = Z1000071")

				Reclock("ZN8",.T.)
				ZN8->ZN8_FILIAL := xFilial("ZN8")
				ZN8->ZN8_DTREF  := stod(QR07->DTREF)
				ZN8->ZN8_TPPROD := "PA"
				ZN8->ZN8_PRODUT := "Z1000071"
				ZN8->ZN8_ITCUS  := "071"
				ZN8->ZN8_TPCUS  := "CV"
				ZN8->ZN8_CUS223 := QR07->CUS223
				ZN8->ZN8_CUS224 := QR07->CUS224
				ZN8->(MsUnlock())

				QR07->(dbSkip())

			End

			QR07->(dbCloseArea())
			Ferase(Q7Index+GetDBExtension())
			Ferase(Q7Index+OrdBagExt())

			// Completa lacunas para os itens de custo realizados
			msQry08 := U_BIA677N8()

			Q8Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQry08),'QR08',.T.,.T.)
			dbSelectArea("QR08")
			QR08->(dbGoTop())
			ProcRegua(RecCount())
			While !QR08->(Eof())

				msMsg := "Completa lacunas para os itens de custo realizados"
				IncProc("Completa lacunas para os itens de custo realizados")

				Reclock("ZN8",.T.)
				ZN8->ZN8_FILIAL := xFilial("ZN8")
				ZN8->ZN8_DTREF  := stod(QR08->DTREF)
				ZN8->ZN8_TPPROD := QR08->TPPROD
				ZN8->ZN8_PRODUT := QR08->PRODUTO
				ZN8->ZN8_ITCUS  := QR08->ITCUS
				ZN8->ZN8_TPCUS  := QR08->TPPROD
				ZN8->ZN8_CUS223 := QR08->QUANT
				ZN8->ZN8_CUS224 := QR08->CUSTO1
				ZN8->(MsUnlock())

				QR08->(dbSkip())

			End

			QR08->(dbCloseArea())
			Ferase(Q8Index+GetDBExtension())
			Ferase(Q8Index+OrdBagExt())

		Endif

	Else

		msGravaErr := TCSQLError()

	EndIf

	ZN8->(dbSeek(xFilial("ZN8") + cDatFin ))	

Return

Static Function ExistThenD()

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSqlName("ZN8") + " ZN8 (NOLOCK) "
	cSql += " WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "' "
	cSql += "       AND ZN8_DTREF = '" + cDatFin + "'
	cSql += "       AND ZN8.D_E_L_E_T_ = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(RecCount())
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZN8->(DBGoTo((cQry)->RECNO))

		If !ZN8->(EOF())

			Reclock("ZN8", .F.)
			ZN8->(DBDelete())
			ZN8->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)

User Function BIA677N1()

	RK001 := Alltrim(" WITH TAB_A                                                                                                                                            ") + msEnter 
	RK001 += Alltrim("      AS (SELECT APL = 'GNA',                                                                                                                          ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_DEB',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                          ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                                ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                                      ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                           ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                                ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                                ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                   ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLDB,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                                   ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                                    ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                                          ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                          ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                                         ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                                      ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                           ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                                ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                                ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                   ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLCR,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                                   ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                                    ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                                          ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_OUTR_DEB',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                          ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                                ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                                      ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                           ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                               ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                                ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                   ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLDB,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                                   ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                                    ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                                          ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                          ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                                         ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                                      ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                           ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                               ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                                  ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                                ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                   ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLCR,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)),                                                                                                                 ") + msEnter
	RK001 += Alltrim("      TAB_A_ACUM                                                                                                                                       ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                              ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                                 ") + msEnter
	RK001 += Alltrim("                 VALOR = ROUND(SUM(VALOR), 2)                                                                                                          ") + msEnter
	RK001 += Alltrim("          FROM TAB_A                                                                                                                                   ") + msEnter
	RK001 += Alltrim("          GROUP BY PERIODO,                                                                                                                            ") + msEnter
	RK001 += Alltrim("                   APL,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                   CTA,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                   CLVL                                                                                                                                ") + msEnter
	RK001 += Alltrim("          HAVING ROUND(SUM(VALOR), 2) <> 0),                                                                                                           ") + msEnter
	RK001 += Alltrim("      TAB_B                                                                                                                                            ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                              ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 DESC01 = CT1_DESC01,                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 AGRUP = SUBSTRING(CT1_YAGRUP, 1, 10),                                                                                                 ") + msEnter
	RK001 += Alltrim("                 ITCUS = CASE                                                                                                                          ") + msEnter
	RK001 += Alltrim("                             WHEN SUBSTRING(CTH_YCRIT, 1, 3) = 'GCS'                                                                                   ") + msEnter
	RK001 += Alltrim("                             THEN '133'                                                                                                                ") + msEnter
	RK001 += Alltrim("                             WHEN SUBSTRING(CTH_YCRIT, 1, 3) = 'MOP'                                                                                   ") + msEnter
	RK001 += Alltrim("                             THEN '146'                                                                                                                ") + msEnter
	RK001 += Alltrim("                             WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                               ") + msEnter
	RK001 += Alltrim("                             THEN CTH_YITCUS                                                                                                           ") + msEnter
	RK001 += Alltrim("                             WHEN CTA IN('61103001')                                                                                                   ") + msEnter
	RK001 += Alltrim("                                  AND RTRIM(CLVL) IN('3103')                                                                                           ") + msEnter
	RK001 += Alltrim("                             THEN '026'                                                                                                                ") + msEnter
	RK001 += Alltrim("                             ELSE CT1_YITCUS                                                                                                           ") + msEnter
	RK001 += Alltrim("                         END,                                                                                                                          ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                                 ") + msEnter
	RK001 += Alltrim("                 AGGRAT = CASE                                                                                                                         ") + msEnter
	RK001 += Alltrim("                              WHEN((RTRIM(SUBSTRING(CTA, 1, 3)) IN('615', '617'))                                                                      ") + msEnter
	RK001 += Alltrim("                                   OR (RTRIM(SUBSTRING(CTA, 1, 3)) IN('616')                                                                           ") + msEnter
	RK001 += Alltrim("                                       AND RTRIM(CTA) NOT IN('61601022')                                                                               ") + msEnter
	RK001 += Alltrim("                                       AND SUBSTRING(CTH_YCRIT, 1, 1) <> 'L'))                                                                         ") + msEnter
	RK001 += Alltrim("                              THEN CASE                                                                                                                ") + msEnter
	RK001 += Alltrim("                                       WHEN CLVL = '3141'                                                                                              ") + msEnter
	RK001 += Alltrim("                                       THEN 'AC00'                                                                                                     ") + msEnter
	RK001 += Alltrim("                                       WHEN SUBSTRING(CLVL, 2, 1) = '1'                                                                                ") + msEnter
	RK001 += Alltrim("                                       THEN 'AC01'                                                                                                     ") + msEnter
	RK001 += Alltrim("                                       WHEN SUBSTRING(CLVL, 2, 1) = '2'                                                                                ") + msEnter
	RK001 += Alltrim("                                       THEN 'AC05'                                                                                                     ") + msEnter
	RK001 += Alltrim("                                       ELSE 'AC00'                                                                                                     ") + msEnter
	RK001 += Alltrim("                                   END                                                                                                                 ") + msEnter
	RK001 += Alltrim("                              ELSE SUBSTRING(ZF2_AGGRAT, 1, 4)                                                                                         ") + msEnter
	RK001 += Alltrim("                          END,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                 CRIT = SUBSTRING(CTH_YCRIT, 1, 3),                                                                                                    ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(VALOR)                                                                                                                    ") + msEnter
	RK001 += Alltrim("          FROM TAB_A_ACUM AS TAB                                                                                                                       ") + msEnter
	RK001 += Alltrim("               INNER JOIN " + RetSqlName("CT1") + "  CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'                                              ") + msEnter
	RK001 += Alltrim("                                                AND CT1_CONTA = CTA                                                                                    ") + msEnter
	RK001 += Alltrim("                                                AND CT1.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	RK001 += Alltrim("               INNER JOIN " + RetSqlName("CTH") + "  CTH(NOLOCK) ON CTH_FILIAL = '" + xFilial("CTH") + "'                                              ") + msEnter
	RK001 += Alltrim("                                                AND CTH_CLVL = CLVL                                                                                    ") + msEnter
	RK001 += Alltrim("                                                AND CTH_YAPLCT = 'S'                                                                                   ") + msEnter
	RK001 += Alltrim("                                                AND CTH.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	RK001 += Alltrim("               LEFT JOIN " + RetSqlName("ZF2") + " ZF2(NOLOCK) ON ZF2_FILIAL = '" + xFilial("ZF2") + "'                                                ") + msEnter
	RK001 += Alltrim("                                               AND ZF2_CODIGO = CTH_YAGRAT                                                                             ") + msEnter
	RK001 += Alltrim("                                               AND ZF2.D_E_L_E_T_ = ' '                                                                                ") + msEnter
	RK001 += Alltrim("          GROUP BY PERIODO,                                                                                                                            ") + msEnter
	RK001 += Alltrim("                   APL,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                   CTA,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                   CT1_DESC01,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   CT1_YITCUS,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   SUBSTRING(CT1_YAGRUP, 1, 10),                                                                                                       ") + msEnter
	RK001 += Alltrim("                   CLVL,                                                                                                                               ") + msEnter
	RK001 += Alltrim("                   SUBSTRING(ZF2_AGGRAT, 1, 4),                                                                                                        ") + msEnter
	RK001 += Alltrim("                   CTH_YITCUS,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                   SUBSTRING(CTH_YCRIT, 1, 3),                                                                                                         ") + msEnter
	RK001 += Alltrim("                   SUBSTRING(CTH_YCRIT, 1, 1)),                                                                                                        ") + msEnter
	RK001 += Alltrim("      TAB_C                                                                                                                                            ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                              ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 DESC01,                                                                                                                               ") + msEnter
	RK001 += Alltrim("                 AGRUP,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                 ITCUS,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                 Z29_TIPO,                                                                                                                             ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                                 ") + msEnter
	RK001 += Alltrim("                 AGGRAT = CASE                                                                                                                         ") + msEnter
	RK001 += Alltrim("                              WHEN ITCUS IN('033')                                                                                                     ") + msEnter
	RK001 += Alltrim("                                   AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('E3-E03', 'E4-E04')                                                        ") + msEnter
	RK001 += Alltrim("                              THEN 'AC01'                                                                                                              ") + msEnter
	RK001 += Alltrim("                              WHEN ITCUS IN('033')                                                                                                     ") + msEnter
	RK001 += Alltrim("                                   AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('L1L2-L01', 'L3-L03')                                                      ") + msEnter
	RK001 += Alltrim("                              THEN 'AC01'                                                                                                              ") + msEnter
	RK001 += Alltrim("                              WHEN ITCUS IN('130')                                                                                                     ") + msEnter
	RK001 += Alltrim("                                   AND CRIT IN('E03', 'E04')                                                                                           ") + msEnter
	RK001 += Alltrim("                              THEN SUBSTRING(CRIT, 1, 1) + SUBSTRING(CRIT, 3, 1)                                                                       ") + msEnter
	RK001 += Alltrim("                              ELSE AGGRAT                                                                                                              ") + msEnter
	RK001 += Alltrim("                          END,                                                                                                                         ") + msEnter
	RK001 += Alltrim("                 CRIT = CASE                                                                                                                           ") + msEnter
	RK001 += Alltrim("                            WHEN ITCUS IN('033')                                                                                                       ") + msEnter
	RK001 += Alltrim("                                 AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('E3-E03', 'E4-E04')                                                          ") + msEnter
	RK001 += Alltrim("                            THEN 'TOT'                                                                                                                 ") + msEnter
	RK001 += Alltrim("                            WHEN ITCUS IN('033')                                                                                                       ") + msEnter
	RK001 += Alltrim("                                 AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('L1L2-L01', 'L3-L03')                                                        ") + msEnter
	RK001 += Alltrim("                            THEN 'TOT'                                                                                                                 ") + msEnter
	RK001 += Alltrim("                            ELSE CRIT                                                                                                                  ") + msEnter
	RK001 += Alltrim("                        END,                                                                                                                           ") + msEnter
	RK001 += Alltrim("                 VALOR,                                                                                                                                ") + msEnter
	RK001 += Alltrim("                 MODS = CASE                                                                                                                           ") + msEnter
	RK001 += Alltrim("                            WHEN RTRIM(APL) = 'GA'                                                                                                     ") + msEnter
	RK001 += Alltrim("                            THEN 'DIRETA'                                                                                                              ") + msEnter
	RK001 += Alltrim("                            WHEN CTA IN('61103001')                                                                                                    ") + msEnter
	RK001 += Alltrim("                                 AND RTRIM(CLVL) IN('3103')                                                                                            ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD1ATM'                                                                                                             ") + msEnter
	RK001 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                           ") + msEnter
	RK001 += Alltrim("                                 AND Z29_TIPO = 'CV'                                                                                                   ") + msEnter
	RK001 += Alltrim("                                 AND Z29_COD_IT = '004'                                                                                                ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'E' + RTRIM(CLVL) + SPACE(7)                                                          ") + msEnter
	RK001 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                           ") + msEnter
	RK001 += Alltrim("                                 AND Z29_TIPO = 'CV'                                                                                                   ") + msEnter
	RK001 += Alltrim("                                 AND Z29_COD_IT <> '004'                                                                                               ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'V' + RTRIM(CLVL) + SPACE(7)                                                          ") + msEnter
	RK001 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                           ") + msEnter
	RK001 += Alltrim("                                 AND Z29_TIPO = 'CF'                                                                                                   ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'F' + RTRIM(CLVL) + RTRIM(SUBSTRING(AGRUP, 1, 6))                                     ") + msEnter
	RK001 += Alltrim("                            WHEN RTRIM(CLVL) IN('6112', '6208')                                                                                        ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) + SPACE(7)                                                      ") + msEnter
	RK001 += Alltrim("                            WHEN CTA IN('61601022')                                                                                                    ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                                ") + msEnter
	RK001 += Alltrim("                            WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                                ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                                 ") + msEnter
	RK001 += Alltrim("                            WHEN RTRIM(CLVL) IN('3299')                                                                                                ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                                 ") + msEnter
	RK001 += Alltrim("                            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('612', '613', '614')                                                                ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                                ") + msEnter
	RK001 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '3'                                                                                           ") + msEnter
	RK001 += Alltrim("                            THEN 'MOD' + '0' + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                                          ") + msEnter
	RK001 += Alltrim("                            ELSE 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                        ") + msEnter
	RK001 += Alltrim("                        END,                                                                                                                           ") + msEnter
	RK001 += Alltrim("                 CONTRAP = CASE                                                                                                                        ") + msEnter
	RK001 += Alltrim("                               WHEN RTRIM(CLVL) IN('3801')                                                                                             ") + msEnter
	RK001 += Alltrim("                               THEN 'MP'                                                                                                               ") + msEnter
	RK001 += Alltrim("                               WHEN RTRIM(CLVL) IN('3802', '3803')                                                                                     ") + msEnter
	RK001 += Alltrim("                               THEN 'PI'                                                                                                               ") + msEnter
	RK001 += Alltrim("                               WHEN RTRIM(CLVL) IN('3804', '3805')                                                                                     ") + msEnter
	RK001 += Alltrim("                               THEN 'PA'                                                                                                               ") + msEnter
	RK001 += Alltrim("                               WHEN((RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617')                                                        ") + msEnter
	RK001 += Alltrim("                                     AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09')                                                   ") + msEnter
	RK001 += Alltrim("                                     AND B.ITCUS NOT IN('033'))                                                                                        ") + msEnter
	RK001 += Alltrim("                                    OR (B.ITCUS IN('130')                                                                                              ") + msEnter
	RK001 += Alltrim("                                        AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09')))                                              ") + msEnter
	RK001 += Alltrim("                               THEN 'PA'                                                                                                               ") + msEnter
	RK001 += Alltrim("                               WHEN SUBSTRING(CTA, 1, 5) IN('61104', '61110')                                                                          ") + msEnter
	RK001 += Alltrim("                               THEN 'PA'                                                                                                               ") + msEnter
	RK001 += Alltrim("                               ELSE 'PP'                                                                                                               ") + msEnter
	RK001 += Alltrim("                           END                                                                                                                         ") + msEnter
	RK001 += Alltrim("          FROM TAB_B B                                                                                                                                 ") + msEnter
	RK001 += Alltrim("               LEFT JOIN " + RetSqlName("Z29") + "  Z29(NOLOCK) ON Z29_COD_IT = B.ITCUS                                                                ") + msEnter
	RK001 += Alltrim("                                               AND Z29.D_E_L_E_T_ = ' '),                                                                              ") + msEnter
	RK001 += Alltrim("      TABFINAL                                                                                                                                         ") + msEnter
	RK001 += Alltrim("      AS (SELECT C.*,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("                 DESCR = ISNULL(SUBSTRING(B1_DESC, 1, 50), ' '),                                                                                       ") + msEnter
	RK001 += Alltrim("                 REGRAC = ISNULL(B1_YREGRAC, ' '),                                                                                                     ") + msEnter
	RK001 += Alltrim("                 RATEIO = CASE                                                                                                                         ") + msEnter
	RK001 += Alltrim("                              WHEN B1_YREGRAC = '1'                                                                                                    ") + msEnter
	RK001 += Alltrim("                              THEN 'CAP. PRODUTIVA'                                                                                                    ") + msEnter
	RK001 += Alltrim("                              WHEN B1_YREGRAC = '2'                                                                                                    ") + msEnter
	RK001 += Alltrim("                              THEN 'PESO SECO'                                                                                                         ") + msEnter
	RK001 += Alltrim("                              WHEN B1_YREGRAC = '3'                                                                                                    ") + msEnter
	RK001 += Alltrim("                              THEN 'M2'                                                                                                                ") + msEnter
	RK001 += Alltrim("                              ELSE 'INDEFINIDO'                                                                                                        ") + msEnter
	RK001 += Alltrim("                          END                                                                                                                          ") + msEnter
	RK001 += Alltrim("          FROM TAB_C C                                                                                                                                 ") + msEnter
	RK001 += Alltrim("               LEFT JOIN " + RetSqlName("SB1") + "  SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                                ") + msEnter
	RK001 += Alltrim("                                               AND B1_COD = MODS                                                                                       ") + msEnter
	RK001 += Alltrim("                                               AND SB1.D_E_L_E_T_ = ' '                                                                                ") + msEnter
	RK001 += Alltrim("          WHERE Z29_TIPO = 'CF')                                                                                                                       ") + msEnter
	RK001 += Alltrim("      SELECT FABRICA = SUBSTRING(MODS, 4, 1),                                                                                                          ") + msEnter
	RK001 += Alltrim("             APLIC_CUSTO = CASE                                                                                                                        ") + msEnter
	RK001 += Alltrim("                               WHEN CTA = '61601022'                                                                                                   ") + msEnter
	RK001 += Alltrim("                               THEN 'RPV'                                                                                                              ") + msEnter
	RK001 += Alltrim("                               WHEN CRIT = 'GCS'                                                                                                       ") + msEnter
	RK001 += Alltrim("                               THEN 'GCS'                                                                                                              ") + msEnter
	RK001 += Alltrim("                               WHEN CRIT = 'MOP'                                                                                                       ") + msEnter
	RK001 += Alltrim("                               THEN 'MOP'                                                                                                              ") + msEnter
	RK001 += Alltrim("                               WHEN ITCUS = '125'                                                                                                      ") + msEnter
	RK001 += Alltrim("                               THEN 'DEPRE'                                                                                                            ") + msEnter
	RK001 += Alltrim("                               WHEN ITCUS = '145'                                                                                                      ") + msEnter
	RK001 += Alltrim("                               THEN 'ALUGU'                                                                                                            ") + msEnter
	RK001 += Alltrim("                               WHEN ITCUS = '033'                                                                                                      ") + msEnter
	RK001 += Alltrim("                               THEN 'COMBU'                                                                                                            ") + msEnter
	RK001 += Alltrim("                               ELSE 'GERAL'                                                                                                            ") + msEnter
	RK001 += Alltrim("                           END,                                                                                                                        ") + msEnter
	RK001 += Alltrim("             CONECT = CASE                                                                                                                             ") + msEnter
	//                                      -- exceção                                                                                                                       ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PP'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('AC01')                                                                                            ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(CRIT) IN('L01')                                                                                               ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(ITCUS) IN('130')                                                                                              ") + msEnter	
	RK001 += Alltrim("                          THEN '209'                                                                                                                   ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PP'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('L1L2', 'L3')                                                                                      ") + msEnter
	RK001 += Alltrim("                          THEN '209'                                                                                                                   ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PP'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('AC01', 'AC05')                                                                                    ") + msEnter
	RK001 += Alltrim("                          THEN '222'                                                                                                                   ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PP'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('AC00')                                                                                            ") + msEnter
	RK001 += Alltrim("                          THEN '233'                                                                                                                   ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PA'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('E3', 'E4', 'R1', 'R2')                                                                            ") + msEnter
	RK001 += Alltrim("                          THEN '209'                                                                                                                   ") + msEnter
	RK001 += Alltrim("                          ELSE '   '                                                                                                                      ") + msEnter
	RK001 += Alltrim("                      END,                                                                                                                             ") + msEnter
	RK001 += Alltrim("             PERIODO,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("             APL,                                                                                                                                      ") + msEnter
	RK001 += Alltrim("             CTA,                                                                                                                                      ") + msEnter
	RK001 += Alltrim("             DESC01,                                                                                                                                   ") + msEnter
	RK001 += Alltrim("             AGRUP,                                                                                                                                    ") + msEnter
	RK001 += Alltrim("             ITCUS,                                                                                                                                    ") + msEnter
	RK001 += Alltrim("             Z29_TIPO,                                                                                                                                 ") + msEnter
	RK001 += Alltrim("             CLVL,                                                                                                                                     ") + msEnter
	RK001 += Alltrim("             AGGRAT = CASE                                                                                                                             ") + msEnter
	//                                      -- exceção                                                                                                                       ") + msEnter
	RK001 += Alltrim("                          WHEN CONTRAP = 'PP'                                                                                                          ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(AGGRAT) IN('AC01')                                                                                            ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(CRIT) IN('L01')                                                                                               ") + msEnter
	RK001 += Alltrim("                               AND RTRIM(ITCUS) IN('130')                                                                                              ") + msEnter
	RK001 += Alltrim("                          THEN 'L1L2'                                                                                                                  ") + msEnter
	RK001 += Alltrim("                          ELSE AGGRAT                                                                                                                  ") + msEnter
	RK001 += Alltrim("                      END,                                                                                                                             ") + msEnter
	RK001 += Alltrim("             CRIT,                                                                                                                                     ") + msEnter
	RK001 += Alltrim("             VALOR,                                                                                                                                    ") + msEnter
	RK001 += Alltrim("             MODS,                                                                                                                                     ") + msEnter
	RK001 += Alltrim("             CONTRAP,                                                                                                                                  ") + msEnter
	RK001 += Alltrim("             DESCR,                                                                                                                                    ") + msEnter
	RK001 += Alltrim("             REGRAC,                                                                                                                                   ") + msEnter
	RK001 += Alltrim("             RATEIO                                                                                                                                    ") + msEnter
	RK001 += Alltrim("      INTO " + ms1TbTemp + "                                                                                                                           ") + msEnter
	RK001 += Alltrim("      FROM TABFINAL                                                                                                                                    ") + msEnter

Return( RK001 )

User Function BJZ677N1()

	RK001 := Alltrim(" WITH FXRATEIO                                                                                                                              ") + msEnter
	RK001 += Alltrim("      AS (SELECT CTQ_RATEIO,                                                                                                                ") + msEnter
	RK001 += Alltrim("                 CTQ_SEQUEN,                                                                                                                ") + msEnter
	RK001 += Alltrim("                 CTQ_CLPAR,                                                                                                                 ") + msEnter
	RK001 += Alltrim("                 CTQ_CLORI,                                                                                                                 ") + msEnter
	RK001 += Alltrim("                 CTQ_CLCPAR,                                                                                                                ") + msEnter
	RK001 += Alltrim("                 CTQ_PERCEN = CTQ_PERCEN / 100                                                                                              ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("CTQ") + "  CTQ(NOLOCK)                                                                                       ") + msEnter
	RK001 += Alltrim("          WHERE CTQ_FILIAL = '" + xFilial("CTQ") + "'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND CTQ_RATEIO BETWEEN '" + substr(cDatFin,3,2) + cMesRef + "  ' AND '" + substr(cDatFin,3,2) + cMesRef + "ZZ'              ") + msEnter
	RK001 += Alltrim("                AND CTQ_MSBLQL <> '1'                                                                                                       ") + msEnter
	RK001 += Alltrim("                AND CTQ_STATUS = '1'                                                                                                        ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                        ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A1' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3801' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3801' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3801' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN                                                                                                               ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A2' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3802' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3802' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3802' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN                                                                                                               ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A3' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3803' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3803' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3803' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN                                                                                                               ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A4' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3804' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3804' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3804' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN                                                                                                               ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A5' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3805' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3805' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3805' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN                                                                                                               ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT '" + substr(cDatFin,3,2) + cMesRef + "' + 'A6' CTQ_RATEIO,                                                                 ") + msEnter
	RK001 += Alltrim("                 '001' CTQ_SEQUEN,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3558' CTQ_CLPAR,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3558' CTQ_CLORI,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 '3803' CTQ_CLCPAR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 1 CTQ_PERCEN),                                                                                                             ") + msEnter
	RK001 += Alltrim("      PROCN01                                                                                                                               ") + msEnter
	RK001 += Alltrim("      AS (SELECT APL = 'GNA',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_DEB',                                                                                                    ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                               ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                     ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                           ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                     ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                        ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLDB,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                        ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                    ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                               ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                              ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                           ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                     ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                     ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                        ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLCR,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                        ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_OUTR_DEB',                                                                                                    ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                               ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                     ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                           ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                    ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                     ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                        ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLDB,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                        ") + msEnter
	RK001 += Alltrim("          UNION ALL                                                                                                                         ") + msEnter
	RK001 += Alltrim("          SELECT APL = 'GNA',                                                                                                               ") + msEnter
	RK001 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                    ") + msEnter
	RK001 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                          ") + msEnter
	RK001 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                         ") + msEnter
	RK001 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                               ") + msEnter
	RK001 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                              ") + msEnter
	RK001 += Alltrim("          FROM " + RetSqlName("ZBZ") + " (NOLOCK)                                                                                           ") + msEnter
	RK001 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND ZBZ_VERSAO = '" + cVersao + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_REVISA = '" + cRevisa + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_ANOREF = '" + cAnoRef + "'                                                                                          ") + msEnter
	RK001 += Alltrim("                AND ZBZ_DATA BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                                ") + msEnter
	RK001 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                    ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                       ") + msEnter
	RK001 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                     ") + msEnter
	RK001 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                        ") + msEnter
	RK001 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   ZBZ_CLVLCR,                                                                                                              ") + msEnter
	RK001 += Alltrim("                   LEFT(ZBZ_DATA, 6)),                                                                                                      ") + msEnter
	RK001 += Alltrim("      PROCN02                                                                                                                               ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                   ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                      ") + msEnter
	RK001 += Alltrim("                 VALOR = ROUND(SUM(VALOR), 2)                                                                                               ") + msEnter
	RK001 += Alltrim("          FROM PROCN01 PRC01                                                                                                                ") + msEnter
	RK001 += Alltrim("          GROUP BY PERIODO,                                                                                                                 ") + msEnter
	RK001 += Alltrim("                   APL,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                   CTA,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                   CLVL                                                                                                                     ") + msEnter
	RK001 += Alltrim("          HAVING ROUND(SUM(VALOR), 2) <> 0),                                                                                                ") + msEnter
	RK001 += Alltrim("      PROCN03                                                                                                                               ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                   ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                      ") + msEnter
	RK001 += Alltrim("                 VALOR,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL2 = CTQ.CTQ_CLCPAR,                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERCEN2 = CTQ.CTQ_PERCEN,                                                                                                  ") + msEnter
	RK001 += Alltrim("                 VALOR2 = VALOR * CTQ_PERCEN                                                                                                ") + msEnter
	RK001 += Alltrim("          FROM PROCN02 PRC02                                                                                                                ") + msEnter
	RK001 += Alltrim("               LEFT JOIN FXRATEIO CTQ ON CTQ.CTQ_CLORI = CLVL),                                                                             ") + msEnter
	RK001 += Alltrim("      PROCN04                                                                                                                               ") + msEnter
	RK001 += Alltrim("      AS (SELECT PRC03.*                                                                                                                    ") + msEnter
	RK001 += Alltrim("          FROM PROCN03 PRC03),                                                                                                              ") + msEnter
	RK001 += Alltrim("      PROCN05                                                                                                                               ") + msEnter
	RK001 += Alltrim("      AS (SELECT PERIODO,                                                                                                                   ") + msEnter
	RK001 += Alltrim("                 APL,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CTA,                                                                                                                       ") + msEnter
	RK001 += Alltrim("                 CLVL,                                                                                                                      ") + msEnter
	RK001 += Alltrim("                 VALOR,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 CLVL2,                                                                                                                     ") + msEnter
	RK001 += Alltrim("                 PERCEN2,                                                                                                                   ") + msEnter
	RK001 += Alltrim("                 VALOR2,                                                                                                                    ") + msEnter
	RK001 += Alltrim("                 CLVL3 = CTQ.CTQ_CLCPAR,                                                                                                    ") + msEnter
	RK001 += Alltrim("                 PERCEN3 = CTQ.CTQ_PERCEN,                                                                                                  ") + msEnter
	RK001 += Alltrim("                 VALOR3 = VALOR2 * CTQ_PERCEN                                                                                               ") + msEnter
	RK001 += Alltrim("          FROM PROCN04 PRC04                                                                                                                ") + msEnter
	RK001 += Alltrim("               LEFT JOIN FXRATEIO CTQ ON CTQ.CTQ_CLORI = CLVL2)                                                                             ") + msEnter
	RK001 += Alltrim("      SELECT PRC05.*,                                                                                                                       ") + msEnter
	RK001 += Alltrim("             CONECT = '209',                                                                                                                ") + msEnter
	RK001 += Alltrim("             AGGRAT = CLVL3,                                                                                                                ") + msEnter
	RK001 += Alltrim("             ITCUS = CT1_YITCUS                                                                                                             ") + msEnter
	RK001 += Alltrim("      INTO " + ms1TbTemp + "                                                                                                                ") + msEnter
	RK001 += Alltrim("      FROM PROCN05 PRC05                                                                                                                    ") + msEnter
	RK001 += Alltrim("           INNER JOIN " + RetSqlName("CT1") + "  CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'                                       ") + msEnter
	RK001 += Alltrim("                                            AND CT1_CONTA = CTA                                                                             ") + msEnter
	RK001 += Alltrim("                                            AND CT1.D_E_L_E_T_ = ' '                                                                        ") + msEnter
	RK001 += Alltrim("           INNER JOIN " + RetSqlName("CTH") + "  CTH(NOLOCK) ON CTH_FILIAL = '" + xFilial("CTH") + "'                                       ") + msEnter
	RK001 += Alltrim("                                            AND CTH_CLVL = CLVL3                                                                            ") + msEnter
	RK001 += Alltrim("                                            AND CTH_YAPLCT = 'S'                                                                            ") + msEnter
	RK001 += Alltrim("                                            AND CTH.D_E_L_E_T_ = ' '                                                                        ") + msEnter
	RK001 += Alltrim("           INNER JOIN " + RetSqlName("Z29") + "  Z29(NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "'                                       ") + msEnter
	RK001 += Alltrim("                                            AND Z29_COD_IT = CT1_YITCUS                                                                     ") + msEnter
	RK001 += Alltrim("                                            AND Z29_TIPO = 'CF'                                                                             ") + msEnter
	RK001 += Alltrim("                                            AND Z29.D_E_L_E_T_ = ' ';                                                                       ") + msEnter

Return( RK001 )

User Function BIA677N2()

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z57_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z57") + " Z57(NOLOCK) "
	XP001 += " WHERE Z57_DATARF BETWEEN '" + Substr(dtos(MV_PAR01),1,4) + "0101' AND '" + Substr(dtos(MV_PAR01),1,4) + "1231' "
	XP001 += "       AND Z57.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	RK002 := Alltrim(" WITH ITCUSF                                                                                                                                 ") + msEnter
	RK002 += Alltrim("      AS (SELECT Z29_TIPO TIPO,                                                                                                              ") + msEnter
	RK002 += Alltrim("                 Z29_COD_IT ITCUS,                                                                                                           ") + msEnter
	RK002 += Alltrim("                 Z29_DRESUM DESCR                                                                                                            ") + msEnter
	RK002 += Alltrim("          FROM " + RetSqlName("Z29") + "  Z29(NOLOCK)                                                                                        ") + msEnter
	RK002 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                        ") + msEnter
	RK002 += Alltrim("                AND Z29_TIPO = 'CF'                                                                                                          ") + msEnter
	RK002 += Alltrim("                AND D_E_L_E_T_ = ' '),                                                                                                       ") + msEnter
	RK002 += Alltrim("      CFPROCESS01                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT DTREF = Z57.Z57_DATARF,                                                                                                     ") + msEnter
	RK002 += Alltrim("                 TPPROD = SB1.B1_TIPO,                                                                                                       ") + msEnter
	RK002 += Alltrim("                 PRODUT = Z57.Z57_PRODUT,                                                                                                    ") + msEnter
	RK002 += Alltrim("                 LINHA = Z57.Z57_LINHA,                                                                                                      ") + msEnter
	RK002 += Alltrim("                 LNH209 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PP'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('L01', 'L02')                                                                        ") + msEnter
	RK002 += Alltrim("                              THEN 'L1L2'                                                                                                    ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PP'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('L03')                                                                               ") + msEnter
	RK002 += Alltrim("                              THEN LEFT(Z57.Z57_LINHA, 1) + RIGHT(Z57.Z57_LINHA, 1)                                                          ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PA'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('E03', 'E04', 'R01', 'R02', 'R09')                                                   ") + msEnter
	RK002 += Alltrim("                              THEN LEFT(Z57.Z57_LINHA, 1) + RIGHT(Z57.Z57_LINHA, 1)                                                          ") + msEnter
	RK002 += Alltrim("                              ELSE ''                                                                                                        ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 LNH222 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PP'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('L01', 'L02', 'L03')                                                                 ") + msEnter
	RK002 += Alltrim("                              THEN 'AC01'                                                                                                    ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PP'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('L04', 'L05')                                                                        ") + msEnter
	RK002 += Alltrim("                              THEN 'AC05'                                                                                                    ") + msEnter
	RK002 += Alltrim("                              ELSE ''                                                                                                        ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 LNH233 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN SB1.B1_TIPO = 'PP'                                                                                        ") + msEnter
	RK002 += Alltrim("                                   AND Z57.Z57_LINHA IN('L01', 'L02', 'L03', 'L04', 'L05')                                                   ") + msEnter
	RK002 += Alltrim("                              THEN 'AC00'                                                                                                    ") + msEnter
	RK002 += Alltrim("                              ELSE ''                                                                                                        ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 PSECO = Z57.Z57_PSECO,                                                                                                      ") + msEnter
	RK002 += Alltrim("                 CUS200 = Z57.Z57_QTDRAC,                                                                                                    ") + msEnter
	RK002 += Alltrim("                 CUS201 = Z57.Z57_CAPACI,                                                                                                    ") + msEnter
	RK002 += Alltrim("                 CUS202 = Z57.Z57_QTDRAC / Z57.Z57_CAPACI,                                                                                   ") + msEnter
	RK002 += Alltrim("                 CUS203 =                                                                                                                    ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.Z57_QTDRAC)                                                                                                     ") + msEnter
	RK002 += Alltrim("              FROM " + RetSqlName("Z57") + "  XXX(NOLOCK)                                                                                    ") + msEnter
	RK002 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " QQQ(NOLOCK) ON QQQ.B1_COD = XXX.Z57_PRODUT                                           ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.B1_TIPO = SB1.B1_TIPO                                                                    ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	RK002 += Alltrim("              WHERE XXX.Z57_FILIAL = Z57.Z57_FILIAL                                                                                          ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_DATARF = Z57.Z57_DATARF                                                                                      ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_GMCD = Z57.Z57_GMCD                                                                                          ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_SEQUEN = Z57.Z57_SEQUEN                                                                                      ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_LINHA = Z57.Z57_LINHA                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.D_E_L_E_T_ = ' '                                                                                                 ") + msEnter
	RK002 += Alltrim("          )                                                                                                                                  ") + msEnter
	RK002 += Alltrim("          FROM " + RetSqlName("Z57") + "  Z57(NOLOCK)                                                                                        ") + msEnter
	RK002 += Alltrim("               INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_COD = Z57.Z57_PRODUT                                               ") + msEnter
	RK002 += Alltrim("                                        AND SB1.D_E_L_E_T_ = ' '                                                                             ") + msEnter
	RK002 += Alltrim("          WHERE Z57.Z57_FILIAL = '" + xFilial("Z57") + "'                                                                                    ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_DATARF = '" + cDatFin + "'                                                                                       ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_GMCD = 'S'                                                                                                       ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_SEQUEN = '" + msSequenc + "'                                                                                     ") + msEnter
	RK002 += Alltrim("                AND Z57.D_E_L_E_T_ = ' '),                                                                                                   ") + msEnter
	RK002 += Alltrim("      CFPROCESS02                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS204 =                                                                                                                    ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("          ),                                                                                                                                 ") + msEnter
	RK002 += Alltrim("                 CUS205 = " + cUltDia + " /                                                                                                  ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("          ) * CUS202,                                                                                                                        ") + msEnter
	RK002 += Alltrim("                 CUS206 = CUS201 * (" + cUltDia + " /                                                                                        ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("          ) * CUS202),                                                                                                                       ") + msEnter
	RK002 += Alltrim("                 CUS207 = PSECO,                                                                                                             ") + msEnter
	RK002 += Alltrim("                 CUS208 = (CUS201 * (" + cUltDia + " /                                                                                       ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("          ) * CUS202)) * PSECO                                                                                                               ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS01 PRC01),                                                                                                           ") + msEnter
	RK002 += Alltrim("      CFPROCESS03                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS209 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC02.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH209 = PRC02.LNH209                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC02.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH209 <> ''                                                                                                     ") + msEnter
	RK002 += Alltrim("          ), 0)                                                                                                                              ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS02 PRC02),                                                                                                           ") + msEnter
	RK002 += Alltrim("      CFPROCESS04                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT ITCF.*,                                                                                                                     ") + msEnter
	RK002 += Alltrim("                 PRC03.*,                                                                                                                    ") + msEnter
	RK002 += Alltrim("                 CUS222 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC03.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH222 = PRC03.LNH222                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC03.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH222 <> ''                                                                                                     ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                             ") + msEnter
	RK002 += Alltrim("                 CUS233 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                         ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                   ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC03.DTREF                                                                                                  ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH233 = PRC03.LNH233                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC03.TPPROD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH233 <> ''                                                                                                     ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                             ") + msEnter
	RK002 += Alltrim("                 CUS210 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR)                                                                                                              ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ(NOLOCK)                                                                                             ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '209'                                                                                                       ") + msEnter
	RK002 += Alltrim("                    AND JJJ.CONTRAP = PRC03.TPPROD                                                                                           ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH209                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                               ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                             ") + msEnter
	RK002 += Alltrim("                 CUS211 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR)                                                                                                              ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ(NOLOCK)                                                                                             ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '222'                                                                                                       ") + msEnter
	RK002 += Alltrim("                    AND JJJ.CONTRAP = PRC03.TPPROD                                                                                           ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH222                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                               ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                             ") + msEnter
	RK002 += Alltrim("                 CUS234 = ISNULL(                                                                                                            ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                  ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR)                                                                                                              ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ(NOLOCK)                                                                                             ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '233'                                                                                                       ") + msEnter
	RK002 += Alltrim("                    AND JJJ.CONTRAP = PRC03.TPPROD                                                                                           ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH233                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                               ") + msEnter
	RK002 += Alltrim("          ), 0)                                                                                                                              ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS03 PRC03                                                                                                             ") + msEnter
	RK002 += Alltrim("               INNER JOIN ITCUSF ITCF ON 1 = 1),                                                                                             ") + msEnter
	RK002 += Alltrim("      CFPROCESS05                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS212 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN CUS209 <> 0                                                                                               ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS209 * CUS210                                                                                  ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                         ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS213 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN CUS222 <> 0                                                                                               ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS222 * CUS211                                                                                  ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                         ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS235 = CASE                                                                                                               ") + msEnter
	RK002 += Alltrim("                              WHEN CUS233 <> 0                                                                                               ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS233 * CUS234                                                                                  ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                         ") + msEnter
	RK002 += Alltrim("                          END                                                                                                                ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS04),                                                                                                                 ") + msEnter
	RK002 += Alltrim("      CFPROCESS06                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS214 = CUS212 / CUS206,                                                                                                   ") + msEnter
	RK002 += Alltrim("                 CUS215 = CUS213 / CUS206,                                                                                                   ") + msEnter
	RK002 += Alltrim("                 CUS236 = CUS235 / CUS206                                                                                                    ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS05),                                                                                                                 ") + msEnter
	RK002 += Alltrim("      CFPROCESS07                                                                                                                            ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS216 = CUS214 + CUS215 + CUS236,                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS217 = CUS212 + CUS213 + CUS235                                                                                           ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS06)                                                                                                                  ") + msEnter
	RK002 += Alltrim("      SELECT *,                                                                                                                              ") + msEnter
	RK002 += Alltrim("             CUS223 = CUS206,                                                                                                                ") + msEnter
	RK002 += Alltrim("             CUS224 = CUS217                                                                                                                 ") + msEnter
	RK002 += Alltrim("      FROM CFPROCESS07                                                                                                                       ") + msEnter
	RK002 += Alltrim("      WHERE CUS217 <> 0                                                                                                                      ") + msEnter

Return( RK002 )

User Function BJZ677N2()

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z57_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z57") + " Z57(NOLOCK) "
	XP001 += " WHERE Z57_DATARF BETWEEN '" + Substr(dtos(MV_PAR01),1,4) + "0101' AND '" + Substr(dtos(MV_PAR01),1,4) + "1231' "
	XP001 += "       AND Z57.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	RK002 := Alltrim(" WITH ITCUSF                                                                                                                                   ") + msEnter
	RK002 += Alltrim("      AS (SELECT Z29_TIPO TIPO,                                                                                                                ") + msEnter
	RK002 += Alltrim("                 Z29_COD_IT ITCUS,                                                                                                             ") + msEnter
	RK002 += Alltrim("                 Z29_DRESUM DESCR                                                                                                              ") + msEnter
	RK002 += Alltrim("          FROM " + RetSqlName("Z29") + "  Z29(NOLOCK)                                                                                          ") + msEnter
	RK002 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                          ") + msEnter
	RK002 += Alltrim("                AND Z29_TIPO = 'CF'                                                                                                            ") + msEnter
	RK002 += Alltrim("                AND D_E_L_E_T_ = ' '),                                                                                                         ") + msEnter
	RK002 += Alltrim("      CFPROCESS01                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT DTREF = Z57.Z57_DATARF,                                                                                                       ") + msEnter
	RK002 += Alltrim("                 TPPROD = SB1.B1_TIPO,                                                                                                         ") + msEnter
	RK002 += Alltrim("                 PRODUT = Z57.Z57_PRODUT,                                                                                                      ") + msEnter
	RK002 += Alltrim("                 LINHA = Z57.Z57_LINHA,                                                                                                        ") + msEnter
	RK002 += Alltrim("                 LNH209 = '38' + SUBSTRING(Z57.Z57_LINHA, 2, 2),                                                                               ") + msEnter
	RK002 += Alltrim("                 LNH222 = '',                                                                                                                  ") + msEnter
	RK002 += Alltrim("                 LNH233 = '',                                                                                                                  ") + msEnter
	RK002 += Alltrim("                 PSECO = Z57.Z57_PSECO,                                                                                                        ") + msEnter
	RK002 += Alltrim("                 CUS200 = Z57.Z57_QTDRAC,                                                                                                      ") + msEnter
	RK002 += Alltrim("                 CUS201 =                                                                                                                      ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.Z57_QTDRAC)                                                                                                       ") + msEnter
	RK002 += Alltrim("              FROM " + RetSqlName("Z57") + "  XXX(NOLOCK)                                                                                      ") + msEnter
	RK002 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + "  QQQ ON QQQ.B1_COD = XXX.Z57_PRODUT                                                    ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.B1_TIPO = SB1.B1_TIPO                                                                      ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.D_E_L_E_T_ = ' '                                                                           ") + msEnter
	RK002 += Alltrim("              WHERE XXX.Z57_FILIAL = Z57.Z57_FILIAL                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_DATARF = Z57.Z57_DATARF                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_GMCD = Z57.Z57_GMCD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_SEQUEN = Z57.Z57_SEQUEN                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_LINHA = Z57.Z57_LINHA                                                                                          ") + msEnter
	RK002 += Alltrim("                    AND XXX.D_E_L_E_T_ = ' '                                                                                                   ") + msEnter
	RK002 += Alltrim("          ) / " + cUltDia + ",                                                                                                                 ") + msEnter
	RK002 += Alltrim("                 CUS202 = Z57.Z57_QTDRAC / (                                                                                                   ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.Z57_QTDRAC)                                                                                                       ") + msEnter
	RK002 += Alltrim("              FROM " + RetSqlName("Z57") + "  XXX(NOLOCK)                                                                                      ") + msEnter
	RK002 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + "  QQQ ON QQQ.B1_COD = XXX.Z57_PRODUT                                                    ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.B1_TIPO = SB1.B1_TIPO                                                                      ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.D_E_L_E_T_ = ' '                                                                           ") + msEnter
	RK002 += Alltrim("              WHERE XXX.Z57_FILIAL = Z57.Z57_FILIAL                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_DATARF = Z57.Z57_DATARF                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_GMCD = Z57.Z57_GMCD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_SEQUEN = Z57.Z57_SEQUEN                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_LINHA = Z57.Z57_LINHA                                                                                          ") + msEnter
	RK002 += Alltrim("                    AND XXX.D_E_L_E_T_ = ' '                                                                                                   ") + msEnter
	RK002 += Alltrim("          ) / " + cUltDia + "),                                                                                                                ") + msEnter
	RK002 += Alltrim("                 CUS203 =                                                                                                                      ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.Z57_QTDRAC)                                                                                                       ") + msEnter
	RK002 += Alltrim("              FROM " + RetSqlName("Z57") + "  XXX(NOLOCK)                                                                                      ") + msEnter
	RK002 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + "  QQQ ON QQQ.B1_COD = XXX.Z57_PRODUT                                                    ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.B1_TIPO = SB1.B1_TIPO                                                                      ") + msEnter
	RK002 += Alltrim("                                            AND QQQ.D_E_L_E_T_ = ' '                                                                           ") + msEnter
	RK002 += Alltrim("              WHERE XXX.Z57_FILIAL = Z57.Z57_FILIAL                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_DATARF = Z57.Z57_DATARF                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_GMCD = Z57.Z57_GMCD                                                                                            ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_SEQUEN = Z57.Z57_SEQUEN                                                                                        ") + msEnter
	RK002 += Alltrim("                    AND XXX.Z57_LINHA = Z57.Z57_LINHA                                                                                          ") + msEnter
	RK002 += Alltrim("                    AND XXX.D_E_L_E_T_ = ' '                                                                                                   ") + msEnter
	RK002 += Alltrim("          )                                                                                                                                    ") + msEnter
	RK002 += Alltrim("          FROM " + RetSqlName("Z57") + "  Z57(NOLOCK)                                                                                          ") + msEnter
	RK002 += Alltrim("               INNER JOIN " + RetSqlName("SB1") + "  SB1 ON SB1.B1_COD = Z57.Z57_PRODUT                                                        ") + msEnter
	RK002 += Alltrim("                                        AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	RK002 += Alltrim("          WHERE Z57.Z57_FILIAL = '" + xFilial("Z57") + "'                                                                                      ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_DATARF = '" + cDatFin + "'                                                                                         ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_GMCD = 'S'                                                                                                         ") + msEnter
	RK002 += Alltrim("                AND Z57.Z57_SEQUEN = '" + msSequenc + "'                                                                                       ") + msEnter
	RK002 += Alltrim("                AND Z57.D_E_L_E_T_ = ' '),                                                                                                     ") + msEnter
	RK002 += Alltrim("      CFPROCESS02                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS204 =                                                                                                                      ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                                ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("          ),                                                                                                                                   ") + msEnter
	RK002 += Alltrim("                 CUS205 = " + cUltDia + " /                                                                                                    ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                                ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("          ) * CUS202,                                                                                                                          ") + msEnter
	RK002 += Alltrim("                 CUS206 = CUS201 * (" + cUltDia + " /                                                                                          ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                                ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("          ) * CUS202),                                                                                                                         ") + msEnter
	RK002 += Alltrim("                 CUS207 = PSECO,                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS208 = (CUS201 * (" + cUltDia + " /                                                                                         ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS202)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS01 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC01.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LINHA = PRC01.LINHA                                                                                                ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC01.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("          ) * CUS202)) * PSECO                                                                                                                 ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS01 PRC01),                                                                                                             ") + msEnter
	RK002 += Alltrim("      CFPROCESS03                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS209 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC02.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH209 = PRC02.LNH209                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC02.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH209 <> ''                                                                                                       ") + msEnter
	RK002 += Alltrim("          ), 0)                                                                                                                                ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS02 PRC02),                                                                                                             ") + msEnter
	RK002 += Alltrim("      CFPROCESS04                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT ITCF.*,                                                                                                                       ") + msEnter
	RK002 += Alltrim("                 PRC03.*,                                                                                                                      ") + msEnter
	RK002 += Alltrim("                 CUS222 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC03.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH222 = PRC03.LNH222                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC03.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH222 <> ''                                                                                                       ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS233 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(XXX.CUS208)                                                                                                           ") + msEnter
	RK002 += Alltrim("              FROM CFPROCESS02 XXX(NOLOCK)                                                                                                     ") + msEnter
	RK002 += Alltrim("              WHERE XXX.DTREF = PRC03.DTREF                                                                                                    ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH233 = PRC03.LNH233                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.TPPROD = PRC03.TPPROD                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND XXX.LNH233 <> ''                                                                                                       ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS210 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR3)                                                                                                               ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ                                                                                                       ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '209'                                                                                                         ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH209                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                                 ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS211 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR3)                                                                                                               ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ                                                                                                       ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '222'                                                                                                         ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH222                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                                 ") + msEnter
	RK002 += Alltrim("          ), 0),                                                                                                                               ") + msEnter
	RK002 += Alltrim("                 CUS234 = ISNULL(                                                                                                              ") + msEnter
	RK002 += Alltrim("          (                                                                                                                                    ") + msEnter
	RK002 += Alltrim("              SELECT SUM(VALOR3)                                                                                                               ") + msEnter
	RK002 += Alltrim("              FROM " + ms1TbTemp + " JJJ                                                                                                       ") + msEnter
	RK002 += Alltrim("              WHERE JJJ.CONECT = '233'                                                                                                         ") + msEnter
	RK002 += Alltrim("                    AND JJJ.AGGRAT = PRC03.LNH233                                                                                              ") + msEnter
	RK002 += Alltrim("                    AND JJJ.ITCUS = ITCF.ITCUS                                                                                                 ") + msEnter
	RK002 += Alltrim("          ), 0)                                                                                                                                ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS03 PRC03                                                                                                               ") + msEnter
	RK002 += Alltrim("               INNER JOIN ITCUSF ITCF ON 1 = 1),                                                                                               ") + msEnter
	RK002 += Alltrim("      CFPROCESS05                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS212 = CASE                                                                                                                 ") + msEnter
	RK002 += Alltrim("                              WHEN CUS209 <> 0                                                                                                 ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS209 * CUS210                                                                                    ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                           ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                                 ") + msEnter
	RK002 += Alltrim("                 CUS213 = CASE                                                                                                                 ") + msEnter
	RK002 += Alltrim("                              WHEN CUS222 <> 0                                                                                                 ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS222 * CUS211                                                                                    ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                           ") + msEnter
	RK002 += Alltrim("                          END,                                                                                                                 ") + msEnter
	RK002 += Alltrim("                 CUS235 = CASE                                                                                                                 ") + msEnter
	RK002 += Alltrim("                              WHEN CUS233 <> 0                                                                                                 ") + msEnter
	RK002 += Alltrim("                              THEN CUS208 / CUS233 * CUS234                                                                                    ") + msEnter
	RK002 += Alltrim("                              ELSE 0                                                                                                           ") + msEnter
	RK002 += Alltrim("                          END                                                                                                                  ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS04),                                                                                                                   ") + msEnter
	RK002 += Alltrim("      CFPROCESS06                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS214 = CUS212 / CUS206,                                                                                                     ") + msEnter
	RK002 += Alltrim("                 CUS215 = CUS213 / CUS206,                                                                                                     ") + msEnter
	RK002 += Alltrim("                 CUS236 = CUS235 / CUS206                                                                                                      ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS05),                                                                                                                   ") + msEnter
	RK002 += Alltrim("      CFPROCESS07                                                                                                                              ") + msEnter
	RK002 += Alltrim("      AS (SELECT *,                                                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS216 = CUS214 + CUS215 + CUS236,                                                                                            ") + msEnter
	RK002 += Alltrim("                 CUS217 = CUS212 + CUS213 + CUS235                                                                                             ") + msEnter
	RK002 += Alltrim("          FROM CFPROCESS06)                                                                                                                    ") + msEnter
	RK002 += Alltrim("      SELECT *,                                                                                                                                ") + msEnter
	RK002 += Alltrim("             CUS223 = CUS206,                                                                                                                  ") + msEnter
	RK002 += Alltrim("             CUS224 = CUS217                                                                                                                   ") + msEnter
	RK002 += Alltrim("      FROM CFPROCESS07                                                                                                                         ") + msEnter
	RK002 += Alltrim("      WHERE CUS217 <> 0                                                                                                                        ") + msEnter	

Return( RK002 )

User Function BIA677N3()

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z57_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z57") + " Z57(NOLOCK) "
	XP001 += " WHERE Z57_DATARF BETWEEN '" + Substr(dtos(MV_PAR01),1,4) + "0101' AND '" + Substr(dtos(MV_PAR01),1,4) + "1231' "
	XP001 += "       AND Z57.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	KR003 := Alltrim(" WITH CVPROCESS01                                                                                            ") + msEnter
	KR003 += Alltrim("      AS (SELECT Z56_DATARF DTREF,                                                                           ") + msEnter
	KR003 += Alltrim("                 Z56_COD PRODUT,                                                                             ") + msEnter
	KR003 += Alltrim("                 Z56_ITCUS ITCUS,                                                                            ") + msEnter
	KR003 += Alltrim("                 SUM(Z56_M" + cMesRef + ") CUS218                                                            ") + msEnter
	KR003 += Alltrim("          FROM " + RetSqlName("Z56") + " Z56(NOLOCK)                                                         ") + msEnter
	KR003 += Alltrim("          WHERE Z56.Z56_FILIAL = '" + xFilial("Z56") + "'                                                    ") + msEnter
	KR003 += Alltrim("                AND Z56_DATARF = '" + cDatFin + "'                                                           ") + msEnter
	KR003 += Alltrim("                AND Z56_GMCD = 'S'                                                                           ") + msEnter
	KR003 += Alltrim("                AND Z56.D_E_L_E_T_ = ' '                                                                     ") + msEnter
	KR003 += Alltrim("          GROUP BY Z56_DATARF,                                                                               ") + msEnter
	KR003 += Alltrim("                   Z56_COD,                                                                                  ") + msEnter
	KR003 += Alltrim("                   Z56_ITCUS),                                                                               ") + msEnter
	KR003 += Alltrim("      CVPROCESS02                                                                                            ") + msEnter
	KR003 += Alltrim("      AS (SELECT *,                                                                                          ") + msEnter
	KR003 += Alltrim("                 CUS221 =                                                                                    ") + msEnter
	KR003 += Alltrim("          (                                                                                                  ") + msEnter
	KR003 += Alltrim("              SELECT SUM(Z57.Z57_QTDRAC)                                                                     ") + msEnter
	KR003 += Alltrim("              FROM " + RetSqlName("Z57") + " Z57(NOLOCK)                                                     ") + msEnter
	KR003 += Alltrim("              WHERE Z57.Z57_FILIAL = '" + xFilial("Z57") + "'                                                ") + msEnter
	KR003 += Alltrim("                    AND Z57.Z57_DATARF = CVP01.DTREF                                                         ") + msEnter
	KR003 += Alltrim("                    AND Z57.Z57_PRODUT = CVP01.PRODUT                                                        ") + msEnter
	KR003 += Alltrim("                    AND Z57.Z57_GMCD = 'S'                                                                   ") + msEnter
	KR003 += Alltrim("                    AND Z57.Z57_SEQUEN = '" + msSequenc + "'                                                 ") + msEnter
	KR003 += Alltrim("                    AND Z57.D_E_L_E_T_ = ' '                                                                 ") + msEnter
	KR003 += Alltrim("          )                                                                                                  ") + msEnter
	KR003 += Alltrim("          FROM CVPROCESS01 CVP01),                                                                           ") + msEnter
	KR003 += Alltrim("      CVPROCESS03                                                                                            ") + msEnter
	KR003 += Alltrim("      AS (SELECT *,                                                                                          ") + msEnter
	KR003 += Alltrim("                 CUS220 = CUS218 * CUS221                                                                    ") + msEnter
	KR003 += Alltrim("          FROM CVPROCESS02 CVP02),                                                                           ") + msEnter
	KR003 += Alltrim("      CVPROCESS04                                                                                            ") + msEnter
	KR003 += Alltrim("      AS (SELECT DTREF,                                                                                      ") + msEnter
	KR003 += Alltrim("                 PRODUT,                                                                                     ") + msEnter
	KR003 += Alltrim("                 REFERENCIA = SUBSTRING(PRODUT, 1, 7) + SPACE(8),                                            ") + msEnter
	KR003 += Alltrim("                 TPPROD = CASE                                                                               ") + msEnter
	KR003 += Alltrim("                              WHEN SUBSTRING(PRODUT, 8, 1) = ''                                              ") + msEnter
	KR003 += Alltrim("                              THEN 'PP'                                                                      ") + msEnter
	KR003 += Alltrim("                              ELSE 'PA'                                                                      ") + msEnter
	KR003 += Alltrim("                          END,                                                                               ") + msEnter
	KR003 += Alltrim("                 ITCUS = ITCUS,                                                                              ") + msEnter
	KR003 += Alltrim("                 TIPO = Z29_TIPO,                                                                            ") + msEnter
	KR003 += Alltrim("                 CUS218,                                                                                     ") + msEnter
	KR003 += Alltrim("                 CUS223 = CUS221,                                                                            ") + msEnter
	KR003 += Alltrim("                 CUS224 = CUS220                                                                             ") + msEnter
	KR003 += Alltrim("          FROM CVPROCESS03 CVPR03                                                                            ") + msEnter
	KR003 += Alltrim("               INNER JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "'     ") + msEnter
	KR003 += Alltrim("                                        AND Z29_COD_IT = ITCUS                                               ") + msEnter
	KR003 += Alltrim("                                        AND Z29.D_E_L_E_T_ = ' ')                                            ") + msEnter
	KR003 += Alltrim("      SELECT *                                                                                               ") + msEnter
	KR003 += Alltrim("      FROM CVPROCESS04 CVPR04                                                                                ") + msEnter

Return( KR003 )

User Function BIA677N4()

	KR004 := Alltrim(" WITH PRODCRET                                                                                                ") + msEnter
	KR004 += Alltrim("      AS (SELECT DISTINCT                                                                                     ") + msEnter
	KR004 += Alltrim("                 ZN8_DTREF,                                                                                   ") + msEnter
	KR004 += Alltrim("                 ZN8_PRODUT,                                                                                  ") + msEnter
	KR004 += Alltrim("                 ZN8_CUS223                                                                                   ") + msEnter
	KR004 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                          ") + msEnter
	KR004 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                         ") + msEnter
	KR004 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                 ") + msEnter
	KR004 += Alltrim("                AND SUBSTRING(ZN8_PRODUT, 1, 2) IN('B9', 'BO', 'C6')                                          ") + msEnter
	KR004 += Alltrim("          AND ZN8_TPCUS = 'CV'                                                                                ") + msEnter
	KR004 += Alltrim("          AND ZN8.D_E_L_E_T_ = ' '),                                                                          ") + msEnter
	KR004 += Alltrim("      PRODUCC1                                                                                                ") + msEnter
	KR004 += Alltrim("      AS (SELECT SUBSTRING(ZN8_PRODUT, 1, 7) + '1' + SPACE(7) PRODC1,                                         ") + msEnter
	KR004 += Alltrim("                 SUM(ZN8_CUS224 / ZN8_CUS223) CUSTMED                                                         ") + msEnter
	KR004 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                          ") + msEnter
	KR004 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                         ") + msEnter
	KR004 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                 ") + msEnter
	KR004 += Alltrim("                AND SUBSTRING(ZN8_PRODUT, 1, 2) = 'C1'                                                        ") + msEnter
	KR004 += Alltrim("                AND ZN8_TPPROD = 'PP'                                                                         ") + msEnter
	KR004 += Alltrim("                AND ZN8_CUS223 <> 0                                                                           ") + msEnter
	KR004 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                      ") + msEnter
	KR004 += Alltrim("          GROUP BY SUBSTRING(ZN8_PRODUT, 1, 7)),                                                              ") + msEnter
	KR004 += Alltrim("      PROCRT02                                                                                                ") + msEnter
	KR004 += Alltrim("      AS (SELECT ZN8_DTREF,                                                                                   ") + msEnter
	KR004 += Alltrim("                 ZN8_PRODUT,                                                                                  ") + msEnter
	KR004 += Alltrim("                 ZN8_CUS223,                                                                                  ") + msEnter
	KR004 += Alltrim("                 G1_COMP,                                                                                     ") + msEnter
	KR004 += Alltrim("                 G1_QUANT                                                                                     ") + msEnter
	KR004 += Alltrim("          FROM PRODCRET PRT                                                                                   ") + msEnter
	KR004 += Alltrim("               INNER JOIN " + RetSqlName("SG1") + " SG1(NOLOCK) ON G1_FILIAL = '" + xFilial("SG1") + "'       ") + msEnter
	KR004 += Alltrim("                                                AND G1_COD = ZN8_PRODUT                                       ") + msEnter
	KR004 += Alltrim("                                                AND SUBSTRING(G1_COMP, 1, 2) = 'C1'                           ") + msEnter
	KR004 += Alltrim("                                                AND SG1.D_E_L_E_T_ = ' ')                                     ") + msEnter
	KR004 += Alltrim("      SELECT *,                                                                                               ") + msEnter
	KR004 += Alltrim("             CUS223 = ZN8_CUS223,                                                                             ") + msEnter
	KR004 += Alltrim("             CUS224 = ZN8_CUS223 * CUSTMED                                                                    ") + msEnter
	KR004 += Alltrim("      FROM PROCRT02 PROC02                                                                                    ") + msEnter
	KR004 += Alltrim("           LEFT JOIN PRODUCC1 PRC1 ON PRC1.PRODC1 = PROC02.G1_COMP;                                           ") + msEnter

Return( KR004 )

User Function BIA677N5()

	KR005 := Alltrim(" WITH PRODCRET                                                                                                                 ") + msEnter
	KR005 += Alltrim("      AS (SELECT DISTINCT                                                                                                      ") + msEnter
	KR005 += Alltrim("                 ZN8_DTREF,                                                                                                    ") + msEnter
	KR005 += Alltrim("                 ZN8_PRODUT,                                                                                                   ") + msEnter
	KR005 += Alltrim("                 ZN8_CUS223,                                                                                                   ") + msEnter
	KR005 += Alltrim("                 ZN8.R_E_C_N_O_ REGZN8                                                                                         ") + msEnter
	KR005 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                           ") + msEnter
	KR005 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                          ") + msEnter
	KR005 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                                  ") + msEnter
	KR005 += Alltrim("                AND ZN8_TPCUS = 'CV'                                                                                           ") + msEnter
	KR005 += Alltrim("                AND ZN8_ITCUS = '065'                                                                                          ") + msEnter
	KR005 += Alltrim("                AND ZN8_CUS224 = 0                                                                                             ") + msEnter
	KR005 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '),                                                                                     ") + msEnter
	KR005 += Alltrim("      PROCC101                                                                                                                 ") + msEnter
	KR005 += Alltrim("      AS (SELECT PRT.*,                                                                                                        ") + msEnter
	KR005 += Alltrim("                 G1_COMP,                                                                                                      ") + msEnter
	KR005 += Alltrim("          (                                                                                                                    ") + msEnter
	KR005 += Alltrim("              SELECT MAX(Z57_DATARF)                                                                                           ") + msEnter
	KR005 += Alltrim("              FROM " + RetSqlName("Z57") + " Z57(NOLOCK)                                                                       ") + msEnter
	KR005 += Alltrim("              WHERE Z57_FILIAL = '" + xFilial("Z57") + "'                                                                      ") + msEnter
	KR005 += Alltrim("                    AND Z57_PRODUT = G1_COMP                                                                                   ") + msEnter
	KR005 += Alltrim("                    AND Z57_DATARF <= '" + cDatFin + "'                                                                        ") + msEnter
	KR005 += Alltrim("                    AND D_E_L_E_T_ = ' '                                                                                       ") + msEnter
	KR005 += Alltrim("          ) DTPROD                                                                                                             ") + msEnter
	KR005 += Alltrim("          FROM PRODCRET PRT                                                                                                    ") + msEnter
	KR005 += Alltrim("               INNER JOIN " + RetSqlName("SG1") + " SG1(NOLOCK) ON G1_FILIAL = '" + xFilial("SG1") + "'                        ") + msEnter
	KR005 += Alltrim("                                                AND G1_COD = ZN8_PRODUT                                                        ") + msEnter
	KR005 += Alltrim("                                                AND SUBSTRING(G1_COMP, 1, 2) = 'C1'                                            ") + msEnter
	KR005 += Alltrim("                                                AND SG1.D_E_L_E_T_ = ' ')                                                      ") + msEnter
	KR005 += Alltrim("      SELECT *,                                                                                                                ") + msEnter
	KR005 += Alltrim("      (                                                                                                                        ") + msEnter
	KR005 += Alltrim("          SELECT SUM(ZN8_CUS224 / ZN8_CUS223)                                                                                  ") + msEnter
	KR005 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                           ") + msEnter
	KR005 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                          ") + msEnter
	KR005 += Alltrim("                AND ZN8_DTREF BETWEEN SUBSTRING(DTPROD, 1, 6) + '01' AND DTPROD                                                ") + msEnter
	KR005 += Alltrim("                AND SUBSTRING(ZN8_PRODUT, 1, 7) = SUBSTRING(G1_COMP, 1, 7)                                                     ") + msEnter
	KR005 += Alltrim("                AND ZN8_TPPROD = 'PP'                                                                                          ") + msEnter
	KR005 += Alltrim("                AND ZN8_CUS223 <> 0                                                                                            ") + msEnter
	KR005 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                                       ") + msEnter
	KR005 += Alltrim("      ) MEDIO                                                                                                                  ") + msEnter
	KR005 += Alltrim("      FROM PROCC101                                                                                                            ") + msEnter

Return( KR005 )

User Function BIA677N6()

	KR006 := Alltrim(" SELECT DTREF = ZN8_DTREF,                                                                                    ") + msEnter
	KR006 += Alltrim("        CUS223 = SUM(ZN8_CUS223) * (-1),                                                                      ") + msEnter
	KR006 += Alltrim("        CUS224 = SUM(ZN8_CUS224) * (-1)                                                                       ") + msEnter
	KR006 += Alltrim(" FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                   ") + msEnter
	KR006 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                ") + msEnter
	KR006 += Alltrim("                                       AND B1_COD = ZN8_PRODUT                                                ") + msEnter
	KR006 += Alltrim("                                       AND B1_YFORMAT IN('B9', 'BO', 'C6')                                    ") + msEnter
	KR006 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                               ") + msEnter
	KR006 += Alltrim(" WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                  ") + msEnter
	KR006 += Alltrim("       AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                          ") + msEnter
	KR006 += Alltrim("       AND ZN8_ITCUS = '065'                                                                                  ") + msEnter
	KR006 += Alltrim("       AND ZN8.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	KR006 += Alltrim(" GROUP BY ZN8_DTREF                                                                                           ") + msEnter

Return( KR006 )

User Function BIA677N7()

	KR007 := Alltrim(" SELECT DTREF = ZN8_DTREF,                                                                                    ") + msEnter
	KR007 += Alltrim("        CUS223 = SUM(ZN8_CUS223) * (-1),                                                                      ") + msEnter
	KR007 += Alltrim("        CUS224 = SUM(ZN8_CUS224) * (-1)                                                                       ") + msEnter
	KR007 += Alltrim(" FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                   ") + msEnter
	KR007 += Alltrim(" WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                  ") + msEnter
	KR007 += Alltrim("       AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                          ") + msEnter
	KR007 += Alltrim("       AND ZN8_ITCUS = '070'                                                                                  ") + msEnter
	KR007 += Alltrim("       AND ZN8.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	KR007 += Alltrim(" GROUP BY ZN8_DTREF                                                                                           ") + msEnter

Return( KR007 )

User Function BIA677N8()

	KR008 := Alltrim(" WITH RAC001                                                                                                     ") + msEnter
	KR008 += Alltrim("      AS (SELECT ZN8_ITCUS ITCUS,                                                                                ") + msEnter
	KR008 += Alltrim("                 ZN8_TPPROD TPPROD                                                                               ") + msEnter
	KR008 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                             ") + msEnter
	KR008 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                            ") + msEnter
	KR008 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                    ") + msEnter
	KR008 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	KR008 += Alltrim("          GROUP BY ZN8_ITCUS,                                                                                    ") + msEnter
	KR008 += Alltrim("                   ZN8_TPPROD),                                                                                  ") + msEnter
	KR008 += Alltrim("      RAC002                                                                                                     ") + msEnter
	KR008 += Alltrim("      AS (SELECT ZN8_PRODUT PRODUTO,                                                                             ") + msEnter
	KR008 += Alltrim("                 ZN8_TPPROD TPPROD                                                                               ") + msEnter
	KR008 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                             ") + msEnter
	KR008 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                            ") + msEnter
	KR008 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                    ") + msEnter
	KR008 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	KR008 += Alltrim("          GROUP BY ZN8_PRODUT,                                                                                   ") + msEnter
	KR008 += Alltrim("                   ZN8_TPPROD),                                                                                  ") + msEnter
	KR008 += Alltrim("      RAC003                                                                                                     ") + msEnter
	KR008 += Alltrim("      AS (SELECT ZN8_PRODUT PRODUTO,                                                                             ") + msEnter
	KR008 += Alltrim("                 ZN8_TPPROD TPPROD,                                                                              ") + msEnter
	KR008 += Alltrim("                 ZN8_ITCUS ITCUS,                                                                                ") + msEnter
	KR008 += Alltrim("                 SUM(ZN8_CUS223) QUANT,                                                                          ") + msEnter
	KR008 += Alltrim("                 SUM(ZN8_CUS224) CUSTO1                                                                          ") + msEnter
	KR008 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                             ") + msEnter
	KR008 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                            ") + msEnter
	KR008 += Alltrim("                AND ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'                                    ") + msEnter
	KR008 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	KR008 += Alltrim("          GROUP BY ZN8_PRODUT,                                                                                   ") + msEnter
	KR008 += Alltrim("                   ZN8_TPPROD,                                                                                   ") + msEnter
	KR008 += Alltrim("                   ZN8_ITCUS),                                                                                   ") + msEnter
	KR008 += Alltrim("      RAC004                                                                                                     ") + msEnter
	KR008 += Alltrim("      AS (SELECT R002.PRODUTO,                                                                                   ") + msEnter
	KR008 += Alltrim("                 R002.TPPROD,                                                                                    ") + msEnter
	KR008 += Alltrim("                 R001.ITCUS,                                                                                     ") + msEnter
	KR008 += Alltrim("                 ISNULL(R003.QUANT, 0) QUANT,                                                                    ") + msEnter
	KR008 += Alltrim("                 ISNULL(R003.CUSTO1, 0) CUSTO1                                                                   ") + msEnter
	KR008 += Alltrim("          FROM RAC002 R002                                                                                       ") + msEnter
	KR008 += Alltrim("               INNER JOIN RAC001 R001 ON R001.TPPROD = R002.TPPROD                                               ") + msEnter
	KR008 += Alltrim("               LEFT JOIN RAC003 R003 ON R003.PRODUTO = R002.PRODUTO                                              ") + msEnter
	KR008 += Alltrim("                                        AND R003.TPPROD = R002.TPPROD                                            ") + msEnter
	KR008 += Alltrim("                                        AND R003.ITCUS = R001.ITCUS)                                             ") + msEnter
	KR008 += Alltrim("      SELECT '" + cDatFin + "' DTREF,                                                                            ") + msEnter
	KR008 += Alltrim("             R004.*,                                                                                             ") + msEnter
	KR008 += Alltrim("             Z29_TIPO                                                                                            ") + msEnter
	KR008 += Alltrim("      FROM RAC004 R004                                                                                           ") + msEnter
	KR008 += Alltrim("           LEFT JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "'              ") + msEnter
	KR008 += Alltrim("                                           AND Z29_COD_IT = R004.ITCUS                                           ") + msEnter
	KR008 += Alltrim("                                           AND Z29.D_E_L_E_T_ = ' '                                              ") + msEnter
	KR008 += Alltrim("      WHERE QUANT = 0                                                                                            ") + msEnter
	KR008 += Alltrim("            AND CUSTO1 = 0                                                                                       ") + msEnter
	KR008 += Alltrim("      ORDER BY R004.PRODUTO,                                                                                     ") + msEnter
	KR008 += Alltrim("               R004.TPPROD,                                                                                      ") + msEnter
	KR008 += Alltrim("               R004.ITCUS                                                                                        ") + msEnter

Return( KR008 )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA677I  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 12.03.21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime RAC Ajustada                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA677I()

	Processa({|| RptiDetail()})

Return

Static Function RptiDetail()

	cHInicio := Time()
	fPerg := "BIA677I"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidTPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	cDatIni := dtos(MV_PAR01)
	cDatFin := dtos(MV_PAR02) 

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Base para Cálculo do Custo Ajustado - RAC"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTREF"          ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "TPPROD"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUT"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LNH209"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LNH222"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LNH233"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PSECO"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ITCUS"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPCUS"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS200"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS201"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS202"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS203"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS204"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS205"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS206"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS207"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS208"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS209"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS210"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS211"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS212"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS213"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS214"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS215"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS216"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS217"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS218"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS219"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS220"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS221"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS222"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS223"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS224"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS225"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS230"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS231"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS232"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS233"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS234"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS235"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUS236"         ,3,2)	

	QR008 := Alltrim(" SELECT ZN8_FILIAL,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_DTREF,                                                         ") + msEnter
	QR008 += Alltrim("        ZN8_TPPROD,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_PRODUT,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_LINHA,                                                         ") + msEnter
	QR008 += Alltrim("        ZN8_LNH209,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_LNH222,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_LNH233,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_PSECO,                                                         ") + msEnter
	QR008 += Alltrim("        ZN8_ITCUS,                                                         ") + msEnter
	QR008 += Alltrim("        ZN8_TPCUS,                                                         ") + msEnter
	QR008 += Alltrim("        ZN8_CUS200,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS201,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS202,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS203,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS204,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS205,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS206,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS207,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS208,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS209,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS210,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS211,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS212,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS213,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS214,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS215,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS216,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS217,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS218,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS219,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS220,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS221,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS222,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS223,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS224,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS225,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS230,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS231,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS232,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS233,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS234,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS235,                                                        ") + msEnter
	QR008 += Alltrim("        ZN8_CUS236                                                         ") + msEnter
	QR008 += Alltrim(" FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                ") + msEnter
	QR008 += Alltrim(" WHERE ZN8.ZN8_FILIAL = '" + xFilial("ZN8") + "'                           ") + msEnter
	QR008 += Alltrim("       AND ZN8.ZN8_DTREF BETWEEN '" + cDatIni + "' AND '" + cDatFin + "'   ") + msEnter
	QR008 += Alltrim("       AND ZN8.D_E_L_E_T_ = ' '                                            ") + msEnter
	QR008 += Alltrim(" ORDER BY ZN8_DTREF,                                                       ") + msEnter
	QR008 += Alltrim("          ZN8_PRODUT,                                                      ") + msEnter
	QR008 += Alltrim("          ZN8_TPPROD,                                                      ") + msEnter
	QR008 += Alltrim("          ZN8_TPCUS,                                                       ") + msEnter
	QR008 += Alltrim("          ZN8_ITCUS                                                        ") + msEnter
	QRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR008),'QR08',.F.,.T.)
	dbSelectArea("QR08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { QR08->ZN8_FILIAL ,;
		stod(QR08->ZN8_DTREF) ,;
		QR08->ZN8_TPPROD ,;
		QR08->ZN8_PRODUT ,;
		QR08->ZN8_LINHA  ,;
		QR08->ZN8_LNH209 ,;
		QR08->ZN8_LNH222 ,;
		QR08->ZN8_LNH233 ,;
		QR08->ZN8_PSECO  ,;
		QR08->ZN8_ITCUS  ,;
		QR08->ZN8_TPCUS  ,;
		QR08->ZN8_CUS200 ,;
		QR08->ZN8_CUS201 ,;
		QR08->ZN8_CUS202 ,;
		QR08->ZN8_CUS203 ,;
		QR08->ZN8_CUS204 ,;
		QR08->ZN8_CUS205 ,;
		QR08->ZN8_CUS206 ,;
		QR08->ZN8_CUS207 ,;
		QR08->ZN8_CUS208 ,;
		QR08->ZN8_CUS209 ,;
		QR08->ZN8_CUS210 ,;
		QR08->ZN8_CUS211 ,;
		QR08->ZN8_CUS212 ,;
		QR08->ZN8_CUS213 ,;
		QR08->ZN8_CUS214 ,;
		QR08->ZN8_CUS215 ,;
		QR08->ZN8_CUS216 ,;
		QR08->ZN8_CUS217 ,;
		QR08->ZN8_CUS218 ,;
		QR08->ZN8_CUS219 ,;
		QR08->ZN8_CUS220 ,;
		QR08->ZN8_CUS221 ,;
		QR08->ZN8_CUS222 ,;
		QR08->ZN8_CUS223 ,;
		QR08->ZN8_CUS224 ,;
		QR08->ZN8_CUS225 ,;
		QR08->ZN8_CUS230 ,;
		QR08->ZN8_CUS231 ,;
		QR08->ZN8_CUS232 ,;
		QR08->ZN8_CUS233 ,;
		QR08->ZN8_CUS234 ,;
		QR08->ZN8_CUS235 ,;
		QR08->ZN8_CUS236 })

		dbSelectArea("QR08")
		dbSkip()

	End

	QR08->(dbCloseArea())
	Ferase(QRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QRcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "rac - ajustada - " + cEmpAnt + " - " + dtos(MV_PAR01) + " - " + dtos(MV_PAR02)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Dt Ini p/ Fechamento?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Fim p/ Fechamento?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Versão Orçamentária ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Revisão Ativa       ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano de Referência   ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidTPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Dt Ini p/ Fechamento?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Fim p/ Fechamento?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
