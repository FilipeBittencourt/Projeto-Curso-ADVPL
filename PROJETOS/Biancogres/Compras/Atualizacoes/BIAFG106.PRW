#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG106
Tela para gravação do número do RPV 
@author Gabriel Rossi Mafioletti
@since 27/08/2019
@version 1.0
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro -  Obrigatório 
@type function
/*/

User Function BIAFG106(cOrigem, nVlrDesc)  //, cNumDoc, cSerPref, cCliFor, cLjCliFor, nTotRat)

	Local lRatRPV 	:= .F.
	Local aAreaRPV		:= GetArea()
	Local cDescErro := ""

	Default nVlrDesc := 0

	// Desativado por Emerson (Facile) em 26/08/2021 para a chamada da funcao TelaRPV()
	/*While !ValidPerg()
EndDo */

	// Executa somente se rotina for chamada via interface com usuário
if !IsBlind()

	If !MsFile(Alltrim(RetSQLName('ZNC')),,"TOPCONN") .Or. Empty(cOrigem)
			//FWAlertInfo("A tabela ZNC na empresa logada não existe. Favor criar.", "Rateio RPV")
			Return
	Endif

		// Chama tela de Rateio de RPV - Já deve estar posicionado na tabela correspondente
	If cOrigem == "1"   			// NF Entrada (SF1)

			cDescErro := "Rateio RPV não permitido para esta NF de Entrada (" + SF1->F1_DOC + " / " + SF1->F1_SERIE + ") !!! Somente é permitido Rateio RPV para NF´s do tipo Normal."
		If !IsInCallStack("U_TACLNFJB") .And. !IsInCallStack("U_PNFM0002") .And. !IsInCallStack("U_PNFM0005") .And. !IsInCallStack("U_JOBFATPARTE") .And. SF1->F1_TIPO == "N"
			If ChkRegra("1")
					lRatRPV := .T.
			Endif
		Endif

	Elseif cOrigem == "2"   		// Pedido Vendas (SC5)

			cDescErro := "Rateio RPV não permitido para este Pedido (" + SC5->C5_NUM  + ") !!! Somente é permitido Rateio RPV  para pedido(s) com tipo de vendas igual 'G'." 
		If Alltrim(SC5->C5_YSUBTP) == "G"
				lRatRPV := .T.
		Endif

	Elseif cOrigem == "3"   		// Liberação Financeira (ZL0)
			
			lRatRPV := .T.		

	Endif

	If lRatRPV
			TelaRatRPV(cOrigem, nVlrDesc) 
	Else
			FWAlertInfo(cDescErro, "Rateio RPV")
	Endif

Endif

	RestArea(aAreaRPV)

Return


/*/{Protheus.doc} TelaRatRPV
Tela de cadastro de rateio RPV
@author Emerson Salvador
@since 17/08/2021
@param cPOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro -  Obrigatório 
@type function
@version 1.0
 Obs.:  O cmapo NC_FLGGRV é usado para o rateio do financeiro, pois precisa confirmar a ação no browser principal;
/*/

