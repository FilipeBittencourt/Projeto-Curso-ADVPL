#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA597
@author Wlysses Cerqueira (Facile)
@since 30/10/2020
@version 1.0
@description Receita Prestadoras - Apura Receita a partir do OrcaFinal 
@type function
@Obs Projeto A-35
/*/

User Function BIA597()

	Local _aSize 		:= {}
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZO2") + SPACE(TAMSX3("ZO2_VERSAO")[1]) + SPACE(TAMSX3("ZO2_REVISA")[1]) + SPACE(TAMSX3("ZO2_ANOREF")[1])
	Local bWhile	    := {|| ZO2_FILIAL + ZO2_VERSAO + ZO2_REVISA + ZO2_ANOREF }

	Local aNoFields     := {"ZO2_VERSAO", "ZO2_REVISA", "ZO2_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil

	Private _cVersao	:= SPACE(TAMSX3("ZO2_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZO2_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZO2_ANOREF")[1])
	Private _oGAnoRef
	Private _cDataRef	:= ctod("  /  /  ")
	Private _oGDataRef
	// Private _cHistFil	:= SPACE(TAMSX3("ZO2_HIST")[1])
	Private _oGHistFil

	//aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	//aAdd(_aButtons,{"PEDIDO"  ,{|| U_B597IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B597IPC() }, "Gera PIS/COFINS" , "Gera PIS/COFINS"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B597PRO() }, "Processa Orc."   , "Processa Orc."})

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZO2",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)

	Define MsDialog _oDlg Title "Lançamentos Contábeis p/ Orçamento - Receitas Prestadoras" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA597A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA597B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA597C()

	// @ 050,310 SAY "DataRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	// @ 048,350 MSGET _oGDataRef VAR _cDataRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA597D()

	// @ 050,410 SAY "HistFiltro:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	// @ 048,450 MSGET _oGHistFil VAR _cHistFil  SIZE 100, 11 OF _oDlg PIXEL VALID fBIA597G()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_B597LOK()" /*[ cLinhaOk]*/, /*[ cTudoOk]*/, "+++ZO2_LINHA" /*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B597FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B597DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons)

Return()

Static Function fBIA597A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return(.F.)
	EndIf

	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA597F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return(.T.)

Static Function fBIA597B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return(.F.)
	EndIf

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA597F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return()

Static Function fBIA597C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return(.F.)
	EndIf

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA597F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return()

Static Function fBIA597D()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA597F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA597G()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA597F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA597F()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return(.F.)
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CONTABIL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'CONTABIL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql

	(M001)->(dbGoTop())

	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return(.F.)
	EndIf

	(M001)->(dbCloseArea())

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:ZO2% ZO2
		WHERE ZO2_FILIAL = %xFilial:ZO2%
		AND ZO2_VERSAO = %Exp:_cVersao%
		AND ZO2_REVISA = %Exp:_cRevisa%
		AND ZO2_ANOREF = %Exp:_cAnoRef%
		// AND ZO2_DATA = %Exp:_cDataRef%
		//AND ZO2_ORIPRC = 'CONTABIL'
		AND ZO2.%NotDel%
		) NUMREG
		FROM %TABLE:ZO2% ZO2
		WHERE ZO2_FILIAL = %xFilial:ZO2%
		AND ZO2_VERSAO = %Exp:_cVersao%
		AND ZO2_REVISA = %Exp:_cRevisa%
		AND ZO2_ANOREF = %Exp:_cAnoRef%
		// AND ZO2_DATA = %Exp:_cDataRef%
		//AND ZO2_ORIPRC = 'CONTABIL'
		AND ZO2.%NotDel%
		ORDER BY ZO2_VERSAO, ZO2_REVISA, ZO2_ANOREF, ZO2_LINHA

	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)

	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())

	_oGetDados:aCols :=	{}

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )

			For _msc := 1 To Len(_oGetDados:aHeader)

				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZO2"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_DDEB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZO2_DEBITO, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_DCRD"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZO2_CREDIT, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_DCVDB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZO2_CLVLDB, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_DCVCR"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZO2_CLVLCR, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_DATA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZO2_DATA)

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO2_YDELTA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZO2_YDELTA)

				Else

					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf

			Next _msc

			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols :=	{}

		_oGetDados:AddLine(.F., .F.)

	EndIf

	_oGetDados:Refresh()

Return(.T.)

Static Function fGrvDados()

	Local _nI
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO2_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	dbSelectArea('ZO2')
	For _nI	:=	1 To Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZO2->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))

			Reclock("ZO2",.F.)

			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 To Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO2->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO2->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

			Else

				ZO2->(DbDelete())

			EndIf

			ZO2->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZO2",.T.)

				ZO2->ZO2_FILIAL  := xFilial("ZO2")
				ZO2->ZO2_VERSAO  := _cVersao
				ZO2->ZO2_REVISA  := _cRevisa
				ZO2->ZO2_ANOREF  := _cAnoRef

				// ZO2->ZO2_ORIPRC  := "CONTABIL"
				// ZO2->ZO2_LOTE    := "004100"
				// ZO2->ZO2_SBLOTE  := "001"

				For _msc := 1 To Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO2->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO2->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

				ZO2->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao := SPACE(TAMSX3("ZO2_VERSAO")[1])
	_cRevisa := SPACE(TAMSX3("ZO2_REVISA")[1])
	_cAnoRef := SPACE(TAMSX3("ZO2_ANOREF")[1])

	_oGetDados:aCols :=	{}

	_oGetDados:AddLine(.F., .F.)

	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()

	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return()

User Function B597FOK()

	Local cMenVar    := ReadVar()
	Local vfArea     := GetArea()
	Local _cAlias
	Local _nAt       := _oGetDados:nAt
	Local _nI
	Local isDC       := ""
	Local isDEBITO   := ""
	Local isCREDIT   := ""
	Local isCLVLDB   := ""
	Local isCLVLCR   := ""
	Local isITEMD    := ""
	Local isITEMC    := ""

	If !GDdeleted(_nAt)

		Do Case

			Case Alltrim(cMenVar) == "M->ZO2_DC"
			isDC       := M->ZO2_DC
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !isDC $ "1/2/3"
				MsgINFO("Somente são permitidos os valores 1=Débito; 2=Crédito; 3=Partida Dobrada")
				Return(.F.)
			EndIf
			GdFieldPut("ZO2_ORGLAN" , IIF(isDC == "1", "D", IIF(isDC == "2", "C", IIF(isDC == "3", "P", ""))) , _nAt)

			Case Alltrim(cMenVar) == "M->ZO2_DEBITO"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := M->ZO2_DEBITO
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !Empty(isDEBITO)
				If !ExistCPO("CT1")
					Return(.F.)
				EndIf
			EndIf
			GdFieldPut("ZO2_DDEB"     , Posicione("CT1", 1, xFilial("CT1") + isDEBITO, "CT1_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZO2_CREDIT"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := M->ZO2_CREDIT
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !Empty(isCREDIT)
				If !ExistCPO("CT1")
					Return(.F.)
				EndIf
			EndIf
			GdFieldPut("ZO2_DCRD"     , Posicione("CT1", 1, xFilial("CT1") + isCREDIT, "CT1_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZO2_CLVLDB"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := M->ZO2_CLVLDB
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !Empty(isCLVLDB)
				If !ExistCPO("CTH")
					Return(.F.)
				EndIf
			EndIf
			If !U_B597VdCl(isCLVLDB)
				MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
				Return(.F.)
			EndIf
			GdFieldPut("ZO2_DCVDB"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLDB, "CTH_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZO2_CLVLCR"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := M->ZO2_CLVLCR
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !Empty(isCLVLCR)
				If !ExistCPO("CTH")
					Return(.F.)
				EndIf
			EndIf
			If !U_B597VdCl(isCLVLCR)
				MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
				Return(.F.)
			EndIf
			GdFieldPut("ZO2_DCVCR"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLCR, "CTH_DESC01") , _nAt)

			Case Alltrim(cMenVar) == "M->ZO2_ITEMD"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := M->ZO2_ITEMD
			isITEMC    := GdFieldGet("ZO2_ITEMC",_nAt)
			If !ExistCPO("CTD")
				Return(.F.)
			EndIf

			Case Alltrim(cMenVar) == "M->ZO2_ITEMC"
			isDC       := GdFieldGet("ZO2_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO2_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO2_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO2_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO2_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO2_ITEMD",_nAt)
			isITEMC    := M->ZO2_ITEMC
			If !ExistCPO("CTD")
				Return(.F.)
			EndIf

		EndCase

	EndIf

Return(.T.)

User Function B597LOK()

	Local _lRet	:=	.T.
	xxDC       := GdFieldGet("ZO2_DC", n)
	xxDEBITO   := GdFieldGet("ZO2_DEBITO", n)
	xxCREDIT   := GdFieldGet("ZO2_CREDIT", n)
	xxCLVLDB   := GdFieldGet("ZO2_CLVLDB", n)
	xxCLVLCR   := GdFieldGet("ZO2_CLVLCR", n)
	xxITEMD    := GdFieldGet("ZO2_ITEMD", n)
	xxITEMC    := GdFieldGet("ZO2_ITEMC", n)

	If xxDC == "1"
		If Empty(xxDEBITO) .or. Empty(xxCLVLDB) .or. !Empty(xxCREDIT) .or. !Empty(xxCLVLCR) .or. !Empty(xxITEMC)
			MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
			Return(.F.)
		EndIf
	EndIf

	If xxDC == "2"
		If Empty(xxCREDIT) .or. Empty(xxCLVLCR) .or. !Empty(xxDEBITO) .or. !Empty(xxCLVLDB) .or. !Empty(xxITEMD)
			If Alltrim(xxCREDIT) == "41301001"
				If !Empty(xxCLVLCR) .or. !Empty(xxCLVLDB)
					MsgINFO("Favor verificar, pois a conta 41301001 quanto receita não pode ter classe de valor associada!!!")
					Return(.F.)
				EndIf
			Else
				MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
				Return(.F.)
			EndIf
		EndIf
	EndIf

	If xxDC == "3"
		If Empty(xxDEBITO) .or. Empty(xxCLVLDB) .or. Empty(xxCREDIT) .or. Empty(xxCLVLCR)
			MsgINFO("Favor verificar o tipo de lançamento vs conta e classe de valor preenchidos, pois são conflitantes!!!")
			Return(.F.)
		EndIf
	EndIf

Return(_lRet)

User Function B597DOK()

	Local _lRet	:=	.T.

Return(_lRet)

User Function B597VdCl(ksCLVL)

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

Return(ukRet)

User Function B597IPC()

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local _nW := 0

	cSQL := " SELECT ZO3_CTAREC, ZO3_CTACUS, ANO, ZO3_PERREC, "
	cSQL += " [01] AS MES01, "
	cSQL += " [02] AS MES02, "
	cSQL += " [03] AS MES03, "
	cSQL += " [04] AS MES04, "
	cSQL += " [05] AS MES05, "
	cSQL += " [06] AS MES06, "
	cSQL += " [07] AS MES07, "
	cSQL += " [08] AS MES08, "
	cSQL += " [09] AS MES09, "
	cSQL += " [10] AS MES10, "
	cSQL += " [11] AS MES11, "
	cSQL += " [12] AS MES12  "
	cSQL += " FROM ( "
	cSQL += " 	SELECT * "
	cSQL += " 	FROM ( "
	cSQL += " 		SELECT ZO3_CTAREC, ZO3_CTACUS, ANO, MES, ZO3_PERREC, SUM(VALOR / ZO3_PERREC) VALREC "
	cSQL += " 		FROM ( "
	cSQL += " 			SELECT ZO3_CTAREC, ZO3_CTACUS, "
	cSQL += " 			SUBSTRING(ZBZ.ZBZ_DATA, 1, 4) ANO, "
	cSQL += " 			SUBSTRING(ZBZ.ZBZ_DATA, 5, 2) MES, "
	cSQL += " 			ZO3_PERREC, "
	cSQL += " 			CASE WHEN ZBZ.ZBZ_DEBITO <> '' THEN ZBZ.ZBZ_VALOR ELSE ZBZ.ZBZ_VALOR * -1 END VALOR "
	cSQL += " 			FROM " + RetSqlName("ZO3") + " ZO3 (NOLOCK) "
	cSQL += " 			JOIN " + RetFullName("ZBZ", "01") + " ZBZ (NOLOCK) ON " // RetSqlName("ZBZ")
	cSQL += " 			( "
	cSQL += " 				ZO3.ZO3_FILIAL = '' "
	// cSQL += " 				AND ZO3.ZO3_CTACUS = '61701001' "
	cSQL += " 				AND ( ZBZ_DEBITO = ZO3.ZO3_CTACUS  OR ZBZ_CREDIT = ZO3.ZO3_CTACUS ) "
	cSQL += " 				AND ZBZ.ZBZ_VERSAO = ZO3_VERSAO "
	cSQL += " 				AND ZBZ.ZBZ_REVISA = ZO3_REVISA "
	cSQL += " 				AND ZBZ.ZBZ_ANOREF = ZO3_ANOREF "
	cSQL += " 				AND ZBZ.D_E_L_E_T_ = '' "
	cSQL += " 			) "
	cSQL += " 			WHERE ZO3.D_E_L_E_T_ = '' "
	cSQL += " 			AND ZBZ.ZBZ_VERSAO = " + ValToSql(_cVersao)
	cSQL += " 			AND ZBZ.ZBZ_REVISA = " + ValToSql(_cRevisa)
	cSQL += " 			AND ZBZ.ZBZ_ANOREF = " + ValToSql(_cAnoRef)
	// cSQL += " 			AND ZBZ.ZBZ_DATA BETWEEN '20200101' AND '20201231' "
	cSQL += " 		) TAB1 "
	cSQL += " 		GROUP BY ZO3_CTAREC, ZO3_CTACUS, ANO, MES, ZO3_PERREC "
	cSQL += " 	) LINHA "
	cSQL += " 	PIVOT (SUM(VALREC) FOR MES IN ([01], [02], [03], [04], [05], [06], [07], [08], [09], [10], [11], [12])) COLUNA "
	cSQL += " ) TAB "

	TcQuery cSQL New Alias (cQry)

	_oGetDados:aCols := {}

	While !(cQry)->(EOF())

		_oGetDados:AddLine(.F., .F.)

		For _nW := 1 To Len(_oGetDados:aHeader)

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_VERSAO"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := _cVersao

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_REVISA"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := _cRevisa

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_ANOREF"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := _cAnoRef

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_TIPO"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := "P"

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_CTAREC"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->ZO3_CTAREC

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M01"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES01

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M02"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES02

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M03"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES03

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M04"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES04

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M05"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES05

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M06"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES06

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M07"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES07

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M08"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES08

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M09"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES09

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M10"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES10

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M11"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES11

			EndIf

			If Alltrim(_oGetDados:aHeader[_nW][2]) == "ZO2_M12"

				_oGetDados:aCols[Len(_oGetDados:aCols), _nW] := (cQry)->MES12

			Endif

		Next _nW

		(cQry)->(DbSkip())

	EndDo

	_oGetDados:Refresh()

	(cQry)->(DbCloseArea())

Return()

User Function B597PRO()

	Local cSQL 	:= ""
	Local cQry 	:= GetNextAlias()
	Local _nTot := 0
	Local _nW 	:= 0
	Local _nX 	:= 0

	Local lRet	:= .T.
	Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZBZ	:= GetNextAlias()

	cSQL := " SELECT  "
	cSQL += " CASE WHEN CT1_NORMAL = '1' THEN 'D' ELSE 'C' END TIPOCTA, "
	cSQL += " ZO2.*, ZO3.* "
	cSQL += " FROM " + RetSqlName("ZO2") + " ZO2 (NOLOCK) "
	cSQL += " INNER JOIN " + RetSqlName("ZO3") + " ZO3 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	ZO3.ZO3_FILIAL = '' "
	cSQL += " 	AND ZO3.ZO3_CTAREC = ZO2.ZO2_CTAREC "
	cSQL += " 	AND ZO3.ZO3_VERSAO = ZO2.ZO2_VERSAO "
	cSQL += " 	AND ZO3.ZO3_REVISA = ZO2.ZO2_REVISA "
	cSQL += " 	AND ZO3.ZO3_ANOREF = ZO2.ZO2_ANOREF "
	cSQL += " 	AND ZO3.D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " INNER JOIN " + RetSqlName("CT1") + " CT1 (NOLOCK) ON "
	cSQL += " ( "
	cSQL += " 	CT1.CT1_CONTA = ZO2.ZO2_CTAREC "
	cSQL += " 	AND CT1.D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " WHERE ZO2.ZO2_VERSAO 	= " + ValToSql(_cVersao)
	cSQL += " AND ZO2.ZO2_REVISA 	= " + ValToSql(_cRevisa)
	cSQL += " AND ZO2.ZO2_ANOREF 	= " + ValToSql(_cAnoRef)
	cSQL += " AND ZO2.D_E_L_E_T_ 	= '' "

	TcQuery cSQL New Alias (cQry)

	BEGIN TRANSACTION

		While !(cQry)->(EOF())

			_nTot++

			For _nW := 1 To 12

				For _nX := 1 To 2 // PIS / COFINS

					IF EmpOpenFile(cZBZ, "ZBZ", 1, .T., "01", @cModo)

						Reclock(cZBZ,.T.)
						(cZBZ)->ZBZ_FILIAL := cEmpAnt
						(cZBZ)->ZBZ_VERSAO := (cQry)->ZO2_VERSAO
						(cZBZ)->ZBZ_REVISA := (cQry)->ZO2_REVISA
						(cZBZ)->ZBZ_ANOREF := (cQry)->ZO2_ANOREF
						(cZBZ)->ZBZ_LINHA  := StrZero(_nTot, TAMSX3("ZBZ_LINHA")[1])
						(cZBZ)->ZBZ_DATA	:= LastDay(CToD("01" + "/" + StrZero(_nW, 2) + "/" + (cQry)->ZO2_ANOREF))
						(cZBZ)->ZBZ_DC     := (cQry)->TIPOCTA

						If _nX == 1 // PIS

							(cZBZ)->ZBZ_VALOR  := ( &("(cQry)->ZO2_M" + StrZero(_nW, 2)) * (cQry)->ZO3_PERPIS ) / 100

							(cZBZ)->ZBZ_CREDIT := If((cQry)->TIPOCTA == "C", (cQry)->ZO3_CTAPIS, "")

							(cZBZ)->ZBZ_DEBITO := If((cQry)->TIPOCTA == "D", (cQry)->ZO3_CTAPIS, "")

							(cZBZ)->ZBZ_HIST   := "RECEITA PRESTADORAS - PIS"

						Else // COFINS

							(cZBZ)->ZBZ_VALOR  := ( &("(cQry)->ZO2_M" + StrZero(_nW, 2)) * (cQry)->ZO3_PERCOF ) / 100

							(cZBZ)->ZBZ_CREDIT := If((cQry)->TIPOCTA == "C", (cQry)->ZO3_CTACOF, "")

							(cZBZ)->ZBZ_DEBITO := If((cQry)->TIPOCTA == "D", (cQry)->ZO3_CTACOF, "")

							(cZBZ)->ZBZ_HIST   := "RECEITA PRESTADORAS - COFINS"

						EndIf

						/*
						(cZBZ)->ZBZ_ORIPRC := (cQry)->ZBZ_ORIPRC
						(cZBZ)->ZBZ_ORGLAN := (cQry)->ZBZ_ORGLAN
						(cZBZ)->ZBZ_LOTE   := (cQry)->ZBZ_LOTE
						(cZBZ)->ZBZ_SBLOTE := (cQry)->ZBZ_SBLOTE
						(cZBZ)->ZBZ_DOC    := (cQry)->ZBZ_DOC
						(cZBZ)->ZBZ_CLVLDB := (cQry)->ZBZ_CLVLDB
						(cZBZ)->ZBZ_CLVLCR := (cQry)->ZBZ_CLVLCR
						(cZBZ)->ZBZ_ITEMD  := (cQry)->ZBZ_ITEMD
						(cZBZ)->ZBZ_ITEMC  := (cQry)->ZBZ_ITEMC
						(cZBZ)->ZBZ_YHIST  := (cQry)->ZBZ_YHIST
						(cZBZ)->ZBZ_SI     := (cQry)->ZBZ_SI
						(cZBZ)->ZBZ_YDELTA := STOD((cQry)->ZBZ_YDELTA)
						*/

						(cZBZ)->(MsUnlock())

					Else

						lRet := .F.

						Exit

					EndIf

				Next _nX

			Next _nW

			(cQry)->(DbSkip())

		EndDo

		If !lRet

			DisarmTransaction()

			Aviso("ATENCAO", "Erro no processamento", {"Ok"}, 3)

		EndIf

	END TRANSACTION

	If Select(cZBZ)

		TcRefresh(cZBZ)

		(cZBZ)->(DbCloseArea())

	EndIf

	(cQry)->(DbCloseArea())

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B597IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B597IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !Empty(_cDataRef) .or. !Empty(_cHistFil)
		MsgSTOP("Somente poderá ser usada a rotina de importação quando DataRef e HistFiltro estiverem vazios", "Controle de Importação!!!")
		Return()
	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos ajustes orçamentário direto para a tabela ZO2."))   
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

Return()

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B597IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return()

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZO2'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb
	Local ny
	Local _msc
	Local nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO2_REC_WT"})
	Local vtRecGrd := {}

	_ImpaColsBkp  := aClone(_oGetDados:aCols)

	For vnb := 1 To Len(_ImpaColsBkp)
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

		For nx := 1 To len(aWorksheet)

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6) )	

			If nx == 1

				aCampos := aWorksheet[nx]
				For ny := 1 To len(aCampos)
					cTemp := SubStr(UPPER(aCampos[ny]),AT(cTabImp+'_',UPPER(aCampos[ny])),10)
					aCampos[ny] := cTemp
				Next ny

			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				nLinReg   := 0
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZO2_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						_oGetDados:aCols :=	{}

						_oGetDados:AddLine(.F., .F.)

						_oGetDados:Refresh()

						nLinReg := Len(_oGetDados:aCols)

					EndIf

					For _msc := 1 To Len(aCampos)

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

		_oGetDados:aCols := {}

		_oGetDados:AddLine(.F., .F.)

		_oGetDados:Refresh()

	EndIf

	RestArea(aArea)

Return()
