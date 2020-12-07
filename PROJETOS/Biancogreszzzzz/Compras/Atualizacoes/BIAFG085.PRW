#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG085
@author Gabriel Rossi Mafioletti
@since 10/05/2019
@version 1.0
@description Cadastro de CST para Simples Nacional
@type function
/*/

User Function BIAFG085()

	Local _aCols	:=	{}
	Local _aHeader	:=	{}
	Local _oDlg
	
	
	Local _aSize := MsAdvSize(.T.) //Sem Enchoice	
	Local _aObjects := {}
	Local _aInfo
	Local _nOpca	:= 0
	Local _aPosObj
	
	Local cSeek	:=	xFilial("ZE1")
	Local bWhile	:=	{|| ZE1_FILIAL}
	
	Private _oGd
	
	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	FillGetDados(4,"ZE1",1,cSeek,bWhile,,,,,,,,@_aHeader,@_aCols)

	DEFINE MSDIALOG _oDlg TITLE "Cadastro de CST para Simples Nacional" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL
	
	_oGd	:=	MsNewGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], GD_INSERT+GD_UPDATE+GD_DELETE, /*[ cLinhaOk]*/"U_BFG85LOK()", "AlwaysTrue" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "AlwaysTrue" /*cFieldOK*/, /*[ cSuperDel]*/,"AlwaysTrue"/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)
	
	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGd:TudoOk(), _oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()})
	
	
	
	
	If _nOpcA == 1
	
		fGrvDados()
	
	EndIf
	

Return

Static Function fGrvDados()

	Local _nI
	Local _nJ

	local nPosRec	    := aScan(_oGd:aHeader,{|x| AllTrim(x[2]) == "ZE1_REC_WT"})
	local nPosDel	:=	Len(_oGd:aHeader) + 1	

	DbSelectArea('ZE1')
	for _nI	:=	1 to Len(_oGd:aCols)
		If _oGd:aCols[_nI,nPosRec] > 0
			ZE1->(DbGoTo(_oGd:aCols[_nI,nPosRec]))
			Reclock("ZE1",.F.)
			If !_oGd:aCols[_nI,nPosDel]
				For _nJ	:=	1 to Len(_oGd:aHeader)
					If _oGd:aHeader[_nJ][10] == "R"
						&("ZE1->" + Alltrim(_oGd:aHeader[_nJ][2])) := _oGd:aCols[_nI, _nJ]
					EndIf
				Next
			Else
				ZE1->(DbDelete())
			EndIf
			ZE1->(MsUnlock())
		ElseIf !_oGd:aCols[_nI,nPosDel]
			Reclock("ZE1",.T.)
			ZE1->ZE1_FILIAL:=	xFilial("ZE1")
			For _nJ	:=	1 to Len(_oGd:aHeader)
				If _oGd:aHeader[_nJ][10] == "R"
					&("ZE1->" + Alltrim(_oGd:aHeader[_nJ][2])) := _oGd:aCols[_nI, _nJ]
				EndIf
			Next

			ZE1->(MsUnlock())			
		EndIf
	next


Return


User Function BFG85LOK()

	Local _nPosCSTSN	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE1_CSTSN"})
	Local _nPosCST	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE1_CST"})
	Local _nPosTipo	:=	aScan(_oGd:aHeader,{|x| alltrim(x[2]) == "ZE1_TPPROD"})
	Local _nPosDel	:=	Len(_oGd:aHeader) + 1
	Local _nAt		:=	_oGd:nAt
	Local _lRet		:=	.T.
	
	
	Local _nI


	For _nI	:= 1 To Len(_oGd:aCols)

		If !_oGd:aCols[_nI,_nPosDel] .And. _nAt <> _nI
			If _oGd:aCols[_nI,_nPosCST] == _oGd:aCols[_nAt,_nPosCST] .And. _oGd:aCols[_nI,_nPosCSTSN] == _oGd:aCols[_nAt,_nPosCSTSN] .And. _oGd:aCols[_nI,_nPosTipo] == _oGd:aCols[_nAt,_nPosTipo]
				MsgInfo("Já Existe Combinação de CST","BIAFG085")
				_lRet	:=	.F.
				Exit
			EndIf 
		EndIf

	Next
Return _lRet