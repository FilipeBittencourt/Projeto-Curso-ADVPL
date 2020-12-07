#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwcommand.ch"


/*/{Protheus.doc} BIAF063
@author Artur Antunes
@since 09/02/2017
@version 1.0
@description Rotina para Integração Ecosis vs Protheus
@obs OS: 0243-16
@type function
/*/

User Function BIAF063()

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
	private cFuncao     := 'BIAF063'
	private dDtMovDe    := STOD('')   
	private dDtMovAte   := STOD('')   
	private dDtRef      := Date()  

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
			Conout(cFuncao+" - Processando Integracao!")
			fProcInteg(aEmpres[nx,1],aEmpres[nx,2])

		next nx

	else	

		if cEmpAnt + '01' $ cEFjob

			fPergunte()

			AADD(aSays, OemToAnsi("Rotina para Integração de Movimentação de Estoque,"))   
			AADD(aSays, OemToAnsi("Ecosis vs Protheus."))   
			AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
			AADD(aSays, OemToAnsi("Deseja Continuar?"))   

			AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
			AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
			AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

			FormBatch( OemToAnsi('Integração Ecosis vs Protheus'), aSays, aButtons ,,,500)

			if lConfirm
				if !Empty(dDtMovDe) .and. !Empty(dDtMovAte) 
					Processa({ || fProcInteg(cEmpAnt,'01') },"Aguarde...","Carregando Registros...",.F.)
				else	
					MsgStop("Periodo não informado!!!",cFuncao)
					Return
				endif
			endif
		else
			MsgStop("Empresa não configurada para Integração Ecosis vs Protheus !!!",cFuncao)
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
	dDtRef    := STOD('')    

	aAdd( aPergs ,{1,"DT Movto Eco de: " ,dDtMovDe  ,"","NAOVAZIO()",'','.T.',50,.F.})	
	aAdd( aPergs ,{1,"DT Movto Eco Ate:" ,dDtMovAte ,"","NAOVAZIO()",'','.T.',50,.F.})	
	aAdd( aPergs ,{1,"DT Ref Protheus :" ,dDtRef    ,"","NAOVAZIO()",'','.T.',50,.F.})	

	If ParamBox(aPergs ,"Integração Ecosis vs Protheus",,,,,,,,cLoad,.T.,.T.)      
		dDtMovDe  := ParamLoad(cFileName,,1,dDtMovDe) 
		dDtMovAte := ParamLoad(cFileName,,2,dDtMovAte)     
		dDtRef    := ParamLoad(cFileName,,3,dDtRef)     
	endif

return

