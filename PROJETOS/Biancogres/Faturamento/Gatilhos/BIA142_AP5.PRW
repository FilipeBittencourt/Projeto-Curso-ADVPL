#include "rwmake.ch"        

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA142     � Autor � CESAR MAGNAGO         � Data � 21/11/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Determina que nao pode ter quantidade quebrada no PV         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa variaveis...                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

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

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//� Executa fun嚻o padr苚 de processamento.                              �
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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

					//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
					//� Fim do Programa Principal                                            �
					//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
