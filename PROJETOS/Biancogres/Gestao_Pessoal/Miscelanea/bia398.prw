#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA398
@author Marcos Alberto Soprani
@since 04/10/17
@version 1.0
@description Rotina de gravação do Orçamento de RH em base contábel orçamentária   
@type function
/*/

User Function BIA398()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA398"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
	M0007 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
	M0007 += "    AND ZBZ.ZBZ_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBZ.ZBZ_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'RH' "
	M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe base contábel orçamentária para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBZ") + " "
			KS001 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
			KS001 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
			KS001 += "    AND ZBZ.ZBZ_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBZ.ZBZ_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'RH' "
			KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	Processa({ || cMsg := BIA398A() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function BIA398A()

	Local mxFx

	UJ007 := " SELECT *, "
	UJ007 += "        (SELECT COUNT(*) "
	UJ007 += "           FROM " + RetSqlName("ZBC") + " ZBC "
	UJ007 += "          WHERE ZBC.ZBC_FILIAL = '" + xFilial("ZBC") + "' "
	UJ007 += "            AND ZBC.ZBC_VERSAO = '" + _cVersao + "' "
	UJ007 += "            AND ZBC.ZBC_REVISA = '" + _cRevisa + "' "
	UJ007 += "            AND ZBC.ZBC_ANOREF = '" + _cAnoRef + "' "
	UJ007 += "            AND ZBC.D_E_L_E_T_ = ' ') NREGS "
	UJ007 += "   FROM " + RetSqlName("ZBC") + " ZBC "
	UJ007 += "  WHERE ZBC.ZBC_FILIAL = '" + xFilial("ZBC") + "' "
	UJ007 += "    AND ZBC.ZBC_VERSAO = '" + _cVersao + "' "
	UJ007 += "    AND ZBC.ZBC_REVISA = '" + _cRevisa + "' "
	UJ007 += "    AND ZBC.ZBC_ANOREF = '" + _cAnoRef + "' "
	UJ007 += "    AND ZBC.D_E_L_E_T_ = ' ' "
	UJ007 += "  ORDER BY ZBC_ORDEM "
	UJIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,UJ007),'UJ07',.T.,.T.)
	dbSelectArea("UJ07")
	UJ07->(dbGoTop())

	xtrTot := UJ07->(NREGS)
	ProcRegua(xtrTot)

	If UJ07->(!Eof())

		While UJ07->(!Eof())

			IncProc("Rubrica: " + UJ07->ZBC_DRUBRI + ", " + AllTrim(Str(UJ07->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			TS003 := " WITH RHTODESP AS (SELECT ZBA.ZBA_ANOREF + ZBA.ZBA_PERIOD + '01' PERIODO, "
			TS003 += "                          ZBA.ZBA_CLVL CLVL, "
			TS003 += "                          CTH.CTH_YATRIB ATRIB, "
			TS003 += "                          CASE "
			TS003 += "                            WHEN CTH.CTH_YATRIB = 'D' THEN ZBC.ZBC_CTADES "
			TS003 += "                            WHEN CTH.CTH_YATRIB = 'C' THEN ZBC.ZBC_CTACST "
			TS003 += "                            ELSE 'ERRO' "
			TS003 += "                          END CONTA, "
			TS003 += "                          ZBA." + UJ07->ZBC_RUBRIC + " VALOR "
			TS003 += "                     FROM " + RetSqlName("ZBA") + " ZBA "
			TS003 += "                    INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH.CTH_CLVL = ZBA.ZBA_CLVL "
			TS003 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
			TS003 += "                    INNER JOIN " + RetSqlName("ZBC") + " ZBC ON ZBC.ZBC_FILIAL = '" + xFilial("ZBC") + "' "
			TS003 += "                                         AND ZBC.ZBC_VERSAO = ZBA.ZBA_VERSAO "
			TS003 += "                                         AND ZBC.ZBC_REVISA = ZBA.ZBA_REVISA "
			TS003 += "                                         AND ZBC.ZBC_ANOREF = ZBA.ZBA_ANOREF "
			TS003 += "                                         AND ZBC.ZBC_RUBRIC = '" + UJ07->ZBC_RUBRIC + "' "
			TS003 += "                                         AND ZBC.D_E_L_E_T_ = ' ' "
			TS003 += "                    WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
			TS003 += "                      AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
			TS003 += "                      AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
			TS003 += "                      AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
			TS003 += "                      AND ZBA.ZBA_PERIOD <> '00' "
			TS003 += "                      AND ZBA." + UJ07->ZBC_RUBRIC + " <> 0 "
			TS003 += "                      AND ZBA.D_E_L_E_T_ = ' ') "
			TS003 += " SELECT PERIODO, "
			TS003 += "        CLVL, "
			TS003 += "        ATRIB, "
			TS003 += "        CONTA, "
			TS003 += "        SUM(VALOR) VALOR "
			TS003 += "   FROM RHTODESP "
			TS003 += "  GROUP BY PERIODO, "
			TS003 += "           CLVL, "
			TS003 += "           ATRIB, "
			TS003 += "           CONTA "
			TSIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,TS003),'TS03',.T.,.T.)
			dbSelectArea("TS03")
			TS03->(dbGoTop())

			If TS03->(!Eof())

				While TS03->(!Eof())

					IncProc("Rubrica: " + Alltrim(UJ07->ZBC_DRUBRI) + ", " + AllTrim(Str(UJ07->(Recno()))) + " de " + AllTrim(Str(xtrTot)) + ". Orct RH: " + AllTrim(Str(TS03->(Recno()))) )

					Reclock("ZBZ",.T.)
					ZBZ->ZBZ_FILIAL := xFilial("ZBZ") 
					ZBZ->ZBZ_VERSAO := _cVersao
					ZBZ->ZBZ_REVISA := _cRevisa
					ZBZ->ZBZ_ANOREF := _cAnoRef
					ZBZ->ZBZ_ORIPRC := "RH"
					ZBZ->ZBZ_ORGLAN := "D"
					ZBZ->ZBZ_DATA   := UltimoDia(stod(TS03->PERIODO))
					ZBZ->ZBZ_LOTE   := "004700"
					ZBZ->ZBZ_SBLOTE := "001"
					ZBZ->ZBZ_DOC    := StrZero(UJ07->(Recno()),6)
					ZBZ->ZBZ_LINHA  := StrZero(TS03->(Recno()),3)
					ZBZ->ZBZ_DC     := "1"
					ZBZ->ZBZ_DEBITO := TS03->CONTA
					ZBZ->ZBZ_CREDIT := ""
					ZBZ->ZBZ_CLVLDB := TS03->CLVL
					ZBZ->ZBZ_CLVLCR := ""
					ZBZ->ZBZ_ITEMD  := ""
					ZBZ->ZBZ_ITEMC  := ""
					ZBZ->ZBZ_VALOR  := TS03->VALOR
					ZBZ->ZBZ_HIST   := "ORCTO RH" 
					ZBZ->ZBZ_YHIST  := "ORCAMENTO RH"
					ZBZ->ZBZ_SI     := ""
					ZBZ->ZBZ_YDELTA := ctod("  /  /  ")
					ZBZ->(MsUnlock())

					TS03->(dbSkip())

				EndDo

			EndIf	

			TS03->(dbCloseArea())
			Ferase(TSIndex+GetDBExtension())
			Ferase(TSIndex+OrdBagExt())

			UJ07->(dbSkip())

		EndDo

	EndIf	

	UJ07->(dbCloseArea())
	Ferase(UJIndex+GetDBExtension())
	Ferase(UJIndex+OrdBagExt())

	If MsgYESNO("Confirma o Fechamento da Versão para o Módulo RH? Importante verificar se não há outra filial pra ser processada.", "Fechamento de Versão")

		ZP001 := " UPDATE " + RetSqlName("ZB5") + " SET ZB5_STATUS = 'F' "
		ZP001 += "   FROM " + RetSqlName("ZB5") + " ZB5 "
		ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
		ZP001 += "    AND ZB5.ZB5_VERSAO = '" + _cVersao + "' "
		ZP001 += "    AND ZB5.ZB5_REVISA = '" + _cRevisa + "' "
		ZP001 += "    AND ZB5.ZB5_ANOREF = '" + _cAnoRef + "' "
		ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'RH' "
		ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Fechando Versão Orçamentária ... ",,{|| TcSQLExec(ZP001) })

		MsgINFO("A versão orçamentária para o modelo RH está fechada para esta empresa neste momento. Caso necessite efetuar qualquer reprocessamento é necessário acionar a controladoria para que a mesma efetue o cancelamento desta integração!!!")

	EndIf

	MsgINFO("... Fim do Processamento ...")

Return

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
