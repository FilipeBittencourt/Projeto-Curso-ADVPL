#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA591
@author Marcos Alberto Soprani
@since 02/11/17
@version 1.0
@description Tela para cadastro das Contas de Ativo para Contas de Depreciação
@type function
/*/

User Function BIA591()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBX") + SPACE(TAMSX3("ZBX_VERSAO")[1]) + SPACE(TAMSX3("ZBX_REVISA")[1]) + SPACE(TAMSX3("ZBX_ANOREF")[1])
	Local bWhile	    := {|| ZBX_FILIAL + ZBX_VERSAO + ZBX_REVISA + ZBX_ANOREF }                    
	Local aNoFields     := {"ZBX_VERSAO", "ZBX_REVISA", "ZBX_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBX_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBX_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBX_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel", "Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBX",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Contas de Ativo para Contas de Depreciação" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA591A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA591B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA591C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_INSERT + GD_UPDATE + GD_DELETE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, "U_B591FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B591DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA591A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA591C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA591B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA591C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA591C()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CAPEX" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"

	BeginSql Alias M001
	SELECT COUNT(*) CONTAD
	FROM %TABLE:ZB5% ZB5
	WHERE ZB5_FILIAL = %xFilial:ZB5%
	AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
	AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
	AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
	AND RTRIM(ZB5.ZB5_TPORCT) = 'CAPEX'
	AND ZB5.ZB5_STATUS = 'A'
	AND ZB5.ZB5_DTDIGT = ''
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
		_oGetDados:lInsert := .T.
		_oGetDados:lUpdate := .T.
		_oGetDados:lDelete := .T.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZBX% ZBX
	WHERE ZBX_FILIAL = %xFilial:ZBX%
	AND ZBX_VERSAO = %Exp:_cVersao%
	AND ZBX_REVISA = %Exp:_cRevisa%
	AND ZBX_ANOREF = %Exp:_cAnoRef%
	AND ZBX.%NotDel%
	ORDER BY ZBX.ZBX_CTAATV, ZBX.ZBX_CHVCV, ZBX.ZBX_CTADPR
	EndSql

	ProcRegua(0)

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno() ))))

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZBX_CTAATV,;
			ZBX_CTADPR,;
			ZBX_CHVCV,;
			ZBX_TXDPRE,;
			"ZBX",;
			R_E_C_N_O_,;
			.F.	}))

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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBX_REC_WT"})
	Local _mCTAATV := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBX_CTAATV"})
	Local _mCTADPR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBX_CTADPR"})
	Local _mCHVCV  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBX_CHVCV"})
	Local _mTXDPRE := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBX_TXDPRE"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBX')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBX->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBX",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					ZBX->ZBX_CTAATV  := _oGetDados:aCols[_nI,_mCTAATV]
					ZBX->ZBX_CTADPR  := _oGetDados:aCols[_nI,_mCTADPR]
					ZBX->ZBX_CHVCV   := _oGetDados:aCols[_nI,_mCHVCV]
					ZBX->ZBX_TXDPRE  := _oGetDados:aCols[_nI,_mTXDPRE]

				Else

					ZBX->(DbDelete())

				EndIf

				ZBX->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBX",.T.)
					ZBX->ZBX_FILIAL  := xFilial("ZBX")
					ZBX->ZBX_VERSAO  := _cVersao
					ZBX->ZBX_REVISA  := _cRevisa
					ZBX->ZBX_ANOREF  := _cAnoRef
					ZBX->ZBX_CTAATV  := _oGetDados:aCols[_nI,_mCTAATV]
					ZBX->ZBX_CTADPR  := _oGetDados:aCols[_nI,_mCTADPR]
					ZBX->ZBX_CHVCV   := _oGetDados:aCols[_nI,_mCHVCV]
					ZBX->ZBX_TXDPRE  := _oGetDados:aCols[_nI,_mTXDPRE]
					ZBX->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZBX_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZBX_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZBX_ANOREF")[1])
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

User Function B591FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpCTAATV   := ""
	Local _zpCTADPR   := ""
	Local _zpCHVCV    := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZBX_CTAATV"
		_zpCTAATV   := M->ZBX_CTAATV
		_zpCTADPR   := GdFieldGet("ZBX_CTADPR",_nAt)
		_zpCHVCV    := GdFieldGet("ZBX_CHVCV",_nAt)
		If !ExistCPO("CT1")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZBX_CTADPR"
		_zpCTAATV   := GdFieldGet("ZBX_CTAATV",_nAt)
		_zpCTADPR   := M->ZBX_CTADPR
		_zpCHVCV    := GdFieldGet("ZBX_CHVCV",_nAt)
		If !ExistCPO("CT1")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZBX_CHVCV"
		_zpCTAATV   := GdFieldGet("ZBX_CTAATV",_nAt)
		_zpCTADPR   := GdFieldGet("ZBX_CTADPR",_nAt)
		_zpCHVCV    := M->ZBX_CHVCV

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpCTAATV) .and. _zpCTAATV == GdFieldGet("ZBX_CTAATV",_nI)

				If !Empty(_zpCTADPR) .and. _zpCTADPR == GdFieldGet("ZBX_CTADPR",_nI)

					If !Empty(_zpCHVCV) .and. _zpCHVCV == GdFieldGet("ZBX_CHVCV",_nI)

						MsgInfo("Não poderá haver a mesma chave (Cta Ativo/Cta Deprec/ChvCV) informada mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a chave informada!!!")
						Return .F.

					EndIf

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B591DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
