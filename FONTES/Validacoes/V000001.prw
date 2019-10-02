#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topConn.ch"

Static nLimite := 300 // Limite de itens em um pedido de Venda segundo a TOTVS.

/*/{Protheus.doc} BRA0637
Funcao para Solicitacao Eletronica
@author Paulo Cesar Camata
@since 06/03/2018
@type function
@history 23/10/2018, TOTVS-IURY, Chamado 14596- GE - ID40 - Ajustar rotina de solicitação eletrônica para tratar romaneado e não expedido
/*/
user function V000001()
	local oBrowse
	private cCadastro := "Solicitação Eletrônica de Nota Fiscal"
	private aRotina   := menuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZV1")
	oBrowse:SetDescription(cCadastro)
	oBrowse:AddLegend("!empty(ZV1->ZV1_NFS)"   , "BR_VERMELHO", "Solicitação Eletrônica Faturada" )
	oBrowse:AddLegend("!empty(ZV1->ZV1_PEDIDO)", "BR_AMARELO" , "Solicitação Eletrônica em Pedido")
	oBrowse:AddLegend("empty(ZV1->ZV1_PEDIDO)" , "BR_VERDE"   , "Solicitação Eletrônica em Aberto")
	oBrowse:Activate()
return nil

static function menuDef()
	local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "axPesqui"   OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "U_BRA0637I" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "U_BRA0637I" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "U_BRA0637I" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "U_BRA0637I" OPERATION MODEL_OPERATION_DELETE ACCESS 0
return aRotina

/*/{Protheus.doc} BRA0637I
Funcao chamada para Visualizar, Incluir, Alterar e Excluir
@author Paulo Cesar Camata
@since 06/03/2018
@type function
@history 14/07/2019, BRAMETAL-Gabriel, Adicionado limitador de itens suportados na geração da solicitação eletronica, para evitar erros na criação do PV.
/*/
user function BRA0637I(cAlias, nReg, nOpc)
	local aObject   := {}
	local aColsExp  := {}
	local aAltCpo   := {}
	local aSize     := MsAdvSize()
	local nOpcAlt   := 0
	local oDlg, aInfo, aPosObj, aAltEncho, aHeaderEX, aEncho, aEncho2, aAltEnc2
	local cUsuSol   := getNewPar("BRA_USUSOL", "002202")
	local cUsuFat   := getNewPar("BRA_USUFAT", "002202")
	local lConfirm  := .F.

	private oMSNewCont, oEnch1
	private bVldProd := {|| fVldProd(@oMSNewCont)} // Validacao campo Codigo do Produto
	private bVldQtde := {|| fVldQtd( @oMSNewCont)} // Validacao campo Quantidade
	private bVldPrec := {|| fVldPrc( @oMSNewCont)} // Validação campo Preco
	private bVldEtq  := {||	fVldEtq( @oMSNewCont)} // Validação campo Etiqueta
	private bVldEto  := {||	fVldEto( @oMSNewCont)} // Validação campo Etiqueta original
	private cDelOk 	 := {||	fAtuPeso(@oMSNewCont,.T.)} // Validação deletar linha	
	Private bLinOk   := {|| fValid(@oMSNewCont,n)}
	Private bWhenQtd := {|| Empty(GDFieldGet("ZV2_ETIMAT", n)) }


//	if !(__cUserId $ cUsuSol) .and. ( nOpc <> 2 .or. !(__cUserId $ cUsuFat))
//		Help(, , "Help", , "Usuário não possui acesso a rotina (PARAMETRO BRA_USUSOL). Verifique.", 1, 0 )
//		return nil
//	endif

	if (nOpc == 4 .or. nOpc == 5) .and. !empty(ZV1->ZV1_PEDIDO) // Nao permitir Alterar/Excluir quando Solicitação Eletronica com pedido emitido.
		Help(, , "Help", , "Solicitação Eletrônica já possui Pedido de Venda gerado. Não é possível " + if(nOpc == 4, "ALTERAR.", "EXCLUIR."), 1, 0 )
		return nil
	endif

	AAdd(aObject, {100, 20, .T., .T.})
	AAdd(aObject, {100, 50, .T., .T.})
	AAdd(aObject, {100, 30, .T., .T.})

	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize(aInfo, aObject, .T. )

	define msDialog oDlg title "Solicitação Eletrônica" FROM aSize[7], aSize[1] to aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	regToMemory("ZV1", nOpc == 3)
	if nOpc == 3 // Incluir
		if pergunte("BRA0637", .T.)
			if mv_Par01 == 1 // Com Estoque
				aColsExp := fBusEstoque() // Carregar produtos em estoque
			endif
			M->ZV1_NRDOC := GETSXENUM("ZV1","ZV1_NRDOC")
		else
			return .T.
		endif
	else
		aColsExp := fCarItens()
	endif

	aEncho    := {"ZV1_NRDOC",  "ZV1_ESTOQU", "ZV1_OPERAC", "ZV1_DESOPE", "ZV1_OBS", "ZV1_PSLIQ", "ZV1_PSBRU", "NOUSER"}
	aAltEncho := {"ZV1_OPERAC", "ZV1_OBS", "ZV1_PSLIQ", "ZV1_PSBRU"}
	oEnch1 := Enchoice("ZV1", ZV1->(recno()), nOpc, , , , aEncho, { aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4]}, aAltEncho, 3, , , , , , nOpc == 3)
	if nOpc == 3
		if mv_par01 == 1
			M->ZV1_ESTOQU := "S"
		else
			M->ZV1_ESTOQU := "N"
		endif
	endif
	aHeaderEX := fRetHeader()

	if (nOpc == 3 .and. mv_par01 == 2) .or. (nOpc == 4 .and. ZV1->ZV1_ESTOQU == "N")
		aAltCpo := {"ZV2_CODPRO", "ZV2_QUANT", "ZV2_VLUNIT","ZV2_ETIMAT", "ZV2_ETIORI"}
		nOpcAlt := GD_INSERT + GD_UPDATE + GD_DELETE
	endif

	oMSNewCont := MsNewGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcAlt, "Eval(bLinOk)", "AllwaysTrue", "+ZV2_ITEDOC", aAltCpo,, nLimite, "AllwaysTrue", "", "Eval(cDelOk)", oDlg, aHeaderEx, aColsExp)

	aEncho2  := {"ZV1_CODCLI", "ZV1_LOJCLI", "ZV1_NOMCLI", "ZV1_ENDER" , "ZV1_MUN"   , "ZV1_BAIRRO", "ZV1_ESTADO", ;
	"ZV1_CEP"   , "ZV1_TIPFRE", "ZV1_PLCVEI", "ZV1_CODTRA", "ZV1_NOMTRA", "ZV1_VOLUME", "ZV1_ESPECI", "ZV1_CONPAG", "NOUSER"}
	aAltEnc2 := {"ZV1_CODCLI", "ZV1_LOJCLI", "ZV1_TIPFRE", "ZV1_PLCVEI", "ZV1_CODTRA", "ZV1_VOLUME", "ZV1_ESPECI", "ZV1_CONPAG"}
	Enchoice("ZV1", ZV1->(recno()), nOpc, , , , aEncho2, { aPosObj[3,1], aPosObj[3,2], aPosObj[3,3], aPosObj[3,4]}, aAltEnc2, 3, , , , , , .F.)

	enchoiceBar(oDlg, {|| lConfirm := .T., fConfirm(nOpc, @oDlg, @oMSNewCont)}, {|| oDlg:end()}, ,  )
	activate msDialog oDlg centered
	if nOpc == 3 // Incluir
		if lConfirm
			confirmSX8()
		else
			ROLLBACKSXE()
		endif
	endif
