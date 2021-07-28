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
	Method Export()
	
EndClass


Method New(oParam) Class TConciliacaoExtratoContabilidade

	Default oParam := Nil

	::oParam := oParam
	
	::cVwTypeMov := Upper(GetNewPar("MV_YVWTPMO", "C"))
	
Return()


Method Export() Class TConciliacaoExtratoContabilidade
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAF175-" + cEmpAnt + __cUserID + "-" + dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWork01 := "Extrato x Contabilidade"
Local cTable01 := "Resumo - " + cWork01
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

  oFWExcel := FWMsExcel():New()
	  
	oFWExcel:AddWorkSheet(cWork01)
	oFWExcel:AddTable(cWork01, cTable01)
	oFWExcel:AddColumn(cWork01, cTable01, "Data", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Entradas", 3, 2, .T.)
	oFWExcel:AddColumn(cWork01, cTable01, "Saídas", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork01, cTable01, "Saldo Financeiro", 3, 2, .T.)
	oFWExcel:AddColumn(cWork01, cTable01, "Débito", 3, 2, .T.)
	oFWExcel:AddColumn(cWork01, cTable01, "Crédito", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork01, cTable01, "Saldo Contábil", 3, 2, .T.)
	oFWExcel:AddColumn(cWork01, cTable01, "Dif. Dia", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork01, cTable01, "Débito", 3, 2, .T.)
	oFWExcel:AddColumn(cWork01, cTable01, "Crédito", 3, 2, .T.)	
		
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
		nSalF := nEnt - nSai
		
		nDeb := SaldoConta(cConta, sToD((cQry)->E5_DTDISPO), "01", "1", 2)
		nCre := SaldoConta(cConta, sToD((cQry)->E5_DTDISPO), "01", "1", 3)
		nSalC := nDeb - nCre
		
		nDif := nSalC - nSalF
		nDifDeb := nEnt - nDeb
		nDifCre := nSai - nCre	  	  
			  
	  oFWExcel:AddRow(cWork01, cTable01, {dData, nEnt, nSai, nSalF, nDeb, nCre, nSalC, nDif, nDifDeb, nDifCre})
	  
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