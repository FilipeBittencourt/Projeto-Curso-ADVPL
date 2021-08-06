#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwcommand.ch"

/*/{Protheus.doc} BIAF065
@author Artur Antunes
@since 02/03/2017
@version 1.0
@description Rotina para Integração Ecosis vs Protheus - EXPEDIÇÃO
@obs OS: 0137-17
@type function
/*/

User Function BIAF065()

	Local nRecSM0  		:= 0 
	Local aEmpres  		:= {}   
	Local nx	   		:= 0   
	Local cEFjob		:= "0101/0501/1401" //Empresa+Filial
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Local _aSm0	:=	{}
	Local _nI
	Local _cEmp

	Private lWind 		:= Type("oMainWnd") <> "U"
	private cFuncao     := 'BIAF065'
	private dDtMovDe
	private dDtMovAte


	if !lWind
		OpenSm0()
		nRecSM0 := SM0->(Recno())
		SM0->(dbGotop())

		_aSm0	:=	FWLoadSM0()

		For _nI	:=	1 to Len(_aSM0)
			_cEmp	:=	Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP])
			if _cEmp + _aSM0[_nI,SM0_FILIAL] $ cEFjob 
				if ASCAN(aEmpres, {|x| x[1] == _cEmp .and. x[2] == _aSM0[_nI,SM0_FILIAL] }) == 0
					AADD(aEmpres, { _cEmp, _aSM0[_nI,SM0_FILIAL] })	
				endif	
			endif	
		Next 	
		SM0->(DbGoTo(nRecSM0)) 

		For nx := 1 to Len(aEmpres)

			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv(aEmpres[nx,1],aEmpres[nx,2],,,"EST") 

			dDtMovDe    := GetMv("MV_YULMES") //STOD('20170401')   
			dDtMovAte   := STOD('20491231') 

			Conout(cFuncao+" - Processando Integracao!")

			fProcInteg(aEmpres[nx,1],aEmpres[nx,2])

		next nx

	else	

		if cEmpAnt + '01' $ cEFjob

			dDtMovDe    := GetMv("MV_YULMES") //STOD('20170401')   
			dDtMovAte   := STOD('20491231')   

			fPergunte()

			AADD(aSays, OemToAnsi("Rotina para Integração de Movimentação de Estoque,"))   
			AADD(aSays, OemToAnsi("Ecosis vs Protheus - EXPEDIÇÃO."))   
			AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
			AADD(aSays, OemToAnsi("Deseja Continuar?"))   

			AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
			AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
			AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

			FormBatch( OemToAnsi('EXPEDIÇÃO - Integração Ecosis vs Protheus'), aSays, aButtons ,,,500)

			if lConfirm
				if !Empty(dDtMovDe) .and. !Empty(dDtMovAte) 
					Processa({ || fProcInteg(cEmpAnt,'01') },"Aguarde...","Carregando Registros...",.F.)
				else	
					MsgStop("Periodo não informado!!!",cFuncao)
					Return
				endif
			endif
		else
			MsgStop("Empresa não configurada para Integração Ecosis vs Protheus - EXPEDIÇÃO !!!",cFuncao)
			Return
		endif	
	endif
Return


//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	local cLoad	    := cFuncao + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad

	dDtMovDe  := STOD('')   
	dDtMovAte := STOD('')    

	aAdd( aPergs ,{1,"DT Movto Eco de: " ,dDtMovDe  ,"","NAOVAZIO()",'','.T.',50,.F.})	
	aAdd( aPergs ,{1,"DT Movto Eco Ate:" ,dDtMovAte ,"","NAOVAZIO()",'','.T.',50,.F.})	

	If ParamBox(aPergs ,"Integração Ecosis vs Protheus - EXPEDIÇÃO",,,,,,,,cLoad,.T.,.T.)      
		dDtMovDe  := ParamLoad(cFileName,,1,dDtMovDe) 
		dDtMovAte := ParamLoad(cFileName,,2,dDtMovAte)     
	endif

return

