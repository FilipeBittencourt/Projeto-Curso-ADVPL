#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA945
@author Marcos Alberto Soprani
@since 04/09/18
@version 1.0
@description Rotina para preenchimento do quadro Orçamento do cadastro de Funcionários.   
@type function
/*/

User Function BIA945()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA945"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cDataRef  := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
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

	Processa({ || cMsg := BIA945A() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function BIA945A()

	Local M002        := GetNextAlias()

	//                                                ZERA OS VALORES PARA CARGA
	//**************************************************************************
	UP001 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP001 += "        RA_YCTGFU = '', "
	UP001 += "        RA_YBNADC = '', "
	UP001 += "        RA_YQSLPPR = 0, "
	UP001 += "        RA_YQVLTRT = 0, "
	UP001 += "        RA_YQTREFC = 0 "
	UP001 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP001 += "  WHERE D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [CLVL p/ Orct]...",,{|| TcSQLExec(UP001)})

	//                                                              CLVL p/ Orct
	//**************************************************************************
	UP001 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP001 += "        RA_YCLVL = RA_CLVL "
	UP001 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP001 += "  WHERE D_E_L_E_T_ = ' ' "
	If MV_PAR05 == 1
		UP001 += "    AND RA_YCLVL = ' ' "
	EndIf
	U_BIAMsgRun("Aguarde... Preparando Bases [CLVL p/ Orct]...",,{|| TcSQLExec(UP001)})

	//                                                              Categ. Func.
	//**************************************************************************
	UP002 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP002 += "        RA_YCTGFU = "
	UP002 += "        CASE "
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'P'                                        THEN '005' "   // Prolabore 
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_HRSEMAN = 20 AND RA_YPCD <> '3' THEN '010' "   // Menor Interno
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_HRSEMAN = 20 AND RA_YPCD = '3'  THEN '015' "   // Menor externo
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'E'                                        THEN '020' "   // Estagiário
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_YPCD <> '4'                     THEN '025' "   // Mensalistas
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT <> 0 AND RA_CATFUNC = 'M' AND RA_YPCD <> '4'                     THEN '030' "   // Mens. Aposentadoria Especial
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_YPCD = '4'                      THEN '035' "   // Promotoras
	UP002 += "          WHEN RA_DEFIFIS =  1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_YPCD = '1'                      THEN '040' "   // PCD Interno
	UP002 += "          WHEN RA_DEFIFIS =  1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_YPCD = '2'                      THEN '045' "   // PCD Externo
	UP002 += "          WHEN RA_DEFIFIS =  1 AND RA_PERCSAT <> 0 AND RA_CATFUNC = 'M'                                        THEN '050' "   // PCD Aposentadoria Especial
	UP002 += "          WHEN RA_DEFIFIS <> 1 AND RA_PERCSAT =  0 AND RA_CATFUNC = 'M' AND RA_YPCD = '3'                      THEN '???' "   // SENAI Externo ???
	UP002 += "          ELSE                                                                                                      '   ' "   // VERIFICAR
	UP002 += "        END "
	UP002 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP002 += "  WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > '" + dtos(_cDataRef) + "' ) "
	UP002 += "    AND RA_MAT < '2' "
	UP002 += "    AND RA_ADMISSA <= '" + dtos(_cDataRef) + "' "
	UP002 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Categ. Func.]...",,{|| TcSQLExec(UP002)})

	xfCompl := ""
	xfCompl += " Foram encontradas inconsistências no preenchimento" + msrhEnter
	xfCompl += "do campo Categoria do funcionário para as seguntes " + msrhEnter
	xfCompl += "matriculas: " + msrhEnter + msrhEnter

	BeginSql Alias M002

		SELECT RA_MAT
		FROM %TABLE:SRA% SRA
		WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > %Exp:dtos(_cDataRef)% )
		AND RA_MAT < '2'
		AND RA_ADMISSA <= %Exp:dtos(_cDataRef)%
		AND RA_YCTGFU IN( '   ', '???')
		AND SRA.%NotDel%

	EndSql

	(M002)->(dbGoTop())
	While !(M002)->(Eof())
		xfCompl += (M002)->RA_MAT + msrhEnter + msrhEnter 
		(M002)->(dbSkip())
	End	
	If !MsgYESNO(xfCompl + msrhEnter + msrhEnter + "Deseja prosseguir com o processamento?", "Problemas")
		(M002)->(dbCloseArea())
		Return .F.
	EndIf
	(M002)->(dbCloseArea())

	//                                                               Benef.Adic.
	//**************************************************************************
	UP003 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP003 += "        RA_YBNADC = "
	UP003 += "        ZBD_BNC002 "
	UP003 += "        + "
	UP003 += "        CASE "
	UP003 += "          WHEN (SELECT COUNT(R0_CODIGO) "
	UP003 += "                  FROM " + RetSqlName("SR0") + " SR0 "
	UP003 += "                 WHERE R0_MAT = RA_MAT "
	UP003 += "                   AND SR0.D_E_L_E_T_ = ' ') > 0 THEN ZBD_BNC005 "
	UP003 += "          ELSE '***' "
	UP003 += "        END "
	UP003 += "        + "
	UP003 += "        ZBD_BNC010 "
	UP003 += "        + "
	UP003 += "        ZBD_BNCB05 "
	UP003 += "        + "
	UP003 += "        CASE "
	UP003 += "          WHEN TUR.TURNO IN('022','031','047','048','183') OR SUBSTRING(TUR.TURNO,1,2) IN('E1') THEN ZBD_BNCB10 "
	UP003 += "          ELSE '***' "
	UP003 += "        END "
	UP003 += "        + "
	UP003 += "        ZBD_BNCB15 "
	UP003 += "        + "
	UP003 += "        CASE "
	UP003 += "          WHEN R6_YTPBENE = '3' THEN ZBD_BNCB20 "
	UP003 += "          ELSE '***' "
	UP003 += "        END "
	UP003 += "        + "
	UP003 += "        CASE "
	UP003 += "          WHEN R6_YTPBENE = '2' THEN ZBD_BNCB25 "
	UP003 += "          ELSE '***' "
	UP003 += "        END "
	UP003 += "        + "
	UP003 += "        CASE "
	UP003 += "          WHEN RA_YVALCOM = 'S' THEN ZBD_BNCB30 "
	UP003 += "          ELSE '***' "
	UP003 += "        END "
	UP003 += "        + "
	UP003 += "        ZBD_BNCB35 "
	UP003 += "        + "
	UP003 += "        ZBD_BNCC05 "
	UP003 += "        + "
	UP003 += "        ZBD_BNCC10 "
	UP003 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP003 += "   LEFT JOIN VW_BG_TURNO_FUNC TUR ON TUR.MATRIC = RA_MAT "
	UP003 += "   LEFT JOIN " + RetSqlName("SR6") + " SR6 ON R6_TURNO = TUR.TURNO "
	UP003 += "                       AND SR6.D_E_L_E_T_ = ' ' "
	UP003 += "   LEFT JOIN " + RetSqlName("ZBD") + " ZBD ON ZBD_CATEGF = RA_YCTGFU "
	UP003 += "                       AND ZBD.D_E_L_E_T_ = ' ' "
	UP003 += "  WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > '" + dtos(_cDataRef) + "' ) "
	UP003 += "    AND RA_MAT < '2' "
	UP003 += "    AND RA_ADMISSA <= '" + dtos(_cDataRef) + "' "
	UP003 += "    AND NOT ZBD_BNC002 IS NULL "
	UP003 += "    AND SRA.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Benef.Adic.]...",,{|| TcSQLExec(UP003)})

	//                                                              Qtd. Sal.PPR
	//**************************************************************************
	UP004 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP004 += "       RA_YQSLPPR = CASE "
	UP004 += "                        WHEN RJ_FUNCAO <> '8244' "
	UP004 += "                             AND RA_YBNADC LIKE '%010%' "
	UP004 += "                             AND (RJ_DESC LIKE 'DIR %' "
	UP004 += "                                  OR RJ_DESC LIKE 'DIR.%' "
	UP004 += "                                  OR RJ_DESC LIKE 'DIRETOR%' "
	UP004 += "                                  OR RJ_DESC LIKE 'GER %' "
	UP004 += "                                  OR RJ_DESC LIKE 'GER.%' "
	UP004 += "                                  OR RJ_DESC LIKE 'GERENTE%') "
	UP004 += "                        THEN 0.75 "
	UP004 += "                        WHEN RJ_FUNCAO <> '8244' "
	UP004 += "                             AND RA_YBNADC LIKE '%010%' "
	UP004 += "                        THEN 0.5 "
	UP004 += "                        WHEN RJ_FUNCAO = '8244' "
	UP004 += "                             AND RA_YBNADC LIKE '%010%' "
	UP004 += "                        THEN 0.5 "
	UP004 += "                        ELSE 0 "
	UP004 += "                    END "
	UP004 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP004 += "   LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON RJ_FUNCAO = RA_CODFUNC "
	UP004 += "                       AND SRJ.D_E_L_E_T_ = ' ' "
	UP004 += "  WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > '" + dtos(_cDataRef) + "' ) "
	UP004 += "    AND RA_MAT < '2' "
	UP004 += "    AND RA_ADMISSA <= '" + dtos(_cDataRef) + "' "
	UP004 += "    AND SRA.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd. Sal.PPR]...",,{|| TcSQLExec(UP004)})

	//                                                               Qtd Vl.Tran
	//**************************************************************************
	UP005 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP005 += "        RA_YQVLTRT = "
	UP005 += "        CASE "
	UP005 += "          WHEN RA_YBNADC LIKE '%005%' AND TUR.TURNO IN('047','048') THEN 32 "
	UP005 += "          WHEN RA_YBNADC LIKE '%005%' AND SUBSTRING(TUR.TURNO,1,2) IN('E1','E2','E3') THEN 48 "
	UP005 += "          WHEN RA_YBNADC LIKE '%005%' AND TUR.TURNO NOT IN('047','048') AND SUBSTRING(TUR.TURNO,1,2) NOT IN('E1','E2','E3') THEN 44 "
	UP005 += "          ELSE 0 "
	UP005 += "        END "
	UP005 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP005 += "   LEFT JOIN VW_BG_TURNO_FUNC TUR ON TUR.MATRIC = RA_MAT "
	UP005 += "  WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > '" + dtos(_cDataRef) + "' ) "
	UP005 += "    AND RA_MAT < '2' "
	UP005 += "    AND RA_ADMISSA <= '" + dtos(_cDataRef) + "' "
	UP005 += "    AND SRA.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd Vl.Tran]...",,{|| TcSQLExec(UP005)})

	//                                                              Qtd Refeição
	//**************************************************************************
	UP006 := " UPDATE " + RetSqlName("SRA") + " SET "
	UP006 += "        RA_YQTREFC = "
	UP006 += "        CASE "
	UP006 += "          WHEN RA_YBNADC LIKE '%B05%' AND TUR.TURNO IN('047') THEN 8 "
	UP006 += "          WHEN RA_YBNADC LIKE '%B05%' AND TUR.TURNO IN('048') THEN 16 "
	UP006 += "          WHEN RA_YBNADC LIKE '%B05%' AND SUBSTRING(TUR.TURNO,1,2) IN('E1') THEN 24 "
	UP006 += "          WHEN RA_YBNADC LIKE '%B05%' AND TUR.TURNO NOT IN('047','048') AND SUBSTRING(TUR.TURNO,1,2) NOT IN('E2', 'E3') THEN 22 "
	UP006 += "          ELSE 0 "
	UP006 += "        END "
	UP006 += "   FROM " + RetSqlName("SRA") + " SRA "
	UP006 += "   LEFT JOIN VW_BG_TURNO_FUNC TUR ON TUR.MATRIC = RA_MAT "
	UP006 += "  WHERE ( RA_SITFOLH <> 'D' OR RA_DEMISSA > '" + dtos(_cDataRef) + "' ) "
	UP006 += "    AND RA_MAT < '2' "
	UP006 += "    AND RA_ADMISSA <= '" + dtos(_cDataRef) + "' "
	UP006 += "    AND SRA.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd Refeição]...",,{|| TcSQLExec(UP006)})

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
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária         ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa               ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência           ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Data Referência para Foto   ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Preencher apenas CLVL Vazias?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
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
