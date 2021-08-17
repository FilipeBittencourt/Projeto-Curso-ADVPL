#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA620
@author Marcos Alberto Soprani
@since 22/03/16
@version 1.0
@description Movimento Diário de Produção
@obs Em 21/02/17, Por Marcos Alberto Soprani - incluído filtro AND B1_YTPPROD <> 'RP' para retirar os Rodapés do modelo até segunda ordem.
@type function
/*/

User Function BIA620()

	Local aArea     := GetArea()

	Private cCadastro 	:= "Movimento Diário de Produção"
	Private aRotina 	:= { {"Pesquisar"  			,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			,"AxVisual"     ,0,2},;
	{                         "Incluir"   			,"U_B620INC"    ,0,3},;
	{                         "Alterar"   			,"U_B620ALT"    ,0,4},;
	{                         "Processar"      		,"U_BIA620P"    ,0,5},;
	{                         "Excel"     			,"U_BIA620A"    ,0,6},;
	{                         "Carga SAP"  			,"U_B620SAP"    ,0,7},;
	{                         "Chk Metas"           ,"U_BIA620M"    ,0,8},;
	{                         "Fechamento Mensal"	,"U_B620Fhm"    ,0,9} }

	dbSelectArea("Z75")
	dbSetOrder(1)

	Public XB620VALID := .T.

	mBrowse(6,1,22,75,"Z75",,,,,,)

	RestArea( aArea )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B620INC  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07/04/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de Alteração                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B620INC()

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local nOpcao	:= 0
	Local cAlias	:= "Z75"

	nOpcao := AxInclui(cAlias)

	RestArea(aArea)

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B620ALT  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07/04/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de Alteração                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B620ALT()

	Local lRet		 := .T.
	Local aArea		 := GetArea()
	Local nOpcao	 := 0
	Private aCpos	 := {"Z75_TPMOV", "Z75_DATARF", "Z75_PRODUT", "Z75_TPPROD", "Z75_TURNO", "Z75_EQUIPE", "Z75_LINHA", "Z75_QUANT", "Z75_METARF", "Z75_QUALIT", "Z75_QTD_A"}  // CAMPOS que permite edição

	If Z75->Z75_TIPO2 = "I"

		nOpcao := AxAltera("Z75",Z75->(Recno()),4,,aCpos,,,"U_B620TOK()",,,,,,,.T.,,,,,)

	Else

		MsgINFO("Somente registros TIPO2 igual a Informado poderão ser alterados. Favor verificar...")

	EndIf

	RestArea(aArea)

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B620TOK  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07/04/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Incluído TudoOk apenas para preenchimento dos campos Delta ¦¦¦ 
¦¦           ¦ e hora delta                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B620TOK()

	Local lRet		 := .T.
	Local aArea		 := GetArea()

	M->Z75_DELTA  := date()
	M->Z75_HRDELT := time()

	RestArea(aArea)

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA620P  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera as informações de Liberado e Etiquetado               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA620P()

	Processa({|| RptPDetail()})

Return

Static Function RptPDetail()

	Local _dDtAte
	Local kr, wd

	fPerg := "BIA620"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	//************************************************************************************************
	ZP003 := " DELETE "+RetSqlName("Z75")+" "
	ZP003 += "   FROM "+RetSqlName("Z75")+" "
	ZP003 += "  WHERE Z75_FILIAL = '"+xFilial("Z75")+"' "
	ZP003 += "    AND Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	ZP003 += "    AND Z75_TIPO2 <> 'I'
	ZP003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Movimentação da produção no período definido",,{|| TCSQLExec(ZP003)})

	If cEmpAnt $ "01/05/14"

		If cEmpAnt == "01"
			kt_BsDad := "DADOSEOS"
		ElseIf cEmpAnt == "05"
			kt_BsDad := "DADOS_05_EOS"
		ElseIf cEmpAnt == "14"
			kt_BsDad := "DADOS_14_EOS"			
		EndIf

		//                                                                                      Etiquetado
		//************************************************************************************************
		ET001 := " WITH ETIQUETADO AS (SELECT RTRIM(A.COD_PRODUTO) PRODUT, "
		ET001 += "                            A.CE_NUMERO_DOCTO ETIQUETA, "
		ET001 += "                            SUBSTRING(B1_DESC,1,50) DESCR, "
		ET001 += "                            CASE "
		ET001 += "                              WHEN ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' ) THEN A.CE_QTDADE * (-1) "
		ET001 += "                              ELSE A.CE_QTDADE "
		ET001 += "                            END QUANT, "
		ET001 += "                            A.CE_TURNO EQUIPE, "
		ET001 += "                            CASE "
		ET001 += "                              WHEN A.CE_FORNO IN('1','9') THEN 'L01' "
		ET001 += "                              WHEN A.CE_FORNO IN('2','7') THEN 'L02' "
		ET001 += "                              WHEN A.CE_FORNO IN('10') THEN 'L04' "
		ET001 += "                              WHEN A.CE_FORNO IN('11') THEN 'L05' "		
		ET001 += "                              WHEN A.CE_FORNO IN('3') THEN 'E03' "
		ET001 += "                              WHEN A.CE_FORNO IN('4') THEN 'E04' "
		ET001 += "                              ELSE 'VRF' "
		ET001 += "                            END LINHA, "
		ET001 += "                            B.ETIQ_DATA, "
		ET001 += "                            CASE "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '17:59:59' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '21:59:59' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00') "
		ET001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		ET001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '13:59:59' "
		ET001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		ET001 += "                            END DATA_TURNO "
		ET001 += "                       FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A "
		ET001 += "                       JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA "
		ET001 += "                                                           AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO "
		ET001 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = A.COD_PRODUTO COLLATE SQL_Latin1_General_CP1_CI_AS "
		ET001 += "                                           AND B1_YTPPROD <> 'RP' " 
		ET001 += "                                           AND SB1.D_E_L_E_T_ = ' ' "
		ET001 += "                      WHERE A.ID_CIA = 1 "
		ET001 += "                        AND ( ( A.COD_TRANSACAO IN('1','20') AND A.CE_DOCTO <> 'SA' ) OR ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' ) ) "
		ET001 += "                        AND NOT ( A.COD_TRANSACAO = '20' AND B.ETIQ_TRANSITO_PRODUCAO = 1 ) "
		ET001 += "                        AND SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10) BETWEEN '"+dtos(MV_PAR01-31)+"' AND '"+dtos(MV_PAR02+31)+"') "
		ET001 += " SELECT 'ETQ' TPMOV, "
		ET001 += "        SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) DATREF, "
		ET001 += "        PRODUT, "
		ET001 += "        DESCR, "
		ET001 += "        SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5) HRTURNO, "
		ET001 += "        EQUIPE, "
		ET001 += "        LINHA, "
		ET001 += "        SUM(QUANT) QUANT "
		ET001 += "   FROM ETIQUETADO "
		ET001 += "  WHERE SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		ET001 += "  GROUP BY PRODUT, "
		ET001 += "           DESCR, "
		ET001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		ET001 += "           EQUIPE, "
		ET001 += "           LINHA, "
		ET001 += "           SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) "
		ET001 += "  ORDER BY PRODUT, "
		ET001 += "           DESCR, "
		ET001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		ET001 += "           EQUIPE, "
		ET001 += "           LINHA, "
		ET001 += "           SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) "
		ETcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ET001),'ET01',.F.,.T.)
		dbSelectArea("ET01")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento1")

			hsTurno := IIF(ET01->HRTURNO == "06:00", "D", IIF(ET01->HRTURNO == "14:00", "T", "N"))

			If ET01->QUANT <> 0

				// Grava Registro para PA e PS
				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + ET01->TPMOV + ET01->DATREF + ET01->PRODUT + hsTurno + ET01->EQUIPE + ET01->LINHA + "C" + "N")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := ET01->TPMOV
				Z75->Z75_DATARF := stod(ET01->DATREF)
				Z75->Z75_PRODUT := ET01->PRODUT
				Z75->Z75_TPPROD := IIF(Substr(ET01->PRODUT,1,2) == "C1", "PS", "PA")
				Z75->Z75_TURNO  := hsTurno
				Z75->Z75_EQUIPE := ET01->EQUIPE
				Z75->Z75_LINHA  := ET01->LINHA
				Z75->Z75_QUANT  += ET01->QUANT
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"
				MsUnlock()

				// Grava Registro para PP
				If !ET01->LINHA $ "E03/E04"

					hCodPP := Substr(ET01->PRODUT,1,7) + Space(8)
					dbSelectArea("Z75")
					dbSetOrder(1)
					If !dbSeek(xFilial("Z75") + ET01->TPMOV + ET01->DATREF + hCodPP + hsTurno + ET01->EQUIPE + ET01->LINHA + "C" + "N")
						RecLock("Z75",.T.)
					Else
						RecLock("Z75",.F.)
					EndIf
					Z75->Z75_FILIAL := xFilial("Z75")
					Z75->Z75_TPMOV  := ET01->TPMOV
					Z75->Z75_DATARF := stod(ET01->DATREF)
					Z75->Z75_PRODUT := hCodPP
					Z75->Z75_TPPROD := "PP"
					Z75->Z75_TURNO  := hsTurno
					Z75->Z75_EQUIPE := ET01->EQUIPE
					Z75->Z75_LINHA  := ET01->LINHA
					Z75->Z75_QUANT  += ET01->QUANT
					Z75->Z75_DELTA  := date()
					Z75->Z75_HRDELT := time()
					Z75->Z75_TIPO2  := "C"
					Z75->Z75_AJUSTE := "N"
					MsUnlock()

				EndIf

			EndIf
			dbSelectArea("ET01")
			dbSkip()

		End

		ET01->(dbCloseArea())
		Ferase(ETcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(ETcIndex+OrdBagExt())          //indice gerado

		//                                                                                        Liberado
		//************************************************************************************************
		LB001 := " WITH LIBERADO AS (SELECT Z18_COD PRODUT, "
		LB001 += "                          Z18_NUMETQ, "
		LB001 += "                          SUBSTRING(B1_DESC,1,50) DESCR, "
		LB001 += "                          A.CE_TURNO EQUIPE, "
		LB001 += "                          CASE "
		LB001 += "                            WHEN A.CE_FORNO IN('1','9') THEN 'L01' "
		LB001 += "                            WHEN A.CE_FORNO IN('2','7') THEN 'L02' "
		LB001 += "                            WHEN A.CE_FORNO IN('10') THEN 'L04' "
		LB001 += "                            WHEN A.CE_FORNO IN('11') THEN 'L05' "	
		LB001 += "                            WHEN A.CE_FORNO IN('3') THEN 'E03' "
		LB001 += "                            WHEN A.CE_FORNO IN('4') THEN 'E04' "
		LB001 += "                            ELSE 'VRF' "
		LB001 += "                          END LINHA, "
		LB001 += "                          Z18_DATA DATREF, "
		LB001 += "                          CASE "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '17:59:59' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '21:59:59' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '14:00:00') "
		LB001 += "                     WHEN CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		LB001 += "                          AND CONVERT(SMALLDATETIME, B.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '13:59:59' "
		LB001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, B.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		LB001 += "                          END DATA_TURNO, "
		LB001 += "                   	    CASE "
		LB001 += "                   	      WHEN Z18_TM = 'EST' THEN Z18_QUANT*(-1) "
		LB001 += "                   		  ELSE Z18_QUANT "
		LB001 += "                   	    END QUANT "
		LB001 += "                     FROM "+RetSqlName("Z18")+" Z18 "
		LB001 += "                    INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = Z18_COD "
		LB001 += "                                         AND B1_YTPPROD <> 'RP' " 
		LB001 += "                                         AND SB1.D_E_L_E_T_ = ' ' "
		LB001 += "                    INNER JOIN "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A ON A.cod_produto = Z18_COD COLLATE SQL_Latin1_General_CP1_CI_AS "
		LB001 += "                                                                AND A.CE_NUMERO_DOCTO = Z18_NUMETQ "
		LB001 += " 							                                      AND A.ID_MOV_PROD = Z18_IDECO "
		LB001 += "                                                                AND A.ID_CIA = 1 "
		LB001 += "                                                                AND ( ( A.COD_TRANSACAO IN('1','20') AND A.CE_DOCTO <> 'SA' ) OR ( A.COD_TRANSACAO = 64 AND A.CE_DOCTO = 'CP' ) ) "
		LB001 += "                    INNER JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA "
		LB001 += "                                                              AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO "
		LB001 += "                    WHERE Z18_FILIAL = '"+xFilial("Z18")+"' "
		LB001 += "                      AND Z18_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		LB001 += "                      AND Z18.D_E_L_E_T_ = ' ') "
		LB001 += " SELECT 'LIB' TPMOV, "
		LB001 += "        DATREF, "
		LB001 += "        RTRIM(PRODUT) PRODUT, "
		LB001 += "        DESCR, "
		LB001 += "        SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5) HRTURNO, "
		LB001 += "        EQUIPE, "
		LB001 += "        LINHA, "
		LB001 += " 	      SUM(QUANT) QUANT "
		LB001 += "   FROM LIBERADO "
		LB001 += "  GROUP BY PRODUT, "
		LB001 += "           DESCR, "
		LB001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		LB001 += "           EQUIPE, "
		LB001 += "           LINHA, "
		LB001 += " 	         DATREF "
		LB001 += "  ORDER BY PRODUT, "
		LB001 += "           DESCR, "
		LB001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		LB001 += "           EQUIPE, "
		LB001 += "           LINHA, "
		LB001 += " 	         DATREF "
		LBcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,LB001),'LB01',.F.,.T.)
		dbSelectArea("LB01")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento2")

			If LB01->QUANT <> 0

				hsTurno := IIF(LB01->HRTURNO == "06:00", "D", IIF(LB01->HRTURNO == "14:00", "T", "N"))

				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + LB01->TPMOV + LB01->DATREF + LB01->PRODUT + hsTurno + LB01->EQUIPE + LB01->LINHA + "C" + "N")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := LB01->TPMOV
				Z75->Z75_DATARF := stod(LB01->DATREF)
				Z75->Z75_PRODUT := LB01->PRODUT
				Z75->Z75_TPPROD := IIF(Substr(LB01->PRODUT,1,2) == "C1", "PS", "PA")
				Z75->Z75_TURNO  := hsTurno
				Z75->Z75_EQUIPE := LB01->EQUIPE
				Z75->Z75_LINHA  := LB01->LINHA
				Z75->Z75_QUANT  += LB01->QUANT
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"
				MsUnlock()

			EndIf

			dbSelectArea("LB01")
			dbSkip()

		End

		LB01->(dbCloseArea())
		Ferase(LBcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(LBcIndex+OrdBagExt())          //indice gerado

		//Gabriel - Solicitado por Marcos - Incluir casos de etiquetas retidas
		//                                                                                          Retido
		//************************************************************************************************
		RT001 := " WITH ETIQUETADO AS (SELECT RTRIM(A.COD_PRODUTO) PRODUT, "
		RT001 += "                            A.cod_etiqueta ETIQUETA, "
		RT001 += "                            SUBSTRING(B1_DESC,1,50) DESCR, "
		RT001 += "  					      A.etiq_qtde QUANT, "
		RT001 += "                            A.etiq_turma EQUIPE, "
		RT001 += "                            CASE "
		RT001 += "                              WHEN A.etiq_forno IN('1','9') THEN 'L01' "
		RT001 += "                              WHEN A.etiq_forno IN('2','7') THEN 'L02' "
		RT001 += "                              WHEN A.etiq_forno IN('10') THEN 'L04' "
		RT001 += "                              WHEN A.etiq_forno IN('11') THEN 'L05' "	
		RT001 += "                              WHEN A.etiq_forno IN('3') THEN 'E03' "
		RT001 += "                              WHEN A.etiq_forno IN('4') THEN 'E04' "
		RT001 += "                              ELSE 'VRF' "
		RT001 += "                            END LINHA, "
		RT001 += " 						      A.ETIQ_DATA, "
		RT001 += "                            CASE "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, A.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '18:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '18:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) <= '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '17:59:59' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '00:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '05:59:00' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, -1, A.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '22:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '23:59:59' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '22:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '14:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '21:59:59' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '14:00:00') "
		RT001 += "                     WHEN CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) > '2019-10-21 06:00:00' "
		RT001 += "                          AND CONVERT(SMALLDATETIME, A.ETIQ_DATA, 120) BETWEEN SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '06:00:00' AND SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '13:59:59' "
		RT001 += "                     THEN CONVERT(SMALLDATETIME, SUBSTRING(CONVERT(CHAR, DATEADD(DAY, 0, A.ETIQ_DATA), 120), 1, 11) + '06:00:00') "
		RT001 += "                            END DATA_TURNO "
		RT001 += "                       FROM "+kt_BsDad+"..CEP_ETIQUETA_PALLET A "
		RT001 += "                      INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = A.COD_PRODUTO COLLATE SQL_Latin1_General_CP1_CI_AS "
		RT001 += "                                           AND B1_YTPPROD <> 'RP' " 
		RT001 += "                                           AND SB1.D_E_L_E_T_ = ' ' "
		RT001 += "                      WHERE A.ID_CIA = 1 "
		RT001 += "                        AND ETIQ_RETIDO <> 0 "
		RT001 += "                        AND NF_NUMERO = '' "
		RT001 += "                        AND etiq_cancelada <> '1' "
		RT001 += " 	    			      AND SUBSTRING(CONVERT(VARCHAR(10), A.ETIQ_DATA, 112), 1, 10) BETWEEN '"+dtos(MV_PAR01-31)+"' AND '"+dtos(MV_PAR02+31)+"') "
		RT001 += " SELECT 'RET' TPMOV, "
		RT001 += "        SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) DATREF, "
		RT001 += "        PRODUT, "
		RT001 += "        DESCR, "
		RT001 += "        SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5) HRTURNO, "
		RT001 += "        EQUIPE, "
		RT001 += "        LINHA, "
		RT001 += " 	      SUM(QUANT) QUANT "
		RT001 += "   FROM ETIQUETADO "
		RT001 += "  WHERE SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		RT001 += "  GROUP BY PRODUT, "
		RT001 += "           DESCR, "
		RT001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		RT001 += "           EQUIPE, "
		RT001 += "           LINHA, "
		RT001 += " 	         SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) "
		RT001 += "  ORDER BY PRODUT, "
		RT001 += "           DESCR, "
		RT001 += "           SUBSTRING(CONVERT(VARCHAR(16), DATA_TURNO, 120), 12, 5), "
		RT001 += "           EQUIPE, "
		RT001 += "           LINHA, "
		RT001 += " 	         SUBSTRING(CONVERT(VARCHAR(10), DATA_TURNO, 112), 1, 10) "
		RTcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT001),'RT01',.F.,.T.)
		dbSelectArea("RT01")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento3")

			hsTurno := IIF(RT01->HRTURNO == "06:00", "D", IIF(RT01->HRTURNO == "14:00", "T", "N"))

			If RT01->QUANT <> 0

				// Grava Registro para PA e PS
				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + RT01->TPMOV + RT01->DATREF + RT01->PRODUT + hsTurno + RT01->EQUIPE + RT01->LINHA + "C" + "N")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := RT01->TPMOV
				Z75->Z75_DATARF := stod(RT01->DATREF)
				Z75->Z75_PRODUT := RT01->PRODUT
				Z75->Z75_TPPROD := IIF(Substr(RT01->PRODUT,1,2) == "C1", "PS", "PA")
				Z75->Z75_TURNO  := hsTurno
				Z75->Z75_EQUIPE := RT01->EQUIPE
				Z75->Z75_LINHA  := RT01->LINHA
				Z75->Z75_QUANT  += RT01->QUANT
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"
				MsUnlock()

				// Grava Registro para PP
				If !RT01->LINHA $ "E03/E04"

					hCodPP := Substr(RT01->PRODUT,1,7) + Space(8)
					dbSelectArea("Z75")
					dbSetOrder(1)
					If !dbSeek(xFilial("Z75") + RT01->TPMOV + RT01->DATREF + hCodPP + hsTurno + RT01->EQUIPE + RT01->LINHA + "C" + "N")
						RecLock("Z75",.T.)
					Else
						RecLock("Z75",.F.)
					EndIf
					Z75->Z75_FILIAL := xFilial("Z75")
					Z75->Z75_TPMOV  := RT01->TPMOV
					Z75->Z75_DATARF := stod(RT01->DATREF)
					Z75->Z75_PRODUT := hCodPP
					Z75->Z75_TPPROD := "PP"
					Z75->Z75_TURNO  := hsTurno
					Z75->Z75_EQUIPE := RT01->EQUIPE
					Z75->Z75_LINHA  := RT01->LINHA
					Z75->Z75_QUANT  += RT01->QUANT
					Z75->Z75_DELTA  := date()
					Z75->Z75_HRDELT := time()
					Z75->Z75_TIPO2  := "C"
					Z75->Z75_AJUSTE := "N"
					MsUnlock()

				EndIf

			EndIf
			dbSelectArea("RT01")
			dbSkip()

		End

		RT01->(dbCloseArea())
		Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RTcIndex+OrdBagExt())          //indice gerado


		//                                                 Etiquetado - para ajustes de Produção realizada
		//************************************************************************************************
		XE001 := " SELECT 'ETQ' TPMOV,
		XE001 += "        Z76_DDATA DATREF,
		XE001 += "        Z76_DLINHA LINHA,
		XE001 += "        Z76_DEQUIP EQUIPE,
		XE001 += "        Z76_DTURNO TURNO,
		XE001 += "        Z76_DPROD PRODUT,
		XE001 += "        Z76_DQUANT QUANT
		XE001 += "   FROM " + RetSqlName("Z76")
		XE001 += "  WHERE Z76_FILIAL = '"+xFilial("Z76")+"'
		XE001 += "    AND Z76_DDATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		XE001 += "    AND D_E_L_E_T_ = ' '
		XE001 += "  UNION ALL
		XE001 += " SELECT 'ETQ' TPMOV,
		XE001 += "        Z76_PDATA DATREF,
		XE001 += "        Z76_PLINHA LINHA,
		XE001 += "        Z76_PEQUIP EQUIPE,
		XE001 += "        Z76_PTURNO TURNO,
		XE001 += "        Z76_PPROD PRODUT,
		XE001 += "        Z76_PQUANT * (-1) QUANT
		XE001 += "   FROM " + RetSqlName("Z76")
		XE001 += "  WHERE Z76_FILIAL = '"+xFilial("Z76")+"'
		XE001 += "    AND Z76_PDATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		XE001 += "    AND D_E_L_E_T_ = ' '
		XEcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,XE001),'XE01',.F.,.T.)
		dbSelectArea("XE01")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento4")

			If XE01->QUANT <> 0

				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + XE01->TPMOV + XE01->DATREF + XE01->PRODUT + XE01->TURNO + XE01->EQUIPE + XE01->LINHA + "C" + "S")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := XE01->TPMOV
				Z75->Z75_DATARF := stod(XE01->DATREF)
				Z75->Z75_PRODUT := XE01->PRODUT
				Z75->Z75_TPPROD := IIF(Substr(XE01->PRODUT,1,2) == "C1", "PS", "PA")
				Z75->Z75_TURNO  := XE01->TURNO
				Z75->Z75_EQUIPE := XE01->EQUIPE
				Z75->Z75_LINHA  := XE01->LINHA
				Z75->Z75_QUANT  += XE01->QUANT
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "S"
				MsUnlock()

			EndIf

			dbSelectArea("XE01")
			dbSkip()

		End

		XE01->(dbCloseArea())
		Ferase(XEcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(XEcIndex+OrdBagExt())          //indice gerado

	EndIf

	//                                                                     Grava Registro para META(1)
	//************************************************************************************************
	QP002 := " WITH MOVPROD AS (SELECT Z75.Z75_FILIAL, "
	QP002 += "                         Z75.Z75_TPMOV, "
	QP002 += "                         Z75.Z75_DATARF, "
	QP002 += "                         Z75.Z75_PRODUT, "
	QP002 += "                         Z75.Z75_TPPROD, "
	QP002 += "                         Z75.Z75_TURNO, "
	QP002 += "                         Z75.Z75_EQUIPE, "
	QP002 += "                         Z75.Z75_LINHA, "
	QP002 += "                         Z75.Z75_TIPO2, "
	QP002 += "                         Z75.Z75_AJUSTE, "
	QP002 += "                         Z75.Z75_QUANT, "
	QP002 += "                         Z75.R_E_C_N_O_ REGZ75, "
	QP002 += "                         CASE "
	QP002 += "                           WHEN Z75_EQUIPE = '1' THEN (SELECT Z73_TUREQ1 "
	QP002 += "                                                         FROM "+RetSqlName("Z73")+" Z73 "
	QP002 += "                                                        WHERE Z73_FILIAL = '"+xFilial("Z73")+"' "
	QP002 += "                                                          AND Z73_DIA = Z75_DATARF "
	QP002 += "                                                          AND Z73.D_E_L_E_T_ = ' ') "
	QP002 += "                           WHEN Z75_EQUIPE = '2' THEN (SELECT Z73_TUREQ2 "
	QP002 += "                                                         FROM "+RetSqlName("Z73")+" Z73 "
	QP002 += "                                                        WHERE Z73_FILIAL = '"+xFilial("Z73")+"' "
	QP002 += "                                                          AND Z73_DIA = Z75_DATARF "
	QP002 += "                                                          AND Z73.D_E_L_E_T_ = ' ') "
	QP002 += "                           WHEN Z75_EQUIPE = '3' THEN (SELECT Z73_TUREQ3 "
	QP002 += "                                                         FROM "+RetSqlName("Z73")+" Z73 "
	QP002 += "                                                        WHERE Z73_FILIAL = '"+xFilial("Z73")+"' "
	QP002 += "                                                          AND Z73_DIA = Z75_DATARF "
	QP002 += "                                                          AND Z73.D_E_L_E_T_ = ' ') "
	QP002 += "                           WHEN Z75_EQUIPE = '4' THEN (SELECT Z73_TUREQ4 "
	QP002 += "                                                         FROM "+RetSqlName("Z73")+" Z73 "
	QP002 += "                                                        WHERE Z73_FILIAL = '"+xFilial("Z73")+"' "
	QP002 += "                                                          AND Z73_DIA = Z75_DATARF "
	QP002 += "                                                          AND Z73.D_E_L_E_T_ = ' ') "
	QP002 += "                         END ESCALA "
	QP002 += "                    FROM "+RetSqlName("Z75")+" Z75 "
	QP002 += "                   WHERE Z75.Z75_FILIAL = '"+xFilial("Z75")+"' "
	QP002 += "                     AND Z75.Z75_TPMOV = 'ETQ' "
	QP002 += "                     AND Z75.Z75_AJUSTE <> 'S' "
	QP002 += "                     AND Z75.Z75_QUANT <> 0 "
	QP002 += "                     AND Z75.Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	QP002 += "                     AND Z75.D_E_L_E_T_ = ' ') "
	QP002 += " SELECT MVPRD.*, "
	QP002 += "        ISNULL((SELECT SUM(XX75.Z75_QUANT) "
	QP002 += "                  FROM "+RetSqlName("Z75")+" XX75 "
	QP002 += "                 WHERE XX75.Z75_FILIAL = MVPRD.Z75_FILIAL "
	QP002 += "                   AND XX75.Z75_TPMOV = MVPRD.Z75_TPMOV "
	QP002 += "                   AND XX75.Z75_DATARF = MVPRD.Z75_DATARF "
	QP002 += "                   AND XX75.Z75_EQUIPE = MVPRD.Z75_EQUIPE "
	QP002 += "                   AND XX75.Z75_LINHA = MVPRD.Z75_LINHA "
	QP002 += "                   AND SUBSTRING(XX75.Z75_PRODUT,1,2) = SUBSTRING(MVPRD.Z75_PRODUT,1,2) "
	QP002 += "                   AND XX75.Z75_AJUSTE <> 'S' "
	QP002 += "                   AND XX75.Z75_TPPROD = MVPRD.Z75_TPPROD "
	QP002 += "                   AND XX75.D_E_L_E_T_ = ' '),0) QTDAGRP, "
	QP002 += "        ISNULL((SELECT SUM(XX74.Z74_METAQT) "
	QP002 += "                  FROM "+RetSqlName("Z74")+" XX74 "
	QP002 += "                 WHERE XX74.Z74_FILIAL = '"+xFilial("Z74")+"' "
	QP002 += "                   AND XX74.Z74_DATA = MVPRD.Z75_DATARF "
	QP002 += "                   AND XX74.Z74_TURNO = MVPRD.ESCALA "
	QP002 += "                   AND XX74.Z74_LINHA = MVPRD.Z75_LINHA "
	QP002 += "                   AND XX74.Z74_FORMAT = SUBSTRING(MVPRD.Z75_PRODUT,1,2) "
	QP002 += "                   AND XX74.D_E_L_E_T_ = ' '),0) META "
	QP002 += "   FROM MOVPROD MVPRD "
	QP002 += "  WHERE ESCALA <> ' ' "
	QPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QP002),'QP02',.F.,.T.)
	dbSelectArea("QP02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processando4 - Metas de Quantidade...")

		dbSelectArea("Z75")
		dbGoTo(QP02->REGZ75)
		RecLock("Z75", .F.)
		Z75->Z75_ESCALA := QP02->ESCALA
		Z75->Z75_QTMETA := QP02->Z75_QUANT / QP02->QTDAGRP * QP02->META
		MsUnLock()

		dbSelectArea("QP02")
		dbSkip()

	End

	QP02->(dbCloseArea())
	Ferase(QPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QPcIndex+OrdBagExt())          //indice gerado

	//                                                                     Grava Registro para META(2)
	//                                           ... para os formatos que não possuiam produção no dia
	//************************************************************************************************
	JQ008 := " WITH METAATRIB AS (SELECT Z75_DATARF, "
	JQ008 += "                           Z75_LINHA, "
	JQ008 += "                           Z75_ESCALA, "
	JQ008 += "                           FORMATO, "
	JQ008 += "                           Z75_TURNO, "
	JQ008 += "                           SUM(METAPA) METAPA, "
	JQ008 += "                           SUM(METAPP) METAPP "
	JQ008 += "                      FROM (SELECT Z75_DATARF, "
	JQ008 += "                                   Z75_TPPROD, "
	JQ008 += "                                   Z75_LINHA, "
	JQ008 += "                                   Z75_ESCALA,  "
	JQ008 += "                                   SUBSTRING(Z75_PRODUT,1,2) FORMATO, "
	JQ008 += "                                   Z75_TURNO, "
	JQ008 += "                                   ROUND(SUM(Z75_QTMETA),2) METAPA, "
	JQ008 += "                                   0 METAPP "
	JQ008 += "                              FROM " + RetSqlName("Z75") + " "
	JQ008 += "                             WHERE Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	JQ008 += "                               AND Z75_TPMOV = 'ETQ' "
	JQ008 += "                               AND Z75_AJUSTE <> 'S' "
	JQ008 += "                               AND Z75_TPPROD IN('PA','PS') "
	JQ008 += "                               AND Z75_ESCALA <> ' ' "
	JQ008 += "                               AND D_E_L_E_T_ = ' ' "
	JQ008 += "                             GROUP BY Z75_DATARF, "
	JQ008 += "                                      Z75_TPPROD, "
	JQ008 += "                                      Z75_LINHA, "
	JQ008 += "                                      Z75_ESCALA, "
	JQ008 += "                                      SUBSTRING(Z75_PRODUT,1,2), "
	JQ008 += "                                      Z75_TURNO "
	JQ008 += "                              UNION ALL "
	JQ008 += "                             SELECT Z75_DATARF, "
	JQ008 += "                                   Z75_TPPROD, "
	JQ008 += "                                   Z75_LINHA, "
	JQ008 += "                                   Z75_ESCALA,  "
	JQ008 += "                                   SUBSTRING(Z75_PRODUT,1,2) FORMATO, "
	JQ008 += "                                   Z75_TURNO, "
	JQ008 += "                                   0 METAPA, "
	JQ008 += "                                   ROUND(SUM(Z75_QTMETA),2) METAPP "
	JQ008 += "                              FROM " + RetSqlName("Z75") + " "
	JQ008 += "                             WHERE Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	JQ008 += "                               AND Z75_TPMOV = 'ETQ' "
	JQ008 += "                               AND Z75_AJUSTE <> 'S' "
	JQ008 += "                               AND Z75_TPPROD IN('PP') "
	JQ008 += "                               AND Z75_ESCALA <> ' ' "
	JQ008 += "                               AND D_E_L_E_T_ = ' ' "
	JQ008 += "                             GROUP BY Z75_DATARF, "
	JQ008 += "                                      Z75_TPPROD, "
	JQ008 += "                                      Z75_LINHA, "
	JQ008 += "                                      Z75_ESCALA, "
	JQ008 += "                                      SUBSTRING(Z75_PRODUT,1,2), "
	JQ008 += "                                      Z75_TURNO) AS TABT "
	JQ008 += "                  GROUP BY Z75_DATARF, "
	JQ008 += "                           Z75_LINHA, "
	JQ008 += "                           Z75_ESCALA, "
	JQ008 += "                           FORMATO, "
	JQ008 += "                           Z75_TURNO) "
	JQ008 += " SELECT Z74_DATA, "
	JQ008 += "        Z74_LINHA, "
	JQ008 += "        Z74_FORMAT, "
	JQ008 += "        Z74_TURNO, "
	JQ008 += "        ROUND(Z74_METAQT, 2) Z74_METAQT, "
	JQ008 += "        ROUND(SUM(METAPA), 2) METAPA, "
	JQ008 += "        ROUND(SUM(METAPP), 2) METAPP "
	JQ008 += "   FROM (SELECT Z74_DATA, "
	JQ008 += "                Z74_LINHA, "
	JQ008 += "                Z74_FORMAT, "
	JQ008 += "                Z74_TURNO, "
	JQ008 += "                Z74_METAQT, "
	JQ008 += "                ISNULL(METAPA, 0) METAPA, "
	JQ008 += "                ISNULL(METAPP, 0) METAPP "
	JQ008 += "           FROM " + RetSqlName("Z74") + " Z74 "
	JQ008 += "           LEFT JOIN METAATRIB MTA ON Z75_DATARF = Z74_DATA "
	JQ008 += "                                  AND Z75_LINHA = Z74_LINHA "
	JQ008 += "                                  AND Z75_ESCALA = Z74_TURNO "
	JQ008 += "                                  AND FORMATO = Z74_FORMAT "
	JQ008 += "                                  AND Z74.D_E_L_E_T_ = ' ' "
	JQ008 += "          WHERE Z74_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	JQ008 += "            AND Z74.D_E_L_E_T_ = ' ') AS TABRFE "
	JQ008 += "  WHERE METAPP <> Z74_METAQT "
	JQ008 += "     OR METAPA <> Z74_METAQT "
	JQ008 += "  GROUP BY Z74_DATA, "
	JQ008 += "           Z74_LINHA, "
	JQ008 += "           Z74_FORMAT, "
	JQ008 += "           Z74_TURNO, "
	JQ008 += "           Z74_METAQT "
	JQ008 += "  ORDER BY 2, 3 "
	JQcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,JQ008),'JQ08',.F.,.T.)
	dbSelectArea("JQ08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento4.1 - Meta sem Produção...")

		WU003 := " WITH ESCALATURN AS (SELECT Z73_DIA DIA, "
		WU003 += "                            '1     ' EQUIPE, "
		WU003 += "                            Z73_EQ1 TRAB, "
		WU003 += "                            Z73_TUREQ1 TURNO "
		WU003 += "                       FROM " + RetSqlName("Z73") + " "
		WU003 += "                      WHERE D_E_L_E_T_ = ' ' "
		WU003 += "                      UNION ALL "
		WU003 += "                     SELECT Z73_DIA DIA, "
		WU003 += "                            '2     ' EQUIPE, "
		WU003 += "                            Z73_EQ2 TRAB, "
		WU003 += "                            Z73_TUREQ2 TURNO "
		WU003 += "                       FROM " + RetSqlName("Z73") + " "
		WU003 += "                      WHERE D_E_L_E_T_ = ' ' "
		WU003 += "                      UNION ALL "
		WU003 += "                     SELECT Z73_DIA DIA, "
		WU003 += "                            '3     ' EQUIPE, "
		WU003 += "                            Z73_EQ3 TRAB, "
		WU003 += "                            Z73_TUREQ3 TURNO "
		WU003 += "                       FROM " + RetSqlName("Z73") + " "
		WU003 += "                      WHERE D_E_L_E_T_ = ' ' "
		WU003 += "                      UNION ALL "
		WU003 += "                     SELECT Z73_DIA DIA, "
		WU003 += "                            '4     ' EQUIPE, "
		WU003 += "                            Z73_EQ4 TRAB, "
		WU003 += "                            Z73_TUREQ4 TURNO "
		WU003 += "                       FROM " + RetSqlName("Z73") + " "
		WU003 += "                      WHERE D_E_L_E_T_ = ' ') "
		WU003 += " SELECT * "
		WU003 += "   FROM ESCALATURN "
		WU003 += "  WHERE DIA = '" + JQ08->Z74_DATA + "' "
		WU003 += "    AND TRAB = 'S' "
		WU003 += "    AND TURNO = '" + JQ08->Z74_TURNO + "' "
		WUcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,WU003),'WU03',.F.,.T.)
		dbSelectArea("WU03")
		dbGoTop()
		qtEquip := WU03->EQUIPE
		WU03->(dbCloseArea())
		Ferase(WUcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(WUcIndex+OrdBagExt())          //indice gerado

		If JQ08->METAPA <> JQ08->Z74_METAQT .and. !JQ08->Z74_LINHA $ "L03" .and. !(JQ08->Z74_FORMAT == "CE" .and. JQ08->Z74_LINHA == "L02")

			xfProdut := JQ08->Z74_FORMAT + "000001       "

			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+xfProdut)) 

				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + "ETQ" + JQ08->Z74_DATA + xfProdut + JQ08->Z74_TURNO + qtEquip + JQ08->Z74_LINHA + "C" + "N")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := "ETQ"
				Z75->Z75_DATARF := stod(JQ08->Z74_DATA)
				Z75->Z75_PRODUT := xfProdut
				Z75->Z75_TPPROD := IIF(Substr(xfProdut,1,2) == "C1", "PS", "PA")
				Z75->Z75_TURNO  := JQ08->Z74_TURNO
				Z75->Z75_ESCALA := JQ08->Z74_TURNO
				Z75->Z75_EQUIPE := qtEquip
				Z75->Z75_LINHA  := JQ08->Z74_LINHA
				Z75->Z75_QUANT  := 0
				Z75->Z75_QTMETA := JQ08->Z74_METAQT - JQ08->METAPA
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"
				MsUnlock()

			Else

				MsgSTOP("O produto: " + Alltrim(xfProdut) + " não está cadastrado. Favor efetuar o cadastro e efetuar o reprocessamento!!!")

			EndIf

		EndIf

		If JQ08->METAPP <> JQ08->Z74_METAQT .and. !JQ08->Z74_LINHA $ "E03/E04"

			xfProdut := JQ08->Z74_FORMAT + "00000        "

			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+xfProdut)) 

				dbSelectArea("Z75")
				dbSetOrder(1)
				If !dbSeek(xFilial("Z75") + "ETQ" + JQ08->Z74_DATA + xfProdut + JQ08->Z74_TURNO + qtEquip + JQ08->Z74_LINHA + "C" + "N")
					RecLock("Z75",.T.)
				Else
					RecLock("Z75",.F.)
				EndIf
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := "ETQ"
				Z75->Z75_DATARF := stod(JQ08->Z74_DATA)
				Z75->Z75_PRODUT := xfProdut
				Z75->Z75_TPPROD := "PP"
				Z75->Z75_TURNO  := JQ08->Z74_TURNO
				Z75->Z75_ESCALA := JQ08->Z74_TURNO
				Z75->Z75_EQUIPE := qtEquip
				Z75->Z75_LINHA  := JQ08->Z74_LINHA
				Z75->Z75_QUANT  := 0
				Z75->Z75_QTMETA := JQ08->Z74_METAQT - JQ08->METAPA
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"
				MsUnlock()

			Else

				MsgSTOP("O produto: " + Alltrim(xfProdut) + " não está cadastrado. Favor efetuar o cadastro e efetuar o reprocessamento!!!")

			EndIf

		EndIf

		dbSelectArea("JQ08")
		dbSkip()

	End

	JQ08->(dbCloseArea())
	Ferase(JQcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(JQcIndex+OrdBagExt())          //indice gerado

	//                                                                       Tratamento para Qualidade
	//************************************************************************************************
	TM003 := " UPDATE " + RetSqlName("Z75")+ " SET Z75_QUALIT = Z75_QUANT * ISNULL((SELECT TOP 1 Z71_QUALIT / 100 "
	TM003 += "                                                      FROM " + RetSqlName("Z71")+ " Z71 "
	TM003 += "                                                     WHERE Z71_FILIAL = '" + xFilial("Z71") + "' "
	TM003 += "                                                       AND Z71_DATADE <= Z75_DATARF "
	TM003 += "                                                       AND Z71_DATAAT >= Z75_DATARF "
	TM003 += "                                                       AND Z71_PRODUT = Z75_PRODUT "
	TM003 += "                                                       AND Z71.D_E_L_E_T_ = ' '), 0) "
	TM003 += "   FROM " + RetSqlName("Z75")+ " Z75 "
	TM003 += "  WHERE Z75.Z75_FILIAL = '" + xFilial("Z75") + "' "
	TM003 += "    AND Z75.Z75_TPMOV = 'ETQ' "
	TM003 += "    AND Z75.Z75_AJUSTE <> 'S' "
	TM003 += "    AND Z75.Z75_TPPROD <> 'PP' "
	TM003 += "    AND Z75.Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	TM003 += "    AND Z75.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Atualizando Base(1)... ",,{|| TcSQLExec(TM003)})

	// Quant. de PA para referência de Qualidade de Realizado (quantidade de A sobre a produção TOTAL) 
	//************************************************************************************************
	YS009 := " UPDATE " + RetSqlName("Z75")+ " SET Z75_QTD_A = Z75_QUANT "
	YS009 += "   FROM " + RetSqlName("Z75")+ " Z75 "
	YS009 += "   INNER JOIN " + RetSqlName("SB1")+ " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	YS009 += "                        AND B1_COD = Z75_PRODUT "
	YS009 += "                        AND B1_YCLASSE = '1' "
	YS009 += "                        AND SB1.D_E_L_E_T_ = ' ' "
	YS009 += "  WHERE Z75.Z75_FILIAL = '" + xFilial("Z75") + "' "
	YS009 += "    AND Z75.Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	//YS009 += "    AND Z75.Z75_TPMOV <> 'SPS' "
	YS009 += "    AND Z75.Z75_TPMOV IN('ETQ','LIB') "
	YS009 += "    AND Z75.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Atualizando Base(3)... ",,{|| TcSQLExec(YS009)})

	//                                                            Validando preenchimento da qualidade
	//************************************************************************************************
	msChkMetaOk := .T.
	fValidQlyt("1")

	//                                                                                     Saldo de PS
	//************************************************************************************************
	If msChkMetaOk

		DF007 := " SELECT DISTINCT Z75_DATARF "
		DF007 += "   FROM " + RetSqlName("Z75")+ " Z75 "
		DF007 += "  WHERE Z75.Z75_FILIAL = '" + xFilial("Z75") + "' "
		DF007 += "    AND Z75.Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		DF007 += "    AND Z75.D_E_L_E_T_ = ' ' "
		DF007 += "  ORDER BY Z75_DATARF "
		DFcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,DF007),'DF07',.F.,.T.)
		dbSelectArea("DF07")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processando5 - Saldo de PS... " + dtoc(stod(DF07->Z75_DATARF)))

			hfSaldoC1 := U_BIA251()

			For kr := 1 to Len(hfSaldoC1) 

				If hfSaldoC1[kr][2] <> 0

					dbSelectArea("Z75")
					dbSetOrder(1)
					If !dbSeek(xFilial("Z75") + "SPS" + DF07->Z75_DATARF + hfSaldoC1[kr][1] + " " + " " + "L02" + "C" + "N")
						RecLock("Z75",.T.)
					Else
						RecLock("Z75",.F.)
					EndIf
					Z75->Z75_FILIAL := xFilial("Z75")
					Z75->Z75_TPMOV  := "SPS"
					Z75->Z75_DATARF := stod(DF07->Z75_DATARF)
					Z75->Z75_PRODUT := hfSaldoC1[kr][1]
					Z75->Z75_TPPROD := "PS"
					Z75->Z75_TURNO  := " "
					Z75->Z75_EQUIPE := " "
					Z75->Z75_LINHA  := "L02"
					Z75->Z75_QUANT  += hfSaldoC1[kr][2]
					Z75->Z75_DELTA  := date()
					Z75->Z75_HRDELT := time()
					Z75->Z75_TIPO2  := "C"
					Z75->Z75_AJUSTE := "N"
					Z75->Z75_ESCALA := " "
					MsUnlock()

				EndIf

			Next kr

			dbSelectArea("DF07")
			dbSkip()

		End

		DF07->(dbCloseArea())
		Ferase(DFcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(DFcIndex+OrdBagExt())          //indice gerado

		// Restaura o grupo de perguntas....
		fPerg := "BIA620"
		Pergunte(fPerg ,.F.)

		//                                    Desdobrar os formatos B9, B0 e C6 para as equipes da linha 1
		//************************************************************************************************
		UP003 := " UPDATE " + RetSqlName("Z75") + " SET "
		UP003 += "        Z75_BKEQUI = Z75_EQUIPE, "
		UP003 += "        Z75_EQUIPE = '1     ', "
		UP003 += "        Z75_BKQTD = Z75_QUANT, "
		UP003 += "        Z75_BKQT_A = Z75_QTD_A, "
		UP003 += "        Z75_BKQTMT = Z75_QTMETA, "
		UP003 += "        Z75_BKMTQL = Z75_QUALIT "
		UP003 += "   FROM " + RetSqlName("Z75") + " "
		UP003 += "  WHERE Z75_FILIAL = '" + xFilial("Z75") + "' "
		UP003 += "    AND Z75_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		UP003 += "    AND SUBSTRING(Z75_PRODUT,1,2) IN('B9','BO','C6') "
		UP003 += "    AND Z75_TIPO2 <> 'I' "
		UP003 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Backupeando... ",,{|| TcSQLExec(UP003)})

		_dDtAte	:=	MV_PAR02

		For wd := 1 to 3

			If wd == 3 
				If DtoS(MV_PAR01) > '20191021'  
					loop
				Else
					_dDtAte	:=	Stod('20191020')
				EndIf
			EndIf

			gfEqp := Alltrim( Str ( wd + 1 ) ) + Space(5) 

			UP004 := " INSERT INTO " + RetSqlName("Z75") + " "
			UP004 += " ( "
			UP004 += "  Z75_FILIAL, "
			UP004 += "  Z75_TPMOV, "
			UP004 += "  Z75_DATARF, "
			UP004 += "  Z75_PRODUT, "
			UP004 += "  Z75_TPPROD, "
			UP004 += "  Z75_TURNO, "
			UP004 += "  Z75_EQUIPE, "
			UP004 += "  Z75_LINHA, "
			UP004 += "  Z75_QUANT, "
			UP004 += "  Z75_METARF, "
			UP004 += "  Z75_DELTA, "
			UP004 += "  Z75_HRDELT, "
			UP004 += "  Z75_TIPO2, "
			UP004 += "  Z75_AJUSTE, "
			UP004 += "  D_E_L_E_T_, "
			UP004 += "  R_E_C_N_O_, "
			UP004 += "  Z75_DELTAM, "
			UP004 += "  Z75_SALDPS, "
			UP004 += "  Z75_ESCALA, "
			UP004 += "  Z75_QUALIT, "
			UP004 += "  Z75_QTD_A, "
			UP004 += "  Z75_QTMETA, "
			UP004 += "  Z75_BKQTD, "
			UP004 += "  Z75_BKQT_A, "
			UP004 += "  Z75_BKQTMT, "
			UP004 += "  Z75_BKMTQL, "
			UP004 += "  Z75_BKEQUI "
			UP004 += " ) "
			UP004 += " SELECT Z75_FILIAL, "
			UP004 += "        Z75_TPMOV, "
			UP004 += "        Z75_DATARF, "
			UP004 += "        Z75_PRODUT, "
			UP004 += "        Z75_TPPROD, "
			UP004 += "        Z75_TURNO, "
			UP004 += "        '" + gfEqp + "' Z75_EQUIPE, "
			UP004 += "        Z75_LINHA, "
			UP004 += "        Z75_QUANT, "
			UP004 += "        Z75_METARF, "
			UP004 += "        Z75_DELTA, "
			UP004 += "        Z75_HRDELT, "
			UP004 += "        Z75_TIPO2, "
			UP004 += "        Z75_AJUSTE, "
			UP004 += "        D_E_L_E_T_, "
			UP004 += "        (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("Z75") + " ) + ROW_NUMBER() OVER(ORDER BY Z75.R_E_C_N_O_) AS R_E_C_N_O_, "
			UP004 += "        Z75_DELTAM, "
			UP004 += "        Z75_SALDPS, "
			UP004 += "        Z75_ESCALA, "
			UP004 += "        Z75_QUALIT, "
			UP004 += "        Z75_QTD_A, "
			UP004 += "        Z75_QTMETA, "
			UP004 += "        Z75_BKQTD, "
			UP004 += "        Z75_BKQT_A, "
			UP004 += "        Z75_BKQTMT, "
			UP004 += "        Z75_BKMTQL, "
			UP004 += "        Z75_BKEQUI "
			UP004 += "   FROM " + RetSqlName("Z75") + " Z75 "
			UP004 += "  WHERE Z75_FILIAL = '" + xFilial("Z75") + "' "
			UP004 += "    AND Z75_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(_dDtAte) + "' "
			UP004 += "    AND SUBSTRING(Z75_PRODUT, 1, 2) IN('B9', 'BO', 'C6') "
			UP004 += "    AND Z75_EQUIPE = '1' "
			UP004 += "    AND Z75_TIPO2 <> 'I' "
			UP004 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Desdobrando... ",,{|| TcSQLExec(UP004)})

		Next wd

		UP005 := " UPDATE " + RetSqlName("Z75") + " SET "
		UP005 += "        Z75_QUANT = Z75_BKQTD / CASE WHEN Z75_DATARF < '20191021' THEN 4 ELSE 3 END, "
		UP005 += "        Z75_QTD_A = Z75_BKQT_A / CASE WHEN Z75_DATARF < '20191021' THEN 4 ELSE 3 END, "
		UP005 += "        Z75_QTMETA = Z75_BKQTMT / CASE WHEN Z75_DATARF < '20191021' THEN 4 ELSE 3 END, "
		UP005 += "        Z75_QUALIT = Z75_BKMTQL / CASE WHEN Z75_DATARF < '20191021' THEN 4 ELSE 3 END "
		UP005 += "   FROM " + RetSqlName("Z75") + " "
		UP005 += "  WHERE Z75_FILIAL = '" + xFilial("Z75") + "' "
		UP005 += "    AND Z75_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		UP005 += "    AND SUBSTRING(Z75_PRODUT,1,2) IN('B9','BO','C6') "
		UP005 += "    AND Z75_TIPO2 <> 'I' "
		UP005 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Reteando... ",,{|| TcSQLExec(UP005)})

		UP006 := " UPDATE " + RetSqlName("Z75") + " SET "
		UP006 += "        Z75_MATRIC = CASE "
		UP006 += "                       WHEN SUBSTRING(Z75_PRODUT,1,2) NOT IN('C6','B9','BO') THEN " 
		UP006 += "                                                                                  ISNULL((SELECT Z72_MATRIC "
		UP006 += "                                                                                            FROM " + RetSqlName("Z72") + " "
		UP006 += "                                                                                           WHERE Z72_LINHA = Z75_LINHA "
		UP006 += "                                                                                             AND Z72_EQUIPE = Z75_EQUIPE "
		UP006 += "                                                                                             AND Z75_DATARF >= Z72_DATADE "
		UP006 += "                                                                                             AND Z75_DATARF <= Z72_DATAAT "
		UP006 += "                                                                                             AND D_E_L_E_T_ = ' '), '') "
		UP006 += "                       ELSE "
		UP006 += "                                                                                  ISNULL((SELECT Z72_MATRIC "
		UP006 += "                                                                                            FROM " + RetSqlName("Z72") + " "
		UP006 += "                                                                                           WHERE Z72_LINHA = 'L02' "
		UP006 += "                                                                                             AND Z72_EQUIPE = Z75_EQUIPE "
		UP006 += "                                                                                             AND Z75_DATARF >= Z72_DATADE "
		UP006 += "                                                                                             AND Z75_DATARF <= Z72_DATAAT "
		UP006 += "                                                                                             AND D_E_L_E_T_ = ' '), '') "
		UP006 += "                       END "
		UP006 += "   FROM " + RetSqlName("Z75") + " "
		UP006 += "  WHERE Z75_FILIAL = '" + xFilial("Z75") + "' "
		UP006 += "    AND Z75_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
		UP006 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Atribuindo Lider... ",,{|| TcSQLExec(UP006)})

		U_BIAFG090(MV_PAR01,MV_PAR02)

		fCalcPOL()

		fCalcNLD()

		U_BIAFG026(Substr(Dtos(MV_PAR02),1,6))

	Else

		MsgINFO("Devido problema com a Meta de qualidade, não será processado o Saldo de PS por ser um processo mais custoso. Corriga o problema antes de prosseguir!!!")

	EndIf
    U_EXEJBSQL("HERMES", "DW - Industrial - Indicadores - Delta d-5", "Sincronizando Dados com BI")
	Aviso( 'BIA620P', 'Fim do Processamento', {'Ok'} )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA620A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera as informações de Liberado e Etiquetado               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA620A()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA620"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Movimento Diário de Produção"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNO"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UNIDFAB"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESCOLHA"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPPROD"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUT"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATARF"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPMOV"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TURNO"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESCALA"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EQUIPE"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO2"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "AJUSTE"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_A"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTMETA"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "METAQL"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SUPERVISOR"           ,1,1)

	RK009 := " SELECT EMPR, "
	RK009 += "        FORNO, "
	RK009 += "        UNIDFAB, "
	RK009 += "        ESCOLHA, "
	RK009 += "        TPPROD, "
	RK009 += "        PRODUT, "
	RK009 += "        DATARF, "
	RK009 += "        TPMOV, "
	RK009 += "        TURNO, "
	RK009 += "        ESCALA, "
	RK009 += "        EQUIPE, "
	RK009 += "        LINHA, "
	RK009 += "        TIPO2, "
	RK009 += "        AJUSTE, "
	RK009 += "        QUANT, "
	RK009 += "        QTD_A, "
	RK009 += "        QTMETA, "
	RK009 += "        METAQL, "
	RK009 += "        SUPERVISOR "
	RK009 += "   FROM VW_SAP_IND_MOVPROD "
	RK009 += "  WHERE EMPR = '" + cEmpAnt + "' "
	RK009 += "    AND DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	RK009 += "  ORDER BY 1, 7, 2, 3, 4, 5, 6"
	RKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RK009),'RK09',.F.,.T.)
	dbSelectArea("RK09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { RK09->EMPR                    ,;
		RK09->FORNO                                                   ,;
		RK09->UNIDFAB                                                 ,;
		RK09->ESCOLHA                                                 ,;
		RK09->TPPROD                                                  ,;
		RK09->PRODUT                                                  ,;
		dtoc(stod(RK09->DATARF))                                      ,;
		RK09->TPMOV                                                   ,;
		RK09->TURNO                                                   ,;
		RK09->ESCALA                                                  ,;
		RK09->EQUIPE                                                  ,;
		RK09->LINHA                                                   ,;
		RK09->TIPO2                                                   ,;
		RK09->AJUSTE                                                  ,;
		RK09->QUANT                                                   ,;
		RK09->QTD_A                                                   ,;
		RK09->QTMETA                                                  ,;
		RK09->METAQL                                                  ,;
		RK09->SUPERVISOR                                              })

		dbSelectArea("RK09")
		dbSkip()

	End

	RK09->(dbCloseArea())
	Ferase(RKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RKcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "movprod - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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
¦¦¦Funçao    ¦ B620SAP  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08/12/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de Alteração                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B620SAP()

	Local aArea		:= GetArea()
	Local oProcess
	Local oProcJst

	Local _msEnter   := CHR(13) + CHR(10)
	Private oDlgLogProc
	Private oBut1LogProc
	Private oGet1LogProc
	Private cGet1LogProc := ""
	Private oSay1LogProc
	Private zProdErro := ""

	FX003 := " WITH BUSCAPRODUT AS (SELECT DISTINCT A.PRODUT, B.PRODUTO, ESCALA, TPPROD, DATARF, LINHA, QUANT "
	FX003 += "                        FROM VW_SAP_IND_MOVPROD A "
	FX003 += "                        LEFT JOIN VW_SAP_IND_PRODUTO B ON B.PRODUTO = A.PRODUT) "
	FX003 += " SELECT 'Escala: ' + ESCALA + "
	FX003 += "        ', TpProd: ' + TPPROD + "
	FX003 += "        ', DtRef: ' + DATARF + "
	FX003 += "        ', Linha: ' + LINHA + "
	FX003 += "        ', Quant: ' + rtrim(CONVERT(CHAR, QUANT)) + "
	FX003 += "        ', Prod: ' + rtrim(PRODUT) + "
	FX003 += "        ', Formato: ' + rtrim(SB1.B1_YFORMAT) + "
	FX003 += "        ', Base: ' + rtrim(SB1.B1_YBASE) + "
	FX003 += "        ', Acabam: ' + rtrim(SB1.B1_YACABAM) + "
	FX003 += "        ', Linha: ' + rtrim(SB1.B1_YLINHA) + "
	FX003 += "        ', LinSeq: ' + rtrim(SB1.B1_YLINSEQ) KEY_PRODUTO "
	FX003 += "   FROM BUSCAPRODUT "
	FX003 += "   LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = PRODUT "
	FX003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	FX003 += "  WHERE PRODUTO IS NULL "
	FXcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,FX003),'FX03',.F.,.T.)
	dbSelectArea("FX03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		zProdErro += FX03->KEY_PRODUTO + _msEnter

		dbSelectArea("FX03")
		dbSkip()

	End

	FX03->(dbCloseArea())
	Ferase(FXcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(FXcIndex+OrdBagExt())          //indice gerado

	If !Empty(zProdErro)

		cGet1LogProc := zProdErro

		DEFINE MSDIALOG oDlgLogProc TITLE "Log de Processamento" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

		@ 010, 011 SAY oSay1LogProc PROMPT "Produtos com problema de cadastro. Corrija antes de integrar os dados com o SAP:" SIZE 226, 007 OF oDlgLogProc COLORS 0, 16777215 PIXEL
		@ 021, 011 GET oGet1LogProc VAR cGet1LogProc OF oDlgLogProc MULTILINE SIZE 227, 205 COLORS 0, 16777215 HSCROLL PIXEL
		@ 232, 201 BUTTON oBut1LogProc PROMPT "Fechar" SIZE 037, 012 OF oDlgLogProc ACTION oDlgLogProc:End() PIXEL
		ACTIVATE MSDIALOG oDlgLogProc

		Return

	EndIf

	//                                                            Validando preenchimento da qualidade
	//************************************************************************************************
	msChkMetaOk := .T.
	fValidQlyt("2")

	//                                                                    Validando DELTA de carga SAP
	//************************************************************************************************
	fValidDelt("2")

	//                                                 Validando a Empresa responsável pelo Transporte
	//************************************************************************************************
	If cEmpAnt <> "01"

		Aviso("Alerta de Integração", "Este processamento somente poderá ser realizado pela Empresa Biancogres", {"Ok"} )		
		msChkMetaOk := .F.

	EndIf

	If msChkMetaOk

		oProcJst := MsNewProcess():New({|lEnd| B6SAPJst(@oProcJst) }, "Carga de Dados", "DataBase IND_FACT_JUSTIFICATIVA SAP", .T.)
		oProcJst:Activate()

		Sleep( 5000 )

		oProcess := MsNewProcess():New({|lEnd| B6SAPchk(@oProcess) }, "Carga de Dados", "DataBase IND_FACT_PRODUCAO SAP", .T.)
		oProcess:Activate()

	EndIf

	RestArea(aArea)

Return

Static Function B6SAPchk(oProcess)

	Local MS007
	Local nSrvDB := Iif( "PROD" $ Upper(AllTrim(getenvserver())) , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC "+nSrvDB+".msdb.dbo.sp_start_job N'SAP->DM_INDUSTRIAL' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(MS007)})

	mCtrFimJob := .F. 
	oProcess:SetRegua1(100000)
	oProcess:SetRegua2(100000)             
	hhTmpINI      := TIME()
	oProcess:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oProcess:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC "+nSrvDB+".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'SAP->DM_INDUSTRIAL', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

	End

Return

Static Function B6SAPJst(oProcJst)

	Local MS007
	Local nSrvDB := Iif( "PROD" $ Upper(AllTrim(getenvserver())) , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC "+nSrvDB+".msdb.dbo.sp_start_job N'SAP->DM_GERAL_JUSTIFICATIVA' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(MS007)})

	mCtrFimJob := .F. 
	oProcJst:SetRegua1(1000)
	oProcJst:SetRegua2(1000)             
	hhTmpINI      := TIME()
	oProcJst:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oProcJst:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC "+nSrvDB+".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'SAP->DM_GERAL_JUSTIFICATIVA', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B620Fhm  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09/12/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B620Fhm()

	MsgINFO("Em construção....")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA620M  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22/03/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera as informações de Liberado e Etiquetado               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA620M()

	Processa({|| RptMDet()})

Return

Static Function RptMDet()

	fPerg := "BIA620"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Metas de Movimento VS Metas de Referência"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TPMOV"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATAREF"              ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "EQUIPE"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TPPROD"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "META_MOV"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "META_REF"             ,3,2)

	IH007 := " WITH CHKMETA AS (SELECT Z75_TPMOV TPMOV, " 
	IH007 += "                         Z75_DATARF DATAREF, "
	IH007 += "                         Z75_EQUIPE EQUIPE, "
	IH007 += "                         Z75_LINHA LINHA, "
	IH007 += "                         SUBSTRING(Z75_PRODUT,1,2) FORMATO, "
	IH007 += "                         Z75_TPPROD TPPROD, "
	IH007 += "                         ROUND(SUM(Z75_QTMETA),2) META_MOV, "
	IH007 += "                         ISNULL((SELECT SUM(XX74.Z74_METAQT) "
	IH007 += "                                   FROM " + RetSqlName("Z74") + " XX74 "
	IH007 += "                                  WHERE XX74.Z74_FILIAL = '" + xFilial("Z74") + "' "
	IH007 += "                                    AND XX74.Z74_DATA = Z75.Z75_DATARF "
	IH007 += "                                    AND XX74.Z74_TURNO = Z75.Z75_ESCALA "
	IH007 += "                                    AND XX74.Z74_LINHA = Z75.Z75_LINHA "
	IH007 += "                                    AND XX74.Z74_FORMAT = SUBSTRING(Z75.Z75_PRODUT,1,2) "
	IH007 += "                                    AND XX74.D_E_L_E_T_ = ' '),0) META_REF "
	IH007 += "                    FROM " + RetSqlName("Z75") + " Z75 "
	IH007 += "                   WHERE Z75.Z75_FILIAL = '" + xFilial("Z75") + "' "
	IH007 += "                     AND Z75.Z75_TPMOV = 'ETQ' "
	IH007 += "                     AND Z75.Z75_AJUSTE <> 'S' "
	IH007 += "                     AND Z75.Z75_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	IH007 += "                     AND Z75.D_E_L_E_T_ = ' ' "
	IH007 += "                    GROUP BY Z75_TPMOV, "
	IH007 += "                             Z75_DATARF, "
	IH007 += "                             Z75_EQUIPE, "
	IH007 += "                             Z75_LINHA, "
	IH007 += "                             SUBSTRING(Z75_PRODUT,1,2), "
	IH007 += "                             Z75_TPPROD, "
	IH007 += "                             Z75_ESCALA) "
	IH007 += " SELECT * "
	IH007 += "   FROM CHKMETA "
	IH007 += "  WHERE META_MOV <> META_REF "
	IH007 += "    OR ( META_MOV = 0 AND META_REF = 0 ) "
	IHcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,IH007),'IH07',.F.,.T.)
	dbSelectArea("IH07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Gerando...")

		oExcel:AddRow(nxPlan, nxTabl, { IH07->TPMOV         ,;
		stod(IH07->DATAREF)                                 ,;
		IH07->EQUIPE                                        ,;
		IH07->LINHA                                         ,;
		IH07->FORMATO                                       ,;
		IH07->TPPROD                                        ,;
		IH07->META_MOV                                      ,;
		IH07->META_REF                                      })

		dbSelectArea("IH07")
		dbSkip()

	End

	IH07->(dbCloseArea())
	Ferase(IHcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(IHcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "chkmeta - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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
¦¦¦Função    ¦ fValidQlyt ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 01/02/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidQlyt(msOrig)

	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFields := {"DATAREF","PRODUTO","DESCRIC","EQUIPE","TURNO","LINHA","QUANTI"}
	Local aAlterFields := {}
	Private oMSNewGetVldQlt
	Private oDlgVldQlt
	Private oButton1
	Private oSay1Qlt
	Private trNumReg := .F.

	aAdd(aHeaderEx,{"DATAREF"         ,"DATAREF"    ,"@!"               , 08   , 0,,, "D",, })
	aAdd(aHeaderEx,{"PRODUTO"         ,"PRODUTO"    ,"@!"               , 15   , 0,,, "C",, })
	aAdd(aHeaderEx,{"DESCRIC"         ,"DESCRIC"    ,"@!"               , 50   , 0,,, "C",, })
	aAdd(aHeaderEx,{"EQUIPE"          ,"EQUIPE"     ,"@!"               , 06   , 0,,, "C",, })
	aAdd(aHeaderEx,{"TURNO"           ,"TURNO"      ,"@!"               , 01   , 0,,, "C",, })
	aAdd(aHeaderEx,{"LINHA"           ,"LINHA"      ,"@!"               , 03   , 0,,, "C",, })
	aAdd(aHeaderEx,{"QUANTI"          ,"QUANTI"     ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })

	YT002 := " SELECT Z75_DATARF DTREF, "
	YT002 += "        Z75_PRODUT PRODUTO, "
	YT002 += "        SUBSTRING(B1_DESC,1,50) DESCR, "
	YT002 += "        Z75_EQUIPE EQUIPE, "
	YT002 += "        Z75_TURNO TURNO, "
	YT002 += "        Z75_LINHA LINHA, "
	YT002 += "        Z75_QUANT QUANT "
	YT002 += "   FROM " + RetSqlName("Z75") + " Z75 "
	YT002 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	YT002 += "                       AND B1_COD = Z75_PRODUT "
	YT002 += "                       AND B1_YTPPROD <> 'RP'
	YT002 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	YT002 += "  WHERE Z75_FILIAL = '" + xFilial("Z75") + "' "
	If msOrig == "1"
		YT002 += "    AND Z75_DATARF BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	EndIf
	YT002 += "    AND Z75_TPMOV = 'ETQ' "
	YT002 += "    AND Z75_TPPROD <> 'PP' "
	YT002 += "    AND Z75_AJUSTE <> 'S' "
	YT002 += "    AND Z75_QUANT <> 0 "
	YT002 += "    AND Z75_QUALIT = 0 "
	YT002 += "    AND Z75.D_E_L_E_T_ = ' ' "
	YTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YT002),'YT02',.F.,.T.)
	dbSelectArea("YT02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		trNumReg := .T.
		msChkMetaOk := .F.

		AADD(aColsEx, Array(Len(aFields)+1) )
		aColsEx[Len(aColsEx), 1] := stod(YT02->DTREF)
		aColsEx[Len(aColsEx), 2] := YT02->PRODUTO
		aColsEx[Len(aColsEx), 3] := YT02->DESCR
		aColsEx[Len(aColsEx), 4] := YT02->EQUIPE
		aColsEx[Len(aColsEx), 5] := YT02->TURNO
		aColsEx[Len(aColsEx), 6] := YT02->LINHA
		aColsEx[Len(aColsEx), 7] := YT02->QUANT
		aColsEx[Len(aColsEx), Len(aFields)+1] := .F.

		dbSelectArea("YT02")
		dbSkip()

	End
	YT02->(dbCloseArea())
	Ferase(YTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(YTcIndex+OrdBagExt())          //indice gerado

	If trNumReg

		DEFINE MSDIALOG oDlgVldQlt TITLE "Validando Preenchimento da Qualidade" FROM 000, 000  TO 500, 900 COLORS 0, 16777215 PIXEL

		oMSNewGetVldQlt := MsNewGetDados():New( 006, 005, 224, 443, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgVldQlt, aHeaderEx, aColsEx)

		@ 229, 405 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlgVldQlt ACTION oDlgVldQlt:End() PIXEL
		@ 234, 007 SAY oSay1Qlt PROMPT "Os produtos acima listados não receberam meta de qualidade. Favor verificar antes de continuar..." SIZE 392, 007 OF oDlgVldQlt COLORS 0, 16777215 PIXEL

		ACTIVATE MSDIALOG oDlgVldQlt

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidQlyt ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 01/02/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidDelt(vqOrig)

	If vqOrig == "2"

		/* FOI NECESSÁRIO REPLICAR A INFORMAÇÃO DE 'DELTA D' E 'DELTA M' PARA A EMPRESA BIANCOGRES.
		COMO A EMPRESA '05' (INCESA) NÃO EIXSTE MAIS A ROTINA VERIFICA O DELTA DAS DUAS EMPRESAS
		PARA REALIZAR A 'CARGA SAP'. (TICKET 10381) */

		RE002 := " WITH CTRLDELTA AS (SELECT EMPR,
		RE002 += "                           MAX(DELTAD) DELTA01,
		RE002 += "                           MAX(DELTAD) DELTA05
		RE002 += "                      FROM VW_SAP_IND_MOVPROD
		RE002 += "                     WHERE EMPR = '01'
		RE002 += "                     GROUP BY EMPR
		RE002 += "                     UNION ALL
		RE002 += "                    SELECT EMPR,
		RE002 += "                           MAX(DELTAM) DELTA01,
		RE002 += "                           MAX(DELTAM) DELTA05
		RE002 += "                      FROM VW_SAP_IND_MOVPROD
		RE002 += "                     WHERE EMPR = '01'
		RE002 += "                     GROUP BY EMPR
		/*
		RE002 += "                    UNION ALL
		RE002 += "                    SELECT EMPR,
		RE002 += "                           '' DELTA01,
		RE002 += "                           MAX(DELTAD) DELTA05
		RE002 += "                      FROM VW_SAP_IND_MOVPROD
		RE002 += "                     WHERE EMPR = '05'
		RE002 += "                     GROUP BY EMPR
		RE002 += "                     UNION ALL
		RE002 += "                    SELECT EMPR,
		RE002 += "                           '' DELTA01,
		RE002 += "                           MAX(DELTAM) DELTA05
		RE002 += "                      FROM VW_SAP_IND_MOVPROD
		RE002 += "                     WHERE EMPR = '05'
		RE002 += "                     GROUP BY EMPR
		*/
		RE002 += "                     )
		RE002 += " SELECT COUNT(*) CONTAD
		RE002 += "   FROM (SELECT MAX(DELTA01) DT01, MAX(DELTA05) DT05
		RE002 += "           FROM CTRLDELTA) AS BDFGEDED
		RE002 += "  WHERE DT01 = DT05
		REcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RE002),'RE02',.F.,.T.)
		dbSelectArea("RE02")
		dbGoTop()
		If RE02->CONTAD <> 1
			Aviso("Alerta de Integração", "Favor verificar as datas de DELTA das empresas, pois estão divergentes!!!", {"Ok"} )		
			msChkMetaOk := .F.
		EndIf
		RE02->(dbCloseArea())
		Ferase(REcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(REcIndex+OrdBagExt())          //indice gerado

	EndIf

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
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

Static Function fCalcPol()

	Local TD008
	Local _cAlias
	Local _cDataDe	:=	Dtos(MV_PAR01)//Iif(Dtos(MV_PAR01) >= '20170704', MV_PAR01,'20170704')
	Local _cDataAte	:=	Dtos(MV_PAR02)
	Local _cData	:=	_cDataDe
	Local _cSaldo	:=	0

	While _cData <= _cDataAte

		TD008 := " WITH METAUTIPS AS (SELECT 'Biancogres' EMPR,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
		TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
		TD008 += "                           END ENTRADA,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		TD008 += "                             ELSE (Z74_METAQT * 0)
		TD008 += "                           END SAIDA,
		TD008 += "                           0 SALDO,
		TD008 += "                           *
		TD008 += "                      FROM Z74010 Z74
		TD008 += "                     WHERE Z74_FILIAL = '01'
		TD008 += "                       AND Z74_DATA BETWEEN '" + _cData + "' AND '" + _cData + "'
		TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		TD008 += "                       AND Z74.D_E_L_E_T_ = ' '
		TD008 += "                     UNION ALL
		TD008 += "                    SELECT 'Vitcer' EMPR,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
		TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
		TD008 += "                           END ENTRADA,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		TD008 += "                             ELSE (Z74_METAQT * 0)
		TD008 += "                           END SAIDA,
		TD008 += "                           0 SALDO,
		TD008 += "                           *
		TD008 += "                      FROM Z74140 Z74
		TD008 += "                     WHERE Z74_FILIAL = '01'
		TD008 += "                       AND Z74_DATA BETWEEN '" + _cData + "' AND '" + _cData + "'
		TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		TD008 += "                       AND Z74.D_E_L_E_T_ = ' ')
		TD008 += " ,    METSALIPS AS (SELECT 'Biancogres' EMPR,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
		TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
		TD008 += "                           END ENTRADA,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		TD008 += "                             ELSE (Z74_METAQT * 0)
		TD008 += "                           END SAIDA,
		TD008 += "                           *
		TD008 += "                      FROM Z74010 Z74
		TD008 += "                     WHERE Z74_FILIAL = '01'
		TD008 += "                       AND Z74_DATA < '" + _cData + "'
		TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		TD008 += "                       AND Z74.D_E_L_E_T_ = ' '
		TD008 += "                     UNION ALL
		TD008 += "                    SELECT 'Vitcer' EMPR,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * 0
		TD008 += "                             ELSE ROUND((Z74_METAQT * 0.9770114942528736),2)
		TD008 += "                           END ENTRADA,
		TD008 += "                           CASE
		TD008 += "                             WHEN Z74_FORMAT IN('B9', 'BO', 'C6') THEN Z74_METAQT * (-1)
		TD008 += "                             ELSE (Z74_METAQT * 0)
		TD008 += "                           END SAIDA,
		TD008 += "                           *
		TD008 += "                      FROM Z74140 Z74
		TD008 += "                     WHERE Z74_FILIAL = '01'
		TD008 += "                       AND Z74_DATA < '" + _cData + "'
		TD008 += "                       AND Z74_FORMAT IN('C1', 'B9', 'BO', 'C6')
		TD008 += "                       AND Z74.D_E_L_E_T_ = ' ')
		TD008 += " SELECT *
		TD008 += "   FROM (SELECT EMPR,
		TD008 += "                Z74_DATA,
		TD008 += "                Z74_FORMAT,
		TD008 += "                Z74_LINHA,
		TD008 += "                SUM(ENTRADA) ENTRADA,
		TD008 += "                SUM(SAIDA) SAIDA,
		TD008 += "         	  SUM(SALDO) SALDO
		TD008 += "           FROM METAUTIPS PPM
		TD008 += "         GROUP BY EMPR,
		TD008 += "                  Z74_DATA,
		TD008 += "                  Z74_FORMAT,
		TD008 += "                  Z74_LINHA
		TD008 += "          UNION ALL
		TD008 += "         SELECT EMPR,
		TD008 += "                MAX(Z74_DATA)  DATARF,
		TD008 += "                Z74_FORMAT,
		TD008 += "                Z74_LINHA,
		TD008 += "                0 ENTRADA,
		TD008 += "                0 SAIDA,
		TD008 += "                SUM(ENTRADA)+SUM(SAIDA) SALDO
		TD008 += "           FROM METSALIPS PPM
		TD008 += "         GROUP BY EMPR,
		TD008 += "                  Z74_FORMAT,
		TD008 += "                  Z74_LINHA) AS TAB
		TD008 += "   ORDER BY EMPR, Z74_DATA
		TDcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TD008),'TD08',.F.,.T.)
		dbSelectArea("TD08")
		TD08->(dbGoTop())

		_cSaldo	:=	0
		If TD08->(!EOF())
			While TD08->(!EOF())
				_cSaldo += TD08->SALDO + TD08->ENTRADA + TD08->SAIDA
				TD08->(DbSkip())
			EndDo

			_cAlias	:=	GetNextAlias()

			BeginSql Alias _cAlias
				SELECT MIN(B1_COD) COD
				FROM %TABLE:SB1% 
				WHERE B1_FILIAL = %XFILIAL:SB1%
				AND B1_TIPO = 'PA' 
				AND B1_YFORMAT = 'C1'
				AND B1_MSBLQL <> '1'
				AND B1_YFORMAT <> ''
				AND B1_YBASE <> ''
				AND B1_YACABAM <> ''
				AND B1_YLINHA <> ''
				AND B1_YLINSEQ <> ''
				AND %NotDel%
			EndSql

			If (_cAlias)->(!EOF())

				Reclock("Z75",.T.)
				Z75->Z75_FILIAL := xFilial("Z75")
				Z75->Z75_TPMOV  := "PLM"
				Z75->Z75_DATARF := stod(_cData)
				Z75->Z75_TPPROD := "PS"
				Z75->Z75_LINHA  := "L02"
				Z75->Z75_TIPO2  := "C"
				Z75->Z75_AJUSTE := "N"				
				Z75->Z75_PRODUT := (_cAlias)->COD
				Z75->Z75_DELTA  := date()
				Z75->Z75_HRDELT := time()
				Z75->Z75_QUANT	:= _cSaldo
				Z75->(MsUnlock())

			EndIf
		EndIf
		(_cAlias)->(DbCloseArea())
		TD08->(dbCloseArea())
		Ferase(TDcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TDcIndex+OrdBagExt())          //indice gerado

		_cData := DtoS(DaySum(Stod(_cData),1))

	ENDDO

