#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA388
@author Marcos Alberto Soprani
@since 13/09/17
@version 1.0
@description Tela para cadastro de Calendário de Feriados Efetivos p/ H.E. Programadas   
@type function
/*/

User Function BIA388()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB7") + SPACE(TAMSX3("ZB7_VERSAO")[1]) + SPACE(TAMSX3("ZB7_REVISA")[1]) + SPACE(TAMSX3("ZB7_ANOREF")[1])
	Local bWhile	    := {|| ZB7_FILIAL + ZB7_VERSAO + ZB7_REVISA + ZB7_ANOREF }                    
	Local aNoFields     := {"ZB7_VERSAO", "ZB7_REVISA", "ZB7_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB7_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB7_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB7_ANOREF")[1])
	Private _oGAnoRef

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB7",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Feriados Efetidos p/ H.E. Programadas" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA388A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA388B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA388C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B388FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B388DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA388A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA388C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA388B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA388C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA388C()

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
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZB7% ZB7
	WHERE ZB7_FILIAL = %xFilial:ZB7%
	AND ZB7_VERSAO = %Exp:_cVersao%
	AND ZB7_REVISA = %Exp:_cRevisa%
	AND ZB7_ANOREF = %Exp:_cAnoRef%
	AND ZB7.%NotDel%
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB7_ANOMES,;
			ZB7_DESCMS,;
			ZB7_NRFERI,;
			"ZB7",;
			R_E_C_N_O_,;
			.F.	}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "01", "Janeiro"    , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "02", "Fevereiro"  , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "03", "Março"      , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "04", "Abril"      , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "05", "Maio"       , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "06", "Junho"      , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "07", "Julho"      , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "08", "Agosto"     , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "09", "Setembro"   , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "10", "Outubro"    , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "11", "Novembro"   , 0, "ZB7", 0, .F. }))
		(_cAlias)->(aAdd(_oGetDados:aCols, {_cAnoRef + "12", "Dezembro"   , 0, "ZB7", 0, .F. }))

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB7_REC_WT"})
	Local _mANOMES := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB7_ANOMES"})
	Local _mDESCMS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB7_DESCMS"})
	Local _mNRFERI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB7_NRFERI"})
	Local nPosDel  := Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZB7')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZB7->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZB7",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZB7->ZB7_ANOMES := _oGetDados:aCols[_nI,_mANOMES]
				ZB7->ZB7_DESCMS := _oGetDados:aCols[_nI,_mDESCMS]
				ZB7->ZB7_NRFERI := _oGetDados:aCols[_nI,_mNRFERI]

			Else

				ZB7->(DbDelete())

			EndIf

			ZB7->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZB7",.T.)
				ZB7->ZB7_FILIAL := xFilial("ZB7")
				ZB7->ZB7_VERSAO := _cVersao
				ZB7->ZB7_REVISA := _cRevisa
				ZB7->ZB7_ANOREF := _cAnoRef
				ZB7->ZB7_ANOMES := _oGetDados:aCols[_nI,_mANOMES]
				ZB7->ZB7_DESCMS := _oGetDados:aCols[_nI,_mDESCMS]
				ZB7->ZB7_NRFERI := _oGetDados:aCols[_nI,_mNRFERI]
				ZB7->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao		    :=	SPACE(TAMSX3("ZB7_VERSAO")[1])
	_cRevisa		    :=	SPACE(TAMSX3("ZB7_REVISA")[1])
	_cAnoRef		    :=	SPACE(TAMSX3("ZB7_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B388FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbNRFERI := 0

	Do Case

		Case Alltrim(cMenVar) == "M->ZB7_NRFERI"
		_gbVCHEIO := M->ZB7_NRFERI

	EndCase

Return .T.

User Function B388DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