return nil

/*/{Protheus.doc} fRetHeader
Funcao para montar o aHeader
@author Paulo Cesar Camata
@since 06/03/2018
@type function
/*/
static function fRetHeader()
	local aVetor := {}

	Aadd(aVetor, {" Item"      		, "ZV2_ITEDOC", ""                , 04, 0, "", , "C", "", ""})
	Aadd(aVetor, {" Produto"   		, "ZV2_CODPRO", ""                , 15, 0, "existCpo('SB1') .and. Eval(bVldProd)", , "C", "SB1", ""})
	Aadd(aVetor, {" Descrição" 		, "ZV2_DESPRO", ""                , 40, 0, "", , "C", "", ""})
	Aadd(aVetor, {" UM"        		, "ZV2_UNID"  , ""                , 06, 0, "", , "C", "", ""})
	Aadd(aVetor, {" NCM"       		, "ZV2_NCM"   , ""                , 10, 0, "", , "C", "", ""})
	Aadd(aVetor, {" Eti. Original" 	, "ZV2_ETIORI", "@!"              , 09, 0, "(existCpo('ZC2') .and. Eval(bVldEto)) .OR. VAZIO()", , "C", "ZC2", ""})
	Aadd(aVetor, {" Etiqueta"  		, "ZV2_ETIMAT", "@!"              , 09, 0, "If(Left(M->ZV2_ETIMAT,1) == 'M',existCpo('UZT'),existCpo('ZC2'))  .and. Eval(bVldEtq)", , "C", "UZT", ""})
	Aadd(aVetor, {" Qtde"      		, "ZV2_QUANT" , "@E 9,999,999.999", 13, 3, "Eval(bVldQtde)", , "N", "", "", , , "Eval(bWhenQtd)"})
	Aadd(aVetor, {" Valor Unit"		, "ZV2_VLUNIT", "@E 9,999,999.999", 13, 2, "Eval(bVldPrec)", , "N", "", ""})
	Aadd(aVetor, {" Vlr Total" 		, "ZV2_VLRTOT", "@E 9,999,999.999", 13, 2, "", , "N", "", ""})
return aVetor

/*/{Protheus.doc} fVldProd
Funcao para efetuar o gatilho para os outros campos
@author Paulo Cesar Camata
@since 06/03/2018
@history 26/04/2017, BRAMETAL-Gabriel, Removido validação do campo B1_YESTOQ
@type function
/*/
static function fVldProd(oGrid)

	Local lAutorizado := .F.
	Local cIdpriv := getNewPar("BRA_SOLPRI", "000687")
	Local cCodOper:= getNewPar("BRA_CODOPE", "1")
	local nPosDes := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_DESPRO"})
	local nPosUni := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_UNID"})
	local nPosNcm := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_NCM"})
	local nPosCod := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_CODPRO"})

	If M->ZV1_OPERAC ==cCodOper
	  lAutorizado := U_fUsrInRule(cIdpriv)
		If !(lAutorizado)
			MsgAlert("Usuário sem permissão. ","Atenção")
			Return(.F.)
		Endif
	Endif

	If	!Empty(M->ZV2_ETIMAT)

		If Left(M->ZV2_ETIMAT,1) == "M"
			posicione("SB1", 1, xFilial("SB1") + UZT->UZT_PRODUT, "FOUND()")
		Else
			posicione("SB1", 1, xFilial("SB1") + ZC2->ZC2_PRODUT, "FOUND()")
		endif

	endif

	oGrid:aCols[oGrid:nAt, nPosDes] := allTrim(SB1->B1_DESC)
	oGrid:aCols[oGrid:nAt, nPosUni] := allTrim(SB1->B1_UM)
	oGrid:aCols[oGrid:nAt, nPosNcm] := allTrim(SB1->B1_POSIPI)

	oGrid:refresh()
	fVldQtd(oGrid)
return .T.

