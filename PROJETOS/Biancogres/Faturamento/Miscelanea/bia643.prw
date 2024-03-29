#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA643
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para cadastro de Impostos 
@type function
/*/

User Function BIA643()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBH") + SPACE(TAMSX3("ZBH_VERSAO")[1]) + SPACE(TAMSX3("ZBH_REVISA")[1]) + SPACE(TAMSX3("ZBH_ANOREF")[1]) + SPACE(TAMSX3("ZBH_MARCA")[1]) + SPACE(TAMSX3("ZBH_CANALD")[1])
	Local bWhile	    := {|| ZBH_FILIAL + ZBH_VERSAO + ZBH_REVISA + ZBH_ANOREF + ZBH_MARCA + ZBH_CANALD }   

	Local aYesFields	:=	{"ZBH_TPSEG","ZBH_ESTADO","ZBH_PCTGMR","ZBH_DPCTGM","ZBH_PICMS","ZBH_PPIS","ZBH_PCOF","ZBH_PST","ZBH_PDIFAL","ZBH_PIPI"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBH_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBH_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBH_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZBH_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc  := SPACE(50) 
	Private _cCanalDist := SPACE(TAMSX3("ZBH_CANALD")[1])
	Private _oGCanalDis
	Private _mDescCanD  := SPACE(50) 

	Private _msCtrlAlt  := .F.

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integra��o" , "Layout Integra��o"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B643IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBH",1,cSeek,bWhile,,,aYesFields,.T.,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Impostos para Or�amento de Receita" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Vers�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA643A()

	@ 050,110 SAY "Revis�o:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA643B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA643C()

	@ 050,310 SAY "Marca:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA643D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	@ 050,490 SAY "Canal Distr:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,550 MSGET _oGCanalDis VAR _cCanalDist F3("ZBJ") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA643E()
	@ 050,610 SAY _mDescCanD SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, "U_B643TOK" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B643FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B643DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA643A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Vers�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc) .and. !Empty(_cCanalDist)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA643E() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA643B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revis�o � Obrigat�rio!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc) .and. !Empty(_cCanalDist)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA643E() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA643C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano � Obrigat�rio!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc) .and. !Empty(_cCanalDist)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA643E() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA643D()

	If Empty(_cCodMarc)
		MsgInfo("O preenchimento do campo Marca � Obrigat�rio!!!")
		Return .F.
	EndIf
	_mNomeMarc := Posicione("Z37", 1, xFilial("Z37") + _cCodMarc, "Z37_DESCR")
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc) .and. !Empty(_cCanalDist)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA643E() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA643E()

	Local _cAlias   := GetNextAlias()
	Local M001      := GetNextAlias()
	Local _msc
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodMarc) .or. Empty(_cCanalDist)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mDescCanD := Posicione("ZBJ", 1, xFilial("ZBJ") + _cCanalDist, "ZBJ_DESCR")

	xfMensCompl := ""
	xfMensCompl += "Tipo Or�amento igual RECEITA" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digita��o diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Concilia��o igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

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
		AND ZB5.ZB5_DTDIGT <= %Exp:dtos(Date())%
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

	If _msCtrlAlt

		// Confirma e gera registros na tabela de Receita Integration para os casos em que os registros n�o foram inclu�dos

		AX001 := " SELECT ZBK_VEND + ZBK_GRPCLI + ZBK_TPSEG +  ZBK_ESTADO + ZBK_PCTGMR +  ZBK_FORMAT + ZBK_CATEG KEYREF INTO ##REFZBK "
		AX001 += "   FROM " + RetSqlName("ZBK") + " XZBK "
		AX001 += "  WHERE XZBK.ZBK_VERSAO = '" + _cVersao + "' "
		AX001 += "    AND XZBK.ZBK_REVISA = '" + _cRevisa + "' "
		AX001 += "    AND XZBK.ZBK_ANOREF = '" + _cAnoRef + "' "
		AX001 += "    AND XZBK.ZBK_MARCA = '" + _cCodMarc + "' "
		AX001 += "    AND XZBK.ZBK_CAN" + _cCanalDist + " <> 0 "
		AX001 += "    AND XZBK.D_E_L_E_T_ = ' ' "
		TcSqlExec(AX001)

		AZ002 := " SELECT ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR, ZBH_VEND + ZBH_GRPCLI + ZBH_TPSEG + ZBH_ESTADO + ZBH_PCTGMR + ZBH_FORMAT + ZBH_CATEG KEYTAY INTO ##REFZBH "
		AZ002 += "   FROM " + RetSqlName("ZBH") + " ZBH "
		AZ002 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
		AZ002 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
		AZ002 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
		AZ002 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
		AZ002 += "    AND ZBH.ZBH_MARCA  = '" + _cCodMarc + "' "
		AZ002 += "    AND ZBH.ZBH_PERIOD = '00' "
		AZ002 += "    AND ZBH.ZBH_ORIGF = '1' "
		AZ002 += "    AND ZBH.ZBH_TPSEG + ZBH.ZBH_ESTADO + ZBH.ZBH_PCTGMR NOT IN(SELECT XZBH.ZBH_TPSEG + XZBH.ZBH_ESTADO + XZBH.ZBH_PCTGMR "
		AZ002 += "                                                                 FROM " + RetSqlName("ZBH") + " XZBH "
		AZ002 += "                                                                WHERE XZBH.ZBH_FILIAL = ZBH.ZBH_FILIAL "
		AZ002 += "                                                                  AND XZBH.ZBH_VERSAO = ZBH.ZBH_VERSAO "
		AZ002 += "                                                                  AND XZBH.ZBH_REVISA = ZBH.ZBH_REVISA "
		AZ002 += "                                                                  AND XZBH.ZBH_ANOREF = ZBH.ZBH_ANOREF "
		AZ002 += "                                                                  AND XZBH.ZBH_MARCA = ZBH.ZBH_MARCA "
		AZ002 += "                                                                  AND XZBH.ZBH_PERIOD = ZBH.ZBH_PERIOD "
		AZ002 += "                                                                  AND XZBH.ZBH_CANALD = '" + _cCanalDist + "' "
		AZ002 += "                                                                  AND XZBH.ZBH_ORIGF = '3' "
		AZ002 += "                                                                  AND XZBH.D_E_L_E_T_ = ' ') "
		AZ002 += "    AND ZBH.D_E_L_E_T_ = ' ' "
		TcSqlExec(AZ002)				

		RG003 := " SELECT ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR "
		RG003 += "   FROM ##REFZBH ZBH "
		RG003 += "  INNER JOIN ##REFZBK ZBK ON ZBK.KEYREF = ZBH.KEYTAY "
		RG003 += "  GROUP BY ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR "
		RG003 += "  ORDER BY ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR "
		RGIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
		dbSelectArea("RG03")
		RG03->(dbGoTop())

		If RG03->(!Eof())

			While RG03->(!Eof())

				Reclock("ZBH",.T.)
				ZBH->ZBH_FILIAL  := xFilial("ZBH")
				ZBH->ZBH_VERSAO  := _cVersao
				ZBH->ZBH_REVISA  := _cRevisa
				ZBH->ZBH_ANOREF  := _cAnoRef
				ZBH->ZBH_MARCA   := _cCodMarc
				ZBH->ZBH_PERIOD  := "00"
				ZBH->ZBH_CANALD  := _cCanalDist
				ZBH->ZBH_ORIGF   := "3"
				ZBH->ZBH_TPSEG   := RG03->ZBH_TPSEG
				ZBH->ZBH_ESTADO  := RG03->ZBH_ESTADO
				ZBH->ZBH_PCTGMR  := RG03->ZBH_PCTGMR
				ZBH->(MsUnlock())

				RG03->(dbSkip())

			End

		EndIf

		RG03->(dbCloseArea())
		Ferase(RGIndex+GetDBExtension())
		Ferase(RGIndex+OrdBagExt())

		TcSqlExec("DROP TABLE ##REFZBK")
		TcSqlExec("DROP TABLE ##REFZBH")

	EndIf

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBH% ZBH
		WHERE ZBH_FILIAL = %xFilial:ZBH%
		AND ZBH_VERSAO = %Exp:_cVersao%
		AND ZBH_REVISA = %Exp:_cRevisa%
		AND ZBH_ANOREF = %Exp:_cAnoRef%
		AND ZBH_MARCA = %Exp:_cCodMarc%
		AND ZBH_CANALD = %Exp:_cCanalDist%
		AND ZBH_PERIOD = '00'
		AND ZBH_ORIGF = '3'
		AND ZBH.%NotDel%
		ORDER BY ZBH_TPSEG, ZBH_ESTADO, ZBH_PCTGMR
	EndSql

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBH"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + (_cAlias)->ZBH_PCTGMR, "X5_DESCRI")

				Else
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := &(Alltrim(_oGetDados:aHeader[_msc][2]))

				EndIf			
			Next _msc
			_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := .F.	

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		_oGetDados:aCols	:=	aClone(_aColsBkp)

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI, _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBH')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBH->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBH",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBH->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZBH->(DbDelete())

				EndIf

				ZBH->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBH",.T.)

					ZBH->ZBH_FILIAL  := xFilial("ZBH")
					ZBH->ZBH_VERSAO  := _cVersao
					ZBH->ZBH_REVISA  := _cRevisa
					ZBH->ZBH_ANOREF  := _cAnoRef
					ZBH->ZBH_PERIOD  := "00"
					ZBH->ZBH_MARCA   := _cCodMarc
					ZBH->ZBH_CANALD  := _cCanalDist
					ZBH->ZBH_ORIGF   := "3"
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBH->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZBH->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBH_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBH_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBH_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBH_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_cCanalDist     := SPACE(TAMSX3("ZBH_CANALD")[1])
	_mDescCanD      := SPACE(50) 
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Inclu�do com Sucesso!")

Return

User Function B643FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _zpTPSEG  := ""
	Local _zpESTADO := ""
	Local _zpPCTGMR := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZBH_TPSEG"
		_zpTPSEG   := M->ZBH_TPSEG
		_zpESTADO  := GdFieldGet("ZBH_ESTADO",_nAt)
		_zpPCTGMR  := GdFieldGet("ZBH_PCTGMR",_nAt)

		Case Alltrim(cMenVar) == "M->ZBH_ESTADO"
		_zpTPSEG   := GdFieldGet("ZBH_TPSEG",_nAt)
		_zpESTADO  := M->ZBH_ESTADO
		_zpPCTGMR  := GdFieldGet("ZBH_PCTGMR",_nAt)

		Case Alltrim(cMenVar) == "M->ZBH_PCTGMR"
		_zpTPSEG   := GdFieldGet("ZBH_TPSEG",_nAt)
		_zpESTADO  := GdFieldGet("ZBH_ESTADO",_nAt)
		_zpPCTGMR  := M->ZBH_PCTGMR
		GdFieldPut("ZBH_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + _zpPCTGMR, "X5_DESCRI") , _nAt)

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_zpTPSEG) .and. _zpTPSEG == GdFieldGet("ZBH_TPSEG",_nI)

				If !Empty(_zpESTADO) .and. _zpESTADO == GdFieldGet("ZBH_ESTADO",_nI)

					If !Empty(_zpPCTGMR) .and. _zpPCTGMR == GdFieldGet("ZBH_PCTGMR",_nI)

						MsgInfo("A chave composta de TipoSegmento / Estado / Pacote GMR s� pode existir uma �nica vez. Na linha: " + Alltrim(Str(_nI)) + " j� existe esta chave informada!!!")
						Return .F.

					EndIf

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B643DOK()

	Local _lRet	:=	.T.

Return _lRet

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B643IEXC � Autor � Marcos Alberto S      � Data � 21/06/17 ���
��+----------+------------------------------------------------------------���
���Descri��o � Importa��o planilha Excel para Or�amento - Comiss�os REC.I ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B643IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	If !_msCtrlAlt
		MsgInfo("A Vers�o or�ament�ria informada n�o est� ativa para executar este processamento!!!")
		Return .F.
	EndIf

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importa��o dos percentuais de Impostos para Or�amento RECEITA."))   
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
	Local cLoad	    := 'B643IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZBH'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_REC_WT"})
	Local vtRecGrd := {}

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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBH_REC_WT"})

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
���  TudoOk                                                               ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B643TOK()

	Local _lRet	:=	.T.
	Local _nI

	nPosTPSEG   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_TPSEG"})
	nPosESTADO  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_ESTADO"})
	nPosPCTGMR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_PCTGMR"})

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If !GDdeleted(_nI)

			nTPSEGLin   := _oGetDados:aCols[_nI][nPosTPSEG]
			nESTADOLin  := _oGetDados:aCols[_nI][nPosESTADO]
			nPCTGMRLin  := _oGetDados:aCols[_nI][nPosPCTGMR]

			xkPosRec := aScan(_oGetDados:aCols,{|x| Alltrim(x[nPosTPSEG]) == Alltrim(nTPSEGLin) .and. Alltrim(x[nPosESTADO]) == Alltrim(nESTADOLin) .and. Alltrim(x[nPosPCTGMR]) == Alltrim(nPCTGMRLin) })

			If xkPosRec <> _nI

				MsgInfo("A chave composta de TpSeg / Estado / Pacote GMR s� pode existir uma �nica vez. Na linha: " + Alltrim(Str(xkPosRec)) + " j� existe esta chave informada!!!")
				Return .F.

			EndIf

		EndIf

	Next _nI

Return _lRet
