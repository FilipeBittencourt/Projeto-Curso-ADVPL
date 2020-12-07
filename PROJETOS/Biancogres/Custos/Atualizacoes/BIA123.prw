#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA123
@author Marcos Alberto Soprani
@since 13/09/17
@version 1.0
@description Tela para cadastro de Roteiro de Fabricação para Custo
@type function
/*/

User Function BIA123()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZCV") + SPACE(TAMSX3("ZCV_DTREF")[1]) + SPACE(TAMSX3("ZCV_TPPROD")[1])
	Local bWhile	    := {|| ZCV_FILIAL + ZCV_DTREF + ZCV_TPPROD}                    
	Local aNoFields     := {"ZCV_DTREF", "ZCV_TPPROD"}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cDtRef 	:= ctod('')
	Private _oGDtRef 
	Private _cTpProd	:= SPACE(TAMSX3("ZCV_TPPROD")[1])
	Private _oGTpProd

	Private _msCtrlAlt := .F.

	aAdd(_aButtons,{"PEDIDO"  ,{|| U_B123CTAS()} , "Replica Roteiro"   , "Replica Roteiro"})

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZCV",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Roteiro de Fabricação para Custo" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Data Ref:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,050 MSGET _oGDtRef VAR _cDtRef Picture "@!" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA123A()

	@ 050,110 SAY "Tipo Prod:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,150 MSGET _oGTpProd VAR _cTpProd Picture "@!" F3 "02" SIZE 50, 11 OF _oDlg PIXEL VALID fBIA123B()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/,  /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA123A()

	If Empty(_cDtRef)
		MsgInfo("O preenchimento do campo Data Ref é Obrigatório!!!")
		Return .F.
	EndIf
	If !Empty(_cDtRef) .and. !Empty(_cTpProd)
		_oGetDados:oBrowse:SetFocus()
		Processa({ || fBIA123B() }, "Aguarde...", "Carregando dados...",.F.)
	EndIf

Return .T.

Static Function fBIA123B()

	Local _cAlias   := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Empty(_cDtRef) .or. Empty(_cTpProd)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	If !Alltrim(_cTpProd) $ "PA/PP" 
		MsgInfo("Somente é permitido informar os tipos PA/PP!!!")
		Return .F.
	EndIf

	If _cDtRef <= GetMV("MV_ULMES")
		MsgSTOP("Favor verificar a data informada, pois está fora do período de fechamento de estoque.", "BIA123 - Data de Fechamento!!!")
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

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZCV% ZCV
		WHERE ZCV_FILIAL = %xFilial:ZCV%
		AND ZCV_DTREF = %Exp:_cDtRef%
		AND ZCV_TPPROD = %Exp:_cTpProd%
		AND ZCV.%NotDel%

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZCV_CLVL,;
			ZCV_FORMAT,;
			ZCV_APPROD,;
			ZCV_EXPROD,;
			"ZCV",;
			R_E_C_N_O_,;
			.F.	}))

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

	Local nPosRec   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_REC_WT"})
	Local _msCLVL   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_CLVL"})
	Local _msFORMAT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_FORMAT"})
	Local _msAPPROD := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_APPROD"})
	Local _msEXPROD := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_EXPROD"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	If _msCtrlAlt

		dbSelectArea('ZCV')
		For _nI	:=	1 to Len(_oGetDados:aCols)

			If _oGetDados:aCols[_nI,nPosRec] > 0

				ZCV->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
				Reclock("ZCV",.F.)
				If !_oGetDados:aCols[_nI,nPosDel]

					ZCV->ZCV_CLVL   := _oGetDados:aCols[_nI,_msCLVL]
					ZCV->ZCV_FORMAT := _oGetDados:aCols[_nI,_msFORMAT]
					ZCV->ZCV_APPROD := _oGetDados:aCols[_nI,_msAPPROD]
					ZCV->ZCV_EXPROD := _oGetDados:aCols[_nI,_msEXPROD]

				Else

					ZCV->(DbDelete())

				EndIf

				ZCV->(MsUnlock())

			Else

				If !_oGetDados:aCols[_nI,nPosDel]

					Reclock("ZCV",.T.)
					ZCV->ZCV_FILIAL := xFilial("ZCV")
					ZCV->ZCV_DTREF  := _cDtRef
					ZCV->ZCV_TPPROD := _cTpProd
					ZCV->ZCV_CLVL   := _oGetDados:aCols[_nI,_msCLVL]
					ZCV->ZCV_FORMAT := _oGetDados:aCols[_nI,_msFORMAT]
					ZCV->ZCV_APPROD := _oGetDados:aCols[_nI,_msAPPROD]
					ZCV->ZCV_EXPROD := _oGetDados:aCols[_nI,_msEXPROD]

					ZCV->(MsUnlock())

				EndIf

			EndIf

		Next

	End

	_cDtRef 		    :=	ctod('')
	_cTpProd 		    :=	SPACE(TAMSX3("ZCV_TPPROD")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGDtRef :SetFocus()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B123CTAS ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 20/04/20 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replicando Roteiro de Fabricação para custo mes anterior   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B123CTAS()

	Local M002      := GetNextAlias()

	Local nPosRec   := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZCV_REC_WT"})

	If !_msCtrlAlt

		MsgInfo("Não é permitido importar dados para período de custo fechado.")
		Return

	EndIf

	If Len(_oGetDados:aCols) > 0

		If _oGetDados:aCols[Len(_oGetDados:aCols), nPosRec] <> 0

			MsgInfo("Não é permitido importar registros quando já existem registros válidos na tela")
			Return

		EndIf

	EndIf

	_oGetDados:aCols	:=	{}

	BeginSql Alias M002
		SELECT ZCV_CLVL,
		ZCV_FORMAT,
		ZCV_APPROD,
		ZCV_EXPROD
		FROM %TABLE:ZCV% ZCV
		WHERE ZCV_DTREF+ZCV_TPPROD = (SELECT MAX(ZCV_DTREF+ZCV_TPPROD)
		FROM %TABLE:ZCV% ZCV
		WHERE ZCV_DTREF < %Exp:dtos(_cDtRef)%
		AND ZCV_TPPROD = %Exp:_cTpProd%
		AND ZCV.%NotDel%)
		AND ZCV.%NotDel%
	EndSql

	While (M002)->(!Eof())

		(M002)->(aAdd(_oGetDados:aCols,{ZCV_CLVL,;
		ZCV_FORMAT,;
		ZCV_APPROD,;
		ZCV_EXPROD,;
		"ZCV",;
		0,;
		.F.	}))

		(M002)->(dbSkip())

	End	

	(M002)->(dbCloseArea())

	_oGetDados:Refresh()

Return
