#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} FACOWF01
@description Workflow de acompanhamento de acordos de objetivos
@author Fernando Rocha
@since 23/05/2017
@version undefined
@param _lManual, , descricao
@type function
/*/
User Function FACOWF01(_lManual)
	Local nCount := 0
	Local _cAux
	Local I
	Local nI
	Local xv_Emps
	Local _cTpAcord	 := ""
	Local _nTotBonus := 0

	Private cSQL := ""
	Private Qry := ""
	Private cHtml := ''
	Private _cRep
	Private lManual := _lManual

	//Ticket 28275 - Erro ao executar de forma manual. Pablo S. Nascimento
//	RPCSetType(3)
//	RpcSetEnv('01', '01')

	If (Upper(AllTrim(getenvserver())) == "SCHEDULE")
		lManual := .F.
	Else
		lManual := .T.
	EndIf

	Conout("FACOWF01 Inicio - lManual = "+IIf(lManual,"SIM","NAO"))

	If lManual
		xv_Emps := Array(1)
	Else
		xv_Emps    := U_BAGtEmpr("01_05")
	EndIf

	Private __CDATAINI
	Private __CDATAFIM
	Private __cAOINI	:= Space(6)
	Private __cAOFIM	:= Space(6)


	If lManual

		_aPergs := {}
		_aRet := { CTOD(" "), CTOD(" "), __cAOINI, __cAOFIM }
		aAdd( _aPergs ,{1,"Data de: " ,CTOD(" ") ,"","NAOVAZIO()",'','.T.',50,.F.})
		aAdd( _aPergs ,{1,"Data Ate:" ,CTOD(" ") ,"","NAOVAZIO()",'','.T.',50,.F.})
		aAdd( _aPergs ,{1,"Nº AO de" , __cAOINI, "", '', "",'.T.',20,.F.})
		aAdd( _aPergs ,{1,"Nº AO até", __cAOFIM, "", '', "",'.T.',20,.F.})


		IF !ParamBox(_aPergs ,"Workflow de acompanhamento de AO",_aRet,,,,,,,,.T.,.T.)
			Return
		ENDIF

		__CDATAINI := DTOS(_aRet[1])
		__CDATAFIM := DTOS(_aRet[2])
		__cAOINI  := _aRet[3]
		__cAOFIM  := _aRet[4]

	Else

		__CDATAINI := StrZero(Year(Date()),4)+'0101'
		__CDATAFIM := ""

	EndIf

	//Testar dias de execucao - somente 5, 15 e 25
	If !(Day(Date()) == 5 .Or. Day(Date()) == 15 .Or. Day(Date()) == 25) .And. (Upper(AllTrim(getenvserver())) == "SCHEDULE")
		Return
	EndIf

	For nI := 1 to Len(xv_Emps)

		//Inicializa o ambiente
		If !lManual
			RpcClearEnv()
			RPCSetType(3)
			WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2])
		EndIf

		//Atualiza realizado de todos os acordos em andamento da empresa
		If Upper(AllTrim(getenvserver())) == "SCHEDULE" .Or. Upper(AllTrim(getenvserver())) == "PRODUCAO"
			UpdAcordos()
		EndIf

		//query para base do workflow
		GetData()

		If !(Qry)->(Eof())

			While !(Qry)->(Eof())



				_cRep := (Qry)->PZ5_CODVEN
				_cCli := (Qry)->COD_CLI
				_cNCli := (Qry)->NOME_CLI
				_cCodPZ5 := (Qry)->PZ5_CODIGO
				_cTpAcord	:= (Qry)->TPACOR
				_nTotBonus 	:= 0

				_nMaxFaixa := Val((Qry)->MAXFAIXA)


				GetHeader()
				GetColumnHeader(_cRep, _nMaxFaixa, _cNCli, _cTpAcord)

				While !(Qry)->(Eof()) .And. (Qry)->PZ5_CODVEN == _cRep .And. (Qry)->COD_CLI == _cCli

					GetItems(_nMaxFaixa, _cTpAcord)

					_nTotBonus 	+= (QRY)->BONUS

					(Qry)->(DbSkip())
				EndDo

				cHtml += ' </table>
				GetFooter(_cTpAcord, _nTotBonus)
				SendMail(_cRep, _cCodPZ5)

				cHtml := ""


			EndDo

		EndIf

		(Qry)->(dbCloseArea())

		If lManual
			MsgInfo("Finalizado com sucesso!","Workflow Acompanhamento AO")
		Else
			//Encerra ambiente
			RpcClearEnv()
		EndIf

	Next nI

Return()

Static Function UpdAcordos()
	Local cAliasTmp

	cAliasTmp := GetNextAlias()
	BeginSQL Alias cAliasTmp
	%NOPARSER%

	SELECT DISTINCT PZ5_CODIGO
	FROM %TABLE:PZ6% PZ6
	JOIN %TABLE:PZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO
	WHERE
	PZ5_STATUS = 'S'
	AND PZ6_PERINI >= %EXP:StrZero(Year(Date()),4)+'0101'%
	AND PZ6_PERFIM > (convert(varchar(8),GetDate(),112))  
	AND PZ6_DTULRE <= (convert(varchar(8),GetDate(),112)) 
	AND PZ6.D_E_L_E_T_=''
	AND PZ5.D_E_L_E_T_='' 
	order by PZ5_CODIGO

	EndSQL

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		U_AO_UPREA((cAliasTmp)->PZ5_CODIGO)

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return


Static Function GetData()
	Local cExpFim 		:= ""
	Local cExpAOIni		:= ""
	Local cExpAOFim		:= ""
	Local cExpMaxPer	:= ""


	If !Empty(__CDATAFIM)
		cExpFim := "% PZ6_PERFIM <= '"+__CDATAFIM+"' %"
	Else
		cExpFim := "% 1 = 1 %"
	EndIf

	If !Empty(__cAOINI)
		cExpAOIni := "% PZ5_CODIGO >= '"+__cAOINI+"' %"
	Else
		cExpAOIni := "% 1 = 1 %"
	EndIf

	If !Empty(__cAOFIM)
		cExpAOFim := "% PZ5_CODIGO <= '"+__cAOFIM+"' %"
	Else
		cExpAOFim := "% 1 = 1 %"
	EndIf



	If !lManual .And. AllTrim(CEMPANT) == "05"
		cExpMaxPer := "% (select MAX(PZ6_PERFIM) from PZ6050 X where X.PZ6_FILIAL = PZ6.PZ6_FILIAL and X.PZ6_CODIGO = PZ6.PZ6_CODIGO and X.D_E_L_E_T_ = '') >= convert(varchar(8),dateadd(day,-1,(dateadd(month,1,convert(char(08),dateadd(mm,-1,getdate()) ,126)+'01'))), 112) %"
	Else
		cExpMaxPer := "% 1 = 1 %"
	EndIf


	Qry := GetNextAlias()

	IF Z79->(FieldPos("Z79_YCTPRO")) > 0

		BeginSql Alias Qry
		%NOPARSER%

		with tab_ao as
		(
		SELECT
		PZ5_CODIGO,
		PZ5_CODVEN,
		PZ5_NFAIXA,
		PZ5_TIPCLI,
		
		COD_CLI = CASE WHEN PZ5_TIPCLI = '1' THEN PZ5_CODCLI+PZ5_LOJCLI 
		WHEN PZ5_TIPCLI = '2' THEN PZ5_CODGRP
		ELSE PZ5_REDE END,

		NOME_CLI = CASE WHEN PZ5_TIPCLI = '1' THEN (SELECT TOP 1 A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = PZ5_CODCLI+PZ5_LOJCLI AND D_E_L_E_T_='')
		WHEN PZ5_TIPCLI = '2' THEN (SELECT TOP 1 ACY_DESCRI FROM ACY010 WHERE ACY_GRPVEN = PZ5_CODGRP AND D_E_L_E_T_='')
		ELSE (SELECT TOP 1 Z79_DESCR FROM Z79010 WHERE Z79_REDE = PZ5_REDE AND D_E_L_E_T_='') END,

		PZ6_PERINI,
		PZ6_PERFIM,
		PERIODO = PZ6_IDPER,
		STATUS = CASE WHEN PZ6_PERFIM < (convert(varchar(8),GetDate(),112)) THEN 'ENCERRADO'
		WHEN PZ6_PERINI <= (convert(varchar(8),GetDate(),112)) AND PZ6_PERFIM >= (convert(varchar(8),GetDate(),112)) THEN 'EM ANDAMENTO'
		ELSE 'NAO INICIADO'	END,
		REALIZADO = PZ6_VALREA,
		METAF1 = PZ6_METAF1,
		FALTAF1 = CASE WHEN PZ6_METAF1 <= 0 OR (PZ6_METAF1 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF1 - PZ6_VALREA) END,
		METAF2 = PZ6_METAF2,
		FALTAF2 = CASE WHEN PZ6_METAF2 <= 0 OR (PZ6_METAF2 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF2 - PZ6_VALREA) END,
		METAF3 = PZ6_METAF3,
		FALTAF3 = CASE WHEN PZ6_METAF3 <= 0 OR (PZ6_METAF3 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF3 - PZ6_VALREA) END,
		METAF4 = PZ6_METAF4,
		FALTAF4 = CASE WHEN PZ6_METAF4 <= 0 OR (PZ6_METAF4 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF4 - PZ6_VALREA) END,
		METAF5 = PZ6_METAF5,
		FALTAF5 = CASE WHEN PZ6_METAF5 <= 0 OR (PZ6_METAF5 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF5 - PZ6_VALREA) END,
		BONUS = PZ6_BONUS,     
		NUMSI = PZ6_SI,
		TPACOR = PZ5_TPACOR,
		PREALI = PZ6_PREALI,

		VLRPROXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE WHEN PZ6_METAF1 > 0 AND PZ6_METAP1 > 0 AND (PZ6_VALREA <= PZ6_METAF1 OR PZ6_PREALI <= PZ6_METAP1) AND PZ6_VALREA < PZ6_METAF2 THEN (PZ6_METAF2 - PZ6_VALREA)
							 WHEN PZ6_METAF2 > 0 AND PZ6_METAP2 > 0 AND (PZ6_VALREA <= PZ6_METAF2 OR PZ6_PREALI <= PZ6_METAP2) AND PZ6_VALREA < PZ6_METAF3 THEN (PZ6_METAF3 - PZ6_VALREA) 
							 WHEN PZ6_METAF3 > 0 AND PZ6_METAP3 > 0 AND (PZ6_VALREA <= PZ6_METAF3 OR PZ6_PREALI <= PZ6_METAP3) AND PZ6_VALREA < PZ6_METAF4 THEN (PZ6_METAF4 - PZ6_VALREA) 
							 WHEN PZ6_METAF4 > 0 AND PZ6_METAP4 > 0 AND (PZ6_VALREA <= PZ6_METAF4 OR PZ6_PREALI <= PZ6_METAP4) AND PZ6_VALREA < PZ6_METAF5 THEN (PZ6_METAF5 - PZ6_VALREA) 
		ELSE 0 END
		ELSE 0 END,

		ITPROXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE WHEN PZ6_METAF1 > 0 AND PZ6_METAP1 > 0 AND (PZ6_VALREA <= PZ6_METAF1 OR PZ6_PREALI <= PZ6_METAP1) AND PZ6_PREALI < PZ6_METAP2 THEN (PZ6_METAP2 - PZ6_PREALI)
				  			 WHEN PZ6_METAF2 > 0 AND PZ6_METAP2 > 0 AND (PZ6_VALREA <= PZ6_METAF2 OR PZ6_PREALI <= PZ6_METAP2) AND PZ6_PREALI < PZ6_METAP3 THEN (PZ6_METAP3 - PZ6_PREALI) 
				  		  	 WHEN PZ6_METAF3 > 0 AND PZ6_METAP3 > 0 AND (PZ6_VALREA <= PZ6_METAF3 OR PZ6_PREALI <= PZ6_METAP3) AND PZ6_PREALI < PZ6_METAP4 THEN (PZ6_METAP4 - PZ6_PREALI) 
				  		  	 WHEN PZ6_METAF4 > 0 AND PZ6_METAP4 > 0 AND (PZ6_VALREA <= PZ6_METAF4 OR PZ6_PREALI <= PZ6_METAP4) AND PZ6_PREALI < PZ6_METAP5 THEN (PZ6_METAP5 - PZ6_PREALI) 
		ELSE 0 END
		ELSE 0 END,

		VLRMAXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE  WHEN PZ5_NFAIXA = 5 AND PZ6_METAF5 > PZ6_VALREA THEN (PZ6_METAF5 - PZ6_VALREA)
							  WHEN PZ5_NFAIXA = 4 AND PZ6_METAF4 > PZ6_VALREA THEN (PZ6_METAF4 - PZ6_VALREA)
						  	  WHEN PZ5_NFAIXA = 3 AND PZ6_METAF3 > PZ6_VALREA THEN (PZ6_METAF3 - PZ6_VALREA)  
				  		  	  WHEN PZ5_NFAIXA = 2 AND PZ6_METAF2 > PZ6_VALREA THEN (PZ6_METAF2 - PZ6_VALREA)
				  		  	  WHEN PZ5_NFAIXA = 1 AND PZ6_METAF1 > PZ6_VALREA THEN (PZ6_METAF1 - PZ6_VALREA) 
		ELSE 0 END
		ELSE 0 END,

		ITMAXCAT   = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE  WHEN PZ5_NFAIXA = 5 AND PZ6_METAP5 > PZ6_PREALI THEN (PZ6_METAP5 - PZ6_PREALI)
							  WHEN PZ5_NFAIXA = 4 AND PZ6_METAP4 > PZ6_PREALI THEN (PZ6_METAP4 - PZ6_PREALI)
						  	  WHEN PZ5_NFAIXA = 3 AND PZ6_METAP3 > PZ6_PREALI THEN (PZ6_METAP3 - PZ6_PREALI)  
				  		  	  WHEN PZ5_NFAIXA = 2 AND PZ6_METAP2 > PZ6_PREALI THEN (PZ6_METAP2 - PZ6_PREALI)  
				  		  	  WHEN PZ5_NFAIXA = 1 AND PZ6_METAP1 > PZ6_PREALI THEN (PZ6_METAP1 - PZ6_PREALI) 
		ELSE 0 END
		ELSE 0 END

		FROM %TABLE:PZ6% PZ6
		JOIN %TABLE:PZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO
		WHERE
		PZ5_STATUS = 'S'
		AND %Exp:cExpMaxPer%
		AND PZ6.D_E_L_E_T_=''
		AND PZ5.D_E_L_E_T_=''
		)
		select * 
		,MAXFAIXA = (select max(PZ5_NFAIXA) from tab_ao X where X.PZ5_CODVEN = tab_ao.PZ5_CODVEN)
		from tab_ao
		where PZ6_PERINI >= %EXP:__CDATAINI%
		AND %Exp:cExpFim%
		AND %Exp:cExpAOIni%	AND %Exp:cExpAOFim%
		order by PZ5_CODVEN, COD_CLI, PZ5_CODIGO, PZ6_PERINI

		EndSql

	ELSE

		BeginSql Alias Qry
		%NOPARSER%

		with tab_ao as
		(
		SELECT
		PZ5_CODIGO,
		PZ5_CODVEN,
		PZ5_NFAIXA,
		PZ5_TIPCLI,
		COD_CLI = CASE WHEN PZ5_TIPCLI = '1' THEN PZ5_CODCLI+PZ5_LOJCLI ELSE PZ5_CODGRP	END,
		NOME_CLI = CASE WHEN PZ5_TIPCLI = '1' THEN (SELECT TOP 1 A1_NOME FROM SA1010 WHERE A1_COD+A1_LOJA = PZ5_CODCLI+PZ5_LOJCLI AND D_E_L_E_T_='')
		ELSE (SELECT TOP 1 ACY_DESCRI FROM ACY010 WHERE ACY_GRPVEN = PZ5_CODGRP AND D_E_L_E_T_='') END,
		PZ6_PERINI,
		PZ6_PERFIM,
		PERIODO = PZ6_IDPER,
		STATUS = CASE WHEN PZ6_PERFIM < (convert(varchar(8),GetDate(),112)) THEN 'ENCERRADO'
		WHEN PZ6_PERINI <= (convert(varchar(8),GetDate(),112)) AND PZ6_PERFIM >= (convert(varchar(8),GetDate(),112)) THEN 'EM ANDAMENTO'
		ELSE 'NAO INICIADO'	END,
		REALIZADO = PZ6_VALREA,
		METAF1 = PZ6_METAF1,
		FALTAF1 = CASE WHEN PZ6_METAF1 <= 0 OR (PZ6_METAF1 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF1 - PZ6_VALREA) END,
		METAF2 = PZ6_METAF2,
		FALTAF2 = CASE WHEN PZ6_METAF2 <= 0 OR (PZ6_METAF2 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF2 - PZ6_VALREA) END,
		METAF3 = PZ6_METAF3,
		FALTAF3 = CASE WHEN PZ6_METAF3 <= 0 OR (PZ6_METAF3 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF3 - PZ6_VALREA) END,
		METAF4 = PZ6_METAF4,
		FALTAF4 = CASE WHEN PZ6_METAF4 <= 0 OR (PZ6_METAF4 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF4 - PZ6_VALREA) END,
		METAF5 = PZ6_METAF5,
		FALTAF5 = CASE WHEN PZ6_METAF5 <= 0 OR (PZ6_METAF5 - PZ6_VALREA) < 0 THEN 0 ELSE (PZ6_METAF5 - PZ6_VALREA) END,
		BONUS = PZ6_BONUS,     
		NUMSI = PZ6_SI,
		TPACOR = PZ5_TPACOR,
		PREALI = PZ6_PREALI,

		VLRPROXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE WHEN PZ6_METAF1 > 0 AND PZ6_METAP1 > 0 AND (PZ6_VALREA <= PZ6_METAF1 OR PZ6_PREALI <= PZ6_METAP1) AND PZ6_VALREA < PZ6_METAF2 THEN (PZ6_METAF2 - PZ6_VALREA)
							 WHEN PZ6_METAF2 > 0 AND PZ6_METAP2 > 0 AND (PZ6_VALREA <= PZ6_METAF2 OR PZ6_PREALI <= PZ6_METAP2) AND PZ6_VALREA < PZ6_METAF3 THEN (PZ6_METAF3 - PZ6_VALREA) 
							 WHEN PZ6_METAF3 > 0 AND PZ6_METAP3 > 0 AND (PZ6_VALREA <= PZ6_METAF3 OR PZ6_PREALI <= PZ6_METAP3) AND PZ6_VALREA < PZ6_METAF4 THEN (PZ6_METAF4 - PZ6_VALREA) 
							 WHEN PZ6_METAF4 > 0 AND PZ6_METAP4 > 0 AND (PZ6_VALREA <= PZ6_METAF4 OR PZ6_PREALI <= PZ6_METAP4) AND PZ6_VALREA < PZ6_METAF5 THEN (PZ6_METAF5 - PZ6_VALREA) 
		ELSE 0 END
		ELSE 0 END,

		ITPROXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE WHEN PZ6_METAF1 > 0 AND PZ6_METAP1 > 0 AND (PZ6_VALREA <= PZ6_METAF1 OR PZ6_PREALI <= PZ6_METAP1) AND PZ6_PREALI < PZ6_METAP2 THEN (PZ6_METAP2 - PZ6_PREALI)
				  			 WHEN PZ6_METAF2 > 0 AND PZ6_METAP2 > 0 AND (PZ6_VALREA <= PZ6_METAF2 OR PZ6_PREALI <= PZ6_METAP2) AND PZ6_PREALI < PZ6_METAP3 THEN (PZ6_METAP3 - PZ6_PREALI) 
				  		  	 WHEN PZ6_METAF3 > 0 AND PZ6_METAP3 > 0 AND (PZ6_VALREA <= PZ6_METAF3 OR PZ6_PREALI <= PZ6_METAP3) AND PZ6_PREALI < PZ6_METAP4 THEN (PZ6_METAP4 - PZ6_PREALI) 
				  		  	 WHEN PZ6_METAF4 > 0 AND PZ6_METAP4 > 0 AND (PZ6_VALREA <= PZ6_METAF4 OR PZ6_PREALI <= PZ6_METAP4) AND PZ6_PREALI < PZ6_METAP5 THEN (PZ6_METAP5 - PZ6_PREALI) 
		ELSE 0 END
		ELSE 0 END,

		VLRMAXCAT = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE  WHEN PZ5_NFAIXA = 5 AND PZ6_METAF5 > PZ6_VALREA THEN (PZ6_METAF5 - PZ6_VALREA)
							  WHEN PZ5_NFAIXA = 4 AND PZ6_METAF4 > PZ6_VALREA THEN (PZ6_METAF4 - PZ6_VALREA)
						  	  WHEN PZ5_NFAIXA = 3 AND PZ6_METAF3 > PZ6_VALREA THEN (PZ6_METAF3 - PZ6_VALREA)  
				  		  	  WHEN PZ5_NFAIXA = 2 AND PZ6_METAF2 > PZ6_VALREA THEN (PZ6_METAF2 - PZ6_VALREA)
				  		  	  WHEN PZ5_NFAIXA = 1 AND PZ6_METAF1 > PZ6_VALREA THEN (PZ6_METAF1 - PZ6_VALREA) 
		ELSE 0 END
		ELSE 0 END,

		ITMAXCAT   = CASE WHEN PZ5_TPACOR IN ('AG') THEN
		CASE  WHEN PZ5_NFAIXA = 5 AND PZ6_METAP5 > PZ6_PREALI THEN (PZ6_METAP5 - PZ6_PREALI)
							  WHEN PZ5_NFAIXA = 4 AND PZ6_METAP4 > PZ6_PREALI THEN (PZ6_METAP4 - PZ6_PREALI)
						  	  WHEN PZ5_NFAIXA = 3 AND PZ6_METAP3 > PZ6_PREALI THEN (PZ6_METAP3 - PZ6_PREALI)  
				  		  	  WHEN PZ5_NFAIXA = 2 AND PZ6_METAP2 > PZ6_PREALI THEN (PZ6_METAP2 - PZ6_PREALI)  
				  		  	  WHEN PZ5_NFAIXA = 1 AND PZ6_METAP1 > PZ6_PREALI THEN (PZ6_METAP1 - PZ6_PREALI) 
		ELSE 0 END
		ELSE 0 END

		FROM %TABLE:PZ6% PZ6
		JOIN %TABLE:PZ5% PZ5 on PZ5_CODIGO = PZ6_CODIGO
		WHERE
		PZ5_STATUS = 'S'
		AND %Exp:cExpMaxPer%
		//AND PZ5_CODIGO = '000064'  //TESTE
		AND PZ6.D_E_L_E_T_=''
		AND PZ5.D_E_L_E_T_=''
		)
		select * 
		,MAXFAIXA = (select max(PZ5_NFAIXA) from tab_ao X where X.PZ5_CODVEN = tab_ao.PZ5_CODVEN)
		from tab_ao
		where PZ6_PERINI >= %EXP:__CDATAINI%
		AND %Exp:cExpFim%
		AND %Exp:cExpAOIni%	AND %Exp:cExpAOFim%
		order by PZ5_CODVEN, COD_CLI, PZ5_CODIGO, PZ6_PERINI

		EndSql

	ENDIF
	/* 
	aDados := GetLastQuery()
 	cQry   := aDados[2]
	*/

