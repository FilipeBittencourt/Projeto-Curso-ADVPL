#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"
#include "Ap5Mail.ch"
#include "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA254
@author Marcos Alberto Soprani
@since 14/07/11
@version 1.1
@description Monta Menu para Programas do Controle Banestik / Ticket
.            Este fonte substituiu oL fonte BIA980 DE 18/01/07
.            Em 02/10/12 o COMPROCARD mudou para Ticket conforme Effettivo
.            2253-12.
@type function
/*/

User Function BIA254()

	fPerg := "BIA254"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	cCadastro := "Benefícios"
	aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
	{               "Visualizar"    ,"AxVisual"	  ,0,2},;
	{               "Incluir"       ,"AxInclui"	  ,0,3},;
	{               "Alterar"       ,"AxAltera"	  ,0,4},;
	{               "Excluir"       ,"AxDeleta"	  ,0,5},;
	{               "Importar"      ,"U_BIA254A"  ,0,6},;
	{               "Relatórios"    ,"U_BIA254B"  ,0,7},;
	{               "Gerar Arq."    ,"U_BIA254C"  ,0,8} }

	dbSelectArea("SZS")
	dbSetOrder(1)
	dbGoTop()

	Set filter to SZS->ZS_MESANO == MV_PAR01

	SZS->(mBrowse(06,01,22,75,"SZS"))

	dbSelectArea("SZS")
	dbClearFilter()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA254A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 14.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA254A()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local oButton1
	Local oRadMenu1
	Local nRadMenu1 := 0
	Private oDlg01

	DEFINE MSDIALOG oDlg01 TITLE "Importação de Benefícios" FROM 000, 000  TO 130, 360 COLORS 0, 16777215 PIXEL

	@ 003, 014 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "1 - Visa Vale", "2 - Comprocard 1", "3 - Comprocard 2", "4 - Combustível", "5 - Ticket", "6 - Alimentação" SIZE 108, 032 OF oDlg01 COLOR 0, 16777215 PIXEL
	@ 008, 131 BUTTON oButton1 PROMPT "Gerar" SIZE 037, 035 OF oDlg01  ACTION Close(oDlg01) PIXEL

	ACTIVATE MSDIALOG oDlg01 CENTERED

	//2014.03.31 - Julio, ajuste para verificaçao do Beneficio Ticket VITCER
	If nRadMenu1 == 5
		nRadTicket := 1
	Else
		nRadTicket := 0
	EndIf

	//2019.04.17 - Marcelo - Função para gerar lançamento de Alimentacao para funcionários a partir dos dados inseridos
	If nRadMenu1 == 6
		GERALIM(nRadMenu1)
		Return
	EndIf

	// Controle para verificação de reprocessamento
	QY004 := " SELECT COUNT(*) CONTAD
	QY004 += "   FROM " + RetSqlName("SZS")
	QY004 += "  WHERE ZS_FILIAL = '" + xFilial("SZS") + "'
	QY004 += "    AND ZS_MESANO = '" + MV_PAR01 + "'
	QY004 += "    AND ZS_MAT = '     '
	QY004 += "    AND ZS_BENEF = '" + StrZero(nRadMenu1+nRadTicket,1) + "'
	QY004 += "    AND ZS_PAGAR = 'P'
	QY004 += "    AND D_E_L_E_T_ = ' '
	QYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QY004),'QY04',.T.,.T.)
	dbSelectArea("QY04")
	dbGoTop()
	If QY04->CONTAD > 0

		If !MsgYESNO("Já existe um processamento para o período/benefício informado. Deseja reprocessar?")

			QY04->(dbCloseArea())
			Ferase(QYIndex+GetDBExtension())
			Ferase(QYIndex+OrdBagExt())
			Return

		Else

			QX005 := " SELECT ZS_MAT, R_E_C_N_O_ REGSZS
			QX005 += "   FROM " + RetSqlName("SZS")
			QX005 += "  WHERE ZS_FILIAL = '" + xFilial("SZS") + "'
			QX005 += "    AND ZS_MESANO = '" + MV_PAR01 + "'
			QX005 += "    AND ZS_MAT <> '     '
			QX005 += "    AND ZS_BENEF = '" + StrZero(nRadMenu1+nRadTicket,1) + "'
			QX005 += "    AND D_E_L_E_T_ = ' '
			QXIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,QX005),'QX05',.T.,.T.)
			dbSelectArea("QX05")
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				IncProc("Zerando Processamento. Matr: " + QX05->ZS_MAT)

				dbSelectArea("SZS")
				dbGoTo(QX05->REGSZS)
				RecLock("SZS", .F.)
				dbDelete()
				MsUnLock()

				dbSelectArea("QX05")
				dbSkip()

			End
			QX05->(dbCloseArea())
			Ferase(QXIndex+GetDBExtension())
			Ferase(QXIndex+OrdBagExt())

			Q0006 := " UPDATE " + RetSqlName("SZS") + " SET ZS_PAGAR = ' '
			Q0006 += "  WHERE ZS_FILIAL = '" + xFilial("SZS") + "'
			Q0006 += "    AND ZS_MESANO = '" + MV_PAR01 + "'
			Q0006 += "    AND ZS_MAT = '     '
			Q0006 += "    AND ZS_BENEF = '" + StrZero(nRadMenu1+nRadTicket,1) + "'
			Q0006 += "    AND ZS_PAGAR = 'P'
			Q0006 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(Q0006)

		EndIf

	EndIf
	QY04->(dbCloseArea())
	Ferase(QYIndex+GetDBExtension())
	Ferase(QYIndex+OrdBagExt())

	// Processamento
	xl_Valor  := 0
	xl_TxBase := 0
	A0001 := " SELECT ZS_VALOR, ZS_TXBASE, ZS_DTPAG
	A0001 += "   FROM " + RetSqlName("SZS")
	A0001 += "  WHERE ZS_FILIAL = '" + xFilial("SZS") + "'
	A0001 += "    AND ZS_MESANO = '" + MV_PAR01 + "'
	IF nRadMenu1 <> 6
		A0001 += "    AND ZS_MAT = '     '
	ENDIF
	A0001 += "    AND ZS_BENEF = '" + StrZero(nRadMenu1+nRadTicket,1) + "'
	A0001 += "    AND ZS_PAGAR = ' '
	A0001 += "    AND D_E_L_E_T_ = ' '
	TcQuery A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	If A001->ZS_VALOR > 0
		xl_Valor  := A001->ZS_VALOR
		xl_TxBase := A001->ZS_TXBASE
		xl_DatPag := stod(A001->ZS_DTPAG)
		A001->(dbCloseArea())
	Else
		MsgInfo("Ainda não foi informado o VALOR do Benefício para o período selecionado. Favor Verificar!!!")
		A001->(dbCloseArea())
		Return
	EndIf

	If nRadMenu1 == 1

		IF SUBSTR(MV_PAR01,5,2) <> '13'
			// Alteração efetuada em 02/12/11 por Marcos Alberto
			xx_DtIni  := ""
			xx_DtFin  := ""
			A0009 := " SELECT PO_DATAINI, PO_DATAFIM
			A0009 += "   FROM "+RetSqlName("SPO")
			A0009 += "  WHERE PO_FILIAL = '"+xFilial("SPO")+"'
			A0009 += "    AND SUBSTRING(PO_DATAFIM,1,6) = '"+MV_PAR01+"'
			A0009 += "    AND D_E_L_E_T_ = ' '
			TcQuery A0009 New Alias "A009"
			dbSelectArea("A009")
			dbGoTop()
			If !Empty(A009->PO_DATAINI)
				xx_DtIni  := IIf(A009->PO_DATAINI == "20190911", "20190921", A009->PO_DATAINI)
				xx_DtFin  := A009->PO_DATAFIM
			Else
				MsgINFO("O período do ponto ainda não foi fechado!!!")
				Return
			EndIf

			A009->(dbCloseArea())
		ENDIF

		A0002 := " SELECT SRA.RA_MAT,
		A0002 += "        SRA.RA_NOME,
		A0002 += "        CASE
		A0002 += "          WHEN SUBSTRING(RA_ADMISSA,1,6) = '"+MV_PAR01+"' THEN 'S'
		A0002 += "          ELSE 'N'
		A0002 += "        END ADM_MES,
		A0002 += "        CASE
		A0002 += "          WHEN SUBSTRING(RA_DEMISSA,1,6) = '"+MV_PAR01+"' THEN 'S'
		A0002 += "          ELSE 'N'
		A0002 += "        END DEM_MES,
		A0002 += "        CASE
		A0002 += "          WHEN SUBSTRING(RA_ADMISSA,1,6) = SUBSTRING(RA_DEMISSA,1,6) THEN 'S'
		A0002 += "          ELSE 'N'
		A0002 += "        END ADM_DEM,
		A0002 += "        ISNULL((SELECT SUBSTRING(XRA.RA_ADMISSA,7,2)
		A0002 += "                  FROM "+RetSqlName("SRA")+" XRA
		A0002 += "                 WHERE XRA.RA_FILIAL = '"+xFilial("SRA")+"'
		A0002 += "                   AND XRA.RA_MAT = SRA.RA_MAT
		A0002 += " 	              AND SUBSTRING(XRA.RA_ADMISSA,1,6) >= '"+MV_PAR01+"'
		A0002 += " 	              AND SUBSTRING(XRA.RA_ADMISSA,1,6) <= '"+MV_PAR01+"'
		A0002 += "                   AND XRA.D_E_L_E_T_ = ' '), '00') ADM_DIAS,
		A0002 += "        ISNULL((SELECT SUBSTRING(XRA.RA_DEMISSA,7,2)
		A0002 += "                  FROM "+RetSqlName("SRA")+" XRA
		A0002 += "                 WHERE XRA.RA_FILIAL = '"+xFilial("SRA")+"'
		A0002 += "                   AND XRA.RA_MAT = SRA.RA_MAT
		A0002 += " 	              AND SUBSTRING(XRA.RA_DEMISSA,1,6) >= '"+MV_PAR01+"'
		A0002 += " 	              AND SUBSTRING(XRA.RA_DEMISSA,1,6) <= '"+MV_PAR01+"'
		A0002 += "                   AND XRA.D_E_L_E_T_ = ' '), '00') DEM_DIAS,
		A0002 += "        (SELECT COUNT(*)
		A0002 += "           FROM " + RetSqlName("SR8")
		A0002 += "          WHERE R8_FILIAL = '"+xFilial("SR8")+"'
		A0002 += "            AND R8_MAT = SRA.RA_MAT
		A0002 += "            AND SUBSTRING(R8_DATAINI,1,6) >= '"+MV_PAR01+"'
		A0002 += "            AND (SUBSTRING(R8_DATAFIM,1,6) <= '"+MV_PAR01+"' OR R8_DATAFIM = '        ')
		A0002 += "            AND R8_TIPO <> 'F'
		A0002 += "            AND R8_TIPOAFA <> '001'
		A0002 += "            AND D_E_L_E_T_ = ' ') AFASTAM,
		A0002 += "        ISNULL((SELECT CASE
		//2014.03.25 - Julio - Verifica fim de afastamento
		A0002 += "                         WHEN (SUBSTRING(R8_DATAFIM,1,6) >= '"+MV_PAR01+"' OR SR8.R8_DATAFIM = '        ')  AND SR8.R8_YMOTAFA <> '      ' THEN 'AFAT_ABONAD'
		A0002 += "                         WHEN (SUBSTRING(R8_DATAFIM,1,6) >= '"+MV_PAR01+"' OR SR8.R8_DATAFIM = '        ')  AND SR8.R8_YMOTAFA = '      ' THEN 'AFAT_INDET'
		A0002 += "                         ELSE 'ATIVO'
		A0002 += "                       END
		A0002 += "                  FROM "+RetSqlName("SR8")+" SR8
		A0002 += "                 WHERE SR8.R8_FILIAL = '"+xFilial("SR8")+"'
		A0002 += "                   AND SR8.R8_MAT = SRA.RA_MAT
		A0002 += "                   AND SR8.R8_DATAINI IN(SELECT MAX(XR8.R8_DATAINI)
		A0002 += "                                           FROM "+RetSqlName("SR8")+" XR8
		A0002 += "                                          WHERE XR8.R8_FILIAL = '"+xFilial("SR8")+"'
		A0002 += "                                            AND XR8.R8_MAT = SR8.R8_MAT
		A0002 += "                                            AND SUBSTRING(XR8.R8_DATAINI,1,6) < '"+MV_PAR01+"'
		A0002 += "                                            AND XR8.R8_TIPO <> 'F'
		A0002 += "                                            AND XR8.R8_TIPOAFA <> '001'
		A0002 += "                                            AND XR8.D_E_L_E_T_ = ' ')

		// Alteraçao para tratamento diferenciado para o TICKET de 13
		IF SUBSTR(MV_PAR01,5,2) <> '13'

			A0002 += "                   AND SR8.D_E_L_E_T_ = ' '), 'ATIVO') STA, 0 AS FALTAS
			//Alterado Conforme Ticket 5698 solicitado por Gustavo para que nunca sejam consideradas as faltas para desconto de Alelo
			/*			
			A0002 += "       ((SELECT COUNT(*)
			A0002 += "           FROM "+RetSqlName("SPH")+" SPH
			A0002 += "          INNER JOIN SP9010 SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'
			A0002 += "                               AND P9_CODIGO = PH_PD
			A0002 += "                               AND P9_CLASEV = '02'
			A0002 += "                               AND P9_BHORAS = 'N'
			A0002 += "                               AND SP9.D_E_L_E_T_ = ' '
			A0002 += "          WHERE PH_FILIAL = '"+xFilial("SPH")+"'
			A0002 += "            AND PH_MAT = SRA.RA_MAT
			A0002 += "            AND PH_DATA BETWEEN '"+xx_DtIni+"' AND '"+xx_DtFin+"'
			A0002 += "            AND PH_ABONO IN( '   ', '015' )
			A0002 += "            AND PH_PDI = '   '
			A0002 += "            AND SPH.D_E_L_E_T_ = ' ') + (SELECT COUNT(*)
			A0002 += "                                           FROM "+RetSqlName("SPC")+" SPC
			A0002 += "                                          INNER JOIN SP9010 SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'
			A0002 += "                                                               AND P9_CODIGO = PC_PD
			A0002 += "                                                               AND P9_CLASEV = '02'
			A0002 += "                                                               AND P9_BHORAS = 'N'
			A0002 += "                                                               AND SP9.D_E_L_E_T_ = ' '
			A0002 += "                                          WHERE PC_FILIAL = '"+xFilial("SPC")+"'
			A0002 += "                                            AND PC_MAT = SRA.RA_MAT
			A0002 += "                                            AND PC_DATA BETWEEN '"+xx_DtIni+"' AND '"+xx_DtFin+"'
			A0002 += "                                            AND PC_ABONO IN( '   ', '015')
			A0002 += "                                            AND PC_PDI = '   '
			A0002 += "                                            AND SPC.D_E_L_E_T_ = ' ') + (SELECT COUNT(*)
			A0002 += "                                                                           FROM "+RetSqlName("SPH")+" SPH
			A0002 += "                                                                          INNER JOIN SP9010 SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'
			A0002 += "                                                                                               AND P9_CODIGO = PH_PDI
			A0002 += "                                                                                               AND P9_CLASEV = '02'
			A0002 += "                                                                                               AND P9_BHORAS = 'N'
			A0002 += "                                                                                               AND SP9.D_E_L_E_T_ = ' '
			A0002 += "                                                                          WHERE PH_FILIAL = '"+xFilial("SPH")+"'
			A0002 += "                                                                            AND PH_MAT = SRA.RA_MAT
			A0002 += "                                                                            AND PH_DATA BETWEEN '"+xx_DtIni+"' AND '"+xx_DtFin+"'
			A0002 += "                                                                            AND PH_ABONO IN( '   ', '015' )
			A0002 += "                                                                            AND SPH.D_E_L_E_T_ = ' ') + (SELECT COUNT(*)
			A0002 += "                                                                                                           FROM "+RetSqlName("SPC")+" SPC
			A0002 += "                                                                                                          INNER JOIN SP9010 SP9 ON P9_FILIAL = '"+xFilial("SP9")+"'
			A0002 += "                                                                                                                               AND P9_CODIGO = PC_PDI
			A0002 += "                                                                                                                               AND P9_CLASEV = '02'
			A0002 += "                                                                                                                               AND P9_BHORAS = 'N'
			A0002 += "                                                                                                                               AND SP9.D_E_L_E_T_ = ' '
			A0002 += "                                                                                                          WHERE PC_FILIAL = '"+xFilial("SPC")+"'
			A0002 += "                                                                                                            AND PC_MAT = SRA.RA_MAT
			A0002 += "                                                                                                            AND PC_DATA BETWEEN '"+xx_DtIni+"' AND '"+xx_DtFin+"'
			A0002 += "                                                                                                            AND PC_ABONO IN( '   ', '015')
			A0002 += "                                                                                                            AND SPC.D_E_L_E_T_ = ' ')) FALTAS
			*/
		ELSE

			// Alteraçao para tratamento diferenciado para o TICKET de 13
			A0002 += "                   AND SR8.D_E_L_E_T_ = ' '), 'ATIVO') STA

		ENDIF

		A0002 += "   FROM "+RetSqlName("SRA")+" SRA
		A0002 += "  WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"'
		// Retirada regra conforma OS effettivo 1072-13
		A0002 += "    AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
		// Retirado filtro dos demitidos em 30/05/16 em atendimento a OS effettivo 2589-15
		//A0002 += "    AND SRA.RA_SITFOLH <> 'D'
		A0002 += "    AND SRA.RA_PERFGTS <> '2'
		A0002 += "    AND SRA.RA_MAT < '100000'
		// desabilitado pra atender a OS 0514-15 em 26/03/2015... nao gerar informaçao pra Categoria diferente de M
		//A0002 += "    AND (SRA.RA_CC <> '4000' OR SRA.RA_CATFUNC = 'M')
		A0002 += "    AND SRA.RA_CATFUNC = 'M'
		A0002 += "    AND SUBSTRING(SRA.RA_ADMISSA,1,6) <= '"+MV_PAR01+"'
		A0002 += "    AND SRA.RA_YPCD <> '2'
		// 2014.08.27 Modificado para buscar o campo no cadastro de Funcionarios RA_YPCD diferente de EXTERNO

		A0002 += "    AND SRA.D_E_L_E_T_ = ' '
		A0002 += "  ORDER BY SRA.RA_MAT
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc(A002->RA_NOME)

			xj_DiasBase := 0
			xj_Obs      := ""
			xj_Afastam  := A002->AFASTAM
			// Alteraçao para tratamento diferenciado para o TICKET de 13
			IF SUBSTR(MV_PAR01,5,2) <> '13'
				xj_Faltas   := A002->FALTAS
			ELSE
				xj_Faltas   := 0
			ENDIF

			// O Campo R8_YMOTAFA, quando diferernte de BRANCO significa que foi abonado o afastamento, logo poderá ser pago o benefício.
			If xj_Afastam > 0
				A0010 := " SELECT COUNT(*) CONTAD
				A0010 += "   FROM " + RetSqlName("SR8")
				A0010 += "  WHERE R8_FILIAL = '"+xFilial("SR8")+"'
				A0010 += "    AND R8_MAT = '"+A002->RA_MAT+"'
				A0010 += "    AND SUBSTRING(R8_DATAINI,1,6) >= '"+MV_PAR01+"'
				A0010 += "    AND (SUBSTRING(R8_DATAFIM,1,6) <= '"+MV_PAR01+"' OR R8_DATAFIM = '        ')
				A0010 += "    AND R8_TIPO <> 'F'
				A0010 += "    AND R8_TIPOAFA <> '001'
				A0010 += "    AND R8_YMOTAFA <> '                              '
				A0010 += "    AND D_E_L_E_T_ = ' '
				TcQuery A0010 New Alias "A010"
				dbSelectArea("A010")
				dbGoTop()
				If A010->CONTAD > 0
					xj_Obs += Alltrim(Str(xj_Afastam))+" Afastamentos - ATESTADO MÉDICO; "
					xj_Afastam := 0
				EndIf
				A010->(dbCloseArea())
				dbSelectArea("A002")
			EndIf

			// Tratamento para os casos em que o funcionário está afastado por tempo indeterminado sendo que este afastamento começo em
			//período anterior ao período de apuração em questão.
			If A002->STA == "AFAT_ABONAD"
				xj_Obs += "Afast. Indeterminado Abonado;"
			ElseIf A002->STA == "AFAT_INDET "
				xj_Obs += "Afast. Indeterminado s/Abono;"
				xj_Afastam := 1
			EndIf

			If xj_Afastam + xj_Faltas == 0
				If A002->ADM_DEM == "S"
					xj_DiasBase := Val(A002->DEM_DIAS) - Val(A002->ADM_DIAS) + 1
					xj_DiasBase := 0  // Conforme solicitado em 29/11/11 pela OS 0947-11 Effettivo. Implementado em 01/12/11 por Marcos Alberto
				ElseIf A002->ADM_MES == "S"
					xj_Obs += "Adm Dia: " + A002->ADM_DIAS+";"
					xj_UltDia = 30 // Esta regra já erar usada pela rotina antiga e foi confirmada em 04/08/11 pela Letícia/RH
					xj_DiasBase := (xj_UltDia - Val(A002->ADM_DIAS)) + 1
					//xj_DiasBase := 0  // Conforme solicitado em 29/11/11 pela OS 0947-11 Effettivo. Implementado em 01/12/11 por Marcos Alberto
					xj_DiasBase := (30 - Val(A002->ADM_DIAS)) + 1 // Conforme solicitado em 29/05/15 pela OS -15 Effettivo. Implementado em 29/05/15 por Wanisay
				ElseIf A002->DEM_MES == "S"
					xj_Obs += "Dem Dia: " + A002->DEM_DIAS+";"
					xj_DiasBase := Val(A002->DEM_DIAS)
					//xj_DiasBase := 0  // Conforme solicitado em 29/11/11 pela OS 0947-11 Effettivo. Implementado em 01/12/11 por Marcos Alberto // Retirado novamente em 01/06/16 conforme OS effettivo 2589-15
				Else
					xj_DiasBase := 30
				EndIf
			Else
				If xj_Afastam > 0
					xj_Obs += Alltrim(Str(xj_Afastam))+" Afastamentos; "
				EndIf
				If xj_Faltas > 0
					xj_Obs += Alltrim(Str(xj_Faltas))+" Faltas. "
				EndIf
			EndIf

			RecLock("SZS",.T.)
			SZS->ZS_FILIAL	:= xFilial("SZS")
			SZS->ZS_MESANO  := MV_PAR01
			SZS->ZS_MAT		:= A002->RA_MAT
			SZS->ZS_NOME	:= A002->RA_NOME
			SZS->ZS_VALOR   := xj_DiasBase / 30 * xl_Valor
			SZS->ZS_DTPAG   := xl_DatPag
			SZS->ZS_BENEF   := StrZero(nRadMenu1,1)
			SZS->ZS_DIASREF := xj_DiasBase
			SZS->ZS_TXBASE  := IIF(xj_DiasBase > 0, xl_TxBase, 0)
			SZS->ZS_OBS     := xj_Obs
			MsUnLock()

			dbSelectArea("A002")
			dbSkip()
		End
		A002->(dbCloseArea())

		//2014.03.31 - Julio, ajuste para verificaçao do Beneficio Ticket VITCER (nRadMenu1=5+1)
	ElseIf nRadMenu1 == 2 .or. nRadMenu1 == 3 .or. (nRadMenu1+nRadTicket) == 6

		Campos_work := {}
		AADD(  Campos_Work , {"MATRI"     ,    "C" ,    06 ,  0}  )
		AADD(  Campos_Work , {"TURNO"     ,    "C" ,    03 ,  0}  )
		AADD(  Campos_Work , {"FERIAS"    ,    "N" ,    18 ,  2}  )
		AADD(  Campos_Work , {"FALTAS"    ,    "N" ,    18 ,  2}  )
		AADD(  Campos_Work , {"NORMAL"    ,    "N" ,    18 ,  2}  )
		AADD(  Campos_Work , {"DSR"       ,    "N" ,    18 ,  2}  )
		T001 := CriaTrab(Campos_work,.T.)
		cInd := CriaTrab(Nil,.F.)
		dbUseArea(.T.,,T001,"T001",.F.,.F.)
		cChave  :="MATRI+TURNO"
		IndRegua("T001",cInd,cChave,,,"Selecionando registros...")

		Cp_work := {}
		AADD(  Cp_Work , {"MATRI"     ,    "C" ,    06 ,  0}  )
		AADD(  Cp_Work , {"OBS"       ,    "C" ,    90 ,  0}  )
		AADD(  Cp_Work , {"DIASREF"   ,    "N" ,    18 ,  2}  )
		T002 := CriaTrab(Cp_work,.T.)
		cInd := CriaTrab(Nil,.F.)
		dbUseArea(.T.,,T002,"T002",.F.,.F.)
		cChave  :="MATRI"
		IndRegua("T002",cInd,cChave,,,"Selecionando registros...")

		A0002 := " SELECT PO_DATAINI, PO_DATAFIM
		A0002 += "   FROM "+RetSqlName("SPO")
		A0002 += "  WHERE PO_FILIAL = '"+xFilial("SPO")+"'
		A0002 += "    AND SUBSTRING(PO_DATAFIM,1,6) = '"+MV_PAR01+"'
		A0002 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0002 New Alias "A002"
		dbSelectArea("A002")
		dbGoTop()
		// Alteração efetuada para tratramento do novo período de ponto que passa de 11/10 para 21/20
		sh_DtIni  := IIf(A002->PO_DATAINI == "20190911", "20190921", A002->PO_DATAINI)
		sh_DtFin  := A002->PO_DATAFIM
		old_DtIni := IIf(A002->PO_DATAINI == "20190911", "20190921", A002->PO_DATAINI)
		old_DtFin := A002->PO_DATAFIM
		If Empty(sh_DtIni)
			MsgINFO("O período do ponto ainda não foi fechado!!!")
			Return
		EndIf
		A002->(dbCloseArea())

		A0001 := " SELECT SR8.R8_MAT MATRIC,
		A0001 += "        CASE
		A0001 += "          WHEN SR8.R8_DATAINI < '"+sh_DtIni+"' THEN
		A0001 += "            '"+sh_DtIni+"'
		A0001 += "          ELSE
		A0001 += "            SR8.R8_DATAINI
		A0001 += "          END DTINI,

		// Tiago Rossini Coradini - 03/10/2016 - OS: 0591-15 - Jessica Alvarenga - Ajuste no calculo de ticket para funcionarios em ferias
		A0001 += " CASE WHEN SR8.R8_DATAFIM BETWEEN '"+sh_DtIni+"' AND '"+sh_DtFin+"' OR SR8.R8_DATAFIM = '' THEN SR8.R8_DATAFIM ELSE '"+sh_DtFin+"' END DTFIM, "

		A0001 += "        '   ' TURNO,
		A0001 += "        'FERIAS' TIPO
		A0001 += "   FROM "+RetSqlName("SR8")+" SR8
		A0001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON SRA.RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                       AND SRA.RA_MAT = SR8.R8_MAT
		// Retirado filtro dos demitidos em 30/05/16 em atendimento a OS effettivo 2589-15
		A0001 += "                       AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
		//A0001 += "                       AND SRA.RA_SITFOLH <> 'D'
		A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0001 += "  WHERE SR8.R8_FILIAL = '"+xFilial("SR8")+"'

		// Tiago Rossini Coradini - 03/10/2016 - OS: 0591-15 - Jessica Alvarenga - Ajuste no calculo de ticket para funcionarios em ferias
		A0001 += "    AND SR8.R8_DATAINI BETWEEN dbo.FirstDayOfDate(DATEADD(MONTH, -1, '"+sh_DtIni+"')) AND '"+sh_DtFin+"' "
		A0001 += "    AND SR8.R8_DATAFIM BETWEEN '"+sh_DtIni+"' AND dbo.LastDayOfDate(DATEADD(MONTH, 1, '"+sh_DtFin+"')) "
		A0001 += "    AND ( SR8.R8_TIPO = 'F' OR SR8.R8_TIPOAFA = '001' ) "
		A0001 += "    AND SR8.D_E_L_E_T_ = '' "

		A0001 += " UNION

		A0001 += " SELECT SPH.PH_MAT MATRIC,
		A0001 += "        SPH.PH_DATA DTINI,
		A0001 += "        SPH.PH_DATA DTFIM,
		A0001 += "        SPH.PH_TURNO TURNO,
		A0001 += "        CASE
		A0001 += "          WHEN SP9.P9_CLASEV = '02' AND SPH.PH_ABONO = '   ' THEN
		A0001 += "            'FALTA'
		A0001 += "          ELSE
		A0001 += "            'NORMAL'
		A0001 += "          END TIPO
		A0001 += "   FROM "+RetSqlName("SPH")+" SPH
		A0001 += "  INNER JOIN "+RetSqlName("SP9")+" SP9 ON SP9.P9_FILIAL = '"+xFilial("SP9")+"'
		A0001 += "                       AND SP9.P9_CODIGO = SPH.PH_PD
		A0001 += "                       AND SP9.P9_TIPOCOD <> '3'
		A0001 += "                       AND SP9.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON SRA.RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "                       AND SRA.RA_MAT = SPH.PH_MAT
		// Retirado filtro dos demitidos em 30/05/16 em  atendimento a OS effettivo 2589-15
		A0001 += "                       AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
		//A0001 += "                       AND SRA.RA_SITFOLH <> 'D'
		A0001 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0001 += "  WHERE SPH.PH_FILIAL = '"+xFilial("SPH")+"'
		A0001 += "    AND SPH.PH_DATA BETWEEN '"+sh_DtIni+"' AND '"+sh_DtFin+"'
		A0001 += "    AND SPH.D_E_L_E_T_ = ' '
		A0001 += "  ORDER BY MATRIC, DTINI, DTFIM

		TcQuery A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			// É necessário incluir esta regra para tratamento daqueles funcionários que são demitidos durante o período...
			SRA->(dbSetOrder(1))
			SRA->(dbSeek(xFilial("SRA")+A001->MATRIC))
			If dtos(SRA->RA_ADMISSA) > sh_DtIni
				sh_DtIni  := dtos(SRA->RA_ADMISSA)
			EndIf
			If !Empty(SRA->RA_DEMISSA) .and. dtos(SRA->RA_DEMISSA) < sh_DtFin
				sh_DtFin  := dtos(SRA->RA_DEMISSA)
			EndIf

			dk_PrimeiroD := sh_DtIni
			dk_Mat       := A001->MATRIC

			A0017 := " SELECT PF_TURNOPA
			A0017 += "   FROM " + RetSqlName("SPF")
			A0017 += "  WHERE PF_FILIAL = '"+xFilial("SPF")+"'
			A0017 += "    AND PF_MAT = '"+dk_Mat+"'
			A0017 += "    AND PF_DATA IN(SELECT MAX(PF_DATA)
			A0017 += "                     FROM " + RetSqlName("SPF")
			A0017 += "                    WHERE PF_FILIAL = '"+xFilial("SPF")+"'
			A0017 += "                      AND PF_MAT = '"+dk_Mat+"'
			A0017 += "                      AND PF_DATA < '"+sh_DtIni+"'
			A0017 += "                      AND D_E_L_E_T_ = ' ')
			A0017 += "    AND D_E_L_E_T_ = ' '
			TcQuery A0017 New Alias "A017"
			dbSelectArea("A017")
			dbGoTop()
			dk_TurAnt := A017->PF_TURNOPA
			A017->(dbCloseArea())

			IncProc("Processando...  " + A001->MATRIC)

			// Busca DSR quando este acontece logo no primeiro dia Período do Ponto
			If A001->DTINI <> dk_PrimeiroD
				dbSelectArea("T001")
				If !dbSeek(A001->MATRIC+dk_TurAnt)
					RecLock("T001",.T.)
					T001->MATRI  := A001->MATRIC
					T001->TURNO  := dk_TurAnt
				Else
					RecLock("T001",.F.)
				EndIf
				T001->DSR    += stod(A001->DTINI) - stod(dk_PrimeiroD)
				MsUnLock()
				dk_PrimeiroD := A001->DTINI
			EndIf

			// Efetua Loop dentro da matrícula para apurar dias trabalhados
			dk_GrvDtFim := Space(8)
			dbSelectArea("A001")
			While !Eof() .and. A001->MATRIC == dk_Mat
				dk_TurAnt := IIF(!Empty(A001->TURNO), A001->TURNO, dk_TurAnt)
				If A001->DTINI == dk_PrimeiroD
					dbSelectArea("T001")
					If !dbSeek(A001->MATRIC+dk_TurAnt)
						RecLock("T001",.T.)
						T001->MATRI  := A001->MATRIC
						T001->TURNO  := dk_TurAnt
					Else
						RecLock("T001",.F.)
					EndIf
					If A001->TIPO == "FERIAS"
						T001->FERIAS += stod(A001->DTFIM) - stod(A001->DTINI) + 1
					EndIf
					If A001->TIPO == "FALTA "
						T001->FALTAS += stod(A001->DTFIM) - stod(A001->DTINI) + 1
					EndIf
					If A001->TIPO == "NORMAL"
						T001->NORMAL += stod(A001->DTFIM) - stod(A001->DTINI) + 1
					EndIf
					MsUnLock()
					dk_PrimeiroD := dtos(stod(A001->DTFIM)+1)
				Else
					// Para os dias de DSR dentro do Período do Ponto
					dbSelectArea("T001")
					If !dbSeek(A001->MATRIC+dk_TurAnt)
						RecLock("T001",.T.)
						T001->MATRI  := A001->MATRIC
						T001->TURNO  := dk_TurAnt
					Else
						RecLock("T001",.F.)
					EndIf
					T001->DSR    += stod(A001->DTINI) - stod(dk_PrimeiroD)
					MsUnLock()
					dk_PrimeiroD := A001->DTINI
					// É impressindível este loop para que o sistema não vá para o outro registro....
					Loop
				EndIf
				dk_GrvDtFim := A001->DTFIM
				dbSelectArea("A001")
				dbSkip()
			End
			// Busca DSR quando este acontece nos ultimos dias do Período do Ponto
			If dk_GrvDtFim <> sh_DtFin
				dbSelectArea("T001")
				If !dbSeek(dk_Mat+dk_TurAnt)
					RecLock("T001",.T.)
					T001->MATRI  := dk_Mat
					T001->TURNO  := dk_TurAnt
				Else
					RecLock("T001",.F.)
				EndIf
				T001->DSR    += stod(sh_DtFin) - stod(dk_GrvDtFim)
				MsUnLock()
			EndIf
			dbSelectArea("A001")

			// Isto se fez necessário porque as duas datas são diretamente interferidas pela data de admissão de demissão do funcionário
			sh_DtIni  := old_DtIni
			sh_DtFin  := old_DtFin

		End
		A001->(dbCloseArea())

		dbSelectArea("T001")
		dbGoTop()
		While !Eof()

			dbSelectArea("T002")
			If !dbSeek(T001->MATRI)
				RecLock("T002",.T.)
				T002->MATRI  := T001->MATRI
			Else
				RecLock("T002",.F.)
			EndIf
			T002->OBS := Alltrim(T002->OBS) + " * T=" + T001->TURNO
			If T001->FERIAS <> 0
				T002->OBS := Alltrim(T002->OBS) + ",Fe:" + Alltrim(Str(T001->FERIAS))
			EndIf
			If T001->FALTAS <> 0
				T002->OBS := Alltrim(T002->OBS) + ",Fa:" + Alltrim(Str(T001->FALTAS))
			EndIf
			If T001->NORMAL <> 0
				T002->OBS := Alltrim(T002->OBS) + ",N:" + Alltrim(Str(T001->NORMAL))
			EndIf
			If T001->DSR <> 0
				T002->OBS := Alltrim(T002->OBS) + ",Ds:" + Alltrim(Str(T001->DSR))
			EndIf

			// Arredondamento em virtude da regra de 30 dias usado pela Folha.
			xg_Arred30 := 0
			If T001->NORMAL + T001->DSR > 30
				xg_Arred30 := -1
			EndIf
			If T001->NORMAL + T001->DSR == 28 .and. Substr(MV_PAR01,5,2) == "02"
				xg_Arred30 := 2
			EndIf
			// Identificado por Jessica em 02/04/13 durante apuração dos valores do mes de março de 2013. Foi necessário inserir esta regra porque a regra acima somente antende quando o fechamento for dentro do mes.
			// atualmente o fechamento é feito de 11/xx/xx a 10/xx+1/xx
			If T001->NORMAL + T001->DSR == 28 .and. Substr(MV_PAR01,5,2) == "03"
				xg_Arred30 := 2
			EndIf
			If T001->NORMAL + T001->DSR == 29 .and. Substr(MV_PAR01,5,2) == "03"
				xg_Arred30 := 1
			EndIf

			//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
			DbSelectArea( "SR6" )
			DbSetOrder( 1 )
			DbSeek( xFilial("SR6") + T001->TURNO, .F. )
			cTpBenef := SR6->R6_YTPBENE

			If T001->NORMAL <> 0 .or. T001->DSR <> 0
				//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
				//If T001->TURNO $ "003,005,012,013,019,020,023,028,045,046,065,075,082,084,086,088,089,090,095" .and. nRadMenu1 == 2
				If cTpBenef == "2" .and. nRadMenu1 == 2    //..	Aguardando Validaçao 2014.12.22 ... ativado em 2015.01.12
					T002->DIASREF += T001->NORMAL + T001->DSR + xg_Arred30
				EndIf
				//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
				//If T001->TURNO $ "047,114" .and. nRadMenu1 == 3
				If cTpBenef == "3" .and. nRadMenu1 == 3     //..	Aguardando Validaçao 2014.12.22 ... ativado em 2015.01.12
					T002->DIASREF += T001->NORMAL + T001->DSR + xg_Arred30
				EndIf
			EndIf

			dbSelectArea("T001")
			dbSkip()
		End
		T001->(dbCloseArea())

		/*-----------------------------------------------------------------------+
		| Query busca a Quantidade de Dias Trabalhados no Período Anterior       |
		+-----------------------------------------------------------------------*/
		dbSelectArea("T002")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Armazenando....")

			tk_Mat := T002->MATRI
			/*----------------------------------------------------------+
			| Query que busca o Valor Antecipado no Mes anterior        |
			+----------------------------------------------------------*/
			xc_MesAnt   := Substr(dtos(stod(MV_PAR01+"01") - 1),1,6)
			xc_QtDiaAnt := 0
			A0007 := " SELECT SUM(ZS_DSMATU) ANTECIP
			A0007 += "   FROM " + RetSqlName("SZS")
			A0007 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
			A0007 += "    AND ZS_MESANO = '"+xc_MesAnt+"'
			A0007 += "    AND ZS_MAT = '"+tk_Mat+"'
			//2014.03.31 - Julio Ajuste Ticket VITCER
			A0007 += "    AND ZS_BENEF = '"+StrZero(nRadMenu1+nRadTicket,1)+"'
			A0007 += "    AND D_E_L_E_T_ = ' '
			TcQuery A0007 New Alias "A007"
			dbSelectArea("A007")
			dbGoTop()
			xc_QtDiaAnt := A007->ANTECIP
			A007->(dbCloseArea())

			/*----------------------------------------------------------+
			| 26/09/13 - Tratamento para buscar saldo devedor no período|
			|            anterior para subtrair na apuração do mês      |
			+----------------------------------------------------------*/
			xc_MesAnt   := Substr(dtos(stod(MV_PAR01+"01") - 1),1,6)
			xc_xDevAnt  := 0
			P0005 := " SELECT SUM(ZS_VALOR) XVALOR
			P0005 += "   FROM " + RetSqlName("SZS")
			P0005 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
			P0005 += "    AND ZS_MESANO = '"+xc_MesAnt+"'
			P0005 += "    AND ZS_MAT = '"+tk_Mat+"'
			//2014.03.31 - Julio, ajuste Ticket VITCER
			P0005 += "    AND ZS_BENEF = '"+StrZero(nRadMenu1+nRadTicket,1)+"'
			P0005 += "    AND D_E_L_E_T_ = ' '
			TcQuery P0005 New Alias "P005"
			dbSelectArea("P005")
			dbGoTop()
			If P005->XVALOR < 0
				xc_xDevAnt := ABS(P005->XVALOR)
			EndIf
			P005->(dbCloseArea())

			/*------------------------------------------------------------+
			| Projeta Quantidade de dias para o Mês atual conf. turno     |
			| * Em 04/11/11 foi identificado que a antecipação estava com |
			| problema, pois não era conveniente antecipar 30 dias uma    |
			| vez que, a apuração é feita pelo período do ponto em não    |
			| na virada no Mês                                            |
			| * Em 11/11/11 identificamos que não poderá ser contemplado o|
			| turno atual e sim o TURNO em que o funcionário estava no 1º |
			| dia subsequente o fechamento do período do cálculo.         |
			+------------------------------------------------------------*/
			A0017 := " SELECT PF_DATA, PF_TURNOPA
			A0017 += "   FROM " + RetSqlName("SPF")
			A0017 += "  WHERE PF_FILIAL = '"+xFilial("SPF")+"'
			A0017 += "    AND PF_MAT = '"+tk_Mat+"'
			A0017 += "    AND PF_DATA IN(SELECT MAX(PF_DATA)
			A0017 += "                     FROM " + RetSqlName("SPF")
			A0017 += "                    WHERE PF_FILIAL = '"+xFilial("SPF")+"'
			A0017 += "                      AND PF_MAT = '"+tk_Mat+"'
			A0017 += "                      AND PF_DATA <= '"+dtos(stod(sh_DtFin)+1)+"'
			A0017 += "                      AND D_E_L_E_T_ = ' ')
			A0017 += "    AND D_E_L_E_T_ = ' '
			TcQuery A0017 New Alias "A017"
			dbSelectArea("A017")
			dbGoTop()
			tk_UltTur := A017->PF_TURNOPA
			tk_UltDat := A017->PF_DATA
			A017->(dbCloseArea())

			//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
			DbSelectArea( "SR6" )
			DbSetOrder( 1 )
			DbSeek( xFilial("SR6") + tk_UltTur, .F. )
			cTpBenef := SR6->R6_YTPBENE

			dl_Atual := 0
			//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
			//If tk_UltTur $ "003,005,012,013,019,020,023,028,045,046,065,075,082,084,086,088,089,090,095" .and. (nRadMenu1 == 2 .or. (nRadMenu1+nRadTicket)==6)
			If cTpBenef == "2" .and. (nRadMenu1 == 2 .or. (nRadMenu1+nRadTicket)==6)  //..	Aguardando Validaçao 2014.12.22 ... ativado em 2015.01.12
				dl_Atual := 30
				// Retirado em 11/11/11 conforme justificativa acima
				//If tk_UltDat > sh_DtIni
				//	dl_Atual -= stod(tk_UltDat) - (stod(sh_DtFin)+1)
				//EndIf
			EndIf
			//2014.12.22 - Ajuste para verificar o Tipo de Beneficio no Cadastro de Turno
			//If tk_UltTur $ "047,114" .and. nRadMenu1 == 3
			If cTpBenef == "3" .and. nRadMenu1 == 3 //..	Aguardando Validaçao 2014.12.22 ... ativado em 2015.01.12
				dl_Atual := 30
				// Retirado em 11/11/11 conforme justificativa acima
				//If tk_UltDat > sh_DtIni
				//	dl_Atual -= stod(tk_UltDat) - (stod(sh_DtFin)+1)
				//EndIf
			EndIf
			// Exceções para antecipação de valor
			If dl_Atual > 0
				If cEmpAnt == "01"
					// Incluidas matriculas 000832,000690,000130,000550,000512,000616 conforme OS 2679-12
					If !(tk_Mat $ "000073,000305,000561,000602,000679,000685,000733,000734,000771,000780,000835,000256,000306,000745,000764,000645,000179,000771,000549,000637,000681,000381,000752,000692,000453,000817,000829,000676,000832,000690,000130,000550,000512,000616,000176,000410,000548,000572,000680,000825,000382,000390" .or. tk_Mat >= "000852")
						dl_Atual := 0
					EndIf
				ElseIf cEmpAnt == "05"
					If !(tk_Mat $ "000115,000213" .or. tk_Mat >= "000215")
						dl_Atual := 0
					EndIf
				EndIf
			EndIf

			/*--------------------------------------------------+
			| Atualiza a Base de Dados do Beneficio no Período  |
			+--------------------------------------------------*/

			gt_VlrRef := xl_Valor / 30

			dbSelectArea("SZS")
			RecLock("SZS",.T.)
			SZS->ZS_FILIAL	:= xFilial("SZS")
			SZS->ZS_MESANO  := MV_PAR01
			SZS->ZS_MAT	    := tk_Mat
			SZS->ZS_NOME    := Posicione("SRA",1,xFilial("SRA")+tk_Mat,"RA_NOME")
			SZS->ZS_DTPAG   := xl_DatPag
			//2014.03.31 - Julio, ajuste para Ticket VITCER
			SZS->ZS_BENEF   := StrZero(nRadMenu1+nRadTicket,1)
			SZS->ZS_TXBASE  := IIF(T002->DIASREF > 0, xl_TxBase, 0)
			SZS->ZS_DIASREF := T002->DIASREF
			SZS->ZS_SLDSANT := T002->DIASREF - xc_QtDiaAnt
			SZS->ZS_DSMATU  := dl_Atual
			SZS->ZS_VALOR := (((T002->DIASREF - xc_QtDiaAnt) + dl_Atual) * gt_VlrRef) - xc_xDevAnt 
			SZS->ZS_OBS := T002->OBS
			SZS->(MsUnLock())

			// Tiago Rossini Coradini - 04/10/2016 - OS: 0590-15 - Jessica Alvarenga - Rotina para compensar valores Comprocard 1 e 2
			fComVal(MV_PAR01, tk_Mat, Posicione("SRA",1,xFilial("SRA")+tk_Mat,"RA_NOME"), xl_DatPag,;
			StrZero(nRadMenu1+nRadTicket,1), IIF(T002->DIASREF > 0, xl_TxBase, 0),;
			(((T002->DIASREF - xc_QtDiaAnt) + dl_Atual) * gt_VlrRef) - xc_xDevAnt)

			// Tiago Rossini Coradini - 31/01/2017 - OS: 2195-16 - Jessica Alvarenga - Rotina para compensar valores Comprocard 1 e 2 para funcionarios demitidos
			fComValD(MV_PAR01, tk_Mat, Posicione("SRA",1,xFilial("SRA")+tk_Mat,"RA_NOME"), xl_DatPag,;
			StrZero(nRadMenu1+nRadTicket,1), IIF(T002->DIASREF > 0, xl_TxBase, 0),;
			(((T002->DIASREF - xc_QtDiaAnt) + dl_Atual) * gt_VlrRef) - xc_xDevAnt, xl_Valor)


			dbSelectArea("T002")
			dbSkip()

		End

		T002->(dbCloseArea())

	ElseIf nRadMenu1 == 4                                        //Combustível
		**********************************************************************

		xj_DTLim    := dtos(UltimoDia(stod(MV_PAR01+"01")))

		A0001 := " SELECT RA_MAT,
		A0001 += "        RA_NOME,
		A0001 += "        SUBSTRING(RA_ADMISSA, 1, 6) ADMISSA
		A0001 += "   FROM " + RetSqlName("SRA")
		A0001 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		A0001 += "    AND RA_YVALCOM = 'S'
		A0001 += "    AND RA_SITFOLH <> 'D'
		A0001 += "    AND RA_ADMISSA <= '"+xj_DTLim+"'
		A0001 += "    AND D_E_L_E_T_ = ' '
		A0cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,A0001),'A001',.F.,.T.)
		dbSelectArea("A001")
		dbGoTop()
		While !Eof()

			xj_DiasBase := 30
			xj_Obs      := ""
			xj_ValRef   :=  xl_Valor
			If A001->ADMISSA == MV_PAR01
				xj_DiasBase := 0
				xj_Obs      := "Valor zerado por se tratar do mes de admissão"
				xj_ValRef   := 0
			EndIf

			RecLock("SZS",.T.)
			SZS->ZS_FILIAL	:= xFilial("SZS")
			SZS->ZS_MESANO  := MV_PAR01
			SZS->ZS_MAT	    := A001->RA_MAT
			SZS->ZS_NOME    := A001->RA_NOME
			SZS->ZS_VALOR   := xj_ValRef
			SZS->ZS_DTPAG   := xl_DatPag
			SZS->ZS_BENEF   := StrZero(nRadMenu1,1)
			SZS->ZS_DIASREF := xj_DiasBase
			SZS->ZS_TXBASE  := IIF(xj_DiasBase > 0, xl_TxBase, 0)
			SZS->ZS_OBS     := xj_Obs
			MsUnLock()

			dbSelectArea("A001")
			dbSkip()

		End

		Ferase(A0cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(A0cIndex+OrdBagExt())          //indice gerado
		A001->(dbCloseArea())

	ELSEIF (nRadMenu1+nRadTicket) == 7

	EndIf

	A0006 := " UPDATE "+RetSqlName("SZS")+" SET ZS_PAGAR = 'P'
	A0006 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
	A0006 += "    AND ZS_MESANO = '"+MV_PAR01+"'
	A0006 += "    AND ZS_MAT = '     '
	A0006 += "    AND ZS_BENEF = '"+StrZero(nRadMenu1,1)+"'
	A0006 += "    AND ZS_PAGAR = ' '
	A0006 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(A0006)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA254B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 14.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Função para Impressão de Relatório de Benefícios           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA254B()

	Processa({|| RptDetailR()})

Return

Static Function RptDetailR()

	Local oButton1
	Local oCheckBo1
	Local lCheckBo1 := .F.
	Local oRadMenu1
	Local nRadMenu1 := 0
	Private oDlg01

	DEFINE MSDIALOG oDlg01 TITLE "Relatório de Benefícios" FROM 000, 000  TO 130, 360 COLORS 0, 16777215 PIXEL

	@ 006, 012 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Visa Vale", "Comprocard", "Combustível", "Premiação","Ticket","Alimentação" SIZE 108, 032 OF oDlg01 COLOR 0, 16777215 PIXEL
	@ 008, 131 BUTTON oButton1 PROMPT "Imprimir" SIZE 037, 035 OF oDlg01  ACTION Close(oDlg01) PIXEL
	@ 055, 012 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Listar Valores Zerados?" SIZE 110, 008 OF oDlg01 COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg01 CENTERED

	If nRadMenu1 <> 0

		aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
		ik_Benef := ""

		If nRadMenu1 == 1
			fCabec   := "Controle Visa Vale"
			ik_Benef := "1"

		ElseIf nRadMenu1 == 2
			fCabec   := "Controle Comprocard"
			ik_Benef := "2','3"

		ElseIf nRadMenu1 == 3
			fCabec   := "Combustível"
			ik_Benef := "4"

		ElseIf nRadMenu1 == 4
			fCabec   := "Premiação"
			ik_Benef := "5"

			// 2014.03.31 - Julio - Ajuste para Ticket VITCER
		ElseIf nRadMenu1 == 5
			fCabec   := "Ticket"
			ik_Benef := "6"

			// 2019.04.17 - Ticket 14064 - Adição de Vale Alimentação em função
		ElseIf nRadMenu1 == 6
			fCabec   := "Alimentação"
			ik_Benef := "7"
		EndIf

		wnPag    := 0
		nRow1    := 0

		oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
		oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
		oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
		oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

		oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
		oPrint:SetPortrait()
		oPrint:SetPaperSize(09)
		oPrint:Setup()

		fImpCabec(1, nRadMenu1)

		xt_VlrTot := 0
		A0003 := " SELECT RA_CLVL,
		A0003 += "        ZS_MAT,
		A0003 += "        RA_NOME,
		A0003 += "        ZS_VALOR,
		A0003 += "        ZS_VALOR - CASE WHEN ZS_VALOR > 0 THEN ROUND(ZS_VALOR * 1.5 / 100, 2) ELSE 0 END AS VLR_DESC,
		A0003 += "        ZS_TXBASE+ZS_VLRTX VALTX,
		A0003 += "        ZS_OBS
		A0003 += "   FROM "+RetSqlName("SZS")+" SZS
		A0003 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0003 += "                       AND RA_MAT = ZS_MAT
		A0003 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0003 += "  WHERE ZS_FILIAL = '"+xFilial("SRA")+"'
		A0003 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0003 += "    AND ZS_MAT <> '      '
		A0003 += "    AND ZS_BENEF IN('"+ik_Benef+"')
		If !lCheckBo1
			A0003 += "    AND ZS_VALOR <> 0
		EndIf
		A0003 += "    AND SZS.D_E_L_E_T_ = ' '
		A0003 += "  ORDER BY RA_NOME

		TcQuery A0003 New Alias "A003"

		dbSelectArea("A003")
		dbGoTop()
		ProcRegua(RecCount())

		While !Eof()

			IncProc(A003->RA_NOME)

			If nRow1 > 3350
				fImpRoda()
				fImpCabec(1, nRadMenu1)
			EndIf

			xf_Titu := ""
			xf_Titu += Padr(A003->RA_CLVL, 009) + Space(1)
			xf_Titu += Padr(A003->ZS_MAT, 006) + Space(1)
			xf_Titu += Padr(A003->RA_NOME, 030) + Space(1)
			xf_Titu += Padl(Transform(A003->ZS_VALOR,"@E 999,999,999.99"), 014) + Space(1)			
			xf_Titu += Padl(Transform(A003->VALTX,"@E 999,999,999.99"),014) + Space(1)
			xf_Titu += Padl(Transform(A003->ZS_VALOR+A003->VALTX,"@E 999,999,999.99"), 014) + Space(1)
			xf_Titu += Padr(A003->ZS_OBS, 100)

			oPrint:Say(nRow1, 0050, xf_Titu, oFont10)
			oPrint:Line(nRow1+35, 050, nRow1+35, 2400)

			nRow1 += 075

			If nRadMenu1 == 1 .Or. nRadMenu1 == 2

				If A003->VLR_DESC > 0 .And. !Upper(SubStr(A003->ZS_OBS, 1, 2)) == "CP"
					xt_VlrTot += A003->VLR_DESC + VALTX
				EndIf

			Else

				If A003->ZS_VALOR > 0 .And. !Upper(SubStr(A003->ZS_OBS, 1, 2)) == "CP"
					xt_VlrTot += A003->ZS_VALOR + VALTX
				EndIf

			EndIf

			dbSelectArea("A003")
			dbSkip()

		EndDo()

		A003->(dbCloseArea())

		fImpRoda()
		fImpCabec(2, nRadMenu1)

		vw_VlrT := 0
		vw_VlrD := 0
		vw_TaxT := 0
		vw_TotT := 0
		vw_PerT := 0
		A0004 := " SELECT RA_CLVL,
		A0004 += "        SUM(ZS_VALOR) ZS_VALOR,
		A0004 += "        SUM(ZS_VALOR) - ROUND(SUM(ZS_VALOR) * (1.5/100),2) AS VLR_DESC,
		A0004 += "        SUM(ZS_TXBASE+ZS_VLRTX) VALTX
		A0004 += "   FROM "+RetSqlName("SZS")+" SZS
		A0004 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0004 += "                       AND RA_MAT = ZS_MAT
		A0004 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0004 += "  WHERE ZS_FILIAL = '"+xFilial("SRA")+"'
		A0004 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0004 += "    AND ZS_MAT <> '      '
		A0004 += "    AND ZS_BENEF IN('"+ik_Benef+"')
		A0004 += "    AND ZS_VALOR >= 0

		// Tiago Rossini Coradini - 04/10/2016 - OS: 0590-15 - Jessica Alvarenga - Rotina para compensar valores Comprocard 1 e 2
		A0004 += "    AND UPPER(SUBSTRING(ZS_OBS, 1, 2)) <> 'CP' "

		If !lCheckBo1
			A0004 += "    AND ZS_VALOR <> 0
		EndIf
		A0004 += "    AND SZS.D_E_L_E_T_ = ' '
		A0004 += "  GROUP BY RA_CLVL
		A0004 += "  ORDER BY RA_CLVL
		TcQuery A0004 New Alias "A004"

		dbSelectArea("A004")
		dbGoTop()
		ProcRegua(RecCount())

		While !Eof()

			IncProc(A004->RA_CLVL)

			If nRow1 > 3350
				fImpRoda()
				fImpCabec(2, nRadMenu1)
			EndIf

			xf_Titu := ""
			xf_Titu += Padr(Space(1), 020) + Space(1)
			xf_Titu += Padr(A004->RA_CLVL, 009) + Space(1)
			xf_Titu += Padl(Transform(A004->ZS_VALOR,"@E 999,999,999.99"), 014) + Space(1)

			If nRadMenu1 == 1 .Or. nRadMenu1 == 2
				xf_Titu += Padl(Transform(A004->VLR_DESC, "@E 999,999,999.99"), 014) + Space(1)
			EndIf

			xf_Titu += Padl(Transform(A004->VALTX,"@E 999,999,999.99"),014) + Space(1)

			If nRadMenu1 == 1 .Or. nRadMenu1 == 2

				xf_Titu += Padl(Transform(A004->VLR_DESC+A004->VALTX,"@E 999,999,999.99"), 014) + Space(1)
				xf_Titu += Padl(Transform(((A004->VLR_DESC+A004->VALTX)/xt_VlrTot)*100,"@E 999,999,999.99"), 014)

			Else

				xf_Titu += Padl(Transform(A004->ZS_VALOR+A004->VALTX,"@E 999,999,999.99"), 014) + Space(1)
				xf_Titu += Padl(Transform(((A004->ZS_VALOR+A004->VALTX)/xt_VlrTot)*100,"@E 999,999,999.99"), 014)

			EndIf

			oPrint:Say(nRow1, 0050, xf_Titu, oFont10)
			oPrint:Line(nRow1+35, 050, nRow1+35, 2400)
			nRow1 += 075

			If nRadMenu1 == 1 .Or. nRadMenu1 == 2

				If A004->VLR_DESC > 0

					vw_VlrT += A004->ZS_VALOR
					vw_VlrD += A004->VLR_DESC
					vw_TaxT += A004->VALTX
					vw_TotT += A004->VLR_DESC+A004->VALTX
					vw_PerT += ((A004->VLR_DESC+A004->VALTX)/xt_VlrTot)*100

				EndIf

			Else

				If A004->ZS_VALOR > 0

					vw_VlrT += A004->ZS_VALOR				
					vw_TaxT += A004->VALTX
					vw_TotT += A004->ZS_VALOR+A004->VALTX
					vw_PerT += ((A004->ZS_VALOR+A004->VALTX)/xt_VlrTot)*100

				EndIf

			EndIF

			dbSelectArea("A004")
			dbSkip()

		EndDo()

		A004->(dbCloseArea())

		If nRow1 > 3350
			fImpRoda()
			fImpCabec(2, nRadMenu1)
		EndIf

		xf_Titu := ""
		xf_Titu += Padr(Space(1), 020) + Space(1)
		xf_Titu += Padr("Total-->", 009) + Space(1)
		xf_Titu += Padl(Transform(vw_VlrT,"@E 999,999,999.99"), 014) + Space(1)

		If nRadMenu1 == 1 .Or. nRadMenu1 == 2
			xf_Titu += Padl(Transform(vw_VlrD,"@E 999,999,999.99"), 014) + Space(1)
		EndIf

		xf_Titu += Padl(Transform(vw_TaxT,"@E 999,999,999.99"), 014) + Space(1)
		xf_Titu += Padl(Transform(vw_TotT,"@E 999,999,999.99"), 014) + Space(1)
		xf_Titu += Padl(Transform(vw_PerT,"@E 999,999,999.99"), 014)

		oPrint:Say(nRow1, 0050, xf_Titu, oFont10)
		oPrint:Line(nRow1+35, 050, nRow1+35, 2400)
		nRow1 += 075

		fImpRoda()

		oPrint:EndPage()
		oPrint:Preview()

	Else

		MsgALERT("Erro de Paramentro. Favor verificar!!!")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA254C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA254C()

	Processa({|| RptDetailG()})

Return

Static Function RptDetailG()

	Local oButton1
	Local oRadMenu1
	Local nRadMenu1 := 0
	Private oDlg01gr

	DEFINE MSDIALOG oDlg01gr TITLE "Gerar Arquivo de Benefícios" FROM 000, 000  TO 200, 360 COLORS 0, 16777215 PIXEL

	@ 010, 014 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Banestik(Fora de Uso)", "Comprocard", "Visa Vale", "Combustível", "Premiação", "Ticket", "Diversos","Alimentação" SIZE 180, 080 OF oDlg01gr COLOR 0, 16777215 PIXEL
	@ 008, 131 BUTTON oButton1 PROMPT "Gerar" SIZE 037, 035 OF oDlg01gr  ACTION Close(oDlg01gr) PIXEL

	ACTIVATE MSDIALOG oDlg01gr CENTERED

	//2014.03.31 - Julio, ajuste para verificaçao do Beneficio Ticket VITCER
	If nRadMenu1 == 5
		nRadTicket := 1
	Else
		nRadTicket := 0
	EndIf

	cNewPath := "C:\Temp\"
	If !lIsDir( cNewPath )
		MakeDir( cNewPath )
	EndIf

	// Estrutura para criação do arquivo txt
	If nRadMenu1 == 1
		df_ArqEtq := "c:\temp\" + MV_PAR01 +"_"+cEmpAnt+"_banestik.txt"
	ElseIf nRadMenu1 == 2
		df_ArqEtq := "c:\temp\" + MV_PAR01 +"_"+cEmpAnt+"_Comprocard.txt"
	ElseIf nRadMenu1 == 3
		df_ArqEtq := "c:\temp\" + MV_PAR01 +"_"+cEmpAnt+"_visavale.txt"
	ElseIf nRadMenu1 == 4
		df_ArqEtq := "c:\temp\COMBUSTIVEL_" + UPPER(Alltrim(Substr(SM0->M0_NOME,1,10))) + "_" + GravaData(dDataBase,.F.,5)+StrTran(TIME(),":","")+ ".txt"
	ElseIf nRadMenu1 == 5
		df_ArqEtq := "c:\temp\PREMIACAO_" + UPPER(Alltrim(Substr(SM0->M0_NOME,1,10))) + "_" + GravaData(dDataBase,.F.,5)+StrTran(TIME(),":","")+ ".txt"
	ElseIf (nRadMenu1+nRadTicket) == 6 .or. (nRadMenu1+nRadTicket) == 7
		df_ArqEtq := "c:\temp\" + MV_PAR01 +"_"+cEmpAnt+"_ticket.txt"
	Else
		MsgALERT("Erro de Paramentro. Favor verificar!!!")
		Return
	EndIf

	If File(df_ArqEtq)
		FERASE(df_ArqEtq)
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	Else
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	EndIf
	nTerHdl := FOPEN(df_ArqEtq,FO_WRITE)
	nTamArq := FSEEK(nTerHdl,0,0)

	If nRadMenu1 == 1 //.or. (nRadMenu1+nRadTicket) == 6                              // Banestik (Fora de Uso)
		*********************************************************************

		// Foi necessário implentar este artifício porque quando o cadastramento era manual, acabou-se cadastrando a matricula errada junto ao banco
		wf_VetMat := {}
		If cEmpAnt == "01"
			aadd(wf_VetMat, {'000429', '000430'} )
			aadd(wf_VetMat, {'000445', '001007'} )
			aadd(wf_VetMat, {'000446', '001005'} )
			aadd(wf_VetMat, {'000471', '001013'} )
			aadd(wf_VetMat, {'001001', '011001'} )
			aadd(wf_VetMat, {'001002', '011002'} )
			aadd(wf_VetMat, {'001004', '011004'} )
			aadd(wf_VetMat, {'001005', '011005'} )
			aadd(wf_VetMat, {'001007', '011007'} )
			aadd(wf_VetMat, {'001009', '011009'} )
			aadd(wf_VetMat, {'001011', '110011'} )
			aadd(wf_VetMat, {'001012', '011012'} )
			aadd(wf_VetMat, {'001013', '011013'} )
			aadd(wf_VetMat, {'001015', '011015'} )
			aadd(wf_VetMat, {'001018', '011018'} )
			aadd(wf_VetMat, {'001019', '011019'} )
			aadd(wf_VetMat, {'001020', '011020'} )
			aadd(wf_VetMat, {'001021', '011021'} )
			aadd(wf_VetMat, {'001022', '011022'} )
			aadd(wf_VetMat, {'001023', '011023'} )
			aadd(wf_VetMat, {'001024', '011024'} )
			aadd(wf_VetMat, {'001025', '011025'} )
			aadd(wf_VetMat, {'001026', '011026'} )
			aadd(wf_VetMat, {'001027', '011027'} )
			aadd(wf_VetMat, {'001030', '011030'} )
			aadd(wf_VetMat, {'001031', '011031'} )
			aadd(wf_VetMat, {'001032', '011032'} )
			aadd(wf_VetMat, {'001033', '011033'} )
		ElseIf cEmpAnt == "05"
			aadd(wf_VetMat, {'000350', '100350'} )
			aadd(wf_VetMat, {'000351', '100351'} )
			aadd(wf_VetMat, {'000352', '100352'} )
		EndIf

		AT021 := " SELECT ZS_SEQ
		AT021 += "   FROM "+RetSqlName("SZS")+" SZS
		AT021 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		AT021 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		AT021 += "    AND ZS_BENEF = '1'
		AT021 += "    AND ZS_MAT = '      '
		AT021 += "    AND ZS_VALOR <> 0
		AT021 += "    AND SZS.D_E_L_E_T_ = ' '
		TcQuery AT021 New Alias "AT21"
		dbSelectArea("AT21")
		dbGoTop()
		qw_SeqRem := AT21->ZS_SEQ
		AT21->(dbCloseArea())

		fr_Header := +;
		Padr("H"                             ,001)+;
		Padr(SM0->M0_CGC                     ,014)+;
		Padr(qw_SeqRem                       ,006)+;
		Padr(GravaData(dDataBase,.F.,5)      ,008)+;
		Padr("BANESTIK"                      ,008)+;
		Padr("0"                             ,001)
		FWRITE(nTerHdl,  fr_Header + CRLF )

		wt_CntTot := 0
		wt_SomTot := 0
		A0021 := " SELECT ZS_MAT, ZS_DTPAG, SUM(ZS_VALOR) ZS_VALOR
		A0021 += "   FROM "+RetSqlName("SZS")+" SZS
		A0021 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0021 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0021 += "    AND ZS_BENEF = '1'
		A0021 += "    AND ZS_MAT <> '      '
		A0021 += "    AND ZS_VALOR <> 0
		A0021 += "    AND SZS.D_E_L_E_T_ = ' '
		A0021 += "  GROUP BY ZS_MAT, ZS_DTPAG
		A0021 += "  UNION
		// Conforme solicitado em 29/11/11 pela OS 0947-11 Effettivo. Implementado em 01/12/11 por Marcos Alberto
		A0021 += " SELECT RA_MAT ZS_MAT, RA_ADMISSA ZS_DTPAG, 0 ZS_VALOR
		A0021 += "   FROM "+RetSqlName("SRA")
		A0021 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		// Retirado filtro dos demitidos em 30/05/16 em atendimento a OS effettivo 2589-15
		A0021 += "    AND (RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
		A0021 += "    AND RA_PERFGTS <> '2'
		A0021 += "    AND RA_MAT < '100000'
		A0021 += "    AND (RA_CLVL <> '4000' OR RA_CATFUNC = 'M')
		A0021 += "    AND SUBSTRING(RA_ADMISSA,1,6) = '"+MV_PAR01+"'
		A0021 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0021 New Alias "A021"
		dbSelectArea("A021")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Aguarde! Apurando dados...")

			SRA->(dbSetOrder(1))
			SRA->(dbSeek(xFilial("SRA")+A021->ZS_MAT))

			wf_Matric := A021->ZS_MAT
			nPos := aScan(wf_VetMat,{|x| x[1] == A021->ZS_MAT })
			If nPos > 0
				wf_Matric := wf_VetMat[nPos][2]
			EndIf

			If Substr(dtos(SRA->RA_ADMISSA),1,6) == MV_PAR01
				fr_Regi_B := +;
				Padr("B"                                        ,001)+;
				Padr(StrZero(Val(wf_Matric),11)                 ,011)+;
				Padr(SRA->RA_NOME                               ,050)+;
				Padr(""                                         ,030)+;
				Padr(SRA->RA_RG                                 ,010)+;
				Padr(SRA->RA_CIC                                ,011)+;
				Padr(GravaData(SRA->RA_NASC,.F.,5)              ,008)+;
				Padr("15"                                       ,002)+;
				Padr("00000001"                                 ,008)
				FWRITE(nTerHdl,  fr_Regi_B + CRLF )
				wt_CntTot ++
			EndIf

			If A021->ZS_VALOR <> 0
				fr_Regi_C := +;
				Padr("C"                                                                ,001)+;
				Padr(StrZero(Val(wf_Matric),11)                                         ,011)+;
				Padr("15"                                                               ,002)+;
				Padr(GravaData(stod(A021->ZS_DTPAG),.F.,5)                              ,008)+;
				Padr(Transform(StrZero(A021->ZS_VALOR*100,12),"@R 999999999999")        ,012)
				FWRITE(nTerHdl,  fr_Regi_C + CRLF )
				wt_CntTot ++
				wt_SomTot += A021->ZS_VALOR
			EndIf

			dbSelectArea("A021")
			dbSkip()
		End
		A021->(dbCloseArea())

		fr_Header := +;
		Padr("T"                                                           ,001)+;
		Padr(Transform(StrZero(wt_CntTot,6),"@R 999999")                   ,006)+;
		Padr(Transform(StrZero(wt_SomTot*100,12),"@R 999999999999")        ,012)
		FWRITE(nTerHdl,  fr_Header + CRLF )

		MsgINFO( "O arquivo poderá ser acessado em :      "+df_ArqEtq )

	ElseIf nRadMenu1 == 2      // Comprocard (devem ser somados os dois Comprocard´s)
		*********************************************************************

		A0021 := " SELECT ZS_MAT, RA_NOME, RA_CIC, SUM(ZS_VALOR) ZS_VALOR
		A0021 += "   FROM "+RetSqlName("SZS")+" SZS
		A0021 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0021 += "                       AND RA_MAT = ZS_MAT
		A0021 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0021 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0021 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0021 += "    AND ZS_BENEF IN('2', '3')
		A0021 += "    AND ZS_MAT <> ''
		A0021 += "    AND ZS_VALOR <> 0
		A0021 += "    AND SZS.D_E_L_E_T_ = ''
		A0021 += "  GROUP BY ZS_MAT, RA_NOME, RA_CIC
		TcQuery A0021 New Alias "A021"
		dbSelectArea("A021")
		dbGoTop()
		ProcRegua(RecCount())

		While !Eof()

			IncProc("Aguarde! Apurando dados...")

			If A021-> ZS_VALOR > 0
				FWRITE(nTerHdl, A021->RA_NOME+;
				"	"+;
				A021->RA_CIC+;
				"	"+;
				Transform(A021->ZS_VALOR,"@E 99,999,999.99")+;
				CRLF)
			EndIf

			dbSelectArea("A021")
			dbSkip()
		End
		A021->(dbCloseArea())

		MsgINFO( "O arquivo poderá ser acessado em :      "+df_ArqEtq )

	ElseIf nRadMenu1 == 3                                         // VisaVale
		*********************************************************************

		aDados2 := {}

		dg_TpLc := "  "
		If cEmpAnt == "01"
			dg_TpLc := "FI"
			dg_CNPJ := Right(Alltrim(SM0->M0_CGC),3)
		ElseIf cEmpAnt $ "05,12"
			dg_TpLc := "PT"
			dg_CNPJ := SM0->M0_CGC
		ElseIf cEmpAnt == "13"
			dg_TpLc := "  "
			dg_CNPJ := ""
		ElseIf cEmpAnt == "14"  //2014.06.26 - Julio, inclusao VITCER
			dg_TpLc := "PT"
			dg_CNPJ := "123"
		ElseIf cEmpAnt == "07"  //2019.06.04 - Marcelo Facile, inclusão LM
			dg_TpLc := "  "
			dg_CNPJ := Right(Alltrim(SM0->M0_CGC),3)

		EndIf

		A0033 := " SELECT '%' INI,
		A0033 += "        RA_NOME NOME_DO_USUARIO,
		A0033 += "        RA_CIC CPF,
		A0033 += "        Convert(Char(10),convert(datetime, RA_NASC),103) DATA_NASCIMENTO,
		A0033 += "        RA_SEXO CODIGO_SEXO,
		A0033 += "        ZS_VALOR VALOR,
		A0033 += "        '"+dg_TpLc+"' TP_LOCAL,
		A0033 += "        '"+dg_CNPJ+"' LOCAL_ENTREGA,
		A0033 += "        ZS_MAT MATRICULA,
		A0033 += "        '%' FIM
		A0033 += "   FROM "+RetSqlName("SZS")+" SZS
		A0033 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0033 += "                       AND RA_MAT = ZS_MAT
		A0033 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0033 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0033 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0033 += "    AND ZS_BENEF = '1'
		A0033 += "    AND ZS_MAT <> '      '
		A0033 += "    AND ZS_VALOR <> 0
		A0033 += "    AND SZS.D_E_L_E_T_ = ' '
		A0033 += "  UNION
		// Implantado em 02/03/12
		// Semelhante ao que foi feito para o Benefício Banestik, é necessário gravar um registro zerado para o mes de admissão para que o fornecedor tenha tempo de envia o cartão do empregado.
		A0033 += " SELECT '%' INI,
		A0033 += "        RA_NOME NOME_DO_USUARIO,
		A0033 += "        RA_CIC CPF,
		A0033 += "        Convert(Char(10),convert(datetime, RA_NASC),103) DATA_NASCIMENTO,
		A0033 += "        RA_SEXO CODIGO_SEXO,
		A0033 += "        0 VALOR,
		A0033 += "        '"+dg_TpLc+"' TP_LOCAL,
		A0033 += "        '"+dg_CNPJ+"' LOCAL_ENTREGA,
		A0033 += "        RA_MAT MATRICULA,
		A0033 += "        '%' FIM
		A0033 += "   FROM "+RetSqlName("SRA")
		A0033 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		// Retirado filtro dos demitidos em 30/05/16 em atendimento a OS effettivo 2589-15
		A0033 += "    AND (RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
		A0033 += "    AND RA_PERFGTS <> '2'
		A0033 += "    AND RA_MAT < '100000'
		A0033 += "    AND (RA_CLVL <> '4000' OR RA_CATFUNC = 'M')
		A0033 += "    AND SUBSTRING(RA_ADMISSA,1,6) = '"+MV_PAR01+"'
		A0033 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0033 New Alias "A033"
		dbSelectArea("A033")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Aguarde! Apurando dados...")

			aAdd(aDados2, { Alltrim(A033->INI),;
			Alltrim(A033->NOME_DO_USUARIO),;
			Alltrim(A033->CPF),;
			Alltrim(A033->DATA_NASCIMENTO),;
			Alltrim(A033->CODIGO_SEXO),;
			Alltrim(Transform(A033->VALOR   ,"@E 999,999,999.99")),;
			Alltrim(A033->TP_LOCAL),;
			Alltrim(A033->LOCAL_ENTREGA),;
			Alltrim(A033->MATRICULA),;
			Alltrim(A033->FIM)} )

			dbSelectArea("A033")
			dbSkip()
		End
		aStru1 := ("A033")->(dbStruct())
		A033->(dbCloseArea())

		df_ArqEtq := Substr(SM0->M0_NOME,1,3)+"_"+strzero(seconds()%3500,5)

		aDados2 := aSort(aDados2,,,{|x,y| x[9] < y[9] })
		fGrvCsv(aDados2, aStru1, df_ArqEtq )

	ElseIf nRadMenu1 == 4                                      // Combustível
		*********************************************************************

		__lDebug := .F.

		// Novo Layout
		If __lDebug

			oPolicard := TPolicard():New()

			oPolicard:Get(cValToChar(nRadMenu1), nTerHdl, MV_PAR01)

		Else

			/* TICKET 9336
			xtProdut := "00058"
			xtDescri := "COMBUSTIVEL"
			xtEmprs  := ""
			If cEmpAnt == "01"
			xtEmprs  := "94922"
			Else
			xtEmprs  := "94921"
			EndIf

			fr_Header := +;
			Padr("H"                             ,001)+;
			Padr(xtProdut                        ,005)+;
			Padr(xtDescri                        ,050)+;
			Padr(GravaData(dDataBase,.F.,5)      ,008)
			FWRITE(nTerHdl,  fr_Header + CRLF )*/

			aDados2 := {}

			RF006 := " SELECT ZS_MAT MATRICULA,
			RF006 += "        RA_NOME NOME,
			RF006 += "        RA_SEXO SEXO,
			RF006 += "        RA_NASC DT_NASC,
			RF006 += "        RA_CIC CPF,
			RF006 += "        RA_RG RG,
			RF006 += "        RA_PAI PAI,
			RF006 += "        RA_MAE MAE,
			RF006 += "        ZS_VALOR LIMITE,
			RF006 += "        ZS_DTPAG DTPAGTO
			RF006 += "   FROM "+RetSqlName("SZS")+" SZS
			RF006 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
			RF006 += "                       AND RA_MAT = ZS_MAT
			//2014.03.25 - Julio Ajuste para verificaçao da Situacao do Funcionario Demitido
			// Retirado filtro dos demitidos em 30/05/16 em atendimento a OS effettivo 2589-15
			RF006 += "                       AND (SRA.RA_SITFOLH <> 'D' OR SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR01+"')
			//RF006 += "                       AND RA_SITFOLH <> 'D'
			RF006 += "                       AND SRA.D_E_L_E_T_ = ' '
			RF006 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
			RF006 += "    AND ZS_MESANO = '"+MV_PAR01+"'
			RF006 += "    AND ZS_BENEF = '4'
			RF006 += "    AND ZS_MAT <> '      '
			RF006 += "    AND SZS.D_E_L_E_T_ = ' '

			RFcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF006),'RF06',.F.,.T.)
			dbSelectArea("RF06")
			frLinha := 0
			dbGoTop()
			ProcRegua(RecCount())

			/*TICKET 9336
			While !Eof()

			frLinha ++

			IncProc("Aguarde! Apurando dados...")

			fr_Regi_B := +;
			Padr("D"                                        ,001)+;
			Padr(xtEmprs                                    ,006)+;
			Padl(Alltrim(Str(Val(RF06->MATRICULA)))         ,015)+;
			Padr(RF06->NOME                                 ,050)+;
			Padr(RF06->SEXO                                 ,001)+;
			Padr(GRAVADATA(stod(RF06->DT_NASC), .F., 5)     ,008)+;
			Padr(RF06->CPF                                  ,011)+;
			Padr(RF06->RG                                   ,015)+;
			Padr(RF06->PAI                                  ,050)+;
			Padr(RF06->MAE                                  ,050)+;
			Padr(StrZero(RF06->LIMITE*100,6)                ,006)+;
			Padr(StrZero(frLinha,9)                         ,009)
			FWRITE(nTerHdl,  fr_Regi_B + CRLF )

			dbSelectArea("RF06")
			dbSkip()
			End*/

			//TICKET 9336
			While !Eof()

				IncProc("Aguarde! Apurando dados...")

				If RF06->LIMITE > 0
					FWRITE(nTerHdl, RF06->NOME+;
					"	"+;
					RF06->CPF+;
					"	"+;
					Transform(RF06->LIMITE,"@E 99,999,999.99")+;
					CRLF)
				EndIf

				dbSelectArea("RF06")
				dbSkip()
			End

			aStru1 := ("RF06")->(dbStruct())

			/*TICKET 9336
			fr_Header := +;
			Padr("T"                             ,001)+;
			Padr(StrZero(frLinha,9)              ,009)
			FWRITE(nTerHdl,  fr_Header + CRLF )*/

			Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(RFcIndex+OrdBagExt())          //indice gerado
			RF06->(dbCloseArea())

		EndIf

		MsgINFO("O arquivo poderá ser acessado em: "+ df_ArqEtq)

	ElseIf nRadMenu1 == 5                                        // Premiação
		*********************************************************************

		__lDebug := .F.

		// Novo Layout
		If __lDebug

			oPolicard := TPolicard():New()

			oPolicard:Get(cValToChar(nRadMenu1), nTerHdl, MV_PAR01)

		Else
			xtProdut := "00058"
			xtDescri := "CARTAO PREMIACAO"
			xtEmprs  := ""
			If cEmpAnt == "01"
				xtEmprs  := "95511"
			Else
				xtEmprs  := ""
			EndIf

			fr_Header := +;
			Padr("H"                             ,001)+;
			Padr(xtProdut                        ,005)+;
			Padr(xtDescri                        ,050)+;
			Padr(GravaData(dDataBase,.F.,5)      ,008)
			FWRITE(nTerHdl,  fr_Header + CRLF )

			aDados2 := {}

			RF006 := " SELECT ZS_MAT MATRICULA,
			RF006 += "        RA_NOME NOME,
			RF006 += "        RA_SEXO SEXO,
			RF006 += "        RA_NASC DT_NASC,
			RF006 += "        RA_CIC CPF,
			RF006 += "        RA_RG RG,
			RF006 += "        RA_PAI PAI,
			RF006 += "        RA_MAE MAE,
			RF006 += "        ZS_VALOR LIMITE,
			RF006 += "        ZS_DTPAG DTPAGTO
			RF006 += "   FROM "+RetSqlName("SZS")+" SZS
			RF006 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
			RF006 += "                       AND RA_MAT = ZS_MAT
			RF006 += "                       AND SRA.D_E_L_E_T_ = ' '
			RF006 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
			RF006 += "    AND ZS_MESANO = '"+MV_PAR01+"'
			RF006 += "    AND ZS_BENEF = '5'
			RF006 += "    AND ZS_MAT <> '      '
			RF006 += "    AND SZS.D_E_L_E_T_ = ' '
			RFcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF006),'RF06',.F.,.T.)
			dbSelectArea("RF06")
			frLinha := 0
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				frLinha ++

				IncProc("Aguarde! Apurando dados...")

				fr_Regi_B := +;
				Padr("D"                                        ,001)+;
				Padr(xtEmprs                                   ,006)+;
				Padl(Alltrim(Str(Val(RF06->MATRICULA)))         ,015)+;
				Padr(RF06->NOME                                 ,050)+;
				Padr(RF06->SEXO                                 ,001)+;
				Padr(GRAVADATA(stod(RF06->DT_NASC), .F., 5)     ,008)+;
				Padr(RF06->CPF                                  ,011)+;
				Padr(RF06->RG                                   ,015)+;
				Padr(RF06->PAI                                  ,050)+;
				Padr(RF06->MAE                                  ,050)+;
				Padr(StrZero(RF06->LIMITE*100,6)                ,006)+;
				Padr(StrZero(frLinha,9)                         ,009)
				FWRITE(nTerHdl,  fr_Regi_B + CRLF )

				dbSelectArea("RF06")
				dbSkip()
			End
			aStru1 := ("RF06")->(dbStruct())

			fr_Header := +;
			Padr("T"                             ,001)+;
			Padr(StrZero(frLinha,9)              ,009)
			FWRITE(nTerHdl,  fr_Header + CRLF )

			Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(RFcIndex+OrdBagExt())          //indice gerado
			RF06->(dbCloseArea())

		EndIf

		MsgINFO("O arquivo poderá ser acessado em:"+ df_ArqEtq)

		//Gabriel Mafioletti - Ticket 2254 - Ajustar Layout do Ticket
	ElseIf nRadMenu1 == 6

		aDados2 := {}

		dg_TpLc := "  "
		If cEmpAnt == "01"
			dg_TpLc := "FI"
			dg_CNPJ := Right(Alltrim(SM0->M0_CGC),3)
		ElseIf cEmpAnt $ "05,12"
			dg_TpLc := "PT"
			dg_CNPJ := "160" //Incesa Sempre deverá ser 160
		ElseIf cEmpAnt == "13"
			dg_TpLc := "  "
			dg_CNPJ := ""
		ElseIf cEmpAnt == "14"  //2014.06.26 - Julio, inclusao VITCER
			dg_TpLc := "PT"
			dg_CNPJ := "123"
		EndIf

		A0026 := " SELECT '%' INI,
		A0026 += "        RA_NOME NOME_DO_USUARIO,
		A0026 += "        RA_CIC CPF,
		A0026 += "        Convert(Char(10),convert(datetime, RA_NASC),103) DATA_NASCIMENTO,
		A0026 += "        RA_SEXO CODIGO_SEXO,
		A0026 += "        SUM(ZS_VALOR) VALOR,
		A0026 += "        '"+dg_TpLc+"' TP_LOCAL,
		A0026 += "        '"+dg_CNPJ+"' LOCAL_ENTREGA,
		A0026 += "        ZS_MAT MATRICULA,
		A0026 += "        '%' FIM
		A0026 += "   FROM (SELECT ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01, SUM(ZS_VALOR) ZS_VALOR, RA_SEXO
		A0026 += "           FROM "+RetSqlName("SZS")+" SZS
		A0026 += "          INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0026 += "                               AND RA_MAT = ZS_MAT
		A0026 += "                               AND SRA.D_E_L_E_T_ = ' '
		A0026 += "          INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'
		A0026 += "                               AND CTH_CLVL = RA_CLVL
		A0026 += "                               AND CTH.D_E_L_E_T_ = ' '
		A0026 += "          WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0026 += "            AND ZS_MESANO = '"+MV_PAR01+"'
		A0026 += "            AND ZS_BENEF IN ('2','3')
		A0026 += "            AND ZS_MAT <> '      '
		A0026 += "            AND ZS_VALOR <> 0
		A0026 += "            AND SZS.D_E_L_E_T_ = ' '
		A0026 += "          GROUP BY ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01, RA_SEXO
		A0026 += "        ) AS TABL
		A0026 += "  WHERE ZS_VALOR > 0
		A0026 += "  GROUP BY ZS_MAT,
		A0026 += "           RA_NOME,
		A0026 += "           RA_CIC,
		A0026 += "           RA_NASC,
		A0026 += "           RA_SEXO

		TcQuery A0026 New Alias "A026"
		dbSelectArea("A026")
		dbGoTop()
		ProcRegua(RecCount())

		While !Eof()

			IncProc("Aguarde! Apurando dados...")

			aAdd(aDados2, { Alltrim(A026->INI),;
			Alltrim(A026->NOME_DO_USUARIO),;
			Alltrim(A026->CPF),;
			Alltrim(A026->DATA_NASCIMENTO),;
			Alltrim(A026->CODIGO_SEXO),;
			Alltrim(Transform(A026->VALOR   ,"@E 999,999,999.99")),;
			Alltrim(A026->TP_LOCAL),;
			Alltrim(A026->LOCAL_ENTREGA),;
			Alltrim(A026->MATRICULA),;
			Alltrim(A026->FIM)} )

			dbSelectArea("A026")
			dbSkip()
		End
		aStru1 := ("A026")->(dbStruct())
		A026->(dbCloseArea())

		df_ArqEtq := Substr(SM0->M0_NOME,1,3)+"_"+strzero(seconds()%3500,5)

		aDados2 := aSort(aDados2,,,{|x,y| x[9] < y[9] })
		fGrvCsv(aDados2, aStru1, df_ArqEtq )


	ElseIf nRadMenu1 == 7
		// TICKET (devem ser somados os dois Comprocard´s + os funcioanrios com TICKET)
		// Em 01/12/14 foi incluída a opção de somar VisaVale + Ticket1 + Ticket2 devido problema com a ALELO.
		*********************************************************************
		cTpProduto   := "T"
		cProduto     := "A"
		cCodContrato := ""
		If 	   cEmpAnt == "01"
			cCodContrato  := "1735543476"
		ElseIf cEmpAnt == "05"
			cCodContrato  := "1735543485"
		ElseIf cEmpAnt == "14"
			cCodContrato  := "1681770014"
		EndIf
		//...REGISTRO HEADER DO ARQUIVO DE PEDIDO
		fr_Header := +;							//Nome do Campo				Ini	Fim	Tam Tp	Descricão
		Padr("LSUP5"					,005)+; //Tipo de registro			001	005	005 X	LSUP5
		Padr("TICKET"					,008)+; //Usuário do sistema		006	013	008 X	Nome  do  usuário  que	gerou  o arquivo de Pedidos
		Replicate(" "					, 11)+; //Reservado					014	024	011 X	branco.
		Padr(GravaData(dDataBase,.F.,5) ,008)+; //Data da geracão do pedido	025	032	008 N	Data no formato "AAAAMMDD"
		Padr(STRTRAN(Time(),":",".")	,008)+;	//Hora geracão do pedido	033	040	008 X	Hora no formato "HH.MM.SS"
		Padr("LAYOUT-16/06/2014"		,017)+; //Reservado					041	057	017 X	Fixo "LAYOUT-16/06/2014"
		Replicate(" "					,107)	//Espaco reservado			058	165	107 X	branco.
		FWRITE(nTerHdl,  fr_Header + CRLF )		//

		frLinha := 1
		//...TRE / TAE - REGISTRO HEADER
		fr_Header1 := +;						//Nome do Campo				Ini	Fim	Tam Tp	Descricão
		Padr(cTpProduto					,001)+; //Tipo de Produto/Sequencia	001	001	001 X	Fixo "T"
		Padr(cProduto					,001)+; //Produto					002	002	001 X	A = Alimentacão	/ R = Restaurante
		Padr("02"						,002)+; //Fixo						003	004	002 X	Fixo "02"
		Padr("0"						,001)+; //Tipo de Registro			005	005	001 X	"0"
		Padr(cProduto					,001)+; //Produto					006	006	001 X	A = Alimentacão	/ R = Restaurante
		Padr(cCodContra					,010)+; //Codigo do Cliente			007	016	010 9	Codigo de contrato do cliente
		Padr(Substr(SM0->M0_NOME,1,24)	,024)+; //Nome da Empresa			017	040	024 X	Nome  da  empresa	cliente	que será personalizado no cartão
		Replicate(" "					,  6)+;	//Reservado					041	046	006 X	Preencher com espacos "  "
		Padr(GravaData(dDataBase,.F.,8) ,008)+; //Data do Pedido			047	054	008 9	Formato AAAAMMDD
		Padr(GravaData(dDataBase+3,.F.,8),008)+;//Data Liberacão Beneficio	055	062	008 9	Formato AAAAMMDD
		Padr("C"						,001)+; //Tipo do Pedido			063	063	001 X	Preencher com "C"
		Replicate(" "					, 16)+; //Reservado					064	079	016 X	Preencher com espacos em "	"
		Padr(Month(dDataBase)			,002)+; //Mes de Referencia			080	081	002 9	Mes de referencia do pedido
		Replicate( " "					, 19)+;	//Reservado					082	100	019 X	Preencher com espacos em "	"
		Padr("04"						,002)+;	//Tipo de Layout			101	102	002 X	Preencher com "04"
		Padr("33"						,002)+;	//Tipo do Cartão			103	104	002 X	33 = Magnético (TAE) / 34 = Magnético (TRE)
		Replicate(" "					, 48)+;	//Reservado					105	152	048 X	Preencher com espacos
		Padr("SUP   "					,006)+; //Origem					153	158	006 X	Preencher com "SUP"
		Padr(StrZero(frLinha,6)			,006)	//Sequencial				159	164	006 9	Numero sequencial para cada linha do arquivo. Formato	"999999", iniciando em ex.:	1a. linha = 000001 / 2a. linha = 000002 e assim  por diante.
		FWRITE(nTerHdl,  fr_Header1 + CRLF )	//

		frLinha += 1
		cUnidEnt := rtrim(SM0->M0_NOME) +" - "+SM0->M0_FILIAL
		cTipoEnd := SUBSTR(SM0->M0_ENDENT,1, AT(" ",SM0->M0_ENDENT))
		cEnd1 	 := Alltrim(SUBSTR(Alltrim(SM0->M0_ENDENT),AT(" ",SM0->M0_ENDENT), Len(Alltrim(SM0->M0_ENDENT))))
		cEnd	 := SubStr(cEnd1,1, AT(",",cEnd1)-1)
		cEndNum	 := Alltrim(SUBSTR(Alltrim(SM0->M0_ENDENT),AT(",",SM0->M0_ENDENT)+1,Len(Alltrim(SM0->M0_ENDENT))))
		//aEnd     := {}
		//aEnd     := FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)
		//...TRE / TAE - REGISTRO DE UNIDADEE ENTREGA
		fr_Header2 := +;						//Nome do Campo				Ini	Fim	Tam Tp	Descricão
		Padr(cTpProduto					,001)+; //Tipo de Produto/Sequencia	001	001	001 X	Fixo "T"
		Padr(cProduto					,001)+; //Produto					002	002	001 X	A = Alimentacão	/ R = Restaurante
		Padr("02"						,002)+; //Fixo						003	004	002 X	Fixo "02"
		Padr("2"						,001)+; //Tipo de Registro			005	005	001 X	"2"
		Padr(cUnidEnt					,026)+; //Nome da Unidade			006	031	026 X	Nome da Unidade
		Padr(cTipoEnd					,004)+; //Tp logradouro				032	035	004 X	Tipo de logradouro
		Padr(cEnd						,030)+; //Logradouro				036	065	030 X	Logradouro
		Padr(strzero(Val(cEndNum),6)	,006)+; //Numero					066	071	006 X	Numero
		Padr(SM0->M0_COMPENT			,010)+; //Complemento				072	081	010 X	Complemento
		Padr(SM0->M0_CIDENT				,025)+; //Municipio					082	106	025 X	Municipio
		Padr(SM0->M0_BAIRENT			,015)+; //Bairro					107	121	015 X	Bairro
		Padr(SUBSTR(SM0->M0_CEPENT,1,5)	,005)+; //CEP						122	126	005 9	CEP
		Padr(SM0->M0_ESTENT				,002)+; //Estado					127	128	002 X	Estado
		Padr(cUserName					,020)+; //Interlocutor				129	148	020 X	Interlocutor	responsável	pelo recebimento	do	pedido	na unidade
		Padr(SUBSTR(SM0->M0_CEPENT,6,3)	,003)+; //Complemento do CEP		149	151	003 9	Complemento do CEP
		Replicate(" "					,  7)+; //Reservado					152	158	007 X	Preencher com espacos
		Padr(StrZero(frLinha,6)			,006)	//Sequencial				159	164	006 9	Numero sequencial para cada linha do arquivo. Formato	"999999", dar continuidade ao Registro anterior.
		FWRITE(nTerHdl,  fr_Header2 + CRLF )	//

		wt_CntTotReg := 0
		wt_SomaTotal := 0

		/*
		A0026 := " SELECT ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CC, CTT_DESC01, SUM(ZS_VALOR) ZS_VALOR
		A0026 += "   FROM "+RetSqlName("SZS")+" SZS
		A0026 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0026 += "                       AND RA_MAT = ZS_MAT
		A0026 += "                       AND SRA.D_E_L_E_T_ = ' '
		A0026 += "  INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"'
		A0026 += "                       AND CTT_CUSTO = RA_CC
		A0026 += "                       AND CTT.D_E_L_E_T_ = ' '
		A0026 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0026 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		If nRadMenu1 == 6
		A0026 += "    AND ZS_BENEF IN('2','3')
		Else
		A0026 += "    AND ZS_BENEF IN('2','3','1')
		EndIf
		A0026 += "    AND ZS_MAT <> '      '
		A0026 += "    AND ZS_VALOR <> 0
		A0026 += "    AND SZS.D_E_L_E_T_ = ' '
		A0026 += "  GROUP BY ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CC, CTT_DESC01
		*/
		A0026 := " SELECT ZS_MAT,
		A0026 += "        RA_NOME,
		A0026 += "        RA_CIC,
		A0026 += "        RA_NASC,
		A0026 += "        RA_CLVL,
		A0026 += "        CTH_DESC01,
		A0026 += "        SUM(ZS_VALOR) ZS_VALOR
		A0026 += "   FROM (SELECT ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01, SUM(ZS_VALOR) ZS_VALOR
		A0026 += "           FROM "+RetSqlName("SZS")+" SZS
		A0026 += "          INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
		A0026 += "                               AND RA_MAT = ZS_MAT
		A0026 += "                               AND SRA.D_E_L_E_T_ = ' '
		A0026 += "          INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'
		A0026 += "                               AND CTH_CLVL = RA_CLVL
		A0026 += "                               AND CTH.D_E_L_E_T_ = ' '
		A0026 += "          WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0026 += "            AND ZS_MESANO = '"+MV_PAR01+"'
		A0026 += "            AND ZS_BENEF IN('2','3')
		A0026 += "            AND ZS_MAT <> '      '
		A0026 += "            AND ZS_VALOR <> 0
		A0026 += "            AND SZS.D_E_L_E_T_ = ' '
		A0026 += "          GROUP BY ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01
		If nRadMenu1 == 7
			A0026 += "          UNION ALL
			A0026 += "         SELECT ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01, SUM(ZS_VALOR) ZS_VALOR
			A0026 += "           FROM "+RetSqlName("SZS")+" SZS
			A0026 += "          INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'
			A0026 += "                               AND RA_MAT = ZS_MAT
			A0026 += "                               AND SRA.D_E_L_E_T_ = ' '
			A0026 += "          INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'
			A0026 += "                               AND CTH_CUSTO = RA_CLVL
			A0026 += "                               AND CTH.D_E_L_E_T_ = ' '
			A0026 += "          WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
			A0026 += "            AND ZS_MESANO = '"+MV_PAR01+"'
			A0026 += "            AND ZS_BENEF IN('1')
			A0026 += "            AND ZS_MAT <> '      '
			A0026 += "            AND ZS_VALOR <> 0
			A0026 += "            AND SZS.D_E_L_E_T_ = ' '
			A0026 += "          GROUP BY ZS_MAT, RA_NOME, RA_CIC, RA_NASC, RA_CLVL, CTH_DESC01
		EndIf
		A0026 += "        ) AS TABL
		A0026 += "  WHERE ZS_VALOR > 0
		A0026 += "  GROUP BY ZS_MAT,
		A0026 += "           RA_NOME,
		A0026 += "           RA_CIC,
		A0026 += "           RA_NASC,
		A0026 += "           RA_CLVL,
		A0026 += "           CTH_DESC01

		TcQuery A0026 New Alias "A026"
		dbSelectArea("A026")
		dbGoTop()
		ProcRegua(RecCount())

		While !Eof()


			IncProc("Aguarde! Apurando dados...")

			If A026-> ZS_VALOR > 0	 							//...TRE / TAE - REGISTRO DE FUNCIONARIOS

				frLinha ++

				fr_Detalhe := +;					 			//Nome do Campo				Ini	Fim	Tam Tp	Descricão
				Padr(cTpProduto							,001)+; //Tipo de Produto/Sequencia	001	001	001 X	Fixo "T"
				Padr(cProduto							,001)+; //Produto					002	002	001 X	A = Alimentacão	/ R = Restaurante
				Padr("02"								,002)+; //Fixo						003	004	002 X	Fixo "02"
				Padr("3"								,001)+; //Tipo de Registro			005	005	001 X	"3"
				Padr(A026->CTH_DESC01					,026)+; //Departamento				006 031	026 X	Codigo do departamento
				Padr("0" + A026->RA_CIC					,012)+; //Identificacão				032 043	012 9	Identificacão do funcionário na	Ticket. Esse campo é chave para geracão de cartões e nunca poderá ser utilizado para outro funcionário no mesmo	CNPJ. Obrigatorio utilizacão do CPF, pois este numero é unico para cada	individuo. Ponto de atencão: caso sua empresa já possua cartões emitidos e esteja mudando de tecnologia (E-ticket,SUP, etc.), verificar qual informacão foi enviada nesse campo nos edidos anteriores, a informacão deve ser igual para não ocorrer emissão de novos cartões.
				Padr(GRAVADATA(StoD(A026->RA_NASC),.F.,5),008)+;//Nascimento Funcionário	044 051	008 X	Formato DDMMAAAA
				Replicate(" "							, 18)+; //Reservado					052 069	018 X	Preencher com espacos
				Padr(rtrim(SM0->M0_NOME) +" - "+SM0->M0_FILIAL	,026)+; //Nome da Unidade			070 095	026 X	Nome da Unidade
				Padr("00101"							,005)+; //Fixo						096 100	005 9	Preencher com "00101"
				Padr(Transform(StrZero(A026->ZS_VALOR*100,9),"@R 999999999"),009)+; //Valor	101 109	009 9	Valor do beneficio com 7 inteiros e 2 casas decimais
				Padr(cProduto							,001)+; //Produto					110 110	001 X	"A" = Alimentacão	/ "R" = Restaurante
				Padr("E"								,001)+; //Fixo						111 111	001 X	"E" = Eletrônico
				Padr(A026->RA_NOME						,030)+; //Nome do Funcionário		112 141	030 X	Nome do funcionário
				Replicate(" "							, 17)+; //Reservado					142 158	017 X	Preencher com espacos
				Padr(StrZero(frLinha,6)					,006)	//Sequencial				159	164	006 9	Numero sequencial para cada linha do arquivo. Formato	"999999", dar continuidade ao Registro anterior.
				FWRITE(nTerHdl,  fr_Detalhe + CRLF )			//

				wt_CntTotReg ++
				wt_SomaTotal += A026->ZS_VALOR
			EndIf

			dbSelectArea("A026")
			dbSkip()
		End
		A026->(dbCloseArea())

		//...TRE / TAE - REGISTRO TRAILLER
		frLinha ++
		fr_Trailler := +;					 									//Nome do Campo				Ini	Fim	Tam Tp	Descricão
		Padr(cTpProduto													,001)+; //Tipo de Produto/Sequencia	001	001	001 X	Fixo "T"
		Padr(cProduto													,001)+; //Produto					002	002	001 X	A = Alimentacão	/ R = Restaurante
		Padr("02"														,002)+; //Fixo						003	004	002 X	Fixo "02"
		Padr("9"														,001)+; //Tipo de Registro			005	005	001 X	"9"
		Padr(Transform(StrZero(wt_CntTotReg,8),"@R 99999999")           ,008)+; //Total de Funcionários		006 013	008 9	Quantidade	de	registros	tipo  3	(Funcionários)
		Padr(Transform(StrZero(wt_SomaTotal*100,14),"@R 99999999999999"),014)+; //Valor Total				014 027	014 9	Somatoria	do	valor	do	pedido,	com 2 casas decimais
		Replicate(" "													,131)+; //Reservado					028 158	131 X	Preencher com espacos
		Padr(StrZero(frLinha,6)											,006)	//Sequencial				159 164	006 9	Numero sequencial para cada linha do arquivo. Formato	"999999",  dar continuidade ao Registro anterior.
		FWRITE(nTerHdl,  fr_Trailler + CRLF )								    //
		//...REGISTRO TRAILLER DO ARQUIVO DE PEDIDO
		fr_TraillerArq := +;													//Nome do Campo				Ini Fim	Tam Tp	Descricão
		Padr("LSUP9"													,005)+; //Tipo de registro			001 005	005 X	"LSUP9"
		Padr("00000002"													,008)+; //Quantidade de Header		006 013	008 9	Somatorio	total	dos	registros Header’s do	arquivo de pedidos, formato "99999999"
		Padr("00000002"													,008)+; //Quantidade de Trailler	014 021	008 9	Somatorio	total	dos	registros Trailler’s do	arquivo de pedidos. Formato "99999999"
		Padr(Transform(StrZero(wt_CntTotReg,8),"@R 99999999")           ,008)+; //Quant. registros arquivo 	022 029	008 9	Somatorio total dos registros do arquivo   de	pedidos,	formato "99999999",  exceto  header’s  e trailler’s
		Replicate(" "													,277) 	//Espaco Reservado			030 306	277 X	brancos
		FWRITE(nTerHdl,  fr_TraillerArq + CRLF )								    //

		MsgINFO( "O arquivo poderá ser acessado em :      "+df_ArqEtq )

	EndIf

	FCLOSE(nTerHdl)

