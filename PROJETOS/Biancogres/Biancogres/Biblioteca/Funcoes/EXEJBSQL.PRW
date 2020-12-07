#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"


/*/{Protheus.doc} EXEJBSQL
//TODO Descrição auto-gerada.
@author ferna
@since 16/09/2019
@version 1.0
@param oProcess, object, descricao
@type function
/*/
User Function EXEJBSQL(nSrvDB, cJobName, cTitle)

	Local oProcess	
	Default cTitle := "Processando JOB"
	Default nSrvDB := Iif( "PROD" $ Upper(AllTrim(getenvserver())) , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	oProcess := MsNewProcess():New({|lEnd| ExecProc(@oProcess, nSrvDB, cJobName) }, cTitle+" ("+AllTrim(nSrvDB)+")", "Job: "+AllTrim(cJobName), .T.)
	oProcess:Activate()

Return

Static Function ExecProc(oProcess, nSrvDB, cJobName)

	Local cAliasTmp
	Local cSQL
	Local MSGER	

	cSQL := " EXEC "+nSrvDB+".msdb.dbo.sp_start_job N'"+cJobName+"' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(cSQL)})

	mCtrFimJob := .F. 
	oProcess:SetRegua1(100000)
	oProcess:SetRegua2(100000)             
	hhTmpINI      := TIME()
	oProcess:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oProcess:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		cSQL := " EXEC "+nSrvDB+".msdb.dbo.sp_help_job "
		cSQL += "    @job_name = N'"+cJobName+"', "
		cSQL += "    @job_aspect = N'JOB', "
		cSQL += "    @execution_status = 1 "

		cAliasTmp := GetNextAlias()
		MScIndex := CriaTrab(Nil,.f.)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),(cAliasTmp),.F.,.T.)

		(cAliasTmp)->(dbGoTop())

		If (cAliasTmp)->(Eof())
			mCtrFimJob := .T.
		Else
			Sleep( 1000 )
		End

		(cAliasTmp)->(dbCloseArea())

		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

	EndDo

Return