Return()


Static Function GetHeader()

	cHtml := '   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cHtml += '   <html xmlns="http://www.w3.org/1999/xhtml">
	cHtml += '      <head>
	cHtml += '         <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cHtml += '         <title>cabtitpag</title>
	cHtml += '         <style type="text/css">
	cHtml += '			<!--
	cHtml += '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cHtml += '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cHtml += '			.footTexto  {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
	cHtml += '			.footTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
	cHtml += '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
	cHtml += '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
	cHtml += '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
	cHtml += '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
	cHtml += '			-->
	cHtml += '         </style>
	cHtml += '      </head>
	cHtml += '      <body>

Return()


Static Function GetColumnHeader(_cRep, _nMaxFaixa, _cNomeCli, _cTpAcord)
	Local I

	SA3->(DbSetOrder(1))
	SA3->(DbSeek(XFilial("SA3")+_cRep))

	If Alltrim(_cTpAcord) <> "AG"

		cHtml += '         <p><div class = "headTexto1">Prezado(s):</div></p>'
		cHtml += '         <p/>'
		cHtml += '         <p><div class = "headTexto">REPRESENTANTE: '+AllTrim(SA3->A3_NREDUZ)+'</div></p>'
		cHtml += '         <p/>'
		cHtml += '         <p><div class = "headTexto">CLIENTE: '+AllTrim(_cNomeCli)+'</div></p>'
		cHtml += '         <p/>'
		cHtml += '         <p><div class = "headTexto1">Segue para acompanhamento a evolução dos seus acordos de objetivos em andamento:</div></p>'
		cHtml += '         <p/>'
		cHtml += '         <table align="center" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Acordo </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Período </th>'
		cHtml += '               <th class = "cabtab" width="20" scope="col"> Status </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Realizado </th>'

		For I := 1 To _nMaxFaixa

			cHtml += '               <th class = "cabtab" width="40" scope="col"> Meta Faixa '+AllTrim(Str(I))+' </th>'
			cHtml += '               <th class = "cabtab" width="40" scope="col"> Falta p/ Faixa '+AllTrim(Str(I))+' </th>'

		Next I

		cHtml += '               <th class = "cabtab" width="40" scope="col"> Bônus </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> No. SI </th>'
		cHtml += '            </tr>

	Else

		cHtml += '         <p><div class = "headTexto1">Olá</div></p>'
		cHtml += '         <br>'
		cHtml += '         <br>'
		cHtml += '         <p><div class = "headTexto1">Você está recebendo um relatório do seu desempenho no período e os valores que estarão disponíveis para a utilização no Programa de Benefícios Galleria Biancogres no próximo Semestre.</div></p>'
		cHtml += '         <br>'
		cHtml += '         <br>'
		cHtml += '         <p><div class = "headTexto">CLIENTE: '+AllTrim(_cNomeCli)+'</div></p>'
		cHtml += '         <p><div class = "headTexto">REPRESENTANTE: '+AllTrim(SA3->A3_NREDUZ)+'</div></p>'
		cHtml += '         <br>'
		cHtml += '         <table align="left" width="1200" border="1" cellspacing="0" cellpadding="1">'
		cHtml += '            <tr align=center>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Acordo </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Período </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Realizado (em R$) </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Itens Exclusivos Positivados (produtos ativos até o período) </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Falta para subir para PRÓXIMA Categoria (em R$) </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Falta para subir para PRÓXIMA Categoria (em nº de items) </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Falta para chegar a MAIOR Categoria (em R$) </th>'
		cHtml += '               <th class = "cabtab" width="40" scope="col"> Falta para chegar a MAIOR Categoria (em nº de items) </th>'
		cHtml += '            </tr>

	Endif

