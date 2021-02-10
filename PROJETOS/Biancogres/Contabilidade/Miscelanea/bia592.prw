#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA592
@author Marcos Alberto Soprani
@since 02/11/17
@version 1.0
@description Browser principal para a rotina de Ativo Fixo Orçado para OrcaFinal
@type function
/*/

User Function BIA592()

	Local aArea     := GetArea()

	Private cCadastro 	:= "AtivoFixo CAPEX p/ OrcaFinal"
	Private aRotina 	:= { {"Pesquisar"  			      ,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			      ,"AxVisual"     ,0,2},;
	{                         "ATF (CAPEX) p/ OrcaFinal"  ,"U_B592IMDD"   ,0,3} }

	dbSelectArea("ZBY")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZBY",,,,,,)

	restArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B592IMDD ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Gera Integração com modelo de OrcaFinal                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B592IMDD()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Geração de Integração dos registros CAPEX com Modelo de OrcaFinal!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergIntMD() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração CAPEX com OrcaFinal'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
		xfMensCompl += "Data Encerramento diferente de branco e menor ou igual DataBase" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:idVersao%
			AND ZB5.ZB5_REVISA = %Exp:idRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:idAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
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

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
		M0007 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		M0007 += "    AND ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
		M0007 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
		M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
		M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'CAPEX' "
		M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base contábel orçamentária para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

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
Static Function fPergIntMD()

	Local aPergs 	:= {}
	Local cLoad	    := 'B592IMDD' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração CAPEX p/ OrcaFinal",,,,,,,,cLoad,.T.,.T.)      
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

	Local lvxt

	KS001 := " DELETE " + RetSqlName("ZBZ") + " "
	KS001 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
	KS001 += "  WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
	KS001 += "    AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
	KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
	KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'CAPEX' "
	KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| TcSQLExec(KS001) })

	ProcRegua(0)
	For lvxt := 1 to 12

		IncProc("Processando mês " + AllTrim(Str(lvxt)) )

		ghDtRef := idAnoRef + StrZero(lvxt,2) + "01"

		LV007 := " WITH CAPEXINT AS (SELECT ISNULL(SUBSTRING(CTH_YEMPFL,1,2), 'ER') EMPR, "
		LV007 += "                          ZBY_FILIAL, "
		LV007 += "                          ZBY_VERSAO, "
		LV007 += "                          ZBY_REVISA, "
		LV007 += "                          ZBY_ANOREF, "
		LV007 += "                          ZBY_CLVL, "
		LV007 += "                          ZBY_CDEPRE, "
		LV007 += "                          ISNULL(CT1_NORMAL, 'E') CT1_NORMAL, "
		LV007 += "                          SUM(ZBY_VRDMES) MESREF "
		LV007 += "                     FROM " + RetSqlName("ZBY") + " ZBY "
		LV007 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = ZBY_CDEPRE "
		LV007 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
		LV007 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBY_CLVL "
		LV007 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
		LV007 += "                    WHERE ZBY.ZBY_VERSAO = '" + idVersao + "' "
		LV007 += "                      AND ZBY.ZBY_REVISA = '" + idRevisa + "' "
		LV007 += "                      AND ZBY.ZBY_ANOREF = '" + idAnoRef + "' "
		LV007 += "                      AND '" + ghDtRef + "' BETWEEN ZBY_DTIDPR AND ZBY_DTFDPR
		LV007 += "                      AND ZBY.D_E_L_E_T_ = ' ' "
		LV007 += "                    GROUP BY SUBSTRING(CTH_YEMPFL,1,2), "
		LV007 += "                             ZBY_FILIAL, "
		LV007 += "                             ZBY_VERSAO, "
		LV007 += "                             ZBY_REVISA, "
		LV007 += "                             ZBY_ANOREF, "
		LV007 += "                             ZBY_CLVL, "
		LV007 += "                             ZBY_CDEPRE, "
		LV007 += "                             CT1_NORMAL) "
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
		LV007 += "  R_E_C_D_E_L_) "
		LV007 += " SELECT ZBY_FILIAL, "
		LV007 += "        ZBY_VERSAO, "
		LV007 += "        ZBY_REVISA, "
		LV007 += "        ZBY_ANOREF, "
		LV007 += "        'CAPEX' ZBZ_ORIPRC, "
		LV007 += "        CASE "
		LV007 += "          WHEN CT1_NORMAL = '1' THEN 'D' "
		LV007 += "          WHEN CT1_NORMAL = '2' THEN 'C' "
		LV007 += "          ELSE 'E' "
		LV007 += "        END ZBZ_ORGLAN, "
		LV007 += "        '" + ghDtRef + "' ZBZ_DATA, "
		LV007 += "        '004300'ZBZ_LOTE, "
		LV007 += "        '001' ZBZ_SBLOTE, "
		LV007 += "        '' ZBZ_DOC, "
		LV007 += "        '' ZBZ_LINHA, "
		LV007 += "        CT1_NORMAL ZBZ_DC, "
		LV007 += "        CASE "
		LV007 += "          WHEN CT1_NORMAL = '1' THEN ZBY_CDEPRE "
		LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
		LV007 += "          ELSE '' "
		LV007 += "        END ZBZ_DEBITO, "
		LV007 += "        CASE "
		LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
		LV007 += "          WHEN CT1_NORMAL = '2' THEN ZBY_CDEPRE "
		LV007 += "          ELSE '' "
		LV007 += "        END ZBZ_CREDIT, "
		LV007 += "        CASE "
		LV007 += "          WHEN CT1_NORMAL = '1' THEN ZBY_CLVL "
		LV007 += "          WHEN CT1_NORMAL = '2' THEN '' "
		LV007 += "          ELSE '' "
		LV007 += "        END ZBZ_CLVLDB, "
		LV007 += "        CASE "
		LV007 += "          WHEN CT1_NORMAL = '1' THEN '' "
		LV007 += "          WHEN CT1_NORMAL = '2' THEN ZBY_CLVL "
		LV007 += "          ELSE '' "
		LV007 += "        END ZBZ_CLVLCR, "
		LV007 += "        ' ' ZBZ_ITEMD, "
		LV007 += "        ' ' ZBZ_ITEMC, "
		LV007 += "        MESREF ZBZ_VALOR, "
		LV007 += "        'ORCTO CAPEX' ZBZ_HIST, "
		LV007 += "        'ORCAMENTO CAPEX' ZBZ_YHIST, "
		LV007 += "        '' ZBZ_SI, "
		LV007 += "        '' ZBZ_YDELTA, "
		LV007 += "        ' ' D_E_L_E_T_, "
		LV007 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZBZ") + ") + ROW_NUMBER() OVER(ORDER BY CAPEXI.ZBY_CLVL, CAPEXI.ZBY_CDEPRE) AS R_E_C_N_O_, "
		LV007 += "        0 R_E_C_D_E_L_ "
		LV007 += "   FROM CAPEXINT CAPEXI "
		LV007 += "  WHERE NOT ( CT1_NORMAL = 'E' OR EMPR = 'ER' ) "
		LV007 += "    AND MESREF <> 0 "
		U_BIAMsgRun("Aguarde... Convertendo CAPEX em DEPESAS... ",,{|| TcSQLExec(LV007) })

	Next lvxt

	ZP001 := " UPDATE " + RetSqlName("ZB5") + " SET ZB5_STATUS = 'F' "
	ZP001 += "   FROM " + RetSqlName("ZB5") + " ZB5 "
	ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
	ZP001 += "    AND ZB5.ZB5_VERSAO = '" + idVersao + "' "
	ZP001 += "    AND ZB5.ZB5_REVISA = '" + idRevisa + "' "
	ZP001 += "    AND ZB5.ZB5_ANOREF = '" + idAnoRef + "' "
	ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX' "
	ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Fechando Versão Orçamentária ... ",,{|| TcSQLExec(ZP001) })

	MsgINFO("Conversão CAPEX em OrcaFinal realizada com sucesso!!!")

Return