//Processa Integração
Static Function fProcInteg(_cEmp,_cFil)

	local aArea      	:= GetArea()
	local cAliasTmp 	:= GetNextAlias()
	local cLocaliz		:= 'PAP'
	local oMov			:= nil
	local aErro			:= {}
	local aProces		:= {}
	local nContReg		:= 0
	local nTotReg		:= 0
	local cBaseDados	:= ''
	local cQuery 		:= ''
	local lContinua		:= .T.
	local dDateBkp		:= Date() 
	Local cPasta 	 	:=  AllTrim(GetNewPar("MV_YITGERR","\LOG_ERRO_Ecosis_x_Protheus\")) 
	Local cArqErro 	 	:= cPasta + cFuncao + "-ERRO" + "-D"+ALLTrim( DTOS(DATE())+"-H"+StrTran( time(),':','-')) + ".txt"
	Local cArqProc 	 	:= cPasta + cFuncao + "-PROCESSADOS" + "-D"+ALLTrim( DTOS(DATE())+"-H"+StrTran( time(),':','-')) + ".txt"
	local nHandle    	:= 0
	local nI			:= 0
	local cTo      		:= ''
	local dDataCorte	:= STOD(AllTrim(GetNewPar("MV_YITGDAT","20170301"))) 
	local cSubject 		:= ''
	local cMens	   		:= ''
	local lErro			:= .F.
	local lProces		:= .F.
	local aTemp			:= {}
	local cCeCusto		:= ''
	local cClasseVal	:= ''
	local cConta  		:= ''

	if Type('dDataBase') == "D"
		if !Empty(dDataBase)
			dDateBkp := dDataBase
		else
			dDataBase := Date()
		endif
	else
		dDataBase := Date()
	endif

	cEmpAnt := _cEmp
	cFilAnt := _cFil

	If cEmpAnt == "01"
		cBaseDados := "% DADOSEOS..cep_movimento_produto %"
	ElseIf cEmpAnt == "05"
		cBaseDados := "% DADOS_05_EOS..cep_movimento_produto %"
	ElseIf cEmpAnt == "14"
		cBaseDados := "% DADOS_14_EOS..cep_movimento_produto %"
	Else
		AADD(aErro,"Empresa "+cEmpAnt+" não configurada para Integração Ecosis vs Protheus - EXPEDIÇÃO !!")
		if lWind   
			MsgINFO(aErro[len(aErro)],cFuncao)
			RestArea(aArea)
			return
		else
			//Conout(cFuncao+" - "+aErro[len(aErro)])
			lContinua := .F.
		endif	
	EndIf

	if lContinua

		BeginSQL Alias cAliasTmp 
			%NOPARSER% 

			SELECT X.*,
			(SELECT CTH_YCC FROM %Table:CTH% CTH ( NOLOCK ) WHERE CTH.CTH_CLVL = X.CLVL01 AND CTH.D_E_L_E_T_ = ' ') CC01,
			(SELECT CTH_YCC FROM %Table:CTH% CTH ( NOLOCK ) WHERE CTH.CTH_CLVL = X.CLVL05 AND CTH.D_E_L_E_T_ = ' ') CC05
			FROM   ( 
			SELECT  
			CASE WHEN cod_transacao = '16' THEN 'transferência de'
			WHEN cod_transacao = '18' THEN 'requisição'
			WHEN cod_transacao = '19' THEN 'devolução'
			WHEN cod_transacao = '65' THEN 'não usar '
			WHEN cod_transacao = '66' THEN 'requisição'
			WHEN cod_transacao = '67' THEN 'transferência para'
			WHEN cod_transacao = '68' THEN 'requisição'
			WHEN cod_transacao = '71' THEN 'requisição'
			WHEN cod_transacao = '72' THEN 'requisição'
			ELSE 'error'
		END OPERAC ,
		A.cod_transacao TRANSAC ,
		A.ce_numero_docto ETIQUET ,
		A.id_mov_prod IDECO ,
		SUBSTRING(CONVERT(VARCHAR(10), ce_data_movimento, 112), 1, 10) DTREF ,
		SUBSTRING(CONVERT(VARCHAR(16), ce_data_movimento, 120), 12,5) HRREF, 
		A.cod_produto PRODUT ,
		SBZ.BZ_LOCPAD LOCAL , 
		A.ce_lote LOTEPR ,
		ISNULL(( SELECT MAX(SB8.B8_DTVALID)
		FROM   %Table:SB8% (NOLOCK) SB8
		WHERE  SB8.B8_FILIAL = '01'
		AND SB8.B8_PRODUTO = A.cod_produto COLLATE DATABASE_DEFAULT
		AND SB8.B8_LOCAL = SBZ.BZ_LOCPAD
		AND SB8.B8_LOTECTL = A.ce_lote COLLATE DATABASE_DEFAULT
		AND SB8.D_E_L_E_T_ = ' '
		), '') DTVALID,
		A.ce_qtdade QUANT,
		CASE WHEN cod_transacao = '16' THEN '499'
		WHEN cod_transacao = '18' THEN '600'
		WHEN cod_transacao = '19' THEN '300'
		WHEN cod_transacao = '65' THEN 'não usar'
		WHEN cod_transacao = '66' THEN '512'
		WHEN cod_transacao = '67' THEN '999'
		WHEN cod_transacao = '68' THEN '518'
		WHEN cod_transacao = '71' THEN '503'
		WHEN cod_transacao = '72' THEN '503'
		ELSE 'error'
	END TM ,
	CASE WHEN cod_transacao = '16' THEN 'não usar'
	WHEN cod_transacao = '18' THEN '2120'
	WHEN cod_transacao = '19' THEN '2120'
	WHEN cod_transacao = '65' THEN 'não usar'
	WHEN cod_transacao = '66' THEN '3107'
	WHEN cod_transacao = '67' THEN 'não usar'
	WHEN cod_transacao = '68' THEN '2100'
	WHEN cod_transacao = '71' THEN '2120'
	WHEN cod_transacao = '72' THEN '3100'
	ELSE 'error'
	END CLVL01 ,
	CASE WHEN cod_transacao = '16' THEN 'não usar'
	WHEN cod_transacao = '18' THEN '2220'
	WHEN cod_transacao = '19' THEN '2220'
	WHEN cod_transacao = '65' THEN 'não usar'
	WHEN cod_transacao = '66' THEN '3207'
	WHEN cod_transacao = '67' THEN 'não usar'
	WHEN cod_transacao = '68' THEN '2200'
	WHEN cod_transacao = '71' THEN '2220'
	WHEN cod_transacao = '72' THEN '3220'
	ELSE 'error'
	END CLVL05 ,
	SB1.B1_CONTA CONTA 
	FROM      %Exp:cBaseDados% A ( NOLOCK )

	LEFT JOIN %Table:SB1% SB1 ( NOLOCK ) 
	ON SB1.B1_FILIAL = %xFilial:SB1%
	AND SB1.B1_COD = A.cod_produto COLLATE DATABASE_DEFAULT
	AND SB1.D_E_L_E_T_ = ' '

	LEFT JOIN %Table:SBZ% SBZ ( NOLOCK ) 
	ON SBZ.BZ_FILIAL = %xFilial:SBZ%
	AND SBZ.BZ_COD = A.cod_produto COLLATE DATABASE_DEFAULT
	AND SBZ.D_E_L_E_T_ = ' '

	WHERE     A.cod_transacao IN ( '19', '18', '66', '68', '71', '72' )    
	AND SUBSTRING(CONVERT(VARCHAR(10), ce_data_movimento, 112), 1, 10) >= %Exp:dtos(dDataCorte)% 
	AND SUBSTRING(CONVERT(VARCHAR(10), ce_data_movimento, 112), 1, 10) BETWEEN %Exp:dtos(dDtMovDe)% AND %Exp:dtos(dDtMovAte)%
	AND A.id_mov_prod not in ('1498942', '1494419')
	AND NOT EXISTS (  SELECT D3_YIDECO ID 
	FROM   %Table:SD3% SD3 ( NOLOCK ) 
	WHERE  SD3.D3_YIDECO = A.id_mov_prod 
	AND SD3.D3_FILIAL = '01' 
	AND SD3.D3_ESTORNO = ' ' 
	AND SD3.D_E_L_E_T_ = ' ' 
	UNION ALL 
	SELECT Z18_IDECO ID 
	FROM   %Table:Z18% Z18 ( NOLOCK ) 
	WHERE  Z18_IDECO = A.id_mov_prod 
	AND Z18.Z18_FILIAL = '01' 
	AND Z18.D_E_L_E_T_ = ' ' ) 
	) X
	ORDER BY X.TM,X.DTREF

	EndSQL

	(cAliasTmp)->(DbGoTop())
	Count To nTotReg 
	If nTotReg == 0   
		AADD(aErro,"Não existem Registros para serem processados na empresa: "+cEmpAnt+", processo finalizado!")
		if lWind   
			MsgINFO(aErro[len(aErro)],cFuncao)
			RestArea(aArea)
			return
		else
			//Conout(cFuncao+" - "+aErro[len(aErro)])
			lContinua := .F.
			return // Em 05/04/17... Por Marcos Alberto Soprani (não é necessário enviar e-mail quando não há nada para ser proc...)
		endif	 	
	EndIf
	if lWind 
		nTotReg += 2
		ProcRegua(nTotReg)
	endif
	(cAliasTmp)->(DbGoTop())

	if lWind 
		nContReg++
		IncProc("EXPEDIÇÃO: Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 100, StrZero((nContReg/nTotReg)*100,3), STRZERO(100,3)) + "%")	
	endif

	if lContinua
		oMov	:= TBiaEstoque():New()

		While !(cAliasTmp)->(EOF())

			if lWind 
				nContReg++
				IncProc("EXPEDIÇÃO: Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 100, StrZero((nContReg/nTotReg)*100,3), STRZERO(100,3)) + "%")	
			endif

			do case
				case cEmpAnt == '01'
				cCeCusto 	:= (cAliasTmp)->CC01
				cClasseVal	:= (cAliasTmp)->CLVL01
				case cEmpAnt == '05'
				cCeCusto 	:= (cAliasTmp)->CC05
				cClasseVal 	:= (cAliasTmp)->CLVL05
				otherwise
				cCeCusto 	:= ''
				cClasseVal 	:= ''
			endcase

			aTemp := {{	(cAliasTmp)->TM		  		,; 
			cCeCusto 					,; 
			cClasseVal					,; 
			(cAliasTmp)->PRODUT			,; 
			(cAliasTmp)->LOTEPR			,; 
			(cAliasTmp)->LOCAL			,; 
			(cAliasTmp)->QUANT			,; 
			(cAliasTmp)->CONTA			,; 
			STOD((cAliasTmp)->DTVALID)	,; 
			'ZZZZ'						,; 
			''							,; 
			cFuncao						,; 
			(cAliasTmp)->IDECO			}}

			Begin Transaction

				dDataBase := stod((cAliasTmp)->DTREF)  

				if !oMov:MovInterno(aTemp)

					AADD(aErro, "ERRO: " + CRLF;
					+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
					+ "PRODUTO: "+ Alltrim((cAliasTmp)->PRODUT) + CRLF ; 
					+ "LOTE: "+ Alltrim((cAliasTmp)->LOTEPR) + CRLF ; 
					+ "QTD: "+ Alltrim(STR((cAliasTmp)->QUANT)) + CRLF ; 
					+ "TM: "+ Alltrim((cAliasTmp)->TM) + CRLF ; 
					+ oMov:cTxtLog + CRLF)
					//Conout(cFuncao+" - "+aErro[len(aErro)])

					DisarmTransaction()

				else

					AADD(aProces, "PROCESSADO: " + CRLF;
					+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
					+ "PRODUTO: "+ Alltrim((cAliasTmp)->PRODUT) + CRLF ; 
					+ "LOTE: "+ Alltrim((cAliasTmp)->LOTEPR) + CRLF ; 
					+ "QTD: "+ Alltrim(STR((cAliasTmp)->QUANT)) + CRLF ; 
					+ "TM: "+ Alltrim((cAliasTmp)->TM) + CRLF ; 
					+ "DOCUMENTO: "+ oMov:cTxtLog + CRLF)

				endif

			End Transaction

			(cAliasTmp)->(DbSkip())
		End
	endif

	endif

	dDataBase := dDateBkp

	if !ExistDir(cPasta)
		FWMakeDir(cPasta)
	endif
	aArqs := DIRECTORY(cPasta + "*.txt")
	For nI := 1 To Len(aArqs)  
		if aArqs[nI,3]+1 < Date()
			FErase(cPasta+AllTrim(aArqs[nI,1])) 
		endif	
	next nI

	if len(aErro) > 0
		nHandle  := fCreate(cArqErro) 
		If nHandle == -1 
			if lWind
				MsgAlert("Erro ao criar o arquvio " + cArqErro + ". Favor verificar a configurcao!",cFuncao)
			else 
				Conout(cFuncao+" - Erro ao criar o arquvio " + cArqErro + ". Favor verificar a configurcao!")
			endif
			RestArea(aArea)
			Return
		endif	
		For nI := 1 To Len(aErro) 
			FWrite(nHandle,aErro[nI]+ CRLF) 
		next nI	
		fClose(nHandle) 
	endif

	if len(aProces) > 0
		nHandle  := fCreate(cArqProc) 
		If nHandle == -1 
			if lWind
				MsgAlert("Erro ao criar o arquvio " + cArqProc + ". Favor verificar a configurcao!",cFuncao)
			else 
				Conout(cFuncao+" - Erro ao criar o arquvio " + cArqProc + ". Favor verificar a configurcao!")
			endif
			RestArea(aArea)
			Return
		endif	
		For nI := 1 To Len(aProces) 
			FWrite(nHandle,aProces[nI]+ CRLF) 
		next nI	
		fClose(nHandle) 
	endif

	cTo	:= U_EmailWF(cFuncao,cEmpAnt)
	if !Empty(cTo)

		if File(cArqErro)

			cSubject := "Erros - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus - EXPEDIÇÃO"
			cMens	 := "Segue (Anexo) arquivo de erros ocorridos durante o processamento da integração Ecosis vs Protheus - EXPEDIÇÃO."

			if !U_BIAEnvMail(, cTo, cSubject, cMens, "", cArqErro)
				if lWind
					MsgAlert("Erro ao enviar e-mail, favor verificar as configurcões!",cFuncao)
				else 
					Conout(cFuncao+" - Erro ao enviar e-mail, favor verificar as configurcões!")
				endif	
			else
				lErro := .T.
			endif	
		endif

		if File(cArqProc)

			cSubject := "Processados - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus - EXPEDIÇÃO"
			cMens	 := "Segue (Anexo) arquivo com os registros processados com sucesso pela rotina de integração Ecosis vs Protheus - EXPEDIÇÃO."

			if !U_BIAEnvMail(, cTo, cSubject, cMens, "", cArqProc)
				if lWind
					MsgAlert("Erro ao enviar e-mail, favor verificar as configurcões!",cFuncao)
				else 
					Conout(cFuncao+" - Erro ao enviar e-mail, favor verificar as configurcões!")
				endif	
			else
				lProces	:= .T.
			endif	
		endif

	else
		if lWind
			MsgAlert("Erro ao enviar e-mail! Não existem destinatarios configurados para o recebimento do e-mail de erros!",cFuncao)
		else 
			Conout(cFuncao+" - Erro ao enviar e-mail! Nao existem destinatarios configurados para o recebimento do e-mail de erros!")
		endif	
	endif

	cMens := ''
	if lProces .and. lErro
		cMens := "Processo Finalizado com Erros e acertos!" + CRLF ;
		+"e-mail, referente aos resultados dos registros processados, foi enviado com sucesso para os seguintes destinatarios: " + CRLF + cTo
	elseif lProces .and. !lErro
		cMens := "Processo Finalizado com Sucesso!" + CRLF ;
		+"e-mail, referente aos resultados dos registros processados, foi enviado com sucesso para os seguintes destinatarios: " + CRLF + cTo
	elseif !lProces .and. lErro
		cMens := "Processo Finalizado com Erros!" + CRLF ;
		+"e-mail, referente aos resultados dos registros processados, foi enviado com sucesso para os seguintes destinatarios: " + CRLF + cTo
	endif

	if lWind 
		nContReg++
		IncProc("EXPEDIÇÃO: Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 100, StrZero((nContReg/nTotReg)*100,3), STRZERO(100,3)) + "%")	
	endif

	if !Empty(cMens) 
		if lWind
			MsgAlert(cMens,cFuncao)
		else 
			//Conout(cFuncao+" - "+cMens)
		endif
	endif

	RestArea(aArea)
return


// Somente para teste do job
User Function BI065JOB()
	STARTJOB("U_BIAF065",GetEnvServer(),.F.,cEmpAnt,cFilAnt)
return