Return()


Static Function GetItems(_nMaxFaixa, _cTpAcord)
	Local I

	If Alltrim(_cTpAcord) <> "AG"

		cHtml += " 			<tr align=center>
		cHtml += "          	<td class='style12' width='100'scope='col'>"+ (Qry)->PZ5_CODIGO +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->PERIODO +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->STATUS +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->REALIZADO,"@E 999,999,999,999.99") +"</td>"

		For I := 1 To _nMaxFaixa

			cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(&("(Qry)->METAF"+AllTrim(Str(I))+""),"@E 999,999,999,999.99") +"</td>"
			cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform(&("(Qry)->FALTAF"+AllTrim(Str(I))+""),"@E 999,999,999,999.99") +"</td>"

		NexT

		cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->BONUS,"@E 999,999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->NUMSI +"</td>"
		cHtml += "          </tr>"

	Else

		cHtml += " 			<tr align=center>"
		cHtml += "          	<td class='style12' width='100'scope='col'>"+ (Qry)->PZ5_CODIGO +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ (Qry)->PERIODO +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->REALIZADO,"@E 999,999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ cValToChar((Qry)->PREALI) +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->VLRPROXCAT,"@E 999,999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ cValToChar((Qry)->ITPROXCAT) +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ Transform((Qry)->VLRMAXCAT,"@E 999,999,999,999.99") +"</td>"
		cHtml += "          	<td class='style12' width='20'scope='col'>"+ cValToChar((Qry)->ITMAXCAT) +"</td>"
		cHtml += "          </tr>"

	Endif

