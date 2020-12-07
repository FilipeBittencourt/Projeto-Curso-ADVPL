#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0026; Return()

/*
|-----------------------------------------------------------|
| Função: | TReportDataBiaFr007															|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 06/04/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Dados do Relatorio de crédito clientes					|
|-----------------------------------------------------------|
| OS:			|	1806-13 - Usuário: Vagner Salles								|
|-----------------------------------------------------------|
*/


Class TReportDataBiaFR007 From LongClassName
	
	Data cCodVen
	Data cNomVen
	Data cCodGrp
	Data cDesGrp
	Data cCodCli
	Data cLojCli
	Data cNomCli
	Data nLimCre
	Data nTitAbe
	Data nPedCar
	Data nSalLc
	Data nSalDup
	Data nMedFat
	Data nVlrFatSt
	Data cTipLimCre
	Data cDatDe
	Data cDatAte	
	Data cTabSA1
	
	Method New(cCodCli, cLojCli, cTabSA1, oParam) Constructor
	Method Get()
	Method GetSalLc() // Retorna saldo do limite de credito
	Method GetMedFat() // Retorna media de faturamento
	Method GetVlrFatSt() // Retorna valor faturado com ST

EndClass


Method New(cCodCli, cLojCli, cTabSA1, oParam) Class TReportDataBiaFr007
	
	::cCodVen := oParam:cCodVen
	::cNomVen := Alltrim(Posicione("SA3", 1, xFilial("SA3") + ::cCodVen, "A3_NOME"))
	::cCodGrp := ""
	::cDesGrp := ""
	::cCodCli := cCodCli
	::cLojCli := cLojCli
	::cNomCli := Alltrim(Posicione("SA1", 1, xFilial("SA1") + ::cCodCli, "A1_NOME"))
	::nLimCre := 0
	::nTitAbe := 0
	::nPedCar := 0
	::nSalLc := 0
	::nSalDup := 0
	::nMedFat := 0
	::nVlrFatSt := 0
	::cTipLimCre := ""
	::cTabSA1 := cTabSA1
	::cDatDe := dToS(oParam:dDatDe)
	::cDatAte := dToS(oParam:dDatAte)
	
Return()


Method Get() Class TReportDataBiaFr007
Local lReport := .T.

	U_SIT_FIN(::cCodCli, ::cLojCli, .F., lReport, ::cCodVen, @::nLimCre, @::nPedCar, @::nSalDup)
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	If SA1->(DbSeek(xFilial("SA1") + ::cCodCli + ::cLojCli))		

		If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			
			::cCodGrp := Alltrim(SA1->A1_GRPVEN)
			::cDesGrp := Alltrim(Posicione("ACY", 1, xFilial("ACY") + SA1->A1_GRPVEN, "ACY_DESCRI"))
			::cTipLimCre := "G"

		EndIf
		
		StaticCall(POS_CLI, TITABERTO, lReport, ::cCodVen, @::nTitAbe)

		::nSalLc := ::GetSalLc()
		::nMedFat := ::GetMedFat()
		::nVlrFatSt := ::GetVlrFatSt()
		
	EndIf
		
Return()


Method GetSalLc() Class TReportDataBiaFr007
Local nSalLc := 0
Local nTotPed := 0
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := U_QryPedCons(::cCodCli, ::cLojCli, ::cTipLimCre, ::cCodGrp, '', .F.)
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
		
		If (cQry)->LIBMAN == 'N'
			nTotPed := (cQry)->SALDO
		EndIf
		
		(cQry)->(DbSkip())
		
	End
	
	(cQry)->(DbCloseArea())
	
	nSalLc := ::nLimCre - (::nSalDup + nTotPed)
				
Return(nSalLc)


Method GetMedFat() Class TReportDataBiaFr007
Local nMedFat := 0
Local aSPRet := {}
Local cSQL := ""
Local cSE1 := ""
Local cQry := GetNextAlias()

	If Alltrim(::cCodGrp) <> "" .AND. ::cTipLimCre == "G"
		aSPRet := TcSPExec("SP_POSCLI_SE1", ::cTabSA1, '', '', ::cCodGrp, ::cTipLimCre, ::cDatDe, ::cDatAte, ::cCodVen)
	Else                                                                    
		aSPRet := TcSPExec("SP_POSCLI_SE1", ::cTabSA1, ::cCodCli, ::cLojCli, '', '', ::cDatDe, ::cDatAte, ::cCodVen)
	EndIf
    
	cSE1 := aSPRet[2]
	
	cSQL := " SELECT ROUND(SUM(DATEDIFF(D,E1_EMISSAO,E1_VENCTO) * E1_VALOR) / SUM(E1_VALOR), 0) AS MEDFAT "
	cSQL += " FROM " + cSE1
	
	TcQuery cSQL New Alias (cQry)
	
	nMedFat := (cQry)->MEDFAT
	
	(cQry)->(DbCloseArea())

Return(nMedFat)


Method GetVlrFatSt() Class TReportDataBiaFr007
Local nVlrFatSt := 0
Local aSPRet := {}
Local cSQL := ""
Local cSF2 := ""
Local cQry := GetNextAlias()

	If Alltrim(::cCodGrp) <> "" .AND. ::cTipLimCre == "G"
		aSPRet := TcSPExec("SP_POSCLI_SF2", ::cTabSA1, '', '', ::cCodGrp, ::cTipLimCre, ::cDatDe, ::cDatAte, ::cCodVen)
	Else                                                                    
		aSPRet := TcSPExec("SP_POSCLI_SF2", ::cTabSA1, ::cCodCli, ::cLojCli, '', '', ::cDatDe, ::cDatAte, ::cCodVen)
	EndIf
    
	cSF2 := aSPRet[2]
	
	cSQL := " SELECT SUM(F2_VALBRUT) AS VLRFATST "
	cSQL += " FROM " + cSF2
	
	TcQuery cSQL New Alias (cQry)
	
	nVlrFatSt := (cQry)->VLRFATST
	
	(cQry)->(DbCloseArea())

Return(nVlrFatSt)