#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA762
@author Marcos Alberto Soprani
@since 06/01/20
@version 1.0
@description Rotina para transporte dos dados de modelo de RECEITA para Base pre-GMR
@type function
/*/

User Function BIA762()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private idSeq       := space(003) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	If cEmpAnt <> "01"
		MsgSTOP("Este processamento somente se faz necessário na empresa 01.", "Atenção!!!")
		Return
	EndIf

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados de modelo de RECEITA para Base pre-GMR!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA762A() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração RECEITA com Base pre-GMR'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
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
			AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
			AND ZB5.ZB5_STATUS = 'F'
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

		nxContaProc := 0
		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBM") + " ZBM "
		M0007 += "  WHERE ZBM.ZBM_VERSAO = '" + idVersao + "' "
		M0007 += "    AND ZBM.ZBM_REVISA = '" + idRevisa + "' "
		M0007 += "    AND ZBM.ZBM_ANOREF = '" + idAnoRef + "' "
		M0007 += "    AND ZBM.ZBM_SEQUEN = '" + idSeq + "' "
		M0007 += "    AND ZBM.D_E_L_E_T_ = ' ' "
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
Static Function BIA762A()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA762A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004)
	idSeq           := space(003) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})
	aAdd( aPergs ,{1,"Sequência p/ Controle:"       ,idSeq       ,"@!",""          ,''   ,'.T.', 03,.F.})	

	If ParamBox(aPergs ,"Integração RECEITA p/ Base pre-GMR",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef)
		idSeq       := ParamLoad(cFileName,,4,idSeq)  
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

	KS001 := " DELETE ZBM "
	KS001 += "   FROM " + RetSqlName("ZBM") + " ZBM "
	KS001 += "  WHERE ZBM.ZBM_VERSAO = '" + idVersao + "' "
	KS001 += "    AND ZBM.ZBM_REVISA = '" + idRevisa + "' "
	KS001 += "    AND ZBM.ZBM_ANOREF = '" + idAnoRef + "' "
	KS001 += "    AND ZBM.ZBM_SEQUEN = '" + idSeq + "' "
	KS001 += "    AND ZBM.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBM... ",,{|| TcSQLExec(KS001) })

	LV007 := " INSERT INTO " + RetSqlName("ZBM") + " "
	LV007 += " (ZBM_FILIAL, "
	LV007 += "  ZBM_VERSAO, "
	LV007 += "  ZBM_REVISA, "
	LV007 += "  ZBM_ANOREF, "
	LV007 += "  ZBM_SEQUEN, "
	LV007 += "  ZBM_PERIOD, "
	LV007 += "  ZBM_MARCA, "
	LV007 += "  ZBM_VEND, "
	LV007 += "  ZBM_GRPCLI, "
	LV007 += "  ZBM_TPSEG, "
	LV007 += "  ZBM_ESTADO, "
	LV007 += "  ZBM_PCTGMR, "
	LV007 += "  ZBM_FORMAT, "
	LV007 += "  ZBM_VALOR, "
	LV007 += "  ZBM_TIPO2, "
	LV007 += "  ZBM_CANALD, "
	LV007 += "  ZBM_QUANT, "
	LV007 += "  ZBM_CATEG, "
	LV007 += "  ZBM_TOTAL, "
	LV007 += "  ZBM_USER, "
	LV007 += "  ZBM_DTPROC, "
	LV007 += "  ZBM_HRPROC, "
	LV007 += "  ZBM_PCOMIS, "
	LV007 += "  ZBM_VCOMIS, "
	LV007 += "  ZBM_PICMS, "
	LV007 += "  ZBM_VICMS, "
	LV007 += "  ZBM_PPIS, "
	LV007 += "  ZBM_VPIS, "
	LV007 += "  ZBM_PCOF, "
	LV007 += "  ZBM_VCOF, "
	LV007 += "  ZBM_PST, "
	LV007 += "  ZBM_VST, "
	LV007 += "  ZBM_PDIFAL, "
	LV007 += "  ZBM_VDIFAL, "
	LV007 += "  ZBM_ORIGF, "
	LV007 += "  ZBM_LINHAA, "
	LV007 += "  ZBM_FILEIN, "
	LV007 += "  ZBM_CLASSE, "
	LV007 += "  ZBM_METVER, "
	LV007 += "  ZBM_PERBON, "
	LV007 += "  ZBM_PERVER, "
	LV007 += "  ZBM_VALVER, "
	LV007 += "  ZBM_VALBON, "
	LV007 += "  ZBM_PERCPV, "
	LV007 += "  ZBM_VALCPV, "
	LV007 += "  ZBM_PICMBO, "
	LV007 += "  ZBM_PRZMET, "
	LV007 += "  ZBM_VICMBO, "
	LV007 += "  D_E_L_E_T_, "
	LV007 += "  R_E_C_N_O_, "
	LV007 += "  R_E_C_D_E_L_ "
	LV007 += " ) "
	LV007 += "        SELECT ZBH_FILIAL, "
	LV007 += "               ZBH_VERSAO, "
	LV007 += "               ZBH_REVISA, "
	LV007 += "               ZBH_ANOREF, "
	LV007 += "               '" + idSeq + "' ZBH_SEQUEN, "
	LV007 += "               ZBH_PERIOD, "
	LV007 += "               ZBH_MARCA, "
	LV007 += "               ZBH_VEND, "
	LV007 += "               ZBH_GRPCLI, "
	LV007 += "               ZBH_TPSEG, "
	LV007 += "               ZBH_ESTADO, "
	LV007 += "               ZBH_PCTGMR, "
	LV007 += "               ZBH_FORMAT, "
	LV007 += "               ZBH_VALOR, "
	LV007 += "               ZBH_TIPO2, "
	LV007 += "               ZBH_CANALD, "
	LV007 += "               ZBH_QUANT, "
	LV007 += "               ZBH_CATEG, "
	LV007 += "               ZBH_TOTAL, "
	LV007 += "               ZBH_USER, "
	LV007 += "               ZBH_DTPROC, "
	LV007 += "               ZBH_HRPROC, "
	LV007 += "               ZBH_PCOMIS, "
	LV007 += "               ZBH_VCOMIS, "
	LV007 += "               ZBH_PICMS, "
	LV007 += "               ZBH_VICMS, "
	LV007 += "               ZBH_PPIS, "
	LV007 += "               ZBH_VPIS, "
	LV007 += "               ZBH_PCOF, "
	LV007 += "               ZBH_VCOF, "
	LV007 += "               ZBH_PST, "
	LV007 += "               ZBH_VST, "
	LV007 += "               ZBH_PDIFAL, "
	LV007 += "               ZBH_VDIFAL, "
	LV007 += "               ZBH_ORIGF, "
	LV007 += "               ZBH_LINHAA, "
	LV007 += "               ZBH_FILEIN, "
	LV007 += "               ZBH_CLASSE, "
	LV007 += "               ZBH_METVER, "
	LV007 += "               ZBH_PERBON, "
	LV007 += "               ZBH_PERVER, "
	LV007 += "               ZBH_VALVER, "
	LV007 += "               ZBH_VALBON, "
	LV007 += "               ZBH_PERCPV, "
	LV007 += "               ZBH_VALCPV, "
	LV007 += "               ZBH_PICMBO, "
	LV007 += "               ZBH_PRZMET, "
	LV007 += "               ZBH_VICMBO, "
	LV007 += "               D_E_L_E_T_, "
	LV007 += "        ( "
	LV007 += "            SELECT MAX(R_E_C_N_O_) "
	LV007 += "            FROM " + RetSqlName("ZBM") + " "
	LV007 += "        ) + ROW_NUMBER() OVER( "
	LV007 += "               ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
	LV007 += "               R_E_C_D_E_L_ "
	LV007 += "        FROM " + RetSqlName("ZBH") + " ZBH "
	LV007 += "        WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
	LV007 += "              AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
	LV007 += "              AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
	LV007 += "              AND ZBH.ZBH_ORIGF = '5' "
	LV007 += "              AND ZBH.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Convertendo modelo de RECEITA em Base pre-GMR... ",,{|| TcSQLExec(LV007) })

	MsgINFO("Conversão do modelo RECEITA em Base pre-GMR realizada com sucesso!!!")

Return
