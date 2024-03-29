#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "PROTHEUS.CH"



#Define DS_MODALFRAME 128
#Define CLRF CHR(13) + CHR(10)

/*/{Protheus.doc} 
Agrupamento de mat�ria prima conforme Ordens de Produ��o.
@author Facile - Filipe
@since 01/10/2019 
@return nil, Retorno nulo
@type function
/*/
User Function ZMKBROWS()

	Local alDms := FWGetDialogSize(oMainWnd) // { nTop, nLeft, nBottom, nRight }
	Local nUpScreen := 0
	Local nDownScreen := 0
	Local oDlg
	Local oFWLayer
	Local oPanelUp
	Local oPanelDown
	Local oBrowse
	Local oFont := TFont():New("MS Sans Serif",,12,,.F.,,,,,.F.,.F.)
	Local oTButton1, oTButton2
	Local aFilParser := {}
	Local cFilter := ""


	// Calcula, conforme a resolu��o do monitor, o percentual de altura
	// que cada layer (camada) da tela possuir�.
	// Considera o tamanho fixo em 120 pixels para a camada superior (UP)
	// e 72 pixels para a camada inferior (DOWN).
	nDownScreen := ( ( 052 * 100 ) / alDms[3] ) //72
	nUpScreen := ( 100 - nDownScreen )

	// Cria janela de di�logo do tipo modal
	oDlg := MSDialog():New( alDms[1],alDms[2],alDms[3],alDms[4],"Lista de OPs",,,.F.,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.,,,.T. )

	oFWLayer := FWLayer():New() // cria camada
	oFWLayer:Init(oDlg, .F., .T.) // define em qual dialog a camada ser� inicializada
	oFWLayer:AddLine('UP', nUpScreen, .F.) // segmenta a camada em uma linha e define sua propor��o perante o dialog principal
	oFwLayer:AddLine('DOWN', nDownScreen, .F.)

	oPanelUp := oFWLayer:GetLinePanel('UP') // retorna o objeto do painel referente � segmenta��o realizada
	oPanelDown := oFWLayer:GetLinePanel('DOWN') // retorna o objeto do painel referente � segmenta��o realizada

	// Cria browse de marca��o para sele��o dos agrupamentos desejados
	oBrowse := FwMarkBrowse():New()
	oBrowse:SetOwner(oPanelUp)	
	oBrowse:DisableReport()
	oBrowse:SetLineHeight(30)
    oBrowse:ForceQuitButton()
	oBrowse:SetFontBrowse(oFont)    
	oBrowse:SetFieldMark('C6_YOK') //Necess�rio para o MarkBrowser
	oBrowse:SetDescription("Lista de OPs")
	oBrowse:SetAlias('SC6')
	
	/*oBrowse:AddLegend( {|| UD4_STATUS == "1"},"BR_VERMELHO","Agrupamento criado")
	oBrowse:AddLegend( {|| UD4_STATUS == "2"},"BR_AZUL"    ,"Agrupamento exportado")
	oBrowse:AddLegend( {|| UD4_STATUS == "3"},"BR_AMARELO" ,"Agrupamento importado parcialmente")
	oBrowse:AddLegend( {|| UD4_STATUS == "4"},"BR_VERDE"   ,"Agrupamento importado totalmente")
    */
	//oBrowse:SetOnlyFields( { 'C6_NUM' } ) 

	// Define filtro por agrupamento criado 
 	/*aFilParser := {}
	cFilter := "UD4->UD4_STATUS <= '3' "
	aadd(aFilParser,{cFilter, "EXPRESSION"})
	oBrowse:AddFilter("UD4_STATUS <= 3", cFilter, .T., .T., "UD4", .F., aFilParser, '01')
 */
    oBrowse:Activate()
    
	oTButton1 := TButton():New( 10, 10, "Adicionar" , oPanelDown, {|| btnAdd(oBrowse)}    , 50,16,,,.F.,.T.,.F.,,.F.,,,.F. )	  
	oTButton2 := TButton():New( 10, 10+(60*01), "Remover"   , oPanelDown, {|| btnDel(oBrowse,.F.)}, 50,16,,,.F.,.T.,.F.,,.F.,,,.F. )

	oDlg:lCentered := .T.
	oDlg:Activate()
	


Return()


/*/{Protheus.doc} getColumn
Define estrutura de colunas a serem exibidas pelo browse da fun��o principal 
@return nil, Retorno nulo
@param cCampo, characters, nome do campo. exemplo: "UD4_COD"
@param nAlign, numeric, alinhamento, onde: 1- esquerda, 2- centro, 3- direita)
@param nSize, numeric, tamanho. exemplo: 20
@param bData, block, bloco de c�digo para carga dos dados. exemplo: {|| UD4->UD4_COD}
@type function
/*/
Static Function getColumn(cCampo,nAlign,nSize,bData)

	Local aHeader := {}
	Local aColumn := {}
	Local aArea := GetArea()

	Default bData := &("{|| " + cCampo + "}")

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // X3_CAMPO

	If MsSeek(cCampo)
		/* Array da coluna
	    [n][01] T�tulo da coluna
	    [n][02] Code-Block de carga dos dados
	    [n][03] Tipo de dados
	    [n][04] M�scara
	    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	    [n][06] Tamanho
	    [n][07] Decimal
	    [n][08] Indica se permite a edi��o
	    [n][09] Code-Block de valida��o da coluna ap�s a edi��o
	    [n][10] Indica se exibe imagem
	    [n][11] Code-Block de execu��o do duplo clique
	    [n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
	    [n][13] Code-Block de execu��o do clique no header
	    [n][14] Indica se a coluna est� deletada
	    [n][15] Indica se a coluna ser� exibida nos detalhes do Browse
	    [n][16] Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
	    */
		aColumn := {SX3->X3_TITULO,bData,SX3->X3_TIPO,SX3->X3_PICTURE,nAlign,nSize,SX3->X3_DECIMAL,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
		aadd(aHeader,aColumn)
	EndIf

	SX3->(DbCloseArea())

	RestArea(aArea)

Return(aHeader)

Static Function btnAdd(oBrowse)

	Local cMarca   := oBrowse:Mark()
	Local lInverte := oBrowse:IsInvert()
	Local nCt      := 0
	
	nAt := 0
	oBrowse:GoTop(.T.)	
	
		SC6->(DbGoTop())
		While !SC6->(EoF())
			If oBrowse:IsMark(cMarca)			 	
				Alert(SC6->C6_NUM)
				nCt++					
			EndIf
			SC6->(DbSkip())
		EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Aten��o")
 	oBrowse:Refresh(.T.)
Return .T.

// Deletar as selecionadas 
Static Function btnDel(oBrowse)

	Local cMarca   := oBrowse:Mark()
	Local lInverte := oBrowse:IsInvert()
	Local nCt      := 0
	
	//Percorrendo os registros da SA1
	
	SC6->(DbGoTop())
	While !SC6->(EoF())  
		//Caso esteja marcado, aumenta o contador
		If oBrowse:IsMark(cMarca)
			Alert(SC6->C6_NUM)
			nCt++	
		EndIf	 
		 
		SC6->(DbSkip())
	EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Aten��o")
 	oBrowse:Refresh(.T.)

Return .T.