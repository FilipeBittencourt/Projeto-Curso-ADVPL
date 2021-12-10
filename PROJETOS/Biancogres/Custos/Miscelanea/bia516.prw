#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA516
@author Marcos Alberto Soprani
@since 10/09/21
@version 1.0
@description Processa JOB de carga de dados para RAC
@type function
@Obs Projeto A-46 - Migrar Consultas e Visões do RAC/SAP para o RAC/PwBI
/*/

User Function BIA516()

	Local oPrcFctC

	If MsgNoYes("Necessário confirmar para prosseguir com a carga de dados do RAC para PwBI. Confirmar Processamento?","Confirmação.")

		oPrcFctC := MsNewProcess():New({|lEnd| B516FctG(@oPrcFctC) }, "Carga de Dados", "Data Warehouse DW -> RAC", .T.)
		oPrcFctC:Activate()

		MsgINFO("Processamento Realizado com Sucesso: o Job |DW -> RAC| está concluído neste momento. Favor solicitar que seja feita a carga no Front-End.", "Atenção!!!")

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function B516FctG(oPrcFctC)

	Local MS007
	Local nSrvDB := Iif( !U_fValDEV() , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC " + nSrvDB + ".msdb.dbo.sp_start_job N'DW -> RAC' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(MS007)})

	mCtrFimJob := .F. 
	oPrcFctC:SetRegua1(1000)
	oPrcFctC:SetRegua2(1000)             
	hhTmpINI      := TIME()
	oPrcFctC:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oPrcFctC:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC " + nSrvDB + ".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'DW -> RAC', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

	End

Return
