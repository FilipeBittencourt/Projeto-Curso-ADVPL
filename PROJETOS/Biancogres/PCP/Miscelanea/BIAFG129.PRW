#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG129
@author Gabriel Rossi Mafioletti
@since 11/08/20
@version 1.0
@description Tela de Gerenciamento do HeadCount
@type function
/*/
User Function BIAFG129()

	Local oBrowse := NIL

	Private cCadastro	:= "Gerenciamento do HeadCount"
	Private _oGetDados	:= Nil
	Private bGrdVldMat	:= {|| fVldGrdMat() }

	Private nTotLin		:= 0

	DbSelectArea('ZLC')

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('ZLC')
	oBrowse:SetDescription('Gerenciamento do HeadCount')

	oBrowse:AddLegend("ZLC_STATUS == 'A'", "GREEN"	, "Aberto")
	oBrowse:AddLegend("ZLC_STATUS == 'F'", "RED"	, "Fechado")
	oBrowse:AddLegend("ZLC_STATUS == 'I'", "YELLOW"	, "Iniciado")

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'        , 'PesqBrw'  , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar'       , 'U_BFG129V', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Alterar'          , 'U_BFG129A', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Mudança Status'   , 'U_BFG129S', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Legenda'          , 'U_BFG129L', 0, 8, 0, NIL } )
	aAdd( aRotina, { 'Exportar Excel'   , 'U_BFG129I', 0, 2, 0, NIL } )

Return aRotina

User Function BFG129L()

	Brwlegenda(cCadastro, "Legenda",{{ "BR_VERDE"    ,"Aberto"}   ,;
	{                                  "BR_VERMELHO" ,"Fechado"}  ,;
	{                                  "BR_AMARELO"  ,"Iniciado"} })

Return

User Function BFG129V()

	Private _oDlg		:=	Nil
	//Private _oGetDados	:=	Nil
	Private aSize	 	:= MsAdvSize(.T.) //Sem Enchoice
	Private aObjects	:=	{}

	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Headcount - Visualizar" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	fGeraGd(@_oDlg, aPosObj)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg,  {||  _oDlg:End()}, {|| _oDlg:End()})

Return

User Function BFG129A()

	Local _oDlg			:= Nil
	Local aSize	 		:= MsAdvSize(.T.) //Sem Enchoice
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aPosObj		:= {}

	If ( ZLC->ZLC_STATUS == 'A' )
		// Instruções de delimitação da tela.
		AAdd( aObjects, { 100, 100, .T., .T. } )
		aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
		aPosObj := MsObjSize( aInfo, aObjects, .T. )
		// Montagem da tela.
		DEFINE MSDIALOG _oDlg TITLE "Headcount - Alterar" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
			// Carga das inforamções para a GRID.
			fGeraGd(@_oDlg, aPosObj, "A")

		ACTIVATE DIALOG _oDlg CENTERED on Init ;
			EnchoiceBar(_oDlg,  {|| fGrdGrava(), _oDlg:End()}, {|| _oDlg:End()})
	Else
		MsgStop("Somente processos em aberto poderão ser alterado!", "Atenção")
	EndIf

Return

Static Function fGeraGd(_oDlg, aPosObj, pOpc)

	Local _aCols	:= {}
	Local _aHeader	:= {}
	Local aAltCpos	:= {}
	Local _cAlias	:= GetNextAlias()
	Local nGetOpc

	Default _oDlg	:= Nil				// V - Visualizar / A - Alterar.
	Default aPosObj := Nil
	Default pOpc	:= "V"

	BeginSql Alias _cAlias
			
		%NoParser%
		SELECT 
			CASE 
				WHEN ZLD.ZLD_TIPO = '1'
				THEN 'AUTOMATICO'
				ELSE 'MANUAL'
			END TIPO
			,ZLA.ZLA_CODIGO
			,ZLA.ZLA_DESPOS
			,ZLD.ZLD_MAT
			,ISNULL(MAT.nomfun, '') AS NOMFUN
			,ISNULL(ZLE.ZLE_DESCRI, '') SITUAC
			,ZLD_OBS
			,ZLD_MATOBS
			,ISNULL(MATSUB.nomfun, '') AS NOMOBS
			,ZLD_DATOBS
			,ZLD_MOTOBS
		FROM %TABLE:ZLD% ZLD
			JOIN %TABLE:ZLA% ZLA ON 
					ZLA.ZLA_FILIAL = ZLD.ZLD_FILIAL
				AND ZLA.ZLA_CODIGO = ZLD.ZLD_CODPOS
				AND ZLA.%NotDel%
				AND ZLD.%NotDel%
			LEFT JOIN %TABLE:ZLE% ZLE ON 
					ZLE.ZLE_CODIGO = ZLD.ZLD_SITUAC
				AND ZLE.%NotDel%
			LEFT JOIN VETORH..r034fun MAT ON 	// VETORH..r034fun
					CAST(SUBSTRING(ZLD.ZLD_MAT, 1, 2) AS INT) = MAT.numemp
				AND CAST(RIGHT(ZLD.ZLD_MAT, 6) AS INT) = MAT.numcad
				AND MAT.tipcol = 1
				AND MAT.sitafa <> 7
			LEFT JOIN VETORH..r034fun MATSUB ON 
					CAST(SUBSTRING(ZLD.ZLD_MATOBS, 1, 2) AS INT) = MATSUB.numemp
				AND CAST(RIGHT(ZLD.ZLD_MATOBS, 6) AS INT) = MATSUB.numcad
				AND MATSUB.tipcol = 1
				AND MATSUB.sitafa <> 7
		WHERE 
				ZLD.ZLD_FILIAL = %Exp:ZLC->ZLC_FILIAL%
			AND ZLD.ZLD_CODIGO = %Exp:ZLC->ZLC_CODIGO%

	EndSql
	
	// Definir colunas GRID.
	/*Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})*/
	aAdd(_aHeader,{"Tipo"           ,"TIPO"   ,"@!"		, 10 , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Cod. Pos"       ,"CODPOS" ,"@!"		, 8  , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Desc. Pos"      ,"DESPOS" ,"@!"		, 70 , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Matrícula"      ,"MATRIC" ,"@!"		, 8  , 0, "Eval(bGrdVldMat)",, "C","SRA623",,,	})
	aAdd(_aHeader,{"Nome"           ,"NOMFUN" ,"@!"		, 40 , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Situa."         ,"SITUAC" ,"@!"		, 20 , 0,,, "C",,,,	 							})
	aAdd(_aHeader,{"Obs."           ,"OBS"    ,"@40"	, 40 , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Mat. Obs."      ,"MATOBS" ,"@!"		, 8  , 0,,, "C","SRA623",,, 					})
	aAdd(_aHeader,{"Nome Obs."      ,"NOMOBS" ,"@!"		, 40 , 0,,, "C",,,, 							})
	aAdd(_aHeader,{"Data Obs."      ,"DATOBS" ,"@!"		, 8  , 0, "Eval(bGrdVldMat)",, "D",,,,			})
	aAdd(_aHeader,{"Mot. Obs."      ,"MOTOBS" ,"@!"		, 70 , 0,,, "C",,,, 							})

	While (_cAlias)->(!EOF())

		(_cAlias)->(aAdd(_aCols,{TIPO			 ,;
								 ZLA_CODIGO		 ,;
								 ZLA_DESPOS		 ,;
								 ZLD_MAT		 ,;
								 NOMFUN			 ,;
								 SITUAC			 ,;
								 ZLD_OBS		 ,;
								 ZLD_MATOBS		 ,;
								 NOMOBS			 ,;
								 Stod(ZLD_DATOBS),;
								 ZLD_MOTOBS		 ,;
								 .F.}))
		(_cAlias)->(DbSkip())

	EndDo

	If ( Valtype(_oDlg) == "O" )
		If ( pOpc == "V" )
			_oGetDados	:=	MsNewGetDados():New( aPosObj[1][1] + 10, aPosObj[1][2] + 5, aPosObj[1][3] - 5, aPosObj[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "AllWaysTrue", "", _oDlg, _aHeader, _aCols, )
		Else
			// Propriedades da GET.
			nGetOpc  	:= GD_UPDATE	//GD_INSERT + GD_UPDATE //+ GD_DELETE
			aAltCpos 	:= {"MATRIC", "OBS", "MATOBS", "MOTOBS"}	// Campos editáveis.
			// Montar a GET.
			_oGetDados	:=	MsNewGetDados():New( aPosObj[1][1] + 10, aPosObj[1][2] + 5, aPosObj[1][3] - 5, aPosObj[1][4] - 5, nGetOpc, "AllwaysTrue", "AllwaysTrue", "", aAltCpos,/*cFieldOk*/, 999,/*cDelOk*/, "AllWaysTrue",, _oDlg, _aHeader, _aCols)
		EndIf
		nTotLin	:= Len(_oGetDados:aCols)
	EndIf

Return

User Function BFG129S()

	Private oDlg
	Private oButton1
	Private oButton2
	Private oComboBox1
	Private nComboBox1 := ZLC->ZLC_STATUS
	Private msRecZLC   := ZLC->(Recno())
	Private oSay1
	Private msFechTl   := .F.
	Private msAltReg   := .F.

	DEFINE MSDIALOG oDlg TITLE "Status HeadCount" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

	@ 023, 011 SAY oSay1 PROMPT "Mudança de Status: " SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 072 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"A=Aberto;","I=Iniciado;","F=Fechado"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 149 BUTTON oButton1 PROMPT "Cancelar"  SIZE 037, 012 OF oDlg ACTION msFecha()   PIXEL
	@ 019, 190 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION msConfSta() PIXEL

	ACTIVATE MSDIALOG oDlg VALID msFechTl

	If msAltReg

		MsgINFO("Alteração Realizada com SUCESSO.....", "Status")

	Else

		MsgAlert("Alteração Cancelada.....", "Status")

	EndIf

Return

Static Function msConfSta()

	dbSelectArea("ZLC")
	ZLC->(dbGoTo(msRecZLC))
	ZLC->(RecLock("ZLC",.F.))
		ZLC->ZLC_STATUS := nComboBox1
	ZLC->(MsUnLock())

	msFechTl  := .T.
	msAltReg  := .T.
	Close(oDlg)

Return

Static Function msFecha()

	msFechTl := .T.
	Close(oDlg)

Return

Static Function __Dummy()

    If (.F.)
        __Dummy()
        MENUDEF()
    EndIf

Return

Static Function fVldGrdMat()
Local xAliasI	:= GetNextAlias()
Local _lOk		:= .T.
Local lForceDat := .F.
Local xGridMat	:= ""
Local xGridDat	:= ""
Local nPosMat	:= 0
Local nPosDat	:= 0
Local nPosReg	:= 0

	_oGetDados:ForceRefresh()
	// Identificar campo na GRID.
	nPosMat  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "MATRIC"})
	nPosDat	 := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "DATOBS"})
	// Capturar informação.
	If ( "MATRIC" $ ReadVar() )
		xGridMat := &(ReadVar())
	EndIf
	If !Empty(xGridMat)
		If ( ValType(n) == "N" )
			_oGetDados:aCols[n][nPosMat] := xGridMat
		Else
			_oGetDados:aCols[_oGetDados:nAt][nPosMat] := xGridMat
		EndIf
	EndIf
	If ( "DATOBS" $ ReadVar() )
		xGridDat := &(ReadVar())
	Else
		If ( ValType(n) == "N" )
			xGridDat := _oGetDados:aCols[n][nPosDat]
		Else
			xGridDat := _oGetDados:aCols[_oGetDados:nAt][nPosDat]
		EndIf
	EndIf
	// Forçar preenchimento da DATA, pela referência de preenchimento da matrícula.
	If Empty(xGridDat)
		lForceDat := .T.
		If ( ValType(n) == "N" )
			GdFieldPut("DATOBS", dDataBase, n)
			xGridDat := _oGetDados:aCols[n][nPosDat]
			If Empty(xGridDat)
				_oGetDados:aCols[n][nPosDat] := dDataBase
				xGridDat  := dDataBase
				lForceDat := .T.
			EndIf
		Else
			GdFieldPut("DATOBS", dDataBase, _oGetDados:nAt)
			xGridDat := _oGetDados:aCols[_oGetDados:nAt][nPosDat]
			If Empty(xGridDat)
				_oGetDados:aCols[_oGetDados:nAt][nPosDat] := dDataBase
				xGridDat  := dDataBase
				lForceDat := .T.
			EndIf
		EndIf
		_oGetDados:ForceRefresh()
	EndIf
	If !Empty(xGridMat) .AnD. !Empty(xGridDat)
		// Garantir que uma matrícula somente seja usada uma única vez naquele processo;
		//	Entende-se por processo: todos os registros de uma mesma data, logo o registro ZLD_MAT somente poderá ser usado uma vez naquela data.
		BeginSql Alias xAliasI
			%NoParser%
			SELECT
				ZLC_DATREF
			FROM %TABLE:ZLC% ZLC
			WHERE 
					ZLC.ZLC_FILIAL = %Exp:ZLC->ZLC_FILIAL%
				AND ZLC.ZLC_MAT = %Exp:xGridMat%
				AND ZLC.ZLC_DATREF = %Exp:xGridDat%
				AND ZLC.%NotDel%
		EndSql
		// Reciclagem dos dados obtidos a partir da query.
		(xAliasI)->(DbGoTop())
		_lOk := (xAliasI)->(EoF())
		If !_lOk
			MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
			// Limpar campos.
			If ( ValType(n) == "N" )
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), n)
				_oGetDados:aCols[n][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), n)
					_oGetDados:aCols[n][nPosDat] := StoD("")
				EndIf
			Else	
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), _oGetDados:nAt)
				_oGetDados:aCols[_oGetDados:nAt][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), _oGetDados:nAt)
					_oGetDados:aCols[_oGetDados:nAt][nPosDat] := StoD("")
				EndIf
			EndIf
			_oGetDados:ForceRefresh()
			Return(.F.)
		EndIf
		// Caso não identificado resultado via QUERY, observar a GRID editada e que esta em edicao.
		nPosReg := aScan(_oGetDados:aCols, {|aInfos| aInfos[nPosDat] == xGridDat .AnD. aInfos[nPosMat] == xGridMat })
		If ( ValType(n) == "N" )
			If ( nPosReg <> N ) .AnD. ( nPosReg > 0 )
				MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
				// Limpar campos.
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), n)
				_oGetDados:aCols[n][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), n)
					_oGetDados:aCols[n][nPosDat] := StoD("")
				EndIf
				_oGetDados:ForceRefresh()	
				Return(.F.)
			ElseIf ( nPosReg == N )
				// Caso não identificado resultado via QUERY, observar a GRID editada e que esta em edicao.
				nPosReg := aScan(_oGetDados:aCols, {|aInfos| aInfos[nPosMat] == xGridMat })
				If ( nPosReg <> N ) .AnD. ( nPosReg > 0 )
					MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
					// Limpar campos.
					GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), n)
					_oGetDados:aCols[n][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
					If lForceDat
						GdFieldPut("DATOBS", StoD(""), n)
						_oGetDados:aCols[n][nPosDat] := StoD("")
					EndIf
					_oGetDados:ForceRefresh()
					Return(.F.)
				EndIf
			EndIf
		Else
			If ( nPosReg <> _oGetDados:nAt ) .AnD. ( nPosReg > 0 )
				MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
				// Limpar campos.
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), _oGetDados:nAt)
				_oGetDados:aCols[_oGetDados:nAt][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), _oGetDados:nAt)
					_oGetDados:aCols[_oGetDados:nAt][nPosDat] := StoD("")
				EndIf
				Return(.F.)
			ElseIf ( nPosReg == _oGetDados:nAt )
				// Caso não identificado resultado via QUERY, observar a GRID editada e que esta em edicao.
				nPosReg := aScan(_oGetDados:aCols, {|aInfos| aInfos[nPosMat] == xGridMat })
				If ( nPosReg <> _oGetDados:nAt ) .AnD. ( nPosReg > 0 )
					MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
					// Limpar campos.
					GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), _oGetDados:nAt)
					_oGetDados:aCols[_oGetDados:nAt][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
					If lForceDat
						GdFieldPut("DATOBS", StoD(""), _oGetDados:nAt)
						_oGetDados:aCols[_oGetDados:nAt][nPosDat] := StoD("")
					EndIf
					Return(.F.)
				EndIf
			EndIf
		EndIf
	ElseIf !Empty(xGridMat)
		// Caso não identificado resultado via QUERY, observar a GRID editada e que esta em edicao.
		nPosReg := aScan(_oGetDados:aCols, {|aInfos| aInfos[nPosMat] == xGridMat })
		If ( ValType(n) == "N" )
			If ( nPosReg <> N ) .AnD. ( nPosReg > 0 )
				MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
				// Limpar campos.
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), n)
				_oGetDados:aCols[n][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), n)
					_oGetDados:aCols[n][nPosDat] := StoD("")
				EndIf
				_oGetDados:ForceRefresh()	
				Return(.F.)
			EndIf
		Else
			If ( nPosReg <> _oGetDados:nAt ) .AnD. ( nPosReg > 0 )
				MsgStop("Uma matrícula somente pode ser usada uma única vez por processo!", "Atenção")
				// Limpar campos.
				GdFieldPut("MATRIC", Space(TamSX3("ZLC_MAT")[1]), _oGetDados:nAt)
				_oGetDados:aCols[_oGetDados:nAt][nPosMat] := Space(TamSX3("ZLC_MAT")[1])
				If lForceDat
					GdFieldPut("DATOBS", StoD(""), _oGetDados:nAt)
					_oGetDados:aCols[_oGetDados:nAt][nPosDat] := StoD("")
				EndIf
				Return(.F.)
			EndIf
		EndIf
	EndIf

