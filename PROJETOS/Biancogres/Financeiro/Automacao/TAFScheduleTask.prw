#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFScheduleTask
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe para execucao de tarefas agendadas
@type class
/*/

Class TAFScheduleTask From LongClassName

	Data cTipo // R=Receber; P=Pagar
	Data oLst // Lista de objetos
	
	Method New() Constructor
	Method Get()
	Method ChkJobExec(_cRotina)
	Method ExecJob(_cTimeRun)
	Method GetParams(_cCodigo)
	
EndClass


Method New() Class TAFScheduleTask

	::cTipo := "P"
	::oLst := ArrayList():New()

Return()


Method Get() Class TAFScheduleTask

	Local aEmpFil, aFil
	Local nX, nCount

	aEmpFil := &(AllTrim(ZK5->ZK5_EMPFIL))
	SM0->(DbSetOrder(1))

	If ValType(aEmpFil) == "A"

		For nX := 1 To Len(aEmpFil)

			If aEmpFil[nX][2] <> "XX"

				If SM0->(DbSeek(aEmpFil[nX][1]+aEmpFil[nX][2]))

					oObj := TIAFEmpresa():New()
		
					oObj:cEmp := aEmpFil[nX][1]
					oObj:cFil := aEmpFil[nX][2]
		
					::oLst:Add(oObj)
	
				EndIf
			
				//XX = Todas as filiais da Empresa
			Else
			
				aFil := FWAllFilial(,,aEmpFil[nX][1])
			
				For nCount := 1 To Len(aFil)
			
					oObj := TIAFEmpresa():New()
			
					oObj:cEmp := aEmpFil[nX][1]
					oObj:cFil := aFil[nCount]
		
					::oLst:Add(oObj)
				
				Next
					
			EndIF
		
		Next nX
	
	EndIf
		
Return()


/*/{Protheus.doc} ChkJobExec
@description Checkar dia/horario de execucao de tarefa e disparar metodo de execucao
@author Fernando Rocha
@since 15/02/2019
@version 1.0
@type function
/*/
Method ChkJobExec(_cRotina) class TAFScheduleTask

	Local _aPar

	ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ChkJobExec["+_cRotina+"] -> Iniciando.")
	
	ZK5->(DbSetOrder(1))
	If ZK5->(DbSeek(XFilial("ZK5")+_cRotina))

		_nDiaSem 	:= DOW(Date())
		_cTimeExec 	:= SubStr(Time(),1,5)

		ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ChkJobExec["+_cRotina+"] -> Verificando Dia/Horario.")
		ConOut("ChkJobExec => DOW="+Str(_nDiaSem))
		ConOut("ChkJobExec => TIME EXEC="+_cTimeExec)


		If (ZK5->ZK5_TIPEXE == "1")

			_cHora 		:= SubStr(_cTimeExec,1,2)
			_nMinuto	:= Val(SubStr(_cTimeExec,4,2))
			_cMinuto	:= "00"

			While _nMinuto >= 0

				_cMinuto := StrZero(_nMinuto, 2)

				If ( _cMinuto $ "00_05_10_15_20_25_30_35_40_45_50_55")

					exit

				EndIf

				_nMinuto := _nMinuto - 1

			EndDo

			_cTimeComp		:= _cHora+":"+_cMinuto
			_cTimeAntComp 	:= _cHora+":"+StrZero((_nMinuto - 5), 2)
			
			ConOut("ChkJobExec => TIME COMPARE="+_cTimeComp+", TIME ANTERIOR COMPARE="+_cTimeAntComp)


			If 	( ZK5->ZK5_DIAS1 .And. _nDiaSem == 1 ) .Or.;
					( ZK5->ZK5_DIAS2 .And. _nDiaSem == 2 ) .Or.;
					( ZK5->ZK5_DIAS3 .And. _nDiaSem == 3 ) .Or.;
					( ZK5->ZK5_DIAS4 .And. _nDiaSem == 4 ) .Or.;
					( ZK5->ZK5_DIAS5 .And. _nDiaSem == 5 ) .Or.;
					( ZK5->ZK5_DIAS6 .And. _nDiaSem == 6 ) .Or.;
					( ZK5->ZK5_DIAS7 .And. _nDiaSem == 7 )


				_cTime := ZK5->ZK5_TIME

				ConOut("ChkJobExec => ZK5_TIME="+_cTime)

				If 	(( _cTimeComp $ AllTrim(_cTime)) .Or. ( _cTimeAntComp $ AllTrim(_cTime))) .And.;
						( ZK5->ZK5_ULTDAT 	<>	 dDataBase .Or. ;
						   (ZK5->ZK5_ULTHOR	<>	_cTimeComp .And.;
							ZK5->ZK5_ULTHOR	<>	_cTimeAntComp) )
							
					::ExecJob(_cTimeComp)
				
				Else
				
					ConOut("ChkJobExec => ::ExecJob() - [Agendamento] - Fora do intervalo de processamento")
					
				EndIF


			EndIf

		Else

			If 	( ZK5->ZK5_DIAS1 .And. _nDiaSem == 1 ) .Or.;
					( ZK5->ZK5_DIAS2 .And. _nDiaSem == 2 ) .Or.;
					( ZK5->ZK5_DIAS3 .And. _nDiaSem == 3 ) .Or.;
					( ZK5->ZK5_DIAS4 .And. _nDiaSem == 4 ) .Or.;
					( ZK5->ZK5_DIAS5 .And. _nDiaSem == 5 ) .Or.;
					( ZK5->ZK5_DIAS6 .And. _nDiaSem == 6 ) .Or.;
					( ZK5->ZK5_DIAS7 .And. _nDiaSem == 7 )


				_cHorIni := IIf(!Empty(ZK5->ZK5_HORINI),ZK5->ZK5_HORINI,"00:00")
				_cHorFim := IIf(!Empty(ZK5->ZK5_HORFIM),ZK5->ZK5_HORFIM,"24:00")

				If ( _cTimeExec >= _cHorIni .And. _cTimeExec <= _cHorFim )

					::ExecJob(_cTimeExec)
				
				Else
				
					ConOut("ChkJobExec => ::ExecJob() - [Continuo] - Fora do intervalo de processamento")
									
				EndIF
					
			EndIf

		EndIF

	EndIf

Return

/*/{Protheus.doc} GetParams
@description Processar a job selecionada
@author ferna
@since 19/02/2019
@version 1.0
@param _cRotina, , descricao
@type function
/*/
Method ExecJob(_cTimeRun) class TAFScheduleTask

	Local _aPar
	Local _aEmpFil
	Local _cRotina := AllTrim(ZK5->ZK5_ROTINA)
	Local _cCodigo := AllTrim(ZK5->ZK5_CODIGO)
	Local nCount
	Local cEmpBkp := CEMPANT
	Local cFilBkp := CFILANT

	ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ExecJob["+_cRotina+"] -> EXECUTANDO PROCESSO. ")

	_aPar := ::GetParams(_cCodigo)
	::Get()

	IF ::oLst:GetCount() > 0

		//limpando ambiente de controle de execucao
		RpcClearEnv()

		//inicializar ambiente de cada empresa selecionada e disparar rotina
		For nCount := 1 To ::oLst:GetCount()

			ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ExecJob["+_cRotina+"] -> EXECUTANDO PROCESSO ==> EMPRESA:"+::oLst:GetItem(nCount):cEmp+" - FILIAL:"+::oLst:GetItem(nCount):cFil+". ")

			RpcSetEnv(::oLst:GetItem(nCount):cEmp, ::oLst:GetItem(nCount):cFil)

			EXECBLOCK(_cRotina,.F.,.F.,_aPar)

			RpcClearEnv()

			ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ExecJob["+_cRotina+"] -> FIM PROCESSO ==> EMPRESA:"+::oLst:GetItem(nCount):cEmp+" - FILIAL:"+::oLst:GetItem(nCount):cFil+". ")

		Next nCount

		// Recuperar ambiente de controle de execucao
		RpcSetEnv(cEmpBkp, cFilBkp)
		
	ENDIF

	ZK5->(DbSetOrder(2))
	If ZK5->(DbSeek(XFilial("ZK5")+_cCodigo))

		RecLock("ZK5",.F.)
		ZK5->ZK5_ULTDAT := dDataBase
		ZK5->ZK5_ULTHOR := _cTimeRun
		ZK5->(MsUnlock())

	EndIf

	ConOut("[THREAD: "+AllTrim(Str(ThreadId()))+"] TAFScheduleTask -> ChkJobExec["+_cRotina+"] -> FIM PROCESSO. ")

Return


/*/{Protheus.doc} GetParams
@description Processar e montar vetor para passar como parametro para rotina
@author ferna
@since 19/02/2019
@version 1.0
@param _cRotina, , descricao
@type function
/*/
Method GetParams(_cCodigo) class TAFScheduleTask

	Local aRet := Nil

	ZK6->(DbSetOrder(1))
	IF ZK6->(DbSeek(XFilial("ZK6")+_cCodigo))

		aRet := {}

		While !ZK6->(Eof()) .And. ZK6->ZK6_CODIGO == _cCodigo

			AAdd(aRet, (ZK6->ZK6_FORMUL))

			ZK6->(DbSkip())
		EndDo

	EndIF

Return(aRet)