Return


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec(xf_Cab, nOpcMnu)

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025
	sw_Perid := "Periodo: " + MesExtenso(Substr(MV_PAR01,5,2)) + " de " + Substr(MV_PAR01,1,4)
	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,80)                                            ,oFont14)
	oPrint:Say  (nRow1+10 ,2000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,2150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,2000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,2150 ,dtoc(dDataBase)                                            ,oFont8)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(sw_Perid,135)                                         ,oFont10)
	nRow1 += 150
	oPrint:Line (nRow1, 050, nRow1, 2400)

	nRow1 += 050
	If xf_Cab == 1

		xf_Titu := ""
		xf_Titu += Padr("Cl Valor", 009) + Space(1)
		xf_Titu += Padr("Matricula",006) + Space(1)
		xf_Titu += Padr("Colaborador", 030) + Space(1)
		xf_Titu += Padl("Valor", 014) + Space(1)	
		xf_Titu += Padl("Taxa", 014) + Space(1)
		xf_Titu += Padl("Total", 014) + Space(1)
		xf_Titu += Padr("Descrição", 100) + Space(1)

	Else

		xf_Titu := ""
		xf_Titu += Padr(Space(1), 020) + Space(1)
		xf_Titu += Padr("Cl.Valor", 009) + Space(1)
		xf_Titu += Padl("Valor", 014) + Space(1)

		If nOpcMnu == 1 .Or. nOpcMnu == 2
			xf_Titu += Padl("Vlr Desc.", 014) + Space(1)
		EndIf

		xf_Titu += Padl("Taxa", 014) + Space(1)
		xf_Titu += Padl("Total" , 014) + Space(1)
		xf_Titu += Padl("Percent", 014) + Space(1)

	EndIf

	oPrint:Say(nRow1, 0050, xf_Titu, oFont10)
	oPrint:Line(nRow1+35, 050, nRow1+35, 2400)
	nRow1 += 075

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (3400, 050, 3400, 2400)
	oPrint:Say  (3400+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (3400+30 ,1850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrvCsv  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 15/03/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrvCsv(aColunas,ahead,cArq)

	Local ny
	Local cDirDocs   := "\P10\DOCTEMP" //MsDocPath() // Alterado em 21/07/15 porque estava gerando problema com o BancoDeConhecimento
	Local aStru      := {}
	Local cArquivo   := CriaTrab(,.F.)
	Local cPath      := AllTrim(GetTempPath())
	Local nHandle
	Local cCrLf      := Chr(13) + Chr(10)
	Local nX
	If ahead == nil
		Return
	Endif
	If cArq <> nil
		cArquivo := cArq
	Endif
	aStru := ahead
	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".csv",0)
	If nHandle > 0
		// Grava o cabecalho do arquivo
		IncProc("Aguarde! Gerando arquivo de integração...")
		aEval(aStru, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha
		For nX := 1 to Len(aColunas)
			IncProc("Aguarde! Gerando arquivo de integração...")
			For nY := 1 to Len(aStru)
				fWrite(nHandle, Transform(aColunas[nX,nY], "@!" ) + IIf(nY < Len(aStru), ";", "") )
			Next nY
			fWrite(nHandle, cCrLf ) // Pula linha
		Next nX

		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".csv" , cPath, .T. )
		cNewPath := "c:\temp"
		// cNewPath := "c:\temp\"
		If !lIsDir( cNewPath )
			MakeDir( cNewPath )
		EndIf
		// CpyS2T(cDirDocs+"\"+cArquivo+".csv", cNewPath+cArquivo+".csv")
		CpyS2T(cDirDocs+"\"+cArquivo+".csv", cNewPath)
		MsgINFO( "O arquivo poderá ser acessado em :      "+cNewPath+cArquivo+".csv"  )

	Else

		MsgAlert( "Falha na criação do arquivo" )

	Endif

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Ano e Mes           ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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


Static Function fComVal(cMesAno, cMat, cNome, dDatPag, cBenef, nTxBase, nValor)
	Local cMesAnt := SubStr(dToS(sToD(cMesAno + "01") - 1), 1, 6)
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local nValAnt := 0

	// Somente avalia se o valor calculado for negativo
	If nValor < 0 .And. cBenef $ "2/3"

		// Soma valores do periodo anterior		
		cSQL := " SELECT SUM(ZS_VALOR) ZS_VALOR "
		cSQL += " FROM " + RetSqlName("SZS")
		cSQL += " WHERE ZS_FILIAL = " + ValToSQL(xFilial("SZS"))
		cSQL += " AND ZS_MESANO = " + ValToSQL(cMesAnt)
		cSQL += " AND ZS_MAT = " + ValToSQL(cMat)
		cSQL += " AND ZS_BENEF IN ('2' , '3') "
		cSQL += " AND D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		If (cQry)->ZS_VALOR > 0

			// Retorna valor do beneficio no mes anterior
			nValAnt := fValAnt(cMesAnt, cMat, cBenef)

			// Somente adiciona compensacao de valor se for negativo
			If nValAnt < 0

				RecLock("SZS", .T.)

				SZS->ZS_FILIAL := xFilial("SZS")
				SZS->ZS_MESANO := cMesAno
				SZS->ZS_MAT := cMat
				SZS->ZS_NOME := cNome
				SZS->ZS_DTPAG := dDatPag
				SZS->ZS_BENEF := cBenef
				SZS->ZS_TXBASE := nTxBase
				SZS->ZS_VALOR := Abs(nValAnt)
				SZS->ZS_OBS := "Cp=" + cMesAnt

				SZS->(MsUnLock())

			EndIf

		EndIf

	EndIf

Return()


Static Function fValAnt(cMesAnt, cMat, cBenef)

	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()

	// Busca valor do periodo anterior		
	cSQL := " SELECT SUM(ZS_VALOR) ZS_VALOR "
	cSQL += " FROM " + RetSqlName("SZS")
	cSQL += " WHERE ZS_FILIAL = " + ValToSQL(xFilial("SZS"))
	cSQL += " AND ZS_MESANO = " + ValToSQL(cMesAnt)
	cSQL += " AND ZS_MAT = " + ValToSQL(cMat)
	cSQL += " AND ZS_BENEF = " + ValToSQL(cBenef)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->ZS_VALOR

	(cQry)->(DbCloseArea())

Return(nRet)

Static Function fComValD(cMesAno, cMat, cNome, dDatPag, cBenef, nTxBase, nValor, nValBen)

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local dDtDem := Posicione("SRA", 1, xFilial("SRA") + cMat, "RA_DEMISSA")
	Local nVal := 0

	// Somente avalia se o valor calculado for positivo
	If !Empty(dDtDem) .And. nValor > 0 .And. cBenef $ "2/3"

		// Soma valores do periodo anterior		
		cSQL := " SELECT SUM(ZS_VALOR) ZS_VALOR "
		cSQL += " FROM " + RetSqlName("SZS")
		cSQL += " WHERE ZS_FILIAL = " + ValToSQL(xFilial("SZS"))
		cSQL += " AND ZS_MESANO = " + ValToSQL(cMesAno)
		cSQL += " AND ZS_MAT = " + ValToSQL(cMat)
		cSQL += " AND ZS_BENEF IN ('2' , '3') "
		cSQL += " AND D_E_L_E_T_ = '' "

		TcQuery cSQL New Alias (cQry)

		If (cQry)->ZS_VALOR > 0 .And. dDtDem >= FirstDate(sToD(sh_DtFin)) .And. dDtDem <= LastDate(sToD(sh_DtFin))

			If dDtDem < sToD(sh_DtFin)

				nVal := (cQry)->ZS_VALOR * (-1)

			ElseIf dDtDem > sToD(sh_DtFin)

				nVal := (nValBen / 30) * (dDtDem - sToD(sh_DtFin))

				nVal := nVal - (cQry)->ZS_VALOR

			EndIf

			RecLock("SZS", .T.)

			SZS->ZS_FILIAL := xFilial("SZS")
			SZS->ZS_MESANO := cMesAno
			SZS->ZS_MAT := cMat
			SZS->ZS_NOME := cNome
			SZS->ZS_DTPAG := dDatPag
			SZS->ZS_BENEF := cBenef
			SZS->ZS_TXBASE := nTxBase
			SZS->ZS_VALOR := nVal
			SZS->ZS_OBS := "Cp=Demissão"

			SZS->(MsUnLock())

		EndIf

	EndIf

Return()

Static Function GERALIM(nRadMenu1)

	Local nCount := 0

	A0001 := " SELECT ZS_MAT
	A0001 += "   FROM " + RetSqlName("SZS")
	A0001 += "  WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
	A0001 += "    AND ZS_MESANO = '"+MV_PAR01+"'
	A0001 += "    AND ZS_BENEF IN ('1','2','3')
	A0001 += "    AND ZS_PAGAR = ' '
	A0001 += "    AND ZS_VALOR > 0
	A0001 += "    AND D_E_L_E_T_ = ' '
	TcQuery A0001 New Alias "A001"
	A001->(dbGoTop())

	A0002 := " SELECT RCH_DTPAGO,RCH_DTFECH FROM RCH010
	A0002 += " WHERE RCH_PER = '"+MV_PAR01+"'
	A0002 += " AND RCH_ROTEIR = 'FOL'
	TcQuery A0002 New Alias "A002"
	dbSelectArea("A002")
	A002->(dbGoTop())

	IF A002->RCH_DTFECH > '        ' .AND. !MSGYESNO("Periodo já se encontra fechado. Deseja continuar?","Periodo Fechado")
		Return
	ENDIF

	DBSELECTAREA("SRC")
	SRC->(DBSETORDER(1))

	DBSELECTAREA("SRA")
	SRA->(DBSETORDER(1))

	WHILE !A001->(EOF())

		xl_Mat    := A001->ZS_MAT
		SRA->(DBSEEK(XFILIAL()+xl_Mat))

		IF (SELECT("A003") <> 0)
			A003->(dbCloseArea())
		ENDIF

		A0003 := "    SELECT ROUND(SUM(ZS_VALOR),2) AS nValor
		A0003 += "    FROM " + RetSqlName("SZS")
		A0003 += "    WHERE ZS_FILIAL = '"+xFilial("SZS")+"'
		A0003 += "    AND ZS_MESANO = '"+MV_PAR01+"'
		A0003 += "    AND ZS_BENEF IN ('1','2','3')
		A0003 += "    AND ZS_PAGAR = ' '
		A0003 += "    AND ZS_VALOR > 0
		A0003 += "    AND ZS_MAT = '"+xl_Mat+"'
		A0003 += "    AND D_E_L_E_T_ = ' '
		TcQuery A0003 New Alias "A003"

		nVal := A003->nValor

		IF ALLTRIM(DTOS(SRA->RA_DEMISSA)) == '' .AND. nVal > 0 .AND. (xl_Mat <> '      ' .OR. xl_Mat <> '000000')

			DBSELECTAREA("RGB")

			IF RGB->(DBSEEK(XFILIAL()+xl_Mat+'628'))

				RECLOCK("RGB",.F.)

				DBDELETE()

				MSUNLOCK()	

			ENDIF

			RECLOCK("RGB",.T.)

			RGB_FILIAL := XFILIAL()
			RGB_MAT    := xl_Mat
			RGB_PD     := "628"
			RGB_PERIOD := MV_PAR01
			RGB_SEMANA := "01"
			RGB_SEQ    := ''
			RGB_CONVOC := ''
			RGB_ROTEIR := "FOL"
			RGB_VALOR  := nVal
			RGB_PROCES := "00001"
			RGB_CC     := ALLTRIM(SRA->RA_CC)
			RGB_TIPO1  := "V"
			RGB_TIPO2  := "I"
			RGB_CODFUN := ALLTRIM(SRA->RA_CODFUNC)
			RGB_DEPTO  := ALLTRIM(SRA->RA_DEPTO)
			RGB_ITEM   := "GPE000000"
			RGB_CLVL   := ALLTRIM(SRA->RA_CLVL)
			RGB_ROTORI := "VAL"

			MSUNLOCK()	

			//|PONTIN Facile - Gravar também na SRC quando integrado após cálculo |
			If SuperGetMV("MV_YGERSRC",.F.,.T.)

				DBSELECTAREA("SRC")

				IF SRC->(DBSEEK(XFILIAL()+xl_Mat+'628'))

					RECLOCK("SRC",.F.)

					DBDELETE()

					MSUNLOCK()	

				ENDIF

				RECLOCK("SRC",.T.)

				SRC->RC_FILIAL 	:= XFILIAL()
				SRC->RC_MAT    	:= xl_Mat
				SRC->RC_PD     	:= "628"
				SRC->RC_PERIODO := MV_PAR01
				SRC->RC_DATA 		:= StoD(A002->RCH_DTPAGO)
				SRC->RC_DTREF 	:= LastDate( dDataBase )
				SRC->RC_SEMANA 	:= "01"
				SRC->RC_SEQ    	:= ''
				SRC->RC_CONVOC 	:= ''
				SRC->RC_ROTEIR 	:= "FOL"
				SRC->RC_VALOR  	:= nVal
				SRC->RC_PROCES 	:= "00001"
				SRC->RC_CC     	:= ALLTRIM(SRA->RA_CC)
				SRC->RC_TIPO1  	:= "V"
				SRC->RC_TIPO2  	:= "I"
				SRC->RC_DEPTO  	:= ALLTRIM(SRA->RA_DEPTO)
				SRC->RC_ITEM   	:= "GPE000000"
				SRC->RC_CLVL   	:= ALLTRIM(SRA->RA_CLVL)
				SRC->RC_CODB1T 	:= "94"

				MSUNLOCK()	

			EndIf

			nCount := nCount + 1 

		ENDIF

		A001->(DBSKIP())

	ENDDO

	A001->(dbCloseArea())
	A002->(dbCloseArea())
	A003->(dbCloseArea())

	Alert(cValToChar(nCount) + " registros processados.")

Return