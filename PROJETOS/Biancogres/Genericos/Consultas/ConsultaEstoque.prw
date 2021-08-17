#Include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ConsEst
@description CONSULTA A POSICAO DO PRODUTO SELECIONADO NO ESTOQUE
@author RENEWED BY FERNANDO ROCHA
@since 2020 - COVID-19 
@version 1.0
@type function
/*/

User Function ConsEst()

	Local aAreaBKP		:= GetArea()

	Private cProduto	:= Space(15)
	Private cFORMATO	:= Space(15)
	Private cLINHA		:= Space(15)
	Private cCLASSE		:= Space(15)
	Private cAlmox		:= '02/04'
	Private cMarcaPro	:= Space(4)
	Private lFiltraEmp  := .F.
	Private AALOTE		:= Space(10)

	//Variaveis da linha posicionada
	Private _cEmpSel
	Private _cProdSel
	Private _cLoteSel
	Private _cRuaSel
	Private _nQtdDispo
	Private _cLocalSel	

	//TRATA MVC NA TELA DE RESERVA
	Private lMVC 		:= .F.
	If Upper(Alltrim(FunName())) == "MATA430"
		lMVC := U_BIAChkMV()
	EndIf

	Private oDlgDet, oDlg15

	//BROWSE DE ESTOQUE PRINCIPAL
	Private oBrowse
	Private aBrwList := {}

	//PROJETO RESERVA DE OP - FERNANDO/FACILE
	Private oWBrowse1
	Private aWBrowse1 := {}

	cAlmox := U_MontaSQLIN(cAlmox,'/',2)

	//Fernando/Facile em 03/09/2015 - OS 2318-15 - Pedidos de Amostra
	If Type("M->C5_YSUBTP") <> "U" .And.  !Empty(M->C5_YSUBTP) .And. AllTrim(M->C5_YSUBTP) $ "A#M"

		cAlmox := "'05'"

		//Ticket VINILICO => Pedidos bonificação do almoxarifado amostra
	elseif Type("M->C5_YLINHA") <> "U" .And. AllTrim(M->C5_YLINHA) == "6" .And.  AllTrim(M->C5_YSUBTP) $ "B"

		cAlmox += "'02','05'"

	EndIf

	//Controla a abertura do programa
	cContador ++
	If cContador > 1
		Return
	EndIf

	Markbrow()

	//Controla a abertura do programa
	cContador := 0
	RestArea(aAreaBKP)

Return

/*/{Protheus.doc} MARKBROW
@description MONTA O OBROWSE PARA LISTAS OS TITULOS BLOQUEADOS
@author BRUNO MADALENO
@since 21/10/05 
@version 1.0
@type function
/*/
Static Function Markbrow()

	Local nCol, nLin, nLinDlg, nColDlg

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	nLinDlg := nLin*.850
	nColDlg := nCol*.900

	//Popular varivel cProduto conforme Funcao Chamadora
	GetTelaProp(2)

	// Cria Dialog
	oDlg15 := MsDialog():New(10, 10, nLinDlg, nColDlg, "Consulta Estoque",,,,DS_MODALFRAME,,,,,.T.)
	oDlg15:lCentered := .T.
	oDlg15:bValid := {|| .F. }

	oLayer := FWLayer():New()
	oLayer:Init(oDlg15, .F., .T.)

	// Adiciona linha 1 ao Layer
	oLayer:AddLine("LIN1", 15, .F.)
	oLayer:AddCollumn("COL1", 100, .T., "LIN1")
	oLayer:AddWindow("COL1", "WND1", "Parâmetros", 100, .F. ,.T.,, "LIN1", { || })

	oPanel1 := oLayer:GetWinPanel("COL1", "WND1", "LIN1")

	_nLeft := 10
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "CÓDIGO PRODUTO:"
	oSay:nWidth 	:= 100
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 100
	oGet11 := TGet():Create(oPanel1)
	oGet11:cName 	:= "oGet11"
	oGet11:nWidth 	:= 100
	oGet11:nHeight 	:= 20
	oGet11:nLeft	:= _nLeft
	oGet11:cVariable := "cProduto"
	oGet11:bSetGet := bSetGet(cProduto)
	oGet11:Picture := "@!"
	oGet11:cF3 := "SB1"

	_nLeft += 110
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "LOTE:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 30
	oGet12 := TGet():Create(oPanel1)
	oGet12:cName := "oGet12"
	oGet12:nWidth 	:= 50
	oGet12:nHeight 	:= 20
	oGet12:nLeft	:= _nLeft
	oGet12:cVariable	:= "AALOTE"
	oGet12:bSetGet 		:= bSetGet(AALOTE)
	oGet12:Picture 		:= "@!"

	_nLeft += 60
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "FORMATO:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 60
	oGet13 := TGet():Create(oPanel1)
	oGet13:cName 	:= "oGet13"
	oGet13:nWidth 	:= 50
	oGet13:nHeight 	:= 20
	oGet13:nLeft	:= _nLeft
	oGet13:cVariable := "cFORMATO"
	oGet13:bSetGet 	:= bSetGet(cFORMATO)
	oGet13:Picture 	:= "@!"
	oGet13:cF3 		:= "ZZ6"

	_nLeft += 60
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "LINHA:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 40
	oGet14 := TGet():Create(oPanel1)
	oGet14:cName := "oGet14"
	oGet14:nWidth 	:= 50
	oGet14:nHeight 	:= 20
	oGet14:nLeft	:= _nLeft
	oGet14:cVariable	:= "cLINHA"
	oGet14:bSetGet 		:= bSetGet(cLINHA)
	oGet14:Picture 		:= "@!"
	oGet14:cF3 			:= "ZZ7"

	_nLeft += 60
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "CLASSE:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 50
	oGet15 := TGet():Create(oPanel1)
	oGet15:cName 	:= "oGet15"
	oGet15:nWidth 	:= 50
	oGet15:nHeight 	:= 20
	oGet15:nLeft	:= _nLeft
	oGet15:cVariable := "cCLASSE"
	oGet15:bSetGet := bSetGet(cCLASSE)
	oGet15:Picture := "@!"
	oGet15:cF3 := "ZZ8"

	_nLeft += 60
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "MARCA:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 50
	oGet16 := TGet():Create(oPanel1)
	oGet16:cName 	:= "oGet16"
	oGet16:nWidth 	:= 50
	oGet16:nHeight 	:= 20
	oGet16:nLeft	:= _nLeft
	oGet16:cVariable := "cMarcaPro"
	oGet16:bSetGet 	:= bSetGet(cMarcaPro)
	oGet16:Picture 	:= "@!"
	oGet16:cF3 		:= "Z37"

	_nLeft += 60
	oSay := TSay():Create(oPanel1)
	oSay:cCaption 	:= "ALMOX:"
	oSay:nWidth 	:= 50
	oSay:nHeight 	:= 20
	oSay:nLeft		:= _nLeft

	_nLeft += 50
	oGet17 := TGet():Create(oPanel1)
	oGet17:cName 	:= "oGet17"
	oGet17:nWidth 	:= 50
	oGet17:nHeight 	:= 20
	oGet17:nLeft	:= _nLeft
	oGet17:cVariable 	:= "cAlmox"
	oGet17:bSetGet 		:= bSetGet(cAlmox)
	oGet17:Picture 		:= "@!"

	_nLeft += 60
	oChk := TCheckBox():Create(oPanel1)
	oChk:cName := 'oChk'
	oChk:cCaption := "Na Empresa?"
	oChk:nLeft := _nLeft
	oChk:nWidth := 100
	oChk:nHeight := 20
	oChk:cVariable := "lFiltraEmp"
	oChk:bSetGet := bSetGet(lFiltraEmp)

	oBtnFiltro := TBUTTON():Create(oPanel1)
	oBtnFiltro:cCaption	:= "Filtrar"
	oBtnFiltro:nWidth 	:= 60
	oBtnFiltro:cTooltip 	:= "Pesquisar Registros"
	oBtnFiltro:bAction 	:= {|| Filtrar() }

	oBtnObs := TBUTTON():Create(oPanel1)
	oBtnObs:cCaption	:= "Obs. Prod."
	oBtnObs:nWidth 	:= 60
	oBtnObs:cTooltip 	:= "Observações"
	oBtnObs:bAction 	:= {|| ShowProdObs(_cProdSel, _cLoteSel) }

	oBtnHist := TBUTTON():Create(oPanel1)
	oBtnHist:cCaption	:= "Histórico"
	oBtnHist:nWidth 	:= 60
	oBtnHist:cTooltip 	:= "Consulta Histórico"
	oBtnHist:bAction 	:= {|| fHistorico(_cProdSel, _cLoteSel) }

	oBtnTela 	:= Nil
	oBtnOP		:= Nil

	//Criar Botoes Especificos conforme Funcao Chamadora
	GetTelaProp(1, oPanel1)

	//ALINHAMENTO DOS BOTOES NO PAINEL SUPERIOR
	If (oBtnOP <> Nil)
		oBtnOP:Align	:= CONTROL_ALIGN_RIGHT
	EndIf

	If (oBtnTela <> Nil)
		oBtnTela:Align	:= CONTROL_ALIGN_RIGHT
	EndIf

	oBtnHist:Align		:= CONTROL_ALIGN_RIGHT
	oBtnObs:Align		:= CONTROL_ALIGN_RIGHT
	oBtnFiltro:Align	:= CONTROL_ALIGN_RIGHT

	//LISTA DE ESTOQUE DISPONIVEL
	oLayer:AddLine("LIN2", 60, .F.)
	oLayer:AddCollumn("COL2", 100, .T., "LIN2")
	oLayer:AddWindow("COL2", "WND2", "Estoque Disponível", 100, .F. ,.T.,, "LIN2", { || })

	oPanel2 := oLayer:GetWinPanel("COL2", "WND2", "LIN2")

	oBrowse := TCBrowse():New(000,000,000,000,,,,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.)
	oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oBrowse:AddColumn(TcColumn():New("NS"			, {|| aBrwList[oBrowse:nAt, 01] }, "@!"				,nil,nil,"Left"		,02,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("PROD."		, {|| aBrwList[oBrowse:nAt, 02] }, "@!"				,nil,nil,"Left"		,05,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("DESCRIÇÃO"	, {|| aBrwList[oBrowse:nAt, 03] }, "@!"				,nil,nil,"Left"		,200,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("LOTE"			, {|| aBrwList[oBrowse:nAt, 04] }, "@!"				,nil,nil,"Left"		,10,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("DATA LOTE"	, {|| aBrwList[oBrowse:nAt, 05] }, "@!"				,nil,nil,"Center"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("EMPRESA"		, {|| aBrwList[oBrowse:nAt, 06] }, "@!"				,nil,nil,"Left"		,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("ALMOX"		, {|| aBrwList[oBrowse:nAt, 07] }, "@!"				,nil,nil,"Left"		,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("QUANT."		, {|| aBrwList[oBrowse:nAt, 08] }, "@E 999,999.99"	,nil,nil,"Right"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("EMP.PED."		, {|| aBrwList[oBrowse:nAt, 09] }, "@E 999,999.99"	,nil,nil,"Right"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("EMP.RES."		, {|| aBrwList[oBrowse:nAt, 10] }, "@E 999,999.99"	,nil,nil,"Right"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("DISPON."		, {|| aBrwList[oBrowse:nAt, 11] }, "@E 999,999.99"	,nil,nil,"Right"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("PEDCART"		, {|| aBrwList[oBrowse:nAt, 12] }, "@E 999,999.99"	,nil,nil,"Right"	,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("QUANT. PLT"	, {|| aBrwList[oBrowse:nAt, 13] }, "@!"				,nil,nil,"Left"		,30,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("CX"			, {|| aBrwList[oBrowse:nAt, 14] }, "@E 9,999"		,nil,nil,"Right"	,20,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("CONV"			, {|| aBrwList[oBrowse:nAt, 15] }, "@E 99.99"		,nil,nil,"Right"	,20,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("PESO B./M2"	, {|| aBrwList[oBrowse:nAt, 16] }, "@E 99.99999"	,nil,nil,"Right"	,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oBrowse:AddColumn(TcColumn():New("RUA"			, {|| aBrwList[oBrowse:nAt, 17] }, "@!"				,nil,nil,"Left"		,20,.F.,.F.,nil,nil,nil,.F.,nil))

	oBrowse:lHScroll := .T.
	oBrowse:lVScroll := .T.

	aBrwList := {}
	Aadd(aBrwList,{"","","","","","","",0,0,0,0,0,"",0,0,0,""})

	oBrowse:SetArray(aWBrowse1)
	oBrowse:Refresh()

	oBrowse:bLDblClick := {|| GetSelProd(), Detalhes() }
	oBrowse:bSeekChange := {|| GetSelProd() }
	//oBrowse:oBrowse:bHeaderClick := {|oBrowse, nCol| Ordena(nCol)}     
	aBrwOrder	:= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0}
	oBrowse:bHeaderClick := {|oBrw, nCol| Sort(nCol, aBrwOrder, aBrwList, oBrowse, 0) }
	
	//PAINEL DE LISTAGEM DE OPs
	oLayer:AddLine("LIN3", 25, .F.)
	oLayer:AddCollumn("COL3", 100, .T., "LIN3")
	oLayer:AddWindow("COL3", "WND3", "Previsão de Produção", 100, .F. ,.T.,, "LIN3", { || })

	oPanel3 := oLayer:GetWinPanel("COL3", "WND3", "LIN3")

	oWBrowse1 := TCBrowse():New(000,000,000,000,,,,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.)
	oWBrowse1:Align := CONTROL_ALIGN_ALLCLIENT

	oWBrowse1:AddColumn(TcColumn():New("Produto"	, {|| aWBrowse1[oWBrowse1:nAt, 01]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("OP"			, {|| aWBrowse1[oWBrowse1:nAt, 02]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("Item"		, {|| aWBrowse1[oWBrowse1:nAt, 03]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("Seq"		, {|| aWBrowse1[oWBrowse1:nAt, 04]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("Empresa"	, {|| aWBrowse1[oWBrowse1:nAt, 05]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("Dt.Dispo"	, {|| aWBrowse1[oWBrowse1:nAt, 06]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oWBrowse1:AddColumn(TcColumn():New("Saldo"		, {|| aWBrowse1[oWBrowse1:nAt, 07]}, "@E 999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))

	aWBrowse1 := {}
	Aadd(aWBrowse1,{"","","","","","",0})

	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:Refresh()

	oDlg15:Activate()

Return

Static Function GetTelaProp(_nOpt, oPanel1)

//_nOpt == 1 ==> Criar Botoes Especificos da Tela
//_nOpt == 2 ==> Popular Variaveis da Tela  //cProduto

	Local _cFunName 	:= UPPER(ALLTRIM(FUNNAME()))
	Local oModelAux 	:= FWModelActive()

	IF _cFunName == "MATA430"
		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			If ALTERA = .T. .OR. INCLUI = .T.

				IF (_nOpt == 1)

					oBtnTela := TBUTTON():Create(oPanel1)
					oBtnTela:cCaption	:= "Reserva"
					oBtnTela:nWidth 	:= 60
					oBtnTela:cTooltip 	:= "Selecionar Lote para Reserva"
					oBtnTela:bAction 	:= {|| Prenche_Re() }

				ELSEIF (_nOpt == 2)

					If lMVC
						cProduto := oModelAux:GetValue( 'SC0GRID', 'C0_PRODUTO' )
					Else
						If Gdfieldget("C0_PRODUTO",n) <> ""
							cProduto := Gdfieldget("C0_PRODUTO",n)
						EndIf
					EndIf
				ENDIF

			ENDIF
		EndIf

	ELSEIF _cFunName == "MATA410"

		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			IF ALTERA = .T. .OR. INCLUI = .T.

				IF (_nOpt == 1)

					oBtnTela := TBUTTON():Create(oPanel1)
					oBtnTela:cCaption	:= "Pedido"
					oBtnTela:nWidth 	:= 60
					oBtnTela:cTooltip 	:= "Selecionar Lote para Pedido"
					oBtnTela:bAction 	:= {|| Prenche_Re() }

					//Fernando em 15/01/15 - botao para escolher OP para o pedido
					IF ALTERA

						oBtnOP := TBUTTON():Create(oPanel1)
						oBtnOP:cCaption	:= "Sel.OP"
						oBtnOP:nWidth 		:= 60
						oBtnOP:cTooltip 	:= "Selecionar OP para Pedido"
						oBtnOP:bAction 	:= {|| Prenche_Op() }

					ENDIF

				ELSEIF (_nOpt == 2)

					IF ALLTRIM(ACOLS[N,2]) <> ""
						cProduto := ACOLS[N,2]
					ENDIF

				ENDIF

			ENDIF
		EndIf

	ELSEIF _cFunName == "MATA440"

		If Type("ALTERA") <> "U" .And. Type("ALTERA") <> "U"
			IF ALTERA = .T. .OR. INCLUI = .T.

				IF (_nOpt == 1)

					oBtnTela := TBUTTON():Create(oPanel1)
					oBtnTela:cCaption	:= "Liberação"
					oBtnTela:nWidth 		:= 60
					oBtnTela:cTooltip 	:= "Selecionar Lote para Liberação"
					oBtnTela:bAction 	:= {|| Prenche_Re() }

				ELSEIF (_nOpt == 2)

					IF ALLTRIM(ACOLS[N,2]) <> ""
						cProduto := ALLTRIM(ACOLS[N,2])
					ENDIF

				ENDIF

			ENDIF
		EndIf

	ELSEIF _cFunName == "BFATTE01"

		IF (_nOpt == 2)
			IF ALLTRIM(ACOLS[N,2]) <> ""
				cProduto := ALLTRIM(ACOLS[N,2])
			ENDIF
		ENDIF

	ELSEIF _cFunName == "BIA229"

		IF (_nOpt == 2)

			oModel	:= FwModelActive()
			If Type("oModel") <> "U"
				oModelDetalhe	:= oModel:GetModel('DETAIL')
				cProduto		:= oModelDetalhe:GetValue('Z55_PROD')

				//Fernando em 11/10/2017 - para a tela de inclusao de proposta de engenharia chamada de dentro do BIA229
			ElseIf (Type("n") <> "U" .And. GdFieldGet("Z69_CODPRO", n) <> nil)
				cProduto	:= GdFieldGet("Z69_CODPRO", n)
			EndIf

		ENDIF

	ELSEIF _cFunName == "BPOLTE03"

		IF (_nOpt == 1)

			oModel		:= FwModelActive()
			IF Type("oModel") <> "U"

				__nOpc		:= oModel:getoperation()

				IF ( __nOpc == MODEL_OPERATION_INSERT .or. __nOpc == MODEL_OPERATION_UPDATE )

					oBtnTela := TBUTTON():Create(oPanel1)
					oBtnTela:cCaption	:= "Politica"
					oBtnTela:nWidth 		:= 60
					oBtnTela:cTooltip 	:= "Selecionar Lote para Politica"
					oBtnTela:bAction 	:= {|| Prenche_Re() }

				ENDIF

			ENDIF

		ELSEIF (_nOpt == 2)

			oModel		:= FwModelActive()
			IF Type("oModel") <> "U"

				__nOpc		:= oModel:getoperation()

				IF ( __nOpc == MODEL_OPERATION_INSERT .or. __nOpc == MODEL_OPERATION_UPDATE )

					cProduto	:= oModel:GetModel("CamposZA0"):GetValue("ZA0_CODPRO")

				ENDIF

			ENDIF

		ENDIF

	ENDIF

RETURN

Static Function Prenche_Op()

	If Len(aWBrowse1) > 0 .And. oWBrowse1:nAt > 0
		
		If (ALLTRIM(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_BLQ"})]) == 'R')
			MsgAlert("Item pedido com residuo eliminado.")
		Else
			Gdfieldput("C6_NUMOP",aWBrowse1[oWBrowse1:nAt][2],n)
			Gdfieldput("C6_ITEMOP",aWBrowse1[oWBrowse1:nAt][3],n)
			oDlg15:End()			
		EndIf		

	EndIf

Return

//BROWSE DE SALDOS EM OP - PROJETO COMERCIAL/RESERVA DE OP - FERNANDO/FACILE - 28/04/2014
//(Thiago Dantas - 16/04/15) -> Produto OutSorcing
Static Function PesqOPSld(cProduto,cFORMATO,cLINHA,cCLASSE,cEmpOut)
	Local _aListOP
	Local I
	Local _aAux
	Local cAliasTmp

	aWBrowse1 := {}

	If Substr(cProduto,1,2) <> "C1"

		If Empty(cEmpOut) .And. AllTrim(CEMPANT) <> "07"

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp

				select * from FNC_ROP_GET_OPEMP(%XFILIAL:SC2%,%Exp:DTOS(dDataBase)%,%Exp:DTOS(dDataBase)%,'','',%Exp:cProduto%,'',0,'')

			EndSql

			_aListOP := {}

			While !(cAliasTmp)->(Eof())

				_aListAux := U_FRRT04PO("", "",cProduto, 0, "X", , , AllTrim(cFORMATO), AllTrim(cLINHA), AllTrim(cCLASSE), (cAliasTmp)->EMP)

				FOR I := 1 To Len(_aListAux)

					aAdd(_aListOP, _aListAux[I])

				NEXT I

				(cAliasTmp)->(DbSkip())
			EndDo

			(cAliasTmp)->(DbCloseArea())

		Else

			//Fernando em 23/04/15 - 5o parametro trocado de "S" para "X" - lista todas as OPs indenpendente do saldo estar zerado ou negativo
			_aListOP := U_FRRT04PO("", "",cProduto, 0, "X", , , AllTrim(cFORMATO), AllTrim(cLINHA), AllTrim(cCLASSE), cEmpOut)

		EndIf

	Else

		_aListOP := {}

	EndIf


	If Len(_aListOP) > 0

		FOR I := 1 To Len(_aListOP)

			_aAux := {}
			AAdd(_aAux,_aListOP[I][6])
			AAdd(_aAux,_aListOP[I][1])
			AAdd(_aAux,_aListOP[I][2])
			AAdd(_aAux,_aListOP[I][3])
			AAdd(_aAux,_aListOP[I][7])
			AAdd(_aAux,DTOC(_aListOP[I][4]))
			AAdd(_aAux,_aListOP[I][5])

			AAdd(aWBrowse1,_aAux)

		NEXT I

		//Ticket 27254: Corrigir ordenação das OP's no F6
		aWBrowse1 := aSort(aWBrowse1,,,{|x,y| Ctod(x[6]) < Ctod(y[6])})

	Else

		Aadd(aWBrowse1,{"","","","","","",0})

	EndIf

	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {;
		aWBrowse1[oWBrowse1:nAt,1],;
		aWBrowse1[oWBrowse1:nAt,2],;
		aWBrowse1[oWBrowse1:nAt,3],;
		aWBrowse1[oWBrowse1:nAt,4],;
		aWBrowse1[oWBrowse1:nAt,5],;
		aWBrowse1[oWBrowse1:nAt,6],;
		aWBrowse1[oWBrowse1:nAt,7];
		}}
	oWBrowse1:Refresh()

Return


/*/{Protheus.doc} Prenche_Re
@description preenche variaveis da linha selecionada
@author Fernando Rocha
/*/
Static Function GetSelProd

	Local nBrwAT		:= oBrowse:nAt

	/*
	01 = "NS"			
	02 = "PROD."		
	03 = "DESCRIÇÃO"	
	04 = "LOTE"			
	05 = "DATA LOTE"	
	06 = "EMPRESA"		
	07 = "ALMOX"		
	08 = "QUANT."		
	09 = "EMP.PED"		
	10 = "EMP.RES"
	11 = "DISPON."		
	12 = "PEDCART"		
	13 = "QUANT. PLT"	
	14 = "CX"			
	15 = "CONV"			
	16 = "PESO B./M2"	
	17 = "RUA"	
	*/		


	If nBrwAT <= 0
		Return
	EndIf

	_cEmpSel	:= AllTrim(aBrwList[nBrwAT][06])
	_cProdSel	:= AllTrim(aBrwList[nBrwAT][02])
	_cLoteSel	:= STRTRAN(AllTrim(aBrwList[nBrwAT][04])  ,"*", "") 
	_cRuaSel	:= AllTrim(aBrwList[nBrwAT][17])
	_nQtdDispo	:= aBrwList[nBrwAT][11]
	_cLocalSel	:= aBrwList[nBrwAT][07]
	

