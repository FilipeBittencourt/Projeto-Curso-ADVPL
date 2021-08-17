#include "rwMake.ch"
#include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM         ºAutor  ³BRUNO MADALENO      º Data ³  30/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTO DE ENTRADA NO FINAL DA NOTA FISCAL                          º±±
±±º          ³                                                                  º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460FIM()

	Local cSql			:= ""
	Local cFilOri 		:= xFilial("SF2")
	Local cSerieOri 	:= SF2->F2_SERIE
	Local cDocOri 		:= SF2->F2_DOC
	Local cCliOri		:= SF2->F2_CLIENTE
	Local cLojaOri 		:= SF2->F2_LOJA
	Local oObj460FIM	:= BIAF029():New()
	Local oObjFatPart	:= TWFaturamentoemPartes():New(.F.)
	Local cFornece		:= ""
	Local cQrySC9		:= ""
	Local cQryPED		:= ""
	Local cQryTES		:= ""
	Local cQrySD2		:= ""
	Local cQrySDB		:= ""

	//Variaveis de Posicionamento
	//--------------------------------
	Private aArea	:= GetArea()
	Private cArq	:= Alias()
	Private cInd	:= IndexOrd()
	Private cReg	:= Recno() 
	//--------------------------------

	If MV_PAR11 == 2 //PARAMETRO QUE DEFINE SE O SISTEMA IRA AGLUTINAR OS PEDIDOS

		//VERIFICA SE FOI UTILIZADO MAIS DE UM PEDIDO NA GERACAO DA NF (ESTE PROBLEMA PASSOU A OCORRER APÓS A MIGRAÇÃO PARA O PROTHEUS11
		cQryPED	:= GetNextAlias()
		CSQL := "SELECT COUNT(*) QUANT	"
		CSQL += "FROM					"
		CSQL += "	(SELECT D2_PEDIDO, COUNT(*) COUNT				"
		CSQL += "	FROM "+RetSqlName("SD2")+" 						"
		CSQL += "	WHERE 	D2_FILIAL	= '"+xFilial("SD2")+"' 	AND "
		CSQL += "			D2_DOC 		= '"+SF2->F2_DOC+"' 	AND "
		CSQL += "			D2_SERIE 	= '"+SF2->F2_SERIE+"'	AND "
		CSQL += "			D_E_L_E_T_ 	= ''						"
		CSQL += "	GROUP BY D2_PEDIDO) TMP							"
		TcQuery cSQL New Alias (cQryPED)

		If (cQryPED)->QUANT <> 1
			MsgBox("O SISTEMA UTILIZOU MAIS DE UM PEDIDO PARA GERAR A NF "+SF2->F2_SERIE+"/"+SF2->F2_DOC+". FAVOR CONTACTAR O SETOR DE TI!","M460FIM","STOP")
		EndIf

		(cQryPED)->(DbCloseArea())

	EndIf

	//VERIFICA SE FOI UTILIZADO MAIS DE UM TES NA GERACAO DA NF
	cQryTES	:= GetNextAlias()
	CSQL := "SELECT COUNT(*) QUANT	"
	CSQL += "FROM					"
	CSQL += "	(SELECT D2_TES, COUNT(*) COUNT					"
	CSQL += "	FROM "+RetSqlName("SD2")+" 						"
	CSQL += "	WHERE 	D2_FILIAL	= '"+xFilial("SD2")+"' 	AND "
	CSQL += "			D2_DOC 		= '"+SF2->F2_DOC+"' 	AND "
	CSQL += "			D2_SERIE 	= '"+SF2->F2_SERIE+"'	AND "
	CSQL += "			D_E_L_E_T_ 	= ''						"
	CSQL += "	GROUP BY D2_TES) TMP							"
	TcQuery cSQL New Alias (cQryTES)

	If (cQryTES)->QUANT <> 1 .and. SF2->F2_CLIENTE <> "004536" // Por Marcos em 16/01/18 para atender venda Fábrica vs Fábrica
		MsgBox("O SISTEMA UTILIZOU MAIS DE UM TES PARA GERAR A NF "+SF2->F2_SERIE+"/"+SF2->F2_DOC+". FAVOR CONTACTAR O SETOR DE TI!","M460FIM","STOP")
	EndIf

	(cQryTES)->(DbCloseArea())

	cQrySDB	:= GetNextAlias()
	CSQL := "SELECT SUM(DB_QUANT) AS QUANT FROM " + RETSQLNAME("SDB") + " "
	CSQL += "WHERE 	DB_FILIAL	=  '" + xFilial("SDB") 	+ "' AND "
	CSQL += "		DB_DOC 		=  '" + SF2->F2_DOC 	+ "' AND "
	CSQL += "		DB_SERIE 	=  '" + SF2->F2_SERIE 	+ "' AND "
	CSQL += "		DB_CLIFOR	=  '" + SF2->F2_CLIENTE + "' AND "
	CSQL += "		DB_LOJA		=  '" + SF2->F2_LOJA   	+ "' AND "
	CSQL += "		DB_TM >= '500' AND "
	CSQL += "		DB_ESTORNO 	=  ''  AND "
	CSQL += "		D_E_L_E_T_ 	=  ''  "
	TcQuery cSQL New Alias (cQrySDB)

	cQrySD2 := GetNextAlias()
	CSQL := "SELECT D2_TP, D2_ESTOQUE, SUM(D2_QUANT) AS QUANT FROM " + RETSQLNAME("SD2") + " "
	CSQL += "WHERE 	D2_FILIAL	=  '" + xFilial("SD2") 	+ "' AND "
	CSQL += "		D2_DOC		=  '" + SF2->F2_DOC 	+ "' AND "
	CSQL += "		D2_SERIE	=  '" + SF2->F2_SERIE	+ "' AND "
	CSQL += "		D2_CLIENTE	=  '" + SF2->F2_CLIENTE + "' AND "
	CSQL += "		D2_LOJA		=  '" + SF2->F2_LOJA   	+ "' AND "
	CSQL += "		D_E_L_E_T_ = '' "
	CSQL += "		GROUP BY D2_TP, D2_ESTOQUE "
	TcQuery cSQL New Alias (cQrySD2)

	If cEmpAnt <> "06"  // Projeto JK

		IF (cQrySD2)->D2_TP == "PA" .And. (cQrySD2)->D2_ESTOQUE == "S"

			IF (cQrySD2)->QUANT <> (cQrySDB)->QUANT

				MsgBox("NOTA FISCAL COM PROBLEMA, FAVOR EXCLUIR E GERAR A NOTA FISCAL NOVAMENTE OU CONTACTAR O SETOR DE TI!","M460FIM","STOP")

			ENDIF

		ENDIF

	EndIf

	(cQrySD2)->(DbCloseArea())
	
	(cQrySDB)->(DbCloseArea())

	//DESATIVADO EM 23/10/17 POR RANISSES - NÃO É REALIZADO O CALCULO DO MC1
	//EXECUTAR STORED PROCEDURE PARA CALCULO DO D2_YMC1 - FERNANDO ROCHA - 04/11/2010
	//IF (cEmpAnt $ "01#05#07") .AND. TCSPEXIST("GMR_UPD_MC")
	//	_cChaveD2 = SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
	//	TCSPEXEC("GMR_UPD_MC",cEmpAnt,DTOS(SF2->F2_EMISSAO),DTOS(SF2->F2_EMISSAO),"S",_cChaveD2)
	//ENDIF

	//*************************************************************************************************************
	//** Imprementado tratamento para controle de vendas a funcionários em 11/04/13 por Marcos Alberto Soprani   **
	//*************************************************************************************************************
	fIncFunc()

	// Informações complementares da nota
	U_BIAF026()	

	//Parametro para desligar os Jobs Automaticos em caso de Necessidade
	//Processar comando abaixo somente com Automação ligada
	//If (U_GETBIAPAR("BIA_FATAUTO", .T.))

	//02/12 -> rodando independente do Fat Automatico para ajustar mensagem conforme a CARGA - Testando
	oObj460FIM:Processa()

	oObjFatPart:Processa()

	//EndIf	


	If AllTrim(cEmpAnt) == "07"

		//Posiciona no SC9 Faturado para buscar as informações da NF de Origem
		cQrySC9	:= GetNextAlias()
		cSQL :=""
		CSQL += "SELECT C9_BLINF, SUBSTRING(C9_BLINF,1,2) EMPRESA, SUBSTRING(C9_BLINF,12,3) PREFIXO, SUBSTRING(C9_BLINF,3,9) NOTA, SUBSTRING(C9_BLINF,15,6) PEDIDO, SUBSTRING(C9_BLINF,21,2) ITEM, SUBSTRING(C9_BLINF,23,2) SEQ "
		CSQL += "FROM SC9070 "
		CSQL += "WHERE C9_FILIAL = '"+cFilOri+"' AND C9_NFISCAL = '"+cDocOri+"' AND C9_SERIENF = '"+cSerieOri+"' AND C9_CLIENTE = '"+cCliOri+"' AND C9_LOJA = '"+cLojaOri+"' AND C9_BLINF <> '' AND D_E_L_E_T_ = '' "
		TcQuery cSQL New Alias (cQrySC9)

		If !(cQrySC9)->(Eof())

			If (cQrySC9)->EMPRESA == "01"
				cFornece := "000534"
			ElseIf (cQrySC9)->EMPRESA == "05"
				cFornece := "002912"
			ElseIf (cQrySC9)->EMPRESA == "13"
				cFornece := "004695"
			ElseIf (cQrySC9)->EMPRESA == "14"
				cFornece := "003721"
			Else
				cFornece := "000534"				
			EndIf	

			CSQL := ""
			CSQL += " with TAB_SE2 as "
			CSQL += " ( "
			CSQL += " SELECT DISTINCT RECSE2 = SE2.R_E_C_N_O_, E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA, CHVSE1 = (E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) "
			CSQL += " from SE1070 SE1 INNER JOIN SE2070 SE2 on " 
			CSQL += " 		E2_FILIAL 	= '"+cFilOri+"' "
			CSQL += " 	and E2_PREFIXO	= '"+(cQrySC9)->PREFIXO+"' "
			CSQL += " 	and E2_NUM 		= '"+(cQrySC9)->NOTA+"' "
			CSQL += " 	and E2_FORNECE	= '"+cFornece+"' "
			CSQL += " 	and E2_PARCELA = case "	
			CSQL += "							when (select COUNT(*) QUANT from SE1070 X " 
			CSQL += " 										where X.E1_FILIAL	= '"+cFilOri+"' "
			CSQL += " 										and X.E1_NUM 		= '"+cDocOri+"' "
			CSQL += " 										and X.E1_PREFIXO 	= '"+cSerieOri+"' "
			CSQL += " 										and X.E1_TIPO 		= 'NF' "
			CSQL += " 										and X.E1_NATUREZ 	<> '1230') = 1  OR "
			CSQL += "								(select COUNT(*) QUANT from SE2070 X " 
			CSQL += " 										where X.E2_FILIAL 	= '"+cFilOri+"' "
			CSQL += " 										and X.E2_PREFIXO 	= '"+(cQrySC9)->PREFIXO+"' "
			CSQL += " 										and X.E2_NUM 		= '"+(cQrySC9)->NOTA+"' "
			CSQL += "										and X.E2_FORNECE	= '"+cFornece+"' "
			CSQL += " 										and X.E2_TIPO 		= 'NF' ) = 1 "
			CSQL += "								then  '' "  			
			CSQL += " 							when (select COUNT(*) QUANT from SE1070 X " 
			CSQL += " 										where X.E1_FILIAL	= '"+cFilOri+"' "
			CSQL += " 										and X.E1_NUM 		= '"+cDocOri+"' "
			CSQL += " 										and X.E1_PREFIXO 	= '"+cSerieOri+"' "
			CSQL += " 										and X.E1_TIPO 		= 'NF' "
			CSQL += " 										and X.E1_NATUREZ 	= '1230') = 1 " 
			CSQL += " 								then (select top 1 E2_PARCELA from SE2070 X " 
			CSQL += " 													where X.E2_FILIAL 	= '"+cFilOri+"' "
			CSQL += " 													and X.E2_PREFIXO 	= '"+(cQrySC9)->PREFIXO+"' "
			CSQL += " 													and X.E2_NUM 		= '"+(cQrySC9)->NOTA+"' "
			CSQL += "													and X.E2_FORNECE	= '"+cFornece+"' "
			CSQL += " 													and X.E2_TIPO 		= 'NF' "
			CSQL += " 													and X.E2_PARCELA 	< SE1.E1_PARCELA "
			CSQL += " 													order by X.E2_PARCELA desc) "
			CSQL += " 							when (select COUNT(*) QUANT from SE1070 X " 
			CSQL += " 										where X.E1_FILIAL	= '"+cFilOri+"' "
			CSQL += " 										and X.E1_NUM 		= '"+cDocOri+"' "
			CSQL += " 										and X.E1_PREFIXO 	= '"+cSerieOri+"' "
			CSQL += " 										and X.E1_TIPO 		= 'NF' "
			CSQL += " 										and X.E1_NATUREZ 	<> '1230') > 1 " 
			CSQL += " 								then (select top 1 E2_PARCELA from SE2070 X " 
			CSQL += " 													where X.E2_FILIAL	= '"+cFilOri+"' "
			CSQL += " 													and X.E2_PREFIXO	= '"+(cQrySC9)->PREFIXO+"' "
			CSQL += " 													and X.E2_NUM 		= '"+(cQrySC9)->NOTA+"' "
			CSQL += "													and X.E2_FORNECE	= '"+cFornece+"' "
			CSQL += " 													and X.E2_TIPO 		= 'NF' "
			CSQL += " 													and X.E2_PARCELA 	= SE1.E1_PARCELA "
			CSQL += " 													order by X.E2_PARCELA desc) "
			CSQL += " 							else SE1.E1_PARCELA "
			CSQL += " 							end "
			CSQL += " where " 
			CSQL += " 	  E1_FILIAL  = '"+cFilOri+"' "
			CSQL += " and E1_PREFIXO = '"+cSerieOri+"' "
			CSQL += " and E1_NUM	 = '"+cDocOri+"' "
			CSQL += " and E1_TIPO 	 = 'NF' "
			CSQL += " and E1_NATUREZ 	<> '1230' "
			CSQL += " and SE1.D_E_L_E_T_='' "
			CSQL += " and SE2.D_E_L_E_T_='' "
			CSQL += " ) "
			CSQL += " UPDATE SE2070 SET E2_YCHVSE1 = T.CHVSE1 "
			CSQL += " FROM SE2070 SE2 INNER JOIN TAB_SE2 T on T.RECSE2 = SE2.R_E_C_N_O_ "
			TCSQLExec(CSQL)

		EndIf

		(cQrySC9)->(DbCloseArea()) 

	EndIf


	//FATURAMENTO AUTOMATICO - GRAVAR FINAL DO FATURAMENTO PARA PERMITIR TRANSMISSAO
	DbSelectArea("SF2")
	RecLock("SF2",.F.)
	SF2->F2_IDCLE := "F:"+AllTrim(Time())
	SF2->(MsUnlock())


	//--------------------------------
	//Volta posicionamento
	//--------------------------------
	If cArq <> ""
		dbSelectArea(cArq)
		dbSetOrder(cInd)
		dbGoTo(cReg)
	EndIf

	RestArea(aArea)
	//--------------------------------

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fIncFunc ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 11/04/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Verifica se a venda é para consumidor final e se este é um ¦¦¦
¦¦¦          ¦ funcionário. Se sim,                                       ¦¦¦
¦¦¦          ¦ 1) Envia um e-mail para o setor de RH;                     ¦¦¦
¦¦¦          ¦ 2) Marca os títulos gerados com sendo de funcionários;     ¦¦¦
¦¦¦          ¦ 3) Grava registro na tabela SRK - Valores Futuros para des-¦¦¦
¦¦¦          ¦ conta em folha de pagamento.                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fIncFunc()

	If SA1->A1_TIPO == "F" .and. ( (!SF2->F2_COND $ "000/169" .and. cEmpAnt == "01") .or. (!SF2->F2_COND $ "900/976" .and. cEmpAnt == "05") )

		// Verifica se é FUNCIONÁRIO
		AL005 := " SELECT COUNT(*) CONTAD, MAX(RA_MAT) MATRIC, MAX(RA_CC) CC, MAX(RA_NOME) NOMEF, MAX(RA_CLVL) CLVL
		AL005 += "   FROM " + RetSqlName("SRA")
		AL005 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
		AL005 += "    AND RA_CIC = '"+Alltrim(SA1->A1_CGC)+"'
		AL005 += "    AND RA_SITFOLH <> 'D'
		AL005 += "    AND D_E_L_E_T_ = ' '
		AL005 := ChangeQuery(AL005)
		cIndex := CriaTrab(Nil,.f.)
		If chkfile("AL05")
			dbSelectArea("AL05")
			dbCloseArea()
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,AL005),'AL05',.T.,.T.)
		dbSelectArea("AL05")
		dbGoTop()
		If AL05->CONTAD >= 1

			// Verifica se a operação gerou título
			AX007 := " SELECT COUNT(*) CONTAD
			AX007 += "   FROM " + RetSqlName("SE1")
			AX007 += "  WHERE E1_FILIAL = '"+xFilial("SE1")+"'
			AX007 += "    AND E1_NUM = '"+SF2->F2_DOC+"'
			AX007 += "    AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
			AX007 += "    AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"'
			AX007 += "    AND E1_LOJA = '"+SF2->F2_LOJA+"'
			AX007 += "    AND D_E_L_E_T_ = ' '
			AX007 := ChangeQuery(AX007)
			xIndex := CriaTrab(Nil,.f.)
			If chkfile("AX07")
				dbSelectArea("AX07")
				dbCloseArea()
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,AX007),'AX07',.T.,.T.)
			dbSelectArea("AX07")
			dbGoTop()
			If AX07->CONTAD >= 1

				ZJ009 := " SELECT ISNULL(MAX(RK_DOCUMEN),'000000') DOC_PROX
				ZJ009 += "   FROM " + RetSqlName("SRK")
				ZJ009 += "  WHERE RK_FILIAL = '"+xFilial("SRK")+"'
				ZJ009 += "    AND RK_MAT = '"+AL05->MATRIC+"'
				ZJ009 += "    AND D_E_L_E_T_ = ' '
				jxIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZJ009),'ZJ09',.T.,.T.)
				dbSelectArea("ZJ09")
				dbGoTop()
				zgDocReg := Soma1(ZJ09->DOC_PROX)
				ZJ09->(dbCloseArea())
				Ferase(jxIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(jxIndex+OrdBagExt())          //indice gerado

				// Grava registro em Valores Futuros para desconto em folha					
				RecLock("SRK",.T.)

				SRK->RK_FILIAL  := xFilial("SRK")
				SRK->RK_MAT     := AL05->MATRIC
				SRK->RK_PD      := "430"
				SRK->RK_VALORTO := SF2->F2_VALBRUT
				SRK->RK_PARCELA := AX07->CONTAD
				SRK->RK_VALORPA := SF2->F2_VALBRUT / AX07->CONTAD
				SRK->RK_VALORAR := SF2->F2_VALBRUT - ( Round(SF2->F2_VALBRUT / AX07->CONTAD,2) * AX07->CONTAD )
				SRK->RK_DTVENC  := UltimoDia( UltimoDia(SF2->F2_EMISSAO) + 1 )
				SRK->RK_DTMOVI  := SF2->F2_EMISSAO
				SRK->RK_DOCUMEN := zgDocReg
				SRK->RK_CC      := AL05->CC
				SRK->RK_CLVL    := AL05->CLVL
				SRK->RK_ITEM    := "GPE000000"
				SRK->RK_PARCPAG := 0
				SRK->RK_VLRPAGO := 0
				SRK->RK_VLSALDO := SF2->F2_VALBRUT
				SRK->RK_REGRADS := "1"
				SRK->RK_YNFISCA := SF2->F2_DOC
				SRK->RK_YSERNF  := SF2->F2_SERIE

				// Novos campos V12
				SRK->RK_PERINI  := AnoMes(SF2->F2_EMISSAO)
				SRK->RK_NUMPAGO := "01"
				SRK->RK_PROCES  := "00001"
				SRK->RK_STATUS  := "2"
				SRK->RK_NUMID   := "SRK" + xFilial("SRK") + AL05->MATRIC + "430" + zgDocReg				

				MsUnLock()

				// Envia e-mail notificando ao RH
				WF007 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				WF007 += ' <html xmlns="http://www.w3.org/1999/xhtml">
				WF007 += ' <head>
				//WF007 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				WF007 += ' <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />  '
				WF007 += ' <title>Untitled Document</title>
				WF007 += ' </head>
				WF007 += ' <body>
				WF007 += ' <p>&nbsp;</p>
				WF007 += ' <p>Para conhecimento,</p>
				WF007 += ' <p>&nbsp;</p>
				WF007 += ' <p>Foi emitida a nota fiscal '+SF2->F2_DOC+' série '+SF2->F2_SERIE+', nesta data ('+dtoc(SF2->F2_EMISSAO)+'), para pagamento em '+Alltrim(Str(AX07->CONTAD))+' parcelas contra o funcionário '+AL05->NOMEF+' CPF: '+Transform(Alltrim(SA1->A1_CGC), "@R 999.999.999-99")+' no valor total de R$ '+Alltrim(Transform(SF2->F2_VALBRUT, "@E 999,999,999.99"))+'.</p>
				WF007 += ' <p>O registro para pagamento futuro já foi efetuado nas tabelas de controle da folha de pagamento contra a matrícula '+AL05->MATRIC+', empresa '+Alltrim(SM0->M0_NOME)+'.</p>
				WF007 += ' <p>Favor efetuar as conferências necessárias.</p>
				WF007 += ' <p>&nbsp;</p>
				WF007 += ' <p>Atenciosamente,</p>
				WF007 += ' <p>&nbsp;</p>
				WF007 += ' <p>Setor Comercial.</p>
				WF007 += ' <p>&nbsp;</p>
				WF007 += ' <p>Informações geradas automaticamente por meio de parametrização do sistema Protheus via ponto de entrada M460FIM.</p>
				WF007 += ' </body>
				WF007 += ' </html>

				//RUBENS JUNIOR - 14/03/14, NOVA FORMA DE BUSCAR DESTINATARIO DO EMAIL, VIA TABELA Z28
				df_Dest := U_EmailWF('M460FIM',cEmpAnt)
				//SE RETORNAR VAZIO, UTILIZA FORMA ANTIGA
				If Empty(df_Dest)
					df_Dest := "francine.araujo@biancogres.com.br;jeane.carvalho@biancogres.com.br;"
				EndIf
				df_Assu := "Venda a funcionários"
				df_Erro := "Venda a funcionários não enviado. Favor verificar!!!"
				U_BIAEnvMail(, df_Dest, df_Assu, WF007, df_Erro)

				// Atualiza títulos a receber para não sair na listagem de cobrança
				GX007 := " UPDATE " + RetSqlName("SE1")
				GX007 += "    SET E1_HIST = 'FUNCIONARIO'
				GX007 += "  WHERE E1_FILIAL = '"+xFilial("SE1")+"'
				GX007 += "    AND E1_NUM = '"+SF2->F2_DOC+"'
				GX007 += "    AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
				GX007 += "    AND E1_CLIENTE = '"+SF2->F2_CLIENTE+"'
				GX007 += "    AND E1_LOJA = '"+SF2->F2_LOJA+"'
				GX007 += "    AND D_E_L_E_T_ = ' '
				TCSQLExec(GX007)

			EndIf

			AX07->(dbCloseArea())
			Ferase(xIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(xIndex+OrdBagExt())          //indice gerado

		EndIf

		AL05->(dbCloseArea())
		Ferase(cIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(cIndex+OrdBagExt())          //indice gerado

	EndIf

Return()
