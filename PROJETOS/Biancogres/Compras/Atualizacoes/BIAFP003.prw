#Include "Protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#Include 'Set.CH'

#Define CLRYELLOW		rgb(255, 254, 141)
#Define CLRRED 		  rgb(255, 139, 139)
#Define CLRGREEN	  rgb(0, 201, 168)
#Define CLRWHITE	  rgb(255, 255, 255)

/*/{Protheus.doc} BIAFP003
Tela para gestão do limite de caixa nos pedidos de compras
@type function
@version 1.0
@author Facile - Pontin
@since 23/11/2020
/*/
User Function BIAFP003()

  Local aArea			      := GetArea()
  Local oLayer		      := Nil
  Local aSize			      := {}
  //------------------------
  Private 	cTitulo	    := "BIAFP003 - Gestão do Limite de Caixa"
  //------------------------
  Private oDlgTela	    := Nil
  Private oBrowse		    := NIL
  Private dEmissaoDe    := DaySub( dDataBase , 30 )
  Private dEmissaoAte   := dDataBase
  Private oCbxFiltro	  := Nil
  Private cFiltroSel	  := ""
  Private cSearch	      := Space(200)
  Private cAliasQry	    := GetNextAlias()

  //-- Definicoes da Janela
  aSize	:= FWGetDialogSize( oMainWnd )

  oDlgtela := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitulo,,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )

  oLayer := FWLayer():New()
  oLayer:Init(oDlgTela,.F.,.T.)

  //-- DIVISOR DE TELA SUPEIROR [ FILTRO ]
  oLayer:AddLine("LINESUP", 25 )
  oLayer:AddCollumn("BOX01", 100,, "LINESUP" )
  oLayer:AddWindow("BOX01", "PANEL01", "Filtros", 100, .F.,,, "LINESUP" ) //"Filtros"

  //-- DIVISOR DE TELA INFERIOR [ GRID ]
  oLayer:AddLine("LINEINF", 75 )
  oLayer:AddCollumn( "BOX02", 100,, "LINEINF" )
  oLayer:AddWindow( "BOX02", "PANEL02", cTitulo	, 100, .F.,,, "LINEINF" )

  //-- ALOCA CADA COMPONENTE EM SEU RESPECTIVO BOX ( TPANEL )
  FPanel01( oLayer:GetWinPanel( "BOX01", "PANEL01", "LINESUP" ) ) //Contrução do Painel de Filtros
  FPanel02( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINEINF" ) ) //Contrução do Painel de titulos

  oDlgtela:Activate()

  RestArea(aArea)

Return

/*/{Protheus.doc} FPanel01
Cria a parte superior da janela "Filtros" e aloca ao painel 01.
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function FPanel01( oPanel )

  Local bFiltrar	:=	Nil

  //-- Inclui a borda pora apresentacao dos componentes em tela
  TGroup():New( 005, 005, (oPanel:nHeight/2) - 005, (oPanel:nWidth/2) - 010 , "", oPanel,,, .T. ) //"Filtros"

//-- Inclui legendas dos campos
  TSay():New( 010, 010, { || "Emissão De"    }, oPanel,,,,,, .T.,,, 80, 010 )
  @020,010 MSGET dEmissaoDe  	PICTURE "@!" SIZE 80, 010 OF oPanel PIXEL HASBUTTON

	TSay():New( 010, 095, { || "Emissão Ate"    }, oPanel,,,,,, .T.,,, 80, 010 )
  @020,095 MSGET dEmissaoAte  	PICTURE "@!" SIZE 80, 010 OF oPanel PIXEL HASBUTTON

  TSay():New( 010, 178, { || "Filtro rápido" }, oPanel,,,,,, .T.,,, 80, 010 )

  //-- Inclui combo com as opções de filtro
  oCbxFiltro := TComboBox():Create(oPanel)
  oCbxFiltro:cName 		  := "oCbxFiltro"
  oCbxFiltro:cCaption 	:= "Filtro"
  oCbxFiltro:nLeft 		  := 357
  oCbxFiltro:nTop 		  := 039
  oCbxFiltro:nWidth 		:= 160
  oCbxFiltro:nHeight 		:= 024
  oCbxFiltro:lShowHint 	:= .F.
  oCbxFiltro:lReadOnly 	:= .F.
  oCbxFiltro:Align 		  := 0
  oCbxFiltro:cVariable 	:= "cFiltroSel"
  oCbxFiltro:bSetGet 		:= {|u| If(PCount()>0,cFiltroSel:=u,cFiltroSel) }
  oCbxFiltro:aItems 		:= {"1=Bloqueados","2=Aprovados","3=Todos"}
  oCbxFiltro:nAt 			  := 0

  TSay():New( 010, 270, { || "Filtro inteligente"    }, oPanel,,,,,, .T.,,, 80, 010 )
  TGet():New( 020, 270, { |u| If(PCount()>0,cSearch := u, cSearch)},oPanel,160,010,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSearch",,)

  //Inclui botao filtrar
  bFiltrar := { || ExecFil("Aplicando Filtros") }
  TButton():New( 019,435, "Filtrar", oPanel, bFiltrar, 050, 013,,,, .T. ) //"Filtrar"

Return()


/*/{Protheus.doc} FPanel02
Cria a parte inferior da janela "Grid Browse" e aloca ao painel 02.
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function FPanel02( oPanel )

  Local bProcessa       := { |xProc| fProcessa(xProc) }
  Local aIndex	        := {}
  Local aSeek 	        := {}
  Local aFilter	        := {}

  // Aplica as definicoes para um Browse de tabela temporaria
  oBrowse := FWFormBrowse():New()
  oBrowse:SetDescription(cTitulo)
  oBrowse:SetTemporary(.T.)
  oBrowse:SetAlias(cAliasQry)
  oBrowse:SetCacheView(.F.)
  oBrowse:SetDataQuery()

  oBrowse:SetQuery( GetQuery() )

  oBrowse:SetOwner(oPanel)
  oBrowse:SetColumns( GetColumns(cAliasQry)[1] )
  oBrowse:SetDBFFilter(.T.)
  oBrowse:SetUseFilter()

  aFilter := GetColumns(cAliasQry)[2]
  oBrowse:SetFieldFilter(aFilter)
  oBrowse:DisableDetails()

  // ---------------------------------------------+
  //  Faz a inserção dos botoes para o browse     |
  // ---------------------------------------------+
  oBrowse:AddButton( OemToAnsi("Gerenciar Pedido")        , {|| eVal( bProcessa, "RUN" ) } 	    ,, 2 )
  oBrowse:AddButton( OemToAnsi("Fechar")		              , {|| oDlgTela:End() } 	              ,, 2 )
  oBrowse:AddButton( OemToAnsi("Reavaliar Pedido")        , {|| fReavaliar() } 	                ,, 2 )
  oBrowse:AddButton( OemToAnsi("Legenda")			            , {|| LegendBrw() } 	                ,, 2 )

  // ------------------------------------------------------+
  //  Cria Indices para obter a busca por pedido e Cliente |
  // ------------------------------------------------------+
  aAdd( aIndex, "C7_FILIAL+C7_NUM" )
  aAdd( aSeek, { "Filial+Pedido",;
    { ;
    {"","C",TamSx3('C7_FILIAL')[1],0    ,"Filial","@!"},  ;
    {"","C",TamSx3('C7_NUM')[1],0   ,"Pedido","@!"}  ;
    },1  } )

  aAdd( aIndex, "C7_NUM" )
  aAdd( aSeek, { "Pedido", { {"","C",TamSx3('C7_NUM')[1],0,"Pedido","@!"}  },2  } )

  aAdd( aIndex, "C7_FORNECE" )
  aAdd( aSeek, { "Fornecedor", { {"","C",TamSx3('C7_FORNECE')[1],0,"Fornecedor","@!"}  },3  } )

  aAdd( aIndex, "C7_YNAPLCX" )
  aAdd( aSeek, { "Aprovador", { {"","C",TamSx3('C7_YNAPLCX')[1],0,"Aprovador",""}  },4  } )

  oBrowse:SetQueryIndex(aIndex)
  oBrowse:SetSeek(,aSeek)

  //-------------------------
  // Ativa exibição do browse
  oBrowse:Activate()

Return()


/*/{Protheus.doc} GetQuery
Monta consulta sql para buscar os pedidos que possuem bloqueios. 
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function GetQuery()

  Local cQuery 	    := ""

  //-- Aplica regra ao obter a selecao do filtro
  nTipo   := Val(cFiltroSel)

	cQuery += " SELECT SC7.C7_FILIAL, "
	cQuery += " 			SC7.C7_NUM, "
	cQuery += " 			SC7.C7_EMISSAO, "
	cQuery += " 			SC7.C7_YAPRLCX, "
	cQuery += " 			SC7.C7_YNAPLCX, "
	cQuery += " 			SC7.C7_YDTALCX, "
	cQuery += " 			SC7.C7_YSTLCX, "
	cQuery += " 			SC7.C7_FORNECE, "
	cQuery += " 			SC7.C7_LOJA "
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += " WHERE SC7.C7_FILIAL > '' "
	cQuery += " 			AND SC7.C7_EMISSAO BETWEEN " + ValToSql(dEmissaoDe) + " AND " + ValToSql(dEmissaoAte)
	cQuery += " 			AND SC7.C7_RESIDUO = '' "
	// cQuery += " 			AND SC7.C7_CONAPRO <> 'B' "
	cQuery += " 			AND SC7.C7_ENCER = '' "

	//|Filtros do combobox |
  If nTipo == 1
    cQuery += "       AND SC7.C7_YSTLCX = 'B' "
  ElseIf nTipo == 2
    cQuery += "       AND SC7.C7_YSTLCX = 'A' "
  ElseIf nTipo == 3
    cQuery += "       AND SC7.C7_YSTLCX <> '' "
	EndIf

	If !Empty(cSearch)
    fMountWhe( @cQuery, cSearch )
  EndIf

	cQuery += " 			AND SC7.D_E_L_E_T_ <> '*' "

	cQuery += " GROUP BY SC7.C7_FILIAL,
	cQuery += " 				SC7.C7_NUM,
	cQuery += " 				SC7.C7_EMISSAO,
	cQuery += " 				SC7.C7_YAPRLCX,
	cQuery += " 				SC7.C7_YNAPLCX,
	cQuery += " 				SC7.C7_YDTALCX,
	cQuery += " 				SC7.C7_YSTLCX,
	cQuery += " 				SC7.C7_FORNECE,
	cQuery += " 				SC7.C7_LOJA

  cQuery := ChangeQuery(cQuery)

Return(cQuery)


/*/{Protheus.doc} fMountWhe
Funcao para montar o filtro de acordo com a pesquisa
@type Function
@author Pontin
@since 26/12/2019
@version 1.0
/*/
Static Function fMountWhe( cQry, cSearch )

  Local aTxt 	:= StrToKarr( AllTrim(cSearch), " " )
  Local nI	  := 0

  For nI := 1 To Len(aTxt)

    cQry += " AND (C7_FILIAL LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_NUM    LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_YAPRLCX   LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_YNAPLCX      LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_YDTALCX      LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_YSTLCX      LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_FORNECE      LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " OR C7_LOJA      LIKE '%"+aTxt[nI]+"%' " + CRLF
    cQry += " ) "

  Next nI

Return


/*/{Protheus.doc} ExecFil
Executa rotina de atualização do browse com opção de tela de processamento. 
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function ExecFil(cMsgRun)

  Default cMsgRun	:=  ""

  If !Empty(cMsgRun)
    FWMsgRun( ,{|| UpdateBrw() },"Aguarde",cMsgRun)
  Else
    CursorWait()
    UpdateBrw()
    CursorArrow()
  EndIf

Return


/*/{Protheus.doc} UpdateBrw
Faz atualização dos dados que estao no browse (REFRESH) 
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/ 
Static Function UpdateBrw()

  oBrowse:Data():DeActivate(.T.)
  oBrowse:SetQuery( GetQuery() )
  oBrowse:Data():Activate()
  oBrowse:UpdateBrowse(.T.)
  oBrowse:GoBottom()
  oBrowse:GoTo(1,.T.)
  oBrowse:Refresh(.T.)

  oBrowse:ExecuteFilter( .T. )

Return()


/*/{Protheus.doc} GetColumns
Rotina responsavel por montar a estrutura das colunas do Browse.
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function GetColumns(cAlias)

  Local aArea	    := GetArea()
  Local cCampo	  := ""
  Local cTipo 	  := ""
  Local aCampos	  := {}
  Local aColumns	:= {}
  Local aFilters	:= {}
  Local nX		    := 0
  Local nLinha	  := 0
  Local bLegenda  := Nil

  aAdd( aCampos, "C7_FILIAL" )
  aAdd( aCampos, "C7_NUM" )
  aAdd( aCampos, "C7_EMISSAO" )
  aAdd( aCampos, "C7_YAPRLCX" )
  aAdd( aCampos, "C7_YNAPLCX" )
  aAdd( aCampos, "C7_YDTALCX" )
  // aAdd( aCampos, "C7_YSTLCX" )
  aAdd( aCampos, "C7_FORNECE" )
  aAdd( aCampos, "C7_LOJA" )
  // aAdd( aCampos, "RECNO " )

  //|Adiciona a coluna de legenda |
  AAdd(aColumns,FWBrwColumn():New())
  nLinha := Len(aColumns)

  bLegenda	:= {|| fLegenda() }

  aColumns[nLinha]:SetData( &("{|| eVal(bLegenda) }") )
  aColumns[nLinha]:SetTitle("")
  aColumns[nLinha]:SetType("C")
  aColumns[nLinha]:SetPicture("@BMP")
  aColumns[nLinha]:SetSize(1)
  aColumns[nLinha]:SetDecimal(0)
  aColumns[nLinha]:SetDoubleClick({|| LegendBrw() })
  aColumns[nLinha]:SetImage(.T.)


  For nX := 1 To Len(aCampos)

    If !Empty( FwSx3Util():GetDescription( aCampos[nX] ) )


      AAdd(aColumns,FWBrwColumn():New())
      nLinha	:= Len(aColumns)
      cCampo 	:= GetSx3Cache( aCampos[nX], "X3_CAMPO" )
      cTipo   := GetSx3Cache( cCampo, "X3_TIPO" )
      aColumns[nLinha]:SetType( cTipo )

      //|Monta campos do filtro |
      If cTipo != "D"
        aAdd( aFilters,  {;
          cCampo,;
          GetSx3Cache( cCampo, "X3_TITULO" ),;
          cTipo,;
          GetSx3Cache( cCampo, "X3_TAMANHO" ),;
          GetSx3Cache( cCampo, "X3_DECIMAL" ),;
          PesqPict( "SE1", cCampo );
          })
      EndIf

      If cTipo == "D"
        aColumns[nLinha]:SetData( &("{|| StoD("  + "('"+cAlias+"')->" + cCampo + ") }") )
      Else
        aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
      EndIf

      aColumns[nLinha]:SetTitle( GetSx3Cache( cCampo, "X3_TITULO" ) )
      aColumns[nLinha]:SetSize( GetSx3Cache( cCampo, "X3_TAMANHO" ) )
      aColumns[nLinha]:SetDecimal( GetSx3Cache( cCampo, "X3_DECIMAL" ) )
      aColumns[nLinha]:SetPicture( PesqPict( "SC7", cCampo ) )

    ElseIf aCampos[nX] == "RECNO"

      cCampo := "RECNO"
      AAdd(aColumns,FWBrwColumn():New())
      nLinha := Len(aColumns)
      aColumns[nLinha]:SetData( &("{|| " + "('"+cAlias+"')->" + cCampo + " }") )
      aColumns[nLinha]:SetTitle("RECNO")
      aColumns[nLinha]:SetType("C")
      aColumns[nLinha]:SetPicture("9999999")
      aColumns[nLinha]:SetSize(7)
      aColumns[nLinha]:SetDecimal(0)

    EndIf

  Next nX


  RestArea(aArea)

Return { aColumns, aFilters }


/*/{Protheus.doc} LegendBrw
Monta interface com as legenda do browse
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 02/03/2021
/*/
Static Function LegendBrw()

  Local oLegenda  := FWLegend():New()
  Local aDados    := fLegenda(.F.)
  Local nI        := 0

  For nI := 1 To Len(aDados)

    oLegenda:Add( "",aDados[nI,2]	,aDados[nI,3] )

  Next nI

  oLegenda:Activate()
  oLegenda:View()
  oLegenda:DeActivate()

Return Nil


Static Function fLegenda(lCor)

  Local aLegenda    := {}
  Local nI          := 0
  Local xRet        := ""

  Default lCor      := .T.

  xRet        := IIf(lCor, "", {})

  aAdd( aLegenda, { "(oBrowse:Alias())->C7_YSTLCX == 'B'", "BR_VERMELHO"   , "Bloqueado por limite de caixa" } )
  aAdd( aLegenda, { "(oBrowse:Alias())->C7_YSTLCX == 'A'", "BR_VERDE"      , "Aprovado no limite de caixa" } )

  If lCor
    For nI := 1 To Len(aLegenda)

      If &( aLegenda[nI, 1] )

        xRet  := aLegenda[nI, 2]
        Exit

      EndIf

    Next nI

  Else
    xRet  := aClone(aLegenda)
  EndIf

Return xRet



Static Function fProcessa(xProc)

  Local aArea       := GetArea()
  Local cSeek       := ""
  Local bWhile      :={|| C7_FILIAL + C7_NUM }

  //|variaveis tela |
  Local aObjects    := {}
  Local aInfo       := {}
  Local aSizeAut    := MsAdvSize(.F.) // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

  //|variaveis msmget |
  Local aCposTela   := {}
  Local aCposE      := GetCpos( @aCposTela )
  Local aPosMsmGet  :={0, 0, 100, 700}

  //|Variaveis do msnewgetdados |
  Private _aHeader  := {}
  Private _aCols    := {}
  Private _aHeadDep := {}
  Private _aColsDep := {}

  Private _aHeader2 := {}
  Private _aCols2   := {}

  Private oFolder1  := NIL
  Private oFW199    := FWLayer():New()

  Private oFolderG  := Nil
	Private oPanelGrp := Nil
	Private oPanelDep := Nil
  
  aObjects := {}
  aAdd( aObjects, { 000, 100 , .T. , .F. } )//folder
  aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
  aPos  := MsObjSize (aInfo, aObjects,.F.)

  oDlg199      := MSDialog():New( aSizeAut[7],000,aSizeAut[6],aSizeAut[5],"Gerenciar Pedido de Compra",,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.)

  @ aPos[1,1],aPos[1,2] FOLDER oFolder1 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1] OF oDlg199 ITEMS "Limite de Caixa","Itens do Pedido de Compra" COLORS 0, 16777215 PIXEL
  oFolder1:ALIGN := CONTROL_ALIGN_ALLCLIENT

  oFW199:Init(oFolder1:aDialogs[1],.F.)
  oFW199:AddCollumn('Col1',100,.F.)
  oFW199:AddWindow('Col1','Win1','Detalhes do Pedido',30,.T.,.F.)
  oFW199:AddWindow('Col1','Win3','Gerenciar',70,.T.,.F.)

  oPnlTop199	  := oFW199:GetWinPanel('Col1','Win1')
  oPnlTop199:FreeChildren()

  oPnlDown199 	:= oFW199:GetWinPanel('Col1','Win3')
  oPnlDown199:FreeChildren()
    // Divisão da Window Inferior - Gerenciar.
    oFolderG := TFolder():New(,, {"Grupo de Produto", "Departamento"}, {"HEADER"}, oPnlDown199,,,, .T., .F., /*L#W*/(oPnlDown199:nWidth/2),(oPnlDown199:nWidth/2)/*A#H*/ ,)
	      oPanelGrp := TPanel():New(01,01,"", oFolderG:aDialogs[1],,,,,,oFolderG:nWidth - (oFolderG:aDialogs[1]:nClientHeight - oFolderG:aDialogs[1]:oWnd:nHeight) - 15;
                                                                     , oFolderG:nWidth,.T.,.T.)
	      oPanelDep := TPanel():New(01,01,"", oFolderG:aDialogs[2],,,,,,oFolderG:nWidth - (oFolderG:aDialogs[2]:nClientHeight - oFolderG:aDialogs[2]:oWnd:nHeight) - 15;
                                                                     , oFolderG:nWidth,.T.,.T.)

  //|Posiciona no pedido a ser gerenciado |
  cSeek := (oBrowse:Alias())->C7_FILIAL + (oBrowse:Alias())->C7_NUM

  dbSelectArea("SC7")
  SC7->( dbSetOrder(1) )
  If !SC7->( dbSeek( cSeek ) )
    MsgAlert("Não foi possível encontrar o pedido selecionado, talvez ele tenha sido excluído.", "BIAFP003")
    Return
  EndIf

  RegToMemory("SC7",.F.)

  //|###############################
  //|#### ABA 1 PAINEL SUPERIOR ####
  //|###############################
  oEnch199 := MSMGet():New( ,0,2,,,,aCposTela,aPosMsmGet,,,,,,oPnlTop199,.F.,.T.,.F.,,,,aCposE )
  oEnch199:oBox:Align 	:= CONTROL_ALIGN_ALLCLIENT

  //|###############################
  //|#### ABA 1 PAINEL INFERIOR ####
  //|###############################
  CursorWait()

  //|Alimenta o aHeader |
  fGetHeader()
  
  FWMsgRun( , { || fGetCols() }, "Aguarde", "Buscando os dados do pedido..." )

  // Referência de informações para : Grupo de Produtos.
  _oGetDados := MsNewGetDados():New(0, 0, 100, 100, 0, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, ;
                /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*"U_BG105DOK()"*/ /*[ cDelOk]*/;
                , oPanelGrp, _aHeader, _aCols)

  _oGetDados:oBrowse:lUseDefaultColors := .F.
  _oGetDados:oBrowse:SetBlkBackColor( { || fCorGrid( _oGetDados:aCols, _oGetDados:nAt, _oGetDados:aHeader, "GRP" ) } )

  _oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  // Referência de informações para : Classe de Valor / Departamento.
  _oGetDDep := MsNewGetDados():New(0, 0, 100, 100, 0, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, ;
              /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*"U_BG105DOK()"*/ /*[ cDelOk]*/;
              , /*oPnlDown199*/oPanelDep, _aHeadDep, _aColsDep)

  _oGetDDep:oBrowse:lUseDefaultColors := .F.
  _oGetDDep:oBrowse:SetBlkBackColor( { || fCorGrid( _oGetDDep:aCols, _oGetDDep:nAt, _oGetDDep:aHeader, "DEP" ) } )

  _oGetDDep:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  //|###############################
  //|#### ABA 2 ITENS DO PEDIDO ####
  //|###############################
  FillGetDados(2,"SC7",1,cSeek,bWhile,,/*aNoFields*/,,,,,,@_aHeader2,@_aCols2)

  _oGet2 := MsNewGetDados():New(0, 0, 100, 100, 2, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, ;
            /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*"U_BG105DOK()"*/ /*[ cDelOk]*/;
            , oFolder1:aDialogs[2], _aHeader2, _aCols2)
  _oGet2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  CursorArrow() 

  //|Abre a tela posicionado na aba de Departamento |
  oFolderG:ShowPage(2)         

  Activate MsDialog oDlg199 Centered on Init EnchoiceBar(oDlg199, {|| fAprovar() }, {|| oDlg199:End()})

  RestArea( aArea )