RETURN


/*/{Protheus.doc} Prenche_Re
@description preenche o campo de produto na reserva
@author BRUNO MADALENO
@since 21/10/05 
@version 1.0
@type function
/*/
Static Function Prenche_Re()

	Local oModelAux 	:= FWModelActive()
	Local oViewAux 		:= FWViewActive()
	Local oModelGrid
	Local oViewGrid
	Local cAliasTmp
	Local _dDtValid
	Local _cAliasTmp	:= Nil
	Local _cQuery		:= ""

	If lMVC
		oModelGrid := oModelAux:GetModel('SC0GRID')
	EndIf

	If lMVC
		oViewGrid := oViewAux:GetViewStruct('VIEW_GRD')
	EndIf

	If (cEmpAnt <> "07") .And. (cEmpAnt <> _cEmpSel)
		MSGALERT("Este produto poderá ser utilizado apenas em sua EMPRESA de origem!","STOP")
		Return
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+PADR(_cProdSel, TamSX3("B1_COD")[1],""),.F.))

	//Preenche a Reserva
	IF UPPER(ALLTRIM(FUNNAME())) == "MATA430"

		If lMVC
			oModelGrid:SetValue('C0_PRODUTO',_cProdSel)
			oModelGrid:SetValue('C0_LOTECTL',_cLoteSel)
			oModelGrid:SetValue('C0_LOCALIZ',_cRuaSel)
			If lMVC
				oViewAux:Refresh('VIEW_GRD')
			EndIF
		Else
			Gdfieldput("C0_PRODUTO",PADR(_cProdSel, TamSX3("B1_COD")[1],"") ,n)
			Gdfieldput("C0_LOTECTL",PADR(_cLoteSel, TamSX3("BF_LOTECTL")[1],""),n)
			Gdfieldput("C0_LOCALIZ",PADR(_cRuaSel, TamSX3("BF_LOCALIZ")[1],""),n)
		EndIf

		//Preenche o Pedido de Venda
	ELSEIF UPPER(ALLTRIM(FUNNAME())) == "MATA410"

		IF (AllTrim(_cLoteSel) <> "AMT") .And.  (_nQtdDispo % SB1->B1_CONV) > 0
			MSGALERT("ATENÇÃO! Estoque disponivel do lote NÃO é caixa fechada."+Chr(10)+Chr(13)+"Favor verificar o estoque.","Valida Caixa Fechada")
			return
		ENDIF

		If (AllTrim(_cRuaSel) == 'PMEC')
			MSGALERT("ATENÇÃO! Não e possivel selecionar Lotes das Rua PMEC .","RUA PMEC")
			Return
		EndIf
		
		If (!Empty(Gdfieldget("C6_PRODUTO", n)) .And. AllTrim(Gdfieldget("C6_PRODUTO", n)) != AllTrim(_cProdSel))
			MSGALERT("ATENÇÃO! Produto selecionado: "+AllTrim(_cProdSel)+", diferente do da linha selecionada: "+AllTrim(Gdfieldget("C6_PRODUTO", n))+"","Produto")
			Return
		EndIf
		

		__cLoteAnt := Gdfieldget("C6_LOTECTL",n)//salvar lote anterior

		
		If (AllTrim(cEmpAnt) <> '07')
			SB8->(DbSetOrder(3))
			If SB8->( DbSeek( xFilial("SB8") + PADR(_cProdSel, TamSX3("C6_PRODUTO")[1],"") + PADR(_cLocalSel, TamSX3("C6_LOCAL")[1],"") + PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"") ))
				_dDtValid := SB8->B8_DTVALID
			Else
				MSGALERT("ATENÇÃO! Lote não encontrado: "+_cLoteSel+". Favor verificar o estoque.","Lotes")
				Return
			Endif
		Else
			If (!Empty(_cEmpSel))
				_cAliasTmp := GetNextAlias()
				
				_cQuery := "select B8_DTVALID from SB8"+_cEmpSel+"0 where 										"
				_cQuery += " B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL = '"+xFilial("SB8") + PADR(_cProdSel, TamSX3("C6_PRODUTO")[1],"") + PADR(_cLocalSel, TamSX3("C6_LOCAL")[1],"") + PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"") +"'								"
				_cQuery += " AND D_E_L_E_T_ = ''															"	
				
				TCQUERY _cQuery ALIAS (_cAliasTmp) NEW
				If !(_cAliasTmp)->(EOF())
					_dDtValid := stod((_cAliasTmp)->B8_DTVALID)
				Else
					MSGALERT("ATENÇÃO! Lote não encontrado: "+_cLoteSel+"Favor verificar o estoque.","Lotes")
					(_cAliasTmp)->(DbCloseArea())
					Return
				EndIf
				(_cAliasTmp)->(DbCloseArea())
			EndIf
		EndIf

				
		Gdfieldput("C6_PRODUTO"	, PADR(_cProdSel, TamSX3("C6_PRODUTO")[1],"")			,n)
		Gdfieldput("C6_UM"		,SB1->B1_UM			,n)
		Gdfieldput("C6_SEGUM"	,SB1->B1_SEGUM		,n)
		Gdfieldput("C6_LOCAL"	,PADR(_cLocalSel, TamSX3("C6_LOCAL")[1],"")		,n)
		Gdfieldput("C6_LOTECTL"	, PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"")			,n)
		Gdfieldput("C6_DTVALID" ,_dDtValid			,n)
		Gdfieldput("C6_LOCALIZ"	, PADR(_cRuaSel, TamSX3("C6_LOCALIZ")[1],"")     		,n)

		//Fernando/Facile em 12/08/16 - OS 2669-16 Alteracao de Lote pelo atendente - se tiver desconto tem que recalcular a politica
		If Empty(__cLoteAnt) .Or. (__cLoteAnt <> _cLoteSel)

			Public __FCESTALTLTPOL := .T.
			U_BPOLGA01()
			Gdfieldput("C6_PRCVEN"	,EXECBLOCK("BIA436",.F.,.F.),n)
			__FCESTALTLTPOL := Nil

		EndIf

		//Fernando/Facile em 21/01/15 - preencher campos para reserva de estoque
		IF !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And. !(M->C5_YSUBTP $ AllTrim(GetNewPar("FA_TPNLOT","A #M #G #B #RI#"))) .And. !(M->C5_YLINHA == "4")

			Gdfieldput("C6_YTPEST"	,"E",n)
			U_FROPCLFU()

		ENDIF

		//Preenche a Liberacao de Pedido
	ELSEIF UPPER(ALLTRIM(FUNNAME())) == "MATA440"

		IF Alltrim(Gdfieldget("C6_PRODUTO",n)) == ALLTRIM(_cProdSel)

			IF (AllTrim(_cLoteSel) <> "AMT") .And. (_nQtdDispo % SB1->B1_CONV) > 0
				MSGALERT("ATENÇÃO! Estoque disponivel do lote NÃO é caixa fechada."+Chr(10)+Chr(13)+"Favor verificar o estoque.","Valida Caixa Fechada")
				return
			ENDIF

			__cLoteAnt := Gdfieldget("C6_LOTECTL",n)//salvar lote anterior

			If Empty(__cLoteAnt) .Or. (__cLoteAnt <> _cLoteSel)

				If U_BPOLVL02(M->C5_NUM, Gdfieldget("C6_ITEM",n))
					MSGALERT("ATENÇÃO! Este pedido tem desconto do LOTE '"+AllTrim(__cLoteAnt)+"'"+Chr(10)+Chr(13)+"Não é permitida a troca.","Valida Politica de Lote")
					return
				EndIf

				__cLoteBas 	:= Gdfieldget("C6_YLOTBAS",n)
				__cRAut		:= Gdfieldget("C6_YRAVLOT",n)
				__cPedIt	:= Gdfieldget("C6_YPITCHA",n)

				If ( !Empty(__cLoteBas) .And. __cRAut == "N" )

					If !MSGNOYES(	"ATENÇÃO! Este pedido esta vinculado ao PEDIDO PISO: "+__cPedIt+" com o lote: "+__cLoteBas+"."+CHR(13)+CHR(10)+;
							"O Representante não autorizou envio com lote diferente."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"TEM CERTEZA QUE DESEJA ALTERAR O LOTE?","Valida Lote de Rodapé")
						return
					EndIf

				EndIf

				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					select top 1 C6_YLOTBAS from SC6140 where C6_FILIAL = '01' and C6_YPITCHA = %Exp:SC5->C5_NUM+Gdfieldget("C6_ITEM",n)% and C6_YLOTBAS <> '' and C6_YRAVLOT <> 'S'
				EndSql

				If !(cAliasTmp)->(Eof()) .And. !Empty((cAliasTmp)->C6_YLOTBAS)

					If !MSGNOYES("Este Pedido está vinculado ao pedido de Rodapé (VITCER) com o lote '"+(cAliasTmp)->C6_YLOTBAS+"'."+CHR(13)+CHR(10)+;
							"O representante não autorizou envio em lote diferente."+CHR(13)+CHR(10)+;
							"TEM CERTEZA QUE DESEJA ALTERAR O LOTE?","Valida Lote de Rodapé")
						(cAliasTmp)->(DbCloseArea())
						return
					EndIf

				EndIf
				(cAliasTmp)->(DbCloseArea())

			EndIf

			If (AllTrim(_cRuaSel) == 'PMEC')
				MSGALERT("ATENÇÃO! Não e possivel selecionar Lotes das Rua PMEC .","RUA PMEC")
				Return
			EndIf

			If (AllTrim(cEmpAnt) <> '07')
				SB8->(DbSetOrder(3))
				If SB8->( DbSeek( xFilial("SB8") + PADR(_cProdSel, TamSX3("B1_COD")[1],"") + PADR(_cLocalSel, TamSX3("C6_LOCAL")[1],"") + PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"") ))
					_dDtValid := SB8->B8_DTVALID
				Else
					MSGALERT("ATENÇÃO! Lote não encontrado: "+_cLoteSel+"Favor verificar o estoque.","Lotes")
					Return
				Endif
			Else
				If (!Empty(_cEmpSel))
					_cAliasTmp := GetNextAlias()
					
					_cQuery := "select B8_DTVALID from SB8"+_cEmpSel+"0 where 										"
					_cQuery += " B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL = '"+xFilial("SB8") + PADR(_cProdSel, TamSX3("C6_PRODUTO")[1],"") + PADR(_cLocalSel, TamSX3("C6_LOCAL")[1],"") + PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"") +"'								"
					_cQuery += " AND D_E_L_E_T_ = ''															"	
					
					TCQUERY _cQuery ALIAS (_cAliasTmp) NEW
					If !(_cAliasTmp)->(EOF())
						_dDtValid := stod((_cAliasTmp)->B8_DTVALID)
					Else
						MSGALERT("ATENÇÃO! Lote não encontrado: "+_cLoteSel+"Favor verificar o estoque.","Lotes")
						(_cAliasTmp)->(DbCloseArea())
						Return
					EndIf
					(_cAliasTmp)->(DbCloseArea())
				EndIf
			EndIf

				Gdfieldput("C6_PRODUTO"	, PADR(_cProdSel, TamSX3("C6_PRODUTO")[1],"")			,n)
				Gdfieldput("C6_LOTECTL"	, PADR(_cLoteSel, TamSX3("C6_LOTECTL")[1],"")			,n)
				Gdfieldput("C6_DTVALID" ,_dDtValid			,n)
				Gdfieldput("C6_LOCALIZ"	, PADR(_cRuaSel, TamSX3("C6_LOCALIZ")[1],"")     		,n)
			

			//Fernando/Facile em 08/04/2015 - preencher campos de bloqueio quando a selecao manual de lote - para tela de permissao do gerente
			IF !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And. !(M->C5_YSUBTP $ AllTrim(GetNewPar("FA_TPNLOT","A #M #G #B #RI#"))) .And. !(M->C5_YLINHA == "4")

				Gdfieldput("C6_YTPEST"	,"E",n)

				If Empty(__cLoteAnt) .Or. (__cLoteAnt <> _cLoteSel)
					Gdfieldput("C6_QTDLIB"	,0,n)  //zerar quantidade - obrigar a digitar denovo para validar o lote - Fernando em 13/04
					Gdfieldput("C6_YMOTFRA"	,"999",n)  //marcar que houve selecao manual para testar se teve ponta
				EndIf

			ENDIF

		ELSE
			MSGALERT("O produto consultado deve ser igual, ao produto do pedido!","Consulta Estoque")
			MSGALERT("Produto PEDIDO-> "+Alltrim(Gdfieldget("C6_PRODUTO",n))+" DIFERENTE do Produto CONSULTA->"+ALLTRIM(_cProdSel),"Consulta Estoque" )
			RETURN
		END IF

		//Preenche a Politica Comercial - Fernando OS 2669-16
	ELSEIF UPPER(ALLTRIM(FUNNAME())) == "BPOLTE03"

		oModel		:= FwModelActive()
		oModelZA0	:= oModel:GetModel("CamposZA0")
		oModelZA0:SetValue('ZA0_LOTE',_cLoteSel)

		oView		:= FwViewActive()
		oView:Refresh()
		oView:lModify := .T.

	END IF

	oDlg15:End()

