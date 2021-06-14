#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA679
@author Marcos Alberto Soprani
@since 11/04/21
@version 1.0
@description Rotina de processamento dos valores para Gestão Matricial de Tributos
@Obs Projeto A-59
@type function
/*/

User Function BIA679()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .T.
	Local oProcess
	Local oPrcZera

	Private cTitulo := "Processamento Gestão Matricial de Tributos"

	Private dDataIni
	Private dDataFin
	Private xVersao
	Private xRevisa
	Private xAnoRef
	Private xCodPla
	Private xRubVis
	Private msEnter   := CHR(13) + CHR(10)
	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private hhTmpINI
	Private smMsnPrc
	Private msCanPrc  := .F.
	Private xVerRet   := .T.
	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		dDataIni := MV_PAR01
		dDataFin := MV_PAR02
		xVersao  := MV_PAR03
		xRevisa  := MV_PAR04
		xAnoRef  := MV_PAR05
		xCodPla  := MV_PAR06

		oEmp:GSEmpFil()

		If Len(oEmp:aEmpSel) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			//Begin Transaction

			For nW := 1 To Len(oEmp:aEmpSel)

				RpcSetType(3)
				RpcSetEnv( oEmp:aEmpSel[nW][1], Substr(oEmp:aEmpSel[nW][2], 1, 2) )

				smMsnPrc := oEmp:aEmpSel[nW][1] + "/" + Substr(oEmp:aEmpSel[nW][2], 1, 2) + " - " + Alltrim(oEmp:aEmpSel[nW][4])
				oPrcZera := MsNewProcess():New({|lEnd| ExistThenD(@oPrcZera) }, "Deletando...", smMsnPrc, .T.)
				oPrcZera:Activate()

				lRet := xVerRet

				If xVerRet

					oProcess := MsNewProcess():New({|lEnd| Prc679EX(@oProcess) }, "Gravando...", smMsnPrc, .T.)
					oProcess:Activate()

					lRet := xVerRet

					If !xVerRet

						//DisarmTransaction()
						msCanPrc  := .F.
						Exit

					EndIf

				Else

					//DisarmTransaction()
					msCanPrc  := .F.
					Exit

				EndIf

				RpcClearEnv()

			Next nW

			//End Transaction

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	RpcSetEnv( msEmpAtu, msFilAtu )

	If Type("__cInternet") == "C"
		__cInternet := Nil
	EndIf

	If !msCanPrc

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msEnter + msEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			MsgINFO("Fim do Processamento!!!" + msEnter + msEnter + Alltrim(ElapTime(hhTmpINI, TIME())), "Atenção!!!")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIA679" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	ctod("  /  /  ")
	MV_PAR02 := ctod("  /  /  ")
	MV_PAR03 := Space(10)
	MV_PAR04 :=	Space(03)
	MV_PAR05 :=	Space(04)
	MV_PAR06 :=	Space(03)

	aAdd( aPergs ,{1, "Data Inicial"     ,MV_PAR01 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Data Final"       ,MV_PAR02 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Versão Orca"      ,MV_PAR03 ,""  ,"EXISTCPO('ZB5')",'ZB5'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Revisão Orca"     ,MV_PAR04 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "AnoRef Orca"      ,MV_PAR05 ,""  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Visão Gerencial"  ,MV_PAR06 ,""  ,"EXISTCPO('CVE')",'CVE'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

Return lRet

Static Function ExistThenD(oPrcZera)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	If fExistTabl(RetSqlName("ZN6"))

		cQry := GetNextAlias()

		cSql := " SELECT R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSqlName("ZN6") + " ZN6 (NOLOCK) "
		cSql += " WHERE ZN6_FILIAL = '" + xFilial("ZN6") + "' "
		cSql += "       AND ZN6_TIPO1 <> 'M' "
		cSql += "       AND ZN6_DATREF = '" + dtos(dDataFin) + "' "
		cSql += "       AND ZN6.D_E_L_E_T_    = ' ' "

		TcQuery cSQL New Alias (cQry)

		oPrcZera:SetRegua1(1)
		oPrcZera:SetRegua2(1000)

		oPrcZera:IncRegua1(smMsnPrc)
		While !(cQry)->(Eof())

			oPrcZera:IncRegua2("Apagando Registros encontrados na base...")

			If lPerg .AND. 1 == 2

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

	Else

		msErroQuery := "Empresa: " + cEmpAnt + msEnter + msEnter
		msErroQuery += "Filial: " + cFilAnt + msEnter + msEnter
		msErroQuery += "A tabela ZN6 não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet 

Return ( lRet )

Static Function Prc679EX(oProcess)

	Local pk
	Local msVerCon
	Local msQryPrc
	Local msCampoQ
	Local lRet	:= .T.

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	For pk := 1 to 3

		// LOOP da tabela CVF
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

			oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

			CVF->(dbGoTo(GT07->REGCVF))

			xRubVis  := CVF->CVF_CONTAG
			xYRFDre  := CVF->CVF_YRFDRE

			If pk == 1                                  // Query REALIZADO

				msVerCon := "A01"
				msQryPrc := CVF->CVF_YQRYRE
				msCampoQ := "Query Realizado"

			ElseIf pk == 2                              // Query ORCADO

				msVerCon := "B01"
				msQryPrc := CVF->CVF_YQRYOR
				msCampoQ := "Query Orçado"

			ElseIf pk == 3                              // Query AJUSTADO

				msVerCon := "F01"
				msQryPrc := CVF->CVF_YQRYAJ
				msCampoQ := "Query Ajustado"

			EndIf

			If !Empty(msQryPrc)

				While .T.
					nPosQP = AT("@ALIAS#", msQryPrc)
					msTamVar := Len("@ALIAS#")
					If nPosQP > 0
						msAlias := Substr(msQryPrc, nPosQP + msTamVar, 3) 
						msQryPrc = Replace(msQryPrc, Substr(msQryPrc, nPosQP, 3 + msTamVar) , RetSqlName(msAlias))
					Else
						Exit
					EndIf
				End
				While .T.
					nPosQP = AT("@XFILIAL#", msQryPrc)
					msTamVar := Len("@XFILIAL#")
					If nPosQP > 0
						msAlias := Substr(msQryPrc, nPosQP + msTamVar, 3) 
						msQryPrc = Replace(msQryPrc, Substr(msQryPrc, nPosQP, 3 + msTamVar) , xFilial(msAlias))
					Else
						Exit
					EndIf
				End
				msQryPrc = Replace(msQryPrc, "@DATAINI" , dtos(dDataIni))
				msQryPrc = Replace(msQryPrc, "@DATAFIM" , dtos(dDataFin))
				msQryPrc = Replace(msQryPrc, "@VERSAO"  , xVersao)
				msQryPrc = Replace(msQryPrc, "@REVISA"  , xRevisa)
				msQryPrc = Replace(msQryPrc, "@ANOREF"  , xAnoRef)
				msQryPrc = Replace(msQryPrc, "@CODPLA"  , xCodPla)
				msQryPrc = Replace(msQryPrc, "@RUBVIS"  , xRubVis)
				msQryPrc = Replace(msQryPrc, "@EMPANT"  , cEmpAnt)
				msQryPrc = Replace(msQryPrc, "@FILANT"  , cFilAnt)
				msQryPrc = Replace(msQryPrc, "@PERIODO" , Substr(dtos(dDataFin), 5, 2))
				msQryPrc = Replace(msQryPrc, "@YRFDRE"  , xYRFDre)

				QPIndex := CriaTrab(Nil,.f.)

				lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,msQryPrc),'QP001',.T.,.T.) },,.T.,,)
				If !lEvalBlock
					msErroQuery := "Rubrica: " + CVF->CVF_CONTAG + " - " + CVF->CVF_DESCCG + msEnter + msEnter
					msErroQuery += "Campo: " + msCampoQ + msEnter + msEnter
					msErroQuery += msQryPrc
					lRet := .F.
					Exit
				EndIf

				dbSelectArea("QP001")
				dbGoTop()

				While !QP001->(Eof())

					If QP001->VALOR <> 0

						Reclock("ZN6",.T.)
						ZN6->ZN6_FILIAL := xFilial("ZN6")
						ZN6->ZN6_DATREF := dDataFin
						ZN6->ZN6_VERCON := msVerCon
						ZN6->ZN6_CODPLA := xCodPla
						ZN6->ZN6_RUBVIS := xRubVis
						ZN6->ZN6_TIPO1  := "A"
						ZN6->ZN6_OPERAC := QP001->OPERAC
						ZN6->ZN6_VALOR  := QP001->VALOR
						ZN6->ZN6_DENOMI := QP001->DENOMI
						ZN6->(MsUnLock())

					EndIf

					QP001->(dbSkip())

				End

				QP001->(dbCloseArea())
				Ferase(QPIndex+GetDBExtension())
				Ferase(QPIndex+OrdBagExt())

			EndIf

			GT07->(dbSkip())

		End

		GT07->(dbCloseArea())
		Ferase(GTIndex+GetDBExtension())
		Ferase(GTIndex+OrdBagExt())

	Next pk

	xVerRet := lRet

Return( lRet )

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
