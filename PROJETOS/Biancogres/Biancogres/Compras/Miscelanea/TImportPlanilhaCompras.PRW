#INCLUDE "TOTVS.CH"

User Function FCLA0002; Return()

/*
|------------------------------------------------------------|
| Classe:	| TImportPlanilhaCompras													 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 10/09/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Classe para inportação da planilha de compras,   |
| 				| referente a classificação dos produtos: A, B, C	 |
| 				| campo: B1_YTPCOT 				 				 								 |
|------------------------------------------------------------|
*/


// Indices do array de dados do arquivo
#DEFINE IDX_PRODUTO 1
#DEFINE IDX_DESCRICAO 2
#DEFINE IDX_ESPECIFICO 3
#DEFINE IDX_CONTRATO 4
#DEFINE IDX_COTACAO 5


Class TImportPlanilhaCompras From LongClassName

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


Method New() Class TImportPlanilhaCompras
	
	::cFile := ""
	::nHandle := -1
	::cLine := ""	
 
  ::cHeader := "CODIGOS/ESPECIFICOS/CONTRATOS/COTACOES/"
  ::cFileHeader := ""
  ::aValue := {}
	::aFile := {}
			
Return()


Method OpenFile(cFile) Class TImportPlanilhaCompras
Local lRet := .T.
	
	If (::nHandle := FT_FUse(AllTrim(cFile))) == -1		
		
		lRet := .F.
		
		::aValue := {}

	Else
		::cFile := cFile
	EndIf
	
Return(lRet)


Method VldFile(cFile) Class TImportPlanilhaCompras
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


Method VldHeader() Class TImportPlanilhaCompras
Local lRet := .T.
	
	If ::cHeader <> AllTrim(::cFileHeader)
		lRet := .F.	
	EndIf
		
Return(lRet)


Method GetHeader() Class TImportPlanilhaCompras
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


Method GetFieldValue() Class TImportPlanilhaCompras
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
					
					If Len(aAux) == 1
						aAdd(aAux, "")
					EndIf
					
					cValue := ""
					
				EndIf
				
			Next nCount
			
		EndIf
																	
		aAux[IDX_DESCRICAO] := Posicione("SB1", 1, xFilial("SB1") + (aAux[IDX_PRODUTO]), "B1_DESC")
		
		If Empty(aAux[IDX_DESCRICAO])
			aAux[IDX_DESCRICAO] := "Produto não encontrado"
		EndIf 
		
		aAux[IDX_ESPECIFICO] := If (Upper(aAux[IDX_ESPECIFICO]) == "X", "Sim", "Não")
		aAux[IDX_CONTRATO] := If (Upper(aAux[IDX_CONTRATO]) == "X", "Sim", "Não")
		aAux[IDX_COTACAO] := If (Upper(aAux[IDX_COTACAO]) == "X", "Sim", "Não")		
		
		aAdd(aAux, Space(1))
		
		aAdd(::aValue, aAux)
		
		cValue := ""
		aAux := {}
		
		FT_FSKIP()
		
	EndDo		
			
Return(::aValue)


Method ImportFile(oProcess) Class TImportPlanilhaCompras
Local nCount := 1
Local cCodPrd := ""
Local cTipCot := ""
	
	oProcess:SetRegua1(Len(::aValue))

	oProcess:SetRegua2(Len(::aValue))
	
	
	BEGIN TRANSACTION
	
		While nCount <= Len(::aValue)
			
			oProcess:IncRegua1("Atualizando produtos..." )
			
			oProcess:IncRegua2("Produto: " + ::aValue[nCount, IDX_PRODUTO])//+ " - Descrição: " + ::aValue[nCount, IDX_DESCRICAO] )
						
			
			cCodPrd := ::aValue[nCount, IDX_PRODUTO]
			
			If ::aValue[nCount, IDX_ESPECIFICO] == "Sim"			
				cTipCot := "A"			
			ElseIf ::aValue[nCount, IDX_CONTRATO] == "Sim"				
				cTipCot := "B"				
			ElseIf ::aValue[nCount, IDX_COTACAO] == "Sim"			  
				cTipCot := "C"		
			EndIf
				
			::UpdatePrd(cCodPrd, cTipCot)
			
			cCodPrd := ""
			cTipCot := ""
			
			nCount++
			
		EndDo
		
	END TRANSACTION
	
Return()


Method UpdatePrd(cCodPrd, cTipCot) Class TImportPlanilhaCompras

	If !Empty(cCodPrd) .And. !Empty(cTipCot)
	
		DbSelectArea("SB1")
		DbSetOrder(1)
		If SB1->(DbSeek(xFilial("SB1") + cCodPrd))
			
			RecLock("SB1", .F.)
				SB1->B1_YTPCOT := cTipCot
			SB1->(MsUnlock())
						
		EndIf
		
	EndIf

Return()