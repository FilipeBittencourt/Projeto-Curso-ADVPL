#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BHC0002
@author Gabriel Rossi Mafioletti
@since 21/01/2019
@version 1.0
@description Tela de Cadastro de Gestor x Posições
@type function
/*/

User Function BHC0002()

	Local _aSize	
	Local _aObjects := {}
	Local _aInfo

	Local _aPosObj
	Local _aHeader	:= {}
	Local _aCols	:= {}
	Local _aButtons	:= {}

	Private _oGetDados
	Private _oEnch
	Private _cMatricula	:=	Space(8)
	Private _cNome	:=	Space(TamSx3("RA_NOME")[1])

	aAdd(_aButtons,{"HISTORIC",{|| U_BHC02PRC()}, "Processa Conferência HeadCount", "Processa Conferência HeadCount"})

	_aSize := MsAdvSize(.T.) //Sem Enchoice

	fMontaHead(_aHeader)

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	

	AAdd(_aObjects, {100, 20, .T. , .T. })
	AAdd(_aObjects, {100, 80, .T. , .T. })

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	DEFINE MSDIALOG _oDlg TITLE "Cadastro de Gestor x Posição" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL

	@ _aposObj[1,1]+10, _aposObj[1,2] +10 SAY "Matrícula:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aposObj[1,1]+7, _aposObj[1,2] + 45 MSGET _oGetMat VAR _cMatricula  SIZE 50, 11 OF _oDlg PIXEL F3 "SRA623" VALID U_BHC02MAT()

	@ _aposObj[1,1]+30, _aposObj[1,2]+10 SAY "Nome:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aposObj[1,1]+27, _aposObj[1,2] + 45 MSGET _oGetNome VAR _cNome  SIZE 200, 11 OF _oDlg PIXEL WHEN .F.

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE+GD_INSERT+GD_DELETE, /*[ cLinhaOk]*/, "U_BHC02TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/,{"POSIC","DTINI","DTFIM","TIPO"} /*Acpos*/, /*[ nFreeze]*/,999 /*[ nMax]*/, "U_BHC02FOK()" /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	ACTIVATE DIALOG _oDlg CENTERED on Init EnchoiceBar(_oDlg, {||_nOk := 1, If(_oGetDados:TudoOk(),fGrava(),_nOk := 0)}, {|| _oDlg:End()},,_aButtons)

Return

