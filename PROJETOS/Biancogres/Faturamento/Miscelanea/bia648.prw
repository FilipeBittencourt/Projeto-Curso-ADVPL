#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA648
@author Marcos Alberto Soprani
@since 02/10/17
@version 1.0
@description Tela para cadastro de/para Da MARCA À RECEITA por CNPJ 
@type function
/*/

User Function BIA648()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBL") + SPACE(TAMSX3("ZBL_VERSAO")[1]) + SPACE(TAMSX3("ZBL_REVISA")[1]) + SPACE(TAMSX3("ZBL_ANOREF")[1]) + SPACE(TAMSX3("ZBL_MARCA")[1])
	Local bWhile	    := {|| ZBL_FILIAL + ZBL_VERSAO + ZBL_REVISA + ZBL_ANOREF + ZBL_MARCA }                    
	Local aNoFields     := {"ZBL_VERSAO", "ZBL_REVISA", "ZBL_ANOREF", "ZBL_MARCA", "ZBL_DMARCA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBL_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBL_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBL_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZBL_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc  := SPACE(50) 

	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A") }, "Exporta p/Excel"   , "Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBL",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Da MARCA À RECEITA por CNPJ" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA648A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA648B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA648C()

	@ 050,310 SAY "Marca:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA648D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B648FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B648DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA648A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA648F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA648B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA648F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA648C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA648F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA648D()

	If Empty(_cCodMarc)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA648F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA648F()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodMarc)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mNomeMarc := Posicione("Z37", 1, xFilial("Z37") + _cCodMarc, "Z37_DESCR")

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RECEITA" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RECEITA'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
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

	M0007 := " SELECT * "
	M0007 += "   FROM " + RetSqlName("ZBL") + " ZBL "
	M0007 += "  WHERE ZBL_FILIAL = '" + xFilial("ZBL") + "' "
	M0007 += "    AND ZBL_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBL_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBL_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBL_MARCA = '" + _cCodMarc + "' "
	M0007 += "    AND ZBL.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY ZBL.ZBL_VERSAO, ZBL.ZBL_REVISA, ZBL.ZBL_ANOREF, "
	M0007 += "           ZBL.ZBL_MARCA, ZBL.ZBL_CANALD, ZBL.ZBL_EMPRP "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	ProcRegua(0)
	If M007->(!Eof())

		While M007->(!Eof())

			IncProc("Processando..." + Alltrim(Str(M007->(Recno()))))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBL_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBL"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBL_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBL_DCANDI"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZBJ", 1, xFilial("ZBJ") + M007->ZBL_CANALD, "ZBJ_DESCR")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBL_DEMPRP"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("Z35", 1, xFilial("Z35") + M007->ZBL_EMPRP, "Z35_DESCR")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBL_DSCSEG"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("Z41", 1, xFilial("Z41") + M007->ZBL_TPSEG, "Z41_DESCR")
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

Static Function fGrvDados()

	Local _nI, _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBL_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBL')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBL->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBL",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBL->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZBL->(DbDelete())

				EndIf

				ZBL->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBL",.T.)

					ZBL->ZBL_FILIAL  := xFilial("ZBL")
					ZBL->ZBL_VERSAO  := _cVersao
					ZBL->ZBL_REVISA  := _cRevisa
					ZBL->ZBL_ANOREF  := _cAnoRef
					ZBL->ZBL_MARCA   := _cCodMarc
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBL->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZBL->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBL_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBL_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBL_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBL_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	If _msCtrlAlt

		MsgInfo("Registro Incluído com Sucesso!")

	Else

		MsgInfo("Nenhum Registro foi afetado!")

	EndIf

Return

User Function B648FOK()

	Local cMenVar     := ReadVar()
	Local vfArea      := GetArea()
	Local _cAlias
	Local _nAt		  := _oGetDados:nAt
	Local _nI
	Local _msCANALD   := ""
	Local _msEMPRP    := ""
	Local _msTPSEG

	Do Case

		Case Alltrim(cMenVar) == "M->ZBL_CANALD"
		_msCANALD   := M->ZBL_CANALD
		_msEMPRP    := GdFieldGet("ZBL_EMPRP",_nAt)
		_msTPSEG	:= GdFieldGet("ZBL_TPSEG",_nAt)
		GdFieldPut("ZBL_DCANDI"   , Posicione("ZBJ", 1, xFilial("ZBJ") + M->ZBL_CANALD, "ZBJ_DESCR") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBL_EMPRP"
		_msCANALD   := GdFieldGet("ZBL_CANALD",_nAt)
		_msEMPRP    := M->ZBL_EMPRP
		_msTPSEG	:= GdFieldGet("ZBL_TPSEG",_nAt)
		GdFieldPut("ZBL_DEMPRP"   , Posicione("Z35", 1, xFilial("Z35") + M->ZBL_EMPRP + "01", "Z35_DESCR") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBL_TPSEG"
		_msCANALD   := GdFieldGet("ZBL_CANALD",_nAt)
		_msEMPRP    := GdFieldGet("ZBL_EMPRP",_nAt)
		_msTPSEG	:= M->ZBL_TPSEG
		
		GdFieldPut("ZBL_DSCSEG"   , Posicione("Z41", 1, xFilial("Z41") + M->ZBL_TPSEG, "Z41_DESCR") , _nAt)
		

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_msCANALD) .and. _msCANALD == GdFieldGet("ZBL_CANALD",_nI)

				If !Empty(_msEMPRP) .and. _msEMPRP == GdFieldGet("ZBL_EMPRP",_nI)

					If !Empty(_msTpSeg) .and. _msTPSEG == GdFieldGet("ZBL_TPSEG",_nI)
						MsgInfo("Não poderá haver a mesma CHAVE informada mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a CHAVE informada!!!")
						Return .F.
					EndIf	

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B648DOK()

	Local _lRet	:=	.T.

Return _lRet
