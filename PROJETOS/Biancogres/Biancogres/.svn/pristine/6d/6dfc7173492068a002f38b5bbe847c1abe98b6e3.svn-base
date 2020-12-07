#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA644
@author Marcos Alberto Soprani
@since 14/09/17
@version 1.0
@description Tela para cadastro de Canal de Distribuição 
@type function
/*/

User Function BIA644()

	Local _aSize 		:= {} 
	Local _aObjects		:= {}
	Local _aInfo		:= {}
	Local _aPosObj		:= {}

	Local _aHeader		:= {}          
	Local _aCols		:= {}

	Local cSeek	        := xFilial("ZBJ") + SPACE(TAMSX3("ZBJ_CANALD")[1])
	Local bWhile	    := {|| ZBJ_FILIAL + ZBJ_CANALD }                    
	Local aNoFields     := {}

	Local oFont         := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	Local _nOpcA	    := 0
	Local _aButtons	    := {}

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:= {}
	Private _cCanalDist	:= "Y"
	Private _oGCanalDist

	_aSize := MsAdvSize(.T.)      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZBJ",1,cSeek,bWhile,,aNoFields,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)

	Define MsDialog _oDlg Title "Cadastro de Canal de Distribuição" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Listar Itens:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,060 MSGET _oGCanalDist VAR _cCanalDist  SIZE 07, 11 OF _oDlg PIXEL VALID fBIA644A()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_B644FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_B644DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fBIA644A()

	Local _cAlias	:=	GetNextAlias()

	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZBJ% ZBJ
		WHERE ZBJ_FILIAL = %xFilial:ZBJ%
		AND ZBJ.%NotDel%

	EndSql

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())

			(_cAlias)->(aAdd(_oGetDados:aCols,{ZBJ_CANALD,;
			ZBJ_DESCR,;
			"ZBJ",;
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

	Local nPosRec  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBJ_REC_WT"})
	Local _mCATEGF := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBJ_CANALD"})
	Local _mDESCR  := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZBJ_DESCR"})

	Local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	dbSelectArea('ZBJ')
	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,nPosRec] > 0

			ZBJ->(dbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZBJ",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]

				ZBJ->ZBJ_CANALD := _oGetDados:aCols[_nI,_mCATEGF]
				ZBJ->ZBJ_DESCR  := _oGetDados:aCols[_nI,_mDESCR]

			Else

				ZBJ->(DbDelete())

			EndIf

			ZBJ->(MsUnlock())

		Else

			If !_oGetDados:aCols[_nI,nPosDel]

				Reclock("ZBJ",.T.)
				ZBJ->ZBJ_FILIAL := xFilial("ZBJ")
				ZBJ->ZBJ_CANALD := _oGetDados:aCols[_nI,_mCATEGF]
				ZBJ->ZBJ_DESCR  := _oGetDados:aCols[_nI,_mDESCR]
				ZBJ->(MsUnlock())

			EndIf

		EndIf

	Next

	_cCanalDist		    :=	Space(1)
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGCanalDist:SetFocus()
	_oGCanalDist:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function B644FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI
	Local _gbCATEGF := ""
	Local _xEnter   := CHR(13)+CHR(10)

	Do Case

		Case Alltrim(cMenVar) == "M->ZBJ_CANALD"
		_gbCATEGF := M->ZBJ_CANALD
		ZBJ->(dbSetOrder(1))
		If ZBJ->(dbSeek(xFilial("SBJ") + _gbCATEGF))

			MsgInfo("Registro já existe na base!!!")
			Return .F.

		Else

			xcMenDet := "Quando um novo Canal de Comercialização é criado, faz-se necessário efetuar os seguintes ajustes no sistema:" + _xEnter + _xEnter
			xcMenDet += " 1) Incluir um campo na tabela ZBK correspondente ao código do canal criado." + _xEnter
			MsgINFO( xcMenDet )

		EndIf

	EndCase

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .and. !GDdeleted(_nI)

			If !Empty(_gbCATEGF) .and. _gbCATEGF == GdFieldGet("ZBJ_CANALD",_nI)

				MsgInfo("Não poderá haver o mesmo Canal de Comercialização mais de uma vez na lista. Na linha: " + Alltrim(Str(_nI)) + " já existe o Canal de Comercialização informada!!!")
				Return .F.

			EndIf

		EndIf

	Next

Return .T.

User Function B644DOK()

	Local _lRet	:=	.T.

	// Sem necessidade inicial de controle de deleção

Return _lRet
