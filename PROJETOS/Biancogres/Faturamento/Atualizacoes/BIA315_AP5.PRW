#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

User Function BIA315()        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WALIAS,WC5YMAXCND,WC5VLRFRET,WC5CLIENTE,WC5LOJA,WC6PRCVEN")
SetPrvt("WNUM,XXN,XCCAMPO,WC6QTDVEN,WC6YPERVOL,WC6YPROMO")
SetPrvt("WC6YPERPTA,WC6YPERPAL,WC6YDESC,WC6YPERC,WC6YOUTDSC,WNPRCVEN")
SetPrvt("WVALOR,ACOLS,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA315     ³ Autor ³ Gustav Koblinger Jr   ³ Data ³ 10/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo do Preco de Vendas Final                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Private nPosQtdVend, nPosVlUnit, nPosVlPrc, nPosVlTotal, nPosDesc, nPosPerc := 0
Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSE4	:= ""
Private cIndSE4	:= 0
Private cRegSE4	:= 0

Private cArqSA1	:= ""
Private cIndSA1	:= 0
Private cRegSA1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SE4")
cArqSE4 := Alias()
cIndSE4 := IndexOrd()
cRegSE4 := Recno()

DbSelectArea("SA1")
cArqSA1 := Alias()
cIndSA1 := IndexOrd()
cRegSA1 := Recno()

wAlias := Alias()

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek(xFilial("SE4")+M->C5_CONDPAG,.T.)

wC5YMAXCND := M->C5_YMAXCND
wC5VLRFRET := M->C5_VLRFRET
wC5YVLRREV := M->C5_YVLRREV
wCliente   := M->C5_CLIENTE
wLoja      := M->C5_LOJAENT

nPosVlUnit := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRUNIT'})
wNPrcVen   := aCols[n,nPosVlUnit]

//Executa somente para os produto Mercado Interno
IF ALLTRIM(FUNNAME()) <> "EECAP100"
	//If M->C5_TIPOCLI <> "X"  MADALENO
	wNPrcVen   := 0
	// Obter Valores de Cada linha
	nPosQtdVend	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'})
	nPosVlUnit  := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRUNIT'})
	nPosVlPrc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'})
	nPosVlTotal	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_VALOR'})
	nPosDesc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDESC'})
	nPosPerc 	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPERC'})
	nPosVlDesc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_VALDESC'})
	
	wC6QTDVEN	:= aCols[n,nPosQtdVend]
	wC6PRCVEN	:= aCols[n,nPosVlUnit]
	wC6YDESC	:= aCols[n,nPosDesc]
	wC6YPERC	:= aCols[n,nPosPerc]
	wC6DESCONT 	:= aCols[n,nPosVlDesc]
	
	// Calcular Descontos
	wNPrcVen := wC6PRCVEN
	
	//Multiplica preco da tabela * fator financeiro
	If wC5YMAXCND > 0
		wNPrcVen := wNPrcVen * wC5YMAXCND
	EndIf
	//Subtraindo a politica de precos
	wNPrcVen := wNPrcVen * ((100 - wC6YPERC) / 100)
	//Aplicar o desconto do item
	wNPrcVen := wNPrcVen - (wNPrcVen * (wC6YDESC / 100))
	//Somou o valor do frete/seguro
	wNPrcVen := wNPrcVen + wC5VLRFRET + wC5YVLRREV
	//Arrendoda para 02 casas decimais
	wNprcVen := wNprcVen
	//Substraindo o DM
	If M->C5_YRECR == "S"
		wNPrcVen := wNPrcVen * GetMV("MV_YRECR")
	EndIf
	dbSelectArea("SA1")
	dbSetOrder(1)
	If  dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.)
		If SA1->A1_EST == "EX"
			wNPrcVen := Round(wNPrcVen,4)
		Else
			wNPrcVen := Round(wNPrcVen,2)
		EndIf
	Else
		//MsgStop("Atencao, Cliente nao encontrado. Favor verificar - BIA315")
	EndIf
	
	wValor   := Round(wC6QTDVEN * wNPrcVen,2)
	
	aCols[n,nPosVlUnit]  := wNPrcVen
	aCols[n,nPosVlPrc]   := wNPrcVen
	aCols[n,nPosVlTotal] := wValor
	
	//Se o pedido tiver desconto incodicional
	If wC6DESCONT > 0
		aCols[n,nPosVlPrc]		:= Round((wValor-wC6DESCONT) / wC6QTDVEN,4)
		aCols[n,nPosVlTotal]	:= (wValor-wC6DESCONT)
		wNPrcVen				:= (aCols[n,nPosVlPrc])
	EndIf
EndIf

dbSelectArea(wAlias)

If cArqSE4 <> ""
	dbSelectArea(cArqSE4)
	dbSetOrder(cIndSE4)
	dbGoTo(cRegSE4)
	RetIndex("SE4")
EndIf

If cArqSA1 <> ""
	dbSelectArea(cArqSA1)
	dbSetOrder(cIndSA1)
	dbGoTo(cRegSA1)
	RetIndex("SA1")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(wNPrcVen)