/*/{Protheus.doc} fVldTot
Funcao para preenchimento do valor total
@author Paulo Cesar Camata
@since 06/03/2018
@type function
/*/
static function fVldQtd(oGrid)
	local nPosPrc := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLUNIT"})
	local nPosTot := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLRTOT"})
	local nPosEtq := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_ETIMAT"})
	local nPosQt  := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})

	If !Empty(oGrid:aCols[oGrid:nAt, nPosEtq])

		IF !Empty(UZT->UZT_SALDO)
			If oGrid:aCols[oGrid:nAt, nPosQt] <> UZT->UZT_SALDO
				Help(, , "Help", , "Quantidade Não Pode Ser Diferente da Quantidade da Etiqueta.", 1, 0)
				return .F.
			Endif
		Else
			If oGrid:aCols[oGrid:nAt, nPosQt] <> ZC2->ZC2_QUANT
				Help(, , "Help", , "Quantidade Não Pode Ser Diferente da Quantidade da Etiqueta.", 1, 0)
				return .F.
			Endif
		Endif
	Endif

	oGrid:refresh()
	fAtuPeso(oGrid) // Funcao para atualizar o peso

return .T.

/*/{Protheus.doc} fVldEtq
Funcao para preenchimento da Quantidade
@author Paulo Cesar Camata
@since 06/03/2018
@type function
/*/
static function fVldEtq(oGrid)

	local i
	local nPosQut := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})
	local nPosCod := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_CODPRO"})
	Local cLocPad := getNewPar("BRA_LOCSOE", "25")
	Local cPrjOdmEt := getNewPar("BRA_PRJETMT","AJUSTE")
	Private nSalTot := 0


	dbSelectArea("UZT")
	UZT->(dbSetOrder(1))
	UZT->(DbGoTop())

	dbSelectArea("ZC2")
	ZC2->(dbSetOrder(1))
	ZC2->(DbGoTop())

	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	SB2->(DbGoTop())

	If UZT->(dbSeek(xFilial("UZT") + M->ZV2_ETIMAT))

		SB2->(dbSeek(xFilial("SB2") + UZT->UZT_PRODUT + cLocPad))

		If UZT->UZT_STATUS <> 'N'
		 Help(, , "Help", , "Status da Etiqueta Difente de Normal. Verifique.", 1, 0 )
		return .F.
		Endif
		If UZT->UZT_SALDO == 0
    		Help(, , "Help", , "Etiqueta sem Saldo. Verifique.", 1, 0 )
		return .F.
		Endif
		If ALLTRIM(UZT->UZT_LISSEP) <> ""
    		Help(, , "Help", , "Etiqueta Com Lista De Separação. Verifique.", 1, 0 )
		return .F.
		Endif
		for i := 1 to len(oGrid:aCols)
			if !oGrid:aCols[i, len(oGrid:aCols[i])] // Nao deletada

				if UZT->UZT_PRODUT ==  oGrid:aCols[i, nPosCod]
					nSalTot += oGrid:aCols[i, nPosQut]
				endif
			endif
		next i
			nSalTot += UZT->UZT_SALDO

		If nSalTot > SB2->B2_QATU
			Help(, , "Help", , " Saldo do produto Insuficiente. Verifique.", 1, 0 )
		return .F.
		Endif

		oGrid:aCols[oGrid:nAt, nPosQut] := UZT->UZT_SALDO
		oGrid:aCols[oGrid:nAt, nPosCod] := UZT->UZT_PRODUT
		oGrid:refresh()

	Endif
	If ZC2->(dbSeek(xFilial("ZC2") + M->ZV2_ETIMAT))


		If allTrim(M->ZV1_OPERAC) == "16"
			If ZC2->ZC2_STATUS <> "E"
				Help(, , "Help", , "Status da Etiqueta diferente de Entregue. Verifique.", 1, 0 )
				return .F.
			Endif

			If alltrim(ZC2->ZC2_PRJODM) <> cPrjOdmEt
				Help(, , "Help", , "Projeto ODM da Etiqueta diferente de " + cPrjOdmEt + ". Verifique.", 1, 0 )
				return .F.
			Endif
		Else
			If ZC2->ZC2_STATUS $ "S,C,S"
				Help(, , "Help", , "Status da Etiqueta Diferente de Normal. Verifique.", 1, 0 )
				return .F.
			Endif

			If ZC2->ZC2_STATEX <> "N"
				Help(, , "Help", , "Etiqueta já expedida. Verifique.", 1, 0 )
				return .F.
			Endif

			If ZC2->ZC2_MSBLQL == "1"
				Help(, , "Help", , "Etiqueta  Bloqueada. Verifique.", 1, 0 )
				return .F.
			Endif
			If ZC2->ZC2_QUANT == 0
				Help(, , "Help", , "Etiqueta sem Saldo. Verifique.", 1, 0 )
				return .F.
			Endif
			If posicione("UZL", 2, xFilial("UZL") + ZC2->ZC2_CODIGO, "FOUND()")
				Help(, , "Help", , "Etiqueta em planejamento pela expedição. Verifique.", 1, 0 )
				return .F.
			Endif
		EndIf



		oGrid:aCols[oGrid:nAt, nPosQut] := ZC2->ZC2_QUANT
		oGrid:aCols[oGrid:nAt, nPosCod] := ZC2->ZC2_PRODUT
		oGrid:refresh()
	Endif

	fVldProd(oGrid)

return .T.

