#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA708
@author Marcos Alberto Soprani
@since 23/07/21
@version 1.0
@description Processa JOB de carga de dados para ODS/ETL
@type function
@Obs Projeto A-59 - Gestão Matricial de Tributos
/*/

User Function BIA708()

	Local oPrcDimC
	Local oPrcFctC

	If MsgNoYes("Necessário confirmar para prosseguir com a carga de dados do GMT para PwBI. Confirmar Processamento?","Confirmação.")

		oPrcDimC := MsNewProcess():New({|lEnd| B708DimC(@oPrcDimC) }, "Carga de Dados", "Data Warehouse DW -> Controladoria Dims", .T.)
		oPrcDimC:Activate()

		Sleep( 5000 )

		oPrcFctC := MsNewProcess():New({|lEnd| B708FctG(@oPrcFctC) }, "Carga de Dados", "Data Warehouse DW -> GMT", .T.)
		oPrcFctC:Activate()

		MsgINFO("Processamento Realizado com Sucesso: o Job |DW -> GMT| está concluído neste momento. Favor solicitar que seja feita a carga no Front-End.", "Atenção!!!")

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function B708DimC(oPrcDimC)

	Local MS007
	Local nSrvDB := Iif( !U_fValDEV() , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC " + nSrvDB + ".msdb.dbo.sp_start_job N'DW -> Controladoria Dims' "
	U_BIAMsgRun("Start JOB... Aguarde... ",,{|| TcSQLExec(MS007)})

	mCtrFimJob := .F. 
	oPrcDimC:SetRegua1(1000)
	oPrcDimC:SetRegua2(1000)             
	hhTmpINI      := TIME()
	oPrcDimC:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oPrcDimC:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC " + nSrvDB + ".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'DW -> Controladoria Dims', "
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

Static Function B708FctG(oPrcFctC)

	Local MS007
	Local nSrvDB := Iif( !U_fValDEV() , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV

	MS007 := " EXEC " + nSrvDB + ".msdb.dbo.sp_start_job N'DW -> GMT' "
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
		MS004 += "    @job_name = N'DW -> GMT', "
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
