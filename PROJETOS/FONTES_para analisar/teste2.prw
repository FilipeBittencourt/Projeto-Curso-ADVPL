#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "PROTHEUS.CH"



#Define DS_MODALFRAME 128
#Define CLRF CHR(13) + CHR(10)

/*/{Protheus.doc} 
Agrupamento de matéria prima conforme Ordens de Produção.
@author Facile - Filipe
@since 01/10/2019 
@return nil, Retorno nulo
@type function
/*/
User Function PCPTEST()

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


	// Calcula, conforme a resolução do monitor, o percentual de altura
	// que cada layer (camada) da tela possuirá.
	// Considera o tamanho fixo em 120 pixels para a camada superior (UP)
	// e 72 pixels para a camada inferior (DOWN).
	nDownScreen := ( ( 052 * 100 ) / alDms[3] ) //72
	nUpScreen := ( 100 - nDownScreen )

	// Cria janela de diálogo do tipo modal
	oDlg := MSDialog():New( alDms[1],alDms[2],alDms[3],alDms[4],"Lista de OPs",,,.F.,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.,,,.T. )

	oFWLayer := FWLayer():New() // cria camada
	oFWLayer:Init(oDlg, .F., .T.) // define em qual dialog a camada será inicializada
	oFWLayer:AddLine('UP', nUpScreen, .F.) // segmenta a camada em uma linha e define sua proporção perante o dialog principal
	oFwLayer:AddLine('DOWN', nDownScreen, .F.)

	oPanelUp := oFWLayer:GetLinePanel('UP') // retorna o objeto do painel referente à segmentação realizada
	oPanelDown := oFWLayer:GetLinePanel('DOWN') // retorna o objeto do painel referente à segmentação realizada

	// Cria browse de marcação para seleção dos agrupamentos desejados
	oBrowse := FwMarkBrowse():New()
	oBrowse:SetOwner(oPanelUp)	
	oBrowse:DisableReport()
	oBrowse:SetLineHeight(30)
    oBrowse:ForceQuitButton()
	oBrowse:SetFontBrowse(oFont)    
	oBrowse:SetFieldMark('UD4_YOK') //Necessário para o MarkBrowser
	oBrowse:SetDescription("Lista de OPs")
	oBrowse:SetAlias('UD4')
	
	/*oBrowse:AddLegend( {|| UD4_STATUS == "1"},"BR_VERMELHO","Agrupamento criado")
	oBrowse:AddLegend( {|| UD4_STATUS == "2"},"BR_AZUL"    ,"Agrupamento exportado")
	oBrowse:AddLegend( {|| UD4_STATUS == "3"},"BR_AMARELO" ,"Agrupamento importado parcialmente")
	oBrowse:AddLegend( {|| UD4_STATUS == "4"},"BR_VERDE"   ,"Agrupamento importado totalmente")
    */
	oBrowse:SetOnlyFields( { 'UD4_DOC' } ) 

	// Define filtro por agrupamento criado 
	aFilParser := {}
	cFilter := "UD4->UD4_STATUS <= '3' "
	aadd(aFilParser,{cFilter, "EXPRESSION"})
	oBrowse:AddFilter("Apenas com saldo", cFilter, .T., .T., "UD4", .F., aFilParser, '01')
 
 
    oBrowse:Activate()
    
	oTButton1 := TButton():New( 10, 10, "Adicionar" , oPanelDown, {|| btnAdd(oBrowse)}    , 50,16,,,.F.,.T.,.F.,,.F.,,,.F. )	  
	oTButton2 := TButton():New( 10, 10+(60*01), "Remover"   , oPanelDown, {|| btnDel(oBrowse,.F.)}, 50,16,,,.F.,.T.,.F.,,.F.,,,.F. )

	oDlg:lCentered := .T.
	oDlg:Activate()
	


Return()


/*/{Protheus.doc} getColumn
Define estrutura de colunas a serem exibidas pelo browse da função principal 
@return nil, Retorno nulo
@param cCampo, characters, nome do campo. exemplo: "UD4_COD"
@param nAlign, numeric, alinhamento, onde: 1- esquerda, 2- centro, 3- direita)
@param nSize, numeric, tamanho. exemplo: 20
@param bData, block, bloco de código para carga dos dados. exemplo: {|| UD4->UD4_COD}
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
	    [n][01] Título da coluna
	    [n][02] Code-Block de carga dos dados
	    [n][03] Tipo de dados
	    [n][04] Máscara
	    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	    [n][06] Tamanho
	    [n][07] Decimal
	    [n][08] Indica se permite a edição
	    [n][09] Code-Block de validação da coluna após a edição
	    [n][10] Indica se exibe imagem
	    [n][11] Code-Block de execução do duplo clique
	    [n][12] Variável a ser utilizada na edição (ReadVar)
	    [n][13] Code-Block de execução do clique no header
	    [n][14] Indica se a coluna está deletada
	    [n][15] Indica se a coluna será exibida nos detalhes do Browse
	    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
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
	
	//Percorrendo os registros da SA1
	UD4->(DbGoTop())
	While !UD4->(EoF()) .AND. VAL(UD4->UD4_STATUS)  <= 3  
		//Caso esteja marcado, aumenta o contador
		If oBrowse:IsMark(cMarca)
			Alert(UD4->UD4_DOC)
			nCt++	
		EndIf	 
		 
		UD4->(DbSkip())
	EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Atenção")
 
Return .T.

// Deletar as selecionadas 
Static Function btnDel(oBrowse)

	Local cMarca   := oBrowse:Mark()
	Local lInverte := oBrowse:IsInvert()
	Local nCt      := 0
	
	//Percorrendo os registros da SA1
	UD4->(DbGoTop())
	While !UD4->(EoF()) .AND. VAL(UD4->UD4_STATUS)  <= 3  
		//Caso esteja marcado, aumenta o contador
		If oBrowse:IsMark(cMarca)
			Alert(UD4->UD4_OP)
			nCt++	
		EndIf	 
		 
		UD4->(DbSkip())
	EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Atenção")
 
Return .T.