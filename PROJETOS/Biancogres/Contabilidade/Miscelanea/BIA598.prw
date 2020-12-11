#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA598
@author Wlysses Cerqueira (Facile)
@since 30/10/2020
@version 1.0
@Projet A-35
@description Consolidação empresas grupo para filial 90. 
@type Program
/*/

User Function BIA598()

	Local _aSize 		:= {}
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZO3") + SPACE(TAMSX3("ZO3_VERSAO")[1]) + SPACE(TAMSX3("ZO3_REVISA")[1]) + SPACE(TAMSX3("ZO3_ANOREF")[1])
	Local bWhile	    := {|| ZO3_FILIAL + ZO3_VERSAO + ZO3_REVISA + ZO3_ANOREF }

	Local aNoFields     := {"ZO3_VERSAO", "ZO3_REVISA", "ZO3_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil

	Private _cVersao	:= SPACE(TAMSX3("ZO3_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZO3_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZO3_ANOREF")[1])
	Private _oGAnoRef
	Private _cDataRef	:= ctod("  /  /  ")
	Private _oGDataRef
	// Private _cHistFil	:= SPACE(TAMSX3("ZO3_HIST")[1])
	Private _oGHistFil

	//aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	//aAdd(_aButtons,{"PEDIDO"  ,{|| U_B598IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZO3",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)

	Define MsDialog _oDlg Title "Lançamentos Contábeis p/ Orçamento - Receitas Prestadoras % Rec/Pis/Cofins" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA598A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA598B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA598C()

	// @ 050,310 SAY "DataRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	// @ 048,350 MSGET _oGDataRef VAR _cDataRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA598D()

	// @ 050,410 SAY "HistFiltro:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	// @ 048,450 MSGET _oGHistFil VAR _cHistFil  SIZE 100, 11 OF _oDlg PIXEL VALID fBIA598G()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_B598LOK()" /*[ cLinhaOk]*/, /*[ cTudoOk]*/, "+++ZO3_LINHA" /*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B598FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B598DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons)

Return()

Static Function fBIA598A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return(.F.)
	EndIf

	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA598F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return(.T.)

Static Function fBIA598B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return(.F.)
	EndIf

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA598F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return()

Static Function fBIA598C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return(.F.)
	EndIf

	//If !MsgYesNo("Deseja filtrar por data antes de prosseguir?", "Atenção")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA598F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf
	//EndIf

Return()

Static Function fBIA598D()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA598F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA598G()

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA598F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return()

Static Function fBIA598F()

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
        FROM %TABLE:ZO3% ZO3
        WHERE ZO3_FILIAL = %xFilial:ZO3%
        AND ZO3_VERSAO = %Exp:_cVersao%
        AND ZO3_REVISA = %Exp:_cRevisa%
        AND ZO3_ANOREF = %Exp:_cAnoRef%
        // AND ZO3_DATA = %Exp:_cDataRef%
        //AND ZO3_ORIPRC = 'CONTABIL'
        AND ZO3.%NotDel%
        ) NUMREG
        FROM %TABLE:ZO3% ZO3
        WHERE ZO3_FILIAL = %xFilial:ZO3%
        AND ZO3_VERSAO = %Exp:_cVersao%
        AND ZO3_REVISA = %Exp:_cRevisa%
        AND ZO3_ANOREF = %Exp:_cAnoRef%
        // AND ZO3_DATA = %Exp:_cDataRef%
        //AND ZO3_ORIPRC = 'CONTABIL'
        AND ZO3.%NotDel%
        ORDER BY ZO3_VERSAO, ZO3_REVISA, ZO3_ANOREF, ZO3_LINHA

	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)

	ProcRegua(xtrTot)

	_oGetDados:aCols :=	{}

	(_cAlias)->(dbGoTop())

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			_oGetDados:AddLine(.F., .F.)

			For _msc := 1 to Len(_oGetDados:aHeader)

				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZO3"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_DDEB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZO3_DEBITO, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_DCRD"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + (_cAlias)->ZO3_CREDIT, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_DCVDB"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZO3_CLVLDB, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_DCVCR"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + (_cAlias)->ZO3_CLVLCR, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_DATA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZO3_DATA)

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZO3_YDELTA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod((_cAlias)->ZO3_YDELTA)

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

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO3_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	dbSelectArea('ZO3')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZO3->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))

			Reclock("ZO3",.F.)

			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO3->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO3->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

			Else

				ZO3->(DbDelete())

			EndIf

			ZO3->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZO3",.T.)

				ZO3->ZO3_FILIAL  := xFilial("ZO3")
				ZO3->ZO3_VERSAO  := _cVersao
				ZO3->ZO3_REVISA  := _cRevisa
				ZO3->ZO3_ANOREF  := _cAnoRef

				// ZO3->ZO3_ORIPRC  := "CONTABIL"
				// ZO3->ZO3_LOTE    := "004100"
				// ZO3->ZO3_SBLOTE  := "001"

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] <> "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO3->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					ElseIf _oGetDados:aHeader[_msc][10] == "R" .and. _oGetDados:aHeader[_msc][8] == "D"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZO3->" + Alltrim(_oGetDados:aHeader[_msc][2])) := IIF( Valtype(_oGetDados:aCols[_nI, nPosColG]) == "D", _oGetDados:aCols[_nI, nPosColG], ctod(_oGetDados:aCols[_nI, nPosColG]) )

					EndIf

				Next _msc

				ZO3->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao := SPACE(TAMSX3("ZO3_VERSAO")[1])
	_cRevisa := SPACE(TAMSX3("ZO3_REVISA")[1])
	_cAnoRef := SPACE(TAMSX3("ZO3_ANOREF")[1])

	_oGetDados:aCols :=	{}

	_oGetDados:AddLine(.F., .F.)

	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()

	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return()

User Function B598FOK()

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

		Case Alltrim(cMenVar) == "M->ZO3_DC"
			isDC       := M->ZO3_DC
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !isDC $ "1/2/3"
				MsgINFO("Somente são permitidos os valores 1=Débito; 2=Crédito; 3=Partida Dobrada")
				Return(.F.)
			EndIf
			GdFieldPut("ZO3_ORGLAN" , IIF(isDC == "1", "D", IIF(isDC == "2", "C", IIF(isDC == "3", "P", ""))) , _nAt)

		Case Alltrim(cMenVar) == "M->ZO3_DEBITO"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := M->ZO3_DEBITO
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !Empty(isDEBITO)
				If !ExistCPO("CT1")
					Return(.F.)
				EndIf
			EndIf
			GdFieldPut("ZO3_DDEB"     , Posicione("CT1", 1, xFilial("CT1") + isDEBITO, "CT1_DESC01") , _nAt)

		Case Alltrim(cMenVar) == "M->ZO3_CREDIT"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := M->ZO3_CREDIT
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !Empty(isCREDIT)
				If !ExistCPO("CT1")
					Return(.F.)
				EndIf
			EndIf
			GdFieldPut("ZO3_DCRD"     , Posicione("CT1", 1, xFilial("CT1") + isCREDIT, "CT1_DESC01") , _nAt)

		Case Alltrim(cMenVar) == "M->ZO3_CLVLDB"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := M->ZO3_CLVLDB
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !Empty(isCLVLDB)
				If !ExistCPO("CTH")
					Return(.F.)
				EndIf
			EndIf
			If !U_B598VdCl(isCLVLDB)
				MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
				Return(.F.)
			EndIf
			GdFieldPut("ZO3_DCVDB"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLDB, "CTH_DESC01") , _nAt)

		Case Alltrim(cMenVar) == "M->ZO3_CLVLCR"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := M->ZO3_CLVLCR
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !Empty(isCLVLCR)
				If !ExistCPO("CTH")
					Return(.F.)
				EndIf
			EndIf
			If !U_B598VdCl(isCLVLCR)
				MsgINFO("A classe de valor informada não está associada a empresa orçamentária posicionada.")
				Return(.F.)
			EndIf
			GdFieldPut("ZO3_DCVCR"    , Posicione("CTH", 1, xFilial("CTH") + isCLVLCR, "CTH_DESC01") , _nAt)

		Case Alltrim(cMenVar) == "M->ZO3_ITEMD"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := M->ZO3_ITEMD
			isITEMC    := GdFieldGet("ZO3_ITEMC",_nAt)
			If !ExistCPO("CTD")
				Return(.F.)
			EndIf

		Case Alltrim(cMenVar) == "M->ZO3_ITEMC"
			isDC       := GdFieldGet("ZO3_DC",_nAt)
			isDEBITO   := GdFieldGet("ZO3_DEBITO",_nAt)
			isCREDIT   := GdFieldGet("ZO3_CREDIT",_nAt)
			isCLVLDB   := GdFieldGet("ZO3_CLVLDB",_nAt)
			isCLVLCR   := GdFieldGet("ZO3_CLVLCR",_nAt)
			isITEMD    := GdFieldGet("ZO3_ITEMD",_nAt)
			isITEMC    := M->ZO3_ITEMC
			If !ExistCPO("CTD")
				Return(.F.)
			EndIf

		EndCase

	EndIf

Return(.T.)

User Function B598LOK()

	Local _lRet	:=	.T.
	xxDC       := GdFieldGet("ZO3_DC", n)
	xxDEBITO   := GdFieldGet("ZO3_DEBITO", n)
	xxCREDIT   := GdFieldGet("ZO3_CREDIT", n)
	xxCLVLDB   := GdFieldGet("ZO3_CLVLDB", n)
	xxCLVLCR   := GdFieldGet("ZO3_CLVLCR", n)
	xxITEMD    := GdFieldGet("ZO3_ITEMD", n)
	xxITEMC    := GdFieldGet("ZO3_ITEMC", n)

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

User Function B598DOK()

	Local _lRet	:=	.T.

Return(_lRet)

User Function B598VdCl(ksCLVL)

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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B598IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B598IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !Empty(_cDataRef) .or. !Empty(_cHistFil)
		MsgSTOP("Somente poderá ser usada a rotina de importação quando DataRef e HistFiltro estiverem vazios", "Controle de Importação!!!")
		Return()
	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos ajustes orçamentário direto para a tabela ZO3."))   
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
	Local cLoad	    := 'B598IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZO3'
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZO3_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZO3_REC_WT"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})

					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						_oGetDados:aCols :=	{}

						_oGetDados:AddLine(.F., .F.)

						_oGetDados:Refresh()

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

        _oGetDados:aCols :=	{}

		_oGetDados:AddLine(.F., .F.)

        _oGetDados:Refresh()

	EndIf

	RestArea(aArea)

Return()
