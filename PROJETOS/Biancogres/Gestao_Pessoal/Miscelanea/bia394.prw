#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA394
@author Marcos Alberto Soprani
@since 25/09/17
@version 1.0
@description Tela para cadastro dos Reajustes Anuais Previstos em orçamento 
@type function
/*/

User Function BIA394()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBB") + SPACE(TAMSX3("ZBB_VERSAO")[1]) + SPACE(TAMSX3("ZBB_REVISA")[1]) + SPACE(TAMSX3("ZBB_ANOREF")[1])
	Local bWhile	    := {|| ZBB_FILIAL + ZBB_VERSAO + ZBB_REVISA + ZBB_ANOREF }                    
	Local aNoFields     := {"ZBB_VERSAO", "ZBB_REVISA", "ZBB_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZBB_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZBB_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZBB_ANOREF")[1])
	Private _oGAnoRef

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBB",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Reajustes Anuais Previstos" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA394A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA394B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA394C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B394FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B394DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA394A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA394C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA394B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA394C() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA394C()

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
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZBB% ZBB
	WHERE ZBB_FILIAL = %xFilial:ZBB%
	AND ZBB_VERSAO = %Exp:_cVersao%
	AND ZBB_REVISA = %Exp:_cRevisa%
	AND ZBB_ANOREF = %Exp:_cAnoRef%
	AND ZBB.%NotDel%
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZBB_RUBRIC,;
			ZBB_DRUBRI,;
			ZBB_M01,;
			ZBB_M02,;
			ZBB_M03,;
			ZBB_M04,;
			ZBB_M05,;
			ZBB_M06,;
			ZBB_M07,;
			ZBB_M08,;
			ZBB_M09,;
			ZBB_M10,;
			ZBB_M11,;
			ZBB_M12,;
			"ZBB",;
			R_E_C_N_O_,;
			.F.	}))

			(_cAlias)->(dbSkip())

		EndDo

		(_cAlias)->(dbCloseArea())

	Else

		aAdd(_oGetDados:aCols, {"ZBA_SALARI", "Salario     ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_CALIME", "$ C.Alimenta", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_CJTURN", "$ C.J.Turno ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_CJNOIT", "$ C.J.Noites", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_CCOMBU", "$ C.Combusti", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_PLSMED", "$ Pls Saude ", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })
		aAdd(_oGetDados:aCols, {"ZBA_PLSODO", "$ Pls Odonto", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "ZBB", 0, .F. })

	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_REC_WT"})
	Local xmyRUBR := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_RUBRIC"})
	Local xmyDRUB := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_DRUBRI"})
	Local xmyM01  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M01"})
	Local xmyM02  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M02"})
	Local xmyM03  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M03"})
	Local xmyM04  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M04"})
	Local xmyM05  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M05"})
	Local xmyM06  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M06"})
	Local xmyM07  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M07"})
	Local xmyM08  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M08"})
	Local xmyM09  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M09"})
	Local xmyM10  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M10"})
	Local xmyM11  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M11"})
	Local xmyM12  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBB_M12"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZBB')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBB->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBB",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZBB->ZBB_RUBRIC  := _oGetDados:aCols[_nI,xmyRUBR]
				ZBB->ZBB_DRUBRI  := _oGetDados:aCols[_nI,xmyDRUB]
				ZBB->ZBB_M01     := _oGetDados:aCols[_nI,xmyM01]
				ZBB->ZBB_M02     := _oGetDados:aCols[_nI,xmyM02]
				ZBB->ZBB_M03     := _oGetDados:aCols[_nI,xmyM03]
				ZBB->ZBB_M04     := _oGetDados:aCols[_nI,xmyM04]
				ZBB->ZBB_M05     := _oGetDados:aCols[_nI,xmyM05]
				ZBB->ZBB_M06     := _oGetDados:aCols[_nI,xmyM06]
				ZBB->ZBB_M07     := _oGetDados:aCols[_nI,xmyM07]
				ZBB->ZBB_M08     := _oGetDados:aCols[_nI,xmyM08]
				ZBB->ZBB_M09     := _oGetDados:aCols[_nI,xmyM09]
				ZBB->ZBB_M10     := _oGetDados:aCols[_nI,xmyM10]
				ZBB->ZBB_M11     := _oGetDados:aCols[_nI,xmyM11]
				ZBB->ZBB_M12     := _oGetDados:aCols[_nI,xmyM12]

			Else

				ZBB->(DbDelete())

			EndIf

			ZBB->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZBB",.T.)
				ZBB->ZBB_FILIAL  := xFilial("ZBB")
				ZBB->ZBB_VERSAO  := _cVersao
				ZBB->ZBB_REVISA  := _cRevisa
				ZBB->ZBB_ANOREF  := _cAnoRef
				ZBB->ZBB_RUBRIC  := _oGetDados:aCols[_nI,xmyRUBR]
				ZBB->ZBB_DRUBRI  := _oGetDados:aCols[_nI,xmyDRUB]
				ZBB->ZBB_M01     := _oGetDados:aCols[_nI,xmyM01]
				ZBB->ZBB_M02     := _oGetDados:aCols[_nI,xmyM02]
				ZBB->ZBB_M03     := _oGetDados:aCols[_nI,xmyM03]
				ZBB->ZBB_M04     := _oGetDados:aCols[_nI,xmyM04]
				ZBB->ZBB_M05     := _oGetDados:aCols[_nI,xmyM05]
				ZBB->ZBB_M06     := _oGetDados:aCols[_nI,xmyM06]
				ZBB->ZBB_M07     := _oGetDados:aCols[_nI,xmyM07]
				ZBB->ZBB_M08     := _oGetDados:aCols[_nI,xmyM08]
				ZBB->ZBB_M09     := _oGetDados:aCols[_nI,xmyM09]
				ZBB->ZBB_M10     := _oGetDados:aCols[_nI,xmyM10]
				ZBB->ZBB_M11     := _oGetDados:aCols[_nI,xmyM11]
				ZBB->ZBB_M12     := _oGetDados:aCols[_nI,xmyM12]
				ZBB->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("ZBB_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZBB_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZBB_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B394FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
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

	Do Case

		Case Alltrim(cMenVar) == "M->ZBB_M01"
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := _mqM02 := _mqM01 := M->ZBB_M01

		Case Alltrim(cMenVar) == "M->ZBB_M02"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		If M->ZBB_M02 < _mqM01
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := _mqM02 := M->ZBB_M02

		Case Alltrim(cMenVar) == "M->ZBB_M03"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		If M->ZBB_M03 < _mqM02
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := _mqM03 := M->ZBB_M03

		Case Alltrim(cMenVar) == "M->ZBB_M04"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		If M->ZBB_M04 < _mqM03
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := _mqM04 := M->ZBB_M04

		Case Alltrim(cMenVar) == "M->ZBB_M05"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		If M->ZBB_M05 < _mqM04
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := _mqM05 := M->ZBB_M05

		Case Alltrim(cMenVar) == "M->ZBB_M06"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		If M->ZBB_M06 < _mqM05
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := _mqM06 := M->ZBB_M06

		Case Alltrim(cMenVar) == "M->ZBB_M07"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		If M->ZBB_M07 < _mqM06
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := _mqM07 := M->ZBB_M07

		Case Alltrim(cMenVar) == "M->ZBB_M08"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		_mqM07 := GdFieldGet("ZBB_M07",_nAt)
		If M->ZBB_M08 < _mqM07
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := _mqM08 := M->ZBB_M08

		Case Alltrim(cMenVar) == "M->ZBB_M09"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		_mqM07 := GdFieldGet("ZBB_M07",_nAt)
		_mqM08 := GdFieldGet("ZBB_M08",_nAt)
		If M->ZBB_M09 < _mqM08
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10 := _mqM09 := M->ZBB_M09

		Case Alltrim(cMenVar) == "M->ZBB_M10"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		_mqM07 := GdFieldGet("ZBB_M07",_nAt)
		_mqM08 := GdFieldGet("ZBB_M08",_nAt)
		_mqM09 := GdFieldGet("ZBB_M09",_nAt)
		If M->ZBB_M10 < _mqM09
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11 := _mqM10:= M->ZBB_M10

		Case Alltrim(cMenVar) == "M->ZBB_M11"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		_mqM07 := GdFieldGet("ZBB_M07",_nAt)
		_mqM08 := GdFieldGet("ZBB_M08",_nAt)
		_mqM09 := GdFieldGet("ZBB_M09",_nAt)
		_mqM10 := GdFieldGet("ZBB_M10",_nAt)
		If M->ZBB_M11 < _mqM10
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12 := _mqM11:= M->ZBB_M11

		Case Alltrim(cMenVar) == "M->ZBB_M12"
		_mqM01 := GdFieldGet("ZBB_M01",_nAt)
		_mqM02 := GdFieldGet("ZBB_M02",_nAt)
		_mqM03 := GdFieldGet("ZBB_M03",_nAt)
		_mqM04 := GdFieldGet("ZBB_M04",_nAt)
		_mqM05 := GdFieldGet("ZBB_M05",_nAt)
		_mqM06 := GdFieldGet("ZBB_M06",_nAt)
		_mqM07 := GdFieldGet("ZBB_M07",_nAt)
		_mqM08 := GdFieldGet("ZBB_M08",_nAt)
		_mqM09 := GdFieldGet("ZBB_M09",_nAt)
		_mqM10 := GdFieldGet("ZBB_M10",_nAt)
		_mqM11 := GdFieldGet("ZBB_M11",_nAt)
		If M->ZBB_M12 < _mqM11
			MsgINFO("Não é permitido informar valor menor que aquele informado anteriormente!!!")
			Return .F.
		EndIf
		_mqM12:= M->ZBB_M12

	EndCase

	GdFieldPut("ZBB_M01"   , _mqM01 , _nAt)
	GdFieldPut("ZBB_M02"   , _mqM02 , _nAt)
	GdFieldPut("ZBB_M03"   , _mqM03 , _nAt)
	GdFieldPut("ZBB_M04"   , _mqM04 , _nAt)
	GdFieldPut("ZBB_M05"   , _mqM05 , _nAt)
	GdFieldPut("ZBB_M06"   , _mqM06 , _nAt)
	GdFieldPut("ZBB_M07"   , _mqM07 , _nAt)
	GdFieldPut("ZBB_M08"   , _mqM08 , _nAt)
	GdFieldPut("ZBB_M09"   , _mqM09 , _nAt)
	GdFieldPut("ZBB_M10"   , _mqM10 , _nAt)
	GdFieldPut("ZBB_M11"   , _mqM11 , _nAt)
	GdFieldPut("ZBB_M12"   , _mqM12 , _nAt)

Return .T.

User Function B394DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
