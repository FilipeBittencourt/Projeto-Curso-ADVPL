#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA659
@author Marcos Alberto Soprani
@since 19/06/20
@version 1.0
@description Rotina de processamento e gravação do FORECAST do Orçamento de RECEITA  
@type function
/*/

User Function BIA659()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA659"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cMarca    := MV_PAR04
	_cSequen   := MV_PAR05
	_cMes      := MV_PAR06

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
		FROM %TABLE:ZB5% ZB5 (NOLOCK)
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
	M0007 += "   FROM " + RetSqlName("ZBH") + " ZBH (NOLOCK) "
	M0007 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	M0007 += "        AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	M0007 += "        AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	M0007 += "        AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	M0007 += "        AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
	M0007 += "        AND ZBH.ZBH_ORIGF = '5' "
	If !Empty(_cMes)
		M0007 += "        AND ZBH.ZBH_PERIOD = '" + _cMes + "' "
	EndIf
	M0007 += "        AND ZBH.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe desdobramento da Versão informada." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados desdobrados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE ZBH "
			KS001 += "   FROM " + RetSqlName("ZBH") + " ZBH "
			KS001 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
			KS001 += "        AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
			KS001 += "        AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
			KS001 += "        AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
			KS001 += "        AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
			KS001 += "        AND ZBH.ZBH_ORIGF = '5' "
			If !Empty(_cMes)
				KS001 += "        AND ZBH.ZBH_PERIOD = '" + _cMes + "' "
			EndIf
			KS001 += "        AND ZBH.D_E_L_E_T_ = ' ' "
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

	Processa({ || cMsg := BIA659A() }, "Aguarde...", "Carregando dados...", .F.)

Return

Static Function BIA659A()

	Local mxFx      := 0
	Local msDtProc  := Date()
	Local msHrProc  := Time()

	ProcRegua(0)

	IncProc("Carregando dados....: " )

	YH007 := " WITH FORECASTR "
	YH007 += "      AS (SELECT ZBH_FILIAL FILIAL, "
	YH007 += "                 ZBH_VERSAO VERSAO, "
	YH007 += "                 ZBH_REVISA REVISA, "
	YH007 += "                 ZBH_ANOREF ANOREF, "
	YH007 += "                 ZBH_PERIOD PERIODO, "
	YH007 += "                 ZBH_MARCA MARCA, " 
	YH007 += "                 ZBH_TPSEG TPSEG, "
	YH007 += "                 ZBH_ESTADO ESTADO, "
	YH007 += "                 ZBH_FORMAT FORMATO, "
	YH007 += "                 ZBH_FORVOL FORVOL, "
	YH007 += "                 ZBH_FORPRC FORPRC "
	YH007 += "          FROM " + RetSqlName("ZBH") + " ZBH(NOLOCK) "
	YH007 += "          WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	YH007 += "                AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	YH007 += "                AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	YH007 += "                AND ZBH.ZBH_MARCA = '" + _cMarca + "' "
	YH007 += "                AND ZBH.ZBH_ORIGF = '9' "
	If !Empty(_cMes)
		YH007 += "                AND ZBH.ZBH_PERIOD = '" + _cMes + "' "
	End
	YH007 += "                AND ZBH.D_E_L_E_T_ = ' ') "
	YH007 += "      SELECT ZBM.*, "
	YH007 += "             ISNULL(FORVOL, 1) FORVOL, "
	YH007 += "             ISNULL(FORPRC, 1) FORPRC "
	YH007 += "      FROM " + RetSqlName("ZBM") + " ZBM(NOLOCK) "
	YH007 += "           LEFT JOIN FORECASTR FCR ON FCR.FILIAL = ZBM.ZBM_FILIAL "
	YH007 += "                                      AND FCR.VERSAO = ZBM.ZBM_VERSAO "
	YH007 += "                                      AND FCR.REVISA = ZBM.ZBM_REVISA "
	YH007 += "                                      AND FCR.ANOREF = ZBM.ZBM_ANOREF "
	YH007 += "                                      AND FCR.PERIODO = ZBM.ZBM_PERIOD "
	YH007 += "                                      AND FCR.MARCA = ZBM.ZBM_MARCA "
	YH007 += "                                      AND FCR.TPSEG = ZBM.ZBM_TPSEG "
	YH007 += "                                      AND FCR.ESTADO = ZBM.ZBM_ESTADO "
	YH007 += "                                      AND FCR.FORMATO = ZBM.ZBM_FORMAT "
	YH007 += "      WHERE ZBM.ZBM_VERSAO = '" + _cVersao + "' "
	YH007 += "            AND ZBM.ZBM_REVISA = '" + _cRevisa + "' "
	YH007 += "            AND ZBM.ZBM_ANOREF = '" + _cAnoRef + "' "
	YH007 += "            AND ZBM.ZBM_MARCA = '" + _cMarca + "' "
	YH007 += "            AND ZBM.ZBM_SEQUEN = '" + _cSequen + "' "
	YH007 += "            AND ZBM.ZBM_ORIGF = '5' "
	If !Empty(_cMes)
		YH007 += "            AND ZBM.ZBM_PERIOD = '" + _cMes + "' "
	EndIf
	YH007 += "            AND ZBM.D_E_L_E_T_ = ' ' "
	YHIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YH007),'YH07',.T.,.T.)
	dbSelectArea("YH07")
	YH07->(dbGoTop())
	While !YH07->(Eof())

		mxFx ++
		IncProc("Carregando dados. " + AllTrim(StrZero(mxFx,2)))

		msQtdRec := YH07->ZBM_QUANT * YH07->FORVOL
		msVlrTot := YH07->ZBM_TOTAL * YH07->FORPRC
		msVlrRec := msVlrTot / msQtdRec

		If msQtdRec <> 0

			RecLock("ZBH", .T.)
			ZBH->ZBH_FILIAL  := YH07->ZBM_FILIAL
			ZBH->ZBH_VERSAO  := YH07->ZBM_VERSAO
			ZBH->ZBH_REVISA  := YH07->ZBM_REVISA
			ZBH->ZBH_ANOREF  := YH07->ZBM_ANOREF
			ZBH->ZBH_PERIOD  := YH07->ZBM_PERIOD 
			ZBH->ZBH_MARCA   := YH07->ZBM_MARCA 
			ZBH->ZBH_CANALD  := YH07->ZBM_CANALD
			ZBH->ZBH_VEND    := YH07->ZBM_VEND  
			ZBH->ZBH_GRPCLI  := YH07->ZBM_GRPCLI
			ZBH->ZBH_TPSEG   := YH07->ZBM_TPSEG 
			ZBH->ZBH_ESTADO  := YH07->ZBM_ESTADO
			ZBH->ZBH_PCTGMR  := YH07->ZBM_PCTGMR
			ZBH->ZBH_FORMAT  := YH07->ZBM_FORMAT
			ZBH->ZBH_CATEG   := YH07->ZBM_CATEG 
			ZBH->ZBH_CLASSE  := YH07->ZBM_CLASSE 
			ZBH->ZBH_QUANT   := Round(msQtdRec, 2)
			ZBH->ZBH_VALOR   := Round(msVlrRec, 2)
			ZBH->ZBH_TOTAL   := Round(msQtdRec * msVlrRec, 2)
			ZBH->ZBH_PCOMIS  := YH07->ZBM_PCOMIS
			ZBH->ZBH_VCOMIS  := Round(msQtdRec * msVlrRec *  YH07->ZBM_PCOMIS, 2)
			ZBH->ZBH_PICMS   := YH07->ZBM_PICMS
			ZBH->ZBH_VICMS   := Round(msQtdRec * msVlrRec * YH07->ZBM_PICMS, 2)
			ZBH->ZBH_PPIS    := YH07->ZBM_PPIS
			ZBH->ZBH_VPIS    := Round(msQtdRec * msVlrRec * YH07->ZBM_PPIS, 2)
			ZBH->ZBH_PCOF    := YH07->ZBM_PCOF
			ZBH->ZBH_VCOF    := Round(msQtdRec * msVlrRec * YH07->ZBM_PCOF, 2)
			ZBH->ZBH_PST     := YH07->ZBM_PST
			ZBH->ZBH_VST     := Round(msQtdRec * msVlrRec * YH07->ZBM_PST, 2)
			ZBH->ZBH_PDIFAL  := YH07->ZBM_PDIFAL
			ZBH->ZBH_VDIFAL  := Round(msQtdRec * msVlrRec * YH07->ZBM_PDIFAL, 2)
			ZBH->ZBH_ORIGF   := "5"
			// ...novos
			ZBH->ZBH_USER    := __cUserId
			ZBH->ZBH_DTPROC  := msDtProc
			ZBH->ZBH_HRPROC  := msHrProc
			ZBH->ZBH_METVER	 :=	YH07->ZBM_METVER
			ZBH->ZBH_PRZMET	 :=	YH07->ZBM_PRZMET
			ZBH->ZBH_PERVER	 :=	YH07->ZBM_PERVER
			ZBH->ZBH_VALVER  :=	Round(ZBH->ZBH_TOTAL * ZBH->ZBH_PERVER / 100,2)
			ZBH->ZBH_PERBON	 :=	YH07->ZBM_PERBON
			ZBH->ZBH_VALBON  :=	Round(ZBH->ZBH_TOTAL * ZBH->ZBH_PERBON / 100,2)
			ZBH->ZBH_PERCPV	 :=	YH07->ZBM_PERCPV
			ZBH->ZBH_VALCPV	 :=	Round(ZBH->ZBH_VALBON * ZBH->ZBH_PERCPV / 100,2)
			ZBH->ZBH_PICMBO	 :=	YH07->ZBM_PICMBO
			ZBH->ZBH_VICMBO	 :=	Round(ZBH->ZBH_PICMBO * ZBH->ZBH_VALBON / 100,2)

			MsUnlockAll()

		EndIf

		YH07->(dbSkip())

	End
	YH07->(dbCloseArea())
	Ferase(YHIndex+GetDBExtension())
	Ferase(YHIndex+OrdBagExt())

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
	aAdd(aRegs,{cPerg,"05","Sequencia                ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Mês (Vazio Todos)        ?","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
