#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Classe Para tratar concorrência entre rotinas
@author Gabriel Mafioletti
@since 02/12/2019
@version 1.0
@type class
/*/

User Function BSemTsT1

	Local _oSemaforo

	RpcSetType(3)
	RpcSetEnv('01','01')

	_oSemaforo	:=	TBiaSemaforo():New()

	_oSemaforo:cGrupo	:=	"TESTE_FERNANDO"

	//_oSemaforo:cLogLock := "Existem Rotinas Concorrentes sendo executadas no momento." + CRLF
	//_oSemaforo:cLogLock += "Rotina: " + "Rotina Super AUtomatica teste 1" + CRLF
	//_oSemaforo:cLogLock += "Data: " + DtoC(Date()) + CRLF
	//_oSemaforo:cLogLock += "Rotina: " + Time() + CRLF
	//_oSemaforo:cLogLock += "Usuário: " + "USUARIO TESTE DA SILVA" + CRLF
	//_oSemaforo:ShowAlert()

	//_oSemaforo:nCntTRot := 10
	_lRet := _oSemaforo:GeraSemaforo("TESTE_FERNANDO")

	_oSemaforo:LiberaSemaforo()

	If (_lRet)
		MSGALERT( "PROCESSO OK" )
	EndIf

	RpcClearEnv()

Return

	Class TBiaSemaforo From LongClassName

		Data cGrupo
		Data cPasta
		Data cErro
		Data nHandle
		Data nRecno
		Data lShowMsg
		Data cRotina
		Data oTimer
		Data cLogLock
		Data nCntTimer
		Data nCntTRot
		Data oLblTime
		Data oDlgLock
		Data IsOk

		Method New() Constructor
		Method GeraSemaforo(_cRotina)
		Method LiberaSemaforo()
		Method ShowAlert()
		Method TimerExec()

	EndClass

Method New() Class TBiaSemaforo

	::cGrupo	:=	""
	::cErro		:=	""
	::nHandle	:=	0
	::cPasta	:=	"BIA_SEMAFORO"
	::nRecno	:=	0
	::lShowMsg	:= .T.
	::cLogLock	:= ""
	::nCntTimer	:= 5
	::nCntTRot	:= ::nCntTimer
	::cRotina	:= ""
	::IsOk		:= .F.
	::oDlgLock	:= Nil
	::oLblTime	:= Nil
	::oTimer 	:= Nil

Return

Method GeraSemaforo(_cRotina) Class TBiaSemaforo

	Default _cRotina	:= FunName()

	If Empty(::cRotina)
		::cRotina := _cRotina
	EndIf

	ZKR->(DbSetOrder(1))

	If !ZKR->(DbSeek(xFilial("ZKR")+cEmpAnt+cFilAnt+PADR(::cGrupo,TAMSX3("ZKR_GRUPO")[1])))
		RecLock("ZKR",.T.)
		ZKR->ZKR_FILIAL	:=	xFilial("ZKR")
		ZKR->ZKR_EMP	:=	cEmpAnt
		ZKR->ZKR_FIL	:=	cFilAnt
		ZKR->ZKR_GRUPO	:=	::cGrupo
		ZKR->(MsUnlock())
	EndIF

	::nRecno	:=	ZKR->(RECNO())

	::IsOk	:=	ZKR->(Rlock())

	If ::IsOk

		ZKR->ZKR_DTLOCK		:=	Date()
		ZKR->ZKR_HRLOCK		:=	Time()
		ZKR->ZKR_USRLOC 	:=	UsrFullName(__cUserId)
		ZKR->ZKR_ROTLOCK	:=	::cRotina

		ZKR->(DbrUnlock(::nRecno))
		ZKR->(Rlock())

	Else
		::cLogLock := "Existem Rotinas Concorrentes sendo executadas no momento." + CRLF
		::cLogLock += "Rotina: " + ZKR->ZKR_ROTLOC + CRLF
		::cLogLock += "Data: " + DtoC(ZKR->ZKR_DTLOCK) + CRLF
		::cLogLock += "Rotina: " + ZKR->ZKR_HRLOCK + CRLF
		::cLogLock += "Usuário: " + ZKR->ZKR_USRLOC + CRLF

		If IsBlind() .Or. (!::lShowMsg)

			CONOUT("[CONTROLE DE LOCK] ==> "+AllTrim(FunName())+" - Rotina:"+_cRotina+" ==>"+::cLogLock)

		Else

			::ShowAlert()

		EndIf

	EndIf

Return ::IsOk

Method LiberaSemaforo() Class TBiaSemaforo

	ZKR->(DbrUnlock(::nRecno))

Return

Method ShowAlert() Class TBiaSemaforo

	::nCntTimer := ::nCntTRot

	::oDlgLock      := MSDialog():New( 080,200,250,600,"CONTROLE DE ROTINAS CONCORRENTES",,,.F.,,,,,,.T.,,,.T. )

	::oLblTime      := TSay():New( 010,010,{||::cLogLock},::oDlgLock,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,190,100)
	::oLblTime      := TSay():New( 060,010,{|| "Tentando novamente em "+AllTrim(Str(::nCntTimer))+" segundos..." },::oDlgLock,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,100)

	oBtnCancel 		:= TButton():New( 070,160,"CANCELAR",::oDlgLock,,037,012,,,,.T.,,"",,,,.F. )

	oBtnCancel:bAction 	:= {|| ::IsOk := .F., ::oTimer:DeActivate(), ::oDlgLock:End() }

	::oTimer 	:= TTimer():New(1000, {|| ::TimerExec() }, ::oDlgLock )
	::oTimer:Activate()

	::oDlgLock:Activate(,,,.T.)

Return()

Method TimerExec() Class TBiaSemaforo

	If ( ::nCntTimer > 0 )

		::nCntTimer := ::nCntTimer - 1
		::oLblTime:Refresh()
		::oDlgLock:Refresh()

	Else

		::oTimer:DeActivate()
		::oDlgLock:End()
		::nCntTimer := ::nCntTRot
		::GeraSemaforo()

	EndIf

Return