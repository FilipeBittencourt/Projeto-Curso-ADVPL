#include "rwmake.ch"

/*/{Protheus.doc} BIA573
@author Marcos Alberto Soprani
@since 05/07/20
@version 1.1
@description Rotina para cadastramento automático do Rateio de custo - Projeto JK  
@type function
/*/                                                                                               

User Function BIA573()

	Private msrhEnter   := CHR(13) + CHR(10)

	cHInicio := Time()
	fPerg := "BIA573"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.", "BIA752 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.", "BIA752 - Data de Fechamento!!!")
		Return
	EndIf

	Processa({|| fProcBia573()})

Return

Static Function fProcBia573()

	Local msUPDT      := ""
	Local msStaExcQy  := 0
	Local lOk         := .T.

	Begin Transaction

		msUPDT := " WITH EXTRACAO3810 "
		msUPDT += "      AS (SELECT D3_GRUPO, "
		msUPDT += "                 SUM(D3_QUANT) QUANT, "
		msUPDT += "          ( "
		msUPDT += "              SELECT SUM(XD3.D3_QUANT) "
		msUPDT += "              FROM " + RetSqlName("SD3") + " XD3(NOLOCK) "
		msUPDT += "              WHERE XD3.D3_FILIAL = '" + xFilial("SD3") + "' "
		msUPDT += "                    AND XD3.D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		msUPDT += "                    AND XD3.D3_ESTORNO = ' ' "
		msUPDT += "                    AND XD3.D3_TM = '010' "
		msUPDT += "                    AND XD3.D3_TIPO = 'MP' "
		msUPDT += "                    AND XD3.D_E_L_E_T_ = ' ' "
		msUPDT += "          ) TOTAL "
		msUPDT += "          FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
		msUPDT += "          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
		msUPDT += "                AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		msUPDT += "                AND D3_ESTORNO = ' ' "
		msUPDT += "                AND D3_TM = '010' "
		msUPDT += "                AND D3_TIPO = 'MP' "
		msUPDT += "                AND SD3.D_E_L_E_T_ = ' ' "
		msUPDT += "          GROUP BY D3_GRUPO), "
		msUPDT += "      LANC3810 "
		msUPDT += "      AS (SELECT RATEIO = '" + Substr(dtos(MV_PAR02), 1, 2) + "' + '" + Substr(dtos(MV_PAR02), 5, 2) + "' + '01', "
		msUPDT += "                 CLVLORI = '3810', "
		msUPDT += "                 CLVLPAR = CASE "
		msUPDT += "                               WHEN D3_GRUPO = '108A' "
		msUPDT += "                               THEN '3804     ' "
		msUPDT += "                               WHEN D3_GRUPO = '108B' "
		msUPDT += "                               THEN '3801     ' "
		msUPDT += "                               ELSE '         ' "
		msUPDT += "                           END, "
		msUPDT += "                 RIGHT('000' + RTRIM(CONVERT(VARCHAR, ROW_NUMBER() OVER( "
		msUPDT += "                       ORDER BY D3_GRUPO))), 3) SEQUENC, "
		msUPDT += "                 ROUND(QUANT / TOTAL * 100, 8) PERC "
		msUPDT += "          FROM EXTRACAO3810), "
		msUPDT += "      EXTRACAO3806 "
		msUPDT += "      AS (SELECT D3_CLVL, "
		msUPDT += "                 SUM(D3_QUANT) QUANT, "
		msUPDT += "          ( "
		msUPDT += "              SELECT SUM(XD3.D3_QUANT) "
		msUPDT += "              FROM " + RetSqlName("SD3") + " XD3(NOLOCK) "
		msUPDT += "              WHERE XD3.D3_FILIAL = '" + xFilial("SD3") + "' "
		msUPDT += "                    AND XD3.D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		msUPDT += "                    AND XD3.D3_ESTORNO = ' ' "
		msUPDT += "                    AND XD3.D3_TM = '010' "
		msUPDT += "                    AND XD3.D3_GRUPO <> '108A' "
		msUPDT += "                    AND XD3.D_E_L_E_T_ = ' ' "
		msUPDT += "          ) TOTAL "
		msUPDT += "          FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
		msUPDT += "          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
		msUPDT += "                AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		msUPDT += "                AND D3_ESTORNO = ' ' "
		msUPDT += "                AND D3_TM = '010' "
		msUPDT += "                AND SD3.D3_GRUPO <> '108A' "
		msUPDT += "                AND SD3.D_E_L_E_T_ = ' ' "
		msUPDT += "          GROUP BY D3_CLVL), "
		msUPDT += "      LANC3806 "
		msUPDT += "      AS (SELECT RATEIO = '" + Substr(dtos(MV_PAR02), 1, 2) + "' + '" + Substr(dtos(MV_PAR02), 5, 2) + "' + '03', "
		msUPDT += "                 CLVLORI = '3806', "
		msUPDT += "                 CLVLPAR = D3_CLVL, "
		msUPDT += "                 RIGHT('000' + RTRIM(CONVERT(VARCHAR, ROW_NUMBER() OVER( "
		msUPDT += "                       ORDER BY D3_CLVL))), 3) SEQUENC, "
		msUPDT += "                 ROUND(QUANT / TOTAL * 100, 8) PERC "
		msUPDT += "          FROM EXTRACAO3806), "
		msUPDT += "      RATGERAL "
		msUPDT += "      AS (SELECT * "
		msUPDT += "          FROM LANC3810 "
		msUPDT += "          UNION ALL "
		msUPDT += "          SELECT RATEIO = '" + Substr(dtos(MV_PAR02), 1, 2) + "' + '" + Substr(dtos(MV_PAR02), 5, 2) + "' + '02', "
		msUPDT += "                 CLVLORI = '3808', "
		msUPDT += "                 CLVLPAR = '3806', "
		msUPDT += "                 SEQUENC = '001', "
		msUPDT += "                 PERC = 100.00 "
		msUPDT += "          UNION ALL "
		msUPDT += "          SELECT * "
		msUPDT += "          FROM LANC3806) "
		msUPDT += "      INSERT INTO " + RetSqlName("CTQ") + " "
		msUPDT += "      (CTQ_FILIAL, "
		msUPDT += "       CTQ_RATEIO, "
		msUPDT += "       CTQ_DESC, "
		msUPDT += "       CTQ_TIPO, "
		msUPDT += "       CTQ_PERBAS, "
		msUPDT += "       CTQ_CTORI, "
		msUPDT += "       CTQ_CCORI, "
		msUPDT += "       CTQ_ITORI, "
		msUPDT += "       CTQ_CLORI, "
		msUPDT += "       CTQ_CTPAR, "
		msUPDT += "       CTQ_CCPAR, "
		msUPDT += "       CTQ_ITPAR, "
		msUPDT += "       CTQ_CLPAR, "
		msUPDT += "       CTQ_SEQUEN, "
		msUPDT += "       CTQ_CTCPAR, "
		msUPDT += "       CTQ_CCCPAR, "
		msUPDT += "       CTQ_ITCPAR, "
		msUPDT += "       CTQ_CLCPAR, "
		msUPDT += "       CTQ_PERCEN, "
		msUPDT += "       D_E_L_E_T_, "
		msUPDT += "       R_E_C_N_O_, "
		msUPDT += "       R_E_C_D_E_L_, " 
		msUPDT += "       CTQ_UM, "
		msUPDT += "       CTQ_VALOR, "
		msUPDT += "       CTQ_FORMUL, "
		msUPDT += "       CTQ_INTERC, "
		msUPDT += "       CTQ_AMARRA, "
		msUPDT += "       CTQ_MSBLQL, "
		msUPDT += "       CTQ_STATUS "
		msUPDT += "      ) "
		msUPDT += "             SELECT '  ' CTQ_FILIAL, "
		msUPDT += "                    RATEIO CTQ_RATEIO, "
		msUPDT += "                    'APROPRIACAO ' + RTRIM(CLVLORI) CTQ_DESC, "
		msUPDT += "                    '1' CTQ_TIPO, "
		msUPDT += "                    100 CTQ_PERBAS, "
		msUPDT += "                    '' CTQ_CTORI, "
		msUPDT += "                    '' CTQ_CCORI, "
		msUPDT += "                    '' CTQ_ITORI, "
		msUPDT += "                    CLVLORI CTQ_CLORI, "
		msUPDT += "                    '' CTQ_CTPAR, "
		msUPDT += "                    '' CTQ_CCPAR, "
		msUPDT += "                    '' CTQ_ITPAR, "
		msUPDT += "                    CLVLORI CTQ_CLPAR, "
		msUPDT += "                    SEQUENC CTQ_SEQUEN, "
		msUPDT += "                    '' CTQ_CTCPAR, "
		msUPDT += "                    '' CTQ_CCCPAR, "
		msUPDT += "                    '' CTQ_ITCPAR, "
		msUPDT += "                    CLVLPAR CTQ_CLCPAR, "
		msUPDT += "                    PERC CTQ_PERCEN, "
		msUPDT += "                    '' D_E_L_E_T_, "
		msUPDT += "             ( "
		msUPDT += "                 SELECT MAX(R_E_C_N_O_) "
		msUPDT += "                 FROM " + RetSqlName("CTQ") + " CTQ(NOLOCK) "
		msUPDT += "             ) + ROW_NUMBER() OVER( "
		msUPDT += "                    ORDER BY RATEIO) AS R_E_C_N_O_, "
		msUPDT += "                    0 R_E_C_D_E_L_, "
		msUPDT += "                    '' CTQ_UM, "
		msUPDT += "                    0 CTQ_VALOR, "
		msUPDT += "                    '1' CTQ_FORMUL, "
		msUPDT += "                    '2' CTQ_INTERC, "
		msUPDT += "                    '' CTQ_AMARRA, "
		msUPDT += "                    '2' CTQ_MSBLQL, "
		msUPDT += "                    '1' CTQ_STATUS "
		msUPDT += "             FROM RATGERAL RTG "
		msUPDT += "             WHERE NOT EXISTS "
		msUPDT += "             ( "
		msUPDT += "                  SELECT * "
		msUPDT += "                  FROM " + RetSqlName("CTQ") + " XXX "
		msUPDT += "                  WHERE XXX.CTQ_RATEIO + XXX.CTQ_SEQUEN = RTG.RATEIO + RTG.SEQUENC "
		msUPDT += "                        AND XXX.D_E_L_E_T_ = ' ' "
		msUPDT += "             ) "
		U_BIAMsgRun("Gravando Apropriação de Custo...",,{|| msStaExcQy := TcSQLExec(msUPDT)})
		If msStaExcQy < 0
			Aviso('Problema de Processamento', "Erro na execução da Instrução SQL. Favor abrir ticket para atendimento: " + msrhEnter + msrhEnter + msrhEnter + TCSQLError() + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
			lOk := .F.
		EndIf

		If lOk

			MsgINFO("Apropriação do Custo para Rateio gravado com sucesso.", "")

		Else

			DisarmTransaction()

		EndIf

	End Transaction 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 05/07/11 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Data Inicial             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Final               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
