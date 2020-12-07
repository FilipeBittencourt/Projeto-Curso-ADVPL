#include "rwmake.ch"        

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA142     ³ Autor ³ CESAR MAGNAGO         ³ Data ³ 21/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina que nao pode ter quantidade quebrada no PV         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function BIA142()    

	Local wNum  

	SetPrvt("WALIAS,WNPRODUTO,WNQTDVEN,WNQTDORIG,WNUNSVEN,WXINTEIRO")
	SetPrvt("WXDECIMAL,WOPCAO,WNUM,YYN,XXN,XCCAMPO")
	SetPrvt("ACOLS,")

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	wAlias   := Alias()
	wnProduto:= ""      // Produto
	wnQtdven := 0       // Retorno da Qtde Vendida
	wnQtdOrig:= 0       // Qtde Orignal
	wnUnsven := 0       // Qtde na Segunda Unidade de Medida
	wxInteiro:= 0       // Total Interio
	wxDecimal:= 0       // Total Decimal
	yyn 	 := n

	For wNum := 1 to Len(aCols)

		wnProduto	:= Gdfieldget("C6_PRODUTO",yyn)
		wnQtdven	:= Gdfieldget("C6_QTDLIB" ,yyn)
		wnQtdOrig	:= Gdfieldget("C6_QTDLIB" ,yyn)
		wnUnsven	:= Gdfieldget("C6_UNSVEN" ,yyn)
		wnLocal		:= Gdfieldget("C6_LOCAL"  ,yyn)

		If cEmpAnt <> "06" // Projeto Jazidas

			IF wnLocal <> '05'

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+wnProduto,.T.)

				If AllTrim(wnProduto) <> "0000C500" .And. AllTrim(wnProduto) <> "0000C700" .And. AllTrim(wnProduto) <> "0000C800" .And.	SB1->B1_UM <> 'PC'

					If SB1->B1_TIPCONV == "D"
						wnUnsven:= (wnQtdven / SB1->B1_CONV)
					Else
						wnUnsven:= (wnQtdven * SB1->B1_CONV)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa fun‡Æo padrÆo de processamento.                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SB1->B1_TIPO == "PA"
						wxInteiro := INT(wnUnsven)
						wxDecimal := (wnUnsven - INT(wnUnsven))

						If wxDecimal == 0           
							wnQtdven	:= Gdfieldget("C6_QTDLIB" ,yyn)
						Else
							wnUnsven := wxInteiro + 1					
							If SB1->B1_TIPCONV == "D"
								wnQtdven := (wnUnsven * SB1->B1_CONV)
							Else
								wnQtdven := (wnUnsven / SB1->B1_CONV)
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fim do Programa Principal                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Gdfieldput("C6_UNSVEN",wnUnsven,yyn)
					Gdfieldput("C6_QTDLIB",wnQtdven,yyn)

					If wnQtdven <> wnQtdOrig
						MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BIA142")
					EndIf

				EndIf

			EndIf

		EndIf

	Next

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(wnQtdven)
