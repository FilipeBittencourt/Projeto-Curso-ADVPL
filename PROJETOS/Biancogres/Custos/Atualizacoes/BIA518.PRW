#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA518
@author Marcos Alberto Soprani
@since 09/09/11
@version 1.0
@description Custos unitário para previsto ajustado BPC - SAP
@obs Em 08/03/17... Por Marcos Alberto Soprani... Revisado
@type function
/*/

/*/{Protheus.doc} BIA518
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BIA518()

	dbSelectArea("SX2")
	dbSeek("Z56")

	If !cEmpAnt $ "01/06/14"

		MsgALERT("A empresa " + cEmpAnt + " não está preparada para este processamento!!! Necessário adequar o sistema.", "BIA518")
		Return

	EndIf

	cCadastro := Upper(Alltrim(SX2->X2_NOME))
	aRotina   := { {"Pesquisar"         ,"AxPesqui"	                         ,0,1},;
	{               "Visualizar"        ,"AxVisual"	                         ,0,2},;
	{               "Orcto p/ Ajustado" ,'ExecBlock("BIA518P",.F.,.F.)'       ,0,3},;
	{               "Verifica Faltante" ,'ExecBlock("BIA518V",.F.,.F.)'       ,0,4},;
	{               "Fora do MIX (2)"   ,'ExecBlock("BIA518W",.F.,.F.)'       ,0,5},;
	{               "Ct Unit Cogeração" ,'ExecBlock("BIA518T",.F.,.F.)'       ,0,6},;
	{               "Ct Quebra PP"      ,'ExecBlock("BIA518Q",.F.,.F.)'       ,0,7},;
	{               "Orct Sem Ajustado" ,'ExecBlock("BIA518O",.F.,.F.)'       ,0,8},;
	{               "Imprimir C.Unit  " ,'ExecBlock("BIA518I",.F.,.F.)'       ,0,9} }

	dbSelectArea(SX2->X2_CHAVE)
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,SX2->X2_CHAVE)

	dbSelectArea(SX2->X2_CHAVE)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518P  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 12.02.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Apanha os valores orçados para calculo do Previsto Ajustado¦¦¦
