#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

// Indices do array de dados do arquivo
#DEFINE IDX_CLVL 1
#DEFINE IDX_ITEM 2
#DEFINE IDX_DOLAR 3
#DEFINE IDX_LIBRA 4
#DEFINE IDX_EURO 5
#DEFINE IDX_SUBITEM 6
#DEFINE IDX_UNIDADE 7
#DEFINE IDX_QUANTIDADE 8
#DEFINE IDX_MOEDA 9
#DEFINE IDX_VALOR 10
#DEFINE IDX_TOTAL 11
#DEFINE IDX_ENCERRADO 12


Class TImportOrcamentoClvl From LongClassName

	Data cFile
	Data nHandle
	Data cLine
	Data cHeader
	Data cFileHeader
	Data aValue
	Data aFile
	
	Method New() Constructor
	Method OpenFile()
	Method VldHeader()
	Method VldData()
	Method VldFile()
	Method GetHeader()
	Method GetFieldValue()
	Method ImportFile(oProcess)
	Method UpdateItem(cClvl, cItem, nDolar, nLibra, nEuro, cSubitem, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer)
	Method UpdateSubitem(cCodRef, cSubitem, cDesc, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer)
	
EndClass


Method New() Class TImportOrcamentoClvl
	
	::cFile := ""
	::nHandle := -1
	::cLine := ""	
 
  ::cHeader := "CLVL/ITEM/DOLAR/LIBRA/EURO/SUBITEM/UNIDADE/QUANTIDADE/MOEDA/VALOR/TOTAL/ENCERRADO/"
  ::cFileHeader := ""
  ::aValue := {}
	::aFile := {}
			
Return()


Method OpenFile(cFile) Class TImportOrcamentoClvl
Local lRet := .T.
	
	If (::nHandle := FT_FUse(AllTrim(cFile))) == -1		
		
		lRet := .F.
		
		::aValue := {}

	Else
		::cFile := cFile
	EndIf
	
Return(lRet)


Method VldFile(cFile) Class TImportOrcamentoClvl
Local lRet := .F.

	If ::OpenFile(cFile)
	
		lRet := .T.
		 
		::GetHeader()
		
		If ::VldHeader()
			
			//If ::VldData()
			
				::GetFieldValue()
			
			//Else
			
				//::aValue := {}
			
			//EndIf
			
		Else
			
			::aValue := {}
			
			MsgStop("Estrutura do arquivo incorreta, cabeçalho não identificado!")
			
		EndIf
		
	Else
		
		MsgStop("Erro ao abririr o arquivo: " + cFile)
				
	EndIf
	
Return(lRet)


Method VldHeader() Class TImportOrcamentoClvl
Local lRet := .T.
	
	If ::cHeader <> AllTrim(::cFileHeader)
		
		lRet := .F.
			
	EndIf
		
Return(lRet)


