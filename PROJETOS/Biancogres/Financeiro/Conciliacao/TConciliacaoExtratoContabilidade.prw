#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TConciliacaoExtratoContabilidade
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Extrato x Contabilidade 
@obs Projeto A-61 - Conciliação do Extrato
@type class
/*/

Class TConciliacaoExtratoContabilidade From LongClassName 

	Data oParam
	Data cVwTypeMov // Tipo de visualização de movimentos bancarios: E=Exclusivo; C=Compartilhado
	
	Method New() Constructor
	Method BankBalance()
	Method AccountingBalance(cAccont, dDate, cType)
	Method Export()
	
EndClass


Method New(oParam) Class TConciliacaoExtratoContabilidade

	Default oParam := Nil

	::oParam := oParam
	
	::cVwTypeMov := Upper(GetNewPar("MV_YVWTPMO", "C"))
	
Return()


Method BankBalance() Class TConciliacaoExtratoContabilidade
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(ROUND(E8_SALATUA, 2), 0) AS E8_SALATUA "
	cSQL += " FROM " + RetSQLName("SE8")
	cSQL += " WHERE E8_FILIAL = " + ValToSQL(xFilial("SE8"))	
	cSQL += " AND E8_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E8_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E8_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E8_DTSALAT = " + ValToSQL(DataValida(DaySub(::oParam:dDataDe, 1), .F.))
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->E8_SALATUA

	(cQry)->(DbCloseArea())

Return(nRet)


Method AccountingBalance(cAccont, dDate, cType) Class TConciliacaoExtratoContabilidade
Local nRet := 0
Local aFil := {}
Local nCount := 0
Local cFilBkp := cFilAnt
	
	If ::cVwTypeMov == "E"
	
		nRet := SaldoConta(cAccont, dDate, "01", "1", If (cType == "D", 2, 3))
	
	Else
	
		aFil := FWAllFilial()
		
		For nCount := 1 To Len(aFil)
	
			cFilAnt := aFil[nCount]
	
			nRet += SaldoConta(cAccont, dDate, "01", "1", If (cType == "D", 2, 3))
	
		Next
		
		cFilAnt := cFilBkp
		
	EndIf

Return(nRet)


Method Export() Class TConciliacaoExtratoContabilidade
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAF175-" + cEmpAnt + __cUserID + "-" + dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWork01 := "Parâmetros"
Local cWork02 := "Saldo Anterior"
Local cWork03 := "Extrato x Contabilidade"
Local cTable01 := cWork01
Local cTable02 := cWork02
Local cTable03 := "Resumo - " + cWork03
Local cDirTmp := AllTrim(GetTempPath())
Local cSQL := ""
Local cQry := GetNextAlias()
Local dData := dDatabase
Local nEnt := 0
Local nSai := 0
Local nSalF := 0
Local nDeb := 0
Local nCre := 0
Local nSalC := 0
Local nDif := 0
Local nDifDeb := 0
Local nDifCre := 0
Local cConta := Posicione("SA6", 1, xFilial("SA6") + ::oParam:cBanco + ::oParam:cAgencia + ::oParam:cConta, "A6_CONTA")
Local nVlSIni := ::BankBalance()

  oFWExcel := FWMsExcel():New()

	oFWExcel:AddWorkSheet(cWork01)
	oFWExcel:AddTable(cWork01, cTable01)
	oFWExcel:AddColumn(cWork01, cTable01, "Banco", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Agência", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Conta", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Data De", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Data Até", 1, 1)

	oFWExcel:AddRow(cWork01, cTable01, {::oParam:cBanco, ::oParam:cAgencia, ::oParam:cConta, ::oParam:dDataDe, ::oParam:dDataAte})

	oFWExcel:AddWorkSheet(cWork02)
	oFWExcel:AddTable(cWork02, cTable02)
	oFWExcel:AddColumn(cWork02, cTable02, "Banco", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Agência", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Conta", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Data", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Saldo", 3, 2, .F.)

	oFWExcel:AddRow(cWork02, cTable02, {::oParam:cBanco, ::oParam:cAgencia, ::oParam:cConta, DataValida(DaySub(::oParam:dDataDe, 1)), nVlSIni})

	oFWExcel:AddWorkSheet(cWork03)
	oFWExcel:AddTable(cWork03, cTable03)
	oFWExcel:AddColumn(cWork03, cTable03, "Data", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Entradas", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Saídas", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork03, cTable03, "Saldo Financeiro", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Débito", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Crédito", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork03, cTable03, "Saldo Contábil", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Dif. Dia", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork03, cTable03, "Débito", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Crédito", 3, 2, .T.)	
		
	cSQL := " SELECT E5_DTDISPO, ISNULL(ROUND(SUM(CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE 0 END), 2), 0) AS ENT, ISNULL(ROUND(SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR ELSE 0 END), 2), 0) AS SAI "
	cSQL += " FROM " + RetSQLName("SE5")

	If ::cVwTypeMov == "E"

		cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))

	ElseIf ::cVwTypeMov == "C"

		cSQL += " WHERE E5_FILIAL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND E5_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_TIPODOC NOT IN ('BA','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL') "
	cSQL += " AND (E5_MOEDA NOT IN ('C1','C2','C3','C4','C5','CH') OR (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ <> '')) "
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND ((E5_TIPODOC IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + ")"
	cSQL += " OR (E5_TIPODOC NOT IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + "))"
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_DTDISPO "
	cSQL += " ORDER BY E5_DTDISPO "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
		
		dData := dToC(sToD((cQry)->E5_DTDISPO))
	
		nEnt := (cQry)->ENT
		nSai := (cQry)->SAI
		nSalF := nVlSIni + nEnt - nSai
		
		nDeb := ::AccountingBalance(cConta, sToD((cQry)->E5_DTDISPO), "D")
		nCre := ::AccountingBalance(cConta, sToD((cQry)->E5_DTDISPO), "C")
		nSalC := nVlSIni + nDeb - nCre
		
		nDif := nSalC - nSalF
		nDifDeb := nEnt - nDeb
		nDifCre := nSai - nCre
		
		nVlSIni := nSalF
		
	  oFWExcel:AddRow(cWork03, cTable03, {dData, nEnt, nSai, nSalF, nDeb, nCre, nSalC, nDif, nDifDeb, nDifCre})
	  
	  (cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())
			
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
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif
	
	RestArea(aArea)
		
Return()