¦¦¦          ¦ A partir do unitário previsto para orçamento - tabela Z50  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518P()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA518P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR02)
		Return
	endif

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA518",fPerg)

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XP001 += "   FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XP001 += "  WHERE Z56_FILIAL = '" + xFilial("Z56") + "' " "
	XP001 += "    AND Z56_DATARF BETWEEN '" + Substr(dtos(MV_PAR02),1,4) + "0101' AND '" + Substr(dtos(MV_PAR02),1,4) + "1231' "
	XP001 += "    AND Z56.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " DELETE Z56 "
	ZP003 += "   FROM " + RetSqlName("Z56") + " Z56 "
	ZP003 += "  WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	ZP003 += "    AND Z56_DATARF BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "'
	ZP003 += "    AND Z56_SEQUEN = '" + msSequenc + "'
	ZP003 += "    AND D_E_L_E_T_ = ' '
	U_BIAMsgRun("Aguarde... Zerando valores...",,{|| TCSQLExec(ZP003)})

	QY004 := " WITH PRODMES AS (SELECT 
	If cEmpAnt == "01" 
		QY004 += "                         SUBSTRING(D3_COD,1,7) REFEREN,
	ElseIf cEmpAnt == "06"
		QY004 += "                         D3_COD REFEREN,
	ElseIf cEmpAnt == "14"
		QY004 += "                         SUBSTRING(D3_COD,1,7) REFEREN,
	EndIf
	QY004 += "                         D3_COD,
	QY004 += "                         D3_TIPO,
	QY004 += "                         SUM(D3_QUANT) QTDPROD
	QY004 += "                    FROM " + RetSqlName("SD3") + " SD3(NOLOCK)
	QY004 += "                   INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'
	QY004 += "                                        AND B1_COD = D3_COD
	QY004 += "                                        AND SB1.D_E_L_E_T_ = ' '
	QY004 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	QY004 += "                     AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "'
	If cEmpAnt == "01"
		QY004 += "                     AND D3_TIPO IN('PA','PP')
	ElseIf cEmpAnt == "06"
		QY004 += "                     AND D3_TIPO IN('MP', 'PI', 'PA')
	ElseIf cEmpAnt == "14"
		QY004 += "                     AND D3_TIPO IN('PA')
	EndIf
	QY004 += "                     AND D3_TM = '010'
	QY004 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	QY004 += "                     AND D3_ESTORNO = ' '
	QY004 += "                     AND SD3.D_E_L_E_T_= ' '
	QY004 += "                   GROUP BY SUBSTRING(D3_COD,1,7), D3_COD, D3_TIPO)
	QY004 += "  SELECT PRODMES.*, Z50.*
	QY004 += "   FROM PRODMES
	QY004 += "  INNER JOIN "+RetSqlName("Z50")+" Z50(NOLOCK) ON Z50_FILIAL = '"+xFilial("Z50")+"'
	If cEmpAnt == "01"
		QY004 += "                       AND SUBSTRING(Z50_COD,1,7) = REFEREN
	ElseIf cEmpAnt == "06"
		QY004 += "                       AND Z50_COD = REFEREN
	ElseIf cEmpAnt == "14"
		QY004 += "                       AND SUBSTRING(Z50_COD,1,7) = REFEREN
	EndIf
	QY004 += "                       AND Z50_VERSAO = '" + MV_PAR04 + "'
	QY004 += "                       AND Z50_REVISA = '" + MV_PAR05 + "'
	QY004 += "                       AND Z50_ANOREF = '" + MV_PAR06 + "'
	QY004 += "                       AND Z50_DATARF = '" + dtos(MV_PAR01) + "'
	QY004 += "                       AND Z50_M" + Substr(dtos(MV_PAR03),5,2) + " <> 0
	QY004 += "                       AND Z50.D_E_L_E_T_ = ' '
	QY004 += "  INNER JOIN "+RetSqlName("CT1")+" CT1(NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"'
	QY004 += "                       AND CT1_CONTA = Z50_CONTA
	QY004 += "                       AND CT1.D_E_L_E_T_ = ' '
	QY004 += "  INNER JOIN "+RetSqlName("Z29")+" Z29(NOLOCK) ON Z29_FILIAL = '"+xFilial("Z29")+"'
	If cEmpAnt == "01"
		QY004 += "                       AND Z29_COD_IT = CT1_YITCUS
		QY004 += "                       AND Z29_APLIC = D3_TIPO
	ElseIf cEmpAnt == "06"
		QY004 += "                       AND Z29_COD_IT = Z50_ITCUS
		QY004 += "                       AND Z29_APLIC = D3_TIPO
	ElseIf cEmpAnt == "14"
		QY004 += "                       AND Z29_COD_IT = CT1_YITCUS
	EndIf
	QY004 += "                       AND Z29.D_E_L_E_T_ = ' '
	QY004 += "  ORDER BY D3_COD, Z50_CONTA
	QYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QY004),'QY04',.T.,.T.)
	dbSelectArea("QY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		dbSelectArea("Z56")
		dbSetOrder(1)
		If !dbSeek(xFilial("Z56") + QY04->Z50_DATARF + QY04->D3_COD + QY04->Z50_CONTA + QY04->Z50_ITCUS)
			Reclock("Z56",.T.)
			Z56->Z56_FILIAL := xFilial("Z56")
		Else
			Reclock("Z56",.F.)
		EndIf
		Z56->Z56_DATARF  := MV_PAR03
		Z56->Z56_COD     := QY04->D3_COD
		Z56->Z56_CONTA   := QY04->Z50_CONTA
		Z56->Z56_ITCUS   := QY04->Z50_ITCUS
		Z56->Z56_CTOTAL  := QY04->Z50_CTOTAL
		Z56->Z56_M01     := IIF(Substr(dtos(MV_PAR03),5,2) == "01", QY04->Z50_M01, 0)
		Z56->Z56_M02     := IIF(Substr(dtos(MV_PAR03),5,2) == "02", QY04->Z50_M02, 0)
		Z56->Z56_M03     := IIF(Substr(dtos(MV_PAR03),5,2) == "03", QY04->Z50_M03, 0)
		Z56->Z56_M04     := IIF(Substr(dtos(MV_PAR03),5,2) == "04", QY04->Z50_M04, 0)
		Z56->Z56_M05     := IIF(Substr(dtos(MV_PAR03),5,2) == "05", QY04->Z50_M05, 0)
		Z56->Z56_M06     := IIF(Substr(dtos(MV_PAR03),5,2) == "06", QY04->Z50_M06, 0)
		Z56->Z56_M07     := IIF(Substr(dtos(MV_PAR03),5,2) == "07", QY04->Z50_M07, 0)
		Z56->Z56_M08     := IIF(Substr(dtos(MV_PAR03),5,2) == "08", QY04->Z50_M08, 0)
		Z56->Z56_M09     := IIF(Substr(dtos(MV_PAR03),5,2) == "09", QY04->Z50_M09, 0)
		Z56->Z56_M10     := IIF(Substr(dtos(MV_PAR03),5,2) == "10", QY04->Z50_M10, 0)
		Z56->Z56_M11     := IIF(Substr(dtos(MV_PAR03),5,2) == "11", QY04->Z50_M11, 0)
		Z56->Z56_M12     := IIF(Substr(dtos(MV_PAR03),5,2) == "12", QY04->Z50_M12, 0)
		Z56->Z56_GMCD    := "S"
		Z56->Z56_SEQUEN  := msSequenc
		MsUnlock()

		dbSelectArea("QY04")
		dbSkip()

	End

	QY04->(dbCloseArea())
	Ferase(QYIndex+GetDBExtension())
	Ferase(QYIndex+OrdBagExt())

	oLogProc:LogFimProc()

	Aviso('BIA518', 'Processamento executado com sucesso (1)', {'Ok'} )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518T  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 12.02.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Uma espécie de BACALHAU para recuperar o custo unitário    ¦¦¦
¦¦¦          ¦ para COGERAÇÃO até que tenhamos uma definição clara do pro-¦¦¦
¦¦¦          ¦ cesso de valorização de orçamento / ajustado               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518T()

	MsgINFO("Rotina retirada de uso em 07/05/18")

	//Processa({|| RptTDetail()})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518Q  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.02.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atribui custo de quebra para formatos que possibilitam este¦¦¦
¦¦¦          ¦ item de custo, contudo esta informação somente tem utilida-¦¦¦
¦¦¦          ¦ de para o ajustado, uma vez que não vai para o custo orçado¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518Q()

	Processa({|| RptQDetail()})

Return

Static Function RptQDetail()

	cHInicio := Time()
	fPerg := "BIA518P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR03)
		Return
	endif

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA518",fPerg)

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XP001 += " WHERE Z56_DATARF BETWEEN '" + Substr(dtos(MV_PAR02),1,4) + "0101' AND '" + Substr(dtos(MV_PAR02),1,4) + "1231' "
	XP001 += "       AND Z56.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	xcTab := "\data\bkp_Marcos\quebra_pp"
	dbUseArea(.T.,,xcTab+".dtc","REF1",.F.)
	dbCreateIndex(xcTab+".idx","EMP+FORMATO+ANO",{||EMP+FORMATO+ANO })
	dbSelectArea("REF1")
	dbGoTop()

	RT004 := " SELECT DISTINCT Z56_COD "
	RT004 += "   FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	RT004 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	RT004 += "                       AND B1_COD = Z56_COD "
	RT004 += "                       AND B1_TIPO = 'PA' "
	RT004 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	RT004 += "  WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	RT004 += "    AND Z56_DATARF = '" + dtos(MV_PAR03) + "' "
	RT004 += "    AND Z56_SEQUEN = '" + msSequenc + "' "
	RT004 += "    AND Z56.D_E_L_E_T_ = ' ' "
	RTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT004),'RT04',.T.,.T.)
	dbSelectArea("RT04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		dbSelectArea("REF1")
		dbGoTop()
		If dbSeek(cEmpAnt+Substr(RT04->Z56_COD,1,2)+Substr(dtos(MV_PAR03),1,4))

			dbSelectArea("Z56")
			dbSetOrder(1)
			If !dbSeek(xFilial("Z56") + dtos(MV_PAR03) + RT04->Z56_COD + REF1->CONTA + REF1->ITCUS)
				Reclock("Z56",.T.)
				Z56->Z56_FILIAL := xFilial("Z56")
			Else
				Reclock("Z56",.F.)
			EndIf
			Z56->Z56_DATARF  := MV_PAR03
			Z56->Z56_COD     := RT04->Z56_COD
			Z56->Z56_CONTA   := REF1->CONTA
			Z56->Z56_ITCUS   := REF1->ITCUS
			Z56->Z56_CTOTAL  := &("REF1->M"+Substr(dtos(MV_PAR03),5,2))
			Z56->Z56_M01     := IIF(Substr(dtos(MV_PAR03),5,2) == "01", REF1->M01, 0)
			Z56->Z56_M02     := IIF(Substr(dtos(MV_PAR03),5,2) == "02", REF1->M02, 0)
			Z56->Z56_M03     := IIF(Substr(dtos(MV_PAR03),5,2) == "03", REF1->M03, 0)
			Z56->Z56_M04     := IIF(Substr(dtos(MV_PAR03),5,2) == "04", REF1->M04, 0)
			Z56->Z56_M05     := IIF(Substr(dtos(MV_PAR03),5,2) == "05", REF1->M05, 0)
			Z56->Z56_M06     := IIF(Substr(dtos(MV_PAR03),5,2) == "06", REF1->M06, 0)
			Z56->Z56_M07     := IIF(Substr(dtos(MV_PAR03),5,2) == "07", REF1->M07, 0)
			Z56->Z56_M08     := IIF(Substr(dtos(MV_PAR03),5,2) == "08", REF1->M08, 0)
			Z56->Z56_M09     := IIF(Substr(dtos(MV_PAR03),5,2) == "09", REF1->M09, 0)
			Z56->Z56_M10     := IIF(Substr(dtos(MV_PAR03),5,2) == "10", REF1->M10, 0)
			Z56->Z56_M11     := IIF(Substr(dtos(MV_PAR03),5,2) == "11", REF1->M11, 0)
			Z56->Z56_M12     := IIF(Substr(dtos(MV_PAR03),5,2) == "12", REF1->M12, 0)
			Z56->Z56_GMCD    := "S"
			Z56->Z56_SEQUEN  := msSequenc
			MsUnlock()

		EndIf

		dbSelectArea("RT04")
		dbSkip()

	End

	RT04->(dbCloseArea())
	Ferase(RTIndex+GetDBExtension())
	Ferase(RTIndex+OrdBagExt())

	REF1->(dbCloseArea())
	Ferase(xcTab+".idx")

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518V  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 12.02.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica os produtos que não estavam previstos no orçamento¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518V()

	Processa({|| Rpt2Detail()})

Return

Static Function Rpt2Detail()

	cHInicio := Time()
	fPerg := "BIA518P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR02)
		Return
	endif

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA518",fPerg)

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XP001 += " WHERE Z56_DATARF BETWEEN '" + Substr(dtos(MV_PAR02),1,4) + "0101' AND '" + Substr(dtos(MV_PAR02),1,4) + "1231' "
	XP001 += "       AND Z56.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	xtFalta  := .F.
	xtMensag := "Os produtos abaixo não possuem custo para cálculo do ajustado: " + CHR(10) + CHR(13) + CHR(10) + CHR(13)

	YQ007 := " SELECT D3_COD REFEREN "
	YQ007 += "   FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	YQ007 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	YQ007 += "                       AND B1_COD = D3_COD "
	YQ007 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	YQ007 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	YQ007 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR02) + "' AND '" + dtos(MV_PAR03) + "' "
	YQ007 += "    AND D3_TIPO IN('PA','PP','PS') "
	YQ007 += "    AND D3_TM = '010' "
	YQ007 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	YQ007 += "    AND NOT EXISTS (SELECT Z56_COD "
	YQ007 += "                      FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	YQ007 += "                     WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	YQ007 += "                       AND Z56_DATARF = '" + dtos(MV_PAR03) + "' "
	YQ007 += "                       AND SUBSTRING(Z56_COD,1,7) = SUBSTRING(D3_COD,1,7) "
	YQ007 += "                       AND Z56_SEQUEN = '" + msSequenc + "' "
	YQ007 += "                       AND D_E_L_E_T_ = ' ') "
	YQ007 += "    AND D3_ESTORNO = ' ' "
	YQ007 += "    AND SD3.D_E_L_E_T_= ' ' "
	YQ007 += "  GROUP BY D3_COD "
	YQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,YQ007),'YQ07',.T.,.T.)
	dbSelectArea("YQ07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + YQ07->REFEREN)

		xtFalta  := .T.
		xtMensag += Alltrim(YQ07->REFEREN) + " - " + Substr(SB1->B1_DESC, 1, 70) + CHR(10) + CHR(13)

		dbSelectArea("YQ07")
		dbSkip()

	End

	YQ07->(dbCloseArea())
	Ferase(YQIndex+GetDBExtension())
	Ferase(YQIndex+OrdBagExt())

	oLogProc:LogFimProc()

	If xtFalta

		xtMensag += CHR(10) + CHR(13)

		xtMensag += "Favor Verificar e cadastrar os custos unitários necessários!!!" + CHR(10) + CHR(13)

		Aviso('BIA518', xtMensag, {'Ok'} )

	Else

		Aviso('BIA518', 'Não foram encontrados produtos sem custo para cálculo do AJUSTADO!!!', {'Ok'} )

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518X  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 12.02.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza Custo para os produtos que estiverem fora do MIX  ¦¦¦
¦¦¦          ¦ a partir de outros produtos da mesma tipologia - somente   ¦¦¦
¦¦¦          ¦ alterando o esmalte                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518X()

	MsgINFO("Retirado de uso... em 24/02/16 às 14:31")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518O  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.08.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime o custo para avaliação antes de enviar para o SAP  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518O()

	Processa({|| RptDetB01()})

Return

Static Function RptDetB01()

	cHInicio := Time()
	fPerg := "BIA518P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR02)
		Return
	endif

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA518",fPerg)

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XP001 += " WHERE Z56_DATARF BETWEEN '" + Substr(dtos(MV_PAR02),1,4) + "0101' AND '" + Substr(dtos(MV_PAR02),1,4) + "1231' "
	XP001 += "       AND Z56.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())	

	SK007 := " WITH RAZAO AS (SELECT 'DEB' TIPO, "
	SK007 += "                       Z50_CONTA CONTA, "
	SK007 += "                       '' ITCUS, "
	SK007 += "                       SUM(Z50_M" + Substr(dtos(MV_PAR03),5,2) + ") VALOR "
	SK007 += "                  FROM " + RetSqlName("Z50") + " Z50(NOLOCK) "
	SK007 += "                 INNER JOIN " + RetSqlName("Z47") + " Z47(NOLOCK) ON Z47_FILIAL = '" + xFilial("Z47") + "' "
	SK007 += "                                      AND Z47_ANO = '" + Substr(dtos(MV_PAR03),1,4) + "' "
	SK007 += "                                      AND Z47_QTDM" + Substr(dtos(MV_PAR03),5,2) + " <> 0 "
	SK007 += "                                      AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(Z50_COD,1,7) "
	SK007 += "                                      AND Z47.D_E_L_E_T_ = ' ' "
	SK007 += "                 WHERE Z50_FILIAL = '" + xFilial("Z50") + "' "
	SK007 += "                   AND Z50_VERSAO = '" + MV_PAR04 + "'
	SK007 += "                   AND Z50_REVISA = '" + MV_PAR05 + "'
	SK007 += "                   AND Z50_ANOREF = '" + MV_PAR06 + "'
	SK007 += "                   AND Z50_DATARF = '" + dtos(MV_PAR01) + "' "
	SK007 += "                   AND Z50.D_E_L_E_T_ = ' ' "
	SK007 += "                 GROUP BY Z50_CONTA) "
	SK007 += " SELECT *, "
	//         --     Identificação de um produto para registro da ocorrência da conta sem custo Ajustado para cálculo na RAC/SAP
	SK007 += "        CASE "
	SK007 += "          WHEN CHK = 'OK' THEN '' "
	SK007 += "          ELSE (SELECT MIN(Z56_COD) "
	SK007 += "                  FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	SK007 += "                 WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	SK007 += "                   AND Z56_DATARF = '" + dtos(MV_PAR03) + "' "
	SK007 += "                   AND SUBSTRING(Z56_COD,8,1) = '1' "
	SK007 += "                   AND Z56_SEQUEN = '" + msSequenc + "' "
	SK007 += "                   AND D_E_L_E_T_ = ' ') "
	SK007 += "        END PRODUT "
	SK007 += "   FROM (SELECT *, "
	//         --             2) Tratativa para identificação da auxência de CONTA
	SK007 += "                CASE "
	SK007 += "                  WHEN CONTA IN('61101020','61102020') THEN 'OK' "
	SK007 += "                  WHEN USADO = 0 THEN 'ERRO' "
	SK007 += "                  ELSE 'OK' "
	SK007 += "                END CHK "
	SK007 += "           FROM (SELECT *, "
	//         --                    1) Tratativa para identificação da auxência de CONTA
	SK007 += "                       (SELECT COUNT(*) CONTAD "
	SK007 += "                          FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	SK007 += "                         WHERE Z56_FILIAL = '" + xFilial("Z56") + "' "
	SK007 += "                           AND Z56_DATARF = '" + dtos(MV_PAR03) + "' "
	SK007 += "                           AND Z56_CONTA = CONTA "
	SK007 += "                           AND Z56_SEQUEN = '" + msSequenc + "' "
	SK007 += "                           AND D_E_L_E_T_ = ' ') USADO "
	//         --               Regra Geral - Base de Dados das contas realizadas
	SK007 += "                  FROM (SELECT CONTA, "
	SK007 += "                               CT1_DESC01 DESC01, "
	SK007 += "                               Z29_COD_IT ITCUS, "
	SK007 += "                               Z29_TIPO TIPO, "
	SK007 += "                               SUM(VALOR) VALOR "
	SK007 += "                          FROM RAZAO RAZ "
	SK007 += "                         INNER JOIN " + RetSqlName("CT1") + " CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "' "
	SK007 += "                                              AND CT1_CONTA = CONTA "
	SK007 += "                                              AND CT1.D_E_L_E_T_ = ' ' "
	SK007 += "                         INNER JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "' "
	SK007 += "                                              AND Z29_COD_IT = CT1_YITCUS "
	SK007 += "                                              AND Z29_TIPO = 'CV' "
	SK007 += "                                              AND Z29.D_E_L_E_T_ = ' ' "
	SK007 += "                         GROUP BY CONTA, "
	SK007 += "                                  CT1_DESC01, "
	SK007 += "                                  Z29_COD_IT, "
	SK007 += "                                  Z29_TIPO) AS TABFR) AS GFGFH) AS SDFSF "
	SK007 += "  WHERE CHK <> 'OK' "
	SK007 += "  ORDER BY CONTA "
	SKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SK007),'SK07',.F.,.T.)
	dbSelectArea("SK07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("ProcessamentoX")

		dbSelectArea("Z56")
		dbSetOrder(1)
		If !dbSeek(xFilial("Z56") + dtos(MV_PAR03) + SK07->PRODUT + SK07->CONTA + SK07->ITCUS)
			Reclock("Z56",.T.)
			Z56->Z56_FILIAL := xFilial("Z56")
		Else
			Reclock("Z56",.F.)
		EndIf
		Z56->Z56_DATARF  := MV_PAR03
		Z56->Z56_COD     := SK07->PRODUT
		Z56->Z56_CONTA   := SK07->CONTA
		Z56->Z56_ITCUS   := SK07->ITCUS
		Z56->Z56_CTOTAL  := 0
		Z56->Z56_M01     := IIF(Substr(dtos(MV_PAR03),5,2) == "01", 0.0000001, 0)
		Z56->Z56_M02     := IIF(Substr(dtos(MV_PAR03),5,2) == "02", 0.0000001, 0)
		Z56->Z56_M03     := IIF(Substr(dtos(MV_PAR03),5,2) == "03", 0.0000001, 0)
		Z56->Z56_M04     := IIF(Substr(dtos(MV_PAR03),5,2) == "04", 0.0000001, 0)
		Z56->Z56_M05     := IIF(Substr(dtos(MV_PAR03),5,2) == "05", 0.0000001, 0)
		Z56->Z56_M06     := IIF(Substr(dtos(MV_PAR03),5,2) == "06", 0.0000001, 0)
		Z56->Z56_M07     := IIF(Substr(dtos(MV_PAR03),5,2) == "07", 0.0000001, 0)
		Z56->Z56_M08     := IIF(Substr(dtos(MV_PAR03),5,2) == "08", 0.0000001, 0)
		Z56->Z56_M09     := IIF(Substr(dtos(MV_PAR03),5,2) == "09", 0.0000001, 0)
		Z56->Z56_M10     := IIF(Substr(dtos(MV_PAR03),5,2) == "10", 0.0000001, 0)
		Z56->Z56_M11     := IIF(Substr(dtos(MV_PAR03),5,2) == "11", 0.0000001, 0)
		Z56->Z56_M12     := IIF(Substr(dtos(MV_PAR03),5,2) == "12", 0.0000001, 0)
		Z56->Z56_GMCD    := "S"
		Z56->Z56_SEQUEN  := msSequenc
		MsUnlock()

		dbSelectArea("SK07")
		dbSkip()

	End

	SK07->(dbCloseArea())
	Ferase(SKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(SKcIndex+OrdBagExt())          //indice gerado

	oLogProc:LogFimProc()

	Aviso('BIA518', 'Processamento executado com sucesso (5)', {'Ok'} )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518I  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.09.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime o custo para avaliação antes de enviar para o SAP  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518I()

	Processa({|| RptiDetail()})

Return

Static Function RptiDetail()

	cHInicio := Time()
	fPerg := "BIA518P"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA518",fPerg)

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z56_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z56") + " Z56(NOLOCK) "
	XP001 += " WHERE Z56_DATARF BETWEEN '" + Substr(dtos(MV_PAR02),1,4) + "0101' AND '" + Substr(dtos(MV_PAR02),1,4) + "1231' "
	XP001 += "       AND Z56.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())	

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Base para Cálculo do Custo Ajustado - RAC"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODREF"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DPROD"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCONTA"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHVCTA"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITCUS"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DITCUS"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFORMATO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHVFORMT"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTOTAL"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTDRAC"          ,3,2)

	QR008 := " WITH REFPROD AS (SELECT D3_COD PRODUT, SUM(D3_QUANT) QUANTD
	QR008 += "                    FROM "+RetSqlName("SD3")+" SD3(NOLOCK)
	QR008 += "                   INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'
	QR008 += "                                        AND B1_COD = D3_COD
	QR008 += "                                        AND SB1.D_E_L_E_T_ = ' '
	QR008 += "                   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	QR008 += "                     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'
	QR008 += "                     AND D3_TM = '010'
	QR008 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	If cEmpAnt == "01"
		QR008 += "                     AND D3_TIPO IN('PA', 'PP', 'PS')
	ElseIf cEmpAnt == "06"
		QR008 += "                     AND D3_TIPO IN('MP', 'PI', 'PA')
	ElseIf cEmpAnt == "14"
		QR008 += "                     AND D3_TIPO IN('PA')
	EndIf
	QR008 += "                     AND D3_ESTORNO = ' '
	QR008 += "                     AND SD3.D_E_L_E_T_ = ' '
	QR008 += "                   GROUP BY D3_COD)
	QR008 += " SELECT REF.PRODUT PRODREF,
	QR008 += "        Z56_COD PRODUTO,
	QR008 += "        SUBSTRING(B1_DESC,1,50) DPROD,
	QR008 += "        B1_TIPO TIPO,
	QR008 += "        Z56_CONTA CONTA,
	QR008 += "        CT1_DESC01 DCONTA,
	QR008 += "        SUBSTRING(RTRIM(Z56_CONTA)+' - '+RTRIM(CT1_DESC01),1,25) CHVCTA,
	QR008 += "        Z56_ITCUS ITCUS,
	QR008 += "        Z29_DESCR DITCUS,
	QR008 += "        B1_YFORMAT FORMATO,
	QR008 += "        ZZ6_DESC DFORMATO,
	QR008 += "        SUBSTRING(RTRIM(B1_YFORMAT)+' - '+RTRIM(ZZ6_DESC),1,15) CHVFORMT,
	QR008 += "        Z56_M"+StrZero(Month(MV_PAR03),2)+" CTOTAL,
	QR008 += "        (SELECT Z57_QTDRAC
	QR008 += "           FROM "+RetSqlName("Z57")+" Z57(NOLOCK)
	QR008 += "          WHERE Z57_FILIAL = '"+xFilial("Z57")+"'
	QR008 += "            AND Z57_DATARF = Z56_DATARF
	QR008 += "            AND Z57_PRODUT = Z56_COD
	QR008 += "            AND Z57_SEQUEN = Z56_SEQUEN
	QR008 += "            AND Z57.D_E_L_E_T_ = ' ') QTDRAC
	QR008 += "   FROM REFPROD REF
	QR008 += "   LEFT JOIN "+RetSqlName("Z56")+" Z56(NOLOCK) ON Z56_FILIAL = '"+xFilial("Z56")+"'
	QR008 += "                                     AND Z56_DATARF = '"+dtos(MV_PAR03)+"'
	QR008 += "                                     AND Z56_COD = PRODUT
	QR008 += "                                     AND Z56_SEQUEN = '" + msSequenc + "'
	QR008 += "                                     AND Z56_GMCD = 'S'
	QR008 += "                                     AND Z56.D_E_L_E_T_ = ' '
	QR008 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	QR008 += "                                     AND B1_COD = Z56_COD
	QR008 += "                                     AND SB1.D_E_L_E_T_ = ' '
	QR008 += "   LEFT JOIN "+RetSqlName("CT1")+" CT1(NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"'
	QR008 += "                                     AND CT1_CONTA = Z56_CONTA
	QR008 += "                                     AND CT1.D_E_L_E_T_ = ' '
	QR008 += "   LEFT JOIN "+RetSqlName("Z29")+" Z29(NOLOCK) ON Z29_FILIAL = '"+xFilial("Z29")+"'
	QR008 += "                                     AND Z29_COD_IT = Z56_ITCUS
	QR008 += "                                     AND Z29.D_E_L_E_T_ = ' '
	QR008 += "   LEFT JOIN "+RetSqlName("ZZ6")+" ZZ6(NOLOCK) ON ZZ6_FILIAL = '"+xFilial("ZZ6")+"'
	QR008 += "                                     AND ZZ6_COD = B1_YFORMAT
	QR008 += "                                     AND ZZ6.D_E_L_E_T_ = ' '
	QR008 += "  ORDER BY PRODUT
	QRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR008),'QR08',.F.,.T.)
	dbSelectArea("QR08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { QR08->PRODREF         ,;
		QR08->PRODUTO                                         ,;
		QR08->DPROD                                           ,;
		QR08->TIPO                                            ,;
		QR08->CONTA                                           ,;
		QR08->DCONTA                                          ,;
		QR08->CHVCTA                                          ,;
		QR08->ITCUS                                           ,;
		QR08->DITCUS                                          ,;
		QR08->FORMATO                                         ,;
		QR08->DFORMATO                                        ,;
		QR08->CHVFORMT                                        ,;
		QR08->CTOTAL                                          ,;
		QR08->QTDRAC                                          })

		dbSelectArea("QR08")
		dbSkip()

	End

	QR08->(dbCloseArea())
	Ferase(QRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QRcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "baserac - "+cEmpAnt+" - "+dtos(MV_PAR02)+" - "+dtos(MV_PAR03)

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

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA518W  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.09.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tratamento para captura e gravação de custo para produtos  ¦¦¦
¦¦¦          ¦ fora do MIX                                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA518W()

	Private w8FilAleat := ""
	Private fyDatRef   := ctod("  /  /  ")
	Private oGet2
	Private cGet2      := Space(10)
	Private oGet3
	Private cGet3      := Space(03)
	Private oGet4
	Private cGet4      := Space(04)
	Private oSay3

	If !U_B518VDT(dDataBase)
		Return
	EndIf

	// Retirado de Uso em 05/02/18, pois em 2018 a trativa para Orçamento é diferente...

	// Incluída tratativa que passa pelo controle da tabela SGG...

	// Chama user function interna para gravação da SGG. Função corretata BIA631, sub-função bBa631Grv 
	ExecBlock("B518WSGG", .F., .F.)

	// Chama o programa principal para geração e gravação do custo padrão - orçado
	ExecBlock("BIA776", .F., .F.)

	// Grava os unitários em tabela Orçamentária
	ExecBlock("B943RUNT", .F., .F.)

	// Replica custo unitário para tabela de Ajustado RAC
	ExecBlock("B943CVAR", .F., .F.)

	Aviso('BIA518W','Fim do Processamento...', {'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B518WSGG  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09.09.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime o custo para avaliação antes de enviar para o SAP  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B518WSGG()

	Processa({|| RptB518WSGG()})

Return

Static Function RptB518WSGG()

	Local oDlgCpad
	Local Confirmar
	Local oGet1
	Local cGet1      := dDataBase
	Local oMultiGet1
	Local cMultiGet1 := ""
	Local oSay1
	Local oSay2
	Local fh_Esc     := .F.
	Local msx

	w8FilAleat := ""
	fyDatRef   := ctod("  /  /  ")

	DEFINE MSDIALOG oDlgCpad TITLE "Filtro adicional para Custo Padrão" FROM 000, 000  TO 350, 550 COLORS 0, 16777215 PIXEL

	@ 030, 013 SAY oSay1 PROMPT "Informe o código dos produtos que deseja filtrar separados por virgula:" SIZE 167, 007 OF oDlgCpad COLORS 0, 16777215 PIXEL
	@ 042, 014 GET oMultiGet1 VAR cMultiGet1 OF oDlgCpad MULTILINE SIZE 246, 095 COLORS 0, 16777215 HSCROLL PIXEL
	@ 008, 223 BUTTON Confirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgCpad ACTION (fh_Esc := .T., oDlgCpad:End()) PIXEL
	@ 015, 013 SAY oSay2 PROMPT "Informe a Data de Fechamento:" SIZE 077, 007 OF oDlgCpad COLORS 0, 16777215 PIXEL
	@ 013, 094 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgCpad COLORS 0, 16777215 PIXEL WHEN .F. 
	@ 144, 013 SAY oSay3 PROMPT "Informe a Vesão Orçamentária Vigente:" SIZE 097, 007 OF oDlgCpad COLORS 0, 16777215 PIXEL
	@ 141, 109 MSGET oGet2 VAR cGet2 SIZE 039, 010 OF oDlgCpad F3("ZB5") COLORS 0, 16777215 PIXEL
	@ 141, 151 MSGET oGet3 VAR cGet3 SIZE 021, 010 OF oDlgCpad COLORS 0, 16777215 PIXEL
	@ 141, 176 MSGET oGet4 VAR cGet4 SIZE 034, 010 OF oDlgCpad COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlgCpad VALID fh_Esc

	w8FilAleat := cMultiGet1
	fyDatRef   := cGet1

	If !U_BiaULRAC(fyDatRef)
		Return
	EndIf

	// Primeiro dia do ano orçamentário: servirá de referência para eventuais confrontos.
	msDtStrut := stod(Substr(dtos(fyDatRef),1,4) + "0101")
	msObserv  := "Data Foto: " + dtoc(dDataBase) + ", Data Strut: " + dtoc(msDtStrut)
	bBa518Grv( dDataBase, msDtStrut, msObserv, w8FilAleat )

	For msx := 1 to 12

		// Foto da estrutura para orçamento variável mes a mes
		msDtStrut := stod(Substr(dtos(fyDatRef),1,4) + StrZero(msx,2) + "01")
		msDtStrut := Ultimodia(msDtStrut)
		msObserv  := "Data Foto: " + dtoc(dDataBase) + ", Data Strut: " + dtoc(msDtStrut)
		If msDtStrut >= fyDatRef
			bBa518Grv( dDataBase, msDtStrut, msObserv, w8FilAleat )
		EndIf

	Next

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ bBa518Grv    ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 19/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function bBa518Grv(xsDtREf, xsDtStt, xsObsv, xsProdRf)

	Local msEnter     := Chr(13) + Chr(10)

	PU008 := Alltrim(" WITH NIVEIS AS (                                                                                                                                      ") + msEnter
	//                                 -- Membro âncora                                                                                                                      
	PU008 += Alltrim("                 SELECT SG1.G1_COMP     ID,                                                                                                            ") + msEnter
	PU008 += Alltrim("                        SG1.G1_COD      IDPAI,                                                                                                         ") + msEnter
	PU008 += Alltrim("                        SG1.R_E_C_N_O_  REGSG1,                                                                                                        ") + msEnter
	PU008 += Alltrim("                        0               NIVEL                                                                                                          ") + msEnter
	PU008 += Alltrim("                   FROM " + RetSqlName("SG1") + " SG1(NOLOCK)                                                                                         ") + msEnter
	PU008 += Alltrim("                  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_COD = SG1.G1_COD                                                         ") + msEnter
	PU008 += Alltrim("                                                AND SB1.B1_TIPO IN('PA')                                                                               ") + msEnter
	PU008 += Alltrim("                                                AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	PU008 += Alltrim("                  INNER JOIN " + RetSqlName("SB1") + " XB1(NOLOCK) ON XB1.B1_COD = SG1.G1_COMP                                                        ") + msEnter                                                  
	//	PU008 += Alltrim("                                                AND XB1.B1_TIPO NOT IN('PA')                                                                           ") + msEnter
	PU008 += Alltrim("                                                AND XB1.D_E_L_E_T_ = ' '                                                                               ") + msEnter
	PU008 += Alltrim("                  WHERE SG1.G1_FILIAL = '" + xFilial("SG1") + "'                                                                                       ") + msEnter
	//                                    --***************************************************************************                                                      
	//                                    --*  neste ponto incluir sub set com os produto que se pretende fotografar  *                                                      
	//                                    --***************************************************************************                                                      
	PU008 += Alltrim("                    AND SG1.G1_COD IN " + FormatIn(xsProdRf,",") + "                                                                                   ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' >= SG1.G1_INI                                                                                          ") + msEnter
	PU008 += Alltrim("                    AND '" + dtos(xsDtREf) + "' <= SG1.G1_FIM                                                                                          ") + msEnter
	PU008 += Alltrim("                    AND SG1.D_E_L_E_T_ = ' '                                                                                                           ") + msEnter
	PU008 += Alltrim("                  UNION ALL                                                                                                                            ") + msEnter
	//                                 -- Filhos                                                                                                                             
	PU008 += Alltrim("                 SELECT T1.G1_COMP     ID,                                                                                                             ") + msEnter
	PU008 += Alltrim("                        T1.G1_COD      IDPAI,                                                                                                          ") + msEnter
	PU008 += Alltrim("                        T1.R_E_C_N_O_  REGSG1,                                                                                                         ") + msEnter
	PU008 += Alltrim("                        NIVEL + 1      NIVEL                                                                                                           ") + msEnter
	PU008 += Alltrim("                   FROM " + RetSqlName("SG1") + " T1(NOLOCK)                                                                                          ") + msEnter
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
	PU008 += Alltrim("        (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("SGG") + " SGG(NOLOCK)) + ROW_NUMBER() OVER(ORDER BY SG1.R_E_C_N_O_) AS R_E_C_N_O_,                 ") + msEnter
	PU008 += Alltrim("        G1_YMISTUR                                                                                                                                     ") + msEnter
	PU008 += Alltrim("   FROM (SELECT DISTINCT REGSG1                                                                                                                        ") + msEnter
	PU008 += Alltrim("           FROM NIVEIS NIV                                                                                                                             ") + msEnter
	PU008 += Alltrim("          WHERE ID + IDPAI NOT IN ( SELECT GG_COMP + GG_COD                                                                                            ") + msEnter
	PU008 += Alltrim("                                      FROM " + RetSqlName("SGG") + " SGG(NOLOCK)                                                                                   ") + msEnter
	PU008 += Alltrim("                                     WHERE D_E_L_E_T_ = ' ' AND GG_FIM IN('" + dtos(xsDtStt) + "'))                                                    ") + msEnter
	PU008 += Alltrim("            AND IDPAI NOT IN ( SELECT GG_COD                                                                                                           ") + msEnter                              
	PU008 += Alltrim("                                 FROM " + RetSqlName("SGG") + " SGG(NOLOCK)                                                                                        ") + msEnter                                     
	PU008 += Alltrim("                                WHERE D_E_L_E_T_ = ' ' AND GG_FIM IN('" + dtos(xsDtStt) + "'))                                                         ") + msEnter
	PU008 += Alltrim("         ) AS TAB                                                                                                                                      ") + msEnter
	PU008 += Alltrim("   LEFT JOIN " + RetSqlName("SG1") + " SG1(NOLOCK) ON SG1.R_E_C_N_O_ = TAB.REGSG1                                                                              ") + msEnter

	U_BIAMsgRun("Aguarde... Efetuando Cópia da Estrutura de Produtos. Dt Estrut: " + dtoc(xsDtStt),,{|| TcSqlExec(PU008) })

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Data Ref. Orçamento ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Ini p/ Fechamento?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Dt Fim p/ Fechamento?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Versão Orçamentária ?","","","mv_ch4","C",10,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"05","Revisão Ativa       ?","","","mv_ch5","C",03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ano de Referência   ?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

User Function B518VDT(_dData)

	Local _lRet	:=	.T.

	If _dData < GetMv("MV_YULMES")
		MsgInfo("Data do Sistema menor que último Fechamento! Favor Alterar a Mesma e tentar novamente! ")
		_lRet	:=	.F.
	EndIf

	If _dData <> LastDay(_dData)
		MsgInfo("A Data do Sistema precisa ser o último dia do mês inicial da Fotografia! ")
		_lRet	:=	.F.		
	EndIf

Return _lRet
