#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA363
@author Marcos Alberto Soprani
@since 08/01/18
@version 1.0
@description Rotina para transporte dos dados de modelo de RECEITA para base de dados GMR
@type function
/*/

User Function BIA363()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private idMarca     := space(004) 
	Private idSeq       := space(003) 

	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados de modelo de RECEITA para base de dados GMR!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("ATENÇÃO: não efetuar processamento simultâneo das marcas!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA363A() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração RECEITA com GMR'), aSays, aButtons ,,,500)

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

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBM") + " ZBM(NOLOCK) "
		M0007 += "  WHERE ZBM.ZBM_VERSAO = '" + idVersao + "' "
		M0007 += "    AND ZBM.ZBM_REVISA = '" + idRevisa + "' "
		M0007 += "    AND ZBM.ZBM_ANOREF = '" + idAnoRef + "' "
		If !Empty(idMarca)
			M0007 += "    AND ZBM.ZBM_MARCA = '" + idMarca + "' "
		EndIf
		M0007 += "    AND ZBM.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para GMR  para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

		EndIf

		MsgINFO('Fim do Processamento!!!')

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
Static Function BIA363A()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA363A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 
	idMarca  		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Marca (vazio TODAS):"         ,idMarca     ,"@!",""          ,'Z37','.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração RECEITA p/ GMR",,,,,,,,cLoad,.T.,.T.)      
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

	Local msStaExcQy 

	KS001 := " DELETE ZBM "
	KS001 += "   FROM " + RetSqlName("ZBM") + " ZBM "
	KS001 += "  WHERE ZBM.ZBM_VERSAO = '" + idVersao + "' "
	KS001 += "    AND ZBM.ZBM_REVISA = '" + idRevisa + "' "
	KS001 += "    AND ZBM.ZBM_ANOREF = '" + idAnoRef + "' "
	If !Empty(idMarca)
		KS001 += "    AND ZBM.ZBM_MARCA = '" + idMarca + "' "
	EndIf
	KS001 += "    AND ZBM.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Apagando registros ZBM... ",,{|| msStaExcQy := TcSQLExec(KS001) })

	If (msStaExcQy < 0)
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + TCSQLError() + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )
	EndIf	

	MS007 := " INSERT INTO " + RetSqlName("ZBM") + " "
	MS007 += " (ZBM_FILIAL, "
	MS007 += "  ZBM_VERSAO, "
	MS007 += "  ZBM_REVISA, "
	MS007 += "  ZBM_ANOREF, "
	MS007 += "  ZBM_SEQUEN, "
	MS007 += "  ZBM_PERIOD, "
	MS007 += "  ZBM_MARCA, "
	MS007 += "  ZBM_VEND, "
	MS007 += "  ZBM_GRPCLI, "
	MS007 += "  ZBM_TPSEG, "
	MS007 += "  ZBM_ESTADO, "
	MS007 += "  ZBM_PCTGMR, "
	MS007 += "  ZBM_FORMAT, "
	MS007 += "  ZBM_VALOR, "
	MS007 += "  ZBM_TIPO2, "
	MS007 += "  ZBM_CANALD, "
	MS007 += "  ZBM_QUANT, "
	MS007 += "  ZBM_CATEG, "
	MS007 += "  ZBM_TOTAL, "
	MS007 += "  ZBM_USER, "
	MS007 += "  ZBM_DTPROC, "
	MS007 += "  ZBM_HRPROC, "
	MS007 += "  ZBM_PCOMIS, "
	MS007 += "  ZBM_VCOMIS, "
	MS007 += "  ZBM_PICMS, "
	MS007 += "  ZBM_VICMS, "
	MS007 += "  ZBM_PPIS, "
	MS007 += "  ZBM_VPIS, "
	MS007 += "  ZBM_PCOF, "
	MS007 += "  ZBM_VCOF, "
	MS007 += "  ZBM_PST, "
	MS007 += "  ZBM_VST, "
	MS007 += "  ZBM_PDIFAL, " 
	MS007 += "  ZBM_VDIFAL, "
	MS007 += "  ZBM_ORIGF, "
	MS007 += "  ZBM_LINHAA, "
	MS007 += "  ZBM_FILEIN, "
	MS007 += "  ZBM_CLASSE, "
	MS007 += "  ZBM_METVER, "
	MS007 += "  ZBM_PERBON, "
	MS007 += "  ZBM_PERVER, "
	MS007 += "  ZBM_VALVER, "
	MS007 += "  ZBM_VALBON, "
	MS007 += "  ZBM_PERCPV, "
	MS007 += "  ZBM_VALCPV, "
	MS007 += "  ZBM_PICMBO, "
	MS007 += "  ZBM_PRZMET, "
	MS007 += "  ZBM_VICMBO, "
	MS007 += "  D_E_L_E_T_, "
	MS007 += "  R_E_C_N_O_, "
	MS007 += "  R_E_C_D_E_L_, "
	MS007 += "  ZBM_MODAO, " 
	MS007 += "  ZBM_MODCF, " 
	MS007 += "  ZBM_MOINVE, "
	MS007 += "  ZBM_MOICMS, "
	MS007 += "  ZBM_MODCVF, "
	MS007 += "  ZBM_MODCVC, "
	MS007 += "  ZBM_ATIVO "
	MS007 += " ) "
	MS007 += "        SELECT ZBH_FILIAL, "
	MS007 += "               ZBH_VERSAO, "
	MS007 += "               ZBH_REVISA, "
	MS007 += "               ZBH_ANOREF, "
	MS007 += "               '001' ZBH_SEQUEN, "
	MS007 += "               ZBH_PERIOD, "
	MS007 += "               ZBH_MARCA, "
	MS007 += "               ZBH_VEND, "
	MS007 += "               ZBH_GRPCLI, "
	MS007 += "               ZBH_TPSEG, "
	MS007 += "               ZBH_ESTADO, "
	MS007 += "               ZBH_PCTGMR, "
	MS007 += "               ZBH_FORMAT, "
	MS007 += "               ZBH_VALOR, "
	MS007 += "               ZBH_TIPO2, "
	MS007 += "               ZBH_CANALD, "
	MS007 += "               ZBH_QUANT, "
	MS007 += "               ZBH_CATEG, "
	MS007 += "               ZBH_TOTAL, "
	MS007 += "               ZBH_USER, "
	MS007 += "               ZBH_DTPROC, "
	MS007 += "               ZBH_HRPROC, "
	MS007 += "               ZBH_PCOMIS, "
	MS007 += "               ZBH_VCOMIS, "
	MS007 += "               ZBH_PICMS, "
	MS007 += "               ZBH_VICMS, "
	MS007 += "               ZBH_PPIS, "
	MS007 += "               ZBH_VPIS, "
	MS007 += "               ZBH_PCOF, "
	MS007 += "               ZBH_VCOF, "
	MS007 += "               ZBH_PST, "
	MS007 += "               ZBH_VST, "
	MS007 += "               ZBH_PDIFAL, "
	MS007 += "               ZBH_VDIFAL, "
	MS007 += "               ZBH_ORIGF, "
	MS007 += "               ZBH_LINHAA, "
	MS007 += "               ZBH_FILEIN, "
	MS007 += "               ZBH_CLASSE, "
	MS007 += "               ZBH_METVER, "
	MS007 += "               ZBH_PERBON, "
	MS007 += "               ZBH_PERVER, "
	MS007 += "               ZBH_VALVER, "
	MS007 += "               ZBH_VALBON, "
	MS007 += "               ZBH_PERCPV, "
	MS007 += "               ZBH_VALCPV, "
	MS007 += "               ZBH_PICMBO, "
	MS007 += "               ZBH_PRZMET, "
	MS007 += "               ZBH_VICMBO, "
	MS007 += "               '' D_E_L_E_T_, "
	MS007 += "        ( "
	MS007 += "            SELECT MAX(R_E_C_N_O_) "
	MS007 += "            FROM " + RetSqlName("ZBM") + " ZBM(NOLOCK) "
	MS007 += "        ) + ROW_NUMBER() OVER( "
	MS007 += "               ORDER BY ZBH.R_E_C_N_O_) AS R_E_C_N_O_, "
	MS007 += "               0 R_E_C_D_E_L_, "
	MS007 += "               0 ZBH_MODAO, "
	MS007 += "               0 ZBH_MODCF, "
	MS007 += "               0 ZBH_MOINVE, "
	MS007 += "               0 ZBH_MOICMS, "
	MS007 += "               0 ZBH_MODCVF, "
	MS007 += "               0 ZBH_MODCVC, "
	MS007 += "               ' ' ZBH_ATIVO "
	MS007 += "        FROM " + RetSqlName("ZBH") + " ZBH(NOLOCK) "
	MS007 += "        WHERE ZBH.ZBH_VERSAO = '" + idVersao + "' "
	MS007 += "              AND ZBH.ZBH_REVISA = '" + idRevisa + "' "
	MS007 += "              AND ZBH.ZBH_ANOREF = '" + idAnoRef + "' "
	If !Empty(idMarca)
		MS007 += "              AND ZBH.ZBH_MARCA = '" + idMarca + "' "
	EndIf
	MS007 += "              AND ZBH_ORIGF = '5' "
	MS007 += "              AND ZBH.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Inserindo registros ZBM... ",,{|| msStaExcQy := TcSQLExec(MS007) })

Return
