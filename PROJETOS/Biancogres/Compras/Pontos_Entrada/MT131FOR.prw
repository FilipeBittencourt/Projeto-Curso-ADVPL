#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT131FOR
@author Tiago Rossini Coradini
@since 013/04/2018
@version 1.0
@description Ponto de entrada permite manipular os fornecedores envolvidos no processo de cotação de compra
@obs Ticket: 3737
@type Function
/*/

User Function MT131FOR()
Local aFornec := ParamIxb[1]
Local aUltCom := {}
Local nNumFor := MV_PAR01
Local nUltCom := MV_PAR02
Local cEmp_A := ""
Local cNom_A := ""
Local cEmp_B := ""
Local cNom_B := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local nCount := 1
Local nPosFor := 0
		
	If nUltCom > 0
	
		If cEmpAnt == "01"
		
			cEmp_A := RetFullName("SD1", "05")
			cNom_A := "INCESA"
			
			cEmp_B := RetFullName("SD1", "14")
			cNom_B := "VITCER"
		
		ElseIf cEmpAnt == "05" 
		
			cEmp_A := RetFullName("SD1", "01")
			cNom_A := "BIANCOGRES"
			
			cEmp_B := RetFullName("SD1", "14")
			cNom_B := "VITCER"
			
		ElseIf cEmpAnt == "14" 
		
			cEmp_A := RetFullName("SD1", "01")
			cNom_A := "BIANCOGRES"
			
			cEmp_B := RetFullName("SD1", "05")
			cNom_B := "INCESA"
			
		EndIf
		
		cSQL := " SELECT * "
		cSQL += " FROM ( "
		cSQL += " 	SELECT TOP "+ cValToChar(nUltCom) + Space(1) + ValToSQL(cNom_A) + " AS EMPRESA, D1_FORNECE, D1_LOJA, D1_EMISSAO "
		cSQL += " 	FROM " + cEmp_A
		cSQL += " 	WHERE D1_FILIAL = " + ValToSQL(xFilial("SD1"))
		cSQL += " 	AND D1_COD = " + ValToSQL(SC1->C1_PRODUTO)
		cSQL += " 	AND D1_TIPO = 'N' "
		cSQL += "   AND D1_CUSTO > 0 "
		cSQL += "		AND D_E_L_E_T_ = '' "
		cSQL += "		ORDER BY D1_EMISSAO DESC "
		cSQL += "	) AS NFS_" + cValToChar(cEmp_A)
		
		cSQL += " UNION ALL "
		
		cSQL += " SELECT * "
		cSQL += " FROM ( "
		cSQL += " 	SELECT TOP "+ cValToChar(nUltCom) + Space(1) + ValToSQL(cNom_B) + " AS EMPRESA, D1_FORNECE, D1_LOJA, D1_EMISSAO "
		cSQL += " 	FROM " + cEmp_B
		cSQL += " 	WHERE D1_FILIAL = " + ValToSQL(xFilial("SD1"))
		cSQL += " 	AND D1_COD = " + ValToSQL(SC1->C1_PRODUTO)
		cSQL += " 	AND D1_TIPO = 'N' "
		cSQL += "   AND D1_CUSTO > 0 "
		cSQL += "		AND D_E_L_E_T_ = '' "
		cSQL += "		ORDER BY D1_EMISSAO DESC "
		cSQL += "	) AS NFS_" + cValToChar(cEmp_B)
		cSQL += "	ORDER BY D1_EMISSAO DESC "
		
		TcQuery cSQL New Alias (cQry)
		
		While !(cQry)->(Eof()) 
				
			If aScan(aUltCom, {|x| x[1] == (cQry)->D1_FORNECE .And. x[2] == (cQry)->D1_LOJA }) == 0
									
				aAdd(aUltCom, {(cQry)->D1_FORNECE, (cQry)->D1_LOJA, AllTrim("Ultima Compra: " + DtoC(StoD((cQry)->D1_EMISSAO)) + " - " + (cQry)->EMPRESA)})
			
			EndIf
			
			(cQry)->(DbSkip())
		
		EndDo()
	
		
		While nCount <= Len(aUltCom) .And. Len(aFornec) < nNumFor
			
			nPosFor := aScan(aFornec, {|x| x[1] == aUltCom[nCount][1] .And. x[2] == aUltCom[nCount][2]})
			
			If nPosFor == 0
				
				DbSelectArea("SA2")
				DbSetOrder(1)
				
				If SA2->(MsSeek(xFilial("SA2") + aUltCom[nCount][1] + aUltCom[nCount][2]))
				     //Retira fornecedores bloqueados
				 	IF SA2->A2_MSBLQL != "1"
				 		aAdd(aFornec, {aUltCom[nCount][1], aUltCom[nCount][2], aUltCom[nCount][3], "SA2", SA2->(Recno())})
					EndIf
				EndIf
			
			Else
					
				aFornec[nPosFor][3] := aUltCom[nCount][3]
								
			EndIf
			
			nCount++
			
		EndDo()
		
	EndIf

Return(aFornec)