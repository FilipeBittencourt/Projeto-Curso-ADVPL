#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA816
@author Marcos Alberto Soprani
@since 15/11/17
@version 1.0
@description Rotina para processamento do Rateio por Filial em OrcaFinal oriundos de dPessoal
@type function
/*/

User Function BIA816()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para processamento do Rateio por Filial em OrcaFinal oriundos de dPessoal!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA816A() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Rateio por Filial em OrcaFinal'), aSays, aButtons ,,,500)

	If Empty(idVersao) .or. Empty(idRevisa) .or. Empty(idAnoRef)

		MsgStop('Processo Abortado: não foram informados os parâmetros. Favor Verificar!!!')
		lConfirm := .F.
		Return

	EndIf

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
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
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
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
			//(M001)->(dbCloseArea())
			//Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		xfErCta := "Os seguintes MESES apresentam problema de cadastro de percentual:" + msrhEnter + msrhEnter
		xfRetErCta := .F.
		ZG003 := " WITH RATEIORH "
		ZG003 += "      AS (SELECT ZOP_VERSAO, "
		ZG003 += "                 ZOP_REVISA, "
		ZG003 += "                 ZOP_ANOREF, "
		ZG003 += "                 M01 = ROUND(SUM(ZOP_M01), 2), "
		ZG003 += "                 M02 = ROUND(SUM(ZOP_M02), 2), "
		ZG003 += "                 M03 = ROUND(SUM(ZOP_M03), 2), "
		ZG003 += "                 M04 = ROUND(SUM(ZOP_M04), 2), "
		ZG003 += "                 M05 = ROUND(SUM(ZOP_M05), 2), "
		ZG003 += "                 M06 = ROUND(SUM(ZOP_M06), 2), "
		ZG003 += "                 M07 = ROUND(SUM(ZOP_M07), 2), "
		ZG003 += "                 M08 = ROUND(SUM(ZOP_M08), 2), "
		ZG003 += "                 M09 = ROUND(SUM(ZOP_M09), 2), "
		ZG003 += "                 M10 = ROUND(SUM(ZOP_M10), 2), "
		ZG003 += "                 M11 = ROUND(SUM(ZOP_M11), 2), "
		ZG003 += "                 M12 = ROUND(SUM(ZOP_M12), 2) "
		ZG003 += "          FROM " + RetSqlName("ZOP") + " ZOP(NOLOCK) "
		ZG003 += "          WHERE ZOP_FILIAL = '" + xFilial("ZOP") + "' "
		ZG003 += "                AND ZOP_VERSAO = '" + idVersao + "' "
		ZG003 += "                AND ZOP_REVISA = '" + idRevisa + "' "
		ZG003 += "                AND ZOP_ANOREF = '" + idAnoRef + "' "
		ZG003 += "                AND ZOP.D_E_L_E_T_ = ' ' "
		ZG003 += "          GROUP BY ZOP_VERSAO, "
		ZG003 += "                   ZOP_REVISA, "
		ZG003 += "                   ZOP_ANOREF) "
		ZG003 += "      SELECT * "
		ZG003 += "      FROM RATEIORH "
		ZG003 += "      WHERE M01 <> 100 "
		ZG003 += "            OR M02 <> 100 "
		ZG003 += "            OR M03 <> 100 "
		ZG003 += "            OR M04 <> 100 "
		ZG003 += "            OR M05 <> 100 "
		ZG003 += "            OR M06 <> 100 "
		ZG003 += "            OR M07 <> 100 "
		ZG003 += "            OR M08 <> 100 "
		ZG003 += "            OR M09 <> 100 "
		ZG003 += "            OR M10 <> 100 "
		ZG003 += "            OR M11 <> 100 "
		ZG003 += "            OR M12 <> 100 "
		ZGIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZG003),'ZG03',.T.,.T.)
		dbSelectArea("ZG03")
		ZG03->(dbGoTop())
		ProcRegua(LASTREC())
		While ZG03->(!Eof())

			xfErCta += ;
			" M01: " + Transform(ZG03->M01,"@E 999,999.99999999") + ;
			" M02: " + Transform(ZG03->M02,"@E 999,999.99999999") + ;
			" M03: " + Transform(ZG03->M03,"@E 999,999.99999999") + ;
			" M04: " + Transform(ZG03->M04,"@E 999,999.99999999") + ;
			" M05: " + Transform(ZG03->M05,"@E 999,999.99999999") + ;
			" M06: " + Transform(ZG03->M06,"@E 999,999.99999999") + ;
			" M07: " + Transform(ZG03->M07,"@E 999,999.99999999") + ;
			" M08: " + Transform(ZG03->M08,"@E 999,999.99999999") + ;
			" M09: " + Transform(ZG03->M09,"@E 999,999.99999999") + ;
			" M10: " + Transform(ZG03->M10,"@E 999,999.99999999") + ;
			" M11: " + Transform(ZG03->M11,"@E 999,999.99999999") + ;
			" M12: " + Transform(ZG03->M12,"@E 999,999.99999999") 

			xfRetErCta := .T.
			ZG03->(dbSkip())

		End

		xfErCta += msrhEnter
		xfErCta += "Acerte o cadastro de Rateio antes de prosseguir..."

		ZG03->(dbCloseArea())
		Ferase(ZGIndex+GetDBExtension())
		Ferase(ZGIndex+OrdBagExt())

		If xfRetErCta
			MsgSTOP(xfErCta)
			Return
		EndIf

		Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

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
Static Function BIA816A()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA816A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Parâmentros",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
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

	Local msStaExcQy    := 0
	Local lOk           := .T.
	Local msGravaErr    := ""
	msNomeTMP  := "##TMPBIA816" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)     

	ProcRegua(0)

	Begin Transaction

		KS001 := " SELECT * "
		KS001 += " INTO " + msNomeTMP
		KS001 += " FROM " + RetSqlName("ZBZ") + " ZBZ(NOLOCK) "
		KS001 += " WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		KS001 += "       AND ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
		KS001 += "       AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
		KS001 += "       AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
		KS001 += "       AND ZBZ.ZBZ_ORIPRC = 'RH' "
		KS001 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Criando arquivo temporário ZBZ... ",,{|| msStaExcQy := TcSQLExec(KS001) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			KS002 := " DELETE ZBZ "
			KS002 += " FROM " + RetSqlName("ZBZ") + " ZBZ "
			KS002 += " WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
			KS002 += "       AND ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
			KS002 += "       AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
			KS002 += "       AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
			KS002 += "       AND ZBZ.ZBZ_ORIPRC = 'RH' "
			KS002 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| msStaExcQy := TcSQLExec(KS002) })
			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If lOk

				IncProc("Processando...")

				LV007 := " WITH RATEIORH "
				LV007 += "      AS (SELECT ZOP_VERSAO, "
				LV007 += "                 ZOP_REVISA, "
				LV007 += "                 ZOP_ANOREF, "
				LV007 += "                 ZOP_FILORI, "
				LV007 += "                 ZOP_FILDES, "
				LV007 += "                 DTREF = ZOP_ANOREF + SUBSTRING(PERIODO, 6, 2), "
				LV007 += "                 PERCENTUAL "
				LV007 += "          FROM "
				LV007 += "          ( "
				LV007 += "              SELECT ZOP_VERSAO, "
				LV007 += "                     ZOP_REVISA, "
				LV007 += "                     ZOP_ANOREF, "
				LV007 += "                     ZOP_FILORI, "
				LV007 += "                     ZOP_FILDES, "
				LV007 += "                     ZOP_M01, "
				LV007 += "                     ZOP_M02, "
				LV007 += "                     ZOP_M03, "
				LV007 += "                     ZOP_M04, "
				LV007 += "                     ZOP_M05, "
				LV007 += "                     ZOP_M06, "
				LV007 += "                     ZOP_M07, "
				LV007 += "                     ZOP_M08, "
				LV007 += "                     ZOP_M09, "
				LV007 += "                     ZOP_M10, "
				LV007 += "                     ZOP_M11, "
				LV007 += "                     ZOP_M12 "
				LV007 += "              FROM " + RetSqlName("ZOP") + " ZOP(NOLOCK) "
				LV007 += "              WHERE ZOP_FILIAL = '" + xFilial("ZOP") + "' "
				LV007 += "                    AND ZOP_VERSAO = '" + idVersao + "' "
				LV007 += "                    AND ZOP_REVISA = '" + idRevisa + "' "
				LV007 += "                    AND ZOP_ANOREF = '" + idAnoRef + "' "
				LV007 += "                    AND ZOP.D_E_L_E_T_ = ' ' "
				LV007 += "          ) P UNPIVOT(PERCENTUAL FOR PERIODO IN(ZOP_M01, "
				LV007 += "                                                ZOP_M02, "
				LV007 += "                                                ZOP_M03, "
				LV007 += "                                                ZOP_M04, "
				LV007 += "                                                ZOP_M05, "
				LV007 += "                                                ZOP_M06, "
				LV007 += "                                                ZOP_M07, "
				LV007 += "                                                ZOP_M08, "
				LV007 += "                                                ZOP_M09, "
				LV007 += "                                                ZOP_M10, "
				LV007 += "                                                ZOP_M11, "
				LV007 += "                                                ZOP_M12)) AS UNPVT) "
				LV007 += "      INSERT INTO " + RetSqlName("ZBZ") + " "
				LV007 += "      (ZBZ_FILIAL, "
				LV007 += "       ZBZ_VERSAO, " 
				LV007 += "       ZBZ_REVISA, "
				LV007 += "       ZBZ_ANOREF, "
				LV007 += "       ZBZ_ORIPRC, "
				LV007 += "       ZBZ_ORGLAN, "
				LV007 += "       ZBZ_DATA, "
				LV007 += "       ZBZ_LOTE, "
				LV007 += "       ZBZ_SBLOTE, "
				LV007 += "       ZBZ_DOC, "
				LV007 += "       ZBZ_LINHA, "
				LV007 += "       ZBZ_DC, "
				LV007 += "       ZBZ_DEBITO, " 
				LV007 += "       ZBZ_CREDIT, "
				LV007 += "       ZBZ_CLVLDB, "
				LV007 += "       ZBZ_CLVLCR, "
				LV007 += "       ZBZ_ITEMD, "
				LV007 += "       ZBZ_ITEMC, "
				LV007 += "       ZBZ_VALOR, "
				LV007 += "       ZBZ_HIST, "
				LV007 += "       ZBZ_YHIST, "
				LV007 += "       ZBZ_SI, "
				LV007 += "       ZBZ_YDELTA, " 
				LV007 += "       D_E_L_E_T_, "
				LV007 += "       R_E_C_N_O_, "
				LV007 += "       R_E_C_D_E_L_, "
				LV007 += "       ZBZ_ORIPR2, "
				LV007 += "       ZBZ_APLIC, "
				LV007 += "       ZBZ_DRVDB, "
				LV007 += "       ZBZ_DRVCR, "
				LV007 += "       ZBZ_NEGOCI, "
				LV007 += "       ZBZ_CENARI "
				LV007 += "      ) "
				LV007 += "             SELECT ZBZ_FILIAL = RRH.ZOP_FILDES, "
				LV007 += "                    ZBZ_VERSAO, "
				LV007 += "                    ZBZ_REVISA, "
				LV007 += "                    ZBZ_ANOREF, "
				LV007 += "                    ZBZ_ORIPRC, "
				LV007 += "                    ZBZ_ORGLAN, "
				LV007 += "                    ZBZ_DATA, "
				LV007 += "                    ZBZ_LOTE, "
				LV007 += "                    ZBZ_SBLOTE, "
				LV007 += "                    ZBZ_DOC, "
				LV007 += "                    ZBZ_LINHA, "
				LV007 += "                    ZBZ_DC, "
				LV007 += "                    ZBZ_DEBITO, "
				LV007 += "                    ZBZ_CREDIT, "
				LV007 += "                    ZBZ_CLVLDB, "
				LV007 += "                    ZBZ_CLVLCR, "
				LV007 += "                    ZBZ_ITEMD, "
				LV007 += "                    ZBZ_ITEMC, "
				LV007 += "                    ZBZ_VALOR = ROUND(ZBZ_VALOR * RRH.PERCENTUAL / 100, 8), "
				LV007 += "                    ZBZ_HIST, "
				LV007 += "                    ZBZ_YHIST = RTRIM(ZBZ_YHIST) + ' ... % RATEIO ' + CONVERT(VARCHAR, RRH.PERCENTUAL), "
				LV007 += "                    ZBZ_SI, "
				LV007 += "                    ZBZ_YDELTA, "
				LV007 += "                    D_E_L_E_T_ = ' ', "
				LV007 += "                    R_E_C_N_O_ = "
				LV007 += "             ( "
				LV007 += "                 SELECT ISNULL(MAX(R_E_C_N_O_), 0) "
				LV007 += "                 FROM " + RetSqlName("ZBZ") + " XXX(NOLOCK) "
				LV007 += "             ) + ROW_NUMBER() OVER( "
				LV007 += "             ORDER BY ZBZ.R_E_C_N_O_), "
				LV007 += "                    R_E_C_D_E_L_ = 0, "
				LV007 += "                    ZBZ_ORIPR2, "
				LV007 += "                    ZBZ_APLIC, "
				LV007 += "                    ZBZ_DRVDB, "
				LV007 += "                    ZBZ_DRVCR, "
				LV007 += "                    ZBZ_NEGOCI, "
				LV007 += "                    ZBZ_CENARI "
				LV007 += "             FROM " + msNomeTMP + " ZBZ(NOLOCK) "
				LV007 += "                  INNER JOIN RATEIORH RRH ON RRH.ZOP_VERSAO = ZBZ.ZBZ_VERSAO "
				LV007 += "                                             AND RRH.ZOP_REVISA = ZBZ.ZBZ_REVISA "
				LV007 += "                                             AND RRH.ZOP_ANOREF = ZBZ.ZBZ_ANOREF "
				LV007 += "                                             AND RRH.ZOP_FILORI = ZBZ.ZBZ_FILIAL "
				LV007 += "                                             AND RRH.DTREF = SUBSTRING(ZBZ.ZBZ_DATA, 1, 6) "
				LV007 += "             WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
				LV007 += "                   AND ZBZ_VERSAO = '" + idVersao + "' "
				LV007 += "                   AND ZBZ_REVISA = '" + idRevisa + "' "
				LV007 += "                   AND ZBZ_ANOREF = '" + idAnoRef + "' "
				LV007 += "                   AND ZBZ_ORIPRC = 'RH' "
				LV007 += "                   AND ZBZ.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Rateio por Filial em OrcaFinal...",,{|| msStaExcQy := TcSQLExec(LV007) })
				If msStaExcQy < 0
					lOk := .F.
				EndIf

				If !lOk

					msGravaErr := TCSQLError()
					DisarmTransaction()

				EndIf

			Else

				msGravaErr := TCSQLError()
				DisarmTransaction()

			EndIf

		Else

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 

	If lOk

		MsgINFO("Conversão do Rateio por Filial em OrcaFinal realizada com sucesso!!!")

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return