Return()


Static Function GetFooter(_cTpAcord, _nTotBonus)

	If Alltrim(_cTpAcord) <> "AG"
		cHtml += "		<table align='center' width='1200' border='1' cellspacing='0' cellpadding='1'>"
	Else
		cHtml += "		<table align='left' width='1200' border='1' cellspacing='0' cellpadding='1'>"
	Endif
	cHtml += "          <tr>"
	cHtml += "            <th class = 'tottab' width='1200' scope='col'> E-mail enviado automaticamente pelo sistema Protheus (FACOWF01).</th>"
	cHtml += "			</tr>"
	cHtml += "		</table>"

	If Alltrim(_cTpAcord) == "AG"

		cHtml += "		<br>"
		cHtml += "		<br>"
		cHtml += "		<br>"
		cHtml += "		<br>"
		cHtml += "		<br>"
		cHtml += "		<br>"
		cHtml += "      	<p><div class = 'footTexto'>Seu BÔNUS ESTIMADO para o próximo semestre até o momento é de: R$ " + Transform(_nTotBonus,"@E 999,999,999,999.99") + "</div></p>"
		cHtml += "      <br>"
		cHtml += "      <br>"
		cHtml += "      	<p><div class = 'footTexto'>Consulte seu representante para que possamos alinhar nossas estratégias, a fim de busca a melhor faixa de benefício possível.</div></p>"
		cHtml += "      <br>"
		cHtml += "      <br>"
		cHtml += "		<p><div class = 'footTexto1'>Biancogres</div></p>"

	Endif

	cHtml += "      </body>"
	cHtml += "   </html>"
	cHtml += "   </html>"

