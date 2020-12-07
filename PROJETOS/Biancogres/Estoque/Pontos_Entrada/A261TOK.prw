#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A261TOK
@author Marcos Alberto Soprani
@since 20/02/13
@version 1.0
@description Valida movimento de transferência - Transferencia Mod II
@type function
/*/

User Function A261TOK()
	Local zlRet := .T.
	Local nLocal := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D3_LOCAL"})
	Local nLocDest := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D3_LOCAL"},nLocal+1)
	Local I
	
	Local _nQuant			:= 0
	Local _cProd			:= ""
	Local _cLocalOri		:= ""
	Local _oObj				:= Nil
	Local _lValida			:= .T.
	Local _nSaldo			:= 0
	Local _nEmpenhoBizagi	:= 0
	
	//2060352
	For I := 1 To Len(aCols)
		wCod 		:= Gdfieldget('D3_COD',I)
		cAlmVend	:= aCols[I][nLocDest]

		DbSelectArea("SB1")
		cArqSB1 := Alias()
		cIndSB1 := IndexOrd()
		cRegSB1 := Recno()
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wCod,.F.)

		If !(SB1->B1_TIPO $ "PA#PP") .And. cAlmVend $ "02#04"
			MsgBox("Almoxarifado destino incorreto: " + cAlmVend,"A261TOK","STOP")
			zlRet := .F.			
		EndIf
		
		If !(SB1->B1_TIPO $ "PA#PP")
		
			/*--Valida empenho bizagi--*/
			_cProd		:= Gdfieldget('D3_COD',	I)
			_cLocalOri	:= Gdfieldget('D3_LOCAL',	I)
			_nQuant 	:= Gdfieldget('D3_QUANT', I)
			
			
			_oObj		:= TValidaSaldo():New(_cProd, _cLocalOri, _nQuant)
			_lValida	:= _oObj:Check()
			
			_nSaldo			:= _oObj:nSaldo
			_nEmpenhoBizagi	:= _oObj:nEmpenhoBizagi
			zlRet			:= _lValida
			
			If (IsBlind())
				If (!_lValida)
					Conout("Impossível prosseguir, "+cvalTochar(_cProd)+", quantidade da transferência superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Transferência: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+" => MT260TOK")
				EndIf
			Else	
				If (!_lValida)
					MsgSTOP("Impossível prosseguir, "+cvalTochar(_cProd)+", quantidade da transferência superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Transferência: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+"","MT260TOK")
				EndIf		
			EndIf
			/*--Fim valida empenho bizagi--*/
			
		EndIf


		If cArqSB1 <> ""
			dbSelectArea(cArqSB1)
			dbSetOrder(cIndSB1)
			dbGoTo(cRegSB1)
			RetIndex("SB1")
		EndIf
		
		
	Next
	

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If Da261Data <= GetMv("MV_YULMES")
		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","A261TOK")
		zlRet := .F.
	EndIf

Return ( zlRet )
