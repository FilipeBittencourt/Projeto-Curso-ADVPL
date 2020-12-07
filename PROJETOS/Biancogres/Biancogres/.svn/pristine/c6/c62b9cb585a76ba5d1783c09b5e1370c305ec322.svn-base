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
	Local cClienteOri	:= SF2->F2_CLIENTE
	Local cLojaOri 		:= SF2->F2_LOJA
	Local oObj460FIM	:= BIAF029():New()
	Local oObjFatPart	:= TWFaturamentoemPartes():New(.F.)

	//Variaveis de Posicionamento
	//--------------------------------
	Private aArea	:= GetArea()
	Private cArq	:= Alias()
	Private cInd	:= IndexOrd()
	Private cReg	:= Recno() 
	//--------------------------------

	If MV_PAR11 == 2 //PARAMETRO QUE DEFINE SE O SISTEMA IRA AGLUTINAR OS PEDIDOS

		//VERIFICA SE FOI UTILIZADO MAIS DE UM PEDIDO NA GERACAO DA NF (ESTE PROBLEMA PASSOU A OCORRER APÓS A MIGRAÇÃO PARA O PROTHEUS11
		CSQL := "SELECT COUNT(*) QUANT	"
		CSQL += "FROM					"
		CSQL += "	(SELECT D2_PEDIDO, COUNT(*) COUNT				"
		CSQL += "	FROM "+RetSqlName("SD2")+" 						"
		CSQL += "	WHERE 	D2_FILIAL	= '"+xFilial("SD2")+"' 	AND "
		CSQL += "			D2_DOC 		= '"+SF2->F2_DOC+"' 	AND "
		CSQL += "			D2_SERIE 	= '"+SF2->F2_SERIE+"'	AND "
		CSQL += "			D_E_L_E_T_ 	= ''						"
		CSQL += "	GROUP BY D2_PEDIDO) TMP							"
		If chkfile("_RAC")
			dbSelectArea("_RAC")
			dbCloseArea()
		EndIf
		TCQUERY cSQL ALIAS "_RAC" NEW

		If _RAC->QUANT <> 1
			MsgBox("O SISTEMA UTILIZOU MAIS DE UM PEDIDO PARA GERAR A NF "+SF2->F2_SERIE+"/"+SF2->F2_DOC+". FAVOR CONTACTAR O SETOR DE TI!","M460FIM","STOP")
		EndIf

	EndIf

	//VERIFICA SE FOI UTILIZADO MAIS DE UM TES NA GERACAO DA NF
	CSQL := "SELECT COUNT(*) QUANT	"
	CSQL += "FROM					"
	CSQL += "	(SELECT D2_TES, COUNT(*) COUNT					"
	CSQL += "	FROM "+RetSqlName("SD2")+" 						"
	CSQL += "	WHERE 	D2_FILIAL	= '"+xFilial("SD2")+"' 	AND "
	CSQL += "			D2_DOC 		= '"+SF2->F2_DOC+"' 	AND "
	CSQL += "			D2_SERIE 	= '"+SF2->F2_SERIE+"'	AND "
	CSQL += "			D_E_L_E_T_ 	= ''						"
	CSQL += "	GROUP BY D2_TES) TMP							"
	If chkfile("_RAC1")
		dbSelectArea("_RAC1")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_RAC1" NEW

	If _RAC1->QUANT <> 1 .and. SF2->F2_CLIENTE <> "004536" // Por Marcos em 16/01/18 para atender venda Fábrica vs Fábrica
		MsgBox("O SISTEMA UTILIZOU MAIS DE UM TES PARA GERAR A NF "+SF2->F2_SERIE+"/"+SF2->F2_DOC+". FAVOR CONTACTAR O SETOR DE TI!","M460FIM","STOP")
	EndIf

	//SELECIONANDO OS ITENS DA NOTA FISCAL E A TES.
	CSQL := "SELECT SUM(D2_QUANT) AS QUANT, D2_TES FROM " + RETSQLNAME("SD2") + " "
	CSQL += "WHERE 	D2_FILIAL	= '" + xFilial("SD2") + "'	 AND "
	CSQL += "		D2_DOC 		= '" + SF2->F2_DOC + "'	 AND "
	CSQL += "		D2_SERIE 	= '" + SF2->F2_SERIE + "'	 AND "
	CSQL += "		D_E_L_E_T_ 	= '' "
	CSQL += "		GROUP BY D2_TES "
	If chkfile("_SD2")
		dbSelectArea("_SD2")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_SD2" NEW

	//SELECIONANDO A TES DA NOTA FISCAL
	CSQL := "SELECT F4_ESTOQUE FROM " + RETSQLNAME("SF4") + " "
	CSQL += "WHERE F4_CODIGO = '" + _SD2->D2_TES + "' AND "
	CSQL += "		D_E_L_E_T_ = ''  "
	If chkfile("_SF4")
		dbSelectArea("_SF4")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_SF4" NEW

	CSQL := "SELECT SUM(DB_QUANT) AS QUANT FROM " + RETSQLNAME("SDB") + " "
	CSQL += "WHERE 	DB_FILIAL	=  '" + xFilial("SDB") 	+ "' AND "
	CSQL += "		DB_DOC 		=  '" + SF2->F2_DOC 	+ "' AND "
	CSQL += "		DB_SERIE 	=  '" + SF2->F2_SERIE 	+ "' AND "
	CSQL += "		DB_CLIFOR	=  '" + SF2->F2_CLIENTE + "' AND "
	CSQL += "		DB_LOJA		=  '" + SF2->F2_LOJA   	+ "' AND "
	CSQL += "		DB_TM >= '500' AND "
	CSQL += "		DB_ESTORNO 	=  ''  AND "
	CSQL += "		D_E_L_E_T_ 	=  ''  "
	If chkfile("_SDB")
		dbSelectArea("_SDB")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_SDB" NEW

	CSQL := "SELECT SUM(D2_QUANT) AS QUANT, D2_TP FROM " + RETSQLNAME("SD2") + " "
	CSQL += "WHERE 	D2_FILIAL	=  '" + xFilial("SD2") 	+ "' AND "
	CSQL += "		D2_DOC		=  '" + SF2->F2_DOC 	+ "' AND "
	CSQL += "		D2_SERIE	=  '" + SF2->F2_SERIE	+ "' AND "
	CSQL += "		D2_CLIENTE	=  '" + SF2->F2_CLIENTE + "' AND "
	CSQL += "		D2_LOJA		=  '" + SF2->F2_LOJA   	+ "' AND "
	CSQL += "		D_E_L_E_T_ = '' "
	CSQL += "		GROUP BY D2_TP "
	If chkfile("SD2A")
		dbSelectArea("SD2A")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "SD2A" NEW

	If cEmpAnt <> "06"  // Projeto JK

		IF SD2A->D2_TP == "PA"

			IF _SF4->F4_ESTOQUE = 'S'	 // SO VERIFIA SE A TES ATUALIZA ESTOQUE

				IF _SD2->QUANT <> _SDB->QUANT

					MsgBox("NOTA FISCAL COM PROBLEMA, FAVOR EXCLUIR E GERAR A NOTA FISCAL NOVAMENTE OU CONTACTAR O SETOR DE TI!","M460FIM","STOP")

				ENDIF

			ENDIF

		ENDIF

	EndIf

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

	//Apaga area de trabalho
	//--------------------------------
	If chkfile("_SD2")
		dbSelectArea("_SD2")
		dbCloseArea()
	EndIf

	If chkfile("_SF4")
		dbSelectArea("_SF4")
		dbCloseArea()
	EndIf

	If chkfile("_SDB")
		dbSelectArea("_SDB")
		dbCloseArea()
	EndIf

	If chkfile("SD2A")
		dbSelectArea("SD2A")
		dbCloseArea()
	EndIf

	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf

	If chkfile("_RAC1")
		dbSelectArea("_RAC1")
		dbCloseArea()
	EndIf

	// Informações complementares da nota
	U_BIAF026()	

	//Parametro para desligar os Jobs Automaticos em caso de Necessidade
	//Processar comando abaixo somente com Automação ligada
	//If (U_GETBIAPAR("BIA_FATAUTO", .T.))

	//02/12 -> rodando independente do Fat Automatico para ajustar mensagem conforme a CARGA - Testando
	oObj460FIM:Processa()

	oObjFatPart:Processa()

	//EndIf	


	If AllTrim(CEMPANT) == "07"

		CSQL := " with tab_SE2 as "
		CSQL += " ( "
		CSQL += " select distinct RECSE2 = SE2.R_E_C_N_O_, E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA, CHVSE1 = (E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) "
		CSQL += " from SC9070 SC9 "
		CSQL += " join SE1070 SE1 on E1_FILIAL = C9_FILIAL and E1_PREFIXO = C9_SERIENF and E1_NUM = C9_NFISCAL "
		CSQL += " join SE2070 SE2 on " 
		CSQL += " 	E2_FILIAL = '"+cFilOri+"' "
		CSQL += " 	and E2_PREFIXO = SUBSTRING(C9_BLINF,12,3) "
		CSQL += " 	and E2_NUM = SUBSTRING(C9_BLINF,3,9) "
		CSQL += " 	and E2_PARCELA = case when exists (select 1 from SE1070 X " 
		CSQL += " 										where X.E1_FILIAL	= '"+cFilOri+"' "
		CSQL += " 										and X.E1_NUM 		= '"+cDocOri+"' "
		CSQL += " 										and X.E1_PREFIXO 	= '"+cSerieOri+"' "
		CSQL += " 										and X.E1_TIPO 		= 'NF' "
		CSQL += " 										and X.E1_NATUREZ 	= '1230') " 
		CSQL += " 								then " 
		CSQL += " 									(select top 1 E2_PARCELA from SE2070 X " 
		CSQL += " 													where X.E2_FILIAL = '"+cFilOri+"' "
		CSQL += " 													and X.E2_PREFIXO = SUBSTRING(C9_BLINF,12,3) "
		CSQL += " 													and X.E2_NUM = SUBSTRING(C9_BLINF,3,9) "
		CSQL += " 													and X.E2_TIPO 		= 'NF' "
		CSQL += " 													and X.E2_PARCELA < SE1.E1_PARCELA "
		CSQL += " 													order by X.E2_PARCELA desc) "
		CSQL += " 								else SE1.E1_PARCELA "
		CSQL += " 								end "
		CSQL += " where " 
		CSQL += " C9_FILIAL = '"+cFilOri+"' "
		CSQL += " and C9_SERIENF = '"+cSerieOri+"' "
		CSQL += " and C9_NFISCAL = '"+cDocOri+"' "
		CSQL += " and E1_TIPO = 'NF' "
		CSQL += " and E1_NATUREZ 	<> '1230' "
		CSQL += " and SC9.D_E_L_E_T_='' "
		CSQL += " and SE1.D_E_L_E_T_='' "
		CSQL += " and SE2.D_E_L_E_T_='' "
		CSQL += " ) "
		CSQL += " update SE2070 "
		CSQL += " set E2_YCHVSE1 = T.CHVSE1 "
		CSQL += " from SE2070 SE2 "
		CSQL += " join tab_SE2 T on T.RECSE2 = SE2.R_E_C_N_O_ "

		TCSQLExec(CSQL)

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