#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA387
@author Marcos Alberto Soprani
@since 14/09/17
@version 1.0
@description Tela para Cadastro de Benefícios / Adicionais 
@type function
/*/

User Function BIA387()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZB6") + SPACE(TAMSX3("ZB6_BNADC")[1])
	Local bWhile	    := {||  ZB6_FILIAL + ZB6_BNADC }                    
	Local aNoFields     := {}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cCadBnA	:= "Y"
	Private _oGCadBnA

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZB6",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Benefícios / Adicionais" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Listar Itens:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,060 MSGET _oGCadBnA VAR _cCadBnA  SIZE 07, 11 OF _oDlg PIXEL VALID fBIA387A()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B387FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B387DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA387A()

	Local _cAlias	:=	GetNextAlias()

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZB6% ZB6
	WHERE ZB6_FILIAL = %xFilial:ZB6%
	AND ZB6.%NotDel%
	ORDER BY ZB6.ZB6_BNADC
	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZB6_BNADC,;
			ZB6_DESCRI,;
			"ZB6",;
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB6_REC_WT"})
	Local _mBNADC  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB6_BNADC"})
	Local _mDESCRI := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZB6_DESCRI"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZB6')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZB6->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZB6",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZB6->ZB6_BNADC := _oGetDados:aCols[_nI,_mBNADC]
				ZB6->ZB6_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]

			Else

				ZB6->(DbDelete())

			EndIf

			ZB6->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZB6",.T.)
				ZB6->ZB6_FILIAL := xFilial("ZB6")
				ZB6->ZB6_BNADC := _oGetDados:aCols[_nI,_mBNADC]
				ZB6->ZB6_DESCRI := _oGetDados:aCols[_nI,_mDESCRI]
				ZB6->(MsUnlock())

			EndIf

		EndIf

	Next

	_cCadBnA		    :=	Space(1)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGCadBnA:SetFocus()
	_oGCadBnA:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B387FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbBNADC  := ""

	Do Case

		Case Alltrim(cMenVar) == "M->ZB6_BNADC"
		_gbBNADC  := M->ZB6_BNADC

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_gbBNADC) .and. _gbBNADC == GdFieldGet("ZB6_BNADC",_nI)

				MsgInfo("Favor verificar, pois existem registros duplicados que impedem a confirmação do movimento!!!")
				Return .F.

			EndIf

		EndIf

	Next

Return .T.

User Function B387DOK()

	Local _lRet	:=	.T.

Return _lRet