Return()


Static Function SendMail(_cRep, _cCodPZ5)
	Local _lRet
	Local _cFrom	 	:= ""
	Local _cTo 			:= ""
	Local _cSubject		:= ""
	Local _cBody 		:= ""
	Local _cCC 			:= ""
	Local _oCC 			:= ""
	Local _cAGMail		:= ""
	Local _cAteMail		:= ""
	Local _cGerMail		:= ""

	Local cDataBase    := AllTrim(U_DBNAME())

	SA3->(DbSetOrder(1))
	SA3->(DbSeek(XFilial("SA3")+_cRep))

	/*SM0->(DbSetOrder(1))
	SM0->(DbSeek(CEMPANT+CFILANT))*/

	PZ5->(DbSetOrder(1))
	PZ5->(DbSeek(XFilial("PZ5")+_cCodPZ5))
	
	Z37->(DbSetOrder(1))
	Z37->(DbSeek(PZ5->PZ5_FILIAL+PZ5->PZ5_MARCA))


	_cSubject := "Acompanhamento de Acordos Objetivos - "+  AllTrim(Z37->Z37_DESCR)

	If !Empty(SA3->A3_EMAIL)
		_cTo := AllTrim(SA3->A3_EMAIL) 
	Else
		If AllTrim(CEMPANT) == "05"
			_cTo := "mateus.fadini@bellacasaceramica.com.br"
		Else
			_cTo := "claudeir.fadini@biancogres.com.br"
		EndIf
		_cSubject := "Email Representante não cadastrado! Acompanhamento de Acordos Objetivos - "+ AllTrim(Z37->Z37_DESCR)
	EndIf

	//Pedro Henrique/Facile  - em 09/01/2018 - Ticket 8847
	If PZ5->(FieldPos("PZ5_EMAILC")) > 0 .And. !Empty(PZ5->PZ5_EMAILC)
		_cTo += ";"+AllTrim(PZ5->PZ5_EMAILC)
	EndIf
	
	_oCC := "valmir.vali@biancogres.com.br;micheli.zanoni@biancogres.com.br;"
	_oCC += "tatiane.perpetua@biancogres.com.br;mateus.fadini@biancogres.com.br;claudeir.fadini@biancogres.com.br"
	
	//Fernando/Facil em 18/08/2015 - OS 2583
	//email do cliente - campo informado manualmente no cabecalho do acordo
	
	//email dos atendentes/gerente 
	_cAGMail := MailAteGer() 
	_cAteMail := _cAGMail[1] //atendente
	_cGerMail := _cAGMail[2] //gerente
	
	 
	If !Empty(_cAteMail)
		_cCC += _cAteMail +";" 
	EndIf
	
	If !Empty(_cGerMail)
		_cCC += _cGerMail +";" 
	EndIf

	_cCC += U_EmailWF("FACOWF01", CEMPANT)

	If !(Upper(AllTrim(getenvserver())) == "SCHEDULE" .Or. Upper(AllTrim(getenvserver())) == "PRODUCAO") .Or. ( cDataBase <> "DADOSADV" )
		_cTo := "claudeir.fadini@biancogres.com.br"
		_cCC := "fernando@facilesistemas.com.br"
	EndIf
	
	_cBody := cHtml      

	Conout("FACOWF01 Fim - lManual = "+IIf(lManual,"SIM","NAO")+" - enviando e-mail para: "+_cTo)
	//_lRet := U_BIAEnvMail(, _cTo, _cSubject, _cBody, "", "", , _cCC, _oCC)    // aqui descomentar antes aplicar em produção
	_lRet := U_BIAEnvMail(, 'karina.barbosa@biancogres.com.br;emerson.salvador@facilesistemas.com.br;filipe.bittencourt@facilesistemas.com.br', _cSubject, _cBody, "", "", , "", "")   //aqui retirar essa linha somente para testes
	

