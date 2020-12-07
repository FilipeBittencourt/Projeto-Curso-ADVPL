#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF134
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Rotina para Retorno do Frete de Produtos Vinilico
@obs Ticket: 17739
@type class
/*/

User Function BIAF134(cCliente, cLoja, cProduto, nQuant, nPeso)
Local nRet := 0
Local oObj := TCalculoFreteVinilico():New()

	oObj:cCliente := cCliente
	oObj:cLoja := cLoja 
	oObj:cProduto := cProduto
	oObj:nQuant := nQuant
	oObj:nPeso := nPeso
	oObj:nVlrProd := nPeso
	
	
	nRet := oObj:Calc()
	nRet := oObj:GetSeguro()
		
Return (nRet)


User Function fFrete()

	Local oObj := TCalculoFreteVinilico():New()
	
	RPCSetType(3)
	RPCSetEnv("07", "01")

		
		oObj:cCliente 	:= "000025"
		oObj:cLoja 		:= "01"
		oObj:cProduto 	:= "VF0752C1"
		oObj:nQuant 	:= 146.8
		oObj:nPeso 		:= 800.06
		oObj:nVlrProd	:= 45

		_nVlrFrete 	:= oObj:CalcFrete()
		_nVlrProd	:= oObj:CalcVlrProd()
		_nVlrSeguro	:= oObj:CalcSeguro()
	
	RpcClearEnv()

	Alert(cvaltochar(_nVlrFrete) +" == "+cvaltochar(_nVlrProd) + " == "+ cvaltochar(_nVlrSeguro))
Return()