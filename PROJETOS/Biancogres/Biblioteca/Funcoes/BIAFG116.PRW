#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Monitor de Rotinas Concorrentes
@author Gabriel Mafioletti
@since 04/11/2019
@version 1.0
@type Function
/*/

User Function BIAFG116()

	Local _oDlg

	Local _aObjects		:=	{}

	Local _aSize1 		:=	{}
	Local _aInfo1		:=	{}
	Local _aPosObj1		:=	{}

	Local _aSize2 		:=	{}
	Local _aInfo2		:=	{}
	Local _aPosObj2		:=	{}

	Local _aButtons		:=	{}
	Local _aGrupos

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Private _oGetDados	:=	Nil
	Private _oGdServer	:=	Nil

	Private _oCGrupo	:=	Nil
	Private _cCGrupos

	Private _aCols		:=	{}
	Private _aHeader	:=	{}
	Private _aCSrv		:=	{}
	Private _aHSrv		:=	{}

	Private cCadastro	:=	"Monitor de Rotinas Concorrentes"

	Private oCheckBo1
	Private lCheckBo1 := GetMv("MV_YBLQRCM")

	_aGrupos		:=	fGetGrupos()

	SetKey(VK_F5, {|| U_BIAMsgRun("Aguarde... Carregando dados",,{|| fRefresh() }) })

	_aSize1 := MsAdvSize(.F.)

	AAdd(_aObjects, {100, 30, .T. , .T. })
	AAdd(_aObjects, {100, 60, .T. , .T. })
	AAdd(_aObjects, {100, 10, .T. , .T. })

	_aInfo1   := {_aSize1[1], _aSize1[2], _aSize1[3], _aSize1[4], 5, 5}

	_aPosObj1 := MsObjSize(_aInfo1, _aObjects, .T. )

	_aObjects	:=	{}

	AAdd( _aObjects, { 60, 100, .T., .T. } )
	AAdd( _aObjects, { 40, 100, .T., .T. } )

	_aSize2 := aClone( _aPosObj1[1] )
	_aInfo2   := { _aSize2[2], _aSize2[1], _aSize2[4], _aSize2[3], 3, 3 }
	_aPosObj2 := MsObjSize( _aInfo2, _aObjects, ,.T. )

	fMontaHead()

	//fMontaCols()

	Define MsDialog _oDlg Title "Monitor de Rotinas Concorrentes" From _aSize1[7],0 To _aSize1[6],_aSize1[5] Of oMainWnd Pixel STYLE nOR( WS_VISIBLE, WS_POPUP )

	@ _aPosObj2[1,1], _aPosObj2[1,2] GROUP oGpMRP1 TO _aPosObj2[1,3], _aPosObj2[1,4] PROMPT "Parâmetros..." OF _oDlg COLOR 0, 16777215 PIXEL
	@ _aPosObj2[1,1] + 010, _aPosObj2[1,2] + 010 SAY "Grupo:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aPosObj2[1,1] + 010, _aPosObj2[1,2] + 047 MsComboBox _oCGrupo Var _cCGrupos Items _aGrupos Size 90, 11 Of _oDlg Colors 0, 16777215 Pixel VALID U_BFG116VL() WHEN .F.

	@ _aPosObj2[1,1] + 030, _aPosObj2[1,1] + 010 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Bloqueio RCM?" SIZE 081, 008 OF _oDlg FONT oFont COLORS 0, 16777215 PIXEL ON CLICK U_BFG116PR()

	_oGetDados := MsNewGetDados():New(_aPosObj1[2,1], _aPosObj1[2,2], _aPosObj1[2,3], _aPosObj1[2,4], 0,/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999,  /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	_oGetDados:oBrowse:bLDblClick := {|| fKill()}

	@ _aPosObj2[2,1], _aPosObj2[2,2] GROUP oGpMRP1 TO _aPosObj2[2,3], _aPosObj2[2,4] PROMPT "Servidores..." OF _oDlg COLOR 0, 16777215 PIXEL
	_oGdServer := MsNewGetDados():New(_aPosObj2[2,1]+10, _aPosObj2[2,2]+5, _aPosObj2[2,3]-5, _aPosObj2[2,4]-5, 0,/*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, 9999,  /*cFieldOK*/, /*[ cSuperDel]*/, /*[ cDelOk]*/, _oDlg, _aHSrv, _aCSrv)

	@ _aPosObj1[3][1], _aPosObj1[3][2] GROUP oGpBut TO _aPosObj1[3][3], _aPosObj1[3][4] PROMPT "Opções..." OF _oDlg COLOR 0, 16777215 PIXEL

	oBtnBar := FwButtonBar():New()
	oBtnBar:Init(oGpBut, 018, 018, CONTROL_ALIGN_BOTTOM, .T.)
	oBtnBar:AddBtnText('Sair'		, 'Fecha a tela.'									, {|| _oDlg:End() },,,CONTROL_ALIGN_RIGHT, .T.)
	oBtnBar:AddBtnText('Atualizar(F5)'		, 'Atualiza os Dados'									, {|| U_BFG116VL() },,,CONTROL_ALIGN_LEFT, .T.)

	U_BFG116VL()

	ACTIVATE DIALOG _oDlg CENTERED

	SetKey(VK_F5,Nil)

