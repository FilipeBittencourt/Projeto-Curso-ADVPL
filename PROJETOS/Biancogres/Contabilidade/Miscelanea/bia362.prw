#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA362
@author Marcos Alberto Soprani
@since 08/01/18
@version 1.0
@description Browser principal para a rotina Meta/Orçamento p/ GMCD
@type function
/*/

User Function BIA362()

	Local aArea         := GetArea()
	Private msrhEnter   := CHR(13) + CHR(10)

	Private cCadastro 	:= "Meta/Orçamento p/ GMCD"
	Private aRotina 	:= { {"Pesquisar"               ,"AxPesqui"     ,0,1},;
	{                         "Visualizar"              ,"AxVisual"     ,0,2},;
	{                         "Corrige Driver Padrão"	,"U_BIA362D()"  ,0,3},;
	{                         "OrcaFinal p/ Meta"       ,"U_BIA362A()"  ,0,4},;
	{                         "ForeCast p/ Meta"        ,"U_BIA362F()"  ,0,5} }

	dbSelectArea("ZBF")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZBF",,,,,,)

	RestArea(aArea)

Return

//************************
// OrcaFinal p/ Meta    **
//************************
User Function BIA362A()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados do Orçamento Final para base de dados Meta!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA362B() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração OrcaFinal com META'), aSays, aButtons ,,,500)

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
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
			AND ZB5.ZB5_STATUS = 'F'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão CONTABIL informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBF") + " ZBF "
		M0007 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + idAnoRef + "0101' AND '" + idAnoRef + "1231' "
		M0007 += "    AND SUBSTRING(ZBF.ZBF_ORGLAN, 1, 8) <> 'AJUSTADO' "
		M0007 += "    AND ZBF.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para Meta para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcIntMD() },"Aguarde...","Carregando Arquivo...",.F.)

			MsgINFO(" Fim do processamento...")

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros - OrcaFinal p/ Meta                                        ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA362B()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA362B' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração OrcaFinal p/ Meta",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
	Endif

Return 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento - OrcaFinal p/ Meta                                     ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcIntMD()

	KS001 := " DELETE " + RetSqlName("ZBF") + " "
	KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
	KS001 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + idAnoRef + "0101' AND '" + idAnoRef + "1231' "
	KS001 += "    AND ZBF.ZBF_ORGLAN NOT LIKE '%AJUSTADO%' "
	KS001 += "    AND ZBF.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| TcSQLExec(KS001) })

	ET003 := "INSERT INTO " + RetSqlName("ZBF") + " "
	ET003 += "(ZBF_FILIAL, "
	ET003 += " ZBF_DATA, "
	ET003 += " ZBF_LOTE, "
	ET003 += " ZBF_SBLOTE, "
	ET003 += " ZBF_DOC, "
	ET003 += " ZBF_LINHA, "
	ET003 += " ZBF_DC, "
	ET003 += " ZBF_DEBITO, "
	ET003 += " ZBF_CREDIT, "
	ET003 += " ZBF_CLVLDB, "
	ET003 += " ZBF_CLVLCR, "
	ET003 += " ZBF_ITEMDB, "
	ET003 += " ZBF_ITEMCR, "
	ET003 += " ZBF_VALOR, "
	ET003 += " ZBF_HIST, "
	ET003 += " ZBF_YHIST, "
	ET003 += " ZBF_YSI, "
	ET003 += " ZBF_YDELTA, "
	ET003 += " D_E_L_E_T_, "
	ET003 += " R_E_C_N_O_, "
	ET003 += " R_E_C_D_E_L_, "
	ET003 += " ZBF_DRVDB, "
	ET003 += " ZBF_DRVCR, "
	ET003 += " ZBF_YAPLIC, "
	ET003 += " ZBF_ORGLAN, "
	ET003 += " ZBF_SEQUEN, "
	ET003 += " ZBF_GMCD) "
	ET003 += "       SELECT ZBZ_FILIAL, "
	ET003 += "              ZBZ_DATA, "
	ET003 += "              ZBZ_LOTE, "
	ET003 += "              ZBZ_SBLOTE, "
	ET003 += "              ZBZ_DOC, "
	ET003 += "              ZBZ_LINHA, "
	ET003 += "              ZBZ_DC, "
	ET003 += "              ZBZ_DEBITO, "
	ET003 += "              ZBZ_CREDIT, "
	ET003 += "              ZBZ_CLVLDB, "
	ET003 += "              ZBZ_CLVLCR, "
	ET003 += "              ZBZ_ITEMD, "
	ET003 += "              ZBZ_ITEMC, "
	ET003 += "              SUM(ZBZ_VALOR) VALOR, "
	ET003 += "              ZBZ_HIST, "
	ET003 += "              ZBZ_YHIST, "
	ET003 += "              ZBZ_SI, "
	ET003 += "              '" + dtos(dDataBase) + "' ZBZ_YDELTA, "
	ET003 += "              D_E_L_E_T_, "
	ET003 += "              (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZBF") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
	ET003 += "              R_E_C_D_E_L_, "
	ET003 += "              ZBZ_DRVDB, "
	ET003 += "              ZBZ_DRVCR, "
	ET003 += "              ZBZ_APLIC APLIC, "
	ET003 += "              '' ORGLAN, "
	ET003 += "              '' SEQUEN, "
	ET003 += "              'S' GMCD "
	ET003 += "       FROM " + RetSqlName("ZBZ") + " "
	ET003 += "       WHERE ZBZ_VERSAO = '" + idVersao + "' "
	ET003 += "             AND ZBZ_REVISA = '" + idRevisa + "' "
	ET003 += "             AND ZBZ_ANOREF = '" + idAnoRef + "' "
	ET003 += "             AND ZBZ_DEBITO NOT IN('61112001','61111001') "
	ET003 += "             AND ZBZ_CREDIT NOT IN('61112001','61111001') "
	ET003 += "             AND ( ( SUBSTRING(ZBZ_DEBITO,1,1) IN('3','6') OR ZBZ_DEBITO = '41301001' ) "
	ET003 += "              OR ( SUBSTRING(ZBZ_CREDIT,1,1) IN('3','6') OR ZBZ_CREDIT = '41301001' ) ) "
	//If cEmpAnt == "05"
	//	ET003 += "             AND SUBSTRING(ZBZ_DEBITO, 1, 3) <> '615' "
	//	ET003 += "             AND SUBSTRING(ZBZ_CREDIT, 1, 3) <> '615' "
	//EndIf
	ET003 += "             AND D_E_L_E_T_ = ' ' "
	ET003 += "       GROUP BY ZBZ_FILIAL, "
	ET003 += "                ZBZ_DATA, "
	ET003 += "                ZBZ_LOTE, "
	ET003 += "                ZBZ_SBLOTE, "
	ET003 += "                ZBZ_DOC, "
	ET003 += "                ZBZ_LINHA, "
	ET003 += "                ZBZ_DC, "
	ET003 += "                ZBZ_DEBITO, "
	ET003 += "                ZBZ_CREDIT, "
	ET003 += "                ZBZ_CLVLDB, "
	ET003 += "                ZBZ_CLVLCR, "
	ET003 += "                ZBZ_ITEMD, "
	ET003 += "                ZBZ_ITEMC, "
	ET003 += "                ZBZ_HIST, "
	ET003 += "                ZBZ_YHIST, "
	ET003 += "                ZBZ_SI, "
	ET003 += "                ZBZ_YDELTA, "
	ET003 += "                D_E_L_E_T_, "
	ET003 += "                R_E_C_N_O_, "
	ET003 += "                R_E_C_D_E_L_, "
	ET003 += "                ZBZ_DRVDB, "
	ET003 += "                ZBZ_DRVCR, "
	ET003 += "                ZBZ_APLIC "
	U_BIAMsgRun("Aguarde... Convertendo OrcaFinal em Meta... ",,{|| TcSQLExec(ET003) })

Return

//************************
// ForeCast p/ Meta     **
//************************
User Function BIA362F()

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

	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados do ForeCast para base de dados Meta!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA362G() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração ForeCast com META'), aSays, aButtons ,,,500)

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
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
			AND ZB5.ZB5_STATUS = 'F'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 0
			MsgALERT("A versão CONTABIL informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			//(M001)->(dbCloseArea())
			//Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBF") + " ZBF "
		M0007 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
		M0007 += "    AND ZBF.ZBF_SEQUEN = '" + miSeqDes + "' "
		M0007 += "    AND ZBF.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para Meta para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcForeCa() },"Aguarde...","Carregando Arquivo...",.F.)

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
Static Function BIA362G()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA362G' + cEmpAnt
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
	aAdd( aPergs ,{1,"Ano ForeCast: "               ,miAno      ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	
	aAdd( aPergs ,{1,"Mês De ForeCast: "            ,miMesDe    ,"@!","NAOVAZIO()",''   ,'.T.', 02,.F.})	
	aAdd( aPergs ,{1,"Mês Até ForeCast: "           ,miMesAt    ,"@!","NAOVAZIO()",''   ,'.T.', 02,.F.})	
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
Static Function fProcForeCa()

	Local msStaExcQy    := 0
	Local lOk           := .T.

	msDtAteUlt := dtos(UltimoDia(stod(miAno + miMesAt + "01")))

	Begin Transaction

		// Deleta registros da sequência DESTINO.
		KS001 := " DELETE ZBF "
		KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
		KS001 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
		KS001 += "    AND ZBF.ZBF_SEQUEN = '" + miSeqDes + "' "
		KS001 += "    AND ZBF.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| msStaExcQy := TcSQLExec(KS001) })
		If msStaExcQy < 0
			lOk := .F.
		EndIf

		If lOk

			// Converte REALIZADO em META para o período do ano já transcorrido.
			FJ004 := " WITH FORECAST "
			FJ004 += "      AS (SELECT SUBSTRING(DTREF, 1, 6) + '01' ZBZ_DATA, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN DEBITO <> 0 "
			FJ004 += "                     THEN CONTA "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_DEBITO, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN CREDITO <> 0 "
			FJ004 += "                     THEN CONTA "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_CREDIT, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN DEBITO <> 0 "
			FJ004 += "                     THEN CLVL "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_CLVLDB, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN CREDITO <> 0 "
			FJ004 += "                     THEN CLVL "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_CLVLCR, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN DEBITO <> 0 "
			FJ004 += "                     THEN ITEM "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_ITEMD, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN CREDITO <> 0 "
			FJ004 += "                     THEN ITEM "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_ITEMC, "
			FJ004 += "                 SI ZBZ_SI, "
			FJ004 += "                 ABS(VALOR) VALOR, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN DEBITO <> 0 "
			FJ004 += "                     THEN DRIVER "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_DRVDB, "
			FJ004 += "                 CASE "
			FJ004 += "                     WHEN CREDITO <> 0 "
			FJ004 += "                     THEN DRIVER "
			FJ004 += "                     ELSE '' "
			FJ004 += "                 END ZBZ_DRVCR, "
			FJ004 += "                 APLICACAO APLIC "
			FJ004 += "          FROM VW_SAP_CTB_MOVCONTABIL "
			FJ004 += "          WHERE DTREF BETWEEN '" + miAno + miMesDe + "01' AND '" + msDtAteUlt + "' "
			FJ004 += "                AND VERSAO = '001' "
			FJ004 += "                AND CONTA NOT IN('61112001', '61111001') "
			FJ004 += "                AND (SUBSTRING(CONTA, 1, 1) IN('3', '6') OR CONTA = '41301001') "
			FJ004 += "                AND EMPR = '" + cEmpAnt+ "'
			// Tratamento específico para a revião orçamentária realizada em junho de 2020
			FJ004 += "                AND NOT ( SUBSTRING(DTREF,1,6) IN('202001', '202002', '202003') AND SUBSTRING(CONTA,1,5) IN('31401', '31403')  ) "
			// Fim do tratamento
			FJ004 += "                AND D_E_L_E_T_ = ' ') "
			FJ004 += "      INSERT INTO " + RetSqlName("ZBF") + " "
			FJ004 += "      (ZBF_FILIAL, "
			FJ004 += "       ZBF_DATA, "
			FJ004 += "       ZBF_LOTE, "
			FJ004 += "       ZBF_SBLOTE, "
			FJ004 += "       ZBF_DOC, "
			FJ004 += "       ZBF_LINHA, "
			FJ004 += "       ZBF_DC, "
			FJ004 += "       ZBF_DEBITO, "
			FJ004 += "       ZBF_CREDIT, "
			FJ004 += "       ZBF_CLVLDB, "
			FJ004 += "       ZBF_CLVLCR, "
			FJ004 += "       ZBF_ITEMDB, "
			FJ004 += "       ZBF_ITEMCR, "
			FJ004 += "       ZBF_VALOR, "
			FJ004 += "       ZBF_HIST, "
			FJ004 += "       ZBF_YHIST, "
			FJ004 += "       ZBF_YSI, "
			FJ004 += "       ZBF_YDELTA, "
			FJ004 += "       D_E_L_E_T_, "
			FJ004 += "       R_E_C_N_O_, "
			FJ004 += "       R_E_C_D_E_L_, "
			FJ004 += "       ZBF_DRVDB, "
			FJ004 += "       ZBF_DRVCR, "
			FJ004 += "       ZBF_YAPLIC, "
			FJ004 += "       ZBF_ORGLAN, "
			FJ004 += "       ZBF_SEQUEN, "
			FJ004 += "       ZBF_GMCD "
			FJ004 += "      ) "
			FJ004 += "             SELECT '" + xFilial("ZBZ") + "' ZBZ_FILIAL, "
			FJ004 += "                    ZBZ_DATA, "
			FJ004 += "                    '007777' ZBZ_LOTE, "
			FJ004 += "                    '001' ZBZ_SBLOTE, "
			FJ004 += "                    '005248' ZBZ_DOC, "
			FJ004 += "                    '' ZBZ_LINHA, "
			FJ004 += "                    CASE 
			FJ004 += "                      WHEN ZBZ_DEBITO <> '' THEN '1' 
			FJ004 += "                      WHEN ZBZ_CREDIT <> '' THEN '2' 
			FJ004 += "                      ELSE ''
			FJ004 += "                    END ZBZ_DC, "
			FJ004 += "                    ZBZ_DEBITO, "
			FJ004 += "                    ZBZ_CREDIT, "
			FJ004 += "                    ZBZ_CLVLDB, "
			FJ004 += "                    ZBZ_CLVLCR, "
			FJ004 += "                    ZBZ_ITEMD, "
			FJ004 += "                    ZBZ_ITEMC, "
			FJ004 += "                    VALOR VALOR, "
			FJ004 += "                    'FORECAST " + miMesAt + "/" + miAno + "' ZBZ_HIST, "
			FJ004 += "                    'FORECAST " + miMesAt + "/" + miAno + "' ZBZ_YHIST, "
			FJ004 += "                    ZBZ_SI, "
			FJ004 += "                    '" + dtos(dDataBase) + "' ZBZ_YDELTA, "
			FJ004 += "                    ' ' D_E_L_E_T_, "
			FJ004 += "                    (SELECT ISNULL(MAX(R_E_C_N_O_), 0) FROM " + RetSqlName("ZBF") + ") + ROW_NUMBER() OVER( ORDER BY ZBZ_DATA) AS R_E_C_N_O_, "
			FJ004 += "                    0 R_E_C_D_E_L_, "
			FJ004 += "                    ZBZ_DRVDB, "
			FJ004 += "                    ZBZ_DRVCR, "
			FJ004 += "                    APLIC APLIC, "
			FJ004 += "                    '' ORGLAN, "
			FJ004 += "                    '" + miSeqDes + "' SEQUEN, "
			FJ004 += "                    'S' GMCD "
			FJ004 += "             FROM "
			FJ004 += "             ( "
			FJ004 += "                 SELECT ZBZ_DATA, "
			FJ004 += "                        ZBZ_DEBITO, "
			FJ004 += "                        ZBZ_CREDIT, "
			FJ004 += "                        ZBZ_CLVLDB, "
			FJ004 += "                        ZBZ_CLVLCR, "
			FJ004 += "                        ZBZ_ITEMD, "
			FJ004 += "                        ZBZ_ITEMC, "
			FJ004 += "                        ZBZ_SI, "
			FJ004 += "                        ZBZ_DRVDB, "
			FJ004 += "                        ZBZ_DRVCR, "
			FJ004 += "                        APLIC, "
			FJ004 += "                        SUM(VALOR) VALOR "
			FJ004 += "                 FROM FORECAST "
			FJ004 += "                 GROUP BY ZBZ_DATA, "
			FJ004 += "                          ZBZ_DEBITO, "
			FJ004 += "                          ZBZ_CREDIT, "
			FJ004 += "                          ZBZ_CLVLDB, "
			FJ004 += "                          ZBZ_CLVLCR, "
			FJ004 += "                          ZBZ_ITEMD, "
			FJ004 += "                          ZBZ_ITEMC, "
			FJ004 += "                          ZBZ_SI, "
			FJ004 += "                          ZBZ_DRVDB, "
			FJ004 += "                          ZBZ_DRVCR, "
			FJ004 += "                          APLIC "
			FJ004 += "             ) AS TABLX "
			U_BIAMsgRun("Aguarde... Convertendo REALIZADO em META... ",,{|| msStaExcQy := TcSQLExec(FJ004) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

		EndIf

		If lOk

			// Converte ORCAFINAL (revisado) em META para o período do ano que está por vir.
			ET003 := "INSERT INTO " + RetSqlName("ZBF") + " "
			ET003 += "(ZBF_FILIAL, "
			ET003 += " ZBF_DATA, "
			ET003 += " ZBF_LOTE, "
			ET003 += " ZBF_SBLOTE, "
			ET003 += " ZBF_DOC, "
			ET003 += " ZBF_LINHA, "
			ET003 += " ZBF_DC, "
			ET003 += " ZBF_DEBITO, "
			ET003 += " ZBF_CREDIT, "
			ET003 += " ZBF_CLVLDB, "
			ET003 += " ZBF_CLVLCR, "
			ET003 += " ZBF_ITEMDB, "
			ET003 += " ZBF_ITEMCR, "
			ET003 += " ZBF_VALOR, "
			ET003 += " ZBF_HIST, "
			ET003 += " ZBF_YHIST, "
			ET003 += " ZBF_YSI, "
			ET003 += " ZBF_YDELTA, "
			ET003 += " D_E_L_E_T_, "
			ET003 += " R_E_C_N_O_, "
			ET003 += " R_E_C_D_E_L_, "
			ET003 += " ZBF_DRVDB, "
			ET003 += " ZBF_DRVCR, "
			ET003 += " ZBF_YAPLIC, "
			ET003 += " ZBF_ORGLAN, "
			ET003 += " ZBF_SEQUEN, "
			ET003 += " ZBF_GMCD) "
			ET003 += "       SELECT ZBZ_FILIAL, "
			ET003 += "              ZBZ_DATA, "
			ET003 += "              '007777' ZBZ_LOTE, "
			ET003 += "              '001' ZBZ_SBLOTE, "
			ET003 += "              ZBZ_DOC, "
			ET003 += "              ZBZ_LINHA, "
			ET003 += "              ZBZ_DC, "
			ET003 += "              ZBZ_DEBITO, "
			ET003 += "              ZBZ_CREDIT, "
			ET003 += "              ZBZ_CLVLDB, "
			ET003 += "              ZBZ_CLVLCR, "
			ET003 += "              ZBZ_ITEMD, "
			ET003 += "              ZBZ_ITEMC, "
			ET003 += "              SUM(ZBZ_VALOR) VALOR, "
			ET003 += "              ZBZ_HIST, "
			ET003 += "              ZBZ_YHIST, "
			ET003 += "              ZBZ_SI, "
			ET003 += "              '" + dtos(dDataBase) + "' ZBZ_YDELTA, "
			ET003 += "              D_E_L_E_T_, "
			ET003 += "              (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM " + RetSqlName("ZBF") + ") + ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) AS R_E_C_N_O_, "
			ET003 += "              R_E_C_D_E_L_, "
			ET003 += "              ZBZ_DRVDB, "
			ET003 += "              ZBZ_DRVCR, "
			ET003 += "              ZBZ_APLIC APLIC, "
			ET003 += "              '' ORGLAN, "
			ET003 += "              '" + miSeqDes + "' SEQUEN, "
			ET003 += "              'S' GMCD "
			ET003 += "       FROM " + RetSqlName("ZBZ") + " "
			ET003 += "       WHERE ZBZ_VERSAO = '" + idVersao + "' "
			ET003 += "             AND ZBZ_REVISA = '" + idRevisa + "' "
			ET003 += "             AND ZBZ_ANOREF = '" + idAnoRef + "' "
			ET003 += "             AND ( ( ZBZ_DATA BETWEEN '" + miAno + StrZero(Val(miMesAt) + 1, 2) + "01' AND '" + miAno + "1231' "
			ET003 += "             AND ZBZ_DEBITO NOT IN('61112001','61111001') "
			ET003 += "             AND ZBZ_CREDIT NOT IN('61112001','61111001') "
			ET003 += "             AND ( ( SUBSTRING(ZBZ_DEBITO,1,1) IN('3','6') OR ZBZ_DEBITO = '41301001' ) "
			ET003 += "              OR ( SUBSTRING(ZBZ_CREDIT,1,1) IN('3','6') OR ZBZ_CREDIT = '41301001' ) ) ) "
			// Tratamento específico para a revião orçamentária realizada em junho de 2020
			ET003 += "              OR (SUBSTRING(ZBZ_DATA, 1, 6) IN('202001', '202002', '202003') AND ((SUBSTRING(ZBZ_DEBITO, 1, 5) IN('31401', '31403')) OR (SUBSTRING(ZBZ_CREDIT, 1, 5) IN('31401', '31403'))))) "
			// Fim do tratamento
			ET003 += "             AND D_E_L_E_T_ = ' ' "
			ET003 += "       GROUP BY ZBZ_FILIAL, "
			ET003 += "                ZBZ_DATA, "
			ET003 += "                ZBZ_LOTE, "
			ET003 += "                ZBZ_SBLOTE, "
			ET003 += "                ZBZ_DOC, "
			ET003 += "                ZBZ_LINHA, "
			ET003 += "                ZBZ_DC, "
			ET003 += "                ZBZ_DEBITO, "
			ET003 += "                ZBZ_CREDIT, "
			ET003 += "                ZBZ_CLVLDB, "
			ET003 += "                ZBZ_CLVLCR, "
			ET003 += "                ZBZ_ITEMD, "
			ET003 += "                ZBZ_ITEMC, "
			ET003 += "                ZBZ_HIST, "
			ET003 += "                ZBZ_YHIST, "
			ET003 += "                ZBZ_SI, "
			ET003 += "                ZBZ_YDELTA, "
			ET003 += "                D_E_L_E_T_, "
			ET003 += "                R_E_C_N_O_, "
			ET003 += "                R_E_C_D_E_L_, "
			ET003 += "                ZBZ_DRVDB, "
			ET003 += "                ZBZ_DRVCR, "
			ET003 += "                ZBZ_APLIC "
			U_BIAMsgRun("Aguarde... Convertendo ORCAFINAL (revisado) em Meta... ",,{|| msStaExcQy := TcSQLExec(ET003) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

		EndIf

		If lOk

			KS008 := " UPDATE ZBF SET ZBF_GMCD = 'N' "
			KS008 += "   FROM " + RetSqlName("ZBF") + " ZBF "
			KS008 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + miAno + "0101' AND '" + miAno + "1231' "
			KS008 += "    AND ZBF.ZBF_SEQUEN = '" + miSeqOrg + "' "
			KS008 += "    AND ZBF.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Convertendo Meta em ForeCast Meta... ",,{|| msStaExcQy := TcSQLExec(KS008) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

		EndIf

		If !lOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 	

	If lOk

		MsgINFO("Processamento realizado. Sequência " + miSeqDes + " habilitada com sucesso.", "")

	Else

		DisarmTransaction()
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return

// Correção da Driver Padrão: exceto OBZ
User Function BIA362D()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Correção do Driver Padrão a partir do Cadastro de Drivers."))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA362B() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Correção dos Drivers Padrões'), aSays, aButtons ,,,500)

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
			AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
			AND ZB5.ZB5_STATUS = 'F'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql
		(M001)->(dbGoTop())
		If (M001)->CONTAD <> 1
			MsgALERT("A versão CONTABIL informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("ZBF") + " ZBF "
		M0007 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + idAnoRef + "0101' AND '" + idAnoRef + "1231' "
		M0007 += "    AND SUBSTRING(ZBF.ZBF_ORGLAN, 1, 8) <> 'AJUSTADO' "
		M0007 += "    AND ZBF.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para Meta para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		EndIf

		M007->(dbCloseArea())
		Ferase(MSIndex+GetDBExtension())
		Ferase(MSIndex+OrdBagExt())

		If xkContinua

			Processa({ || cMsg := fProcDrvPd() },"Aguarde...","Carregando Arquivo...",.F.)

			MsgINFO(" Fim do processamento...")

		EndIf

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Processamento                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fProcDrvPd()

	KS001 := " DELETE ZBF "
	KS001 += "   FROM " + RetSqlName("ZBF") + " ZBF "
	KS001 += "  WHERE ZBF.ZBF_DATA BETWEEN '" + idAnoRef + "0101' AND '" + idAnoRef + "1231' "
	KS001 += "    AND ZBF.ZBF_ORGLAN NOT LIKE '%AJUSTADO%' "
	KS001 += "    AND ZBF.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros ZBF... ",,{|| TcSQLExec(KS001) })

	UF007 := " UPDATE ZBZ SET "
	UF007 += "        ZBZ_DRVDB = ZBE_DRIVER "
	UF007 += " FROM " + RetSqlName("ZBZ") + " ZBZ "
	UF007 += "      LEFT JOIN " + RetSqlName("ZBE") + " ZBE(NOLOCK) ON ZBE.ZBE_VERSAO = ZBZ.ZBZ_VERSAO "
	UF007 += "                                      AND ZBE.ZBE_REVISA = ZBZ.ZBZ_REVISA "
	UF007 += "                                      AND ZBE.ZBE_ANOREF = ZBZ.ZBZ_ANOREF "
	UF007 += "                                      AND ZBE.ZBE_APLDEF = ZBZ.ZBZ_ORIPRC "
	UF007 += "                                      AND ZBE.D_E_L_E_T_ = ' ' "
	UF007 += " WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
	UF007 += "       AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
	UF007 += "       AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
	UF007 += "       AND ZBZ.ZBZ_DEBITO <> '' "
	UF007 += "       AND ZBZ.ZBZ_ORIPRC <> 'OBZ' "
	UF007 += "       AND ZBZ.ZBZ_DRVDB <> ZBE.ZBE_DRIVER "
	UF007 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Carregando Drivers Debito Padrões... ",,{|| TcSQLExec(UF007) })

	UF007 := " UPDATE ZBZ SET "
	UF007 += "        ZBZ_DRVCR = ZBE_DRIVER "
	UF007 += " FROM " + RetSqlName("ZBZ") + " ZBZ "
	UF007 += "      LEFT JOIN " + RetSqlName("ZBE") + " ZBE(NOLOCK) ON ZBE.ZBE_VERSAO = ZBZ.ZBZ_VERSAO "
	UF007 += "                                      AND ZBE.ZBE_REVISA = ZBZ.ZBZ_REVISA "
	UF007 += "                                      AND ZBE.ZBE_ANOREF = ZBZ.ZBZ_ANOREF "
	UF007 += "                                      AND ZBE.ZBE_APLDEF = ZBZ.ZBZ_ORIPRC "
	UF007 += "                                      AND ZBE.D_E_L_E_T_ = ' ' "
	UF007 += " WHERE ZBZ.ZBZ_VERSAO = '" + idVersao + "' "
	UF007 += "       AND ZBZ.ZBZ_REVISA = '" + idRevisa + "' "
	UF007 += "       AND ZBZ.ZBZ_ANOREF = '" + idAnoRef + "' "
	UF007 += "       AND ZBZ.ZBZ_CREDIT <> '' "
	UF007 += "       AND ZBZ.ZBZ_ORIPRC <> 'OBZ' "
	UF007 += "       AND ZBZ.ZBZ_DRVCR <> ZBE.ZBE_DRIVER "
	UF007 += "       AND ZBZ.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Carregando Drivers Crédito Padrões... ",,{|| TcSQLExec(UF007) })

Return
