#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA782
@author Marcos Alberto Soprani
@since 03/11/21
@version 1.0
@description Rotina para Contabilizar os valores de Expurgo fechando a consolidação contábil do Grupo
@type function
/*/

User Function BIA782()

	Local oProcess
	Local oPrcZera
	Local lRet           := .T.

	Private XX003
	Private RT002
	Private smMsnPrc
	Private hhTmpINI
	Private msrhEnter   := CHR(13) + CHR(10)
	Private msErroQuery
	Private xVerRet      := .T.
	Private msStaExcQy   := 0

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIA782", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 90, devido as amarrações com as tabelas origens.", "BIA782", "STOP")
		Return
	EndIf

	If xValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

		hhTmpINI  := TIME()
		smMsnPrc := "Processando Contabilização dos Expurgos"

		oPrcZera := MsNewProcess():New({|lEnd| ExistThenD(@oPrcZera) }, "Deletando...", smMsnPrc, .T.)
		oPrcZera:Activate()
		lRet := xVerRet

		If lRet
			oProcess := MsNewProcess():New({|lEnd| fCont782(@oProcess) }, "Extraindo...", smMsnPrc, .T.)
			oProcess:Activate()
			lRet := xVerRet
		EndIf

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msrhEnter + msrhEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			MsgINFO("Processamento realizado com sucesso!!!", "BIA782")

		EndIf

	Else

		MsgALERT("Processamento cancelado com sucesso!!!", "BIA782")

	EndIf


Return

Static Function xValidPerg()

	Local cLoad	    := "BIA782" + cEmpAnt
	Local cFileName := RetCodUsr() + "_" + cLoad
	Local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)
	MV_PAR02 :=	""

	aAdd( aPergs ,{1, "Ano/Mês"                    ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

Static Function ExistThenD(oPrcZera)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .T.

	If fExistTabl(RetSqlName("ZNF"))

		cQry := GetNextAlias()

		cSql := " DELETE ZNF "
		cSql += " FROM " + RetSqlName("ZNF") + " ZNF (NOLOCK) "
		cSql += " WHERE ZNF_FILIAL = '" + xFilial("ZNF") + "' "
		cSql += "       AND ZNF_DATREF = '" + dtos(dDataFin) + "' "
		cSql += "       AND ZNF.D_E_L_E_T_    = ' ' "
		U_BIAMsgRun("Aguarde... Deletando registros ZNF... ",,{|| msStaExcQy := TcSQLExec(cSql) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
			msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
			msErroQuery += "DELETE ZNF" + msrhEnter + msrhEnter
			msErroQuery += TCSQLError()

		EndIf

	Else

		msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
		msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
		msErroQuery += "A tabela ZNF não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet 

Return ( lRet )

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

Static Function fCont782(oProcess)

	Local msrhEnter    := CHR(13) + CHR(10)

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(254)             

	RT003 := U_BIA768Qy()

	RT002 := Alltrim(" SELECT ZNC_DATPRC,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILORI,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_EMPDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_FILDES,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_TABMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_ORIMOV,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        ZNC_GRPPRD,                                                                                                ") + msrhEnter
	RT002 += Alltrim("        DC,                                                                                                        ") + msrhEnter
	RT002 += Alltrim("        TPMOV,                                                                                                     ") + msrhEnter
	RT002 += Alltrim("        CONTA,                                                                                                     ") + msrhEnter
	RT002 += Alltrim("        ZNC_ITCTA,                                                                                                 ") + msrhEnter
	RT002 += Alltrim("        VALOR = SUM(VALOR)                                                                                         ") + msrhEnter
	RT002 += Alltrim(" FROM                                                                                                              ") + msrhEnter
	RT002 += Alltrim(" (                                                                                                                 ") + msrhEnter
	RT002 += RT003
	RT002 += Alltrim(" ) AS TEMP1                                                                                                        ") + msrhEnter
	RT002 += Alltrim(" GROUP BY ZNC_DATPRC,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_TABMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_ORIMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_GRPPRD,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          DC,                                                                                                      ") + msrhEnter
	RT002 += Alltrim("          TPMOV,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          CONTA,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_ITCTA                                                                                                ") + msrhEnter
	RT002 += Alltrim(" ORDER BY ZNC_DATPRC,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILORI,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_EMPDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_FILDES,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          DC,                                                                                                      ") + msrhEnter
	RT002 += Alltrim("          TPMOV,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_TABMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_ORIMOV,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          ZNC_GRPPRD,                                                                                              ") + msrhEnter
	RT002 += Alltrim("          CONTA,                                                                                                   ") + msrhEnter
	RT002 += Alltrim("          ZNC_ITCTA                                                                                                ") + msrhEnter

	QPIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT002),'QP001',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += RT002
		lRet := .F.
		Return
	EndIf

	dbSelectArea("QP001")
	dbGoTop()
	oProcess:SetRegua1(1)

	While !QP001->(Eof())

		oProcess:IncRegua2("Gerando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

		xDCExp    := ""
		xContaExp  := ""
		If !Empty(QP001->ZNC_EMPDES)
			xDCExp    := IIF(Substr(QP001->DC,1,1) == "1", "2-CREDITO", IIF(Substr(QP001->DC,1,1) == "2", "1-DEBITO", ""))
			xContaExp  := QP001->CONTA
		EndIf

		msCtaCPV := "41301001"
		msTpCPV  := 0
		msVlrCPV := 0
		If QP001->ZNC_TABMOV == "FAT" .and. QP001->ZNC_ORIMOV == "SAI"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := 1
			Else
				msTpCPV  := -1
			EndIf 
		ElseIf QP001->ZNC_TABMOV == "FAT" .and. QP001->ZNC_ORIMOV == "DEV"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := -1
			Else
				msTpCPV  := 1
			EndIf 
		ElseIf QP001->ZNC_TABMOV == "CTB"
			If QP001->TPMOV == "1-REC"
				msTpCPV  := 1
			Else
				msTpCPV  := -1
			EndIf 
		EndIf
		msVlrCPV := QP001->VALOR * msTpCPV

		msCtaRAI := ""
		msCLVRAI := ""
		msExtRAI := ""
		msVlrRAI := 0
		msVlrGan := 0

		RJ004 := Alltrim(" SELECT CTARAI = ZNE_CTARAI,                                                                                     ") + msrhEnter
		RJ004 += Alltrim("        CLVRAI = ZNE_CLVRAI,                                                                                     ") + msrhEnter
		RJ004 += Alltrim("        EXTRAI = ZNE_EXTRAI,                                                                                     ") + msrhEnter
		RJ004 += Alltrim("        PERORI = ZNE_PERORI / 100,                                                                               ") + msrhEnter
		RJ004 += Alltrim("        PERDES = ZNE_PERDES / 100                                                                                ") + msrhEnter
		RJ004 += Alltrim(" FROM " + RetSqlName("ZNE") + " ZNE(NOLOCK)                                                                      ") + msrhEnter
		RJ004 += Alltrim(" WHERE ZNE_FILIAL = '" + xFilial("ZNE") + "'                                                                     ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_EMPORI = '" + QP001->ZNC_EMPORI + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_EMPDES = '" + QP001->ZNC_EMPDES + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_CONTA = '" + QP001->CONTA + "'                                                                    ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_TABMOV = '" + QP001->ZNC_TABMOV + "'                                                              ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE_TPMOV = '" + Substr(QP001->TPMOV,1,1) + "'                                                        ") + msrhEnter
		RJ004 += Alltrim("       AND ZNE.D_E_L_E_T_ = ' '                                                                                  ") + msrhEnter
		RJIndex := CriaTrab(Nil,.f.)
		lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RJ004),'RJ04',.T.,.T.) },,.T.,,)
		If !lEvalBlock
			msErroQuery := "Problema: " + msrhEnter + msrhEnter
			msErroQuery += RJ004
			lRet := .F.
			Return
		EndIf

		RJ04->(dbGoTop())
		If !RJ04->(Eof())
			msCtaRAI := RJ04->CTARAI
			msCLVRAI := RJ04->CLVRAI
			msExtRAI := RJ04->EXTRAI
			msVlrRAI := msVlrCPV * ( 1 - RJ04->PERORI )
			msVlrGan := ( msVlrCPV * ( 1 - RJ04->PERDES ) ) - msVlrRAI
		EndIf
		RJ04->(dbCloseArea())
		Ferase(RJIndex+GetDBExtension())
		Ferase(RJIndex+OrdBagExt())

		msElegivel := "Sim"
		If QP001->ZNC_FILDES $ "  /ER" 
			msElegivel := "Não"
		EndIf

		If msElegivel == "Sim"

			// Expurgo
			RecLock("ZNF",.T.)
			ZNF->ZNF_FILIAL  := xFilial("ZNF")
			ZNF->ZNF_DATREF  := stod(QP001->ZNC_DATPRC)
			ZNF->ZNF_EMPORI  := QP001->ZNC_EMPORI
			ZNF->ZNF_FILORI  := QP001->ZNC_FILORI
			ZNF->ZNF_EMPDES  := QP001->ZNC_EMPDES
			ZNF->ZNF_FILDES  := QP001->ZNC_FILDES
			ZNF->ZNF_TABMOV  := QP001->ZNC_TABMOV
			ZNF->ZNF_ORIMOV  := QP001->ZNC_ORIMOV
			ZNF->ZNF_TIPMOV  := QP001->TPMOV
			ZNF->ZNF_DC      := Substr(xDCExp, 1, 1)
			ZNF->ZNF_CONTA   := xContaExp
			ZNF->ZNF_CLVL    := ""
			ZNF->ZNF_ITMCTA  := QP001->ZNC_ITCTA
			ZNF->ZNF_VALOR   := QP001->VALOR
			MsUnlock()

			// CPV
			If msVlrCPV <> 0

				RecLock("ZNF",.T.)
				ZNF->ZNF_FILIAL  := xFilial("ZNF")
				ZNF->ZNF_DATREF  := stod(QP001->ZNC_DATPRC)
				ZNF->ZNF_EMPORI  := QP001->ZNC_EMPORI
				ZNF->ZNF_FILORI  := QP001->ZNC_FILORI
				ZNF->ZNF_EMPDES  := QP001->ZNC_EMPDES
				ZNF->ZNF_FILDES  := QP001->ZNC_FILDES
				ZNF->ZNF_TABMOV  := QP001->ZNC_TABMOV
				ZNF->ZNF_ORIMOV  := QP001->ZNC_ORIMOV
				ZNF->ZNF_TIPMOV  := "6-CPV"
				ZNF->ZNF_DC      := "2"
				ZNF->ZNF_CONTA   := msCtaCPV
				ZNF->ZNF_CLVL    := ""
				ZNF->ZNF_ITMCTA  := QP001->ZNC_ITCTA
				ZNF->ZNF_VALOR   := msVlrCPV
				MsUnlock()

			EndIf

			// RAI
			If msVlrRAI <> 0

				RecLock("ZNF",.T.)
				ZNF->ZNF_FILIAL  := xFilial("ZNF")
				ZNF->ZNF_DATREF  := stod(QP001->ZNC_DATPRC)
				ZNF->ZNF_EMPORI  := QP001->ZNC_EMPORI
				ZNF->ZNF_FILORI  := QP001->ZNC_FILORI
				ZNF->ZNF_EMPDES  := QP001->ZNC_EMPDES
				ZNF->ZNF_FILDES  := QP001->ZNC_FILDES
				ZNF->ZNF_TABMOV  := QP001->ZNC_TABMOV
				ZNF->ZNF_ORIMOV  := QP001->ZNC_ORIMOV
				ZNF->ZNF_TIPMOV  := "7-RAI"
				ZNF->ZNF_DC      := "2"
				ZNF->ZNF_CONTA   := msCtaRAI
				ZNF->ZNF_CLVL    := msCLVRAI
				ZNF->ZNF_ITMCTA  := QP001->ZNC_ITCTA
				ZNF->ZNF_VALOR   := msVlrRAI
				MsUnlock()

			EndIf

		EndIf

		QP001->(dbSkip())

	End

	QP001->(dbCloseArea())
	Ferase(QPIndex+GetDBExtension())
	Ferase(QPIndex+OrdBagExt())

Return