Return


/*/{Protheus.doc} Filtrar
@description SELECIONANDO OSPRODUTOS DE ACORDOCOM O FILTRO
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
Static Function Filtrar()

	U_BIAMsgRun("Aguarde... Pesquisando...",,{|| FilProc() })

RETURN

Static Function FilProc()

	Local cEmpOut
	Local cAlmLoc

	//Verifica se alguma variavel esta preenchido com conteudo invalido
	cProduto	:= STRTRAN(cProduto,"'", "")
	cFORMATO	:= STRTRAN(cFORMATO,"'", "")
	cLINHA		:= STRTRAN(cLINHA  ,"'", "")
	cCLASSE		:= STRTRAN(cCLASSE ,"'", "")
	AALOTE		:= STRTRAN(AALOTE  ,"'", "")

	//Verifica se o conteudo da variavel está correta
	IF AllTrim(CEMPANT) <> "07"
		If EMPTY(cProduto) .And. EMPTY(cFORMATO) .And. EMPTY(cLINHA)
			MsgAlert("Você Precisa Informar pelo menos PRODUTO, FORMATO ou LINHA no FILTRO!")
			Return
		EndIf
	ENDIF

	cAlmox		:= STRTRAN(cAlmox  ,"'", "")
	cAlmLoc		:= cAlmox
	cAlmox 		:= U_MontaSQLIN(cAlmox,',',2)

	IF EMPTY(cAlmox)
		cAlmox := '01/02/04/05'
		cAlmox := U_MontaSQLIN(cAlmox,'/',2)
	ENDIF

	cMarcaPro		:= STRTRAN(cMarcaPro  ,"'", "")

	cSQL := ""
	cSQL += "SELECT	PRIORIDADE, B1_COD, B1_COD AS PRODUTO,	CONV, DESCRICAO, LOTE, LOTE_ORI, RUA, EMPRESA, ALMOX, QUANTIDADE, EMPENHO,EMPC6,EMPC0, PEDCART, ISNULL(QUANTIDADE - EMPENHO,0) AS DISPONIVEL, CAIXA, PESOBR, DTPRILOTE, DTULTIMOLOTE, B8_DTVALID, "  + CRLF
	cSQL += "(CASE WHEN B1_YCLASSE IN ('2','3') OR B1_YSTATUS <> '1' OR RUA = 'P. DEVOL' OR DATEDIFF(DAY, DTULTIMOLOTE, GETDATE()) > 180 OR cast(((QUANTIDADE)/CONV)/CAIXA as numeric(12,2)) < 1 THEN 'S' ELSE '' END) AS NS"  + CRLF
	cSQL += "FROM  "  + CRLF
	cSQL += "	(SELECT *, PEDCART = CASE WHEN PRIORIDADE = 1 THEN (SELECT dbo.FN_SALDOPEDIDOLOC(EMPRESA,B1_COD,'" + cAlmLoc + "')) ELSE 0 END"  + CRLF
	cSQL += "	 FROM "  + CRLF
	cSQL += "			(SELECT ROW_NUMBER() over (PARTITION BY B1_COD, EMPRESA ORDER BY B1_COD, EMPRESA DESC) AS PRIORIDADE ,IIF(EMPRESA IS NULL,SBF.EMP,EMPRESA) EMPRESA, "  + CRLF
	cSQL += "			B1_COD, B1_CONV AS CONV,  "  + CRLF
	cSQL += "			B1_DESC AS DESCRICAO,  "  + CRLF
	cSQL += "			SUBSTRING(B1_COD,1,8) AS PRODUTO,  "  + CRLF
	cSQL += "			LOTE = CASE WHEN ZZ9_RESTRI = '*' THEN RTRIM(BF_LOTECTL)+ZZ9_RESTRI ELSE RTRIM(BF_LOTECTL) END, "  + CRLF
	cSQL += "			BF_LOTECTL AS LOTE_ORI,  "  + CRLF
	cSQL += "			BF_LOCAL ,  "  + CRLF
	cSQL += "			BF_LOCAL AS ALMOX ,  "  + CRLF
	cSQL += "			ISNULL(BF_LOCALIZ,'---') AS RUA,  "  + CRLF
	cSQL += "			ISNULL(BF_QUANT,0) AS QUANTIDADE,  "  + CRLF
	cSQL += "			ISNULL(BF_EMPENHO,0) AS EMPENHO,  "  + CRLF
	cSQL += "			ISNULL(EMPC6,0) AS EMPC6,  "  + CRLF
	cSQL += "			ISNULL(EMPC0,0) AS EMPC0,  "  + CRLF
	cSQL += "			ZZ9.ZZ9_DIVPA AS CAIXA, B1_YFORMAT, B1_YFATOR, B1_YLINHA, B1_YCLASSE,B1_YSTATUS, ROUND(ZZ9_PESO+(ZZ9_PESEMB/B1_CONV),4) AS PESOBR --, "  + CRLF
	cSQL += "	FROM     " + RETSQLNAME("SB1") + "  SB1 " 	
	cSQL += "	JOIN " +RetSqlName("ZZ7")+" ZZ7 ON SB1.B1_YLINHA = ZZ7.ZZ7_COD " + CRLF
	cSQL += "		AND SB1.B1_YLINSEQ = ZZ7.ZZ7_LINSEQ "  + CRLF
	cSQL += "	JOIN "
	If (cEmpAnt == '07' .And. cFilAnt == '05')
		cSQL += " (SELECT '"+cEmpAnt+"' EMP, * FROM "+RetSqlName("SBF")+" WHERE BF_FILIAL = '"+XFILIAL("SBF")+"' AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '') SBF " + CRLF
	ElseIf cEmpAnt $ "01_05_07_14" .And. !lFiltraEmp
		cSQL += "			(SELECT '01' EMP, * FROM SBF010 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C') AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 		"  + CRLF
		cSQL += "			UNION																																							            "  + CRLF
		cSQL += "			SELECT '05' EMP, * FROM SBF050 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = ''		"  + CRLF
		cSQL += "			UNION																																										"  + CRLF
		cSQL += "			SELECT '13' EMP, * FROM SBF130 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 		"  + CRLF
		cSQL += "			UNION																																																							"  + CRLF
		cSQL += "			SELECT '14' EMP, * FROM SBF140 WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C')  AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' 		"  + CRLF
		cSQL += "			UNION	
		cSQL += "			SELECT '"+cEmpAnt+"' EMP, * FROM "+RetSqlName("SBF")+" WHERE BF_FILIAL = '01' AND SUBSTRING(BF_PRODUTO,4,4) NOT IN ('0000','000C') AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '' ) SBF	"  + CRLF
	Else
		cSQL += "		 	(SELECT '"+cEmpAnt+"' EMP, * FROM "+RetSqlName("SBF")+" WHERE BF_FILIAL = '"+XFILIAL("SBF")+"' AND BF_LOCAL IN (" + cAlmox + ") AND D_E_L_E_T_ = '') SBF " + CRLF
	EndIf
    cSql += " ON SBF.BF_FILIAL = " + ValtoSql(xFilial("SBF")) + " "
	cSql += " AND SB1.B1_COD = SBF.BF_PRODUTO "
    
    cSql += " JOIN " +RetSqlName("ZZ9")+" ZZ9 ON "
	cSQL += "	SBF.BF_PRODUTO  = ZZ9.ZZ9_PRODUT	AND "  + CRLF
	cSQL += " 	SBF.BF_LOTECTL  = ZZ9.ZZ9_LOTE "  + CRLF
    cSql += " LEFT JOIN "
    

	If (cEmpAnt == '07' .And. cFilAnt == '05')
		cSQL += "	(SELECT '"+cEmpAnt+"' EMPRESA,DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM "+RetSqlName("SDC")+" " + CRLF
		cSQL += "		WHERE DC_FILIAL = '"+XFILIAL("SDC")+"' " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL ) SDC " + CRLF

	ElseIf cEmpAnt $ "01_05_07_14" .And. !lFiltraEmp
		cSQL += "	(SELECT '01' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM SDC010 " + CRLF
		cSQL += "		WHERE DC_FILIAL = '01' " + CRLF
		cSQL += "			AND SUBSTRING(DC_PRODUTO,4,4) NOT IN ('0000','000C') " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL " + CRLF
		cSQL += "	UNION " + CRLF
		cSQL += "	SELECT '05' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM SDC050 " + CRLF
		cSQL += "		WHERE DC_FILIAL = '01' " + CRLF
		cSQL += "			AND SUBSTRING(DC_PRODUTO,4,4) NOT IN ('0000','000C') " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A" + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL " + CRLF
		cSQL += "	UNION " + CRLF
		cSQL += "	SELECT '13' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM SDC130 " + CRLF
		cSQL += "		WHERE DC_FILIAL = '01' " + CRLF
		cSQL += "			AND SUBSTRING(DC_PRODUTO,4,4) NOT IN ('0000','000C') " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL " + CRLF
		cSQL += "	UNION " + CRLF
		cSQL += "	SELECT '14' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM SDC140 " + CRLF
		cSQL += "		WHERE DC_FILIAL = '01' " + CRLF
		cSQL += "			AND SUBSTRING(DC_PRODUTO,4,4) NOT IN ('0000','000C') " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL " + CRLF	
		cSQL += "	UNION " + CRLF
		cSQL += "	SELECT '"+cEmpAnt+"' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL " + CRLF				
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM "+RetSqlName("SDC")+" " + CRLF
		cSQL += "		WHERE DC_FILIAL = '"+XFILIAL("SDC")+"' " + CRLF
		cSQL += "			AND SUBSTRING(DC_PRODUTO,4,4) NOT IN ('0000','000C') " + CRLF
		cSQL += "			AND DC_PRODUTO = " +ValtoSql(cProduto)+ " " + CRLF
		cSQL += "			AND DC_LOTECTL = "+ValtoSql(aAlote)+" " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL ) SDC " + CRLF
	Else
		cSQL += "	(SELECT '"+cEmpAnt+"' EMPRESA, DC_PRODUTO, DC_LOTECTL , ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC6' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC6 " + CRLF
		cSQL += "		,ISNULL(SUM(CASE " + CRLF
		cSQL += "				WHEN DC_ORIGEM = 'SC0' " + CRLF
		cSQL += "					THEN DC_QUANT " + CRLF
		cSQL += "				ELSE 0 " + CRLF
		cSQL += "				END),0) EMPC0 " + CRLF
		cSQL += "	FROM ( " + CRLF
		cSQL += "		SELECT DC_ORIGEM " + CRLF
		cSQL += "			,DC_PRODUTO " + CRLF
		cSQL += "			,DC_LOTECTL "		 + CRLF		
		cSQL += "			,DC_QUANT " + CRLF
		cSQL += "		FROM "+RetSqlName("SDC")+" " + CRLF
		cSQL += "		WHERE DC_FILIAL = '"+XFILIAL("SDC")+"' " + CRLF
		cSQL += "			AND DC_PRODUTO = " +ValtoSql(cProduto)+ " " + CRLF
		cSQL += "			AND DC_LOTECTL = "+ValtoSql(aAlote)+" " + CRLF
		cSQL += "			AND DC_LOCAL IN (" + cAlmox + ") " + CRLF
		cSQL += "			AND D_E_L_E_T_ = '' " + CRLF
		cSQL += "		) A " + CRLF
		cSQL += "		GROUP BY DC_PRODUTO,DC_LOTECTL ) SDC " + CRLF
	EndIf

	cSQL += " ON SDC.DC_PRODUTO = ZZ9.ZZ9_PRODUT " + CRLF
	cSQL += "	AND SDC.DC_LOTECTL = ZZ9.ZZ9_LOTE " + CRLF

	cSQL += "	WHERE	SB1.B1_FILIAL		= '"+xFilial("SB1")+"'	AND "  + CRLF
	cSQL += "				ZZ9.ZZ9_FILIAL	= '"+xFilial("ZZ9")+"'	AND "  + CRLF
	If !Empty(AllTrim(cMarcaPro))
		cSQL += " 			    ZZ7.ZZ7_EMP ='"+AllTrim(cMarcaPro)+"' 	AND "  + CRLF
	EndIf
	cSQL += "				SB1.D_E_L_E_T_	= '' 				AND "  + CRLF
	cSQL += "				SBF.D_E_L_E_T_	= '' 				AND "  + CRLF
	cSQL += "				ZZ7.D_E_L_E_T_	= '' 				AND "  + CRLF
	cSQL += "				ZZ9.D_E_L_E_T_	= '') AS TMP ) PROD		"  + CRLF
	cSQL += " LEFT JOIN

	If (cEmpAnt == '07' .And. cFilAnt == '05')
		cSQL += " (SELECT '"+cEmpAnt+"' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE  "  + CRLF
		cSQL += " FROM " +RETSQLNAME("SB8") + "																										"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0 AND B8_FILIAL = '"+XFILIAL("SB8")+"'														"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID)SB8
	ElseIf cEmpAnt $ "01_05_07_14"
		cSQL += " ((SELECT '01' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + CRLF
		cSQL += "  FROM  SB8010 																													"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0																							"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID)																			"  + CRLF
		cSQL += " UNION 																															"  + CRLF
		cSQL += " (SELECT '05' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + CRLF
		cSQL += "  FROM  SB8050   																													"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0																							"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID)																			"  + CRLF
		cSQL += " UNION 																															"  + CRLF
		cSQL += " (SELECT '13' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + CRLF
		cSQL += "  FROM  SB8130   																													"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0																							"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID)																			"  + CRLF
		cSQL += " UNION 																															"  + CRLF
		cSQL += " (SELECT '14' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE 			"  + CRLF
		cSQL += "  FROM  SB8140   																													"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0																							"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID))SB8
	Else
		cSQL += " (SELECT '"+cEmpAnt+"' EMP, B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID, MIN(B8_DATA) AS DTPRILOTE ,MAX(B8_DATA) AS DTULTIMOLOTE  "  + CRLF
		cSQL += " FROM " +RETSQLNAME("SB8") + "																										"  + CRLF
		cSQL += " WHERE D_E_L_E_T_ = '' AND B8_SALDO <> 0																							"  + CRLF
		cSQL += " GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_DTVALID)SB8																			"  + CRLF
	EndIf

	cSQL += " ON SB8.B8_PRODUTO  = PROD.PRODUTO	AND	 																							"  + CRLF
	cSQL += " 	 SB8.B8_LOTECTL  = PROD.LOTE_ORI AND																							"  + CRLF
	cSQL += " 	 SB8.B8_LOCAL  	 = PROD.BF_LOCAL AND																							"  + CRLF
	cSQL += "	 SB8.EMP		 = PROD.EMPRESA																									"  + CRLF
	cSQL += " WHERE																																"  + CRLF

	If AllTrim(cProduto) <> ""
		cSQL += "       	PROD.B1_COD   Like '" + AllTrim(cProduto) + "%' AND	" + CRLF
	ELSE
		IF AllTrim(cFORMATO) <> ""
			cSQL += "       PROD.B1_YFORMAT   = '" + AllTrim(cFORMATO) + "' AND	"  + CRLF
		END IF

		IF AllTrim(cLINHA) <> ""
			cSQL += "       PROD.B1_YLINHA   = '" + AllTrim(cLINHA) + "' AND	"  + CRLF
		END IF
		IF AllTrim(cCLASSE) <> ""
			cSQL += "       PROD.B1_YCLASSE   = '" + AllTrim(cCLASSE) + "' AND "  + CRLF
		END IF
	END IF
	IF ALLTRIM(AALOTE) <> ""
		cSQL += "       LOTE ='"+ALLTRIM(AALOTE)+"' 	AND "  + CRLF
	END IF

	cSQL += "		(PROD.QUANTIDADE > 0 OR PEDCART > 0) "  + CRLF


	//Fernando - Ticket 4910 - Adicionando estoque de produtos PR - LM (manta) na consulta

	IF AllTrim(CEMPANT) == "07"

		cSQL += " UNION ALL " + CRLF
		cSQL += " SELECT " + CRLF
		cSQL += " PRIORIDADE = 9, " + CRLF
		cSQL += " B1_COD, " + CRLF
		cSQL += " B1_COD AS PRODUTO, " + CRLF
		cSQL += " CONV = B1_CONV, " + CRLF
		cSQL += " DESCRICAO = B1_DESC, " + CRLF
		cSQL += " LOTE = '', " + CRLF
		cSQL += " LOTE_ORI = '', " + CRLF
		cSQL += " RUA = '', " + CRLF
		cSQL += " EMPRESA = '07', " + CRLF
		cSQL += " ALMOX = B2_LOCAL, " + CRLF
		cSQL += " QUANTIDADE = B2_QATU, " + CRLF
		cSQL += " EMPENHO = B2_QEMP + B2_RESERVA,  " + CRLF
		cSQL += " EMPC6 = 0,  " + CRLF
		cSQL += " EMPC0 = 0,  " + CRLF		
		cSQL += " PEDCART = B2_QPEDVEN, " + CRLF
		cSQL += " ISNULL(B2_QATU - (B2_QEMP + B2_RESERVA),0) AS DISPONIVEL, " + CRLF
		cSQL += " CAIXA = 0, " + CRLF
		cSQL += " PESOBR = B1_PESO, " + CRLF
		cSQL += " DTPRILOTE 	= '', " + CRLF
		cSQL += " DTULTIMOLOTE	= '', " + CRLF
		cSQL += " B8_DTVALID 	= '', " + CRLF
		cSQL += " '' AS NS " + CRLF
		cSQL += " FROM SB2070 SB2 " + CRLF
		cSQL += " JOIN SB1010 SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_='' " + CRLF
		cSQL += " WHERE " + CRLF
		cSQL += " B1_TIPO = 'PR' " + CRLF
		cSQL += " AND B2_LOCAL IN ('02','04') " + CRLF
		cSQL += " AND B2_QATU > 0 " + CRLF

		If AllTrim(cProduto) <> ""
			cSQL += " AND B1_COD   Like '" + AllTrim(cProduto) + "%' " + CRLF
		Else
			If AllTrim(cFORMATO) <> ""
				cSQL += " AND B1_YFORMAT   = '" + AllTrim(cFORMATO) + "' "  + CRLF
			EndIf

			If AllTrim(cLINHA) <> ""
				cSQL += " AND B1_YLINHA   = '" + AllTrim(cLINHA) + "' "  + CRLF
			EndIf
		EndIf

		cSQL += " AND SB1.D_E_L_E_T_=' ' " + CRLF
		cSQL += " AND SB2.D_E_L_E_T_=' ' " + CRLF

	ENDIF
	cSQL += "ORDER BY PROD.B1_COD, PROD.CAIXA  "  + CRLF

	MemoWrite("\Consulta_EstoqueRAC.TXT", cSQL)

	//Atualiza a tela da Consulta
	AtualizaBrowse()

	cEmpOut := Nil

	//OS 3932-16 - Fernando/Facile - ajustado para nao usar o alias _AAUX que nao existe em algumas situacoes
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("01")+cProduto))
		If cEmpAnt == '01' .And. AllTrim(SB1->B1_YPCGMR3) == '8'
			cEmpOut := '05'
		EndIf
	EndIf

	//PROJETO RESERVA DE OP PREENCHER GRIP DE SALDOS DE OP
	If !Empty(cProduto) .Or. !Empty(cFORMATO) .Or. !Empty(cLINHA) .Or. !Empty(cCLASSE)
		PesqOPSld(cProduto,cFORMATO,cLINHA,cCLASSE,cEmpOut)
	EndIf

Return


/*/{Protheus.doc} AtualizaBrowse
@description ATUALIZA O BOWSE CONFOR O FILTRO SELECIONADO
@author Fernando Rocha
@since 18/03/2020
@version 2.0
@type function
/*/
Static function AtualizaBrowse()

	Local cAliasTmp
	Local aAux

	aBrwList := {}
	
	lPassei := .F.
	cAliasTmp := GetNextAlias()

	TCQUERY cSql ALIAS (cAliasTmp) NEW
	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(EOF())

		// FUNCAO PARA TRAZER A QUANTIDADE DE PALETS
		QUANT_PALET := U_PALETES((cAliasTmp)->B1_COD  ,  (cAliasTmp)->DISPONIVEL, (cAliasTmp)->LOTE_ORI)
		lPassei := .T.

		aAux :={}

		AAdd(aAux, (cAliasTmp)->NS)
		AAdd(aAux, (cAliasTmp)->PRODUTO)
		AAdd(aAux, AllTrim((cAliasTmp)->DESCRICAO))
		AAdd(aAux, (cAliasTmp)->LOTE)
		AAdd(aAux, sTod((cAliasTmp)->DTPRILOTE))
		AAdd(aAux, (cAliasTmp)->EMPRESA)
		AAdd(aAux, (cAliasTmp)->ALMOX)
		AAdd(aAux, (cAliasTmp)->QUANTIDADE)
		AAdd(aAux, (cAliasTmp)->EMPC6)
		AAdd(aAux, (cAliasTmp)->EMPC0)
		AAdd(aAux, (cAliasTmp)->DISPONIVEL)
		AAdd(aAux, (cAliasTmp)->PEDCART)
		AAdd(aAux, Alltrim(QUANT_PALET))
		AAdd(aAux, (cAliasTmp)->CAIXA)
		AAdd(aAux, (cAliasTmp)->CONV)
		AAdd(aAux, (cAliasTmp)->PESOBR)
		AAdd(aAux, (cAliasTmp)->RUA)

		AAdd(aBrwList, aAux)

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

	IF !lPassei
		MSGALERT("Não existem dados para a consulta realizada","STOP")
	//	Return
	ENDIF

	If (Len(aBrwList) == 0)
		Aadd(aBrwList,{"","","","","","","",0,0,0,0,0,"",0,0,0,""})
	EndIf
	
	oBrowse:SetArray(aBrwList)
	oBrowse:Refresh()
	oDlg15:Refresh()

	oBrowse:GoTop()
	nBrwAT := oBrowse:nAT

	If (nBrwAT > 0 .And. Len(aBrwList) >= nBrwAT)

		_cEmpSel	:= AllTrim(aBrwList[nBrwAT][06])
		_cProdSel	:= AllTrim(aBrwList[nBrwAT][02])
		_cLoteSel	:= STRTRAN(AllTrim(aBrwList[nBrwAT][04])  ,"*", "") 
		_cRuaSel	:= AllTrim(aBrwList[nBrwAT][17])
		_nQtdDispo	:= aBrwList[nBrwAT][11]
		_cLocalSel	:= aBrwList[nBrwAT][07]

	EndIf

Return

/*/{Protheus.doc} Detalhes
@description Detalhes do Estoque e Reservas do Produto Selecionado
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
Static Function Detalhes()
	
	If (Empty(_cProdSel))
		Return
	EndIf
	
	U_BIAMsgRun("Aguarde... Carregando detalhes do estoque...",,{|| DetProc() })

