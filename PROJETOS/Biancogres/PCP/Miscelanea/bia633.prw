#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA633
@author Marcos Alberto Soprani
@since 02/11/17
@version 1.0
@description Browser principal para a rotina de OBZ Integration p/ Or�amento
@type function
/*/

User Function BIA633()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Local oEmp 			:= TLoadEmpresa():New()
	Local nW

	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.
	Private msEmpAtu    := cEmpAnt
	Private msFilAtu    := cFilAnt
	Private msGravaErr  := ""

	If cEmpAnt <> "01"
		Msgbox("Esta rotina poder� ser utilizada somente na empresa 01", "BIA633", "STOP")
		Return
	EndIf

	If cEmpAnt == "01" .and. cFilAnt <> "01"
		Msgbox("Esta rotina poder� ser utilizada somente na empresa 01, Filial 01, devido as amarra��es com as tabelas origens.", "BIA633", "STOP")
		Return
	EndIf

	AADD(aSays, OemToAnsi("Rotina para Gera��o de Integra��o dos registros OBZ com Modelo de OrcaFinal!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os par�metros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergIntMD() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integra��o OBZ com OrcaFinal'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Or�amento igual OBZ" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digita��o diferente de branco" + msrhEnter
		xfMensCompl += "Data Concilia��o diferente de branco" + msrhEnter
		xfMensCompl += "Data Encerramento diferente de branco e menor ou igual DataBase" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:idVersao%
			AND ZB5.ZB5_REVISA = %Exp:idRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:idAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A vers�o informada n�o est� ativa para execu��o deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de vers�o conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o respons�vel pelo processo Or�ament�rio!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
		M0007 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
		M0007 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
		M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
		M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'OBZ' "
		M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("J� existe base cont�bel or�ament�ria para a Vers�o / Revis�o / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema ir� efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			oEmp:GSEmpFil()

			If Len(oEmp:aEmpSel) > 0

				RpcSetType(3)
				RpcSetEnv( cEmpAnt, cFilAnt )
				RpcClearEnv()

				For nW := 1 To Len(oEmp:aEmpSel)

					RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

					smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])

					xVerRet := .F.
					oProcess := MsNewProcess():New({|lEnd| fProcIntMD(@oProcess) }, "Gravando...", smMsnPrc, .T.)
					oProcess:Activate()

					If xVerRet

						RpcClearEnv()

					Else

						Exit

					EndIf

				Next nW

				RpcSetEnv( msEmpAtu, msFilAtu )

				If Type("__cInternet") == "C"
					__cInternet := Nil
				EndIf

				If xVerRet

					MsgINFO("Fim do processamento...", "BIA633")

				Else 

					MsgSTOP("Erro na execu��o do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!", "BIA633" )
					Return

				EndIf

				fVerEmp()	

			Else

				Aviso("OBZ Integration - BIA633", "N�o foram selecionadas empresas! Processamento n�o realizado" , {'Ok'}, 3)

			EndIf

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
��� Parametros                                                            ���
��+-----------------------------------------------------------------------���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fPergIntMD()

	Local aPergs 	:= {}
	Local cLoad	    := 'B633IMDD' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Vers�o:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revis�o:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Or�ament�rio: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integra��o OBZ p/ OrcaFinal",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
	Endif

Return 

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
��� Processamento                                                         ���
��+-----------------------------------------------------------------------���
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fProcIntMD(oProcess)

	Local lvxt
	Local msStaExcQy    := 0
	Local lOk           := .T.

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	oProcess:IncRegua2("Verificando Tabelas...")

	Begin Transaction

		KS001 := " DELETE ZBZ "
		KS001 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
		KS001 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
		KS001 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
		KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
		KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'OBZ' "
		KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
		oProcess:IncRegua2("Aguarde... Apagando registros ZBZ... ")
		U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| msStaExcQy := TcSQLExec(KS001) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			//TcSQLExec(KS001)

			For lvxt := 1 to 12

				IncProc("Processando m�s " + AllTrim(Str(lvxt)) )

				ghDtRef := idAnoRef + StrZero(lvxt,2) + "01"

				// Preenchimento permitido para o campo Z98_APLIC, conforme SX3
				// 0=Nenhum;1=Producao;2=Manutencao;3=Melhoria_M;4=Seguranca;5=Calibracao;6=Melhoria_Prod;7=Administrativo;8=Fiscal;9=Patrimonial;

				LV007 := " WITH OBZINTEG AS (SELECT ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') EMPR, "
				LV007 += "                          Z98_FILIAL, "
				LV007 += "                          Z98_VERSAO, "
				LV007 += "                          Z98_REVISA, "
				LV007 += "                          Z98_ANOREF, "
				LV007 += "                          Z98_CLVL, "
				LV007 += "                          Z98_CONTA, "
				LV007 += "                          Z98_EMPR, "
				LV007 += "                          Z98_FIL, "
				LV007 += "                          ISNULL(CT1_NORMAL, 'E') CT1_NORMAL, "
				LV007 += "                          Z98_APLIC = CASE "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = ''               THEN '0' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'NENHUM'         THEN '0' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'PRODUCAO'       THEN '1' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'MANUTENCAO'     THEN '2' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'MELHORIA_M'     THEN '3' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'SEGURANCA'      THEN '4' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'CALIBRACAO'     THEN '5' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'MELHORIA_PROD'  THEN '6' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'ADMINISTRATIVO' THEN '7' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'FISCAL'         THEN '8' "
				LV007 += "                                        WHEN UPPER(RTRIM(Z98_APLIC)) = 'PATRIMONIAL'    THEN '9' "
				LV007 += "                                        ELSE 'Z' "
				LV007 += "                                      END, "
				LV007 += "                          Z98_IDDRV, "
				LV007 += "                          Z98_CENARI, "
				LV007 += "                          SUM(Z98_M" + StrZero(lvxt,2) + ") MESREF "
				LV007 += "                     FROM " + RetSqlName("Z98") + " Z98 "
				LV007 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = Z98_CONTA "
				LV007 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
				LV007 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = Z98_CLVL "
				LV007 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
				LV007 += "                    WHERE Z98.Z98_VERSAO = '" + idVersao + "' "
				LV007 += "                      AND Z98.Z98_REVISA = '" + idRevisa + "' "
				LV007 += "                      AND Z98.Z98_ANOREF = '" + idAnoRef + "' "
				LV007 += "                      AND SUBSTRING(Z98.Z98_CONTA,1,3) NOT IN('165','168') "
				LV007 += "                      AND RTRIM(Z98_CENARI) NOT IN('ESFORCO OBZ') "
				LV007 += "                      AND RTRIM(Z98_CENARI) NOT IN('CORTE') " 
				LV007 += "                      AND Z98_CONTA <> '' "
				LV007 += "                      AND Z98_M01 + Z98_M02 + Z98_M03 + Z98_M04 + Z98_M05 + Z98_M06 + Z98_M07 + Z98_M08 + Z98_M09 + Z98_M10 + Z98_M11 + Z98_M12 <> 0 "
				LV007 += "                      AND Z98.D_E_L_E_T_ = ' ' "
				LV007 += "                    GROUP BY SUBSTRING(CTH_YEFORC,1,2), "
				LV007 += "                             Z98_FILIAL, "
				LV007 += "                             Z98_VERSAO, "
				LV007 += "                             Z98_REVISA, "
				LV007 += "                             Z98_ANOREF, "
				LV007 += "                             Z98_CLVL, "
				LV007 += "                             Z98_CONTA, "
				LV007 += "                             Z98_EMPR, "
				LV007 += "                             Z98_FIL, "
				LV007 += "                             CT1_NORMAL, "
				LV007 += "                             Z98_APLIC, "
				LV007 += "                             Z98_IDDRV, "
				LV007 += "                             Z98_CENARI) "
				LV007 += " INSERT INTO " + RetSqlName("ZBZ") + " "
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
				LV007 += "  ZBZ_APLIC, "
				LV007 += "  ZBZ_DRVDB, "
				LV007 += "  ZBZ_DRVCR, "
				LV007 += "  ZBZ_NEGOCI, "
				LV007 += "  ZBZ_CENARI) "
				LV007 += " SELECT Z98_FIL Z98_FILIAL, "
				LV007 += "        Z98_VERSAO, "
				LV007 += "        Z98_REVISA, "
				LV007 += "        Z98_ANOREF, "
				LV007 += "        'OBZ' ZBZ_ORIPRC, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN 'D' "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN 'C' "
				LV007 += "          ELSE 'E' "
				LV007 += "        END ZBZ_ORGLAN, "
				LV007 += "        '" + ghDtRef + "' ZBZ_DATA, "
				LV007 += "        '004500'ZBZ_LOTE, "
				LV007 += "        '001' ZBZ_SBLOTE, "
				LV007 += "        '' ZBZ_DOC, "
				LV007 += "        '' ZBZ_LINHA, "
				LV007 += "        CT1_NORMAL ZBZ_DC, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN Z98_CONTA "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_DEBITO, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN Z98_CONTA "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_CREDIT, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN Z98_CLVL "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_CLVLDB, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN Z98_CLVL "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_CLVLCR, "
				LV007 += "        ' ' ZBZ_ITEMD, "
				LV007 += "        ' ' ZBZ_ITEMC, "
				LV007 += "        MESREF ZBZ_VALOR, "
				LV007 += "        'ORCTO OBZ' ZBZ_HIST, "
				LV007 += "        'ORCAMENTO OBZ' ZBZ_YHIST, "
				LV007 += "        '' ZBZ_SI, "
				LV007 += "        '' ZBZ_YDELTA, "
				LV007 += "        ' ' D_E_L_E_T_, "
				LV007 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZBZ") + ") + ROW_NUMBER() OVER(ORDER BY OBZI.Z98_CLVL, OBZI.Z98_CONTA) AS R_E_C_N_O_, "
				LV007 += "        0 R_E_C_D_E_L_, "
				LV007 += "        Z98_APLIC, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN Z98_IDDRV "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_DRVDB, "
				LV007 += "        CASE "
				LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
				LV007 += "          WHEN CT1_NORMAL = '2' THEN Z98_IDDRV "
				LV007 += "          ELSE '' "
				LV007 += "        END ZBZ_DRVCR, "
				LV007 += "        '' NEGOCIO, "
				LV007 += "        Z98_CENARI "
				LV007 += "   FROM OBZINTEG OBZI "
				LV007 += "  WHERE NOT ( CT1_NORMAL = 'E' OR EMPR = 'ER' ) "
				LV007 += "    AND EMPR = '" + cEmpAnt + "' "
				LV007 += "    AND MESREF <> 0 "
				oProcess:IncRegua2("Aguarde... Convertendo OBZ em OrcaFinal...")
				U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| msStaExcQy := TcSQLExec(LV007) })
				If msStaExcQy < 0
					lOk := .F.
					Exit
				EndIf

				//TcSQLExec(LV007)

			Next lvxt

			If lOk

				ZP001 := " UPDATE ZB5 SET ZB5_STATUS = 'F' "
				ZP001 += "   FROM " + RetSqlName("ZB5") + " ZB5 "
				ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
				ZP001 += "    AND ZB5.ZB5_VERSAO = '" + idVersao + "' "
				ZP001 += "    AND ZB5.ZB5_REVISA = '" + idRevisa + "' "
				ZP001 += "    AND ZB5.ZB5_ANOREF = '" + idAnoRef + "' "
				ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ' "
				ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
				oProcess:IncRegua2("Aguarde... Fechando Vers�o Or�ament�ria...")
				U_BIAMsgRun("Aguarde... Fechando Vers�o Or�ament�ria... ",,{|| msStaExcQy := TcSQLExec(ZP001) })

				If msStaExcQy < 0
					lOk := .F.
				EndIf

			EndIf

			//TcSQLExec(ZP001)

		EndIf

		If !lOk

			xVerRet := .F.
			msGravaErr := TCSQLError()
			DisarmTransaction()

		Else

			xVerRet := .T.

		EndIf

	End Transaction

Return

Static Function fVerEmp()

	Local trrhEnter := CHR(13) + CHR(10)
	Local ny

	trEmprToO := {}
	RQ002 := " WITH OBZINTEG AS (SELECT ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') EMPR "
	RQ002 += "                     FROM " + RetSqlName("Z98") + " Z98 "
	RQ002 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = Z98_CLVL "
	RQ002 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
	RQ002 += "                    WHERE Z98.Z98_VERSAO = '" + idVersao + "' "
	RQ002 += "                      AND Z98.Z98_REVISA = '" + idRevisa + "' "
	RQ002 += "                      AND Z98.Z98_ANOREF = '" + idAnoRef + "' "
	RQ002 += "                      AND SUBSTRING(Z98.Z98_CONTA,1,3) NOT IN('165','168') "
	RQ002 += "                      AND RTRIM(Z98_CENARI) NOT IN('ESFORCO OBZ') "
	RQ002 += "                      AND RTRIM(Z98_CENARI) NOT IN('CORTE') " 
	RQ002 += "                      AND Z98_CONTA <> '' "
	RQ002 += "                      AND Z98_M01 + Z98_M02 + Z98_M03 + Z98_M04 + Z98_M05 + Z98_M06 + Z98_M07 + Z98_M08 + Z98_M09 + Z98_M10 + Z98_M11 + Z98_M12 <> 0 "
	RQ002 += "                      AND Z98.D_E_L_E_T_ = ' ' "
	RQ002 += "                    GROUP BY SUBSTRING(CTH_YEFORC,1,2)) "
	RQ002 += " SELECT * "
	RQ002 += "   FROM OBZINTEG "
	RQ002 += "  ORDER BY EMPR "
	RQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RQ002),'RQ02',.T.,.T.)
	dbSelectArea("RQ02")
	RQ02->(dbGoTop())
	If RQ02->(!Eof())
		While RQ02->(!Eof())
			aAdd(trEmprToO, RQ02->EMPR)
			RQ02->(dbSkip())
		End
	EndIf
	RQ02->(dbCloseArea())
	Ferase(RQIndex+GetDBExtension())
	Ferase(RQIndex+OrdBagExt())	

	If Len(trEmprToO) > 0

		fhEmprProc := ""
		FH001 := " WITH ORCTEMPR AS ( "
		FH001 += "                   SELECT '" + trEmprToO[1] + "' EMPR "
		FH001 += "                     FROM ZB5" + trEmprToO[1] + "0 "
		FH001 += "                    WHERE ZB5_VERSAO = '" + idVersao + "' "
		FH001 += "                      AND ZB5_REVISA = '" + idRevisa + "' "
		FH001 += "                      AND ZB5_ANOREF = '" + idAnoRef + "' "
		FH001 += "                      AND ZB5_TPORCT = 'OBZ' "
		FH001 += "                      AND ZB5_STATUS = 'A' "
		FH001 += "                      AND D_E_L_E_T_ = ' ' "
		For ny := 1 to Len(trEmprToO)
			If ny <> 1 
				FH001 += "                    UNION ALL "
				FH001 += "                   SELECT '" + trEmprToO[ny] + "' EMPR "
				FH001 += "                     FROM ZB5" + trEmprToO[ny] + "0 "
				FH001 += "                    WHERE ZB5_VERSAO = '" + idVersao + "' "
				FH001 += "                      AND ZB5_REVISA = '" + idRevisa + "' "
				FH001 += "                      AND ZB5_ANOREF = '" + idAnoRef + "' "
				FH001 += "                      AND ZB5_TPORCT = 'OBZ' "
				FH001 += "                      AND ZB5_STATUS = 'A' "
				FH001 += "                      AND D_E_L_E_T_ = ' ' "
			EndIf
		Next ny	
		FH001 += "                  ) "
		FH001 += " SELECT EMPR + ' - ' + Z35_DREDUZ EMPRESA "
		FH001 += "   FROM ORCTEMPR "
		FH001 += "  INNER JOIN " + RetSqlName("Z35") + " Z35 ON Z35_EMP = EMPR "
		FH001 += "                       AND Z35_FIL = '01' "
		FH001 += "                       AND Z35.D_E_L_E_T_ = ' ' "
		FHIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,FH001),'FH01',.T.,.T.)
		dbSelectArea("FH01")
		FH01->(dbGoTop())
		If FH01->(!Eof())
			While FH01->(!Eof())
				fhEmprProc += FH01->EMPRESA + trrhEnter
				FH01->(dbSkip())
			End
		EndIf
		FH01->(dbCloseArea())
		Ferase(FHIndex+GetDBExtension())
		Ferase(FHIndex+OrdBagExt())	

		If !Empty(fhEmprProc)

			MsgSTOP("Ainda falta executar este processamento nas seguintes empresas do grupo: " + trrhEnter + trrhEnter + fhEmprProc )

		Else

			MsgINFO("N�o resta nenhuma empresa para ser processada. Favor comunicar ao Cont�bil que o OBZ foi totalmente integrado!!!")

		EndIf

	Else

		MsgSTOP("Favor verificar os arquivos OBZ importados para esta empresa, pois n�o foi identificado nenhum registro para ser enviado para o m�dulo de OrcaFinal!!!")

	EndIf	

Return
