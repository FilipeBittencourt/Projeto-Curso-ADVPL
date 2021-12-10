#Include "TOTVS.CH"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFaturamentoMonitor
@description Tela para consulta , monitoramento e faturamento automatico de cargas
@author Fernando Rocha / Projeto Ciclo de Pedido
@since 06/08/2019
@version 1.0

@type class
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN1 "LIN1"
#DEFINE LIN2 "LIN2"
#DEFINE LIN3 "LIN3"
#DEFINE LIN4 "LIN4"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_1 7
#DEFINE PER_LIN_2 28
#DEFINE PER_LIN_3 28
#DEFINE PER_LIN_4 37

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND1 "WND1"
#DEFINE WND2 "WND2"
#DEFINE WND3 "WND3"
#DEFINE WND4 "WND4"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Monitor de Faturamento"
#DEFINE TIT_WND_CARGA "Cargas Disponíveis para Faturamento"
#DEFINE TIT_WND_PEDIDOS "Pedidos da Carga"
#DEFINE TIT_WND_DOC "Documento Fiscal"

//COLUNAS DO BROWSE DE CARGAS
#DEFINE C_ST_CARGA	1

/*C_ST_CARGA
1 = Faltando Dados
2 = Motorista nao chegou
3 = Faturamento Autorizada
4 = Documento Preparado
5 = Transmitida
6 = NFe Autorizada
....

*/
#DEFINE C_EDIT_BITMAP 1
#DEFINE C_CARGA 	2
#DEFINE C_TICKET 	3
#DEFINE C_PLACA		4
#DEFINE C_TRANSP 	5
#DEFINE C_FRETE 	6
#DEFINE C_ECOSIS	7
#DEFINE C_BALANC	8
#DEFINE C_DIVERG	9
#DEFINE C_PBT		10

#DEFINE C_OBS		11
#DEFINE C_DATA		12
#DEFINE C_FAT		13

//COLUNAS DO BROWSE DE PEDIDOS
#DEFINE P_EDIT_BITMAP 1
#DEFINE P_CARGA 	2
#DEFINE P_PEDIDO	3
#DEFINE P_ITEM		4
#DEFINE P_NFISCAL	5
#DEFINE P_EMISSAONF	6
#DEFINE P_SERIE		7
#DEFINE P_PRODUTO	8
#DEFINE P_QTDE		9
#DEFINE P_PESO		10
#DEFINE P_CLIENTE	11
#DEFINE P_LOJA		12
#DEFINE P_NOMCLI	13
#DEFINE P_EST		14
#DEFINE P_CLIENTEO	15
#DEFINE P_LOJAO		16
#DEFINE P_NOMCLIO	17
#DEFINE P_ESTO		18
#DEFINE P_MSGPAD	19
#DEFINE P_MSGNOTA	20
#DEFINE P_VLRFRET	21

//COLUNAS DO BROWSE DE DOCUMENTOS
#DEFINE D_EDIT_BITMAP 	1
#DEFINE D_EMPFIL		2
#DEFINE D_CARGA	 		3
#DEFINE D_DOC			4
#DEFINE D_SERIE			5
#DEFINE D_CLIENTE		6
#DEFINE D_LOJA			7
#DEFINE D_NREDUZ		8
#DEFINE D_CNPJ			9
#DEFINE D_EST			10
#DEFINE D_TRANSP		11
#DEFINE D_CNPJTRANSP	12
#DEFINE D_UFTRANSP		13
#DEFINE D_VEIC			14
#DEFINE D_SERMDF		15
#DEFINE D_NUMMDF		16
#DEFINE D_STATUS_NFE	17
#DEFINE D_STATUS_LM		18
#DEFINE D_STATUS_GNRE	19
#DEFINE D_STATUS_MDFE	20
#DEFINE D_GUIA			21

#DEFINE N_DOC			1
#DEFINE N_SERIE			2
#DEFINE N_CLIENTE		3
#DEFINE N_LOJA			4
#DEFINE N_CNPJ			5
#DEFINE N_NREDUZ		6
#DEFINE N_EMISSAO		7
#DEFINE N_EST			8
#DEFINE N_VEIC			9
#DEFINE N_SERMDF		10
#DEFINE N_NUMMDF		11
#DEFINE N_TRANSP		12
#DEFINE N_CNPJTRANSP	13
#DEFINE N_UFTRANSP		14
#DEFINE N_CARGA			15
#DEFINE N_CODCLI		16
#DEFINE N_CODLOJA		17
#DEFINE N_GUIA			18
#DEFINE N_STATUS_LM		19
#DEFINE N_STATUS_NFE	20
#DEFINE N_STATUS_GNRE	21
#DEFINE N_STATUS_MDFE	22

Class TFaturamentoMonitor FROM LongClassName

	Data cImpressora
	Data cPathPrint

	Data cCarga
	Data cCargaPesq

	Data dDtAgend
	Data cFaturadas
	Data cMotPatio
	Data cName
	Data aParam
	Data aParRet
	Data bConfirm

//propriedades
	Data aCargas
	Data aPedidos
	Data aDocumentos
	Data cDlgTime
	Data lAutIsStarted

//Objetos visual
	Data oDlg
	Data oTimer
	Data oTimerLoad
	Data oGetCarga
	Data oBtnStop
	Data oSayAlert

	Data oBrwCarga
	Data oBrwPedido
	Data oBrwDocumento

	Data oSayTime
	Data oObjFat

//metodos publicos
	Method New() Constructor

	Method Get(lPergunte, lMonit)
	Method Pergunte(lPergunte)

	Method GetCarga()
	Method GetPrc()
	Method LoadPed(lMonit)
	Method GetPedidos(lGrid)
	Method GetDocCarDest(cEmp, cFil, cUf, cCarga, cCodCli, cCodLoja)
	Method AtuLegDoc()
	Method CargaOk(cCarga, lAllReady, lNfe, lMdfe, lGnre, lLMOk)
	Method Print()
	Method Print2()
	Method SetPrintOk(cCarga)
	Method IsGnrePaga(cEmp, cFil, cDoc, cSerie, cCliente, cLoja)
	Method GetTipoPedido(cEmp, cFil, cDoc, cSerie, cCliente, cLoja)

	Method GetCol(_nCol)
	Method GetColDoc(_nCol)
	Method GetColPed(_nCol)

	Method GetBmpCarga(_nSit)
	Method GetBmpDoc(_nSit)
	Method SetTimer()
	Method Show()
	Method ScrRefresh()
	Method SeekCarga()
	Method SelectImpressora()
	Method StopJobs()

	Method TelaCarga()
	Method TelaPedido()

	Method Faturar()
	Method SetKeys()

EndClass

Method New () Class TFaturamentoMonitor

	::lAutIsStarted := U_GETBIAPAR("BIA_FATAUTO", .T.)
	::cImpressora	:= ""
	::cPathPrint := ""

	::cCarga := Space(TamSX3("C9_AGREG")[1])
	::cCargaPesq := Space(TamSX3("C9_AGREG")[1])

	::dDtAgend := dDataBase
	::cFaturadas := "1"
	::cMotPatio := "1"

	::cName := "TFaturamentoMonitor"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}

	::aCargas	:= {}
	::aPedidos	:= {}
	::aDocumentos := {}

	::cDlgTime	:= "00:00:00"

	::oDlg			:= Nil
	::oTimer 		:= Nil
	::oTimerLoad 	:= Nil

	::oBrwCarga		:= Nil
	::oBrwPedido 	:= Nil
	::oBrwDocumento	:= Nil

	::oSayTime		:= Nil

	::oObjFat 		:= TFaturamentoAutomatico():New()

Return()

	Method SelectImpressora()Class TFaturamentoMonitor

	Local lRet 		:= .F.
	Local oBtnSair	:= nil
	Local oBtnOK	:= nil
	Local aImpress 	:= GetImpWindows(.F.) //Lista de impressoras disponíveis - A 1ª é a impressora padrão
	Local cImpress	:= Space(20)
	Local cConfImp	:= GetPrinterSession()

	DEFINE MSDIALOG oDlg TITLE "Seleção da Impressora" FROM 000, 000  TO 230, 350 PIXEL

	@ 015, 028 COMBOBOX cImpress ITEMS aImpress  	SIZE 120, 010 PIXEL OF oDlg
	@ 030, 094 BUTTON oBtnSair PROMPT "OK"     	SIZE 037, 012 OF oDlg ACTION {||lRet := .T., oDlg:End()} PIXEL
	@ 030, 134 BUTTON oBtnOK PROMPT "Sair"     	SIZE 037, 012 OF oDlg ACTION {||lRet := .F., oDlg:End()} PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
		::cImpressora := cImpress
		WriteProfString(cConfImp,"DEFAULT",cImpress,.T.) //Altera a impressora default do usuário
	EndIf

Return()

Method Print2() Class TFaturamentoMonitor

	Local aImpress 	:= {}
	Local cConfImp	:= GetPrinterSession()

	If Empty(::cImpressora) //Variável privada
		aImpress := GetImpWindows(.F.)
		If Len(aImpress) > 0
			::cImpressora := aImpress[1]
		Else
			Aviso("Atencao","Não foi encontrado impressora instalado neste computador, favor entrar em contato com a TI (Infra-estrutura)",{"OK"})
		EndIf
	EndIf

	If ! Empty(::cImpressora)
		If at('\\', ::cImpressora) <= 0
			::cImpressora := '\\' + AllTrim(ComputerName()) + '\' + ::cImpressora
		EndIf

		cRet := WaitRun('print /d:"' + ::cImpressora +'" ' + cNameFile, SW_HIDE)

		If cRet == 0
			If File(cNameFile)
				FErase(cNameFile)
			Endif
		EndIf
	EndIf

Return()

Method Get(lPergunte, lMonit) Class TFaturamentoMonitor

	Default lPergunte  := .F.
	Default lMonit  := .F.

	If ::Pergunte(lPergunte)

		If lMonit

			LjMsgRun("Aguarde... sincronizando pedidos",,{|| ::LoadPed(lMonit) })

			//::LoadPed(lMonit)

		Else

			LjMsgRun("Aguarde... carregando cargas",,{|| ::GetPrc() })

			LjMsgRun("Aguarde... carregando pedidos",,{|| ::LoadPed() })

		EndIf

	EndIf

Return()

