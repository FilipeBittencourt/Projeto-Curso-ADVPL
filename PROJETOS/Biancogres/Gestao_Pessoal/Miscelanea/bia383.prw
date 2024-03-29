#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA383
@author Marcos Alberto Soprani
@since 13/09/17
@version 1.0
@description Tela para cadastro das metricas or�ament�rias de Encargos Trabalhistas 
@type function
/*/

User Function BIA383()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB2") + SPACE(TAMSX3("ZB2_VERSAO")[1]) + SPACE(TAMSX3("ZB2_REVISA")[1]) + SPACE(TAMSX3("ZB2_ANOREF")[1])
	Local bWhile	    := {|| ZB2_FILIAL + ZB2_VERSAO + ZB2_REVISA + ZB2_ANOREF }                    
	Local aNoFields     := {"ZB2_VERSAO", "ZB2_REVISA", "ZB2_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB2_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB2_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB2_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC" ,{|| U_B383RPCSET()}, "Reprocessa Enc.Trabalhistas", "Reprocessa Enc.Trabalhistas"})
	aAdd(_aButtons,{"PRODUTO"  ,{|| U_BIA393("E")} , "Layout Integra��o"          , "Layout Integra��o"})
	aAdd(_aButtons,{"PEDIDO"   ,{|| U_B383IEXC() } , "Importa Arquivo"            , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"    ,{|| U_B383RPLC() } , "Replica Registros"          , "Replica Registros"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB2",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Custo c/ Encargos Trabalhistas" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Vers�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA383A()

	@ 050,110 SAY "Revis�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA383B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA383C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B383TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B383FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B383DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA383A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Vers�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA383C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA383B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revis�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA383C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA383C()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Or�amento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digita��o igual a branco" + msrhEnter
	xfMensCompl += "Data Concilia��o igual a branco" + msrhEnter
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
		MsgALERT("A vers�o informada n�o est� ativa para execu��o deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de vers�o conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o respons�vel pelo processo Or�ament�rio!!!")
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
		FROM %TABLE:ZB2% ZB2
		WHERE ZB2_FILIAL = %xFilial:ZB2%
		AND ZB2_VERSAO = %Exp:_cVersao%
		AND ZB2_REVISA = %Exp:_cRevisa%
		AND ZB2_ANOREF = %Exp:_cAnoRef%
		AND ZB2.%NotDel%
		ORDER BY ZB2.ZB2_FILIAL, ZB2.ZB2_ENCARG, ZB2.ZB2_CATGFU

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB2_ENCARG,;
			ZB2_CATGFU,;
			ZB2_DESCCF,;
			ZB2_PRCBAS,;
			ZB2_PRCEMP,;
			ZB2_PRCTER,;
			ZB2_PRCACT,;
			ZB2_PRCSEN,;
			ZB2_PRCSES,;
			ZB2_PRCRAT,;
			ZB2_PRCTOT,;
			"ZB2",;
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_REC_WT"})
	Local _mENCARG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_ENCARG"})
	Local _mCATGFU := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_CATGFU"})
	Local _mDESCCF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_DESCCF"})
	Local _mPRCBAS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCBAS"})
	Local _mPRCEMP := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCEMP"})
	Local _mPRCTER := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCTER"})
	Local _mPRCACT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCACT"})
	Local _mPRCSEN := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCSEN"})
	Local _mPRCSES := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCSES"})
	Local _mPRCRAT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCRAT"})
	Local _mPRCTOT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_PRCTOT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1

	If _msCtrlAlt

		dbSelectArea('ZB2')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZB2->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				If !_oGetDados:aCols[_nI,nPosDel]

					If ZB2->ZB2_VERSAO == _cVersao .and. ZB2->ZB2_REVISA == _cRevisa .and. ZB2->ZB2_ANOREF == _cAnoRef
						Reclock("ZB2",.F.)
					Else
						Reclock("ZB2",.T.)
						ZB2->ZB2_FILIAL  := xFilial("ZB2")
						ZB2->ZB2_VERSAO  := _cVersao
						ZB2->ZB2_REVISA  := _cRevisa
						ZB2->ZB2_ANOREF  := _cAnoRef
					EndIf
					ZB2->ZB2_ENCARG := _oGetDados:aCols[_nI,_mENCARG]
					ZB2->ZB2_CATGFU := _oGetDados:aCols[_nI,_mCATGFU]
					ZB2->ZB2_DESCCF := _oGetDados:aCols[_nI,_mDESCCF]
					ZB2->ZB2_PRCBAS := _oGetDados:aCols[_nI,_mPRCBAS]
					ZB2->ZB2_PRCEMP := _oGetDados:aCols[_nI,_mPRCEMP]
					ZB2->ZB2_PRCTER := _oGetDados:aCols[_nI,_mPRCTER]
					ZB2->ZB2_PRCACT := _oGetDados:aCols[_nI,_mPRCACT]
					ZB2->ZB2_PRCSEN := _oGetDados:aCols[_nI,_mPRCSEN]
					ZB2->ZB2_PRCSES := _oGetDados:aCols[_nI,_mPRCSES]
					ZB2->ZB2_PRCRAT := _oGetDados:aCols[_nI,_mPRCRAT]
					ZB2->ZB2_PRCTOT := _oGetDados:aCols[_nI,_mPRCTOT]
					ZB2->(MsUnlock())

				Else

					Reclock("ZB2",.F.)
					ZB2->(DbDelete())
					ZB2->(MsUnlock())

				EndIf

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZB2",.T.)
					ZB2->ZB2_FILIAL := xFilial("ZB2")
					ZB2->ZB2_VERSAO := _cVersao
					ZB2->ZB2_REVISA := _cRevisa
					ZB2->ZB2_ANOREF := _cAnoRef
					ZB2->ZB2_ENCARG := _oGetDados:aCols[_nI,_mENCARG]
					ZB2->ZB2_CATGFU := _oGetDados:aCols[_nI,_mCATGFU]
					ZB2->ZB2_DESCCF := _oGetDados:aCols[_nI,_mDESCCF]
					ZB2->ZB2_PRCBAS := _oGetDados:aCols[_nI,_mPRCBAS]
					ZB2->ZB2_PRCEMP := _oGetDados:aCols[_nI,_mPRCEMP]
					ZB2->ZB2_PRCTER := _oGetDados:aCols[_nI,_mPRCTER]
					ZB2->ZB2_PRCACT := _oGetDados:aCols[_nI,_mPRCACT]
					ZB2->ZB2_PRCSEN := _oGetDados:aCols[_nI,_mPRCSEN]
					ZB2->ZB2_PRCSES := _oGetDados:aCols[_nI,_mPRCSES]
					ZB2->ZB2_PRCRAT := _oGetDados:aCols[_nI,_mPRCRAT]
					ZB2->ZB2_PRCTOT := _oGetDados:aCols[_nI,_mPRCTOT]
					ZB2->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		    :=	SPACE(TAMSX3("ZB2_VERSAO")[1])
	_cRevisa		    :=	SPACE(TAMSX3("ZB2_REVISA")[1])
	_cAnoRef		    :=	SPACE(TAMSX3("ZB2_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Inclu�do com Sucesso!")

	Else

		MsgALERT("Nenhum registro foi atualizado!")

	EndIf

Return

User Function B383FOK()

	Local cMenVar   := ReadVar()
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbENCARG := ""
	Local _gbCATGFU := ""
	Local _gbPRCBAS := 0
	Local _gbPRCEMP := 0
	Local _gbPRCTER := 0
	Local _gbPRCACT := 0
	Local _gbPRCSEN := 0
	Local _gbPRCSES := 0
	Local _gbPRCRAT := 0
	Local _gbPRCTOT := 0

	Do Case

		Case Alltrim(cMenVar) == "M->ZB2_ENCARG"
		_gbENCARG := M->ZB2_ENCARG
		_gbCATGFU := GdFieldGet("ZB2_CATGFU",_nAt)
		If Empty(M->ZB2_ENCARG)
			MsgInfo("Necess�rio informar o Encargo!!!")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZB2_CATGFU"
		_gbENCARG := GdFieldGet("ZB2_ENCARG",_nAt)
		_gbCATGFU := M->ZB2_CATGFU
		If Empty(M->ZB2_CATGFU)
			MsgInfo("Necess�rio informar a Categoria do funcion�rio que aplica o Encargo!!!")
			Return .F.
		EndIf
		If !ExistCPO("ZB4")
			MsgInfo("Registro n�o cadastrado!!!")
			Return .F.
		EndIf

		GdFieldPut("ZB2_DESCCF" , Posicione("ZB4", 1, xFilial("ZB5") + _gbCATGFU, "ZB4_DESCRI")     , _nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCBAS"
		If M->ZB2_PRCBAS == 0 .and. !cEmpAnt $ "07/13"
			MsgInfo("Necess�rio informar o % sobre o qual ser� aplicado o Encargo!!!")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZB2_PRCBAS"
		_gbPRCBAS := M->ZB2_PRCBAS
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCEMP"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := M->ZB2_PRCEMP
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCTER"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := M->ZB2_PRCTER
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCACT"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := M->ZB2_PRCACT
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCSEN"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := M->ZB2_PRCSEN
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCSES"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := M->ZB2_PRCSES
		_gbPRCRAT := GdFieldGet("ZB2_PRCRAT",_nAt)

		Case Alltrim(cMenVar) == "M->ZB2_PRCRAT"
		_gbPRCBAS := GdFieldGet("ZB2_PRCBAS",_nAt)
		_gbPRCEMP := GdFieldGet("ZB2_PRCEMP",_nAt)
		_gbPRCTER := GdFieldGet("ZB2_PRCTER",_nAt)
		_gbPRCACT := GdFieldGet("ZB2_PRCACT",_nAt)
		_gbPRCSEN := GdFieldGet("ZB2_PRCSEN",_nAt)
		_gbPRCSES := GdFieldGet("ZB2_PRCSES",_nAt)
		_gbPRCRAT := M->ZB2_PRCRAT

	EndCase

	_gbPRCTOT := ( _gbPRCEMP + _gbPRCTER + _gbPRCACT + _gbPRCSEN + _gbPRCSES + _gbPRCRAT ) * ( _gbPRCBAS / 100 )
	GdFieldPut("ZB2_PRCTOT" , _gbPRCTOT     , _nAt)

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_gbENCARG) .and. _gbENCARG == GdFieldGet("ZB2_ENCARG",_nI)

				If !Empty(_gbCATGFU) .and. _gbCATGFU == GdFieldGet("ZB2_CATGFU",_nI)

					MsgInfo("N�o poder� haver a mesma Categoria Func informada para o mesmo Encargo mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " j� existe a Categoria Func informada!!!")
					Return .F.

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B383DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de dele��o

Return _lRet

User Function B383TOK()

	Local M001       := GetNextAlias()
	Local _lRet      := .T.
	Local _msi
	Local _ms2
	Local _mQtdCatg  := 0
	Local _msBkpGrad := _oGetDados:aCols
	Local _msVetGrad := _oGetDados:aCols
	Local _msContCtg := {}
	Local _mPosDel   := Len(_oGetDados:aHeader) + 1	
	Local _msEnter   := CHR(13) + CHR(10)
	Local _msMensErr := "Os seguintes encargos n�o atingiram a quantidade de categorias cadastrada: " + _msEnter + _msEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB4% ZB4
		WHERE ZB4_FILIAL = %xFilial:ZB4%
		AND ZB4.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->(!Eof())
		_mQtdCatg := (M001)->CONTAD
		_msMensErr += "Total de Categorias Cadastradas: " + Alltrim(Str(_mQtdCatg)) + _msEnter + _msEnter
	EndIf	
	(M001)->(dbCloseArea())

	_msVetGrad := aSort(_msVetGrad,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
	For _msi := 1 to Len(_msVetGrad)

		If !_msVetGrad[_msi,_mPosDel]
			nPos := aScan(_msContCtg,{|x| x[1] == _msVetGrad[_msi,1] })
			If nPos > 0
				_msContCtg[nPos][2] ++
			Else
				Aadd(_msContCtg, { _msVetGrad[_msi,1], 1 } )
			EndIf
		EndIf

	Next msi

	_msMensErr += "Encargos/Categorias com problemas: " + _msEnter 
	For _ms2 := 1 to Len(_msContCtg)

		If _msContCtg[_ms2][2] <> _mQtdCatg

			_msMensErr += IIF( _msContCtg[_ms2][1] == "1", "INSS", IIF( _msContCtg[_ms2][1] == "2", "FGTS", IIF( _msContCtg[_ms2][1] == "3", "SENAI", IIF( _msContCtg[_ms2][1] == "4", "SESI", "" ) ) ) ) + "   >>>   " + Alltrim(Str(_msContCtg[_ms2][2])) + _msEnter
			_lRet      := .F.

		EndIf

	Next _ms2

	If !_lRet

		MsgSTOP(_msMensErr)

	EndIf

	_oGetDados:aCols := _msBkpGrad

Return _lRet

User Function B383RPCSET()

	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	xfMensCompl := ""
	xfMensCompl += "Tipo Or�amento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digita��o igual a branco" + msrhEnter
	xfMensCompl += "Data Concilia��o igual a branco" + msrhEnter
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
		MsgALERT("A vers�o informada n�o est� ativa para execu��o deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de vers�o conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o respons�vel pelo processo Or�ament�rio!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf

	(M001)->(dbCloseArea())

	fgContin := MsgYESNO("Voc� est� prestes a executar o reprocessamento dos Encargos Trabalhistas. EST� CERTO(A) DE QUE TODOS OS REGISTROS FORAM DEVIDAMENTE GRAVADOS??? Deseja continuar???")
	If !fgContin

		MsgALERT("O reprocessamento dos Encargos Trabalhistas foi abortado...")
		Return .F.

	Else

		fgContin := MsgYESNO("Voc� CONFIRMOU o reprocessamento. Primeiramente o sistema ir� excluir o desdobramento. Deseja continuar???")
		If !fgContin

			MsgALERT("O reprocessamento dos Encargos Trabalhistas foi abortado...")
			Return .F.

		EndIf

	EndIf

	KS001 := " DELETE ZBA "
	KS001 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	KS001 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	KS001 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
	KS001 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
	KS001 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	KS001 += "    AND ZBA.ZBA_PERIOD <> '00' "
	KS001 += "    AND ZBA.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros da tabela ZBA" ,,{|| TcSQLExec(KS001) })

	US009 := " WITH ENCTRABA AS (SELECT ZB2_CATGFU CATGFU, "
	US009 += "                          [1] INSS, "
	US009 += "                          [2] FGTS, "
	US009 += "                          [3] SENAI, "
	US009 += "                          [4] SESI "
	US009 += "                     FROM (SELECT ZB2_ENCARG, ZB2_CATGFU, ZB2_PRCTOT "
	US009 += "                             FROM " + RetSqlName("ZB2") + " ZB2 "
	US009 += "                            WHERE ZB2.ZB2_FILIAL = '" + xFilial("ZB2") + "' "
	US009 += "                              AND ZB2.ZB2_VERSAO = '" + _cVersao + "' "
	US009 += "                              AND ZB2.ZB2_REVISA = '" + _cRevisa + "' "
	US009 += "                              AND ZB2.ZB2_ANOREF = '" + _cAnoRef + "' "
	US009 += "                              AND ZB2.D_E_L_E_T_ = ' ') AS TARE "
	US009 += "                    PIVOT (SUM(ZB2_PRCTOT) "
	US009 += "                           FOR ZB2_ENCARG IN([1], [2], [3], [4]) ) AS FIM ) "
	US009 += " UPDATE " + RetSqlName("ZBA") + " SET  "
	US009 += "        ZBA_PRCINS = INSS, "
	US009 += "        ZBA_PRCFGT = FGTS, "
	US009 += "        ZBA_PRCSEN = SENAI, "
	US009 += "        ZBA_PRCSES = SESI, "
	US009 += "        ZBA_VRINSF = (ZBA_SALARI + ZBA_PERICU + ZBA_INSALU + ZBA_VHEPRG + ZBA_DSRPRG + ZBA_VADCNO + ZBA_PREMPR) * INSS / 100, "
	US009 += "        ZBA_VRFGTF = (ZBA_SALARI + ZBA_PERICU + ZBA_INSALU + ZBA_VHEPRG + ZBA_DSRPRG + ZBA_VADCNO + ZBA_PREMPR) * FGTS / 100, "
	US009 += "        ZBA_VRSENF = (ZBA_SALARI + ZBA_PERICU + ZBA_INSALU + ZBA_VHEPRG + ZBA_DSRPRG + ZBA_VADCNO + ZBA_PREMPR) * SENAI / 100, "
	US009 += "        ZBA_VRSESF = (ZBA_SALARI + ZBA_PERICU + ZBA_INSALU + ZBA_VHEPRG + ZBA_DSRPRG + ZBA_VADCNO + ZBA_PREMPR) * SESI / 100, "
	US009 += "        ZBA_INSFER = ZBA_FMULTF * ZBA_FERIAS * INSS / 100, "
	US009 += "        ZBA_FGTFER = ZBA_FMULTF * ZBA_FERIAS * FGTS / 100, "
	US009 += "        ZBA_SENFER = ZBA_FMULTF * ZBA_FERIAS * SENAI / 100, "
	US009 += "        ZBA_SESFER = ZBA_FMULTF * ZBA_FERIAS * SESI / 100, "
	US009 += "        ZBA_INS13O = ZBA_FMUL13 * ZBA_13OSAL * INSS/ 100, "
	US009 += "        ZBA_FGT13O = ZBA_FMUL13 * ZBA_13OSAL * FGTS/ 100, "
	US009 += "        ZBA_SEN13O = ZBA_FMUL13 * ZBA_13OSAL * SENAI/ 100, "
	US009 += "        ZBA_SES13O = ZBA_FMUL13 * ZBA_13OSAL * SESI/ 100 "
	US009 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	US009 += "   LEFT JOIN ENCTRABA ZB2 ON ZB2.CATGFU = ZBA.ZBA_CATGFU "
	US009 += "  WHERE ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	KS001 += "    AND ZBA_VERSAO = '" + _cVersao + "' "
	US009 += "    AND ZBA_REVISA = '" + _cRevisa + "' "
	US009 += "    AND ZBA_ANOREF = '" + _cAnoRef + "' "
	US009 += "    AND ZBA_PERIOD = '00' "
	US009 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Atualizando registros da tabela ZBA" ,,{|| TcSQLExec(US009) })

	MsgINFO("O processamento foi conclu�do. Favor verificar se os dados foram gravados corretamente...")

	MsgALERT("Este processamento dever� ser executado individualmente para cada uma das empresas contempladas pelo Or�amento RH")

	MsgINFO("N�o se esque�a de processar para todas as empresa...")

	MsgALERT("Ah! Mais uma coisa... necess�rio processar o desdobramento em todas as empresas novamente...")

	MsgINFO("Fim do processamento...")

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B383IEXC � Autor � Marcos Alberto S      � Data � 21/06/17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Importa��o planilha Excel para Or�amento - Comiss�os REC.I ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B383IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("N�o � permitido importar dados porque a Vers�o or�ament�ria est� bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importa��o dos percentuais de Comiss�o para Or�amento RECEITA."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os par�metros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> n�o � permitido importar arquivos que esteja com prote��o"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importa��o dos percentuais...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importa��o!')
		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B383IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= space(100) 

	aAdd( aPergs ,{6,"Arquivo para Importa��o: " 	,cArquivo  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,cLoad,.T.,.T.)      
		cArquivo  := ParamLoad(cFileName,,1,cArquivo) 
	Endif

Return 

//Processa importa��o
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'ZB2'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB2_REC_WT"})
	Local vtRecGrd := {}

	Local vnb
	Local ny
	Local _msc
	Local nx

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZB2_REC_WT"})

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

					MsgALERT("Erro no Layout do Arquivo de Importa��o!!!")
					nImport := 0
					Exit

				EndIf

			EndIf

		Next nx

	EndIf

	If nImport > 0 

		MsgInfo("Registros importados com sucesso")

	Else

		MsgStop("Falha na importa��o dos registros")
		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf

	RestArea(aArea)

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B383RPLC � Autor � Marcos Alberto S      � Data � 09/09/19 ���
��+----------+------------------------------------------------------------���
���Descri��o � Replicando Registros da Vers�o Anterior para Corrente      ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B383RPLC()

	Local M002        := GetNextAlias()

	If !_msCtrlAlt

		MsgInfo("N�o � permitido importar dados porque a Vers�o or�ament�ria est� bloquada.")
		Return

	EndIf

	If !Empty(_oGetDados:aCols[1][1])

		MsgInfo("N�o � permitido importar dados porque j� existem registros contidos nesta revis�o.")
		Return

	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias M002

		SELECT *
		FROM %TABLE:ZB2% ZB2
		WHERE ZB2_FILIAL = %xFilial:ZB2%
		AND ZB2_VERSAO+ZB2_REVISA+ZB2_ANOREF = (SELECT MAX(ZB2_VERSAO+ZB2_REVISA+ZB2_ANOREF)
		FROM %TABLE:ZB2% ZB2
		WHERE ZB2_FILIAL = %xFilial:ZB2%
		AND ZB2_ANOREF < %Exp:_cAnoRef%
		AND ZB2.%NotDel%)
		AND ZB2.%NotDel%
		ORDER BY ZB2.ZB2_VERSAO, ZB2.ZB2_REVISA, ZB2.ZB2_ANOREF, ZB2.ZB2_ENCARG, ZB2.ZB2_CATGFU

	EndSql

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			(M002)->(aAdd(_oGetDados:aCols,{ZB2_ENCARG,;
			ZB2_CATGFU,;
			ZB2_DESCCF,;
			ZB2_PRCBAS,;
			ZB2_PRCEMP,;
			ZB2_PRCTER,;
			ZB2_PRCACT,;
			ZB2_PRCSEN,;
			ZB2_PRCSES,;
			ZB2_PRCRAT,;
			ZB2_PRCTOT,;
			"ZB2",;
			0,;
			.F.	}))

			(M002)->(dbSkip())

		EndDo

		(M002)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

	MsgINFO("Replica efetuada com sucesso. Para concluir a grava��o � necess�rio clicar em Confirmar.")

Return
