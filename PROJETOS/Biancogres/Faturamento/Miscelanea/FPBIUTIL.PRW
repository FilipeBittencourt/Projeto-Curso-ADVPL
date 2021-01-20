#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} FPBIGEMP
@description Busca a empresa do estoque do produto / Projeto PBI
@author Fernando Rocha
@since 16/07/2018
@version 1.0
@type function
/*/

User Function FPBIGEMP(cCodPro, nQtdDig, cSegmento, cIdTemp, cItemPV, nPercMax, nPercMin, cEmpOri, lPalete, _cCategoria, _cLotRes, _nProxLote, _cLoteAdd, _cLoteExc, _cPrioSaldo, _nTolerancia, _lExibirTela)

	Local oPBI
	Local aRet := Array(13)

	Default cEmpOri 	:= ""
	Default lPalete 	:= .F.
	Default _cCategoria	:= ""
	Default _cLotRes	:= ""
	Default _nProxLote	:= .F.
	

	oPBI := TPorcelanatoBiancogresIncesa():New()

	oPBI:cCodPro 	:= cCodPro
	oPBI:nQtdDig 	:= nQtdDig
	oPBI:cSegmento	:= cSegmento
	oPBI:cCategoria	:= _cCategoria
	oPBI:cLotRes	:= _cLotRes
	oPBI:cIdTemp	:= cIdTemp
	oPBI:cItemPV	:= cItemPV
	oPBI:nPercMax	:= nPercMax
	oPBI:nPercMin	:= nPercMin
	oPBI:cEmpAt		:= cEmpOri
	oPBI:lPalete	:= lPalete
	oPBI:nProxLote	:= _nProxLote
	oPBI:cLoteAdd	:= _cLoteAdd
	oPBI:cLoteExc	:= _cLoteExc
	oPBI:cPrioSaldo	:= _cPrioSaldo
	oPBI:nTolerancia:= _nTolerancia
	oPBI:ExibirTela := _lExibirTela
	
	oPBI:TelaSugestao()

	aRet[1] 	:= oPBI:EmpEst		
	aRet[2] 	:= oPBI:LocEst		
	aRet[3] 	:= oPBI:CodProduto	
	aRet[4] 	:= oPBI:Prioridade	
	aRet[5] 	:= oPBI:Lote			
	aRet[6] 	:= oPBI:Qtd_Solicit	
	aRet[7] 	:= oPBI:Saldo			
	aRet[8] 	:= oPBI:Qtd_Sug		
	aRet[9] 	:= oPBI:N_Pallets		
	aRet[10] 	:= oPBI:Qtd_Um_Pallet
	aRet[11] 	:= oPBI:Qtd_Ponta		
	aRet[12] 	:= oPBI:Regra_Sug
	aRet[13] 	:= oPBI:EscolheuSugestao
	
Return(aRet)