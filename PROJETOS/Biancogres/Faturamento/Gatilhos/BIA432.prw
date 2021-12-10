#include "protheus.ch"
#include "topconn.ch"

User Function BIA432()
	Local wQuant 	:= 0
	Local wQtdPC 	:= Gdfieldget("C6_YQTDPC",n)   
	Local _cProd 	:= Gdfieldget("C6_PRODUTO",n)
	Local _nSaldo
	Local _nSaldoPC
	Local lRodape 	:= Posicione("SB1", 1, xFilial("SB1") + _cProd, "B1_YTPPROD") == "RP"
	Local __cLocAmo := AllTrim(GetNewPar("FA_LOCAMO","05"))
	Local _cLocal 	:= Gdfieldget("C6_LOCAL",n)
	Local xxn

	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC###MATA440")
		Return(GdFieldGet("C6_QTDVEN", n))
	EndIf

	//Alteração para tratar pedidos de AMOSTRA - Fernando/Facile em 03/09/15 - OS 2318-15
	If (AllTrim(M->C5_YSUBTP) $ "A#M#F") .and. ( _cLocal == __cLocAmo )

		_nSaldo := Round(U_FRSLDAMO(_cProd, __cLocAmo, wQtdPC),2)
		_nSaldoPC :=  (_nSaldo/SB1->B1_CONV) * SB1->B1_YPECA

		If (_nSaldoPC < wQtdPC)
			U_FROPMSG("BIA432","PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
			"Qtde Solicitada (PC): "+AllTrim(Str(wQtdPC))+CRLF+; 
			"Saldo de Amostra (PC): "+AllTrim(Str(_nSaldoPC))+CRLF+CRLF+;
			"Não existe saldo de amostra para atender esse pedido.",;
			,,"PEDIDO DE AMOSTRA - ALMOXARIFADO 05")

			Gdfieldput("C6_YQTDPC", 0, n) 
			Return(0)
		EndIf

		// Tiago Rossini Coradini - Tratamento para produtos do tipo rodape
	ElseIf AllTrim(M->C5_YSUBTP) == "N" .And. lRodape

		Gdfieldput("C6_LOCAL", "02", n)

		_nSaldo := Round(U_FRSLDAMO(_cProd, _cLocal, wQtdPC, .T.), 2)
		_nSaldoPC :=  (_nSaldo/SB1->B1_CONV) * SB1->B1_YPECA

		If (_nSaldoPC < wQtdPC)

			U_FROPMSG("BIA432","PRODUTO: "+AllTrim(_cProd)+" - "+AllTrim(SB1->B1_DESC)+CRLF+;
			"Qtde Solicitada (PC): "+AllTrim(Str(wQtdPC))+CRLF+; 
			"Saldo de Rodapé (PC): "+AllTrim(Str(_nSaldoPC))+CRLF+CRLF+;
			"Não existe saldo de rodapé para atender esse pedido.",;
			,,"PEDIDO DE RODAPÉ - ALMOXARIFADO 02")

			Gdfieldput("C6_YQTDPC", 0, n) 		
			Return(0)

		EndIf


	EndIf

	IF wQtdPC > 0

		wProduto := Gdfieldget("C6_PRODUTO",n)
		
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1")+wProduto)) 
			If SB1->B1_UM == "PC"
				wQuant := wQtdPC
			Else
				wQuant := ROUND(wQtdPC/SB1->B1_YPECA*SB1->B1_CONV,2)
			EndIf
		EndIf
	ENDIF

Return(wQuant)
