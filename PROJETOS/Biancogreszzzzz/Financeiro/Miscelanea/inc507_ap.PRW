#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function INC507()

	SetPrvt("CPERG,AARRAY,NLASTKEY,LABORTPRINT,WPERG,WFILIAL")
	SetPrvt("ACAMPOS,CQUERY,CARQ,WPREFAT,WNATFAT,WNUM,WUFCLI,WPORCJUR,WBAIDEL")
	SetPrvt("WCLIENTE,WLOJA,WVEND1,WVEND2,WVEND3,WVEND4,WVEND5,WNOMCLI,WPORTADO,WEMISSAO,WEMIS1,WRECR")
	SetPrvt("WVENCTO,WVENCREA,WVALOR,NCONT,WNUMFAT,I")
	SetPrvt("A,_SALIAS,AREGS,J,")

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ INC507   ³ Autor ³ Joao Carlos Andrade   ³ Data ³ 19.09.00 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Geracao Automatica de Fatura a Receber                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Ceramica Incesa                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	cPerg		:= "INC507"
	aArray		:= {}
	nLastKey	:= 0
	lAbortPrint := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        // Da Emissao                                ³
	//³ mv_par02        // Ate a Emissao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wPerg := pergunte("INC507",.t.)
	If ! wPerg
		Return
	EndIf

	If nLastKey == 27
		Set Filter To
		Return
	Endif

	Processa({|| R507GERA() })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R507GERA ³ Autor ³ Joao Carlos de Andrade³ Data ³ 19.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Processamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ INC507                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R507GERA()

	Local i
	Private Enter	:= CHR(13)+CHR(10)

	nCli	:= "000000"
	nVerCli := "000000"
	nVerLj	:= "00"
	wParc	:= "A"

	DbSelectArea("SE1")
	DbSetOrder(1)
	wFilial := xFilial("SE1")

	cQuery := "SELECT	A.E1_FILIAL, A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, 							" + Enter
	cQuery += "		A.E1_TIPO, A.E1_NATUREZ, A.E1_CLIENTE, A.E1_LOJA, A.E1_NOMCLI, 					" + Enter
	cQuery += "		A.E1_EMISSAO, A.E1_VENCTO, A.E1_VENCREA, A.E1_VALOR, 							" + Enter	
	cQuery += "		A.E1_EMIS1, A.E1_SITUACA, A.E1_SALDO, A.E1_VENCORI, 							" + Enter
	cQuery += "		A.E1_MOEDA, A.E1_FATURA, A.E1_OCORREN, A.E1_YUFCLI, A.E1_YBAIDEL, A.E1_YRECR, 	" + Enter
	cQuery += "		A.E1_VEND1, A.E1_VEND2, A.E1_VEND3, A.E1_VEND4, A.E1_VEND5, A.E1_VLCRUZ, A.E1_PORCJUR, A.E1_STATUS, A.E1_ORIGEM, " + Enter
	cQuery += "		A.E1_OK, A.E1_FATPREF, A.E1_DTFATUR, A.E1_YFORMA, A.E1_PORTADO, B.A1_YGERFAT, A.E1_YEMP " + Enter
	cQuery += "FROM " + retsqlname("SE1") + " A, "+retsqlname("SA1") + " B 	" + Enter
	cQuery += "WHERE	A.E1_FILIAL  = '"+xFilial("SE1")+"' 		AND " + Enter
	cQuery += " 		B.A1_FILIAL  = '"+xFilial("SA1")+"' 		AND " + Enter
	cQuery += " 		A.E1_EMISSAO >= '" + Dtos(mv_par01) + "' 	AND " + Enter
	cQuery += " 		A.E1_EMISSAO <= '" + Dtos(mv_par02) + "' 	AND " + Enter
	cQuery += " 		A.E1_NATUREZ NOT IN ('1131','1230')			AND " + Enter   
	cQuery += " 		A.E1_CLIENTE IN ('000434','000484')			AND " + Enter   
	cQuery += " 		A.E1_YFORMA  =  '1'			AND " + Enter
	cQuery += " 		A.E1_SITUACA <> '1'			AND " + Enter
	cQuery += " 		A.E1_TIPO    = 'NF'			AND " + Enter 
	cQuery += " 		A.E1_SALDO   > 0			AND " + Enter
	cQuery += " 		A.E1_CLIENTE = B.A1_COD		AND " + Enter
	cQuery += " 		A.E1_LOJA    = B.A1_LOJA	AND " + Enter
	cQuery += " 		B.A1_YGERFAT = 'S'			AND " + Enter
	cQuery += " 		A.D_E_L_E_T_ = ''			AND " + Enter
	cQuery += " 		B.D_E_L_E_T_ = ''				" + Enter
	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY cQuery ALIAS "TRB" NEW

	cArq := CriaTrab(NIL,.F.)
	Copy To &cArq

	dbSelectArea("TRB")
	dbCloseArea()
	dbUseArea(.T.,,cArq,"TRB",.T.)
	//IndRegua("TRB",cArq,"E1_FILIAL+E1_VENCTO+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM",,,"Selecionando Registros...")
	IndRegua("TRB",cArq,"E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_VENCTO+E1_PREFIXO+E1_NUM",,,"Selecionando Registros...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento da Rotina                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	DbGotop()
	ProcRegua(RecCount())

	While ! Eof()
		wPreFat   := E1_PREFIXO      // Prefixo da Fatura
		wNatFat   := E1_NATUREZ      // Natureza da Fatura
		wNum      := E1_NUM
		wCliente  := E1_CLIENTE
		wLoja     := E1_LOJA   
		wVend1	  := E1_VEND1
		wVend2	  := E1_VEND2	
		wVend3	  := E1_VEND3
		wVend4	  := E1_VEND4	
		wVend5	  := E1_VEND5		
		wNomCli   := E1_NOMCLI                                             
		wPrefixo  := E1_PREFIXO  
		wUfCli	  := E1_YUFCLI
		wPorcJur  := E1_PORCJUR
		wBaiDel   := E1_YBAIDEL 
		wRecr	  	:= E1_YRECR
		wForma	  := E1_YFORMA
		wEmp	  	:= E1_YEMP

		//Verifica se o Portador existe no Titulo
		If Empty(TRB->E1_PORTADO)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+TRB->E1_CLIENTE+TRB->E1_LOJA)
			wPortado  := SA1->A1_BCO1
		Else
			wPortado  := TRB->E1_PORTADO
		EndIf

		dbSelectArea("TRB")
		wEmissao  := DdataBase
		wEmis1    := DdataBase
		wVencto   := Ctod(Subs(E1_VENCTO,7,2)+"/"+Subs(E1_VENCTO,5,2)+"/"+Subs(E1_VENCTO,3,2))
		wVencrea  := Ctod(Subs(E1_VENCREA,7,2)+"/"+Subs(E1_VENCREA,5,2)+"/"+Subs(E1_VENCREA,3,2))
		wValor    := 0
		nCont     := 0

		//Gera faturas apenas para os mesmos CLIENTE / LOJA / VENCIMENTO / VENDEDOR
		While ! Eof() .and. wCliente == E1_CLIENTE .and. wLoja == E1_LOJA .and. Dtos(wVencto) == E1_VENCTO .and. wPrefixo == E1_PREFIXO .and. wVend1 == E1_VEND1
			IncProc()
			If Interrupcao(@lAbortPrint)
				Exit
			Endif
			nCont	:= nCont + 1
			wValor	:= wValor + E1_VALOR
			AADD(aArray,{E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO})
			nVerCli := E1_CLIENTE
			nVerLj	:= E1_LOJA
			DbSkip()
		Enddo

		If nCont > 1 

			//Verifica Numeracao da Fatura
			If nCli <> nVerCli 
				wNumFat := GetMv("MV_NUMFAT")
				wNumFat := StrZero(Val(wNumFat)+1,6,0)
				wParc	:= "A"
			EndIf

			//Verifica se vai gerar mais de UMA parcela
			cSql := "SELECT E1_CLIENTE, E1_LOJA, COUNT(*) QUANT 				" + Enter
			cSql += "FROM 														" + Enter
			cSql += "	(SELECT E1_CLIENTE, E1_LOJA, E1_VENCTO, COUNT(*) QUANT	" + Enter
			cSql += "	FROM  "+RetSqlName("SE1")+" A, "+RetSqlName("SA1")+" B 	" + Enter
			cSql += "	WHERE 	A.E1_FILIAL  = '"+xFilial("SE1")+"'		AND	" + Enter
			cSql += "			B.A1_FILIAL  = '"+xFilial("SA1")+"'		AND	" + Enter
			cSql += "			A.E1_EMISSAO >= '"+Dtos(mv_par01)+"'	AND	" + Enter
			cSql += "			A.E1_EMISSAO <= '"+Dtos(mv_par02)+"' 	AND	" + Enter
			cSql += "			A.E1_CLIENTE =  '"+nVerCli+"'			AND	" + Enter
			cSql += "			A.E1_LOJA	 =  '"+nVerLj+"'			AND	" + Enter
			cSql += "			A.E1_NATUREZ NOT IN ('1131','1230')	AND " + Enter
			cSql += "			A.E1_YFORMA  =  '1'			AND 		" + Enter
			cSql += "			A.E1_SITUACA <> '1'			AND 		" + Enter
			cSql += "			A.E1_TIPO    = 'NF'			AND  		" + Enter
			cSql += "			A.E1_CLIENTE = B.A1_COD		AND 		" + Enter
			cSql += "			A.E1_LOJA    = B.A1_LOJA	AND 		" + Enter
			cSql += "			B.A1_YGERFAT = 'S'			AND 		" + Enter
			cSql += "			A.D_E_L_E_T_ = ''			AND 		" + Enter
			cSql += "			B.D_E_L_E_T_ = ''						" + Enter
			cSql += "	GROUP BY E1_CLIENTE, E1_LOJA, E1_VENCTO			" + Enter
			cSql += "	HAVING COUNT(*) > 1) TMP						" + Enter
			cSql += "GROUP BY E1_CLIENTE, E1_LOJA						" + Enter
			If chkfile("R001")
				dbSelectArea("R001")
				dbCloseArea()
			EndIf
			TcQuery cSql ALIAS "R001" NEW

			//Verifica Sequencia da Parcela
			If R001->QUANT > 1
				If nCli == nVerCli 
					wParc	:= Soma1(wParc,,.T.)					
				EndIf
			Else
				wParc	:= ""
			EndIf
			nCli := nVerCli 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Fatura                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SE1")
			RecLock("SE1",.T.)
			SE1->E1_FILIAL   	:= wFilial
			SE1->E1_PREFIXO  	:= wPrefixo //wPreFat
			SE1->E1_NUM      	:= wNumFat
			SE1->E1_PARCELA	 	:= wParc
			SE1->E1_TIPO     	:= "FT"
			SE1->E1_NATUREZ  	:= wNatFat
			SE1->E1_CLIENTE  	:= wCliente
			SE1->E1_LOJA     	:= wLoja
			SE1->E1_NOMCLI   	:= wNomCli
			SE1->E1_YUFCLI	 	:= wUfCli
			SE1->E1_YFORMA   	:= wForma //"1" Alterado conforme solicitacao do Sr. Clebes, o sistema deve considerar a forma de pagto do titulo original
			SE1->E1_EMISSAO  	:= dDataBase
			SE1->E1_VENCTO   	:= wVencto
			SE1->E1_VENCREA  	:= wVencrea
			SE1->E1_VALOR    	:= wValor
			SE1->E1_VEND1	 		:= wVend1
			SE1->E1_VEND2	 		:= wVend2
			SE1->E1_VEND3	 		:= wVend3
			SE1->E1_VEND4	 		:= wVend4
			SE1->E1_VEND5	 		:= wVend5
			SE1->E1_EMIS1    	:= dDataBase
			SE1->E1_SITUACA  	:= "0"
			SE1->E1_SALDO    	:= wValor
			SE1->E1_PORCJUR  	:= wPorcJur //GetMv("MV_TXPER")
			SE1->E1_VENCORI  	:= wVencto
			SE1->E1_MOEDA    	:= 1
			SE1->E1_FATURA   	:= "NOTFAT"
			SE1->E1_OCORREN  	:= "01"
			SE1->E1_VLCRUZ   	:= wValor
			SE1->E1_STATUS   	:= "A"
			SE1->E1_ORIGEM   	:= "FINA280"
			SE1->E1_PORTADO  	:= wPortado 
			SE1->E1_YBAIDEL  	:= wBaiDel
			SE1->E1_YRECR	 	:= wRecr   
			SE1->E1_FILORIG  	:= wFilial
			SE1->E1_YEMP	 	:= wEmp
			SE1->E1_YCLASSE		:= "5"

			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Titulos                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i := 1 to Len(aArray)
				DbSelectArea("SE1")
				DbSetOrder(1)
				If DbSeek(aArray[i,1]+aArray[i,2]+aArray[i,3]+aArray[i,4]+aArray[i,5],.F.)
					RecLock("SE1",.F.)
					SE1->E1_BAIXA   := dDataBase
					SE1->E1_MOVIMEN := dDataBase
					SE1->E1_DTFATUR := dDataBase
					SE1->E1_SALDO   := 0
					SE1->E1_VALLIQ  := SE1->E1_VALOR
					SE1->E1_FATPREF := wPreFat
					SE1->E1_FATURA  := wNumFat
					SE1->E1_OK      := "ok"
					SE1->E1_STATUS  := "B"
					SE1->E1_FLAGFAT := "S"
					SE1->E1_TIPOFAT := "FT"

					MsUnLock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera Movimentacao Bancaria                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					DbSelectArea("SE5")
					DbSetOrder(1)
					RecLock("SE5",.T.)
					SE5->E5_FILIAL	:= wFilial
					SE5->E5_DATA	:= dDataBase 
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_VALOR	:= SE1->E1_VALOR
					SE5->E5_NATUREZ	:= wNatFat
					SE5->E5_RECPAG	:= "R"
					SE5->E5_BENEF	:= SE1->E1_NOMCLI
					SE5->E5_HISTOR	:= "Bx.Emis.Fat."+wNumFat
					SE5->E5_TIPODOC	:= "BA"
					SE5->E5_VLMOED2	:= SE1->E1_VALOR
					SE5->E5_LA		:= "S"		
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE		
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_DTDIGIT	:= dDataBase 
					SE5->E5_MOTBX	:= "FAT"
					SE5->E5_SEQ		:= "01"
					SE5->E5_DTDISPO	:= dDataBase 	
					SE5->E5_FILORIG	:= cFilAnt		
					MsUnLock()

				Endif
			Next

			DbSelectArea("SX6")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD := wNumFat
			MsUnLock()

			DbSelectArea("TRB")
			aArray := {}
			nCont  := 0

		Else
			aArray := {}
		Endif
	End

	MS_FLUSH()

	DbSelectArea("TRB")
	DbCloseArea()
	If file(cArq+".DBF")
		ferase(cArq+".DBF")
	Endif

Return