Return(_lRet)


Static Function MailAteGer()
	
	Local cAliasTmp
	Local cRet 			:= ""
	Local cRetGer		:= ""
	Local cEmailGer		:= ""   
	Local _cWhereSeg
	Local _cSeg 		:= ""

	If (PZ5->PZ5_TIPCLI == '1')

		oGerenteAtendente	:= TGerenteAtendente():New()
		oResult 			:= oGerenteAtendente:GetCliente(cEmpAnt+cFilAnt, PZ5->PZ5_CODCLI, PZ5->PZ5_LOJCLI, PZ5->PZ5_CODVEN)
		
		cRet += IIf(!Empty(cRet),";","")
		cRet += oResult:cEmailAten
		
		cEmailGer := GetEmail(oResult:cGerente)
		cRetGer += IIF(!Empty(cRetGer), ";", "")
		cRetGer += IIF(!Empty(cEmailGer), cEmailGer, "")		 
		
		//SA1->(DbSetOrder(1))
		//If SA1->(DbSeek(XFilial("SA1")+PZ5->(PZ5_CODCLI+PZ5_LOJCLI)))
			//_cWhereSeg := "% ZZI_TPSEG = '"+SA1->A1_YTPSEG+"' %"
		//EndIf
	ElseIf (PZ5->PZ5_TIPCLI == '2')

		SA1->(DbSetOrder(6))
		If SA1->(DbSeek(XFilial("SA1")+PZ5->(PZ5_CODGRP)))

			While !SA1->(Eof()) .And. SA1->(A1_FILIAL+A1_GRPVEN) == (XFilial("SA1")+PZ5->(PZ5_CODGRP))

				/*If !(SA1->A1_YTPSEG $ _cSeg)
					_cSeg += IIf(!Empty(_cSeg),",","")
					_cSeg += "'"+SA1->A1_YTPSEG+"'"
			EndIf
				*/

			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente(cEmpAnt+cFilAnt, SA1->A1_COD, SA1->A1_LOJA, PZ5->PZ5_CODVEN)

			cRet += IIf(!Empty(cRet),";","")
			cRet += oResult:cEmailAten

			cEmailGer := GetEmail(oResult:cGerente)
			cRetGer += IIF(!Empty(cRetGer), ";", "")
			cRetGer += IIF(!Empty(cEmailGer), cEmailGer, "")

			SA1->(DbSkip())
		EndDo

		//_cWhereSeg := "% ZZI_TPSEG in ("+_cSeg+") %"

	EndIf

