#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAFR004																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 26/11/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Rotina para impressao do relatorio de controle  |
| 				| de compra de pisos 														  |
|-----------------------------------------------------------|
| OS:			|	0384-14 - Usuário: Francine Araujo							|
|-----------------------------------------------------------|
*/

User Function BIAFR004()
Local oReport
Private oParam := TParBIAFR004():New()

	If oParam:Box()
		
		MsgInfo("Atenção, para a correta emissão do relatório, a folha deverá estar fechada e o mesmo deverá ser emitido no ultimo dia do mês!")
		
		oReport := ReportDef()
		oReport:PrintDialog()
		
	EndIf

Return()


Static Function ReportDef()
Local oReport 
Local oSecFun
Local cQry := GetNextAlias()
Local cTitRel := "Controle de Baixa de Prestações - Compra de Revestimento Cerâmico"

	oReport := TReport():New("BIAFR004", cTitRel, {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry)}, cTitRel)
	
	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)
	
	// Aumenta o tamanho da fonte do corpo de relatorio
	oReport:nFontBody := 10
	
	// Imprime cabecalho customizado da secao
	oReport:OnPageBreak({|| fPrintHeader(oReport, oSecFun) })
	
	
	oSecFun := TRSection():New(oReport, "Funcionário", cQry)
	
	// Desabilita impressao padrao do cabecalho da secao
	oSecFun:lHeaderPage := .T.
	
	// Aumenta o espaco entre as linhas - Salto de linha
	oSecFun:OnPrintLine({|| oReport:SkipLine() })
	
	
	TRCell():New(oSecFun, "RA_CLVL", cQry, "CV")
	TRCell():New(oSecFun, "RK_MAT", cQry, "Matricula",, 25)
	TRCell():New(oSecFun, "RA_NOME", cQry, "Colaborador",, 70,, {|| AllTrim((cQry)->RA_NOME) })
	TRCell():New(oSecFun, "RK_VALORTO", cQry,,, 25)
	TRCell():New(oSecFun, "PARCELA", cQry, "Parcelas",, 25)
	TRCell():New(oSecFun, "RK_VALORPA", cQry, "Desc. Mês",, 30)
	
	// Tiago Rossini --  Não estava zerando o saldo pendente quando era a ultima parcela  -- OS: 0632-15 - Leticia Vieira
	//TRCell():New(oSecFun, "RK_VLRPAGO", cQry, "Saldo Pend",, 30,, {|| If (Ceiling((cQry)->RK_VLRPAGO) <= 1, (cQry)->RK_VALORPA, (cQry)->RK_VLRPAGO) })
	TRCell():New(oSecFun, "RK_VLRPAGO", cQry, "Saldo Pend",, 30,, {|| If (Left(AllTrim((cQry)->PARCELA), 1) == Right(AllTrim((cQry)->PARCELA), 1), 0, If (Ceiling((cQry)->RK_VLRPAGO) <= 1, (cQry)->RK_VALORPA, (cQry)->RK_VLRPAGO)) })
	
	TRCell():New(oSecFun, "RK_YNFISCA", cQry,,, 25)
	TRCell():New(oSecFun, "TEXTO1", cQry, "Dt Baixa Con",, 30)
	TRCell():New(oSecFun, "TEXTO2", cQry, "Cred/Cob - VISTO",, 45)
	
	oBreak := TRBreak():New(oSecFun, {|| .T. })//, "Totais")
	
	oTot := TRFunction():New(oSecFun:Cell("RK_VALORTO"), Nil, "SUM", oBreak, Nil, Nil, Nil, .F., .F.)
	oTot:SetTotalInLine(.F.)
	
	TRFunction():New(oSecFun:Cell("RK_VALORPA"), Nil, "SUM", oBreak, Nil, Nil, Nil, .F., .F.)
	TRFunction():New(oSecFun:Cell("RK_VLRPAGO"), Nil, "SUM", oBreak, Nil, Nil, Nil, .F., .F.)	

Return(oReport)


