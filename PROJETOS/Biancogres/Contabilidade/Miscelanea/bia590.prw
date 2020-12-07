#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA590
@author Marcos Alberto Soprani
@since 21/06/17
@version 1.0
@description Browser principal para a rotina de CAPEX Integration
@type function
/*/

User Function BIA590()

	Local aArea     := GetArea()
	Local cCondicao := ""

	Private cCadastro 	:= "CAPEX Integration"
	Private aRotina 	:= { {"Pesquisar"  			 ,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			 ,"AxVisual"     ,0,2},;
	{                         "Importar Orçamento"	 ,"U_B590IEXC"   ,0,3},;
	{                         "OBZ p/ CAPEX"         ,"U_B590OCAP"   ,0,4},;
	{                         "Trocar Usuário Resp"  ,"U_B590TRCA"   ,0,5},;
	{                         "Conferir Digitação"   ,"U_B590CFDG"   ,0,6},;
	{                         "SN3 p/ ATF Orçamen"   ,"U_B590SN3O"   ,0,7},;
	{                         "CAPEX p/ ATF Orçamen" ,"U_B590ZBVO"   ,0,8} }

	dbSelectArea("ZBV")
	dbSetOrder(1)

	If cEmpAnt <> "01"

		MsgSTOP("Esta rotina somente poderá ser acessada pela empresa Biancogres. Isto porque tanto a leitura do formuário CAPEX quanto a explosão da tabela SN3 são feitas de uma única vez para as empresas 01 / 05 / 06 / 07 / 12 / 13 / 14!!!")

	Else

		mBrowse(6,1,22,75,"ZBV",,,,,,)

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590OCAP ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imp. planilha Excel para Orçamento - CAPEX Integration     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590OCAP()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private ocVersao        := space(010)
	Private ocRevisa        := space(003) 
	Private ocAnoRef		:= space(004) 

	AADD(aSays, OemToAnsi("Rotina para importação de dados oriundos da tabela OBZ p/ CAPEX Integration!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergOCAP() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de CAPEX Integration'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcImOCAP() },"Aguarde...","Carregando Arquivo...",.F.)

	EndIf	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergOCAP()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590OCAP' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	ocVersao        := space(010)
	ocRevisa        := space(003) 
	ocAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,ocVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,ocRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,ocAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		ocVersao    := ParamLoad(cFileName,,1,ocVersao) 
		ocRevisa    := ParamLoad(cFileName,,2,ocRevisa) 
		ocAnoRef    := ParamLoad(cFileName,,3,ocAnoRef) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcImOCAP()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBV'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local M001              := GetNextAlias()
	Local M002              := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	// Efetua verificação de Versão e gravação...
	If Empty(ocVersao) .or. Empty(ocRevisa) .or. Empty(ocAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual OBZ" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a database" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:ocVersao%
		AND ZB5.ZB5_REVISA = %Exp:ocRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:ocAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'OBZ'
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

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a database" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M002
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:ocVersao%
		AND ZB5.ZB5_REVISA = %Exp:ocRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:ocAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M002)->(dbGoTop())
	If (M002)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M002)->(dbCloseArea())
		Return .F.
	EndIf	
	(M002)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBV") + " ZBV "
	M0007 += "  WHERE ZBV.ZBV_VERSAO = '" + ocVersao + "' "
	M0007 += "    AND ZBV.ZBV_REVISA = '" + ocRevisa + "' "
	M0007 += "    AND ZBV.ZBV_ANOREF = '" + ocAnoRef + "' "
	M0007 += "    AND ZBV.ZBV_ORIPRC = 'OBZ' "
	M0007 += "    AND ZBV.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existem registros CAPEX associados ao arquivo informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados existentes." + msrhEnter + msrhEnter+ " Deseja prosseguir com o importação?")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBV") + " "
			KS001 += "   FROM " + RetSqlName("ZBV") + " ZBV "
			KS001 += "  WHERE ZBV.ZBV_VERSAO = '" + ocVersao + "' "
			KS001 += "    AND ZBV.ZBV_REVISA = '" + ocRevisa + "' "
			KS001 += "    AND ZBV.ZBV_ANOREF = '" + ocAnoRef + "' "
			KS001 += "    AND ZBV.ZBV_ORIPRC = 'OBZ' "
			KS001 += "    AND ZBV.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBV... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	JD009 := " INSERT INTO " + RetSqlName("ZBV") + " "
	JD009 += " ( "
	JD009 += "  ZBV_FILIAL, "
	JD009 += "  ZBV_VERSAO, "
	JD009 += "  ZBV_REVISA, "
	JD009 += "  ZBV_ANOREF, "
	JD009 += "  ZBV_CLVL, "
	JD009 += "  ZBV_SETOR, "
	JD009 += "  ZBV_CONTA, "
	JD009 += "  ZBV_DRIVER, "
	JD009 += "  ZBV_ITCUST, "
	JD009 += "  ZBV_DSPARM, "
	JD009 += "  ZBV_VLPARM, "
	JD009 += "  ZBV_DSINDC, "
	JD009 += "  ZBV_VLINDC, "
	JD009 += "  ZBV_MOTIVO, "
	JD009 += "  ZBV_JUSTIF, "
	JD009 += "  ZBV_RETORN, "
	JD009 += "  ZBV_CONSEQ, "
	JD009 += "  ZBV_CENARI, "
	JD009 += "  ZBV_M01, "
	JD009 += "  ZBV_M02, "
	JD009 += "  ZBV_M03, "
	JD009 += "  ZBV_M04, "
	JD009 += "  ZBV_M05, "
	JD009 += "  ZBV_M06, "
	JD009 += "  ZBV_M07, "
	JD009 += "  ZBV_M08, "
	JD009 += "  ZBV_M09, "
	JD009 += "  ZBV_M10, "
	JD009 += "  ZBV_M11, "
	JD009 += "  ZBV_M12, "
	JD009 += "  ZBV_OBSERV, "
	JD009 += "  ZBV_PILHA, "
	JD009 += "  ZBV_ESTORN, "
	JD009 += "  ZBV_USER, "
	JD009 += "  ZBV_DTPROC, "
	JD009 += "  ZBV_HRPROC, "
	JD009 += "  ZBV_TOTAL, "
	JD009 += "  ZBV_APLIC, "
	JD009 += "  ZBV_INIDPR, "
	JD009 += "  ZBV_ESFORC, "
	JD009 += "  ZBV_FILEIN, "
	JD009 += "  ZBV_LINHAA, "
	JD009 += "  ZBV_USRRSP, "
	JD009 += "  D_E_L_E_T_, "
	JD009 += "  R_E_C_N_O_, "
	JD009 += "  R_E_C_D_E_L_,
	JD009 += "  ZBV_ORIPRC "
	JD009 += " ) "
	JD009 += " SELECT '" + xFilial("ZBV") + "' FILIAL, "
	JD009 += "        Z98_VERSAO, "
	JD009 += "        Z98_REVISA, "
	JD009 += "        Z98_ANOREF, "
	JD009 += "        Z98_CLVL, "
	JD009 += "        Z98_SETOR, "
	JD009 += "        Z98_CONTA, "
	JD009 += "        Z98_DRIVER, "
	JD009 += "        Z98_ITCUST, "
	JD009 += "        Z98_DSPARM, "
	JD009 += "        Z98_VLPARM, "
	JD009 += "        Z98_DSINDC, "
	JD009 += "        Z98_VLINDC, "
	JD009 += "        Z98_MOTIVO, "
	JD009 += "        Z98_JUSTIF, "
	JD009 += "        Z98_RETORN, "
	JD009 += "        Z98_CONSEQ, "
	JD009 += "        Z98_CENARI, "
	JD009 += "        Z98_M01, "
	JD009 += "        Z98_M02, "
	JD009 += "        Z98_M03, "
	JD009 += "        Z98_M04, "
	JD009 += "        Z98_M05, "
	JD009 += "        Z98_M06, "
	JD009 += "        Z98_M07, "
	JD009 += "        Z98_M08, "
	JD009 += "        Z98_M09, "
	JD009 += "        Z98_M10, "
	JD009 += "        Z98_M11, "
	JD009 += "        Z98_M12, "
	JD009 += "        Z98_OBSERV, "
	JD009 += "        Z98_PILHA, "
	JD009 += "        Z98_ESTORN, "
	JD009 += "        Z98_USER, "
	JD009 += "        Z98_DTPROC, "
	JD009 += "        Z98_HRPROC, "
	JD009 += "        Z98_M01 + Z98_M02 + Z98_M03 + Z98_M04 + Z98_M05 + Z98_M06 + Z98_M07 + Z98_M08 + Z98_M09 + Z98_M10 + Z98_M11 + Z98_M12 Z98_TOTAL, "
	JD009 += "        Z98_APLIC, "
	JD009 += "        CASE "
	JD009 += "          WHEN Z98_INIDPR <> '' THEN Z98_INIDPR "
	JD009 += "          WHEN Z98_M12 <> 0 THEN Z98_ANOREF + '1201' "
	JD009 += "          WHEN Z98_M11 <> 0 THEN Z98_ANOREF + '1101' "
	JD009 += "          WHEN Z98_M10 <> 0 THEN Z98_ANOREF + '1001' "
	JD009 += "          WHEN Z98_M09 <> 0 THEN Z98_ANOREF + '0901' "
	JD009 += "          WHEN Z98_M08 <> 0 THEN Z98_ANOREF + '0801' "
	JD009 += "          WHEN Z98_M07 <> 0 THEN Z98_ANOREF + '0701' "
	JD009 += "          WHEN Z98_M06 <> 0 THEN Z98_ANOREF + '0601' "
	JD009 += "          WHEN Z98_M05 <> 0 THEN Z98_ANOREF + '0501' "
	JD009 += "          WHEN Z98_M04 <> 0 THEN Z98_ANOREF + '0401' "
	JD009 += "          WHEN Z98_M03 <> 0 THEN Z98_ANOREF + '0301' "
	JD009 += "          WHEN Z98_M02 <> 0 THEN Z98_ANOREF + '0201' "
	JD009 += "          WHEN Z98_M01 <> 0 THEN Z98_ANOREF + '0101' "
	JD009 += "          ELSE Z98_ANOREF + '1201' "
	JD009 += "        END Z98_INIDPR, "
	JD009 += "        Z98_ESFORC, "
	JD009 += "        Z98_FILEIN, "
	JD009 += "        Z98_LINHAA, "
	JD009 += "        Z98_USRRSP, "
	JD009 += "        D_E_L_E_T_, "
	JD009 += "        (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("ZBV") + ") + ROW_NUMBER() OVER(ORDER BY Z98.R_E_C_N_O_) AS R_E_C_N_O_, "
	JD009 += "        R_E_C_D_E_L_,
	JD009 += "        'OBZ' ORIPRC "
	JD009 += "   FROM " + RetSqlName("Z98") + " Z98 "
	JD009 += "  WHERE Z98_FILIAL = '" + xFilial("Z98") + "' "
	JD009 += "    AND Z98.Z98_VERSAO = '" + ocVersao + "' "
	JD009 += "    AND Z98.Z98_REVISA = '" + ocRevisa + "' "
	JD009 += "    AND Z98.Z98_ANOREF = '" + ocAnoRef + "' "
	JD009 += "    AND SUBSTRING(Z98_CONTA,1,1) = '1' "
	JD009 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Atualizando totalizadores ZBV... ",,{|| TcSQLExec(JD009) })

	MsgInfo("Registros importados com sucesso")

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imp. planilha Excel para Orçamento - CAPEX Integration     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo		:= space(150)
	Private xdVersao        := space(010)
	Private xdRevisa        := space(003) 
	Private xdAnoRef		:= space(004) 
	Private xdUserDigt      := space(006) 

	AADD(aSays, OemToAnsi("Rotina para importação da Planilha de dados oriunda do CAPEX Integration!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de CAPEX Integration'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)

			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)

		Else

			MsgStop('Informe o arquivo valido para importação!')

		EndIf

	EndIf	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(150)
	xdVersao        := space(010)
	xdRevisa        := space(003) 
	xdAnoRef		:= space(004) 
	xdUserDigt      := space(006) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo    ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	aAdd( aPergs ,{1,"Versão:"                      ,xdVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,xdRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,xdAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Usuário Responsável:"         ,xdUserDigt  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo    := ParamLoad(cFileName,,1,cArquivo) 
		xdVersao    := ParamLoad(cFileName,,2,xdVersao) 
		xdRevisa    := ParamLoad(cFileName,,3,xdRevisa) 
		xdAnoRef    := ParamLoad(cFileName,,4,xdAnoRef) 
		xdUserDigt  := ParamLoad(cFileName,,5,xdUserDigt) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZBV'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local M001              := GetNextAlias()
	Local ny
	Local zpt
	Local nx

	Private msrhEnter := CHR(13) + CHR(10)

	// Efetua verificação de Versão e gravação...
	If Empty(xdVersao) .or. Empty(xdRevisa) .or. Empty(xdAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a database" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:xdVersao%
		AND ZB5.ZB5_REVISA = %Exp:xdRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:xdAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
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
	M0007 += "   FROM " + RetSqlName("ZBV") + " ZBV "
	M0007 += "  WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
	M0007 += "    AND ZBV.ZBV_VERSAO = '" + xdVersao + "' "
	M0007 += "    AND ZBV.ZBV_REVISA = '" + xdRevisa + "' "
	M0007 += "    AND ZBV.ZBV_ANOREF = '" + xdAnoRef + "' "
	M0007 += "    AND UPPER(ZBV.ZBV_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
	M0007 += "    AND ZBV.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existem registros CAPEX associados ao arquivo informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados existentes." + msrhEnter + msrhEnter+ " Deseja prosseguir com o importação?")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBV") + " "
			KS001 += "   FROM " + RetSqlName("ZBV") + " ZBV "
			KS001 += "  WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
			KS001 += "    AND ZBV.ZBV_VERSAO = '" + xdVersao + "' "
			KS001 += "    AND ZBV.ZBV_REVISA = '" + xdRevisa + "' "
			KS001 += "    AND ZBV.ZBV_ANOREF = '" + xdAnoRef + "' "
			KS001 += "    AND UPPER(ZBV.ZBV_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
			KS001 += "    AND ZBV.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBV... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		BEGIN TRANSACTION   

			msTotPos := 1
			msVerPos := 1
			msFirstP := .T. 
			For nx := 1 to len(aWorksheet) 

				IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

				If nx == 1

					aCampos := aWorksheet[nx]
					For ny := 1 to len(aCampos)
						cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
						aCampos[ny] := cTemp
					Next ny

				Else

					aLinha    := aWorksheet[nx]
					aItem     := {}
					cConteudo := ''
					msTotMesO := 0
					msCabecIn := .F.

					SX3->(DbSetOrder(2))

					For ny := 1 to Len(aLinha)

						If Len(aCampos) >= ny 

							cConteudo := aLinha[ny]

							If SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

								If Alltrim(Padr(aCampos[ny],10)) == "ZBV_CLVL"
									If Alltrim(cConteudo) == "ClasseValor"
										msCabecIn := .T.
									EndIf
								EndIf

								Do Case

									case SX3->X3_TIPO == "D"
									cConteudo := SubStr(cConteudo,1,10)
									cConteudo := stod(StrTran(cConteudo, "-", ""))

									case SX3->X3_TIPO == "N"
									cConteudo := Val(cConteudo)
									If Alltrim(Padr(aCampos[ny],10)) $ "ZBV_M01/ZBV_M02/ZBV_M03/ZBV_M04/ZBV_M05/ZBV_M06/ZBV_M07/ZBV_M08/ZBV_M09/ZBV_M10/ZBV_M11/ZBV_M12"
										msTotMesO += cConteudo
									EndIf

									case SX3->X3_TIPO == "C"
									cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

								EndCase

								AADD(aItem,{ aCampos[ny] , cConteudo , nil })

							EndIf

						EndIf

					Next ny

					If len(aItem) > 0

						If !msCabecIn .and. msTotMesO <> 0

							RecLock("ZBV", .T.)
							ZBV->ZBV_FILIAL := xFilial("ZBV")
							ZBV->ZBV_VERSAO := xdVersao
							ZBV->ZBV_REVISA := xdRevisa
							ZBV->ZBV_ANOREF := xdAnoRef
							For zpt := 1 to Len(aItem)
								&(aItem[zpt][1]) := aItem[zpt][2]  
							Next zpt
							ZBV->ZBV_USER   := cUserName
							ZBV->ZBV_DTPROC := msDtProc
							ZBV->ZBV_HRPROC := msHrProc
							ZBV->ZBV_FILEIN := Alltrim(cArquivo)
							ZBV->ZBV_LINHAA := nx
							ZBV->ZBV_USRRSP := xdUserDigt
							MsUnlockAll()

							nImport ++

						EndIf

					EndIf

				EndIf

			Next nx

		END TRANSACTION

	EndIf

	If nImport > 0 

		KS006 := " UPDATE " + RetSqlName("ZBV") + " SET ZBV_TOTAL = ZBV_M01 + ZBV_M02 + ZBV_M03 + ZBV_M04 + ZBV_M05 + ZBV_M06 + ZBV_M07 + ZBV_M08 + ZBV_M09 + ZBV_M10 + ZBV_M11 + ZBV_M12 "
		KS006 += "   FROM " + RetSqlName("ZBV") + " ZBV "
		KS006 += "  WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
		KS006 += "    AND ZBV.ZBV_VERSAO = '" + xdVersao + "' "
		KS006 += "    AND ZBV.ZBV_REVISA = '" + xdRevisa + "' "
		KS006 += "    AND ZBV.ZBV_ANOREF = '" + xdAnoRef + "' "
		KS006 += "    AND UPPER(ZBV.ZBV_FILEIN) LIKE UPPER('" + Alltrim(cArquivo) + "') "
		KS006 += "    AND ZBV.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Atualizando totalizadores ZBV... ",,{|| TcSQLExec(KS006) })

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590TRCA ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Troca de Usuário que terá acesso a visualizar os dados     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590TRCA()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private trVersao        := space(010)
	Private trRevisa        := space(003) 
	Private trAnoRef		:= space(004) 
	Private trUserDigt      := space(006) 
	Private trNovoUser      := space(006) 

	AADD(aSays, OemToAnsi("Rotina para Troca de Usuário Responsável pelo Acompanhamento CAPEX Integration!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergTroca() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Troca de Usuário'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcTroca() },"Aguarde...","Carregando Arquivo...",.F.)

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
Static Function fPergTroca()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590TRCA' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	trVersao        := space(010)
	trRevisa        := space(003) 
	trAnoRef		:= space(004) 
	trUserDigt      := space(006)
	trNovoUser      := space(006)

	aAdd( aPergs ,{1,"Versão:"                      ,trVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,trRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,trAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Usuário Responsável:"         ,trUserDigt  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	
	aAdd( aPergs ,{1,"Novo Usuário Responsável:"    ,trNovoUser  ,"@!","NAOVAZIO()",'USR','.T.', 06,.F.})	

	If ParamBox(aPergs ,"Troca Responsável",,,,,,,,cLoad,.T.,.T.)      
		trVersao    := ParamLoad(cFileName,,1,trVersao) 
		trRevisa    := ParamLoad(cFileName,,2,trRevisa) 
		trAnoRef    := ParamLoad(cFileName,,3,trAnoRef) 
		trUserDigt  := ParamLoad(cFileName,,4,trUserDigt) 
		trNovoUser  := ParamLoad(cFileName,,5,trNovoUser) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcTroca()

	Local trrhEnter := CHR(13) + CHR(10)

	VC002 := " SELECT COUNT(*) CONTAD "
	VC002 += "   FROM " + RetSqlName("ZBV") + " ZBV "
	VC002 += "  WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
	VC002 += "    AND ZBV.ZBV_VERSAO = '" + trVersao + "' "
	VC002 += "    AND ZBV.ZBV_REVISA = '" + trRevisa + "' "
	VC002 += "    AND ZBV.ZBV_ANOREF = '" + trAnoRef + "' "
	VC002 += "    AND ZBV_USRRSP = '" + trUserDigt + "' "
	VC002 += "    AND ZBV.D_E_L_E_T_ = ' ' "
	VCIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,VC002),'VC02',.T.,.T.)
	dbSelectArea("VC02")
	VC02->(dbGoTop())

	If VC02->CONTAD <> 0

		trContinua := MsgNOYES("Existem registros CAPEX associados ao usuário responsável mencionado." + trrhEnter + trrhEnter + " São " + Alltrim(Str(VC02->CONTAD)) + " registros." + trrhEnter + trrhEnter+ " Deseja prosseguir com o TROCA de usuário RESPONSÁVEL???")

		If trContinua

			KS001 := " UPDATE " + RetSqlName("ZBV") + " SET ZBV_USRRSP = '" + trNovoUser + "' "
			KS001 += "   FROM " + RetSqlName("ZBV") + " ZBV "
			KS001 += "  WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
			KS001 += "    AND ZBV.ZBV_VERSAO = '" + trVersao + "' "
			KS001 += "    AND ZBV.ZBV_REVISA = '" + trRevisa + "' "
			KS001 += "    AND ZBV.ZBV_ANOREF = '" + trAnoRef + "' "
			KS001 += "    AND ZBV_USRRSP = '" + trUserDigt + "' "
			KS001 += "    AND ZBV.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Trocando usuário responsável ZBV... ",,{|| TcSQLExec(KS001) })

		Else

			VC02->(dbCloseArea())
			Ferase(VCIndex+GetDBExtension())
			Ferase(VCIndex+OrdBagExt())
			Return .F.

		EndIf


	Else

		MsgALERT("Nenhum registro afetado. Usuário responsável não localizado!!!")

		VC02->(dbCloseArea())
		Ferase(VCIndex+GetDBExtension())
		Ferase(VCIndex+OrdBagExt())
		Return .F.

	EndIf

	VC02->(dbCloseArea())
	Ferase(VCIndex+GetDBExtension())
	Ferase(VCIndex+OrdBagExt())

	MsgINFO("Troca de responsável realizada com sucesso!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590CFDG ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27/10/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Lista divergência encontrada pós importação planilhas CAPEX¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590CFDG()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cfVersao        := space(010)
	Private cfRevisa        := space(003) 
	Private cfAnoRef		:= space(004) 

	AADD(aSays, OemToAnsi("Rotina para listar divergência encontrada após importação planilhas CAPEX!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergCfDgt() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Conferência Integridade CAPEX Integration'), aSays, aButtons ,,,500)

	If lConfirm

		Processa({ || fProcConfer() },"Aguarde...","Carregando Arquivo...",.F.)

		MsgINFO('Processamento concluído!')

	Else

		MsgStop('Processo Abortado!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergCfDgt()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590CFDG' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cfVersao        := space(010)
	cfRevisa        := space(003) 
	cfAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,cfVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,cfRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,cfAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Conferência dados CAPEX",,,,,,,,cLoad,.T.,.T.)      
		cfVersao    := ParamLoad(cFileName,,1,cfVersao) 
		cfRevisa    := ParamLoad(cFileName,,2,cfRevisa) 
		cfAnoRef    := ParamLoad(cFileName,,3,cfAnoRef) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcConfer()

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0
	Local _daduser
	Local _mNomeUsr

	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

	ProcRegua(100000)

	oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 60, 300, 60, 60, 60, 120, 60, 60}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + 26 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + 26 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Orçamento - CAPEX", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + 26 + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Versão"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Revisão"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Ano.Ref"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Classe Valor"    , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Descr.CLVL"      , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Empresa"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Conta"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Descr.Cta"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("IniDeprec"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Janeiro"         , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Fevereiro"       , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Março"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Abril"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Maio"            , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Junho"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Julho"           , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Agosto"          , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Setembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Outubro"         , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Novembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Dezembro"        , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("Arquivo Imp"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LinhaArq"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("UsrRespon"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NomeUsrResp"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ContaDeprec"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TaxaDeprec"      , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	KV005 := " WITH CAPEXINT AS (SELECT ZBV_VERSAO, "
	KV005 += "                          ZBV_REVISA, "
	KV005 += "                          ZBV_ANOREF, "
	KV005 += "                          ZBV_CLVL, "
	KV005 += "                          ISNULL(CTH_DESC01, 'ERRO DIGITACAO') CTH_DESC01, "
	KV005 += "                          ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') CTH_YEFORC, "
	KV005 += "                          ZBV_CONTA, "
	KV005 += "                          ISNULL(CT1_DESC01, 'ERRO DIGITACAO') CT1_DESC01, "
	KV005 += "                          ISNULL(CT1_NORMAL, 'E') CT1_NORMAL, "
	KV005 += "                          CASE "
	KV005 += "                            WHEN CT1_NORMAL = '1' THEN 'DEBITO' "
	KV005 += "                            WHEN CT1_NORMAL = '2' THEN 'CREDIT' "
	KV005 += "                            ELSE 'ERROR' "
	KV005 += "                          END NORMAL, "
	KV005 += "                          ZBV_INIDPR, "
	KV005 += "                          ZBV_M01, "
	KV005 += "                          ZBV_M02, "
	KV005 += "                          ZBV_M03, "
	KV005 += "                          ZBV_M04, "
	KV005 += "                          ZBV_M05, "
	KV005 += "                          ZBV_M06, "
	KV005 += "                          ZBV_M07, "
	KV005 += "                          ZBV_M08, "
	KV005 += "                          ZBV_M09, "
	KV005 += "                          ZBV_M10, "
	KV005 += "                          ZBV_M11, "
	KV005 += "                          ZBV_M12, "
	KV005 += "                          ZBV_FILEIN, "
	KV005 += "                          ZBV_LINHAA, "
	KV005 += "                          ZBV_USRRSP, "
	KV005 += "                          ISNULL(ZBX_CTADPR, '') CDEPRE, "
	KV005 += "                          ISNULL(ZBX_TXDPRE, 0) TXDPRE "
	KV005 += "                     FROM " + RetSqlName("ZBV") + " ZBV "
	KV005 += "                     LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1.CT1_CONTA = ZBV.ZBV_CONTA "
	KV005 += "                                         AND CT1.D_E_L_E_T_ = ' ' "
	KV005 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH.CTH_CLVL = ZBV.ZBV_CLVL "
	KV005 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
	KV005 += "                     LEFT JOIN " + RetSqlName("ZBX") + " ZBX ON ZBX.ZBX_VERSAO = ZBV.ZBV_VERSAO
	KV005 += "                                         AND ZBX.ZBX_REVISA = ZBV.ZBV_REVISA
	KV005 += "                                         AND ZBX.ZBX_ANOREF = ZBV.ZBV_ANOREF
	KV005 += "                                         AND ZBX.ZBX_CTAATV = ZBV.ZBV_CONTA
	KV005 += "                                         AND ZBX.ZBX_CHVCV = CTH.CTH_YATRIB
	KV005 += "                                         AND ZBX.D_E_L_E_T_ = ' '
	KV005 += "                    WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
	KV005 += "                      AND ZBV.ZBV_VERSAO = '" + cfVersao + "' "
	KV005 += "                      AND ZBV.ZBV_REVISA = '" + cfRevisa + "' "
	KV005 += "                      AND ZBV.ZBV_ANOREF = '" + cfAnoRef + "' "
	KV005 += "                      AND ZBV.D_E_L_E_T_ = ' ') "
	KV005 += " SELECT * "
	KV005 += "   FROM CAPEXINT "
	//KV005 += "  WHERE CT1_NORMAL = 'E' OR CTH_YEFORC = 'ER' OR TXDPRE = 0 "
	KV005 += "  ORDER BY ZBV_CLVL, ZBV_CONTA "
	KVIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KV005),'KV05',.T.,.T.)
	dbSelectArea("KV05")
	KV05->(dbGoTop())

	If KV05->(!Eof())

		While KV05->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(KV05->(Recno()))) )

			psworder(1)                          // Pesquisa por Nome
			If  pswseek(KV05->ZBV_USRRSP,.t.)    // Nome do usuario, Pesquisa usuarios
				_daduser  := pswret(1)           // Numero do registro
				_mNomeUsr := _daduser[1][4]
			EndIf
			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			oExcel:AddCelula( KV05->ZBV_VERSAO                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_REVISA                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_ANOREF                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_CLVL                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CTH_DESC01                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CTH_YEFORC                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_CONTA                             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CT1_DESC01                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( dtoc(stod(KV05->ZBV_INIDPR))                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M01                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M02                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M03                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M04                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M05                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M06                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M07                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M08                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M09                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M10                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M11                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_M12                               , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_FILEIN                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_LINHAA                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->ZBV_USRRSP                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( _mNomeUsr                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->CDEPRE                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( KV05->TXDPRE                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			KV05->(dbSkip())

		EndDo

	EndIf

	KV05->(dbCloseArea())
	Ferase(KVIndex+GetDBExtension())
	Ferase(KVIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590SN3O ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclui registros de ATF p/ Orçamento a partir da SN3       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590SN3O()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private n3Versao    := space(010)
	Private n3Revisa    := space(003) 
	Private n3AnoRef    := space(004) 
	Private n3rhEnter   := CHR(13) + CHR(10)
	Private msrhEnter := CHR(13) + CHR(10)	
	Private n3Continua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Geração de registros de ATF p/ Orçamento a partir da SN3!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergSN3Or() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração SN3 P/ ATF Orcto'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a database" + msrhEnter
		xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:n3Versao%
			AND ZB5.ZB5_REVISA = %Exp:n3Revisa%
			AND ZB5.ZB5_ANOREF = %Exp:n3AnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
			AND ZB5.ZB5_DTENCR = ''
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		NY007 := " SELECT COUNT(*) CONTAD "
		NY007 += "   FROM " + RetSqlName("ZBY") + " ZBY "
		NY007 += "  WHERE ZBY.ZBY_FILIAL = '" + xFilial("ZBY") + "' "
		NY007 += "    AND ZBY.ZBY_VERSAO = '" + n3Versao + "' "
		NY007 += "    AND ZBY.ZBY_REVISA = '" + n3Revisa + "' "
		NY007 += "    AND ZBY.ZBY_ANOREF = '" + n3AnoRef + "' "
		NY007 += "    AND ZBY.ZBY_TABORI = 'SN3' "
		NY007 += "    AND ZBY.D_E_L_E_T_ = ' ' "
		NYIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,NY007),'NY07',.T.,.T.)
		dbSelectArea("NY07")
		NY07->(dbGoTop())

		If NY07->CONTAD <> 0

			n3Continua := MsgNOYES("Já existe ATF p/ Orçamento para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		NY07->(dbCloseArea())
		Ferase(NYIndex+GetDBExtension())
		Ferase(NYIndex+OrdBagExt())

		If n3Continua

			Processa({ || cMsg := fProcSN3Or() },"Aguarde...","Carregando Arquivo...",.F.)

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parâmetros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergSN3Or()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590SN3O' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	n3Versao        := space(010)
	n3Revisa        := space(003) 
	n3AnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,n3Versao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,n3Revisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,n3AnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração SN3 p/ ATF Orcto",,,,,,,,cLoad,.T.,.T.)      
		n3Versao    := ParamLoad(cFileName,,1,n3Versao) 
		n3Revisa    := ParamLoad(cFileName,,2,n3Revisa) 
		n3AnoRef    := ParamLoad(cFileName,,3,n3AnoRef) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcSN3Or()

	Local n3xy
	Local n3EmprPrc := {"01","05","06","07","12","13","14"}

	ProcRegua(0)
	For n3xy := 1 to Len(n3EmprPrc)

		IncProc("Empresa: " + n3EmprPrc[n3xy] + " .... " )

		CS001 := " DELETE ZBY" + n3EmprPrc[n3xy] + "0 "
		CS001 += "   FROM ZBY" + n3EmprPrc[n3xy] + "0 ZBY "
		CS001 += "  WHERE ZBY.ZBY_VERSAO = '" + n3Versao + "' "
		CS001 += "    AND ZBY.ZBY_REVISA = '" + n3Revisa + "' "
		CS001 += "    AND ZBY.ZBY_ANOREF = '" + n3AnoRef + "' "
		CS001 += "    AND ZBY.ZBY_TABORI = 'SN3' "
		CS001 += "    AND ZBY.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando registros ZBY... ",,{|| TcSQLExec(CS001) })

		UJ005 := " INSERT INTO ZBY" + n3EmprPrc[n3xy] + "0 "
		UJ005 += " ( "
		UJ005 += "  ZBY_FILIAL, "
		UJ005 += "  ZBY_VERSAO, "
		UJ005 += "  ZBY_REVISA, "
		UJ005 += "  ZBY_ANOREF, "
		UJ005 += "  ZBY_TABORI, "
		UJ005 += "  ZBY_CBASE, "
		UJ005 += "  ZBY_ITEM, "
		UJ005 += "  ZBY_HIST, "
		UJ005 += "  ZBY_AQUISI, "
		UJ005 += "  ZBY_CCONTA, "
		UJ005 += "  ZBY_CDEPRE, "
		UJ005 += "  ZBY_CLVL, "
		UJ005 += "  ZBY_VORIG, "
		UJ005 += "  ZBY_TXDEPR, "
		UJ005 += "  ZBY_VRDMES, "
		UJ005 += "  ZBY_VRDACM, "
		UJ005 += "  ZBY_DTIDPR, "
		UJ005 += "  ZBY_DTFDPR, "
		UJ005 += "  D_E_L_E_T_, "
		UJ005 += "  R_E_C_N_O_, "
		UJ005 += "  R_E_C_D_E_L_ "
		UJ005 += " ) "
		UJ005 += " SELECT N3_FILIAL, "
		UJ005 += "        '" + n3Versao + "' VERSAO, "
		UJ005 += "        '" + n3Revisa + "' REVISA, "
		UJ005 += "        '" + n3AnoRef + "' ANOREF, "
		UJ005 += "        'SN3' ORIPRC, "
		UJ005 += "        N3_CBASE, "
		UJ005 += "        N3_ITEM, "
		UJ005 += "        N3_HISTOR, "
		UJ005 += "        N3_AQUISIC, "
		UJ005 += "        N3_CCONTAB, "
		UJ005 += "        N3_CDEPREC, "
		UJ005 += "        N3_CLVLCON, "
		UJ005 += "        N3_VORIG1, "
		UJ005 += "        N3_TXDEPR1, "
		UJ005 += "        N3_VRDMES1, "
		UJ005 += "        N3_VRDACM1, "
		UJ005 += "        N3_DINDEPR, "
		UJ005 += "        CONVERT(CHAR(10), "
		UJ005 += "                          CASE "
		UJ005 += "                             WHEN N3_TXDEPR1 = 0 THEN N3_DINDEPR "
		UJ005 += "                             ELSE DATEADD (year , 100/N3_TXDEPR1 , N3_DINDEPR) "
		UJ005 += "                          END, 112) DFIMDPRE, "
		UJ005 += "        D_E_L_E_T_, "
		UJ005 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZBY" + n3EmprPrc[n3xy] + "0) + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
		UJ005 += "        R_E_C_D_E_L_ "
		UJ005 += "   FROM SN3" + n3EmprPrc[n3xy] + "0 "
		UJ005 += "  WHERE N3_BAIXA <> '1' "
		UJ005 += "    AND N3_VORIG1 > N3_VRDACM1 "
		UJ005 += "    AND N3_CDEPREC <> '                    ' "
		UJ005 += "    AND N3_TXDEPR1 <> 0 "
		UJ005 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Convertendo SN3 em ATF p/ ORCTO... ",,{|| TcSQLExec(UJ005) })

	Next n3ny

	MsgINFO("Conversão SN3 em ATF p/ ORCTO realizada com sucesso!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590ZBVO ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclui registros de ATF p/ Orçamento a partir da ZBV       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B590ZBVO()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private zvVersao    := space(010)
	Private zvRevisa    := space(003) 
	Private zvAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private zvContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Geração de registros de ATF p/ Orçamento a partir da ZBV!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergZBVOr() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração ZBV P/ ATF Orcto'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a database" + msrhEnter
		xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:zvVersao%
			AND ZB5.ZB5_REVISA = %Exp:zvRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:zvAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
			AND ZB5.ZB5_DTENCR = ''
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		NY008 := " SELECT COUNT(*) CONTAD "
		NY008 += "   FROM " + RetSqlName("ZBY") + " ZBY "
		NY008 += "  WHERE ZBY.ZBY_FILIAL = '" + xFilial("ZBY") + "' "
		NY008 += "    AND ZBY.ZBY_VERSAO = '" + zvVersao + "' "
		NY008 += "    AND ZBY.ZBY_REVISA = '" + zvRevisa + "' "
		NY008 += "    AND ZBY.ZBY_ANOREF = '" + zvAnoRef + "' "
		NY008 += "    AND ZBY.ZBY_TABORI = 'ZBV' "
		NY008 += "    AND ZBY.D_E_L_E_T_ = ' ' "
		NYIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,NY008),'NY08',.T.,.T.)
		dbSelectArea("NY08")
		NY08->(dbGoTop())

		If NY08->CONTAD <> 0

			zvContinua := MsgNOYES("Já existe ATF p/ Orçamento para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		NY08->(dbCloseArea())
		Ferase(NYIndex+GetDBExtension())
		Ferase(NYIndex+OrdBagExt())

		If zvContinua

			Processa({ || cMsg := fProcZBVOr() },"Aguarde...","Carregando Arquivo...",.F.)

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parâmetro                                                             ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergZBVOr()

	Local aPergs 	:= {}
	Local cLoad	    := 'B590ZBVO' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	zvVersao        := space(010)
	zvRevisa        := space(003) 
	zvAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,zvVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,zvRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,zvAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração ZBV p/ ATF Orcto",,,,,,,,cLoad,.T.,.T.)      
		zvVersao    := ParamLoad(cFileName,,1,zvVersao) 
		zvRevisa    := ParamLoad(cFileName,,2,zvRevisa) 
		zvAnoRef    := ParamLoad(cFileName,,3,zvAnoRef) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcZBVOr()

	Local trrhEnter := CHR(13) + CHR(10)
	Local lvxt

	XL008 := " WITH CAPEXINT AS (SELECT ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') EMPR "
	XL008 += "                     FROM " + RetSqlName("ZBV") + " ZBV "
	XL008 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBV_CLVL "
	XL008 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
	XL008 += "                    WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
	XL008 += "                      AND ZBV.ZBV_VERSAO = '" + zvVersao + "' "
	XL008 += "                      AND ZBV.ZBV_REVISA = '" + zvRevisa + "' "
	XL008 += "                      AND ZBV.ZBV_ANOREF = '" + zvAnoRef + "' "
	XL008 += "                      AND ZBV.D_E_L_E_T_ = ' ' "
	XL008 += "                    GROUP BY SUBSTRING(CTH_YEFORC,1,2)) "
	XL008 += " SELECT * "
	XL008 += "   FROM CAPEXINT "
	XL008 += "  WHERE EMPR <> 'ER' "
	XL008 += "  ORDER BY EMPR "
	XLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XL008),'XL08',.T.,.T.)
	dbSelectArea("XL08")
	XL08->(dbGoTop())
	ProcRegua(LASTREC())
	If XL08->(!Eof())

		While XL08->(!Eof())

			ksEmpres := XL08->EMPR
			While XL08->(!Eof()) .and. XL08->EMPR == ksEmpres  

				KP001 := " DELETE ZBY" + ksEmpres + "0 "
				KP001 += "   FROM ZBY" + ksEmpres + "0 ZBY "
				KP001 += "  WHERE ZBY.ZBY_VERSAO = '" + zvVersao + "' "
				KP001 += "    AND ZBY.ZBY_REVISA = '" + zvRevisa + "' "
				KP001 += "    AND ZBY.ZBY_ANOREF = '" + zvAnoRef + "' "
				KP001 += "    AND ZBY.ZBY_TABORI = 'ZBV' "
				KP001 += "    AND ZBY.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros ZBY... ",,{|| TcSQLExec(KP001) })

				For lvxt := 1 to 12

					IncProc("Empresa: " + ksEmpres + ", " + AllTrim(Str(lvxt)) )

					YY004 := " WITH CAPEXINT AS (SELECT SUBSTRING(CTH.CTH_YEFORC,1,2) EMPR, "
					YY004 += "                          ZBV.ZBV_FILIAL, "
					YY004 += "                          ZBV.ZBV_VERSAO, "
					YY004 += "                          ZBV.ZBV_REVISA, "
					YY004 += "                          ZBV.ZBV_ANOREF, "
					YY004 += "                          ZBV.ZBV_CLVL, "
					YY004 += "                          ZBV.ZBV_CONTA, "
					YY004 += "                          RTRIM(ZBV.ZBV_DRIVER) + ' - ' + RTRIM(ZBV.ZBV_ITCUST) DESCRBEM, "
					YY004 += "                          ZBV.ZBV_M" + StrZero(lvxt,2) + " VLRMES, "
					YY004 += "                          ZBV.R_E_C_N_O_ REGZBV, "
					YY004 += "                          CTH.CTH_YATRIB CHVCV "
					YY004 += "                     FROM " + RetSqlName("ZBV") + " ZBV "
					YY004 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBV_CLVL "
					YY004 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
					YY004 += "                    WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
					YY004 += "                      AND ZBV.ZBV_VERSAO = '" + zvVersao + "' "
					YY004 += "                      AND ZBV.ZBV_REVISA = '" + zvRevisa + "' "
					YY004 += "                      AND ZBV.ZBV_ANOREF = '" + zvAnoRef + "' "
					YY004 += "                      AND ZBV.ZBV_M" + StrZero(lvxt,2) + " <> 0 "
					YY004 += "                      AND ZBV.D_E_L_E_T_ = ' ') "
					YY004 += " INSERT INTO ZBY" + ksEmpres + "0 "
					YY004 += " ( "
					YY004 += "  ZBY_FILIAL, "
					YY004 += "  ZBY_VERSAO, "
					YY004 += "  ZBY_REVISA, "
					YY004 += "  ZBY_ANOREF, "
					YY004 += "  ZBY_TABORI, "
					YY004 += "  ZBY_CBASE, "
					YY004 += "  ZBY_ITEM, "
					YY004 += "  ZBY_HIST, "
					YY004 += "  ZBY_AQUISI, "
					YY004 += "  ZBY_CCONTA, "
					YY004 += "  ZBY_CDEPRE, "
					YY004 += "  ZBY_CLVL, "
					YY004 += "  ZBY_VORIG, "
					YY004 += "  ZBY_TXDEPR, "
					YY004 += "  ZBY_VRDMES, "
					YY004 += "  ZBY_VRDACM, "
					YY004 += "  ZBY_DTIDPR, "
					YY004 += "  ZBY_DTFDPR, "
					YY004 += "  D_E_L_E_T_, "
					YY004 += "  R_E_C_N_O_, "
					YY004 += "  R_E_C_D_E_L_ "
					YY004 += " ) "
					YY004 += " SELECT ZBV_FILIAL, "
					YY004 += "        ZBV_VERSAO, "
					YY004 += "        ZBV_REVISA, "
					YY004 += "        ZBV_ANOREF, "
					YY004 += "        'ZBV' ZBY_TABORI, "
					YY004 += "        REPLICATE('0', 10 - LEN(RTRIM(REGZBV))) + RTrim(REGZBV) ZBY_CBASE, "
					YY004 += "        ZBY_ITEM = (SELECT REPLICATE('0', 4 - LEN(RTRIM(CONVERT(CHAR, COUNT(*) + 1)))) + RTrim(CONVERT(CHAR, COUNT(*) + 1)) CONTAD "
					YY004 += "                      FROM ZBY" + ksEmpres + "0 ZBY "
					YY004 += "                     WHERE ZBY.ZBY_VERSAO = CAPXI.ZBV_VERSAO "
					YY004 += "                       AND ZBY.ZBY_REVISA = CAPXI.ZBV_REVISA "
					YY004 += "                       AND ZBY.ZBY_ANOREF = CAPXI.ZBV_ANOREF "
					YY004 += "                       AND ZBY.ZBY_TABORI = 'ZBV' "
					YY004 += "                       AND ZBY.ZBY_CBASE = REPLICATE('0', 10 - LEN(RTRIM(CAPXI.REGZBV))) + RTrim(CAPXI.REGZBV) "
					YY004 += "                       AND ZBY.D_E_L_E_T_ = ' '), "
					YY004 += "        SUBSTRING(DESCRBEM,1,100) ZBY_HIST, "
					YY004 += "        CAPXI.ZBV_ANOREF+'" + StrZero(lvxt,2) + "'+'01' ZBY_AQUISI, "
					YY004 += "        ZBV_CONTA ZBY_CCONTA, "
					YY004 += "        ZBX_CTADPR ZBY_CDEPRE, "
					YY004 += "        ZBV_CLVL ZBY_CLVL, "
					YY004 += "        VLRMES ZBY_VORIG, "
					YY004 += "        ZBX_TXDPRE ZBY_TXDEPR, "
					YY004 += "        ROUND(VLRMES / ( ZBX_TXDPRE * 12 ),2) ZBY_VRDMES, "
					YY004 += "        0 ZBY_VRDACM, "
					YY004 += "        CONVERT(CHAR, DATEADD (MONTH , 1 , CAPXI.ZBV_ANOREF+'" + StrZero(lvxt,2) + "'+'01'), 112) ZBY_DTIDPR, "
					YY004 += "        CONVERT(CHAR, DATEADD (year , 100/ZBX_TXDPRE , DATEADD (MONTH , 1 , CAPXI.ZBV_ANOREF+'" + StrZero(lvxt,2) + "'+'01')), 112) ZBY_DTFDPR, "
					YY004 += "        ' ' D_E_L_E_T_, "
					YY004 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZBY" + ksEmpres + "0) + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
					YY004 += "        0 R_E_C_D_E_L_ "
					YY004 += "   FROM CAPEXINT CAPXI "
					YY004 += "   LEFT JOIN " + RetSqlName("ZBX") + " ZBX ON ZBX.ZBX_VERSAO = CAPXI.ZBV_VERSAO "
					YY004 += "                       AND ZBX.ZBX_REVISA = CAPXI.ZBV_REVISA "
					YY004 += "                       AND ZBX.ZBX_ANOREF = CAPXI.ZBV_ANOREF "
					YY004 += "                       AND ZBX.ZBX_CTAATV = CAPXI.ZBV_CONTA "
					YY004 += "                       AND ZBX.ZBX_CHVCV = CHVCV "
					YY004 += "                       AND ZBX.D_E_L_E_T_ = ' ' "
					YY004 += "  WHERE EMPR = '" + ksEmpres + "' "
					YY004 += "  ORDER BY ZBV_CLVL, ZBV_CONTA "
					U_BIAMsgRun("Aguarde... Convertendo CAPEX em DEPESAS... ",,{|| TcSQLExec(YY004) })

				Next lvxt

				XL08->(dbSkip())

			EndDo

		EndDo

	EndIf	

	XL08->(dbCloseArea())
	Ferase(XLIndex+GetDBExtension())
	Ferase(XLIndex+OrdBagExt())

	MsgINFO("Conversão ZBV em ATF p/ ORCTO realizada com sucesso!!!")

Return
