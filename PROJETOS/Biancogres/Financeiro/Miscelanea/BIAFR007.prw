#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAFR007																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 25/03/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Relatorio de crédito clientes por empresa 	 		|
|-----------------------------------------------------------|
| OS:			|	1806-13 - Usuário: Vagner Salles								|
|-----------------------------------------------------------|
*/

User Function BIAFR007(sCodigo, sLoja, nTmpSA1)
Local oReport
Private cCodCli := sCodigo
Private cLojCli := sLoja
Private cTabSA1 := nTmpSA1
Private oParam := TParBIAFR007():New()

	If oParam:Box()

		oReport := ReportDef()
		oReport:PrintDialog()
		
	EndIf

Return()


Static Function ReportDef()
Local oReport
Local oSecVen
Local oSecGrp
Local oSecCli
Local oSecMov
Local cTrb := GetNextAlias()
Local cTitRel := "Relatório de Crédito de Clientes"

	oReport := TReport():New("BIAFR007", cTitRel, {|| oParam:Box() }, {|oReport| PrintReport(oReport, cTrb)}, cTitRel)	
	
	oSecVen := TRSection():New(oReport, "Vendedor", cTrb)
	TRCell():New(oSecVen, "A3_COD", cTrb, "Vendedor")
	TRCell():New(oSecVen, "A3_NOME", cTrb,,, 60)
	
	oSecGrp := TRSection():New(oReport, "Grupo", cTrb)
	TRCell():New(oSecGrp, "ACY_GRPVEN", cTrb, "Grupo")
	TRCell():New(oSecGrp, "ACY_DESCRI", cTrb,,, 60)

	oSecCli := TRSection():New(oReport, "Cliente", cTrb)
	TRCell():New(oSecCli, "A1_COD", cTrb, "Cliente")
	TRCell():New(oSecCli, "A1_LOJA", cTrb)
	TRCell():New(oSecCli, "A1_NOME", cTrb,,, 60)
	
	oSecMov := TRSection():New(oReport, "Movimentos", cTrb)	
	TRCell():New(oSecMov, "LIMCRE", cTrb, "Limite de Crédito", PesqPict("SA1","A1_LC"))
	TRCell():New(oSecMov, "SALLC", cTrb, "Saldo Limite de Crédito", PesqPict("SA1","A1_LC"))	
	TRCell():New(oSecMov, "TITABE", cTrb, "Títulos em Aberto", PesqPict("SA1","A1_LC"))
	TRCell():New(oSecMov, "PEDCAR", cTrb, "Pedidos em Carteira", PesqPict("SA1","A1_LC"))
	TRCell():New(oSecMov, "MEDFAT", cTrb, "Prazo Médio Faturamento", PesqPict("SA1","A1_DIASPAG"))
	TRCell():New(oSecMov, "VLRFATST", cTrb, "Valor Faturado com ST", PesqPict("SA1","A1_LC"))
	
Return(oReport)


Static Function PrintReport(oReport, cTrb)
Local oSecVen := oReport:Section(1)
Local oSecGrp := oReport:Section(2)
Local oSecCli := oReport:Section(3)
Local oSecMov := oReport:Section(4)
Local aCampos := {}
Local oRData := TReportDataBiaFr007():New(cCodCli, cLojCli, cTabSA1, oParam)
									
	aCampos := {{"A3_COD", "C", 06, 0},;
							{"A3_NOME", "C", 30, 0},;
							{"ACY_GRPVEN", "C", 06, 0},;
							{"ACY_DESCRI", "C", 30, 0},;
							{"A1_COD", "C", 06, 0},;
							{"A1_LOJA", "C", 02, 0},;
							{"A1_NOME", "C", 30, 0},;
							{"LIMCRE", "N", 12, 3},;
							{"TITABE", "N", 12, 3},;
							{"PEDCAR", "N", 12, 3},;
							{"SALLC", "N", 12, 3},;
							{"MEDFAT", "N", 12, 3},;
							{"VLRFATST", "N", 12, 3}}

								
	If Select(cTrb) > 0
		(cTrb)->(DbCloseArea())
	EndIf

	cFile := CriaTrab(aCampos)
	dbUseArea(.T.,, cFile, cTrb, .T.)
	dbCreateInd(cFile, "A3_COD", {|| A3_COD })
		
	oRData:Get()
	
	RecLock((cTrb), .T.)

		(cTrb)->A3_COD := oRData:cCodVen
		(cTrb)->A3_NOME := oRData:cNomVen
		(cTrb)->ACY_GRPVEN := oRData:cCodGrp
		(cTrb)->ACY_DESCRI := oRData:cDesGrp
		(cTrb)->A1_COD := oRData:cCodCli
		(cTrb)->A1_LOJA := oRData:cLojCli
		(cTrb)->A1_NOME := oRData:cNomCli
		(cTrb)->LIMCRE := oRData:nLimCre
		(cTrb)->TITABE := oRData:nTitAbe
		(cTrb)->PEDCAR := oRData:nPedCar
		(cTrb)->SALLC := oRData:nSalLc
		(cTrb)->MEDFAT := oRData:nMedFat
		(cTrb)->VLRFATST := oRData:nVlrFatSt
	
	(cTrb)->(MsUnlock())
  			

	// Altera configuracoes da fonte do cabecalho do relatorio
	oReport:oFontHeader:Bold := .T.
	oReport:oFontHeader:nHeight := -12
	
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)

	oSecVen:Print()
	
	If !Empty(oRData:cCodGrp)
		oSecGrp:Print()
	EndIf
	
	oSecCli:Print()
	
	oSecMov:Print()
	
	(cTrb)->(DbCloseArea())

Return()