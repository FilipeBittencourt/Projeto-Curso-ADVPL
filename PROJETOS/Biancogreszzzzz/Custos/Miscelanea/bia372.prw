#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA372
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para cadastro de Cruzamento de CtaContábil x CLVL para Rateio de custo
@type function
/*/

User Function BIA372()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBQ") + SPACE(TAMSX3("ZBQ_VERSAO")[1]) + SPACE(TAMSX3("ZBQ_REVISA")[1]) + SPACE(TAMSX3("ZBQ_ANOREF")[1]) + SPACE(TAMSX3("ZBQ_LINHAF")[1]) + SPACE(TAMSX3("ZBQ_RATCTA")[1])
	Local bWhile	    := {|| ZBQ_FILIAL + ZBQ_VERSAO + ZBQ_REVISA + ZBQ_ANOREF + ZBQ_LINHAF + ZBQ_RATCTA}   

	Local aNoFields     := {"ZBQ_VERSAO", "ZBQ_REVISA", "ZBQ_ANOREF", "ZBQ_LINHAF", "ZBQ_RATCTA", "ZBQ_DRTCTA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	  := Nil    
	Private _aColsBkp	  := {}
	Private _cVersao	  := SPACE(TAMSX3("ZBQ_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	  := SPACE(TAMSX3("ZBQ_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	  := SPACE(TAMSX3("ZBQ_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodRatCta	  := SPACE(TAMSX3("ZBQ_RATCTA")[1])
	Private _oGCodRatCta
	Private _mNomeRatCta  := SPACE(50)
	Private _cCodLinhaF	  := SPACE(TAMSX3("ZBQ_LINHAF")[1])
	Private _oGCodLinhaf
	Private _mNomeLinhaF  := SPACE(50)

	Private _msCtrlAlt := .T. 

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBQ",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cruzamento de CtaContábil x CLVL" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA372A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA372B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA372C()

	@ 050,310 SAY "RatCtaC:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodRatCta VAR _cCodRatCta F3("ZF1") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA372D()
	@ 050,410 SAY _mNomeRatCta SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	@ 050,510 SAY "LinhaF:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,550 MSGET _oGCodLinhaf VAR _cCodLinhaF F3("ZCO") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA372F()
	@ 050,610 SAY _mNomeLinhaF SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA372A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRatCta) .and. !Empty(_cCodLinhaF)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA372F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA372B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRatCta) .and. !Empty(_cCodLinhaF)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA372F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA372C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRatCta) .and. !Empty(_cCodLinhaF)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA372F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA372D()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo RatCtaC é Obrigatório!!!")
		Return .F.
	EndIf

	_mNomeRatCta := Posicione("ZF1", 1, xFilial("ZF1") + _cCodRatCta, "ZF1_DESCR")

	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRatCta) .and. !Empty(_cCodLinhaF)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA372F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA372F()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()`
	Local _msc

	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodRatCta) .or. Empty(_cCodLinhaF)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mNomeLinhaF := Posicione("ZCO", 1, xFilial("ZCO") + _cCodLinhaF, "ZCO_LINHA")

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
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
		_msCtrlAlt := .F.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .F.
		_oGetDados:lDelete := .F.
	Else
		_msCtrlAlt := .T.
		_oGetDados:lInsert := .F.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	// Confirma e gera registros na tabela de Verbas Eventuais para os casos em que os registros não foram incluídos
	RG003 := " SELECT ZF2_CODIGO, "
	RG003 += "        ZF2_DESCR, "
	RG003 += "        ISNULL(ZBQ_ATRBCT, '') ATRBCT, " 
	RG003 += "        ISNULL(ZBQ.R_E_C_N_O_, 0) REGZBQ "
	RG003 += " FROM " + RetSqlName("ZF2") + " ZF2 (NOLOCK) "
	RG003 += "      LEFT JOIN " + RetSqlName("ZBQ") + " ZBQ (NOLOCK) ON ZBQ.ZBQ_FILIAL = '" + xFilial("ZBQ") + "' "
	RG003 += "                                        AND ZBQ.ZBQ_VERSAO = '" + _cVersao + "' "
	RG003 += "                                        AND ZBQ.ZBQ_REVISA = '" + _cRevisa + "' "
	RG003 += "                                        AND ZBQ.ZBQ_ANOREF = '" + _cAnoRef + "' "
	RG003 += "                                        AND ZBQ.ZBQ_LINHAF = '" + _cCodLinhaF + "' "
	RG003 += "                                        AND ZBQ.ZBQ_RATCTA = '" + _cCodRatCta + "' "
	RG003 += "                                        AND ZBQ.ZBQ_RATCLV = ZF2_CODIGO "
	RG003 += "                                        AND ZBQ.D_E_L_E_T_ = ' ' "
	RG003 += " WHERE ZF2.ZF2_FILIAL = '" + xFilial("ZF2") + "' "
	RG003 += "   AND ZF2.D_E_L_E_T_ = ' ' "
	RG003 += " ORDER BY ZF2.ZF2_CODIGO "
	RGIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
	dbSelectArea("RG03")
	RG03->(dbGoTop())

	If RG03->(!Eof())

		While RG03->(!Eof())

			If RG03->REGZBQ == 0
				Reclock("ZBQ",.T.)
				ZBQ->ZBQ_FILIAL  := xFilial("ZBQ")
				ZBQ->ZBQ_VERSAO  := _cVersao
				ZBQ->ZBQ_REVISA  := _cRevisa
				ZBQ->ZBQ_ANOREF  := _cAnoRef
				ZBQ->ZBQ_LINHAF  := _cCodLinhaF
				ZBQ->ZBQ_RATCTA  := _cCodRatCta
				ZBQ->ZBQ_DRTCTA  := _mNomeRatCta
			Else
				ZBQ->(dbGoTo(RG03->REGZBQ))
				Reclock("ZBQ",.F.)
			EndIf
			ZBQ->ZBQ_RATCLV  := RG03->ZF2_CODIGO
			ZBQ->ZBQ_DRTCLV  := RG03->ZF2_DESCR
			ZBQ->ZBQ_ATRBCT  := RG03->ATRBCT
			ZBQ->(MsUnlock())

			RG03->(dbSkip())

		End

	EndIf

	RG03->(dbCloseArea())
	Ferase(RGIndex+GetDBExtension())
	Ferase(RGIndex+OrdBagExt())

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBQ% ZBQ
		WHERE ZBQ_FILIAL = %xFilial:ZBQ%
		AND ZBQ_VERSAO = %Exp:_cVersao%
		AND ZBQ_REVISA = %Exp:_cRevisa%
		AND ZBQ_ANOREF = %Exp:_cAnoRef%
		AND ZBQ_LINHAF = %Exp:_cCodLinhaF%
		AND ZBQ_RATCTA = %Exp:_cCodRatCta%
		AND ZBQ.%NotDel%
		ORDER BY ZBQ_VERSAO, ZBQ_REVISA, ZBQ_ANOREF, ZBQ_LINHAF, ZBQ_RATCTA

	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBQ_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBQ"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBQ_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

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

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBQ_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	
	Local _msc

	If _msCtrlAlt

		dbSelectArea('ZBQ')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBQ->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBQ",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBQ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZBQ->(DbDelete())

				EndIf

				ZBQ->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBQ",.T.)

					ZBQ->ZBQ_FILIAL  := xFilial("ZBQ")
					ZBQ->ZBQ_VERSAO  := _cVersao
					ZBQ->ZBQ_REVISA  := _cRevisa
					ZBQ->ZBQ_ANOREF  := _cAnoRef
					ZBQ->ZBQ_LINHAF  := _cCodLinhaF
					ZBQ->ZBQ_RATCTA  := _cCodRatCta
					ZBQ->ZBQ_DRTCTA  := _mNomeRatCta
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBQ->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZBQ->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBQ_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBQ_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBQ_ANOREF")[1])
	_cCodRatCta     := SPACE(TAMSX3("ZBQ_RATCTA")[1])
	_mNomeRatCta    := SPACE(50)
	_cCodLinhaF     := SPACE(TAMSX3("ZBQ_LINHAF")[1])
	_mNomeLinhaF    := SPACE(50)
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
