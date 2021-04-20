#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA678
@author Marcos Alberto Soprani
@since 09/04/21
@version 1.0
@description Tela de Manutenção para Gestão Matricial de Tributos
@Obs Projeto A-59
@type function
/*/

User Function BIA678()

	Local aArea := ZN6->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Gestão Matricial de Tributos"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
	{               "Incluir"         ,"AxInclui"	                        ,0,3},;
	{               "Alterar"         ,"AxAltera"	                        ,0,4},;
	{               "Excluir"         ,"AxDeleta"	                        ,0,5},;
	{               "Processar"       ,"U_BIA678EX()"	                    ,0,3} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN6")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "ZN6_TIPO1 = 'M'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return

User Function BIA678EX()

	Private dDataIni
	Private dDataFin
	Private xVersao
	Private xRevisa
	Private xAnoRef
	Private xCodPla
	Private xRubVis
	Private msCanPrc  := .F.

	MsgINFO("Rotina de teste. Foi substituida pela BIA679", "Atenção")
	Return

	// Orindo da planilha
	dDataIni := ctod("01/01/21")
	dDataFin := ctod("31/01/21")
	xVersao  := "ORCA_21"
	xRevisa  := "003"
	xAnoRef  := "2021"
	xCodPla  := "400"

	xVerRet := .F.
	Processa({ || ExistThenD() }, "Aguarde...", "Deletando dados...", .F.)
	If xVerRet

		Processa({ || Prc678EX() }, "Aguarde...", "Processando dados...", .F.)
		lRet := xVerRet

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!", "ATENÇÃO - BIA678")

		Else

			MsgINFO("Fim do processamento!", "ATENÇÃO - BIA678")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA678")

	EndIf

Return

Static Function Prc678EX()

	Local YQRYRE
	Local YQRYOR
	Local YQRYAJ

	ProcRegua(0)

	// Oriundo de LOOP da tabela CVF
	GT007 := Alltrim(" WITH VISAOHIERARQUICA                                                                                              ") + msEnter
	GT007 += Alltrim("      AS (SELECT CODIGO = CVE_CODIGO,                                                                               ") + msEnter
	GT007 += Alltrim("                 DESCRI = CVE_DESCRI,                                                                               ") + msEnter
	GT007 += Alltrim("                 YTPVSG = CVE_YTPVSG,                                                                               ") + msEnter
	GT007 += Alltrim("                 CLASSE = CVF_CLASSE,                                                                               ") + msEnter
	GT007 += Alltrim("                 ORDEM = CVF_ORDEM,                                                                                 ") + msEnter
	GT007 += Alltrim("                 CTASUP = CVF_CTASUP,                                                                               ") + msEnter
	GT007 += Alltrim("                 CONTAG = CVF_CONTAG,                                                                               ") + msEnter
	GT007 += Alltrim("                 DESCCG = CVF_DESCCG,                                                                               ") + msEnter
	GT007 += Alltrim("                 YRFDRE = CVF_YRFDRE,                                                                               ") + msEnter
	GT007 += Alltrim("                 REGCVF = CVF.R_E_C_N_O_                                                                            ") + msEnter
	GT007 += Alltrim("          FROM " + RetSqlName("CVE") + " CVE(NOLOCK)                                                                ") + msEnter
	GT007 += Alltrim("               INNER JOIN " + RetSqlName("CVF") + " CVF(NOLOCK) ON CVF_FILIAL = '" + xFilial("CVF") + "'            ") + msEnter
	GT007 += Alltrim("                                                AND CVF_CODIGO = CVE_CODIGO                                         ") + msEnter
	GT007 += Alltrim("                                                AND CVF.D_E_L_E_T_ = ' '                                            ") + msEnter
	GT007 += Alltrim("          WHERE CVE_FILIAL = '" + xFilial("CVE") + "'                                                               ") + msEnter
	GT007 += Alltrim("                AND CVE.CVE_CODIGO = '" + xCodPla + "'                                                              ") + msEnter
	GT007 += Alltrim("                AND CVE.D_E_L_E_T_ = ' ')                                                                           ") + msEnter
	GT007 += Alltrim("      SELECT *                                                                                                      ") + msEnter
	GT007 += Alltrim("      FROM VISAOHIERARQUICA                                                                                         ") + msEnter
	GT007 += Alltrim("      WHERE CLASSE = '2'                                                                                            ") + msEnter
	GT007 += Alltrim("      ORDER BY CODIGO,                                                                                              ") + msEnter
	GT007 += Alltrim("               ORDEM,                                                                                               ") + msEnter
	GT007 += Alltrim("               CONTAG                                                                                               ") + msEnter	
	GTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GT007),'GT07',.T.,.T.)
	dbSelectArea("GT07")
	dbGoTop()
	ProcRegua(0)
	While !GT07->(Eof())

		IncProc("Processando Registros encontrados na base...")

		CVF->(dbGoTo(GT07->REGCVF))

		xRubVis  := CVF->CVF_CONTAG

		// Query REALIZADO
		YQRYRE = CVF->CVF_YQRYRE
		If !Empty(YQRYRE)

			While .T.
				nPosRE = AT("@ALIAS#", YQRYRE)
				msTamVar := Len("@ALIAS#")
				If nPosRE > 0
					msAlias := Substr(YQRYRE, nPosRE + msTamVar, 3) 
					YQRYRE = Replace(YQRYRE, Substr(YQRYRE, nPosRE, 3 + msTamVar) , RetSqlName(msAlias))
				Else
					Exit
				EndIf
			End
			While .T.
				nPosRE = AT("@XFILIAL#", YQRYRE)
				msTamVar := Len("@XFILIAL#")
				If nPosRE > 0
					msAlias := Substr(YQRYRE, nPosRE + msTamVar, 3) 
					YQRYRE = Replace(YQRYRE, Substr(YQRYRE, nPosRE, 3 + msTamVar) , xFilial(msAlias))
				Else
					Exit
				EndIf
			End
			YQRYRE = Replace(YQRYRE, "@DATAINI", dtos(dDataIni))
			YQRYRE = Replace(YQRYRE, "@DATAFIM", dtos(dDataFin))
			YQRYRE = Replace(YQRYRE, "@VERSAO", xVersao)
			YQRYRE = Replace(YQRYRE, "@REVISA", xRevisa)
			YQRYRE = Replace(YQRYRE, "@ANOREF", xAnoRef)
			YQRYRE = Replace(YQRYRE, "@CODPLA", xCodPla)
			YQRYRE = Replace(YQRYRE, "@RUBVIS", xRubVis)
			REIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,YQRYRE),'QRYRE',.T.,.T.)
			dbSelectArea("QRYRE")
			dbGoTop()

			Reclock("ZN6",.T.)
			ZN6->ZN6_FILIAL := xFilial("ZN6")
			ZN6->ZN6_DATREF := dDataFin
			ZN6->ZN6_VERCON := "A01"
			ZN6->ZN6_CODPLA := xCodPla
			ZN6->ZN6_RUBVIS := xRubVis
			ZN6->ZN6_TIPO1  := "A"
			ZN6->ZN6_VALOR  := QRYRE->VALOR
			ZN6->(MsUnLock())		

			QRYRE->(dbCloseArea())
			Ferase(REIndex+GetDBExtension())
			Ferase(REIndex+OrdBagExt())

		EndIf

		// Query ORÇADO
		YQRYOR = CVF->CVF_YQRYOR
		If !Empty(YQRYOR)

			While .T.
				nPosRE = AT("@ALIAS#", YQRYOR)
				msTamVar := Len("@ALIAS#")
				If nPosRE > 0
					msAlias := Substr(YQRYOR, nPosRE + msTamVar, 3) 
					YQRYOR = Replace(YQRYOR, Substr(YQRYOR, nPosRE, 3 + msTamVar) , RetSqlName(msAlias))
				Else
					Exit
				EndIf
			End
			While .T.
				nPosRE = AT("@XFILIAL#", YQRYOR)
				msTamVar := Len("@XFILIAL#")
				If nPosRE > 0
					msAlias := Substr(YQRYOR, nPosRE + msTamVar, 3) 
					YQRYOR = Replace(YQRYOR, Substr(YQRYOR, nPosRE, 3 + msTamVar) , xFilial(msAlias))
				Else
					Exit
				EndIf
			End
			YQRYOR = Replace(YQRYOR, "@DATAINI", dtos(dDataIni))
			YQRYOR = Replace(YQRYOR, "@DATAFIM", dtos(dDataFin))
			YQRYOR = Replace(YQRYOR, "@VERSAO", xVersao)
			YQRYOR = Replace(YQRYOR, "@REVISA", xRevisa)
			YQRYOR = Replace(YQRYOR, "@ANOREF", xAnoRef)	
			YQRYOR = Replace(YQRYOR, "@CODPLA", xCodPla)
			YQRYOR = Replace(YQRYOR, "@RUBVIS", xRubVis)
			ORIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,YQRYOR),'QRYOR',.T.,.T.)
			dbSelectArea("QRYOR")
			dbGoTop()

			Reclock("ZN6",.T.)
			ZN6->ZN6_FILIAL := xFilial("ZN6")
			ZN6->ZN6_DATREF := dDataFin
			ZN6->ZN6_VERCON := "B01"
			ZN6->ZN6_CODPLA := xCodPla
			ZN6->ZN6_RUBVIS := xRubVis
			ZN6->ZN6_TIPO1  := "A"
			ZN6->ZN6_VALOR  := QRYOR->VALOR
			ZN6->(MsUnLock())		

			QRYOR->(dbCloseArea())
			Ferase(ORIndex+GetDBExtension())
			Ferase(ORIndex+OrdBagExt())

		EndIf

		// Query AJUSTADO
		YQRYAJ = CVF->CVF_YQRYAJ
		If !Empty(YQRYAJ)
			While .T.
				nPosRE = AT("@ALIAS#", YQRYAJ)
				msTamVar := Len("@ALIAS#")
				If nPosRE > 0
					msAlias := Substr(YQRYAJ, nPosRE + msTamVar, 3) 
					YQRYAJ = Replace(YQRYAJ, Substr(YQRYAJ, nPosRE, 3 + msTamVar) , RetSqlName(msAlias))
				Else
					Exit
				EndIf
			End
			While .T.
				nPosRE = AT("@XFILIAL#", YQRYAJ)
				msTamVar := Len("@XFILIAL#")
				If nPosRE > 0
					msAlias := Substr(YQRYAJ, nPosRE + msTamVar, 3) 
					YQRYAJ = Replace(YQRYAJ, Substr(YQRYAJ, nPosRE, 3 + msTamVar) , xFilial(msAlias))
				Else
					Exit
				EndIf
			End
			YQRYAJ = Replace(YQRYAJ, "@DATAINI", dtos(dDataIni))
			YQRYAJ = Replace(YQRYAJ, "@DATAFIM", dtos(dDataFin))
			YQRYAJ = Replace(YQRYAJ, "@VERSAO", xVersao)
			YQRYAJ = Replace(YQRYAJ, "@REVISA", xRevisa)
			YQRYAJ = Replace(YQRYAJ, "@ANOREF", xAnoRef)
			YQRYAJ = Replace(YQRYAJ, "@CODPLA", xCodPla)
			YQRYAJ = Replace(YQRYAJ, "@RUBVIS", xRubVis)
			AJIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,YQRYAJ),'QRYAJ',.T.,.T.)
			dbSelectArea("QRYAJ")
			dbGoTop()

			Reclock("ZN6",.T.)
			ZN6->ZN6_FILIAL := xFilial("ZN6")
			ZN6->ZN6_DATREF := dDataFin
			ZN6->ZN6_VERCON := "F01"
			ZN6->ZN6_CODPLA := xCodPla
			ZN6->ZN6_RUBVIS := xRubVis
			ZN6->ZN6_TIPO1  := "A"
			ZN6->ZN6_VALOR  := QRYAJ->VALOR
			ZN6->(MsUnLock())		

			QRYAJ->(dbCloseArea())
			Ferase(AJIndex+GetDBExtension())
			Ferase(AJIndex+OrdBagExt())

		EndIf

		GT07->(dbSkip())

	End

	GT07->(dbCloseArea())
	Ferase(GTIndex+GetDBExtension())
	Ferase(GTIndex+OrdBagExt())

Return

Static Function ExistThenD(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSqlName("ZN6") + " ZN6 (NOLOCK) "
	cSql += " WHERE ZN6_FILIAL = '" + xFilial("ZN6") + "' "
	cSql += "       AND ZN6_DATREF = '" + dtos(dDataFin) + "' "
	cSql += "       AND ZN6.D_E_L_E_T_    = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o período selecionado. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZN6->(DbGoTo((cQry)->RECNO))
		If !ZN6->(EOF())

			Reclock("ZN6", .F.)
			ZN6->(DBDelete())
			ZN6->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
