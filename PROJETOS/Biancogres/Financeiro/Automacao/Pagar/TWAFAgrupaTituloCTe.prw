#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

// IDENTIFICADORES DE LINHA
#DEFINE LIN_UP "LIN_UP"
#DEFINE LIN_DOWN "LIN_DOWN"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_UP 100
#DEFINE PER_LIN_DOWN 50

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_UP "WND_UP"
#DEFINE WND_DOWN "WND_DOWN"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Gerar título de liquidação"
#DEFINE TIT_WND_UP "Selecione os títulos para gerar o título de liquidação"

Class TWAFAgrupaTituloCTe From LongClassName

	Data oDlg // Janela principal
	Data cCadastro
	Data oLayer	// Organizador de objetos
	Data oSize
	Data oSplitter
	Data aCampos
	Data aStru
	Data aStruMKB
	
	Data oPanel
	Data oPnlBtn
	Data oPnlBtn2
	Data oPnlBtn3
	Data oPnl_A
	Data oPnl_B
	Data oPnl_B01
	Data oPnl_C
	
	Data oBtnAdd
	Data oBtnCh2
	Data oBtnChk
	Data oBtnDel
	Data oBtnFiltro
	
	// Paineis
	Data oPnlUp // Painel acima
	Data oPnlDown // Painel abaixo
	
	Data oBusiness // Objeto com as regras de negocio de importação

	Data oTmpTable1
	Data oTmpTable2

	Data cAlias1
	Data cAlias2
	Data oMarca1
	Data oMarca2
	Data cMarca1
	Data cMarca2
	
	Data oSay1
	Data oSay2
	Data cDesTitFat
	Data cDesTitulo
	
	Data cFornece
	Data cLoja
	Data cRaizCnpj
	Data dEmisDe
	Data dEmisAte
	Data cNatureza
		
	Method New() Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLineUp() // Carrega a interface da linha Acima
	
	Method LoadTable(lLoad)
	Method CreateStruct()
	Method CreateTemp()
	Method DropTemp(oTempTable)
	Method GetSql(cRecnoIn)
	Method TotalTitSel(cAlias, oMarca, cMarca, oSay, cMsg, cTitulo)
	Method Confirma()
	Method Filtro(lLoad)
	Method Refresh()
	
	Method Add(cAlias, oMarca, cMarca, cAliasPara, oMarcaPara)
	Method Check(nOp, cAlias, oMarca, cMarca)
	Method CheckAll(cAlias, oMarca, cMarca )
	
	Method Activate() // Ativa exibicao do objeto

EndClass


// Construtor da classe
Method New() Class TWAFAgrupaTituloCTe
	
	::cCadastro := TIT_MAIN_WND
	
	::oDlg := Nil
	::oSize := Nil
	::oLayer := Nil
	::oBusiness := Nil
	::oSplitter := Nil
	::aCampos := {}
	::aStru := {}
	::aStruMKB := {}
	
	::oPnlUp := Nil
	::oPnlDown := Nil
	::oPanel := Nil
	::oPnlBtn := Nil
	::oPnlBtn2 := Nil
	::oPnlBtn3 := Nil
	::oPnlDown := Nil
	::oPnlUp := Nil
	::oPnl_A := Nil
	::oPnl_B := Nil
	::oPnl_B01 := Nil
	::oPnl_C := Nil

	::oBtnAdd := Nil
	::oBtnCh2 := Nil
	::oBtnChk := Nil
	::oBtnDel := Nil
	::oBtnFiltro := Nil
	
	::oTmpTable1 := Nil
	::oTmpTable2 := Nil

	::cAlias1 := ""
	::cAlias2 := ""
	::oMarca1 := Nil
	::oMarca2 := Nil
	::cMarca1 := GetMark()
	::cMarca2 := GetMark()
	
	::oSay1 := Nil
	::oSay2 := Nil
	::cDesTitulo := " "
	::cDesTitFat := ""

	::cFornece := PADR("",	TamSX3("E2_FORNECE")[1], " ")
	::cLoja := PADR("", TamSX3("E2_LOJA")[1], " ")
	::cRaizCnpj := Space(8)
	::dEmisDe := CTOD("  /  /  ")
	::dEmisAte := dDataBase
	::cNatureza := PADR("", TamSX3("E2_NATUREZ")[1], " ")
	
