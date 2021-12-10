#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

// IDENTIFICADORES DE LINHA
#DEFINE LIN1 "LIN1"
#DEFINE LIN2 "LIN2"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN 100

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Informações Complementares da Nota Fiscal de Saída"
#DEFINE TIT_WND_NFS "Nota Fiscal de Saída:"
#DEFINE TIT_WND_INF_COM "Informações Complementares:"


/*/{Protheus.doc} BIAF026
@description Tela de informações complementares apos o documento de saida
@author Tiago Rossini
@since 24/02/2015
@version undefined
@type function
/*/
User Function BIAF026()

	Local cSQL := ""
	Local _cTabZZV
	Local _cAliasTmp
	Local ra

	Private fh_Esc := .F.
	Private CARQANT, CINDANT, CREGANT, CARQSE1, CARQSF2, CARQSC9
	Private CARQSC5, CARQSM2, CARQSC6, CARQSA4, CARQSB1, CARQSD2
	Private WSERIE, WPLACA, WPLACAPES, WDTSAIDA, WTIME
	Private WUF, WVOLUME, WESPECIE, WMARCA, WNUMERO, WMOTOR
	Private WPESOBR, WPESOLIQ, WPESOLIQC
	Private WNOTA, XWPESOBR, XWPESOLIQ, WPESOEMB, WBASECALC, WICMS
	Private WSEGURO, CINDSF2, CREGSF2, CINDSD2, CREGSD2, WROMAN
	Private CINDSC9, CREGSC9, CINDSC6, CREGSC6, CINDSB1, CREGSB1
	Private LIQC, _PESO, _VOLU, CINDSC5, CREGSC5, WTRANSP, WTPFRETE, WVT, WSALDO
	Private CINDSA4, CREGSA4, CARQSA1, CINDSA1, CREGSA1, CINDSE1
	Private CREGSE1, WFILIAL, WPESOBRAC, WPESOLIQAC, OLDAREA, OLDORDEM
	Private TLIQPROD, TLIQNOTA, WSEMDUPL, APERMECOM, AVALCOM, D2ORDEM
	Private E1ORDEM, CQUERY, CCONDQRY, WMSG, WTOTREGS, NRECNO, CMUN, CEST
	Private QUANT_PALET := 0
	Private aPedido := {}
	Private oDlg
	Private oBtnBar
	Private oLayer
	Private oPnlNfs
	Private oPnlInfC
	Private oFntBold := TFont():New('Arial',,14,,.T.)
	Private wCliente, wLoja, wNome, wNomTran, wFreteAut, wBasFreteAut, wIcmFreteAut	
	Private WMSGPAD   //Mensagem Padrão
	Private WMSGLIV1  //Mensagem Livre 01
	Private WMSGLIV2  //Mensagem Livre 02
	//Private nTransp
	//Private nTpFrete

	Private _IsAuto := Type("_XCRGATFAT") <> "U" .And. _XCRGATFAT

	//Variaveis de Posicionamento
	aAreaGer:= GetArea()

	cArqANT := Alias()
	cIndANT := IndexOrd()
	cRegANT := Recno()

	dbSelectArea("SC5")
	cArqSC5 := Alias()
	cIndSC5 := IndexOrd()
	cRegSC5 := Recno()

	dbSelectArea("SC6")
	cArqSC6 := Alias()
	cIndSC6 := IndexOrd()
	cRegSC6 := Recno()

	dbSelectArea("SC9")
	cArqSC9 := Alias()
	cIndSC9 := IndexOrd()
	cRegSC9 := Recno()

	dbSelectArea("SF2")
	cArqSF2 := Alias()
	cIndSF2 := IndexOrd()
	cRegSF2 := Recno()

	dbSelectArea("SD2")
	cArqSD2 := Alias()
	cIndSD2 := IndexOrd()
	cRegSD2 := Recno()

	dbSelectArea("SE1")
	cArqSE1 := Alias()
	cIndSE1 := IndexOrd()
	cRegSE1 := Recno()

	dbSelectArea("SM2")
	cArqSM2 := Alias()
	cIndSM2 := IndexOrd()
	cRegSM2 := Recno()

	dbSelectArea("SA4")
	cArqSA4 := Alias()
	cIndSA4 := IndexOrd()
	cRegSA4 := Recno()

	dbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	dbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	// Atualizar o campo E1_YRECR com a informacao do pedido de compras
	fAtuSE1()

	// Corrige Data Vencimento GUIA GNRE
	fAcertaSF6()

	//Posiciona no Cadastro de Cliente
	If SF2->F2_TIPO $ "N_C"
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
	EndIf

	lOk := .T.

	nPedido      := Space(6)
	wSerie		 := Space(3)
	wPlaca		 := Space(7)
	wPlacaPES	 := Space(7)
	wQtdPes	 := "1"
	wDtSaida 	 := DDATABASE
	wTime 		 := "      "
	wUF			 := Space(2)
	wVolume		 := 0.00
	wEspecie 	 := "CAIXAS"
	wMarca		 := Space(10)
	wNumero		 := Space(15)
	wMotor		 := Space(50)
	wPesoBr		 := 0.000
	wPesoLiq 	 := 0.000
	wPesoLiqC	 := 0.000
	wMSGPad		 := Space(3)
	wMSGLiv1 	 := Space(100)
	wMSGLiv2 	 := Space(100)
	wNota 		 := Space(6)
	xwPesoBr 	 := 0
	xwPesoLiq	 := 0
	wPesoEmb 	 := 0
	wBaseCalc	 := 0
	wIcms 		 := 0
	wBaseCalc1	 := 0
	wIcms1 		 := 0
	wSeguro		 := 0
	wCliente := Space(6)
	wLoja := Space(2)
	wNome := Space(60)
	wNomTran := Space(60)
	wFreteAut := Space(3)
	wBasFreteAut := 0
	wIcmFreteAut := 0

	//Definicao da Marca Geral por Empresa.
	//Ticket 11834 - Projeto Consolidacao - Incluida a serie 2 para marca Incesa na empresa 01
	If cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "1" //Biancogres
		wMarca := "BIANCOGRES"
	ElseIf cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "2" //Incesa
		wMarca := "INCESA"
	ElseIf cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "4" //Pegasus
		wMarca := "PEGASUS"
	ElseIf cEmpAnt == "05" .and. Alltrim(SF2->F2_SERIE) == "1" //Incesa
		wMarca := "INCESA"
	ElseIf cEmpAnt == "05" .and. Alltrim(SF2->F2_SERIE) == "2" //Bellacasa
		wMarca := "BELLACASA"
	ElseIf cEmpAnt == "05" .and. Alltrim(SF2->F2_SERIE) == "3" //Mundialli
		wMarca := "MUNDIALLI"
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "1" //Biancogres
		wMarca := "BIANCOGRES"                                                       
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "2" //Incesa
		wMarca := "INCESA"
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "3" //Bellacasa
		wMarca := "BELLACASA"
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "4" //Mundialli
		wMarca := "MUNDIALLI"			
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "6" //Pegagus
		wMarca := "PEGASUS"
	ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "7" //Biancogres Vinilico
		wMarca := "BIANCOGRES VINILICO"
	EndIf


	//OS 3577-16 - Copiar dados da CARGA para o Faturamento  - Fernando/Facile
	IF (Type("cQNumCarga") <> "U") .And. !Empty(cQNumCarga) .And. (SF2->F2_CLIENTE <> "010064") 

		_cTabZZV := "% ZZV"+AllTrim(CEMPANT)+"0 %"
		If AllTrim(CEMPANT) == "07"
			IF (Type("cEmpCarga") <> "U") .And. !Empty(cEmpCarga)
				_cTabZZV := "% ZZV"+AllTrim(cEmpCarga)+"0 %"
			ENDIF
		EndIf

		_cAliasTmp := GetNextAlias()
		BeginSql Alias _cAliasTmp
			SELECT ZZV_PLACA, ZZV_PL_UF FROM %Exp:_cTabZZV% WHERE ZZV_CARGA = %Exp:cQNumCarga% AND %NotDel%
		EndSql

		If !(_cAliasTmp)->(Eof())

			wPlaca 	:= (_cAliasTmp)->ZZV_PLACA
			wUF		:= (_cAliasTmp)->ZZV_PL_UF

		EndIf
		(_cAliasTmp)->(DbCloseArea())

	ENDIF	

	//BUSCANDO O SF2 ALTERACAO BRUNO
	cSQL := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, SC5.C5_PEDEXP "
	cSQL += "FROM "+ RetSqlName("SF2")+" SF2, "+ RetSqlName("SC5")+" SC5 "
	cSQL += "WHERE	SF2.F2_FILIAL = '"+ xFilial("SF2") +"' AND "
	cSQL += "	SF2.F2_DOC 	= '"+ SC6->C6_NOTA +"'	 AND 	"
	cSQL += "	SF2.F2_CLIENTE	= '"+ SC6->C6_CLI +"'  	 AND 	 "
	cSQL += "	SF2.F2_LOJA	= '"+ SC6->C6_LOJA +"'	 	 AND 	"
	cSQL += "	SC5.C5_NUM	= '"+ SC6->C6_NUM +"'	 AND "
	cSQL += "	SC5.C5_CLIENTE	= SF2.F2_CLIENTE AND "
	cSQL += "	SC5.C5_LOJACLI	= SF2.F2_LOJA	 AND 	 "
	cSQL += "	SF2.D_E_L_E_T_ 	= '' 		 AND "
	cSQL += "	SC5.D_E_L_E_T_ 	= ''	 "
	If chkfile("_SF2")
		dbSelectArea("_SF2")
		dbCloseArea()
	EndIf
	TCQuery cSQL Alias "_SF2" New

	//Calculo do Volume
	DbSelectArea("SD2")
	DbSetOrder(3)
	IF _SF2->(eof()) .OR. EMPTY(_SF2->C5_PEDEXP)
		_F2_DOC   	:= SF2->F2_DOC
		_F2_SERIE 	:= SF2->F2_SERIE
		_F2_CLIENTE := SF2->F2_CLIENTE
		_F2_LOJA	:= SF2->F2_LOJA
	ELSE
		_F2_DOC   	:= _SF2->F2_DOC
		_F2_SERIE 	:= _SF2->F2_SERIE
		_F2_CLIENTE := _SF2->F2_CLIENTE
		_F2_LOJA	:= _SF2->F2_LOJA
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSeek(xFilial("SF2")+_F2_DOC+_F2_SERIE+_F2_CLIENTE+_F2_LOJA)
	END IF

	If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)

		QUANT_PALET := 0 // MADALENO: ZERANDO A VARIAVEL PARA RODAR TODOS OS ITENS DA  NOTA PARA ACUMULAR A QUANT DE PALETTS

		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
		While ! Eof() .And.;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	== SD2->D2_LOJA

			//Grava no Campo D2_YIMPNF o conteudo do C6_YIMPNF
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)
			RecLock("SD2",.F.)
			SD2->D2_YIMPNF := SC6->C6_YIMPNF
			SD2->(MsUnLock())

			//Acumula o Valor do Seguro do Frete
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
			If SC5->C5_VLRFRET > 0
				wSeguro := wSeguro + (SD2->D2_QUANT * SC5->C5_VLRFRET)
			EndIf

			//MADALENO: ACUMULA A QUANTIDADE DE PALETTS
			QUANT_PALET += U_NUMPALETES(  SD2->D2_COD  ,  SD2->D2_QUANT , SD2->D2_LOTECTL)

			//Calculo do Peso Liquido
			DbSelectArea("SB1")
			DbSetOrder(1)
			If Dbseek(xFilial("SB1")+SD2->D2_COD)

				IF cEmpAnt == "02"
					aCODPRODUTO := SB1->B1_COD
					sPESO	    := SB1->B1_PESO
					sPESEMB     := SB1->B1_YPESEMB
					sDIVPA	    := SB1->B1_YDIVPA
				ELSE
					aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
					cSQLL := ""
					cSQLL := "SELECT * FROM ZZ9010 "
					cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
					cSQLL += "		ZZ9_LOTE = '" +SD2->D2_LOTECTL+ "' AND "
					cSQLL += "		D_E_L_E_T_ = '' "
					IF chkfile("_ZZ9")
						dbSelectArea("_ZZ9")
						dbCloseArea()
					ENDIF
					TCQuery cSQLL Alias "_ZZ9" New
					IF ! _ZZ9->(EOF())
						sPESEMB := _ZZ9->ZZ9_PESEMB
						sPESO	:= _ZZ9->ZZ9_PESO
						sDIVPA	:= _ZZ9->ZZ9_DIVPA
					ELSE
						sPESO	:= SB1->B1_PESO
						sPESEMB := SB1->B1_YPESEMB
						sDIVPA	:= SB1->B1_YDIVPA						
					ENDIF
				ENDIF

				LiqC := ( SD2->D2_QUANT  * sPESO )
				wPesoLiq := wPesoLiq + LiqC
				If SB1->B1_TIPCONV == "M"
					_peso  := (( SD2->D2_QUANT * SB1->B1_CONV ) * sPESEMB ) + LiqC
					_volu  := ( SD2->D2_QUANT * SB1->B1_CONV )
				Else
					_peso  := (( SD2->D2_QUANT / SB1->B1_CONV ) * sPESEMB ) + LiqC
					_volu  := ( SD2->D2_QUANT / SB1->B1_CONV )
				EndIf
				wPesoBr := wPesoBr + _peso

				//Calcula Qtd de Volumes da NF
				wVolume := wVolume + _volu

				//Define Especie e Marca para produtos do Tipo CACO	(Nao faz para a Incesa)
				If !cEmpAnt $ "02"
					If SB1->B1_YCLASSE == "5"
						wEspecie := "VOLUME"
						wMarca	 := ""
					EndIf
				EndIf

			EndIf

			//Grava no Campo D2_CCUSTO/D2_CLVL/D2_ITEMCC o conteudo do C5_YCC/C5_YCLVL/C5_YITEMCT
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)

			//Definicao da Marca Detalhado - Por Empresa e Linha - OS 0364-12 - Claudeir  
			//Correção da Gravação da Marca - OS 1411-16 - Valeria
			//Ticket 11834 - Projeto Consolidacao - Incluida a serie 2 para marca Incesa na empresa 01
			If cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "1" //Biancogres
				wMarca := "BIANCOGRES"
			ElseIf cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "2" //Incesa
				wMarca := "INCESA"
			ElseIf cEmpAnt == "01" .and. Alltrim(SF2->F2_SERIE) == "4" //PEGASUS
				wMarca := "PEGASUS"
			ElseIf cempant == "05" .and. Alltrim(SF2->F2_SERIE) == "1" //Incesa
				wMarca := "INCESA"
			ElseIf cempant == "05" .and. Alltrim(SF2->F2_SERIE) == "2" //Bellacasa
				wMarca := "BELLACASA"
			ElseIf cempant == "05" .and. Alltrim(SF2->F2_SERIE) == "3" //Mundialli
				wMarca := "MUNDIALLI"
			ElseIf cempant == "07" .and. Alltrim(SF2->F2_SERIE) == "1" //Biancogres
				wMarca := "BIANCOGRES"                                                       
			ElseIf cempant == "07" .and. Alltrim(SF2->F2_SERIE) == "2" //Incesa
				wMarca := "INCESA"
			ElseIf cempant == "07" .and. Alltrim(SF2->F2_SERIE) == "3" //Bellacasa
				wMarca := "BELLACASA"
			ElseIf cempant == "07" .and. Alltrim(SF2->F2_SERIE) == "4" //Mundialli
				wMarca := "MUNDIALLI"			
			ElseIf cempant == "07" .and. Alltrim(SF2->F2_SERIE) == "6" //Pegasus
				wMarca := "PEGASUS"	
			ElseIf cEmpAnt == "07" .and. Alltrim(SF2->F2_SERIE) == "7" //Biancogres Vinilico
				wMarca := "BIANCOGRES VINILICO"			
			EndIf

			If Alltrim(SC5->C5_YFLAG) == "2" 		//Local de Entrega no Pedido
				cEst	:= SC5->C5_YEST
				cMun	:= SC5->C5_YCODMUN 			//SC5->C5_YMUN
			ElseIf Alltrim(SF2->F2_TIPO) $ "DB"		//Posiciona no Fornecedor
				DbSelectArea("SA2")
				DbSetOrder(1)
				If DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
					cEst	:= SA2->A2_EST
					cMun	:= SA2->A2_COD_MUN 		//SA2->A2_MUN
				EndIf
			Else
				cEst	:= SA1->A1_EST			 											 //Posiciona no Cliente
				cMun	:= SA1->A1_COD_MUN 			//SA1->A1_MUN							 //Posiciona no Cliente
			EndIf

			dbSelectArea("SD2")
			RecLock("SD2",.F.)
			SD2->D2_CCUSTO := SC5->C5_YCC
			SD2->D2_CLVL   := SC5->C5_YCLVL
			SD2->D2_ITEMCC := SC5->C5_YITEMCT
			SD2->(MsUnLock())

			DbSelectArea("SD2")
			DbSetOrder(3)
			dbSkip()
		EndDo
	Else
		MSGBOX("NAO CADASTRADO NO SD2")
	EndIf

	//Carrega os pedidos utilizados na NF
	aPedido := U_fBuscaPedido(SF2->F2_FILIAL,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA)

	//Roda todos pedidos
	For ra := 1 to Len(aPedido)

		If Empty(nPedido)
			nPedido := (aPedido[ra])
		Else
			nPedido := nPedido+","+(aPedido[ra])
		EndIf

		//Dados do Rodape da Nota Fiscal
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+aPedido[ra]))	

		wNumero	  := SC5->C5_YNUMERO
		wMSGPad	  := SC5->C5_MENPAD

		wMSGLiv1  := Subs(SC5->C5_MENNOTA, 1, 100)
		wMSGLiv2  := Subs(SC5->C5_MENNOTA, 101, 100)

		wMSGLiv1  := Subs(SC5->C5_MENNOTA, 1, 100)
		wMSGLiv2  := Subs(SC5->C5_MENNOTA, 101, 100)

		//Tratamento para pedidos já gravados.
		If !(Alltrim(SC5->C5_TIPO) $ "D_B")
			If SC5->C5_CLIENTE == "015966" 
				wMSGLiv1  := "MVA cobrado em 53% por meio dos Mandados de Segurança: "
				wMSGLiv2  := "NR: 0060128-35.2010.8.19.0000 e NR: 0060127-50.2010.8.19.0000"
			ElseIf SC5->C5_CLIENTE == "012366" // Tiago Rossini Coradini - 14/03/16 - OS: 0039-16 - Mayara Pimentel - Gravar mensagem especial para o Cliente: 012366 - HOME CENTER TENDTUDO	
				wMSGLiv1  := "O ICMS devido por substituição tributária será recolhido pelo destinatário até o dia 15 do mês"
				wMSGLiv2  := "subsequente - Procedimento autorizado pela SEFAZ - SP - Regime Especial - Processo UA 13456-581479-2008"
			Else
				wMSGLiv1  := Subs(SC5->C5_MENNOTA,1,100)
				wMSGLiv2  := Subs(SC5->C5_MENNOTA,101,100)
			EndIf
		EndIf 

	Next ra

	//Localiza a Liberacao do Pedido e do Romaneio correspondente a NF atual.
	cCondQry  := ""
	cCondQry  += "SELECT C9_PEDIDO, C9_DATALIB, C9_AGREG "
	cCondQry  += "FROM " +RetSQLName("SC9")+" SC9 "
	cCondQry  += "WHERE "
	cCondQry  += " SC9.C9_FILIAL  = '"+xFilial("SC9")+"' AND "
	cCondQry  += " SC9.C9_NFISCAL = '"+SF2->F2_DOC+"'    AND "
	cCondQry  += " SC9.C9_SERIENF = '"+SF2->F2_SERIE+"'  AND "
	cCondQry  += " SC9.D_E_L_E_T_ = '' "
	TCQuery cCondQry Alias "X" New
	wRoman	:= substr(X->C9_DATALIB,1,4)+X->C9_AGREG
	X->(DbCloseArea())

	wTransp	  := IIf(cEmpAnt <> "07" .And. SF2->F2_CLIENTE == "010064" .And. !(SF2->F2_TIPO $ "D_B"), "", nTransp) //Autonomo - Alterado para utilizar variavel do Tipo de Frete 08/09/09 Ranisses
	wTpFrete  := IIf(cEmpAnt <> "07" .And. SF2->F2_CLIENTE == "010064" .And. !(SF2->F2_TIPO $ "D_B"), 2, nTpFrete)  
	wVt		  := 0
	wBaseCalc := 0
	wIcms 	  := 0

	//GRAVA EMPRESA ORIGINAL
	IF !cEmpAnt $ "02"
		DbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_YEMP	:= SC5->C5_YEMP
		SF2->F2_YRESULT	:= SC5->C5_YRESULT	//GRAVA RESULTADO
		SF2->F2_YRESUL2	:= SC5->C5_YRESUL2
		SF2->(MsUnLock())
		dbCommit()
	ENDIF

	wNota := SF2->F2_DOC
	wSerie := SF2->F2_SERIE

	// Tiago Rossini Coradini - 20/11/15 - OS: 2766-15 - Dalvina Ferreira - Atualização dos componentes de tela
	wCliente := SF2->F2_CLIENTE
	wLoja := SF2->F2_LOJA
	wNome := AllTrim(Posicione("SA1", 1, xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, "A1_NOME"))

	If Empty(AllTrim(wTransp))
		wNomTran := "SEM FRETE"
	Else
		wNomTran := wTransp + "-" + AllTrim(Posicione("SA4", 1, xFilial("SA4") + wTransp, "A4_NOME"))
	EndIf

	wFreteAut := If (wTpFrete == 1, "Sim", "Não")
	wBasFreteAut := Round(SF2->F2_FRETAUT, 2)
	wIcmFreteAut := Round(SF2->F2_ICMAUTO, 2)


	IF (_IsAuto)

		fConfirma()

	ELSE

		// Array com as coordenadas da janela
		aCoors := FWGetDialogSize(oMainWnd)

		// Cria Dialog
		oDlg := MsDialog():New(aCoors[1], aCoors[2], 500, 750, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
		oDlg:cName := "oDlg"
		oDlg:lCentered := .T.
		oDlg:lEscClose := .F.
		oDlg:bValid := {|| .F. }


		// Barra de botoes
		oBtnBar := FWButtonBar():New()
		oBtnBar:Init(oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		oBtnBar:AddBtnText("OK", "OK", {|| fConfirma(oDlg) },,,CONTROL_ALIGN_RIGHT,.T.)

		// Layer
		oLayer := FWLayer():New()
		oLayer:Init(oDlg, .F., .T.)

		// Adiciona linha ao Layer
		oLayer:AddLine(LIN1, 25, .F.)
		// Adiciona coluna ao Layer
		oLayer:AddCollumn(COL, PER_COL, .T., LIN1)
		// Adiciona janela ao Layer
		oLayer:AddWindow(COL, WND, TIT_WND_NFS, 100, .F. ,.T.,, LIN1, { || })

		// Retorna paimel da janela do Layer
		oPnlNfs := oLayer:GetWinPanel(COL, WND, LIN1)

		// Numero do Documento
		oSayNumDoc := TSay():Create(oPnlNfs)
		oSayNumDoc:cName := "oSayNumDoc."
		oSayNumDoc:cCaption := "Número"
		oSayNumDoc:nLeft := 06
		oSayNumDoc:nTop := 06
		oSayNumDoc:nWidth := 45
		oSayNumDoc:nHeight := 30
		oSayNumDoc:lReadOnly := .T.
		oSayNumDoc:nClrText := CLR_HBLUE
		oSayNumDoc:oFont := oFntBold
		oSayNumDoc:cToolTip := "Número do Documento"

		oGetNumDoc := TGet():Create(oPnlNfs)
		oGetNumDoc:cName := "oGetNumDoc"
		oGetNumDoc:nLeft := 06
		oGetNumDoc:nTop := 22
		oGetNumDoc:nWidth := 65
		oGetNumDoc:nHeight := 20
		oGetNumDoc:cVariable := "wNota"
		oGetNumDoc:bSetGet := bSetGet(wNota)
		oGetNumDoc:Picture := PesqPict("SF2", "F2_DOC")
		//oGetNumDoc:lHasButton := .T.
		oGetNumDoc:cToolTip := "Número do Documento"
		oGetNumDoc:Disable()

		// Serie
		oSaySerie := TSay():Create(oPnlNfs)
		oSaySerie:cName := "oSaySerie"
		oSaySerie:cCaption := "Serie"
		oSaySerie:nLeft := 96
		oSaySerie:nTop := 06
		oSaySerie:nWidth := 40
		oSaySerie:nHeight := 20
		oSaySerie:nClrText := CLR_HBLUE
		oSaySerie:oFont := oFntBold
		oSaySerie:cToolTip := "Serie"

		oGetSerie := TGet():Create(oPnlNfs)
		oGetSerie:cName := "oGetSerie"
		oGetSerie:nLeft := 96
		oGetSerie:nTop := 22
		oGetSerie:nWidth := 65
		oGetSerie:nHeight := 20
		oGetSerie:cVariable := "wSerie"
		oGetSerie:bSetGet := bSetGet(wSerie)
		oGetSerie:Picture := PesqPict("SF2", "F2_SERIE")
		oGetSerie:cToolTip := "Série"
		oGetSerie:Disable()

		// Cliente
		oSayCliente := TSay():Create(oPnlNfs)
		oSayCliente:cName := "oSayCliente"
		oSayCliente:cCaption := "Cliente"
		oSayCliente:nLeft := 186
		oSayCliente:nTop := 06
		oSayCliente:nWidth := 65
		oSayCliente:nHeight := 30
		oSayCliente:nClrText := CLR_HBLUE
		oSayCliente:oFont := oFntBold
		oSayCliente:cToolTip := "Cliente"

		oGetCliente := TGet():Create(oPnlNfs)
		oGetCliente:cName := "oGetCliente"
		oGetCliente:nLeft := 186
		oGetCliente:nTop := 22
		oGetCliente:nWidth := 65
		oGetCliente:nHeight := 20
		oGetCliente:cVariable := "wCliente"
		oGetCliente:bSetGet := bSetGet(wCliente)
		oGetCliente:Picture := PesqPict("SA1", "A1_COD")
		oGetCliente:cToolTip := "Cliente"
		oGetCliente:Disable()

		// Loja
		oSayLoja := TSay():Create(oPnlNfs)
		oSayLoja:cName := "oSayLoja"
		oSayLoja:cCaption := "Loja"
		oSayLoja:nLeft := 276
		oSayLoja:nTop := 06
		oSayLoja:nWidth := 65
		oSayLoja:nHeight := 30
		oSayLoja:nClrText := CLR_HBLUE
		oSayLoja:oFont := oFntBold
		oSayLoja:cToolTip := "Loja"

		oGetLoja := TGet():Create(oPnlNfs)
		oGetLoja:cName := "oGetLoja"
		oGetLoja:nLeft := 276
		oGetLoja:nTop := 22
		oGetLoja:nWidth := 65
		oGetLoja:nHeight := 20
		oGetLoja:cVariable := "wLoja"
		oGetLoja:bSetGet := bSetGet(wLoja)
		oGetLoja:Picture := PesqPict("SA1", "A1_LOJA")
		oGetLoja:cToolTip := "Loja"
		oGetLoja:Disable()

		// Nome
		oSayNome := TSay():Create(oPnlNfs)
		oSayNome:cName := "oSayNome"
		oSayNome:cCaption := "Nome"
		oSayNome:nLeft := 366
		oSayNome:nTop := 06
		oSayNome:nWidth := 65
		oSayNome:nHeight := 30
		oSayNome:nClrText := CLR_HBLUE
		oSayNome:oFont := oFntBold
		oSayNome:cToolTip := "Nome do Cliente"

		oGetNome := TGet():Create(oPnlNfs)
		oGetNome:cName := "oGetNome"
		oGetNome:nLeft := 366
		oGetNome:nTop := 22
		oGetNome:nWidth := 300
		oGetNome:nHeight := 20
		oGetNome:cVariable := "wNome"
		oGetNome:bSetGet := bSetGet(wNome)
		oGetNome:Picture := PesqPict("SA1", "A1_NOME")
		oGetNome:cToolTip := "Nome do Cliente"
		oGetNome:Disable()

		// Adiciona linha ao Layer
		oLayer:AddLine(LIN2, 75, .F.)
		// Adiciona coluna ao Layer
		oLayer:AddCollumn(COL, PER_COL, .T., LIN2)
		// Adiciona janela ao Layer
		oLayer:AddWindow(COL, WND, TIT_WND_INF_COM, 100, .F. ,.T.,, LIN2, { || })

		// Retorna paimel da janela do Layer
		oPnlInfC := oLayer:GetWinPanel(COL, WND, LIN2)

		// Placa
		oSayPla := TSay():Create(oPnlInfC)
		oSayPla:cName := "oSayPla"
		oSayPla:cCaption := "Placa"
		oSayPla:nLeft := 06
		oSayPla:nTop := 06
		oSayPla:nWidth := 45
		oSayPla:nHeight := 30
		oSayPla:lReadOnly := .T.
		oSayPla:nClrText := CLR_HBLUE
		oSayPla:oFont := oFntBold
		oSayPla:cToolTip := "Placa"

		oGetPla := TGet():Create(oPnlInfC)
		oGetPla:cName := "oGetPla"
		oGetPla:nLeft := 06
		oGetPla:nTop := 22
		oGetPla:nWidth := 65
		oGetPla:nHeight := 20
		oGetPla:cVariable := "wPlaca"
		oGetPla:bSetGet := bSetGet(wPlaca)
		oGetPla:Picture := "@! AAA9999" //"@R AAA-9999"
		oGetPla:cToolTip := "Placa"

		// Placa Pesagem
		oSayPlaPes := TSay():Create(oPnlInfC)
		oSayPlaPes:cName := "oSayPlaPes"
		oSayPlaPes:cCaption := "Placa Pes"
		oSayPlaPes:nLeft := 96
		oSayPlaPes:nTop := 06
		oSayPlaPes:nWidth := 100
		oSayPlaPes:nHeight := 30
		oSayPlaPes:lReadOnly := .T.
		oSayPlaPes:nClrText := CLR_HBLUE
		oSayPlaPes:oFont := oFntBold
		oSayPlaPes:cToolTip := "Placa Pesagem"

		oGetPlaPes := TGet():Create(oPnlInfC)
		oGetPlaPes:cName := "oGetPlaPes"
		oGetPlaPes:nLeft := 96
		oGetPlaPes:nTop := 22
		oGetPlaPes:nWidth := 65
		oGetPlaPes:nHeight := 20
		oGetPlaPes:cVariable := "wPlacaPes"
		oGetPlaPes:bSetGet := bSetGet(wPlacaPes)
		oGetPlaPes:Picture := "@! AAA9999" //"@R AAA-9999"
		oGetPlaPes:cToolTip := "Placa Pesagem"

		// Quantidade Pesagem
		oSayQtdPes := TSay():Create(oPnlInfC)
		oSayQtdPes:cName := "oSayQtdPes"
		oSayQtdPes:cCaption := "Qtd. Pes"
		oSayQtdPes:nLeft := 186
		oSayQtdPes:nTop := 06
		oSayQtdPes:nWidth := 100
		oSayQtdPes:nHeight := 30
		oSayQtdPes:lReadOnly := .T.
		oSayQtdPes:nClrText := CLR_HBLUE
		oSayQtdPes:oFont := oFntBold
		oSayQtdPes:cToolTip := "Quantidade Pesagem"

		oGetQtdPes := TGet():Create(oPnlInfC)
		oGetQtdPes:cName := "oGetQtdPes"
		oGetQtdPes:nLeft := 186
		oGetQtdPes:nTop := 22
		oGetQtdPes:nWidth := 65
		oGetQtdPes:nHeight := 20
		oGetQtdPes:cVariable := "wQtdPes"
		oGetQtdPes:bSetGet := bSetGet(wQtdPes)
		oGetQtdPes:Picture := "@!"
		oGetQtdPes:cToolTip := "Quantidade Pesagem"

		// UF
		oSayUF := TSay():Create(oPnlInfC)
		oSayUF:cName := "oSayUF"
		oSayUF:cCaption := "UF Placa"
		oSayUF:nLeft := 276
		oSayUF:nTop := 06
		oSayUF:nWidth := 100
		oSayUF:nHeight := 30
		oSayUF:lReadOnly := .T.
		oSayUF:nClrText := CLR_HBLUE
		oSayUF:oFont := oFntBold
		oSayUF:cToolTip := "Informe a UF da Placa"

		oGetUF := TGet():Create(oPnlInfC)
		oGetUF:cName := "oGetUF"
		oGetUF:nLeft := 276
		oGetUF:nTop := 22
		oGetUF:nWidth := 65
		oGetUF:nHeight := 20
		oGetUF:cVariable := "wUF"
		oGetUF:bSetGet := bSetGet(wUF)
		oGetUF:Picture := "@!"
		oGetUF:cToolTip := "Informe a UF da Placa"
		oGetUF:cF3 := "12"
		oGetUF:bValid := {|| fVldUF() }

		// Transportadora
		oSayTransp := TSay():Create(oPnlInfC)
		oSayTransp:cName := "oSayTransp"
		oSayTransp:cCaption := "Transportadora / Motorista"
		oSayTransp:nLeft := 366
		oSayTransp:nTop := 06
		oSayTransp:nWidth := 200
		oSayTransp:nHeight := 30
		oSayTransp:lReadOnly := .T.
		oSayTransp:nClrText := CLR_HBLUE
		oSayTransp:oFont := oFntBold
		oSayTransp:cToolTip := "Transportadora / Motorista"

		oGetTransp := TGet():Create(oPnlInfC)
		oGetTransp:cName := "oGetTransp"
		oGetTransp:nLeft := 366
		oGetTransp:nTop := 22
		oGetTransp:nWidth := 300
		oGetTransp:nHeight := 20
		oGetTransp:cVariable := "wNomTran"
		oGetTransp:bSetGet := bSetGet(wNomTran)
		oGetTransp:Picture := "@!"
		oGetTransp:cToolTip := "Transportadora / Motorista"
		oGetTransp:Disable()

		// Frete Autonomo
		oSayFreteAut := TSay():Create(oPnlInfC)
		oSayFreteAut:cName := "oSayFreteAut"
		oSayFreteAut:cCaption := "Frete Aut"
		oSayFreteAut:nLeft := 06
		oSayFreteAut:nTop := 62
		oSayFreteAut:nWidth := 100
		oSayFreteAut:nHeight := 30
		oSayFreteAut:lReadOnly := .T.
		oSayFreteAut:nClrText := CLR_HBLUE
		oSayFreteAut:oFont := oFntBold
		oSayFreteAut:cToolTip := "Frete Autonomo"

		oGetFreteAut := TGet():Create(oPnlInfC)
		oGetFreteAut:cName := "oGetFreteAut"
		oGetFreteAut:nLeft := 06
		oGetFreteAut:nTop := 78
		oGetFreteAut:nWidth := 65
		oGetFreteAut:nHeight := 20
		oGetFreteAut:cVariable := "wFreteAut"
		oGetFreteAut:bSetGet := bSetGet(wFreteAut)
		oGetFreteAut:Picture := "@!"
		oGetFreteAut:cToolTip := "Frete Autonomo"
		oGetFreteAut:Disable()

		// Base Frete Autonomo
		oSayBasFrete := TSay():Create(oPnlInfC)
		oSayBasFrete:cName := "oSayBasFrete"
		oSayBasFrete:cCaption := "Bas Fre Au"
		oSayBasFrete:nLeft := 96
		oSayBasFrete:nTop := 62
		oSayBasFrete:nWidth := 100
		oSayBasFrete:nHeight := 30
		oSayBasFrete:lReadOnly := .T.
		oSayBasFrete:nClrText := CLR_HBLUE
		oSayBasFrete:oFont := oFntBold
		oSayBasFrete:cToolTip := "Base Frete Autonomo"

		oGetBasFrete := TGet():Create(oPnlInfC)
		oGetBasFrete:cName := "oGetBasFrete"
		oGetBasFrete:nLeft := 96
		oGetBasFrete:nTop := 78
		oGetBasFrete:nWidth := 65
		oGetBasFrete:nHeight := 20
		oGetBasFrete:cVariable := "wBasFreteAut"
		oGetBasFrete:bSetGet := bSetGet(wBasFreteAut)
		oGetBasFrete:Picture := "@E 999,999.99"
		oGetBasFrete:cToolTip := "Base Frete Autonomo"
		oGetBasFrete:Disable()

		// ICMS Frete Autonomo
		oSayIcmFrete := TSay():Create(oPnlInfC)
		oSayIcmFrete:cName := "oSayIcmFrete"
		oSayIcmFrete:cCaption := "ICM Fre Au"
		oSayIcmFrete:nLeft := 186
		oSayIcmFrete:nTop := 62
		oSayIcmFrete:nWidth := 100
		oSayIcmFrete:nHeight := 30
		oSayIcmFrete:lReadOnly := .T.
		oSayIcmFrete:nClrText := CLR_HBLUE
		oSayIcmFrete:oFont := oFntBold
		oSayIcmFrete:cToolTip := "ICMS Frete Autonomo"

		oGetIcmFrete := TGet():Create(oPnlInfC)
		oGetIcmFrete:cName := "oGetIcmFrete"
		oGetIcmFrete:nLeft := 186
		oGetIcmFrete:nTop := 78
		oGetIcmFrete:nWidth := 65
		oGetIcmFrete:nHeight := 20
		oGetIcmFrete:cVariable := "wIcmFreteAut"
		oGetIcmFrete:bSetGet := bSetGet(wIcmFreteAut)
		oGetIcmFrete:Picture := "@E 999,999.99"
		oGetIcmFrete:cToolTip := "ICMS Frete Autonomo"
		oGetIcmFrete:Disable()

		// Volume
		oSayVolume := TSay():Create(oPnlInfC)
		oSayVolume:cName := "oSayVolume"
		oSayVolume:cCaption := "Volume"
		oSayVolume:nLeft := 276
		oSayVolume:nTop := 62
		oSayVolume:nWidth := 100
		oSayVolume:nHeight := 30
		oSayVolume:lReadOnly := .T.
		oSayVolume:nClrText := CLR_HBLUE
		oSayVolume:oFont := oFntBold
		oSayVolume:cToolTip := "Volume"

		oGetVolume := TGet():Create(oPnlInfC)
		oGetVolume:cName := "oGetVolume"
		oGetVolume:nLeft := 276
		oGetVolume:nTop := 78
		oGetVolume:nWidth := 65
		oGetVolume:nHeight := 20
		oGetVolume:cVariable := "wVolume"
		oGetVolume:bSetGet := bSetGet(wVolume)
		oGetVolume:Picture := "999999"
		oGetVolume:cToolTip := "Volume"

		// Especie
		oSayEspecie := TSay():Create(oPnlInfC)
		oSayEspecie:cName := "oSayEspecie"
		oSayEspecie:cCaption := "Especie"
		oSayEspecie:nLeft := 366
		oSayEspecie:nTop := 62
		oSayEspecie:nWidth := 100
		oSayEspecie:nHeight := 30
		oSayEspecie:lReadOnly := .T.
		oSayEspecie:nClrText := CLR_HBLUE
		oSayEspecie:oFont := oFntBold
		oSayEspecie:cToolTip := "Especie"

		oGetEspecie := TGet():Create(oPnlInfC)
		oGetEspecie:cName := "oGetEspecie"
		oGetEspecie:nLeft := 366
		oGetEspecie:nTop := 78
		oGetEspecie:nWidth := 65
		oGetEspecie:nHeight := 20
		oGetEspecie:cVariable := "wEspecie"
		oGetEspecie:bSetGet := bSetGet(wEspecie)
		oGetEspecie:Picture := "@!"
		oGetEspecie:cToolTip := "Especie"

		// Marca
		oSayMarca := TSay():Create(oPnlInfC)
		oSayMarca:cName := "oSayMarca"
		oSayMarca:cCaption := "Marca"
		oSayMarca:nLeft := 456
		oSayMarca:nTop := 62
		oSayMarca:nWidth := 100
		oSayMarca:nHeight := 30
		oSayMarca:lReadOnly := .T.
		oSayMarca:nClrText := CLR_HBLUE
		oSayMarca:oFont := oFntBold
		oSayMarca:cToolTip := "Marca"

		oGetMarca := TGet():Create(oPnlInfC)
		oGetMarca:cName := "oGetMarca"
		oGetMarca:nLeft := 456
		oGetMarca:nTop := 78
		oGetMarca:nWidth := 65
		oGetMarca:nHeight := 20
		oGetMarca:cVariable := "wMarca"
		oGetMarca:bSetGet := bSetGet(wMarca)
		oGetMarca:Picture := "@!"
		oGetMarca:cToolTip := "Marca"

		// Numero
		oSayNumero := TSay():Create(oPnlInfC)
		oSayNumero:cName := "oSayNumero"
		oSayNumero:cCaption := "Numero"
		oSayNumero:nLeft := 546
		oSayNumero:nTop := 62
		oSayNumero:nWidth := 100
		oSayNumero:nHeight := 30
		oSayNumero:lReadOnly := .T.
		oSayNumero:nClrText := CLR_HBLUE
		oSayNumero:oFont := oFntBold
		oSayNumero:cToolTip := "Numero"

		oGetNumero := TGet():Create(oPnlInfC)
		oGetNumero:cName := "oGetNumero"
		oGetNumero:nLeft := 546
		oGetNumero:nTop := 78
		oGetNumero:nWidth := 65
		oGetNumero:nHeight := 20
		oGetNumero:cVariable := "wNumero"
		oGetNumero:bSetGet := bSetGet(wNumero)
		oGetNumero:Picture := "@!"
		oGetNumero:cToolTip := "Numero"

		// Peso Bruto
		oSayPesBru := TSay():Create(oPnlInfC)
		oSayPesBru:cName := "oSayPesBru"
		oSayPesBru:cCaption := "Peso Bruto"
		oSayPesBru:nLeft := 06
		oSayPesBru:nTop := 118
		oSayPesBru:nWidth := 100
		oSayPesBru:nHeight := 30
		oSayPesBru:lReadOnly := .T.
		oSayPesBru:nClrText := CLR_HBLUE
		oSayPesBru:oFont := oFntBold
		oSayPesBru:cToolTip := "Peso Bruto"

		oGetPesBru := TGet():Create(oPnlInfC)
		oGetPesBru:cName := "oGetPesBru"
		oGetPesBru:nLeft := 06
		oGetPesBru:nTop := 134
		oGetPesBru:nWidth := 156
		oGetPesBru:nHeight := 20
		oGetPesBru:cVariable := "wPesoBr"
		oGetPesBru:bSetGet := bSetGet(wPesoBr)
		oGetPesBru:Picture := "@E 999,999,999.999"
		oGetPesBru:lHasButton := .T.
		oGetPesBru:cToolTip := "Peso Bruto"

		// Peso Liquido
		oSayPesLiq := TSay():Create(oPnlInfC)
		oSayPesLiq:cName := "oSayPesLiq"
		oSayPesLiq:cCaption := "Peso Liquido"
		oSayPesLiq:nLeft := 186
		oSayPesLiq:nTop := 118
		oSayPesLiq:nWidth := 100
		oSayPesLiq:nHeight := 30
		oSayPesLiq:lReadOnly := .T.
		oSayPesLiq:nClrText := CLR_HBLUE
		oSayPesLiq:oFont := oFntBold
		oSayPesLiq:cToolTip := "Peso Liquido"

		oGetPesLiq := TGet():Create(oPnlInfC)
		oGetPesLiq:cName := "oGetPesLiq"
		oGetPesLiq:nLeft := 186
		oGetPesLiq:nTop := 134
		oGetPesLiq:nWidth := 156
		oGetPesLiq:nHeight := 20
		oGetPesLiq:cVariable := "wPesoLiq"
		oGetPesLiq:bSetGet := bSetGet(wPesoLiq)
		oGetPesLiq:Picture := "@E 999,999,999.999"
		oGetPesLiq:lHasButton := .T.
		oGetPesLiq:cToolTip := "Peso Liquido"

		// Data Saida
		oSayDtSai := TSay():Create(oPnlInfC)
		oSayDtSai:cName := "oSayDtSai"
		oSayDtSai:cCaption := "Data Saida"
		oSayDtSai:nLeft := 366
		oSayDtSai:nTop := 118
		oSayDtSai:nWidth := 100
		oSayDtSai:nHeight := 30
		oSayDtSai:lReadOnly := .T.
		oSayDtSai:nClrText := CLR_HBLUE
		oSayDtSai:oFont := oFntBold
		oSayDtSai:cToolTip := "Data Saida"

		oGetDtSai := TGet():Create(oPnlInfC)
		oGetDtSai:cName := "oGetDtSai"
		oGetDtSai:nLeft := 366
		oGetDtSai:nTop := 134
		oGetDtSai:nWidth := 65
		oGetDtSai:nHeight := 20
		oGetDtSai:cVariable := "wDtSaida"
		oGetDtSai:bSetGet := bSetGet(wDtSaida)
		oGetDtSai:Picture := "@!"
		oGetDtSai:cToolTip := "Data Saida"
		oGetDtSai:bValid := {|| fVldDTS() }

		// Hora Saida
		oSayHrSai := TSay():Create(oPnlInfC)
		oSayHrSai:cName := "oSayHrSai"
		oSayHrSai:cCaption := "Hora Saida"
		oSayHrSai:nLeft := 456
		oSayHrSai:nTop := 118
		oSayHrSai:nWidth := 100
		oSayHrSai:nHeight := 30
		oSayHrSai:lReadOnly := .T.
		oSayHrSai:nClrText := CLR_HBLUE
		oSayHrSai:oFont := oFntBold
		oSayHrSai:cToolTip := "Hora Saida"

		oGetHrSai := TGet():Create(oPnlInfC)
		oGetHrSai:cName := "oGetHrSai"
		oGetHrSai:nLeft := 456
		oGetHrSai:nTop := 134
		oGetHrSai:nWidth := 65
		oGetHrSai:nHeight := 20
		oGetHrSai:cVariable := "wTime"
		oGetHrSai:bSetGet := bSetGet(wTime)
		oGetHrSai:Picture := "99:99"
		oGetHrSai:cToolTip := "Hora Saida"

		// Mensagem Padrao
		oSayMsgPad := TSay():Create(oPnlInfC)
		oSayMsgPad:cName := "oSayMsgPad"
		oSayMsgPad:cCaption := "Msg Padrao"
		oSayMsgPad:nLeft := 546
		oSayMsgPad:nTop := 118
		oSayMsgPad:nWidth := 100
		oSayMsgPad:nHeight := 30
		oSayMsgPad:lReadOnly := .T.
		oSayMsgPad:nClrText := CLR_HBLUE
		oSayMsgPad:oFont := oFntBold
		oSayMsgPad:cToolTip := "Mensagem Padrao"

		oGetMsgPad := TGet():Create(oPnlInfC)
		oGetMsgPad:cName := "oGetMsgPad"
		oGetMsgPad:nLeft := 546
		oGetMsgPad:nTop := 134
		oGetMsgPad:nWidth := 65
		oGetMsgPad:nHeight := 20
		oGetMsgPad:cVariable := "wMSGPad"
		oGetMsgPad:bSetGet := bSetGet(wMSGPad)
		oGetMsgPad:Picture := "@!"
		oGetMsgPad:cF3 := "SM4"
		oGetMsgPad:cToolTip := "Mensagem Padrao"

		// Mensagem Livre
		oSayMsgLiv1 := TSay():Create(oPnlInfC)
		oSayMsgLiv1:cName := "oSayMsgLiv1"
		oSayMsgLiv1:cCaption := "Mensagem Livre"
		oSayMsgLiv1:nLeft := 06
		oSayMsgLiv1:nTop := 174
		oSayMsgLiv1:nWidth := 100
		oSayMsgLiv1:nHeight := 30
		oSayMsgLiv1:lReadOnly := .T.
		oSayMsgLiv1:nClrText := CLR_HBLUE
		oSayMsgLiv1:oFont := oFntBold
		oSayMsgLiv1:cToolTip := "Mensagem Livre"

		oGetMsgLiv1 := TGet():Create(oPnlInfC)
		oGetMsgLiv1:cName := "oGetMsgLiv1"
		oGetMsgLiv1:nLeft := 06
		oGetMsgLiv1:nTop := 190
		oGetMsgLiv1:nWidth := 660
		oGetMsgLiv1:nHeight := 20
		oGetMsgLiv1:cVariable := "wMSGLiv1"
		oGetMsgLiv1:bSetGet := bSetGet(wMSGLiv1)
		oGetMsgLiv1:Picture := "@!"
		oGetMsgLiv1:cToolTip := "Mensagem Livre 1"

		oGetMsgLiv2 := TGet():Create(oPnlInfC)
		oGetMsgLiv2:cName := "oGetMsgLiv2"
		oGetMsgLiv2:nLeft := 06
		oGetMsgLiv2:nTop := 212
		oGetMsgLiv2:nWidth := 660
		oGetMsgLiv2:nHeight := 20
		oGetMsgLiv2:cVariable := "wMsgLiv2"
		oGetMsgLiv2:bSetGet := bSetGet(wMsgLiv2)
		oGetMsgLiv2:Picture := "@!"
		oGetMsgLiv2:cToolTip := "Mensagem Livre 2"

		// Pedido de Venda
		oSayPedVen := TSay():Create(oPnlInfC)
		oSayPedVen:cName := "oSayPedVen"
		oSayPedVen:cCaption := "Pedido Venda"
		oSayPedVen:nLeft := 06
		oSayPedVen:nTop := 252
		oSayPedVen:nWidth := 100
		oSayPedVen:nHeight := 30
		oSayPedVen:lReadOnly := .T.
		oSayPedVen:nClrText := CLR_HBLUE
		oSayPedVen:oFont := oFntBold
		oSayPedVen:cToolTip := "Numero do Pedido de Venda"

		oGetPedVen := TGet():Create(oPnlInfC)
		oGetPedVen:cName := "oGetPedVen"
		oGetPedVen:nLeft := 06
		oGetPedVen:nTop := 268
		oGetPedVen:nWidth := 65
		oGetPedVen:nHeight := 20
		oGetPedVen:cVariable := "nPedido"
		oGetPedVen:bSetGet := bSetGet(nPedido)
		oGetPedVen:Picture := "@!"
		oGetPedVen:cToolTip := "Numero do Pedido de Venda"
		oGetPedVen:Disable()

		// Abre Janela
		oDlg:Activate()

	ENDIF



	//Apaga arquivos temporarios
	If chkfile("_SF2")
		dbSelectArea("_SF2")
		dbCloseArea()
	EndIf

	If chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
	EndIf

	If cArqSA4 <> ""
		dbSelectArea(cArqSA4)
		dbSetOrder(cIndSA4)
		dbGoTo(cRegSA4)
	EndIf

	If cArqSM2 <> ""
		dbSelectArea(cArqSM2)
		dbSetOrder(cIndSM2)
		dbGoTo(cRegSM2)
	EndIf

	If cArqSE1 <> ""
		dbSelectArea(cArqSE1)
		dbSetOrder(cIndSE1)
		dbGoTo(cRegSE1)
	EndIf

	If cArqSD2 <> ""
		dbSelectArea(cArqSD2)
		dbSetOrder(cIndSD2)
		dbGoTo(cRegSD2)
	EndIf

	If cArqSF2 <> ""
		dbSelectArea(cArqSF2)
		dbSetOrder(cIndSF2)
		dbGoTo(cRegSF2)
	EndIf

	If cArqSC9 <> ""
		dbSelectArea(cArqSC9)
		dbSetOrder(cIndSC9)
		dbGoTo(cRegSC9)
	EndIF

	If cArqSC5 <> ""
		dbSelectArea(cArqSC5)
		dbSetOrder(cIndSC5)
		dbGoTo(cRegSC5)
	EndIF

	If cArqSC6 <> ""
		dbSelectArea(cArqSC6)
		dbSetOrder(cIndSC6)
		dbGoTo(cRegSC6)
	EndIf

	//If cArqANT <> ""
	If chkfile(cArqANT)
		dbSelectArea(cArqANT)
		dbSetOrder(cIndANT)
		dbGoTo(cRegANT)
	EndIf

	//RUBENS JUNIOR - WORKFLOW DE FATURAMENTO DE CFOP ESPECIFICAS
	//EFFETIVO 0153-14
	U_BIA192()

	//(02/01/15 - Thiago) -> Caso o Pedido seja de ShowRoom, envia WF para o Marketing
	If cEmpAnt <> "02" //OS 3494-16 - Tania c/ aprovação do Fabio
		U_BIA228()
	EndIf

	RestArea(aAreaGer)

Return


Static Function fValida()
	
	Local lRet := .T.

	begin sequence

		If (Alltrim(SF2->F2_TPFRETE)=="S")
			break
		endif

		//Testa se o pedido esta sendo faturado utilizando as Transportadoras Padroes
		If Alltrim(wTransp) $ "000051_000052"
			Help(nil,nil,"","__VLDTRANSP__","Favor informar a Transportadora Correta!",1,0,!IsBlind(),nil,nil,nil,.T.) 
			lRet := .F.
			break
		Endif

		//Valida se a Transportadora esta preenchida
		If Empty(wTransp)
			Help(nil,nil,"","__VLDTRANSP__","Transportadora nao cadastrada!",1,0,!IsBlind(),nil,nil,nil,.T.) 
			lRet := .F.
			break
		Endif

		//Valida se a Transportadora esta correta
		DbSelectArea("SA4")
		DbSetOrder(1)
		If !dbSeek(xFilial("SA4")+wTransp,.F.)
			Help(nil,nil,"","__VLDTRANSP__","Transportadora não cadastrada!",1,0,!IsBlind(),nil,nil,nil,.T.) 
			lRet := .F.
			break
		EndIf

		// Valida se a UF da Placa esta preenchida
		If !Empty(Alltrim(wPlaca)) .And. Empty(Alltrim(wUF))
			Help(nil,nil,"","__VLDTRANSP__","Favor informar a UF da Placa do Veículo!",1,0,!IsBlind(),nil,nil,nil,.T.) 
			lRet := .F.
			break
		EndIf
	
	end sequence

	if ((!lRet).and.(stackTools():IsInStackCall({"FaturarPedido","ProcFat","DocSaida"})))
		lRet:=.T.
	endif

Return(lRet)

// Grava dados - SF2, SD2, SF3
Static Function fConfirma(oDlg)

	Local hj

	If fValida()

		// Calcula frete autonomo
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
		While ! Eof() .And.;
		SF2->F2_FILIAL  == SD2->D2_FILIAL  .And. ;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	== SD2->D2_LOJA

			If wTpFrete == 1 //Autonomo - Alterado para utilizar variavel do Tipo de Frete 08/09/09 Ranisses

				//Calcula o ICMS Frete
				aVlr		:= U_fCalcFreteAut(cEST,cMun,SD2->D2_COD,SD2->D2_LOTECTL,SD2->D2_QUANT)

				//Acumula variaveis
				wBaseCalc	+= aVlr[1]
				wIcms		+= aVlr[2]

			EndIf

			DbSelectArea("SD2")
			DbSetOrder(3)

			dbSkip()

		EndDo

		If wTpFrete == 1 //Autonomo - Alterado para utilizar variavel do Tipo de Frete 08/09/09 Ranisses

			//Grava o valor do Icms de Frete no Cabecalho da NF
			DbSelectArea("SF2")
			RecLock("SF2",.F.)
			SF2->F2_FRETAUT:= wBaseCalc
			SF2->F2_ICMAUTO:= wIcms
			SF2->(MsUnLock())
			dbCommit()

			// Grava o valor do Icms de Frete no Livro
			RecLock("SF3",.F.)
			SF3->F3_ICMAUTO	:= wIcms
			SF3->(MsUnLock())
		EndIf

		// Roda todos pedidos
		For hj := 1 to Len(aPedido)

			cSql := "SELECT SUM(C6_QTDVEN - C6_QTDENT)AS SALDO "
			cSql += "FROM " +RetSQLName("SC6")+" SC6 WITH (NOLOCK) "
			cSql += "WHERE "
			cSql += " SC6.C6_FILIAL  = '"+xFilial("SC6") +"' AND "
			cSql += " SC6.C6_NUM     = '"+aPedido[hj]+"' AND "
			cSql += " SC6.C6_CLI     = '"+SF2->F2_CLIENTE+"' AND "
			cSql += " SC6.D_E_L_E_T_ = '' "
			TCQuery cSql Alias "X" New
			wSaldo	:= X->SALDO
			X->(DbCloseArea())

			If wSaldo > 0
				wNota := ""
				wSerie:= ""
			Endif

			DbSelectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+aPedido[hj],.T.)
			RecLock("SC5",.F.)
			SC5->C5_YMARCA  := wMarca
			SC5->C5_ESPECI1	:= wEspecie
			SC5->C5_MENPAD  := wMSGPad		
			SC5->C5_MENNOTA := cValToChar(wMSGLiv1)+cValToChar(wMSGLiv2) //Ticket 9450			
			SC5->C5_NOTA    := wNota
			SC5->C5_SERIE   := wSerie
			//SC5->C5_TRANSP  := wTransp
			SC5->(MsUnLock())

		Next hj

		DbSelectArea("SF2")
		RecLock("SF2",.F.)
		If SF2->(FieldPos("F2_YMARCA")) > 0
			SF2->F2_YMARCA := wMarca
		EndIf

		SF2->F2_PBRUTO	:= wPesoBr
		SF2->F2_PLIQUI	:= wPesoLiq
		SF2->F2_TRANSP	:= wTransp
		SF2->F2_YPLACA	:= wPlaca
		SF2->F2_YPLACAB	:= wPlacaPES    // MADALENO
		SF2->F2_YSEQB	:= wQtdPes     // MADALENO
		SF2->F2_YPALLET	:= QUANT_PALET  // MADALENO
		SF2->F2_YDES	:= wDtSaida
		SF2->F2_YHES	:= wTime
		SF2->F2_YUF		:= wUF
		SF2->F2_YPEDIDO	:= IIF(Len(aPedido)==1,aPedido[1],"******")
		SF2->F2_VOLUME1	:= wVolume
		SF2->F2_ESPECI1	:= wEspecie
		SF2->F2_YAGREG	:= wRoman

		//Grava Resposta do PE M460MARK
		SF2->F2_YFLAGFT	:= nFlagFT

		//Grava as Mensagens do Pedido
		SF2->F2_YMENPAD	:= wMSGPad
		SF2->F2_YMENNOT	:= cValToChar(wMSGLiv1)+cValToChar(wMSGLiv2) //Ticket 9450
		SF2->F2_YSEGURO	:= wSeguro
		SF2->F2_YSUBTP	:= SC5->C5_YSUBTP
		SF2->F2_YCCUSTO	:= SC5->C5_YCC
		SF2->F2_YCLVL	:= SC5->C5_YCLVL
		SF2->F2_YITEMCT	:= SC5->C5_YITEMCT
		SF2->F2_YEMP	:= SC5->C5_YEMP 		//GRAVA EMPRESA ORIGINAL
		SF2->F2_YRESULT	:= SC5->C5_YRESULT		//GRAVA RESULTADO
		SF2->F2_YRESUL2	:= SC5->C5_YRESUL2

		//Inserido por Wanisay no dia 25/12/16 para atender a exigência MDF-e
		If !Empty(wPlaca)
			DA3->(DbSetOrder(3))
			If DA3->(DbSeek(xFilial("DA3")+Alltrim(wPlaca)))			
				SF2->F2_VEICUL1 := ALLTRIM(DA3->DA3_COD)
			EndIf
		EndIf

		SF2->(MsUnLock())

		If !Empty(wTransp)
			DbSelectArea("SA4")
			DbSetOrder(1)
			dbSeek(xFilial("SA4")+wTransp,.T.)
			RecLock("SA4",.F.)
			SA4->A4_YMOTOR := ALLTRIM(wMotor)
			SA4->(MsUnLock())
		END IF

		If SF2->F2_TIPO $ "N_C_I"
			DbSelectArea("SA1")
			DbSetOrder(1)
			If ! DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				MsgBox("SF2460I.PRW - Cliente nao Cadastrado","Cliente "+SF2->F2_CLIENTE+" "+SF2->F2_LOJA+" nao Cadastrado","INFO")
			EndIf				
		EndIf

		If (!_IsAuto)

			oDlg:bValid := {|| .T. }
			oDlg:End()

		EndIf

	EndIf

Return()

// Gravar o campo E1_YRECR no SE1
Static function fAtuSE1()
	Local aArea 	:= GetArea()
	Local nIndSE1 	:= SE1->(IndexOrd())
	Local nRegSE1	:= SE1->(Recno())
	Local nRegSD2 	:= SD2->(Recno())
	Local nIndSC5	:= SC5->(IndexOrd())
	Local nRegSC5 	:= SC5->(Recno())

	Local cTitulos	:= "Titulo/Parc/Tipo"
	Local _ATITULOS := {}
	Local lComiZer	:= .F.
	Local cAliasTmp

	SD2->(DbSetOrder(3))
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SD2")+SD2->D2_PEDIDO))

	SD2->(DbSetOrder(cIndSD2))
	SD2->(DbGoto(nRegSD2))

	//VERIFICA SE EXISTE COMISSAO ZERADA NA NF EM PRODUTO PA - FERNANDO - 13/08/2010
	cAliasTmp:=GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT COUNT(*) CONT
		FROM %TABLE:SD2%
		WHERE D2_FILIAL 	= %Exp:SF2->F2_FILIAL%
		AND D2_DOC		= %Exp:SF2->F2_DOC%
		AND D2_SERIE	= %Exp:SF2->F2_SERIE%
		AND D2_GRUPO 	= 'PA'
		AND D2_COMIS1 	= 0
		AND %NotDel%
	EndSql
	lComiZer := (cAliasTmp)->CONT > 0
	(cAliasTmp)->(DbCloseArea())

	DbSelectArea("SE1")
	DbSetOrder(2)
	DbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC)
	Do While !Eof() .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. ;
	SE1->E1_LOJA  == SF2->F2_LOJA	 .And	.  SE1->E1_PREFIXO == 	SF2->F2_SERIE .And. ;
	SE1->E1_NUM == SF2->F2_DOC
		IF SE1->E1_COMIS1 = 0
			cTitulos += SE1->E1_NUM +"/"+ SE1->E1_PARCELA +"/"+ SE1->E1_TIPO + CHR(13)+CHR(10)
		END IF
		Reclock("SE1",.F.)
		SE1->E1_YRECR := SC5->C5_YRECR
		SE1->(MsUnLock())

		//EMAIL DE COMISSOES ZERADAS - MODIFICADO POR FERNANDO - 05/08/2010
		IF (lComiZer) .AND. (SE1->E1_TIPO == "NF") .AND. (SE1->E1_COMIS1 == 0) .AND. !(SE1->E1_VEND1 $ '999999#000258')
			AADD(_ATITULOS,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_HIST})
		ENDIF

		DbSkip()
	EndDo

	DbSelectArea("SE1")
	DbSetOrder(nIndSE1)
	DbGoto(nregSE1)

	DbSelectArea("SC5")
	DbSetOrder(nIndSC5)
	DbGoto(nregSC5)

	RestArea(aArea)

	//EMAIL DE COMISSOES ZERADAS - MODIFICADO POR FERNANDO - 05/08/2010
	IF Len(_ATITULOS) > 0
		C_TITULO 	:= "Comissão zerada na baixa do contas a receber"
		C_DESTI		:= IIF(CEMPANT="01","wellison.toras@biancogres.com.br;claudeir.fadini@biancogres.com.br" ,IIF(CEMPANT="05","wellison.toras@biancogres.com.br;luismar.lucchini@biancogres.com.br" ,"wellison.toras@biancogres.com.br;claudeir.fadini@biancogres.com.br" ))
		C_MENS		:= U_COMZMAIL(DTOC(SF2->F2_EMISSAO),SUBSTR(Time(),1,5),SE1->E1_CLIENTE+" - "+AllTrim(SE1->E1_NOMCLI),SF2->F2_VEND1+" - "+POSICIONE("SA3",1,XFILIAL("SA3")+SF2->F2_VEND1,"A3_NOME"),_ATITULOS)
		U_BIAEnvMail(,C_DESTI,C_TITULO,C_MENS)
	END IF

