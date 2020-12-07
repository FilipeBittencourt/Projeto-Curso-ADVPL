#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------------|
| Função: | BIAFR003											  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 18/11/14											  |
|-----------------------------------------------------------------|
| Desc.:	| Rotina para impressao do relatorio de controle      |
| 				| de remessa p/demonstração e conserto e seus     |
| 				| respectivos retornos.      					  |
| 				| Utilizado para identificar o saldo do produto   |
| 				| enviado para conserto ou o saldo do produto  	  |
| 				| recebido como demonstração					  |
|-----------------------------------------------------------------|
| OS:			|	1747-12 - Usuário: Fabiana Aparecida Corona	  |
| OS:			|	1743-14 - Usuário: Tania de Fatima Monico	  |
| OS:			|	2138-12 - Usuário: Antonio Marcio   		  |
|-----------------------------------------------------------------|
*/

User Function BIAFR003()

	Local oReport
	Private oParam := TParBIAFR003():New()

	If oParam:Box()

		oReport := ReportDef()
		oReport:PrintDialog()

	EndIf

Return()

Static Function ReportDef()

	Local oReport
	Local oSecPrd
	Local oSecMov
	Local cQry := GetNextAlias()
	Local cTitRel := "Tipo de Operação: "+ oParam:cTipOpeFis + "-" + AllTrim(Capital(Posicione("Z52", 1, xFilial("Z52") + oParam:cTipOpeFis, "Z52_DESC")))+; 
	" - " + SubStr(oParam:cOrdem, 5, Len(oParam:cOrdem))

	oReport := TReport():New("BIAFR003", cTitRel, {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry)}, cTitRel)

	oSecPrd := TRSection():New(oReport, "Produtos", cQry)
	TRCell():New(oSecPrd, "B1_COD", cQry)
	TRCell():New(oSecPrd, "B1_DESC", cQry)

	oSecMov := TRSection():New(oSecPrd, "Movimentos", cQry)
	TRCell():New(oSecMov, "TIPO", cQry, "Tipo Mov.",,10)
	TRCell():New(oSecMov, "D1_DTDIGIT", cQry,,,,,{|| sToD((cQry)->D1_DTDIGIT) })
	TRCell():New(oSecMov, "D1_EMISSAO", cQry,,,,,{|| sToD((cQry)->D1_EMISSAO) })
	TRCell():New(oSecMov, "D1_DOC", cQry)
	TRCell():New(oSecMov, "D1_SERIE", cQry)
	TRCell():New(oSecMov, "D1_FORNECE", cQry, "Cli/For")
	TRCell():New(oSecMov, "D1_LOJA", cQry)
	TRCell():New(oSecMov, "D1_CF", cQry)	
	TRCell():New(oSecMov, "D1_QUANT", cQry,,,,,{|| fGetVal((cQry)->TIPO, (cQry)->D1_QUANT) })
	TRCell():New(oSecMov, "D1_VUNIT", cQry,,,,,{|| fGetVal((cQry)->TIPO, (cQry)->D1_VUNIT) })
	TRCell():New(oSecMov, "D1_TOTAL", cQry,,,,,{|| fGetVal((cQry)->TIPO, (cQry)->D1_TOTAL) })

	oBreak := TRBreak():New(oSecPrd, oSecPrd:Cell("B1_COD"))//, "Totais")

	oTot := TRFunction():New(oSecMov:Cell("D1_QUANT"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)
	oTot:SetTotalInLine(.F.)

	TRFunction():New(oSecMov:Cell("D1_VUNIT"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)
	TRFunction():New(oSecMov:Cell("D1_TOTAL"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)	

Return(oReport)

Static Function PrintReport(oReport, cQry)

	Local oSecPrd := oReport:Section(1)
	Local oSecMov := oReport:Section(1):Section(1)
	Local cSQL := ""
	Local cSD1 := RetSqlName("SD1")
	Local cSD2 := RetSqlName("SD2")

	cSQL := " SELECT 'ENTRADA' AS TIPO, D1_DTDIGIT, D1_EMISSAO, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_CF, B1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL "
	cSQL += " FROM Z53010 Z53 "

	cSQL += " INNER JOIN "+ cSD1 + " SD1 "
	cSQL += " ON (Z53_CFOP = D1_CF "
	cSQL += " AND Z53_TIPMOV = 'E' "
	cSQL += " AND Z53_IDOPFI = "+ ValToSQL(oParam:cTipOpeFis)
	cSQL += " AND (Z53_TES = D1_TES OR Z53_TES = '') "
	cSQL += " AND Z53.D_E_L_E_T_ = '' "
	cSQL += " AND D1_FILIAL = "+ ValToSQL(cFilAnt)
	cSQL += " AND D1_DTDIGIT BETWEEN "+ ValToSQL(oParam:dDatDe) +" AND "+ ValToSQL(oParam:dDatAte)	
	cSQL += " AND D1_COD BETWEEN "+ ValToSQL(oParam:cPrdDe) +" AND "+ ValToSQL(oParam:cPrdAte)
	cSQL += " AND D1_FORNECE BETWEEN "+ ValToSQL(oParam:cCliFDe) +" AND "+ ValToSQL(oParam:cCliFAte)
	cSQL += " AND SD1.D_E_L_E_T_ = '') "	

	cSQL += " INNER JOIN SB1010 SB1 "
	cSQL += " ON (D1_COD = B1_COD "
	cSQL += " AND SB1.D_E_L_E_T_ = '') "

	cSQL += " UNION ALL

	cSQL += " SELECT 'SAIDA' AS TIPO, D2_DTDIGIT, D2_EMISSAO, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_CF, B1_COD, B1_DESC, D2_QUANT, D2_PRCVEN, D2_TOTAL
	cSQL += " FROM Z53010 Z53 "

	cSQL += " INNER JOIN "+ cSD2 + " SD2 "
	cSQL += " ON (Z53_CFOP = D2_CF "
	cSQL += " AND Z53_TIPMOV = 'S' "
	cSQL += " AND Z53_IDOPFI = "+ ValToSQL(oParam:cTipOpeFis)
	cSQL += " AND (Z53_TES = D2_TES OR Z53_TES = '') "
	cSQL += " AND Z53.D_E_L_E_T_ = '' "	
	cSQL += " AND D2_FILIAL = "+ ValToSQL(cFilAnt)
	cSQL += " AND D2_EMISSAO BETWEEN "+ ValToSQL(oParam:dDatDe) +" AND "+ ValToSQL(oParam:dDatAte)
	cSQL += " AND D2_COD BETWEEN "+ ValToSQL(oParam:cPrdDe) +" AND "+ ValToSQL(oParam:cPrdAte)	
	cSQL += " AND D2_CLIENTE BETWEEN "+ ValToSQL(oParam:cCliFDe) +" AND "+ ValToSQL(oParam:cCliFAte)
	cSQL += " AND SD2.D_E_L_E_T_ = '')"

	cSQL += " INNER JOIN SB1010 SB1 "
	cSQL += " ON (D2_COD = B1_COD "
	cSQL += " AND SB1.D_E_L_E_T_ = '') "

	cSQL += " ORDER BY B1_COD, TIPO "+ If (SubStr(oParam:cOrdem, 1, 1) == "1", "ASC", "DESC") +", D1_DTDIGIT, D1_EMISSAO "

	TcQuery cSQL New Alias (cQry)

	oSecMov:SetParentQuery()
	oSecMov:SetParentFilter({|cParam| (cQry)->B1_COD >= cParam .And. (cQry)->B1_COD <= cParam}, {|| (cQry)->B1_COD})

	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)

	oSecPrd:Print()

	(cQry)->(DbCloseArea())

Return()


Static Function fGetVal(cTipo, nVal)

	If (SubStr(oParam:cOrdem, 1, 1) == "1" .And. AllTrim(cTipo) == "SAIDA") .Or. (SubStr(oParam:cOrdem, 1, 1) == "2" .And. AllTrim(cTipo) == "ENTRADA")
		nVal := nVal * (-1)
	EndIf

Return(nVal)