static function fValid(oGrid,nLin)
	                 
	Local nPosCod := aScanX(oGrid:AHEADER, {|x| allTrim(x[2]) == "ZV2_CODPRO"})	
	local nPosEtimat := aScanX(oGrid:AHEADER, {|x| allTrim(x[2]) == "ZV2_ETIMAT"})
	Local cQuery := ""
	Local lRet := .T.
	Local cEtiQ := ""
	Local nCount := 0

	For nX := 1 To Len(oGrid:aCols)			
		if !oGrid:aCols[nX, len(oGrid:aCols[nX])] // Nao deletada
			cQuery := " select SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_GRUPO, SBM.BM_GRUPO,SBM.BM_YIMPETI "
			cQuery += " from "+RetSQLName("SBM")+" SBM WITH (NOLOCK), "+RetSQLName("SB1")+" SB1 WITH (NOLOCK)  "			
			cQuery += " WHERE SB1.B1_GRUPO = SBM.BM_GRUPO   "
			cQuery += " AND SB1.B1_FILIAL = " + ValToSql(AllTrim(xfilial("SB1")))	 
			cQuery += " AND SB1.B1_COD = "  + ValToSql(AllTrim(oGrid:ACOLS[nX,nPosCod]))
			cQuery += " AND SB1.D_E_L_E_T_ = '' "
			cQuery += " AND SBM.D_E_L_E_T_ = '' "
			
			TcQuery cQuery new alias "ZPORD" 
			ZPORD->(DBGotop())  
			If  ZPORD->BM_YIMPETI == 'S' .AND. Empty(AllTrim(oGrid:ACOLS[nX,nPosEtimat])) 
				Help( ,, 'HELP',, "Não é permitido prosseguir sem informar código da etiqueta no Item "+PADL(cValToChar(nX), 4, "0")+"", 1, 0)						
				lRet := .F.	
			ElseIf  (Empty(ZPORD->BM_YIMPETI) .OR. ZPORD->BM_YIMPETI = 'N') .AND. !Empty(AllTrim(oGrid:ACOLS[nX,nPosEtimat])) 
				Help( ,, 'HELP',, "Não é permitido prosseguir, pois esse produto não requer o código da etiqueta no Item "+PADL(cValToChar(nX), 4, "0")+"", 1, 0)			
				lRet := .F.	
			EndIf
			ZPORD->(dbCloseArea())			
			 	
		EndIf
	Next nX
 

	If Len(oGrid:aCols) > 1			 
		For nX := 1 To Len(oGrid:aCols)
			if !oGrid:aCols[nX, len(oGrid:aCols[nX])] .AND. !Empty(AllTrim(oGrid:ACOLS[nX,nPosEtimat]))				
				For nW := 2 To Len(oGrid:aCols)	
					if !oGrid:aCols[nW, len(oGrid:aCols[nW])]  .AND. !Empty(AllTrim(oGrid:ACOLS[nW,nPosEtimat])) .AND. nX != nW
						If ( AllTrim(oGrid:ACOLS[nX,nPosEtimat]) == AllTrim(oGrid:ACOLS[nW,nPosEtimat]) )     
							alert("Etiquetas repetidas nos itens "+PADL(cValToChar(nX), 4, "0")+" e "+PADL(cValToChar(nW), 4, "0")+" . Favor alterar.")
							lRet := .F.
							Exit
						EndIf						
					EndIf				
				Next --nW
			EndIf
			If lRet == .F.
				Exit
			EndIf

		Next nX
	EndIf
	
return lRet

/*/{Protheus.doc} fVldEto
Funcao para validação da etiqueta original
@author Totvs.IURY
@since 23/10/2018
@type function
/*/
static function fVldEto(oGrid)

	If alltrim(M->ZV1_OPERAC) == "16"
		dbSelectArea("ZC2")
		ZC2->(dbSetOrder(1))
		ZC2->(DbGoTop())

		ZC2->(dbSeek(xFilial("ZC2") + M->ZV2_ETIORI))

		If ZC2->ZC2_STATEX <> "E"
			Help(, , "Help", , "Status da Etiqueta Diferente de Expedido. Verifique.", 1, 0 )
			return .F.
		Endif

	ElseIf !empty(M->ZV2_ETIORI)
		Help(, , "Help", , "Etiqueta Original só deve ser preenchida para Operação 16. Verifique.", 1, 0 )
		return .F.
	EndIf

	fVldProd(oGrid)

return .T.

/*/{Protheus.doc} fVldTot
Funcao para preenchimento do valor total
@author Paulo Cesar Camata
@since 06/03/2018
@type function
@history 11/11/2018, TOTVS-IURY, Alterado para buscar o preço automatico
/*/
static function fVldPrc(oGrid)

	local nPosQtd := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})
	local nPosTot := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLRTOT"})
	local nPosVal := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLUNIT"})
	Local nPosEtiOri := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_ETIORI"})

	Local cEtiOri := ""


	//Busca o preço da tabela quando o pedido for informado  a operação for 16 e a atualização não pelo proprio campo de valor
	If allTrim(M->ZV1_OPERAC) == "16" .AND. empty(M->ZV2_VLUNIT)
		If empty(M->ZV2_ETIORI)
			cEtiOri := oGrid:aCols[oGrid:nAt, nPosEtiOri]
		Else
			cEtiOri := M->ZV2_ETIORI
		EndIf

		If !empty(cEtiOri)
			oGrid:aCols[oGrid:nAt, nPosVal] := fBusPrc(cEtiOri)
		EndIf

	EndIf

	If Empty(M->ZV2_VLUNIT)

		If Empty(M->ZV2_ETIMAT) .AND. !Empty(M->ZV2_QUANT)
			//Alteracao por quantidade
			oGrid:aCols[oGrid:nAt, nPosTot] := M->ZV2_QUANT *  oGrid:aCols[oGrid:nAt, nPosVal]
		Else
			//Alteracao pela etiqueta
			oGrid:aCols[oGrid:nAt, nPosTot] := oGrid:aCols[oGrid:nAt, nPosQtd] *  oGrid:aCols[oGrid:nAt, nPosVal]
		Endif
		oGrid:refresh()
	else
		//Alteracao pelo campo valor
		oGrid:aCols[oGrid:nAt, nPosTot] := oGrid:aCols[oGrid:nAt, nPosQtd] * M->ZV2_VLUNIT
		oGrid:refresh()
	endif
return .T.

/*/{Protheus.doc} fAtuPreco
Atualiza o preço dos itens baseado no pedido
@author TOTVS-IURY
@since 11/11/2018
@type function
/*/
Static Function fAtuPreco()
	Local nX := 0
	Local nPreco := 0

	Local nPosCod := aScanX(oMSNewCont:aheader, {|x| allTrim(x[2]) == "ZV2_CODPRO"})
	local nPosQtd := aScanX(oMSNewCont:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})
	local nPosTot := aScanX(oMSNewCont:aheader, {|x| allTrim(x[2]) == "ZV2_VLRTOT"})
	local nPosVal := aScanX(oMSNewCont:aheader, {|x| allTrim(x[2]) == "ZV2_VLUNIT"})


	For nX := 1 to len(oMSNewCont:aCols)
		if !oMSNewCont:aCols[nX, len(oMSNewCont:aCols[nX])]

			nPreco := fBusPrc(M->ZV1_PEDORI,oMSNewCont:aCols[nX][nPosCod])

			If nPreco > 0
				oMSNewCont:aCols[nX][nPosVal] := nPreco
				oMSNewCont:aCols[nX][nPosTot] := nPreco * oMSNewCont:aCols[nX][nPosQtd]

			EndIf
		EndIf

	Next nX

	oMSNewCont:refresh()
