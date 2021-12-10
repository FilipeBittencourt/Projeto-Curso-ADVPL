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
@description Browser principal para a rotina de Processamento CAPEX e Ativo Fixo para Depreciação
@type function
/*/

User Function BIA590()

	Local aArea     := GetArea()

	Private cCadastro 	:= "CAPEX(Aquisições) e Ativo Fixo para Depreciação"

	Private aRotina 	:= { {"Pesquisar"                   ,"AxPesqui"     ,0,1},;
	{                         "Visualizar"	                ,"AxVisual"     ,0,2},;
	{                         "Ativo Fixo p/ Depreciação"   ,"U_B590SN3O"   ,0,3},;
	{                         "CAPEX(Aquisições) p/ Deprec" ,"U_B590ZBVO"   ,0,3} }

	dbSelectArea("ZBY")
	dbSetOrder(1)

	If cEmpAnt <> "01"

		MsgSTOP("Esta rotina somente poderá ser acessada pela empresa Biancogres. Isto porque tanto a leitura do formuário CAPEX quanto a explosão da tabela SN3 são feitas de uma única vez para as empresas 01 / 05 / 06 / 07 / 12 / 13 / 14 / 16 / 17!!!")

	Else

		mBrowse(6,1,22,75,"ZBY",,,,,,)

	EndIf

	restArea(aArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590SN3O ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclui registros Ativo Fixo p/ Depreciação                 ¦¦¦
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
	Private msrhEnter   := CHR(13) + CHR(10)	
	Private n3Continua  := .T.

	AADD(aSays, OemToAnsi("Rotina para extração dos valores do Ativo Fixo até o momento da sua execução."))   
	AADD(aSays, OemToAnsi("Serão apanhados os valores da tabela SN3 conforme momento presente da execu-"))   
	AADD(aSays, OemToAnsi("ção da rotina. Não é necessário informar uma data de corte, porque não seria"))   
	AADD(aSays, OemToAnsi("possível separar os valores antes e depois a partir da tabela SN3 por sua ca-"))   
	AADD(aSays, OemToAnsi("racterística aTemporal"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergSN3Or() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração Ativo Fixo p/ Depreciação'), aSays, aButtons ,,,500)

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

			n3Continua := MsgNOYES("Já existe Ativo Fixo p/ Depreciação para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

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

	If ParamBox(aPergs ,"Integração Ativo Fixo p/ Depreciação",,,,,,,,cLoad,.T.,.T.)      
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
	Local n3EmprPrc     := {"01", "05", "06", "07", "12", "13", "14", "16", "17"}
	Local msStaExcQy    := 0
	Local lOk           := .T.

	Begin Transaction

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
			U_BIAMsgRun("Aguarde... Apagando registros ZBY... ",,{|| msStaExcQy := TcSQLExec(CS001) })

			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If lOk

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
				U_BIAMsgRun("Aguarde... Convertendo Ativo Fixo em Depreciação... ",,{|| msStaExcQy := TcSQLExec(UJ005) })

				If msStaExcQy < 0
					lOk := .F.
					Exit
				EndIf			

			EndIf

			If !lOk
				Exit
			EndIf

		Next n3ny

		If !lOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction

	If lOk

		MsgINFO("Conversão Ativo Fixo p/ Depreciação realizada com sucesso!!!", "BIA590")

	Else

		DisarmTransaction()
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf	

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B590ZBVO ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclui registros CAPEX p/ Depreciação                      ¦¦¦
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

	AADD(aSays, OemToAnsi("Rotina para conversão do CAPEX(Aquisições) em valores de depreciação (despesa/"))   
	AADD(aSays, OemToAnsi("custo) conforme registros oriundo do registros das aquisições realizada pelas"))   
	AADD(aSays, OemToAnsi("áreas de negócido versus o cadastro de contas contábeis de Ativo para Depreciação"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergZBVOr() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Integração CAPEX(Aquisições) p/ Depreciação'), aSays, aButtons ,,,500)

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

			zvContinua := MsgNOYES("Já existe CAPEX(Aquisições) p/ Depreciação para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

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

	If ParamBox(aPergs ,"Integração CAPEX(Aquisições) p/ Deprec",,,,,,,,cLoad,.T.,.T.)      
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

	Local lvxt
	Local msStaExcQy    := 0
	Local lOk           := .T.
	Local ksErroEm      := ""

	ksErroEm := "As seguintes Contas de Ativo não possuem amarração cadastrada para a Conta de Depreciação:" + msrhEnter + msrhEnter

	SK007 := " WITH CAPEXINT "
	SK007 += "      AS (SELECT ZBV.ZBV_FILIAL, "
	SK007 += "                 ZBV.ZBV_VERSAO, "
	SK007 += "                 ZBV.ZBV_REVISA, "
	SK007 += "                 ZBV.ZBV_ANOREF, "
	SK007 += "                 ZBV.ZBV_CONTA, "
	SK007 += "                 CTH.CTH_YATRIB CHVCV "
	SK007 += "          FROM " + RetSqlName("ZBV") + " ZBV "
	SK007 += "               LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBV_CLVL "
	SK007 += "                                       AND CTH.D_E_L_E_T_ = ' ' "
	SK007 += "          WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
	SK007 += "                AND ZBV.ZBV_VERSAO = '" + zvVersao + "' "
	SK007 += "                AND ZBV.ZBV_REVISA = '" + zvRevisa + "' "
	SK007 += "                AND ZBV.ZBV_ANOREF = '" + zvAnoRef + "' "
	SK007 += "                AND NOT ZBV.ZBV_CENARI LIKE '%CORTE%' "
	SK007 += "                AND NOT ZBV.ZBV_CENARI LIKE '%ESFORCO OBZ%' "
	SK007 += "                AND ZBV.D_E_L_E_T_ = ' ') "
	SK007 += "      SELECT DISTINCT "
	SK007 += "             CCONTA = ZBV_CONTA "
	SK007 += "      FROM CAPEXINT CAPXI "
	SK007 += "           LEFT JOIN " + RetSqlName("ZBX") + " ZBX ON ZBX.ZBX_VERSAO = CAPXI.ZBV_VERSAO "
	SK007 += "                                   AND ZBX.ZBX_REVISA = CAPXI.ZBV_REVISA "
	SK007 += "                                   AND ZBX.ZBX_ANOREF = CAPXI.ZBV_ANOREF "
	SK007 += "                                   AND ZBX.ZBX_CTAATV = CAPXI.ZBV_CONTA "
	SK007 += "                                   AND ZBX.ZBX_CHVCV = CHVCV "
	SK007 += "                                   AND ZBX.D_E_L_E_T_ = ' ' "
	SK007 += "      WHERE ZBX_CTADPR IS NULL "
	SKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SK007),'SK07',.T.,.T.)
	dbSelectArea("SK07")
	SK07->(dbGoTop())
	ProcRegua(0)
	If SK07->(Eof())	

		Begin Transaction

			XL008 := " WITH CAPEXINT AS (SELECT ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') EMPR "
			XL008 += "                     FROM " + RetSqlName("ZBV") + " ZBV "
			XL008 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBV_CLVL "
			XL008 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
			XL008 += "                    WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
			XL008 += "                      AND ZBV.ZBV_VERSAO = '" + zvVersao + "' "
			XL008 += "                      AND ZBV.ZBV_REVISA = '" + zvRevisa + "' "
			XL008 += "                      AND ZBV.ZBV_ANOREF = '" + zvAnoRef + "' "
			XL008 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%CORTE%' "
			XL008 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%ESFORCO OBZ%' "
			XL008 += "                      AND ZBV.D_E_L_E_T_ = ' ' "
			XL008 += "                    GROUP BY SUBSTRING(CTH_YEFORC,1,2)) "
			XL008 += " SELECT * "
			XL008 += "   FROM CAPEXINT "
			XL008 += "  ORDER BY EMPR "
			XLIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,XL008),'XL08',.T.,.T.)
			dbSelectArea("XL08")
			XL08->(dbGoTop())
			ProcRegua(0)
			If XL08->(!Eof())

				While XL08->(!Eof())

					ksEmpres := XL08->EMPR
					ksErroEm := ""
					If ksEmpres <> "ER" 

						While XL08->(!Eof()) .and. XL08->EMPR == ksEmpres  

							KP001 := " DELETE ZBY" + ksEmpres + "0 "
							KP001 += "   FROM ZBY" + ksEmpres + "0 ZBY "
							KP001 += "  WHERE ZBY.ZBY_VERSAO = '" + zvVersao + "' "
							KP001 += "    AND ZBY.ZBY_REVISA = '" + zvRevisa + "' "
							KP001 += "    AND ZBY.ZBY_ANOREF = '" + zvAnoRef + "' "
							KP001 += "    AND ZBY.ZBY_TABORI = 'ZBV' "
							KP001 += "    AND ZBY.D_E_L_E_T_ = ' ' "
							U_BIAMsgRun("Aguarde... Apagando registros ZBY... ",,{|| msStaExcQy := TcSQLExec(KP001) })
							If msStaExcQy < 0
								lOk := .F.
							EndIf

							If lOk

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
									YY004 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%CORTE%' "
									YY004 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%ESFORCO OBZ%' "
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
									U_BIAMsgRun("Aguarde... Convertendo CAPEX em Depreciação... ",,{|| msStaExcQy := TcSQLExec(YY004) })

									If msStaExcQy < 0
										lOk := .F.
										Exit
									EndIf

								Next lvxt

							EndIf

							If lOk
								XL08->(dbSkip())
							Else
								Exit
							EndIf

						EndDo
						If !lOk
							Exit
						EndIf

					Else

						ksErroEm := "As Classes de Valor listadas abaixo estão com a campo empresa orçamentária informada incorretamente" + msrhEnter + msrhEnter

						GH005 := " WITH CAPEXINT AS (SELECT ZBV_CLVL CLVL, ISNULL(SUBSTRING(CTH_YEFORC,1,2), 'ER') EMPR "
						GH005 += "                     FROM " + RetSqlName("ZBV") + " ZBV "
						GH005 += "                     LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBV_CLVL "
						GH005 += "                                         AND CTH.D_E_L_E_T_ = ' ' "
						GH005 += "                    WHERE ZBV.ZBV_FILIAL = '" + xFilial("ZBV") + "' "
						GH005 += "                      AND ZBV.ZBV_VERSAO = '" + zvVersao + "' "
						GH005 += "                      AND ZBV.ZBV_REVISA = '" + zvRevisa + "' "
						GH005 += "                      AND ZBV.ZBV_ANOREF = '" + zvAnoRef + "' "
						GH005 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%CORTE%' "
						GH005 += "                      AND NOT ZBV.ZBV_CENARI LIKE '%ESFORCO OBZ%' "
						GH005 += "                      AND ZBV.D_E_L_E_T_ = ' ' "
						GH005 += "                    GROUP BY ZBV_CLVL, SUBSTRING(CTH_YEFORC,1,2)) "
						GH005 += " SELECT * "
						GH005 += " FROM CAPEXINT "
						GH005 += " WHERE EMPR = 'ER' "
						GH005 += " ORDER BY EMPR "
						GHIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,GH005),'GH05',.T.,.T.)
						dbSelectArea("GH05")
						GH05->(dbGoTop())
						ProcRegua(0)
						If GH05->(!Eof())

							While GH05->(!Eof())

								ksErroEm += "CLVL: " + XL08->CLVL + msrhEnter

								GH05->(dbSkip())

							EndDo

						EndIf
						GH05->(dbCloseArea())
						Ferase(GHIndex+GetDBExtension())
						Ferase(GHIndex+OrdBagExt())

						lOk := .F.
						Exit

					EndIf

				EndDo

			EndIf	

			XL08->(dbCloseArea())
			Ferase(XLIndex+GetDBExtension())
			Ferase(XLIndex+OrdBagExt())

			If !lOk

				msGravaErr := Iif(Empty(ksErroEm), TCSQLError(), ksErroEm)
				DisarmTransaction()

			EndIf

		End Transaction 

	Else

		While SK07->(!Eof())

			ksErroEm += "Conta de Ativo: " + SK07->CCONTA + msrhEnter

			SK07->(dbSkip())

		EndDo

		msGravaErr := ksErroEm

		lOk := .F.

	EndIf

	SK07->(dbCloseArea())
	Ferase(SKIndex+GetDBExtension())
	Ferase(SKIndex+OrdBagExt())

	If lOk

		MsgINFO("Conversão CAPEX(Aquisições) p/ Depreciação realizada com sucesso!!!", "BIA590")

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return
