#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA691
@author Marcos Alberto Soprani
@since 21/02/2021
@version 1.0
@description Processando Versão Orçamentária Projetada 
@type function
@Obs Projeto A-35
/*/

User Function BIA691()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local cMsg  := ""

	Private msEnter    := CHR(13) + CHR(10)
	Private msRegsProc := "Fim do processamento:" + msEnter + msEnter
	Private msTotRegs  := 0
	Private msGravaErr := ""
	Private msCanPrc   := .F.

	Private cTitulo := "Processando Versão Orçamentária Projetada"

	fPerg := "BIA691"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	msPergT := .T.
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		msPergT := .F.
	EndIf
	cVersao   := MV_PAR01   
	cRevisa   := MV_PAR02
	cAnoRef   := MV_PAR03
	cMesRef   := MV_PAR04

	oEmp := TLoadEmpresa():New()

	If cEmpAnt == "90" .and. cFilAnt == "90"

		If msPergT

			oEmp:GetSelEmp()

			If Len(oEmp:aEmpSel) > 0

				Begin Transaction

					For nW := 1 To Len(oEmp:aEmpSel)

						xVerRet := .F.
						Processa({ || fExistTabl(RetFullName("ZOZ", oEmp:aEmpSel[nW][1])) }, "Aguarde...", "Verificando tabela ZOZ na empresa: " + oEmp:aEmpSel[nW][1], .F.)
						If xVerRet

							xVerRet := .F.
							Processa({ || fExistTabl(RetFullName("CT2", oEmp:aEmpSel[nW][1])) }, "Aguarde...", "Verificando tabela CT2 na empresa: " + oEmp:aEmpSel[nW][1], .F.)
							If xVerRet

								xVerRet := .F.
								Processa({ || fExistTabl(RetFullName("ZBZ", oEmp:aEmpSel[nW][1])) }, "Aguarde...", "Verificando tabela ZBZ na empresa: " + oEmp:aEmpSel[nW][1], .F.)
								If xVerRet

									Processa({ || fProcessa(oEmp:aEmpSel[nW][1], cVersao, cRevisa, cAnoRef, cMesRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
									lRet := xVerRet 

								EndIf

							EndIf

						EndIf

						If !lRet

							DisarmTransaction()

							xxMensErr := "Encontrado problema ao efetuar a cópia dos dados da empresa " + oEmp:aEmpSel[nW][1] + ":" + msEnter + msEnter
							xxMensErr += msGravaErr + msEnter + msEnter
							xxMensErr += "Processo cancelado. Favor abrir ticket anexando o erro apresentado!!!"
							MsgSTOP(xxMensErr, "BIA691")

							msCanPrc  := .T.
							Exit

						EndIf

					Next nW

				End Transaction

			EndIf

		Else

			msCanPrc  := .T.

		EndIf

	Else

		MsgALERT("Este processamento somente poderá ser feito dentro da empresa 90 filial 90", "BIA691")
		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		MsgINFO("Processamento realizado com sucesso", "BIA691")

	Else

		MsgSTOP("Processamento Abortado", "BIA691")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, cMesRef, cMsg)

	Local lRet        := .F.
	Local lProsseg    := .F.
	Local xProsseg    := ""
	Local msStaExcQy  := 0
	Local lOk         := .T.

	Default cMsg := ""

	xDtOrcaI := cAnoRef + cMesRef + '01'
	xDtOrcaF := cAnoRef + '1231'

	MP007 := " SELECT COUNT(*) CONTAD "
	MP007 += "   FROM " + RetFullName("ZOZ", cEmp) + " ZOZ(NOLOCK) "
	MP007 += "  WHERE ZOZ.ZOZ_VERSAO = '" + cVersao + "' "
	MP007 += "    AND ZOZ.ZOZ_REVISA = '" + cRevisa + "' "
	MP007 += "    AND ZOZ.ZOZ_ANOREF = '" + cAnoRef + "' "
	MP007 += "    AND ZOZ.ZOZ_VERCON = 'E" + cMesRef + "' "
	MP007 += "    AND ZOZ.D_E_L_E_T_ = ' ' "
	MPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MP007),'MP07',.T.,.T.)
	dbSelectArea("MP07")
	MP07->(dbGoTop())
	If MP07->(!Eof())

		If MP07->(CONTAD) <> 0

			msMsgCtrl := "Já existem registros gravados para a Versão Orçamentária informada." + msEnter + msEnter
			msMsgCtrl += "Deseja prosseguir?" + msEnter + msEnter
			msMsgCtrl += "Se confirmar, o sistema efetuará de deleção de todos os registros desta Versão, inclusive os ajustes/expurgos manuais" + msEnter + msEnter
			msMsgCtrl += "Sabendo desta prerrogativa, ainda assim deseja prosseguir?" + msEnter + msEnter

			If MsgYESNO(msMsgCtrl, "BIA691")

				UP007 := " DELETE ZOZ "
				UP007 += " FROM " + RetFullName("ZOZ", cEmp) + " ZOZ "
				UP007 += " WHERE ZOZ.ZOZ_VERSAO = " + ValToSQL(cVersao)
				UP007 += "       AND ZOZ.ZOZ_REVISA = " + ValToSQL(cRevisa)
				UP007 += "       AND ZOZ.ZOZ_ANOREF = " + ValToSQL(cAnoRef)
				UP007 += "       AND ZOZ.ZOZ_VERCON = 'E" + cMesRef + "' "
				UP007 += "       AND ZOZ.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Zerando registros ZOZ... ",,{|| msStaExcQy := TcSQLExec(UP007) })
				If !msStaExcQy < 0

					lProsseg := .T.

				Else

					xProsseg := "Erro ao efetuar a deleção dos registros"

				EndIf		

			Else

				xProsseg := "Não foi autorizada a exclusão dos registros existentes "

			EndIf

		Else

			lProsseg := .T.

		EndIf

	EndIf
	MP07->(dbCloseArea())
	Ferase(MPIndex+GetDBExtension())
	Ferase(MPIndex+OrdBagExt())

	If lProsseg

		UP002 := " WITH ORCTOPROJ "
		UP002 += "      AS (SELECT ZBZ_FILIAL, "
		UP002 += "                 ZBZ_VERSAO, "
		UP002 += "                 ZBZ_REVISA, "
		UP002 += "                 ZBZ_ANOREF, "
		UP002 += "                 'PROJETADO' ZBZ_ORIPRC, "
		UP002 += "                 ZBZ_ORGLAN, "
		UP002 += "                 SUBSTRING(ZBZ_DATA, 1, 6) + '01' ZBZ_DATA, "
		UP002 += "                 '' ZBZ_LOTE, "
		UP002 += "                 '' ZBZ_SBLOTE, "
		UP002 += "                 '' ZBZ_DOC, "
		UP002 += "                 '' ZBZ_LINHA, "
		UP002 += "                 ZBZ_DC, "
		UP002 += "                 ZBZ_DEBITO, "
		UP002 += "                 ZBZ_CREDIT, "
		UP002 += "                 ZBZ_CLVLDB, "
		UP002 += "                 ZBZ_CLVLCR, "
		UP002 += "                 SUM(ZBZ_VALOR) ZBZ_VALOR, "
		UP002 += "                 'PROCESSAMENTO PROJETADO - ORCADO' ZBZ_HIST, "
		UP002 += "                 'PROCESSAMENTO PROJETADO - ORCADO' ZBZ_YHIST, "
		UP002 += "                 '' ZBZ_ITEMD, "
		UP002 += "                 '' ZBZ_ITEMC, "
		UP002 += "                 '' ZBZ_SI, "
		UP002 += "                 '' ZBZ_YDELTA, "
		UP002 += "                 '' ZBZ_ORIPR2, "
		UP002 += "                 '' ZBZ_APLIC, "
		UP002 += "                 '' ZBZ_DRVDB, "
		UP002 += "                 '' ZBZ_DRVCR, "
		UP002 += "                 '' D_E_L_E_T_, "
		UP002 += "                 0 R_E_C_N_O_, "
		UP002 += "                 0 R_E_C_D_E_L_, "
		UP002 += "                 SUBSTRING(ZBZ_DATA, 1, 6) + '01' ZBZ_MESREF, "
		UP002 += "                 'E" + cMesRef + "' ZBZ_VERCON "
		UP002 += "          FROM " + RetFullName("ZBZ", cEmp) + " ZBZ(NOLOCK) "
		UP002 += "          WHERE ZBZ.ZBZ_VERSAO = '" + cVersao + "' "
		UP002 += "                AND ZBZ.ZBZ_REVISA = '" + cRevisa + "' "
		UP002 += "                AND ZBZ.ZBZ_ANOREF = '" + cAnoRef + "' "
		UP002 += "                AND ZBZ.ZBZ_DATA BETWEEN '" + xDtOrcaI + "' AND '" + xDtOrcaF + "' "
		UP002 += "                AND NOT EXISTS "
		UP002 += "          ( "
		UP002 += "              SELECT NULL "
		UP002 += "              FROM " + RetFullName("ZOZ", cEmp) + " A(NOLOCK) "
		UP002 += "              WHERE A.ZOZ_FILIAL = ZBZ.ZBZ_FILIAL "
		UP002 += "                    AND A.ZOZ_VERSAO = ZBZ.ZBZ_VERSAO "
		UP002 += "                    AND A.ZOZ_REVISA = ZBZ.ZBZ_REVISA "
		UP002 += "                    AND A.ZOZ_ANOREF = ZBZ.ZBZ_ANOREF "
		UP002 += "                    AND SUBSTRING(A.ZOZ_DATA, 1, 6) = SUBSTRING(ZBZ.ZBZ_DATA, 1, 6) "
		UP002 += "                    AND A.ZOZ_VERCON = 'E" + cMesRef + "' "
		UP002 += "                    AND A.D_E_L_E_T_ = ' ' "
		UP002 += "          ) "
		UP002 += "                AND ZBZ.D_E_L_E_T_ = ' ' "
		UP002 += "          GROUP BY ZBZ_FILIAL, "
		UP002 += "                   ZBZ_VERSAO, "
		UP002 += "                   ZBZ_REVISA, "
		UP002 += "                   ZBZ_ANOREF, "
		UP002 += "                   ZBZ_ORGLAN, "
		UP002 += "                   SUBSTRING(ZBZ_DATA, 1, 6), "
		UP002 += "                   ZBZ_DC, "
		UP002 += "                   ZBZ_DEBITO, "
		UP002 += "                   ZBZ_CREDIT, "
		UP002 += "                   ZBZ_CLVLDB, "
		UP002 += "                   ZBZ_CLVLCR) "
		UP002 += "      INSERT INTO " + RetFullName("ZOZ", cEmp) + " (ZOZ_FILIAL,ZOZ_VERSAO,ZOZ_REVISA,ZOZ_ANOREF,ZOZ_ORIPRC,ZOZ_ORGLAN,ZOZ_DATA,ZOZ_LOTE,ZOZ_SBLOTE,ZOZ_DOC,ZOZ_LINHA,ZOZ_DC,ZOZ_DEBITO,ZOZ_CREDIT,ZOZ_CLVLDB,ZOZ_CLVLCR,ZOZ_VALOR,ZOZ_HIST,ZOZ_YHIST,ZOZ_ITEMD,ZOZ_ITEMC,ZOZ_SI,ZOZ_YDELTA,ZOZ_ORIPR2,ZOZ_APLIC,ZOZ_DRVDB,ZOZ_DRVCR,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_,ZOZ_MESREF,ZOZ_VERCON) "
		UP002 += "      SELECT ZBZ_FILIAL, "
		UP002 += "             ZBZ_VERSAO, "
		UP002 += "             ZBZ_REVISA, "
		UP002 += "             ZBZ_ANOREF, "
		UP002 += "             ZBZ_ORIPRC, "
		UP002 += "             ZBZ_ORGLAN, "
		UP002 += "             ZBZ_DATA, "
		UP002 += "             ZBZ_LOTE, "
		UP002 += "             ZBZ_SBLOTE, "
		UP002 += "             ZBZ_DOC, "
		UP002 += "             ZBZ_LINHA, "
		UP002 += "             ZBZ_DC, "
		UP002 += "             ZBZ_DEBITO, "
		UP002 += "             ZBZ_CREDIT, "
		UP002 += "             ZBZ_CLVLDB, "
		UP002 += "             ZBZ_CLVLCR, "
		UP002 += "             ZBZ_VALOR, "
		UP002 += "             ZBZ_HIST, "
		UP002 += "             ZBZ_YHIST, "
		UP002 += "             ZBZ_ITEMD, "
		UP002 += "             ZBZ_ITEMC, "
		UP002 += "             ZBZ_SI, "
		UP002 += "             ZBZ_YDELTA, "
		UP002 += "             ZBZ_ORIPR2, "
		UP002 += "             ZBZ_APLIC, "
		UP002 += "             ZBZ_DRVDB, "
		UP002 += "             ZBZ_DRVCR, "
		UP002 += "             D_E_L_E_T_, "
		UP002 += "      ( "
		UP002 += "          SELECT MAX(R_E_C_N_O_) "
		UP002 += "          FROM " + RetFullName("ZOZ", cEmp) + "(NOLOCK) "
		UP002 += "      ) + ROW_NUMBER() OVER( "
		UP002 += "             ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
		UP002 += "             R_E_C_D_E_L_, "
		UP002 += "             ZBZ_MESREF, "
		UP002 += "             ZBZ_VERCON "
		UP002 += "      FROM ORCTOPROJ "
		U_BIAMsgRun("Aguarde... Gravando registros ZOZ... ",,{|| msStaExcQy := TcSQLExec(UP002) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			lRet := .T.

		Else

			msGravaErr := TCSQLError()

		EndIf

		If lRet

			If cMesRef > "01"

				xDtInRea := cAnoRef + '0101'
				xDtFiRea := dtos(UltimoDia(stod(cAnoRef + StrZero((Val(cMesRef) - 1),2) + '01')))

				UP003 := " WITH REATOPROJ "
				UP003 += "      AS (SELECT CT2_FILIAL,  "
				UP003 += "                 'D' CT2_ORGLAN,  "
				UP003 += "                 SUBSTRING(CT2_DATA, 1, 6) + '01' CT2_DATA,  "
				UP003 += "                 '1' CT2_DC,  "
				UP003 += "                 CT2_DEBITO,  "
				UP003 += "                 '' CT2_CREDIT,  "
				UP003 += "                 CT2_CLVLDB,  "
				UP003 += "                 '' CT2_CLVLCR,  "
				UP003 += "                 SUM(CT2_VALOR) CT2_VALOR "
				UP003 += "          FROM " + RetFullName("CT2", cEmp) + " CT2(NOLOCK) "
				UP003 += "          WHERE CT2.CT2_DATA BETWEEN '" + xDtInRea + "' AND '" + xDtFiRea + "' "
				UP003 += "                AND CT2_DEBITO <> '' "
				UP003 += "                AND CT2.D_E_L_E_T_ = ' ' "
				UP003 += "          GROUP BY CT2_FILIAL,  "
				UP003 += "                   SUBSTRING(CT2_DATA, 1, 6),  "
				UP003 += "                   CT2_DEBITO,  "
				UP003 += "                   CT2_CLVLDB "
				UP003 += "          UNION ALL "
				UP003 += "          SELECT CT2_FILIAL,  "
				UP003 += "                 'D' CT2_ORGLAN,  "
				UP003 += "                 SUBSTRING(CT2_DATA, 1, 6) + '01' CT2_DATA,  "
				UP003 += "                 '2' CT2_DC,  "
				UP003 += "                 '' CT2_DEBITO,  "
				UP003 += "                 CT2_CREDIT,  "
				UP003 += "                 '' CT2_CLVLDB,  "
				UP003 += "                 CT2_CLVLCR,  "
				UP003 += "                 SUM(CT2_VALOR) CT2_VALOR "
				UP003 += "          FROM " + RetFullName("CT2", cEmp) + " CT2(NOLOCK) "
				UP003 += "          WHERE CT2.CT2_DATA BETWEEN '" + xDtInRea + "' AND '" + xDtFiRea + "' "
				UP003 += "                AND CT2_DEBITO <> '' "
				UP003 += "                AND CT2.D_E_L_E_T_ = ' ' "
				UP003 += "          GROUP BY CT2_FILIAL,  "
				UP003 += "                   SUBSTRING(CT2_DATA, 1, 6),  "
				UP003 += "                   CT2_CREDIT,  "
				UP003 += "                   CT2_CLVLCR) "
				UP003 += "      INSERT INTO " + RetFullName("ZOZ", cEmp) + " (ZOZ_FILIAL,ZOZ_VERSAO,ZOZ_REVISA,ZOZ_ANOREF,ZOZ_ORIPRC,ZOZ_ORGLAN,ZOZ_DATA,ZOZ_LOTE,ZOZ_SBLOTE,ZOZ_DOC,ZOZ_LINHA,ZOZ_DC,ZOZ_DEBITO,ZOZ_CREDIT,ZOZ_CLVLDB,ZOZ_CLVLCR,ZOZ_VALOR,ZOZ_HIST,ZOZ_YHIST,ZOZ_ITEMD,ZOZ_ITEMC,ZOZ_SI,ZOZ_YDELTA,ZOZ_ORIPR2,ZOZ_APLIC,ZOZ_DRVDB,ZOZ_DRVCR,D_E_L_E_T_,R_E_C_N_O_,R_E_C_D_E_L_,ZOZ_MESREF,ZOZ_VERCON) "
				UP003 += "      SELECT CT2_FILIAL,  "
				UP003 += "             '" + cVersao + "' CT2_VERSAO,  "
				UP003 += "             '" + cRevisa + "' CT2_REVISA,  "
				UP003 += "             '" + cAnoRef + "' CT2_ANOREF,  "
				UP003 += "             'PROJETADO' CT2_ORIPRC,  "
				UP003 += "             CT2_ORGLAN,  "
				UP003 += "             CT2_DATA,  "
				UP003 += "             '' CT2_LOTE,  "
				UP003 += "             '' CT2_SBLOTE,  "
				UP003 += "             '' CT2_DOC,  "
				UP003 += "             '' CT2_LINHA,  "
				UP003 += "             CT2_DC,  "
				UP003 += "             CT2_DEBITO,  "
				UP003 += "             CT2_CREDIT,  "
				UP003 += "             CT2_CLVLDB,  "
				UP003 += "             CT2_CLVLCR,  "
				UP003 += "             CT2_VALOR,  "
				UP003 += "             'PROCESSAMENTO PROJETADO - REALIZADO' CT2_HIST,  "
				UP003 += "             'PROCESSAMENTO PROJETADO - REALIZADO' CT2_YHIST,  "
				UP003 += "             '' CT2_ITEMD,  "
				UP003 += "             '' CT2_ITEMC,  "
				UP003 += "             '' CT2_SI,  "
				UP003 += "             '' CT2_YDELTA,  "
				UP003 += "             '' CT2_ORIPR2,  "
				UP003 += "             '' CT2_APLIC,  "
				UP003 += "             '' CT2_DRVDB,  "
				UP003 += "             '' CT2_DRVCR,  "
				UP003 += "             '' D_E_L_E_T_,  "
				UP003 += "      ( "
				UP003 += "          SELECT MAX(R_E_C_N_O_) "
				UP003 += "          FROM " + RetFullName("ZOZ", cEmp) + "(NOLOCK) "
				UP003 += "      ) + ROW_NUMBER() OVER( "
				UP003 += "             ORDER BY CT2_FILIAL) AS R_E_C_N_O_,  "
				UP003 += "             0 R_E_C_D_E_L_,  "
				UP003 += "             CT2_DATA CT2_MESREF,  "
				UP003 += "             'E" + cMesRef + "' CT2_VERCON "
				UP003 += "      FROM REATOPROJ "
				U_BIAMsgRun("Aguarde... Gravando registros ZOZ... ",,{|| msStaExcQy := TcSQLExec(UP002) })
				If msStaExcQy < 0
					lOk := .F.
				EndIf

				If lOk

					lRet := .T.

				Else

					msGravaErr := TCSQLError()

				EndIf

			EndIf

		EndIf

	Else

		msGravaErr := "Problema com o controle de registros existentes: " + xProsseg

	EndIf

	xVerRet := lRet 

Return

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES A(NOLOCK)
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Mês REF p/ Projetado     ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

	RestArea(_sAlias)

Return
