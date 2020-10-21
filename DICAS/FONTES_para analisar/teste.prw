#Include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "PROTHEUS.CH"
//#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "TCBROWSE.CH"

#Define DS_MODALFRAME 128
#Define CLRF CHR(13) + CHR(10)

/*/{Protheus.doc} BRA0503
Agrupamento de matéria prima conforme Ordens de Produção.
@author SISNET-Giovani Soares
@since 28/02/2018
@history 28/02/2018, SISNET-Giovani, construção da rotina
@history 17/10/2018, TOTVS-IURY, Validação da importação da lista de separação conforme chamado 15258
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
	Local oTButton1

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
	//oBrowse:DisableConfig()
	oBrowse:DisableReport()
	oBrowse:SetLineHeight(30)
	oBrowse:SetFontBrowse(oFont)
	oBrowse:SetFieldMark('D4_YOK') //Necessário para o MarkBrowser
	oBrowse:SetDescription("Lista de OPs")
	oBrowse:SetAlias('SD4')
	oBrowse:ForceQuitButton()
	/*oBrowse:AddLegend( {|| SD4_STATUS == "1"},"BR_VERMELHO","Agrupamento criado")
	oBrowse:AddLegend( {|| SD4_STATUS == "2"},"BR_AZUL"    ,"Agrupamento exportado")
	oBrowse:AddLegend( {|| SD4_STATUS == "3"},"BR_AMARELO" ,"Agrupamento importado parcialmente")
	oBrowse:AddLegend( {|| SD4_STATUS == "4"},"BR_VERDE"   ,"Agrupamento importado totalmente")*/
	oBrowse:SetOnlyFields({'D4_FILIAL'})
	oBrowse:SetColumns( getColumn("D4_UD4DOC", 1 ,10) ) 
	oBrowse:SetColumns( getColumn("D4_OP", 1 ,10) )  
	oBrowse:SetColumns( getColumn("D4_PRODUTO", 1 ,10) ) 
	oBrowse:SetColumns( getColumn("D4_DATA", 1 ,10) ) 
	
	
	
    

	oBrowse:Activate()
	oTButton1 := TButton():New( 10, 10, "Adicionar" , oPanelDown, {|| btnAdd(oBrowse)}    , 50,16,,,.F.,.T.,.F.,,.F.,,,.F. )	 
 

	oDlg:lCentered := .T.
	oDlg:Activate()

Return()


/*/{Protheus.doc} getColumn
Define estrutura de colunas a serem exibidas pelo browse da função principal 
@return nil, Retorno nulo
@param cCampo, characters, nome do campo. exemplo: "SD4_COD"
@param nAlign, numeric, alinhamento, onde: 1- esquerda, 2- centro, 3- direita)
@param nSize, numeric, tamanho. exemplo: 20
@param bData, block, bloco de código para carga dos dados. exemplo: {|| SD4->SD4_COD}
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
	SD4->(DbGoTop())
	While !SD4->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oBrowse:IsMark(cMarca)
			nCt++	
		EndIf	 
		 
		SD4->(DbSkip())
	EndDo
	
	//Mostrando a mensagem de registros marcados
	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' </b>.', "Atenção")
 
Return 