Return()


// Contrutor da interface
Method LoadInterface() Class TWAFAgrupaTituloCTe

	::LoadDialog()

	::LoadLayer()

	::LoadLineUp()

Return()


// Carrega Dialog Principal
Method LoadDialog() Class TWAFAgrupaTituloCTe
	
	::oSize := FWDefSize():New(.T.)
	
	::oSize:AddObject( "PANEL", 100, 100, .T., .T. ) // Adiciona enchoice
	
	//::oSize:lProp := .T.
	
	//::oSize:SetWindowSize({000,000, GetScreenRes()[2], GetScreenRes()[1]})
	::oSize:lLateral := .F.  // Calculo vertical
	::oSize:Process() //executa os calculos
	
	::oDlg := MsDialog():New(::oSize:aWindSize[1], ::oSize:aWindSize[2], ::oSize:aWindSize[3], ::oSize:aWindSize[4], TIT_MAIN_WND,,,,nOR(WS_VISIBLE, WS_POPUP),,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lMaximized := .T.
	
Return()


Method LoadLayer() Class TWAFAgrupaTituloCTe

	::oLayer := FWLayer():New()

	::oPanel := TPanel():New(;
		::oSize:GetDimension("PANEL","LININI"),;
		::oSize:GetDimension("PANEL","COLINI"),,::oDlg,,,,,,;
		::oSize:GetDimension("PANEL","XSIZE"),;
		::oSize:GetDimension("PANEL","YSIZE"),.F.,.F. )
	
	::oLayer:Init(::oPanel, .F., .F.)
	
Return()


// Carrega Linha Acima
Method LoadLineUp() Class TWAFAgrupaTituloCTe

	Private cMarca1 := @::cMarca1
	Private cMarca2 := @::cMarca2
	
	// Linha acima com 10% da tela
	::oLayer:AddLine(LIN_UP, PER_LIN_UP, .F.)
	
	// Coluna com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN_UP)
	
	// Janela acima 
	::oLayer:AddWindow(COL, WND_UP, TIT_WND_UP, 100, .F. ,.T.,, LIN_UP, { || })
	
	// Painel acima
	::oPnlUp := ::oLayer:GetWinPanel(COL, WND_UP, LIN_UP)
	
	::oPnl_A := TPanel():New(00,00,,::oPnlUp,,,,,,10,20,.F.,.F.)
	::oPnl_A:Align := CONTROL_ALIGN_ALLCLIENT
	
	::oSplitter := TSplitter():New( 0,0,::oPnlUp,100,100,1 )
	::oSplitter:Align := CONTROL_ALIGN_ALLCLIENT
	
	::oPnl_B := TPanel():New(01,01,,::oSplitter,,,,,,0,0,.F.,.T.)
	::oPnl_B:Align := CONTROL_ALIGN_TOP
	
	::oPnl_B01 := TPanel():New(00,00,,::oPnl_B,,,,,RGB(67,70,87),15,15,.F.,.F.)
	::oPnl_B01:Align := CONTROL_ALIGN_LEFT
	
	::oBtnAdd  := TBtnBmp():NewBar("PMSSETADOWN", "PMSSETADOWN",,,,{|| ::Add(::cAlias1, ::oMarca1, ::cMarca1, ::cAlias2, ::oMarca2)},, ::oPnl_B01,,, "",,,,, "")
	::oBtnAdd:cToolTip := "Adicionar"
	::oBtnAdd:Align    := CONTROL_ALIGN_TOP
	
	::oBtnFiltro			:= TBtnBmp():NewBar("brw_filtro","brw_filtro",,,,{|| ::Filtro(.T.)},,::oPnl_B01,,,"",,,,,"")
	::oBtnFiltro:cToolTip := "Filtrar"
	::oBtnFiltro:Align    := CONTROL_ALIGN_TOP
	
	::oBtnChk := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||::Check(1, ::cAlias1, ::oMarca1, ::cMarca1)},,::oPnl_B01,,,"",,,,,"")
	::oBtnChk:cToolTip := "Marca todos os títulos em tela"
	::oBtnChk:Align    := CONTROL_ALIGN_TOP
	
	::oBtnChk := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||::Check(2, ::cAlias1, ::oMarca1, ::cMarca1)},,::oPnl_B01,,,"",,,,,"")
	::oBtnChk:cToolTip := "Desmarca todos os títulos em tela"
	::oBtnChk:Align    := CONTROL_ALIGN_TOP
	
	::oPnlBtn := TPanel():New(00,00,,::oPnl_B,,,,,RGB(67,70,87),12,12,.F.,.F.)
	::oPnlBtn:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	//@ 03,14  Say "STR0017 " Of ::oPnlBtn COLOR CLR_WHITE Pixel font oFont12B  //"Selecione títulos da Fatura "
	
	::oSay1 := TSay():New( 003,020,{|| ::cDesTitulo},::oPnlBtn,,oFont12B,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
	
	::oPnl_C := TPanel():New(01,01,,::oSplitter,,,,,,0,0,.F.,.T.)
	::oPnl_C:Align := CONTROL_ALIGN_BOTTOM
	
	::oPnlBtn2 := TPanel():New(00,00,,::oPnl_C,,,,,RGB(67,70,87),15,15,.F.,.F.)
	::oPnlBtn2:Align := CONTROL_ALIGN_LEFT
	
	::oBtnDel  := TBtnBmp():NewBar("PMSSETAUP","PMSSETAUP",,,,{|| ::Add(::cAlias2, ::oMarca2, ::cMarca2, ::cAlias1, ::oMarca1)},,::oPnlBtn2,,,"",,,,,"")
	::oBtnDel:cToolTip := "Excluir"
	::oBtnDel:Align    := CONTROL_ALIGN_TOP
	
	::oBtnCh2 := TBtnBmp():NewBar("CHECKED","CHECKED",,,,{||::Check(1, ::cAlias2, ::oMarca2, ::cMarca2)},,::oPnlBtn2,,,"",,,,,"")
	::oBtnCh2:cToolTip := "Marca todos os títulos em tela"
	::oBtnCh2:Align    := CONTROL_ALIGN_TOP
	
	::oBtnCh2 := TBtnBmp():NewBar("UNCHECKED","UNCHECKED",,,,{||::Check(2, ::cAlias2, ::oMarca2, ::cMarca2)},,::oPnlBtn2,,,"",,,,,"")
	::oBtnCh2:cToolTip := "Desmarca todos os títulos em tela"
	::oBtnCh2:Align    := CONTROL_ALIGN_TOP
	
	::oPnlBtn3 := TPanel():New(00,00,,::oPnl_C,,,,,RGB(67,70,87),12,12,.F.,.F.)
	::oPnlBtn3:Align := CONTROL_ALIGN_TOP
	oFont12B := TFont():New('Arial',,-12,,.T.)
	//@ 03,14  Say "STR0019 " Of ::oPnlBtn3 COLOR CLR_WHITE Pixel font oFont12B 	 //""
	
	::oSay2 := TSay():New( 003,014,{|| ::cDesTitFat},::oPnlBtn3,,oFont12B,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
	
	::Filtro()

	DBSelectArea(::cAlias1)
	(::cAlias1)->(DBSetOrder(1) )
	(::cAlias1)->(DBGoTop())
	
	::oMarca1 := MsSelect():New(::cAlias1,"OK",,::aStruMKB,,@::cMarca1,{0,0,0,0},,,::oPnl_B)
	::oMarca1:oBrowse:cToolTip := "Títulos da Fatura"
	::oMarca1:oBrowse:bAllMark := {|| ::CheckAll(::cAlias1, ::oMarca1, ::cMarca1) }
	::oMarca1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	DBSelectArea(::cAlias2)
	(::cAlias2)->(DBSetOrder(1) )
	(::cAlias2)->(DBGoTop())
	
	::oMarca2 := MsSelect():New(::cAlias2,"OK",,::aStruMKB,,@::cMarca2,{0,0,0,0},,,::oPnl_C)
	::oMarca2:oBrowse:bAllMark := {|| ::CheckAll(::cAlias2, ::oMarca2, ::cMarca2) }
	::oMarca2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
	::Refresh()
	
Return()


Method Add(cAlias, oMarca, cMarca, cAliasPara, oMarcaPara) Class TWAFAgrupaTituloCTe
	
	Local nX := 0
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	While (cAlias)->(! Eof())
	
		If (cAlias)->OK == cMarca
		
			RecLock(cAliasPara, .T.)
	
			For nX := 1 To (cAlias)->(FCount())
			
				If (cAlias)->(Field(nX)) == "OK"
				
					(cAliasPara)->(FieldGet(nX)) := "  "
				
				Else
				
					(cAliasPara)->(FieldPut(nX, (cAlias)->(FieldGet(nX))))
				
				EndIf
				
			Next nX
	
			(cAliasPara)->(MsUnlock())
			
			RecLock(cAlias, .F.)
			(cAlias)->(DBDelete())
			(cAlias)->(MsUnlock())
	        
		EndIf
        
		(cAlias)->(dbSkip())
    
	EndDo
    
	::Refresh()
    
	(cAlias)->(DBGoTop())
	
	oMarca:oBrowse:Refresh()
	
	oMarcaPara:oBrowse:Refresh()
	
	(cAliasPara)->(DBGoTop())

Return(.T.)

Method Check(nOp, cAlias, oMarca, cMarca) Class TWAFAgrupaTituloCTe

	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	While !Eof()
	
		If If(nOp==1,!IsMark("OK", cMarca ),IsMark("OK",cMarca ))
			RecLock(cAlias,.F.)
			(cAlias)->OK := If(nOp==1, cMarca, " ")
			(cAlias)->(MsUnlock())
		EndIf
	
		(cAlias)->(dbSkip())
		
	EndDo
	
	(cAlias)->(DBGoTop())
	
	oMarca:oBrowse:Refresh()
	
Return()

Method CheckAll(cAlias, oMarca, cMarca ) Class TWAFAgrupaTituloCTe

	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	While !Eof()
    
		RecLock(cAlias,.F.)
		(cAlias)->OK := If(IsMark("OK", cMarca ), " ",  cMarca )
		(cAlias)->(MsUnlock())
        
		(cAlias)->(dbSkip())
    
	EndDo
    
	(cAlias)->(DBGoTop())
	
	oMarca:oBrowse:Refresh()

Return()


Method Activate() Class TWAFAgrupaTituloCTe
	
	Local bOk := {|| ::Confirma()}
	Local bCancel := {|| ::oDlg:End()}
	
	::LoadInterface()
	
	::oDlg:Activate(,,,.T.,,,EnchoiceBar(::oDlg, bOk, bCancel))
	
	::DropTemp(::oTmpTable1)
	
	::DropTemp(::oTmpTable2)
	
Return()


Method LoadTable(lLoad) Class TWAFAgrupaTituloCTe
	
	::aCampos := {}
	::aStru := {}
	::aStruMKB := {}
			
	AADD(::aCampos, "OK")
	AADD(::aCampos, "A2_CGC")
	AADD(::aCampos, "E2_PREFIXO")
	AADD(::aCampos, "E2_NUM")
	AADD(::aCampos, "E2_PARCELA")
	AADD(::aCampos, "E2_TIPO")
	AADD(::aCampos, "E2_FORNECE")
	AADD(::aCampos, "E2_LOJA")
	AADD(::aCampos, "E2_NOMFOR")
	AADD(::aCampos, "E2_EMISSAO")
	AADD(::aCampos, "E2_VENCTO")
	AADD(::aCampos, "E2_VALOR")
	AADD(::aCampos, "E2_SALDO")
	//AADD(::aCampos, "E2_HIST")
	AADD(::aCampos, "RECNO")
	
	::CreateStruct()
	
	If lLoad
		
		DBSelectArea(::cAlias1)
		ZAP

		DBSelectArea(::cAlias2)
		ZAP
				
		SqlToTrb(::GetSql(), ::aStru, ::cAlias1)
		
		::oMarca1:oBrowse:Refresh()
		
		::oMarca2:oBrowse:Refresh()
		
	Else
		
		// Grid 1
		::oTmpTable1 := ::CreateTemp()
		
		::cAlias1 := ::oTmpTable1:GetAlias()
		
		// Grid 2
		::oTmpTable2 := ::CreateTemp()
		
		::cAlias2 := ::oTmpTable2:GetAlias()
		
		SqlToTrb(::GetSql(), ::aStru, ::cAlias1)
	
	EndIf
	
Return()


Method CreateStruct() Class TWAFAgrupaTituloCTe

	Local nW := 0
	
	For nW := 1 To Len(::aCampos)
		
		If Posicione("SX3", 2, ::aCampos[nW], "FOUND()")
		
			aAdd(::aStru, {::aCampos[nW],;
				TamSx3(::aCampos[nW])[3],;
				TamSx3(::aCampos[nW])[1],;
				TamSx3(::aCampos[nW])[2]})
	
			aAdd(::aStruMKB, {::aCampos[nW],;
				Nil,;
				X3Titulo(::aCampos[nW]),;
				X3Picture(::aCampos[nW])})
								
		ElseIf ::aCampos[nW] == "OK"
			
			aAdd(::aStru,{::aCampos[nW], "C", 02, 0})
			
			aAdd(::aStruMKB, {::aCampos[nW],;
				Nil,;
				"",;
				""})
			
		ElseIf ::aCampos[nW] == "RECNO"
		
			aAdd(::aStru,{"RECNO", "N", 14, 0})

			aAdd(::aStruMKB, {::aCampos[nW],;
				Nil,;
				"Recno",;
				""})
						
		EndIf
		
	Next nW

Return()

Method Filtro(lLoad) Class TWAFAgrupaTituloCTe
	
	Local lRet := .F.
	local cLoad	 := "TWAFAgrupaTituloCTe" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	Local aRet := {::cFornece, ::cLoja, ::cRaizCnpj, ::dEmisDe, ::dEmisAte}
	Local aPergs := {}
	
	Default lLoad := .F.
	
	aAdd( aPergs ,{1, "Fornecedor", ::cFornece,, ".T.", "SA2","Empty(MV_PAR03)", Len(::cFornece), .F.})
	
	aAdd( aPergs ,{1, "Loja", ::cLoja,, ".T.", ,"Empty(MV_PAR03)", Len(::cLoja), .F.})
	
	aAdd( aPergs ,{1, "Raíz Cnpj", ::cRaizCnpj,, ".T.", ,"Empty(MV_PAR01)", Len(::cLoja), .F.})
	
	aAdd( aPergs ,{1, "Emissao de", ::dEmisDe,, ".T.", ,".T.", 8, .F.})
	
	aAdd( aPergs ,{1, "Emissao Ate", ::dEmisAte,, ".T.", ,".T.", 8, .T.})

	If ParamBox(aPergs, "Parâmetros", aRet,, ,, ,, , cLoad, .T., .F.)
		
		::cFornece := ParamLoad(cFileName,,1,MV_PAR01)
		
		::cLoja := ParamLoad(cFileName,,2,MV_PAR02)
		
		::cRaizCnpj := ParamLoad(cFileName,,3,MV_PAR03)
		
		::dEmisDe := ParamLoad(cFileName,,4,MV_PAR04)
		
		::dEmisAte := ParamLoad(cFileName,,5,MV_PAR05)
		
		lRet:= .T.
				
	Else
	
		lRet := .F.
		
	EndIf
	
	::LoadTable(lLoad)

Return(lRet	)

Method TotalTitSel(cAlias, oMarca, cMarca, oSay, cMsg, cTitulo) Class TWAFAgrupaTituloCTe
	
	Local nTot := 0
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())
	
	While (cAlias)->(! Eof())
	
    	//If (cAlias)->OK == cMarca
    	
		nTot += (cAlias)->E2_VALOR
	        
        //EndIf
        
		(cAlias)->(dbSkip())
    
	EndDo
    
	(cAlias)->(DBGoTop())
	
	oMarca:oBrowse:Refresh()
	
	cTitulo := cMsg + AllTrim(Transform(nTot, "@E 99,999,999.99"))
	
	oSay:Refresh()
	
	::oDlg:Refresh()
	
Return()

Method Refresh() Class TWAFAgrupaTituloCTe

	::TotalTitSel(::cAlias1, ::oMarca1, ::cMarca1, @::oSay1, "Titulos: ", @::cDesTitulo)
	
	::TotalTitSel(::cAlias2, ::oMarca2, ::cMarca2, @::oSay2, "Titulos para fatura: ", @::cDesTitFat)
	
Return()

Method GetSql(cRecnoIn) Class TWAFAgrupaTituloCTe

	Local cSql := ""
	Local nW := 0
	
	Default cRecnoIn := ""
	
	cSql += "SELECT "
	
	For nW := 1 To Len(::aStru)
		
		If ::aStru[nW][1] == "OK"
		
			cSql += "'" + Space(::aStru[nW][3]) + "' " + ::aStru[nW][1] + If(nW == Len(::aStru), " ", ", ")
			
		ElseIf ::aStru[nW][1] == "RECNO"
		
			cSql += "A.R_E_C_N_O_ AS RECNO" + If(nW == Len(::aStru), " ", ", ")
		
		Else
		
			cSql += ::aStru[nW][1] + If(nW == Len(::aStru), " ", ", ")
		
		EndIf
		
	Next nW
	
	cSql += "FROM " + RetSqlName("SE2") + " A (NOLOCK) "
	cSQL += "INNER JOIN "+ RetSQLName("SA2") + " SA2 "
	cSQL += "ON A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
	cSQL += "AND A2_COD = E2_FORNECE "
	cSQL += "AND A2_LOJA = E2_LOJA "
	cSQL += "AND SA2.D_E_L_E_T_ = '' "
	cSql += "WHERE E2_FILIAL = " + ValToSQL(xFilial("SE1"))
	
	If Empty(::cRaizCnpj)
	
		cSql += "AND E2_FORNECE = " + ValToSQL(::cFornece)
		cSql += "AND E2_LOJA = " + ValToSQL(::cLoja)
	
	Else
	
		cSql += "AND SUBSTRING(A2_CGC, 1, 8) = " + ValToSQL(::cRaizCnpj)
		
	EndIf
	
	
	cSql += "AND E2_EMISSAO BETWEEN " + ValToSQL(::dEmisDe) + " AND " + ValToSQL(::dEmisAte)
	//cSql += "AND E2_NATUREZ IN " + ValToSQL(::cNatureza)
	cSql += "AND E2_SALDO > 0 "
	cSql += "AND E2_NUMBOR = '' "
	
	If ! Empty(cRecnoIn)
	
		cSql += "AND A.R_E_C_N_O_ IN " + FormatIn(cRecnoIn, ",")
		
	EndIf
	
	cSql += "AND A.D_E_L_E_T_ = '' "
	
Return(cSql)


Method CreateTemp() Class TWAFAgrupaTituloCTe

	Local oTempTable := Nil
	Local cAliasTab := GetNextAlias()
	Local aCpos := {}
	Local nW := 0
	
	For nW := 1 To Len(::aCampos)
	
		If ::aCampos[nW] <> "OK"
		
			aAdd(aCpos, ::aCampos[nW])
		
		EndIf
	
	Next nW
	
	oTempTable := FWTemporaryTable():New(cAliasTab, ::aStru)
		
	oTempTable:AddIndex( "IND1", aCpos )
	
	oTempTable:Create()

Return(oTempTable)

Method DropTemp(oTempTable) Class TWAFAgrupaTituloCTe
	
	If Select(oTempTable:GetAlias()) > 0
	
		DBCloseArea(oTempTable:GetAlias())
		
		oTempTable:Delete()
	
	EndIf
	
Return()


Method Confirma(cTpo, cNaturez, cPrefix, nxMoeda, nVroPag, dDtVencto, cForDe, cLjaDe, cForPara, cLjaPara, cBco, cAg, cConta, cQuery, nAcrescLq, ndecresLq) Class TWAFAgrupaTituloCTe

	Local nZ		:= 1
	Local nX		:= 1
	Local lContinua	:= .T.
	Local nCount	:= 0
	Local nVrLqdAux	:= 0

	Local aTamBco 	:= TamSx3("E2_BCOCHQ")
	Local aTamAge 	:= TamSx3("E2_AGECHQ")
	Local aTamCta 	:= TamSx3("E2_CTACHQ")
	Local aTam		:= TamSx3("E2_NUM")

	Local nTamTit	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]
	Local nTamChave	:= TamSX3("E2_FILIAL")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1]+nTamTit

	Private cLote
	Private aDiario 	:= {}
	Private cCodDiario	:= ""

	Private aCampos	:=	{;
							{"MARCA"   	, "C",  2,0},;
							{"FILIAL"	, "C", If(lFWCodFil,FWGETTAMFILIAL,TamSX3("E2_FILIAL")[1]),0},;		// GESTAO
							{"TITULO"	, "C", nTamTit+3,0},;
							{"MOEDAO"	, "N",  2,0},;			//Moeda do Titulo
							{"CTMOED"	, "N", 10,4},;			//Moeda do Titulo
							{"VALORI"	, "N", 15,2},;			//Valor original do titulo
							{"ABATIM"	, "N", 15,2},;
							{"BAIXADO"	, "N", 15,2},;
							{"VALCVT"	, "N", 15,2},;			//Valor convertido para a moeda escolhida
							{"JUROS"	, "N", 15,2},;
							{"VLMULTA"	, "N", 15,2},;
							{"DESCON"	, "N", 15,2},;
							{"VALLIQ"	, "N", 15,2},;
							{"EMISSAO"	, "D", 08,0},;
							{"VENCTO"	, "D", 08,0},;
							{"ACRESC"	, "N", 15,2},;
							{"DECRESC"	, "N", 15,2},;
							{"CHAVE"	, "C", nTamChave,0},;
							{"CHAVE2"	, "C", nTamChave,0};
						}
						
	Private nUsado2		:= 0

	Private dBaixa	  	:= dDataBase

	Private cParc565  	:= F565Parc()    // controle de parcela (E2_PARCELA)

	Private cFornece	:= Criavar ("E2_FORNECE",.F.)
	Private cLoja   	:= Criavar ("E2_LOJA",.F.)

	Private cFornDE 	:= cForDe
	Private cLojaDE 	:= cLjaDe
	Private cFornAte	:= cForDe
	Private cLojaAte	:= cLjaDe
	Private cNomeForn 	:= CriaVar ("E2_NOMFOR")

	Private nMoeda 	  	:= nxMoeda//1

	Private nQtdTit   	:= 0
	Private nValorMax 	:= 0				// valor maximo de liquidacao (digitado)
	Private nValorDe  	:= 0 			   // valor inicial dos titulos
	Private nValorAte 	:=  9999999999.99 // Valor final dos titulos

	Private nValorLiq 	:= nVrOPag //0				// valor da liquidacao ap¢s mBrowse

	Private nNroParc  	:= 0				// numero de parcelas digitadas
	Private cCondicao 	:= Space(3)		// numero de parcelas automaticas

	Private cNatureza 	:=  cNaturez //Criavar ("E2_NATUREZ")
	Private aHeader   	:= {}
	Private aCols  		:= {}
	Private cMarca		:= GetMark()
	Private cTipo	 	:= cTpo//Criavar ("E2_TIPO")
	Private nJuros		:= 0

	SomaAbat("","","","P")

	cAliasSE2 := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE2,.F.,.T.)

	TRB := sTaticcall(FINA565, Fa565Gerarq, aCampos )	
	Fa565Repl(TRB,cAliasSE2)					
 
	SE2->(DbSetOrder(1))
	
	nValor	:= 0
	
	DbSelectArea("TRB")
	TRB->( DBGOTOP() )
	
	While ! TRB->( Eof() )
	
		SE2->(MSSeek(TRB->CHAVE))
		
		If SE2->( MsRLock() ) .and. SE2->E2_SALDO > 0
		
			RecLock("TRB")
			Replace MARCA With cMarca
			TRB->(MsUnlock())
			nValor 	+= TRB->VALLIQ
			nQtdTit	++
			IF nValor >= nVrOpag // Marca Titulos enquanto o Vr. dos tits. Selec. é menor que o Vr. da OPAGTO + 1 Titulo (q será baixado Parcial)
				Exit
			EndIf
			
		EndIf
		
		TRB->(dbSkip())
		
	EndDo
	
	Aadd(aHeader,{"PREFIXO"		,"E2_PREFIXO"	,"!!!"					,3				,0	,"AllWaysTrue()"	,"û","C","SE2" } )  //"PREFIXO "
	Aadd(aHeader,{"TIPO"		,"E2_TIPO"		,"@!"					,3				,0	,"FA565TIPO()"		,"û","C","SE2" } )  //"TIPO"
	Aadd(aHeader,{"BCO"			,"E2_BCOCHQ"	,"@!"					,aTamBco[1]		,0	,"AllWaysTrue()"	,"û","C","SE2" } )  //"BCO. "
	Aadd(aHeader,{"AGENCIA"		,"E2_AGECHQ"	,"@!"					,aTamAge[1]		,0	,"AllwaysTrue()"	,"û","C","SE2" } )  //"AGENCIA"
	Aadd(aHeader,{"CONTA"		,"E2_CTACHQ"	,"@!"					,aTamCta[1]		,0	,"AllwaysTrue()"	,"û","C","SE2" } )  //"CONTA"
	Aadd(aHeader,{"NRCHEQUE"	,"E2_NUM"		,"@!"					,aTam[1]		,0	,"a565NumChq()"		,"û","C","SE2" } )  //"NRO. CHEQUE"
	Aadd(aHeader,{"DATABOA"		,"E2_VENCTO"	," "					,8				,0	,"a565DataOK()"		,"û","D","SE2" } )  //"DATA BOA"
	Aadd(aHeader,{"VALOR"		,"E2_VLCRUZ"	,"@E 9999,999,999.99"	,14				,2	,"A565Valor()"		,"û","N","SE2" } )	//"VALOR"
	Aadd(aHeader,{"ACRESC."		,"E2_ACRESC"	,"@E 999,999.99"		,10				,2	,"A565Valor()"		,"û","N","SE2" } ) 	//"ACRESCIIMOS"
	Aadd(aHeader,{"DECRESC."	,"E2_DECRESC"	,"@E 999,999.99"		,10				,2	,"A565Valor()"		,"û","N","SE2" } )	//"DECRESCIMOS"
	Aadd(aHeader,{"VR.TOTAL"	,"E2_VALOR"		,"@E 9999,999,999.99"	,14				,2	,"AllwaysTrue()"	,"û","N","SE2" } ) 	//"VALOR TOTAL"

	nPosPrefix 	:= 01
	nPosTipo	:= 02
	nPosBco		:= 03
	nPosAgencia	:= 04
	nPosCta		:= 05
	nPosChq		:= 06
	nPosDtBoa	:= 07
	nPosVr		:= 08
	nPosAcr		:= 09
	nPosDec		:= 10
	nPosTotal		:= 11

	nUsado2 := Len(aHeader)
	aCols   := Array( 1, ( nUsado2 + 1) ) 

	cLiquid	:= Soma1(GetMv("MV_NUMLIQP"),6)

	While !MayIUseCode( "E2_NUMLIQP"+cLiquid )
		cLiquid := Soma1(cLiquid)			 	
	EndDo

	cNatureza	:= cNaturez
	cFornDE		:= cForDe
	cLojaDE 	:= cLjaDe
	cFornAte  	:= cForDe
	cLojaAte  	:= cLjaDe
	nValorLiq 	:= nvropag
	cTipo		:= cTpo
	cfornece 	:= cForPara
	cLoja		:= cLjaPara
	cNomeForn	:=  Posicione("SA2",1,FwxFilial("SA2")+cFornece +cLoja,"SA2->A2_NOME")

	aCols[1,nPosPrefix	]	:= cPrefix
	aCols[1,nPosTipo	]	:= cTpo
	aCols[1,nPosBco		]	:= cBco
	aCols[1,nPosAgencia	]	:= cAg
	aCols[1,nPosCta		] 	:= cConta
	aCols[1,nPosChq		] 	:= cLiquid 
	aCols[1,nPosDtBoa	] 	:= dDtVencto
	aCols[1,nPosVr		] 	:= nVrOpag
	aCols[1,nPosAcr		]	:= nAcrescLq
	aCols[1,nPosDec		]	:= ndecresLq
	acols[1,nUsado2+1	] 	:= .F.  		//Não deletado

	LoteCont( "FIN" )

	Pergunte("FIN565",.F.)
    	
	StaticCall (FINA565, a565Grava, aHeader, aCols )

	If GetMv("MV_NUMLIQP") < cLiquid
	
		PUTMV("MV_NUMLIQP",cLiquid)
		
	EndIf

	Trb->( DbCloseArea() )
	
	(cAliasSe2)->( DbCloseArea() )

Return(.T.)


User Function FCLA0052()

/*
	Local oObj := TWAFAgrupaTituloCTe():New()
	
	Private cCadastro := oObj:cCadastro

	oObj:Activate()
	*/
Return()