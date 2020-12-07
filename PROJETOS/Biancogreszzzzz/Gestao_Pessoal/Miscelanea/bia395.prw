#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA395
@author Marcos Alberto Soprani
@since 26/09/17
@version 1.0
@description Tela para cadastro da Amarração entre Rubricas e Contas Contábeis 
@type function
/*/

User Function BIA395()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBC") + SPACE(TAMSX3("ZBC_VERSAO")[1]) + SPACE(TAMSX3("ZBC_REVISA")[1]) + SPACE(TAMSX3("ZBC_ANOREF")[1])
	Local bWhile	    := {|| ZBC_FILIAL + ZBC_VERSAO + ZBC_REVISA + ZBC_ANOREF }                    
	Local aNoFields     := {"ZBC_VERSAO", "ZBC_REVISA", "ZBC_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBC_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBC_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBC_ANOREF")[1])
	Private _oGAnoRef

	Private _msCtrlAlt  := .T.  

	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B395CTAS()} , "Replica Contas"   , "Replica Contas"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBC",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Amarração entre Rubricas e Contas Contábeis" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA395A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA395B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA395C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, "U_B395DOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B395FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B395DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA395A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA395C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA395B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA395C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA395C()

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
		FROM %TABLE:ZBC% ZBC
		WHERE ZBC_FILIAL = %xFilial:ZBC%
		AND ZBC_VERSAO = %Exp:_cVersao%
		AND ZBC_REVISA = %Exp:_cRevisa%
		AND ZBC_ANOREF = %Exp:_cAnoRef%
		AND ZBC.%NotDel%
		ORDER BY ZBC_ORDEM 
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZBC_ORDEM,;
			ZBC_RUBRIC,;
			ZBC_DRUBRI,;
			ZBC_CTADES,;
			ZBC_CTACST,;
			"ZBC",;
			R_E_C_N_O_,;
			.F.	}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		aAdd(_oGetDados:aCols, {"005", "ZBA_SALMEN", "Salário     ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"010", "ZBA_HONORA", "Honorários  ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"015", "ZBA_BOLSAE", "Bolsa Estág.", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"020", "ZBA_PERICU", "Periculosida", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"025", "ZBA_INSALU", "Insalubidade", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"030", "ZBA_VHEPRG", "Vlr.HE.Prog ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"035", "ZBA_DSRPRG", "Dsr.HE.Prog ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"040", "ZBA_VADCNO", "Vlr.Adc.Not ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"045", "ZBA_PREMPR", "Premio Prod ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"050", "ZBA_TXINST", "Taxa Instit.", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"055", "ZBA_VVLTRT", "Vlr.Vale Trn", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"060", "ZBA_REFEIC", "$ Refeição  ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"065", "ZBA_DESEJU", "$ Desejum   ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"070", "ZBA_CALIME", "$ C.Alimenta", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"075", "ZBA_CJTURN", "$ C.J.Turno ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"080", "ZBA_CJNOIT", "$ C.J.Noites", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"085", "ZBA_CCOMBU", "$ C.Combusti", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"090", "ZBA_PLSMED", "$ Pls Saúde ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"095", "ZBA_PLSODO", "$ Pls Odonto", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"100", "ZBA_VLREXA", "$ Exames    ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"105", "ZBA_VLRUNI", "$ Uniformes ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"110", "ZBA_VLREPI", "$ EPI       ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"115", "ZBA_VRINSF", "$ INSS Folha", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"120", "ZBA_VRFGTF", "$ FGTS Folha", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"125", "ZBA_VRSENF", "$ SENAI Folh", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"130", "ZBA_VRSESF", "$ SESI Folha", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"135", "ZBA_FERIAS", "$ Férias    ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"140", "ZBA_ABONOF", "$ Abono Féri", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"145", "ZBA_INSFER", "$ Inss Féria", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"150", "ZBA_FGTFER", "$ FGTS Féria", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"155", "ZBA_SENFER", "$ SENAI Féri", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"160", "ZBA_SESFER", "$ SESI Féria", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"165", "ZBA_13OSAL", "$ 13o Salári", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"170", "ZBA_INS13O", "$ Inss 13o S", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"175", "ZBA_FGT13O", "$ FGTS 13o S", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"180", "ZBA_SEN13O", "$ SENAI 13oS", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"185", "ZBA_SES13O", "$ SESI 13o S", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"190", "ZBA_VLRPPR", "Valor PPR   ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"200", "ZBA_VRAVIS", "$ Aviso Prev", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"205", "ZBA_FGTAVI", "$ FGTS Aviso", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"210", "ZBA_FERAVI", "$ Ferias Avi", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"215", "ZBA_13OAVI", "13º Aviso   ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"220", "ZBA_13FGTA", "$ FGTS 13ºAv", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"225", "ZBA_13INSA", "$ INSS 13ºAv", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"230", "ZBA_13SENA", "$ Senai 13ºA", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"235", "ZBA_13SESA", "$ Sesi 13ºAv", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"240", "ZBA_MULTAF", "Multa FGTS  ", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"245", "ZBA_AJDCBD", "Ajda.Cust BD", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"250", "ZBA_CFCCCH", "$ Cfcc Crach", Space(20), Space(20), "ZBC", 0, .F. })
		aAdd(_oGetDados:aCols, {"255", "ZBA_VRHENP", "Vlr.HE.NPrg ", Space(20), Space(20), "ZBC", 0, .F. })

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_REC_WT"})
	Local _mORDEM  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_ORDEM"})
	Local _mRUBRIC := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_RUBRIC"})
	Local _mDRUBRI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_DRUBRI"})
	Local _mCTADES := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTADES"})
	Local _mCTACST := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTACST"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZBC')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBC->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBC",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZBC->ZBC_ORDEM  := _oGetDados:aCols[_nI,_mORDEM]
				ZBC->ZBC_RUBRIC := _oGetDados:aCols[_nI,_mRUBRIC]
				ZBC->ZBC_DRUBRI := _oGetDados:aCols[_nI,_mDRUBRI]
				ZBC->ZBC_CTADES := _oGetDados:aCols[_nI,_mCTADES]
				ZBC->ZBC_CTACST := _oGetDados:aCols[_nI,_mCTACST]

			Else

				ZBC->(DbDelete())

			EndIf

			ZBC->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZBC",.T.)
				ZBC->ZBC_FILIAL := xFilial("ZBC")
				ZBC->ZBC_VERSAO := _cVersao
				ZBC->ZBC_REVISA := _cRevisa
				ZBC->ZBC_ANOREF := _cAnoRef
				ZBC->ZBC_ORDEM  := _oGetDados:aCols[_nI,_mORDEM]
				ZBC->ZBC_RUBRIC := _oGetDados:aCols[_nI,_mRUBRIC]
				ZBC->ZBC_DRUBRI := _oGetDados:aCols[_nI,_mDRUBRI]
				ZBC->ZBC_CTADES := _oGetDados:aCols[_nI,_mCTADES]
				ZBC->ZBC_CTACST := _oGetDados:aCols[_nI,_mCTACST]
				ZBC->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao		    :=	SPACE(TAMSX3("ZBC_VERSAO")[1])
	_cRevisa		    :=	SPACE(TAMSX3("ZBC_REVISA")[1])
	_cAnoRef		    :=	SPACE(TAMSX3("ZBC_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B395FOK()

	Local cMenVar   := ReadVar()

	Do Case

		Case Alltrim(cMenVar) == "M->ZBC_CTADES"
		If !ExistCPO("CT1")
			MsgInfo("Informe uma conta válida!!!")
			Return .F.
		EndIf
		If Substr(M->ZBC_CTADES,1,1) <> "3"
			MsgInfo("Não permitido digitar conta contábil nesta coluna que não seja DESPESA")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZBC_CTACST"
		If !ExistCPO("CT1")
			MsgInfo("Informe uma conta válida!!!")
			Return .F.
		EndIf
		If Substr(M->ZBC_CTACST,1,1) <> "6"
			MsgInfo("Não permitido digitar conta contábil nesta coluna que não seja CUSTO")
			Return .F.
		EndIf

	EndCase

Return .T.

User Function B395DOK()

	Local _lRet	:=	.T.
	Local _mCTADES := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTADES"})
	Local _mCTACST := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTACST"})
	Local _nI

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If Empty(_oGetDados:aCols[_nI,_mCTADES]) .or. Empty(_oGetDados:aCols[_nI,_mCTACST])
			_lRet := .F.
		EndIf
	Next _nI

	If !_lRet
		MsgInfo("Não permitido confirmar o cadastro com rubricas sem classificação contábil!!!")
	EndIf 

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B395CTAS ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 27/09/18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Contas Contábeis da Versão anterior             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B395CTAS()

	Local M002        := GetNextAlias()
	Local _mRUBRIC := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_RUBRIC"})
	Local _mCTADES := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTADES"})
	Local _mCTACST := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBC_CTACST"})

	Local _nI

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados porque a Versão orçamentária está bloquada.")
		Return

	EndIf

	For _nI	:=	1 to Len(_oGetDados:aCols)

		BeginSql Alias M002
			SELECT ZBC_CTADES,
			ZBC_CTACST
			FROM %TABLE:ZBC% ZBC
			WHERE ZBC_VERSAO+ZBC_REVISA+ZBC_ANOREF = (SELECT MAX(ZBC_VERSAO+ZBC_REVISA+ZBC_ANOREF)
			FROM %TABLE:ZBC% ZBC
			WHERE ZBC_ANOREF < %Exp:_cAnoRef%
			AND ZBC.%NotDel%)
			AND ZBC_RUBRIC = %Exp:_oGetDados:aCols[_nI,_mRUBRIC]%
			AND ZBC.%NotDel%
		EndSql
		If (M002)->(!Eof())
			_oGetDados:aCols[_nI,_mCTADES] := (M002)->ZBC_CTADES
			_oGetDados:aCols[_nI,_mCTACST] := (M002)->ZBC_CTACST
		EndIf	

		(M002)->(dbCloseArea())

	Next _nI

	_oGetDados:Refresh()

Return
