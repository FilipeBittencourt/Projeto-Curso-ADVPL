#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA381
@author Marcos Alberto Soprani
@since 12/09/17
@version 1.0
@description Tela para cadastro das metricas orçamentárias de Assitências Médica e Odontológica 
@type function
/*/

User Function BIA381()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB1") + SPACE(TAMSX3("ZB1_VERSAO")[1]) + SPACE(TAMSX3("ZB1_REVISA")[1]) + SPACE(TAMSX3("ZB1_ANOREF")[1])
	Local bWhile	    := {|| ZB1_FILIAL + ZB1_VERSAO + ZB1_REVISA + ZB1_ANOREF }                    
	Local aNoFields     := {"ZB1_VERSAO", "ZB1_REVISA", "ZB1_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB1_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB1_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB1_ANOREF")[1])
	Private _oGAnoRef

	Private _msCtrlAlt := .F.

	aAdd(_aButtons,{"PRODUTO"  ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"   ,{|| U_B381IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"    ,{|| U_B381RPLC() }, "Replica Registros" , "Replica Registros"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB1",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Assitência Médica e Odonto" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA381A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA381B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA381C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B381FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B381DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA381A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF	
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA381C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA381B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA381C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA381C()

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
		FROM %TABLE:ZB1% ZB1
		WHERE ZB1_FILIAL = %xFilial:ZB1%
		AND ZB1_VERSAO = %Exp:_cVersao%
		AND ZB1_REVISA = %Exp:_cRevisa%
		AND ZB1_ANOREF = %Exp:_cAnoRef%
		AND ZB1.%NotDel%
		ORDER BY ZB1_VERSAO, ZB1_REVISA, ZB1_ANOREF, ZB1_DOMES, ZB1_ATMES, ZB1_CODPLS, ZB1_SEQ

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB1_DOMES,;
			ZB1_ATMES,;
			ZB1_CODPLS,;
			ZB1_TIPPLS,;
			ZB1_CODOEM,;
			ZB1_CODPLA,;
			ZB1_SEQ,;
			ZB1_DEFAIX,;
			ZB1_ATFAIX,;
			ZB1_VLRTIT,;
			ZB1_DSCTIT,;
			ZB1_VLRDEP,;
			ZB1_DSCDEP,;
			ZB1_VLRAGR,;
			ZB1_DSCAGR,;
			ZB1_STAORC,;
			"ZB1",	;
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

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_REC_WT"})
	Local mDOMES  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DOMES"})
	Local mATMES  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_ATMES"})
	Local mCODPLS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODPLS"})
	Local mTIPPLS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_TIPPLS"})
	Local mCODOEM := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODOEM"})
	Local mCODPLA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODPLA"})
	Local mSEQ    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_SEQ"})
	Local mDEFAIX := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DEFAIX"})
	Local mATFAIX := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_ATFAIX"})
	Local mVLRTIT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_VLRTIT"})
	Local mDSCTIT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DSCTIT"})
	Local mVLRDEP := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_VLRDEP"})
	Local mDSCDEP := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DSCDEP"})
	Local mVLRAGR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_VLRAGR"})
	Local mDSCAGR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DSCAGR"})
	Local mSTAORC := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_STAORC"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZB1')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZB1->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				If !_oGetDados:aCols[_nI,nPosDel]

					If ZB1->ZB1_VERSAO == _cVersao .and. ZB1->ZB1_REVISA == _cRevisa .and. ZB1->ZB1_ANOREF == _cAnoRef
						Reclock("ZB1",.F.)
					Else
						Reclock("ZB1",.T.)
						ZB1->ZB1_FILIAL  := xFilial("ZB1")
						ZB1->ZB1_VERSAO  := _cVersao
						ZB1->ZB1_REVISA  := _cRevisa
						ZB1->ZB1_ANOREF  := _cAnoRef
					EndIf
					ZB1->ZB1_DOMES   := _oGetDados:aCols[_nI,mDOMES]
					ZB1->ZB1_ATMES   := _oGetDados:aCols[_nI,mATMES]
					ZB1->ZB1_CODPLS  := _oGetDados:aCols[_nI,mCODPLS]
					ZB1->ZB1_TIPPLS  := _oGetDados:aCols[_nI,mTIPPLS]
					ZB1->ZB1_CODOEM  := _oGetDados:aCols[_nI,mCODOEM]
					ZB1->ZB1_CODPLA  := _oGetDados:aCols[_nI,mCODPLA]
					ZB1->ZB1_SEQ     := _oGetDados:aCols[_nI,mSEQ]
					ZB1->ZB1_DEFAIX  := _oGetDados:aCols[_nI,mDEFAIX]
					ZB1->ZB1_ATFAIX  := _oGetDados:aCols[_nI,mATFAIX]
					ZB1->ZB1_VLRTIT  := _oGetDados:aCols[_nI,mVLRTIT]
					ZB1->ZB1_DSCTIT  := _oGetDados:aCols[_nI,mDSCTIT]
					ZB1->ZB1_VLRDEP  := _oGetDados:aCols[_nI,mVLRDEP]
					ZB1->ZB1_DSCDEP  := _oGetDados:aCols[_nI,mDSCDEP]
					ZB1->ZB1_VLRAGR  := _oGetDados:aCols[_nI,mVLRAGR]
					ZB1->ZB1_DSCAGR  := _oGetDados:aCols[_nI,mDSCAGR]
					ZB1->ZB1_STAORC  := _oGetDados:aCols[_nI,mSTAORC]
					ZB1->(MsUnlock())

				Else

					Reclock("ZB1",.F.)
					ZB1->(DbDelete())
					ZB1->(MsUnlock())

				EndIf

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZB1",.T.)
					ZB1->ZB1_FILIAL  := xFilial("ZB1")
					ZB1->ZB1_VERSAO  := _cVersao
					ZB1->ZB1_REVISA  := _cRevisa
					ZB1->ZB1_ANOREF  := _cAnoRef
					ZB1->ZB1_DOMES   := _oGetDados:aCols[_nI,mDOMES]
					ZB1->ZB1_ATMES   := _oGetDados:aCols[_nI,mATMES]
					ZB1->ZB1_CODPLS  := _oGetDados:aCols[_nI,mCODPLS]
					ZB1->ZB1_TIPPLS  := _oGetDados:aCols[_nI,mTIPPLS]
					ZB1->ZB1_CODOEM  := _oGetDados:aCols[_nI,mCODOEM]
					ZB1->ZB1_CODPLA  := _oGetDados:aCols[_nI,mCODPLA]
					ZB1->ZB1_SEQ     := _oGetDados:aCols[_nI,mSEQ]
					ZB1->ZB1_DEFAIX  := _oGetDados:aCols[_nI,mDEFAIX]
					ZB1->ZB1_ATFAIX  := _oGetDados:aCols[_nI,mATFAIX]
					ZB1->ZB1_VLRTIT  := _oGetDados:aCols[_nI,mVLRTIT]
					ZB1->ZB1_DSCTIT  := _oGetDados:aCols[_nI,mDSCTIT]
					ZB1->ZB1_VLRDEP  := _oGetDados:aCols[_nI,mVLRDEP]
					ZB1->ZB1_DSCDEP  := _oGetDados:aCols[_nI,mDSCDEP]
					ZB1->ZB1_VLRAGR  := _oGetDados:aCols[_nI,mVLRAGR]
					ZB1->ZB1_DSCAGR  := _oGetDados:aCols[_nI,mDSCAGR]
					ZB1->ZB1_STAORC  := _oGetDados:aCols[_nI,mSTAORC]
					ZB1->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao		:=	SPACE(TAMSX3("ZB1_VERSAO")[1])
	_cRevisa		:=	SPACE(TAMSX3("ZB1_REVISA")[1])
	_cAnoRef		:=	SPACE(TAMSX3("ZB1_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B381FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	//Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI

	Local mDOMES  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_DOMES"})
	Local mATMES  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_ATMES"})
	Local mCODPLS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODPLS"})
	Local mTIPPLS := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_TIPPLS"})
	Local mCODOEM := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODOEM"})
	Local mCODPLA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_CODPLA"})
	Local mSEQ    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_SEQ"})

	Local _zpDoMes  := ""
	Local _zpAtMes  := ""
	Local _zpCodPls := ""
	Local _zpTipPls := ""
	Local _zpCodOem := ""
	Local _zpCodPla := ""
	Local _zpSeqPls := ""
	Local _zpDeFaix := 0
	Local _zpAtFaix := 0
	Local _zpCpEntr := "0"

	Do Case

		Case Alltrim(cMenVar) == "M->ZB1_DOMES"
		If !Empty(GdFieldGet("ZB1_ATMES",_nAt))
			If M->ZB1_DOMES > GdFieldGet("ZB1_ATMES",_nAt)
				MsgINFO("Favor informar corretamente o conteúdo do campo Do Mês!!!")
				Return .F.
			EndIf
		EndIf
		_zpCpEntr := "1"
		_zpDoMes  := M->ZB1_DOMES
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_ATMES"
		If M->ZB1_ATMES <= GdFieldGet("ZB1_DOMES",_nAt)
			MsgINFO("Favor informar corretamente o conteúdo do campo Até Mês!!!")
			Return .F.
		EndIf
		_zpCpEntr := "2"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := M->ZB1_ATMES
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_CODPLS"
		_zpCpEntr := "3"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := M->ZB1_CODPLS
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_TIPPLS"
		_zpCpEntr := "4"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := M->ZB1_TIPPLS
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_CODOEM"
		_zpCpEntr := "8"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := M->ZB1_CODOEM
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_CODPLA"
		_zpCpEntr := "9"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := M->ZB1_CODPLA
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_SEQ"
		If Len(Alltrim(M->ZB1_SEQ)) <> 3
			MsgINFO("O campo SEQUENCIA deverá obrigatoriamente ser preenchido com 3 caracteres!!!")
			Return .F.
		EndIf
		_zpCpEntr := "5"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := M->ZB1_SEQ
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_DEFAIX"
		_zpCpEntr := "6"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := M->ZB1_DEFAIX
		_zpAtFaix := GdFieldGet("ZB1_ATFAIX",_nAt)

		Case Alltrim(cMenVar) == "M->ZB1_ATFAIX"
		If M->ZB1_ATFAIX == 0 .or. M->ZB1_ATFAIX <= GdFieldGet("ZB1_DEFAIX",_nAt)
			MsgINFO("Favor informar corretamente o conteúdo do campo Até Faixa!!!")
			Return .F.
		EndIf
		_zpCpEntr := "7"
		_zpDoMes  := GdFieldGet("ZB1_DOMES",_nAt)
		_zpAtMes  := GdFieldGet("ZB1_ATMES",_nAt)
		_zpCodPls := GdFieldGet("ZB1_CODPLS",_nAt)
		_zpTipPls := GdFieldGet("ZB1_TIPPLS",_nAt)
		_zpCodOem := GdFieldGet("ZB1_CODOEM",_nAt)
		_zpCodPla := GdFieldGet("ZB1_CODPLA",_nAt)
		_zpSeqPls := GdFieldGet("ZB1_SEQ",_nAt)
		_zpDeFaix := GdFieldGet("ZB1_DEFAIX",_nAt)
		_zpAtFaix := M->ZB1_ATFAIX

	EndCase

	nPosKeyCad := aScan(_oGetDados:aCols,{|x| x[mDOMES] + x[mATMES] + x[mCODPLS] + x[mTIPPLS] + x[mCODOEM] + x[mCODPLA] + x[mSEQ] == _zpDoMes + _zpAtMes + _zpCodPls + _zpTipPls + _zpCodOem + _zpCodPla + _zpSeqPls } )
	If nPosKeyCad <> 0
		If _nAt <> nPosKeyCad
			MsgINFO("A chave informada nesta linha já foi informada. Favor verificar!!!")
			Return .F.
		EndIf
	EndIf

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If (_zpDoMes == GdFieldGet("ZB1_DOMES",_nI) .and. _zpAtMes  == GdFieldGet("ZB1_ATMES",_nI) ) .and. !Empty(_zpCodPls) .and. _zpCodPls == GdFieldGet("ZB1_CODPLS",_nI)

				If !Empty(_zpTipPls) .and. _zpTipPls <> GdFieldGet("ZB1_TIPPLS",_nI)

					MsgInfo("O Tipo não poderá ser diferente do Tipo de plano previamente informado!!!")
					Return .F.

				ElseIf !Empty(_zpSeqPls) .and. _zpSeqPls == GdFieldGet("ZB1_SEQ",_nI)

					MsgInfo("A sequência informada não poderá ser igual a outra previamente informada!!!")
					Return .F.

				ElseIf _zpCpEntr == "6" .and. _zpDeFaix <> 0

					If _zpDeFaix <= GdFieldGet("ZB1_DEFAIX",_nI)

						If _zpAtFaix >= GdFieldGet("ZB1_DEFAIX",_nI)

							MsgInfo("O campo De Faixa não pode ser menor ou igual ao De Faixa do plano mencionada neste registro!!!")
							Return .F.

						EndIf

					EndIf

					If _zpDeFaix <= GdFieldGet("ZB1_ATFAIX",_nI)

						If ( _zpAtFaix <> 0 .or. _zpAtFaix >= GdFieldGet("ZB1_DEFAIX",_nI) ) .and. _zpSeqPls > GdFieldGet("ZB1_SEQ",_nI)

							MsgInfo("O campo De Faixa não pode ser menor ou igual ao Até Faixa do plano mencionada neste registro, quando o Até Faixa for maior o De Faixa!!!")
							Return .F.

						ElseIf _zpDeFaix > GdFieldGet("ZB1_DEFAIX",_nI)

							MsgInfo("O campo De Faixa não pode ser menor ou igual ao Até Faixa do plano mencionada neste registro, quando o Até Faixa for maior o De Faixa!!!")
							Return .F.

						EndIf

					EndIf

				ElseIf _zpCpEntr == "7" .and. _zpAtFaix <> 0 

					If _zpAtFaix <= GdFieldGet("ZB1_DEFAIX",_nI)

						If _zpDeFaix < GdFieldGet("ZB1_DEFAIX",_nI)

							If _zpSeqPls > GdFieldGet("ZB1_SEQ",_nI) 

								MsgInfo("O campo Até Faixa não pode ser menor ou igual ao Até Faixa do plano mencionada neste registro!!!")
								Return .F.

							ElseIf _zpAtFaix >= GdFieldGet("ZB1_DEFAIX",_nI)

								If _zpSeqPls < GdFieldGet("ZB1_SEQ",_nI)

									MsgInfo("O campo Até Faixa não pode ser menor ou igual ao De Faixa do plano mencionada neste registro!!!")
									Return .F.

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next

	RestArea( vfArea )

Return .T.

User Function B381DOK()

	Local _lRet	:=	.T.

	If GdFieldGet("ZB1_STAORC",_oGetDados:nAt) <> "A"
		MsgInfo("O registro não poderá ser excluído, pois o registro está bloqueado!!!")
		_lret	:=	.F.
	EndIf 

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B381IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Comissãos REC.I ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B381IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos percentuais de Comissão para Orçamento RECEITA."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação dos percentuais...'), aSays, aButtons ,,,500)

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
	Local cLoad	    := 'B381IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZB1'
	Local aItem 			:= {}
	Local aLinha			:= {}
	//Local aErro				:= {}
	//Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB1_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZB1_REC_WT"})

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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B381RPLC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 09/09/19 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Registros da Versão Anterior para Corrente      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B381RPLC()

	Local M002        := GetNextAlias()

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	If !Empty(_oGetDados:aCols[1][1])

		MsgInfo("Não é permitido importar dados porque já existem registros contidos nesta revisão.")
		Return

	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias M002

		SELECT *
		FROM %TABLE:ZB1% ZB1
		WHERE ZB1_VERSAO+ZB1_REVISA+ZB1_ANOREF = (SELECT MAX(ZB1_VERSAO+ZB1_REVISA+ZB1_ANOREF)
		FROM %TABLE:ZB1% ZB1
		WHERE ZB1_ANOREF < %Exp:_cAnoRef%
		AND ZB1.%NotDel%)
		AND ZB1.%NotDel%
		ORDER BY ZB1_VERSAO, ZB1_REVISA, ZB1_ANOREF, ZB1_DOMES, ZB1_ATMES, ZB1_CODPLS, ZB1_SEQ

	EndSql

	If (M002)->(!Eof())

		While (M002)->(!Eof())

			(M002)->(aAdd(_oGetDados:aCols,{ZB1_DOMES,;
			ZB1_ATMES,;
			ZB1_CODPLS,;
			ZB1_TIPPLS,;
			ZB1_CODOEM,;
			ZB1_CODPLA,;
			ZB1_SEQ,;
			ZB1_DEFAIX,;
			ZB1_ATFAIX,;
			ZB1_VLRTIT,;
			ZB1_DSCTIT,;
			ZB1_VLRDEP,;
			ZB1_DSCDEP,;
			ZB1_VLRAGR,;
			ZB1_DSCAGR,;
			ZB1_STAORC,;
			"ZB1",	;
			0,;
			.F.	}))

			(M002)->(dbSkip())

		EndDo

		(M002)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

	MsgINFO("Replica efetuada com sucesso. Para concluir a gravação é necessário clicar em Confirmar.")

Return