Else  //Rede de Compras

	SA1->(DbSetOrder(12))
	If SA1->(DbSeek(XFilial("SA1")+PZ5->(PZ5_REDE)))

		While !SA1->(Eof()) .And. SA1->(A1_FILIAL+A1_YREDCOM) == (XFilial("SA1")+PZ5->(PZ5_REDE))

				/*If !(SA1->A1_YTPSEG $ _cSeg)
					_cSeg += IIf(!Empty(_cSeg),",","")
					_cSeg += "'"+SA1->A1_YTPSEG+"'"
		EndIf
				*/
		oGerenteAtendente	:= TGerenteAtendente():New()
		oResult 			:= oGerenteAtendente:GetCliente(cEmpAnt+cFilAnt, SA1->A1_COD, SA1->A1_LOJA, PZ5->PZ5_CODVEN)

		cRet += IIf(!Empty(cRet),";","")
		cRet += oResult:cEmailAten

		cEmailGer := GetEmail(oResult:cGerente)
		cRetGer += IIF(!Empty(cRetGer), ";", "")
		cRetGer += IIF(!Empty(cEmailGer), cEmailGer, "")

		SA1->(DbSkip())
	EndDo

	//_cWhereSeg := "% ZZI_TPSEG in ("+_cSeg+") %"

