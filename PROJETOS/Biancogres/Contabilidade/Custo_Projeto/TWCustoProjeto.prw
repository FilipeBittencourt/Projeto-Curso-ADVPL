#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWCustoProjeto
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para gera��o do Relatorio de Custos dos Projetos
@obs Projeto: D-01 - Custos dos Projetos
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Custos dos Projetos"

// Titulo dos botoes
#DEFINE TIT_BTN_PAR "Parametros"
#DEFINE TIT_BTN_EXP "Exportar"

Class TWCustoProjeto From LongClassName 

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox
	Data oBrw	
	Data oField
	Data oParam
	
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetEditableField()
	Method GetFieldProperty()
	Method GetFieldData()
	Method GetData01()
	Method GetData02()
	Method GetData03()
	Method GetDataCtr(cNumero, cItemCta, cSubItem)			
	Method ParamBox()
	Method Refresh()
	Method Export()
	Method ExportExcel()

EndClass


Method New(oParam) Class TWCustoProjeto

	Default oParam := Nil

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::oBrw := Nil	
	::oField := TGDField():New()

	::oParam := oParam
	
Return()


Method LoadInterface() Class TWCustoProjeto

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWCustoProjeto
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()

	::oWindow:AddButton(TIT_BTN_PAR, {|| ::ParamBox() }, TIT_BTN_PAR,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_EXP, {|| ::Export(.T.) }, TIT_BTN_EXP,, .T., .F., .T.)	
	
Return()


Method LoadContainer() Class TWCustoProjeto

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWCustoProjeto
Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(),,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWCustoProjeto	

	::LoadInterface()
		
	::oWindow:Activate()

Return()


Method GetEditableField() Class TWCustoProjeto
Local aRet := {}

Return(aRet)


Method GetFieldProperty() Class TWCustoProjeto

	::oField:Clear()

	::oField:AddField("C3_NUM")
	::oField:FieldName("C3_NUM"):cTitle := "Contrato"
			
	::oField:AddField("C3_YCLVL")
	::oField:FieldName("C3_YCLVL"):cTitle := "Clvl"
	
	::oField:AddField("C3_YITEMCT")
	::oField:FieldName("C3_YITEMCT"):cTitle := "Item"
	
	::oField:AddField("C3_YSUBITE")
	::oField:FieldName("C3_YSUBITE"):cTitle := "Subitem"
	
	::oField:AddField("A2_NOME")
	::oField:FieldName("A2_NOME"):cTitle := "Fornecedor"
	
	::oField:AddField("E2_TIPO")

	::oField:AddField("E2_NUMBCO")
	::oField:FieldName("E2_NUMBCO"):cTitle := "Status"
	::oField:FieldName("E2_NUMBCO"):nSize := 15

	::oField:AddField("E2_NUM")
	::oField:FieldName("E2_NUM"):cTitle := "Documento"
	::oField:FieldName("E2_NUM"):nSize := 16

	::oField:AddField("C7_DESCRI")
	::oField:FieldName("C7_DESCRI"):cTitle := "Descri��o"
		
	::oField:AddField("C7_DATPRF")
	::oField:FieldName("C7_DATPRF"):cTitle := "Data"
	
	::oField:AddField("E2_VALOR")
	::oField:FieldName("E2_VALOR"):cTitle := "Valor"

	::oField:AddField("SPACE")			
		
Return(::oField:GetHeader())


Method GetFieldData() Class TWCustoProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM FNC_CTR_CUSTO(" +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) +;
						", " + ValToSQL(::oParam:cCodForDe) + ", " + ValToSQL(::oParam:cCodForAte) +;
						", " + ValToSQL(::oParam:dDataDe) + ", " + ValToSQL(::oParam:dDataAte) + ")"	
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->CONTRATO, (cQry)->CLVL, (cQry)->ITEMCT, (cQry)->SUBITEM, (cQry)->NOME_FOR, (cQry)->TIPO, (cQry)->STATUS,;
								(cQry)->DOC, (cQry)->DESCRICAO, dToC(sToD((cQry)->DATA)), (cQry)->VALOR, Space(1), .F.})
																		
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method ParamBox() Class TWCustoProjeto

	If ::oParam:Box()
		
		U_BIAMsgRun("Atualizando dados...", "Aguarde!", {|| ::Refresh() })
		
	EndIf

