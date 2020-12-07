#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TConciliacaoContabilIntercompany
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Contabil - Intercompany 
@obs Projeto: A-54
@type class
/*/

Class TConciliacaoContabilIntercompany From LongClassName 

	Data oParam
	
	Method New() Constructor
	Method Export()
	Method GetSalFor(dData, cEmpOri, cEmpDes)
	Method GetSalCli(dData, cEmpOri, cEmpDes)	

EndClass


Method New(oParam) Class TConciliacaoContabilIntercompany

	Default oParam := Nil

	::oParam := oParam
	
Return()


Method Export() Class TConciliacaoContabilIntercompany
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAF166-" + cEmpAnt + __cUserID + "-" + dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWorkCli := "Cliente"
Local cWorkFor := "Fornecedor"
Local cWorkDif := "Dif Cliente x Forn"
Local cTableCli := "Conciliacao Contabil Intercompany - " + cWorkCli + " - " + dToC(::oParam:dData)
Local cTableFor := "Conciliacao Contabil Intercompany - " + cWorkFor + " - " + dToC(::oParam:dData)
Local cTableDif := "Conciliacao Contabil Intercompany - " + cWorkDif + " - " + dToC(::oParam:dData)
Local cDirTmp := AllTrim(GetTempPath())
Local aSaldoCli := {}
Local aSaldoFor := {}

  oFWExcel := FWMsExcel():New()
	
	// Cliente  	
	oFWExcel:AddWorkSheet(cWorkCli)
	oFWExcel:AddTable(cWorkCli, cTableCli)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "Nome", 1, 1)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "BG", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "IN", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "JK", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "LM", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "ST", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "MU", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "VI", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkCli, cTableCli, "TE", 3, 2, .F.)
	
	nSaldoBI := 0
	nSaldoIN := ::GetSalCli(::oParam:dData, "01", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "01", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "01", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "01", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "01", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "01", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "01", "16")
  
  aAdd(aSaldoCli, {"Biancogres", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  
	oFWExcel:AddRow(cWorkCli, cTableCli, {"Biancogres", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	nSaldoBI := ::GetSalCli(::oParam:dData, "05", "01")
	nSaldoIN := 0
	nSaldoJK := ::GetSalCli(::oParam:dData, "05", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "05", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "05", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "05", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "05", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "05", "16")
  	
	aAdd(aSaldoCli, {"Incesa", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"Incesa", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalCli(::oParam:dData, "06", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "06", "05")
	nSaldoJK := 0
	nSaldoLM := ::GetSalCli(::oParam:dData, "06", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "06", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "06", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "06", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "06", "16")
  
  aAdd(aSaldoCli, {"JK", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})	
	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"JK", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalCli(::oParam:dData, "07", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "07", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "07", "06")
	nSaldoLM := 0
	nSaldoST := ::GetSalCli(::oParam:dData, "07", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "07", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "07", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "07", "16")
  	
	aAdd(aSaldoCli, {"LM", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"LM", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	nSaldoBI := ::GetSalCli(::oParam:dData, "12", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "12", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "12", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "12", "07")
	nSaldoST := 0
	nSaldoMU := ::GetSalCli(::oParam:dData, "12", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "12", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "12", "16")
  	
	aAdd(aSaldoCli, {"ST Gestao", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"ST Gestao", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalCli(::oParam:dData, "13", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "13", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "13", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "13", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "13", "12")
	nSaldoMU := 0
	nSaldoVI := ::GetSalCli(::oParam:dData, "13", "14")
	nSaldoTE := ::GetSalCli(::oParam:dData, "13", "16")
  	
	aAdd(aSaldoCli, {"Mundi", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"Mundi", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	nSaldoBI := ::GetSalCli(::oParam:dData, "14", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "14", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "14", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "14", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "14", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "14", "13")
	nSaldoVI := 0
	nSaldoTE := ::GetSalCli(::oParam:dData, "14", "16")

	aAdd(aSaldoCli, {"Vitcer", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"Vitcer", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalCli(::oParam:dData, "16", "01")
	nSaldoIN := ::GetSalCli(::oParam:dData, "16", "05")
	nSaldoJK := ::GetSalCli(::oParam:dData, "16", "06")
	nSaldoLM := ::GetSalCli(::oParam:dData, "16", "07")
	nSaldoST := ::GetSalCli(::oParam:dData, "16", "12")
	nSaldoMU := ::GetSalCli(::oParam:dData, "16", "13")
	nSaldoVI := ::GetSalCli(::oParam:dData, "16", "14")
	nSaldoTE := 0
  
 	aAdd(aSaldoCli, {"Terlac", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
 	 	
	oFWExcel:AddRow(cWorkCli, cTableCli, {"Terlac", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	// Fornecedor
	oFWExcel:AddWorkSheet(cWorkFor)
	oFWExcel:AddTable(cWorkFor, cTableFor)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "Nome", 1, 1)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "BG", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "IN", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "JK", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "LM", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "ST", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "MU", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "VI", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkFor, cTableFor, "TE", 3, 2, .F.)
    
	nSaldoBI := 0
	nSaldoIN := ::GetSalFor(::oParam:dData, "01", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "01", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "01", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "01", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "01", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "01", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "01", "16")
 
	aAdd(aSaldoFor, {"Biancogres", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"Biancogres", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	nSaldoBI := ::GetSalFor(::oParam:dData, "05", "01")
	nSaldoIN := 0
	nSaldoJK := ::GetSalFor(::oParam:dData, "05", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "05", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "05", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "05", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "05", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "05", "16")
  	
	aAdd(aSaldoFor, {"Incesa", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	oFWExcel:AddRow(cWorkFor, cTableFor, {"Incesa", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalFor(::oParam:dData, "06", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "06", "05")
	nSaldoJK := 0
	nSaldoLM := ::GetSalFor(::oParam:dData, "06", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "06", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "06", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "06", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "06", "16")
  	
	aAdd(aSaldoFor, {"JK", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	oFWExcel:AddRow(cWorkFor, cTableFor, {"JK", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalFor(::oParam:dData, "07", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "07", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "07", "06")
	nSaldoLM := 0
	nSaldoST := ::GetSalFor(::oParam:dData, "07", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "07", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "07", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "07", "16")

	aAdd(aSaldoFor, {"LM", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"LM", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})

	nSaldoBI := ::GetSalFor(::oParam:dData, "12", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "12", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "12", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "12", "07")
	nSaldoST := 0
	nSaldoMU := ::GetSalFor(::oParam:dData, "12", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "12", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "12", "16")

	aAdd(aSaldoFor, {"ST Gestao", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"ST Gestao", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalFor(::oParam:dData, "13", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "13", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "13", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "13", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "13", "12")
	nSaldoMU := 0
	nSaldoVI := ::GetSalFor(::oParam:dData, "13", "14")
	nSaldoTE := ::GetSalFor(::oParam:dData, "13", "16")

	aAdd(aSaldoFor, {"Mundi", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"Mundi", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})				 

	nSaldoBI := ::GetSalFor(::oParam:dData, "14", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "14", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "14", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "14", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "14", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "14", "13")
	nSaldoVI := 0
	nSaldoTE := ::GetSalFor(::oParam:dData, "14", "16")

	aAdd(aSaldoFor, {"Vitcer", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"Vitcer", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	nSaldoBI := ::GetSalFor(::oParam:dData, "16", "01")
	nSaldoIN := ::GetSalFor(::oParam:dData, "16", "05")
	nSaldoJK := ::GetSalFor(::oParam:dData, "16", "06")
	nSaldoLM := ::GetSalFor(::oParam:dData, "16", "07")
	nSaldoST := ::GetSalFor(::oParam:dData, "16", "12")
	nSaldoMU := ::GetSalFor(::oParam:dData, "16", "13")
	nSaldoVI := ::GetSalFor(::oParam:dData, "16", "14")
	nSaldoTE := 0

	aAdd(aSaldoFor, {"Terlac", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
  	
	oFWExcel:AddRow(cWorkFor, cTableFor, {"Terlac", nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})
	
	// Diferenças
	oFWExcel:AddWorkSheet(cWorkDif)
	oFWExcel:AddTable(cWorkDif, cTableDif)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "Nome", 1, 1)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "BG", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "IN", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "JK", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "LM", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "ST", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "MU", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "VI", 3, 2, .F.)
	oFWExcel:AddColumn(cWorkDif, cTableDif, "TE", 3, 2, .F.)
	
	For nCount := 1 To Len(aSaldoCli)
	
		nSaldoBI := aSaldoCli[nCount, 2] - aSaldoFor[1, nCount + 1]
		nSaldoIN := aSaldoCli[nCount, 3] - aSaldoFor[2, nCount + 1]
		nSaldoJK := aSaldoCli[nCount, 4] - aSaldoFor[3, nCount + 1]
		nSaldoLM := aSaldoCli[nCount, 5] - aSaldoFor[4, nCount + 1]
		nSaldoST := aSaldoCli[nCount, 6] - aSaldoFor[5, nCount + 1]
		nSaldoMU := aSaldoCli[nCount, 7] - aSaldoFor[6, nCount + 1]
		nSaldoVI := aSaldoCli[nCount, 8] - aSaldoFor[7, nCount + 1]
		nSaldoTE := aSaldoCli[nCount, 9] - aSaldoFor[8, nCount + 1]
		
		oFWExcel:AddRow(cWorkDif, cTableDif, {aSaldoCli[nCount, 1], nSaldoBI, nSaldoIN, nSaldoJK, nSaldoLM, nSaldoST, nSaldoMU, nSaldoVI, nSaldoTE})		
	
	Next


	aEmp := {}
	nCount := 0
	
	aAdd(aEmp, {"01", "BG"})
	aAdd(aEmp, {"05", "IN"})
	aAdd(aEmp, {"06", "JK"})
	aAdd(aEmp, {"07", "LM"})
	aAdd(aEmp, {"12", "ST"})
	aAdd(aEmp, {"13", "MU"})
	aAdd(aEmp, {"14", "VI"})
	aAdd(aEmp, {"16", "TE"})
	
	// Contas a Receber
	For nCount := 1 To Len(aEmp)
		
		cWork := "CR-" + aEmp[nCount, 2]
		cTable := "Contas a Receber" 

		oFWExcel:AddWorkSheet(cWork)
		oFWExcel:AddTable(cWork, cTable)
		oFWExcel:AddColumn(cWork, cTable, "Prefixo", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Numero", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Parcela", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Tipo", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Cliente", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Loja", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Nome", 1, 1)				
		oFWExcel:AddColumn(cWork, cTable, "Emissao", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Vencimento", 1, 1)												
		oFWExcel:AddColumn(cWork, cTable, "Valor", 3, 2, .F.)
		oFWExcel:AddColumn(cWork, cTable, "Valor Recebido", 3, 2, .F.)
		oFWExcel:AddColumn(cWork, cTable, "Saldo", 3, 2, .F.)	
		
		cSQL := ""
		cQry := GetNextAlias()

		cSQL := " SELECT * "
		cSQL += " FROM FNC_CR_AN_INTERCOMPANY("+ ValToSQL(::oParam:dData) + ", "+ ValToSQL(aEmp[nCount, 1]) +")"
		cSQL += " WHERE SALDO > 0 "
		cSQL += " ORDER BY EMISSAO "
		
		TcQuery cSQL New Alias (cQry)
		
		While !(cQry)->(Eof())
	
			oFWExcel:AddRow(cWork, cTable, {(cQry)->PREFIXO, (cQry)->NUM, (cQry)->PARCELA, (cQry)->TIPO, (cQry)->CLIENTE, (cQry)->LOJA, (cQry)->NOME,; 
																			dToC(sToD((cQry)->EMISSAO)), dToC(sToD((cQry)->VENCIMENTO)), (cQry)->VALOR, (cQry)->VALOR_RECEBIDO, (cQry)->SALDO})
		  (cQry)->(DbSkip())

		EndDo()			
		
		(cQry)->(DbCloseArea())
		
	Next
	
	// Contas a Pagar
	For nCount := 1 To Len(aEmp)
		
		cWork := "CP-" + aEmp[nCount, 2]
		cTable := "Contas a Pagar" 

		oFWExcel:AddWorkSheet(cWork)
		oFWExcel:AddTable(cWork, cTable)
		oFWExcel:AddColumn(cWork, cTable, "Prefixo", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Numero", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Parcela", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Tipo", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Fornecedor", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Loja", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Nome", 1, 1)				
		oFWExcel:AddColumn(cWork, cTable, "Emissao", 1, 1)
		oFWExcel:AddColumn(cWork, cTable, "Vencimento", 1, 1)												
		oFWExcel:AddColumn(cWork, cTable, "Valor", 3, 2, .F.)
		oFWExcel:AddColumn(cWork, cTable, "Valor Pago", 3, 2, .F.)
		oFWExcel:AddColumn(cWork, cTable, "Saldo", 3, 2, .F.)	
		
		cSQL := ""
		cQry := GetNextAlias()

		cSQL := " SELECT * "
		cSQL += " FROM FNC_CP_AN_INTERCOMPANY("+ ValToSQL(::oParam:dData) + ", "+ ValToSQL(aEmp[nCount, 1]) +")"
		cSQL += " WHERE SALDO > 0 "
		cSQL += " ORDER BY EMISSAO "
		
		TcQuery cSQL New Alias (cQry)
		
		While !(cQry)->(Eof())
	
			oFWExcel:AddRow(cWork, cTable, {(cQry)->PREFIXO, (cQry)->NUM, (cQry)->PARCELA, (cQry)->TIPO, (cQry)->FORNECE, (cQry)->LOJA, (cQry)->NOME,; 
																			dToC(sToD((cQry)->EMISSAO)), dToC(sToD((cQry)->VENCIMENTO)), (cQry)->VALOR, (cQry)->VALOR_PAGO, (cQry)->SALDO})
		  (cQry)->(DbSkip())

		EndDo()			
		
		(cQry)->(DbCloseArea())
		
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
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif
	
	RestArea(aArea)
		
Return()

Method GetSalFor(dData, cEmpOri, cEmpDes) Class TConciliacaoContabilIntercompany
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ROUND(SUM(SALDO),2) AS SALDO "
	cSQL += " FROM FNC_CP_INTERCOMPANY("+ ValToSQL(dData) + ", "+ ValToSQL(cEmpOri) +", "+ ValToSQL(cEmpDes) +")"
	cSQL += " WHERE SALDO > 0 "
	
	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->SALDO)
	
		nRet := (cQry)->SALDO
		
	EndIf

	(cQry)->(DbCloseArea())
		
Return(nRet)


Method GetSalCli(dData, cEmpOri, cEmpDes) Class TConciliacaoContabilIntercompany
Local nRet := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ROUND(SUM(SALDO),2) AS SALDO "
	cSQL += " FROM FNC_CR_INTERCOMPANY("+ ValToSQL(dData) + ", "+ ValToSQL(cEmpOri) +", "+ ValToSQL(cEmpDes) +")"
	cSQL += " WHERE SALDO > 0 "
	
	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->SALDO)
	
		nRet := (cQry)->SALDO
		
	EndIf

	(cQry)->(DbCloseArea())
		
Return(nRet)