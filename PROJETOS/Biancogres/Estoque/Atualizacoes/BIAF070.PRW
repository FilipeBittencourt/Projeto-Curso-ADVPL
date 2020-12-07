#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwcommand.ch"

/*/{Protheus.doc} BIAF070
@author Artur Antunes
@since 07/04/2017
@version 1.0
@description Rotina para Integração Ecosis vs Protheus, transferencia de saldos
@obs OS: 1215-17
@type function
/*/

User Function BIAF070()

	Local nRecSM0  		:= 0 
	Local aEmpres  		:= {}   
	Local nx	   		:= 0   
	Local cEFjob		:= "0101/0501" 
	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Local _aSm0	:=	{}
	Local _nI
	Local _cEmp

	Private lWind 		:= Type("oMainWnd") <> "U"
	private cFuncao     := 'BIAF070'
	private dDtMovDe    := STOD('')   
	private dDtMovAte   := STOD('')   

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

		End 	
		SM0->(DbGoTo(nRecSM0)) 

		For nx := 1 to Len(aEmpres)

			RpcClearEnv()
			RpcSetType(3)
			RpcSetEnv(aEmpres[nx,1],aEmpres[nx,2],,,"EST") 

			Conout( cFuncao + " - Processando Integracao (Início)! " + Time() + aEmpres[nx,1] )

			fProcInteg(aEmpres[nx,1],aEmpres[nx,2])

			Conout( cFuncao + " - Processando Integracao (.Fim..)! " + Time() + aEmpres[nx,1] )

		next nx

	else	

		if cEmpAnt + '01' $ cEFjob

			fPergunte()

			AADD(aSays, OemToAnsi("Rotina para Integração de Movimentação de Estoque,"))   
			AADD(aSays, OemToAnsi("Ecosis vs Protheus."))   
			AADD(aSays, OemToAnsi("Transferencia de SALDOS DE PRODUTOS!"))   
			AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
			AADD(aSays, OemToAnsi("Deseja Continuar?"))   

			AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
			AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
			AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

			FormBatch( OemToAnsi('Integração Ecosis vs Protheus - TRANSF SALDO PRODUTO'), aSays, aButtons ,,,500)

			if lConfirm

				if !Empty(dDtMovDe) .and. !Empty(dDtMovAte) 

					Processa({ || fProcInteg(cEmpAnt,'01') },"Aguarde...","Carregando Registros...",.F.)

				else	

					MsgStop("Periodo não informado!!!",cFuncao)
					Return

				endif

			endif

		else

			MsgStop("Empresa não configurada para Integração Ecosis vs Protheus - TRANSF. SALDOS DE PRODUTOS !!!",cFuncao)
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

	If ParamBox(aPergs ,"Integração Ecosis vs Protheus - TRANSF. SALDO PRODUTO",,,,,,,,cLoad,.T.,.T.)      
		dDtMovDe  := ParamLoad(cFileName,,1,dDtMovDe) 
		dDtMovAte := ParamLoad(cFileName,,2,dDtMovAte)     
	endif

return