Return


Static Function GetCpos(aTela)

	Local _aCpos	      := {}
  Local cCampos		    := "C7_NUM/C7_EMISSAO/C7_YDATCHE/C7_YAPRLCX/C7_YNAPLCX/C7_YDTALCX/C7_YDTCLCX/C7_FORNECE/C7_LOJA"

	dbSelectArea("SX3")
	SX3->( dbSetOrder(1) )
	
	If SX3->( dbSeek("SC7") )

		While !SX3->( EoF() ) .And. SX3->X3_ARQUIVO == "SC7"

			If AllTrim(SX3->X3_CAMPO) $ cCampos

        aAdd(aTela, SX3->X3_CAMPO )

				aAdd(_aCpos, { ;
            X3Titulo(),;
            SX3->X3_CAMPO,;
            SX3->X3_TIPO,;
            SX3->X3_TAMANHO,;
            SX3->X3_DECIMAL,;
            SX3->X3_PICTURE,;
            SX3->X3_VALID,;
            .F.,;
            SX3->X3_NIVEL,;
            SX3->X3_RELACAO,;
            "",;
            .T.,;
            .T.,;
            "",;
            "",;
            "",;
            "",;
            "",;
            "";
         })

			EndIf

			SX3->( DbSkip() )

		EndDo

	EndIF

