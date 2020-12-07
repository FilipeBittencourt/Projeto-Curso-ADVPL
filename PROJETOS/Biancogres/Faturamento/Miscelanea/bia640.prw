#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA640
@author Marcos Alberto Soprani
@since 28/09/17
@version 1.0
@description Tela para Consulta da importação dos dados da RECEITA Integration para Orçamento 
@type function
/*/

User Function BIA640()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBH") + SPACE(TAMSX3("ZBH_VERSAO")[1]) + SPACE(TAMSX3("ZBH_REVISA")[1]) + SPACE(TAMSX3("ZBH_ANOREF")[1]) + SPACE(TAMSX3("ZBH_MARCA")[1])
	Local bWhile	    := {|| ZBH_FILIAL + ZBH_VERSAO + ZBH_REVISA + ZBH_ANOREF + ZBH_MARCA }                    
	Local aNoFields     := {"ZBH_VERSAO", "ZBH_REVISA", "ZBH_ANOREF", "ZBH_MARCA", "ZBH_PERIOD", "ZBH_CANALD", "ZBH_USER", "ZBH_DTPROC", "ZBH_HRPROC", "ZBH_PCOMIS", "ZBH_VCOMIS",;
	"ZBH_PICMS", "ZBH_VICMS", "ZBH_PPIS", "ZBH_VPIS", "ZBH_PCOF", "ZBH_VCOF", "ZBH_PST", "ZBH_VST", "ZBH_PDIFAL", "ZBH_VDIFAL", "ZBH_ORIGF",;
	"ZBH_PRZMET","ZBH_METVER","ZBH_PERVER","ZBH_PERBON","ZBH_VALVER","ZBH_VALBON","ZBH_PERCPV","ZBH_VALCPV","ZBH_PICMBO","ZBH_VICMBO"}

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
	Private _mNomeMarc   := SPACE(50) 

	aAdd(_aButtons,{"HISTORIC",{|| U_BIA393("A")}, "Exporta p/Excel", "Exporta p/Excel"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBH",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Receita Integration p/ Orçamento" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA640A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA640B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA640C()

	@ 050,310 SAY "MARCA:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,350 MSGET _oGCodMarca VAR _cCodMarc F3("Z37") SIZE 50, 11 OF _oDlg PIXEL VALID fBIA640D()
	@ 050,410 SAY _mNomeMarc SIZE 250, 11 OF _oDlg PIXEL FONT oFont

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B640FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B640DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA640A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA640D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA640B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA640D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA640C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef) .and. !Empty(_cCodMarc)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA640D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA640D()

	Local _cAlias   := GetNextAlias()
	Local _msc

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef) .or. Empty(_cCodMarc)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_mNomeMarc := Posicione("Z37", 1, xFilial("Z37") + _cCodMarc, "Z37_DESCR")

	_oGetDados:lInsert := .F.
	_oGetDados:lUpdate := .F.
	_oGetDados:lDelete := .F.

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBH% ZBH
		WHERE ZBH_FILIAL = %xFilial:ZBH%
		AND ZBH_VERSAO = %Exp:_cVersao%
		AND ZBH_REVISA = %Exp:_cRevisa%
		AND ZBH_ANOREF = %Exp:_cAnoRef%
		AND ZBH_MARCA = %Exp:_cCodMarc%
		AND ZBH_PERIOD = '00'
		AND ZBH_ORIGF = '1'
		AND ZBH.%NotDel%
		ORDER BY ZBH_VEND, ZBH_GRPCLI, ZBH_TPSEG, ZBH_ESTADO, ZBH_PCTGMR, ZBH_FORMAT, ZBH_CATEG 
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

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_NOMEVE"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SA3", 1, xFilial("SA3") + (_cAlias)->ZBH_VEND, "A3_NOME")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_DGRPCI"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ACY", 1, xFilial("ACY") + (_cAlias)->ZBH_GRPCLI, "ACY_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_DPCTGM"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("SX5", 1, xFilial("SX5") + "ZH" + (_cAlias)->ZBH_PCTGMR, "X5_DESCRI")

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZBH_DFORMT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := Posicione("ZZ6", 1, xFilial("ZZ6") + (_cAlias)->ZBH_FORMAT, "ZZ6_DESC")

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

	Local _nI

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBH_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	_cVersao        := SPACE(TAMSX3("ZBH_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBH_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBH_ANOREF")[1])
	_cCodMarc       := SPACE(TAMSX3("ZBH_MARCA")[1])
	_mNomeMarc      := SPACE(50)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

Return

User Function B640FOK()

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
	Local _msQUANT    := 0
	Local _msVALOR    := 0

	Do Case

		Case Alltrim(cMenVar) == "M->ZBH_VEND"
		_msVEND     := M->ZBH_VEND
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_NOMEVE"   , Posicione("SA3", 1, xFilial("SA3") + M->ZBH_VEND, "A3_NOME") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_GRPCLI"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := M->ZBH_GRPCLI
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_DGRPCI"   , Posicione("ACY", 1, xFilial("ACY") + M->ZBH_GRPCLI, "ACY_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_TPSEG"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := M->ZBH_TPSEG
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)

		Case Alltrim(cMenVar) == "M->ZBH_ESTADO"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := M->ZBH_ESTADO
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)

		Case Alltrim(cMenVar) == "M->ZBH_PCTGMR"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := M->ZBH_PCTGMR
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_DPCTGM"   , Posicione("SX5", 1, xFilial("SX5") + "ZH" + M->ZBH_PCTGMR, "X5_DESCRI") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_FORMAT"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := M->ZBH_FORMAT
		_msCATEG    := GdFieldGet("ZBH_CATEG",_nAt)
		GdFieldPut("ZBH_DFORMT"   , Posicione("ZZ6", 1, xFilial("ZZ6") + M->ZBH_FORMAT, "ZZ6_DESC") , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_CATEG"
		_msVEND     := GdFieldGet("ZBH_VEND",_nAt)
		_msGRPCLI   := GdFieldGet("ZBH_GRPCLI",_nAt)
		_msTPSEG    := GdFieldGet("ZBH_TPSEG",_nAt)
		_msESTADO   := GdFieldGet("ZBH_ESTADO",_nAt)
		_msPCTGMR   := GdFieldGet("ZBH_PCTGMR",_nAt)
		_msFORMAT   := GdFieldGet("ZBH_FORMAT",_nAt)
		_msCATEG    := M->ZBH_CATEG

		Case Alltrim(cMenVar) == "M->ZBH_QUANT"
		_msQUANT    := M->ZBH_QUANT
		_msVALOR    := GdFieldGet("ZBH_VALOR",_nAt)
		GdFieldPut("ZBH_TOTAL"   , _msQUANT * _msVALOR , _nAt)

		Case Alltrim(cMenVar) == "M->ZBH_VALOR"
		_msQUANT    := GdFieldGet("ZBH_QUANT",_nAt)
		_msVALOR    := M->ZBH_VALOR
		GdFieldPut("ZBH_TOTAL"   , _msQUANT * _msVALOR , _nAt)

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_msVEND) .and. _msVEND == GdFieldGet("ZBH_VEND",_nI)

				If !Empty(_msGRPCLI) .and. _msGRPCLI == GdFieldGet("ZBH_GRPCLI",_nI)

					If !Empty(_msTPSEG) .and. _msTPSEG == GdFieldGet("ZBH_TPSEG",_nI)

						If !Empty(_msESTADO) .and. _msESTADO == GdFieldGet("ZBH_ESTADO",_nI)

							If !Empty(_msPCTGMR) .and. _msPCTGMR == GdFieldGet("ZBH_PCTGMR",_nI)

								If !Empty(_msFORMAT) .and. _msFORMAT == GdFieldGet("ZBH_FORMAT",_nI)

									If !Empty(_msCATEG) .and. _msCATEG == GdFieldGet("ZBH_CATEG",_nI)

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

User Function B640DOK()

	Local _lRet	:=	.T.

	// Incluir neste ponto o controle de deleção para os casos em que já existir registro de orçamento associado, será necessário primeiro retirar de lá

Return _lRet
