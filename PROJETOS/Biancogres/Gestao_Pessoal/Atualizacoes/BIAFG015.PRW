#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG015
@author Gabriel Rossi Mafioletti
@since 01/08/2017
@version 1.0
@description Tela de Controle de Crachás
@type function
/*/

User Function BIAFG015()

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}

	Local _aHeader		:=	{}          
	Local _aCols		:=	{}

	Local cSeek	:=	xFilial("ZC0") + SPACE(TAMSX3("ZC0_NUMERO")[1])
	Local bWhile	:=	{|| ZC0_FILIAL + ZC0_NUMERO }                    

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _nOpcA	:=	0

	Local _aButtons	:=	{}

	aAdd(_aButtons,{"HISTORIC",{|| U_BIAFG017()}, "Rel. Crachá","Rel. Crachá"})

	Private _oDlg
	Private _oGetDados	:= Nil    
	Private _aColsBkp	:=	{}
	Private _cCracha		:=	SPACE(TAMSX3("ZC0_NUMERO")[1])
	Private _oGCracha

	_aSize := MsAdvSize(.T.)                      

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZC0",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)
	_aColsBkp	:=	aClone(_aCols)
	//	_aHeader := apBuildHeader("ZC0")   

	Define MsDialog _oDlg Title "Controle de Crachás" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ 050,010 SAY "Crachá:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ 048,040 MSGET _oGCracha VAR _cCracha  SIZE 50, 11 OF _oDlg PIXEL VALID fRetCracha()

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], 7, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "U_BFG15FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,"U_BFG15DOK()" /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),fGrvDados(),_nOpcA := 0)}, {|| _oDlg:End()},,_aButtons) 

Return

Static Function fRetCracha()

	Local _cAlias	:=	GetNextAlias()

	If Empty(_cCracha)
		MsgInfo("O número do crachá deverá ser digitado")
		Return .F.
	EndIf
	_oGetDados:aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZC0% ZC0
	WHERE ZC0_FILIAL = %XFILIAL:ZC0%
	AND ZC0_NUMERO = %Exp:_cCracha%
	AND ZC0.%NotDel%
	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			(_cAlias)->(aAdd(_oGetDados:aCols,{ZC0_EMPR, ;
			ZC0_MAT, ;
			ZC0_SOLICI,		; 
			ZC0_CLVL,	;
			ZC0_BENEFI,	;     
			StoD(ZC0_DATREC),	;
			Stod(ZC0_DATDEV),	;
			"ZC0",	;
			R_E_C_N_O_,;
			.F.	}))
			(_cAlias)->(DbSkip())
		EndDo
		(_cAlias)->(DbCloseArea())
	Else
		_oGetDados:aCols	:=	aClone(_aColsBkp)
	EndIf	

	_oGetDados:Refresh()

Return .T.

Static Function fGrvDados()

	Local _nI

	local nPosRec	    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_REC_WT"})
	local nPosEmpr	    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_EMPR"})
	local nPosMat	    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_MAT"})
	local nPosSoli	    := aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_SOLICI"})
	local nPosClVl		:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_CLVL"})	
	local nPosBenef		:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_BENEFI"})
	Local nPosDtRec		:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_DATREC"})
	Local nPosDtDev		:= aScan(_oGetDados:aHeader,{|x| AllTrim(x[2]) == "ZC0_DATDEV"})

	local nPosDel	:=	Len(_oGetDados:aHeader) + 1	

	DbSelectArea('ZC0')
	for _nI	:=	1 to Len(_oGetDados:aCols)
		If _oGetDados:aCols[_nI,nPosRec] > 0
			ZC0->(DbGoTo(_oGetDados:aCols[_nI,nPosRec]))
			Reclock("ZC0",.F.)
			If !_oGetDados:aCols[_nI,nPosDel]
				ZC0->ZC0_EMPR	:=	_oGetDados:aCols[_nI,nPosEmpr]
				ZC0->ZC0_MAT 	:=	_oGetDados:aCols[_nI,nPosMat]
				ZC0->ZC0_SOLICI	:=	_oGetDados:aCols[_nI,nPosSoli]
				ZC0->ZC0_CLVL	:=	_oGetDados:aCols[_nI,nPosClVl]
				ZC0->ZC0_BENEFI	:=	_oGetDados:aCols[_nI,nPosBenef]
				ZC0->ZC0_DATREC	:=	_oGetDados:aCols[_nI,nPosDtRec]
				ZC0->ZC0_DATDEV	:=	_oGetDados:aCols[_nI,nPosDtDev]
			Else
				ZC0->(DbDelete())
			EndIf
			ZC0->(MsUnlock())
		Else
			Reclock("ZC0",.T.)
			ZC0->ZC0_FILIAL	:=	xFilial("ZC0")
			ZC0->ZC0_NUMERO :=	_cCracha
			ZC0->ZC0_EMPR	:=	_oGetDados:aCols[_nI,nPosEmpr]
			ZC0->ZC0_MAT 	:=	_oGetDados:aCols[_nI,nPosMat]
			ZC0->ZC0_SOLICI	:=	_oGetDados:aCols[_nI,nPosSoli]
			ZC0->ZC0_CLVL	:=	_oGetDados:aCols[_nI,nPosClVl]
			ZC0->ZC0_BENEFI	:=	_oGetDados:aCols[_nI,nPosBenef]
			ZC0->ZC0_DATREC	:=	_oGetDados:aCols[_nI,nPosDtRec]
			ZC0->ZC0_DATDEV	:=	_oGetDados:aCols[_nI,nPosDtDev]			

			ZC0->(MsUnlock())			
		EndIf
	next

	_cCracha		:=	SPACE(TAMSX3("ZC0_NUMERO")[1])
	_oGetDados:aCols	:=	aClone(_aColsBkp)
	_oGCracha:SetFocus()
	_oGCracha:Refresh()
	_oGetDados:Refresh()
	_oDlg:Refresh()

	MsgInfo("Registro Incluído com Sucesso!")

Return

User Function BFG15FOK()

	Local cMenVar   := ReadVar()
	Local vfArea    := GetArea()
	Local _cChave	:=	""
	Local _cAlias
	Local _nAt		:=	_oGetDados:nAt
	Local _nI

	If !Empty(GdFieldGet("ZC0_DATDEV",_nAt))
		If Alltrim(__readvar) <> "M->ZC0_DATDEV"
			MsgInfo("O registro não poderá ser alterado após a digitação da data de devolução!")
			Return .F.
		EndIf
	EndIf

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _nI <> _nAt .And. Empty(GdFieldGet("ZC0_DATDEV",_nI)) .And. !GDdeleted(_nI)
			MsgInfo("O crachá somente poderá possuir um registro sem devolução por vez!")
			Return .F.
		EndIf

	Next

	Do Case

		Case Alltrim(cMenVar) == "M->ZC0_MAT"

		_cAlias	:=	GetNextAlias()
		BeginSql Alias _cAlias
		SELECT ZZY_NOME
		FROM %TABLE:ZZY% ZZY
		WHERE ZZY_MATRIC = %Exp:M->ZC0_MAT%
		AND %NOTDEL%
		EndSql
		If (_cAlias)->(!EOF())
			_cChave :=	(_cALias)->ZZY_NOME
			RestArea(vfArea)
			GdFieldPut("ZC0_SOLICI",_cChave,_nAt)
		Else
			MsgInfo("Matrícula Não Encontrada!")
			Return .F.
		EndIf
		(_cAlias)->(DbCloseArea())

		Case Alltrim(cMenVar) == "M->ZC0_CLVL"
		If !ExistCPo("CTH")
			Return .F.
		EndIf

		Case Alltrim(cMenVar) == "M->ZC0_SOLICI"
		GdFieldPut("ZC0_MAT",Space(TAMSX3("ZC0_MAT")[1]),_nAt)

		Case Alltrim(cMenVar) == "M->ZC0_DATDEV"
		If M->ZC0_DATDEV < GdFieldGet("ZC0_DATREC",_nAt) .and. _nAt <> Len(_oGetDados:aCols)
			MsgInfo("A Data de Devolução não poderá ser menor que a data de Entrega!")
			Return .F.
		EndIF

		Case Alltrim(cMenVar) == "M->ZC0_EMPR"
		If !ExistCPO("Z36")
			Return .F.
		EndIf

	EndCase

Return .T.

User Function BFG15DOK()

	Local _lRet	:=	.T.

	If !Empty(GdFieldGet("ZC0_DATDEV",_oGetDados:nAt))
		MsgInfo("O registro não poderá ser excluído após a digitação da data de devolução!")
		_lret	:=	.F.
	EndIf 

Return _lRet
