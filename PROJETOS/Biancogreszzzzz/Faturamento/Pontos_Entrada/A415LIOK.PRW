#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A415LIOK  ³ Autor ³ Ranisses A. Corona    ³ Data ³ 14/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o produto de acordo com a linha utilizada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Faturamento                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A415LIOK()

Local nClassPr	:= ""
Local nFormat	:= ""
Local nLocal	:= ""
Local lRet		:= .T.
Local lRetorno 	:= .T.
Local nTpLinha	:= ""

Local cArq    	:= ""
Local cInd    	:= 0
Local cReg	    := 0

Local cArqSB1	:= ""
Local cIndSB1	:= 0
Local cRegSB1	:= 0

Local cArqTMP1	:= ""
Local cIndTMP1	:= 0
Local cRegTMP1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SB1")
cArqSB1 := Alias()
cIndSB1 := IndexOrd()
cRegSB1 := Recno()

//Posiciona no Arquivo de Trabalho
DbSelectArea("TMP1")
cArqTMP1 := Alias()
cIndTMP1 := IndexOrd()
cRegTMP1 := Recno()

//Procura o Produto
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+TMP1->CK_PRODUTO,.F.)

//Se a linha estiver deletada, não realiza validação
If TMP1->CK_FLAG
	Return(.T.)
EndIf

//Valida os produtos BellaCasa com a Linha = 3
If !cEmpAnt == "02"
	nTpLinha := Posicione("ZZ7",1,xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ,"ZZ7_TIPO")
	If nTpLinha == "B" .And. !M->CJ_YLINHA == "3"
		MsgBox("Para produtos BellaCasa favor acertar a Linha, no cabeçalho do Orçamento!","A415LIOK","ALERT")
		lRetorno := .F.
	ElseIf M->CJ_YLINHA == "3" .And. !nTpLinha == "B"
		MsgBox("Para produtos BellaCasa favor acertar a Linha, no cabeçalho do Orçamento!","A415LIOK","ALERT")
		lRetorno := .F.
	EndIf
	
	IF cEmpAnt == "07" .AND. 	Funname() == "MATA415" .AND. SB1->B1_YTPPROD <> 'IM'
		MsgBox("O Representante não poderá incluir orçamentos na empresa LM para produtos que não sejam Importados!","A415LIOK","STOP")
		lRetorno := .F.
	ENDIF
	
	IF SB1->B1_MSBLQL == '1'
		MsgBox("Este produto está bloqueado para uso!","A415LIOK","STOP")
		lRetorno := .F.
	ENDIF
	
	//Posiciona no primeiro registro do arquivo de trabalho
	dbSelectArea("TMP1")
	dbGotop()
	While !Eof() .And. lRet
		nClassPr 	:= Substr(TMP1->CK_PRODUTO,8,1) //Classe
		nFormat	 	:= Substr(TMP1->CK_PRODUTO,1,1)	//Formato
		nLocal	 	:= TMP1->CK_LOCAL								//Local
		lRet  		:= .F.
		dbSkip()
	EndDo
	
	//Volta posicao original do aCols
	If cArqTMP1 <> ""
		DbSelectArea(cArqTMP1)
		DbSetOrder(cIndTMP1)
		DbGoTo(cRegTMP1)
	EndIf
	
	//Bloqueia digitacao de Produtos Importados com Outros produtos.
	If (Substr(Alltrim(SB1->B1_YFORMAT),1,1) == "I" .And. nFormat <> "I") .Or. (Substr(Alltrim(SB1->B1_YFORMAT),1,1) <> "I" .And. nFormat == "I")
		MsgBox("Não é permitido misturar Produtos Importados com outros Produtos.","A415LIOK","ALERT")
		Return(.F.)
	EndIf
	
	//Somente para Biancogres = Permite apenas produtos do mesmo almoxarifado
	If cEmpAnt == "01" .And. nLocal $ ("02_05")
		If !TMP1->CK_LOCAL $ ("02_05")
			MsgBox("Não é permitido utilizar produtos Biancogres e Incesa no mesmo Orçamento.","A415LIOK","ALERT")
			Return(.F.)
		EndIf
	EndIf
	
	//O sistema nao permite produtos de Classes diferentes em um mesmo pedido.
	If nClassPr == "1" .And. SB1->B1_YCLASSE <> "1"
		MsgBox("Não é permitido incluir Produtos de Classes diferentes.","A415LIOK","ALERT")
		Return(.F.)
	ElseIf nClassPr $ "2_4" .And. !SB1->B1_YCLASSE $ "2_4"
		MsgBox("Não é permitido incluir Produtos de Classes diferentes.","A415LIOK","ALERT")
		Return(.F.)
	ElseIf nClassPr $ "3_5" .And. !SB1->B1_YCLASSE $ "3_5"
		MsgBox("Não é permitido incluir Produtos de Classes diferentes.","A415LIOK","ALERT")
		Return(.F.)
	EndIf

    //Testa a data de entrega
	If !Empty(Alltrim(TMP1->CK_ENTREG))
		If TMP1->CK_ENTREG < M->CJ_EMISSAO
			MsgBox("Data de Entrega menor que a Emissão do Orçamneto. Favor verificar.","A415LIOK","ALERT")
			Return(.F.)
		EndIf	
	EndIf
	
EndIf

If cArqTMP1 <> ""
	DbSelectArea(cArqTMP1)
	DbSetOrder(cIndTMP1)
	DbGoTo(cRegTMP1)
EndIf

If cArqSB1 <> ""
	dbSelectArea(cArqSB1)
	dbSetOrder(cIndSB1)
	dbGoTo(cRegSB1)
	RetIndex("SB1")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(lRetorno)