Method VldData() Class TImportOrcamentoClvl
Local lRet := .T.
Local nCount := 1
Local cQry := ""
Local cQryItem := GetNextAlias()
Local cQrySubitem := GetNextAlias()

	::GetFieldValue()
	
	While nCount <= Len(::aValue) .And. lRet
	
		cClvl := AllTrim(::aValue[nCount, IDX_CLVL])
		cItem := AllTrim(::aValue[nCount, IDX_ITEM])
		nDolar := Val(AllTrim(::aValue[nCount, IDX_DOLAR]))
		nLibra := Val(AllTrim(::aValue[nCount, IDX_LIBRA]))
		nEuro := Val(AllTrim(::aValue[nCount, IDX_EURO]))
		cSubitem := AllTrim(::aValue[nCount, IDX_SUBITEM])
		cUnidade := AllTrim(::aValue[nCount, IDX_UNIDADE])
		nQuant := Val(AllTrim(::aValue[nCount, IDX_QUANTIDADE]))
		cMoeda := AllTrim(::aValue[nCount, IDX_MOEDA])
		nValor := Val(AllTrim(::aValue[nCount, IDX_VALOR]))
		nTotal := Val(AllTrim(::aValue[nCount, IDX_TOTAL]))
		cEncer := AllTrim(::aValue[nCount, IDX_ENCERRADO])	
							
		If !Empty(cClvl) .And. !Empty(cItem) .And. !Empty(cSubitem)
			
			cSQL := " SELECT ISNULL(ZMA_CODIGO, '') AS ZMA_CODIGO "
			cSQL += " FROM "+ RetSQLName("ZMA")
			cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA")) 
			cSQL += " AND ZMA_CLVL = " + ValToSQL(cClvl)
			cSQL += " AND ZMA_ITEMCT = " + ValToSQL(cItem)
			cSQL += " AND D_E_L_E_T_ = '' "
			
			TcQuery cSQL New Alias (cQryItem)
			
			If !Empty((cQryItem)->ZMA_CODIGO)
			
					cSQL := " SELECT R_E_C_N_O_ AS RECNO "
					cSQL += " FROM "+ RetSQLName("ZMB")
					cSQL += " WHERE ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB")) 
					cSQL += " AND ZMB_CODREF = " + ValToSQL((cQryItem)->ZMA_CODIGO)
					cSQL += " AND ZMB_SUBITE = " + ValToSQL(cSubitem)
					cSQL += " AND D_E_L_E_T_ = '' "
					
					TcQuery cSQL New Alias (cQrySubitem)
					
					If Empty((cQrySubitem)->RECNO)
						
						lRet := .F.
						
						MsgStop("Subitem: "+ cSubitem +" não cadastrado na tabela de Subitens" + Chr(13) +; 
										"Linha: " + cValToChar(nCount))
					
					EndIf
					
					(cQrySubitem)->(DbCloseArea())
			
			Else

				lRet := .F.
				
				MsgStop("Classe de Valor: "+ cClvl  +" e ou Item: "+ cItem +" não cadastrados na tabela de Subitens" + Chr(13) +; 
								"Linha: " + cValToChar(nCount))
								
			EndIf
			
			(cQryItem)->(DbCloseArea())
			
		Else
		
			lRet := .F.
			
			MsgStop("Classe de Valor e ou Item não informado(s)" + Chr(13) +; 
							"Linha: " + cValToChar(nCount))

		EndIf

		nCount++
		
	EndDo

Return(lRet)


Method GetHeader() Class TImportOrcamentoClvl
Local cToken := ""
Local nAt := 0
	
	FT_FGOTOP()
	
	::cLine := FT_FREADLN()

	::cFileHeader := ""
				
	FT_FSKIP()

	nAt	:= 1
	
	While nAt > 0
		
		nAt	:= AT(Chr(59), ::cLine)
		
		If nAt == 0
			
			cToken := ::cLine
			
		Else	
			
			cToken := Substr(::cLine, 1, nAt-1)
			
		EndIf
		
		::cFileHeader += cToken + If (nAt <> 0, "/", "")
		
		::cLine := Substr(::cLine, nAt+1)
		
	EndDo

Return()


Method GetFieldValue() Class TImportOrcamentoClvl
Local nCount := 0
Local cValue := ""
Local aAux := {}

	::aValue := {}

	While(!FT_FEOF())
		
		::cLine := FT_FREADLN()
		::cLine := StrTran(::cLine, ".", "") 
		::cLine := StrTran(::cLine, ",", ".")
		
		If Len(::cLine) > 0
		
			::cLine := AllTrim(::cLine+Chr(59))
			
			For nCount := 1 To Len(::cLine)
			
				If Subst(::cLine, nCount,1) <> Chr(59)
					
					cValue := cValue + Subst(::cLine, nCount, 1)
					
				Else
					
					aAdd(aAux, cValue)
										
					cValue := ""
					
				EndIf
				
			Next nCount
			
		EndIf
		
		aAdd(aAux, Space(1))
		
		aAdd(::aValue, aAux)
		
		cValue := ""
		aAux := {}
		
		FT_FSKIP()
		
	EndDo		
			
Return(::aValue)