Method LoadPed(lMonit) Class TFaturamentoMonitor

	Default lMonit  := .F.

	If lMonit

		::GetPedidos()

	Else

		::oBrwCarga:SetArray(::aCargas)
		::oBrwCarga:Refresh()
		::oBrwCarga:GoTop() // Quando executa esse metodo, chama bChange que contem o GetPedidos(), por isso comentei a linha abaixo

		::GetPedidos()

	EndIf

	::oBrwCarga:SetFocus()

Return()

Method SeekCarga() Class TFaturamentoMonitor

	Local nW := 0

	For nW := 1 To Len(::aCargas)

		If AllTrim(::aCargas[nW][C_CARGA]) == ::cCargaPesq

			::oBrwCarga:GoPosition(nW)

			::GetPedidos()

			::oGetCarga:SetFocus()

			Exit

		EndIf

	Next nW

Return()

Method GetPrc() Class TFaturamentoMonitor

	Local cAliasTmp := GetNextAlias()
	Local aAux := {}
	Local cFiltro := If(Empty(::cCarga), "% ZZV_DATAAG = " + ValToSql(::dDtAgend) + "%", "% ZZV_CARGA = " + ValToSql(::cCarga) + "%" )
	Local oObjFat := ::oObjFat
	Local lFat := .F.
	Local oPesaCarga := Nil

	BeginSql Alias cAliasTmp

		SELECT DISTINCT
		ZZV_FIMP,
		ZZV_CARGA,
		ZZV_TICKET,
		ZZV_PLACA,
		ZZV_TRANSP,
		ZZV_CFRETE,
		ZZV_OBS,
		ZZV_DATINC,
		NUMNFS = (SELECT COUNT(1) FROM %table:SC9% SC9 WHERE C9_FILIAL  = ZZW_FILIAL AND C9_PEDIDO = ZZW_PEDIDO AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW_SEQUEN AND C9_NFISCAL <> ' ' AND SC9.D_E_L_E_T_='')
		FROM %table:ZZV% ZZV
		JOIN %table:ZZW% ZZW ON ZZW_FILIAL = ZZV_FILIAL AND ZZW_CARGA = ZZV_CARGA		
		WHERE 
		ZZV_FILIAL = %Exp:xFilial("ZZV")%
		AND %Exp:cFiltro%
		AND 
		(
			(
				%Exp:Self:cMotPatio% = '1'
			)
			OR 
			(
				%Exp:Self:cMotPatio% = '2'
				AND EXISTS
				(
					SELECT *
					FROM %table:Z11% Z11 ( NOLOCK )
					WHERE Z11_FILIAL = %Exp:xFilial("Z11")%
					AND Z11_PESAGE 	 = ZZV_TICKET 
					AND Z11_MOTPAT 	 = 'S' 
					AND Z11.D_E_L_E_T_ = ' '
				)
			)
		)
		AND 
		(	
			(
				%Exp:Self:cFaturadas% = '1'
			)
			OR
			(
				%Exp:Self:cFaturadas% = '2'
				AND (SELECT COUNT(1) FROM %table:SC9% SC9 WHERE C9_FILIAL  = ZZW_FILIAL AND C9_PEDIDO = ZZW_PEDIDO AND C9_ITEM = ZZW_ITEM AND C9_SEQUEN = ZZW_SEQUEN AND C9_NFISCAL <> ' ' AND SC9.D_E_L_E_T_='') = 0
			)
		)
		AND ZZV.D_E_L_E_T_=''
		AND ZZW.D_E_L_E_T_=''
		ORDER BY ZZV_CARGA

	EndSql

	(cAliasTmp)->(DbGoTop())

	::aCargas := {}

	While !(cAliasTmp)->(Eof())

		aAux := {}
		lFat := .F.

		If ( (cAliasTmp)->NUMNFS > 0  )

			lFat := .T.

			If (cAliasTmp)->ZZV_FIMP == "2"

				AAdd(aAux, ::GetBmpCarga(4) )

			Else

				AAdd(aAux, ::GetBmpCarga(3) )

			EndIf

		Else

			__nVld := oObjFat:VldCarga((cAliasTmp)->ZZV_CARGA, .F.)

			If ( __nVld > 0 )

				AAdd(aAux, ::GetBmpCarga(2) )

			Else

				AAdd(aAux, ::GetBmpCarga(1) )

			EndIf

		EndIf

		AAdd(aAux, (cAliasTmp)->ZZV_CARGA )
		AAdd(aAux, (cAliasTmp)->ZZV_TICKET )
		AAdd(aAux, (cAliasTmp)->ZZV_PLACA )
		AAdd(aAux, (cAliasTmp)->ZZV_TRANSP )
		AAdd(aAux, If((cAliasTmp)->ZZV_CFRETE == "S", "Sim", "Não") )

		oPesaCarga := TPesagemCarga():New((cAliasTmp)->ZZV_CARGA, (cAliasTmp)->ZZV_TICKET)

		AAdd(aAux, Transform(oPesaCarga:nPesoEcosis, "@E 999,999.99") )
		AAdd(aAux, Transform(oPesaCarga:nPesoBalanca, "@E 999,999.99") )
		AAdd(aAux, Transform(oPesaCarga:nDiverPeso, "@E 999,999.99") )
		AAdd(aAux, Transform(oPesaCarga:nDiverCapacidade, "@E 999,999.99") )

		AAdd(aAux, (cAliasTmp)->ZZV_OBS )
		AAdd(aAux, STOD((cAliasTmp)->ZZV_DATINC) )
		aAdd(aAux, lFat)

		AAdd(::aCargas, aAux)

		(cAliasTmp)->(DbSkip())

	EndDo

	(cAliasTmp)->(DbCloseArea())

Return()

