#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA645
@author Marcos Alberto Soprani
@since 02/10/17
@version 1.0
@description Tela para cadastro de Rateio das quantidades pelos Canais de Comercialização 
@type function
/*/

User Function BIA645()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBK") + SPACE(TAMSX3("ZBK_VERSAO")[1]) + SPACE(TAMSX3("ZBK_REVISA")[1]) + SPACE(TAMSX3("ZBK_ANOREF")[1]) + SPACE(TAMSX3("ZBK_MARCA")[1])
	Local bWhile	    := {|| ZBK_FILIAL + ZBK_VERSAO + ZBK_REVISA + ZBK_ANOREF + ZBK_MARCA }                    
	Local aNoFields     := {"ZBK_VERSAO", "ZBK_REVISA", "ZBK_ANOREF", "ZBK_MARCA"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBK_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBK_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBK_ANOREF")[1])
	Private _oGAnoRef
	Private _cCodMarc	:= SPACE(TAMSX3("ZBK_MARCA")[1])
	Private _oGCodMarca
	Private _mNomeMarc  := SPACE(50) 

	Private _msCtrlAlt := .T.  

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")      }, "Exporta p/Excel"   , "Exporta p/Excel"})
	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")      }, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B645IEXC()       }, "Importa Arquivo"   , "Importa Arquivo"})
	aAdd(_aButtons,{"AUTOM"   ,{|| U_B645TOREV("010") }, "Canal 015 p/ 010"  , "Canal 015 p/ 010"})
	aAdd(_aButtons,{"AUTOM"   ,{|| U_B645TOREV("035") }, "Canal 015 p/ 035"  , "Canal 015 p/ 035"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBK",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "% Distribuição por Canal" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA645A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA645B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA645C()

	@ 050,310 SAY "Marca:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA645D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B645FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B645DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA645A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA645F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA645B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA645F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA645C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA645F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA645D()

	If Empty(_cCodMarc)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA645F() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA645F()

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

	RG003 := " SELECT ZBH.ZBH_VERSAO, ZBH.ZBH_REVISA, ZBH.ZBH_ANOREF, " 
	RG003 += "        ZBH.ZBH_MARCA, ZBH.ZBH_VEND, ZBH.ZBH_GRPCLI, "
	RG003 += "        ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR, "
	RG003 += "        ZBH.ZBH_FORMAT, ZBH.ZBH_CATEG "
	RG003 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	RG003 += "  WHERE ZBH.ZBH_FILIAL = '" + xFilial("ZBH") + "' "
	RG003 += "    AND ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	RG003 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	RG003 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	RG003 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
	RG003 += "    AND ZBH.ZBH_PERIOD = '00' "
	RG003 += "    AND ZBH.ZBH_ORIGF = '1' "
	RG003 += "    AND ZBH.ZBH_VERSAO + ZBH.ZBH_REVISA + ZBH.ZBH_ANOREF + " 
	RG003 += "        ZBH.ZBH_MARCA + ZBH.ZBH_VEND + ZBH.ZBH_GRPCLI +  "
	RG003 += "        ZBH.ZBH_TPSEG + ZBH.ZBH_ESTADO + ZBH.ZBH_PCTGMR + "
	RG003 += "        ZBH.ZBH_FORMAT + ZBH.ZBH_CATEG NOT IN(SELECT XZBK.ZBK_VERSAO + XZBK.ZBK_REVISA + XZBK.ZBK_ANOREF + "
	RG003 += "                                                     XZBK.ZBK_MARCA + XZBK.ZBK_VEND + XZBK.ZBK_GRPCLI + "
	RG003 += "                                                     XZBK.ZBK_TPSEG + XZBK.ZBK_ESTADO + XZBK.ZBK_PCTGMR + "
	RG003 += "                                                     XZBK.ZBK_FORMAT + XZBK.ZBK_CATEG "
	RG003 += "                                                FROM " + RetSqlName("ZBK") + " XZBK "
	RG003 += "                                               WHERE XZBK.ZBK_FILIAL = ZBH.ZBH_FILIAL "
	RG003 += "                                                 AND XZBK.ZBK_VERSAO = ZBH.ZBH_VERSAO "
	RG003 += "                                                 AND XZBK.ZBK_REVISA = ZBH.ZBH_REVISA "
	RG003 += "                                                 AND XZBK.ZBK_ANOREF = ZBH.ZBH_ANOREF "
	RG003 += "                                                 AND XZBK.ZBK_MARCA = ZBH.ZBH_MARCA "
	RG003 += "                                                 AND XZBK.D_E_L_E_T_ = ' ' ) "
	RG003 += "    AND ZBH.D_E_L_E_T_ = ' ' "
	RG003 += "  GROUP BY ZBH.ZBH_VERSAO, ZBH.ZBH_REVISA, ZBH.ZBH_ANOREF, " 
	RG003 += "           ZBH.ZBH_MARCA, ZBH.ZBH_VEND, ZBH.ZBH_GRPCLI, "
	RG003 += "           ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR, "
	RG003 += "           ZBH.ZBH_FORMAT, ZBH.ZBH_CATEG "
	RG003 += "  ORDER BY ZBH.ZBH_VERSAO, ZBH.ZBH_REVISA, ZBH.ZBH_ANOREF, " 
	RG003 += "           ZBH.ZBH_MARCA, ZBH.ZBH_VEND, ZBH.ZBH_GRPCLI, "
	RG003 += "           ZBH.ZBH_TPSEG, ZBH.ZBH_ESTADO, ZBH.ZBH_PCTGMR, "
	RG003 += "           ZBH.ZBH_FORMAT, ZBH.ZBH_CATEG "
	RGIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RG003),'RG03',.T.,.T.)
	dbSelectArea("RG03")
	RG03->(dbGoTop())

	If RG03->(!Eof())

		While RG03->(!Eof())

			Reclock("ZBK",.T.)
			ZBK->ZBK_FILIAL  := xFilial("ZBK")
			ZBK->ZBK_VERSAO  := _cVersao
			ZBK->ZBK_REVISA  := _cRevisa
			ZBK->ZBK_ANOREF  := _cAnoRef
			ZBK->ZBK_MARCA   := _cCodMarc
			ZBK->ZBK_VEND    := RG03->ZBH_VEND  
			ZBK->ZBK_GRPCLI  := RG03->ZBH_GRPCLI
			ZBK->ZBK_TPSEG   := RG03->ZBH_TPSEG 
			ZBK->ZBK_ESTADO  := RG03->ZBH_ESTADO
			ZBK->ZBK_PCTGMR  := RG03->ZBH_PCTGMR
			ZBK->ZBK_FORMAT  := RG03->ZBH_FORMAT
			ZBK->ZBK_CATEG   := RG03->ZBH_CATEG
			//If RG03->ZBH_GRPCLI == "G-001307" .and. RG03->ZBH_VEND == "999999"
			//	ZBK->ZBK_CAN010   := 100    
			//	ZBK->ZBK_CANTOT   := 100    
			//EndIf 
			ZBK->ZBK_CANTOT  := ZBK->ZBK_CAN005 + ZBK->ZBK_CAN010 + ZBK->ZBK_CAN015 + ZBK->ZBK_CAN020 + ZBK->ZBK_CAN025 + ZBK->ZBK_CAN030 + ZBK->ZBK_CAN035
			ZBK->(MsUnlock())

			RG03->(dbSkip())

		End

	EndIf

	RG03->(dbCloseArea())
	Ferase(RGIndex+GetDBExtension())
	Ferase(RGIndex+OrdBagExt())

	M0007 := " SELECT * "
	M0007 += "   FROM " + RetSqlName("ZBK") + " ZBK "
	M0007 += "  WHERE ZBK_FILIAL = '" + xFilial("ZBK") + "' "
	M0007 += "    AND ZBK_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBK_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBK_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBK_MARCA = '" + _cCodMarc + "' "
	M0007 += "    AND ZBK.D_E_L_E_T_ = ' ' "
	M0007 += "  ORDER BY ZBK.ZBK_VERSAO, ZBK.ZBK_REVISA, ZBK.ZBK_ANOREF, "
	M0007 += "           ZBK.ZBK_MARCA, ZBK.ZBK_VEND, ZBK.ZBK_GRPCLI, "
	M0007 += "           ZBK.ZBK_TPSEG, ZBK.ZBK_ESTADO, ZBK.ZBK_PCTGMR, "
	M0007 += "           ZBK.ZBK_FORMAT, ZBK.ZBK_CATEG "
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
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZBK"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_NOMEVE"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SA3", 1, xFilial("SA3") + M007->ZBK_VEND, "A3_NOME")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_DGRPCL"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ACY", 1, xFilial("ACY") + M007->ZBK_GRPCLI, "ACY_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + M007->ZBK_PCTGMR, "X5_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBK_DFORMT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZZ6", 1, xFilial("ZZ6") + M007->ZBK_FORMAT, "ZZ6_DESC")

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

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZBK')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZBK->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZBK",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBK->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

				Else

					ZBK->(DbDelete())

				EndIf

				ZBK->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZBK",.T.)

					ZBK->ZBK_FILIAL  := xFilial("ZBK")
					ZBK->ZBK_VERSAO  := _cVersao
					ZBK->ZBK_REVISA  := _cRevisa
					ZBK->ZBK_ANOREF  := _cAnoRef
					ZBK->ZBK_MARCA   := _cCodMarc
					For _msc := 1 to Len(_oGetDados:aHeader)

						If _oGetDados:aHeader[_msc][10] == "R"

							nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
							&("ZBK->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

						EndIf

					Next _msc

					ZBK->(MsUnlock())

				EndIf

			EndIf

		Next

	EndIf

	_cVersao        := SPACE(TAMSX3("ZBK_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBK_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBK_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBK_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B645FOK()

	Local cMenVar     := ReadVar()
	Local vfArea      := GetArea()
	Local _cAlias
	Local _nAt		  := _oGetDados:nAt
	Local _nI
	Local _msVEND     := ""
	Local _msGRPCLI   := ""
	Local _msTPSEG    := ""
	Local _msESTADO   := ""
	Local _msPCTGMR   := ""
	Local _msFORMAT   := ""
	Local _msCATEG    := ""
	Local _msCAN005   := 0
	Local _msCAN010   := 0
	Local _msCAN015   := 0
	Local _msCAN020   := 0
	Local _msCAN025   := 0
	Local _msCAN030   := 0
	Local _msCAN035   := 0

	Do Case

		Case Alltrim(cMenVar) == "M->ZBK_VEND"
		_msVEND     := M->ZBK_VEND
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)
		GdFieldPut("ZBK_NOMEVE"   , Posicione("SA3", 1, xFilial("SA3") + M->ZBK_VEND, "A3_NOME") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_GRPCLI"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := M->ZBK_GRPCLI
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)
		GdFieldPut("ZBK_DGRPCL"   , Posicione("ACY", 1, xFilial("ACY") + M->ZBK_GRPCLI, "ACY_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_TPSEG"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := M->ZBK_TPSEG
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)

		Case Alltrim(cMenVar) == "M->ZBK_ESTADO"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := M->ZBK_ESTADO
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)

		Case Alltrim(cMenVar) == "M->ZBK_PCTGMR"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := M->ZBK_PCTGMR
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)
		GdFieldPut("ZBK_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + M->ZBK_PCTGMR, "X5_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_FORMAT"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := M->ZBK_FORMAT
		_msCATEG    := GdFieldGet("ZBK_CATEG",_nAt)
		GdFieldPut("ZBK_DFORMT"   , Posicione("ZZ6", 1, xFilial("ZZ6") + M->ZBK_FORMAT, "ZZ6_DESC") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CATEG"
		_msVEND     := GdFieldGet("ZBK_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBK_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBK_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBK_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBK_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBK_FORMAT",_nAt)
		_msCATEG    := M->ZBK_CATEG

		Case Alltrim(cMenVar) == "M->ZBK_CAN005"
		_msCAN005   := M->ZBK_CAN005
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN010"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := M->ZBK_CAN010
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN015"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := M->ZBK_CAN015
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN020"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := M->ZBK_CAN020
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN025"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := M->ZBK_CAN025
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN030"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := M->ZBK_CAN030
		_msCAN035   := GdFieldGet("ZBK_CAN035",_nAt)
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

		Case Alltrim(cMenVar) == "M->ZBK_CAN035"
		_msCAN005   := GdFieldGet("ZBK_CAN005",_nAt)
		_msCAN010   := GdFieldGet("ZBK_CAN010",_nAt)
		_msCAN015   := GdFieldGet("ZBK_CAN015",_nAt)
		_msCAN020   := GdFieldGet("ZBK_CAN020",_nAt)
		_msCAN025   := GdFieldGet("ZBK_CAN025",_nAt)
		_msCAN030   := GdFieldGet("ZBK_CAN030",_nAt)
		_msCAN035   := M->ZBK_CAN035
		_msCANTOT   := _msCAN005 + _msCAN010 + _msCAN015 + _msCAN020 + _msCAN025 + _msCAN030 + _msCAN035
		GdFieldPut("ZBK_CANTOT"   , _msCANTOT  , _nAt)

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_msVEND) .and. _msVEND == GdFieldGet("ZBK_VEND",_nI)

				If !Empty(_msGRPCLI) .and. _msGRPCLI == GdFieldGet("ZBK_GRPCLI",_nI)

					If !Empty(_msTPSEG) .and. _msTPSEG == GdFieldGet("ZBK_TPSEG",_nI)

						If !Empty(_msESTADO) .and. _msESTADO == GdFieldGet("ZBK_ESTADO",_nI)

							If !Empty(_msPCTGMR) .and. _msPCTGMR == GdFieldGet("ZBK_PCTGMR",_nI)

								If !Empty(_msFORMAT) .and. _msFORMAT == GdFieldGet("ZBK_FORMAT",_nI)

									If !Empty(_msCATEG) .and. _msCATEG == GdFieldGet("ZBK_CATEG",_nI)

										MsgInfo("Não poderá haver a mesma CHAVE informada mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a CHAVE informada!!!")
										Return .F.

									EndIf

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next

Return .T.

User Function B645DOK()

	Local _lRet	:=	.T.

Return _lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B645IEXC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 21/06/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Importação planilha Excel para Orçamento - Custo Variável  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B645IEXC()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	AADD(aSays, OemToAnsi("Rotina de importação dos percentuais de rateio nos Canais de Comercialização"))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> não é permitido importar arquivos que esteja com proteção"))   
	AADD(aSays, OemToAnsi("                 de planilha ativada!!!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Índices...'), aSays, aButtons ,,,500)

	If lConfirm

		If _msCtrlAlt

			If !empty(cArquivo) .and. File(cArquivo)

				Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)

			Else

				MsgStop('Informe o arquivo valido para importação!')

			EndIf

		Else

			MsgALERT('Versão Bloqueada para realizar atividades. Favor Verificar!!!')

		EndIf

	EndIf	

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'B645IEXC' + cEmpAnt
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
	Local cTabImp			:= 'ZBK'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local vnb, ny, _msc, nx

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_REC_WT"})
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
				nPosRec   := aScan(aCampos,{|x| AllTrim(x) == "ZBK_REC_WT"})

				ziPosVEND := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_VEND"})
				ziPosGRPC := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_GRPCLI"})
				ziPosTPSE := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_TPSEG"})
				ziPosESTA := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_ESTADO"})
				ziPosPCTG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_PCTGMR"})
				ziPosFORM := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_FORMAT"})
				ziPosCATE := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBK_CATEG"})

				PosKxVEND := aScan(aCampos,{|x| AllTrim(x) == "ZBK_VEND"})
				PosKxGRPC := aScan(aCampos,{|x| AllTrim(x) == "ZBK_GRPCLI"})
				PosKxTPSE := aScan(aCampos,{|x| AllTrim(x) == "ZBK_TPSEG"})
				PosKxESTA := aScan(aCampos,{|x| AllTrim(x) == "ZBK_ESTADO"})
				PosKxPCTG := aScan(aCampos,{|x| AllTrim(x) == "ZBK_PCTGMR"})
				PosKxFORM := aScan(aCampos,{|x| AllTrim(x) == "ZBK_FORMAT"})
				PosKxCATE := aScan(aCampos,{|x| AllTrim(x) == "ZBK_CATEG"})

				If nPosRec <> 0

					nLinReg := aScan(vtRecGrd,{|x| x == Val(Alltrim(aLinha[nPosRec]))})
					If nLinReg == 0 .or. Val(Alltrim(aLinha[nPosRec])) == 0

						nLinChave := aScan(_oGetDados:aCols,{|x| Alltrim(x[ziPosVEND]) == Alltrim(aLinha[PosKxVEND]) .and. Alltrim(x[ziPosGRPC]) == Alltrim(aLinha[PosKxGRPC]) .and. Alltrim(x[ziPosTPSE]) == Alltrim(aLinha[PosKxTPSE]) .and. Alltrim(x[ziPosESTA]) == Alltrim(aLinha[PosKxESTA]) .and. Alltrim(x[ziPosPCTG]) == Alltrim(aLinha[PosKxPCTG]) .and. Alltrim(x[ziPosFORM]) == Alltrim(aLinha[PosKxFORM]) .and. Alltrim(x[ziPosCATE]) == Alltrim(aLinha[PosKxCATE]) })
						If nLinChave <> 0

							nLinReg := nLinChave

						Else

							AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
							nLinReg := Len(_oGetDados:aCols)

						EndIf

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
¦¦¦Funçao    ¦ B645TOREV ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 13/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Converte Orçamento RECEITA do CANAL 015 para o 010/035     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B645TOREV(xxCanalTO)

	Local xgDesagio := 0

	If xxCanalTO == "010"
		xgDesagio := 0.915 //Ticket 10368

	ElseIf xxCanalTO == "035"
		xgDesagio := 0.800 //Ticket 19467

	EndIf

	If !_msCtrlAlt

		MsgALERT('Versão bloqueada para realizar esta atividade. Favor Verificar!!!')
		Return .F.

	EndIf

	KJ001 := " SELECT COUNT(*) CONTAD "
	KJ001 += "   FROM " + RetSqlName("ZBH") + " ZBH "
	KJ001 += "  WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
	KJ001 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
	KJ001 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
	KJ001 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
	KJ001 += "    AND ZBH.ZBH_PERIOD = '00' "
	KJ001 += "    AND ZBH.ZBH_ORIGF = '1' "
	KJ001 += "    AND ZBH.ZBH_TIPO2 = 'C' "
	KJ001 += "    AND ZBH.D_E_L_E_T_ = ' ' "	
	KJIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KJ001),'KJ01',.T.,.T.)
	dbSelectArea("KJ01")
	KJ01->(dbGoTop())

	If !KJ01->(Eof())

		If KJ01->CONTAD <> 0

			nxContinu := MsgYESNO("Já existes desdobramento das quantidades e valores do canal de distribuição 015 para o " + xxCanalTO + " para esta marca. Deseja continuar?")
			If nxContinu

				KJ001 := " DELETE " + RetSqlName("ZBH") + " "
				KJ001 += "   FROM " + RetSqlName("ZBH") + " ZBH "
				KJ001 += "  WHERE ZBH.ZBH_VERSAO = '" + _cVersao + "' "
				KJ001 += "    AND ZBH.ZBH_REVISA = '" + _cRevisa + "' "
				KJ001 += "    AND ZBH.ZBH_ANOREF = '" + _cAnoRef + "' "
				KJ001 += "    AND ZBH.ZBH_MARCA = '" + _cCodMarc + "' "
				KJ001 += "    AND ZBH.ZBH_PERIOD = '00' "
				KJ001 += "    AND ZBH.ZBH_ORIGF = '1' "
				KJ001 += "    AND ZBH.ZBH_TIPO2 = 'C' "
				KJ001 += "    AND ZBH.D_E_L_E_T_ = ' ' "
				U_BIAMsgRun("Aguarde... Apagando registros ZBA... ",,{|| TcSQLExec(KJ001) })

			Else

				MsgALERT('Processo abortado. Necessário verificar, pois alguns dados do orçamento poderão ficar comprometidos!!!')
				Return .F.

			EndIf

		EndIf

	EndIf

	KJ01->(dbCloseArea())
	Ferase(KJIndex+GetDBExtension())
	Ferase(KJIndex+OrdBagExt())

	BH004 := " WITH RECINTEG AS (SELECT ZBH_FILIAL, "
	BH004 += "                          ZBH_VERSAO, "
	BH004 += "                          ZBH_REVISA, "
	BH004 += "                          ZBH_ANOREF, "
	BH004 += "                          ZBH_PERIOD, "
	BH004 += "                          ZBH_MARCA, "
	BH004 += "                          'NA' ZBH_CANALD, "
	BH004 += "                          '999999' ZBH_VEND, "
	BH004 += "                          'G-001307' ZBH_GRPCLI, "
	BH004 += "                          'R' ZBH_TPSEG, "
	BH004 += "                          'ES' ZBH_ESTADO, "
	BH004 += "                          ZBH_PCTGMR, "
	BH004 += "                          ZBH_FORMAT, "
	BH004 += "                          ZBH_CATEG, "
	BH004 += "                          ZBH_ORIGF, "
	BH004 += "                          'C' ZBH_TIPO2, "
	BH004 += "                          ZBH_QUANT, "
	BH004 += "                          ZBH_VALOR "
	BH004 += "                     FROM " + RetSqlName("ZBH") + " ZBH "
	BH004 += "                    WHERE ZBH_VERSAO = '" + _cVersao + "' "
	BH004 += "                      AND ZBH_REVISA = '" + _cRevisa + "' "
	BH004 += "                      AND ZBH_ANOREF = '" + _cAnoRef + "' "
	BH004 += "                      AND ZBH_MARCA = '" + _cCodMarc + "' "
	BH004 += "                      AND ZBH_PERIOD = '00' "
	BH004 += "                      AND ZBH_ORIGF = '1' "
	BH004 += "                      AND EXISTS (SELECT * "
	BH004 += "                                    FROM " + RetSqlName("ZBK") + " XZBK "
	BH004 += "                                   WHERE XZBK.ZBK_FILIAL = ZBH.ZBH_FILIAL "
	BH004 += "                                     AND XZBK.ZBK_VERSAO = ZBH.ZBH_VERSAO "
	BH004 += "                                     AND XZBK.ZBK_REVISA = ZBH.ZBH_REVISA "
	BH004 += "                                     AND XZBK.ZBK_ANOREF = ZBH.ZBH_ANOREF "
	BH004 += "                                     AND XZBK.ZBK_MARCA = ZBH.ZBH_MARCA "
	BH004 += "                                     AND XZBK.ZBK_VEND = ZBH.ZBH_VEND "
	BH004 += "                                     AND XZBK.ZBK_GRPCLI = ZBH.ZBH_GRPCLI "
	BH004 += "                                     AND XZBK.ZBK_TPSEG = ZBH.ZBH_TPSEG "
	BH004 += "                                     AND XZBK.ZBK_ESTADO = ZBH.ZBH_ESTADO "
	BH004 += "                                     AND XZBK.ZBK_PCTGMR = ZBH.ZBH_PCTGMR "
	BH004 += "                                     AND XZBK.ZBK_FORMAT = ZBH.ZBH_FORMAT "
	BH004 += "                                     AND XZBK.ZBK_CATEG = ZBH.ZBH_CATEG "
	BH004 += "                                     AND XZBK.ZBK_CAN015 <> 0 "
	BH004 += "                                     AND XZBK.D_E_L_E_T_ = ' ') "
	BH004 += "                      AND ZBH.D_E_L_E_T_ = ' ') "
	BH004 += " SELECT ZBH_FILIAL, "
	BH004 += "        ZBH_VERSAO, "
	BH004 += "        ZBH_REVISA, "
	BH004 += "        ZBH_ANOREF, "
	BH004 += "        ZBH_PERIOD, "
	BH004 += "        ZBH_MARCA, "
	BH004 += "        ZBH_CANALD, "
	BH004 += "        ZBH_VEND, "
	BH004 += "        ZBH_GRPCLI, "
	BH004 += "        ZBH_TPSEG, "
	BH004 += "        ZBH_ESTADO, "
	BH004 += "        ZBH_PCTGMR, "
	BH004 += "        ZBH_FORMAT, "
	BH004 += "        ZBH_CATEG, "
	BH004 += "        ZBH_ORIGF, "
	BH004 += "        ZBH_TIPO2, "
	BH004 += "        SUM(ZBH_QUANT) ZBH_QUANT, "
	BH004 += "        SUM(ZBH_QUANT * ZBH_VALOR * " + Alltrim(Str(xgDesagio)) + ") ZBH_TOTAL "
	BH004 += "   FROM RECINTEG RITG "
	BH004 += "  GROUP BY ZBH_FILIAL, "
	BH004 += "           ZBH_VERSAO, "
	BH004 += "           ZBH_REVISA, "
	BH004 += "           ZBH_ANOREF, "
	BH004 += "           ZBH_PERIOD, "
	BH004 += "           ZBH_MARCA, "
	BH004 += "           ZBH_CANALD, "
	BH004 += "           ZBH_VEND, "
	BH004 += "           ZBH_GRPCLI, "
	BH004 += "           ZBH_TPSEG, "
	BH004 += "           ZBH_ESTADO, "
	BH004 += "           ZBH_PCTGMR, "
	BH004 += "           ZBH_FORMAT, "
	BH004 += "           ZBH_CATEG, "
	BH004 += "           ZBH_ORIGF, "
	BH004 += "           ZBH_TIPO2 "	
	BHIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,BH004),'BH04',.T.,.T.)
	dbSelectArea("BH04")
	BH04->(dbGoTop())
	While !BH04->(Eof())

		RecLock("ZBH", .T.)
		ZBH->ZBH_FILIAL  := BH04->ZBH_FILIAL
		ZBH->ZBH_VERSAO  := BH04->ZBH_VERSAO
		ZBH->ZBH_REVISA  := BH04->ZBH_REVISA
		ZBH->ZBH_ANOREF  := BH04->ZBH_ANOREF
		ZBH->ZBH_PERIOD  := BH04->ZBH_PERIOD 
		ZBH->ZBH_MARCA   := BH04->ZBH_MARCA 
		ZBH->ZBH_CANALD  := BH04->ZBH_CANALD
		ZBH->ZBH_VEND    := BH04->ZBH_VEND  
		ZBH->ZBH_GRPCLI  := BH04->ZBH_GRPCLI
		ZBH->ZBH_TPSEG   := BH04->ZBH_TPSEG 
		ZBH->ZBH_ESTADO  := BH04->ZBH_ESTADO
		ZBH->ZBH_PCTGMR  := BH04->ZBH_PCTGMR
		ZBH->ZBH_FORMAT  := BH04->ZBH_FORMAT
		ZBH->ZBH_CATEG   := BH04->ZBH_CATEG 
		ZBH->ZBH_QUANT   := BH04->ZBH_QUANT
		ZBH->ZBH_VALOR   := BH04->ZBH_TOTAL / BH04->ZBH_QUANT 
		ZBH->ZBH_TOTAL   := BH04->ZBH_TOTAL
		ZBH->ZBH_ORIGF   := "1"
		ZBH->ZBH_TIPO2   := "C"       
		ZBH->ZBH_USER    := __cUserId
		ZBH->ZBH_DTPROC  := Date()
		ZBH->ZBH_HRPROC  := Time()
		MsUnlockAll()

		BH04->(dbSkip())
	End
	BH04->(dbCloseArea())
	Ferase(BHIndex+GetDBExtension())
	Ferase(BHIndex+OrdBagExt())

	MsgINFO( "Fim do Processamento.... ")

	_cVersao        := SPACE(TAMSX3("ZBK_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBK_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBK_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBK_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgINFO( "Ah! tem mais uma coisa... é necessário entrar novamente da tela e informar os percentuais de distribuição pelo canal " + xxCanalTO + ". Obrigado!!!")

Return
