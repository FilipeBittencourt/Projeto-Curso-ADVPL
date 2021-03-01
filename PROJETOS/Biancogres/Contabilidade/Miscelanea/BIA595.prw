#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA595
@author Wlysses Cerqueira (Facile)
@since 26/10/2020
@version 1.0
@description Consolidação das empresas na empresa Consolidada 90 e filial 90. 
@type function
@Obs Projeto A-35
/*/

User Function BIA595()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local oPerg	:= Nil
	Local cMsg  := ""
	Local M001  := GetNextAlias()

	Private msEnter    := CHR(13) + CHR(10)
	Private msRegsProc := "Fim do processamento:" + msEnter + msEnter
	Private msTotRegs  := 0
	Private msGravaErr := ""
	Private msCanPrc   := .F.

	Private cTitulo := "Consolidação Orçamento Grupo"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If cEmpAnt == "90"

		If oPerg:Pergunte()

			oEmp:GetSelEmp({"90"})

			If Len(oEmp:aEmpSel) > 0

				Begin Transaction

					For nW := 1 To Len(oEmp:aEmpSel)

						If oEmp:aEmpSel[nW][1] <> "90"

							xVerRet := .F.
							Processa({ || fExistTabl(RetFullName("ZBZ", oEmp:aEmpSel[nW][1])) }, "Aguarde...", "Verificando OrcaFinal na empresa: " + oEmp:aEmpSel[nW][1], .F.)
							If xVerRet

								Processa({ || fProcessa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
								lRet := xVerRet 

							Else

								msRegsProc += "Empresa " + oEmp:aEmpSel[nW][1] + ", registros: 0" + msEnter

							EndIf

							If !lRet

								DisarmTransaction()

								xxMensErr := "Encontrado problema ao efetuar a cópia dos dados da empresa " + oEmp:aEmpSel[nW][1] + ":" + msEnter + msEnter
								xxMensErr += msGravaErr + msEnter + msEnter
								xxMensErr += "Processo cancelado. Favor abrir ticket anexando o erro apresentado!!!"
								MsgSTOP(xxMensErr, "BIA595")

								msCanPrc  := .T.
								Exit

							EndIf

						EndIf

					Next nW

				End Transaction

			EndIf

		Else

			msCanPrc  := .T.

		EndIf

	Else

		MsgALERT("Este processamento somente poderá ser feito dentro da empresa 90", "BIA595")
		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		BeginSql Alias M001
			%NoParser%
			SELECT ZBZ_FILIAL CODFIL, 
			COUNT(*) CONTAD
			FROM %TABLE:ZBZ% ZBZ(NOLOCK)
			WHERE ZBZ.ZBZ_VERSAO = %Exp:oPerg:cVersao%
			AND ZBZ.ZBZ_REVISA = %Exp:oPerg:cRevisa%
			AND ZBZ.ZBZ_ANOREF = %Exp:oPerg:cAnoRef%
			AND ZBZ.%NotDel%
			GROUP BY ZBZ_FILIAL
		EndSql

		msRegsProc += msEnter
		While (M001)->(!Eof())

			msRegsProc += "Empresa " + (M001)->CODFIL + ", registros: " + Alltrim(Str((M001)->CONTAD)) + msEnter
			msTotRegs += (M001)->CONTAD
			(M001)->(dbSkip())

		EndDo

		msRegsProc += msEnter + "Total Geral: " + Alltrim(Str(msTotRegs)) + msEnter

		(M001)->(dbCloseArea())

		MsgINFO(msRegsProc, "BIA595")

	Else

		MsgSTOP("Processamento Abortado", "BIA595")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet        := .F.
	Local lProsseg    := .F.
	Local xProsseg    := ""
	Local msStaExcQy  := 0
	Local lOk         := .T.
	Local M001        := GetNextAlias()

	Default cMsg := ""

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZBZ% ZBZ
		WHERE ZBZ.ZBZ_VERSAO = %Exp:cVersao%
		AND ZBZ.ZBZ_REVISA = %Exp:cRevisa%
		AND ZBZ.ZBZ_ANOREF = %Exp:cAnoRef%
		AND ZBZ.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 0

		msMsgCtrl := "Já existem registros gravados para a Versão Orçamentária informada." + msEnter + msEnter
		msMsgCtrl += "Deseja prosseguir?" + msEnter + msEnter
		msMsgCtrl += "Se confirmar, o sistema efetuará de deleção de todos os registros desta Versão, inclusive os ajustes/expurgos manuais" + msEnter + msEnter
		msMsgCtrl += "Sabendo desta prerrogativa, ainda assim deseja prosseguir?" + msEnter + msEnter

		If MsgYESNO(msMsgCtrl, "BIA595")

			UP007 := " DELETE ZBZ "
			UP007 += " FROM " + RetSqlName("ZBZ") + " ZBZ "
			UP007 += " WHERE ZBZ.ZBZ_VERSAO = " + ValToSQL(cVersao)
			UP007 += "       AND ZBZ.ZBZ_REVISA = " + ValToSQL(cRevisa)
			UP007 += "       AND ZBZ.ZBZ_ANOREF = " + ValToSQL(cAnoRef)
			UP007 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Zerando registros ZBZ... ",,{|| msStaExcQy := TcSQLExec(UP007) })
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
	(M001)->(dbCloseArea())

	If lProsseg

		_cCampTab := ""
		_cIntoCam := ""

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("ZBZ")

		While !Eof() .and. SX3->X3_ARQUIVO == "ZBZ" 

			If SX3->X3_CONTEXT <> "V"

				If "FILIAL" $ Alltrim(SX3->X3_CAMPO) 
					_cCampTab += Alltrim(SX3->X3_CAMPO) + " = '" + cEmp + "', "
				Else
					_cCampTab += Alltrim(SX3->X3_CAMPO) + ", "
				EndIf

				_cIntoCam += Alltrim(SX3->X3_CAMPO) + ", "

			EndIf

			dbSelectArea("SX3")
			dbSkip()

		End

		_cCampTab += " D_E_L_E_T_, R_E_C_D_E_L_, (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("ZBZ") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_"
		_cIntoCam += " D_E_L_E_T_, R_E_C_D_E_L_, R_E_C_N_O_ "

		UP002 := " INSERT INTO " + RetSqlName("ZBZ") + "( " + _cIntoCam + " )"
		UP002 += " SELECT " + _cCampTab + " "
		UP002 += " FROM " + RetFullName("ZBZ", cEmp) + " ZBZ "
		UP002 += " WHERE ZBZ.ZBZ_VERSAO = " + ValToSQL(cVersao)
		UP002 += "       AND ZBZ.ZBZ_REVISA = " + ValToSQL(cRevisa)
		UP002 += "       AND ZBZ.ZBZ_ANOREF = " + ValToSQL(cAnoRef)
		UP002 += "       AND NOT EXISTS "
		UP002 += "       ( "
		UP002 += "           SELECT NULL "
		UP002 += "           FROM " + RetSQLName("ZBZ") + " A "
		UP002 += "           WHERE A.ZBZ_FILIAL = " + ValToSQL(cEmp)
		UP002 += "	              AND A.ZBZ_VERSAO = ZBZ.ZBZ_VERSAO "
		UP002 += "       	        AND A.ZBZ_REVISA = ZBZ.ZBZ_REVISA "
		UP002 += "       	        AND A.ZBZ_ANOREF = ZBZ.ZBZ_ANOREF "
		UP002 += "                 AND A.D_E_L_E_T_ = ' ' "
		UP002 += "       ) "
		UP002 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Gravando registros ZBF... ",,{|| msStaExcQy := TcSQLExec(UP002) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			lRet := .T.

		Else

			msGravaErr := TCSQLError()

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
	cSql += " FROM INFORMATION_SCHEMA.TABLES
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