Return _aCpos


Static Function fGetHeader()

  Local aTam          := {}
  Local cPictValor    := PesqPict('SC7', 'C7_TOTAL')
  Local cPictPercent  := PesqPict('SC7', 'C7_TOTAL')

  // MONTAGEM DO AHEADER (CABEÇALHO)
  // Grupo de Produto.
  aTam := TamSX3('BM_GRUPO')				
  aAdd(_aHeader, {RetTitle("BM_GRUPO")	 , 'BM_GRUPO'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'SBM', ''}) // Grupo de produtos

  aTam := TamSX3('BM_DESC')				
  aAdd(_aHeader, {RetTitle("BM_DESC")	 , 'BM_DESC'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'SBM', ''}) // Descrição do grupo

  aTam := TamSX3('C7_CLVL')				
  aAdd(_aHeader, {RetTitle("C7_CLVL")	 , 'C7_CLVL'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'SC7', ''}) // Classe de valor

  aTam := {14 , 2}			
  aAdd(_aHeader, {"Meta R$"	 , 'META'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Meta do grupo

  aTam := {14 , 2}			
  aAdd(_aHeader, {"Realizado R$"	 , 'REALIZADO'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Valor já realizado

  aTam := {14 , 2}			
  aAdd(_aHeader, {"Saldo R$"	 , 'SALDO'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Saldo do grupo

  aTam := {14 , 2}			
  aAdd(_aHeader, {"Valor PC R$"	 , 'VALOR'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Valor do pedido de compra

  aTam := {14 , 2}			
  aAdd(_aHeader, {"Novo Saldo R$"	 , 'SALDOFINAL'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Saldo final da meta

  aTam := {14 , 2}			
  aAdd(_aHeader, {"% Gatilho"	 , 'PERCGAT'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Percentual de gatilho

  aTam := {14 , 2}			
  aAdd(_aHeader, {"% Meta"	 , 'PERCMETA'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Percentual de meta

  aTam := {14 , 2}			
  aAdd(_aHeader, {"% Realizado"	 , 'GATILHO'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''}) // Percentual da meta atingido

  aAdd(_aHeader, {"Reg."	 , 'REG'	, "@!", 10, 0, '' , .T., 'C', '', ''}) 

  // Classe de Valor / Departamento.
  aTam := TamSX3('ZCA_ENTID')				
  aAdd(_aHeadDep, {"Departamento"	 , 'ZCA_ENTID'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'ZCA', ''})    // Classe de Valor / Departamento

  aTam := TamSX3('ZCA_DESCRI')				
  aAdd(_aHeadDep, {RetTitle("ZCA_DESCRI")	 , 'ZCA_DESCRI'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'ZCA', ''})  // Descrição do Classe de Valor / Departamento

  aTam := TamSX3('C7_CLVL')				
  aAdd(_aHeadDep, {RetTitle("C7_CLVL")	 , 'C7_CLVL'	, "@!", aTam[1], aTam[2], '' , .T., 'C', 'SC7', ''})        // Classe de valor

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"Meta R$"	 , 'META'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''})                   // Meta do grupo

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"Realizado R$"	 , 'REALIZADO'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''})       // Valor já realizado

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"Saldo R$"	 , 'SALDO'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''})               // Saldo do grupo

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"Valor PC R$"	 , 'VALOR'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''})             // Valor do pedido de compra

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"Novo Saldo R$"	 , 'SALDOFINAL'	, cPictValor, aTam[1], aTam[2], '' , .T., 'N', '', ''})       // Saldo final da meta

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"% Gatilho"	 , 'PERCGAT'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''})           // Percentual de gatilho

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"% Meta"	 , 'PERCMETA'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''})             // Percentual de meta

  aTam := {14 , 2}			
  aAdd(_aHeadDep, {"% Realizado"	 , 'GATILHO'	, cPictPercent, aTam[1], aTam[2], '' , .T., 'N', '', ''})         // Percentual da meta atingido

  aAdd(_aHeadDep, {"Reg."	 , 'REG'	, "@!", 10, 0, '' , .T., 'C', '', ''}) 