return .T.

/*/{Protheus.doc} fBusPrc
Busca o Preço da tabela de preço
@author TOTVS.IURY
@since 23/10/2018
@type function
/*/
Static Function fBusPrc(cEtiOri)
	Local nPreco := 0
	Local cQuery := ""

	cQuery := " SELECT DA1_PRCVEN * B1_PESO AS PRECO"
	cQuery += " FROM " + retSqlName("ZC2") + " AS ZC2 (NOLOCK)"
	cQuery += " JOIN " + retSqlName("SC5") + " AS SC5 (NOLOCK)"
	cQuery += " 	ON C5_NUM = ZC2_PEDIDO"
	cQuery += "		AND C5_FILIAL='" + xFilial("SC5") + "'"
	cQuery += "		AND SC5.D_E_L_E_T_=''"
	cQuery += "	JOIN " + retSqlName("SC6") + " AS SC6 (NOLOCK)"
	cQuery += "		ON C6_NUM = C5_NUM"
	cQuery += "		AND C6_ITEM = ZC2_ITEMPV"
	cQuery += "		AND C6_FILIAL='" + xFilial("SC6") + "'"
	cQuery += "		AND SC6.D_E_L_E_T_=''"
	cQuery += " JOIN " + retSqlName("SB1") + " AS SB1 (NOLOCK)"
	cQuery += " 	ON B1_COD = ZC2_PRODUT"
	cQuery += "		AND B1_FILIAL='" + xFilial("SB1") + "'"
	cQuery += "		AND SB1.D_E_L_E_T_=''"
	cQuery += " JOIN " + retSqlName("DA1") + " AS DA1 (NOLOCK)"
	cQuery += "		ON C5_TABELA = DA1_CODTAB "
	cQuery += "		AND DA1_CODPRO = C6_PRODUTO"
	cQuery += "	    AND DA1_FILIAL='" + xFilial("DA1") + "'"
	cQuery += "	    AND DA1.D_E_L_E_T_=''"
	cQuery += " WHERE ZC2_FILIAL='" + xFilial("ZC2") + "'"
	cQuery += " AND ZC2_CODIGO='" + cEtiOri + "'"
	cQuery += " AND ZC2.D_E_L_E_T_=''"

	tcQuery cQuery new Alias "QRYPRC"

	If !QRYPRC->(EOF())
		nPreco := QRYPRC->PRECO
	EndIf

	QRYPRC->(dbCloseArea())

Return nPreco

/*/{Protheus.doc} fBusEstoque
Funcao para preenchimento do aCols caso tenha sido marcado Estoque Simz
@author Paulo Cesar Camata
@since 06/03/2018
@type function
@history 14/07/2019, BRAMETAL-Gabriel, Adicionado limitador de itens suportados na geração da solicitação eletronica, para evitar erros na criação do PV.
/*/
static function fBusEstoque()
	local cItem   := "0000"
	local nPeso   := 0
	local aVetor  := {}
	local cCodArm := getNewPar("BRA_ARMPAD", "11")
	local _cSelect, nPrcVen, nQtdVen, nVlrTot
	Local nCount := 0

	_cSelect := "SELECT B1_COD ZV2_CODPRO, RTRIM(B1_DESC) ZV2_DESPRO, B1_UM ZV2_UNID, B1_POSIPI ZV2_NCM, ROUND(B2_QATU, 3) ZV2_QUANT, ROUND(B2_CM1, 2) ZV2_VLUNIT " + CRLF
	_cSelect += "  FROM " + retSqlName("SB2") + " SB2 " + CRLF
	_cSelect += "  JOIN " + retSqlName("SB1") + " SB1 " + CRLF
	_cSelect += "    ON B1_FILIAL = " + valToSql(xFilial("SB1")) + CRLF
	_cSelect += "   AND B1_COD    = B2_COD " + CRLF
	_cSelect += "   AND B1_RASTRO = 'N' " + CRLF
	_cSelect += "   AND B1_MSBLQL <> '1' " + CRLF
	_cSelect += "   AND SB1.D_E_L_E_T_ = '' " + CRLF
	_cSelect += " WHERE B2_FILIAL = " + valToSql(xFilial("SB2")) + CRLF
	_cSelect += "   AND B2_QATU   > 0 " + CRLF
	_cSelect += "   AND B2_LOCAL  = " + valToSql(cCodArm) + CRLF
	_cSelect += "   AND SB2.D_E_L_E_T_ = '' " + CRLF

	tcQuery _cSelect Alias "SOLICIT" new

	// Total de itens retornados
	Count to nCount

	If nCount > nLimite
		MsgInfo("A quantidade de itens no armazém é maior que o limite de " + cValToChar(nLimite) + " itens permitidos." + Chr(13)+Chr(10) + Chr(13)+Chr(10) + ;
				 "Será gerado para esta solicitação somente a quantidade de itens permitidos, e para o restande deverá ser feita uma nova solicitação.", "Limite de itens na solicitação.")
	EndIf

	// Reposiciona o grid no primeiro item já que a função de contagem desposiciona
	SOLICIT->(DBGoTop())

	while !SOLICIT->(EoF()) .AND. Len(aVetor) < nLimite
		cItem := soma1(cItem)

		posicione("SB1", 1, xFilial("SB1") + SOLICIT->ZV2_CODPRO, "FOUND()")
		if SB1->B1_UM == "KG"
			nPeso += SOLICIT->ZV2_QUANT
		elseif SB1->B1_SEGUM == "KG"
			nPeso += convUm(SB1->B1_COD, 0, SOLICIT->ZV2_QUANT, 2)
		else
			nPeso += SOLICIT->ZV2_QUANT * SB1->B1_PESO // Nova Conversao
		endif

		nPrcVen := noRound(SOLICIT->ZV2_VLUNIT, tamSx3("ZV2_VLUNIT")[2])
		nQtdVen := noRound(SOLICIT->ZV2_QUANT, tamSx3("ZV2_QUANT")[2])
		nVlrTot := round(nQtdVen * nPrcVen, tamSx3("ZV2_VLRTOT")[2])

		aAdd(aVetor, {cItem, SOLICIT->ZV2_CODPRO, SOLICIT->ZV2_DESPRO, SOLICIT->ZV2_UNID, SOLICIT->ZV2_NCM, "", "", nQtdVen, nPrcVen, nVlrTot, .F.})

		SOLICIT->(dbSkip())
	endDo
	SOLICIT->(dbCloseArea())

	M->ZV1_PSBRU := nPeso
	M->ZV1_PSLIQ := nPeso
