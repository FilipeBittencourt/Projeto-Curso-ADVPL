#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA639
@author Wlysses Cerqueira (Facile)
@since 22/12/2020
@version 1.0
@Projet A-35
@description Excel Kardex Orçado. 
@type function
/*/

User Function BIA639()

	Local oEmp 	:= Nil
	Local oPerg	:= Nil

	Private cTitulo := "Kardex Orçado"

    RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			FWMsgRun(, {|| RunExcel(oEmp:aEmpSel, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef) }, "Processando", "Gerando excel...")

		Else

			Alert("Nenhuma empresa foi selecionada!")

		EndIf

	EndIf

    RpcClearEnv()

Return()

Static Function RunExcel(aEmp, cVersao, cRevisa, cAnoRef)

	Local lRet  := .F.
	Local nW    := 0
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Local cSheet	:= ""
	Local cTitSheet	:= ""

	Local oFWExcel	:= FWMsExcel():New()
	Local cDir		:= GetSrvProfString("Startpath", "")
	Local cDirTemp	:= AllTrim(GetTempPath())
	Local cFile		:= "Kardex Orçado - " + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".xml"

	For nW := 1 To Len(aEmp)

		cSheet := "Empresa: " + aEmp[nW][1]

		cTitSheet := "Kardex Orçado: " + aEmp[nW][1]

		oFWExcel:AddWorkSheet(cSheet)

		oFWExcel:AddTable(cSheet, cTitSheet)

		//4 - Alinhamento da coluna ( 1-Left	,2-Center,3-Right )
		//5 - Codigo de formatação  ( 1-General	,2-Number,3-Monetário,4-DateTime )

        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_FILIAL"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VERSAO"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_REVISA"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_ANOREF"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_DTREF"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_PRODUT"	, 1)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VPROD"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_QVENDA"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VVENDA"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_QSALDO"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VSALDO"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_QINI"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_QPROD"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VINI"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VAREST"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VEQTDA"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VECST"	, 3, 2)
        oFWExcel:AddColumn(cSheet, cTitSheet, "ZOB_VECHEC"	, 3, 2)

        cSql := " SELECT * "
        cSql += " FROM " + RetFullName("ZOB", aEmp[nW][1]) + " ZOB (NOLOCK) "
        cSql += " WHERE ZOB.D_E_L_E_T_  = '' "
        cSql += " AND ZOB.ZOB_FILIAL    = " + ValToSql(aEmp[nW][1])
        cSql += " AND ZOB.ZOB_VERSAO    = " + ValToSql(cVersao)
        cSql += " AND ZOB.ZOB_REVISA    = " + ValToSql(cRevisa)
        cSql += " AND ZOB.ZOB_ANOREF    = " + ValToSql(cAnoRef)
        
		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(Eof())

			oFWExcel:AddRow(cSheet, cTitSheet,;
				{;
                    (cQry)->ZOB_FILIAL,;
                    (cQry)->ZOB_VERSAO,;
                    (cQry)->ZOB_REVISA,;
                    (cQry)->ZOB_ANOREF,;
                    (cQry)->ZOB_DTREF,;
                    (cQry)->ZOB_PRODUT,;
                    (cQry)->ZOB_VPROD,;
                    (cQry)->ZOB_QVENDA,;
                    (cQry)->ZOB_VVENDA,;
                    (cQry)->ZOB_QSALDO,;
                    (cQry)->ZOB_VSALDO,;
                    (cQry)->ZOB_QINI,;
                    (cQry)->ZOB_QPROD,;
                    (cQry)->ZOB_VINI,;
                    (cQry)->ZOB_VAREST,;
                    (cQry)->ZOB_VEQTDA,;
                    (cQry)->ZOB_VECST,;
                    (cQry)->ZOB_VECHEC;
				})

			lRet := .T.

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

	Next nW

	If lRet

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cFile)
		oFWExcel:DeActivate()

		If Right(cDir,1) <> "\"

			cDir := cDir + "\"

		EndIf

		If CpyS2T(cDir + cFile, cDirTemp, .T.)

			If ApOleClient('MsExcel')

				oMSExcel := MsExcel():New()
				oMSExcel:WorkBooks:Close()
				oMSExcel:WorkBooks:Open(cDirTemp + cFile)
				oMSExcel:SetVisible(.T.)
				oMSExcel:Destroy()

			EndIf

		Else

			MsgInfo("Arquivo não copiado para a pasta temporária do usuário!")

		EndIf

	Else

		MsgInfo("Não foi encontrado dados!")

	EndIf

Return(lRet)
