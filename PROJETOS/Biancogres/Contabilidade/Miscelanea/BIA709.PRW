#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA709
@author Marcos Alberto Soprani
@since 09/07/21
@version 1.0
@description Processa JOB de carga de dados para ODS/ETL - A-35
@type function
@Obs Projeto A-35 - DRE
/*/

User Function BIA709()

	Private xkOpcao

	If ValidPerg()

		xkOpcao := MV_PAR01

		If xkOpcao == "1"       // Processamento do JOB

			U_BIA709P()

		ElseIf xkOpcao == "2"   // Acompanhamento do JOB

			U_BIA709A()

		Else

			MsgALERT("Opção Indisponível. Processamento Abortado", "Atenção!!!")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "Atenção!!!")

	EndIf

Return

Static Function ValidPerg()

	local cLoad	    := "BIA709" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	"0"

	aAdd(aPergs, {2, "Escolha uma Opção:",  MV_PAR01, {"1=Processamento do JOB", "2=Acompanhamento do JOB"},   090, ".T.", .F.})

	If ParamBox(aPergs ,"Processa Carga Data Warehouse",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

User Function BIA709P()

	Local oPrcDimC
	Local oPrcFctC
	Local mCtrFimJob := .F. 

	MS004 := " EXEC " + nSrvDB + ".msdb.dbo.sp_help_job "
	MS004 += "    @job_name = N'DW -> DRE Contabil', "
	MS004 += "    @job_aspect = N'JOB', "
	MS004 += "    @execution_status = 1 "
	MScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
	dbSelectArea("MS04")
	dbGoTop()
	If Eof()
		mCtrFimJob := .T.
	End

	MS04->(dbCloseArea())
	Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(MScIndex+OrdBagExt())          //indice gerado

	If mCtrFimJob

		oPrcDimC := MsNewProcess():New({|lEnd| B709DimC(@oPrcDimC) }, "Carga de Dados", "Data Warehouse DW -> Controladoria Dims", .T.)
		oPrcDimC:Activate()

		Sleep( 5000 )

		oPrcFctC := MsNewProcess():New({|lEnd| B709FctG(@oPrcFctC) }, "Carga de Dados", "Data Warehouse DW -> DRE Contabil", .T.)
		oPrcFctC:Activate()

	Else

		MsgALERT("O Job |DW -> DRE Contabil| está processando neste momento. Acesse a rotina pela opção Consulta para acompanhar o termino.", "Processamento Job SQL!")

	EndIf

Return

Static Function B709DimC(oPrcDimC)

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

Static Function B709FctG(oPrcFctC)

	Local MS007
	Local nSrvDB  := Iif( !U_fValDEV() , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV
	Local nContad := 0

	MS007 := " EXEC " + nSrvDB + ".msdb.dbo.sp_start_job N'DW -> DRE Contabil' "
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
		MS004 += "    @job_name = N'DW -> DRE Contabil', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
			Exit
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

		nContad ++
		If nContad > 10
			MsgSTOP("O Job |DW -> DRE Contabil| possui uma carga de dados longa: a carga irá prosseguir apesar de interrompido a barra de progressão. Acesse a rotina pela opção Consulta para verificar se já terminou", "Consulta Job SQL!")
			Exit
		EndIf

	End

	If mCtrFimJob
		MsgINFO("O Job |DW -> DRE Contabil| está parada neste momento. Se tiver concluíndo alguma carga por agora, favor solicitar que seja feita a carga no Front-End.", "Consulta Job SQL!")
	EndIf

Return

User Function BIA709A()

	Local oPrcConl

	oPrcConl := MsNewProcess():New({|lEnd| B709Consl(@oPrcConl) }, "Carga de Dados", "Data Warehouse DW -> DRE Contabil", .T.)
	oPrcConl:Activate()

Return

Static Function B709Consl(oPrcConl)

	Local nSrvDB  := Iif( !U_fValDEV() , "HERMES" , "HIMEROS" ) //TRATAMENTO PARA DIFERENCIAR AMBIENTE DE PRD E DEV
	Local nContad := 0

	mCtrFimJob := .F. 
	oPrcConl:SetRegua1(1000)
	oPrcConl:SetRegua2(1000)             
	hhTmpINI      := TIME()
	oPrcConl:IncRegua1("Executando JOB...")
	Sleep( 5000 )
	While !mCtrFimJob

		oPrcConl:IncRegua2("JOB em progresso a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )   

		MS004 := " EXEC " + nSrvDB + ".msdb.dbo.sp_help_job "
		MS004 += "    @job_name = N'DW -> DRE Contabil', "
		MS004 += "    @job_aspect = N'JOB', "
		MS004 += "    @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.F.,.T.)
		dbSelectArea("MS04")
		dbGoTop()
		If Eof()
			mCtrFimJob := .T.
			Exit
		Else
			Sleep( 1000 )
		End

		MS04->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

		nContad ++
		If nContad > 10
			MsgSTOP("O Job |DW -> DRE Contabil| possui uma carga de dados longa: a carga irá prosseguir apesar de interrompido a barra de progressão. Acesse a rotina pela opção Consulta para verificar se já terminou", "Consulta Job SQL!")
			Exit
		EndIf

	End

	If mCtrFimJob
		MsgINFO("O Job |DW -> DRE Contabil| está parada neste momento. Se tiver concluíndo alguma carga por agora, favor solicitar que seja feita a carga no Front-End.", "Consulta Job SQL!")
	EndIf

Return
