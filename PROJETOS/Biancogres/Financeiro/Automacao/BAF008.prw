#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF008
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Geracao de bordero e envio de boletos para a API
@type function
/*/

Function U_BAF008()
	
	Local aArea		as array
	Local aAreaSA1	as array

	Local cSA1Order	as character
	
	Local nSA1Order	as numeric

	Local oObj		as object
	Local oParam	as object

	aArea:=getArea()
	aAreaSA1:=SA1->(getArea())
			
	oObj:=TAFRemessaReceber():New()

	oParam:=TParBAF008():New()

	oParam:dEmissaoDe:=oObj:oMrr:dEmissaoDe
	oParam:dEmissaoAte:=oObj:oMrr:dEmissaoAte

	If (oParam:Box())

		if (FIDC():isFIDCEnabled())
			cSA1Order:="A1_FILIAL+A1_COD+A1_LOJA"
			nSA1Order:=RetOrder("SA1",cSA1Order)
			SA1->(dbSetOrder(nSA1Order))
			if (SA1->(MsSeek(xFilial("SA1")+oParam:cCliente+oParam:cLoja)))
				FIDC():setFIDCVar("A1_YCDGREG",SA1->A1_YCDGREG)
				oObj:oMrr:lFIDC:=FIDC():regrabcoIsFIDC()
			endif
		endif

		U_BIAMsgRun("Processando remessa de títulos - [API Facile.Net]...", "Aguarde!", {|| fProcess(oParam, oObj) })
				
	EndIf

	restArea(aAreaSA1)
	restArea(aArea)

Return()


Static Function fProcess(oParam, oObj)
		
	//oObj:oMrr:dEmissaoDe := oParam:dEmissao
	//oObj:oMrr:dEmissaoAte := oParam:dEmissao
	//oObj:oMrr:nDia := oParam:nDia
	oObj:oMrr:lReenvBord := oParam:lReenvBord
	oObj:oMrr:cBorDe := oParam:cBorDe
	oObj:oMrr:cBorAte := oParam:cBorAte
	oObj:oMrr:cCliente := oParam:cCliente
	oObj:oMrr:cLoja := oParam:cLoja

	oObj:oApi:cReimpr := IIF(oObj:oMrr:lReenvBord,"S","N")
	
	oObj:Send()

Return()