Return(.T.)

Static Function fGrdGrava()
Local nX		:= 0
Local nPosCod	:= 0
Local nPosMat	:= 0
Local nPosSit	:= 0
Local nPosTip	:= 0
Local nPosObs	:= 0
Local nPosMob	:= 0
Local nPosDat	:= 0
Local nPosMot	:= 0

	// Identificar campo na GRID.
	nPosCod  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "CODPOS"})
	nPosMat  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "MATRIC"})
	nPosSit  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "SITUAC"})
	nPosTip  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "TIPO"})
	nPosObs  := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "OBS"})
	nPosMob	 := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "MATOBS"})
	nPosDat	 := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "DATOBS"})
	nPosMot	 := aScan(_oGetDados:aHeader, {|aCampo| AllTrim(aCampo[2]) == "MOTOBS"})
	// Gravação da GRID.
	DbSelectArea("ZLD")
	For nX := 1 To Len(_oGetDados:aCols)
		If !Empty(_oGetDados:aCols[nX][nPosCod])
			ZLD->(DbSetOrder(1))	// ZLD_FILIAL + ZLD_CODIGO + ZLD_CODPOS
			If ZLD->(DbSeek( ZLC->ZLC_FILIAL + ZLC->ZLC_CODIGO + _oGetDados:aCols[nX][nPosCod]))
				RecLock("ZLD", .F.)
					ZLD->ZLD_MAT 	:= _oGetDados:aCols[nX][nPosMat]
					ZLD->ZLD_SITUAC := _oGetDados:aCols[nX][nPosSit]
					ZLD->ZLD_TIPO	:= _oGetDados:aCols[nX][nPosTip]
					ZLD->ZLD_OBS	:= _oGetDados:aCols[nX][nPosObs]
					ZLD->ZLD_MATOBS	:= _oGetDados:aCols[nX][nPosMob]
					ZLD->ZLD_DATOBS	:= _oGetDados:aCols[nX][nPosDat]
					ZLD->ZLD_MOTOBS	:= _oGetDados:aCols[nX][nPosMot]
				ZLD->(MsUnlock())
			EndIf
		EndIf
	Next

Return(.T.)