//Processa Integração
Static Function fProcInteg(_cEmp,_cFil)

	local aArea      	:= GetArea()
	local cAliasTmp 	:= GetNextAlias()
	local cTemp			:= ''
	local cLocOrig		:= '02'
	local cLocDest		:= '07'
	local cLocaliz		:= 'PAP'
	local oTransf		:= nil
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
	local cArqCamin		:= ''
	local dDataCorte	:= STOD(AllTrim(GetNewPar("MV_YITDT63","20170222"))) 
	Local cFrom    		:= "administrador@biancogres.com.br"
	local cSubject 		:= ""
	local cMens	   		:= ""
	local lErro			:= .F.
	local lProces		:= .F.
	Local _nLinha

	Local _nPosCheck		:=	0
	Local _nPosBord		:=	0
	Local _nPosClVl		:=	0
	Local _nPosQuebra	:=	0

	Local _cErro		:=	""
	Local _cDocQuebr	:=	""

	Private _oGetDados	:=	Nil 

	If dDtRef <= GetMV("MV_ULMES") .or. dDtRef <= GetMV("MV_YULMES")
		MsgSTOP("Favor Verificar a [DT Ref Protheus] do parâmetro, pois não pode ser menor que a data do último fechamento do estoque!!!", "Data de Fechamento!!!")
		Return
	EndIf

	If dDtRef > Date()
		MsgSTOP("Favor Verificar a [DT Ref Protheus] do parâmetro, pois não pode ser maior que a data do dia do servidor!!!", "Data de Fechamento!!!")
		Return
	EndIf

	if Type('dDataBase') == "D"
		if !Empty(dDataBase)
			dDateBkp := dDataBase
		endif
	else
		dDataBase := Date()
	endif

	cEmpAnt := _cEmp
	cFilAnt := _cFil

	If cEmpAnt == "01"
		cBaseDados := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		cBaseDados := "DADOS_05_EOS"
	Else
		AADD(aErro,"Empresa "+cEmpAnt+" não configurada para Integração Ecosis vs Protheus!!")
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

		cQuery := " SELECT A.CE_NUMERO_DOCTO ETIQUET, " + CRLF
		cQuery += "        CAB.ID_BORDERO IDBORD, " + CRLF
		cQuery += "        A.ID_MOV_PROD IDECO, " + CRLF

		cQuery += "        A.COD_TRANSACAO TRANSAC, " + CRLF
		cQuery += "        A.COD_PRODUTO PRODUT, " + CRLF
		cQuery += "        A.CE_LOTE LOTEPR, " + CRLF
		cQuery += "        A.CE_QTDADE QUANT, " + CRLF
		cQuery += "        SUBSTRING(CONVERT(VARCHAR(10), CAB.BRD_DATA, 112), 1, 10) DTREF, " + CRLF
		cQuery += "        SUBSTRING(CONVERT(VARCHAR(16), CAB.BRD_DATA, 120), 12, 5) HRREF, " + CRLF
		cQuery += "        ID_MOV_PROD ID " + CRLF
		cQuery += "   FROM " + cBaseDados + "..CEP_MOVIMENTO_PRODUTO A " + CRLF
		cQuery += "  INNER JOIN " + cBaseDados + "..CEP_ETIQUETA_PROCESSA_ITENS ITN ON ITN.COD_ETIQUETA = A.CE_NUMERO_DOCTO " + CRLF
		cQuery += "  INNER JOIN " + cBaseDados + "..CEP_ETIQUETA_PROCESSA CAB ON CAB.ID_BORDERO = ITN.ID_BORDERO " + CRLF
		cQuery += "                                                AND CAB.ID_CIA = ITN.ID_CIA " + CRLF
		cQuery += "                                                AND CAB.BRD_TRANSFERIDO = '1' " + CRLF
		cQuery += "                                                AND CAB.ID_BORDERO NOT IN('1130','1131','1132','1133','1134','1135','1136','1457','1462'," + CRLF
		cQuery += "                                                							 '2619','2626','2794','3061','3263','3796','3970','3972','4089'," + CRLF
		cQuery += "                                                							 '4111','4276','4364','4638','4718','4833','4834','4835','4843'," + CRLF
		cQuery += "                                                							 '4850','4852','4853','4855','4865','5193','5455','6031','6033','6034') " + CRLF
		cQuery += "                                                AND SUBSTRING(CONVERT(VARCHAR(10), CAB.BRD_DATA, 112), 1, 10) >= '" + dtos(dDataCorte) + "' " + CRLF
		If lWind
			If !Empty(dDtMovDe) .and. !Empty(dDtMovAte) 
				cQuery += "                                                AND SUBSTRING(CONVERT(VARCHAR(10), CAB.BRD_DATA, 112), 1, 10) BETWEEN '"+dtos(dDtMovDe)+"' AND '"+dtos(dDtMovAte)+"' " + CRLF
			EndIf	
		EndIf
		cQuery += "  WHERE A.COD_TRANSACAO IN('70', '76') " + CRLF
		cQuery += "    AND NOT EXISTS ( SELECT D3_YIDECO ID " + CRLF
		cQuery += "                       FROM " + RetSQLName("SD3") + " SD3 WITH (NOLOCK) " + CRLF
		cQuery += "                      WHERE SD3.D3_YIDECO = ID_MOV_PROD " + CRLF
		cQuery += "                        AND SD3.D3_FILIAL = '" + xFilial('SD3') + "' " + CRLF
		cQuery += "                        AND SD3.D3_ESTORNO = ' ' " + CRLF
		cQuery += "                        AND SD3.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "                      UNION ALL " + CRLF
		cQuery += "                     SELECT Z18_IDECO ID " + CRLF
		cQuery += "                       FROM " + RetSQLName("Z18") + " Z18 WITH (NOLOCK) " + CRLF
		cQuery += "                      WHERE Z18_IDECO = ID_MOV_PROD " + CRLF
		cQuery += "                        AND Z18.Z18_FILIAL = '" + xFilial('Z18') + "' " + CRLF
		cQuery += "                        AND Z18.D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "  ORDER BY CAB.BRD_DATA, A.COD_PRODUTO, A.CE_LOTE, CAB.ID_BORDERO " + CRLF	 
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
				lContinua := .F.
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

		if lContinua

			If fShowGrid(cAliasTmp)

				_nPosBord	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "BORD"})
				_nPosCheck	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "CHECK"})
				_nPosClVl	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "CLVL"})
				_nPosQuebra	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "QUEBRA"})

				(cAliasTmp)->(DbGoTop())

				oTransf	:= TBiaEstoque():New()

				While !(cAliasTmp)->(EOF())

					If (_nLinha	:=	aScan(_oGetDados:aCols,{|x| x[_nPosBord] == (cAliasTmp)->IDBORD .And. x[_nPosCheck] == "LBOK" })) > 0
						Begin Transaction

							dDataBase := dDtRef  

							//************ Por Marcos Alberto - 20170220 *
							skBorder := (cAliasTmp)->IDBORD
							skProdut := (cAliasTmp)->PRODUT
							skLotePR := (cAliasTmp)->LOTEPR
							skQtdPrd := 0

							While !(cAliasTmp)->(EOF()) .and. (cAliasTmp)->PRODUT == skProdut .and. (cAliasTmp)->LOTEPR == skLotePR .and. (cAliasTmp)->IDBORD == skBorder

								if lWind 
									nContReg++
									IncProc("Integração Ecosis vs Protheus - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(99,2)) + "%")	
								endif

								dbSelectArea("Z18")
								RecLock("Z18",.T.)
								Z18->Z18_FILIAL := xFilial("Z18")
								Z18->Z18_IDECO  := (cAliasTmp)->IDECO
								Z18->Z18_COD    := (cAliasTmp)->PRODUT
								Z18->Z18_DATA   := dDataBase
								Z18->Z18_QUANT  := (cAliasTmp)->QUANT
								Z18->Z18_NUMETQ := Alltrim(Str((cAliasTmp)->ETIQUET))
								Z18->Z18_DOCSD3 := "BIAF063"
								Z18->Z18_NSQSD3 := "XTEMPF"
								Z18->Z18_DTCANC := Date()
								Z18->Z18_TM     := "TRF"
								MsUnLock()

								skQtdPrd += (cAliasTmp)->QUANT

								(cAliasTmp)->(DbSkip())

							EndDo()

							if !oTransf:FSTransfere( {{skProdut, cLocOrig, cLocDest, skLotePR, cLocaliz, skQtdPrd, 0000000 }} )

								AADD(aErro, "ERRO: " + CRLF;
								+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
								+ "PRODUTO: "+ Alltrim(skProdut) + CRLF ; 
								+ "LOTE: "+ Alltrim(skLotePR) + CRLF ; 
								+ "QTD: "+ Alltrim(STR(skQtdPrd)) + CRLF ; 
								+ "BORDERÔ: "+ Alltrim(STR(skBorder)) + CRLF ; 
								+ oTransf:cTxtLog + CRLF)

								DisarmTransaction()

							else

								_cErro	:=	""
								_cDocQuebr	:=	""
								If _oGetDados:aCols[_nLinha,_nPosQuebra] == "1" .And. !fQuebra(cLocDest,cLocaliz,_oGetDados:aCols[_nLinha,_nPosClvl],@_cErro,@_cDocQuebr)

									AADD(aErro, "ERRO(QUEBRA): " + CRLF;
									+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
									+ "PRODUTO: "+ Alltrim(skProdut) + CRLF ; 
									+ "LOTE: "+ Alltrim(skLotePR) + CRLF ; 
									+ "QTD: "+ Alltrim(STR(skQtdPrd)) + CRLF ; 
									+ "BORDERÔ: "+ Alltrim(STR(skBorder)) + CRLF ; 
									+ @_cErro + CRLF)

									DisarmTransaction()							

								Else

									AADD(aProces, "PROCESSADO: " + CRLF;
									+ "DATA DA MOVIMENTAÇÃO: " + DTOC(dDataBase) + CRLF;
									+ "PRODUTO: "+ Alltrim(skProdut) + CRLF ; 
									+ "LOTE: "+ Alltrim(skLotePR) + CRLF ; 
									+ "QTD: "+ Alltrim(STR(skQtdPrd)) + CRLF ; 
									+ "BORDERÔ: "+ Alltrim(STR(skBorder)) + CRLF ; 
									+ "DOCUMENTO: "+ oTransf:cTxtLog + CRLF;
									+ Iif(_oGetDados:aCols[_nLinha,_nPosQuebra] == "1","DOCUMENTO(QUEBRA): "+ Alltrim(_cDocQuebr),"") + CRLF )

									UP005 := " UPDATE " + RetSqlName("Z18") + CRLF
									UP005 += " SET Z18_DOCSD3 = '" + oTransf:cTxtLog + "', Z18_DCD3PP = 'BIAF063' " + CRLF
									UP005 += "   FROM " + RetSqlName("Z18") + CRLF
									UP005 += "  WHERE Z18_DOCSD3 = 'BIAF063' " + CRLF
									UP005 += "    AND Z18_NSQSD3 = 'XTEMPF' " + CRLF
									UP005 += "    AND Z18_DATA = '" + dtos(dDataBase) + "' " + CRLF
									UP005 += "    AND Z18_COD = '" + Alltrim(skProdut) + "' " + CRLF
									UP005 += "    AND Z18_TM = 'TRF' " + CRLF
									UP005 += "    AND D_E_L_E_T_ = ' ' "															
									TcSqlExec(UP005)

								EndIf



							EndIf

						End Transaction

					Else

						(cAliasTmp)->(DbSkip())

					EndIf

				EndDo()
			EndIf
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
				MsgAlert("Erro ao criar o arquivo " + cArqErro + ". Favor verificar a configuracao!",cFuncao)
			else 
				Conout(cFuncao+" - Erro ao criar o arquivo " + cArqErro + ". Favor verificar a configuracao!")
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
				MsgAlert("Erro ao criar o arquivo " + cArqProc + ". Favor verificar a configuracao!",cFuncao)
			else 
				Conout(cFuncao+" - Erro ao criar o arquivo " + cArqProc + ". Favor verificar a configuracao!")
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

			cSubject := "Erros - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus"
			cMens	 := "Segue (Anexo) arquivo de erros ocorridos durante o processamento da integração Ecosis vs Protheus ."

			if !U_BIAEnvMail(, cTo, cSubject, cMens, "", cArqErro)
				if lWind
					MsgAlert("Erro ao enviar e-mail, favor verificar as configuracões!",cFuncao)
				else 
					Conout(cFuncao+" - Erro ao enviar e-mail, favor verificar as configuracões!")
				endif	
			else
				lErro := .T.
			endif	
		endif

		if File(cArqProc)

			cSubject := "Processados - Emp: "+cEmpAnt+" - Integração Ecosis vs Protheus"
			cMens	 := "Segue (Anexo) arquivo com os registros processados com sucesso pela rotina de integração Ecosis vs Protheus ."

			if !U_BIAEnvMail(cFrom, cTo, cSubject, cMens, "", cArqProc, .F.)
				if lWind
					MsgAlert("Erro ao enviar e-mail, favor verificar as configuracões!",cFuncao)
				else 
					Conout(cFuncao+" - Erro ao enviar e-mail, favor verificar as configuracões!")
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
		endif
	endif

	RestArea(aArea)

return

User Function BI063JOB()

	STARTJOB("U_BIAF063",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

return

Static Function fShowGrid(_cAlias)

	Local _aSize 		:=	{} 
	Local _aObjects		:=	{}
	Local _aInfo		:=	{}
	Local _aPosObj		:=	{}


	Local nOpcGd	:= 0 //Somente Visualizar

	Local oFont  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)

	Local _nPosBord	:=	0
	Local _nPosQtd	:=	0
	Local _nPos	:=	0

	Local _aHeader	:=	{}			          
	Local _aCols	:=	{}	

	Private _nOpca	:= 0		

	_aSize := MsAdvSize(.T.)

	AAdd(_aObjects, {100, 10, .T. , .T. })
	AAdd(_aObjects, {100, 90, .T. , .T. })                      

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	aadd(_aHeader,{''		       ,'CHECK'     ,'@BMP'             , 2                         , 0,,, "C",     ,"V",,,'seleciona','V','S'})
	aAdd(_aHeader,{"Borderô"       ,"BORD" 	    ,"@!"               , 15                        , 0,,, "N",, })      	// 1
	aAdd(_aHeader,{"Cod. Produto"  ,"CODPRO" 	,"@!"               , TAMSX3("B1_COD")[1]       , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Descrição"     ,"DESPRO" 	,"@S40"             , TAMSX3("B1_DESC")[1]      , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Lote"          ,"LOTE" 	    ,"@!"               , TAMSX3("B8_LOTECTL")[1]   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Qtd."          ,"QTD" 	    ,"@E 999,999.99"    , 09                        , 2,,, "N",, })      	// 1
	aAdd(_aHeader,{"Dt. Eco"       ,"DTECO" 	,"@!"               , 08                        , 0,,, "D",, })      	// 1
	aAdd(_aHeader,{"Hr. Eco"       ,"HRECO" 	,"@!"               , 05                        , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Quebra"       ,"QUEBRA" 	,"@!"               , 01                        , 0,,, "C",,,"1=Sim;2=Não" })      	// 1
	aAdd(_aHeader,{"Cl. Valor"     ,"CLVL" 	    ,"@!"               , TAMSX3("CTH_CLVL")[1]   , 0,,, "C",,,"3135=RETIFICA-L3;3136=POLIMENTO LINHA 4" })      	// 1

	_nPosBord	:=	aScan(_aHeader,{|x| ALLTRIM(x[2]) == "BORD"})
	_nPosQtd	:=	aScan(_aHeader,{|x| ALLTRIM(x[2]) == "QTD"})

	While (_cAlias)->(!EOF())
		If (_nPos := aScan(_aCols,{|x| x[_nPosBord] == (_cAlias)->IDBORD})) > 0
			_aCols[_nPos,_nPosQtd] +=	(_cAlias)->QUANT
		Else
			(_cAlias)->(aAdd(_aCols,{"LBNO",;
			IDBORD,;
			PRODUT,;
			POSICIONE("SB1",1,xFilial("SB1")+PRODUT,"B1_DESC"),;
			LOTEPR,;
			QUANT,;
			Stod(DTREF),;
			HRREF,;
			Iif(TRANSAC == 76,"1","2"),;
			SPACE(TAMSX3("CTH_CLVL")[1]),;
			.F.;
			}))

		EndIf

		(_cAlias)->(DbSkip())
	EndDo

	Define MsDialog _oDlg Title "Operações de Importação" From _aSize[7],0 To _aSize[6],_aSize[5] Of oMainWnd Pixel

	@ _aPosObj[1,1]+010,010 SAY "Dt. Ref:" SIZE 55, 11 OF _oDlg PIXEL FONT oFont
	@ _aPosObj[1,1]+008,047 MSGET MV_PAR03  SIZE 17, 11 OF _oDlg PIXEL WHEN .F.

	_oGetDados := MsNewGetDados():New(_aPosObj[2,1], _aPosObj[2,2], _aPosObj[2,3], _aPosObj[2,4], GD_UPDATE, "AlwaysTrue" /*[ cLinhaOk]*/,"U_BF63TOK()" /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, {"CLVL"}/*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, "AlwaysTrue"/*cFieldOK*/,"AlwaysTrue" /*[ cSuperDel]*/, "AlwaysTrue"/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	_oGetDados:oBrowse:blDblClick	:= {|| _oGetDados:EditCell(), fMarca()}

	Activate MsDialog _oDlg Centered on Init EnchoiceBar(_oDlg, {||_nOpcA := 1, If(_oGetDados:TudoOk(),_oDlg:End(),_nOpcA := 0)}, {|| _oDlg:End()})

Return _nOpcA == 1

Static Function fMarca() 

	Local _nPosClVl	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "CLVL"})

	If !_oGetDados:oBrowse:nColPos	==	_nPosClVl

		_oGetDados:aCols[_oGetDados:nAt,1]	:=	Iif(_oGetDados:aCols[_oGetDados:nAt,1] == "LBNO","LBOK","LBNO")

		_oGetDados:Refresh()
	EndIf
Return


Static Function fQuebra(_cLocal,_cLocaliz,_cClVl,_cErro,_cDocQuebr)

	Local _lRet	:=	.T.

	Local _cDoc	:=	UPPER( NextNumero("SD3", 2, "D3_DOC", .t.))

	Local _aCab	:=	{}
	Local _aItens	:=	{}
	Local _aLinha	:=	{}
	Local nX

	Private lMsHelpAuto	:= .T.
	Private lMsErroAuto	:= .F.
	Private lAutoErrNoFile := .T.
	Private _cLogTxt 		:= ""
	Private _ExecAutoII	:= .T. //Variavel para desativar Execblock velhos


	_cErro	:=	""

	_aCab :=	{	{"D3_DOC"     ,_cDoc		, NIL},;
	{"D3_TM"      ,"517"			, NIL},;
	{"D3_CC"      ,'3000'			, NIL},;
	{"D3_CLVL"    ,_cClVl 		, NIL},;
	{"D3_EMISSAO" ,dDatabase	, NIL}}

	_aLinha	:=	{}
	aAdd(_aLinha,{"D3_COD"	  	,skProdut		,NIL})
	aAdd(_aLinha,{"D3_UM"	  	,POSICIONE("SB1",1,xFilial("SB1")+skProdut,"B1_UM")		     		,NIL})
	aAdd(_aLinha,{"D3_QUANT"  	,skQtdPrd    	,NIL})
	aAdd(_aLinha,{"D3_LOCAL"  	,_cLocal		,NIL})
	aAdd(_aLinha,{"D3_CONTA" 	,"11306001"						,NIL})
	aAdd(_aLinha,{"D3_CC"		,'3000'  				    ,NIL})
	aAdd(_aLinha,{"D3_CLVL"		,_cClVl					,NIL})

	aAdd(_aLinha,{"D3_USUARIO"	,cUserName						,NIL})
	aAdd(_aLinha,{"D3_LOTECTL"	,skLotePR						,NIL})
	aAdd(_aLinha,{"D3_LOCALIZ"	,_cLocaliz						,NIL})	
	aAdd(_aLinha,{"D3_SEGUM"  	,POSICIONE("SB1",1,xFilial("SB1")+skProdut,"B1_SEGUM")		    	,NIL})
	aAdd(_aLinha,{"D3_YAPLIC" 	,"1"		,NIL})

	aAdd(_aItens, _aLinha)
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| MATA241(x,y,z)}, _aCab, _aItens)
	If lMsErroAuto
		aErro := GetAutoGRLog()
		For nX := 1 To Len(aErro)
			_cErro += aErro[nX]+CRLF
		Next nX
		_cErro := "ERRO MSExecAuto: " + CRLF + _cErro
		_lret := .F.
	Else
		_cDocQuebr	:=	_cDoc
	EndIf

Return _lret

User Function BF63TOK()

	Local _lRet	:=	.T.
	Local _nI	:=	0

	Local _nPosCheck	:=	0
	Local _nPosClVl		:=	0
	Local _nPsQuebra	:=	0

	_nPosCheck	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "CHECK"})
	_nPosClVl	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "CLVL"})
	_nPsQuebra	:=	aScan(_oGetDados:aHeader,{|x| ALLTRIM(x[2]) == "QUEBRA"})

	For _nI	:=	1 to Len(_oGetdados:aCols) 

		If _oGetDados:aCols[_nI,_nPosCheck] == "LBOK" .And. _oGetDados:aCols[_nI,_nPsQuebra] == "1" .And. Empty( _oGetDados:aCols[_nI,_nPosClVl])

			MsgSTOP("Existem Borderôs do tipo quebra que não possuem a classe de valor selecionada!","BIAF063")
			_lRet	:=	.F.
		EndIf

	Next
Return _lret