#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA646
@author Marcos Alberto Soprani
@since 04/10/17
@version 1.0
@description Rotina de processamento e gravação do desdobramento do Orçamento de RECEITA em meses  
@type function
/*/

User Function BIA646()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA646"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cMarca    := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco e menor ou igual DataBase" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTENCR = ''
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
	M0007 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	M0007 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	M0007 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
	M0007 += "    AND ZBH.ZBH_PERIOD <> '00' "
	M0007 += "    AND ZBH.ZBH_ORIGF = '5' "
	M0007 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe desdobramento da Versão informada." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados desdobrados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBH") + " "
			KS001 += "   FROM " + RetSqlName("ZBH") + " ZBH "
			KS001 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
			KS001 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
			KS001 += "    AND ZBH.ZBH_PERIOD <> '00' "
			KS001 += "    AND ZBH.ZBH_ORIGF = '5' "
			KS001 += "    AND ZBH.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBH... ",,{|| TcSQLExec(KS001) })

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

	Processa({ || cMsg := BIA646A() }, "Aguarde...", "Carregando dados...", .F.)

Return

Static Function BIA646A()

	Local mxFx
	Local msDtProc  := Date()
	Local msHrProc  := Time()
	Local M002        := GetNextAlias()

	ProcRegua(0)

	BeginSql Alias M002
		SELECT ZBJ_CANALD
		FROM %TABLE:ZBJ% ZBJ
		WHERE ZBJ.%NotDel%
	EndSql
	(M002)->(dbGoTop())
	If !(M002)->(Eof())

		ProcRegua(0)
		While !(M002)->(Eof())

			mtCanald := (M002)->ZBJ_CANALD 
			While !(M002)->(Eof()) .and. (M002)->ZBJ_CANALD == mtCanald

				For mxFx := 1 to 12

					IncProc("Carregando dados. CANALD: " + mtCanald + " MES: " + AllTrim(StrZero(mxFx,2)))

					YH007 := " WITH RECINTEG AS (SELECT ZBH_FILIAL, "
					YH007 += "                          ZBH_VERSAO, "
					YH007 += "                          ZBH_REVISA, "
					YH007 += "                          ZBH_ANOREF, "
					YH007 += "                          ZBH_PERIOD, "
					YH007 += "                          ZBH_MARCA, "
					YH007 += "                          '" + mtCanald + "' ZBH_CANALD, "
					YH007 += "                          ZBH_VEND, "
					YH007 += "                          ZBH_GRPCLI, "
					YH007 += "                          ZBH_TPSEG, "
					YH007 += "                          ZBH_ESTADO, "
					YH007 += "                          ZBH_PCTGMR, "
					YH007 += "                          ZBH_FORMAT, "
					YH007 += "                          ZBH_CATEG, "
					YH007 += "                          ZBH_CLASSE, "
					YH007 += "                          ZBH_QUANT, "
					YH007 += "                          ZBH_VALOR, "
					YH007 += "                          ZBH_ORIGF, "
					YH007 += "                          (SELECT ISNULL(ZBI_M" + Alltrim(StrZero(mxFx,2)) + ", 0) "
					YH007 += "                             FROM " + RetSqlName("ZBI") + " "
					YH007 += "                            WHERE ZBI_VERSAO = ZBH_VERSAO "
					YH007 += "                              AND ZBI_REVISA = ZBH_REVISA "
					YH007 += "                              AND ZBI_ANOREF = ZBH_ANOREF "
					YH007 += "                              AND ZBI_MARCA = ZBH_MARCA "
					YH007 += "                              AND ZBI_TPFLUT = '1' "
					YH007 += "                              AND ZBI_PCTGMR = ZBH_PCTGMR "
					YH007 += "                              AND ZBI_FORMAT = ZBH_FORMAT "
					YH007 += "                              AND D_E_L_E_T_ = ' ') QTDFLUT, "
					YH007 += "                          1 + (SELECT ISNULL(ZBI_M" + Alltrim(StrZero(mxFx,2)) + ", 0) / 100 "
					YH007 += "                                 FROM " + RetSqlName("ZBI") + " "
					YH007 += "                                WHERE ZBI_VERSAO = ZBH_VERSAO "
					YH007 += "                                  AND ZBI_REVISA = ZBH_REVISA "
					YH007 += "                                  AND ZBI_ANOREF = ZBH_ANOREF "
					YH007 += "                                  AND ZBI_MARCA = ZBH_MARCA "
					YH007 += "                                  AND ZBI_TPFLUT = '2' "
					YH007 += "                                  AND ZBI_PCTGMR = ZBH_PCTGMR "
					YH007 += "                                  AND ZBI_FORMAT = ZBH_FORMAT "
					YH007 += "                                  AND D_E_L_E_T_ = ' ') VLRFLUT "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH_ORIGF = '1' "
					YH007 += "                      AND EXISTS (SELECT * "
					YH007 += "                                    FROM " + RetSqlName("ZBK") + " XZBK "
					YH007 += "                                   WHERE XZBK.ZBK_FILIAL = ZBH.ZBH_FILIAL "
					YH007 += "                                     AND XZBK.ZBK_VERSAO = ZBH.ZBH_VERSAO "
					YH007 += "                                     AND XZBK.ZBK_REVISA = ZBH.ZBH_REVISA "
					YH007 += "                                     AND XZBK.ZBK_ANOREF = ZBH.ZBH_ANOREF "
					YH007 += "                                     AND XZBK.ZBK_MARCA = ZBH.ZBH_MARCA "
					YH007 += "                                     AND XZBK.ZBK_VEND = ZBH.ZBH_VEND "
					YH007 += "                                     AND XZBK.ZBK_GRPCLI = ZBH.ZBH_GRPCLI "
					YH007 += "                                     AND XZBK.ZBK_TPSEG = ZBH.ZBH_TPSEG "
					YH007 += "                                     AND XZBK.ZBK_ESTADO = ZBH.ZBH_ESTADO "
					YH007 += "                                     AND XZBK.ZBK_PCTGMR = ZBH.ZBH_PCTGMR "
					YH007 += "                                     AND XZBK.ZBK_FORMAT = ZBH.ZBH_FORMAT "
					YH007 += "                                     AND XZBK.ZBK_CATEG = ZBH.ZBH_CATEG "
					YH007 += "                                     AND XZBK.ZBK_CAN" + mtCanald + " <> 0 "
					YH007 += "                                     AND XZBK.D_E_L_E_T_ = ' ' ) "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "
					YH007 += " ,    PCOMISSAO AS(SELECT ZBH_FILIAL FILIAL, "
					YH007 += "                          ZBH_VERSAO VERSAO, "
					YH007 += "                          ZBH_REVISA REVISA, "
					YH007 += "                          ZBH_ANOREF ANOREF, "
					YH007 += "                          ZBH_PERIOD PERIODO, "
					YH007 += "                          ZBH_MARCA MARCA, "
					YH007 += "                          ZBH_VEND VEND, "
					YH007 += "                          ZBH_PCTGMR PCTGMR, "
					YH007 += "                          ZBH_CATEG CATEG, "
					YH007 += "                          ZBH_PCOMIS / 100 PCOMIS "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH.ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH.ZBH_ORIGF = '2' "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "
					YH007 += " ,    PIMPOSTOS AS(SELECT ZBH_FILIAL FILIAL, "
					YH007 += "                          ZBH_VERSAO VERSAO, "
					YH007 += "                          ZBH_REVISA REVISA, "
					YH007 += "                          ZBH_ANOREF ANOREF, "
					YH007 += "                          ZBH_PERIOD PERIODO, "
					YH007 += "                          ZBH_MARCA MARCA, "
					YH007 += "                          ZBH_CANALD CANALD, "
					YH007 += "                          ZBH_TPSEG TPSEG, "
					YH007 += "                          ZBH_ESTADO ESTADO, "
					YH007 += "                          ZBH_PCTGMR PCTGMR, "
					YH007 += "                          ZBH_PICMS / 100 PICMS, "
					YH007 += "                          ZBH_PPIS / 100 PPIS, "
					YH007 += "                          ZBH_PCOF / 100 PCOF, "
					YH007 += "                          ZBH_PST / 100 PST, "
					YH007 += "                          ZBH_PDIFAL / 100 PDIFAL "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH.ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH.ZBH_ORIGF = '3' "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "
					YH007 += " ,    PMETAVER AS(SELECT ZBH_FILIAL FILIAL, "
					YH007 += "                          ZBH_VERSAO VERSAO, "
					YH007 += "                          ZBH_REVISA REVISA, "
					YH007 += "                          ZBH_ANOREF ANOREF, "
					YH007 += "                          ZBH_PERIOD PERIODO, "
					YH007 += "                          ZBH_MARCA MARCA, "
					YH007 += "                          ZBH_GRPCLI GRPCLI, "
					YH007 += "                          ZBH_TPSEG TPSEG, "
					YH007 += "                          ZBH_PERVER PERVER, "
					YH007 += "                          ZBH_PERBON PERBON, "															
					YH007 += "                          ZBH_METVER METVER "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH.ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH.ZBH_ORIGF = '6' "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "
					YH007 += " ,    PPRZMET AS(SELECT ZBH_FILIAL FILIAL, "
					YH007 += "                          ZBH_VERSAO VERSAO, "
					YH007 += "                          ZBH_REVISA REVISA, "
					YH007 += "                          ZBH_ANOREF ANOREF, "
					YH007 += "                          ZBH_PERIOD PERIODO, "
					YH007 += "                          ZBH_MARCA MARCA, "
					YH007 += "                          ZBH_GRPCLI GRPCLI, "
					YH007 += "                          ZBH_VEND VEND, "					
					YH007 += "                          ZBH_PRZMET PRZMET "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH.ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH.ZBH_ORIGF = '7' "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "		
					YH007 += " ,    PCPV AS(SELECT ZBH_FILIAL FILIAL, "
					YH007 += "                          ZBH_VERSAO VERSAO, "
					YH007 += "                          ZBH_REVISA REVISA, "
					YH007 += "                          ZBH_ANOREF ANOREF, "
					YH007 += "                          ZBH_PERIOD PERIODO, "
					YH007 += "                          ZBH_MARCA MARCA, "
					YH007 += "                          ZBH_PERCPV PERCPV "
					YH007 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
					YH007 += "                    WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
					YH007 += "                      AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
					YH007 += "                      AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
					YH007 += "                      AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
					YH007 += "                      AND ZBH.ZBH_PERIOD = '00' "
					YH007 += "                      AND ZBH.ZBH_ORIGF = '8' "
					YH007 += "                      AND ZBH.D_E_L_E_T_ = ' ') "								
					YH007 += " SELECT RITG.*, "
					YH007 += "        PCOMIS, "
					YH007 += "        PICMS, "
					YH007 += "        PPIS, "
					YH007 += "        PCOF, "
					YH007 += "        PST, "
					YH007 += "        METVER, "
					YH007 += "        PRZMET, "
					YH007 += "        PERVER, "	
					YH007 += "        PERBON, "
					YH007 += "        PERCPV, "																						
					YH007 += "        PDIFAL "
					YH007 += "   FROM RECINTEG RITG "
					YH007 += "   LEFT JOIN PCOMISSAO PCM ON PCM.FILIAL = RITG.ZBH_FILIAL "
					YH007 += "                          AND PCM.VERSAO = RITG.ZBH_VERSAO "
					YH007 += "                          AND PCM.REVISA = RITG.ZBH_REVISA "
					YH007 += "                          AND PCM.ANOREF = RITG.ZBH_ANOREF "
					YH007 += "                          AND PCM.PERIODO = RITG.ZBH_PERIOD "
					YH007 += "                          AND PCM.MARCA =  RITG.ZBH_MARCA " 
					YH007 += "                          AND PCM.VEND = RITG.ZBH_VEND "
					YH007 += "                          AND PCM.PCTGMR = RITG.ZBH_PCTGMR "
					YH007 += "                          AND PCM.CATEG = RITG.ZBH_CATEG " 
					YH007 += "   LEFT JOIN PIMPOSTOS PIM ON PIM.FILIAL = RITG.ZBH_FILIAL "
					YH007 += "                          AND PIM.VERSAO = RITG.ZBH_VERSAO "
					YH007 += "                          AND PIM.REVISA = RITG.ZBH_REVISA "
					YH007 += "                          AND PIM.ANOREF = RITG.ZBH_ANOREF "
					YH007 += "                          AND PIM.PERIODO = RITG.ZBH_PERIOD "
					YH007 += "                          AND PIM.MARCA =  RITG.ZBH_MARCA " 
					YH007 += "                          AND PIM.CANALD = RITG.ZBH_CANALD "
					YH007 += "                          AND PIM.TPSEG = RITG.ZBH_TPSEG "
					YH007 += "                          AND PIM.ESTADO = RITG.ZBH_ESTADO "
					YH007 += "                          AND PIM.PCTGMR = RITG.ZBH_PCTGMR "
					YH007 += "   LEFT JOIN PMETAVER PMV ON PMV.FILIAL = RITG.ZBH_FILIAL "
					YH007 += "                          AND PMV.VERSAO = RITG.ZBH_VERSAO "
					YH007 += "                          AND PMV.REVISA = RITG.ZBH_REVISA "
					YH007 += "                          AND PMV.ANOREF = RITG.ZBH_ANOREF "
					YH007 += "                          AND PMV.PERIODO = RITG.ZBH_PERIOD "
					YH007 += "                          AND PMV.MARCA =  RITG.ZBH_MARCA " 
					YH007 += "                          AND PMV.GRPCLI = RITG.ZBH_GRPCLI "
					YH007 += "                          AND PMV.TPSEG = RITG.ZBH_TPSEG "
					YH007 += "   LEFT JOIN PPRZMET PPM ON PPM.FILIAL = RITG.ZBH_FILIAL "
					YH007 += "                          AND PPM.VERSAO = RITG.ZBH_VERSAO "
					YH007 += "                          AND PPM.REVISA = RITG.ZBH_REVISA "
					YH007 += "                          AND PPM.ANOREF = RITG.ZBH_ANOREF "
					YH007 += "                          AND PPM.PERIODO = RITG.ZBH_PERIOD "
					YH007 += "                          AND PPM.MARCA =  RITG.ZBH_MARCA " 
					YH007 += "                          AND PPM.GRPCLI = RITG.ZBH_GRPCLI "
					YH007 += "                          AND PPM.VEND = RITG.ZBH_VEND "
					YH007 += "   LEFT JOIN PCPV PCPV ON PCPV.FILIAL = RITG.ZBH_FILIAL "
					YH007 += "                          AND PCPV.VERSAO = RITG.ZBH_VERSAO "
					YH007 += "                          AND PCPV.REVISA = RITG.ZBH_REVISA "
					YH007 += "                          AND PCPV.ANOREF = RITG.ZBH_ANOREF "
					YH007 += "                          AND PCPV.PERIODO = RITG.ZBH_PERIOD "
					YH007 += "                          AND PCPV.MARCA =  RITG.ZBH_MARCA " 

					YHIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,YH007),'YH07',.T.,.T.)
					dbSelectArea("YH07")
					YH07->(dbGoTop())
					While !YH07->(Eof())

						msQtdRec := YH07->ZBH_QUANT * YH07->QTDFLUT
						msVlrRec := YH07->ZBH_VALOR * YH07->VLRFLUT

						If msQtdRec <> 0

							RecLock("ZBH", .T.)
							ZBH->ZBH_FILIAL  := YH07->ZBH_FILIAL
							ZBH->ZBH_VERSAO  := YH07->ZBH_VERSAO
							ZBH->ZBH_REVISA  := YH07->ZBH_REVISA
							ZBH->ZBH_ANOREF  := YH07->ZBH_ANOREF
							ZBH->ZBH_PERIOD  := Alltrim(StrZero(mxFx,2)) 
							ZBH->ZBH_MARCA   := YH07->ZBH_MARCA 
							ZBH->ZBH_CANALD  := YH07->ZBH_CANALD
							ZBH->ZBH_VEND    := YH07->ZBH_VEND  
							ZBH->ZBH_GRPCLI  := YH07->ZBH_GRPCLI
							ZBH->ZBH_TPSEG   := YH07->ZBH_TPSEG 
							ZBH->ZBH_ESTADO  := YH07->ZBH_ESTADO
							ZBH->ZBH_PCTGMR  := YH07->ZBH_PCTGMR
							ZBH->ZBH_FORMAT  := YH07->ZBH_FORMAT
							ZBH->ZBH_CATEG   := YH07->ZBH_CATEG 
							ZBH->ZBH_CLASSE  := YH07->ZBH_CLASSE 
							ZBH->ZBH_QUANT   := Round(msQtdRec, 2)
							ZBH->ZBH_VALOR   := Round(msVlrRec, 2)
							ZBH->ZBH_TOTAL   := Round(msQtdRec * msVlrRec, 2)
							ZBH->ZBH_PCOMIS  := Round(YH07->PCOMIS, 2)
							ZBH->ZBH_VCOMIS  := Round(msQtdRec * msVlrRec *  YH07->PCOMIS, 2)
							ZBH->ZBH_PICMS   := Round(YH07->PICMS, 2)
							ZBH->ZBH_VICMS   := Round(msQtdRec * msVlrRec * YH07->PICMS, 2)
							ZBH->ZBH_PPIS    := Round(YH07->PPIS, 2)
							ZBH->ZBH_VPIS    := Round(msQtdRec * msVlrRec * YH07->PPIS, 2)
							ZBH->ZBH_PCOF    := Round(YH07->PCOF, 2)
							ZBH->ZBH_VCOF    := Round(msQtdRec * msVlrRec * YH07->PCOF, 2)
							ZBH->ZBH_PST     := Round(YH07->PST, 2)
							ZBH->ZBH_VST     := Round(msQtdRec * msVlrRec * YH07->PST, 2)
							ZBH->ZBH_PDIFAL  := Round(YH07->PDIFAL, 2)
							ZBH->ZBH_VDIFAL  := Round(msQtdRec * msVlrRec * YH07->PDIFAL, 2)
							ZBH->ZBH_ORIGF   := "5"
							// ...novos
							ZBH->ZBH_USER    := __cUserId
							ZBH->ZBH_DTPROC  := msDtProc
							ZBH->ZBH_HRPROC  := msHrProc
							ZBH->ZBH_METVER	 :=	Round(YH07->METVER,2)
							ZBH->ZBH_PRZMET	 :=	YH07->PRZMET
							ZBH->ZBH_PERVER	 :=	Round(YH07->PERVER,2)
							ZBH->ZBH_VALVER  :=	Round(ZBH->ZBH_TOTAL * ZBH->ZBH_PERVER / 100,2)
							ZBH->ZBH_PERBON	 :=	Round(YH07->PERBON,2)
							ZBH->ZBH_VALBON  :=	Round(ZBH->ZBH_TOTAL * ZBH->ZBH_PERBON / 100,2)
							ZBH->ZBH_PERCPV	 :=	Round(YH07->PERCPV,2)
							ZBH->ZBH_VALCPV	 :=	Round(ZBH->ZBH_VALBON * ZBH->ZBH_PERCPV / 100,2)
							ZBH->ZBH_PICMBO	 :=	Round(ZBH->ZBH_PICMS * 100,2) 
							ZBH->ZBH_VICMBO	 :=	Round(ZBH->ZBH_PICMBO * ZBH->ZBH_VALBON / 100,2)

							MsUnlockAll()

						EndIf

						YH07->(dbSkip())

					End
					YH07->(dbCloseArea())
					Ferase(YHIndex+GetDBExtension())
					Ferase(YHIndex+OrdBagExt())

				Next mxFx

				(M002)->(dbSkip())

			EndDo

		EndDo

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
	aAdd(aRegs,{cPerg,"04","Marca                    ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","Z37"})
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
