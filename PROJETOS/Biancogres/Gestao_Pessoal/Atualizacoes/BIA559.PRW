#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} BIA559
@author Marcos Alberto Soprani
@since BIA559
@version 1.0
@description REALIZADO de RH
@type function
/*/

User Function BIA559()

	dbSelectArea("Z70")
	dbGoTop()

	n := 1
	cCadastro := " ....: Realizado RH :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
	{                "Processar"   ,'Execblock("BIA559A" ,.F.,.F.)'        ,0, 3},;
	{                "Imprimir"    ,'Execblock("BIA559I" ,.F.,.F.)'        ,0, 4} }

	mBrowse(6,1,22,75, "Z70", , , , , ,)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA559A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/02/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA559A()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	fPerg := "BIA559"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	zAnoMes := MV_PAR01
	zAnMAnt := Substr(dtos(stod(MV_PAR01+"01")-1), 1, 6)
	zDtBs   := dDataBase

	CH001 := " SELECT COUNT(*) CONTAD "
	CH001 += "   FROM " + RetSqlName("RFQ") + " "
	CH001 += "  WHERE RFQ_PROCES = '00001' "
	CH001 += "    AND RFQ_PERIOD = '" + zAnoMes + "' "
	CH001 += "    AND RFQ_STATUS = '2' "
	CH001 += "    AND D_E_L_E_T_ = ' ' "
	CHcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CH001),'CH01',.F.,.T.)
	dbSelectArea("CH01")
	cValdP := CH01->CONTAD 
	CH01->(dbCloseArea())
	Ferase(CHcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(CHcIndex+OrdBagExt())          //indice gerado

	If cValdP == 0
		MsgINFO("A folha de pagamento ainda não está fechada para o período em questão. Favor verificar com departamento de pessoal!!!")
		Return
	EndIf

	JH006 := " DELETE " + RetSqlName("Z70") + ""
	JH006 += "  WHERE Z70_FILIAL = '"+xFilial("Z70")+"' "
	JH006 += "    AND Z70_ANOMES = '"+zAnoMes+"' "
	JH006 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(JH006)

	HY004 := ""
	HyEnter := CHR(13)+CHR(10)

	IncProc("Preparando dados...")

	// BENEFICIOS
	HY004 := Alltrim(" WITH BENEFIC AS (SELECT ZS_MAT,																															   ") + HyEnter
	HY004 += Alltrim("                         ZS_MESANO,																														   ") + HyEnter
	HY004 += Alltrim("                         SUM(ALIMENT) ALIMENT,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(REFEICAO) REFEICAO,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(COMBUSTI) COMBUSTI																											   ") + HyEnter
	HY004 += Alltrim("                    FROM (SELECT ZS_MAT,																													   ") + HyEnter
	HY004 += Alltrim("                                 ZS_MESANO,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE 																													   ") + HyEnter
	HY004 += Alltrim("                                   WHEN ZS_BENEF IN('1') THEN ZS_VALOR																					   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END ALIMENT,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN ZS_BENEF IN('2','3') THEN ZS_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END REFEICAO,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN ZS_BENEF IN('4') THEN ZS_VALOR																					   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END COMBUSTI																												   ") + HyEnter
	HY004 += Alltrim("                            FROM " + RetSqlName("SZS") + "																								   ") + HyEnter
	HY004 += Alltrim("                           WHERE ZS_FILIAL = '"+xFilial("SZS")+"'																							   ") + HyEnter
	HY004 += Alltrim("                             AND ZS_MESANO = '"+zAnoMes+"'																								   ") + HyEnter
	HY004 += Alltrim("                             AND ZS_MAT <> '      '																										   ") + HyEnter
	HY004 += Alltrim("                             AND ZS_VALOR <> 0																											   ") + HyEnter
	HY004 += Alltrim("                             AND D_E_L_E_T_ = ' ') AS TABLR																								   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY ZS_MAT, ZS_MESANO)																											   ") + HyEnter
	//FOLHA MENSAL
	HY004 += Alltrim(" ,    MOVFOLH AS (SELECT RD_MAT,																															   ") + HyEnter
	HY004 += Alltrim("                         RD_CLVL,																															   ") + HyEnter
	HY004 += Alltrim("                         SUM(SALARIO) SALARIO,     																										   ") + HyEnter
	HY004 += Alltrim("                         SUM(REDUZSAL) REDUZSAL,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(PERIC) PERIC,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(INSAL) INSAL,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(FERIAD) FERIAD,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTHE50) QTHE50,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLHE50) VLHE50,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTHE100) QTHE100,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLHE100) VLHE100,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTADNOTR) QTADNOTR,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLADNOTR) VLADNOTR,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTDSREVN) QTDSREVN,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLDSREVN) VLDSREVN,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTDSRPRG) QTDSRPRG,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLDSRPRG) VLDSRPRG,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTGRATIF) QTGRATIF,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLGRATIF) VLGRATIF,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QVALETRAN) QVALETRAN,																										   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLTRANSP) VLTRANSP,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLREFEIC) VLREFEIC,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTPLS) QTPLS,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLRPLS) VLRPLS,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(QTODODP) QTODODP,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(VLODODP) VLODODP,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(PREMIACAO) PREMIACAO,																										   ") + HyEnter
	HY004 += Alltrim("                         SUM(INSSFOL) INSSFOL,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(FGTSFOL) FGTSFOL,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(ENCFOL) ENCFOL,																												   ") + HyEnter
	HY004 += Alltrim("                         SUM(ABONOFER) ABONOFER,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(BOLSEST) BOLSEST,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(PROLABOR) PROLABOR,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(FER_A07) FER_A07,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(FER_A42) FER_A42,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(PPR) PPR																														   ") + HyEnter
	HY004 += Alltrim("                    FROM (SELECT RD_MAT,																													   ") + HyEnter
	HY004 += Alltrim("                                 RD_CLVL,																													   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('101','148','156','174','189','191','195','399','161','101','104','117',									   ") + HyEnter
	HY004 += Alltrim("                                                 '133','144','148','161','190','200','413','208','221','239','240','299',									   ") + HyEnter
	HY004 += Alltrim("                                                 '107','135','180','195','103','189','191','192','105','241','193','319',									   ") + HyEnter
	HY004 += Alltrim("                                                 '320','156','340','341','344','345','366','369','399','175','371','178','374') THEN RD_VALOR				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END SALARIO,   																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('409','414','416','419','502','507','434','436','515','522','527','582','499') THEN RD_VALOR*(-1)		   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END REDUZSAL,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                    WHEN RD_PD IN('108') THEN RD_VALOR																					   ") + HyEnter
	HY004 += Alltrim("                                    ELSE 0																												   ") + HyEnter
	HY004 += Alltrim("                                 END PERIC,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                    WHEN RD_PD IN('110','111') THEN RD_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                    ELSE 0																												   ") + HyEnter
	HY004 += Alltrim("                                 END INSAL,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                    WHEN RD_PD IN('209','358') THEN RD_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                    ELSE 0																												   ") + HyEnter
	HY004 += Alltrim("                                 END FERIAD,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('112','350','355','367') THEN RD_HORAS																	   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTHE50,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('112','350','355','367') THEN RD_VALOR																	   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLHE50,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('114','348','349','356','357') THEN RD_HORAS																   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTHE100,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('114','348','349','356','357') THEN RD_VALOR																   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLHE100,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('115','307') THEN RD_HORAS																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTADNOTR,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('115','307') THEN RD_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLADNOTR,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('116') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTDSREVN,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('116') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLDSREVN,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('177') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTDSRPRG,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('177') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLDSRPRG,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('104') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTGRATIF,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('104') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLGRATIF,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('847') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QVALETRAN,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('847') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLTRANSP,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('718') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLREFEIC,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('883','882','876') THEN RD_HORAS																			   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTPLS,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('883','882','876') THEN RD_VALOR																			   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLRPLS,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('877') THEN RD_HORAS																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END QTODODP,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('877') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END VLODODP,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('317') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END PREMIACAO,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('780','781','782') THEN RD_VALOR																			   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END INSSFOL,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('732') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END FGTSFOL,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('730','742','759') THEN RD_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END ENCFOL,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('120','122','125','142','154','155','130') THEN RD_VALOR													   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END ABONOFER,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('102','365') THEN RD_VALOR																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END BOLSEST,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('118') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END PROLABOR,																											   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('119','121','123','126','127','128','145','146','147','149','152','153',									   ") + HyEnter
	HY004 += Alltrim("                                                 '154','155','158','159','160','163','165','166','188','210','211','260',									   ") + HyEnter
	HY004 += Alltrim("                                                 '261','150','151','122','130','142','167','212','213','216','519','334',									   ") + HyEnter
	HY004 += Alltrim("                                                 '335','364','171') THEN RD_VALOR																			   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END FER_A07,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('488') THEN RD_VALOR*(-1)																				   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END FER_A42,																												   ") + HyEnter
	HY004 += Alltrim("                                 CASE																														   ") + HyEnter
	HY004 += Alltrim("                                   WHEN RD_PD IN('202') THEN RD_VALOR																						   ") + HyEnter
	HY004 += Alltrim("                                   ELSE 0																													   ") + HyEnter
	HY004 += Alltrim("                                 END PPR																													   ") + HyEnter
	HY004 += Alltrim("                            FROM " + RetSqlName("SRD") + " SRD WITH (NOLOCK)																				   ") + HyEnter
	HY004 += Alltrim("                           WHERE RD_FILIAL = '"+xFilial("SRD")+"'																							   ") + HyEnter
	HY004 += Alltrim("                             AND RD_DATARQ = '"+zAnoMes+"'																								   ") + HyEnter
	HY004 += Alltrim("                             AND RD_MAT <= '199999'																										   ") + HyEnter
	HY004 += Alltrim("                             AND SRD.D_E_L_E_T_ = ' ') AS TARF																							   ") + HyEnter
	HY004 += Alltrim("                           GROUP BY RD_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                                    RD_CLVL)																												   ") + HyEnter
	HY004 += Alltrim(" SELECT *																																					   ") + HyEnter
	HY004 += Alltrim("   FROM (SELECT RA_MAT,																																	   ") + HyEnter
	HY004 += Alltrim("                RA_NOME,																																	   ") + HyEnter
	HY004 += Alltrim("                RA_CLVL,																																	   ") + HyEnter
	HY004 += Alltrim("                MOVF.*,																																	   ") + HyEnter
	HY004 += Alltrim("                BNFC.ALIMENT,																																   ") + HyEnter
	HY004 += Alltrim("                BNFC.REFEICAO,																															   ") + HyEnter
	HY004 += Alltrim("                BNFC.COMBUSTI																																   ") + HyEnter
	HY004 += Alltrim("          FROM " + RetSqlName("SRA") + " SRA																												   ") + HyEnter
	HY004 += Alltrim("           LEFT JOIN BENEFIC BNFC ON BNFC.ZS_MAT = RA_MAT																									   ") + HyEnter
	HY004 += Alltrim("           LEFT JOIN MOVFOLH MOVF ON MOVF.RD_MAT = RA_MAT																									   ") + HyEnter
	HY004 += Alltrim("         WHERE RA_FILIAL = '"+xFilial("SRA")+"'																											   ") + HyEnter
	HY004 += Alltrim("            AND D_E_L_E_T_ = ' ') AS TABRL																												   ") + HyEnter
	HY004 += Alltrim("  WHERE SALARIO <> 0 OR ( ALIMENT + REFEICAO + COMBUSTI) <> 0                 																			   ") + HyEnter
	HY004 += Alltrim("  ORDER BY RA_MAT																																			   ") + HyEnter
	HYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HY004),'HY04',.F.,.T.)
	dbSelectArea("HY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc(HY04->RA_MAT + " - " + HY04->RD_CLVL)

		dbSelectArea("Z70")
		dbGoTop()
		If !dbSeek(xFilial("Z70") + zAnoMes + dtos(zDtBs) + HY04->RA_MAT + HY04->RD_CLVL)
			RecLock("Z70",.T.)
		Else
			RecLock("Z70",.F.)
		EndIf
		Z70_FILIAL := xFilial("Z70")
		Z70_ANOMES := zAnoMes
		Z70_DTPROC := zDtBs
		Z70_MATRIC := HY04->RA_MAT
		Z70_CLVL   := HY04->RD_CLVL
		Z70_SALREF := HY04->SALARIO + HY04->REDUZSAL + HY04->PROLABOR
		Z70_PERIC  := HY04->PERIC
		Z70_INSAL  := HY04->INSAL
		Z70_VLFERD := HY04->FERIAD
		Z70_VLHE50 := HY04->VLHE50
		Z70_VLHEA0 := HY04->VLHE100
		Z70_VLADNT := HY04->VLADNOTR
		Z70_VLDSR  := HY04->VLDSREVN
		Z70_VLGRAT := HY04->VLGRATIF
		Z70_VLTRAN := HY04->VLTRANSP
		Z70_VLREFE := HY04->VLREFEIC
		Z70_TKTALM := HY04->ALIMENT
		Z70_TCKTRF := HY04->REFEICAO
		Z70_TKTCBT := HY04->COMBUSTI
		Z70_VLPLS  := HY04->VLRPLS
		Z70_VLODON := HY04->VLODODP
		Z70_EXMPER := 0 //HY04->
		Z70_UNIFOR := 0 //HY04->
		Z70_COEPCI := 0 //HY04->
		Z70_FOLINS := HY04->INSSFOL
		Z70_FOLFGT := HY04->FGTSFOL
		Z70_FOLENC := HY04->ENCFOL
		Z70_PRVFER := 0 //HY04->FER_A07+HY04->FER_A42
		Z70_ABNFER := HY04->ABONOFER
		Z70_PVFRIN := 0 //HY04->INSSFER
		Z70_PVFRFG := 0 //HY04->FGTSFER
		Z70_PRV13  := 0 //HY04->DTERC
		Z70_PV13IN := 0 //HY04->INSS13
		Z70_PV13FG := 0 //HY04->FGTS13
		Z70_PPR    := HY04->PPR
		Z70_VDSRPG := HY04->VLDSRPRG
		Z70_BOLSAE := HY04->BOLSEST
		Z70_SEGVID := 0 //HY04->
		MsUnLock()

		dbSelectArea("HY04")
		dbSkip()

	End

	HY04->(dbCloseArea())
	Ferase(HYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HYcIndex+OrdBagExt())          //indice gerado

	//PROVISÃO FERIAS - PROPRIAMENTE DITA
	HY004 := Alltrim("  WITH PROVENT AS (SELECT 'PROVFER' TIPO,																										   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                          SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(BAIXA) BAIXA																									   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('800','801','802','805','806','807','815','816','817','820','821','822')						   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('800','801','802')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('815','815','817')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_TIPPROV = '1'																							   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('805','806','807')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('820','821','822')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL																											   ") + HyEnter
	HY004 += Alltrim("                    UNION ALL																													   ") + HyEnter
	HY004 += Alltrim("                   SELECT 'PROVINS' TIPO, 																									   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                          SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(BAIXA) BAIXA																									   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('803','808','818','823')																		   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('803')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('818')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_TIPPROV = '1'																							   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('808')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('823')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL																											   ") + HyEnter
	HY004 += Alltrim("                    UNION ALL																													   ") + HyEnter
	HY004 += Alltrim("                   SELECT 'PROVFGT' TIPO,																										   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                          SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(BAIXA) BAIXA																									   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('804','809','819','824')																		   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('804')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('819')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_TIPPROV = '1'																							   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('809')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('824')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL																											   ") + HyEnter
	HY004 += Alltrim("                    UNION ALL																													   ") + HyEnter
	HY004 += Alltrim("                   SELECT 'PRDEC13' TIPO,																										   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                          SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(BAIXA) BAIXA																									   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('830','831'/*,'832'*/,'839','840','XXX','862','863','864','843','844','YYY')					   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('830','831'/*,'832'*/)																			   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('862','863','864')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('839','840','XXX')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('843','844','YYY')																				   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL																											   ") + HyEnter
	HY004 += Alltrim("                    UNION ALL																													   ") + HyEnter
	HY004 += Alltrim("                   SELECT 'PR13INS' TIPO,																										   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                          SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                         SUM(BAIXA) BAIXA																										   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('833','841','865','845')																		   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('833')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('865')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_TIPPROV = '1'																							   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('841')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('845')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL																											   ") + HyEnter
	HY004 += Alltrim("                    UNION ALL																													   ") + HyEnter
	HY004 += Alltrim("                   SELECT 'PR13FGT' TIPO,																										   ") + HyEnter
	HY004 += Alltrim("                          PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                          RT_MAT,																												   ") + HyEnter
	HY004 += Alltrim("                          RT_CLVL,																											   ") + HyEnter
	HY004 += Alltrim("                         SUM(NO_MES) NO_MES,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(TRANSF) TRANSF,																									   ") + HyEnter
	HY004 += Alltrim("                          SUM(BAIXA) BAIXA																									   ") + HyEnter
	HY004 += Alltrim("                     FROM (SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR        NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('834','842','866','846')																		   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, RT_VALOR * (-1) NO_MES, 0               TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnMAnt+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('834')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ' 																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, RT_VALOR * (-1) TRANSF, 0               BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('866')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_TIPPROV = '1'																							   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('842')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' '																						   ") + HyEnter
	HY004 += Alltrim("                            UNION ALL																											   ") + HyEnter
	HY004 += Alltrim("                           SELECT '"+zAnoMes+"' PERIODO, RT_MAT, RT_CLVL, 0               NO_MES, 0               TRANSF, RT_VALOR * (-1) BAIXA  ") + HyEnter
	HY004 += Alltrim("                             FROM "+RetSqlName("SRT")+" SRT																					   ") + HyEnter
	HY004 += Alltrim("                            WHERE RT_FILIAL = '"+xFilial("SRT")+"'																			   ") + HyEnter
	HY004 += Alltrim("                              AND SUBSTRING(RT_DATACAL,1,6) = '"+zAnoMes+"'																	   ") + HyEnter
	HY004 += Alltrim("                              AND RT_VERBA IN('846')																							   ") + HyEnter
	HY004 += Alltrim("                              AND SRT.D_E_L_E_T_ = ' ') AS TASRE																				   ") + HyEnter
	HY004 += Alltrim("                    GROUP BY PERIODO,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_MAT,																											   ") + HyEnter
	HY004 += Alltrim("                             RT_CLVL)																											   ") + HyEnter
	HY004 += Alltrim(" SELECT TIPO,																																	   ") + HyEnter
	HY004 += Alltrim("        RT_MAT,																																   ") + HyEnter
	HY004 += Alltrim("        RT_CLVL,																																   ") + HyEnter
	HY004 += Alltrim("        NO_MES + TRANSF + BAIXA VALOR																											   ") + HyEnter
	HY004 += Alltrim("   FROM PROVENT																																   ") + HyEnter
	HY004 += Alltrim("  ORDER BY RT_MAT, TIPO                        																								   ") + HyEnter
	HYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HY004),'HY04',.F.,.T.)
	dbSelectArea("HY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc(HY04->RT_MAT + " - " + HY04->RT_CLVL)

		dbSelectArea("Z70")
		dbGoTop()
		If !dbSeek(xFilial("Z70") + zAnoMes + dtos(zDtBs) + HY04->RT_MAT + HY04->RT_CLVL)
			RecLock("Z70",.T.)
		Else
			RecLock("Z70",.F.)
		EndIf
		Z70_FILIAL := xFilial("Z70")
		Z70_ANOMES := zAnoMes
		Z70_DTPROC := zDtBs
		Z70_MATRIC := HY04->RT_MAT
		Z70_CLVL   := HY04->RT_CLVL
		Z70_PRVFER += IIF(HY04->TIPO == "PROVFER", HY04->VALOR, 0)
		Z70_PVFRIN += IIF(HY04->TIPO == "PROVINS", HY04->VALOR, 0)
		Z70_PVFRFG += IIF(HY04->TIPO == "PROVFGT", HY04->VALOR, 0)
		Z70_PRV13  += IIF(HY04->TIPO == "PRDEC13", HY04->VALOR, 0)
		Z70_PV13IN += IIF(HY04->TIPO == "PR13INS", HY04->VALOR, 0)
		Z70_PV13FG += IIF(HY04->TIPO == "PR13FGT", HY04->VALOR, 0)
		MsUnLock()

		dbSelectArea("HY04")
		dbSkip()

	End

	HY04->(dbCloseArea())
	Ferase(HYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HYcIndex+OrdBagExt())          //indice gerado

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA559I  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 06/07/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotingem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA559I()

	Processa({|| iRptDetail()})

Return

Static Function iRptDetail()

	Local xt

	fPerg := "BIA559"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	zAnoMes := MV_PAR01
	zDataDe := stod(zAnoMes+"01") 
	zDataAt := UltimoDia(zDataDe)
	zAnoCrr := Substr(MV_PAR01,1,4) 

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Realizado RH"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPR         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TURNO        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTURNO       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVLCAD      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CATEG        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCATEG       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SEXO         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUADRO       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATRIC       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ADMISSA      "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "FUNCAO       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFUNCAO      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEPART       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEMISSAO     "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "EMAILSUPER   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NFERIAS      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ANOMES       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTPROC       "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVLMOV      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SALARIO      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PERIC        "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "INSALUB      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FERIADO      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "HE50         "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "HE100        "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ADCNOT       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DSR          "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "GRATIFIC     "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TRANSP       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "REFEICAO     "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TICKET       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PLANOSAUD    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ODONTO       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "EXAMES       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COEP         "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FOLINSS      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FOLFGTS      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FOLENC       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FERIAS       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ABONOFER     "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FERINS       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "FERFGT       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DECIM13      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "D13INS       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "D13FGT       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TKTALM       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "COMBUST      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "UNIFOR       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PPR          "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DSRHEPROG    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "BOLSAE       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "PLANOS2      "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ODONT2       "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SEGVIDA      "               ,3,2)

	TY002 := " SELECT '"+cEmpAnt+"' EMPR, "
	TY002 += "        RA_TNOTRAB TURNO, "
	TY002 += "        R6_DESC DTURNO, "
	TY002 += "        RA_CLVL CLVLCAD, "
	TY002 += "        RA_CATFUNC CATEG, "
	TY002 += "        X5_DESCRI DCATEG, "
	TY002 += "        RA_SEXO SEXO, "
	TY002 += "        CTH_YQUADR QUADRO, "
	TY002 += "        RA_MAT MATRIC, "
	TY002 += "        RA_NOME NOME, "
	TY002 += "        RA_ADMISSA ADMISSA, "
	TY002 += "        RA_CODFUNC FUNCAO, "
	TY002 += "        RJ_DESC DFUNCAO, "
	TY002 += "        RA_DEPTO DEPART, "
	TY002 += "        RA_DEMISSA DEMISSAO, "
	TY002 += "        RA_YSEMAIL EMAILSUPER, "
	TY002 += "        (SELECT COUNT(*) "
	TY002 += "           FROM "+RetSqlName("SR8") "
	TY002 += "          WHERE R8_FILIAL = RA_FILIAL "
	TY002 += "            AND R8_DATAFIM >= '"+zAnoCrr+"0101' "
	TY002 += "            AND R8_DATAFIM <= '"+zAnoCrr+"1231' "
	TY002 += "            AND R8_MAT = RA_MAT "
	TY002 += "            AND ( R8_TIPO = 'F' OR R8_TIPOAFA = '001' ) "
	TY002 += "            AND D_E_L_E_T_ = ' ') NFERIAS, "
	TY002 += "        Z70_ANOMES ANOMES, "
	TY002 += "        Z70_DTPROC DTPROC, "
	TY002 += "        Z70_CLVL CLVLMOV, "
	TY002 += "        Z70_SALREF SALARIO, "
	TY002 += "        Z70_PERIC PERIC, "
	TY002 += "        Z70_INSAL INSALUB, "
	TY002 += "        Z70_VLFERD FERIADO, "
	TY002 += "        Z70_VLHE50 HE50, "
	TY002 += "        Z70_VLHEA0 HE100, "
	TY002 += "        Z70_VLADNT ADCNOT, "
	TY002 += "        Z70_VLDSR DSR, "
	TY002 += "        Z70_VLGRAT GRATIFIC, "
	TY002 += "        Z70_VLTRAN TRANSP, "
	TY002 += "        Z70_VLREFE REFEICAO, "
	TY002 += "        Z70_TCKTRF TICKET, "
	TY002 += "        Z70_VLPLS PLANOSAUD, "
	TY002 += "        Z70_VLODON ODONTO, "
	TY002 += "        Z70_EXMPER EXAMES, "
	TY002 += "        Z70_COEPCI COEP, "
	TY002 += "        Z70_FOLINS FOLINSS, "
	TY002 += "        Z70_FOLFGT FOLFGTS, "
	TY002 += "        Z70_FOLENC FOLENC, "
	TY002 += "        Z70_PRVFER FERIAS, "
	TY002 += "        Z70_ABNFER ABONOFER, "
	TY002 += "        Z70_PVFRIN FERINS, "
	TY002 += "        Z70_PVFRFG FERFGT, "
	TY002 += "        Z70_PRV13 DECIM13, "
	TY002 += "        Z70_PV13IN D13INS, "
	TY002 += "        Z70_PV13FG D13FGT, "
	TY002 += "        Z70_TKTALM TKTALM, "
	TY002 += "        Z70_TKTCBT COMBUST, "
	TY002 += "        Z70_UNIFOR UNIFOR, "
	TY002 += "        Z70_PPR PPR, "
	TY002 += "        Z70_VDSRPG DSRHEPROG, "
	TY002 += "        Z70_BOLSAE BOLSAE, "
	TY002 += "        Z70_VLPLS2 PLANOS2, "
	TY002 += "        Z70_VLODO2 ODONT2, "
	TY002 += "        Z70_SEGVID SEGVIDA "
	TY002 += "   FROM "+RetSqlName("Z70")+" Z70 "
	TY002 += "  INNER JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"' "
	TY002 += "                       AND RA_MAT = Z70_MATRIC "
	TY002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	TY002 += "   LEFT JOIN "+RetSqlName("SR6")+" SR6 ON R6_TURNO = RA_TNOTRAB "
	TY002 += "                       AND SR6.D_E_L_E_T_ = ' ' "
	TY002 += "   LEFT JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FUNCAO = RA_CODFUNC "
	TY002 += "                       AND SRJ.D_E_L_E_T_ = ' ' "
	TY002 += "   LEFT JOIN "+RetSqlName("CTH")+" CTH ON CTH_CLVL = Z70_CLVL "
	TY002 += "                       AND CTH.D_E_L_E_T_ = ' ' "
	TY002 += "   LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"' "
	TY002 += "                       AND X5_TABELA = '28' "
	TY002 += "                       AND X5_CHAVE = RA_CATFUNC "
	TY002 += "                       AND SX5.D_E_L_E_T_ = ' ' "
	TY002 += "  WHERE Z70_FILIAL = '"+xFilial("Z70")+"' "
	TY002 += "    AND Z70_ANOMES = '"+MV_PAR01+"' "
	TY002 += "    AND Z70.D_E_L_E_T_ = ' ' "
	TYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY002),'TY02',.F.,.T.)
	dbSelectArea("TY02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { TY02->EMPR       ,;
		TY02->TURNO                                      ,;
		TY02->DTURNO                                     ,;
		TY02->CLVLCAD                                    ,;
		TY02->CATEG                                      ,;
		TY02->DCATEG                                     ,;
		TY02->SEXO                                       ,;
		TY02->QUADRO                                     ,;
		TY02->MATRIC                                     ,;
		TY02->NOME                                       ,;
		stod(TY02->ADMISSA)                              ,;
		TY02->FUNCAO                                     ,;
		TY02->DFUNCAO                                    ,;
		TY02->DEPART                                     ,;
		stod(TY02->DEMISSAO)                             ,;
		TY02->EMAILSUPER                                 ,;
		TY02->NFERIAS                                    ,;
		TY02->ANOMES                                     ,;
		stod(TY02->DTPROC)                               ,;
		TY02->CLVLMOV                                    ,;
		TY02->SALARIO                                    ,;
		TY02->PERIC                                      ,;
		TY02->INSALUB                                    ,;
		TY02->FERIADO                                    ,;
		TY02->HE50                                       ,;
		TY02->HE100                                      ,;
		TY02->ADCNOT                                     ,;
		TY02->DSR                                        ,;
		TY02->GRATIFIC                                   ,;
		TY02->TRANSP                                     ,;
		TY02->REFEICAO                                   ,;
		TY02->TICKET                                     ,;
		TY02->PLANOSAUD                                  ,;
		TY02->ODONTO                                     ,;
		TY02->EXAMES                                     ,;
		TY02->COEP                                       ,;
		TY02->FOLINSS                                    ,;
		TY02->FOLFGTS                                    ,;
		TY02->FOLENC                                     ,;
		TY02->FERIAS                                     ,;
		TY02->ABONOFER                                   ,;
		TY02->FERINS                                     ,;
		TY02->FERFGT                                     ,;
		TY02->DECIM13                                    ,;
		TY02->D13INS                                     ,;
		TY02->D13FGT                                     ,;
		TY02->TKTALM                                     ,;
		TY02->COMBUST                                    ,;
		TY02->UNIFOR                                     ,;
		TY02->PPR                                        ,;
		TY02->DSRHEPROG                                  ,;
		TY02->BOLSAE                                     ,;
		TY02->PLANOS2                                    ,;
		TY02->ODONT2                                     ,;
		TY02->SEGVIDA                                    })

		dbSelectArea("TY02")
		dbSkip()

	End

	TY02->(dbCloseArea())
	Ferase(TYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TYcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "bia559 - " + cEmpAnt + " - " + MV_PAR01

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
	aAdd(aRegs,{cPerg,"01","Ano/Mes                     ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