Static Function fMontaHead(_aHeader)

	_aHeader	:=	{}

	aAdd(_aHeader,{"Posição"         ,"POSIC" ,"@!"               , TAMSX3("ZLB_CODIGO")[1]   , 0,,, "C","ZLA",,,,,,,,.T. })      	// 1
	aAdd(_aHeader,{"Descrição"         ,"DESPOS" ,"@!"               , TAMSX3("ZLA_DESPOS")[1]   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Dt. Início"         ,"DTINI" ,"@!"               , 8   , 0,,, "D",,,,,,,,,.T. })      	// 1
	aAdd(_aHeader,{"Dt. Fim"         ,"DTFIM" ,"@!"               , 8   , 0,,, "D",, })      	// 1
	aAdd(_aHeader,{"Tipo"         ,"TIPO" ,""               , 1   , 0,,, "C",,,fRetCBox("ZLB_TIPO") ,,,,,,.T.})      	// 1
	aAdd(_aHeader,{"RECNO"         ,"REGNUM" ,"@!"               , 10   , 0,,, "N",, })      	// 1

Return

Static Function fRetCBox(_cCampo)

	Local _cCBox	:=	""
	Local _aArea	:=	GetArea()

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	If SX3->(DbSeek(PADR(_cCampo,10)))

		_cCBox	:=	X3Cbox()

	EndIf

	RestArea(_aArea)

Return _cCBox

User Function BHC02FOK()

	Local _lret	:=	.T.
	Local _cCampo	:=	Alltrim(ReadVar())
	Local _aArea	:=	GetArea()

	Do Case
		Case _cCampo == "M->POSIC"
		ZLA->(DbSetOrder(2))
		If ZLA->(DbSeek(xFilial("ZLA")+M->POSIC))
			GdFieldPut("DESPOS",ZLA->ZLA_DESPOS,_oGetDados:nAt,_oGetDados:aHeader,_oGetDados:Acols,.F.)
		Else
			MsgAlert("Posição não encontrada!")
			_lRet	:=	.F.
		EndIf
	EndCase

	RestArea(_aArea)

Return _lRet

User Function BHC02MAT()

	Local _lret	:=	.T.
	Local _aArea	:=	GetArea()
	Local _aCols	:=	{}

	If !fSeekMat()//!SRA->(DbSeek(xFilial("SRA")+ _cMatricula ))

		MsgAlert("Funcionário não encontrado!")
		_lRet	:=	.F.

	Else

		_aCols	:=	fMontaCols(_cMatricula)

		_oGetDados:aCols	:=	_aCols

		_oGetDados:Refresh()

	EndIf

	RestArea(_aArea)

Return _lret

Static Function fMontaCols(_cMat)

	Local _aCols	:=	{}
	Local _cAlias	:=	GetNextAlias()

	BEGINSQL ALIAS _cAlias

		SELECT ZLB.R_E_C_N_O_ AS REC,*
		FROM %TABLE:ZLB% ZLB
		JOIN %TABLE:ZLA% ZLA ON ZLB.ZLB_FILIAL = ZLA.ZLA_FILIAL
		AND ZLB.ZLB_CODIGO = ZLA.ZLA_CODIGO
		AND ZLB.ZLB_MATRES = %Exp:_cMat%
		AND ZLB.%NotDel%
		AND ZLA.%NotDel%

	ENDSQL

	If (_cALias)->(!EOF())

		While (_cAlias)->(!EOF())
			aAdd(_aCols,{;
			(_cALias)->ZLB_CODIGO,;
			(_cALias)->ZLA_DESPOS,;
			Stod((_cALias)->ZLB_DTINI),;
			Stod((_cALias)->ZLB_DTFIM),;
			(_cALias)->ZLB_TIPO,;
			(_cAlias)->REC,;
			.F.	})	
			(_cAlias)->(DbSkip())
		EndDo
	Else
		aAdd(_aCols,{;
		SPACE(Tamsx3("ZLB_CODIGO")[1]),;
		SPACE(Tamsx3("ZLA_DESPOS")[1]),;
		Stod(""),;
		Stod(""),;
		SPACE(Tamsx3("ZLB_TIPO")[1]),;
		0,;
		.F.	})
	EndIf

	(_cAlias)->(DbCloseArea())

Return _aCols

User Function BHC02TOK()

	Local _lRet	:= .T.


Return	_lret

Static Function fGrava()

	Local _nI
	Local _nPosDel	:=	Len(_oGetDados:aHeader) + 1

	For _nI	:=	1 to Len(_oGetDados:aCols)

		If _oGetDados:aCols[_nI,_nPosDel] 
			If GdFieldGet("REGNUM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols) > 0
				ZLB->(DbGoTo(GdFieldGet("REGNUM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)))
				If ZLB->(!EOF())
					Reclock("ZLB",.F.)
					ZLB->(DbDelete())
					ZLB->(MsUnlock())
				EndIF
			EndIf
		Else
			If GdFieldGet("REGNUM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols) > 0

				ZLB->(DbGoTo(GdFieldGet("REGNUM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)))
				If ZLB->(!EOF())
					Reclock("ZLB",.F.)
					ZLB->ZLB_CODIGO	:=	GdFieldGet("POSIC",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)
					ZLB->ZLB_DTINI	:=	GdFieldGet("DTINI",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)
					ZLB->ZLB_DTFIM	:=	GdFieldGet("DTFIM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)		
					ZLB->ZLB_TIPO	:=	GdFieldGet("TIPO",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)
					ZLB->(MsUnlock())
				EndIf
			Else
				Reclock("ZLB",.T.)
				ZLB->ZLB_FILIAL	:=	xFilial("ZLB")
				ZLB->ZLB_MATRES	:=	_cMatricula
				ZLB->ZLB_CODIGO	:=	GdFieldGet("POSIC",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)
				ZLB->ZLB_DTINI	:=	GdFieldGet("DTINI",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)
				ZLB->ZLB_DTFIM	:=	GdFieldGet("DTFIM",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)		
				ZLB->ZLB_TIPO	:=	GdFieldGet("TIPO",_nI,.F.,_oGetDados:aHeader,_oGetDados:Acols)				

				ZLB->(MsUnlock())
			EndIf
		EndIf

	Next

	MsgInfo("Dados Atualizados com Sucesso!")

	_aCols	:=	fMontaCols(_cMatricula)

	_oGetDados:aCols	:=	_aCols

	_oGetDados:Refresh()

Return

Static Function fSeekMat()

	Local _cAlias	:=	GetNextAlias()
	Local _nEmp	:=	Val(Substr(_cMatricula,1,2))
	Local _nMat	:=	Val(Substr(_cMatricula,3))
	Local _lRet	:=	.F.

	BeginSql Alias _cAlias

		%NoParser%
		SELECT *
		FROM VETORH..r034fun a
		WHERE tipcol = 1
		AND numemp = %Exp:_nEmp% 
		AND numcad = %Exp:_nMat%
		AND (sitafa <> 7
		OR
		(
		SELECT COUNT(*)
		FROM %TABLE:ZLB%
		WHERE CONVERT(NUMERIC, SUBSTRING(ZLB_MATRES, 3, 6)) = a.numcad
		AND CONVERT(VARCHAR, GETDATE(), 112) BETWEEN ZLB_DTINI AND ZLB_DTFIM
		AND D_E_L_E_T_ = ' '
		) > 0)

	EndSql

	If (_cAlias)->(!EOF())
		_cNome	:=	(_cAlias)->nomfun
		_lRet	:=	.T.
	EndIf

Return _lRet

User Function BHC02PRC()

	Private oDlg
	Private oButton1
	Private oButton2
	Private oComboBox1
	Private oGet1
	Private mscGet1 := ctod(" /  /  ")
	Private oSay1
	Private msFechTl   := .F.
	Private msAltReg   := .F.
	Private msCoutRg   := 0

	DEFINE MSDIALOG oDlg TITLE "Processamento Avulso" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

	@ 023, 011 SAY oSay1 PROMPT "Data de Referência: " SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 070 MSGET oGet1 VAR mscGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 019, 149 BUTTON oButton1 PROMPT "Cancelar"  SIZE 037, 012 OF oDlg ACTION msFecha() PIXEL
	@ 019, 190 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION msPrcHC() PIXEL

	ACTIVATE MSDIALOG oDlg VALID msFechTl

	If msAltReg

		If msCoutRg == 0

			MsgAlert("Processamento realizado: nenhum REGISTRO AFETADO. Verificar o cadastro!!!", "HeadCount")

		Else

			MsgINFO("Alteração Realizada com SUCESSO.....", "HeadCount")

		EndIf

	Else

		MsgSTOP("Alteração Cancelada.....", "HeadCount")

	EndIf

Return

Static Function msPrcHC()

	Local _cAlias	:=	GetNextAlias()

	If !Empty(mscGet1) 

		U_BHC01PRC()

		msFechTl  := .T.
		msAltReg  := .T.
		Close(oDlg)

		BeginSql Alias _cAlias

			%NoParser%

			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZLC% ZLC(NOLOCK)
			WHERE ZLC_FILIAL = %xFilial:ZLC%
			AND ZLC_MAT = %Exp:_cMatricula%
			AND ZLC_DATREF = %Exp:mscGet1%
			AND ZLC.%NotDel%

		EndSql

		If (_cAlias)->(!EOF())
			msCoutRg	:=	(_cAlias)->CONTAD
		EndIf

	Else

		MsgSTOP("Informe uma Data...", "Atenção!!!")

	EndIf

Return

Static Function msFecha()

	msFechTl := .T.
	Close(oDlg)

Return