Return

Static Function DetProc()

	Local nCol, nLin, nLinDlg, nColDlg

	nCol := oMainWnd:nClientWidth
	nLin := oMainWnd:nClientHeight

	nLinDlg := nLin*.800
	nColDlg := nCol*.600

	// Cria Dialog
	oDlgDet := MsDialog():New(10, 10, nLinDlg, nColDlg, "Detalhes",,,,DS_MODALFRAME,,,,,.T.)
	oDlgDet:lCentered := .T.
	oDlgDet:bValid := {|| .F. }

	oLayer := FWLayer():New()
	oLayer:Init(oDlgDet, .F., .T.)

	// Adiciona linha 1 ao Layer
	oLayer:AddLine("LIN1", 30, .F.)
	oLayer:AddCollumn("COL1", 100, .T., "LIN1")
	oLayer:AddWindow("COL1", "WND1", "Pedidos Pendentes", 100, .F. ,.T.,, "LIN1", { || })

	// Adiciona linha 1 ao Layer
	oLayer:AddLine("LIN2", 35, .F.)
	oLayer:AddCollumn("COL2", 100, .T., "LIN2")
	oLayer:AddWindow("COL2", "WND2", "Reservas de Estoque e/ou OP", 100, .F. ,.T.,, "LIN2", { || })

	// Adiciona linha 1 ao Layer
	oLayer:AddLine("LIN3", 35, .F.)
	oLayer:AddCollumn("COL3", 100, .T., "LIN3")
	oLayer:AddWindow("COL3", "WND3", "Empenhos/Liberações", 100, .F. ,.T.,, "LIN3", { || })


	//BROWSE 1 - PEDIDOS PENDENTES
	oPanel1 := oLayer:GetWinPanel("COL1", "WND1", "LIN1")

	oDBrowse1 := TCBrowse():New(000,000,000,000,,,,oPanel1,,,,,,,,,,,,.F.,,.T.,,.F.)
	oDBrowse1:Align := CONTROL_ALIGN_ALLCLIENT

	oDBrowse1:AddColumn(TcColumn():New("Pedido"			, {|| aDBrowse1[oDBrowse1:nAt, 01]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Cliente"		, {|| aDBrowse1[oDBrowse1:nAt, 02]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Nome"			, {|| aDBrowse1[oDBrowse1:nAt, 03]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Saldo"			, {|| aDBrowse1[oDBrowse1:nAt, 04]}, "@E 999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Emissão"		, {|| aDBrowse1[oDBrowse1:nAt, 05]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Entrega"		, {|| aDBrowse1[oDBrowse1:nAt, 06]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Reserva"		, {|| aDBrowse1[oDBrowse1:nAt, 07]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse1:AddColumn(TcColumn():New("Dt.Neces.Eng"	, {|| aDBrowse1[oDBrowse1:nAt, 08]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	
	aDBrowse1 := {}
	Browse1(_cProdSel,_cEmpSel)

	oDBrowse1:SetArray(aDBrowse1)
	oDBrowse1:Refresh()

	//BROWSE 2 - RESERVAS
	oPanel2 := oLayer:GetWinPanel("COL2", "WND2", "LIN2")

	oDBrowse2 := TCBrowse():New(000,000,000,000,,,,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.)
	oDBrowse2:Align := CONTROL_ALIGN_ALLCLIENT

	oDBrowse2:AddColumn(TcColumn():New("Reserva"		, {|| aDBrowse2[oDBrowse2:nAt, 01]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse2:AddColumn(TcColumn():New("Documento"		, {|| aDBrowse2[oDBrowse2:nAt, 02]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse2:AddColumn(TcColumn():New("Cliente"		, {|| aDBrowse2[oDBrowse2:nAt, 03]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse2:AddColumn(TcColumn():New("Saldo"			, {|| aDBrowse2[oDBrowse2:nAt, 04]}, "@E 999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse2:AddColumn(TcColumn():New("Validade"		, {|| aDBrowse2[oDBrowse2:nAt, 05]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse2:AddColumn(TcColumn():New("Dt.Emissao"		, {|| aDBrowse2[oDBrowse2:nAt, 06]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))

	aDBrowse2 := {}
	Browse2(_cProdSel,_cLoteSel,_cEmpSel)

	oDBrowse2:SetArray(aDBrowse2)
	oDBrowse2:Refresh()

	//BROWSE 3 - EMPENHOS
	oPanel3 := oLayer:GetWinPanel("COL3", "WND3", "LIN3")

	oDBrowse3 := TCBrowse():New(000,000,000,000,,,,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.)
	oDBrowse3:Align := CONTROL_ALIGN_ALLCLIENT

	oDBrowse3:AddColumn(TcColumn():New("Cliente"		, {|| aDBrowse3[oDBrowse3:nAt, 01]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Saldo"			, {|| aDBrowse3[oDBrowse3:nAt, 02]}, "@E 999,999.99"	,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Romaneio"		, {|| aDBrowse3[oDBrowse3:nAt, 03]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Pedido"			, {|| aDBrowse3[oDBrowse3:nAt, 04]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Item"			, {|| aDBrowse3[oDBrowse3:nAt, 05]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Seq."			, {|| aDBrowse3[oDBrowse3:nAt, 06]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Emissão"		, {|| aDBrowse3[oDBrowse3:nAt, 07]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Entrega"		, {|| aDBrowse3[oDBrowse3:nAt, 08]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Empenho"		, {|| aDBrowse3[oDBrowse3:nAt, 09]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Dias Empenho"	, {|| aDBrowse3[oDBrowse3:nAt, 10]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	oDBrowse3:AddColumn(TcColumn():New("Dt.Neces.Eng"	, {|| aDBrowse3[oDBrowse3:nAt, 11]}, "@!"				,nil,nil,nil,50,.F.,.F.,nil,nil,nil,.F.,nil))
	
	aDBrowse3 := {}
	Browse3(_cProdSel,_cEmpSel)

	oDBrowse3:SetArray(aDBrowse3)
	oDBrowse3:Refresh()

	//INICIAR TELA
	oDlgDet:Activate()

Return

/*/{Protheus.doc} Browse1
@description DEFINE O BROWSE 1
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
Static Function Browse1(PRO,cEmpresa)

	Local cTabSC0
	Local cTabPZ0
	Local cAliasTmp
	Local aAux

	//Verifica se o conteudo da variavel está correta
	cAlmox		:= STRTRAN(cAlmox  ,"'", "")
	cAlmox 		:= U_MontaSQLIN(cALmox,',',2)

	If cEmpresa == "01"
		cTabSC0 := "SC0010"
		cTabPZ0 := "PZ0010"
	ElseIf cEmpresa == "05"
		cTabSC0 := "SC0050"
		cTabPZ0 := "PZ0050"
	ElseIf cEmpresa == "13"
		cTabSC0 := "SC0130"
		cTabPZ0 := "PZ0130"
	ElseIf cEmpresa == "14"
		cTabSC0 := "SC0140"
		cTabPZ0 := "PZ0140"		
	ElseIf cEmpresa == "07"
		cTabSC0 := "SC0070"
		cTabPZ0 := "PZ0070"
	Else
		cTabSC0 := RetSqlName("SC0")
		cTabPZ0 := RetSqlName("PZ0")
	EndIf

	cSql := "SELECT  NUMERO, CLIENTE, EMISSAO, ENTREGA, DTNECE, SUM(SALDOTOTAL) AS SALDOTOTAL
	cSql += " , (SELECT A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = CLIENTE AND D_E_L_E_T_ = '') AS NOMECLI

	If (cEmpAnt == '07' .And. cFilAnt == '05')

		cSql += " , DOCRES = isnull( "
		cSql += "				(SELECT TOP 1 DOCRES FROM "
		cSql += "				(SELECT DOCRES = 'RE-'+C0_NUM FROM "+cTabSC0+" WHERE C0_FILIAL = '"+xFilial('SC0')+"' and C0_YPEDIDO = NUMERO and C0_YITEMPV = ITEM AND D_E_L_E_T_ = ''  "
		cSql += "				UNION ALL "
		cSql += "				SELECT DOCRES = 'OP-'+PZ0_OPNUM FROM "+cTabPZ0+" WHERE PZ0_FILIAL = '"+xFilial('PZ0')+"'  and PZ0_PEDIDO = NUMERO and PZ0_ITEMPV = ITEM AND D_E_L_E_T_ = '') RES  "
		cSql += "				),'') "

	Else

		cSql += " , DOCRES = isnull( "
		cSql += "				(SELECT TOP 1 DOCRES FROM "
		cSql += "				(SELECT DOCRES = 'RE-'+C0_NUM FROM "+cTabSC0+" WHERE C0_FILIAL = '01' and C0_YPEDIDO = NUMERO and C0_YITEMPV = ITEM AND D_E_L_E_T_ = ''  "
		cSql += "				UNION ALL "
		cSql += "				SELECT DOCRES = 'OP-'+PZ0_OPNUM FROM "+cTabPZ0+" WHERE PZ0_FILIAL = '01' and PZ0_PEDIDO = NUMERO and PZ0_ITEMPV = ITEM AND D_E_L_E_T_ = '') RES  "
		cSql += "				),'') "

	EndIf

	cSql += "FROM ( "
	cSql += "	SELECT C6_YDTNECE AS DTNECE,C5.C5_NUM AS NUMERO, C5_EMISSAO AS EMISSAO, "
	cSql += "			C6_ENTREG AS ENTREGA, C6_ITEM AS ITEM, "
	cSql += "  		 	CLIENTE = CASE "
	cSql += "			WHEN C5.C5_YCLIORI = '' THEN C5.C5_CLIENTE+C5.C5_LOJACLI "
	cSql += "			ELSE C5.C5_YCLIORI+C5.C5_YLOJORI END, "
	cSql += "					convert( numeric(15,4), (C6_QTDVEN-(C6_QTDEMP+C6_QTDENT))) AS SALDOTOTAL  "

	If cEmpAnt $ "01_05_07_14" .And. cEmpresa != "07"
		If cEmpresa == "01"
			cSql += "	FROM SC5010 AS C5, SC6010 AS C6 "
		ElseIf cEmpresa == "05"
			cSql += "	FROM SC5050 AS C5, SC6050 AS C6 "
		ElseIf cEmpresa == "13"
			cSql += "	FROM SC5130 AS C5, SC6130 AS C6 "
		ElseIf cEmpresa == "14"
			cSql += "	FROM SC5140 AS C5, SC6140 AS C6 "			
		EndIf
	Else
		cSql += "	FROM "+RetSqlName("SC5")+" AS C5,"+RETSQLNAME("SC6")+" AS C6 "
	EndIf
	cSql += "	WHERE 	C5.C5_NUM 		= C6.C6_NUM   AND "
	cSql += "		   	C5.C5_CLIENTE	= C6.C6_CLI   AND "
	cSql += "	      	C6.C6_PRODUTO 	= '"+PRO+"'   AND "
	cSql += "			convert( numeric(15,4), (C6.C6_QTDVEN-(C6.C6_QTDEMP+C6.C6_QTDENT))) > 0 AND "
	cSql += "			C6.C6_BLQ 		<> 'R' 	      AND "

	If !Empty(cAlmox)
		cSql += "			C6.C6_LOCAL IN (" + cAlmox + ") AND "
	EndIf

	If (cEmpAnt == '07' .And. cFilAnt == '05')
		cSql += "		   	C5.C5_FILIAL	= '"+xFilial('SC5')+"'   AND "
		cSql += "		   	C6.C6_FILIAL	= '"+xFilial('SC6')+"'   AND "
	EndIf

	cSql += "			C6.D_E_L_E_T_   = '' 		  AND "
	cSql += "			C5.D_E_L_E_T_   = '') AS WWW	"
	cSql += " Group by NUMERO, ITEM, CLIENTE, EMISSAO, ENTREGA, DTNECE "
	cSql += " Order by EMISSAO, NUMERO, CLIENTE "

	cAliasTmp := GetNextAlias()
	TCQUERY cSql ALIAS (cAliasTmp) NEW
	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(EOF())

		aAux := {}

		AAdd(aAux,(cAliasTmp)->NUMERO)
		AAdd(aAux,(cAliasTmp)->CLIENTE)
		AAdd(aAux,(cAliasTmp)->NOMECLI)
		AAdd(aAux,(cAliasTmp)->SALDOTOTAL)
		AAdd(aAux,DTOC(STOD((cAliasTmp)->EMISSAO)))
		AAdd(aAux,DTOC(STOD((cAliasTmp)->ENTREGA)))
		AAdd(aAux,(cAliasTmp)->DOCRES)
		AAdd(aAux,DTOC(STOD((cAliasTmp)->DTNECE)))

		Aadd(aDBrowse1,aAux)

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} Browse2
@description DEFINE O BROWSE 2 - RESERVAS
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
Static Function Browse2(PRO,CCLOTE,cEmpresa)

	Local cAliasTmp
	Local aAux

	//--Buscando o Numero da reserva
	cSql := "SELECT C0_NUM AS NUMERO, CASE WHEN C0_DOCRES <> '' THEN C0_DOCRES ELSE (C0_YPEDIDO+C0_YITEMPV) END AS DOC, C0_SOLICIT AS CLIENTE, C0_QUANT AS SALDOTOTAL, 	"
	cSql += "		C0_VALIDA  AS VALIDADE, 	"
	cSql += " 		C0_EMISSAO AS EMISSAO  	"

	If cEmpAnt $ "01_05_07_14" .And. cEmpresa != "07"
		If cEmpresa == "01"
			cSql += "FROM SC0010 "
		ElseIf cEmpresa == "05"
			cSql += "FROM SC0050 "
		ElseIf cEmpresa == "13"
			cSql += "FROM SC0130 "
		ElseIf cEmpresa == "14"
			cSql += "FROM SC0140 "
		EndIf
	Else
		cSql += " FROM " + RETSQLNAME("SC0") + " "
	EndIf
	cSql += " WHERE		C0_PRODUTO = '" + PRO + "' 							AND "
	cSql += "       	C0_LOCALIZ = '" + _cRuaSel + "' 	AND "
	cSql += "        	C0_LOTECTL = '" + CCLOTE + "' 					AND "

	If (cEmpresa == '07')
		cSql += " C0_FILIAL	= '"+xFilial('SC0')+"'   AND "
	EndIf

	cSql += " D_E_L_E_T_ = '' "
	cSql += " ORDER BY C0_NUM "

	cAliasTmp := GetNextAlias()
	TCQUERY cSql ALIAS (cAliasTmp) NEW
	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(EOF())

		aAux := {}

		AAdd(aAux,(cAliasTmp)->NUMERO)
		AAdd(aAux,(cAliasTmp)->DOC)
		AAdd(aAux,(cAliasTmp)->CLIENTE)
		AAdd(aAux,(cAliasTmp)->SALDOTOTAL)
		AAdd(aAux,DTOC(STOD((cAliasTmp)->VALIDADE)))
		AAdd(aAux,DTOC(STOD((cAliasTmp)->EMISSAO)))

		Aadd(aDBrowse2,aAux)

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} Browse3
@description DEFINE O BROWSE 3 - EMPENHOS
@author Fernando Rocha
@since 2020
@version 1.0
@type function
/*/
Static Function Browse3(PRO,cEmpresa)

	Local cAliasTmp
	Local aAux

	cSql := "SELECT DTNECE, CODCLI, NUMERO, ITEM, SEQ, CLIENTE, EMISSAO, ENTREGA, EMPENHO, SALDOTOTAL, (SELECT A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = CODCLI AND D_E_L_E_T_ = '') AS  A1_NOME "
	cSql += "FROM ( "
	cSql += " SELECT CODCLI  = CASE "
	cSql += " 	 	              WHEN C5_YCLIORI = '' THEN C5_CLIENTE+C5_LOJACLI "
	cSql += " 	 	              ELSE C5_YCLIORI+C5_YLOJORI "
	cSql += "                  END, "
	cSql += "        NUMERO  = CASE "
	cSql += " 	 	              WHEN C9_AGREG = '' THEN '' "
	cSql += " 	 	              ELSE SUBSTRING(C9_DATALIB,1,4)+C9_AGREG "
	cSql += "                  END, "
	cSql += "       C9_PEDIDO AS CLIENTE,  "
	cSql += "       C9_ITEM AS ITEM,  "
	cSql += "       C9_SEQUEN AS SEQ,  "
	cSql += "		C5_EMISSAO AS EMISSAO, "
	cSql += "		C6_ENTREG AS ENTREGA, "
	cSql += "		C9_DATALIB AS EMPENHO, "
	cSql += "		DC_QUANT AS SALDOTOTAL, "
	cSql += "		C6_YDTNECE AS DTNECE "
	If cEmpAnt $ "01_05_07_14".And. cEmpresa != "07"// (Thiago Dantas - 24/02/15)-> Se o local é LM, busca na LM
		If cEmpresa == "01"
			cSql += " FROM SDC010 DC, SC9010 C9, SC5010 C5, SC6010 C6 "
		ElseIf cEmpresa == "05"
			cSql += " FROM SDC050 DC, SC9050 C9, SC5050 C5, SC6050 C6 "
		ElseIf cEmpresa == "13"
			cSql += " FROM SDC130 DC, SC9130 C9, SC5130 C5, SC6130 C6 "
		ElseIf cEmpresa == "14"
			cSql += " FROM SDC140 DC, SC9140 C9, SC5140 C5, SC6140 C6 "
		EndIf
	Else
		cSql += " FROM " + RETSQLNAME("SDC") +  " DC, " + RETSQLNAME("SC9") +  " C9, " + RETSQLNAME("SC5") +  " C5 WITH (NOLOCK), " + RETSQLNAME("SC6") +  " C6 WITH (NOLOCK)"
	EndIf
	cSql += " WHERE	C9.C9_FILIAL = '"+xFilial("SC9")+"'  AND "
	cSql += "		DC.DC_FILIAL = '"+xFilial("SDC")+"'  AND "
	cSql += "		C5.C5_FILIAL = '"+xFilial("SC5")+"'  AND "
	cSql += "		C6.C6_FILIAL = '"+xFilial("SC6")+"'  AND "
	cSql += "	 	DC.DC_PRODUTO = C9.C9_PRODUTO AND  "
	cSql += "	 	DC.DC_PEDIDO = C9.C9_PEDIDO AND "
	cSql += "	 	C9_PRODUTO = '" + PRO + "'  AND "
	cSql += "	 	C5_NUM     = C9_PEDIDO      AND "
	cSql += "	 	C6_NUM     = C5_NUM      	AND "
	cSql += "	 	C6_PRODUTO = C9_PRODUTO     AND "
	cSql += "	 	C6_ITEM    = C9_ITEM        AND "
	cSql += "	 	DC_LOCALIZ = '" + _cRuaSel		+ "' AND "
	cSql += "	 	DC_LOTECTL = '" + _cLoteSel		+ "'  AND "
	cSql += " 		DC.DC_ITEM = C9.C9_ITEM AND "
	cSql += " 		DC.DC_SEQ  = C9.C9_SEQUEN AND "
	cSql += " 		C9_NFISCAL = '' AND "
	cSql += " 		C9_BLEST   = '' AND "
	cSql += " 		C9_BLCRED  = '' AND "
	cSql += " 		C9.D_E_L_E_T_ = ''  AND "
	cSql += " 		DC.D_E_L_E_T_ = '' 	AND "
	cSql += " 		C5.D_E_L_E_T_ = '' 	AND "
	cSql += " 		C6.D_E_L_E_T_ = ''      "
	cSql += " GROUP BY C5_YCLIORI, C5_CLIENTE, C5_LOJACLI, C5_YLOJORI, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_AGREG, C5_EMISSAO, C6_ENTREG, C9_DATALIB, DC_QUANT, C6_YDTNECE"
	cSql += ") AS WWW "

	If (cEmpAnt == "07" .And. cFilAnt <> '05') .And. cEmpresa == "07"

		cSql += " UNION ALL "
		cSql += " SELECT "
		cSql += " CODCLI = C5_CLIENTE, "
		cSql += " NUMERO = CASE WHEN C9_AGREG = '' THEN '' ELSE SUBSTRING(C9_DATALIB,1,4)+C9_AGREG END, "
		cSql += " ITEM = C6_ITEM, "
		cSql += " SEQ = C9_SEQUEN, "
		cSql += " CLIENTE = C9_PEDIDO, "
		cSql += " EMISSAO = C5_EMISSAO, "
		cSql += " ENTREGA = C6_ENTREG, "
		cSql += " EMPENHO = C9_DATALIB, "
		cSql += " SALDOTOTAL = C9_QTDLIB, "
		cSql += " DTNECE = C6_YDTNECE,  "
		cSql += " (SELECT A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = C5_CLIENTE+C5_LOJACLI AND D_E_L_E_T_ = '') AS  A1_NOME "
		cSql += " FROM "+RETSQLNAME("SC9")+" SC9 "
		cSql += " JOIN "+RETSQLNAME("SC5")+" SC5 WITH (NOLOCK) ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_='' "
		cSql += " JOIN "+RETSQLNAME("SC6")+" SC6 WITH (NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_='' "
		cSql += " WHERE "
		cSql += " C9_PRODUTO = '" + PRO + "' "
		cSql += " AND C9_NFISCAL = '' "
		cSql += " AND C9_BLEST   = '' "
		cSql += " AND C9_BLCRED  = '' "
		cSql += " AND SC9.D_E_L_E_T_='' "

	EndIf

	cSql += " ORDER BY EMISSAO,CLIENTE "

	cAliasTmp := GetNextAlias()
	TCQUERY cSql ALIAS (cAliasTmp) NEW
	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(EOF())

		aAux := {}

		AAdd(aAux,(cAliasTmp)->A1_NOME)
		AAdd(aAux,(cAliasTmp)->SALDOTOTAL)
		AAdd(aAux,(cAliasTmp)->NUMERO)
		AAdd(aAux,(cAliasTmp)->CLIENTE)
		AAdd(aAux,(cAliasTmp)->ITEM)
		AAdd(aAux,(cAliasTmp)->SEQ)
		AAdd(aAux,DTOC(STOD((cAliasTmp)->EMISSAO)))
		AAdd(aAux,DTOC(STOD((cAliasTmp)->ENTREGA)))
		AAdd(aAux,DTOC(STOD((cAliasTmp)->EMPENHO)))
		AAdd(aAux,cValToChar(DateDiffDay(dDataBase, sTod((cAliasTmp)->EMPENHO))))
		AAdd(aAux,DTOC(STOD((cAliasTmp)->DTNECE)))

		Aadd(aDBrowse3,aAux)

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} ShowProdObs
@description Exibe informacaoes de Produtos com Defeito (SZE)
@author Ranisses A. Corona / Renewed by Fernando Rocha 2020
@since 13/02/08 
@version 1.0
@type function
/*/
Static Function ShowProdObs(PRO, LOT)

	Local _nObsPrd := ""
	Local cSql
	Local cNOBS
	Local cAliasTmp := GetNextAlias()

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+PADR(PRO, TamSX3("B1_COD")[1],""),.F.))

	If Alltrim(_cProdSel)== ""
		MsgAlert("Realize a pesquisa e selecione um Produto","Consulta Estoque")
		Return
	EndIf

	cSql := "SELECT * FROM "+RetSqlName("ZZ9")+" WHERE	ZZ9_PRODUT = '"+PRO+ "' AND ZZ9_LOTE 	= '"+LOT+"' AND D_E_L_E_T_ = '' "
	TCQUERY cSql ALIAS (cAliasTmp) NEW

	If Alltrim((cAliasTmp)->ZZ9_OBS) == ""

		MsgAlert("O Produto selecionado não possui Observação cadastrada.","Consulta Estoque")
		Return

	EndIf

	cNOBS := (cAliasTmp)->ZZ9_OBS

	_nObsPrd += "Produto " + CRLF
	_nObsPrd += Alltrim((cAliasTmp)->ZZ9_PRODUT)+' - '+Alltrim(LOT)+' - '+AllTrim(SB1->B1_DESC) + CRLF
	_nObsPrd += "Data Produção " + CRLF
	_nObsPrd += SUBSTR((cAliasTmp)->ZZ9_DTPROD,7,2)+"/"+SUBSTR((cAliasTmp)->ZZ9_DTPROD,5,2)+"/"+SUBSTR((cAliasTmp)->ZZ9_DTPROD,1,4) + CRLF
	_nObsPrd += "Informações " + CRLF
	_nObsPrd += cNOBS + CRLF

	(cAliasTmp)->(DbCloseArea())

	U_FROPMSG("Observações do Produto", _nObsPrd)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} BIAChkMV
Valida se o de campos está Ok para execução da rotina como MVC
@since 05/09/2012
@version P11
@return lRet  -> Se está atualizado ou não
/*/
//-------------------------------------------------------------------
User Function BIAChkMV()

	Local lRet     := .F.			// Indicação da atualização
	Local aSave    := GetArea()  	// guarda area ativa
	Local aSaveSXB := {}  			// guarda área do dicionário de consulta padrão
	Local nTamXB   := 0   			// tamanho do campos XB_ALIAS

	DbSelectArea('SXB')
	aSaveSXB := SXB->( GetArea() )

	nTamXB := Len( SXB->XB_ALIAS )

	SXB->( DbSetOrder( 1 ) )

	//-------------------------------------------
	//  Consulta criada especificamente para uso na
	// na rotina com MVC, caso não tenha sido criada
	// o update não foi executado
	lRet := SXB->( DbSeek( PadR('MATSC0', nTamXB ) ) )

	RestArea( aSaveSXB )
	RestArea( aSave )

Return lRet


Static Function fHistorico(cProduto, cLote)

	If !Empty(cProduto) .And. !Empty(cLote)

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+PADR(cProduto, TamSX3("B1_COD")[1],""),.F.))

		U_BIAF106(cProduto, SB1->B1_DESC, cLote)

	EndIf

Return()


Static Function Sort(nCol, aBrwOrder, aBrwList, oBrw, nSortDefault)

	Local nSort 			:= 0
	Local nCount 			:= 0

	For nCount := 1 To Len(aBrwOrder)

		If nCount <> nCol

			aBrwOrder[nCount] := 0

			oBrw:SetHeaderImage(nCount, "")

		EndIf

	Next

	If (nSortDefault > 0  .And. nSortDefault == 1)

		nSort := 2
		aSort(aBrwList,,, {|x,y| (x[nCol]) > (y[nCol])})

	ElseIf (nSortDefault > 0  .And. nSortDefault == 2)

		nSort := 1
		aSort(aBrwList,,, {|x,y| (x[nCol]) < (y[nCol])})

	Else

		If aBrwOrder[nCol] == 1

			nSort := 2

			aSort(aBrwList,,, {|x,y| (x[nCol]) > (y[nCol])})

		Else

			nSort := 1

			aSort(aBrwList,,, {|x,y| (x[nCol]) < (y[nCol])})

		EndIf

	EndIf

	aBrwOrder[nCol] := nSort

	oBrw:SetHeaderImage(nCol, If (nSort == 1, "COLDOWN", "COLRIGHT"))

	oBrw:Refresh()

Return()
