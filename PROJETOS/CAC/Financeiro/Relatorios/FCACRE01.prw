#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"

/*
##############################################################################################################
# PROGRAMA...: AT410GRV         
# AUTOR......: Gabriel Rossi Mafioletti (FACILE SISTEMAS)
# DATA.......: 08/04/2015                      
# DESCRICAO..: Relatório de Rentabilidade
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function FCACRE01()

	Private _cNomRel := "FCACRE01"
	Private _cTitRel := "Relatório de Rentabilidade"
	
	AjustaSX1(_cNomRel)
	oReport := ReportDef()
	oReport :PrintDialog()
Return Nil

Static Function ReportDef()
	
	oReport := TReport():New(_cNomRel, _cTitRel, _cNomRel, {|oReport| ReportPrint(oReport)}, _cTitRel)
	oReport:SetPortrait() // Retrato 
	//oReport:SetLandscape() // Paisagem
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(40)
	oReport:SetColSpace(1)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	//oReport:cFontBody := "Arial"
	oReport:nFontBody := 4
	oReport:lBold := .F.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.
	
	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Notas", {"SD2"}) // Titulos
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1, "D2_DOC"	  	,, "Nota Saida"		,,      17, .F.)
	TRCell():New(oSection1, "D2_EMISSAO"	,, "Emissão NF"		,,      15, .F.)
	TRCell():New(oSection1, "NOMCLI"   		,, "Nome Cliente"	,,  	40, .F.)
	TRCell():New(oSection1, "D2_TOTAL"  	,, "VENDA",,  20, , , "RIGHT",, "RIGHT")
	TRCell():New(oSection1, "D1_TOTAL"  	,, "CUSTO",,  20, , , "RIGHT",, "RIGHT")
	
	oSection1:SetNoFilter({"SD2"})

	// Total Geral
	TRFunction():New(oSection1:Cell("D2_TOTAL"), "Total Geral VENDA", "SUM", , , "@E 999,999,999.99", , .F., .T.)
	TRFunction():New(oSection1:Cell("D1_TOTAL"), "Total Geral CUSTO", "SUM", , , "@E 999,999,999.99", , .F., .T.)
Return(oReport)

Static Function ReportPrint(oReport)
	Local _cALias	:=	GetNextAlias()
	Local _cSelect	:=	""
	oSection1 := oReport:Section(1)

	BeginSql Alias _cAlias
		%NoParser%
	
		EXEC STPCAC_CALCULA_RENTABILIDADE %Exp:MV_PAR3%,%Exp:MV_PAR04%,%Exp:MV_PAR01%,%Exp:MV_PAR02%
	
	EndSql
	
	TcQuery _cSelect Alias _cALias New
	

	
	If !(_cALias)->(EoF())
        While !(_cALias)->(EoF())
			oSection1:Init()

			oSection1:Cell("D2_DOC"):SetValue((_cAlias)->DOC)
			oSection1:Cell("D2_EMISSAO"):SetValue(DTOC(STOD((_cAlias)->EMISSAO)))
			oSection1:Cell("NOMCLI"):SetValue(AllTrim((_cAlias)->NOMCLI))
			oSection1:Cell("D2_TOTAL"):SetValue((_cAlias)->TOTVEN)		
			oSection1:Cell("D1_TOTAL"):SetValue((_cAlias)->TOTCUS)      
		
			oSection1:PrintLine()

			(_cAlias)->(DbSkip())
		
		EndDo
		(_cAlias)->(DbCloseArea())

		// Terminando Secao
		oSection1:Finish()
	EndIf
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Emissao   De:         ", "", "", "mv_ch1", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Emissao  Ate:         ", "", "", "mv_ch2", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "03", "Cliente   De:         ", "", "", "mv_ch3", "C", 6, 00, 0, "G", ""          , "SA1" ,"", " ", "mv_par03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Cliente  Ate:         ", "", "", "mv_ch4", "C", 6, 00, 0, "G", "NaoVazio()", "SA1" ,"", " ", "mv_par04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------