Return


/*/{Protheus.doc} fVldDTS
@description Valida DATA SAIDA 
@author Ranisses A. Corona
@since 22.12.09
@version undefined

@type function
/*/
Static Function fVldDTS()
	Local nDias := GetMV("MV_YDIASDS")

	If !cEmpAnt $  "02_06" //Nao executa regra para Ceramica Incesa
		If Empty(wDtSaida)
			//wDtSaida	:= DDATABASE
			MsgAlert("Favor preencher o campo Data de Saida, pois está em branco!")
			Return(.F.)
		EndIf

		If wDtSaida - DDATABASE > nDias
			//wDtSaida	:= DDATABASE
			MsgAlert("O campo Data de Saida não pode ser maior que "+Alltrim(Str(nDias))+" dia da emissão da NF. Favor preencher o campo corretamente!")
			Return(.F.)
		EndIf
	Else
		Return(.T.)
	EndIf

Return

// Valida a UF da Placa Informada
Static Function fVldUF()

	If wUF $ "AC_AL_AM_AP_BA_CE_DF_ES_GO_MA_MG_MS_MT_PA_PB_PE_PI_PR_RJ_RN_RO_RR_RS_SC_SE_SP_TO" .Or. Empty(Alltrim(wUF))
		Return(.T.)
	Else
		MsgAlert("A UF informada está incorreta. Favor verificar!")
		Return(.F.)
	EndIf

