#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA649
@author Marcos Alberto Soprani
@since 15/11/17
@version 1.0
@description Rotina para transporte dos dados de modelo de RECEITA para o de OrcaFinal do processo orçamentário
@type function
/*/

User Function BIA649()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private idMarca     := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados de modelo de RECEITA para o de OrcaFinal!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA649A() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração RECEITA com OrcaFinal'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
		xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:idVersao%
			AND ZB5.ZB5_REVISA = %Exp:idRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:idAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		xfErCta := "Os seguintes Formatos/Categorias apresentam problema de cadastro de produto:" + msrhEnter + msrhEnter
		xfRetErCta := .F.
		ZG003 := " SELECT ZBH_FORMAT FORMATO, "
		ZG003 += "        ZBH_CATEG CATEG "
		ZG003 += " FROM " + RetSqlName("ZBH") + " ZBH "
		ZG003 += "      LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		ZG003 += "                              AND B1_TIPO = 'PA' "
		ZG003 += "                              AND B1_YCLASSE = '1' "
		ZG003 += "                              AND SB1.B1_YFORMAT = ZBH_FORMAT "
		ZG003 += "                              AND SB1.B1_YCATEG = ZBH_CATEG "
		ZG003 += "                              AND SB1.B1_YTPPROD <> '  ' "
		ZG003 += "                              AND SB1.B1_MSBLQL <> '1' "
		ZG003 += "                              AND SB1.D_E_L_E_T_ = ' ' "
		ZG003 += "      LEFT JOIN " + RetSqlName("SZ6") + " SZ6 ON Z6_TPPROD = B1_YTPPROD "
		ZG003 += "                              AND SZ6.D_E_L_E_T_ = ' ' "
		ZG003 += " WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
		ZG003 += "       AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
		ZG003 += "       AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
		ZG003 += "       AND ZBH.ZBH_MARCA = '" + idMarca + "' "
		ZG003 += "       AND ZBH.ZBH_ORIGF = '1' "
		ZG003 += "       AND Z6_CTRSVDI IS NULL "
		ZG003 += "       AND ZBH.D_E_L_E_T_ = ' ' "
		ZG003 += " GROUP BY ZBH_FORMAT, "
		ZG003 += "          ZBH_CATEG "
		ZGIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZG003),'ZG03',.T.,.T.)
		dbSelectArea("ZG03")
		ZG03->(dbGoTop())
		ProcRegua(LASTREC())
		While ZG03->(!Eof())

			xfErCta += "Formato: " + ZG03->FORMATO + ", categoria: " + ZG03->CATEG + msrhEnter
			xfRetErCta := .T.
			ZG03->(dbSkip())

		End

		xfErCta += msrhEnter
		xfErCta += "Acerte o cadastro de produto corriga o erro antes de prosseguir..."

		ZG03->(dbCloseArea())
		Ferase(ZGIndex+GetDBExtension())
		Ferase(ZGIndex+OrdBagExt())

		If xfRetErCta
			MsgSTOP(xfErCta)
			Return
		EndIf

		nxContaProc := 0
		SL008 := " SELECT ZBL.ZBL_EMPRP EMPR "
		SL008 += "   FROM " + RetSqlName("ZBH") + " ZBH "
		SL008 += "  INNER JOIN " + RetSqlName("ZBL") + " ZBL ON ZBL.ZBL_VERSAO = ZBH.ZBH_VERSAO "
		SL008 += "                       AND ZBL.ZBL_REVISA = ZBH.ZBH_REVISA "
		SL008 += "                       AND ZBL.ZBL_ANOREF = ZBH.ZBH_ANOREF "
		SL008 += "                       AND ZBL.ZBL_MARCA = ZBH.ZBH_MARCA "
		SL008 += "                       AND ZBL.ZBL_CANALD = ZBH.ZBH_CANALD "
		SL008 += "                       AND ZBL.D_E_L_E_T_ = ' ' "
		SL008 += "  WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
		SL008 += "    AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
		SL008 += "    AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
		SL008 += "    AND ZBH.ZBH_MARCA = '" + idMarca + "' "
		SL008 += "    AND ZBH.ZBH_PERIOD <> '00' "
		SL008 += "    AND ZBH.ZBH_ORIGF = '5' "
		SL008 += "    AND ZBH.D_E_L_E_T_ = ' ' "
		SL008 += "  GROUP BY ZBL.ZBL_EMPRP "
		SL008 += "  ORDER BY ZBL.ZBL_EMPRP "
		SLIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,SL008),'SL08',.T.,.T.)
		dbSelectArea("SL08")
		SL08->(dbGoTop())
		ProcRegua(LASTREC())
		While SL08->(!Eof())

			ksEmpres := SL08->EMPR

			M0007 := " SELECT COUNT(*) CONTAD "
			M0007 += "   FROM ZBZ" + ksEmpres + "0 ZBZ "
			M0007 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
			M0007 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
			M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
			M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'RECEITA' "
			M0007 += "    AND ZBZ.ZBZ_ORIPR2 = 'MARCA_" + idMarca + "' "
			M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
			MSIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
			dbSelectArea("M007")
			M007->(dbGoTop())
			If M007->CONTAD <> 0
				nxContaProc += M007->CONTAD
			EndIf

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			SL08->(dbSkip())

		End

		SL08->(dbCloseArea())
		Ferase(SLIndex+GetDBExtension())
		Ferase(SLIndex+OrdBagExt())

		If nxContaProc <> 0

			xkContinua := MsgNOYES("Já existe base contábel orçamentária para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		If xkContinua

			Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

		Else

			MsgStop('Processo Abortado!!!')

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA649A()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA649A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 
	idMarca  		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Marca:"                       ,idMarca     ,"@!","NAOVAZIO()",'Z37','.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração RECEITA p/ OrcaFinal",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
		idMarca     := ParamLoad(cFileName,,4,idMarca) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcIntMD()

	Local lvxt

	SL008 := " SELECT ZBL.ZBL_EMPRP EMPR "
	SL008 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	SL008 += "  INNER JOIN " + RetSqlName("ZBL") + " ZBL ON ZBL.ZBL_VERSAO = ZBH.ZBH_VERSAO "
	SL008 += "                       AND ZBL.ZBL_REVISA = ZBH.ZBH_REVISA "
	SL008 += "                       AND ZBL.ZBL_ANOREF = ZBH.ZBH_ANOREF "
	SL008 += "                       AND ZBL.ZBL_MARCA = ZBH.ZBH_MARCA "
	SL008 += "                       AND ZBL.ZBL_CANALD = ZBH.ZBH_CANALD "
	SL008 += "                       AND ZBL.D_E_L_E_T_ = ' ' "
	SL008 += "  WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
	SL008 += "    AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
	SL008 += "    AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
	SL008 += "    AND ZBH.ZBH_MARCA = '" + idMarca + "' "
	SL008 += "    AND ZBH.ZBH_PERIOD <> '00' "
	SL008 += "    AND ZBH.ZBH_ORIGF = '5' "
	SL008 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	SL008 += "  GROUP BY ZBL.ZBL_EMPRP "
	SL008 += "  ORDER BY ZBL.ZBL_EMPRP "
	SLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SL008),'SL08',.T.,.T.)
	dbSelectArea("SL08")
	SL08->(dbGoTop())
	ProcRegua(LASTREC())
	If SL08->(!Eof())

		While SL08->(!Eof())

			ksEmpres := SL08->EMPR
			While SL08->(!Eof()) .and. SL08->EMPR == ksEmpres  

				KS001 := " DELETE ZBZ" + ksEmpres + "0 "
				KS001 += "   FROM ZBZ" + ksEmpres + "0 ZBZ "
				KS001 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
				KS001 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
				KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
				KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'RECEITA' "
				KS001 += "    AND ZBZ.ZBZ_ORIPR2 = 'MARCA_" + idMarca + "' "
				KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| TcSQLExec(KS001) })

				oxlVetRec := {}
				aadd(oxlVetRec, {"VENDAS"   ,"ZBH_TOTAL"  ,"2"} )
				aadd(oxlVetRec, {"COMISSAO" ,"ZBH_VCOMIS" ,"1"} ) 
				aadd(oxlVetRec, {"ICMS"     ,"ZBH_VICMS"  ,"2"} )
				aadd(oxlVetRec, {"PIS"      ,"ZBH_VPIS"   ,"2"} )
				aadd(oxlVetRec, {"COFINS"   ,"ZBH_VCOF"   ,"2"} )
				aadd(oxlVetRec, {"ST"       ,"ZBH_VST"    ,"2"} )
				aadd(oxlVetRec, {"DIFAL"    ,"ZBH_VDIFAL" ,"2"} )
				aadd(oxlVetRec, {"VALVER"  ,"ZBH_VALVER + ZBH_VALCPV" ,"1"} )
				aadd(oxlVetRec, {"ICMSBON"  ,"ZBH_VICMBO" ,"1"} )

				For lvxt := 1 to Len(oxlVetRec)

					IncProc("Empresa: " + ksEmpres + ", " + AllTrim(Str(lvxt)) )

					LV007 := " WITH DCONTABEIS AS (SELECT ZBH_FORMAT FORMATO, "
					LV007 += "                            ZBH_CATEG CATEG, "
					LV007 += "                            B1_YTPPROD, "
					LV007 += "                            Z6_CTRSVDI VENDAS, "
					LV007 += "                            '31403001' COMISSAO, "
					LV007 += "                            Z6_CTAICMS ICMS, "
					LV007 += "                            Z6_CTAPIS PIS, "
					LV007 += "                            Z6_CTACOF COFINS, "
					LV007 += "                            Z6_CTICMST ST, "
					LV007 += "                            '31401020' VALVER, "
					LV007 += "                            '31701002' ICMSBON, "					
					LV007 += "                            Z6_CTAICMS DIFAL "
					LV007 += "                       FROM " + RetSqlName("ZBH") + " ZBH "
					LV007 += "                       LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
					LV007 += "                                           AND B1_TIPO = 'PA' "
					LV007 += "                                           AND B1_YCLASSE = '1' "
					LV007 += "                                           AND SB1.B1_YFORMAT = ZBH_FORMAT "
					LV007 += "                                           AND SB1.B1_YCATEG = ZBH_CATEG "
					LV007 += "                                           AND SB1.B1_MSBLQL <> '1' "
					LV007 += "                                           AND SB1.B1_YTPPROD <> ' ' "
					LV007 += "                                           AND SB1.D_E_L_E_T_= ' ' "
					LV007 += "                       LEFT JOIN " + RetSqlName("SZ6") + " SZ6 ON Z6_TPPROD = B1_YTPPROD "
					LV007 += "                                           AND SZ6.D_E_L_E_T_= ' ' "
					LV007 += "                      WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
					LV007 += "                        AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
					LV007 += "                        AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
					LV007 += "                        AND ZBH.ZBH_MARCA = '" + idMarca + "' "
					LV007 += "                        AND ZBH.ZBH_ORIGF = '1' "
					LV007 += "                        AND ZBH.D_E_L_E_T_ = ' ' "
					LV007 += "                   GROUP BY ZBH_FORMAT, "
					LV007 += "                            ZBH_CATEG, "
					LV007 += "                            B1_YTPPROD, "
					LV007 += "                            Z6_CTRSVDI, "
					LV007 += "                            Z6_CTAICMS, "
					LV007 += "                            Z6_CTAPIS, "
					LV007 += "                            Z6_CTACOF, "
					LV007 += "                            Z6_CTICMST) "
					LV007 += " INSERT INTO ZBZ" + ksEmpres + "0 "
					LV007 += " (ZBZ_FILIAL, "
					LV007 += "  ZBZ_VERSAO, "
					LV007 += "  ZBZ_REVISA, "
					LV007 += "  ZBZ_ANOREF, "
					LV007 += "  ZBZ_ORIPRC, "
					LV007 += "  ZBZ_ORGLAN, "
					LV007 += "  ZBZ_DATA, "
					LV007 += "  ZBZ_LOTE, "
					LV007 += "  ZBZ_SBLOTE, "
					LV007 += "  ZBZ_DOC, "
					LV007 += "  ZBZ_LINHA, "
					LV007 += "  ZBZ_DC, "
					LV007 += "  ZBZ_DEBITO, "
					LV007 += "  ZBZ_CREDIT, "
					LV007 += "  ZBZ_CLVLDB, "
					LV007 += "  ZBZ_CLVLCR, "
					LV007 += "  ZBZ_ITEMD, "
					LV007 += "  ZBZ_ITEMC, "
					LV007 += "  ZBZ_VALOR, "
					LV007 += "  ZBZ_HIST, "
					LV007 += "  ZBZ_YHIST, "
					LV007 += "  ZBZ_SI, "
					LV007 += "  ZBZ_YDELTA, "
					LV007 += "  D_E_L_E_T_, "
					LV007 += "  R_E_C_N_O_, "
					LV007 += "  R_E_C_D_E_L_, "
					LV007 += "  ZBZ_ORIPR2) "
					LV007 += " SELECT ZBH_FILIAL,
					LV007 += "        ZBH_VERSAO, "
					LV007 += "        ZBH_REVISA, "
					LV007 += "        ZBH_ANOREF, "
					LV007 += "        'RECEITA' ORIPRC, "
					LV007 += "        '" + IIF(oxlVetRec[lvxt][3] == "1", "D", "C") + "' ORGLAN, "
					LV007 += "        ZBH_DATA, "
					LV007 += "        '005100' LOTE, "
					LV007 += "        '001' SBLOTE, "
					LV007 += "        '' DOC, "
					LV007 += "        '' LINHA, "
					LV007 += "        '" + oxlVetRec[lvxt][3] + "' DC, "
					LV007 += "        " + IIF(oxlVetRec[lvxt][3] == "1", "CONTA", "''") + " DEBITO, "
					LV007 += "        " + IIF(oxlVetRec[lvxt][3] == "1", "''", "CONTA") + " CREDIT, "
					LV007 += "        " + IIF(oxlVetRec[lvxt][3] == "1", "CLVL", "''") + " CLVLDB, "
					LV007 += "        " + IIF(oxlVetRec[lvxt][3] == "1", "''", "''") + " CLVLCR, "
					LV007 += "        '' ITEMD, "
					LV007 += "        '' ITEMC, "
					LV007 += "        SUM(VALOR) VALOR, "
					LV007 += "        'ORCTO RECEITA' HIST, "
					LV007 += "        'ORCAMENTO RECEITA' ZBZ_YHIST, "
					LV007 += "        '' ZBZ_SI, "
					LV007 += "        '' ZBZ_YDELTA, "
					LV007 += "        ' ' D_E_L_E_T_, "
					LV007 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZBZ" + ksEmpres + "0) + ROW_NUMBER() OVER(ORDER BY CLVL, CONTA) AS R_E_C_N_O_, "
					LV007 += "        0 R_E_C_D_E_L_, "
					LV007 += "       'MARCA_" + idMarca + "' ORIPR2 "
					LV007 += "   FROM (SELECT ZBH_FILIAL, "
					LV007 += "                ZBH_VERSAO, "
					LV007 += "                ZBH_REVISA, "
					LV007 += "                ZBH_ANOREF, "
					LV007 += "                ZBH_ANOREF + ZBH_PERIOD + '01' ZBH_DATA, "
					LV007 += "                ZBL_CLVL CLVL, "
					LV007 += "                " + oxlVetRec[lvxt][1] + " CONTA, "
					LV007 += "                " + oxlVetRec[lvxt][2] + " VALOR "
					LV007 += "           FROM " + RetSqlName("ZBH") + " ZBH "
					LV007 += "           LEFT JOIN DCONTABEIS DCTB ON FORMATO = ZBH_FORMAT "
					LV007 += "                                    AND CATEG = ZBH_CATEG "
					LV007 += "          INNER JOIN " + RetSqlName("ZBL") + " ZBL ON ZBL.ZBL_VERSAO = ZBH.ZBH_VERSAO "
					LV007 += "                               AND ZBL.ZBL_REVISA = ZBH.ZBH_REVISA "
					LV007 += "                               AND ZBL.ZBL_ANOREF = ZBH.ZBH_ANOREF "
					LV007 += "                               AND ZBL.ZBL_MARCA = ZBH.ZBH_MARCA "
					LV007 += "                               AND ZBL.ZBL_CANALD = ZBH.ZBH_CANALD "
					LV007 += "                               AND ZBL.ZBL_EMPRP = '" + ksEmpres + "' "
					LV007 += "                               AND ZBL.D_E_L_E_T_ = ' ' "
					LV007 += "          WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
					LV007 += "            AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
					LV007 += "            AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
					LV007 += "            AND ZBH.ZBH_MARCA = '" + idMarca + "' "
					LV007 += "            AND ZBH.ZBH_PERIOD <> '00' "
					LV007 += "            AND ZBH.ZBH_ORIGF = '5' "
					LV007 += "            AND ZBH.D_E_L_E_T_ = ' ') AS TABL "
					LV007 += "     WHERE VALOR <> 0 "
					LV007 += "  GROUP BY ZBH_FILIAL, "
					LV007 += "           ZBH_VERSAO, "
					LV007 += "           ZBH_REVISA, "
					LV007 += "           ZBH_ANOREF, "
					LV007 += "           ZBH_DATA, "
					LV007 += "           CLVL, "
					LV007 += "           CONTA "
					LV007 += "  ORDER BY ZBH_DATA, "
					LV007 += "           ZBH_VERSAO, "
					LV007 += "           ZBH_REVISA, "
					LV007 += "           ZBH_ANOREF, "
					LV007 += "           CLVL, "
					LV007 += "           CONTA "

					U_BIAMsgRun("Aguarde... Convertendo modelo de RECEITA em OrcaFinal... ",,{|| TcSQLExec(LV007) })

				Next lvxt

				SL08->(dbSkip())

			EndDo

		EndDo

	EndIf	

	xkFechamen := MsgNOYES("Deseja fechar definitivamente a Versão Orçamentária?" + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar o FECHAMENTO DEFINITIVO da versão impossibilitando este processamento para as outras empresas que ainda não receberam este processamento." + msrhEnter + msrhEnter+ "Confirma o fechamento da versão? Caso não haja nenhuma empresa a ser processada, pode confirmar.")

	If xkFechamen

		dbSelectArea("SL08")
		SL08->(dbGoTop())
		ProcRegua(LASTREC())
		If SL08->(!Eof())

			While SL08->(!Eof())

				ksEmpres := SL08->EMPR
				While SL08->(!Eof()) .and. SL08->EMPR == ksEmpres  

					ZP001 := " UPDATE ZB5 SET ZB5_STATUS = 'F' "
					ZP001 += "   FROM ZB5" + ksEmpres + "0 ZB5 "
					ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
					ZP001 += "    AND ZB5.ZB5_VERSAO = '" + idVersao + "' "
					ZP001 += "    AND ZB5.ZB5_REVISA = '" + idRevisa + "' "
					ZP001 += "    AND ZB5.ZB5_ANOREF = '" + idAnoRef + "' "
					ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA' "
					ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
					U_BIAMsgRun("Aguarde... Fechando Versão Orçamentária ... ",,{|| TcSQLExec(ZP001) })

					SL08->(dbSkip())

				EndDo

			EndDo

		EndIf	

	EndIf

	SL08->(dbCloseArea())
	Ferase(SLIndex+GetDBExtension())
	Ferase(SLIndex+OrdBagExt())

	MsgINFO("Conversão do modelo RECEITA em OrcaFinal realizada com sucesso!!!")

Return
