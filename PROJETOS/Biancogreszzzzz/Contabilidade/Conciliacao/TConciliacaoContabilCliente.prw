#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TConciliacaoContabilCliente
@author Tiago Rossini Coradini
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Contabil - Clientes 
@obs Projeto: A-54
@type class
/*/

Class TConciliacaoContabilCliente From LongClassName 

	Data oParam
	
	Method New() Constructor
	Method Export()
	Method GetSalFin(dData, cConta)
	Method GetSalCon(dData, cConta)
	
EndClass


Method New(oParam) Class TConciliacaoContabilCliente

	Default oParam := Nil

	::oParam := oParam
	
Return()


Method Export() Class TConciliacaoContabilCliente
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAF164-" + cEmpAnt + __cUserID + "-" + dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWork01 := "Saldo Anterior"
Local cWork02 := "Sintetico"
Local cWork03 := "Analítico"
Local cTable01 := "Conciliacao Contabil - " + cWork01
Local cTable02 := "Conciliacao Contabil - " + cWork02
Local cTable03 := "Conciliacao Contabil - " + cWork03
Local cDirTmp := AllTrim(GetTempPath())
Local cSQL := ""
Local cQry := GetNextAlias()

  oFWExcel := FWMsExcel():New()
	  
	oFWExcel:AddWorkSheet(cWork01)
	oFWExcel:AddTable(cWork01, cTable01)
	oFWExcel:AddColumn(cWork01, cTable01, "Conta", 1, 1)
	oFWExcel:AddColumn(cWork01, cTable01, "Saldo Financeiro", 3, 2, .F.)
	oFWExcel:AddColumn(cWork01, cTable01, "Saldo Contabil", 3, 2, .F.)	
	oFWExcel:AddColumn(cWork01, cTable01, "Diferenca", 3, 2, .F.)

  dData := DaySub(::oParam:dDataDe, 1)
  nSalFAnt := ::GetSalFin(dData, ::oParam:cConta)
  nSalCAnt := ::GetSalCon(dData, ::oParam:cConta)
  nDif := nSalCAnt - nSalFAnt
   
  oFWExcel:AddRow(cWork01, cTable01, {::oParam:cConta, nSalFAnt, nSalCAnt, nDif})

	oFWExcel:AddWorkSheet(cWork02) 
	oFWExcel:AddTable(cWork02, cTable02)
	oFWExcel:AddColumn(cWork02, cTable02, "Data", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Conta", 1, 1)
	oFWExcel:AddColumn(cWork02, cTable02, "Saldo Financeiro", 3, 2, .F.)
	oFWExcel:AddColumn(cWork02, cTable02, "Saldo Contabil", 3, 2, .F.)	
	oFWExcel:AddColumn(cWork02, cTable02, "Diferenca", 3, 2, .F.)

  dData := ::oParam:dDataAte
  nSalFAtu := ::GetSalFin(dData, ::oParam:cConta)
  nSalCAtu := ::GetSalCon(dData, ::oParam:cConta)
  nDif := nSalCAtu - nSalFAtu  
  
  oFWExcel:AddRow(cWork02, cTable02, {dToC(dData), ::oParam:cConta, nSalFAtu, nSalCAtu, nDif})

	oFWExcel:AddWorkSheet(cWork03) 
	oFWExcel:AddTable(cWork03, cTable03)
	oFWExcel:AddColumn(cWork03, cTable03, "Filial", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Data", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "DC", 1, 1)		
	oFWExcel:AddColumn(cWork03, cTable03, "Debito", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Credito", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Valor", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Saldo Contabil", 3, 2, .T.)
	oFWExcel:AddColumn(cWork03, cTable03, "Historico Contabil", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Tabela", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Valor", 3, 2, .F.)
	oFWExcel:AddColumn(cWork03, cTable03, "Saldo Financeiro", 3, 2, .T.)	
	oFWExcel:AddColumn(cWork03, cTable03, "Historico Financeiro", 1, 1)
	oFWExcel:AddColumn(cWork03, cTable03, "Diferenca", 3, 2, .F.)

	cSQL := " SELECT CV3_FILIAL, CV3_DTSEQ, CV3_DC, CV3_DEBITO, CV3_CREDIT, CV3_VLR01, CV3_HIST, CV3_TABORI, CV3_RECORI, CV3_RECDES "
	cSQL += " FROM " + RetSQLName("CV3")
	cSQL += " WHERE CV3_FILIAL = " + ValToSQL(xFilial("CV3"))
	cSQL += " AND (CV3_DEBITO = " + ValToSQL(::oParam:cConta) + "OR CV3_CREDIT = "+ ValToSQL(::oParam:cConta) +")"
	cSQL += " AND CV3_DTSEQ BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND "+ ValToSQL(::oParam:dDataAte)
	cSQL += " AND CV3_RECDES <> '' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	nSalFin := nSalFAnt
	nSalCon := nSalCAnt

	While !(cQry)->(Eof())
	  
	  cHist := ""
	  nValor := 0
	  nDif := 0 
	  nRecOri := Val((cQry)->CV3_RECORI)
	  nRecDes := Val((cQry)->CV3_RECDES)
	  	  
	  If nRecOri > 0
		  	  
		  cTab := (cQry)->CV3_TABORI
		  
		  DbSelectArea(cTab)
		  (cTab)->(DbGoTo(nRecOri))
		  
		  If !(cTab)->(Deleted())
		  	  
			  If cTab == "SE5"
			  	
			  	nValor := SE5->E5_VALOR 
			  	 
			  ElseIf cTab == "SD1"
			  
			  	nValor := SD1->D1_TOTAL
			  
			  ElseIf cTab == "SD2"
		
			  	nValor := SD2->D2_VALBRUT
			  				  
			  EndIf
			  
			EndIf
		  
		  If (cQry)->CV3_DC == "2"

				nSalFin -= nValor
				nSalCon -= (cQry)->CV3_VLR01
		  			 
			Else
			
			  nSalFin += nValor
			  nSalCon += (cQry)->CV3_VLR01
			
			EndIf
		  
		  nDif := nSalCon - nSalFin
		 		  			  		  
		EndIf
		
	  If nRecDes > 0
	  
	  	DbSelectArea("CT2")
	  	CT2->(DbGoTo(nRecDes))
	  	
	  	If !CT2->(Deleted()) 
	  	
	  		cHist := AllTrim(CT2->CT2_YHIST)
	  	
	  	EndIf
	  
	  EndIf
			  
	  oFWExcel:AddRow(cWork03, cTable03, {(cQry)->CV3_FILIAL, dToC(sToD((cQry)->CV3_DTSEQ)), (cQry)->CV3_DC, (cQry)->CV3_DEBITO, (cQry)->CV3_CREDIT, (cQry)->CV3_VLR01, nSalCon,;
	  								cHist, (cQry)->CV3_TABORI, nValor, nSalFin, (cQry)->CV3_HIST, nDif})
	  
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


Method GetSalFin(dData, cConta) Class TConciliacaoContabilCliente
Local nRet := 0
Local cCodCli := Right(AllTrim(cConta), 6)
Local cSQL := ""
Local cQry := GetNextAlias()

	TcSPExec("SP_RELPOSCLI_ANALITICO", dToS(dData), cCodCli, cCodCli)
	
	cSQL := " SELECT SUM(SALDO) AS SALDO "
	cSQL += " FROM POSCLI_DATA_CR_ANALITICO "
	cSQL += " WHERE EMPFIL = " + ValToSQL(cEmpAnt + cFilAnt)
	cSQL += " AND DATAREF = " + ValToSQL(dData)
	cSQL += " AND CODCLI = " + ValToSQL(cCodCli)

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->SALDO

	(cQry)->(DbCloseArea())
		
Return(nRet)


Method GetSalCon(dData, cConta) Class TConciliacaoContabilCliente
Local nRet := 0

	nRet := (SaldoConta(cConta, dData, "01") * -1)

Return(nRet)