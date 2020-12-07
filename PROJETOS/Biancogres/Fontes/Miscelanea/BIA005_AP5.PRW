#include "rwmake.ch"
#include "topconn.ch"

User Function Bia005()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local xxn
	SetPrvt("WALIAS,WREFER_ol,WEST,WCOND,CARQSB1,CARQSA1")
	SetPrvt("CARQSZ1,XXN,XCCAMPO,WCOD,WCLIENTE,WLOJA")
	SetPrvt("WPRECO,WTIPO,CARQSX5,CINDSX5,CREGSX5,CINDSB1")
	SetPrvt("CREGSB1,CINDSA1,CREGSA1,CINDSZ1,CREGSZ1,wClasse")

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ BIA005     ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 19/04/99 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Preco de Vendas                                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador x Base                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	wAlias  := Alias()
	WREFER_ol  := space(30)
	wEst    := Space(2)
	wCond   := Space(3)
	wPreco  := 0
	wClasse := ""

	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0

	Private cArqSA1	:= ""
	Private cIndSA1	:= 0
	Private cRegSA1	:= 0

	Private cArqSX5	:= ""
	Private cIndSX5	:= 0
	Private cRegSX5	:= 0

	Private cArqSB1	:= ""
	Private cIndSB1	:= 0
	Private cRegSB1	:= 0

	Private cArqSZ1	:= ""
	Private cIndSZ1	:= 0
	Private cRegSZ1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSZ1 <> ""
		dbSelectArea(cArqSZ1)
		dbSetOrder(cIndSZ1)
		dbGoTo(cRegSZ1)
		RetIndex("SZ1")
	EndIf

	If cArqSX5 <> ""
		dbSelectArea(cArqSX5)
		dbSetOrder(cIndSX5)
		dbGoTo(cRegSX5)
		RetIndex("SX5")
	EndIf

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C6_PRODUTO"
			wCod := aCols[n][xxn]
		Endif
		If xcCampo == "C6_PRCVEN"
			wPreco := aCols[n][xxn]         // Incluido por Luana em 24/11/04.
		Endif
	Next
	wCond   := M->C5_CONDPAG
	wCliente:= M->C5_CLIENTE
	wLoja   := M->C5_LOJAENT
	wTipo   := M->C5_TIPO
	wTabela := M->C5_TABELA
	dEmissao:= Dtos(M->C5_EMISSAO)

	IF ALLTRIM(FUNNAME()) <> "EECAP100"
		//If M->C5_TIPOCLI <> "X"  MADALENO

		If wTipo == "N"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Tabela 91                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SX5")
			DbSetOrder(1)
			If !dbSeek(xFilial("SX5")+"91"+wCond,.f.)
				//msgBox("Cond. Pagto nao cadastrada na Tabela 91","Cond. Pagto nao cadastrado","ALERT")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cadastro do Produto                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SB1")
			DbSetOrder(1)
			If dbSeek(xFilial("SB1")+wCod,.f.)
				WREFER_ol := SB1->B1_YREFPV
			Else
				msgBox("Produto nao cadastrado no SB1","Produto nao cadastrado","ALERT")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cadastro do Cliente                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA1")
			DbSetOrder(1)
			If dbSeek(xFilial("SA1")+wCliente+wLoja,.f.)
				wEst := SA1->A1_EST
				//Desabilitar quando trabalhar com nova tabela de preco.
				If !wEst $ ("ES_EX")
					wEst := "OU"
				EndIf
			Else
				msgBox("Cliente nao cadastrado no SA1","Cliente nao cadastrado","ALERT")
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cadastro do Preco de Vendas                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("ZZ8")
			DbSetOrder(1)
			IF DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
				wClasse := ALLTRIM(ZZ8->ZZ8_DESC)
			ELSE
				MsgStop("Classe: "+SB1->B1_YCLASSE+"-"+SB1->B1_COD+", nao programada para este programa: INC313")
			ENDIF

			/*
			cCount1  := ""
			cSelect1 := ""
			cWhere1  := ""
			cCount1 += "SELECT COUNT(*) AS TOTREGS "
			cWhere1 += "From " + RETSQLNAME("DA1") + " DA1, " + RETSQLNAME("DA0") + " DA0 "
			cWhere1 += "Where 	DA0.DA0_FILIAL 	= '" + xFilial("DA0") + "' And "
			cWhere1 += "     	DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "' And "
			cWhere1 += "	'" + dEmissao +"' 	>= DA0.DA0_DATDE           And "
			cWhere1 += "	'" + dEmissao +"' 	<= DA0.DA0_DATATE          And "
			cWhere1 += "    DA0.DA0_CODTAB	= '" + wCodTab +"'             And "
			cWhere1 += "    DA0.DA0_CODTAB	= DA0.DA0_CODTAB               And "
			cWhere1 += "	DA1.DA1_CODPRO	= '" + wCod +"'		           And "
			IF wEst == 'ES'
			cWhere1 += "	((DA1.DA1_ESTADO	= '  ' AND DA1.DA1_TPOPER = '1') Or DA1.DA1_ESTADO = 'ES')   And "
			ELSE
			cWhere1 += "	((DA1.DA1_ESTADO	= '  ' AND DA1.DA1_TPOPER = '2') Or DA1.DA1_ESTADO = '" + wEst +"' )   And "
			ENDIF
			cWhere1 += "	DA0.D_E_L_E_T_	= ''		                   And "
			cWhere1 += "	DA1.D_E_L_E_T_ 	= '' "
			cCount1 := cCount1 + cWhere1
			If chkfile("X")
			dbSelectArea("X")
			dbCloseArea()
			EndIf
			TCQUERY cCount1 ALIAS "X" NEW
			*/

			//Buscando o preco do Produto.
			DbSelectArea("SZ1")
			DbSetOrder(1)

			cCount  := ""
			cSelect := ""
			cWhere  := ""
			cCount += "SELECT COUNT(*) AS TOTREGS "
			cWhere += "From " + RETSQLNAME("SZ2") + " SZ2, " + RETSQLNAME("SZ1") + " SZ1 "
			cWhere += "Where 	SZ2.Z2_REFER 	= '" + WREFER_ol + "' And "
			cWhere += "	'" + dEmissao +"' 	>= SZ2.Z2_DTINIPR    And "
			cWhere += "	'" + dEmissao +"' 	<= SZ2.Z2_DTFIMPR    And "
			cWhere += "	SZ1.Z1_EST	= '" + wEst +"'		     And "
			cWhere += "	SZ1.Z1_CLASSE	= '" + wClasse +"'	 And "
			cWhere += "	SZ1.Z1_REFER 	= SZ2.Z2_REFER       And "
			cWhere += "	SZ1.Z1_DTINIPR 	= SZ2.Z2_DTINIPR     And "
			cWhere += "	SZ1.D_E_L_E_T_	= ''		         And "
			cWhere += "	SZ2.D_E_L_E_T_ 	= '' "
			cCount := cCount + cWhere
			If chkfile("X")
				dbSelectArea("X")
				dbCloseArea()
			EndIf
			TCQUERY cCount ALIAS "X" NEW

			//Verifica se existe mais de 1 registro
			If X->TOTREGS > 1
				MsgStop("Existem inconsistencias na Tabela de Preco. Favor verificar a referencia "+Alltrim(WREFER_ol)+".")
				//MsgStop("Existem inconsistencias na Tabela de Preco. Favor verificar a referencia "+Alltrim(wCod)+".")

				aCols[n,nPosVlPrc]   := 0
				aCols[n,nPosVlTotal] := 0
			Else
				cSelect += "SELECT * "
				cSelect := cSelect + cWhere
				If chkfile("rPreco")
					dbSelectArea("rPreco")
					dbCloseArea()
				EndIf
				TCQUERY cSelect ALIAS "rPreco" NEW

				//Senao for final de arquivo grava os valores
				If !rPreco->(EOF())
					wPreco := rPreco->Z1_VALOR
				Else
					MsgStop("Nao existe tabela de preco para este produto. Favor verificar a referencia "+Alltrim(WREFER_ol)+".")
				EndIf

				//If !rPreco->(EOF())
				//	wPreco := rPreco->DA1_YPRV1
				//Else
				//    MsgStop("Existem inconsistencias na Tabela de Preco. Favor verificar a referencia "+Alltrim(wCod)+".")
				//EndIf
			EndIf
			dbSelectArea(wAlias)
		EndIf
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSZ1 <> ""
		dbSelectArea(cArqSZ1)
		dbSetOrder(cIndSZ1)
		dbGoTo(cRegSZ1)
		RetIndex("SZ1")
	EndIf

	If cArqSX5 <> ""
		dbSelectArea(cArqSX5)
		dbSetOrder(cIndSX5)
		dbGoTo(cRegSX5)
		RetIndex("SX5")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return(wPreco)
