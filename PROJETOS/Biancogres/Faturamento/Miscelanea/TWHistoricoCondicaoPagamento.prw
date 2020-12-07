#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWHistoricoCondicaoPagamento
@author Tiago Rossini Coradini
@since 19/10/2016
@version 1.0
@description Rotina para exibir ultimas condições de pagamento utilizadas pelo cliente no pedido de venda. 
@obs OS: 3728-16 - Claudeir Fadini

@type class
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN "LIN"

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN 100

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// PERCENTUAL DAS JANELAS
#DEFINE PER_WIN 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Histórico de Condições de Pagamento"
#DEFINE TIT_WND "Condições de Pagamento utilizadas nos últimos 3 mêses"

// TITULOS DAS COLUNAS DO BROWSE
#DEFINE TIT_COL1_BRW "Cond. Pagto"
#DEFINE TIT_COL2_BRW "Descrição"
#DEFINE TIT_COL3_BRW "Qtd. Ped. Util."

// CLIENTES
#DEFINE IDX_CONDPAG 1
#DEFINE IDX_DESCCON 2
#DEFINE IDX_QTD 3

// DESCRICAO E IMAGENS DOS BOTOES DA BARRA PRINCIPAL (oBtnBar)
#DEFINE DSC_BTN_OK "OK"


Class TWHistoricoCondicaoPagamento From LongClassName

	// MsDialog
	Data oDlg
	
	// layer 
	Data oLayer
	
	// array com a coordenadas de tela
	Data aCoors

	// Objetos da Enchoice
	Data oBtnBar // Barra de Botoes Pricipal

	// paineis
	Data oPnl
	Data oBrw // Browse (MsNewGetDados)
	Data aFields
	
	Data cCondPag // Condicao de pagamento selecionada 
					
	Method New(cCodCli, cLojCli, cLinha) Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLine() // Carrega a interface da linha
	Method LoadButtonBar() // Carrega barra de botoes
	Method Activate() // Ativa exibicao do objeto
	Method GetData(cCodCli, cLojCli, cLinha) // Retorna dados dos parametros
	Method GetHeader() // Seta configurações dos campos
	Method Close() // Fecha Janela
			
EndClass


// construtor da classe
Method New(cCodCli, cLojCli, cLinha) Class TWHistoricoCondicaoPagamento
	
	::oDlg := Nil
	::oLayer := Nil
	::aCoors := {}
				
	::oBtnBar := Nil
		
	::oPnl := Nil
			
	::oBrw := Nil
	::aFields := ::GetData(cCodCli, cLojCli, cLinha)
	
	::cCondPag := ""
	
Return()


// Contrutor da interface
Method LoadInterface() Class TWHistoricoCondicaoPagamento
	
	::LoadDialog()
	
	::LoadButtonBar()
	
	::LoadLayer()
		
	::LoadLine()		
			
Return()


Method LoadDialog() Class TWHistoricoCondicaoPagamento
	
	::aCoors := FWGetDialogSize(oMainWnd)	
	
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3] / 2
	::oDlg:nWidth := ::aCoors[4] / 2
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .T.

Return()


Method LoadLayer() Class TWHistoricoCondicaoPagamento

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg)

Return()


