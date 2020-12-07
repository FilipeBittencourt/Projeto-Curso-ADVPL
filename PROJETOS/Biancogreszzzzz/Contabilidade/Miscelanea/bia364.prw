#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA364
@author Marcos Alberto Soprani
@since 08/01/18
@version 1.0
@description Rotina para transporte dos dados de modelo CONTÁBIL para base de dados GMCD 1.0
@type function
/*/

User Function BIA364()

	Local M001          := GetNextAlias()
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para transporte dos dados de modelo de CONTABIL para base de dados GMCD!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA364A() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração CONTABIL com GMCD'), aSays, aButtons ,,,500)

	If lConfirm

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual CONTAIBL" + msrhEnter
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
			(M001)->(dbCloseArea())
			Return .F.
		EndIf	
		(M001)->(dbCloseArea())

		M0007 := " SELECT COUNT(*) CONTAD "
		M0007 += "   FROM " + RetSqlName("CV1") + " CV1 "
		M0007 += "  WHERE CV1.CV1_FILIAL = '" + xFilial("CV1") + "' "
		M0007 += "    AND CV1.CV1_DTINI >= '" + idAnoRef + "0101' "
		M0007 += "    AND CV1.CV1_DTFIM <= '" + idAnoRef + "1231' "
		M0007 += "    AND CV1.D_E_L_E_T_ = ' ' "
		MSIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
		dbSelectArea("M007")
		M007->(dbGoTop())

		If M007->CONTAD <> 0

			xkContinua := MsgNOYES("Já existe base de dados para GMCD 1.0 para o ano informado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

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
Static Function BIA364A()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA364A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Integração CONTABIL p/ GMCD",,,,,,,,cLoad,.T.,.T.)      
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

	Local trrhEnter := CHR(13) + CHR(10)

	KS001 := " DELETE " + RetSqlName("CV1") + " "
	KS001 += "   FROM " + RetSqlName("CV1") + " CV1 "
	KS001 += "  WHERE CV1.CV1_FILIAL = '" + xFilial("CV1") + "' "
	KS001 += "    AND CV1.CV1_DTINI >= '" + idAnoRef + "0101' "
	KS001 += "    AND CV1.CV1_DTFIM <= '" + idAnoRef + "1231' "
	KS001 += "    AND CV1.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros CV1... ",,{|| TcSQLExec(KS001) })

	RS002 := " WITH ORCATOGMCD AS (SELECT 'ORCA'+SUBSTRING(ZBZ_ANOREF,3,2) VERSAO, "
	RS002 += "                            'ORCAMENTO: ' + RTRIM(ZBZ_VERSAO) + ', REV: ' + ZBZ_REVISA + ', ANOREF: ' + ZBZ_ANOREF DESCRIC, "
	RS002 += "                            '" + Substr(idAnoRef,2,3) + "' CALEND, "
	RS002 += "                            ZBZ_REVISA REVISA, "
	RS002 += "                            ZBZ_DEBITO CT1INI, "
	RS002 += "                            ZBZ_DEBITO CT1FIN, "
	RS002 += "                            ZBZ_CLVLDB CTHINI, "
	RS002 += "                            ZBZ_CLVLDB CTHFIM, "
	RS002 += "                            SUBSTRING(ZBZ_DATA,5,2) PERIODO, "
	RS002 += "                            SUM(ZBZ_VALOR) VALOR "
	RS002 += "                       FROM " + RetSqlName("ZBZ") + " ZBZ "
	RS002 += "                      WHERE ZBZ_VERSAO = '" + idVersao + "' "
	RS002 += "                        AND ZBZ_REVISA = '" + idRevisa + "' "
	RS002 += "                        AND ZBZ_ANOREF = '" + idAnoRef + "' "
	RS002 += "                        AND ZBZ_DEBITO <> '' "
	RS002 += "                        AND D_E_L_E_T_ = ' ' "
	RS002 += "                      GROUP BY ZBZ_VERSAO, "
	RS002 += "                               ZBZ_REVISA, "
	RS002 += "                               ZBZ_ANOREF, "
	RS002 += "                               ZBZ_DEBITO, "
	RS002 += "                               ZBZ_CLVLDB, "
	RS002 += "                               SUBSTRING(ZBZ_DATA,5,2), "
	RS002 += "                               SUBSTRING(ZBZ_DATA,1,6) "
	RS002 += "                      UNION ALL "
	RS002 += "                     SELECT 'ORCA'+SUBSTRING(ZBZ_ANOREF,3,2) VERSAO, "
	RS002 += "                            'ORCAMENTO: ' + RTRIM(ZBZ_VERSAO) + ', REV: ' + ZBZ_REVISA + ', ANOREF: ' + ZBZ_ANOREF DESCRIC, "
	RS002 += "                            '" + Substr(idAnoRef,2,3) + "' CALEND, "
	RS002 += "                            ZBZ_REVISA REVISA, "
	RS002 += "                            ZBZ_CREDIT CT1INI, "
	RS002 += "                            ZBZ_CREDIT CT1FIN, "
	RS002 += "                            ZBZ_CLVLCR CTHINI, "
	RS002 += "                            ZBZ_CLVLCR CTHFIM, "
	RS002 += "                            SUBSTRING(ZBZ_DATA,5,2) PERIODO, "
	RS002 += "                            SUM(ZBZ_VALOR) * (-1) VALOR "
	RS002 += "                       FROM " + RetSqlName("ZBZ") + " ZBZ "
	RS002 += "                      WHERE ZBZ_VERSAO = '" + idVersao + "' "
	RS002 += "                        AND ZBZ_REVISA = '" + idRevisa + "' "
	RS002 += "                        AND ZBZ_ANOREF = '" + idAnoRef + "' "
	RS002 += "                        AND ZBZ_CREDIT <> '' "
	RS002 += "                        AND D_E_L_E_T_ = ' ' "
	RS002 += "                      GROUP BY ZBZ_VERSAO, "
	RS002 += "                               ZBZ_REVISA, "
	RS002 += "                               ZBZ_ANOREF, "
	RS002 += "                               ZBZ_CREDIT, "
	RS002 += "                               ZBZ_CLVLCR, "
	RS002 += "                               SUBSTRING(ZBZ_DATA,5,2)) "
	RS002 += " SELECT VERSAO,
	RS002 += "        DESCRIC,
	RS002 += "        CALEND,
	RS002 += "        REVISA,
	RS002 += "        CT1INI,
	RS002 += "        CT1FIN,
	RS002 += "        CTHINI,
	RS002 += "        CTHFIM,
	RS002 += "        PERIODO,
	RS002 += "        SUM(VALOR) VALOR
	RS002 += "   FROM ORCATOGMCD
	RS002 += "  GROUP BY VERSAO,
	RS002 += "           DESCRIC,
	RS002 += "           CALEND,
	RS002 += "           REVISA,
	RS002 += "           CT1INI,
	RS002 += "           CT1FIN,
	RS002 += "           CTHINI,
	RS002 += "           CTHFIM,
	RS002 += "           PERIODO
	RS002 += "  ORDER BY VERSAO, "
	RS002 += "           CT1INI, "
	RS002 += "           CTHINI, "
	RS002 += "           PERIODO "
	RSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RS002),'RS02',.T.,.T.)
	dbSelectArea("RS02")
	RS02->(dbGoTop())
	ProcRegua(LASTREC())
	If RS02->(!Eof())

		While !Eof()

			cfChave := RS02->VERSAO + RS02->CT1INI + RS02->CTHINI

			MS001 := " SELECT MAX(CV1_SEQUEN) MAXDOC "
			MS001 += "   FROM " + RetSqlName("CV1") + " CV1 "
			MS001 += "  WHERE CV1.CV1_FILIAL = '" + xFilial("CV1") + "' "
			MS001 += "    AND CV1.CV1_DTINI >= '" + idAnoRef + "0101' "
			MS001 += "    AND CV1.CV1_DTFIM <= '" + idAnoRef + "1231' "
			MS001 += "    AND CV1.D_E_L_E_T_ = ' ' "
			MSIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS001),'MS01',.T.,.T.)
			dbSelectArea("MS01")
			dbGoTop()
			cfSeq   := Soma1(MS01->MAXDOC)
			cfSeqDc := 0 
			MS01->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			dbSelectArea("RS02")
			While !Eof() .and. RS02->VERSAO + RS02->CT1INI + RS02->CTHINI == cfChave 

				IncProc("Gravando tabela de ORCA ..." + RS02->VERSAO + " " + RS02->CT1INI + " " + RS02->CTHINI)

				cfSeqDc ++

				If RS02->VALOR <> 0

					RecLock("CV1",.T.)
					CV1->CV1_FILIAL  := xFilial("CV1")  
					CV1->CV1_ORCMTO  := RS02->VERSAO
					CV1->CV1_DESCRI  := RS02->DESCRIC
					CV1->CV1_STATUS  := "1"
					CV1->CV1_CALEND  := RS02->CALEND
					CV1->CV1_MOEDA   := "01"
					CV1->CV1_REVISA  := RS02->REVISA
					CV1->CV1_SEQUEN  := cfSeq
					CV1->CV1_CT1INI  := RS02->CT1INI
					CV1->CV1_CT1FIM  := RS02->CT1FIN
					CV1->CV1_CTHINI  := RS02->CTHINI
					CV1->CV1_CTHFIM  := RS02->CTHFIM
					CV1->CV1_PERIOD  := RS02->PERIODO
					CV1->CV1_DTINI   := stod(idAnoRef + RS02->PERIODO + "01")
					CV1->CV1_DTFIM   := UltimoDia(stod(idAnoRef + RS02->PERIODO + "01"))
					CV1->CV1_VALOR   := RS02->VALOR
					CV1->CV1_APROVA  := cUserName
					MsUnLock()

				EndIf

				dbSelectArea("RS02")
				dbSkip()

			End

			dbSelectArea("RS02")

		End

	EndIf

	RS02->(dbCloseArea())
	Ferase(RSIndex+GetDBExtension())
	Ferase(RSIndex+OrdBagExt())

	xkFechamen := MsgNOYES("Deseja fechar definitivamente a Versão Orçamentária?" + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar o FECHAMENTO DEFINITIVO da versão impossibilitando este processamento até que a contabilidade libere a versão." + msrhEnter + msrhEnter+ "Confirma o fechamento da versão? Caso não haja nenhuma empresa a ser processada, pode confirmar.")

	If xkFechamen

		ZP001 := " UPDATE " + RetSqlName("ZB5") + " SET ZB5_STATUS = 'F' "
		ZP001 += "   FROM " + RetSqlName("ZB5") + " ZB5 "
		ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
		ZP001 += "    AND ZB5.ZB5_VERSAO = '" + idVersao + "' "
		ZP001 += "    AND ZB5.ZB5_REVISA = '" + idRevisa + "' "
		ZP001 += "    AND ZB5.ZB5_ANOREF = '" + idAnoRef + "' "
		ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL' "
		ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Fechando Versão Orçamentária ... ",,{|| TcSQLExec(ZP001) })

	EndIf

	MsgINFO("Conversão do modelo CONTABIL em base para GMCD realizada com sucesso!!!")

Return
