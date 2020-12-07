#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "REPORT.CH"

User Function FCLA0029; Return()

/*
|-----------------------------------------------------------|
| Classe: | BIAFR005																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 03/11/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para impressao da pagina de parametros   |
| 				| em relatorios do tipo TReport  								  |
| 				| Utilizada quando os parametros sao criados      |
| 				| atraves da funcao padrao ParamBox.				      |
| 				| Exemplo de utilizacao nos programas: BIAFR004 e |
| 				| TParBIAFR004																		|
|-----------------------------------------------------------|
*/

Class TRParamBoxPage From TRParamPage

	Data oParamBox
	DATA nSize

	Method New()
	Method Print()
	Method PrintFilter()

EndClass


Method New(oParent, oParamBox) Class TRParamBoxPage
	Local cSvAlias := Alias()

	::cClassName := "TRParamBoxPage"

	_Super:New(oParent)

	::nSize := 40
	::oParent := oParent
	::oReport := oParent
	::uParam := oParamBox:cName
	::oParamBox := oParamBox
	::nLineCount := 0

	::SetHeaderSection(.F.)
	::SetPageBreak(.F.)

	If !Empty(cSvAlias)
		DbSelectArea(cSvAlias)
	EndIf

	DEFINE CELL NAME "PERGUNTA" OF Self TITLE "" SIZE ::nSize
	DEFINE CELL NAME "MV_VAR" OF Self TITLE "" SIZE 50 ALIGN LEFT LINE BREAK AUTO SIZE

	::Cell("PERGUNTA"):cFontBody := "Arial"
	::Cell("PERGUNTA"):nFontBody := 9
	::Cell("PERGUNTA"):oFontBody := oParent:oFontHeader
	::Cell("MV_VAR"):oFontBody := oParent:oFontHeader

Return (Self)


Method Print() Class TRParamBoxPage
	Local nCount
	Local cSvAlias
	Local nLineHeight := ::oReport:nLineHeight

	cSvAlias := Alias()

	// Geração em excel não imprime parametros  
	If ::oReport:nDevice <> 4

		::oReport:SetLineHeight(40)
		::oReport:SkipLine()
		::oReport:FatLine(5)
		::oReport:SkipLine()
		::oReport:lPrtParamPage := .T.
		::oReport:oPage:SetPageDiff(.F.)

		::Cell("PERGUNTA"):SetSize(30)
		::Cell("MV_VAR"):SetValue(50)

		::oParamBox:Update()

		For nCount := 1 To Len(::oParamBox:aParam)

			::Cell("PERGUNTA"):SetValue("Pergunta " + StrZero(nCount, 2, 0) +": "+ ::oParamBox:aParam[nCount, 2] + "?")
			::Cell("MV_VAR"):SetValue(::oParamBox:aParam[nCount, 3])

			::PrintLine(,.T.)

		Next

		If ::oReport:lUserFilter
			::PrintFilter()
		EndIf

		::oReport:SkipLine()
		::oReport:FatLine(4)
		::oReport:SetLineHeight(nLineHeight)
		::oReport:lPrtParamPage := .F.
		::oReport:oPage:SetPageDiff()

	EndIf

	If !Empty(cSvAlias)
		DbSelectArea(cSvAlias)
	EndIf

	::Disable()

Return()


Method PrintFilter() Class TRParamBoxPage
	Local ni
	Local nj
	Local lPrintAsk := .T.
	Local oObj

	For ni := 1 To Len(::oReport:aSection)

		oObj := ::oReport:aSection[ni]

		For nj := 1 To Len(oObj:aUserFilter)

			If !Empty(oObj:aUserFilter[nj,3])

				If lPrintAsk
					::Cell("PERGUNTA"):SetValue("Filtro de Usuário")
					lPrintAsk := .F.
				Else
					::Cell("PERGUNTA"):Hide()
				EndIf

				::Cell("MV_VAR"):SetValue(oObj:aUserFilter[nj,3])
				::PrintLine(,.T.)

			EndIf

		Next nj

	Next ni

	::Cell("PERGUNTA"):Show()

Return()