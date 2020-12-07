#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Classe Para tratar comncorrência entre rotinas
@author Gabriel Mafioletti
@since 04/11/2019
@version 1.0
@type class
/*/


Class tBiaMonitor From LongClassName

	Data aProcessos
	Data cGrupo
	Data lAdmin
	Data aServidores
	Data cErro


	Method New() Constructor
	Method Load() 
	Method GetGrupo()
	Method GetProcGrupo()
	Method GetAllServers()
	Method ChkConflito(_cGrupo)

EndClass


Method New() Class tBiaMonitor

	::aProcessos	:=	{}
	::lAdmin		:=	.F.
	::cGrupo		:=	""
	::aServidores	:=	{}
	::cErro			:=	""


Return

Method Load() Class tBiaMonitor

	Local _lRet	:=	.T.
	Local _nI
	Local _nJ
	Local _oRpc	
	Local _aProcessos

	For _nI	:=	1 to Len(::aServidores)
		_oRpc	:=	TRPC():New( ::aServidores[_nI]:cAmbiente )

		If _oRpc:Connect( ::aServidores[_nI]:cIp, ::aServidores[_nI]:nPorta) 

			::aServidores[_nI]:lOnline	:=	.T.

			_aProcessos := _oRpc:CallProc("GetUserInfoArray" )

			For _nJ	:=	1 to Len(_aProcessos)
				aAdd(_aProcessos[_nJ],{::aServidores[_nI]:cIp,::aServidores[_nI]:nPorta,""})
				aAdd(::aProcessos,_aProcessos[_nJ])
			Next

			_oRpc:Disconnect()
		Else
			::aServidores[_nI]:lOnline	:=	.F.
		EndIf	

	Next

Return _lRet

Method GetProcGrupo() Class tBiaMonitor

	Local _nI
	Local _nJ
	Local _aRet		:=	{}

	If !Empty(::cGrupo)

		aGrupo	:=	::GetGrupo()

		If Len(aGrupo) > 0
			For _nI	:=	1 to Len(aGrupo[1,3])
				For _nJ	:=	1 to  Len(::aProcessos)

					//AutoJobs a rotina executada fica na posicao 1 as vezes como no caso do FIN

					If aGrupo[1,3,_nI] $ ::aProcessos[_nJ,11] .OR. aGrupo[1,3,_nI] $ ::aProcessos[_nJ,1] 
						::aProcessos[_nJ,Len(::aProcessos[_nJ]),3]	:=	aGrupo[1,3,_nI]
						aAdd(_aRet,::aProcessos[_nJ])
					EndIf


				Next
			Next
		EndIf
	EndIf


Return _aRet

Method GetGrupo() Class tBiaMonitor

	Local _aGrupo	:=	{}
	Local _cAlias	:=	GetNextAlias()
	Local _cGrupo	:=	::cGrupo


	BeginSql Alias _cAlias

		SELECT *
		FROM %TABLE:ZDA% ZDA
		WHERE ZDA_CODGRP = %Exp:_cGrupo%
		AND %NotDel%

	EndSql

	While (_cAlias)->(!EOF())

		aAdd(_aGrupo,{(_cAlias)->ZDA_CODGRP, (_cAlias)->ZDA_DESGRP,StrToKarr(Alltrim((_cAlias)->ZDA_ROTINA),"/")})

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())
Return _aGrupo


Method GetAllServers(lAutoJobs) Class tBiaMonitor

	Local _aServer	:=	{}
	Local _cAlias	:=	GetNextALias()
	Default lAutoJobs := .T.


	BeginSql ALias _cAlias

		SELECT *
		FROM %TABLE:ZDB% ZDB
		WHERE ZDB_FILIAL = %XFILIAL:ZDB%
		AND %NotDel%

	EndSql

	While (_cAlias)->(!EOF())

		If lAutoJobs .And. (_cAlias)->ZDB_JOB == "1"
			aAdd(_aServer,{Alltrim((_cAlias)->ZDB_IP),(_cAlias)->ZDB_PORTA,Alltrim((_cAlias)->ZDB_AMBIEN)})
		ElseIf 	(_cAlias)->ZDB_JOB <> "1"
			aAdd(_aServer,{Alltrim((_cAlias)->ZDB_IP),(_cAlias)->ZDB_PORTA,Alltrim((_cAlias)->ZDB_AMBIEN)})
		EndIf

		(_cAlias)->(DbSkip())
	EndDo

Return _aServer


Method ChkConflito(_cGrupo) Class tBiaMonitor

	Local _aServers
	Local _cRotinas := ""
	Local nX
	Local _nI

	::cGrupo	:=	_cGrupo

	_aServers := ::GetAllServers()


	For _nI	:= 1 to Len(_aServers)

		_oSrv	:=	tBiaServidor():New()

		_oSrv:cIp		:=	_aServers[_nI,1]
		_oSrv:nPorta	:=	_aServers[_nI,2]
		_oSrv:cAmbiente	:=	_aServers[_nI,3]

		aAdd(::aServidores,_oSrv)	

	Next

	If ::Load()
		_aRotinas := ::GetProcGrupo()
	EndIF

	//Tem Conflito com rotinas em execucao
	If (  Len(_aRotinas) > 0 )

		For nX := 1 To Len(_aRotinas)

			_cRotinas += AllTrim(_aRotinas[nX][1])+">>>"+AllTrim(_aRotinas[nX][11])+CRLF

		Next nX

		If (! IsBlind())

			U_FROPMSG("Controle de Lock - Rotinas/Jobs", "Rotina em execucao que impedem esta de ser executada com segurança: "+CRLF+_cRotinas,,,"Existem rotinas em conflito, tente novamente mais tarde.")

		Else

			_cLog := "Rotina em execucao que impedem esta de ser executada com segurança: "+_cRotinas
			CONOUT("[CONTROLE DE LOCK] ==> [THREAD: "+ThreadId()+"] "+AllTrim(FunName())+" ==>"+_cLog)

		EndIf

		Return( .T. )

	EndIf

Return( .F. )


User Function BMONCHKC(_cGrupo)

	Local lRet := .F.

	LjMsgRun("Aguarde... verificando rotinas em conflito.",,{|| lRet := PRCChkConflito(_cGrupo) })

Return(lRet)

Static Function PRCChkConflito(_cGrupo)

	Local lRet := .F.

	oMonitor	:=	tBiaMonitor():New()
	lRet := oMonitor:ChkConflito(_cGrupo)

Return(lRet)


//PARA TESTES
User Function BMONTST1

	Local oMonitor

	RpcSetEnv("01", "01")

	oMonitor	:=	tBiaMonitor():New()
	oMonitor:ChkConflito("000002")

	RpcClearEnv()

Return