Return


Static Function fGetCols()

  Local oObj          := TFPGestaoLimiteCaixa():New()
  Local oDados        := Nil
  Local nX            := 0
  Local aColsAux      := {}

  oObj:cFilPed        := (oBrowse:Alias())->C7_FILIAL
  oObj:cPedido        := (oBrowse:Alias())->C7_NUM

  oObj:GetInfo()

  //|Limpa variaveis |
  _aCols      := {}
  _aColsDep   := {}

  //|Dados do Grupo de Produtos |
  For nX := 1 To oObj:oLstGrupo:GetCount()

    aColsAux  := {}

    oDados    := oObj:oLstGrupo:GetItem(nX)
    
    aAdd( aColsAux, oDados:cCodGrupo )
    aAdd( aColsAux, oDados:cDescGrupo )
    aAdd( aColsAux, oDados:cClvlAprovador )
    aAdd( aColsAux, oDados:nMetaGrupo )
    aAdd( aColsAux, oDados:nRealizado )
    aAdd( aColsAux, oDados:nSaldo )
    aAdd( aColsAux, oDados:nVlrPedido )
    aAdd( aColsAux, oDados:nNovoSaldo )
    aAdd( aColsAux, oDados:nPercGatilho )
    aAdd( aColsAux, oDados:nPercMeta )
    aAdd( aColsAux, oDados:nPercRealizado )
    aAdd( aColsAux, "" )
    
    //|Cor da linha |
    aAdd( aColsAux, oDados:cCor )

    //|Deletado |
    aAdd( aColsAux, .F. )

    //|Adiciona a linha no aCols |
    aAdd( _aCols, aClone(aColsAux) )
  
  Next nX

  //|Dados da Classe de Valor / Departamento |
  For nX := 1 To oObj:oLstDepto:GetCount()

    oDados    := oObj:oLstDepto:GetItem(nX)

    aColsAux  := {}

    aAdd( aColsAux, oDados:cCodClassVl )
    aAdd( aColsAux, oDados:cDescClasVl )
    aAdd( aColsAux, oDados:cClvlAprovador )
    aAdd( aColsAux, oDados:nMetaClasVl )
    aAdd( aColsAux, oDados:nRealClasVl )
    aAdd( aColsAux, oDados:nSaldoClsVl )
    aAdd( aColsAux, oDados:nVlrPedido )
    aAdd( aColsAux, oDados:nNvSaldoClV )
    aAdd( aColsAux, oDados:nPerGatClsV )
    aAdd( aColsAux, oDados:nPerMetaClV )
    aAdd( aColsAux, oDados:nPerRealClV )
    aAdd( aColsAux, "" )

    //|Cor da linha |
    aAdd( aColsAux, oDados:cCorClsV )

    //|Deletado |
    aAdd( aColsAux, .F. )

    //|Adiciona a linha no aCols |
    aAdd( _aColsDep, aClone(aColsAux) )

  Next nX

  If Len(_aCols) == 0
    aAdd(_aCols, Array(Len(_aHeader) + 2) )
  EndIf

  If Len(_aColsDep) == 0
    aAdd(_aColsDep, Array(Len(_aHeadDep) + 2) )
  EndIf

  If Type("_oGetDados") != "U"
    _oGetDados:aCols := _aCols
    _oGetDados:Refresh()
  EndIf

  If Type("_oGetDDep") != "U"
    _oGetDDep:aCols := _aColsDep
    _oGetDDep:Refresh()
  EndIf

  FreeObj(oDados)
  FreeObj(oObj)