Static Function PrintReport(oReport, cQry)
Local oSecFun := oReport:Section(1)
Local cSQL := ""
Local cSRA := RetSqlName("SRA")
Local cSRK := RetSqlName("SRK")
Local cRCH := RetSqlName("RCH")

	cSQL := " SELECT RA_CLVL, RK_MAT, RA_NOME, RK_VALORTO, "
	
	cSQL += " CONVERT(VARCHAR(8), "
	cSQL += " CASE "
	cSQL += " 	WHEN RA_DEMISSA <> '' THEN 'RECISÃO' " //09/03/2016 - Luana Marin Ribeiro - OS 3029-15 (Cláudia Cardoso)
	cSQL += " 	WHEN RK_PARCPAG + 1 = 1 AND RK_DTVENC > CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)), 112) THEN '0 de ' + CONVERT(VARCHAR(8), RK_PARCELA) "
	cSQL += " 	ELSE CONVERT(VARCHAR(8), RK_PARCPAG + 1) + ' de '+ CONVERT(VARCHAR(8), RK_PARCELA) "
	cSQL += " END) AS PARCELA, "
	
	cSQL += " CASE "
	cSQL += " 	WHEN RA_DEMISSA <> '' THEN (RK_VALORTO - RK_VLRPAGO) " //09/03/2016 - Luana Marin Ribeiro - OS 3029-15 (Cláudia Cardoso)
	cSQL += " 	WHEN RK_PARCPAG + 1 = 1 AND RK_DTVENC > CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)), 112) THEN 0 "
	cSQL += " 	ELSE RK_VALORPA "
	cSQL += " END AS RK_VALORPA, "
	
	cSQL += " CASE "
	cSQL += " 	WHEN RA_DEMISSA <> '' THEN 0 " //09/03/2016 - Luana Marin Ribeiro - OS 3029-15 (Cláudia Cardoso)
	cSQL += " 	WHEN RK_PARCPAG + 1 = 1 AND RK_DTVENC > CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)), 112) THEN RK_VALORTO "
	cSQL += " 	ELSE (RK_VALORTO - (RK_VLRPAGO + RK_VALORPA)) "
	cSQL += " END AS RK_VLRPAGO, "
	
	cSQL += " RK_YNFISCA, '______________' AS TEXTO1, '______________________________' AS TEXTO2 "
	cSQL += " FROM "+ cSRK +" SRK "
	cSQL += " INNER JOIN "+ cSRA +" SRA "
	cSQL += " ON (RK_FILIAL = RA_FILIAL "
	cSQL += " AND RK_MAT = RA_MAT "
	cSQL += " AND RK_PD = '430' "
	cSQL += " AND RK_PARCELA > RK_PARCPAG "
	cSQL += " AND RK_MAT BETWEEN "+ ValToSQL(oParam:cMatDe) +" AND "+ ValToSQL(oParam:cMatAte)
	cSQL += " AND (RA_DEMISSA = '' OR RA_DEMISSA >= CONVERT(VARCHAR(8), DATEADD(DAY, - (DAY(GETDATE()) -1), GETDATE()), 112)) "
	
	// Tiago Rossini Coradini - OS: 0007-16 - Claudia Mara
	//cSQL += " AND RK_DTVENC <= CONVERT(VARCHAR(8), GETDATE(), 112) "
	
	// Tiago Rossini Coradini - OS: 1323-16 - Railane Maria - Ajuste no perido de filtro do relatorio
	//cSQL += " AND RK_DTVENC BETWEEN (SELECT CONVERT(VARCHAR(8), DATEADD(DAY, - (DAY(GETDATE())- 1), GETDATE()), 112)) AND (SELECT CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)), 112)) "
	
	// Marcelo Sousa Corrêa - OS: 8705-18 - Bruna Benvindo - Ajuste no filtro para tratar o período em que o lançamento está incluído
	cSQL += " AND RK_DTVENC BETWEEN (SELECT CONVERT(VARCHAR(8), DATEADD(DAY, - (DAY(GETDATE())- 1), GETDATE()), 112)) AND (SELECT RCH_DTPAGO FROM "+ cRCH +" RCH WHERE RCH_ROTEIR IN ('FOL','FER')  AND RCH_DTINI = (SELECT CONVERT(VARCHAR(8), DATEADD(DAY, - (DAY(GETDATE())- 1), GETDATE()), 112)) AND RCH_DTFIM = (SELECT CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)), 112)) GROUP BY RCH_DTPAGO) "
	
	
	cSQL += " AND SRK.D_E_L_E_T_ = '' "
	cSQL += " AND SRA.D_E_L_E_T_ = '') "
	cSQL += " ORDER BY RA_NOME, RK_DTVENC "
	
	TcQuery cSQL New Alias (cQry)
	
	// Altera configuracoes da fonte do cabecalho do relatorio
	oReport:oFontHeader:Bold := .T.
	oReport:oFontHeader:nHeight := -12
	
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)
	
	oSecFun:Print()
	
	(cQry)->(DbCloseArea())
	
Return()


// Imprime cabecalho customizado da secao
Static Function fPrintHeader(oReport, oSecFun)

	oReport:SkipLine()
	oReport:FatLine()
	oReport:SkipLine()
	
	oSecFun:PrintHeader()
	
	oReport:SkipLine()
	oReport:FatLine()
	
	oReport:SkipLine()
	
Return()