return aVetor

/*/{Protheus.doc} fCarItens
Funcao para carregar os itens
@author Paulo Cesar Camata
@since 07/03/2018
@type function
/*/
static function fCarItens()
	local aVetor := {}

	dbSelectArea("ZV2")
	ZV2->(dbSetOrder(1))
	ZV2->(dbGoTop())
	ZV2->(dbSeek(xFilial("ZV2") + ZV1->ZV1_NRDOC))

	while !ZV2->(EoF()) .and. allTrim(xFilial("ZV2") + ZV1->ZV1_NRDOC) == allTrim(ZV2->ZV2_FILIAL + ZV2->ZV2_NRDOC)
		posicione("SB1", 1, xFilial("SB1") + ZV2->ZV2_CODPRO, "FOUND()")
		aAdd(aVetor, {ZV2->ZV2_ITEDOC, SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, SB1->B1_POSIPI,ZV2_ETIORI,ZV2_ETIMAT, ZV2->ZV2_QUANT, ZV2->ZV2_VLUNIT, ZV2->ZV2_VLRTOT, .F.})
		ZV2->(dbSkip())
	endDo

return aVetor

/*/{Protheus.doc} fAtuPeso
Funcao para calcular o peso Liquido e Bruto conforme GRID passado como parametro
@author Paulo Cesar Camata
@since 07/03/2018
@type function
/*/
static function fAtuPeso(oGrid,cDelOk)
	local i
	local nPeso := 0
	local nPosCod := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_CODPRO"})
	local nPosQt  := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})
	local nPosVal := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLUNIT"})
	local nPos

	Default cDelOk := .F.

	for i := 1 to len(oGrid:aCols)
		if !oGrid:aCols[i, len(oGrid:aCols[i])] // Nao deletada

			posicione("SB1", 1, xFilial("SB1") + oGrid:aCols[i, nPosCod], "FOUND()")
			posicione("SB2", 1, xFilial("SB2") + oGrid:aCols[i, nPosCod] + SB1->B1_LOCPAD, "FOUND()")
			if SB1->B1_UM == "KG" .and. !empty(oGrid:aCols[i, 2])
				nPeso += oGrid:aCols[i, nPosQt]
			elseif SB1->B1_SEGUM == "KG" .and. !empty(oGrid:aCols[i, 2])
				nPeso += convUm(SB1->B1_COD, 0, M->ZV2_QUANT, 2)
			else
				If !empty(oGrid:aCols[i, 2])
					nPeso += oGrid:aCols[i, nPosQt] * SB1->B1_PESO // Nova Conversao
				Endif
			endif
		endif
	next i

	If !(cDelOk)
		M->ZV1_PSBRU := nPeso
		nPos := aScan(O:OWND:ACONTROLS,{|x| x:CREADVAR == "M->ZV1_PSBRU"})
		O:OWND:ACONTROLS[nPos]:REFRESH()
		M->ZV1_PSLIQ := nPeso
		nPos := aScan(O:OWND:ACONTROLS,{|x| x:CREADVAR == "M->ZV1_PSLIQ"})
		O:OWND:ACONTROLS[nPos]:REFRESH()
	Else
		If oGrid:aCols[oGrid:nAt, 11]
			M->ZV1_PSBRU := M->ZV1_PSBRU + oGrid:aCols[oGrid:nAt, nPosQt]
		Else
			M->ZV1_PSBRU := M->ZV1_PSBRU - oGrid:aCols[oGrid:nAt, nPosQt]
		Endif

		nPos := aScan(oGrid:OWND:ACONTROLS,{|x| x:CREADVAR == "M->ZV1_PSBRU"})
		oGrid:OWND:ACONTROLS[nPos]:REFRESH()

		If oGrid:aCols[oGrid:nAt, 11]
			M->ZV1_PSLIQ := M->ZV1_PSLIQ + oGrid:aCols[oGrid:nAt, nPosQt]
		Else
			M->ZV1_PSLIQ := M->ZV1_PSLIQ - oGrid:aCols[oGrid:nAt, nPosQt]
		Endif

		nPos := aScan(oGrid:OWND:ACONTROLS,{|x| x:CREADVAR == "M->ZV1_PSLIQ"})
		oGrid:OWND:ACONTROLS[nPos]:REFRESH()
	Endif

	oGrid:aCols[oGrid:nAt, nPosVal] := ROUND(SB2->B2_CM1, 2)
	oGrid:refresh()
	fVldPrc(oGrid)
return .T.