Static Function TelaRatRPV(cPOrigem, nVlrDesc)  //, cPNumDoc, cPSerPref, cPCliFor, cPLjCliFor, nPTotRat)

	Local aAreaRPV 		:= GetArea()
	Local nOpcGd		:= GD_INSERT + GD_UPDATE + GD_DELETE
	Local oFontC  		:= TFont():New("Arial",8,15,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont  		:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	Local aNoFields 	:= IIf(cPOrigem <> "2", {"ZNC_ORIGEM", "ZNC_CHV1", "ZNC_FLGGRV", "ZNC_REC_WT", "ZNC_ALI_WT"}, {"ZNC_ORIGEM", "ZNC_CHV1", "ZNC_FLGGRV", "ZNC_VALOR", "ZNC_REC_WT", "ZNC_ALI_WT"} )
	Local cSeek	    	:= ""//xFilial("ZNC") + Alltrim(cOrigem) + cChave
	Local bWhile		:= {|| ZNC_FILIAL + ZNC_ORIGEM + ZNC_CHV1 }
	Local _nOK			:= 0
	Local aColsRPV		:= {}
	Local aHeadRPV		:= {}
	Local aTamChv		:= TamSX3("ZNC_CHV1")
	Local cMsg			:= ""
	Local cNumDoc		:= ""
	Local cCodCliFor	:= ""
	Local cNomeCliFor	:= ""
	Local cChaveRat		:= ""
	Local aColsBkp		:= {}
	Local aHeaderBkp	:= {}

	Private nTotRatear	:= 0
	Private nPercRat    := 0
	Private nPercARat	:= 100
	Private oPercRat
	Private oPercARat
	Private oGetDdRPV	:=	Nil

	Private nVlrRat    := 0
	Private nVlrARat   := 0
	Private oVlrRat
	Private oVlrARat

	DEFAULT aCols := {}
	DEFAULT aHeader := {}

/*
	//DEFAULT cOrigem    	:= "1"
	DEFAULT cChave		:= "" //"XXXXXXXXX"
	DEFAULT nPTotRat	:= 100.50  // 0
	DEFAULT cPNumDoc	:= ""
	DEFAULT cPSerPref	:= ""
	DEFAULT cPCliFor	:= ""
	DEFAULT cPLJCliFor	:= ""
*/

	If Len(aCols) > 0 .AND. Len(aHeader) > 0

		aColsBkp		:= aClone(aCols)
		aHeaderBkp	:= aClone(aHeader)

	EndIf

	// Ira estar posicionado nas tabelas conforme a origem enviada no parâmetro "1"= NF Entrada / "2" = NF Saida / "3" = Liberação Financeiro
	cMsg := "Deseja prosseguir com o Rateio RPV referente aos dados abaixo ?" + CRLF+CRLF
	If cPOrigem == "1"  		//-----> NF Entrada (SF1)

		cNumDoc 	:= SF1->F1_DOC + " / " + SF1->F1_SERIE
		cCodCliFor 	:= SF1->F1_FORNECE + "/" + SF1->F1_LOJA
		cNomeCliFor := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")
		nTotRatear	:= SF1->F1_VALBRUT
		cChaveRat	:= SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)  	// SF1 - Ordem 1

		cMsg += "Num.NF / Série: " + cNumDoc + CRLF
		cMsg += "Fornecedor: " + cCodCliFor + " - " + Alltrim(cNomeCliFor) + CRLF
		cMsg += "Valor da NF: R$ " + Transform(nTotRatear, PesqPict("ZNC","ZNC_VALOR"))

	Elseif cPOrigem == "2"  	//-----> PV (SC5)

		cNumDoc 	:= SC5->C5_NUM
		cCodCliFor 	:= SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI
		cNomeCliFor := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
		nTotRatear	:= 0
		cChaveRat	:= SC5->(C5_FILIAL+C5_NUM)	// SC5 - Ordem 1

		cMsg += "Pedido: " + cNumDoc + CRLF
		cMsg += "Cliente: " + cCodCliFor + " - " + Alltrim(cNomeCliFor) + CRLF

	Elseif cPOrigem == "3"    //-----> Liberação Financeira (Contas a Receber Receber)

		cNumDoc 	:= SE1->E1_PREFIXO + " / " + SE1->E1_NUM +  " / " + SE1->E1_PARCELA
		cCodCliFor 	:= SE1->E1_CLIENTE + "/" + SE1->E1_LOJA
		cNomeCliFor := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")
		nTotRatear	:= nVlrDesc //SE1->E1_VALOR
		cChaveRat	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)  // SE1 - Ordem 1

		cMsg += "Prefixo / Título / Parcela: " + cNumDoc + CRLF
		cMsg += "Cliente: " + cCodCliFor + " - " + Alltrim(cNomeCliFor) + CRLF
		cMsg += "Valor do desconto: R$ " + Transform(nTotRatear, PesqPict("ZNC","ZNC_VALOR"))

	Else

		Return

	Endif

	If FWAlertYesno(cMsg, "Rateio RPV")

		// Configura o parametro cChave de acordo com o tamanho do SX3 (ZNC_CHV1)
		cChave 	   := IIf( Empty(cChave), cChaveRat, cChave )
		cChave 	   := IIf( Len(cChave) < aTamChv[1], cChave+Space(aTamChv[1] - Len(cChave)), Left(cChave, aTamChv[1]) )
		cSeek	   := xFilial("ZNC") + Alltrim(cPOrigem) + cChave

		FillGetDados(4,"ZNC",1,cSeek,bWhile,,aNoFields,,,,,,@aHeadRPV,@aColsRPV)

		DEFINE MSDIALOG oDlg TITLE "Rateio RPV" FROM 000, 000 TO 450, 630 OF oMainWnd PIXEL

		@ 032, 020 SAY IIf(cPOrigem == "3", "No.Título/Prefixo/Parcela: ", IIf(cPOrigem == "1", "NF/Série: ", "Pedido: ")) + cNumDoc FONT oFontC  OF oDlg PIXEL
		@ 042, 020 SAY IIf(cPOrigem == "1", "Fornecedor: ", "Cliente: ") + cCodCliFor+" - "+Alltrim(Left(cNomeCliFor,30)) FONT oFontC  OF oDlg PIXEL

		If GdFieldPos("ZNC_VALOR", aHeadRPV) > 0
			@ 052, 020 SAY "Total valor " + IIf(cPOrigem == "3", "do Desconto ", "da NF ") + "a Ratear: R$ " + Transform(nTotRatear, PesqPict("ZNC","ZNC_VALOR")) FONT oFontC  OF oDlg PIXEL
		Endif

		oGetDdRPV := MsNewGetDados():New(065, 020, 166, 290, nOpcGd, /*[ cLinhaOk]*/,"U_FG106TOK"/*[ cTudoOk]*/, /*"+++ZNC_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_FG106FOK"/*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, Odlg, aHeadRPV, aColsRPV, { || TotRodape() } )

		@ 170, 020 GROUP oGroup1 TO 190, 290 PROMPT "% - Rateio"  OF oDlg PIXEL
		@ 180, 025 		Say "% Rateado: " FONT oFont OF oDlg PIXEL
		@ 180, 025+50  	Say oPercRat VAR nPercRat Picture PesqPict("ZNC","ZNC_PERCET") FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ 180, 155     	Say "% A Ratear: " FONT oFont OF oDlg PIXEL
		@ 180, 165+50 	Say oPercARat VAR nPercARat Picture PesqPict("ZNC","ZNC_PERCET") FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL

		If GdFieldPos("ZNC_VALOR", aHeadRPV) > 0
			@ 195, 020 GROUP oGroup1 TO 215, 290 PROMPT "Valores - Rateio"  OF oDlg PIXEL
			@ 205, 025 		Say "Vlr.Rateado: " FONT oFont OF oDlg PIXEL
			@ 205, 025+50  	Say oVlrRat VAR nVlrRat Picture PesqPict("ZNC","ZNC_VALOR") FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
			@ 205, 155     	Say "Vlr A Ratear: " FONT oFont OF oDlg PIXEL
			@ 205, 165+50 	Say oVlrARat VAR nVlrARat Picture PesqPict("ZNC","ZNC_VALOR") FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
		Endif

		TotRodape()

		ACTIVATE MSDIALOG Odlg CENTERED on INIT EnchoiceBar(Odlg, {||_nOK := 1, If(oGetDdRPV:TudoOk(),Odlg:End(),_nOK := 0)}, {|| Odlg:End()})

		If _nOK = 1 .And. FWAlertYesno("Confirma gravação do Rateio RPV ?", "Rateio RPV")
			GrvRat(cPOrigem, cChave)
		EndIf

	Endif

	//Restaurando dados originais devido a função interna  MsNewGetDados() que muda o aCols e o aHeader
	If Len(aCols) > 0 .AND. Len(aHeader) > 0

		aCols	  := {}
		aHeader := {}
		aCols   := aClone(aColsBkp)
		aHeader	:= aClone(aHeaderBkp)

	EndIf

	RestArea(aAreaRPV)

Return

/*/{Protheus.doc} FG106FOK() 
Função para validação da digitação do campo na GetDados
@author Emerson Salvador
@since 17/08/2021
@version 1.0
@type function
/*/

User Function FG106FOK()

	Local cCpo     	  := ReadVar()
	Local _Conteudo	  := (&cCpo)
	Local nLin		  := oGetDdRPV:nAt
	Local lRet		  := .T.

	If cCpo == "M->ZNC_CODRPV"

		If TemRPV(_Conteudo)
			If JaTemRPV(_Conteudo, nLin)
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif


	Elseif cCpo == "M->ZNC_PERCET" .Or. cCpo == "M->ZNC_VALOR"

		If cCpo == "M->ZNC_PERCET"

			If _Conteudo <= 0 .Or. _Conteudo > 100
				FWAlertInfo("Preencher com valor entre 1 e 100 !!!", "Rateio RPV")
				lRet := .F.
			Else
				GdFieldPut("ZNC_PERCET",_Conteudo ,nLin)
				If GdFieldPos("ZNC_VALOR",oGetDdRPV:aHeader) > 0
					GdFieldPut("ZNC_VALOR",	ROUND((nTotRatear * _Conteudo) / 100,2) ,nLin) // (4000*57)/100 = r$ 2280
				Endif
			Endif

		Elseif cCpo == "M->ZNC_VALOR"

			If _Conteudo <= 0 .Or. _Conteudo > nTotRatear
				FWAlertInfo("Preencher com valor maior que zero e menor ou igual ao valor total a ratear !!!", "Rateio RPV")
				lRet := .F.
			Else
				GdFieldPut("ZNC_VALOR",	_Conteudo ,nLin)
				GdFieldPut("ZNC_PERCET",ROUND((_Conteudo * 100) / nTotRatear,2),nLin) // (2280*100)/4000 = 57%
			Endif
		Endif

		// Atualiza totais do rodape
		TotRodape()
	Endif

Return lRet

/*/{Protheus.doc} FG106TOK
Rotina para validação ao clicar no botão de confirmação
@author Emerson Salvador
@since 17/08/2021
@version 1.0
@type function
/*/

User Function FG106TOK()

	Local _nI 		:= 0
	Local nPosDel 	:= Len(oGetDdRPV:aHeader)+1
	Local nPercDig 	:= 0
	Local nVlrDig	:= 0
	Local lRet		:= .T.

	For _nI	:=	1 to Len(oGetDdRPV:aCols)
		If !oGetDdRPV:aCols[_nI,nPosDel]
			If JaTemRPV(GdFieldGet("ZNC_CODRPV",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols ), _nI)
				lRet := .F.
				Exit
			Endif
			nPercDig 	+= GdFieldGet("ZNC_PERCET",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
			If GdFieldPos("ZNC_VALOR",oGetDdRPV:aHeader) > 0
				nVlrDig 	+= GdFieldGet("ZNC_VALOR",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
			Endif
		Endif
	Next

	If lRet .And. nPercDig <> 0 .And. nPercDig < 100.00
		FWAlertInfo("Total do (%) rateado está com " + cValToChar(nPercDig) + " % inferior a 100.00 % !!!", "Rateio RPV")
		lRet := .F.
	Endif

	If lRet .And. nPercDig <> 0 .And. nPercDig > 100.00
		FWAlertInfo("Total do (%) rateado está com " + cValToChar(nPercDig) + " % superior a 100.00 % !!!", "Rateio RPV")
		lRet := .F.
	Endif

	If lRet .And. nVlrDig <> nTotRatear
		FWAlertInfo("Total do Valor Rateio " + Transform(nVlrDig, PesqPict("ZNC","ZNC_VALOR")) + " está divergente do Valor Total a ser rateado " + Transform(nTotRatear, PesqPict("ZNC","ZNC_VALOR")) + " !!!", "Rateio RPV")
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} FGT106EF
Rotina para efetivar a gravação quando o registro da ZNC é gravado na pela rotina TWliberacaofinanceiro / ponto de entrada na exclusão do PV / NF / Lib.Financeira / NF Saída, 
	após a confirmação pelo botão Confirmar da tela, caso seja fechada a tela 
	a rotina apaga os registros que forma gravados na tabela ZNC pelo botão rateio
@author Emerson Salvador
@since 30/08/2021
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro
@param cChaveSeek, characters, Campo concatenado com a chave a ser pesquisada na tabela ZNC
@param cTipoGrv, characters, "S"-Grava como efetivo o campo ZNC_LFGGRV / "N"-Exclui o registro da tabela ZNC, pois não foi efetivada a gravaçãao clicaram no botão fechar da tela de solicitação financeira
@version 1.0
@type function
/*/

User Function FGT106EF(cOrigem, cChaveSeek, cTipoGrv)

	Local aAreaRPV := GetArea()
	Local nTam  := Len(Alltrim(cChaveSeek))

	If MsFile(Alltrim(RetSQLName('ZNC')),,"TOPCONN")

		ZNC->(DbSetOrder(1)) // ZNC_FILIAL+ZNC_ORIGEM+ZNC_CHV1+ZNC_CODRPV

		If ZNC->(DbSeek(xFilial("ZNC")+cOrigem+cChaveSeek))
			Do While ZNC->(!Eof()) .And. SUBSTR(Alltrim(ZNC->ZNC_CHV1),1,nTam) == Alltrim(cChaveSeek)

				ZNC->(Reclock("ZNC",.F.))

				If cTipoGrv == "S"
					ZNC->ZNC_FLGGRV :=	"S"
				Elseif cTipoGrv == "N"
					ZNC->(DbDelete())
				EndIf

				ZNC->(MsUnlock())

				ZNC->(DbSkip())
			Enddo
		Endif

	Endif

	RestArea(aAreaRPV)

Return


/*/{Protheus.doc} FGT106EB
Rotina para buscar e retornar array com os dados dos rateios 
	[1] Codigo RPV
	[2] Percentual rateado
	[3] Valor
@author Emerson Salvador
@since 30/08/2021
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro
@param cChaveSeek, characters, Campo concatenado com a chave a ser pesquisada na tabela ZNC
@version 1.0
@type function
/*/

User Function FGT106EB(cOrigem, cChaveSeek)

	Local aAreaRPV 	:= GetArea()
	Local aRetRPV 	:= {}

	If MsFile(Alltrim(RetSQLName('ZNC')),,"TOPCONN")

		ZNC->(DbSetOrder(1)) // ZNC_FILIAL+ZNC_ORIGEM+ZNC_CHV1+ZNC_CODRPV

		If ZNC->(DbSeek(xFilial("ZNC")+cOrigem+cChaveSeek))
			Do While ZNC->(!Eof()) .And. Alltrim(ZNC->ZNC_CHV1) == Alltrim(cChaveSeek)
				Aadd(aRetRPV, {ZNC->ZNC_CODRPV, ZNC->ZNC_PERCET, ZNC->ZNC_VALOR} )
				ZNC->(DbSkip())
			Enddo
		Endif

	Endif

	RestArea(aAreaRPV)

Return aRetRPV


/*/{Protheus.doc} JaTemRPV
Função para verificar se ja foi digitado o código da RPV no GetDados
@author Emerson Salvador
@since 17/08/2021
@param cCodRPV, characters, Número da RPV
@param nLinACols, numeric, Número da linha onde está posicionado no getdados
@version 1.0
@type function
/*/

Static Function JaTemRPV(cCodRPV, nLinAcols)

	Local _nI := 0
	Local nPosDel := Len(oGetDdRPV:aHeader)+1
	Local lRet := .F.

	For _nI	:= 1 To Len(oGetDdRPV:aCols)
		If !oGetDdRPV:aCols[_nI,nPosDel] .And. _nI <> nLinAcols .And. GdFieldGet("ZNC_CODRPV",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols) == cCodRPV
			FWAlertInfo("RPV " + Alltrim(cCodRPV) + " já Cadastrada para este Rateio !!!", "Rateio RPV")
			lRet	:=	.T.
		EndIf
	Next

Return lRet

/*/{Protheus.doc} TotRodape
Totalizador de valores no rodape da tela
@author Emerson Salvador
@since 17/08/2021
@version 1.0
@type function
/*/

Static Function TotRodape()

	Local _nI := 0
	Local nPosDel := Len(oGetDdRPV:aHeader)+1

	nPercRat 	:= 0
	nPercARat 	:= 100

	nVlrRat		:= 0
	nVlrARat	:= nTotRatear

	For _nI	:=	1 to Len(oGetDdRPV:aCols)
		If !oGetDdRPV:aCols[_nI,nPosDel]
			nPercRat 	+= GdFieldGet("ZNC_PERCET",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
			nPercArat 	-= GdFieldGet("ZNC_PERCET",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
			If GdFieldPos("ZNC_VALOR",oGetDdRPV:aHeader) > 0
				nVlrRat 	+= GdFieldGet("ZNC_VALOR",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
				nVlrARat 	-= GdFieldGet("ZNC_VALOR",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
			Endif
		Endif
	Next

	nVlrRat 	:= IIf(nVlrRat 	< 0, 0, nVlrRat)
	nVlrARat 	:= IIf(nVlrARat < 0, 0, nVlrARat)

	If Type("oPercRat")=="O" .And. Type("oPercARat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
	If Type("oVlrRat")=="O" .And. Type("oVlrARat")=="O"
		oVlrRat:Refresh()
		oVlrARat:Refresh()
	Endif

Return


/*/{Protheus.doc} GrvRat
Rotina para gravação das informações digitadas na GetDados na tabela ZNC
@author Emerson Salvador
@since 17/08/2021
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro
@param cChaveSeek, characters, Campo concatenado com a chave a ser pesquisada na tabela ZNC
@version 1.0
@type function
/*/

Static Function GrvRat(cOrigem, cChaveSeek)

	Local _nI 		:= 0
	Local _nPosDel	:= Len(oGetDdRPV:aHeader)+1

	ZNC->(DbSetOrder(1)) // ZNC_FILIAL+ZNC_ORIGEM+ZNC_CHV1+ZNC_CODRPV

	For _nI	:=	1 to Len(oGetDdRPV:aCols)
		If ZNC->(DbSeek(xFilial("ZNC")+cOrigem+cChaveSeek+GdFieldGet("ZNC_CODRPV",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )  ))
			If !oGetDdRPV:aCols[_nI,_nPosDel]
				ZNC->(Reclock("ZNC",.F.))
				ZNC->ZNC_PERCET	:=	GdFieldGet("ZNC_PERCET",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
				ZNC->ZNC_VALOR	:=	IIF(GdFieldPos("ZNC_VALOR",oGetDdRPV:aHeader) > 0, GdFieldGet("ZNC_VALOR",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols ), 0)
			Else
				ZNC->(DbDelete())
			EndIf
			ZNC->(MsUnlock())
		Else
			If !oGetDdRPV:aCols[_nI,_nPosDel]
				ZNC->(Reclock("ZNC",.T.))
				ZNC->ZNC_FILIAL	:=	xFilial("ZNC")
				ZNC->ZNC_ORIGEM	:=	cOrigem
				ZNC->ZNC_CHV1	  :=	cChaveSeek
				ZNC->ZNC_CODRPV	:=	GdFieldGet("ZNC_CODRPV",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
				ZNC->ZNC_PERCET	:=	GdFieldGet("ZNC_PERCET",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols )
				ZNC->ZNC_VALOR	:=	IIF(GdFieldPos("ZNC_VALOR",oGetDdRPV:aHeader) > 0, GdFieldGet("ZNC_VALOR",_nI,,oGetDdRPV:aHeader,oGetDdRPV:aCols ), 0)
				ZNC->ZNC_FLGGRV :=  "S" //IIF(cOrigem = "3", "N", "S")
				ZNC->(MsUnlock())
			Endif
		Endif
	Next

	FWAlertInfo("Rateio(s) atualizado(s) com Sucesso!!!", "Rateio RPV")

Return

/*/{Protheus.doc} ApuraVlRat
Rotina para apuração dos valores conforme a origem informada no parâmetro cOrigem
@author Emerson Salvador
@since 17/08/2021
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro
@param cDoc, characters, Campo com numero da NF (Entrada/Saida/Num.Titulo)
@param cSerie, characters, Campo com a serie da NF ou prefixo do titulo (Entrada/Saida/Num.Titulo)
@param cCliFor, characters, Campo com o codigo do Cliente ou Fornecedor da NF ou Titulo
@param cLoja, characters, Campo com a Loja do Cliente ou Fornecedor da NF ou Titulo
@version 1.0
@type function
/*/

Static Function ApuraVlRat(cOrigem, cDoc, cSerie, cCliFor, cLoja)

	Local nVlrRet := 0

Return nVlrRet



/*/{Protheus.doc} ChkRegra
Rotina para checagem das regras para a inclusao do rateio
@author Emerson Salvador
@since 26/08/2021
@param cOrigem, characters, "1"= NF Entrada / "2" = PV / "3" = Liberação Financeiro
@param cDoc, characters, Campo com numero da NF (Entrada/Saida/Num.Titulo)
@param cSerie, characters, Campo com a serie da NF ou prefixo do titulo (Entrada/Saida/Num.Titulo)
@param cCliFor, characters, Campo com o codigo do Cliente ou Fornecedor da NF ou Titulo
@param cLoja, characters, Campo com a Loja do Cliente ou Fornecedor da NF ou Titulo
@version 1.0
@type function
/*/

Static Function ChkRegra(cOrigem) //, cSerie, cCliFor, cLoja)

	Local lRet 		:= .F.
	Local Qry 		:= GetNextAlias()
	Local cExpRegra := ""

	If cOrigem == "1"

		cExpRegra := "%D1_CONTA IN " + FormatIn('61601022/31401019',"/") + "%"

		BeginSql Alias Qry

			%NOPARSER%

			SELECT
				D1_FILIAL,
				D1_CONTA

			FROM %TABLE:SD1% D1 (NOLOCK)

				WHERE 	D1_FILIAL =  %xFilial:SD1%
						AND D1_DOC = %Exp:SF1->F1_DOC%
						AND D1_SERIE = %Exp:SF1->F1_SERIE% 
						AND D1_FORNECE = %Exp:SF1->F1_FORNECE% 
						AND D1_LOJA = %Exp:SF1->F1_LOJA%
						AND D1_TIPO = %Exp:SF1->F1_TIPO%
						AND %Exp:cExpRegra%						
					  	AND D1.%notDel% 
				
		EndSql

		If (Qry)->(!Eof())
			lRet := .T.
		Endif

		(Qry)->(DBCloseArea())

	Endif

Return lRet

/*/{Protheus.doc} TemRPV
Função para verificar se a RPV digitada existe na View VW_RPV_ENCERRADA 
@author Emerson Salvador
@since 30/08/2021
@param cCodRPV, characters, Número da RPV
@version 1.0
@type function
/*/

Static Function TemRPV(cCodRPV)

	Local lRet 		:= .F.
	Local Qry 		:= GetNextAlias()
	Local aAreaRPV		:= GetArea()

	BeginSql Alias Qry

		%NOPARSER%

		SELECT
			PROTOCOLO

			FROM VW_RPV_ENCERRADA RPV (NOLOCK)

				WHERE PROTOCOLO =  %Exp:cCodRPV%						
				
	EndSql

	If (Qry)->(!Eof())
		lRet := .T.
	Else
		FWAlertInfo("RPV " + Alltrim(cCodRPV) + " não está Cadastrado !!!", "Rateio RPV")
	Endif

	(Qry)->(DBCloseArea())

	RestArea(aAreaRPV)

Return lRet

/*
Static Function ValidPerg()


	local lRet		:= .F.
	Local aPergs	:=	{}
	
	Local _xBkpMV01

	_xBkpMV01	:=	MV_PAR01

	MV_PAR01 := SPACE(50)


	aAdd( aPergs ,{1,"Número RPV " 		  	,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})


	If ParamBox(aPergs ,"Gravação do RPV",,,,,,,,,.F.,.F.)

		lRet := .T.

		c_cNumRpv	:=	MV_PAR01

	EndIf
	
	
	MV_PAR01	:=	_xBkpMV01
	
Return lRet */

/*

 SELECT DISTINCT TOP 20 D1_DOC, D1_FORNECE
 FROM  SD1010 D1 (NOLOCK) WHERE D1_FILIAL =  '01'
 AND  EXISTS ( SELECT 0  FROM SF1010 WHERE D1_DOC = F1_DOC  AND D1_FILIAL =  F1_FILIAL) 
 AND D1_TIPO =  'N' 
 AND   D1_CONTA IN ('61601022','31401019')  
 AND D1.D_E_L_E_T_= ' '

*/
