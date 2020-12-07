#include "PROTHEUS.CH"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFROPRT06	บAutor  ณFernando Rocha      บ Data ณ 14/01/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ APAGAR RESERVAS TEMPORARIAS - JOB						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BIANCOGRES												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPRT06()

	Local xv_Emps    := U_BAGtEmpr("01_05_07_13")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 
		//Gera o html do WF.
		Processa({|| ProcRT06()})

		RpcClearEnv()
	Next nI 

Return

Static Function ProcRT06()

	Local cAliasSC0
	Local cAliasPZ0
	Local _cContent  
	Local _nTDelRTmp


	Local cFiltroSC0	:= "% C0_FILIAL = '01' %"
	Local cFiltroPZ0	:= "% PZ0_FILIAL = '01' %"
	
	
	If (cEmpAnt == '07')
		cFiltroSC0	:= "% C0_FILIAL = '05' %"
		cFiltroPZ0	:= "% PZ0_FILIAL = '05' %"
	EndIf
	
	
	//Selecionar/Excluir reservas temporarias Sc0 acima do tempo permitido

	//parametro depois de quantas horas mata reservas temporarias
	_nTDelRTmp := GetNewPar("FA_RDELRT", 0.5)  //Numerico - tempo em hora para delecao de reservas temporarias

	cAliasSC0 := GetNextAlias()
	BeginSql Alias cAliasSC0
		%NoParser%
			
		SELECT              
		REC = SC0.R_E_C_N_O_
		,SC0.*
		FROM %TABLE:SC0% SC0 (nolock)
		WHERE
		//C0_FILIAL = '01'
		%EXP:cFiltroSC0%
		AND C0_YTEMP = 'S'
		AND ((C0_YHORA = '' AND C0_EMISSAO < convert(varchar(8), getdate(), 112 ))
		OR (C0_YHORA <> '' AND (CONVERT(DECIMAL(12, 2), datediff(mi, convert(smalldatetime, RTRIM(C0_EMISSAO)+' '+RTRIM(C0_YHORA)), convert(smalldatetime, getdate()) )) / 60.0 > %EXP:_nTDelRTmp%)  )
		)
		AND D_E_L_E_T_ = ''

	EndSql 

	MemoWrite("\FROPRT06_SC0.TXT", GetLastQuery()[2])

	(cAliasSC0)->(DbGoTop())
	While !(cAliasSC0)->(Eof())

		_cContent := (cAliasSC0)->C0_EMISSAO
		SC0->(DbSetOrder(1))
		If SC0->(FieldPos("C0_YHORA")) > 0
			_cContent := (cAliasSC0)->C0_EMISSAO+(cAliasSC0)->C0_YHORA
		EndIf

		SC0->(DbSetOrder(0))	
		SC0->(DbGoTo((cAliasSC0)->REC))	
		If !SC0->(Eof())

			U_GravaPZ2((cAliasSC0)->REC,"SC0",(cAliasSC0)->(C0_FILIAL+C0_NUM+C0_PRODUTO),"DELTEMP",AllTrim(FunName()),"TMP", "SISTEMA")

			__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

			a430Reserv({3,"VD","",(cAliasSC0)->C0_SOLICIT,(cAliasSC0)->C0_FILIAL},;
			(cAliasSC0)->C0_NUM,;
			(cAliasSC0)->C0_PRODUTO,;
			(cAliasSC0)->C0_LOCAL,;
			(cAliasSC0)->C0_QUANT,;
			{	(cAliasSC0)->C0_NUMLOTE,;
			(cAliasSC0)->C0_LOTECTL,;
			(cAliasSC0)->C0_LOCALIZ,;
			(cAliasSC0)->C0_NUMSERI})

			U_FRCHKSDC(__cChaveSDC, "FROPRT06")

		EndIf

		(cAliasSC0)->(DbSkip())
	EndDo 

	If Select(cAliasSC0) > 0
		(cAliasSC0)->(DbCloseArea())
	EndIf

	//Selecionar/Excluir reservas temporarias PZ0 acima do tempo permitido
	cAliasPZ0 := GetNextAlias()
	BeginSql Alias cAliasPZ0
		%NoParser%
				
		SELECT
		REC = R_E_C_N_O_
		,PZ0.*
		FROM %TABLE:PZ0% PZ0 (nolock)
		WHERE
		//PZ0_FILIAL = '01'
		%EXP:cFiltroPZ0%
		AND PZ0_STATUS = 'T'
		AND (PZ0_HORINC <> '' AND (CONVERT(DECIMAL(12, 2), datediff(mi, convert(smalldatetime, RTRIM(PZ0_DATINC)+' '+RTRIM(PZ0_HORINC)), convert(smalldatetime, getdate()) )) / 60.0 > %EXP:_nTDelRTmp%)  )
		AND D_E_L_E_T_ = ''

	EndSql 

	MemoWrite("\FROPRT06_PZ0.TXT", GetLastQuery()[2])

	(cAliasPZ0)->(DbGoTop())
	While !(cAliasPZ0)->(Eof())

		_cContent := (cAliasPZ0)->PZ0_DATINC+(cAliasPZ0)->PZ0_HORINC

		PZ0->(DbSetOrder(0))	
		PZ0->(DbGoTo((cAliasPZ0)->REC))

		If !PZ0->(Eof())

			U_GravaPZ2((cAliasPZ0)->REC,"PZ0",(cAliasPZ0)->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"DELTEMP",_cContent,"TMP", "SISTEMA")

			RecLock("PZ0",.F.)
			PZ0->(DbDelete())
			PZ0->(MsUnlock())

		EndIf

		(cAliasPZ0)->(DbSkip())
	EndDo 

	If Select(cAliasPZ0) > 0
		(cAliasPZ0)->(DbCloseArea())
	EndIf

Return()