Return()

// Corrige data vencimento da Guia SF6
Static Function fAcertaSF6()
	Local nIndSC5	:= SC5->(IndexOrd())
	Local nRegSC5 	:= SC5->(Recno())
	Local dDias		:= 7 //Dias de incremento para o vencimento da ST
	Local aParam := {}

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))

	//Define forma de pagamento de acordo com a Condição de Pagamento
	If U_fValidaRA(SF2->F2_COND)
		If Alltrim(SC5->C5_YSUBTP) == "B"
			nForma := "1"
		Else
			nForma := "3"
		EndIf
	Else
		nForma := "1"
	EndIf

	//Grava informações na Guia 
	DbSelectArea('SF6')
	DbSetOrder(3)
	If DbSeek(xFilial('SF6')+'2'+'N '+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)		


		
		RecLock('SF6',.F.)

		//Grava o protocolo para os estados do MG e BA
		If Alltrim(SF6->F6_EST) $ "MG_BA"
			SF6->F6_NUMCONV	:= "26/2010"
		EndIf

		
		aParam := {24, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e STE de acordo com o código de receita e sigla da UF da guia atual.
	
		If Alltrim(SF6->F6_CODREC) $ '1260' .And.  Alltrim(SF6->F6_EST) $ 'ES' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {24, '2', '',0, '5'}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		//pzzn 
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'CE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'CE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		//Validar informações da NF
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'RS' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'RS' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf
		
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'TO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'TO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf


		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'AM' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'AM' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'AP' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'AP' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'BA' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'AL' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'AC' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'AC' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'GO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'GO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf
		
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'MA' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'MA' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'MG' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'MG' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'MS' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf


		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'MT' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'MT' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'PA' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'PA' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'PI' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'PI' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'PR' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'PR' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'RO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'RO' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'RR' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'RR' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'SE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'SE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'PE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {24, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf
	
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'PE' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'SC' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {24, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf
	
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'SC' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {22, '2', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		If Alltrim(SF6->F6_CODREC) $ '100102' .And. Alltrim(SF6->F6_EST) $ 'DF' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf
	
		If Alltrim(SF6->F6_CODREC) $ '100099' .And. Alltrim(SF6->F6_EST) $ 'DF' //Valida o Código de Receita e sigla da UF da guia atual
			aParam := {10, '1', '',0, ''}          //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o código de receita e sigla da UF da guia atual.
		EndIf

		SF6->F6_TIPOGNU	:= aParam[1]
		SF6->F6_DOCORIG	:= aParam[2]
		SF6->F6_DETRECE	:= aParam[3]
		SF6->F6_CODPROD	:= aParam[4]
		
		If SF6->( FieldPos("F6_CODAREA") ) > 0
			SF6->F6_CODAREA	:= aParam[5]
		EndIf

		SF6->(MsUnLock())

	EndIf

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

	//Grava Titulos de ST para as NF's de Bonificação
	If SF2->F2_ICMSRET > 0

		//Alteracao para atender Vencimento da ST no ES
		If Alltrim(SF2->F2_EST) == "ES"
			dDias := 28
		EndIf

		DbSelectArea("SE1")
		DbSetOrder(2)
		If !DbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC,.F.)

			If Alltrim(SC5->C5_YSUBTP) == "B"
				RecLock("SE1",.T.)
				SE1->E1_FILIAL	:=	xFilial("SE1")
				SE1->E1_PREFIXO	:=	SF2->F2_SERIE
				SE1->E1_NUM		:=	SF2->F2_DOC
				SE1->E1_PARCELA	:=	'A'
				SE1->E1_TIPO	:=	'NF'
				SE1->E1_NATUREZ	:=	'1230'
				SE1->E1_YFORMA	:=	nForma
				SE1->E1_CLIENTE	:=	SF2->F2_CLIENTE
				SE1->E1_LOJA	:=	SF2->F2_LOJA
				SE1->E1_NOMCLI	:=	SA1->A1_NREDUZ
				SE1->E1_YUFCLI	:=	SF2->F2_EST
				SE1->E1_EMISSAO	:= 	SF2->F2_EMISSAO
				SE1->E1_VENCTO	:=	SF2->F2_EMISSAO+dDias
				SE1->E1_VENCREA	:=	DATAVALIDA(SF2->F2_EMISSAO+dDias)
				SE1->E1_VENCORI	:=	SF2->F2_EMISSAO+dDias
				SE1->E1_VALOR	:=	SF2->F2_ICMSRET
				SE1->E1_EMIS1	:=	SF2->F2_EMISSAO
				SE1->E1_SITUACA	:=	'0'
				SE1->E1_SALDO	:=	SF2->F2_ICMSRET
				SE1->E1_VEND1	:=  SF2->F2_VEND1
				SE1->E1_COMIS1	:=	0

				//OS 0335-14 Zerando Juros dos Grupos Abaixo
				If Alltrim(SA1->A1_GRPVEN) $ "000380_000026_000010_000030_000938" //OS 1487-16 - CASSOL
					SE1->E1_PORCJUR	:=	0
				Else
					SE1->E1_PORCJUR	:=	0.20
				EndIf

				SE1->E1_MOEDA	:=	1
				SE1->E1_BASCOM1	:=	0
				SE1->E1_OCORREN	:= '01'
				SE1->E1_PEDIDO	:=	SF2->F2_YPEDIDO
				SE1->E1_VLCRUZ	:=	SF2->F2_ICMSRET
				SE1->E1_SERIE	:=	SF2->F2_SERIE
				SE1->E1_STATUS	:=	'A'
				SE1->E1_ORIGEM	:=	'MATA460'
				SE1->E1_YPRZPTO	:=	'00'
				SE1->E1_YBAIDEL	:=	'N'
				SE1->E1_FILORIG	:=	xFilial("SE1")
				SE1->E1_YRECR	:=	'N'
				SE1->E1_MSFIL	:=	xFilial("SE1")
				SE1->E1_MSEMP	:=	xFilial("SE1")
				SE1->E1_FRETISS	:=	'1'
				SE1->E1_YCLASSE	:=	'1'
				SE1->E1_YEMP	:=	SF2->F2_YEMP    

				//Chama P.E. para ajustes no titulo -- RANISSES EM 05/01/16
				ExecBlock("M040SE1",.F.,.F.) 
				SE1->(MsUnLock())

				//Grava o numero da NF no campo Duplicata
				RecLock("SF2",.F.)
				SF2->F2_DUPL	:= SF2->F2_DOC
				SF2->F2_PREFIXO	:= SF2->F2_SERIE //ADICIONADO POR RUBENS JUNIOR (FACILE SISTEMAS) DIA 02/12/13, PARA QUE POSSA SER EXIBIDO NA DANFE, AS FATURAS REFENTE A ST
				SF2->(MsUnLock())

			Else
				MsgBox("Esta NF possui cálculo de ICMS ST porém não será gerado título no Contas a Receber! Favor comunicar ao Setor Financeiro.","BIAF026","STOP")
			EndIf
		EndIf
	EndIf

	DbSelectArea("SC5")
	DbSetOrder(nIndSC5)
	DbGoto(nregSC5)

Return()
