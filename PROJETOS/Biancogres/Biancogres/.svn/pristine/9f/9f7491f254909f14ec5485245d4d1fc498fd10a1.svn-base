#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF039
@author Tiago Rossini Coradini
@since 04/07/2016
@version 1.0
@description Replicação da tabela de preços entre as empresas
@obs OS: 4470-15 - Claudeir Fadini
@type function
/*/


// Indices do array de campos
#DEFINE nFName 1
#DEFINE nFValue 2

User Function BIAF039()  
	
	Local aPergs   	:= {}
    Local aRet	   	:= {}
    Local cNomeEmp 	:= ""
    Local aListaEmp	:= ListEmp()
    
    Private cCodTab 	:= ""
	Private cEmpDes		:= ""
	
	aAdd( aPergs ,{2, "Cod. Emp. Destino", "", aListaEmp, 40, "",.T.})
    
    If ParamBox(aPergs, "Codigo da Empresa Destino", aRet)
    	cEmpDes := mv_par01
    	If MsgYesNo("Deseja realmente replicar a tabela de preço: " + DA0->DA0_CODTAB +"-"+ AllTrim(DA0->DA0_DESCRI), "Replicação de Tabela de Preços")

    		MsgRun("Replicando Tabela de Preço...", "Aguarde!", {|| fExecute() })
			
			cNomeEmp := POSICIONE('SM0', 1, cEmpDes, 'M0_NOME')
			MsgInfo("A tabela de preço: " + cCodTab +"-"+ AllTrim(DA0->DA0_DESCRI) + " foi criada com sucesso na empresa "+AllTrim(cNomeEmp)+" com o código: "+cCodTab+".", "Replicação de Tabela de Preços")
			
		EndIf
    	
    EndIf
    	
Return()

Static Function ListEmp()

	Local nI		:= 0 
	Local aRet 		:= {}
	Local aListaEmp	:= {'01', '05', '07'}
	
	For nI := 1 To Len(aListaEmp) 
		If (aListaEmp[nI] <> cEmpAnt)
			aAdd(aRet, aListaEmp[nI])
		EndIf
	Next nI 
	
Return aRet

Static Function fExecute()

	Local aArea			:= GetArea()
	Local cDA0			:= GetNextAlias()
	Local cDA1			:= GetNextAlias()
	Local cAccMod		:= ""
	Local aField		:= {}
	Local nFCount		:= 0
	Local cFName		:= ""
	
	If cEmpAnt $ "01/05"
		
		BeginTran()		
		
			// Verifica se a tabela DA0 esta aberta
			If Select(cDA0) > 0		
				(cDA0)->(DbCloseArea())		
			EndIf
					
			// Abre a tabea DA0 na empesa cEmpDes
			EmpOpenFile(cDA0, "DA0", 1, .T., cEmpDes, @cAccMod)
			
			// Retorna campos para replica
			aField := fGetField("DA0")
			
			// Retorna numero sequencial da tabela
			cCodTab := fGetCodTab()					
	
			RecLock(cDA0, .T.)
			
				For nFCount := 1 To (cDA0)->(FCount())
	
					cFName := (cDA0)->(FieldName(nFCount))
	
					If "CODTAB" $ cFName
	
						(cDA0)->DA0_CODTAB := cCodTab
	
					ElseIf "FILIAL" $ cFName
					
						If cEmpDes == "07"
							(cDA0)->DA0_FILIAL := "01"
						Else
							(cDA0)->DA0_FILIAL := "  "
						EndIf
														
					Else
	
						// Verifica se os campos estão na mesma ordem
						If cFName == aField[nFCount, nFName]
	
							(cDA0)->(FieldPut(nFCount, aField[nFCount, nFValue]))
	
						Else
	
							// Procura campo no array de campos
							nFPos := aScan(aField, {|x| x[nFName] == cFName })
	
							// Caso o campo exista, grava o valor
							If nFPos > 0
	
								(cDA0)->(FieldPut(nFCount, aField[nFPos, nFValue]))
	
							EndIf
	
						EndIf
	
					EndIf
	
				Next
							
			(cDA0)->(MsUnlock())
			
			If Select(cDA0) > 0		
				(cDA0)->(DbCloseArea())
			EndIf
			
			//Fim DA0
			
			// Verifica se a tabela DA1 esta aberta
			If Select(cDA1) > 0		
				(cDA1)->(DbCloseArea())		
			EndIf			

			// Abre a tabela DA1 na empesa cEmpDes
			EmpOpenFile(cDA1, "DA1", 1, .T., cEmpDes, @cAccMod)
			
			// Loop na tabela de itens da tabela de preco
			DbSelectarea("DA1")
			DbSetOrder(1)
			If DA1->(DbSeek(xFilial("DA1") + DA0->DA0_CODTAB))
						
				While !DA1->(Eof()) .And. DA1->DA1_CODTAB == DA0->DA0_CODTAB 
				
					// Retorna campos para replica
					aField := fGetField("DA1")										
			
					RecLock(cDA1, .T.)
					
						For nFCount := 1 To (cDA1)->(FCount())
			
							cFName := (cDA1)->(FieldName(nFCount))
		
							If "CODTAB" $ cFName
			
								(cDA1)->DA1_CODTAB := cCodTab
			
							ElseIf "FILIAL" $ cFName
												
								If cEmpDes == "07"
									(cDA1)->DA1_FILIAL := "01"
								Else
									(cDA1)->DA1_FILIAL := "  "
								EndIf
								
							Else
			
								// Verifica se os campos estão na mesma ordem
								If cFName == aField[nFCount, nFName]
			
									(cDA1)->(FieldPut(nFCount, aField[nFCount, nFValue]))
			
								Else
			
									// Procura campo no array de campos
									nFPos := aScan(aField, {|x| x[nFName] == cFName })
			
									// Caso o campo exista, grava o valor
									If nFPos > 0
			
										(cDA1)->(FieldPut(nFCount, aField[nFPos, nFValue]))
			
									EndIf
			
								EndIf
			
							EndIf
			
						Next
									
					(cDA1)->(MsUnlock())
				
					DA1->(DbSkip())
				
				EndDo()
			
			EndIf
			
			If Select(cDA1) > 0		
				(cDA1)->(DbCloseArea())		
			EndIf
		
		EndTran()
		
		
		TcRefresh(cDA0)
		
		TcRefresh(cDA1)
				
	Else		
		MsgStop("Operação permitida somente nas empreas Biancogres e Incesa", "Replicação de Tabela de Preços")	
	EndIf

	RestArea(aArea)
	
Return()


Static Function fGetField(cTable)
	Local nFCount := 0
	Local aField := {}
	Local cFName := ""

	For nFCount := 1 To (cTable)->(FCount())

		cFName := (cTable)->(FieldName(nFCount))

		aAdd(aField, {cFName, (cTable)->(FieldGet(FieldPos(cFName))) })

	Next

Return(aField)


Static Function fGetCodTab()
	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()


	cSQL := " SELECT MAX(DA0_CODTAB) AS DA0_CODTAB "
	cSQL += " FROM DA0"+cEmpDes+"0 "
	cSQL += " WHERE D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := Soma1((cQry)->DA0_CODTAB) 
	
	(cQry)->(DbCloseArea())

Return(cRet)