Method ImportFile(oProcess) Class TImportOrcamentoClvl
Local nCount := 1
Local cClvl := ""
Local cItem := ""
Local nDolar := 0
Local nLibra := 0
Local nEuro := 0
Local cSubitem := ""
Local cUnidade := ""
Local nQuant := ""
Local cMoeda := ""
Local nValor := 0
Local nTotal := 0
Local cEncer := ""
	
	oProcess:SetRegua1(Len(::aValue))

	oProcess:SetRegua2(Len(::aValue))
	
	BEGIN TRANSACTION
	
		While nCount <= Len(::aValue)
			
			oProcess:IncRegua1("Atualizando Orçamento..." )
			
			oProcess:IncRegua2("Clvl: " + ::aValue[nCount, IDX_CLVL] + " - Item: " + ::aValue[nCount, IDX_ITEM])
						
			cClvl := AllTrim(::aValue[nCount, IDX_CLVL])
			cItem := AllTrim(::aValue[nCount, IDX_ITEM])
			nDolar := Val(AllTrim(::aValue[nCount, IDX_DOLAR]))
			nLibra := Val(AllTrim(::aValue[nCount, IDX_LIBRA]))
			nEuro := Val(AllTrim(::aValue[nCount, IDX_EURO]))
			cSubitem := AllTrim(::aValue[nCount, IDX_SUBITEM])
			cUnidade := AllTrim(::aValue[nCount, IDX_UNIDADE])
			nQuant := Val(AllTrim(::aValue[nCount, IDX_QUANTIDADE]))
			cMoeda := AllTrim(::aValue[nCount, IDX_MOEDA])
			nValor := Val(AllTrim(::aValue[nCount, IDX_VALOR]))
			nTotal := Val(AllTrim(::aValue[nCount, IDX_TOTAL])) // Efetuar o Calculo
			cEncer := AllTrim(::aValue[nCount, IDX_ENCERRADO])

			::UpdateItem(cClvl, cItem, nDolar, nLibra, nEuro, cSubitem, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer)
						
			nCount++
			
		EndDo
		
	END TRANSACTION
	
Return()


Method UpdateItem(cClvl, cItem, nDolar, nLibra, nEuro, cSubitem, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer) Class TImportOrcamentoClvl
Local lInsert := .T.
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local oObj := TSubitemProjeto():New()

	If !Empty(cClvl) .And. !Empty(cItem) .And. !Empty(cSubitem)
	
		cSQL := " SELECT ISNULL(ZMC_CODIGO, '') AS ZMC_CODIGO "
		cSQL += " FROM "+ RetSQLName("ZMC")
		cSQL += " WHERE ZMC_FILIAL = "+ ValToSQL(xFilial("ZMC")) 
		cSQL += " AND ZMC_CLVL = " + ValToSQL(cClvl)
		cSQL += " AND ZMC_ITEMCT = " + ValToSQL(cItem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->ZMC_CODIGO)
		
		If lInsert

			cCodRef := U_NumZMC()
			
			RecLock("ZMC", lInsert)
	
				ZMC->ZMC_FILIAL := xFilial("ZMC")
				ZMC->ZMC_CODIGO := cCodRef
				ZMC->ZMC_CLVL := cClvl
				ZMC->ZMC_ITEMCT := cItem
				ZMC->ZMC_DOLAR := nDolar
				ZMC->ZMC_LIBRA := nLibra
				ZMC->ZMC_EURO := nEuro
				
			ZMC->(MsUnLock())
		
		Else
				
			cCodRef := (cQry)->ZMC_CODIGO
				 
		EndIf
		
		oObj:cClvl := cClvl 
		oObj:cItemCta := cItem
		oObj:cSubitem := cSubitem
		
		cDesc := oObj:GetDesc() 
	
		::UpdateSubitem(cCodRef, cSubitem, cDesc, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer)
					
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()


Method UpdateSubitem(cCodRef, cSubitem, cDesc, cUnidade, nQuant, cMoeda, nValor, nTotal, cEncer) Class TImportOrcamentoClvl
Local lInsert := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	If !Empty(cCodRef) .And. !Empty(cSubitem)
	
		cSQL := " SELECT R_E_C_N_O_ AS RECNO "
		cSQL += " FROM "+ RetSQLName("ZMD")
		cSQL += " WHERE ZMD_FILIAL = "+ ValToSQL(xFilial("ZMD")) 
		cSQL += " AND ZMD_CODREF = " + ValToSQL(cCodRef)
		cSQL += " AND ZMD_SUBITE = " + ValToSQL(cSubitem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->RECNO)
		
		If !lInsert
			
			ZMD->(DbGoTo((cQry)->RECNO))
			
		EndIf
		
		RecLock("ZMD", lInsert)
		
			ZMD->ZMD_FILIAL := xFilial("ZMD")
			ZMD->ZMD_CODREF := cCodRef
			ZMD->ZMD_SUBITE := cSubitem
			ZMD->ZMD_DESC := cDesc
			ZMD->ZMD_UNIDAD := cUnidade
			ZMD->ZMD_QUANT := nQuant
			ZMD->ZMD_MOEDA := cMoeda
			ZMD->ZMD_VALOR := nValor
			ZMD->ZMD_TOTAL := nTotal
			ZMD->ZMD_CPENC := cEncer

		ZMD->(MsUnLock())
						
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()