Return


Static Function fCalcNLD()

	Local _cSql	:=	""
	Local _cAlias	:=	GetNExtAlias()

	_cSql :=	"	SELECT  C1 ,	"
	_cSql +=	"	        SUM(QTD) QUANT	"
	_cSql +=	"	FROM    ( SELECT    PRODUT ,	"
	_cSql +=	"	                    CASE WHEN PRODUT COLLATE DATABASE_DEFAULT LIKE 'C1%'	"
	_cSql +=	"	                         THEN PRODUT COLLATE DATABASE_DEFAULT	"
	_cSql +=	"	                         ELSE ( SELECT TOP 1	"
	_cSql +=	"	                                        SG1.G1_COMP	"
	_cSql +=	"	                                FROM    "+RetSqlName("SG1")+" SG1	"
	_cSql +=	"	                                WHERE   SG1.G1_COD COLLATE DATABASE_DEFAULT = PARC.PRODUT COLLATE DATABASE_DEFAULT	"
	_cSql +=	"	                                        AND "+ValtoSql(MV_PAR02)+" BETWEEN G1_INI AND G1_FIM	"
	_cSql +=	"	                                        AND SG1.D_E_L_E_T_ = ''	"
	_cSql +=	"	                                        AND SUBSTRING(SG1.G1_COMP, 1, 2) = 'C1'	"
	_cSql +=	"	                              )	"
	_cSql +=	"	                    END C1 ,	"
	_cSql +=	"	                    CASE WHEN TRANSAC = 64	"
	_cSql +=	"	                         THEN -1	"
	_cSql +=	"	                              * CASE WHEN SUBSTRING(PRODUT, 1, 2) = 'C1'	"
	_cSql +=	"	                                     THEN PARC.QUANT	"
	_cSql +=	"	                                     ELSE -1 * PARC.QUANT	"
	_cSql +=	"	                                END	"
	_cSql +=	"	                         ELSE CASE WHEN SUBSTRING(PRODUT, 1, 2) = 'C1'	"
	_cSql +=	"	                                   THEN PARC.QUANT	"
	_cSql +=	"	                                   ELSE -1 * PARC.QUANT	"
	_cSql +=	"	                              END	"
	_cSql +=	"	                    END QTD	"
	_cSql +=	"	          FROM      ( SELECT    A.cod_transacao TRANSAC ,	"
	_cSql +=	"	                                A.cod_produto PRODUT ,	"
	_cSql +=	"	                                A.ce_qtdade QUANT	"
	_cSql +=	"	                      FROM      "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A	"
	_cSql +=	"	                                JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA	"
	_cSql +=	"	                                                              AND B.cod_etiqueta = A.ce_numero_docto	"
	_cSql +=	"	                      WHERE     A.id_cia = 1	"
	_cSql +=	"	                                AND ( ( A.cod_transacao IN('1','20') AND A.CE_DOCTO <> 'SA' )	"
	_cSql +=	"	                                      OR ( A.cod_transacao = 64	"
	_cSql +=	"	                                           AND A.ce_docto = 'CP'	"
	_cSql +=	"	                                         )	"
	_cSql +=	"	                                    )	"
	_cSql +=	"	                                AND SUBSTRING(A.cod_produto, 1, 2) IN ( 'C1',	"
	_cSql +=	"	                                                              'B9', 'B0', 'C6' )	"
	_cSql +=	"	                                AND B.etiq_transito_producao = 0	"
	_cSql +=	"	                                AND A.ce_lote <> ' '	"
	_cSql +=	"	                                AND B.cod_endereco NOT IN ( 'RETIDO' )	"
	_cSql +=	"	                                AND CONVERT(SMALLDATETIME, A.ce_data_movimento, 120) >= CONVERT(SMALLDATETIME, CONVERT(VARCHAR(10), GETDATE()	"
	_cSql +=	"	                                - 30, 112) + ' 06:00', 120)	"
	_cSql +=	"	                                AND CONVERT(SMALLDATETIME, A.ce_data_movimento, 120) >= CONVERT(SMALLDATETIME, '20150101 06:00', 120)	"
	_cSql +=	"	                                AND id_mov_prod NOT IN (	"
	_cSql +=	"	                                SELECT  D3_YIDECO	"
	_cSql +=	"	                                FROM    "+RetSqlName("SD3")+"  SD3 WITH ( NOLOCK )	"
	_cSql +=	"	                                WHERE   SD3.D3_FILIAL = '"+xFilial("SD3")+"'	"
	_cSql +=	"	                                        AND SD3.D3_YIDECO <> ' '	"
	_cSql +=	"	                                        AND SD3.D3_YORIMOV = 'PR0'	"
	_cSql +=	"	                                        AND SD3.D3_ESTORNO = ' '	"
	_cSql +=	"	                                        AND SD3.D_E_L_E_T_ = ' '	"
	_cSql +=	"	                                UNION ALL	"
	_cSql +=	"	                                SELECT  Z18_IDECO	"
	_cSql +=	"	                                FROM    "+RetSqlName("Z18")+" Z18 WITH ( NOLOCK )	"
	_cSql +=	"	                                WHERE   Z18.Z18_FILIAL = '"+xFilial("Z18")+"'	"
	_cSql +=	"	                                        AND Z18.D_E_L_E_T_ = ' ' )	"
	_cSql +=	"	                                AND A.ce_qtdade > 0	"
	_cSql +=	"	                    ) PARC	"
	_cSql +=	"	        ) FINAL	"
	_cSql +=	"	GROUP BY C1	"


	TDcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),_cAlias,.F.,.T.)
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())

	While (_cAlias)->(!EOF())
		Reclock("Z75",.T.)
		Z75->Z75_FILIAL := xFilial("Z75")
		Z75->Z75_TPMOV  := "NLD"
		Z75->Z75_DATARF := MV_PAR02
		Z75->Z75_TPPROD := "PS"
		Z75->Z75_LINHA  := "L02"
		Z75->Z75_TIPO2  := "C"
		Z75->Z75_AJUSTE := "N"				
		Z75->Z75_PRODUT := (_cAlias)->C1
		Z75->Z75_DELTA  := date()
		Z75->Z75_HRDELT := time()
		Z75->Z75_QUANT	:= (_cAlias)->QUANT
		Z75->(MsUnlock())

		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())
	Ferase(TDcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TDcIndex+OrdBagExt())          //indice gerado

Return


User Function URECACO()

	RpcSetType(3)
	RpcSetEnv('01','01')

	MV_PAR01	:=	Stod("20190401")
	MV_PAR02	:=	Stod("20190428")


	fRecCaco()

	RpcClearEnv()

Return