EndIf

EndIf

	/*If !Empty(_cWhereSeg)

		cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
		%NOPARSER%
		SELECT ZZI_ATENDE, ZZI_GERENT FROM VW_SAP_ZZI 
		WHERE SubString(MARCA,1,2) = %EXP:AllTrim(CEMPANT)% 
		AND ZZI_VEND = %EXP:PZ5->PZ5_CODVEN% 
		and %EXP:_cWhereSeg%
EndSql

(cAliasTmp)->(DbGoTop())
While !(cAliasTmp)->(Eof())

	PswOrder(1)
	If (PswSeek((cAliasTmp)->ZZI_ATENDE, .T.))
		aUser := Pswret(1)
		cRet += IIf(!Empty(cRet),";","")
		cRet += AllTrim(aUser[1][14])
	EndIf

	If !Empty((cAliasTmp)->ZZI_GERENT)
		cEmailGer := GetEmail((cAliasTmp)->ZZI_GERENT)
		cRetGer += IIF(!Empty(cRetGer), ";", "")
		cRetGer += IIF(!Empty(cEmailGer), cEmailGer, "")
	EndIf

	(cAliasTmp)->(DbSkip())
EndDo

(cAliasTmp)->(DbCloseArea())
EndIf
	*/

Return {cRet, cRetGer}


Static Function GetEmail(cCodVend)
	Local aArea  := SA3->(GetArea())
	Local cEmail := ""

	DbSelectArea('SA3')
	SA3->(DbSetOrder(1))
	SA3->(DbGoTop())

	If SA3->(DbSeek(XFilial("SA3")+cCodVend))
		cEmail := AllTrim(SA3->A3_EMAIL)
	EndIf

	SA3->(DbCloseArea())
	SA3->(RestArea(aArea))

Return cEmail