Method Show() Class TFaturamentoMonitor

	Local aCoors
	Local oBtnBar
	Local oLayer
	Local oPnlNfs

	// Array com as coordenadas da janela
	aCoors := FWGetDialogSize(oMainWnd)

	// Cria Dialog
	::oDlg := MsDialog():New(aCoors[1], aCoors[2], aCoors[3], aCoors[4], TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .F.
	::oDlg:bValid := {|| .F. }

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oDlg, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN1, PER_LIN_1, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN1)

	// Painel Ativo
	oPanel := oLayer:getLinePanel(LIN1)

	oConfirma := TBUTTON():Create(oPanel)
	oConfirma:cCaption	:= ""
	oConfirma:nLeft 	:= 1
	oConfirma:nTop 		:= 1
	oConfirma:nWidth 	:= 60
	oConfirma:nHeight 	:= 30
	oConfirma:Align		:= CONTROL_ALIGN_RIGHT
	oConfirma:cTooltip 	:= "Fechar a Janela"
	oConfirma:SetCss("QPushButton{background-image:url(rpo:door.png); background-repeat: none; background-position: center; background-size: cover;}")
	oConfirma:bAction 	:= {|| ::oDlg:End()}

	oBtnCarga := TBUTTON():Create(oPanel)
	oBtnCarga:cCaption	:= ""
	oBtnCarga:nLeft 	:= 1
	oBtnCarga:nTop 		:= 1
	oBtnCarga:nWidth 	:= 60
	oBtnCarga:nHeight 	:= 30
	oBtnCarga:Align		:= CONTROL_ALIGN_RIGHT
	oBtnCarga:cTooltip 	:= "Alterar/Dados da Carga [CTRL + C]"
	oBtnCarga:SetCss("QPushButton{background-image:url(rpo:truck.png); background-repeat: none; background-position: center; background-size: cover;}")
	oBtnCarga:bAction 	:= {|| ::TelaCarga() }

	oBtnFat := TBUTTON():Create(oPanel)
	oBtnFat:cCaption	:= ""
	oBtnFat:nLeft 		:= 1
	oBtnFat:nTop 		:= 1
	oBtnFat:nWidth 		:= 60
	oBtnFat:nHeight 	:= 30
	oBtnFat:Align		:= CONTROL_ALIGN_RIGHT
	oBtnFat:cTooltip 	:= "Faturar Carga [CTRL + F]"
	oBtnFat:SetCss("QPushButton{background-image:url(rpo:invoice.png); background-repeat: none; background-position: center; background-size: cover;}")
	oBtnFat:bAction 	:= {|| ::Faturar() }

	oBtnRefr := TBUTTON():Create(oPanel)
	oBtnRefr:cCaption	:= ""
	oBtnRefr:nLeft 		:= 1
	oBtnRefr:nTop 		:= 1
	oBtnRefr:nWidth 	:= 60
	oBtnRefr:nHeight 	:= 30
	oBtnRefr:Align		:= CONTROL_ALIGN_RIGHT
	oBtnRefr:cTooltip 	:= "Atualizar Cargas [F5]"
	oBtnRefr:SetCss("QPushButton{background-image:url(rpo:refresh.png); background-repeat: none; background-position: center; background-size: cover;}")
	oBtnRefr:bAction 	:= {|| ::Get(.T.) }

	oBtnPrint := TBUTTON():Create(oPanel)
	oBtnPrint:cCaption	:= ""
	oBtnPrint:nLeft 	:= 1
	oBtnPrint:nTop 		:= 1
	oBtnPrint:nWidth 	:= 60
	oBtnPrint:nHeight 	:= 30
	oBtnPrint:Align		:= CONTROL_ALIGN_RIGHT
	oBtnPrint:cTooltip 	:= "Imprimir Carga [CTRL + P]"
	oBtnPrint:SetCss("QPushButton{background-image:url(rpo:print.png); background-repeat: none; background-position: center; background-size: cover;}")
	oBtnPrint:bAction 	:= {|| ::Print() }

	::oBtnStop := TBUTTON():Create(oPanel)
	::oBtnStop:cCaption	:= ""
	::oBtnStop:nLeft 	:= 1
	::oBtnStop:nTop 	:= 1
	::oBtnStop:nWidth 	:= 60
	::oBtnStop:nHeight 	:= 30
	::oBtnStop:Align	:= CONTROL_ALIGN_RIGHT
	::oBtnStop:cTooltip := "Parar/Iniciar Automação"
	::oBtnStop:bAction 	:= {|| ::StopJobs() }

	oFont1 := TFont():New('Courier new',,-15,.T.)
	oFont2 := TFont():New('Courier new',,-15,.T.)
	oFont3 := TFont():New('Courier new',,-18,.T.)

	//::oSayTime := TSay():New(01,01,{|| ::cDlgTime },oPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,40)
	//::oSayTime:Align		:= CONTROL_ALIGN_LEFT

	oSayCarga := TSay():Create(::oDlg)
	oSayCarga:cName := "oSayCarga"
	oSayCarga:cCaption := "Carga: "
	oSayCarga:nLeft := 06
	oSayCarga:nTop := 07
	oSayCarga:nWidth := 100
	oSayCarga:nHeight := 30
	oSayCarga:lReadOnly := .T.
	oSayCarga:oFont := oFont1
	oSayCarga:cToolTip := "Código da carga"

	::oGetCarga := TGet():Create(::oDlg)
	::oGetCarga:cName := "::oGetCarga"
	::oGetCarga:nLeft := 70
	::oGetCarga:nTop := 06
	::oGetCarga:nWidth := 50
	::oGetCarga:nHeight := 20
	::oGetCarga:oFont := oFont2
	::oGetCarga:cVariable := "::cCargaPesq"
	::oGetCarga:bSetGet := bSetGet(::cCargaPesq)
	::oGetCarga:bChange := {|| ::SeekCarga()}
	//::oGetCarga:Picture := PesqPict("SAK", "AK_USER")
	::oGetCarga:lHasButton := .T.
	::oGetCarga:cToolTip := "Código da carga"


	::oSayAlert := TSay():Create(::oDlg)
	::oSayAlert:cName := "oSayCarga"
	::oSayAlert:nLeft := 200
	::oSayAlert:nTop := 07
	::oSayAlert:nWidth := 600
	::oSayAlert:nHeight := 30
	::oSayAlert:lReadOnly := .T.
	::oSayAlert:oFont := oFont3
	::oSayAlert:nClrText := CLR_RED


	If ( ::lAutIsStarted )
		::oSayAlert:cCaption := ""
		::oBtnStop:SetCss("QPushButton{background-image:url(rpo:fastop.png); background-repeat: none; background-position: center; background-size: cover;}")
	Else
		::oSayAlert:cCaption := "ATENÇÃO! FATURAMENTO AUTOMÁTICO PARADO."
		::oBtnStop:SetCss("QPushButton{background-image:url(rpo:faplay.png); background-repeat: none; background-position: center; background-size: cover;}")
	EndIf

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN2, PER_LIN_2, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN2)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND2, TIT_WND_CARGA, 100, .F. ,.T.,, LIN2, { || })

	// Painel Ativo
	oPanel := oLayer:GetWinPanel(COL, WND2, LIN2)

	::oBrwCarga := TCBrowse():New(00,00,0,0,,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwCarga:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrwCarga:lHScroll := .T.
	::oBrwCarga:lVScroll := .T.

	::oBrwCarga:AddColumn(TCColumn():New(" " ,				{|| ::GetCol(C_ST_CARGA)}	,,,,"LEFT", 10,.T.,.F.,,,,.T.))
	::oBrwCarga:AddColumn(TcColumn():New("Carga", 			{|| ::GetCol(C_CARGA)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Ticket", 			{|| ::GetCol(C_TICKET)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Placa", 			{|| ::GetCol(C_PLACA)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Transportador", 	{|| ::GetCol(C_TRANSP)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Icms Frete",	 	{|| ::GetCol(C_FRETE)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwCarga:AddColumn(TcColumn():New("Peso Ecosis", 	{|| ::GetCol(C_ECOSIS)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Peso Balança", 	{|| ::GetCol(C_BALANC)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Divergência", 	{|| ::GetCol(C_DIVERG)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("%PBT", 			{|| ::GetCol(C_PBT)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwCarga:AddColumn(TcColumn():New("Observação", 		{|| ::GetCol(C_OBS)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwCarga:AddColumn(TcColumn():New("Data", 			{|| ::GetCol(C_DATA)}		, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	//::oBrwCarga:bChange := {|| }
	::oBrwCarga:bSeekChange := {|| ::GetPedidos()}

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN3, PER_LIN_3, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN3)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND3, TIT_WND_PEDIDOS, 100, .F. ,.T.,, LIN3, { || })

	// Painel Ativo
	oPanel := oLayer:GetWinPanel(COL, WND3, LIN3)

	::oBrwPedido := TCBrowse():New(00,00,0,0,,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwPedido:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrwPedido:lHScroll := .T.
	::oBrwPedido:lVScroll := .T.

	::oBrwPedido:AddColumn(TCColumn():New(" " ,				{|| ::GetColPed(P_EDIT_BITMAP)},,,,"LEFT", 10,.T.,.F.,,,,.T.))
	::oBrwPedido:AddColumn(TcColumn():New("Pedido", 		{|| ::GetColPed(P_PEDIDO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Item", 			{|| ::GetColPed(P_ITEM) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("NF", 			{|| ::GetColPed(P_NFISCAL) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Emissao NF",		{|| ::GetColPed(P_EMISSAONF) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Produto", 		{|| ::GetColPed(P_PRODUTO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Qtde", 			{|| ::GetColPed(P_QTDE) }, "@E 999,999.99", Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Peso", 			{|| ::GetColPed(P_PESO) }, "@E 999,999.99", Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwPedido:AddColumn(TcColumn():New("Cliente", 		{|| ::GetColPed(P_CLIENTE) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Loja",	 		{|| ::GetColPed(P_LOJA) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Nome",	 		{|| ::GetColPed(P_NOMCLI) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Uf",	 			{|| ::GetColPed(P_EST) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwPedido:AddColumn(TcColumn():New("Cliente Destino",{|| ::GetColPed(P_CLIENTEO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Loja",	 		{|| ::GetColPed(P_LOJAO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Nome",	 		{|| ::GetColPed(P_NOMCLIO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Uf",	 			{|| ::GetColPed(P_ESTO) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwPedido:AddColumn(TcColumn():New("Msg.Padrao", 	{|| ::GetColPed(P_MSGPAD) }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Msg.Nota", 		{|| ::GetColPed(P_MSGNOTA) }, "@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwPedido:AddColumn(TcColumn():New("Vlr.Frete", 		{|| ::GetColPed(P_VLRFRET) }, "@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwPedido:bLDblClick := {|| ::TelaPedido() }

	// Layer para os documentos fiscais
	// Adiciona linha ao Layer
	oLayer:AddLine(LIN4, PER_LIN_4, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN4)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND4, TIT_WND_DOC, 100, .F. ,.T.,, LIN4, { || })

	// Painel Ativo
	oPanel := oLayer:GetWinPanel(COL, WND4, LIN4)

	::oBrwDocumento := TCBrowse():New(00,00,0,0,,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwDocumento:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrwDocumento:lHScroll := .T.
	::oBrwDocumento:lVScroll := .T.

	::oBrwDocumento:AddColumn(TCColumn():New(" " ,				{|| ::GetColDoc(D_EDIT_BITMAP)	},,,,"LEFT", 10,.T.,.F.,,,,.T.))
	::oBrwDocumento:AddColumn(TcColumn():New("Filial",	 		{|| ::GetColDoc(D_EMPFIL)		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Documento", 		{|| ::GetColDoc(D_DOC) 			}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Serie", 			{|| ::GetColDoc(D_SERIE) 		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:AddColumn(TcColumn():New("Cliente", 		{|| ::GetColDoc(D_CLIENTE) 		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Loja", 			{|| ::GetColDoc(D_LOJA) 		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Nome", 			{|| ::GetColDoc(D_NREDUZ) 		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Cnpj/CPF",		{|| ::GetColDoc(D_CNPJ)			}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Uf Cliente",		{|| ::GetColDoc(D_EST) 			}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:AddColumn(TcColumn():New("Transp.",			{|| ::GetColDoc(D_TRANSP)		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Cnpj/CPF",		{|| ::GetColDoc(D_CNPJTRANSP)	}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Uf Transp.",		{|| ::GetColDoc(D_UFTRANSP)		}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:AddColumn(TcColumn():New("Veiculo",			{|| ::GetColDoc(D_VEIC)			}, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:AddColumn(TcColumn():New("Serie MDF-e",		{|| ::GetColDoc(D_SERMDF)		},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Numero MDF-e",	{|| ::GetColDoc(D_NUMMDF)		},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:AddColumn(TcColumn():New("Status NF-e",		{|| ::GetColDoc(D_STATUS_NFE) 	},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Status LM",		{|| ::GetColDoc(D_STATUS_LM) 	},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Status GNR-e",	{|| ::GetColDoc(D_STATUS_GNRE) 	},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrwDocumento:AddColumn(TcColumn():New("Status MDF-e",	{|| ::GetColDoc(D_STATUS_MDFE) 	},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	//::oBrwDocumento:AddColumn(TcColumn():New("Status Impressao",{|| ::GetColDoc(D_STATUS_IMP) 	},,Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))

	::oBrwDocumento:bLDblClick := {|| ::TelaPedido() }

	//Seta teclas de atalho
	::SetKeys()

	::Get(.T., .F.)
	//Inicia Timer de Refresh
	::SetTimer()

	// Abre Janela
	::oDlg:Activate()

	::SetKeys(.T.)

Return()

Method SetKeys(_lClear) Class TFaturamentoMonitor

	Default _lClear := .F.

	If !_lClear

		//Teclas de atalho
		SetKey ( K_CTRL_C,	{|| ::TelaCarga()} )
		SetKey ( K_CTRL_F,	{|| ::Faturar()} )
		SetKey ( VK_F5, 	{|| ::Get(.F.)} )
		SetKey ( K_CTRL_P,	{|| ::Print()} )

	Else

		SetKey ( K_CTRL_C, 	{||} )
		SetKey ( K_CTRL_F, 	{||} )
		SetKey ( VK_F5, 	{||} )
		SetKey ( K_CTRL_P, 	{||} )

	EndIf

Return()

Method GetCol(_nCol) Class TFaturamentoMonitor

	If ::oBrwCarga:nAt <= Len(::aCargas)

		Return(::aCargas[::oBrwCarga:nAt, _nCol])

	Else

		Return(Nil)

	EndIf

Return()

Method GetColPed(_nCol) Class TFaturamentoMonitor

	If ::oBrwPedido:nAt <= Len(::aPedidos)

		Return(::aPedidos[::oBrwPedido:nAt, _nCol])

	Else

		Return(Nil)

	EndIf

Return()

Method GetColDoc(_nCol) Class TFaturamentoMonitor

	If ::oBrwDocumento:nAt <= Len(::aDocumentos)

		Return(::aDocumentos[::oBrwDocumento:nAt, _nCol])

	Else

		Return(Nil)

	EndIf

Return()

Method GetCarga() Class TFaturamentoMonitor

	If ::oBrwCarga:nAt <= Len(::aCargas)

		Return(::aCargas[::oBrwCarga:nAt, C_CARGA])

	Else

		Return(Space(TamSX3("C9_AGREG")[1]))

	EndIf

Return()

Method SetTimer() Class TFaturamentoMonitor

	//::oTimer := TTimer():New(1000, {|| ::ScrRefresh() }, ::oDlg )
	//::oTimer:Activate()

	::oTimerLoad := TTimer():New(30000, {|| ::Get(.F. ,.T.) }, ::oDlg )

	If ( ::lAutIsStarted )
		::oTimerLoad:Activate()
	Else
		::oTimerLoad:DeActivate()
	EndIf

Return()

Method ScrRefresh() Class TFaturamentoMonitor

	::cDlgTime := Time()
	::oSayTime:Refresh()

Return()

/*/{Protheus.doc} TelaCarga
@description Chama a tabela de carga (ZZV) em modo de alteração para alguns campos que influeciam no faturamento
@author Fernando Rocha
@since 12/08/2019
@version 1.0
@type function
/*/
Method TelaCarga() Class TFaturamentoMonitor

	Local lRet		 := .T.
	Local aArea		 := ZZV->(GetArea())
	Local nOpcao	 := 0

	Local aAlterFields := {"ZZV_PLACA","ZZV_CODMOT","ZZV_TRANSP","ZZV_DOCMOT","ZZV_PL_UF","ZZV_PL_MUN", "ZZV_OBSNF1"}

	Private aButtons := {}
	Private cCadastro := "Alteração de Dados da Carga"

	//aAdd( aButtons, { "PEDIDO", {|| wVisual() }, "Pedido", "Visual. Pedido" } )

	ZZV->(DbSetOrder(1))

	If ZZV->(DbSeek(xFilial("ZZV")+::GetCarga()))

		nOpcao := AxAltera("ZZV",ZZV->(Recno()),4,,aAlterFields,,,,"",,aButtons,,,,.T.,,,,,)

		If nOpcao == 1

			MsgInfo("Operacao realizada com sucesso!")

		EndIf

	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} GetPedidos
@description Lista os pedidos vinculados a carga e permite alterar mensagens
@author Fernando Rocha
@since 12/08/2019
@version 1.0
@type function
/*/
Method GetPedidos(lGrid) Class TFaturamentoMonitor

	Local cAliasTmp
	Local aAux
	Local nPos := 0
	Local oObjFat := ::oObjFat
	Local oObjEmp := TLoadEmpresa():New()
	Local aNotas := {}
	Local cBckEmp := cEmpAnt
	Local cBckFil := cFilAnt
	Local nX, nW

	Default lGrid := .T.

	If lGrid

		::cCarga := ::GetCarga()

	EndIf

	oObjEmp:SeekCli("010064", "01")

	//alert(::oBrwCarga:nAT)
	//alert(::oBrwCarga:nRowPos)

	::aPedidos := {}

	::aDocumentos := {}

	If !Empty(::cCarga)

		cAliasTmp := GetNextAlias()

		BeginSql Alias cAliasTmp

			%NoParser%			

			SELECT
			%EXP:cEmpAnt + cFilAnt% EMPFIL,
			ZZW_PEDIDO,
			ZZW_ITEM,
			C9_NFISCAL,
			C9_SERIENF,
			C9_AGREG,
			B1_COD,
			C9_QTDLIB,
			PESO = dbo.FNC_GET_PESOPRODUTO(C9_PRODUTO, C9_LOTECTL, C9_QTDLIB),
			SA1A.A1_NREDUZ A1_NREDUZA,
			SA1A.A1_COD A1_CODA,
			SA1A.A1_LOJA A1_LOJAA,
			SA1A.A1_EST A1_ESTA,
			SA1A.A1_CGC,
			F2_TRANSP,
			F2_EMISSAO,
			F2_VEICUL1,
			F2_NFICMST + F2_GNRDIF + F2_GNRFECP GUIA,
			F2_SERMDF, F2_NUMMDF,
			A4_CGC,
			A4_EST,
			SA1B.A1_NREDUZ A1_NREDUZB,
			SC5.C5_YCLIORI, 
			SC5.C5_YLOJORI,
			SA1B.A1_EST A1_ESTB,
			SC5.C5_MENPAD,
			SC5.C5_MENNOTA,
			SC5.C5_YVLFRST,
			ISNULL(
			(
			SELECT
		CASE WHEN STATUS = 1
			THEN 'Recebida'
			WHEN STATUS = 2
			THEN 'Assinada'
			WHEN STATUS = 3
			THEN 'Falha no Schema'
			WHEN STATUS = 4
			THEN 'Transmitida'
			WHEN STATUS = 5
			THEN 'NF Com problemas'
			WHEN STATUS = 6
			THEN 'Autorizada'
		ELSE '' END
			FROM [DADOSADV].dbo.SPED050 A ( NOLOCK )
			WHERE ID_ENT = %Exp:oObjFat:cIdEnt%
			AND NFE_ID = SC9.C9_SERIENF + SC9.C9_NFISCAL
			AND A.D_E_L_E_T_ = ''
			), '') STATUS_NFE,

			ISNULL(
			(
			SELECT 				
		CASE WHEN STATUS = 1
			THEN 'Recebida'
			WHEN STATUS = 2
			THEN 'Assinada'
			WHEN STATUS = 3
			THEN 'Falha no Schema'
			WHEN STATUS = 4
			THEN 'Transmitida'
			WHEN STATUS = 5
			THEN 'NF Com problemas'
			WHEN STATUS = 6
			THEN 'Autorizada'
	 		WHEN STATUS = 8
			THEN 'MDFe Encerrado'
		ELSE '' END
			FROM [DADOSADV].dbo.SPED050 A ( NOLOCK )
			WHERE ID_ENT = %Exp:oObjFat:cIdEnt%
			AND NFE_ID = SF2.F2_SERMDF + SF2.F2_NUMMDF
			AND A.D_E_L_E_T_ = ''	
			), '') STATUS_MDFE,

		CASE WHEN SC5.C5_YTPCRED = '5' AND SA1A.A1_EST = 'SP' THEN 'N/A' ELSE (
			ISNULL(
			(
			SELECT 				
		CASE WHEN STATUS = 1
			THEN 'Aguardando transmissão'
			WHEN STATUS = 2
			THEN 'Transmitido'
			WHEN STATUS = 3
			THEN 'Falha no Schema'
			WHEN STATUS = 4
			THEN 'Rejeição da SEFAZ'
			WHEN STATUS = 5
			THEN 'Autorizada'
		ELSE '' END
			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK )
			WHERE ID_ENT = %Exp:oObjFat:cIdEnt%
			AND ID = SF2.F2_EST + F2_NFICMST
			AND A.D_E_L_E_T_ = ''
			), '')
			+

			ISNULL(
			(
			SELECT 				
		CASE WHEN STATUS = 1
			THEN 'Aguardando transmissão'
			WHEN STATUS = 2
			THEN 'Transmitido'
			WHEN STATUS = 3
			THEN 'Falha no Schema'
			WHEN STATUS = 4
			THEN 'Rejeição da SEFAZ'
			WHEN STATUS = 5
			THEN 'Autorizada'
		ELSE '' END
			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK )
			WHERE ID_ENT = %Exp:oObjFat:cIdEnt%
			AND ID = SF2.F2_EST + F2_GNRDIF
			AND A.D_E_L_E_T_ = ''
			), '')

			+
			ISNULL(
			(
			SELECT 				
		CASE WHEN STATUS = 1
			THEN 'Aguardando transmissão'
			WHEN STATUS = 2
			THEN 'Transmitido'
			WHEN STATUS = 3
			THEN 'Falha no Schema'
			WHEN STATUS = 4
			THEN 'Rejeição da SEFAZ'
			WHEN STATUS = 5
			THEN 'Autorizada'
		ELSE '' END
			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK )
			WHERE ID_ENT = %Exp:oObjFat:cIdEnt%
			AND ID = SF2.F2_EST + F2_GNRFECP
			AND A.D_E_L_E_T_ = ''
			), '')
			) END STATUS_GNRE,

			(
		CASE WHEN F2_CLIENTE <> '010064' THEN 'N/A'
				WHEN EXISTS
				(
					SELECT 1
					FROM SC9070 SC9
					JOIN SC5070 SC57 ON (SC57.C5_FILIAL = SC9.C9_FILIAL AND SC57.C5_NUM = SC9.C9_PEDIDO AND SC57.D_E_L_E_T_ = '')
					WHERE SC9.C9_FILIAL		= '01'
					AND SC9.C9_NFISCAL		<> ''
					AND SC9.C9_AGREG		= %EXP:SELF:cCarga%
					AND SC57.C5_YPEDORI		= SC5.C5_NUM
					AND SC9.D_E_L_E_T_ = '' 

				) THEN 'Finalizado'

				WHEN EXISTS 
				(
					SELECT 1
					FROM SF1070 SF1
					WHERE SF1.F1_FILIAL		= SF2.F2_FILIAL
					AND SF1.F1_DOC		= SF2.F2_DOC
					AND SF1.F1_SERIE	= SF2.F2_SERIE
					AND SF1.F1_FORNECE	= '000534'
					AND SF1.F1_LOJA		= '01'
					AND SF1.F1_TIPO		= 'N'
					AND SF1.D_E_L_E_T_ = ''
				) THEN 'Entrada concluida'
		ELSE 'Aguardando entrada' END
			) STATUS_LM

			FROM
			%table:ZZV% ZZV
			JOIN      %table:ZZW% ZZW ON (
			ZZW_FILIAL         = ZZV_FILIAL
			AND ZZW_CARGA      = ZZV_CARGA
			)
			JOIN      %table:SC9% SC9 ON (
			C9_FILIAL          = ZZW_FILIAL
			AND C9_PEDIDO      = ZZW_PEDIDO
			AND C9_ITEM        = ZZW_ITEM
			AND C9_SEQUEN      = ZZW_SEQUEN
			)             
			JOIN      %table:SB1% SB1 ON (
			B1_FILIAL          = %EXP:xFilial("SB1")%
			AND B1_COD         = C9_PRODUTO
			)
			JOIN      %table:SC5% SC5 ON (
			SC5.C5_FILIAL          = ZZW_FILIAL
			AND SC5.C5_NUM         = ZZW_PEDIDO
			)
			JOIN      %table:SA1% SA1A ON (
			SA1A.A1_FILIAL     = ' '
			AND SA1A.A1_COD    = SC5.C5_CLIENTE
			AND SA1A.A1_LOJA   = SC5.C5_LOJACLI
			)
			LEFT JOIN      %table:SA1% SA1B ON (
			SA1B.A1_FILIAL     = ' '
			AND SA1B.A1_COD    = SC5.C5_YCLIORI
			AND SA1B.A1_LOJA   = SC5.C5_YLOJORI
			AND SA1B.D_E_L_E_T_ = ''
			)
			LEFT JOIN %table:SF2% SF2 ON (
			F2_FILIAL          = %EXP:xFilial("SF2")%
			AND F2_DOC         = SC9.C9_NFISCAL
			AND F2_SERIE       = SC9.C9_SERIENF
			AND F2_CLIENTE     = SC9.C9_CLIENTE
			AND F2_LOJA        = SC9.C9_LOJA
			AND SF2.D_E_L_E_T_ = ''
			)
			LEFT JOIN %table:SA4% SA4 ON (
			A4_FILIAL          = %EXP:xFilial("SA4")%
			AND A4_COD	       = F2_TRANSP
			AND SA4.D_E_L_E_T_ = ''
			)
			WHERE
			ZZV_CARGA          = %EXP:SELF:cCarga%
			AND ZZV.D_E_L_E_T_ = ''
			AND ZZW.D_E_L_E_T_ = ''
			AND SC9.D_E_L_E_T_ = ''
			AND SB1.D_E_L_E_T_ = ''
			AND SC5.D_E_L_E_T_ = ''
			AND SA1A.D_E_L_E_T_ = ''

		EndSql

		(cAliasTmp)->(DbGoTop())

		While !(cAliasTmp)->(Eof())

			aAux := {}

			AAdd(aAux, LoadBitmap(GetResources(), "EDIT1-20" ))
			AAdd(aAux, (cAliasTmp)->C9_AGREG )
			AAdd(aAux, (cAliasTmp)->ZZW_PEDIDO )
			AAdd(aAux, (cAliasTmp)->ZZW_ITEM )
			AAdd(aAux, (cAliasTmp)->C9_NFISCAL )
			AAdd(aAux, (cAliasTmp)->F2_EMISSAO )

			AAdd(aAux, (cAliasTmp)->C9_SERIENF )
			AAdd(aAux, (cAliasTmp)->B1_COD )
			AAdd(aAux, (cAliasTmp)->C9_QTDLIB )
			AAdd(aAux, (cAliasTmp)->PESO )

			AAdd(aAux, (cAliasTmp)->A1_CODA )
			AAdd(aAux, (cAliasTmp)->A1_LOJAA )
			AAdd(aAux, (cAliasTmp)->A1_NREDUZA )
			AAdd(aAux, (cAliasTmp)->A1_ESTA)

			AAdd(aAux, (cAliasTmp)->C5_YCLIORI )
			AAdd(aAux, (cAliasTmp)->C5_YLOJORI )
			AAdd(aAux, If(Empty((cAliasTmp)->C5_YCLIORI), (cAliasTmp)->A1_NREDUZA, (cAliasTmp)->A1_NREDUZB))
			AAdd(aAux, If(Empty((cAliasTmp)->C5_YCLIORI), (cAliasTmp)->A1_ESTA, (cAliasTmp)->A1_ESTB))
			AAdd(aAux, (cAliasTmp)->C5_MENPAD )
			AAdd(aAux, (cAliasTmp)->C5_MENNOTA )
			AAdd(aAux, (cAliasTmp)->C5_YVLFRST)

			AAdd(::aPedidos, aAux)

			If !Empty((cAliasTmp)->C9_NFISCAL)

				aAux := {}

				nPos := aScan(::aDocumentos, { |x| x[D_EMPFIL] + x[D_DOC] + x[D_SERIE] == cEmpAnt + cFilAnt + (cAliasTmp)->C9_NFISCAL + (cAliasTmp)->C9_SERIENF })

				If nPos == 0

					AAdd(aAux, ::GetBmpDoc(1))
					AAdd(aAux, cEmpAnt + cFilAnt )
					AAdd(aAux, (cAliasTmp)->C9_AGREG )
					AAdd(aAux, (cAliasTmp)->C9_NFISCAL )
					AAdd(aAux, (cAliasTmp)->C9_SERIENF )

					AAdd(aAux, (cAliasTmp)->A1_CODA )
					AAdd(aAux, (cAliasTmp)->A1_LOJAA )
					AAdd(aAux, (cAliasTmp)->A1_NREDUZA )
					AAdd(aAux, Transform((cAliasTmp)->A1_CGC, "@R 999.999.999/9999-99"))
					AAdd(aAux, (cAliasTmp)->A1_ESTA)
					AAdd(aAux, (cAliasTmp)->F2_TRANSP)
					AAdd(aAux, Transform((cAliasTmp)->A4_CGC, "@R 999.999.999/9999-99"))
					AAdd(aAux, (cAliasTmp)->A4_EST)
					AAdd(aAux, (cAliasTmp)->F2_VEICUL1)

					AAdd(aAux, (cAliasTmp)->F2_SERMDF)
					AAdd(aAux, (cAliasTmp)->F2_NUMMDF)

					AAdd(aAux, (cAliasTmp)->STATUS_NFE)
					AAdd(aAux, (cAliasTmp)->STATUS_LM)
					AAdd(aAux, (cAliasTmp)->STATUS_GNRE)
					AAdd(aAux, (cAliasTmp)->STATUS_MDFE)

					AAdd(aAux, (cAliasTmp)->GUIA )
					AAdd(aAux, .F. )

					aAdd(::aDocumentos, aAux)

				EndIf

			EndIf

			(cAliasTmp)->(DbSkip())

		EndDo

		(cAliasTmp)->(DbCloseArea())

		For nW := 1 To Len(::aPedidos)

			//If oObjEmp:SeekCli(::aPedidos[nW][P_CLIENTE], ::aPedidos[nW][P_LOJA])
			//nPos := aScan(aNotas, {|x| x[7] + x[8] + x[9] == ::aPedidos[nW][P_CARGA] + ::aPedidos[nW][P_CLIENTE], ::aPedidos[nW][P_LOJA] })
			//If nPos == 0

			If ( AllTrim(::aPedidos[nW][P_CLIENTE]) == "010064" .And. !Empty(::aPedidos[nW][P_NFISCAL]) )

				aNotas := ::GetDocCarDest(oObjEmp:cCodEmp, oObjEmp:cCodFil, oObjEmp:cUf,::aPedidos[nW][P_CARGA], ::aPedidos[nW][P_CLIENTE], ::aPedidos[nW][P_LOJA], ::aPedidos[nW][P_EMISSAONF])

				For nX := 1 To Len(aNotas)

					nPos := aScan(::aDocumentos, { |x| x[D_EMPFIL] + x[D_DOC] + x[D_SERIE]  == oObjEmp:cCodEmp + oObjEmp:cCodFil + aNotas[nX][N_DOC] + aNotas[nX][N_SERIE] })

					If nPos == 0

						aAux := {}

						AAdd(aAux, ::GetBmpDoc(1))
						AAdd(aAux, oObjEmp:cCodEmp + oObjEmp:cCodFil )
						AAdd(aAux, ::aPedidos[nW][C_CARGA]  )
						AAdd(aAux, aNotas[nX][N_DOC] )
						AAdd(aAux, aNotas[nX][N_SERIE] )
						AAdd(aAux, aNotas[nX][N_CLIENTE] )
						AAdd(aAux, aNotas[nX][N_LOJA] )
						AAdd(aAux, aNotas[nX][N_NREDUZ] )
						AAdd(aAux, Transform(aNotas[nX][N_CNPJ], "@R 999.999.999/9999-99"))
						AAdd(aAux, aNotas[nX][N_EST] )

						AAdd(aAux, aNotas[nX][N_TRANSP] )
						AAdd(aAux, Transform(aNotas[nX][N_CNPJTRANSP], "@R 999.999.999/9999-99"))
						AAdd(aAux, aNotas[nX][N_UFTRANSP] )

						AAdd(aAux, aNotas[nX][N_VEIC] )
						AAdd(aAux, aNotas[nX][N_SERMDF] )
						AAdd(aAux, aNotas[nX][N_NUMMDF] )

						AAdd(aAux, aNotas[nX][N_STATUS_NFE] )
						AAdd(aAux, aNotas[nX][N_STATUS_LM] )
						AAdd(aAux, aNotas[nX][N_STATUS_GNRE] )
						AAdd(aAux, aNotas[nX][N_STATUS_MDFE] )

						AAdd(aAux, aNotas[nX][N_GUIA] )
						AAdd(aAux, .F. )

						aAdd(::aDocumentos, aAux)

					EndIf

				Next nX

			EndIf

			//EndIf

		Next nW

	EndIf

	::AtuLegDoc(lGrid)

	If lGrid

		::oBrwPedido:SetArray(::aPedidos)
		::oBrwPedido:Refresh()

		::oBrwDocumento:SetArray(::aDocumentos)
		::oBrwDocumento:Refresh()

	EndIf

Return()

Method CargaOk(cCarga, lAllReady, lNfe, lMdfe, lGnre, lLMOk) Class TFaturamentoMonitor

	Default cCarga		:= ""
	Default lAllReady	:= .F.
	Default lNfe		:= .F.
	Default lMdfe		:= .F.
	Default lGnre		:= .F.
	Default lLMOk		:= .F.

	::cCarga := cCarga

	//Carga que não foi faturada pelo AUTOMATICO - sempre retorna Falso
	ZZV->(DbSetOrder(1))
	If ZZV->(DbSeek(xFilial("ZZV") + ::cCarga)) .And. Empty(ZZV->ZZV_FIMP)

		lAllReady := .F.
		Return(lAllReady)

	EndIf


	::GetPedidos(.F.)

	If Len(::aDocumentos) > 0

		lAllReady 	:= aScan(::aDocumentos, { |x| !x[Len(::aDocumentos[1])] }) == 0

		lGnre		:= aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_GNRE])) == "AUTORIZADA" }) > 0 .Or.;
			aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_GNRE])) == "AUTORIZADAAUTORIZADA" }) > 0 .Or.;
			aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_GNRE])) == "AUTORIZADAAUTORIZADAAUTORIZADA" }) > 0

		lNfe		:= aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_NFE]))  == "AUTORIZADA" }) > 0

		lMdfe		:= aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_MDFE])) == "AUTORIZADA" }) > 0

		lLMOk		:= aScan(::aDocumentos, { |x| UPPER(AllTrim(x[D_STATUS_LM])) == "" }) <= 0

	Else

		lAllReady := .F.

	EndIf

Return(lAllReady)

Method GetTipoPedido(cEmp, cFil, cDoc, cSerie, cCliente, cLoja) Class TFaturamentoMonitor

	Local cSql := ""
	Local cTpPed := ""
	Local cAliasTrab := ""

	cAliasTrab := GetNextAlias()

	cSql := " SELECT F2_YSUBTP "
	cSql += " FROM " + RetFullName("SF2", cEmp) + " SF2 ( NOLOCK ) "
	cSql += " WHERE SF2.F2_FILIAL	= " + ValToSql(cFil)
	cSql += " AND SF2.F2_DOC	 	= " + ValToSql(cDoc)
	cSql += " AND SF2.F2_SERIE 		= " + ValToSql(cSerie)
	cSql += " AND SF2.F2_CLIENTE 	= " + ValToSql(cCliente)
	cSql += " AND SF2.F2_LOJA 		= " + ValToSql(cLoja)
	cSql += " AND SF2.D_E_L_E_T_ 	= '' "

	TcQuery cSql New ALIAS (cAliasTrab)

	cTpPed := (cAliasTrab)->F2_YSUBTP

	(cAliasTrab)->(DbCloseArea())

Return(cTpPed)

Method IsGnrePaga(cEmp, cFil, cDoc, cSerie, cCliente, cLoja) Class TFaturamentoMonitor

	Local lRet := .T.
	Local cSql := ""
	Local cAliasTrab := ""

	If Upper(AllTrim(GetSrvProfString("DbAlias", ""))) <> "PRODUCAO"

		Return(.T.)

	EndIf

	cAliasTrab := GetNextAlias()

	cSql := "SELECT COUNT(*) TOT "
	cSql += "FROM " + RetFullName("ZK4", cEmp) + " ZK4 ( NOLOCK ) "
	cSql += "WHERE ZK4.ZK4_FILIAL = '' "
	cSql += "AND ZK4.ZK4_EMP = " + ValToSql(cEmp)
	cSql += "AND ZK4.ZK4_FIL = " + ValToSql(cFil)
	cSql += "AND EXISTS "
	cSql += "( "
	cSql += "	SELECT NULL "
	cSql += "	FROM " + RetFullName("SE2", cEmp) + " SE2 ( NOLOCK ) "
	cSql += "	WHERE EXISTS  "
	cSql += "	( "
	cSql += "		SELECT NULL "
	cSql += "		FROM " + RetFullName("SF6", cEmp) + " SF6 ( NOLOCK ) "
	cSql += "		WHERE SF6.F6_FILIAL = '" + cFil + "'"
	cSql += "		AND SF6.F6_DOC	 	= " + ValToSql(cDoc)
	cSql += "		AND SF6.F6_SERIE 	= " + ValToSql(cSerie)
	cSql += "		AND SF6.F6_CLIFOR 	= " + ValToSql(cCliente)
	cSql += "		AND SF6.F6_LOJA 	= " + ValToSql(cLoja)
	cSql += "		AND SF6.F6_NUMERO 	= SE2.E2_PREFIXO + SE2.E2_NUM "
	cSql += "		AND SF6.D_E_L_E_T_ 	= '' "
	cSql += "	) "
	cSql += "	AND SE2.D_E_L_E_T_ = '' "
	cSql += "	AND ( "
	cSql += "	    	(ZK4.ZK4_IDCNAB = SE2.E2_IDCNAB AND SE2.E2_IDCNAB <> '') "
	cSql += "	   		 OR  "
	cSql += "			(ZK4.ZK4_CODBAR = SE2.E2_CODBAR AND SE2.E2_CODBAR <> '') "
	cSql += "		) "
	cSql += "	AND ZK4.ZK4_CHVAUT NOT LIKE '%REJEI%' "
	cSql += ") "
	cSql += "AND ZK4.D_E_L_E_T_ = '' "

	TcQuery cSql New Alias (cAliasTrab)

	lRet := (cAliasTrab)->TOT > 0

	(cAliasTrab)->(DbCloseArea())

Return(lRet)

Method SetPrintOk(cCarga, cFImp) Class TFaturamentoMonitor

	Local lRet := .F.

	Default cCarga := ""
	Default cFImp := "2"

	::cCarga := cCarga

	DBSelectArea("ZZV")
	ZZV->(DbSetOrder(1))

	If ZZV->(DbSeek(xFilial("ZZV") + ::cCarga))

		RecLock("ZZV", .F.)
		ZZV->ZZV_FIMP := cFImp
		ZZV->(MSUnLock())

		lRet := .T.

	EndIf

Return(lRet)

Method Print() Class TFaturamentoMonitor

	Local lRet := .T.
	Local cCarga := ""

	cCarga := ::GetCarga()

	If Len(::aDocumentos) > 0

		If aScan(::aDocumentos, { |x| !x[Len(::aDocumentos[1])] }) == 0

			If MsgYesNo("Confirma comando para impressão da carga " + cCarga + "? ")

				::SetPrintOk(cCarga, "A")

				StartJob("U_BACP0017", GetEnvServer(), .F., cCarga)

				MsgInfo("Comando enviado. Aguarde impressão!")

			EndIf

		Else

			MsgStop("O processo ainda não foi concluído!")

		EndIf

	EndIf

Return(lRet)

Method AtuLegDoc(lGrid) Class TFaturamentoMonitor

	Local nLeg := 1
	Local nW := 0
	Local oObjGNRe	:= Nil
	Local oObjMDFe	:= Nil

	Default lGrid := .T.

	//::oBrwDocumento:SetArray(::aCargas)

	For nW := 1 To Len(::aDocumentos)

		oObjGNRe	:= TGnreTransmissao():New(.T.)
		oObjMDFe	:= TMDFeAutomatico():New(.T.)

		If Empty(::aDocumentos[nW][D_STATUS_NFE])

			::aDocumentos[nW][D_STATUS_NFE] := "Aguardando envio"

		EndIf

		If Empty(::aDocumentos[nW][D_STATUS_GNRE])

			If oObjGNRe:IsUFSubTrib(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_EST])

				::aDocumentos[nW][D_STATUS_GNRE] := "N/A"

			Else

				If oObjGNRe:IsUFWS(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_EST])

					If Empty(::aDocumentos[nW][D_GUIA])

						::aDocumentos[nW][D_STATUS_GNRE] := "N/A"

					Else


						::aDocumentos[nW][D_STATUS_GNRE] := "Aguardando envio"

					EndIf

				Else

					DBSelectArea("SA1")
					SA1->(DBSetOrder(1))

					SA1->(DBSeek(xFilial("SA1") + ::aDocumentos[nW][D_CLIENTE] + ::aDocumentos[nW][D_LOJA]))

					If Empty(SA1->A1_YREGESP)

						If ::IsGnrePaga(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_DOC], ::aDocumentos[nW][D_SERIE], ::aDocumentos[nW][D_CLIENTE], ::aDocumentos[nW][D_LOJA])

							::aDocumentos[nW][D_STATUS_GNRE] := "GNR-e manual"

						Else

							If ( ::GetTipoPedido(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_DOC], ::aDocumentos[nW][D_SERIE], ::aDocumentos[nW][D_CLIENTE], ::aDocumentos[nW][D_LOJA]) <> "A" .And. SA1->A1_TIPO $ "R|S" .And. SA1->A1_EST $ "SP" ) .Or. ( AllTrim(SF2->F2_CLIENTE) $ "008960" )

								::aDocumentos[nW][D_STATUS_GNRE] := "Aguardando pagamento"

							Else

								::aDocumentos[nW][D_STATUS_GNRE] := "N/A"

							EndIf

						EndIf

					Else

						::aDocumentos[nW][D_STATUS_GNRE] := "N/A"

					EndIf

				EndIf

			EndIf

		ElseIf AllTrim(::aDocumentos[nW][D_STATUS_GNRE]) <> "N/A"

			If !::IsGnrePaga(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_DOC], ::aDocumentos[nW][D_SERIE], ::aDocumentos[nW][D_CLIENTE], ::aDocumentos[nW][D_LOJA])

				::aDocumentos[nW][D_STATUS_GNRE] := "Aguardando pagamento"

			EndIf

		EndIf

		If Empty(::aDocumentos[nW][D_STATUS_MDFE]) .Or. "FALHA NO SCHEMA" $ UPPER(AllTrim(::aDocumentos[nW][D_STATUS_MDFE]))

			DBSelectArea("SA1")
			SA1->(DBSetOrder(1))

			SA1->(DBSeek(xFilial("SA1") + ::aDocumentos[nW][D_CLIENTE] + ::aDocumentos[nW][D_LOJA]))
			
			If oObjMDFe:IsValidMDFe(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_EST], ::aDocumentos[nW][D_CNPJ], ::aDocumentos[nW][D_UFTRANSP], ::aDocumentos[nW][D_CNPJTRANSP], SA1->A1_COD_MUN)

				If oObjMDFe:IsFaltaRota(SubStr(::aDocumentos[nW][D_EMPFIL], 1, 2), SubStr(::aDocumentos[nW][D_EMPFIL], 3, 2), ::aDocumentos[nW][D_EST])

					::aDocumentos[nW][D_STATUS_MDFE] := "Falta cadastro rota MDF-e"

				Else

					dbSelectArea("DA3")
					dbSetOrder(1) // DA3_FILIAL, DA3_COD, R_E_C_N_O_, D_E_L_E_T_

					dbSelectArea("DUT")
					dbSetOrder(1) // DUT_FILIAL, DUT_TIPVEI, R_E_C_N_O_, D_E_L_E_T_

					If DA3->(MsSeek(xFilial("DA3") + ::aDocumentos[nW][D_VEIC]))

						If DUT->( msSeek( xFilial( "DUT" ) + DA3->DA3_TIPVEI ) )
							
							If Empty(::aDocumentos[nW][D_STATUS_MDFE])

								::aDocumentos[nW][D_STATUS_MDFE] := "Aguardando envio"

								::aDocumentos[nW][D_SERMDF] := "Aguardando envio"

								::aDocumentos[nW][D_NUMMDF] := "Aguardando envio"

							EndIf

						Else

							::aDocumentos[nW][D_STATUS_MDFE] := "Cadastro tipo veiculo não encontrado"

							::aDocumentos[nW][D_SERMDF] := "Cadastro tipo veiculo não encontrado"

							::aDocumentos[nW][D_NUMMDF] := "Cadastro tipo veiculo não encontrado"

						EndIf

					Else

						::aDocumentos[nW][D_STATUS_MDFE] := "Cadastro veiculo não encontrado"

						::aDocumentos[nW][D_SERMDF] := "Cadastro veiculo não encontrado"

						::aDocumentos[nW][D_NUMMDF] := "Cadastro veiculo não encontrado"

					EndIf

				EndIf

			Else

				::aDocumentos[nW][D_STATUS_MDFE] := "N/A"

				::aDocumentos[nW][D_SERMDF] := "N/A"

				::aDocumentos[nW][D_NUMMDF] := "N/A"

			EndIf

		EndIf

		If Empty(::aDocumentos[nW][D_STATUS_LM])

			If ::aDocumentos[nW][D_CLIENTE] == "010064"

				::aDocumentos[nW][D_STATUS_LM] := ""

			Else

				::aDocumentos[nW][D_STATUS_LM] := "N/A"

			EndIf

		EndIf

		If ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_NFE]))  == "AUTORIZADA" .And.;
				( ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_GNRE])) == "AUTORIZADA" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_GNRE])) == "AUTORIZADAAUTORIZADA" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_GNRE])) == "AUTORIZADAAUTORIZADAAUTORIZADA" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_GNRE])) == "GNR-E MANUAL" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_GNRE])) == "N/A" ) .And.;
				( ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_MDFE])) == "AUTORIZADA" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_MDFE])) == "N/A" ) .And.;
				( ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_LM])) 	== "FINALIZADO" .Or.;
				ALLTRIM(UPPER(::aDocumentos[nW][D_STATUS_LM])) 	== "N/A" )

			::aDocumentos[nW][D_EDIT_BITMAP] := ::GetBmpDoc(1)

			::aDocumentos[nW][Len(::aDocumentos[nW])] := .T.

		Else

			::aDocumentos[nW][D_EDIT_BITMAP] := ::GetBmpDoc(2)

			::aDocumentos[nW][Len(::aDocumentos[nW])] := .F.

		EndIf

	NExt nW

	If lGrid

		::oBrwDocumento:Refresh()

	EndIf

Return()

/*/{Protheus.doc} TelaPedido
@description Chama a tabela de carga (ZZV) em modo de alteração para alguns campos que influeciam no faturamento
@author Fernando Rocha
@since 12/08/2019
@version 1.0
@type function
/*/
Method TelaPedido() Class TFaturamentoMonitor

	Local lRet		 := .T.
	Local aArea		 := SC5->(GetArea())
	Local nOpcao	 := 0

	Local aFields := {"C5_NUM","C5_YSUBTP","C5_CLIENTE","C5_CONDPG","C5_TRANSP","C5_MENPAD","C5_MENNOTA","NOUSER", "C5_YVLFRST"}
	Local aAlterFields := {"C5_MENPAD","C5_MENNOTA", "C5_YVLFRST"}

	Private aButtons := {}
	Private cCadastro := "Alteração de Dados do Pedido"

	SC5->(DbSetOrder(1))

	If SC5->(DbSeek(xFilial("SC5")+::GetColPed(P_PEDIDO)))

		nOpcao := AxAltera("SC5",SC5->(Recno()),4,aFields,aAlterFields,,,,"",,aButtons,,,,.T.,,,,,)

		If nOpcao == 1

			MsgInfo("Alteração realizada com sucesso!")

			::GetPedidos()

		EndIf

	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} GetBmpCarga
@description Chama a tabela de carga (ZZV) em modo de alteração para alguns campos que influeciam no faturamento
@author Fernando Rocha
@since 12/08/2019
@version 1.0
@type function
/*/
Method GetBmpCarga(_nSit) Class TFaturamentoMonitor

	Local uCor

	If _nSit == 1

		uCor := LoadBitmap(GetResources(), "BR_VERDE" ) // Em aberto

	ElseIf _nSit == 2

		uCor := LoadBitmap(GetResources(), "BR_AMARELO" ) // Faltando informacao

	ElseIf _nSit == 3

		uCor := LoadBitmap(GetResources(), "BR_VERMELHO" ) // Faturado, aguardando impressao

	ElseIf _nSit == 4

		uCor := LoadBitmap(GetResources(), "BR_PRETO" ) // Impresso

	EndIf

Return(uCor)

Method GetBmpDoc(_nSit) Class TFaturamentoMonitor

	Local uCor

	If _nSit == 1

		uCor := LoadBitmap(GetResources(), "BR_VERDE" )

	ElseIf _nSit == 2

		uCor := LoadBitmap(GetResources(), "BR_AMARELO" )

	EndIf

Return(uCor)

/*/{Protheus.doc} GetBmpCarga
@description Chama o processo de faturamento referente a CARGA posicionada
@author Fernando Rocha
@since 12/08/2019
@version 1.0
@type function
/*/
Method Faturar() Class TFaturamentoMonitor

	Local _aAreaZZV := ZZV->(GetArea())
	Local oObjFat := ::oObjFat
	Local _oBiaEnv	:=	tBiaAmbiente():New()
	Public _XCRGATFAT := .T.

	If _oBiaEnv:lErro
		MsgInfo("FAVOR COMUNICAR À TI! " + _oBiaEnv:cErro)
		Return .F.
	EndIf
	//__oSemaforo				:=	tBiaSemaforo():New()
	//__oSemaforo:cGrupo		:=	"FATURAMENTO"
	//__oSemaforo:lShowMsg	:= .T. //Nao Exibir mensagem de LOCK
	//If __oSemaforo:GeraSemaforo("FAT:Faturamento Automatico")

		::cCarga := ::GetCarga()

		ZZV->(DbSetOrder(1))

		If ZZV->(DbSeek(xFilial("ZZV")+::cCarga))

			::SetKeys(.T.)

			If Empty(ZZV->ZZV_PL_UF) .And. !Empty(ZZV->ZZV_PLACA)

				Alert("UF do veículo não preenchida!")

				_XCRGATFAT := .F.

				Return(.F.)

			EndIf

			__nVld := oObjFat:VldCarga(ZZV->ZZV_CARGA)

			If ( __nVld == 0 .Or. __nVld == 2 )

				If MsgNoYes("Tem certeza que deseja iniciar o faturamento da CARGA: "+ZZV->ZZV_CARGA,"TFaturamentoMonitor")

					U_GravaPZ2(ZZV->(RecNo()),"ZZV",ZZV->ZZV_CARGA,"FATAUT",AllTrim(FunName()),"FAT", CUSERNAME)

					U_BACP0010(ZZV->ZZV_CARGA, cEmpAnt)

					::cCarga := ""

					::Get()

				EndIf

			EndIf

			::SetKeys()

		EndIf

		_XCRGATFAT := .F. 	// Estava acontecendo de o usuario abrir o monitor, faturava, essa variavel ficar true,
		// e abrir a tela de documento de saida para faturar e como continuava true, entendia que estava em job

		//Liberar semaforo Faturamento
		//__oSemaforo:LiberaSemaforo()

	//EndIf

	RestArea(_aAreaZZV)

Return()

Method GetDocCarDest(cEmp, cFil, cUf, cCarga, cCodCli, cCodLoja, cEmissaoNF) Class TFaturamentoMonitor

	Local cAliasTmp	:= GetNextAlias()
	Local aNotas	:= {}
	Local cSQL		:= ""
	Local cEmpBck	:= cEmpAnt
	Local cFilBck	:= cFilAnt
	Local aAreaSM0	:= SM0->(GetArea())
	Local oObjFat	:= Nil

	cEmpAnt		:= cEmp
	cFilAnt		:= cFil

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt + cFilAnt))

	oObjFat		:= TFaturamentoAutomatico():New()

	cEmpAnt		:= cEmpBck
	cFilAnt		:= cFilBck

	RestArea(aAreaSM0)

	cSQL := " SELECT DISTINCT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_NFICMST + F2_GNRDIF + F2_GNRFECP GUIA, "
	cSQL += " A1_NREDUZ, A1_CGC, A4_COD, A4_CGC, A4_EST, F2_EMISSAO, F2_EST, F2_VEICUL1, F2_SERMDF, F2_NUMMDF, "

	cSQL += " ISNULL(( "
	cSQL += " SELECT "
	cSQL += " 	CASE WHEN STATUS = 1 "
	cSQL += " 	THEN 'Recebida' "
	cSQL += " 	WHEN STATUS = 2 "
	cSQL += " 	THEN 'Assinada' "
	cSQL += " 	WHEN STATUS = 3 "
	cSQL += " 	THEN 'Falha no Schema' "
	cSQL += " 	WHEN STATUS = 4 "
	cSQL += " 	THEN 'Transmitida' "
	cSQL += " 	WHEN STATUS = 5 "
	cSQL += " 	THEN 'NF Com problemas' "
	cSQL += " 	WHEN STATUS = 6 "
	cSQL += " 	THEN 'Autorizada' "
	cSQL += " 	ELSE '' END "
	cSQL += " FROM [DADOSADV].dbo.SPED050 A ( NOLOCK ) "
	cSQL += " WHERE ID_ENT = " + ValToSql(oObjFat:cIdEnt)
	cSQL += " AND NFE_ID = SF2.F2_SERIE + SF2.F2_DOC "
	cSQL += " AND A.D_E_L_E_T_ = '' "
	cSQL += " ), '') STATUS_NFE, "

	cSQL += " '' STATUS_LM, "

	cSQL += " ( "
	cSQL += " 	ISNULL(( "
	cSQL += " 	SELECT 				 "
	cSQL += " 		CASE WHEN STATUS = 1 "
	cSQL += " 		THEN 'Recebida' "
	cSQL += " 		WHEN STATUS = 2 "
	cSQL += " 		THEN 'Assinada' "
	cSQL += " 		WHEN STATUS = 3 "
	cSQL += " 		THEN 'Falha no Schema' "
	cSQL += " 		WHEN STATUS = 4 "
	cSQL += " 		THEN 'Transmitida' "
	cSQL += " 		WHEN STATUS = 5 "
	cSQL += " 		THEN 'NF Com problemas' "
	cSQL += " 		WHEN STATUS = 6 "
	cSQL += " 		THEN 'Autorizada' "
	cSQL += " 		WHEN STATUS = 8 "
	cSQL += " 		THEN 'MDFe Encerrado' "
	cSQL += " 		ELSE '' END "
	cSQL += " 	FROM [DADOSADV].dbo.SPED050 A ( NOLOCK ) "
	cSQL += " 	WHERE ID_ENT = " + ValToSql(oObjFat:cIdEnt)
	cSQL += " 	AND NFE_ID = SF2.F2_SERMDF + SF2.F2_NUMMDF "
	cSQL += " 	AND A.D_E_L_E_T_ = ''	 "
	cSQL += " 	), '') "
	cSQL += " )  STATUS_MDFE, "

	cSQL += "CASE WHEN SC5.C5_YTPCRED = '5' AND SA1.A1_EST = 'SP' THEN 'N/A' ELSE (
	cSQL += " 	ISNULL( "
	cSQL += " 		( "
	cSQL += " 			SELECT 				 "
	cSQL += " 				CASE WHEN STATUS = 1 "
	cSQL += " 				THEN 'Aguardando transmissão' "
	cSQL += " 				WHEN STATUS = 2 "
	cSQL += " 				THEN 'Transmitido' "
	cSQL += " 				WHEN STATUS = 3 "
	cSQL += " 				THEN 'Falha no Schema' "
	cSQL += " 				WHEN STATUS = 4 "
	cSQL += " 				THEN 'Rejeição da SEFAZ' "
	cSQL += " 				WHEN STATUS = 5 "
	cSQL += " 				THEN 'Autorizada' "
	cSQL += " 				ELSE '' END "
	cSQL += " 			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK ) "
	cSQL += " 			WHERE ID_ENT = " + ValToSql(oObjFat:cIdEnt)
	cSQL += " 			AND ID = SF2.F2_EST + SF2.F2_NFICMST "
	cSQL += " 			AND A.D_E_L_E_T_ = '' "
	cSQL += " 		), '' ) "

	cSQL += " 		+ "

	cSQL += " 	ISNULL( "
	cSQL += " 		( "
	cSQL += " 			SELECT 				 "
	cSQL += " 				CASE WHEN STATUS = 1 "
	cSQL += " 				THEN 'Aguardando transmissão' "
	cSQL += " 				WHEN STATUS = 2 "
	cSQL += " 				THEN 'Transmitido' "
	cSQL += " 				WHEN STATUS = 3 "
	cSQL += " 				THEN 'Falha no Schema' "
	cSQL += " 				WHEN STATUS = 4 "
	cSQL += " 				THEN 'Rejeição da SEFAZ' "
	cSQL += " 				WHEN STATUS = 5 "
	cSQL += " 				THEN 'Autorizada' "
	cSQL += " 				ELSE '' END "
	cSQL += " 			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK ) "
	cSQL += " 			WHERE ID_ENT = " + ValToSql(oObjFat:cIdEnt)
	cSQL += " 			AND ID = SF2.F2_EST + SF2.F2_GNRDIF "
	cSQL += " 			AND A.D_E_L_E_T_ = '' "
	cSQL += " 		), '' ) "

	cSQL += " 		+ "

	cSQL += " 	ISNULL( "
	cSQL += " 		( "
	cSQL += " 			SELECT 				 "
	cSQL += " 				CASE WHEN STATUS = 1 "
	cSQL += " 				THEN 'Aguardando transmissão' "
	cSQL += " 				WHEN STATUS = 2 "
	cSQL += " 				THEN 'Transmitido' "
	cSQL += " 				WHEN STATUS = 3 "
	cSQL += " 				THEN 'Falha no Schema' "
	cSQL += " 				WHEN STATUS = 4 "
	cSQL += " 				THEN 'Rejeição da SEFAZ' "
	cSQL += " 				WHEN STATUS = 5 "
	cSQL += " 				THEN 'Autorizada' "
	cSQL += " 				ELSE '' END "
	cSQL += " 			FROM [DADOSADV].dbo.SPED201 A ( NOLOCK ) "
	cSQL += " 			WHERE ID_ENT = " + ValToSql(oObjFat:cIdEnt)
	cSQL += " 			AND ID = SF2.F2_EST + SF2.F2_GNRFECP "
	cSQL += " 			AND A.D_E_L_E_T_ = '' "
	cSQL += " 		), '' ) "

	cSQL += " ) END STATUS_GNRE "

	cSQL += " FROM " + RetFullName("SF2", cEmp) + " SF2 ( NOLOCK ) "

	cSQL += " JOIN " + RetFullName("SD2", cEmp) + " SD2 ( NOLOCK ) ON "
	cSQL += " ( "
	cSQL += " 	D2_FILIAL 			= F2_FILIAL "
	cSQL += " 	AND D2_DOC 			= F2_DOC "
	cSQL += " 	AND D2_SERIE 		= F2_SERIE "
	cSQL += " 	AND D2_CLIENTE 		= F2_CLIENTE "
	cSQL += " 	AND D2_LOJA 		= F2_LOJA "
	cSQL += " 	AND SD2.D_E_L_E_T_ 	= '' "
	cSQL += " ) "

	cSQL += " LEFT JOIN " + RetFullName("SA4", cEmp) + " SA4 ( NOLOCK ) ON "
	cSQL += " ( "
	cSQL += "   A4_FILIAL           = " + ValToSql(xFilial("SA4"))
	cSQL += "   AND A4_COD	        = F2_TRANSP "
	cSQL += " 	AND SA4.D_E_L_E_T_ 	= '' "
	cSQL += " ) "

	cSQL += " JOIN " + RetFullName("SC9", cEmp) + " SC9 (NOLOCK) ON "
	cSQL += " (
	cSQL += "	C9_FILIAL          	= F2_FILIAL
	cSQL += "	AND C9_NFISCAL     	= F2_DOC
	cSQL += "	AND C9_SERIENF     	= F2_SERIE
	cSQL += "	AND C9_CLIENTE     	= F2_CLIENTE
	cSQL += "	AND C9_LOJA        	= F2_LOJA
	cSQL += "	AND SC9.D_E_L_E_T_ 	= ''
	cSQL += " )

	cSQL += " JOIN " + RetFullName("SA1", cEmp) + " SA1 ( NOLOCK ) ON "
	cSQL += " ( "
	cSQL += " 	A1_FILIAL 		   	= '' "
	cSQL += "	AND A1_COD		   	= F2_CLIENTE "
	cSQL += " 	AND A1_LOJA 	  	= F2_LOJA "
	cSQL += " 	AND SA1.D_E_L_E_T_	= '' "
	cSQL += " ) "

	cSQL += " LEFT JOIN " + RetFullName("SC5", cEmp) + " SC5 ( NOLOCK ) ON
	cSQL += " (
	cSQL += " 	SC5.C5_FILIAL      = " + ValToSql(cFil)
	cSQL += " 	AND SC5.C5_NUM 	   = SC9.C9_PEDIDO
	cSQL += " 	AND SC5.D_E_L_E_T_ = ''
	cSQL += " )

	cSQL += " WHERE SF2.F2_FILIAL	= " + ValToSql(cFil)
	cSQL += " AND SC9.C9_AGREG 		= " + ValToSql(cCarga)
	cSQL += " AND ( ( SF2.F2_YAGREG <> '' AND SF2.F2_YAGREG	= " + ValToSql(SubStr(cEmissaoNF, 1, 4)  + cCarga) + " ) OR SF2.F2_YAGREG = '' ) "
	cSQL += " AND SF2.D_E_L_E_T_ 	= '' "

	TcQuery cSQL New Alias (cAliasTmp)

	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(Eof())

		aAdd(aNotas, {(cAliasTmp)->F2_DOC, (cAliasTmp)->F2_SERIE,;
			(cAliasTmp)->F2_CLIENTE, (cAliasTmp)->F2_LOJA,;
			(cAliasTmp)->A1_CGC, (cAliasTmp)->A1_NREDUZ,;
			(cAliasTmp)->F2_EMISSAO, (cAliasTmp)->F2_EST, (cAliasTmp)->F2_VEICUL1,;
			(cAliasTmp)->F2_SERMDF, (cAliasTmp)->F2_NUMMDF,;
			(cAliasTmp)->A4_COD, (cAliasTmp)->A4_CGC, (cAliasTmp)->A4_EST,;
			cCarga, cCodCli, cCodLoja, (cAliasTmp)->GUIA,;
			(cAliasTmp)->STATUS_LM, (cAliasTmp)->STATUS_NFE, (cAliasTmp)->STATUS_GNRE, (cAliasTmp)->STATUS_MDFE})

		(cAliasTmp)->(DbSkip())

	EndDo

	(cAliasTmp)->(DbCloseArea())

Return(aNotas)

Method Pergunte(lPergunte) Class TFaturamentoMonitor

	Local lRet := .F.
	Local nTam := 0

	Default lPergunte  := .T.

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	If lPergunte

		aAdd(::aParam, {1, "Data Agendamento"	, ::dDtAgend	, "@!", ".T.",	,".T.",,.F.})
		aAdd(::aParam, {1, "Carga"				, ::cCarga		, "@!", ".T.",	,".T.",,.F.})
		aAdd(::aParam, {2, "Faturamento"		, ::cFaturadas	, {"1=Todas", "2=Não faturadas"}, 60, ".T.", .F.})
		aAdd(::aParam, {2, "Motorista Patio"	, ::cMotPatio	, {"1=Todas", "2=Sim"}, 60, ".T.", .F.})

		If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)

			lRet := .T.

			nTam++

			::dDtAgend		:= ::aParRet[nTam++]
			::cCarga		:= ::aParRet[nTam++]
			::cFaturadas	:= ::aParRet[nTam++]
			::cMotPatio		:= ::aParRet[nTam++]

		Else

			lRet := .F.

		EndIf

	Else

		lRet := .T.

	EndIf

Return(lRet)


Method StopJobs() Class TFaturamentoMonitor

	::lAutIsStarted := !::lAutIsStarted

	If ( ::lAutIsStarted )

		U_PUTBIAPAR("BIA_FATAUTO",.T.)
		::oSayAlert:cCaption := ""
		::oBtnStop:SetCss("QPushButton{background-image:url(rpo:fastop.png); background-repeat: none; background-position: center; background-size: cover;}")
		::oTimerLoad:Activate()

	Else

		U_PUTBIAPAR("BIA_FATAUTO",.F.)
		::oSayAlert:cCaption := "ATENÇÃO! FATURAMENTO AUTOMÁTICO PARADO."
		::oBtnStop:SetCss("QPushButton{background-image:url(rpo:faplay.png); background-repeat: none; background-position: center; background-size: cover;}")
		::oTimerLoad:DeActivate()

	EndIf

	::oDlg:Refresh()

Return
