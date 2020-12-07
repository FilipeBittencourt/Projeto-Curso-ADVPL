#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA390
@author Marcos Alberto Soprani
@since 21/09/17
@version 1.0
@description Tela para lançamento de valores para Verbas Eventuais p/ orçamento de RH 
@type function
/*/

User Function BIA390()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB8") + SPACE(TAMSX3("ZB8_VERSAO")[1]) + SPACE(TAMSX3("ZB8_REVISA")[1]) + SPACE(TAMSX3("ZB8_ANOREF")[1]) + SPACE(TAMSX3("ZB8_RUBRIC")[1])
	Local bWhile	    := {|| ZB8_FILIAL + ZB8_VERSAO + ZB8_REVISA + ZB8_ANOREF + ZB8_RUBRIC }                    
	Local aNoFields     := {"ZB8_VERSAO", "ZB8_REVISA", "ZB8_ANOREF", "ZB8_RUBRIC", "ZB8_DRUBR"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZB8_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZB8_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZB8_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodRubi	:= SPACE(TAMSX3("ZB8_RUBRIC")[1])
	Private _oGCodRubi
	Private _mDescRubi  := SPACE(50) 
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel","Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB8",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Verbas Eventuais p/ Orçamento de RH" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA390A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA390B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA390C()

	@ 050,310 SAY "Rubrica:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodRubi VAR _cCodRubi SIZE 50, 11 OF _oDlg PIXEL VALID fBIA390D()
	@ 050,410 SAY _mDescRubi SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B390FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B390DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA390A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa  := ZB5->ZB5_REVISA
	_cAnoRef  := ZB5->ZB5_ANOREF
	_cCodRubi := "001" 
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRubi)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA390D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA390B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRubi)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA390D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA390C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodRubi)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA390D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA390D()

	Local M001      := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodRubi)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	If _cCodRubi == "001"
		_mDescRubi := "PROMOCAO EVENTUAL"
	Else
		_mDescRubi := ""
		MsgALERT("Somente está liberada a Rubrica 001 para lançamento de valores eventuais!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
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
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTDIGT <= %Exp:Date()%
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

	// Confirma e gera registros na tabela de Verbas Eventuais para os casos em que os registros não foram incluídos
	RG003 := " WITH LIBCLVL AS (SELECT ZB9.ZB9_CLVL, ZB9.ZB9_DIGIT, ZB9.ZB9_VISUAL "
	RG003 += "                    FROM " + RetSqlName("ZB9") + " ZB9 "
	RG003 += "                   WHERE ZB9.ZB9_FILIAL = '" + xFilial("ZB9") + "' "
	RG003 += "                     AND ZB9.ZB9_VERSAO = '" + _cVersao + "' "
	RG003 += "                     AND ZB9.ZB9_REVISA = '" + _cRevisa + "' "
	RG003 += "                     AND ZB9.ZB9_ANOREF = '" + _cAnoRef + "' "
	RG003 += "                     AND ZB9.ZB9_USER = '" + __cUserID + "' "
	RG003 += "                     AND ZB9.ZB9_TPORCT = 'RH' "
	RG003 += "                     AND ( ZB9.ZB9_DIGIT = '1' OR ZB9.ZB9_VISUAL = '1' ) "
	RG003 += "                     AND ZB9.D_E_L_E_T_ = ' ') "
	RG003 += " SELECT ZBA.ZBA_CLVL CLVL, "
	RG003 += "        ZB9.ZB9_DIGIT, "
	RG003 += "        ZB9.ZB9_VISUAL, "
	RG003 += "        ZBA.* "
	RG003 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	RG003 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = ZBA.ZBA_CLVL "
	RG003 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZB8") + "' "
	RG003 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
	RG003 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
	RG003 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	RG003 += "    AND ZBA.ZBA_PERIOD = '00' "
	RG003 += "    AND ZBA.ZBA_MATR + ZBA.ZBA_CLVL NOT IN(SELECT ZB8.ZB8_MATR + ZB8.ZB8_CLVL
	RG003 += "                                             FROM " + RetSqlName("ZB8") + " ZB8
	RG003 += "                                            WHERE ZB8.ZB8_FILIAL = '" + xFilial("ZB8") + "'
	RG003 += "                                              AND ZB8.ZB8_VERSAO = ZBA.ZBA_VERSAO
	RG003 += "                                              AND ZB8.ZB8_REVISA = ZBA.ZBA_REVISA
	RG003 += "                                              AND ZB8.ZB8_ANOREF = ZBA.ZBA_ANOREF
	RG003 += "                                              AND ZB8.ZB8_RUBRIC = '" + _cCodRubi + "'
	RG003 += "                                              AND ZB8.D_E_L_E_T_ = ' ' )
	RG003 += "    AND ZBA.D_E_L_E_T_ = ' '
	RG003 += "  ORDER BY ZBA.ZBA_CLVL, ZBA.ZBA_MATR
	RGIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
	dbSelectArea("RG03")
	RG03->(dbGoTop())

	If RG03->(!Eof())

		While RG03->(!Eof())

			Reclock("ZB8",.T.)
			ZB8->ZB8_FILIAL  := xFilial("ZB8")
			ZB8->ZB8_VERSAO  := _cVersao
			ZB8->ZB8_REVISA  := _cRevisa
			ZB8->ZB8_ANOREF  := _cAnoRef
			ZB8->ZB8_RUBRIC  := _cCodRubi
			ZB8->ZB8_MATR    := RG03->ZBA_MATR
			ZB8->ZB8_CLVL    := RG03->ZBA_CLVL
			ZB8->(MsUnlock())

			RG03->(dbSkip())

		End

	EndIf

	RG03->(dbCloseArea())
	Ferase(RGIndex+GetDBExtension())
	Ferase(RGIndex+OrdBagExt())

	// Caso já exista registros previamente lançados
	M0007 := " WITH LIBCLVL AS (SELECT ZB9.ZB9_CLVL, "
	M0007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_DIGIT", "'2'") + " ZB9_DIGIT, "
	M0007 += "                         " + IIF(_msCtrlAlt, "ZB9.ZB9_VISUAL", "'2'") + " ZB9_VISUAL "
	M0007 += "                    FROM " + RetSqlName("ZB9") + " ZB9 "
	M0007 += "                   WHERE ZB9.ZB9_FILIAL = '" + xFilial("ZB9") + "' "
	M0007 += "                     AND ZB9.ZB9_VERSAO = '" + _cVersao + "' "
	M0007 += "                     AND ZB9.ZB9_REVISA = '" + _cRevisa + "' "
	M0007 += "                     AND ZB9.ZB9_ANOREF = '" + _cAnoRef + "' "
	M0007 += "                     AND ZB9.ZB9_USER = '" + __cUserID + "' "
	M0007 += "                     AND ZB9.ZB9_TPORCT = 'RH' "
	M0007 += "                     AND ( ZB9.ZB9_DIGIT = '1' OR ZB9.ZB9_VISUAL = '1' ) "
	M0007 += "                     AND ZB9.D_E_L_E_T_ = ' ') "
	M0007 += " SELECT ZBA.ZBA_CLVL CLVL, "
	M0007 += "        ZB9.ZB9_DIGIT, "
	M0007 += "        ZB9.ZB9_VISUAL, "
	M0007 += "        ZB8.* "
	M0007 += "   FROM " + RetSqlName("ZB8") + " ZB8 "
	M0007 += "  INNER JOIN " + RetSqlName("ZBA") + " ZBA ON ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	M0007 += "                       AND ZBA.ZBA_MATR = ZB8.ZB8_MATR "
	M0007 += "                       AND ZBA.ZBA_CLVL = ZB8.ZB8_CLVL "
	M0007 += "                       AND ZBA.ZBA_VERSAO = ZB8.ZB8_VERSAO
	M0007 += "                       AND ZBA.ZBA_REVISA = ZB8.ZB8_REVISA
	M0007 += "                       AND ZBA.ZBA_ANOREF = ZB8.ZB8_ANOREF
	M0007 += "                       AND ZBA.ZBA_PERIOD = '00' "
	M0007 += "                       AND ZBA.D_E_L_E_T_ = ' ' "
	M0007 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = ZBA.ZBA_CLVL "
	M0007 += "  WHERE ZB8.ZB8_FILIAL = '" + xFilial("ZB8") + "' "
	M0007 += "    AND ZB8.ZB8_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZB8.ZB8_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZB8.ZB8_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZB8.ZB8_RUBRIC = '" + _cCodRubi + "' "
	M0007 += "    AND ZB8.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY ZBA.ZBA_CLVL, ZB8.ZB8_MATR "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->(!Eof())

		While M007->(!Eof())

			M007->(aAdd(_oGetDados:aCols,{CLVL,;
			Posicione("CTH", 1, xFilial("CTH") + CLVL, "CTH_DESC01"),;
			ZB9_DIGIT,;
			ZB9_VISUAL,;
			ZB8_MATR,;
			Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + ZB8_MATR, "ZO0_NOME"),;
			ZB8_MOTIVO,;
			ZB8_M01,;
			ZB8_M02,;
			ZB8_M03,;
			ZB8_M04,;
			ZB8_M05,;
			ZB8_M06,;
			ZB8_M07,;
			ZB8_M08,;
			ZB8_M09,;
			ZB8_M10,;
			ZB8_M11,;
			ZB8_M12,;
			ZB8_OBSERV,;
			"ZB8",;
			R_E_C_N_O_,;
			.F.	}))

			M007->(dbSkip())

		EndDo

	Else

		If _msCtrlAlt

			M0008 := " WITH LIBCLVL AS (SELECT ZB9.ZB9_CLVL, ZB9.ZB9_DIGIT, ZB9.ZB9_VISUAL "
			M0008 += "                    FROM " + RetSqlName("ZB9") + " ZB9 "
			M0008 += "                   WHERE ZB9.ZB9_FILIAL = '" + xFilial("ZB9") + "' "
			M0008 += "                     AND ZB9.ZB9_VERSAO = '" + _cVersao + "' "
			M0008 += "                     AND ZB9.ZB9_REVISA = '" + _cRevisa + "' "
			M0008 += "                     AND ZB9.ZB9_ANOREF = '" + _cAnoRef + "' "
			M0008 += "                     AND ZB9.ZB9_USER = '" + __cUserID + "' "
			M0008 += "                     AND ZB9.ZB9_TPORCT = 'RH' "
			M0008 += "                     AND ( ZB9.ZB9_DIGIT = '1' OR ZB9.ZB9_VISUAL = '1' ) "
			M0008 += "                     AND ZB9.D_E_L_E_T_ = ' ') "
			M0008 += " SELECT ZBA.ZBA_CLVL CLVL, "
			M0008 += "        ZB9.ZB9_DIGIT, "
			M0008 += "        ZB9.ZB9_VISUAL, "
			M0008 += "        ZBA.* "
			M0008 += "   FROM " + RetSqlName("ZBA") + " ZBA "
			M0008 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = ZBA.ZBA_CLVL "
			M0008 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZB8") + "' "
			M0008 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
			M0008 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
			M0008 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
			M0008 += "    AND ZBA.ZBA_PERIOD = '00' "
			M0008 += "    AND ZBA.D_E_L_E_T_ = ' ' "
			M0008 += "  ORDER BY ZBA.ZBA_CLVL, ZBA.ZBA_MATR "
			M8Index := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0008),'M008',.T.,.T.)
			dbSelectArea("M008")
			M008->(dbGoTop())

			If M008->(!Eof())

				While M008->(!Eof())

					M008->(aAdd(_oGetDados:aCols,{CLVL,;
					Posicione("CTH", 1, xFilial("CTH") + CLVL, "CTH_DESC01"),;
					ZB9_DIGIT,;
					ZB9_VISUAL,;
					ZBA_MATR,;
					Posicione("ZO0", 1, xFilial("ZO0") + _cVersao + _cRevisa + _cAnoRef + ZBA_MATR, "ZO0_NOME"),;
					Space(TamSx3("ZB8_MOTIVO")[1]),;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					0,;
					Space(TamSx3("ZB8_OBSERV")[1]),;
					"ZB8",;
					0,;
					.F.	}))

					M008->(dbSkip())

				EndDo

			Else

				_oGetDados:aCols	:=	aClone(_aColsBkp)

			EndIf	

			M008->(dbCloseArea())
			Ferase(M8Index+GetDBExtension())
			Ferase(M8Index+OrdBagExt())

		Else

			_oGetDados:aCols	:=	aClone(_aColsBkp)

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_REC_WT"})
	Local xmyMATR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_MATR"})
	Local xmyCLVL := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_CLVL"})
	Local xmyMOTIV:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_MOTIVO"})
	Local xmyM01  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M01"})
	Local xmyM02  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M02"})
	Local xmyM03  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M03"})
	Local xmyM04  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M04"})
	Local xmyM05  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M05"})
	Local xmyM06  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M06"})
	Local xmyM07  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M07"})
	Local xmyM08  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M08"})
	Local xmyM09  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M09"})
	Local xmyM10  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M10"})
	Local xmyM11  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M11"})
	Local xmyM12  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_M12"})
	Local xmyOBSER:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB8_OBSERV"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZB8')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZB8->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZB8",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					ZB8->ZB8_MATR    := _oGetDados:aCols[_nI,xmyMATR]
					ZB8->ZB8_CLVL    := _oGetDados:aCols[_nI,xmyCLVL]
					ZB8->ZB8_MOTIVO  := _oGetDados:aCols[_nI,xmyMOTIV]
					ZB8->ZB8_M01     := _oGetDados:aCols[_nI,xmyM01]
					ZB8->ZB8_M02     := _oGetDados:aCols[_nI,xmyM02]
					ZB8->ZB8_M03     := _oGetDados:aCols[_nI,xmyM03]
					ZB8->ZB8_M04     := _oGetDados:aCols[_nI,xmyM04]
					ZB8->ZB8_M05     := _oGetDados:aCols[_nI,xmyM05]
					ZB8->ZB8_M06     := _oGetDados:aCols[_nI,xmyM06]
					ZB8->ZB8_M07     := _oGetDados:aCols[_nI,xmyM07]
					ZB8->ZB8_M08     := _oGetDados:aCols[_nI,xmyM08]
					ZB8->ZB8_M09     := _oGetDados:aCols[_nI,xmyM09]
					ZB8->ZB8_M10     := _oGetDados:aCols[_nI,xmyM10]
					ZB8->ZB8_M11     := _oGetDados:aCols[_nI,xmyM11]
					ZB8->ZB8_M12     := _oGetDados:aCols[_nI,xmyM12]
					ZB8->ZB8_M12     := _oGetDados:aCols[_nI,xmyM12]
					ZB8->ZB8_OBSERV  := _oGetDados:aCols[_nI,xmyOBSER]

				Else

					ZB8->(DbDelete())

				EndIf

				ZB8->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZB8",.T.)
					ZB8->ZB8_FILIAL  := xFilial("ZB8")
					ZB8->ZB8_VERSAO  := _cVersao
					ZB8->ZB8_REVISA  := _cRevisa
					ZB8->ZB8_ANOREF  := _cAnoRef
					ZB8->ZB8_RUBRIC  := _cCodRubi
					ZB8->ZB8_MATR    := _oGetDados:aCols[_nI,xmyMATR]
					ZB8->ZB8_CLVL    := _oGetDados:aCols[_nI,xmyCLVL]
					ZB8->ZB8_MOTIVO  := _oGetDados:aCols[_nI,xmyMOTIV]
					ZB8->ZB8_M01     := _oGetDados:aCols[_nI,xmyM01]
					ZB8->ZB8_M02     := _oGetDados:aCols[_nI,xmyM02]
					ZB8->ZB8_M03     := _oGetDados:aCols[_nI,xmyM03]
					ZB8->ZB8_M04     := _oGetDados:aCols[_nI,xmyM04]
					ZB8->ZB8_M05     := _oGetDados:aCols[_nI,xmyM05]
					ZB8->ZB8_M06     := _oGetDados:aCols[_nI,xmyM06]
					ZB8->ZB8_M07     := _oGetDados:aCols[_nI,xmyM07]
					ZB8->ZB8_M08     := _oGetDados:aCols[_nI,xmyM08]
					ZB8->ZB8_M09     := _oGetDados:aCols[_nI,xmyM09]
					ZB8->ZB8_M10     := _oGetDados:aCols[_nI,xmyM10]
					ZB8->ZB8_M11     := _oGetDados:aCols[_nI,xmyM11]
					ZB8->ZB8_M12     := _oGetDados:aCols[_nI,xmyM12]
					ZB8->ZB8_OBSERV  := _oGetDados:aCols[_nI,xmyOBSER]
					ZB8->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZB8_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZB8_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZB8_ANOREF")[1])
	_cCodRubi       := SPACE(TAMSX3("ZB8_RUBRIC")[1])
	_mDescRubi      := SPACE(50)
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

User Function B390FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _nAt		:=	_oGetDados:nAt
	Local _CtrlDigt := GdFieldGet("ZB8_DIGIT",_nAt)
	Local _mqM01    := 0
	Local _mqM02    := 0
	Local _mqM03    := 0
	Local _mqM04    := 0
	Local _mqM05    := 0
	Local _mqM06    := 0
	Local _mqM07    := 0
	Local _mqM08    := 0
	Local _mqM09    := 0
	Local _mqM10    := 0
	Local _mqM11    := 0
	Local _mqM12    := 0

	If _CtrlDigt == "1"

		Do Case

			Case cEmpAnt <> '07' .And. ( Alltrim(cMenVar) == "M->ZB8_M02" .or. Alltrim(cMenVar) == "M->ZB8_M03" .or. Alltrim(cMenVar) == "M->ZB8_M04" .or. Alltrim(cMenVar) == "M->ZB8_M05")
			MsgINFO("Não é permitido efetuar promoções para os meses de Fev / Mar / Abr / Mai.")
			Return .F.

			Case cEmpAnt == '07' .And. ( Alltrim(cMenVar) == "M->ZB8_M08" .or. Alltrim(cMenVar) == "M->ZB8_M09" .or. Alltrim(cMenVar) == "M->ZB8_M10" .or. Alltrim(cMenVar) == "M->ZB8_M11")
			MsgINFO("Não é permitido efetuar promoções para os meses de Ago / Set / Out / Nov.")
			Return .F.

		EndCase

		Do Case

			Case Alltrim(cMenVar) == "M->ZB8_M01"
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := _mqM02 := _mqM01 := M->ZB8_M01

			Case Alltrim(cMenVar) == "M->ZB8_M02"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			If M->ZB8_M02 < _mqM01
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := _mqM02 := M->ZB8_M02

			Case Alltrim(cMenVar) == "M->ZB8_M03"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			If M->ZB8_M03 < _mqM02
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := M->ZB8_M03

			Case Alltrim(cMenVar) == "M->ZB8_M04"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			If M->ZB8_M04 < _mqM03
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := M->ZB8_M04

			Case Alltrim(cMenVar) == "M->ZB8_M05"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			If M->ZB8_M05 < _mqM04
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := M->ZB8_M05

			Case Alltrim(cMenVar) == "M->ZB8_M06"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			If M->ZB8_M06 < _mqM05
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := M->ZB8_M06

			Case Alltrim(cMenVar) == "M->ZB8_M07"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			If M->ZB8_M07 < _mqM06
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := M->ZB8_M07

			Case Alltrim(cMenVar) == "M->ZB8_M08"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			_mqM07 := GdFieldGet("ZB8_M07",_nAt)
			If M->ZB8_M08 < _mqM07
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := M->ZB8_M08

			Case Alltrim(cMenVar) == "M->ZB8_M09"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			_mqM07 := GdFieldGet("ZB8_M07",_nAt)
			_mqM08 := GdFieldGet("ZB8_M08",_nAt)
			If M->ZB8_M09 < _mqM08
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10 := _mqM09 := M->ZB8_M09

			Case Alltrim(cMenVar) == "M->ZB8_M10"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			_mqM07 := GdFieldGet("ZB8_M07",_nAt)
			_mqM08 := GdFieldGet("ZB8_M08",_nAt)
			_mqM09 := GdFieldGet("ZB8_M09",_nAt)
			If M->ZB8_M10 < _mqM09
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11 := _mqM10:= M->ZB8_M10

			Case Alltrim(cMenVar) == "M->ZB8_M11"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			_mqM07 := GdFieldGet("ZB8_M07",_nAt)
			_mqM08 := GdFieldGet("ZB8_M08",_nAt)
			_mqM09 := GdFieldGet("ZB8_M09",_nAt)
			_mqM10 := GdFieldGet("ZB8_M10",_nAt)
			If M->ZB8_M11 < _mqM10
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12 := _mqM11:= M->ZB8_M11

			Case Alltrim(cMenVar) == "M->ZB8_M12"
			_mqM01 := GdFieldGet("ZB8_M01",_nAt)
			_mqM02 := GdFieldGet("ZB8_M02",_nAt)
			_mqM03 := GdFieldGet("ZB8_M03",_nAt)
			_mqM04 := GdFieldGet("ZB8_M04",_nAt)
			_mqM05 := GdFieldGet("ZB8_M05",_nAt)
			_mqM06 := GdFieldGet("ZB8_M06",_nAt)
			_mqM07 := GdFieldGet("ZB8_M07",_nAt)
			_mqM08 := GdFieldGet("ZB8_M08",_nAt)
			_mqM09 := GdFieldGet("ZB8_M09",_nAt)
			_mqM10 := GdFieldGet("ZB8_M10",_nAt)
			_mqM11 := GdFieldGet("ZB8_M11",_nAt)
			If M->ZB8_M12 < _mqM11
				MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
				Return .F.
			EndIf
			_mqM12:= M->ZB8_M12

		EndCase

		GdFieldPut("ZB8_M01"   , _mqM01 , _nAt)
		GdFieldPut("ZB8_M02"   , _mqM02 , _nAt)
		GdFieldPut("ZB8_M03"   , _mqM03 , _nAt)
		GdFieldPut("ZB8_M04"   , _mqM04 , _nAt)
		GdFieldPut("ZB8_M05"   , _mqM05 , _nAt)
		GdFieldPut("ZB8_M06"   , _mqM06 , _nAt)
		GdFieldPut("ZB8_M07"   , _mqM07 , _nAt)
		GdFieldPut("ZB8_M08"   , _mqM08 , _nAt)
		GdFieldPut("ZB8_M09"   , _mqM09 , _nAt)
		GdFieldPut("ZB8_M10"   , _mqM10 , _nAt)
		GdFieldPut("ZB8_M11"   , _mqM11 , _nAt)
		GdFieldPut("ZB8_M12"   , _mqM12 , _nAt)

	Else 

		RestArea( vfArea )
		
		Return .F.

	EndIf

	RestArea( vfArea )

Return .T.

User Function B390DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de deleção para os casos em que já existir registro de orçamento associado, será necessário primeiro retirar de lá

Return _lRet
