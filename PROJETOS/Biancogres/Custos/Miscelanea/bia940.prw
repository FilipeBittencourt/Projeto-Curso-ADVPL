#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA940
@author Marcos Alberto Soprani
@since 09/10/17
@version 1.0
@description Tela para Consulta do Consulta OBZ Integration  
@type function
/*/

User Function BIA940()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("Z98") + SPACE(TAMSX3("Z98_VERSAO")[1]) + SPACE(TAMSX3("Z98_REVISA")[1]) + SPACE(TAMSX3("Z98_ANOREF")[1])
	Local bWhile	    := {|| Z98_FILIAL + Z98_VERSAO + Z98_REVISA + Z98_ANOREF }                    
	Local aNoFields     := {"Z98_VERSAO", "Z98_REVISA", "Z98_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	:=	{}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("Z98_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("Z98_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("Z98_ANOREF")[1])
	Private _oGAnoRef
	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel","Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"Z98",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Consulta dados OBZ Integration" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA940A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA940B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA940C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*cTudoOk*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999 /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/, /*cDelOk*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, _nOpcA := 0}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA940A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA940C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA940B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA940C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA940C()

	Local _msc

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	rjCtrlTotal := .F.
	If U_ValOper("OR3", .F.)
		If MsgNOYES("Deseja consultar todos os registros? Clique em Sim. Caso queira visualizar apenas os registros associados ao seu uruário, clique em Não.")
			rjCtrlTotal := .T.
		EndIf
	EndIf

	// Não é necessário fazer filtro pela tabela ZB5 (controle de versão), pois esta rotina somente lista os registros.
	_msCtrlAlt := .F.
	_oGetDados:lInsert := .F.
	_oGetDados:lUpdate := .F.

	_oGetDados:aCols	:=	{}

	M0007 := " SELECT Z98.*, "
	M0007 += "        ISNULL(CONVERT( VARCHAR(8000), CONVERT(VARBINARY(8000), Z98_JSTMEM)), '') AS JSTMEM, "
	M0007 += "        (SELECT COUNT(*) "
	M0007 += "           FROM " + RetSqlName("Z98") + " XZ98 "
	M0007 += "          WHERE XZ98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	M0007 += "            AND XZ98.Z98_VERSAO = '" + _cVersao + "' "
	M0007 += "            AND XZ98.Z98_REVISA = '" + _cRevisa + "' "
	M0007 += "            AND XZ98.Z98_ANOREF = '" + _cAnoRef + "' "
	If !rjCtrlTotal
		M0007 += "            AND ( XZ98.Z98_USRRSP = '" + __cUserID + "' OR XZ98.Z98_USRRS2 = '" + __cUserID + "' ) "
	EndIf
	M0007 += "            AND XZ98.D_E_L_E_T_ = ' ') NREGS "
	M0007 += "   FROM " + RetSqlName("Z98") + " Z98 "
	M0007 += "  WHERE Z98.Z98_FILIAL = '" + xFilial("Z98") + "' "
	M0007 += "    AND Z98.Z98_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND Z98.Z98_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND Z98.Z98_ANOREF = '" + _cAnoRef + "' "
	If !rjCtrlTotal
		M0007 += "    AND ( Z98.Z98_USRRSP = '" + __cUserID + "' OR Z98.Z98_USRRS2 = '" + __cUserID + "' ) "
	EndIf
	M0007 += "    AND Z98.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY Z98.Z98_FILEIN, Z98.Z98_LINHAA "
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
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "Z98"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_DCLVL"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CTH", 1, xFilial("CTH") + M007->Z98_CLVL, "CTH_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_ENTID"
					msCodEnt := Posicione("CTH", 1, xFilial("CTH") + M007->Z98_CLVL, "CTH_YENTID")
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZCA", 1, xFilial("ZCA") + msCodEnt, "ZCA_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_DCONTA"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("CT1", 1, xFilial("CT1") + M007->Z98_CONTA, "CT1_DESC01")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_PACOTE"
					msCodPac := Posicione("CT1", 1, xFilial("CT1") + M007->Z98_CONTA, "CT1_YPCT20")
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZC8", 1, xFilial("ZC8") + msCodPac, "ZC8_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_JSTMEM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := M007->JSTMEM

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_INIDPR"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := ctod(&(Alltrim(_oGetDados:aHeader[_msc][2])))

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "Z98_DIDDRV"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZBE", 1, xFilial("ZBE") + _cVersao + _cRevisa + _cAnoRef + M007->Z98_IDDRV, "ZBE_DESCRI")

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
