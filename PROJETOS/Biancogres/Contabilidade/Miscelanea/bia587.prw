#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA587
@author Marcos Alberto Soprani
@since 28/01/21
@version 1.0
@description Tela para lançamento das ajustes orçamentário na tabela geral de Orçamento ZOZ (FORECAST)
@type function
/*/

User Function BIA587()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOZ") + SPACE(TAMSX3("ZOZ_VERSAO")[1]) + SPACE(TAMSX3("ZOZ_REVISA")[1]) + SPACE(TAMSX3("ZOZ_ANOREF")[1])
	Local bWhile	    := {|| ZOZ_FILIAL + ZOZ_VERSAO + ZOZ_REVISA + ZOZ_ANOREF }   

	Local aNoFields     := {"ZOZ_VERSAO", "ZOZ_REVISA", "ZOZ_ANOREF", "ZOZ_ORIPRC", "ZOZ_LOTE", "ZOZ_SBLOTE", "ZOZ_VERCON"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOZ_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOZ_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOZ_ANOREF")[1])
	Private _oGAnoRef
	Private _cVersCont	:= SPACE(TAMSX3("ZOZ_VERCON")[1])
	Private _oVersCont
	Private _cDataRef	:= ctod("  /  /  ")
	Private _oGDataRef
	Private _cHistFil	:= SPACE(TAMSX3("ZOZ_HIST")[1])
	Private _oGHistFil

	Private _msCtrlAlt := .T.

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B587IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOZ",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Lançamentos Contábeis p/ Orçamento" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5"    SIZE 050, 11 OF _oDlg PIXEL VALID fBIA587A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa                          SIZE 050, 11 OF _oDlg PIXEL VALID fBIA587B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef                          SIZE 050, 11 OF _oDlg PIXEL VALID fBIA587C()

	@ 050,310 SAY "Ver.Cont.:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oVersCont VAR _cVersCont Picture "@!" F3 "ZOYFOR" SIZE 050, 11 OF _oDlg PIXEL VALID fBIA587H()

	@ 050,410 SAY "DataRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,450 MSGET _oGDataRef VAR _cDataRef                        SIZE 050, 11 OF _oDlg PIXEL VALID fBIA587D()

	@ 050,510 SAY "HistFiltro:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,550 MSGET _oGHistFil VAR _cHistFil                        SIZE 100, 11 OF _oDlg PIXEL VALID fBIA587G()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_B587LOK()" /*[ cLinhaOk]*/, /*[ cTudoOk]*/, "+++ZOZ_LINHA" /*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B587FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B587DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA587A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF

	If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
		If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
			_oGetDados:oBrowse:SetFocus()
			Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
		EndIf
	EndIf

Return .T.

Static Function fBIA587B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
		If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
			_oGetDados:oBrowse:SetFocus()
			Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
		EndIf
	EndIf

Return

Static Function fBIA587C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
		If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
			_oGetDados:oBrowse:SetFocus()
			Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
		EndIf
	EndIf

Return

Static Function fBIA587H()

	If Empty(_cVersCont)
		MsgInfo("O preenchimento do campo VersãoContábil é Obrigatório!!!")
		Return .F.
	EndIf
	If Substr(_cVersCont, 1, 1) <> "D"
		MsgSTOP("Esta rotina aceita somente Versões Contábeis do Tipo FORECAST!!!")
		Return .F.
	EndIf	
	If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
		If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
			_oGetDados:oBrowse:SetFocus()
			Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
		EndIf
	EndIf

Return

Static Function fBIA587D()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA587G()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cVersCont)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA587F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA587F()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual DataBase" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'F'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		_msCtrlAlt := .F.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
		_oGetDados:lDelete := .F.
	Else
		_msCtrlAlt := .T.
		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	// Quando DataRef for vazia
	If Empty(_cDataRef)

		// Quando HistFiltro for vazio
		If Empty(_cHistFil)

			BeginSql Alias _cAlias
				SELECT *,
				(SELECT COUNT(*)
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND ZOZ.%NotDel%
				) NUMREG
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND ZOZ.%NotDel%
				ORDER BY ZOZ_VERSAO, ZOZ_REVISA, ZOZ_ANOREF, ZOZ_DATA, ZOZ_DOC, ZOZ_LINHA
			EndSql

		Else

			// Quando HistFiltro estiver preenchido
			_cLkHistFil	:= "% ZOZ_HIST like '%"+AllTrim(_cHistFil)+"%' %"

			BeginSql Alias _cAlias
				SELECT *,
				(SELECT COUNT(*)
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND %Exp:_cLkHistFil%
				AND ZOZ.%NotDel%
				) NUMREG
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND %Exp:_cLkHistFil%
				AND ZOZ.%NotDel%
				ORDER BY ZOZ_VERSAO, ZOZ_REVISA, ZOZ_ANOREF, ZOZ_DATA, ZOZ_DOC, ZOZ_LINHA
			EndSql

		EndIf

	Else

		// Quando DataRef estiver preenchida, e

		// Quando HistFiltro for vazio
		If Empty(_cHistFil)

			BeginSql Alias _cAlias
				SELECT *,
				(SELECT COUNT(*)
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_DATA = %Exp:_cDataRef%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND ZOZ.%NotDel%
				) NUMREG
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_DATA = %Exp:_cDataRef%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND ZOZ.%NotDel%
				ORDER BY ZOZ_VERSAO, ZOZ_REVISA, ZOZ_ANOREF, ZOZ_DATA, ZOZ_DOC, ZOZ_LINHA
			EndSql

		Else

			// Quando HistFiltro estiver preenchido
			_cLkHistFil	:= "% ZOZ_HIST like '%"+AllTrim(_cHistFil)+"%' %"

			BeginSql Alias _cAlias
				SELECT *,
				(SELECT COUNT(*)
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_DATA = %Exp:_cDataRef%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND %Exp:_cLkHistFil%
				AND ZOZ.%NotDel%
				) NUMREG
				FROM %TABLE:ZOZ% ZOZ
				WHERE ZOZ_FILIAL = %xFilial:ZOZ%
				AND ZOZ_VERSAO = %Exp:_cVersao%
				AND ZOZ_REVISA = %Exp:_cRevisa%
				AND ZOZ_ANOREF = %Exp:_cAnoRef%
				AND ZOZ_VERCON = %Exp:_cVersCont%
				AND ZOZ_DATA = %Exp:_cDataRef%
				AND ZOZ_ORIPRC = 'FORECAST-M'
				AND %Exp:_cLkHistFil%
				AND ZOZ.%NotDel%
				ORDER BY ZOZ_VERSAO, ZOZ_REVISA, ZOZ_ANOREF, ZOZ_DATA, ZOZ_DOC, ZOZ_LINHA
			EndSql

		EndIf

	EndIf

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZOZ"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_DDEB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZOZ_DEBITO, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_DCRD"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZOZ_CREDIT, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_DCVDB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZOZ_CLVLDB, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_DCVCR"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZOZ_CLVLCR, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_DATA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZOZ_DATA)

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_YDELTA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZOZ_YDELTA)

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)
		For _msc := 1 to Len(_oGetDados:aHeader)
			If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOZ_LINHA"
				_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "001"
				Exit
			EndIf			
		Next _msc

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOZ_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZOZ')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZOZ->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZOZ",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D" 

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOZ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOZ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

						EndIf

					Next _msc

				Else

					ZOZ->(DbDelete())

				EndIf

				ZOZ->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZOZ",.T.)

					ZOZ->ZOZ_FILIAL  := xFilial("ZOZ")
					ZOZ->ZOZ_VERSAO  := _cVersao
					ZOZ->ZOZ_REVISA  := _cRevisa
					ZOZ->ZOZ_ANOREF  := _cAnoRef
					ZOZ->ZOZ_VERCON  := _cVersCont
					ZOZ->ZOZ_ORIPRC  := "FORECAST-M"
					ZOZ->ZOZ_LOTE    := "004100"
					ZOZ->ZOZ_SBLOTE  := "001"
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOZ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZOZ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

						EndIf

					Next _msc

					ZOZ->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZOZ_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZOZ_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZOZ_ANOREF")[1])
	_cVersCont      := SPACE(TAMSX3("ZOZ_VERCON")[1])
	_cDataRef	    := ctod("  /  /  ")
	_cHistFil	    := SPACE(TAMSX3("ZOZ_HIST")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Incluído com Sucesso!")

	Else

		MsgALERT("Nenhum registro foi atualizado!")

	EndIf

Return

User Function B587FOK()

	Local cMenVar    := ReadVar()
	Local _nAt       := _oGetDados:nAt
	Local isDC       := ""
	Local isDEBITO   := ""
	Local isCREDIT   := ""
	Local isCLVLDB   := ""
	Local isCLVLCR   := ""
	Local isITEMD    := ""
	Local isITEMC    := ""

	If !GDdeleted(_nAt)

		Do Case

			Case Alltrim(cMenVar) == "M->ZOZ_DC"
			isDC       := M->ZOZ_DC
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !isDC $ "1/2/3"
				MsgINFO("Somente são permitidos os valores 1=Débito; 2=Crédito; 3=Partida Dobrada")
				Return .F. 
			EndIf 
			GdFieldPut("ZOZ_ORGLAN" , IIF(isDC == "1", "D", IIF(isDC == "2", "C", IIF(isDC == "3", "P", ""))) , _nAt)

			Case Alltrim(cMenVar) == "M->ZOZ_DEBITO"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := M->ZOZ_DEBITO
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !Empty(isDEBITO)
				If !ExistCPO("CT1")
					Return .F.
				EndIf
			EndIf
			GdFieldPut("ZOZ_DDEB"     , Posicione("CT1", 1, xFilial("CT1") + isDEBITO, "CT1_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZOZ_CREDIT"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := M->ZOZ_CREDIT
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !Empty(isCREDIT)
				If !ExistCPO("CT1")
					Return .F.
				EndIf
			EndIf
			GdFieldPut("ZOZ_DCRD"     , Posicione("CT1", 1, xFilial("CT1") + isCREDIT, "CT1_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZOZ_CLVLDB"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := M->ZOZ_CLVLDB
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !Empty(isCLVLDB)
				If !ExistCPO("CTH")
					Return .F.
				EndIf
			EndIf
			If cEmpAnt <> "90"
				If !U_B587VdCl(isCLVLDB)
					MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
					Return .F.
				EndIf
			EndIf
			GdFieldPut("ZOZ_DCVDB"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLDB, "CTH_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZOZ_CLVLCR"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := M->ZOZ_CLVLCR
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !Empty(isCLVLCR)
				If !ExistCPO("CTH")
					Return .F.
				EndIf
			EndIf
			If cEmpAnt <> "90"
				If !U_B587VdCl(isCLVLCR)
					MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
					Return .F.
				EndIf
			EndIf
			GdFieldPut("ZOZ_DCVCR"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLCR, "CTH_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZOZ_ITEMD"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := M->ZOZ_ITEMD
			isITEMC    := GdFieldGet("ZOZ_ITEMC",_nAt)
			If !ExistCPO("CTD")
				Return .F.
			EndIf

			Case Alltrim(cMenVar) == "M->ZOZ_ITEMC"
			isDC       := GdFieldGet("ZOZ_DC",_nAt)
			isDEBITO   := GdFieldGet("ZOZ_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZOZ_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZOZ_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZOZ_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZOZ_ITEMD",_nAt)
			isITEMC    := M->ZOZ_ITEMC
			If !ExistCPO("CTD")
				Return .F.
			EndIf

		EndCase

	EndIf

Return .T.

User Function B587LOK()

	Local _lRet	:=	.T.
	xxDC       := GdFieldGet("ZOZ_DC", n)
	xxDEBITO   := GdFieldGet("ZOZ_DEBITO", n)
	xxCREDIT   := GdFieldGet("ZOZ_CREDIT", n)
	xxCLVLDB   := GdFieldGet("ZOZ_CLVLDB", n)
	xxCLVLCR   := GdFieldGet("ZOZ_CLVLCR", n)
	xxITEMD    := GdFieldGet("ZOZ_ITEMD", n)
	xxITEMC    := GdFieldGet("ZOZ_ITEMC", n)

	If xxDC == "1"
		If Substr(xxDEBITO,1,5) <> "41399" 
			If !Substr(xxDEBITO, 1, 3) $ "411/412" 
				If Empty(xxDEBITO) .or. Empty(xxCLVLDB) .or. !Empty(xxCREDIT) .or. !Empty(xxCLVLCR) .or. !Empty(xxITEMC)
					If Alltrim(xxDEBITO) <> "41301001"
						MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If xxDC == "2"
		If Substr(xxCREDIT,1,5) <> "41399"
			If !Substr(xxCREDIT, 1, 3) $ "411/412" 
				If Empty(xxCREDIT) .or. Empty(xxCLVLCR) .or. !Empty(xxDEBITO) .or. !Empty(xxCLVLDB) .or. !Empty(xxITEMD)
					If Alltrim(xxCREDIT) == "41301001"
						If !Empty(xxCLVLCR) .or. !Empty(xxCLVLDB)
							MsgINFO("Favor verificar, pois a conta 41301001 quanto receita não pode ter classe de valor associada!!!")
							Return .F.
						EndIf
					Else
						MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If xxDC == "3"
		If Empty(xxDEBITO) .or. Empty(xxCLVLDB) .or. Empty(xxCREDIT) .or. Empty(xxCLVLCR)
			MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
			Return .F.
		EndIf
	EndIf

Return _lRet

User Function B587DOK()

	Local _lRet	:=	.T.

Return _lRet

User Function B587VdCl(ksCLVL)

	Local ukRet := .T.

	dbSelectArea("CTH")
	dbSetOrder(1)
	If !Empty(Alltrim(ksCLVL))
		If dbSeek(xFilial("CTH") + ksCLVL)
			If cEmpAnt <> Substr(CTH->CTH_YEFORC,1,2)
				ukRet   := .F.
			EndIf
		EndIf
	EndIf

Return ( ukRet )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B587IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B587IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !Empty(_cDataRef) .or. !Empty(_cHistFil)
		MsgSTOP("Somente poderá ser usada a rotina de importação quando DataRef e HistFiltro estiverem vazios", "Controle de Importação!!!")
		Return
	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos ajustes orçamentário direto para a tabela ZOZ."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi("               * O nome do arquivo não pode ter espaço ou caracter especial"))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B587IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZOZ'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOZ_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 to Len(_ImpaColsBkp)
		AADD(vtRecGrd, _ImpaColsBkp[vnb][nPosRec])	
	Next vnb

	If Len(vtRecGrd) == 1
		nPrimeralin := _ImpaColsBkp[Len(_ImpaColsBkp)][nPosRec]
		If nPrimeralin == 0
			_oGetDados:aCols := {}
		EndIf
	EndIf

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0 

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZOZ_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
						nLinReg := Len(_oGetDados:aCols)

					EndIf				

					For _msc := 1 to Len(aCampos)

						xkPosCampo := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == aCampos[_msc]})
						If xkPosCampo <> 0
							If _oGetDados:aHeader[xkPosCampo][8] == "N"
								_oGetDados:aCols[nLinReg, xkPosCampo] := Val(Alltrim(aLinha[_msc]))
							Else
								_oGetDados:aCols[nLinReg, xkPosCampo] := aLinha[_msc]
							EndIf
						EndIf

					Next _msc

					_oGetDados:aCols[nLinReg, Len(_oGetDados:aHeader)+1] := .F.	
					nImport ++

				Else

					MsgALERT("Erro no Layout do Arquivo de Importação!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importação dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return
