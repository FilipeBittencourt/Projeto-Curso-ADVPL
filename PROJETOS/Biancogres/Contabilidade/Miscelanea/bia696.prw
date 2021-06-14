#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA696
@author Marcos Alberto Soprani
@since 08/06/21
@version 1.0
@description Forecast de Volume de Produção e Vendas
@type function
/*/

User Function BIA696()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZOI") + SPACE(TAMSX3("ZOI_VERSAO")[1]) + SPACE(TAMSX3("ZOI_REVISA")[1]) + SPACE(TAMSX3("ZOI_ANOREF")[1])
	Local bWhile	    := {|| ZOI_FILIAL + ZOI_VERSAO + ZOI_REVISA + ZOI_ANOREF }   

	Local aNoFields     := {"ZOI_VERSAO", "ZOI_REVISA", "ZOI_ANOREF"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private msrhEnter   := CHR(13) + CHR(10)

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cVersao	:= SPACE(TAMSX3("ZOI_VERSAO")[1])
	Private _oGVersao
	Private _cRevisa	:= SPACE(TAMSX3("ZOI_REVISA")[1])
	Private _oGRevisa
	Private _cAnoRef	:= SPACE(TAMSX3("ZOI_ANOREF")[1])
	Private _oGAnoRef

	aAdd(_aButtons,{"PRODUTO" ,{|| U_BIA393("E")}, "Layout Integração" , "Layout Integração"})
	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B696IEXC() }, "Importa Arquivo"   , "Importa Arquivo"})

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZOI",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Forecast Vol. Produção / Vendas" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Versão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGVersao VAR _cVersao Picture "@!" F3 "ZB5" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA696A()

	@ 050,110 SAY "Revisão:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGRevisa VAR _cRevisa  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA696B()

	@ 050,210 SAY "AnoRef:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,250 MSGET _oGAnoRef VAR _cAnoRef  SIZE 50, 11 OF _oDlg PIXEL VALID fBIA696C()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, "U_B696LOK()" /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 99999 /*[ nMax]*/, "U_B696FOK()" /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA696A()

	If Empty(_cVersao)
		MsgInfo("O preenchimento do campo Versão é Obrigatório!!!")
		Return .F.
	EndIf
	_cRevisa := ZB5->ZB5_REVISA
	_cAnoRef := ZB5->ZB5_ANOREF
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA696D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA696B()

	If Empty(_cRevisa)
		MsgInfo("O preenchimento do campo Revisão é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA696D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA696C()

	If Empty(_cAnoRef)
		MsgInfo("O preenchimento do campo Ano é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cVersao) .and. !Empty(_cRevisa) .and. !Empty(_cAnoRef)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || cMsg := fBIA696D() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return

Static Function fBIA696D()

	Local _cAlias   := GetNextAlias()
	Local _msc

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	_oGetDados:lInsert := .T.
	_oGetDados:lUpdate := .T.
	_oGetDados:lDelete := .T.

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *,
		(SELECT COUNT(*)
		FROM %TABLE:ZOI% ZOI
		WHERE ZOI_FILIAL = %xFilial:ZOI%
		AND ZOI_VERSAO = %Exp:_cVersao%
		AND ZOI_REVISA = %Exp:_cRevisa%
		AND ZOI_ANOREF = %Exp:_cAnoRef%
		AND ZOI.%NotDel%
		) NUMREG
		FROM %TABLE:ZOI% ZOI
		WHERE ZOI_FILIAL = %xFilial:ZOI%
		AND ZOI_VERSAO = %Exp:_cVersao%
		AND ZOI_REVISA = %Exp:_cRevisa%
		AND ZOI_ANOREF = %Exp:_cAnoRef%
		AND ZOI.%NotDel%
		ORDER BY ZOI_VERSAO, ZOI_REVISA, ZOI_ANOREF, ZOI_PRODUT
	EndSql

	xtrTot :=  (_cAlias)->(NUMREG)
	ProcRegua(xtrTot)

	(_cAlias)->(dbGoTop())
	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(xtrTot)))

			AADD(_oGetDados:aCols, Array(Len(_oGetDados:aHeader)+1) )
			For _msc := 1 to Len(_oGetDados:aHeader)
				If Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOI_ALI_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := "ZOI"

				ElseIf Alltrim(_oGetDados:aHeader[_msc][2]) == "ZOI_REC_WT"
					_oGetDados:aCols[Len(_oGetDados:aCols), _msc] := R_E_C_N_O_

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
	Local _msc

	Local nPosRec := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZOI_REC_WT"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZOI')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZOI->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZOI",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZOI->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

			Else

				ZOI->(DbDelete())

			EndIf

			ZOI->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZOI",.T.)

				ZOI->ZOI_FILIAL  := xFilial("ZOI")
				ZOI->ZOI_VERSAO  := _cVersao
				ZOI->ZOI_REVISA  := _cRevisa
				ZOI->ZOI_ANOREF  := _cAnoRef
				For _msc := 1 to Len(_oGetDados:aHeader)

					If _oGetDados:aHeader[_msc][10] == "R"

						nPosColG := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == Alltrim(_oGetDados:aHeader[_msc][2])})
						&("ZOI->" + Alltrim(_oGetDados:aHeader[_msc][2])) := _oGetDados:aCols[_nI, nPosColG]

					EndIf

				Next _msc

				ZOI->(MsUnlock())

			EndIf

		EndIf

	Next

	_cVersao        := SPACE(TAMSX3("ZOI_VERSAO")[1])
	_cRevisa        := SPACE(TAMSX3("ZOI_REVISA")[1])
	_cAnoRef        := SPACE(TAMSX3("ZOI_ANOREF")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGVersao:SetFocus()
	_oGVersao:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B696FOK()

	Local cMenVar    := ReadVar()
	Local _zpPRODUT  := ""
	Local _nAt       := _oGetDados:nAt

	Do Case

		Case Alltrim(cMenVar) == "M->ZOI_PRODUT"
		_zpPRODUT   := M->ZOI_PRODUT
		If !ExistCPO("SB1")
			Return .F.
		EndIf
		If Posicione("SB1", 1, xFilial("SB1") + _zpPRODUT, "B1_TIPO") <> "PA"
			MsgInfo("Somente produtos do TIPO = PA podem ser utilizados. Favor verificar!!!")
			Return .F.
		EndIf
		Gdfieldput("ZOI_DESCRI", Posicione("SB1", 1, xFilial("SB1") + _zpPRODUT, "B1_DESC"), _nAt)

	EndCase

Return .T.

User Function B696LOK()

	Local _nI
	Local _lRet	     := .T.
	Local _nAt       := _oGetDados:nAt
	Local _zpVERCON  := GdFieldGet("ZOI_VERCON",_nAt)
	Local _zpPRDVEN  := GdFieldGet("ZOI_PRDVEN",_nAt)
	Local _zpPRODUT  := GdFieldGet("ZOI_PRODUT",_nAt)

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If _zpVERCON + _zpPRDVEN + _zpPRODUT == GdFieldGet("ZOI_VERCON",_nI) + GdFieldGet("ZOI_PRDVEN",_nI) + GdFieldGet("ZOI_PRODUT",_nI) 

				MsgInfo("A chave informada nesta linha só pode existir uma única vez. " + msrhEnter + msrhEnter + "Na linha: " + Alltrim(Str(_nI)) + " já existe esta chave informada!!!")
				_lRet := .F.

			EndIf

		EndIf

	Next

Return _lRet
