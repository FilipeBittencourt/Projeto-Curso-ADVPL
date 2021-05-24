#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFMoedaBancoCentral
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe para consulta de Cotacoes de Moedas diretamento do Banco Central
@type class
/*/

Class TAFMoedaBancoCentral From LongClassName

	Data cMoeda
	Data cData
	Data nValor	
	Data cURLPost
	Data cXMLReceive
	Data oXmlReceive
	
	Method New() Constructor
	Method Request()
	Method HttpPost()	
	
EndClass


Method New() Class TAFMoedaBancoCentral

	::cMoeda := "USD"
	::cData := dDataBase
	::nValor := 0
	::cURLPost := ""
	::cXMLReceive := ""
	::oXMLReceive := Nil

Return()


Method Request() Class TAFMoedaBancoCentral
Local lRet := .F.

	If (lRet := ::HttpPost())
	
		::nValor := Val(::oXMLReceive:_A_FEED:_A_ENTRY:_A_CONTENT:_M_PROPERTIES:_D_COTACAOVENDA:TEXT)
				
	EndIf
	
Return(lRet)


Method HttpPost() Class TAFMoedaBancoCentral
Local lRet := .F.
Local aHeadOut := {}
Local cXMLHead := ""
Local cError := ''
Local cWarning := ''	

	::cURLPost := "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoMoedaDia(moeda=@moeda,dataCotacao=@dataCotacao)?@moeda='"+ ::cMoeda +"'&@dataCotacao='"+ ::cData +"'&$top=100&$skip=4&$format=xml"
	
	::cXMLReceive := EncodeUTF8(HttpPost(::cURLPost, "", "", 200, aHeadOut, @cXMLHead))
	
	If !Empty(::cXMLReceive)
	
		::oXMLReceive := XMLParser(::cXMLReceive, '_', @cError, @cWarning)
		
		lRet := !Empty(::oXMLReceive)
	
	EndIf
		
Return(lRet)