Return

Static Function fMontaHead()

	Aadd(_aHeader,{" "			 ,"CANCEL","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Usuário"         ,"USER"     ,"@!"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Computador"      ,"COMPUT"     ,"@!"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Thread"          ,"TID"      ,"@!"               , 10   , 0,,, "N",, })      	// 1
	aAdd(_aHeader,{"Servidor"        ,"SERVER"   ,"@!"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"IP"         	,"IP"     ,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Porta"         	,"PORTA"     ,"@!"               , 6   , 0,,, "N",, })      	// 1
	aAdd(_aHeader,{"Ambiente"        ,"AMBIENTE" ,"@!"               , 20   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Tempo Exec."     ,"TEMPO"    ,"@!"               , 08   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Função"          ,"FUNC"   ,"@!"               , 20  , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Rotina"          ,"ROTINA"   ,"@!"               , 200  , 0,,, "C",, })      	// 1

	Aadd(_aHSrv,{" "			 ,"CSTATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHSrv,{"IP"         ,"IP"     ,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(_aHSrv,{"Porta"         ,"PORTA"     ,"@!"               , 6   , 0,,, "N",, })      	// 1
	aAdd(_aHSrv,{"Ambiente"         ,"ENV"     ,"@!"               , 30   , 0,,, "C",, })      	// 1
	aAdd(_aHSrv,{""         ,""     ,"@!"               , 10   , 0,,, "C",, })      	// 1

Return

Static Function fMontaCols()

	Local _aRet		:=	U_BIAFG115(_cCGrupos)
	Local _cIp
	Local _nPorta
	Local _cFuncao
	Local _nI

	_aCols	:=	{}
	_aCSrv	:=	{}

	If Len(_aRet[2]) > 0
		For _nI	:=	1 to Len(_aRet[2])
			_cIp	:=	_aRet[2,_nI,Len(_aRet[2,_nI]),1]
			_nPorta	:=	_aRet[2,_nI,Len(_aRet[2,_nI]),2]
			_cFuncao	:=	_aRet[2,_nI,Len(_aRet[2,_nI]),3]
			aAdd(_aCols,{"CANCEL",_aRet[2,_nI,1],_aRet[2,_nI,2],_aRet[2,_nI,3],_aRet[2,_nI,4],_cIp,_nPorta,_aRet[2,_nI,6],_aRet[2,_nI,8],_cFuncao,_aRet[2,_nI,11],.F.})
		Next
	Else
		aAdd(_aCols,{"","","",0,"","",0,"","","","",.F.})

	EndIF

	If Len(_aRet[1]) > 0
		For _nI	:=	1 to Len(_aRet[1])
			aAdd(_aCSrv,{Iif(_aRet[1,_nI]:lOnLine,"BR_VERDE","BR_VERMELHO"),_aRet[1,_nI]:cIp,_aRet[1,_nI]:nPorta,_aRet[1,_nI]:cAmbiente,"",.F.})
		Next
	Else
		aAdd(_aCSrv,{"BR_VERMELHO","",0,"","",.F.})
	EndIf

Return

Static Function fRefresh()

	fMontaCols()

	_oGetDados:aCols	:=	_aCols
	_oGdServer:aCols	:=	_aCSrv

	_oGetDados:Refresh()
	_oGdServer:Refresh()

Return

Static Function fGetGrupos()

	Local _aGrupos	:=	{}
	Local _cAlias	:=	GetNextAlias()

	_cCGrupos	:=	""

	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZDA% ZDA
		WHERE %NotDel%
		AND ZDA_CODGRP = '000001'

	EndSql

	While (_cAlias)->(!EOF())
		If Empty(_cCGrupos)
			_cCGrupos	:=	(_cAlias)->ZDA_CODGRP
		EndIf
		aAdd(_aGrupos,(_cAlias)->ZDA_CODGRP + "=" + Alltrim((_cAlias)->ZDA_DESGRP))

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

Return _aGrupos

User Function BFG116VL()

	U_BIAMsgRun("Aguarde... Carregando dados",,{|| fRefresh() })

Return .T.

Static Function fKill()

	Local _nAt	:=	_oGetDados:nAt
	Local _nPosUsr	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "USER"})
	Local _nPosPc	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "COMPUT"})
	Local _nPosThr	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "TID"})
	Local _nPosSrv	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "SERVER"})
	Local _nPosEnv	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "AMBIENTE"})
	Local _nPosIp	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "IP"})
	Local _nPosPorta	:=	aScan(_oGetDados:aHeader,{|x| Alltrim(x[2]) == "PORTA"})

	Local _cUser	:=	_oGetDados:aCols[_nAt,_nPosUsr]
	Local _cComp	:=	_oGetDados:aCols[_nAt,_nPosPc]
	Local _nThread	:=	_oGetDados:aCols[_nAt,_nPosThr]
	Local _cServer	:=	_oGetDados:aCols[_nAt,_nPosSrv]
	Local _cEnv		:=	_oGetDados:aCols[_nAt,_nPosEnv]
	Local _cIp		:=	_oGetDados:aCols[_nAt,_nPosIp]
	Local _nPorta		:=	_oGetDados:aCols[_nAt,_nPosPorta]

	Local _oRpc

	MsgInfo("Função temporariamente indisponível!")
	Return

	If _oGetDados:oBrowse:COLPOS == 1 .And. !Empty(_oGetDados:aCols[_oGetDados:nAt,1])

		If !MsgYesno("Tem certeza que deseja derrubar a conexão?")
			U_BFG116VL()
			Return
		EndIf

		_oRpc	:=	TRPC():New( _cEnv )

		If _oRpc:Connect( _cIp, _nPorta)

			_oRpc:CallProc("U_BFG116KL", _cUser,_cComp,_nThread,_cServer)
		Else

			MsgInfo("Falha ao derrubar conexão!")

		EndIf
		U_BFG116VL()
	EndIf
Return

User Function BFG116KL(_cUser,_cComp,_nThread,_cServer)

	KillUser(_cUser,_cComp,_nThread,_cServer)

Return

User Function BFG116PR()

	Local _lRet

	If lCheckBo1
		If MsgYesNo("Tem certeza que deseja bloquear as movimentações de rotinas concorrentes com o Recálculo do Custo Médio?")
			PutMv("MV_YBLQRCM",lCheckBo1)
		Else
			lCheckBo1	:=	!lCheckBo1
		EndIf
	Else
		If MsgYesNo("Tem certeza que deseja desbloquear as movimentações de rotinas concorrentes com o Recálculo do Custo Médio?")
			PutMv("MV_YBLQRCM",lCheckBo1)
		Else
			lCheckBo1	:=	!lCheckBo1
		EndIf
	EndIF
	oCheckbo1:Refresh()

Return