#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA611   ³ Autor ³ Cesar Magnago         ³ Data ³ 10/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Execblock para nao permitir que se digite um codigo de pro-³±±
±±³          ³ dutos com tamanho maior ou igual a 6 caracteres.           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico: BIANCOGRES S/A                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA611()

Local wProduto	:= SPACE(15)
Local wLocal 	:= ""
Local nPrcven	:= 0 

//Tratamento especial para Replcacao de pedido LM
If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	Return(M->C6_PRODUTO)
EndIf

If Alltrim(FUNNAME()) $ "MATA410_MATA416"
	wProduto	:= Gdfieldget('C6_PRODUTO',n)
	wLocal		:= Gdfieldget('C6_LOCAL',n)
Else
	wProduto	:= TMP1->CK_PRODUTO
	wLocal		:= TMP1->CK_LOCAL
EndIf

//Posiciona no Cliente
SB1->(DbSetOrder(1))                 
SB1->(DbSeek(XFilial("SB1")+wProduto)) 

//Se o produto estiver bloqueado, não executa nenhuma ação
If SB1->B1_YBLSCPC == '1'
	MsgBox("Este Código de Produto está bloqueado. Favor procurar o Gerente Comercial.","BIA611","STOP")
	wProduto := SPACE(15)
	Return(wProduto)
Endif

//Não permite infomar produtos PA com codigo incompleto ou Amostra
If Len(AllTrim(wProduto)) < 8 .AND. SUBSTR(wProduto,1,3) <> '000' .AND. SUBSTR(wProduto,1,1) >= 'A' .AND. SUBSTR(wProduto,4,4) <> '0000' .AND. SB1->B1_TIPO <> 'PR'
	//Tramento vendas Loucas na Mundialli
	If !Alltrim(SB1->B1_YFORMAT) $ 'IA_IB_IC'
		wProduto := SPACE(15)
	EndIf	
Endif

//Grava preço para expositores
If SUBSTR(wProduto,1,3) == "216"
	
	DbSelectArea("SB2")
	DbSeek(xFilial("SB2")+wProduto+wLocal)
	
	If Alltrim(FUNNAME()) = "MATA410"
		Gdfieldput('C6_PRCVEN',SB2->B2_CM1,n)
	Else
		TMP1->CK_PRCVEN	:= SB2->B2_CM1
		TMP1->CK_PRUNIT	:= SB2->B2_CM1
		TMP1->CK_VALOR	:= ROUND(TMP1->CK_PRCVEN*TMP1->CK_QTDVEN,2)
	EndIf
	
EndIf

Return(wProduto)