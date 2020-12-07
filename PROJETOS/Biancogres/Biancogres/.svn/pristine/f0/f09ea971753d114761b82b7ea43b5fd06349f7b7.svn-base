#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG088
@author Gabriel Rossi Mafioletti
@since 10/05/2019
@version 1.0
@description Cadastro de CFOP de Entrada x CFOP de Saída
@type function
/*/

User Function BIAFG088

	Local _aCols	:=	{}
	Local _aHeader	:=	{}
	Local _oDlg
	
	
	Local _aSize := MsAdvSize(.T.) //Sem Enchoice	
	Local _aObjects := {}
	Local _aInfo
	Local _nOpca	:= 0
	Local _aPosObj
	
	Local cSeek	:=	xFilial("ZE0")
	Local bWhile	:=	{|| ZE0_FILIAL}
	
	Private _oGd
	
	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZE0",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	DEFINE MSDIALOG _oDlg TITLE "Cadastro de CFOP de Entrada x CFOP de Saída" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL
	
	_oGd	:=	MsNewGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], GD_INSERT+GD_UPDATE+GD_DELETE, /*[ cLinhaOk]*/"U_BFG88LOK()", "AlwaysTrue" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "AlwaysTrue" /*cFieldOK*/, /*[ cSuperDel]*/,"AlwaysTrue"/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)
	
	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGd:TudoOk(), _oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()})
	
	
	
	
	If _nOpcA == 1
	
		fGrvDados()
	
	EndIf
	

Return

Static Function fGrvDados()

	Local _nI
	Local _nJ

	local nPosRec	    := aScan(_oGd:aHeader,{|x| AllTrim(x[2]) == "ZE0_REC_WT"})
	local nPosDel	:=	Len(_oGd:aHeader) + 1	

	DbSelectArea('ZE0')
	for _nI	:=	1 to Len(_oGd:aCols)
		If _oGd:aCols[_nI,nPosRec] > 0
			ZE0->(DbGoTo(_oGd:aCols[_nI,nPosRec]))
			Reclock("ZE0",.F.)
			If !_oGd:aCols[_nI,nPosDel]
				For _nJ	:=	1 to Len(_oGd:aHeader)
					If _oGd:aHeader[_nJ][10] == "R"
						&("ZE0->" + Alltrim(_oGd:aHeader[_nJ][2])) := _oGd:aCols[_nI, _nJ]
					EndIf
				Next
			Else
				ZE0->(DbDelete())
			EndIf
			ZE0->(MsUnlock())
		ElseIf !_oGd:aCols[_nI,nPosDel]
			Reclock("ZE0",.T.)
			ZE0->ZE0_FILIAL:=	xFilial("ZE0")
			For _nJ	:=	1 to Len(_oGd:aHeader)
				If _oGd:aHeader[_nJ][10] == "R"
					&("ZE0->" + Alltrim(_oGd:aHeader[_nJ][2])) := _oGd:aCols[_nI, _nJ]
				EndIf
			Next

			ZE0->(MsUnlock())			
		EndIf
	next


Return


User Function BFG88LOK()

	Local _nPosCFS	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE0_CFS"})
	Local _nPosCFE	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE0_CFE"})
	Local _nPosTpPrd	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE0_CLASSI"})
	Local _nPosAtrib	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE0_ATRIB"})
	Local _nPosClvl		:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE0_CLVL"})
	Local _nPosDel	:=	Len(_oGd:aHeader) + 1
	Local _nAt		:=	_oGd:nAt
	Local _lRet		:=	.T.
	
	
	Local _nI


	For _nI	:= 1 To Len(_oGd:aCols)

		If !_oGd:aCols[_nI,_nPosDel] .And. _nAt <> _nI
			If _oGd:aCols[_nI,_nPosCFS] == _oGd:aCols[_nAt,_nPosCFS]; 
					.And. _oGd:aCols[_nI,_nPosCFE] == _oGd:aCols[_nAt,_nPosCFE];
					.And. _oGd:aCols[_nI,_nPosTpPrd] == _oGd:aCols[_nAt,_nPosTpPrd];
					.And. _oGd:aCols[_nI,_nPosAtrib] == _oGd:aCols[_nAt,_nPosAtrib];
					.And. _oGd:aCols[_nI,_nPosClvl] == _oGd:aCols[_nAt,_nPosClvl]
				MsgInfo("Já Existe Combinação de CF de Saída x CF de Entrada","BIAFG088")
				_lRet	:=	.F.
				Exit
			EndIf 
		EndIf

	Next
Return _lRet