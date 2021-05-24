#include "rwmake.ch"
#include "topconn.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT260TOK	³ Autor ³ Ranisses A. Corona    ³ Data ³ 12/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o preenchimento do campo de Localizacao Destino     ³±±
±±³          ³ e nao permite transferir produtos diferentes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Transferencia Modelo I - MATA260                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT260TOK()

	Local lRet 			:= .T.
	
	Local _nQuant			:= 0
	Local _cProd			:= ""
	Local _cLocalOri		:= ""
	Local _oObj				:= Nil
	Local _lValida			:= .T.
	Local _nSaldo			:= 0
	Local _nEmpenhoBizagi	:= 0
	Local _oMd	:=	TBiaControleMD():New()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa validacao referente Almoxarifado Comum ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Executa funcao de validacao com retorno imediato
	lRet := U_fValProdComum(CCODDEST,CLOCDEST,"MT260TOK","T") //Paramentros da Funcao Produto/Almoxarifado/NomeProgroma/TipoMovimento(C=Compra/T=Transferencia)

	If _oMd:CheckMd(CCODORIG,CLOCORIG) .And. _oMd:CheckMd(CCODDEST,CLOCDEST)
		If (IsBlind())
			Conout("Impossível prosseguir, o produto é MD no Almoxarifado Origem e Destino  => MT260TOK")
		Else	
			MsgSTOP("Impossível prosseguir, o produto é MD no Almoxarifado Origem e Destino  => MT260TOK")
		EndIf
		Return .F.
	EndIf

	If !_oMd:CheckMd(CCODORIG,CLOCORIG) .And. _oMd:CheckMd(CCODDEST,CLOCDEST)
		If (IsBlind())
			Conout("Impossível prosseguir, o produto não é MD na Origem e é MD no Destino  => MT260TOK")
		Else	
			MsgSTOP("Impossível prosseguir, o produto não é MD na Origem e é MD no Destino  => MT260TOK")
		EndIf
		Return .F.
	EndIf

		
	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+CCODORIG,.F.))
	
	
	If !(SB1->B1_TIPO $ "PA#PP")
	
		/*--Valida empenho bizagi--*/
		_nQuant 	:= NQUANT260
		_cProd		:= CCODORIG
		_cLocalOri	:= CLOCORIG
		
		_oObj		:= TValidaSaldo():New(_cProd, _cLocalOri, _nQuant)
		_lValida	:= _oObj:Check()
		
		_nSaldo			:= _oObj:nSaldo
		_nEmpenhoBizagi	:= _oObj:nEmpenhoBizagi
		lRet			:= _lValida
		
		If (IsBlind())
			If (!_lValida)
				Conout("Impossível prosseguir, quantidade da transferência superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Transferência: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+" => MT260TOK")
			EndIf
		Else	
			If (!_lValida)
				MsgSTOP("Impossível prosseguir, quantidade da transferência superior a disponivel no estoque."+CRLF+CRLF+" Saldo: "+cvalTochar(_nSaldo)+""+CRLF+" Empenho Bizagi: "+cvalTochar(_nEmpenhoBizagi)+""+CRLF+" Saldo Disp. Transferência: "+cvalTochar((_nSaldo - _nEmpenhoBizagi))+"","MT260TOK")
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
	

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If dEmis260 <= GetMv("MV_YULMES")
		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT260TOK")
		lRet := .F.
	EndIf

Return(lRet)
