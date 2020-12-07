#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA397
@author Marcos Alberto Soprani
@since 09/10/17
@version 1.0
@description Tela para Consulta do Desdobramento do Orçamento RH  
@type function
/*/

User Function BIA397()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBA") + SPACE(TAMSX3("ZBA_VERSAO")[1]) + SPACE(TAMSX3("ZBA_REVISA")[1]) + SPACE(TAMSX3("ZBA_ANOREF")[1])
	Local bWhile	    := {|| ZBA_FILIAL + ZBA_VERSAO + ZBA_REVISA + ZBA_ANOREF }                    
	Local aNoFields     := {"ZBA_VERSAO", "ZBA_REVISA", "ZBA_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	:=	{}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBA_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBA_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBA_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel","Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBA",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Consulta Desdobramento do Orçamento de RH" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA397A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA397B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA397C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*cTudoOk*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/, /*cDelOk*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_oDlg:End()}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA397A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA397C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA397B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA397C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA397C()

	Local _msc
	Local _cAlias    := GetNextAlias()
	Local M001       := GetNextAlias()

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	// Não é necessário fazer filtro pela tabela ZB5 (controle de versão), pois esta rotina somente lista os registros.
	_msCtrlAlt := .F.
	_oGetDados:lInsert := .F.
	_oGetDados:lUpdate := .F.

	_oGetDados:aCols	:=	{}

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
	M0007 += " SELECT ZB9.ZB9_DIGIT ZBA_DIGIT,
	M0007 += "        ZB9.ZB9_VISUAL ZBA_VISUAL,
	M0007 += "        ZBA.*, "
	M0007 += "        (SELECT COUNT(*) "
	M0007 += "           FROM " + RetSqlName("ZBA") + " XZBA "
	M0007 += "          INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = XZBA.ZBA_CLVL "
	M0007 += "          WHERE XZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	M0007 += "            AND XZBA.ZBA_VERSAO = '" + _cVersao + "' "
	M0007 += "            AND XZBA.ZBA_REVISA = '" + _cRevisa + "' "
	M0007 += "            AND XZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	M0007 += "            AND XZBA.ZBA_PERIOD <> '00' "
	M0007 += "            AND XZBA.D_E_L_E_T_ = ' ') NREGS "
	M0007 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	M0007 += "  INNER JOIN LIBCLVL ZB9 ON ZB9.ZB9_CLVL = ZBA.ZBA_CLVL "
	M0007 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	M0007 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBA.ZBA_PERIOD <> '00' "
	M0007 += "    AND ZBA.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY ZBA.ZBA_CLVL, ZBA.ZBA_MATR "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")

	xtrTot := M007->(NREGS)
	ProcRegua(xtrTot)

	M007->(dbGoTop())
	If M007->(!Eof())

		While M007->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(M007->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBA"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DFUNC"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SRJ", 1, xFilial("SRJ") + M007->ZBA_FUNCAO, "RJ_DESC")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCTGFU"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZB4", 1, xFilial("ZB4") + M007->ZBA_CATGFU, "ZB4_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DCLVL"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + M007->ZBA_CLVL, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBA_DTINIF"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := stod(&(Alltrim(_oGetDados:aHeader[_msc][2])))

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			M007->(dbSkip())

		EndDo

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	_oGetDados:Refresh()

Return .T.
