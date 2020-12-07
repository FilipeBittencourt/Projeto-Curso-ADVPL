#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

// Indices do array de dados do arquivo
#DEFINE IDX_CLVL 1
#DEFINE IDX_ITEM 2
#DEFINE IDX_SUBITEM 3
#DEFINE IDX_DESCRICAO 4


Class TImportSubitemContrato From LongClassName

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
	Method VldFile()
	Method GetHeader()
	Method GetFieldValue()
	Method ImportFile(oProcess)
	Method UpdateItem(cClvl, cItem, cSubitem, cDesc)
	Method UpdateSubitem(cCodRef, cSubitem, cDesc)
	Method fGetNum()
	
EndClass


Method New() Class TImportSubitemContrato
	
	::cFile := ""
	::nHandle := -1
	::cLine := ""	
 
  ::cHeader := "CLVL/ITEM/SUBITEM/DESC/"
  ::cFileHeader := ""
  ::aValue := {}
	::aFile := {}
			
Return()


Method OpenFile(cFile) Class TImportSubitemContrato
Local lRet := .T.
	
	If (::nHandle := FT_FUse(AllTrim(cFile))) == -1		
		
		lRet := .F.
		
		::aValue := {}

	Else
		::cFile := cFile
	EndIf
	
Return(lRet)


Method VldFile(cFile) Class TImportSubitemContrato
Local lRet := .F.

	If ::OpenFile(cFile)
	
		lRet := .T.
		 
		::GetHeader()
		
		If ::VldHeader()				
			
			::GetFieldValue()
			
		Else
			::aValue := {}
			MsgStop("Estrutura do arquivo incorreta, cabeçalho não identificado!")
		EndIf
		
	Else
		MsgStop("Erro ao abririr o arquivo: " + cFile)		
	EndIf
	
Return(lRet)


Method VldHeader() Class TImportSubitemContrato
Local lRet := .T.
	
	If ::cHeader <> AllTrim(::cFileHeader)
		lRet := .F.	
	EndIf
		
Return(lRet)


Method GetHeader() Class TImportSubitemContrato
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


Method GetFieldValue() Class TImportSubitemContrato
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


Method ImportFile(oProcess) Class TImportSubitemContrato
Local nCount := 1
Local cClvl := ""
Local cItem := ""
Local cSubitem := ""
Local cDesc := ""
	
	oProcess:SetRegua1(Len(::aValue))

	oProcess:SetRegua2(Len(::aValue))
	
	BEGIN TRANSACTION
	
		While nCount <= Len(::aValue)
			
			oProcess:IncRegua1("Atualizando Subitem..." )
			
			oProcess:IncRegua2("Clvl: " + ::aValue[nCount, IDX_CLVL] + " - Item: " + ::aValue[nCount, IDX_ITEM])
						
			cClvl := AllTrim(::aValue[nCount, IDX_CLVL])
			cItem := AllTrim(::aValue[nCount, IDX_ITEM])
			cSubitem := AllTrim(::aValue[nCount, IDX_SUBITEM])
			cDesc := AllTrim(::aValue[nCount, IDX_DESCRICAO])

			::UpdateItem(cClvl, cItem, cSubitem, cDesc)
			
			cClvl := ""
			cItem := ""
			cSubitem := ""
			cDesc := ""
			
			nCount++
			
		EndDo
		
	END TRANSACTION
	
Return()


Method UpdateItem(cClvl, cItem, cSubitem, cDesc) Class TImportSubitemContrato
Local lInsert := .T.
Local cCodRef := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	If !Empty(cClvl) .And. !Empty(cItem) .And. !Empty(cSubitem) .And. !Empty(cDesc)
	
		cSQL := " SELECT ISNULL(ZMA_CODIGO, '') AS ZMA_CODIGO "
		cSQL += " FROM "+ RetSQLName("ZMA")
		cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA")) 
		cSQL += " AND ZMA_CLVL = " + ValToSQL(cClvl)
		cSQL += " AND ZMA_ITEMCT = " + ValToSQL(cItem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->ZMA_CODIGO)
		
		If lInsert

			RecLock("ZMA", lInsert)			
			
				cCodRef := ::fGetNum()
	
				ZMA->ZMA_FILIAL := xFilial("ZMA")
				ZMA->ZMA_CODIGO := cCodRef
				ZMA->ZMA_CLVL := cClvl
				ZMA->ZMA_ITEMCT := cItem
				
			ZMA->(MsUnLock())
		
		Else
				
			cCodRef := (cQry)->ZMA_CODIGO
				 
		EndIf
	
		::UpdateSubitem(cCodRef, cSubitem, cDesc)
					
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()


Method UpdateSubitem(cCodRef, cSubitem, cDesc) Class TImportSubitemContrato
Local lInsert := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	If !Empty(cCodRef) .And. !Empty(cSubitem) .And. !Empty(cDesc)
	
		cSQL := " SELECT R_E_C_N_O_ AS RECNO "
		cSQL += " FROM "+ RetSQLName("ZMB")
		cSQL += " WHERE ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB")) 
		cSQL += " AND ZMB_CODREF = " + ValToSQL(cCodRef)
		cSQL += " AND ZMB_SUBITE = " + ValToSQL(cSubitem)
		cSQL += " AND D_E_L_E_T_ = '' "
		
		TcQuery cSQL New Alias (cQry)
		
		lInsert := Empty((cQry)->RECNO)
		
		If !lInsert
			
			ZMB->(DbGoTo((cQry)->RECNO))
			
		EndIf
		
		RecLock("ZMB", lInsert)
		
			ZMB->ZMB_FILIAL := xFilial("ZMB")
			ZMB->ZMB_CODREF := cCodRef
			ZMB->ZMB_SUBITE := cSubitem
			ZMB->ZMB_DESC := cDesc

		ZMB->(MsUnLock())
						
		(cQry)->(DbCloseArea())
		
	EndIf
	
Return()


Method fGetNum() Class TImportSubitemContrato
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT MAX(ZMA_CODIGO) AS ZMA_CODIGO
	cSQL += " FROM ZMA010
	cSQL += " WHERE D_E_L_E_T_ = ''	
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := Soma1((cQry)->ZMA_CODIGO)
	
	(cQry)->(DbCloseArea())	

Return(cRet)