/*/{Protheus.doc} fConfirm
Funcao chamado no botao confirmar da tela
@author Paulo Cesar Camata
@since 07/03/2018
@type function
/*/
static function fConfirm(nOpc, oDlg, oGrid)

	Local lAutorizado := .F.
	local i, lAchou, cNumDoc
	local lIncluiu := .F.
	local _aRet    := {}
	Local cIdpriv  := getNewPar("BRA_SOLPRI", "000687")
	Local cCodOper:= getNewPar("BRA_CODOPE", "19")

	local nPosIteDoc := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_ITEDOC"})
	local nPosCodPro  := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_CODPRO"})
	local nPosUnid := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_UNID"})
	local nPosNcm := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_NCM"})
	local nPosEtiori := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_ETIORI"})
	local nPosEtimat := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_ETIMAT"})
	local nPosQuant := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_QUANT"})
	local nPosVlunit := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLUNIT"})
	local nPosVlTot := aScanX(oGrid:aheader, {|x| allTrim(x[2]) == "ZV2_VLRTOT"})

	if nOpc == 2 // Visualizar
		oDlg:end()

	elseif nOpc == 5 // Excluir
		if msgYesNo("Confirma exclusão do documento " + ZV1->ZV1_NRDOC + "?")
			begin transaction
				cNumDoc := ZV1->ZV1_NRDOC
				dbSelectArea("ZV2")
				ZV2->(dbSetOrder(1))
				ZV2->(dbGoTop())
				ZV2->(dbSeek(xFilial("ZV2") + cNumDoc))
				while !ZV2->(EoF()) .and. allTrim(ZV2->ZV2_FILIAL + ZV2->ZV2_NRDOC) == allTrim(xFilial("ZV2") + cNumDoc)
					recLock("ZV2", .F.)
					ZV2->(dbDelete())
					ZV2->(msUnlock())

					ZV2->(dbSkip())
				enddo

				recLock("ZV1", .F.)
				ZV1->(dbDelete())
				ZV1->(msUnlock())

				MEnviaMail("B08", {cNumDoc, 5})
			end Transaction

			msgInfo("Solicitação excluída com SUCESSO")
			oDlg:end()
			return nil
		else
			return nil
		endif

	elseif nOpc == 3 // Incluir

		// validando acols
		If fValid(oGrid,0) == .F. 
			return .F.
		EndIf

		_aRet := fVldCpoObr()
		if !_aRet[1]
			Help(, , "Help", , "Campo obrigatório não preenchidos " + _aRet[2] + ". Verifique.", 1, 0)
			return .F.
		endif
		If M->ZV1_OPERAC ==cCodOper
		  lAutorizado := U_fUsrInRule(cIdpriv)
			If !(lAutorizado)
				MsgAlert("Usuário sem permissão. ","Atenção")
				Return(.F.)
			Endif
		Endif

		begin transaction
			for i := 1 to len(oGrid:aCols)
				if !oGrid:aCols[i, len(oGrid:aCols[i])] .and. !empty(oGrid:aCols[i, 2]) // Nao deletada
					if !lIncluiu
						recLock("ZV1", .T.)
						ZV1->ZV1_FILIAL := xFilial("ZV1")
						ZV1->ZV1_NRDOC  := M->ZV1_NRDOC
						ZV1->ZV1_ESTOQU := M->ZV1_ESTOQU
						ZV1->ZV1_OPERAC := M->ZV1_OPERAC
						ZV1->ZV1_OBS    := M->ZV1_OBS
						ZV1->ZV1_CONPAG := M->ZV1_CONPAG
						ZV1->ZV1_CODCLI := M->ZV1_CODCLI
						ZV1->ZV1_LOJCLI := M->ZV1_LOJCLI
						ZV1->ZV1_TIPFRE := M->ZV1_TIPFRE
						ZV1->ZV1_PLCVEI := M->ZV1_PLCVEI
						ZV1->ZV1_CODTRA := M->ZV1_CODTRA
						ZV1->ZV1_VOLUME := M->ZV1_VOLUME
						ZV1->ZV1_ESPECI := M->ZV1_ESPECI
						ZV1->ZV1_PSLIQ  := M->ZV1_PSLIQ
						ZV1->ZV1_PSBRU  := M->ZV1_PSBRU
						ZV1->ZV1_USUINC := __cUserId
						ZV1->ZV1_DATINC := dDataBase
						ZV1->ZV1_HORINC := left( time(), 5)
						ZV1->(msUnlock())

						lIncluiu := .T.
					endif

					recLock("ZV2", .T.)
					ZV2->ZV2_FILIAL := xFilial("ZV2")
					ZV2->ZV2_NRDOC  := M->ZV1_NRDOC
					ZV2->ZV2_ITEDOC := oGrid:aCols[i, nPosIteDoc]
					ZV2->ZV2_CODPRO := oGrid:aCols[i, nPosCodPro]
					ZV2->ZV2_UNID   := oGrid:aCols[i, nPosUnid]
					ZV2->ZV2_NCM    := oGrid:aCols[i, nPosNcm]
					ZV2->ZV2_ETIORI := oGrid:aCols[i, nPosEtiori]
					ZV2->ZV2_ETIMAT := oGrid:aCols[i, nPosEtimat]
					ZV2->ZV2_QUANT  := oGrid:aCols[i, nPosQuant]
					ZV2->ZV2_VLUNIT := oGrid:aCols[i, nPosVlunit]
					ZV2->ZV2_VLRTOT := oGrid:aCols[i, nPosVlTot]
					ZV2->(msUnlock())
				endif
			next i
		end Transaction

		if lIncluiu
			MEnviaMail("B08", {ZV1->ZV1_NRDOC, 3})
			msgInfo("Solicitação incluída com SUCESSO")
			oDlg:end()
			return nil
		else
			msgStop("Não existem dados a serem inseridos.")
			return nil
		endif

	elseif nOpc == 4 // Alterar
