#include "TOTVS.CH"

/*/{Protheus.doc} TIAFApiRemessa
@author Tiago Rossini Coradini
@since 01/10/2018
@project Automação Financeira
@version 1.0
@description Classe para geracao de remessa e boletos
@type class
/*/

Class TIAFApiRemessa from LongClassName
	
	Data oRem // Objeto de remessa da API
	Data oRet // Objeto de retorno de processamneto da API
	Data cReimpr // N=Nao (incluir novo titulo); S=Sim (reimprimir / segunda via de boleto)
	Data GArqRem // S=Gera arquivo de remessa; N=Nao gera
	Data CMovRem
	Data nOperacao
	
	Method New() Constructor
	Method Send() // Envia titulos

EndClass


Method New() Class TIAFApiRemessa

	::oRem 		:= Nil
	::oRet 		:= Nil
	::cReimpr	:= "N"
	::GArqRem	:= "N"
	::CMovRem	:= ""
	::nOperacao	:= 0

Return()


Method Send(oLst) Class TIAFApiRemessa
Local nCount := 1
Local oBol := Nil

	::oRem := TAFApiRemessa():New(oLst:GetItem(nCount):cEmp, oLst:GetItem(nCount):cFil)
	::oRem:SetParametros(oLst:GetItem(nCount):cCnpj, oLst:GetItem(nCount):cBanco, oLst:GetItem(nCount):cAgencia, oLst:GetItem(nCount):cConta, oLst:GetItem(nCount):cSubCta)
	::oRem:GArqRem		:= ::GArqRem
	::oRem:CMovRem		:= ::CMovRem
	::oRem:nOperacao	:= ::nOperacao
		
	While nCount <= oLst:GetCount()
		
		// Caso cNumBor seja vazio, a API entende que é um Reenvio do boleto
		::oRem:cLoteNumero := oLst:GetItem(nCount):cNumBor

		oBol := ::oRem:AddBoleto()
		
		If ( ::nOperacao == 0 .or.  ::nOperacao == 1)		
			oBol:Sacado := TAFApiSacado():NewByCliente(oLst:GetItem(nCount):cEmp, oLst:GetItem(nCount):cFil, oLst:GetItem(nCount):cCliFor, oLst:GetItem(nCount):cLoja)
		Else
			oBol:Sacado := TAFApiSacado():NewByFornecedor(oLst:GetItem(nCount):cEmp, oLst:GetItem(nCount):cFil, oLst:GetItem(nCount):cCliFor, oLst:GetItem(nCount):cLoja)
		EndIf
		
		oBol:NumDoc := oLst:GetItem(nCount):cNumero + AllTrim(oLst:GetItem(nCount):cParcela) 
		oBol:NumLote := oLst:GetItem(nCount):cNumBor
		oBol:DtEmissao := oLst:GetItem(nCount):dEmissao
		oBol:DtVenc := oLst:GetItem(nCount):dVencto
		oBol:Valor := oLst:GetItem(nCount):nValorBol
		oBol:Acrescimo := oLst:GetItem(nCount):nAcre		
		oBol:NNumero := oLst:GetItem(nCount):cNumBco
		oBol:TpCom := oLst:GetItem(nCount):cTpCom		
		oBol:ChaveUnica := cValToChar(oLst:GetItem(nCount):nRecNo)
		oBol:VlrDesc := oLst:GetItem(nCount):nDesc
		
		// Informacoes de juros diarios
		
		//COMENTADO FERNANDO EM 09/04 - ESTES CAMPOS FORAM CRIADOS DUPLICADOS NA CLASSE TAFApiBoleto e estava indo errado para a API - Revisar
		//oBol:JurosDia := oLst:GetItem(nCount):nJurosDia
		//oBol:Multa := oLst:GetItem(nCount):nMulta
		
		
		oBol:RecAnt		:= oLst:GetItem(nCount):lRecAnt
		
		// Informacoes de protesto
		oBol:CodProt := oLst:GetItem(nCount):nCodProt
		oBol:DiaProt := oLst:GetItem(nCount):nDiaProt		
		
		// Informacoes de juros calculados
		oBol:DtJuros 	:= oLst:GetItem(nCount):dVencOri
		oBol:PerJurDia 	:= oLst:GetItem(nCount):nPerJur
		
		oBol:VlrJurDia 	:= oLst:GetItem(nCount):nJurosDia
		oBol:VlrMulta	:= oLst:GetItem(nCount):nMulta
		
		// Informacoes de mensagens livres
		oBol:MsgLiv1 := EncodeUTF8(oLst:GetItem(nCount):cMsgLiv1)
		oBol:MsgLiv2 := EncodeUTF8(oLst:GetItem(nCount):cMsgLiv2)
		oBol:MsgLiv3 := EncodeUTF8(oLst:GetItem(nCount):cMsgLiv3)
		
		// Sacado recebe e-mail  (email do cadastro do cliente/sacado)
		oBol:EmailSac	:= "S"	
		
		// Cedente recebe e-mail (email configurado na API)
		oBol:EmailCed	:= "S"
		
		// Reimprimir segunda via do boleto
		oBol:Reimpr		:= ::cReimpr	
		oBol:ChaveNFE	:= oLst:GetItem(nCount):cCHVNFE		

		// Campos nao mapeados
		/*
		oBol:DtMulta := Nil
		oBol:PerMulta := Nil
		oBol:VlrMulta := Nil
		oBol:MenArqRem := Nil
		oBol:CodInstr1 := Nil
		oBol:CodInstr2 := Nil
		oBol:DtDesc := Nil
		*/

		nCount++
		
	EndDo()
	
	::oRet := ::oRem:Send()

Return()