Return


Static Function fCorGrid(aLinha, nLinha, aHeader, pGet)

  Local _nPosCor	  := Len(aHeader) + 1
	Local nRet        := CLRWHITE

  Default pGet      := ""

  If !Empty(pGet)
    If ( pGet == "GRP" )
    
      If _oGetDados:aCols[nLinha,_nPosCor] == "vermelho"
        nRet	:= CLRRED
      ElseIf _oGetDados:aCols[nLinha,_nPosCor] == "amarelo"
        nRet	:=	CLRYELLOW
      ElseIf _oGetDados:aCols[nLinha,_nPosCor] == "verde"
        nRet	:=	CLRGREEN
      EndIF
    
    ElseIf ( pGet == "DEP" )
    
      If (_oGetDDep:aCols[nLinha,_nPosCor] == "vermelho")
        nRet	:= CLRRED
      ElseIf (_oGetDDep:aCols[nLinha,_nPosCor] == "amarelo")
        nRet	:=	CLRYELLOW
      ElseIf (_oGetDDep:aCols[nLinha,_nPosCor] == "verde")
        nRet	:=	CLRGREEN
      EndIF
    
    EndIf
  EndIf

Return nRet


/*/{Protheus.doc} fReavaliar
Rotina para executar a avaliação do pedido
@type function
@version 1.0
@author Facile - Pontin
@since 26/11/2020
/*/
Static Function fReavaliar()

  Local oObj          := TFPGestaoLimiteCaixa():New()

  oObj:cFilPed        := (oBrowse:Alias())->C7_FILIAL
  oObj:cPedido        := (oBrowse:Alias())->C7_NUM

  FWMsgRun( , { || oObj:Calculate() }, "Aguarde", "Estamos reavaliando o pedido de compra..." )

  ExecFil("Atualizando a tela...")

