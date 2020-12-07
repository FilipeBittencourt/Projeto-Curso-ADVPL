#INCLUDE "TOTVS.CH"

User Function FCLA0009; Return()

/*
|------------------------------------------------------------|
| Classe:	| TImportNCM													 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 08/12/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Função para inportação da planilha de compras    |
| 				| referente a atualização do NCM dos produtos  		 |
|------------------------------------------------------------|
*/


// Indices do array de dados do arquivo
#DEFINE IDX_PRODUTO 1
#DEFINE IDX_NCM 2
#DEFINE IDX_DESCRICAO 3


Class TImportNCM From LongClassName

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
	Method UpdatePrd()
	
EndClass


Method New() Class TImportNCM
	
	::cFile := ""
	::nHandle := -1
	::cLine := ""	
 
  ::cHeader := "Cód. Prod./Cód.  NCM"
  ::cFileHeader := ""
  ::aValue := {}
	::aFile := {}
			
Return()


Method OpenFile(cFile) Class TImportNCM
Local lRet := .T.
	
	If (::nHandle := FT_FUse(AllTrim(cFile))) == -1		
		
		lRet := .F.
		
		::aValue := {}

	Else
		::cFile := cFile
	EndIf
	
Return(lRet)


Method VldFile(cFile) Class TImportNCM
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


Method VldHeader() Class TImportNCM
Local lRet := .F.
	
	If ::cHeader $ AllTrim(::cFileHeader)
		lRet := .T.	
	EndIf
		
Return(lRet)


Method GetHeader() Class TImportNCM
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


Method GetFieldValue() Class TImportNCM
Local nCount := 0
Local cValue := ""
Local aAux := {}
Local nCount := 1

	::aValue := {}

	While (!FT_FEOF())
		
		::cLine := FT_FREADLN()
		::cLine := StrTran(::cLine, ".", "") 
		::cLine := StrTran(::cLine, ",", ".")
		
		If Len(::cLine) > 0
		
			::cLine := AllTrim(::cLine+Chr(59))
			
			While nCount <= Len(::cLine) .And. Len(aAux) < 2
			
				If Subst(::cLine, nCount,1) <> Chr(59)
					
					cValue := cValue + Subst(::cLine, nCount, 1)
					
				Else
					
					aAdd(aAux, cValue)
										
					cValue := ""
					
				EndIf
				
				nCount++
				
			EndDo
			
		EndIf																			
		
		aAux[IDX_NCM] := AllTrim((aAux[IDX_NCM]))
		
		aAdd(aAux, "")
		
		aAux[IDX_DESCRICAO] := Posicione("SB1", 1, xFilial("SB1") + (aAux[IDX_PRODUTO]), "B1_DESC")
		
		If Empty(aAux[IDX_DESCRICAO])
			aAux[IDX_DESCRICAO] := "Produto não encontrado"
		EndIf
		
		aAdd(::aValue, aAux)
		
		cValue := ""
		aAux := {}
		nCount := 1
		
		FT_FSKIP()
		
	EndDo		
			
Return(::aValue)


Method ImportFile(oProcess) Class TImportNCM
Local nCount := 1
Local cCodPrd := ""
Local cTipCot := ""
	
	oProcess:SetRegua1(Len(::aValue))

	oProcess:SetRegua2(Len(::aValue))
		
	BEGIN TRANSACTION
	
		While nCount <= Len(::aValue)
			
			oProcess:IncRegua1("Atualizando produtos..." )
			
			oProcess:IncRegua2("Produto: " + ::aValue[nCount, IDX_PRODUTO])
						
			
			cCodPrd := ::aValue[nCount, IDX_PRODUTO]
			
			cNCM := ::aValue[nCount, IDX_NCM]
				
			::UpdatePrd(cCodPrd, cNCM)
			
			cCodPrd := ""
			cNCM := ""
			
			nCount++
			
		EndDo
		
	END TRANSACTION
	
Return()


Method UpdatePrd(cCodPrd, cNCM) Class TImportNCM

	If !Empty(cCodPrd) .And. !Empty(cNCM)
	
		DbSelectArea("SB1")
		DbSetOrder(1)
		If SB1->(DbSeek(xFilial("SB1") + cCodPrd))
			
			RecLock("SB1", .F.)
				SB1->B1_POSIPI := cNCM
			SB1->(MsUnlock())
						
		EndIf
		
	EndIf

Return()