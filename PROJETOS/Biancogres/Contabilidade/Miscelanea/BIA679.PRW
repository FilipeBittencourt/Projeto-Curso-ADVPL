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
	Local xpq

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
	Private msVetImp  := ""
	Private msImpArry := {}
	Private msArryEmp := {}
	Private msZeraRec := .T.

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := "Define variable value"
	Private xoSay1
	Private xoDlg

	oEmp := TLoadEmpresa():New()

	If ValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))
		xVersao  := MV_PAR02
		xRevisa  := MV_PAR03
		xAnoRef  := MV_PAR04
		xCodPla  := MV_PAR05

		//Chamada de tela para seleção do Imposto
		oEmp:GmtQuadroImp()
		msImpArry := oEmp:aEmpSel

		If Len(msImpArry) > 0

			For xpq := 1 to Len(msImpArry)
				msVetImp += "'" + msImpArry[xpq][2] + "'"
				If xpq + 1 <= Len(msImpArry)
					msVetImp += ","
				EndIf
				If msImpArry[xpq][2] == "00"
					msZeraRec := .F.
				EndIf
			Next xpq

			//Chamada de tela para seleção da Empresa/Filial
			oEmp:GSEmpFil()		
			msArryEmp := oEmp:aEmpSel

			If Len(msArryEmp) > 0

				hhTmpINI  := TIME()

				RpcSetType(3)
				RpcSetEnv( cEmpAnt, cFilAnt )
				RpcClearEnv()

				//Begin Transaction

				For nW := 1 To Len(msArryEmp)

					RpcSetType(3)
					RpcSetEnv( msArryEmp[nW][1], Substr(msArryEmp[nW][2], 1, 2) )

					smMsnPrc := msArryEmp[nW][1] + "/" + Substr(msArryEmp[nW][2], 1, 2) + " - " + Alltrim(msArryEmp[nW][4])

					oPrcVerf := MsNewProcess():New({|lEnd| VerifFechP(@oPrcVerf) }, "Verficando Fechamento...", smMsnPrc, .T.)
					oPrcVerf:Activate()

					lRet := xVerRet

					If xVerRet

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

	MV_PAR01 :=	Space(06)
	MV_PAR02 := Space(10)
	MV_PAR03 :=	Space(03)
	MV_PAR04 :=	Space(04)
	MV_PAR05 :=	Space(03)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Versão Orca"      ,MV_PAR02 ,""            ,"EXISTCPO('ZB5')",'ZB5'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Revisão Orca"     ,MV_PAR03 ,""            ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "AnoRef Orca"      ,MV_PAR04 ,""            ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})
	aAdd( aPergs ,{1, "Visão Gerencial"  ,MV_PAR05 ,""            ,"EXISTCPO('CVE')",'CVE'  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa GMT",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

Return lRet

Static Function VerifFechP(oPrcVerf)

	Local cSQL    := ""
	Local cQry    := ""
	Local lRet    := .T.
	Local xxDtRef := Substr(dtos(dDataFin),1,6) + "01"

	If fExistTabl(RetSqlName("ZNA"))

		msErroQuery := "Empresa: " + cEmpAnt + msEnter + msEnter
		msErroQuery += "Filial: " + cFilAnt + msEnter + msEnter
		msErroQuery += "Verificar fechamento: " + msEnter + msEnter

		cQry := GetNextAlias()

		cSql := " SELECT ZNA.ZNA_CODIMP, "
		cSql += "        ZNA.ZNA_DESIMP, "
		cSql += "        ZNA.ZNA_ULTGMT "
		cSql += " FROM " + RetSqlName("ZNA") + " ZNA(NOLOCK) "
		cSql += " WHERE ZNA.ZNA_FILIAL = '" + xFilial("ZNA") + "' "
		cSql += "       AND ZNA.ZNA_CODPLA = '" + xCodPla + "' "
		cSql += "       AND ZNA.ZNA_CODIMP IN(" + msVetImp + ") "
		cSql += "       AND ZNA.ZNA_ULTGMT > '" + xxDtRef + "' "
		cSql += "       AND ZNA.D_E_L_E_T_ = ' ' "
		TcQuery cSQL New Alias (cQry)

		oPrcVerf:SetRegua1(1)
		oPrcVerf:SetRegua2(1000)

		oPrcVerf:IncRegua1(smMsnPrc)
		While !(cQry)->(Eof())

			oPrcVerf:IncRegua2("Verificando Fechamento de período...")

			msErroQuery += "Imposto: " + (cQry)->ZNA_CODIMP + " - " + (cQry)->ZNA_DESIMP + " UltGMT: " + dtoc(stod((cQry)->ZNA_ULTGMT)) + msEnter

			lRet := .F.

			(cQry)->(DbSkip())

		End

		(cQry)->(DbCloseArea())

	EndIf

	xVerRet := lRet 

Return ( lRet )

Static Function ExistThenD(oPrcZera)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	If fExistTabl(RetSqlName("ZN6"))

		cQry := GetNextAlias()

		cSql := " SELECT ZN6.R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSqlName("ZN6") + " ZN6 (NOLOCK) "
		cSql += "      INNER JOIN " + RetSqlName("CVF") + " CVF(NOLOCK) ON CVF_FILIAL = '" + xFilial("CVF") + "' "
		cSql += "                                       AND CVF_CODIGO = ZN6_CODPLA "
		cSql += "                                       AND CVF_CONTAG = ZN6_RUBVIS "
		cSql += "                                       AND (SUBSTRING(CVF_YRFDRE, 4, 2) IN(" + msVetImp + ") "
		cSql += "                                            OR CVF_CTASUP = '' "
		cSql += "                                            OR LEN(RTRIM(CVF_YRFDRE)) = 5) "
		If msZeraRec
			cSql += "                                       AND NOT SUBSTRING(CVF_YRFDRE, 4, 2) IN('00') "
		EndIf
		cSql += "                                       AND CVF.D_E_L_E_T_ = ' ' "
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
	Local lRet	   := .T.

	Local xSubTrib := GetMv( "MV_SUBTRIB", , "" )

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	xDtInApu := "19800101"
	xDtFiApu := "19800101"
	xMesApIR := ""
	KF003 := Alltrim(" SELECT Z35_PERAPU PERAPU                                                                                              ") + msEnter
	KF003 += Alltrim(" FROM " + RetSqlName("Z35") + " Z35(NOLOCK)                                                                            ") + msEnter
	KF003 += Alltrim(" WHERE Z35_EMP = '" + cEmpAnt + "'                                                                                     ") + msEnter
	KF003 += Alltrim("       AND Z35_FIL = '" + cFilAnt + "'                                                                                 ") + msEnter
	KF003 += Alltrim("       AND Z35_REGIME = 'LR'                                                                                           ") + msEnter
	KF003 += Alltrim("       AND Z35.D_E_L_E_T_ = ' '                                                                                        ") + msEnter
	KFIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KF003),'KF03',.T.,.T.)
	dbSelectArea("KF03")
	dbGoTop()
	If !KF03->(Eof())

		If KF03->PERAPU == "A"
			xDtInApu := xAnoRef + "0101"
			xDtFiApu := dtos(dDataFin)
			xMesApIR := "12"

		Else

			xDtInApu := dtos(FirstDate(MonthSub(dDataFin, 2)))
			xDtFiApu := dtos(dDataFin)
			xMesApIR := "03/06/09/12"

		EndIf

	End

	KF03->(dbCloseArea())
	Ferase(KFIndex+GetDBExtension())
	Ferase(KFIndex+OrdBagExt())

	QX005 := Alltrim(" SELECT VERCON = ZOY_VERSAO,                                                                                           ") + msEnter
	QX005 += Alltrim("        CODPLA = CVF_CODIGO,                                                                                           ") + msEnter
	QX005 += Alltrim("        RUBVIS = CVF_CONTAG,                                                                                           ") + msEnter
	QX005 += Alltrim("        OPERAC = OPERACAO                                                                                              ") + msEnter
	QX005 += Alltrim(" FROM " + RetSqlName("CVF") + " CVF(NOLOCK)                                                                            ") + msEnter
	QX005 += Alltrim("      INNER JOIN " + RetSqlName("ZOY") + " ZOY(NOLOCK) ON ZOY_FILIAL = '" + xFilial("ZOY") + "'                        ") + msEnter
	QX005 += Alltrim("                                       AND ZOY_VERSAO IN('A01', 'B01', 'F01')                                          ") + msEnter
	QX005 += Alltrim("                                       AND ZOY.D_E_L_E_T_ = ' '                                                        ") + msEnter
	QX005 += Alltrim("      INNER JOIN VW_BI_D_OPERACAO OPR ON 1 = 1                                                                         ") + msEnter
	QX005 += Alltrim(" WHERE CVF_FILIAL = '" + xFilial("CVF") + "'                                                                           ") + msEnter
	QX005 += Alltrim("       AND CVF_CODIGO = '" + xCodPla + "'                                                                              ") + msEnter
	QX005 += Alltrim("       AND (CVF_CTASUP = ''                                                                                            ") + msEnter
	QX005 += Alltrim("            OR LEN(RTRIM(CVF_YRFDRE)) = 5)                                                                             ") + msEnter
	QX005 += Alltrim("       AND CVF_CLASSE = '1'                                                                                            ") + msEnter
	QX005 += Alltrim("       AND CVF.D_E_L_E_T_ = ' '                                                                                        ") + msEnter
	QX005 += Alltrim(" ORDER BY CVF_ORDEM                                                                                                    ") + msEnter
	QXIndex := CriaTrab(Nil,.f.)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QX005),'QX05',.T.,.T.)
	dbSelectArea("QX05")
	dbGoTop()

	While !QX05->(Eof())

		Reclock("ZN6",.T.)
		ZN6->ZN6_FILIAL := xFilial("ZN6")
		ZN6->ZN6_DATREF := dDataFin
		ZN6->ZN6_VERCON := QX05->VERCON
		ZN6->ZN6_CODPLA := QX05->CODPLA
		ZN6->ZN6_RUBVIS := QX05->RUBVIS
		ZN6->ZN6_TIPO1  := "A"
		ZN6->ZN6_OPERAC := QX05->OPERAC
		ZN6->ZN6_HIST   := "REGISTROS ZERO PARA FRONT-END"
		ZN6->(MsUnLock())

		QX05->(dbSkip())

	End

	QX05->(dbCloseArea())
	Ferase(QXIndex+GetDBExtension())
	Ferase(QXIndex+OrdBagExt())

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
		GT007 += Alltrim("                                                AND SUBSTRING(CVF_YRFDRE, 4, 2) IN(" + msVetImp + ")                ") + msEnter
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
				msQryPrc = Replace(msQryPrc, "@INITRIM" , dtos(FirstDate(MonthSub(dDataFin, 2))))				
				msQryPrc = Replace(msQryPrc, "@VERSAO"  , xVersao)
				msQryPrc = Replace(msQryPrc, "@REVISA"  , xRevisa)
				msQryPrc = Replace(msQryPrc, "@ANOREF"  , xAnoRef)
				msQryPrc = Replace(msQryPrc, "@CODPLA"  , xCodPla)
				msQryPrc = Replace(msQryPrc, "@RUBVIS"  , xRubVis)
				msQryPrc = Replace(msQryPrc, "@EMPANT"  , cEmpAnt)
				msQryPrc = Replace(msQryPrc, "@FILANT"  , cFilAnt)
				msQryPrc = Replace(msQryPrc, "@PERIODO" , Substr(dtos(dDataFin), 5, 2))
				msQryPrc = Replace(msQryPrc, "@YRFDRE"  , xYRFDre)
				msQryPrc = Replace(msQryPrc, "@SUBTRIB" , xSubTrib)
				msQryPrc = Replace(msQryPrc, "@DTINAPU" , xDtInApu)
				msQryPrc = Replace(msQryPrc, "@DTFIAPU" , xDtFiApu)
				msQryPrc = Replace(msQryPrc, "@MESAPIR" , xMesApIR)

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
