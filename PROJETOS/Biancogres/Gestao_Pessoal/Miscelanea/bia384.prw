#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA384
@author Marcos Alberto Soprani
@since 13/09/17
@version 1.0
@description Tela para cadastro de variáveis diversas que servirão de base para algum cálculo no processo orçamentário 
@type function
/*/

User Function BIA384()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB3") + SPACE(TAMSX3("ZB3_VERSAO")[1]) + SPACE(TAMSX3("ZB3_REVISA")[1]) + SPACE(TAMSX3("ZB3_ANOREF")[1])
	Local bWhile	    := {|| ZB3_FILIAL + ZB3_VERSAO + ZB3_REVISA + ZB3_ANOREF }                    
	Local aNoFields     := {"ZB3_VERSAO", "ZB3_REVISA", "ZB3_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB3_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB3_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB3_ANOREF")[1])
	Private _oGAnoRef

	Private _msCtrlAlt := .F.

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB3",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Variáveis Diversas" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA384A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA384B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA384C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B384FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B384DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA384A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA384C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA384B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA384C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA384C()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
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
		FROM %TABLE:ZB3% ZB3
		WHERE ZB3_FILIAL = %xFilial:ZB3%
		AND ZB3_VERSAO = %Exp:_cVersao%
		AND ZB3_REVISA = %Exp:_cRevisa%
		AND ZB3_ANOREF = %Exp:_cAnoRef%
		AND ZB3.%NotDel%
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB3_CODVAR,;
			ZB3_VARIAV,;
			ZB3_DESCRI,;
			ZB3_VCHEIO,;
			"ZB3",;
			R_E_C_N_O_,;
			.F.	}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		(_cAlias)->(aAdd(_oGetDados:aCols, {"001", "zmSalMin", "SALARIO MINIMO"                    , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"002", "zmPrmPrd", "PREMIO DE PRODUTIVIDADE"           , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"003", "zmValTrs", "VT - REGIONAL - GRANDE VITORIA"    , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B05", "zmRefeic", "REFEICAO"                          , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B10", "zmDesejm", "DESJEJUM"                          , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B15", "zmCrtAlm", "CARTAO ALIMENTACAO"                , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B20", "zmCJanTr", "CARTAO JANTAR (TURNO)"             , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B25", "zmCJanNo", "CARTAO JANTAR (TODAS AS NOITES)"   , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B30", "zmCrtCom", "CARTAO COMBUSTIVEL"                , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B35", "zmAjdCBd", "AJUDA DE CUSTO BANCO DE DADOS"     , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B40", "zmCfccCh", "CONFECCAO DE CRACHAS NOVOS FU"     , 0, "ZB3", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {"B45", "zmReeDesp", "REEMBOLSO DE DESPESAS DE VENDA"    , 0, "ZB3", 0, .F. }))
	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB3_REC_WT"})
	Local _mCODVAR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB3_CODVAR"})
	Local _mVARIAV := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB3_VARIAV"})
	Local _mDESCRI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB3_DESCRI"})
	Local _mVCHEIO := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB3_VCHEIO"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZB3')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZB3->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZB3",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					ZB3->ZB3_CODVAR := _oGetDados:aCols[_nI,_mCODVAR]
					ZB3->ZB3_VARIAV := _oGetDados:aCols[_nI,_mVARIAV]
					ZB3->ZB3_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]
					ZB3->ZB3_VCHEIO := _oGetDados:aCols[_nI,_mVCHEIO]

				Else

					ZB3->(DbDelete())

				EndIf

				ZB3->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZB3",.T.)
					ZB3->ZB3_FILIAL := xFilial("ZB3")
					ZB3->ZB3_VERSAO := _cVersao
					ZB3->ZB3_REVISA := _cRevisa
					ZB3->ZB3_ANOREF := _cAnoRef
					ZB3->ZB3_CODVAR := _oGetDados:aCols[_nI,_mCODVAR]
					ZB3->ZB3_VARIAV := _oGetDados:aCols[_nI,_mVARIAV]
					ZB3->ZB3_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]
					ZB3->ZB3_VCHEIO := _oGetDados:aCols[_nI,_mVCHEIO]
					ZB3->(MsUnlock())

				EndIf

			EndIf

		Next

	End

	_cVersao		    :=	SPACE(TAMSX3("ZB3_VERSAO")[1])
	_cRevisa		    :=	SPACE(TAMSX3("ZB3_REVISA")[1])
	_cAnoRef		    :=	SPACE(TAMSX3("ZB3_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B384FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbVCHEIO := 0

	Do Case

		Case Alltrim(cMenVar) == "M->ZB3_VCHEIO"
		_gbVCHEIO := M->ZB3_VCHEIO

	EndCase

Return .T.

User Function B384DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