Return


/*/{Protheus.doc} fAprovar
Função responsável por gerenciar a aprovação
@type function
@version 1.0
@author Facile - POntin
@since 26/11/2020
/*/
Static Function fAprovar()

  Local lAprovado     := .F.

  If (oBrowse:Alias())->C7_YSTLCX == "B"
  
    If MsgYesNo( "Deseja aprovar o pedido de compras no processo de Gestão do Limite de Caixa?", "APROVAÇÃO" )

      //|Valida se o usuário logado pode aprovar |
      If fValAprovador( (oBrowse:Alias())->C7_YAPRLCX )

        //|Atualiza o pedido para aprovado |
        fUpdPedido( (oBrowse:Alias())->C7_FILIAL, (oBrowse:Alias())->C7_NUM )

        lAprovado     := .T.

      Else
        MsgInfo("Seu usuário não tem permissão para aprovar esse pedido de compra!", FunName() )
      EndIf


    EndIf

    If lAprovado
      oDlg199:End()

      ExecFil("Atualizando a tela...")
    EndIf

  Else
    oDlg199:End()
  EndIf 

Return


/*/{Protheus.doc} fValAprovador
Valida se o usuário tem permissão de aprovar o pedido de compra
@type function
@version 1.0
@author Facile - Pontin
@since 26/11/2020
@param cIdAprovador, character, ID do aprovador do pedido
@return logical, Aprovado ou reprovado
/*/
Static Function fValAprovador( cIdAprovador )

  Local lOk         := .F.
  Local cEmailUsr   := ""
  Local cEmailAprov := ""
  Local cEmailSup   := ""
  Local cCorMaior   := "verde"
  Local cClvl       := ""
  Local nI          := 0
  Local lAprovDepto := .T.
  Local oGet        := IIf( lAprovDepto, _oGetDDep, _oGetDados )
  Local _nPosCor	  :=	Len(oGet:aHeader) + 1
  Local aAllUsers   := FWSFALLUSERS( {__cUserID }, { 'USR_EMAIL'} )
  Local aAprovs     := {}
  Local oObj        := TFPGestaoLimiteCaixa():New()

  //|Busca o e-mail no cadastro de usuários |
	If Len(aAllUsers) > 0 .And. Len(aAllUsers[1]) > 0

		If Len(aAllUsers[1]) > 0

			cEmailUsr := aAllUsers[1][3]

		EndIf

	EndIf

  //|Busca o maior nível de bloqueio e a classe de valor |
  For nI := 1 To Len( oGet:aCols )

    If oGet:aCols[nI, _nPosCor] == "vermelho"
      cCorMaior   := "vermelho"
    EndIf

    If oGet:aCols[nI, _nPosCor] == "amarelo" .And. cCorMaior != "vermelho"
      cCorMaior   := "amarelo"
    EndIf

    If Empty(cClvl)
      cClvl   := IIf( lAprovDepto, oGet:aCols[nI, 1], oGet:aCols[nI, 3] )
    EndIf

  Next nI

  //|Busca o e-mail no cadastro de aprovadores |
  aAprovs   := oObj:GetAprovador( cCorMaior, cClvl, cIdAprovador )

  cEmailAprov   := aAprovs[7]
  cEmailSup     := aAprovs[8]
	
  //|Valida o usuário designado como aprovador |
	If AllTrim( Upper(cEmailUsr) ) == AllTrim( Upper(cEmailAprov) )

		lOk := .T.

  ElseIf AllTrim( Upper(cEmailUsr) ) == AllTrim( Upper(cEmailSup) )   //|Valida se é o superior |

    lOk := .T.

	EndIf

Return lOk


/*/{Protheus.doc} fUpdPedido
Atualiza o pedido para aprovado
@type function
@version 1.0
@author Facile - Pontin
@since 26/11/2020
@param cFilPed, character, Filial do Pedido
@param cPedido, character, Codigo do Pedido
/*/
Static Function fUpdPedido( cFilPed, cPedido )

  Local aArea     := GetArea()
  Local aAreaSC7  := SC7->( GetArea() )

  dbSelectArea("SC7")
  SC7->( dbSetOrder(1) )
  SC7->( dbSeek( cFilPed + cPedido ) )

  While !SC7->( EoF() ) .And. SC7->C7_FILIAL == cFilPed .And. SC7->C7_NUM == cPedido

    RecLock("SC7", .F.)

    SC7->C7_YSTLCX  := "A"
    SC7->C7_YDTALCX := DtoC( Date() ) + " " + SubStr( Time(), 1, 5 )

    SC7->( MsUnLock() )

    SC7->( dbSkip() )

  EndDo

  RestArea(aAreaSC7)
  RestArea(aArea)

Return