//		if !fVldCpoObr()
//			Help(, , "Help", , "Existem campos obrigatórios não preenchidos. Verifique.", 1, 0)
//			return .F.
//		endif

		begin transaction
			recLock("ZV1", .F.)
			ZV1->ZV1_OPERAC := M->ZV1_OPERAC
			ZV1->ZV1_OBS    := M->ZV1_OBS
			ZV1->ZV1_CONPAG := M->ZV1_CONPAG
			ZV1->ZV1_CODCLI := M->ZV1_CODCLI
			ZV1->ZV1_LOJCLI := M->ZV1_LOJCLI
			ZV1->ZV1_TIPFRE := M->ZV1_TIPFRE
			ZV1->ZV1_PLCVEI := M->ZV1_PLCVEI
			ZV1->ZV1_CODTRA := M->ZV1_CODTRA
			ZV1->ZV1_VOLUME := M->ZV1_VOLUME
			ZV1->ZV1_ESPECI := M->ZV1_ESPECI
			ZV1->ZV1_PSLIQ  := M->ZV1_PSLIQ
			ZV1->ZV1_PSBRU  := M->ZV1_PSBRU
			ZV1->(msUnlock())

				for i := 1 to len(oGrid:aCols)
					if oGrid:aCols[i, len(oGrid:aCols[i])] // Deletado
						dbSelectArea("ZV2")
						ZV2->(dbSetOrder(1))
						ZV2->(dbGoTop())
						if ZV2->(dbSeek(xFilial("ZV2") + ZV1->ZV1_NRDOC + oGrid:aCols[i, 1]))
							recLock("ZV2", .F.)
							ZV2->(dbDelete())
							ZV2->(msUnlock())
						endif
					else
						dbSelectArea("ZV2")
						ZV2->(dbSetOrder(1))
						ZV2->(dbGoTop())
						if ZV2->(dbSeek(xFilial("ZV2") + ZV1->ZV1_NRDOC + oGrid:aCols[i, 1]))
							lAchou := .T.
						else
							lAchou := .F.
						endif

						recLock("ZV2", !lAchou)
						ZV2->ZV2_FILIAL := xFilial("ZV2")
						ZV2->ZV2_NRDOC  := ZV1->ZV1_NRDOC
						ZV2->ZV2_ITEDOC := oGrid:aCols[i, nPosIteDoc]
						ZV2->ZV2_CODPRO := oGrid:aCols[i, nPosCodPro]
						ZV2->ZV2_UNID   := oGrid:aCols[i, nPosUnid]
						ZV2->ZV2_NCM    := oGrid:aCols[i, nPosNcm]
						ZV2->ZV2_ETIORI := oGrid:aCols[i, nPosEtiori]
						ZV2->ZV2_ETIMAT := oGrid:aCols[i, nPosEtimat]
						ZV2->ZV2_QUANT  := oGrid:aCols[i, nPosQuant]
						ZV2->ZV2_VLUNIT := oGrid:aCols[i, nPosVlunit]
						ZV2->ZV2_VLRTOT := oGrid:aCols[i, nPosVlTot]
						ZV2->(msUnlock())

						If Empty(oGrid:aCols[i, nPosEtimat])
							If Left(oGrid:aCols[i, nPosEtimat],1) == "M"
								UZT->(dbSeek(xFilial("UZT") + oGrid:aCols[i, nPosEtimat]))
								recLock("UZT",.F.)
								UZT->UZT_MSBLQL := "1"
								UZT->(msUnlock())
							Else
								ZC2->(dbSeek(xFilial("ZC2") + oGrid:aCols[i, nPosEtimat]))
								recLock("ZC2",.F.)
								ZC2->ZC2_MSBLQL := "1"
								ZC2->(msUnlock())
							Endif
						Endif
					endif
				next i

			MEnviaMail("B08", {ZV1->ZV1_NRDOC, 4})

		end Transaction
		msgInfo("Solicitação alterada com SUCESSO")
		oDlg:end()
		return nil
	endif
return nil

/*/{Protheus.doc} fVldCpoObr
Funcao para verificar se todos os campos obrigatorios foram preenchidos
@author Paulo Cesar Camata
@since 23/03/2018
@type function
@history 23/10/2018, TOTVS-IURY, adicionado validação conforme chamado 14596
/*/
static function fVldCpoObr()
	local _aRet := { .T., ""}

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("ZV1"))
	while !SX3->(EoF()) .and. SX3->X3_ARQUIVO == "ZV1" .and. _aRet[1]

		if SX3->X3_CONTEXT <> "V" .and. !empty(SX3->X3_OBRIGAT)
			if empty(&("M->" + SX3->X3_CAMPO))
				_aRet := { .F., allTrim(SX3->X3_TITULO)}
			endif
		endif

		SX3->(dbSkip())
	endDo


return _aRet

/*/{Protheus.doc} BRA637FAT
Funcao para envio de e-mail para usuário criador da Solicitacao para aviso do faturamento
@author Paulo Cesar Camata
@since 10/03/2018
@type function
/*/
user function BRA637FAT()
	local oProcess:= TWFProcess():New("000020", "FATURAMENTO SOLICITACAO ")
	local oHtml, aInfUsu

	PswOrder(1)
	if PswSeek(ZV1->ZV1_USUINC, .T.)
		aInfUsu := Pswret(1)

		if !empty(aInfUsu[1,14])
			oProcess:NewTask("inicio", "\workflow\modelos\faturamento\FAT_SOL_ELETRONICA.HTM")
			oProcess:ClientName(ZV1->ZV1_USUINC)
			oProcess:cTo      := allTrim(aInfUsu[1,14]) // Email do usuario que inclui a solicitacao
			oProcess:cSubject := "Workflow - Faturamento Solicitação Eletronica - " + ZV1->ZV1_NRDOC
			oHtml   := oProcess:oHtml
			oHtml:valbyname("NUMSOL", ZV1->ZV1_NRDOC)
			oHtml:valbyname("NUMNFS", SF2->F2_DOC)

			oProcess:Start()
			oProcess:Free()
		else
			Help(, , "Help", , "Usuário " + UsrRetName(ZV1->ZV1_USUINC) + " da solicitação eletrônica não possui e-mail cadastrado. Verifique.", 1, 0 )
			return nil
		endif
	endif

return nil

/*/{Protheus.doc} BRA637POS
Funcao chamada no inicializador padrao do campo ZV1_DESOPE
@author Paulo Cesar Camata
@since 12/03/2018
@type function
/*/
user function BRA637POS()
return posicione("SX5", 1, xFilial("SX5") + allTrim(getNewPar("BRA_CADTAB", "ZB")) + ZV1->ZV1_OPERAC, "X5_DESCRI")