//Processa Integração
Static Function fProcInteg(_cEmp,_cFil)

	local aArea      	:= GetArea()
	local cAliasTmp 	:= GetNextAlias()
	local cTemp			:= ''
	local cLocOrig		:= ''
	local cLocDest		:= ''
	local cLocaliz		:= 'ZZZZ'
	local oTransf		:= nil
	local aErro			:= {}
	local aProces		:= {}
	local nContReg		:= 0
	local nTotReg		:= 0
	local cBaseDados	:= ''
	local cQuery 		:= ''
	local lContinua		:= .T.
	local dDateBkp		:= Date() 
	Local cPasta 	 	:= AllTrim(GetNewPar("MV_YITGERR","\LOG_ERRO_Ecosis_x_Protheus\")) 
	Local cArqErro 	 	:= cPasta + cFuncao + "-ERRO" + "-D"+ALLTrim( DTOS(DATE())+"-H"+StrTran( time(),':','-')) + ".txt"
	Local cArqProc 	 	:= cPasta + cFuncao + "-PROCESSADOS" + "-D"+ALLTrim( DTOS(DATE())+"-H"+StrTran( time(),':','-')) + ".txt"
	local nHandle    	:= 0
	local nI			:= 0
	local cTo      		:= ''
	local cArqCamin		:= ''
	local dDataCorte	:= STOD(AllTrim(GetNewPar("MV_YITDT70","20170412"))) 
	local cSubject 		:= ""
	local cMens	   		:= ""
	local lErro			:= .F.
	local lProces		:= .F.
	local cProdOri 		:= ""
	local cLoteOri 		:= ""
	local nQuant   		:= 0
	local nBordero		:= 0
	local cProdDest		:= ""
	local cLoteDest		:= ""
	local _lErroZZ9		:=	.F.

	if Type('dDataBase') == "D"
		if !Empty(dDataBase)
			dDateBkp := dDataBase
		endif
	else
		dDataBase := Date()
	endif

	cEmpAnt := _cEmp
	cFilAnt := _cFil

	Conout( cFuncao + " - Processando Integracao (Antes da Query)! " + Time() + cEmpAnt )

	If cEmpAnt == "01"
		cBaseDados := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		cBaseDados := "DADOS_05_EOS"
	Else
		AADD(aErro,"Empresa "+cEmpAnt+" não configurada para Integração Ecosis vs Protheus - TRANSF. SALDO PRODUTO!!")
		if lWind   
			MsgINFO(aErro[len(aErro)],cFuncao)
			RestArea(aArea)
			return
		else
			//Conout(cFuncao+" - "+aErro[len(aErro)])
			lContinua := .F.
			RestArea(aArea)
			return
		endif	
	EndIf

	if lContinua

		cQuery := " SELECT A.id_bordero BORDERO, " + CRLF
		cQuery += "        CASE " + CRLF
		cQuery += "          WHEN C.cod_transacao = '67' then '999' " + CRLF
		cQuery += "          WHEN C.cod_transacao = '5' then '499' " + CRLF
		cQuery += "          ELSE 'ERR' " + CRLF
		cQuery += "        END TM, " + CRLF
		cQuery += "        A.brd_data DTREF, " + CRLF
		cQuery += "        C.id_mov_prod IDECO, " + CRLF
		cQuery += "        C.cod_produto PRODUTO, " + CRLF
		cQuery += "        B.cod_etiqueta ETIQUETA, " + CRLF
		cQuery += "        C.ce_lote LOTECRL, " + CRLF
		cQuery += "        C.ce_qtdade QUANT, " + CRLF
		cQuery += " 	   SUBSTRING(CONVERT(VARCHAR(10), A.brd_data, 112), 1, 8) DTREF, " + CRLF
		cQuery += " 	   SUBSTRING(CONVERT(VARCHAR(16), A.brd_data, 120), 12, 5) HRREF, " + CRLF
		cQuery += " 	   SB1.B1_LOCPAD ALMOX " + CRLF
		cQuery += "  FROM " + cBaseDados + "..cep_etiqueta_reclas (NOLOCK) A " + CRLF
		cQuery += "  INNER JOIN " + cBaseDados + "..cep_etiqueta_reclas_itens (NOLOCK) B " + CRLF 
		cQuery += "   ON B.id_bordero = A.id_bordero " + CRLF
		cQuery += "  INNER JOIN " + cBaseDados + "..cep_movimento_produto (NOLOCK) C " + CRLF 
		cQuery += "   ON C.ce_numero_docto = B.cod_etiqueta " + CRLF
		cQuery += "   AND C.ce_data_movimento >= A.brd_data " + CRLF
		cQuery += "   AND C.ce_docto in('CA','ET') " + CRLF
		cQuery += "   AND C.ce_usuario = A.brd_usuario " + CRLF
		cQuery += "   AND A.id_bordero NOT IN('1870', '1868', '1863', '1862') " + CRLF
		cQuery += "   AND NOT EXISTS ( SELECT D3_YIDECO ID " + CRLF
		cQuery += "                    FROM " + RetSQLName("SD3") + " SD3 WITH (NOLOCK) " + CRLF
		cQuery += "                     WHERE SD3.D3_YIDECO = ID_MOV_PROD " + CRLF
		cQuery += "                     AND SD3.D3_FILIAL = '" + xFilial('SD3') + "' " + CRLF
		cQuery += "                     AND SD3.D3_ESTORNO = ' ' " + CRLF
		cQuery += "                     AND SD3.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "                    UNION ALL " + CRLF
		cQuery += "                    SELECT Z18_IDECO ID " + CRLF
		cQuery += "                    FROM " + RetSQLName("Z18") + " Z18 WITH (NOLOCK) " + CRLF
		cQuery += "                    WHERE Z18_IDECO = ID_MOV_PROD " + CRLF
		cQuery += "                     AND Z18.Z18_FILIAL = '" + xFilial('Z18') + "' " + CRLF
		cQuery += "                     AND Z18.D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "  LEFT JOIN " + RetSQLName("SB1") + " (NOLOCK) SB1  " + CRLF
		cQuery += "   ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " + CRLF
		cQuery += "   AND SB1.B1_COD COLLATE DATABASE_DEFAULT = C.cod_produto COLLATE DATABASE_DEFAULT " + CRLF
		cQuery += "   AND SB1.D_E_L_E_T_ = '' " + CRLF		
		cQuery += "  WHERE SUBSTRING(CONVERT(VARCHAR(10), A.brd_data, 112), 1, 10) >= '" + dtos(dDataCorte) + "' " + CRLF
		If lWind
			If !Empty(dDtMovDe) .and. !Empty(dDtMovAte) 		
				cQuery += "   AND SUBSTRING(CONVERT(VARCHAR(10), A.brd_data, 112), 1, 10) BETWEEN '"+dtos(dDtMovDe)+"' AND '"+dtos(dDtMovAte)+"' " + CRLF
			endif
		endif	
		cQuery += "   AND A.brd_transferido = '1' " + CRLF
		cQuery += "  ORDER BY A.id_bordero, C.cod_transacao DESC " + CRLF 

		TcQuery cQuery Alias (cAliasTmp) New

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
				RestArea(aArea)
				return
			endif	 	
		EndIf

		if lWind 
			nTotReg += 2
			ProcRegua(nTotReg)
		endif

		(cAliasTmp)->(DbGoTop())

		if lWind 
			nContReg++
			IncProc("Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(99,2)) + "%")	
		endif

		Conout( cFuncao + " - Processando Integracao (Depois da Query)! " + Time() + cEmpAnt )
		if lContinua

			oTransf	:= TBiaEstoque():New()

			Conout( cFuncao + " - Processando Integracao (Depois da Transferência)! " + Time() + cEmpAnt )

			While !(cAliasTmp)->(EOF())

				Begin Transaction

					dDataBase := (cAliasTmp)->DTREF 

					cProdOri  := ""
					cLoteOri  := ""
					cLocOrig  := ""
					cProdDest := ""
					cLoteDest := ""
					cLocDest  := ""

					nBordero  := (cAliasTmp)->BORDERO
					nQuant    := 0

					While !(cAliasTmp)->(EOF()) .and. (cAliasTmp)->BORDERO == nBordero 

						if lWind 
							nContReg++
							IncProc("Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(99,2)) + "%")	
						endif

						if (cAliasTmp)->TM == '999'
							cProdOri := (cAliasTmp)->PRODUTO
							cLoteOri := (cAliasTmp)->LOTECRL
							cLocOrig := (cAliasTmp)->ALMOX
							nQuant   += (cAliasTmp)->QUANT
						elseif (cAliasTmp)->TM == '499'
							cProdDest := (cAliasTmp)->PRODUTO
							cLoteDest := (cAliasTmp)->LOTECRL
							cLocDest  := (cAliasTmp)->ALMOX
						endif

						If (cAliasTmp)->TM <> "ERR"

							ZZ9->(dbSetOrder(2))	
							If !ZZ9->( dbSeek(xFilial("ZZ9") + Padr((cAliasTmp)->PRODUTO,15) + Padr((cAliasTmp)->LOTECRL,10) ))
								_lErroZZ9	:=	.T.
								DisarmTransaction()
								(cAliasTmp)->(DbSkip())
								Exit
							EndIf

						EndIf

						dbSelectArea("Z18")
						Z18->(RecLock("Z18",.T.))
						Z18->Z18_FILIAL := xFilial("Z18")
						Z18->Z18_IDECO  := (cAliasTmp)->IDECO
						Z18->Z18_COD    := (cAliasTmp)->PRODUTO
						Z18->Z18_DATA   := dDataBase
						Z18->Z18_QUANT  := (cAliasTmp)->QUANT
						Z18->Z18_NUMETQ := Alltrim(Str((cAliasTmp)->ETIQUETA))
						Z18->Z18_DOCSD3 := "BIAF070"
						Z18->Z18_NSQSD3 := "XTEMPF"
						Z18->Z18_DTCANC := Date()
						Z18->Z18_TM     := "TRF"
						Z18->(MsUnLock())

						(cAliasTmp)->(DbSkip())

					End

					If !_lErroZZ9

						If !oTransf:FSTransfere( {{cProdOri, cLocOrig, cLocDest, cLoteOri, cLocaliz, nQuant, 0, cProdDest, cLoteDest }} )

							AADD(aErro, "ERRO: " + CRLF;
							+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
							+ "BORDERO: "+ Alltrim(STR(nBordero)) + CRLF ; 
							+ "PRODUTO ORIGEM: "+ Alltrim(cProdOri) + CRLF ; 
							+ "LOTE ORIGEM: "+ Alltrim(cLoteOri) + CRLF ; 
							+ "ALMOX ORIGEM: "+ Alltrim(cLocOrig) + CRLF ; 
							+ "PRODUTO DESTINO: "+ Alltrim(cProdDest) + CRLF ; 
							+ "LOTE DESTINO: "+ Alltrim(cLoteDest) + CRLF ; 
							+ "ALMOX DESTINO: "+ Alltrim(cLocDest) + CRLF ; 
							+ "QTD: "+ Alltrim(STR(nQuant)) + CRLF ; 
							+ Iif(_lErroZZ9, "ZZ9: PRODUTO/LOTE NÃO ENCONTRADO(S)" + CRLF,"");
							+ oTransf:cTxtLog + CRLF)

							DisarmTransaction()

						Else

							AADD(aProces, "PROCESSADO: " + CRLF;
							+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
							+ "BORDERO: "+ Alltrim(STR(nBordero)) + CRLF ; 
							+ "PRODUTO ORIGEM: "+ Alltrim(cProdOri) + CRLF ; 
							+ "LOTE ORIGEM: "+ Alltrim(cLoteOri) + CRLF ; 
							+ "ALMOX ORIGEM: "+ Alltrim(cLocOrig) + CRLF ; 
							+ "PRODUTO DESTINO: "+ Alltrim(cProdDest) + CRLF ; 
							+ "LOTE DESTINO: "+ Alltrim(cLoteDest) + CRLF ; 
							+ "ALMOX DESTINO: "+ Alltrim(cLocDest) + CRLF ; 
							+ "QTD: "+ Alltrim(STR(nQuant)) + CRLF ; 
							+ "DOCUMENTO: "+ oTransf:cTxtLog + CRLF)				

							UP005 := " UPDATE " + RetSqlName("Z18") + " SET Z18_DOCSD3 = '" + oTransf:cTxtLog + "', Z18_DCD3PP = 'BIAF070' "
							UP005 += "   FROM " + RetSqlName("Z18") + " "
							UP005 += "  WHERE Z18_DOCSD3 = 'BIAF070' "
							UP005 += "    AND Z18_NSQSD3 = 'XTEMPF' "
							UP005 += "    AND Z18_DATA = '" + dtos(dDataBase) + "' "
							UP005 += "    AND Z18_COD = '" + Alltrim(skProdut) + "' "
							UP005 += "    AND Z18_TM = 'TRF' "
							UP005 += "    AND D_E_L_E_T_ = ' ' "															
							TcSqlExec(UP005)

						EndIf										

					EndIf

				End Transaction

			EndDo()

		EndIf

	EndIf

	dDataBase := dDateBkp

	If !ExistDir(cPasta)
		FWMakeDir(cPasta)
	EndIf
	aArqs := DIRECTORY(cPasta + "*.txt")
	For nI := 1 To Len(aArqs)  
		if aArqs[nI,3]+1 < Date() .and. cFuncao $ AllTrim(aArqs[nI,1])
			FErase(cPasta+AllTrim(aArqs[nI,1])) 
		endif	
	Next nI

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

			cSubject := "Erros - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus - TRANSF SALDO PRODUTO"
			cMens	 := "Segue (Anexo) arquivo de erros ocorridos durante o processamento da integração Ecosis vs Protheus - TRANSF. SALDOS DE PRODUTOS."

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

			cSubject := "Processados - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus - TRANSF SALDO PRODUTO"
			cMens	 := "Segue (Anexo) arquivo com os registros processados com sucesso pela rotina de integração Ecosis vs Protheus - TRANSF. SALDOS DE PRODUTOS."

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
		IncProc("Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	
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

User Function BI070JOB()

	STARTJOB("U_BIAF070",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

return
