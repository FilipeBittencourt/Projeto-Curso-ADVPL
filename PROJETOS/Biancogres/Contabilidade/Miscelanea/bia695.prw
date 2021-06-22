#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA695
@author Marcos Alberto Soprani
@since 02/06/21
@version 1.0
@description Cópia da Versão BP ORÇADO para a REVISÃO 01 (apelido ORÇADO): todas as empresa e a 90 como um todo.
@type function
@Obs Projeto A-35
/*/

User Function BIA695()

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

	Private cTitulo := "Cópia de Versão BP ORÇADO para REVISÃO 01 (apelido ORÇADO)"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If cEmpAnt == "90" .and. cFilAnt == "90"

		If oPerg:Pergunte()

			oEmp:GetSelEmp()

			If Len(oEmp:aEmpSel) > 0

				Begin Transaction

					For nW := 1 To Len(oEmp:aEmpSel)

						xVerRet := .F.
						Processa({ || fExistTabl(RetFullName("ZOV", oEmp:aEmpSel[nW][1])) }, "Aguarde...", "Verificando tabela ZOV na empresa: " + oEmp:aEmpSel[nW][1], .F.)
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
							MsgSTOP(xxMensErr, "BIA695")

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

		MsgALERT("Este processamento somente poderá ser feito dentro da empresa 90 filial 90", "BIA695")
		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		BeginSql Alias M001
			%NoParser%
			SELECT ZOV_FILIAL CODFIL, 
			COUNT(*) CONTAD
			FROM %TABLE:ZOV% ZOV(NOLOCK)
			WHERE ZOV.ZOV_VERSAO = %Exp:oPerg:cVersao%
			AND ZOV.ZOV_REVISA = %Exp:oPerg:cRevisa%
			AND ZOV.ZOV_ANOREF = %Exp:oPerg:cAnoRef%
			AND ZOV.%NotDel%
			GROUP BY ZOV_FILIAL
		EndSql

		msRegsProc += msEnter
		While (M001)->(!Eof())

			msRegsProc += "Empresa " + (M001)->CODFIL + ", registros: " + Alltrim(Str((M001)->CONTAD)) + msEnter
			msTotRegs += (M001)->CONTAD
			(M001)->(dbSkip())

		EndDo

		msRegsProc += msEnter + "Total Geral: " + Alltrim(Str(msTotRegs)) + msEnter

		(M001)->(dbCloseArea())

		MsgINFO(msRegsProc, "BIA695")

	Else

		MsgSTOP("Processamento Abortado", "BIA695")

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
		%NoParser%
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5(NOLOCK)
		WHERE ZB5.ZB5_VERSAO = %Exp:cVersao%
		AND ZB5.ZB5_REVISA = %Exp:cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:cAnoRef%
		AND ZB5.ZB5_TPORCT = 'CONTABIL            '
		AND ZB5.ZB5_VERCON = 'B01'
		AND ZB5.%NotDel%
	EndSql

	If (M001)->CONTAD <> 1

		msGravaErr := "A Versão Orçamentária não corresponde a Versão BP Original. Favor rever o cadastro de Versão!!!"
		MsgSTOP(msGravaErr, "BIA695")
		xVerRet := lRet 
		Return

	EndIf

	(M001)->(dbCloseArea())

	MP007 := " SELECT COUNT(*) CONTAD "
	MP007 += "   FROM " + RetFullName("ZOV", cEmp) + " ZOV(NOLOCK) "
	MP007 += "  WHERE ZOV.ZOV_VERSAO = '" + cVersao + "' "
	MP007 += "    AND ZOV.ZOV_REVISA = '" + cRevisa + "' "
	MP007 += "    AND ZOV.ZOV_ANOREF = '" + cAnoRef + "' "
	MP007 += "    AND ZOV.ZOV_VERCON = 'C01' "
	MP007 += "    AND ZOV.D_E_L_E_T_ = ' ' "
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

			If MsgYESNO(msMsgCtrl, "BIA695")

				UP007 := " DELETE ZOV "
				UP007 += " FROM " + RetFullName("ZOV", cEmp) + " ZOV "
				UP007 += " WHERE ZOV.ZOV_VERSAO = " + ValToSQL(cVersao)
				UP007 += "       AND ZOV.ZOV_REVISA = " + ValToSQL(cRevisa)
				UP007 += "       AND ZOV.ZOV_ANOREF = " + ValToSQL(cAnoRef)
				UP007 += "       AND ZOV.ZOV_VERCON = 'C01' "
				UP007 += "       AND ZOV.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Zerando registros ZOV... ",,{|| msStaExcQy := TcSQLExec(UP007) })
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

		_cCampTab := ""
		_cIntoCam := ""

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("ZOV")

		While !Eof() .and. SX3->X3_ARQUIVO == "ZOV" 

			If SX3->X3_CONTEXT <> "V"

				If "MESREF" $ Alltrim(SX3->X3_CAMPO) 
					_cCampTab += StrTran( Alltrim(SX3->X3_CAMPO),"ZOV","ZOD" ) + " = CONVERT(VARCHAR, EOMONTH(ZOD.ZOD_DATA), 112), "

				ElseIf "VERCON" $ Alltrim(SX3->X3_CAMPO) 
					_cCampTab += StrTran( Alltrim(SX3->X3_CAMPO),"ZOV","ZOD" ) + " = 'C01', "

				Else
					_cCampTab += StrTran( Alltrim(SX3->X3_CAMPO),"ZOV","ZOD" ) + ", "

				EndIf

				_cIntoCam += Alltrim(SX3->X3_CAMPO) + ", "

			EndIf

			dbSelectArea("SX3")
			dbSkip()

		End

		_cCampTab += " ZOD.D_E_L_E_T_, ZOD.R_E_C_D_E_L_, (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetFullName("ZOV", cEmp) + ") + ROW_NUMBER() OVER(ORDER BY ZOD.R_E_C_N_O_) AS R_E_C_N_O_"
		_cIntoCam += " D_E_L_E_T_, R_E_C_D_E_L_, R_E_C_N_O_ "

		UP002 := " INSERT INTO " + RetFullName("ZOV", cEmp) + "( " + _cIntoCam + " )"
		UP002 += " SELECT " + _cCampTab + " "
		UP002 += " FROM " + RetFullName("ZOD", cEmp) + " ZOD(NOLOCK) "
		UP002 += "      INNER JOIN ZB5010 ZB5(NOLOCK) ON ZB5_VERSAO = ZOD_VERSAO "
		UP002 += "                                       AND ZB5_REVISA = ZOD_REVISA "
		UP002 += "                                       AND ZB5_ANOREF = ZOD_ANOREF "
		UP002 += "                                       AND ZB5_TPORCT = 'CONTABIL' "
		UP002 += "                                       AND ZB5_VERCON = 'B01' "
		UP002 += "                                       AND ZB5.D_E_L_E_T_ = ' ' "
		UP002 += " WHERE ZOD.ZOD_VERSAO = " + ValToSQL(cVersao)
		UP002 += "       AND ZOD.ZOD_REVISA = " + ValToSQL(cRevisa)
		UP002 += "       AND ZOD.ZOD_ANOREF = " + ValToSQL(cAnoRef)
		UP002 += "       AND ZOD_TIPO = '2'
		UP002 += "       AND NOT EXISTS "
		UP002 += "       ( "
		UP002 += "           SELECT NULL "
		UP002 += "           FROM " + RetFullName("ZOV", cEmp) + " A(NOLOCK) "
		UP002 += "           WHERE A.ZOV_FILIAL = ZOD.ZOD_FILIAL "
		UP002 += "	              AND A.ZOV_VERSAO = ZOD.ZOD_VERSAO "
		UP002 += "	              AND A.ZOV_REVISA = ZOD.ZOD_REVISA "
		UP002 += "	              AND A.ZOV_ANOREF = ZOD.ZOD_ANOREF "
		UP002 += "	              AND A.ZOV_VERCON = 'C01' "
		UP002 += "	              AND A.D_E_L_E_T_ = ' ' "
		UP002 += "       ) "
		UP002 += "       AND ZOD.D_E_L_E_T_ 	= ' ' "
		U_BIAMsgRun("Aguarde... Gravando registros ZOV... ",,{|| msStaExcQy := TcSQLExec(UP002) })
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
	cSql += " FROM INFORMATION_SCHEMA.TABLES A(NOLOCK)
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