Return()


Method Refresh() Class TWCustoProjeto

	::oBrw:SetArray(::GetFieldData())
	
	::oBrw:Refresh()

Return()


Method Export() Class TWCustoProjeto

	U_BIAMsgRun("Gerando Planilha de Custos...", "Aguarde!", {|| ::ExportExcel() })

Return()


Method ExportExcel() Class TWCustoProjeto
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAF161-" + cEmpAnt + __cUserID + "-" + dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWork01 := "Anal�tico I"
Local cWork02 := "Anal�tico II"
Local cWork03 := "Sint�tico"
Local cTable01 := "Custos dos Projetos " + cWork01 
Local cTable02 := "Custos dos Projetos " + cWork02
Local cTable03 := "Custos dos Projetos " + cWork03
Local cDirTmp := AllTrim(GetTempPath())
Local nCount := 0
Local aLine01 := {}
Local aLine02 := {}
Local aLine03 := {}
	
  oFWExcel := FWMsExcel():New()
	  
	oFWExcel:AddWorkSheet(cWork01) 
	oFWExcel:AddTable(cWork01, cTable01)
	oFWExcel:AddColumn(cWork01, cTable01, "Contrato", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Clvl", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Item", 1, 1)		
	oFWExcel:AddColumn(cWork01, cTable01, "Subitem", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Fornecedor", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Tipo", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Status", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Documento", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Descri��o", 1, 1)			
	oFWExcel:AddColumn(cWork01, cTable01, "Data", 1, 1)	
	oFWExcel:AddColumn(cWork01, cTable01, "Valor", 3, 2, .T.)
	  		
	aLine01 := ::GetData01()
	
	For nCount := 1 To Len(aLine01) 

		oFWExcel:AddRow(cWork01, cTable01, aLine01[nCount])

	Next
	
	oFWExcel:AddWorkSheet(cWork02) 
	oFWExcel:AddTable(cWork02, cTable02)
	oFWExcel:AddColumn(cWork02, cTable02, "Contrato", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Clvl", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Fornecedor", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Documento", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Descri��o", 1, 1)			
	oFWExcel:AddColumn(cWork02, cTable02, "Data", 1, 1)	
	oFWExcel:AddColumn(cWork02, cTable02, "Valor", 3, 2, .T.)

	aLine02 := ::GetData02()
	
	For nCount := 1 To Len(aLine02) 

		oFWExcel:AddRow(cWork02, cTable02, aLine02[nCount])

	Next
	
	oFWExcel:AddWorkSheet(cWork03) 
	oFWExcel:AddTable(cWork03, cTable03)
	oFWExcel:AddColumn(cWork03, cTable03, "Contrato", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Item", 1, 1)		
	oFWExcel:AddColumn(cWork03, cTable03, "Subitem", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Nome", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Fornecedor", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Vencimento", 1, 1)	
	oFWExcel:AddColumn(cWork03, cTable03, "Valor Total", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Pago Bruto", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Pagamento Antecipado", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Total Comprometido", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Saldo", 3, 2, .F.)
	  		
	aLine03 := ::GetData03()
	
	For nCount := 1 To Len(aLine03) 

		oFWExcel:AddRow(cWork03, cTable03, aLine03[nCount])

	Next	
			
	oFWExcel:Activate()			
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()		
		 	
	If CpyS2T(cDir + cFile, cDirTmp, .T.)
		
		fErase(cDir + cFile) 
		
		If ApOleClient('MsExcel')
		
			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()
			
		EndIf

	Else
		MsgInfo("Arquivo n�o copiado para a pasta tempor�ria do usu�rio.")
	Endif
	
	RestArea(aArea)
		
Return()


Method GetData01() Class TWCustoProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM FNC_CTR_CUSTO(" +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) +;
						", " + ValToSQL(::oParam:cCodForDe) + ", " + ValToSQL(::oParam:cCodForAte) +;
						", " + ValToSQL(::oParam:dDataDe) + ", " + ValToSQL(::oParam:dDataAte) + ")"	
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->CONTRATO, (cQry)->CLVL, (cQry)->ITEMCT, (cQry)->SUBITEM, (cQry)->NOME_FOR, (cQry)->TIPO, (cQry)->STATUS,;
									(cQry)->DOC, (cQry)->DESCRICAO, dToC(sToD((cQry)->DATA)), (cQry)->VALOR})
	  
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetData02() Class TWCustoProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT * " 
	cSQL += " FROM FNC_CTR_CUSTO_PROD(" +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) +;
						", " + ValToSQL(::oParam:cCodForDe) + ", " + ValToSQL(::oParam:cCodForAte) +;
						", " + ValToSQL(::oParam:dDataDe) + ", " + ValToSQL(::oParam:dDataAte) + ")"	
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {(cQry)->CONTRATO, (cQry)->CLVL, (cQry)->NOME_FOR, (cQry)->DOC, (cQry)->DESCRICAO, dToC(sToD((cQry)->DATA)), (cQry)->VALOR})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetData03() Class TWCustoProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT CONTRATO, ITEMCT, SUBITEM, ISNULL(ROUND(SUM(VALOR), 2), 0) AS VLRPAG, "

	cSQL += " (
	cSQL += " 	SELECT ISNULL(ROUND(SUM(VALOR), 2) , 0)
	cSQL += " 	FROM FNC_CTR_MOV_BAN('01', CONTRATO, CONTRATO, " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) + ", ITEMCT, ITEMCT, SUBITEM, SUBITEM) "
	cSQL += " ) AS PAGBRU,

	cSQL += " (
	cSQL += " 	SELECT ISNULL(ROUND(SUM(SALDO), 2) , 0)
	cSQL += " 	FROM FNC_CTR_PA('01', CONTRATO, CONTRATO, " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) + ", ITEMCT, ITEMCT, SUBITEM, SUBITEM) "
	cSQL += " 	WHERE SALDO > 0
	cSQL += " ) AS PAGANT	
	
	cSQL += " FROM "
	cSQL += " ( "
	
	cSQL += " SELECT CONTRATO, ITEMCT, SUBITEM, ROUND(SUM(VALOR), 2) AS VALOR " 
	cSQL += " FROM FNC_CTR_CUSTO(" +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) +;
						", " + ValToSQL(::oParam:cCodForDe) + ", " + ValToSQL(::oParam:cCodForAte) +;
						", " + ValToSQL(::oParam:dDataDe) + ", " + ValToSQL(::oParam:dDataAte) + ")"
	cSQL += " WHERE SUBSTRING(CONTRATO, 3, 1) <> '9' " 
	cSQL += " GROUP BY CONTRATO, ITEMCT, SUBITEM "
	
	cSQL += " UNION ALL "	
	
	cSQL += " SELECT CONTRATO, '' AS ITEMCT, '' AS SUBITEM, ROUND(SUM(VALOR), 2) AS VALOR " 
	cSQL += " FROM FNC_CTR_CUSTO(" +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) +;
						", " + ValToSQL(::oParam:cCodForDe) + ", " + ValToSQL(::oParam:cCodForAte) +;
						", " + ValToSQL(::oParam:dDataDe) + ", " + ValToSQL(::oParam:dDataAte) + ")"
	cSQL += " WHERE SUBSTRING(CONTRATO, 3, 1) = '9' "						
	cSQL += " GROUP BY CONTRATO "
	
	cSQL += " UNION ALL "
	
	cSQL += " SELECT CONTRATO, ITEMCT, SUBITEM, 0 AS VALOR " 
	cSQL += " FROM FNC_CTR('01', " +; 
						ValToSQL(::oParam:cContratoDe) + ", " + ValToSQL(::oParam:cContratoAte) +;
						", " + ValToSQL(::oParam:cClvlDe) + ", " + ValToSQL(::oParam:cClvlAte) +;
						", " + ValToSQL(::oParam:cItemDe) + ", " + ValToSQL(::oParam:cItemAte) +;
						", " + ValToSQL(::oParam:cSubitemDe) + ", " + ValToSQL(::oParam:cSubitemAte) + ")"
	cSQL += " WHERE SUBSTRING(CONTRATO, 3, 1) <> '9' " 
	cSQL += " GROUP BY CONTRATO, ITEMCT, SUBITEM "
	
	cSQL += " ) AS CTR "
	cSQL += " GROUP BY CONTRATO, ITEMCT, SUBITEM "
	cSQL += " ORDER BY CONTRATO, ITEMCT, SUBITEM "
					
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aContrato := {}
		
		aContrato := ::GetDataCtr((cQry)->CONTRATO, (cQry)->ITEMCT, (cQry)->SUBITEM)
		
		cNomCtr := aContrato[1, 1]
		cFornece := aContrato[1, 2]
		dVencto := aContrato[1, 3]
		nVlrTot := aContrato[1, 4]
 		
		nVlrPag := 0
		
		nVlrPag := (cQry)->VLRPAG
		
		nPagBru := 0 
		
		nPagBru := (cQry)->PAGBRU
		
		nPagAnt := 0
		
		nPagAnt := (cQry)->PAGANT
		
		nTotCom := 0
		
		If nVlrPag > 0
		
			nTotCom := nVlrPag - nPagAnt
			
		EndIf 
		
		nSaldo := 0
		
		If nVlrTot > 0
		
			nSaldo := nVlrTot - nTotCom
			
		EndIf
	
		aAdd(aRet, {(cQry)->CONTRATO, (cQry)->ITEMCT, (cQry)->SUBITEM, cNomCtr, cFornece, dToC(sToD(dVencto)), nVlrTot, nPagBru, nPagAnt, nTotCom, nSaldo})
	  
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetDataCtr(cNumero, cItemCta, cSubItem) Class TWCustoProjeto
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local lCtrGen := SubStr(cNumero, 3, 1) == "9"

	cSQL := " SELECT C3_OBS, " 
	cSQL += " ( "
	cSQL += " 	SELECT A2_NOME "
	cSQL += " 	FROM " + RetSQLName("SA2")
	cSQL += " 	WHERE A2_COD = C3_FORNECE "
	cSQL += " 	AND A2_LOJA = C3_LOJA "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) AS A2_NOME, C3_DATPRF, "
	
	If !lCtrGen
	
		cSQL += " C3_TOTAL "
	
	Else

		cSQL += " SUM(C3_TOTAL) AS C3_TOTAL "
				
	EndIf
	
	cSQL += " FROM " + RetFullName("SC3", "01")
	cSQL += " WHERE C3_FILIAL = " + ValToSQL(xFilial("SC3"))
	cSQL += " AND C3_NUM = " + ValToSQL(cNumero)
	//cSQL += " AND C3_YCLVL = " + ValToSQL(cClvl)

	If !lCtrGen
	
		cSQL += " AND C3_YITEMCT = " + ValToSQL(cItemCta)
		cSQL += " AND C3_YSUBITE = " + ValToSQL(cSubItem)
		
	EndIf

	cSQL += " AND D_E_L_E_T_ = '' "
	
	If lCtrGen
	
		cSQL += " GROUP BY C3_OBS, C3_FORNECE, C3_LOJA, C3_DATPRF "
		
	EndIf	
	
	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->A2_NOME)
			
		cObs := (cQry)->C3_OBS
		cNome := (cQry)->A2_NOME
		dData := (cQry)->C3_DATPRF
		nValor := 0
		
		While !(cQry)->(Eof())
	  
			nValor += (cQry)->C3_TOTAL

			(cQry)->(DbSkip())

	  EndDo()
	  
	  aAdd(aRet, {cObs, cNome, dData, nValor})
	  		
	Else
	
		aAdd(aRet, {"", "", "", 0})
		  
	EndIf
	
	(cQry)->(DbCloseArea())

Return(aRet)