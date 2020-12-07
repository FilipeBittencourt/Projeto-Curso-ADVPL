#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA631
@author Marcos Alberto Soprani
@since 19/10/17
@version 1.0
@description Rotina de processamento e gravação da Fotografia dos dados para Orçamento de Custo Variável - Estrutura de Produto   
@type function
/*/

User Function BIA631()

	Local M001      := GetNextAlias()
	Local entEnter  := CHR(13) + CHR(10)
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA631"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cMesRef   := IIF(!Empty(MV_PAR04), MV_PAR04, "01")

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e anterior à data do dia" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
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

	U_BIAMsgRun("Aguarde... Efetuando gravação dos dados... ",,{|| BIA631A() })

Return

Static Function BIA631A()

	Local msx
	Local iaEnter := CHR(13) + CHR(10)

	rtContinua := .T.
	rtDtIni := _cAnoRef + _cMesRef + "01"
	rtDtFim := _cAnoRef + "1231" 

	TR002 := " WITH REGORCTO AS (SELECT 'FOTO' TIPO, COUNT(*) CONTAD "
	TR002 += "                     FROM " + RetSqlName("SGG") + " SGG WITH (NOLOCK) "
	TR002 += "                    WHERE GG_FILIAL = '" + xFilial("SGG") + "' "
	TR002 += "                      AND GG_INI >= '" + rtDtIni + "' "
	TR002 += "                      AND GG_FIM <= '" + rtDtFim + "' "
	TR002 += "                      AND D_E_L_E_T_ = ' ' "
	TR002 += "                    UNION ALL "
	TR002 += "                   SELECT 'CUST' TIPO, COUNT(*) CONTAD "
	TR002 += "                     FROM " + RetSqlName("Z87") + " Z87 WITH (NOLOCK) "
	TR002 += "                    WHERE Z87_FILIAL = '" + xFilial("Z87") + "' "
	TR002 += "                      AND Z87_DATARF BETWEEN '" + rtDtIni + "' AND '" + rtDtFim + "' "
	TR002 += "                      AND D_E_L_E_T_ = ' ') "
	TR002 += " SELECT ISNULL([FOTO],0) AS FOTO, "
	TR002 += "        ISNULL([CUST],0) AS CUST "
	TR002 += "  FROM (SELECT TIPO, CONTAD "
	TR002 += "          FROM REGORCTO) AS TAB "
	TR002 += " PIVOT (SUM(CONTAD) "
	TR002 += "        FOR TIPO IN ([FOTO], [CUST]) ) AS FIM "
	TRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TR002),'TR02',.F.,.T.)
	dbSelectArea("TR02")
	dbGoTop()
	If ( TR02->FOTO + TR02->CUST ) > 0

		trMensag := " Foram encontrados os seguintes registros na base de dados que estão diretamente associado o processo orçamentário: " + iaEnter 
		trMensag += " " + iaEnter
		trMensag += "   Fotografia: " + Transform(TR02->FOTO, "@E 999,999,999") + iaEnter 
		trMensag += "   Custo Insumos: " + Transform(TR02->CUST, "@E 999,999,999") + iaEnter
		trMensag += " " + iaEnter
		trMensag += " Para prosseguir com o processamento é necessário apagar todos os registros relacionados ao período orçamentário. " + iaEnter
		trMensag += " " + iaEnter
		trMensag += " Deseja continuar o processamento, clique <Sim>. Para abortar <Não> " + iaEnter

		nOpc := Aviso( "BIA631A", trMensag, { "Sim", "Não" }, 3, "Verificação de Registro nas tabela de Orçamento!!! ", , 'ENGRENAGEM', .F. , )

		If nOpc == 1

			TR005 := " DELETE " + RetSqlName("Z87") + " "
			TR005 += "  WHERE Z87_FILIAL = '" + xFilial("Z87") + "' "
			TR005 += "    AND Z87_DATARF BETWEEN '" + rtDtIni + "' AND '" + rtDtFim + "' "
			TR005 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Zerando Custo Unitário Insumos...",,{|| TCSQLExec(TR005)})

			TR004 := " DELETE " + RetSqlName("SGG") + " "
			TR004 += "  WHERE GG_FILIAL = '" + xFilial("SGG") + "' "
			TR004 += "    AND GG_INI >= '" + rtDtIni + "' "
			TR004 += "    AND GG_FIM <= '" + rtDtFim + "' "
			TR004 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Zerando Fotografia da Estrutura...",,{|| TCSQLExec(TR004)})

		ElseIf nOpc == 2

			rtContinua := .F.

		EndIf 

	EndIf

	TR02->(dbCloseArea())
	Ferase(TRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TRcIndex+OrdBagExt())          //indice gerado

	If rtContinua

		If Empty(MV_PAR04) .or. MV_PAR04 == "01"

			// Primeiro dia do ano orçamentário: servirá de referência para eventuais confrontos.
			msDtStrut := stod(_cAnoRef + "0101")
			msObserv  := "Data Foto: " + dtoc(dDataBase) + ", Data Strut: " + dtoc(msDtStrut)
			bBa631Grv( dDataBase, msDtStrut, msObserv)

		EndIf

		For msx := 1 to 12

			If msx >= Val(Alltrim(_cMesRef))

				// Foto da estrutura para orçamento variável mes a mes
				msDtStrut := stod(_cAnoRef + StrZero(msx,2) + "01")
				msDtStrut := Ultimodia(msDtStrut) 
				msObserv  := "Data Foto: " + dtoc(dDataBase) + ", Data Strut: " + dtoc(msDtStrut)
				bBa631Grv( dDataBase, msDtStrut, msObserv)

			EndIf

		Next

		MsgINFO("Fim do Processamento....")

	Else

		MsgINFO("Processamento cancelado....")

	EndIf 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ bBa631Grv    ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 19/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function bBa631Grv(xsDtREf, xsDtStt, xsObsv)

	Local msEnter     := Chr(13) + Chr(10)

	PU008 := Alltrim(" WITH NIVEIS AS (                                                                                                                                      ") + msEnter
	//                                 -- Membro âncora                                                                                                                      
	PU008 += Alltrim("                 SELECT SG1.G1_COMP     ID,                                                                                                            ") + msEnter
	PU008 += Alltrim("                        SG1.G1_COD      IDPAI,                                                                                                         ") + msEnter
	PU008 += Alltrim("                        SG1.R_E_C_N_O_  REGSG1,                                                                                                        ") + msEnter
	PU008 += Alltrim("                        0               NIVEL                                                                                                          ") + msEnter
	PU008 += Alltrim("                   FROM " + RetSqlName("SG1") + " SG1 (NOLOCK)                                                                                         ") + msEnter
	PU008 += Alltrim("                  INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_COD = SG1.G1_COD                                                         ") + msEnter
	PU008 += Alltrim("                                                AND SB1.B1_TIPO IN('PA')                                                                               ") + msEnter
	PU008 += Alltrim("                                                AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	PU008 += Alltrim("                  WHERE SG1.G1_FILIAL = '" + xFilial("SG1") + "'                                                                                       ") + msEnter
	//                                    --***************************************************************************                                                      
	//                                    --*  neste ponto incluir sub set com os produto que se pretende fotografar  *                                                      
	//                                    --***************************************************************************                                                      
	PU008 += Alltrim("                    AND SG1.G1_COD IN(SELECT Z47_PRODUT PRODUT                                                                              ") + msEnter
	PU008 += Alltrim("                                        FROM " + RetSqlName("Z47") + " Z47 (NOLOCK)                                                                    ") + msEnter
	PU008 += Alltrim("                                       WHERE Z47.Z47_FILIAL = '" + xFilial("Z47") + "'                                                                 ") + msEnter
	PU008 += Alltrim("                                         AND Z47.Z47_VERSAO = '" + _cVersao + "'                                                                       ") + msEnter
	PU008 += Alltrim("                                         AND Z47.Z47_REVISA = '" + _cRevisa + "'                                                                       ") + msEnter
	PU008 += Alltrim("                                         AND Z47.Z47_ANOREF = '" + _cAnoRef + "'                                                                       ") + msEnter
	PU008 += Alltrim("                                         AND Z47.D_E_L_E_T_ = ' ')                                                                                     ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' >= SG1.G1_INI                                                                                          ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' <= SG1.G1_FIM                                                                                          ") + msEnter
	PU008 += Alltrim("                    AND SG1.D_E_L_E_T_ = ' '                                                                                                           ") + msEnter
	PU008 += Alltrim("                  UNION ALL                                                                                                                            ") + msEnter
	//                                 -- Filhos                                                                                                                             
	PU008 += Alltrim("                 SELECT T1.G1_COMP     ID,                                                                                                             ") + msEnter
	PU008 += Alltrim("                        T1.G1_COD      IDPAI,                                                                                                          ") + msEnter
	PU008 += Alltrim("                        T1.R_E_C_N_O_  REGSG1,                                                                                                         ") + msEnter
	PU008 += Alltrim("                        NIVEL + 1      NIVEL                                                                                                           ") + msEnter
	PU008 += Alltrim("                   FROM " + RetSqlName("SG1") + " T1 (NOLOCK)                                                                                          ") + msEnter
	PU008 += Alltrim("                  INNER JOIN NIVEIS ON T1.G1_COD = NIVEIS.ID                                                                                           ") + msEnter
	PU008 += Alltrim("                  WHERE T1.G1_FILIAL = '" + xFilial("SG1") + "'                                                                                        ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' >= T1.G1_INI                                                                                           ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' <= T1.G1_FIM                                                                                           ") + msEnter
	PU008 += Alltrim("                    AND T1.D_E_L_E_T_ = ' '                                                                                                            ") + msEnter
	PU008 += Alltrim("                 )                                                                                                                                     ") + msEnter
	PU008 += Alltrim(" INSERT INTO " + RetSqlName("SGG") + "                                                                                                                 ") + msEnter
	PU008 += Alltrim(" (                                                                                                                                                     ") + msEnter
	PU008 += Alltrim("  GG_FILIAL,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_COD,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_COMP,                                                                                                                                             ") + msEnter
	PU008 += Alltrim("  GG_TRT,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_QUANT,                                                                                                                                            ") + msEnter
	PU008 += Alltrim("  GG_PERDA,                                                                                                                                            ") + msEnter
	PU008 += Alltrim("  GG_INI,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_FIM,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_OBSERV,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_FIXVAR,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_GROPC,                                                                                                                                            ") + msEnter
	PU008 += Alltrim("  GG_OPC,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_NIV,                                                                                                                                              ") + msEnter
	PU008 += Alltrim("  GG_NIVINV,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_POTENCI,                                                                                                                                          ") + msEnter
	PU008 += Alltrim("  GG_OK,                                                                                                                                               ") + msEnter
	PU008 += Alltrim("  GG_STATUS,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_USUARIO,                                                                                                                                          ") + msEnter
	PU008 += Alltrim("  GG_REVINI,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_REVFIM,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_TIPVEC,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  GG_VECTOR,                                                                                                                                           ") + msEnter
	PU008 += Alltrim("  D_E_L_E_T_,                                                                                                                                          ") + msEnter
	PU008 += Alltrim("  R_E_C_N_O_,                                                                                                                                          ") + msEnter
	PU008 += Alltrim("  GG_YMISTUR                                                                                                                                           ") + msEnter
	PU008 += Alltrim(" )                                                                                                                                                     ") + msEnter
	PU008 += Alltrim(" SELECT '" + xFilial("SGG") + "' G1_FILIAL,                                                                                                            ") + msEnter
	PU008 += Alltrim("        G1_COD,                                                                                                                                        ") + msEnter
	PU008 += Alltrim("        G1_COMP,                                                                                                                                       ") + msEnter
	PU008 += Alltrim("        G1_TRT,                                                                                                                                        ") + msEnter
	PU008 += Alltrim("        G1_QUANT QUANT,                                                                                                                                ") + msEnter
	PU008 += Alltrim("        G1_PERDA PERDA,                                                                                                                                ") + msEnter
	PU008 += Alltrim("        '" + dtos(xsDtStt) + "' G1_INI,                                                                                                                ") + msEnter
	PU008 += Alltrim("        '" + dtos(xsDtStt) + "' G1_FIM,                                                                                                                ") + msEnter
	PU008 += Alltrim("        '" + xsObsv + "' G1_OBSERV,                                                                                                                    ") + msEnter
	PU008 += Alltrim("        'V' G1_FIXVAR,                                                                                                                                 ") + msEnter
	PU008 += Alltrim("        '' G1_GROPC,                                                                                                                                   ") + msEnter
	PU008 += Alltrim("        '' G1_OPC,                                                                                                                                     ") + msEnter
	PU008 += Alltrim("        G1_NIV,                                                                                                                                        ") + msEnter
	PU008 += Alltrim("        G1_NIVINV,                                                                                                                                     ") + msEnter
	PU008 += Alltrim("        0 G1_POTENCI,                                                                                                                                  ") + msEnter
	PU008 += Alltrim("        '' G1_OK,                                                                                                                                      ") + msEnter
	PU008 += Alltrim("        '1' G1_STATUS,                                                                                                                                 ") + msEnter
	PU008 += Alltrim("        '" + Substr(cUserName,1,6) + "' G1_USUARIO,                                                                                                    ") + msEnter
	PU008 += Alltrim("        G1_REVINI,                                                                                                                                     ") + msEnter
	PU008 += Alltrim("        G1_REVFIM,                                                                                                                                     ") + msEnter
	PU008 += Alltrim("        '' G1_TIPVEC,                                                                                                                                  ") + msEnter
	PU008 += Alltrim("        '' G1_VECTOR,                                                                                                                                  ") + msEnter
	PU008 += Alltrim("        ' ' D_E_L_E_T_,                                                                                                                                ") + msEnter
	PU008 += Alltrim("        (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("SGG") + ") + ROW_NUMBER() OVER(ORDER BY SG1.R_E_C_N_O_) AS R_E_C_N_O_,                 ") + msEnter
	PU008 += Alltrim("        G1_YMISTUR                                                                                                                                     ") + msEnter
	PU008 += Alltrim("   FROM (SELECT DISTINCT REGSG1                                                                                                                        ") + msEnter
	PU008 += Alltrim("           FROM NIVEIS NIV                                                                                                                             ") + msEnter
	PU008 += Alltrim("          WHERE ID + IDPAI NOT IN ( SELECT GG_COMP + GG_COD                                                                                            ") + msEnter
	PU008 += Alltrim("                                      FROM " + RetSqlName("SGG") + "                                                                                   ") + msEnter
	PU008 += Alltrim("                                     WHERE D_E_L_E_T_ = ' ' AND GG_FIM IN('" + dtos(xsDtStt) + "'))                                                    ") + msEnter
	PU008 += Alltrim("         ) AS TAB                                                                                                                                      ") + msEnter
	PU008 += Alltrim("   LEFT JOIN " + RetSqlName("SG1") + " SG1 ON SG1.R_E_C_N_O_ = TAB.REGSG1                                                                              ") + msEnter

	U_BIAMsgRun("Aguarde... Efetuando Cópia da Estrutura de Produtos. Dt Estrut: " + dtoc(xsDtStt),,{|| TcSqlExec(PU008) })

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
	aAdd(aRegs,{cPerg,"04","Mês a considerar ForeCast?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