// Carrega linha
Method LoadLine() Class TWHistoricoCondicaoPagamento
Local cVldDef := "AllwaysTrue"

	// Adciona Linha com 100% da tela
	::oLayer:AddLine(LIN, PER_LIN, .F.)
	
	// Adciona Coluna acima com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	
	// Adciona Janela
	::oLayer:AddWindow(COL, WND, TIT_WND, PER_WIN, .F. ,.T.,, LIN, { || })

	oWindow := Nil
	
	::oLayer:GetWindow(COL, WND, @oWindow, LIN)
	
	oWindow:oTitleBar:oFont := TFont():New("MS Sans Serif",,18,,.T.,,,,,.F.,.F.)
	
	// Painel
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
	
	::oBrw := TCBrowse():New(00,00,0,0,,,,::oPnl,,,,,,,,,,,,.F.,,.T.,,.F.)	
	::oBrw:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:lHScroll := .T.
	::oBrw:lVScroll := .T.	
	
	::oBrw:AddColumn(TcColumn():New(TIT_COL1_BRW, {|| ::aFields[::oBrw:nAt, IDX_CONDPAG] }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL2_BRW, {|| ::aFields[::oBrw:nAt, IDX_DESCCON] }, "@!",Nil,Nil,Nil,85,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL3_BRW, {|| ::aFields[::oBrw:nAt, IDX_QTD] }, "@!",Nil,Nil,Nil,45,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	::oBrw:AddColumn(TcColumn():New("", {|| "" }, "@!",Nil,Nil,Nil,15,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	
	::oBrw:SetArray(::aFields)
	::oBrw:Refresh()
	::oBrw:bLDblClick := {|| ::Close()}
	::oBrw:SetFocus()	
							
Return()


Method LoadButtonBar() Class TWHistoricoCondicaoPagamento
	
	::oBtnBar := FWButtonBar():New()
	::oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	::oBtnBar:AddBtnText(DSC_BTN_OK, DSC_BTN_OK, {|| ::Close() },,,CONTROL_ALIGN_RIGHT, .T.)
	
Return()


Method Activate() Class TWHistoricoCondicaoPagamento
				
	::LoadInterface()
	
	::oDlg:Activate()	
	
Return()


Method GetData(cCodCli, cLojCli, cLinha) Class TWHistoricoCondicaoPagamento
Local aFields := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSC5 := RetSQLName("SC5")
Local cSE4 := "SE4010"
Local cSC6 := RetSQLName("SC6")
Local cSB1 := "SB1010"
Local cSF4 := RetSQLName("SF4")
Local cSA1 := "SA1010" 
	
	If cEmpAnt $ '01/05/07' .And. AllTrim(M->C5_YSUBTP) $ "E/N"
	
		cSQL := " SELECT C5_CONDPAG, E4_DESCRI, COUNT(C5_CONDPAG) COUNT "
		cSQL += " FROM "+ cSC5 +" SC5 "
		cSQL += " INNER JOIN "+ cSE4 +" SE4 "
		cSQL += " ON C5_CONDPAG = E4_CODIGO "
		cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
		cSQL += " AND C5_CLIENTE = "+ ValToSQL(cCodCli)
		cSQL += " AND C5_LOJACLI = "+ ValToSQL(cLojCli)
		cSQL += " AND C5_EMISSAO BETWEEN "+ ValToSQL(FirstDate(MonthSub(dDataBase, 3))) +" AND "+ ValToSQL(dDataBase)
		cSQL += " AND C5_YSUBTP IN ('N', 'E') "
		cSQL += " AND C5_YLINHA = "+ ValToSQL(cLinha)
		cSQL += " AND SC5.D_E_L_E_T_ = '' "
		cSQL += " AND E4_FILIAL = '' "
		cSQL += " AND E4_MSBLQL <> '1' "
		cSQL += " AND SE4.D_E_L_E_T_ = '' "
		cSQL += " AND EXISTS "
		cSQL += " ( "
		cSQL += " 	SELECT C6_TES "
		cSQL += " 	FROM "+ cSC6 +" SC6 "
		cSQL += " 	INNER JOIN "+ cSB1 +" SB1 "
		cSQL += " 	ON C6_PRODUTO = B1_COD "
		cSQL += " 	INNER JOIN "+ cSF4 +" SF4 "
		cSQL += " 	ON C6_TES = F4_CODIGO "
		cSQL += " 	WHERE C6_FILIAL = "+ ValToSQL(xFilial("SC6"))
		cSQL += " 	AND C6_NUM = C5_NUM "
		cSQL += " 	AND B1_FILIAL = '' "
		cSQL += " 	AND B1_TIPO = 'PA' "
		cSQL += " 	AND F4_FILIAL = "+ ValToSQL(xFilial("SF4"))
		cSQL += " 	AND F4_DUPLIC = 'S' "
		cSQL += " 	AND SC6.D_E_L_E_T_ = '' "
		cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
		cSQL += " 	AND SF4.D_E_L_E_T_ = ''	"
		cSQL += " ) "
		cSQL += " AND C5_CLIENTE NOT IN " 
		cSQL += " ( "
		cSQL += " 	SELECT A1_COD "
		cSQL += " 	FROM "+ cSA1
		cSQL += " 	WHERE A1_COD <> '999999' "
		cSQL += " 	AND SUBSTRING(A1_CGC,1,8) = '02077546' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '04917232' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '04548187' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '10524837' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '13231737' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '14086214' "
		cSQL += " 	OR SUBSTRING(A1_CGC,1,8) = '08930868' "
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY A1_COD "
		cSQL += " ) "
		cSQL += " GROUP BY C5_CONDPAG, E4_DESCRI "
		cSQL += " ORDER BY COUNT(C5_CONDPAG) DESC "
	
		TcQuery cSQL New Alias (cQry)
						
		While !(cQry)->(Eof())
			
			aAdd(aFields, {(cQry)->C5_CONDPAG, (cQry)->E4_DESCRI, (cQry)->COUNT, ""})
			
			(cQry)->(DbSkip())
		
		EndDo
		
		(cQry)->(DbCloseArea())

	EndIf
	
Return(aFields)


Method Close() Class TWHistoricoCondicaoPagamento

	::cCondPag := ::aFields[::oBrw:nAt, IDX_CONDPAG] 
	
	::oDlg:End()

Return()