#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA385
@author Marcos Alberto Soprani
@since 14/09/17
@version 1.0
@description Tela para cadastro de Categoria de Funcionários 
@type function
/*/

User Function BIA385()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB4") + SPACE(TAMSX3("ZB4_CATEGF")[1])
	Local bWhile	    := {|| ZB4_FILIAL + ZB4_CATEGF }                    
	Local aNoFields     := {}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cCatTlFU	:= "Y"
	Private _oGCatTlFU

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB4",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Categoria de Funcionários" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Listar Itens:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,060 MSGET _oGCatTlFU VAR _cCatTlFU  SIZE 07, 11 OF _oDlg PIXEL VALID fBIA385A()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B385FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B385DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA385A()

	Local _cAlias	:=	GetNextAlias()

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZB4% ZB4
	WHERE ZB4_FILIAL = %xFilial:ZB4%
	AND ZB4.%NotDel%
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB4_CATEGF,;
			ZB4_DESCRI,;
			ZB4_PRCPAT,;
			ZB4_PRCAVT,;
			ZB4_REAJDI,;
			ZB4_MIN050,;
			ZB4_MIM100,;
			"ZB4",;
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_REC_WT"})
	Local _mCATEGF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_CATEGF"})
	Local _mDESCRI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_DESCRI"})
	Local _mPRCPAT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_PRCPAT"})
	Local _mPRCAVT := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_PRCAVT"})
	Local _mREAJDI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_REAJDI"})
	Local _mMIN050 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_MIN050"})
	Local _mMIM100 := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB4_MIM100"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZB4')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZB4->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZB4",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZB4->ZB4_CATEGF := _oGetDados:aCols[_nI,_mCATEGF]
				ZB4->ZB4_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]
				ZB4->ZB4_PRCPAT := _oGetDados:aCols[_nI,_mPRCPAT]
				ZB4->ZB4_PRCAVT := _oGetDados:aCols[_nI,_mPRCAVT]
				ZB4->ZB4_REAJDI := _oGetDados:aCols[_nI,_mREAJDI]
				ZB4->ZB4_MIN050 := _oGetDados:aCols[_nI,_mMIN050]
				ZB4->ZB4_MIM100 := _oGetDados:aCols[_nI,_mMIM100]

			Else

				ZB4->(DbDelete())

			EndIf

			ZB4->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZB4",.T.)
				ZB4->ZB4_FILIAL := xFilial("ZB4")
				ZB4->ZB4_CATEGF := _oGetDados:aCols[_nI,_mCATEGF]
				ZB4->ZB4_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]
				ZB4->ZB4_PRCPAT := _oGetDados:aCols[_nI,_mPRCPAT]
				ZB4->ZB4_PRCAVT := _oGetDados:aCols[_nI,_mPRCAVT]
				ZB4->ZB4_REAJDI := _oGetDados:aCols[_nI,_mREAJDI]
				ZB4->ZB4_MIN050 := _oGetDados:aCols[_nI,_mMIN050]
				ZB4->ZB4_MIM100 := _oGetDados:aCols[_nI,_mMIM100]
				ZB4->(MsUnlock())

			EndIf

		EndIf

	Next

	_cCatTlFU		    :=	Space(1)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGCatTlFU:SetFocus()
	_oGCatTlFU:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B385FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbCATEGF := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZB4_CATEGF"
		_gbCATEGF := M->ZB4_CATEGF
		If ExistCPO("ZB4")
			MsgInfo("Registro já existe na base!!!")
			Return .F.
		EndIf

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_gbCATEGF) .and. _gbCATEGF == GdFieldGet("ZB4_CATEGF",_nI)

				MsgInfo("Não poderá haver a mesma Categoria Func mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe a Categoria Func informada!!!")
				Return .F.

			EndIf

		EndIf

	Next

Return .T.

User Function B385DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
