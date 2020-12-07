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

User Function BAF008()
Local oParam := TParBAF008():New()
Local oObj := TAFRemessaReceber():New()
	
	oParam:dEmissaoDe := oObj:oMrr:dEmissaoDe
	oParam:dEmissaoAte := oObj:oMrr:dEmissaoAte
	
	//oParam:dEmissaoDe := STOD("20191201")
	//oParam:dEmissaoAte := STOD("20191214")
	//oObj:oMrr:lReproc := .T.
			
	If oParam:Box()
					
		U_BIAMsgRun("Processando remessa de títulos - [API Facile.Net]...", "Aguarde!", {|| fProcess(oParam, oObj) })
				
	EndIf
	
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