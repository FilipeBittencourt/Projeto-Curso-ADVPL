#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} BIA068
@author CESAR MAGNAGO
@since 14/10/99
@version 1.0
@description Determina que nao pode ter quantidade quebrada no PV
@obs Faturamento RODAPE com fabricação na BIANCOGRES
@type function
/*/

User Function BIA068()

	Local wnProduto := ""
	Local wnQtdven	:= 0
	Local wnQtdOrig := 0
	Local wnUnsven  := 0
	Local wnLocal	:= ""
	Local wTes		:= ""

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
		Return(M->C6_QTDVEN)
	EndIf

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
	yyn 	 := n		//Linha para pesquisa do Produto

	//CONOUT('-> BIA068 - '+ Alltrim(FunName()))

	If IsInCallStack("U_COPYDOCE") .And. IsBlind()

		Return(Gdfieldget("D1_QUANT", N))

	EndIf

	If Alltrim(FunName()) $ "EICDI154/COMXCOL/SCHEDCOMCOL/MATA140I/MATA140" .Or. IsInCallStack("MATA140") .Or. IsInCallStack("U_TACLNFJB") .Or. IsInCallStack("U_BACP0012") .Or. IsInCallStack("U_PNFM0002") .Or. IsInCallStack("U_PNFM0005")
		Return Gdfieldget("D1_QUANT" ,N)
	EndIf

	IF !Alltrim(FunName()) $ "MATA103/FAXML02/BIA296/EICDI154/COMXCOL/SCHEDCOMCOL/U_GATI001"

		wnProduto	:= Gdfieldget("C6_PRODUTO",yyn)
		wnQtdven	:= Gdfieldget("C6_QTDVEN" ,yyn)
		wnQtdOrig	:= Gdfieldget("C6_QTDVEN" ,yyn)
		wnUnsven	:= Gdfieldget("C6_UNSVEN" ,yyn)
		wnLocal		:= Gdfieldget("C6_LOCAL"  ,yyn)

		If cEmpAnt <> "06" // Projeto Jazidas

			IF wnLocal <> '05'

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+wnProduto,.T.)

				// Em 06/03/17, por Marcos Alberto Soprani, novo tratamento para Pedidos de Rodapé
				If SB1->B1_YTPPROD <> 'RP'

					ZA6->(DbSetOrder(2))

					If AllTrim(wnProduto) <> "0000C500" .And. AllTrim(wnProduto) <> "0000C700" .And. AllTrim(wnProduto) <> "0000C800" .And.	SB1->B1_UM <> 'PC'

						If SB1->B1_TIPCONV == "D"
							wnUnsven:= (wnQtdven / SB1->B1_CONV)
						Else
							wnUnsven:= (wnQtdven * SB1->B1_CONV)
						EndIf

						If AllTrim(SB1->B1_TIPO) $ "PA_PR"

							wxInteiro := INT(wnUnsven)
							wxDecimal := (wnUnsven - INT(wnUnsven))

							If wxDecimal == 0

								wnQtdven	:= Gdfieldget("C6_QTDVEN" ,yyn)

							Else

								wnUnsven := wxInteiro + 1
								If SB1->B1_TIPCONV == "D"
									wnQtdven := (wnUnsven * SB1->B1_CONV)
								Else
									wnQtdven := (wnUnsven / SB1->B1_CONV)
								EndIf

							EndIf

						EndIf

					EndIf

					Gdfieldput("C6_UNSVEN",wnUnsven,yyn)
					Gdfieldput("C6_QTDVEN",wnQtdven,yyn)

					If wnQtdven <> wnQtdOrig

						MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BIA068")

					EndIf

				EndIf

			EndIf

		EndIf

	ELSE

		// Tratamento para Nota Fiscal de Entrada

		wnProduto	:= Gdfieldget("D1_COD"   ,yyn)
		wnQtdven	:= Gdfieldget("D1_QUANT" ,yyn)
		wnQtdOrig	:= Gdfieldget("D1_QUANT" ,yyn)
		wnLocal		:= Gdfieldget("D1_LOCAL" ,yyn)
		wTes		:= Gdfieldget("D1_TES"	 ,yyn)

		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+wTes)
		IF SF4->F4_PODER3 <> 'D'
			IF wnLocal <> '05'
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+wnProduto,.T.)

				If AllTrim(wnProduto) <> "0000C500" .And. AllTrim(wnProduto) <> "0000C700" .And. AllTrim(wnProduto) <> "0000C800" .And. SB1->B1_TIPO == "PA" .And. SB1->B1_UM <> "PC"

					If SB1->B1_TIPCONV == "D"
						wnUnsven:= (wnQtdven / SB1->B1_CONV)
					Else
						wnUnsven:= (wnQtdven * SB1->B1_CONV)
					EndIf

					wxInteiro := INT(wnUnsven)
					wxDecimal := (wnUnsven - INT(wnUnsven))

					If wxDecimal == 0
						wnQtdven	:= Gdfieldget("D1_QUANT" ,yyn)
					Else
						wnUnsven := wxInteiro + 1

						If SB1->B1_TIPCONV == "D"
							wnQtdven := (wnUnsven * SB1->B1_CONV)
						Else
							wnQtdven := (wnUnsven / SB1->B1_CONV)
						EndIf
					EndIf

					Gdfieldput("D1_QUANT",wnQtdven,yyn)

					If wnQtdven <> wnQtdOrig
						MsgAlert("Quantidade Original na 1a. Unidade: "+str(wnQtdOrig,10,2)+", alterada para "+str(wnQtdven,10,2),"BIA068")
					EndIf

				EndIf

			ENDIF

		ENDIF

	ENDIF

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	//Fernando/Facile - ajustar variavel de memoria para outros gatilhos - Projeto pesquisa de lote - 11/08/2014
	If AllTrim(ReadVar()) == "M->C6_QTDVEN"
		M->C6_QTDVEN := wnQtdven
	EndIf

Return(wnQtdven)
