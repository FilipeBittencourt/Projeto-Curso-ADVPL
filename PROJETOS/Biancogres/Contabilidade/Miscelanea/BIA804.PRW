#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA804
@author Marcos Alberto Soprani
@since 01/12/21
@version 1.0
@description Rotina para Contabilizar os valores de Expurgo a partir dos dados da PPC
@type function
/*/

User Function BIA804()

	Local oProcess
	Local lRet          := .T.	

	Private XX003
	Private RT002
	Private smMsnPrc
	Private hhTmpINI
	Private msrhEnter   := CHR(13) + CHR(10)

	Private msErroQuery
	Private xVerRet     := .T.

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := ""
	Private xoSay1
	Private xoDlg

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIA804", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 90, devido as amarrações com as tabelas origens.", "BIA804", "STOP")
		Return
	EndIf

	If xValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

		hhTmpINI  := TIME()
		smMsnPrc := "Contabilizando Expurgos"

		oPrcZera := MsNewProcess():New({|lEnd| ExistThenD(@oPrcZera) }, "Verificando...", smMsnPrc, .T.)
		oPrcZera:Activate()
		lRet := xVerRet

		If lRet

			oProcess := MsNewProcess():New({|lEnd| fContab804(@oProcess) }, "Contabilizando...", smMsnPrc, .T.)
			oProcess:Activate()

		EndIf

	EndIf

	If !lRet

		xcMultiGe1 := "Erro de Query: " + msrhEnter + msrhEnter + msErroQuery

		DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

		@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
		@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
		@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

		ACTIVATE MSDIALOG xoDlg CENTERED

	Else

		MsgINFO("Processamento realizado com sucesso!!!", "BIA804")

	EndIf

Return

Static Function xValidPerg()

	Local cLoad	    := "BIA804" + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	Local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)

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

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD "
	cSql += " FROM " + RetSqlName("CT2") + " CT2(NOLOCK) "
	cSql += " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' "
	cSql += "       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
	cSql += "       AND CT2_LOTE IN('007000') "
	cSql += "       AND CT2.D_E_L_E_T_    = ' ' "
	XXIndex := CriaTrab(Nil,.f.)
	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'XX01',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += cSql
		lRet := .F.
		Return
	EndIf

	dbSelectArea("XX01")
	dbGoTop()
	If XX01->CONTAD <> 0

		msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
		msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
		msErroQuery += "REGISTROS CT2: " + Alltrim(Str(XX01->CONTAD))  + msrhEnter + msrhEnter
		lRet := .F.

	EndIf
	XX01->(dbCloseArea())
	Ferase(XXIndex+GetDBExtension())
	Ferase(XXIndex+OrdBagExt())

	If lRet

		cQry := GetNextAlias()

		cSql := " SELECT COUNT(*) CONTAD "
		cSql += " FROM " + RetSqlName("Z48") + " Z48(NOLOCK) "
		cSql += " WHERE Z48_FILIAL = '" + xFilial("Z48") + "' "
		cSql += "       AND Z48_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
		cSql += "       AND Z48_LOTE IN('007000') "
		cSql += "       AND Z48.D_E_L_E_T_    = ' ' "
		XXIndex := CriaTrab(Nil,.f.)
		lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'XX01',.T.,.T.) },,.T.,,)
		If !lEvalBlock
			msErroQuery := "Problema: " + msrhEnter + msrhEnter
			msErroQuery += cSql
			lRet := .F.
			Return
		EndIf

		dbSelectArea("XX01")
		dbGoTop()
		If XX01->CONTAD <> 0

			msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
			msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
			msErroQuery += "REGISTROS Z48: " + Alltrim(Str(XX01->CONTAD))  + msrhEnter + msrhEnter
			lRet := .F.

		EndIf
		XX01->(dbCloseArea())
		Ferase(XXIndex+GetDBExtension())
		Ferase(XXIndex+OrdBagExt())

	EndIf

	xVerRet := lRet 

Return

Static Function fContab804(oProcess)

	fgLanPad := "D02"
	fgLotCtb := "007000"
	fgVetCtb := {}
	fgPermDg := .T.

	RT007 := Alltrim(" SELECT DEBITO = CASE                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '1'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_CONTA                                                                                                                                        ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        CREDIT = CASE                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '2'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_CONTA                                                                                                                                        ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        CLVLDB = CASE                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '1'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_CLVL                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        CLVLCR = CASE                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '2'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_CLVL                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        ITEMD = CASE                                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '1'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_ITMCTA                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        ITEMC = CASE                                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim("                     WHEN ZNF_DC = '2'                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("                     THEN ZNF_ITMCTA                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim("                     ELSE ''                                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("                 END,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("        VALOR = SUM(ZNF_VALOR),                                                                                                                                            ") + msrhEnter
	RT007 += Alltrim("        HIST = 'ESTORNO ' + SUBSTRING(ZNF_TIPMOV, 3, 3) + ' EMPORI:' + ZNF_EMPORI + '/' + ZNF_FILORI + ' EMPDES:' + ZNF_EMPDES + '/' + ZNF_FILDES,                         ") + msrhEnter
	RT007 += Alltrim("        CCD = CASE                                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("                  WHEN ZNF_CLVL <> ''                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                       AND ZNF_DC = '1'                                                                                                                                    ") + msrhEnter
	RT007 += Alltrim("                  THEN '3000'                                                                                                                                              ") + msrhEnter
	RT007 += Alltrim("                  ELSE ''                                                                                                                                                  ") + msrhEnter
	RT007 += Alltrim("              END,                                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("        CCC = CASE                                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("                  WHEN ZNF_CLVL <> ''                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("                       AND ZNF_DC = '2'                                                                                                                                    ") + msrhEnter
	RT007 += Alltrim("                  THEN '3000'                                                                                                                                              ") + msrhEnter
	RT007 += Alltrim("                  ELSE ''                                                                                                                                                  ") + msrhEnter
	RT007 += Alltrim("              END,                                                                                                                                                         ") + msrhEnter
	RT007 += Alltrim("        ORIGEM = ZNF_TABMOV + ' ' + ZNF_ORIMOV + ' ' + ZNF_TIPMOV                                                                                                          ") + msrhEnter
	RT007 += Alltrim(" FROM " + RetSqlName("ZNF") + " ZNF(NOLOCK)                                                                                                                                ") + msrhEnter
	RT007 += Alltrim(" WHERE ZNF_FILIAL = '" + xFilial("ZNF") + "'                                                                                                                               ") + msrhEnter
	RT007 += Alltrim("       AND ZNF_DATREF BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                                                        ") + msrhEnter
	RT007 += Alltrim("       AND ZNF.D_E_L_E_T_ = ' '                                                                                                                                            ") + msrhEnter
	RT007 += Alltrim(" GROUP BY ZNF_TABMOV,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_ORIMOV,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_TIPMOV,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_DC,                                                                                                                                                          ") + msrhEnter
	RT007 += Alltrim("          ZNF_CONTA,                                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim("          ZNF_CLVL,                                                                                                                                                        ") + msrhEnter
	RT007 += Alltrim("          ZNF_ITMCTA,                                                                                                                                                        ") + msrhEnter
	RT007 += Alltrim("          SUBSTRING(ZNF_TIPMOV, 3, 3),                                                                                                                                     ") + msrhEnter
	RT007 += Alltrim("          ZNF_EMPORI,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_FILORI,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_EMPDES,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_FILDES                                                                                                                                                       ") + msrhEnter
	RT007 += Alltrim(" ORDER BY ZNF_TIPMOV,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_EMPORI,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_FILORI,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_EMPDES,                                                                                                                                                      ") + msrhEnter
	RT007 += Alltrim("          ZNF_FILDES                                                                                                                                                       ") + msrhEnter
	RTIndex := CriaTrab(Nil,.f.)

	lEvalBlock := EvalBlock():EvalBlock(@{|| dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT007),'CT07',.T.,.T.) },,.T.,,)
	If !lEvalBlock
		msErroQuery := "Problema: " + msrhEnter + msrhEnter
		msErroQuery += RT007
		lRet := .F.
		Return
	EndIf

	dbSelectArea("CT07")
	dbGoTop()
	oProcess:SetRegua1(1)

	msLinZ48 := 0
	While !CT07->(Eof())

		oProcess:IncRegua2("Contabilizando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

		IncProc()

		pdDEBITO := CT07->DEBITO
		pdCREDIT := CT07->CREDIT
		pdCLVLDB := CT07->CLVLDB
		pdCLVLCR := CT07->CLVLCR
		pdITEMD  := CT07->ITEMD
		pdITEMC  := CT07->ITEMC
		pdCCD    := CT07->CCD
		pdCCC    := CT07->CCC
		pdVALOR  := CT07->VALOR
		If CT07->VALOR < 0

			pdDEBITO := CT07->CREDIT
			pdCREDIT := CT07->DEBITO
			pdCLVLDB := CT07->CLVLCR
			pdCLVLCR := CT07->CLVLDB
			pdITEMD  := CT07->ITEMC
			pdITEMC  := CT07->ITEMD
			pdCCD    := CT07->CCC
			pdCCC    := CT07->CCD
			pdVALOR  := ABS(CT07->VALOR)

		EndIf

		If Alltrim(pdDEBITO) <> "41399006" .and. Alltrim(pdCREDIT) <> "41399006" 

			Aadd(fgVetCtb, { pdDEBITO, pdCREDIT, pdCLVLDB, pdCLVLCR, pdITEMD, pdITEMC, pdVALOR, CT07->HIST, pdCCD, pdCCC, CT07->ORIGEM })

		Else

			msLinZ48 ++
			msDC     := IIF(!Empty(pdDEBITO), "1", IIF(!Empty(pdCREDIT), "2", ""))
			RecLock("Z48",.T.)
			Z48->Z48_FILIAL := xFilial("Z48")
			Z48->Z48_DATA   := dDataFin
			Z48->Z48_LOTE   := fgLotCtb
			Z48->Z48_SBLOTE := "001"
			Z48->Z48_DOC    := "000001"
			Z48->Z48_LINHA  := StrZero(msLinZ48,3)
			Z48->Z48_DC     := msDC
			Z48->Z48_DEBITO := pdDEBITO
			Z48->Z48_CREDIT := pdCREDIT
			Z48->Z48_CLVLDB := pdCLVLDB
			Z48->Z48_CLVLCR := pdCLVLCR
			Z48->Z48_ITEMD  := pdITEMD
			Z48->Z48_ITEMC  := pdITEMC
			Z48->Z48_VALOR  := pdVALOR
			Z48->Z48_HIST   := CT07->HIST
			Z48->Z48_YHIST  := CT07->HIST
			Z48->Z48_YDELTA := dDataBase
			MsUnLock()

		EndIf

		CT07->(dbSkip())

	End

	CT07->(dbCloseArea())
	Ferase(RTIndex+GetDBExtension())
	Ferase(RTIndex+OrdBagExt())

	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

Return
