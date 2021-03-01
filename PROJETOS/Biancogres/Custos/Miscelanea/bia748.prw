#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA748
@author Marcos Alberto Soprani
@since 30/10/19
@version 1.0
@description Reprocessamento de quantidade e custo unitário para variável em caso de Rev.Orçado
@type function
/*/

User Function BIA748()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F.

	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private miAno       := Space(04)
	Private miMesDe     := Space(02)
	Private miMesAt     := Space(02)
	Private miSeqOrg    := Space(03) 
	Private miSeqDes    := Space(03) 

	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	Private cMsg        := "Carregando Arquivo..."

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados do Rev.Orçado de Qtd/Vlr p/ C.Variável!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA748G() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração Rev.Orçado de Qtd/Vlr p/ C.Variável'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual: Todos os Tipos" + msrhEnter
		xfMensCompl += "Status igual Fechado" + msrhEnter
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
			AND ZB5.ZB5_STATUS = 'F'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 6
			MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " WITH CONTAREG "
		M0007 += "      AS (SELECT COUNT(*) CONTAD "
		M0007 += "          FROM " + RetSqlName("Z56") + " Z56 "
		M0007 += "          WHERE Z56.Z56_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
		M0007 += "                AND Z56.Z56_SEQUEN = '" + miSeqDes + "' "
		M0007 += "                AND Z56.D_E_L_E_T_ = ' ' "
		M0007 += "          UNION ALL "
		M0007 += "          SELECT COUNT(*) CONTAD "
		M0007 += "          FROM " + RetSqlName("Z57") + " Z57 "
		M0007 += "          WHERE Z57.Z57_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
		M0007 += "                AND Z57.Z57_SEQUEN = '" + miSeqDes + "' "
		M0007 += "                AND Z57.D_E_L_E_T_ = ' ') "
		M0007 += "      SELECT SUM(CONTAD) CONTAD "
		M0007 += "      FROM CONTAREG "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para Custo Real Variável para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({|| U_BIA748A() }, "Aguarde...", cMsg, .F.)

			MsgINFO(" Fim do processamento...")

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
Static Function BIA748G()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA748G' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad

	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 
	miAno           := Space(04)
	miMesDe         := Space(02)
	miMesAt         := Space(02)
	miSeqOrg        := Space(03) 
	miSeqDes        := Space(03)

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao   ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa   ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef   ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Ano Rev.Orçado: "             ,miAno      ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Mês De Rev.Orçado: "          ,miMesDe    ,"@!","NAOVAZIO()",''   ,'.T.', 02,.F.})	
	aAdd( aPergs ,{1,"Mês Até Rev.Orçado: "         ,miMesAt    ,"@!","NAOVAZIO()",''   ,'.T.', 02,.F.})	
	aAdd( aPergs ,{1,"Sequência Original: "         ,miSeqOrg   ,"@!",""          ,''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Sequência Destino: "          ,miSeqDes   ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	

	If ParamBox(aPergs ,"Integração OrcaFinal p/ Meta",,,,,,,,cLoad,.T.,.T.)      
		idVersao   := ParamLoad(cFileName,,1,idVersao) 
		idRevisa   := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef   := ParamLoad(cFileName,,3,idAnoRef) 
		miAno      := ParamLoad(cFileName,,4,miAno) 
		miMesDe    := ParamLoad(cFileName,,5,miMesDe) 
		miMesAt    := ParamLoad(cFileName,,6,miMesAt) 
		miSeqOrg   := ParamLoad(cFileName,,7,miSeqOrg) 
		miSeqDes   := ParamLoad(cFileName,,8,miSeqDes) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA748A()

	Local msStaExcQy    := 0
	Local lOk           := .T.

	ProcRegua(0)

	Begin Transaction

		KS001 := " DELETE Z56 "
		KS001 += "   FROM " + RetSqlName("Z56") + " Z56 "
		KS001 += "  WHERE Z56.Z56_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
		KS001 += "    AND Z56.Z56_SEQUEN = '" + miSeqDes + "' "
		KS001 += "    AND Z56.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando registros Z56... ",,{|| msStaExcQy := TcSQLExec(KS001) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			KS002 := " DELETE Z57 "
			KS002 += "   FROM " + RetSqlName("Z57") + " Z57 "
			KS002 += "  WHERE Z57.Z57_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
			KS002 += "    AND Z57.Z57_SEQUEN = '" + miSeqDes + "' "
			KS002 += "    AND Z57.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros Z57... ",,{|| msStaExcQy := TcSQLExec(KS002) })
			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If lOk

				msCtrlMeses := 0
				While StrZero(msCtrlMeses,2) < miMesAt

					IncProc("Proc.Mês: " + StrZero(msCtrlMeses,2) )
					cMsg := "Proc.Mês: " + StrZero(msCtrlMeses,2)

					msCtrlMeses ++
					msDataDe := miAno + StrZero(msCtrlMeses,2) + "01"
					msDataAt := dtos(UltimoDia(stod(miAno + StrZero(msCtrlMeses,2) + "01")))

					RT003 := " WITH REVORCADOX "
					RT003 += "      AS (SELECT SUBSTRING(D3_EMISSAO, 1, 6) + '01' EMISSAO, "
					RT003 += "                 REFPROD, "
					RT003 += "                 D3_YITCUS ITCUS, "
					RT003 += "                 '' CONTA, "
					RT003 += "                 SUM(QTDPAC) QTDRAC, "
					RT003 += "                 SUM(D3_CUSTO1) CUSTO "
					RT003 += "          FROM VW_SAP_MOVEST FOREC "
					RT003 += "          WHERE D3_EMISSAO BETWEEN '" + msDataDe + "' AND '" + msDataAt + "' "
					RT003 += "                AND D3_YITCUS <> '001' "
					RT003 += "                AND D3_YITCUS <> '   ' "
					RT003 += "          GROUP BY SUBSTRING(D3_EMISSAO, 1, 6), "
					RT003 += "                   REFPROD, "
					RT003 += "                   D3_YITCUS), "
					RT003 += "      CUSTORAC "
					RT003 += "      AS (SELECT SUBSTRING(Z56_DATARF, 1, 6) PERIODO, "
					RT003 += "                 Z56_COD PRODUTO, "
					RT003 += "                 Z56_ITCUS ITCUS, "
					RT003 += "                 MIN(Z56_CONTA) CONTA, "
					RT003 += "                 SUM(Z56_M01) CUSTO "
					RT003 += "          FROM " + RetSqlName("Z56") + " "
					RT003 += "          WHERE Z56_DATARF BETWEEN '" + msDataDe + "' AND '" + msDataAt + "' "
					RT003 += "                AND Z56_SEQUEN = '" + miSeqOrg + "' "
					RT003 += "                AND D_E_L_E_T_ = ' ' "
					RT003 += "          GROUP BY SUBSTRING(Z56_DATARF, 1, 6), "
					RT003 += "                   Z56_COD, "
					RT003 += "                   Z56_ITCUS) "
					RT003 += "      SELECT FRX.EMISSAO, "
					RT003 += "             FRX.REFPROD PRODUTO, "
					RT003 += "             CONTA = CASE "
					RT003 += "                         WHEN CTR.CONTA <> '' "
					RT003 += "                         THEN CTR.CONTA "
					RT003 += "                         ELSE Z29_AGRPCT "
					RT003 += "                     END, "
					RT003 += "             FRX.ITCUS ITCUS, "
					RT003 += "             ROUND(FRX.CUSTO / FRX.QTDRAC, 8) MEDIO "
					RT003 += "      FROM REVORCADOX FRX "
					RT003 += "           INNER JOIN " + RetSqlName("Z29") + " Z29 ON Z29_COD_IT = FRX.ITCUS "
					RT003 += "                                    AND Z29_TIPO = 'CV' "
					RT003 += "                                    AND Z29.D_E_L_E_T_ = ' ' "
					RT003 += "           LEFT JOIN CUSTORAC CTR ON CTR.PERIODO = SUBSTRING(FRX.EMISSAO, 1, 6) "
					RT003 += "                                     AND CTR.PRODUTO = FRX.REFPROD "
					RT003 += "                                     AND CTR.ITCUS = FRX.ITCUS "
					RT003 += "      WHERE FRX.CUSTO <> 0 "
					RT003 += "            AND FRX.ITCUS NOT IN('060', '065') "
					RT003 += "      ORDER BY FRX.EMISSAO, "
					RT003 += "               FRX.REFPROD, "
					RT003 += "               FRX.ITCUS "
					RTIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT003),'RT03',.T.,.T.)
					dbSelectArea("RT03")
					RT03->(dbGoTop())
					ProcRegua(1000000)		
					While !RT03->(Eof())

						IncProc("Proc.Mês: " + StrZero(msCtrlMeses,2) + ", Produto: " + Alltrim(RT03->PRODUTO) )
						cMsg := "Proc.Mês: " + StrZero(msCtrlMeses,2) + ", Produto: " + Alltrim(RT03->PRODUTO)

						msRecebe := "Z56->Z56_M" + StrZero(msCtrlMeses,2)

						dbSelectArea("Z56")
						dbSetOrder(2)
						If !dbSeek(xFilial("Z56") + msDataAt + RT03->PRODUTO + RT03->CONTA + RT03->ITCUS + miSeqDes)
							Reclock("Z56",.T.)
							Z56->Z56_FILIAL := xFilial("Z56")
						Else
							Reclock("Z56",.F.)
						EndIf
						Z56->Z56_DATARF  := stod(msDataAt)
						Z56->Z56_COD     := RT03->PRODUTO
						Z56->Z56_CONTA   := RT03->CONTA
						Z56->Z56_ITCUS   := RT03->ITCUS
						Z56->Z56_CTOTAL  := RT03->MEDIO
						&(msRecebe)      := RT03->MEDIO
						Z56->Z56_GMCD    := 'S'
						Z56->Z56_SEQUEN  := miSeqDes
						MsUnlock()

						RT03->(dbSkip())

					End

					RT03->(dbCloseArea())
					Ferase(RTIndex+GetDBExtension())
					Ferase(RTIndex+OrdBagExt())

				End

				IncProc("Processando restante do ano..." )
				cMsg := "Processando restante do ano..."

				WF004 := " INSERT INTO " + RetSqlName("Z56") + " "
				WF004 += " (Z56_FILIAL, "
				WF004 += "  Z56_DATARF, "
				WF004 += "  Z56_COD, "
				WF004 += "  Z56_CONTA, "
				WF004 += "  Z56_ITCUS, "
				WF004 += "  Z56_CTOTAL, "
				WF004 += "  Z56_M01, "
				WF004 += "  Z56_M02, "
				WF004 += "  Z56_M03, "
				WF004 += "  Z56_M04, "
				WF004 += "  Z56_M05, "
				WF004 += "  Z56_M06, "
				WF004 += "  Z56_M07, "
				WF004 += "  Z56_M08, "
				WF004 += "  Z56_M09, "
				WF004 += "  Z56_M10, "
				WF004 += "  Z56_M11, "
				WF004 += "  Z56_M12, "
				WF004 += "  D_E_L_E_T_, "
				WF004 += "  R_E_C_N_O_, "
				WF004 += "  Z56_GMCD, "
				WF004 += "  Z56_SEQUEN "
				WF004 += " ) "
				WF004 += "        SELECT Z56_FILIAL, "
				WF004 += "               Z56_DATARF, "
				WF004 += "               Z56_COD, "
				WF004 += "               Z56_CONTA, "
				WF004 += "               Z56_ITCUS, "
				WF004 += "               Z56_CTOTAL, "
				WF004 += "               Z56_M01, "
				WF004 += "               Z56_M02, "
				WF004 += "               Z56_M03, "
				WF004 += "               Z56_M04, "
				WF004 += "               Z56_M05, "
				WF004 += "               Z56_M06, "
				WF004 += "               Z56_M07, "
				WF004 += "               Z56_M08, "
				WF004 += "               Z56_M09, "
				WF004 += "               Z56_M10, "
				WF004 += "               Z56_M11, "
				WF004 += "               Z56_M12, "
				WF004 += "               D_E_L_E_T_, "
				WF004 += "               ( SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("Z56") + " ) + ROW_NUMBER() OVER( ORDER BY R_E_C_N_O_ ) AS R_E_C_N_O_, "
				WF004 += "               'S' Z56_GMCD, "
				WF004 += "               '" + miSeqDes + "' Z56_SEQUEN "
				WF004 += "        FROM " + RetSqlName("Z56") + " "
				WF004 += "        WHERE Z56_DATARF BETWEEN '" + miAno + StrZero( Val(miMesAt) + 1, 2) + "01' AND '" + miAno + "1231' "
				WF004 += "              AND Z56_SEQUEN = '" + miSeqOrg + "' "
				WF004 += "              AND D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Convertendo Z56 Rev.Orçado (1)... ",,{|| msStaExcQy := TcSQLExec(WF004) })
				If msStaExcQy < 0
					lOk := .F.
				EndIf

				If lOk

					msCtrlMeses := 0
					While StrZero(msCtrlMeses,2) < miMesAt

						IncProc("Proc. Quatidade Mês: " + StrZero(msCtrlMeses,2) )
						cMsg := "Proc. Quatidade Mês: " + StrZero(msCtrlMeses,2)

						msCtrlMeses ++
						msDataDe := miAno + StrZero(msCtrlMeses,2) + "01"
						msDataAt := dtos(UltimoDia(stod(miAno + StrZero(msCtrlMeses,2) + "01")))

						xhDiasMes := Val(Substr(msDataAt,7,2))
						// Tratativa implementada em 16/03/2016 porque a área de custo identificou que o valor ficou diferente no SAP porque neste ultimo foi fixado 28 dias para cálculo.
						If Substr(msDataAt, 5, 2) == "02" .and. xhDiasMes == 29
							xhDiasMes := 28
						EndIf

						UX009 := " INSERT INTO " + RetSqlName("Z57") + " "
						UX009 += " (Z57_FILIAL, "
						UX009 += "  Z57_DATARF, "
						UX009 += "  Z57_PRODUT, "
						UX009 += "  Z57_LINHA, "
						UX009 += "  Z57_CAPACI, "
						UX009 += "  Z57_PSECO, "
						UX009 += "  D_E_L_E_T_, "
						UX009 += "  R_E_C_N_O_, "
						UX009 += "  Z57_QTDRAC, "
						UX009 += "  Z57_GMCD, "
						UX009 += "  Z57_SEQUEN "
						UX009 += " ) "
						UX009 += "        SELECT Z57_FILIAL, "
						UX009 += "               Z57_DATARF, "
						UX009 += "               Z57_PRODUT, "
						UX009 += "               Z57_LINHA, "
						UX009 += "               Z57_CAPACI = ROUND( "
						UX009 += "        ( "
						UX009 += "            SELECT SUM(XZ57.Z57_QTDRAC) "
						UX009 += "            FROM " + RetSqlName("Z57") + " XZ57 "
						UX009 += "            WHERE XZ57.Z57_FILIAL = Z57.Z57_FILIAL "
						UX009 += "                  AND XZ57.Z57_DATARF = Z57.Z57_DATARF "
						UX009 += "                  AND XZ57.Z57_LINHA = Z57.Z57_LINHA "
						UX009 += "                  AND XZ57.Z57_SEQUEN = Z57.Z57_SEQUEN "
						UX009 += "                  AND LEN(RTRIM(XZ57.Z57_PRODUT)) = LEN(RTRIM(Z57.Z57_PRODUT)) "
						UX009 += "                  AND XZ57.D_E_L_E_T_ = ' ' "
						UX009 += "        ) / " + Alltrim(Str(xhDiasMes)) + ", 2), "
						UX009 += "               Z57_PSECO, "
						UX009 += "               D_E_L_E_T_, "
						UX009 += "        ( "
						UX009 += "            SELECT MAX(R_E_C_N_O_) "
						UX009 += "            FROM " + RetSqlName("Z57") + " "
						UX009 += "        ) + ROW_NUMBER() OVER( "
						UX009 += "               ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
						UX009 += "               Z57_QTDRAC, "
						UX009 += "               'S' Z57_GMCD, "
						UX009 += "               '" + miSeqDes + "' Z57_SEQUEN "
						UX009 += "        FROM " + RetSqlName("Z57") + " Z57 "
						UX009 += "        WHERE Z57_DATARF BETWEEN '" + msDataDe + "' AND '" + msDataAt + "' "
						UX009 += "              AND Z57_SEQUEN = '" + miSeqOrg + "' "
						UX009 += "              AND D_E_L_E_T_ = ' ' "
						U_BIAMsgRun("Aguarde... Convertendo Z57 Rev.Orçado (2)... ",,{|| msStaExcQy := TcSQLExec(UX009)})
						If msStaExcQy < 0
							lOk := .F.
						EndIf

						If !lOk
							Exit
						EndIf

					End

					If lOk

						IncProc("Processando restante do ano..." )
						cMsg := "Processando restante do ano..."

						UX006 := " INSERT INTO " + RetSqlName("Z57") + " "
						UX006 += " (Z57_FILIAL, "
						UX006 += "  Z57_DATARF, "
						UX006 += "  Z57_PRODUT, "
						UX006 += "  Z57_LINHA, "
						UX006 += "  Z57_CAPACI, "
						UX006 += "  Z57_PSECO, "
						UX006 += "  D_E_L_E_T_, "
						UX006 += "  R_E_C_N_O_, "
						UX006 += "  Z57_QTDRAC, "
						UX006 += "  Z57_GMCD, "
						UX006 += "  Z57_SEQUEN "
						UX006 += " ) "
						UX006 += "        SELECT Z57_FILIAL, "
						UX006 += "               Z57_DATARF, "
						UX006 += "               Z57_PRODUT, "
						UX006 += "               Z57_LINHA, "
						UX006 += "               Z57_CAPACI, "
						UX006 += "               Z57_PSECO, "
						UX006 += "               D_E_L_E_T_, "
						UX006 += "               ( SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("Z57") + " ) + ROW_NUMBER() OVER( ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
						UX006 += "               Z57_QTDRAC, "
						UX006 += "               'S' Z57_GMCD, "
						UX006 += "               '" + miSeqDes + "' Z57_SEQUEN "
						UX006 += "        FROM " + RetSqlName("Z57") + " Z57 "
						UX006 += "        WHERE Z57_DATARF BETWEEN '" + miAno + StrZero( Val(miMesAt) + 1, 2) + "01' AND '" + miAno + "1231' "
						UX006 += "              AND Z57_SEQUEN = '" + miSeqOrg + "' "
						UX006 += "              AND D_E_L_E_T_ = ' ' "
						U_BIAMsgRun("Aguarde... Convertendo Z57 Rev.Orçado (3)... ",,{|| msStaExcQy := TcSQLExec(UX006)})
						If msStaExcQy < 0
							lOk := .F.
						EndIf

						If lOk

							KS008 := " UPDATE Z56 SET Z56_GMCD = 'N' "
							KS008 += "   FROM " + RetSqlName("Z56") + " Z56 "
							KS008 += "  WHERE Z56.Z56_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
							KS008 += "    AND Z56.Z56_SEQUEN = '" + miSeqOrg + "' "
							KS008 += "    AND Z56.D_E_L_E_T_ = ' ' "
							U_BIAMsgRun("Aguarde... Convertendo Z56 Rev.Orçado (4)... ",,{|| msStaExcQy := TcSQLExec(KS008) })
							If msStaExcQy < 0
								lOk := .F.
							EndIf

							If lOk

								KS003 := " UPDATE Z57 SET Z57_GMCD = 'N' "
								KS003 += "   FROM " + RetSqlName("Z57") + " Z57 "
								KS003 += "  WHERE Z57.Z57_DATARF BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
								KS003 += "    AND Z57.Z57_SEQUEN = '" + miSeqOrg + "' "
								KS003 += "    AND Z57.D_E_L_E_T_ = ' ' "
								U_BIAMsgRun("Aguarde... Convertendo Z57 Rev.Orçado (5)... ",,{|| TcSQLExec(KS003) })
								If msStaExcQy < 0
									lOk := .F.
								EndIf

								If !lOk

									msGravaErr := TCSQLError()
									DisarmTransaction()

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	End Transaction 	

	If lOk

		MsgINFO("Processamento realizado. Sequência " + miSeqDes + " habilitada com sucesso.", "")

	Else

		DisarmTransaction()
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return
