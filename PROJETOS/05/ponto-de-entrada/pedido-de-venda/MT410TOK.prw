#Include 'Protheus.ch'
/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ MT410TOK ¦ Autor ¦ Augusto               ¦ Data ¦ 04.09.17 ¦¦¦
¦¦¦Descrição ¦Ponto de Entrada utilizado no Pedido de Venda               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
*------------------------------------------------------------------------------------------------
User Function MT410TOK()

	LOCAL _lMt410tok	:= .T.
	LOCAL _aGetArea		:= GETAREA()
	Local nComissa  	:= 0
	//Valida se o campo da comissao foi preechido no Cliente.
	nComissa := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE,"A1_COMIS")
	IF nComissa > 0
		M->C5_COMIS1 := nComissa
	END   

	IF 	!M->C5_YTPOPER $ "01" //.AND. U_UReprese() //aScan(aGrupo, "000001" ) > 0 //GRUPO REPRESENTANTE
		M->C5_COMIS1 := 0
	ENDIF
	//BLOQUEIA O PEDIDO CONFORME POLÍTICA DE VENDA NESHER
	//1) PEDIDO MINIMO    R$ 1.000,00
	//2) DUPLICATA MÍNIMA R$   500,00
	//3) PERCENTUAL DE FRETE <= A ZERO
	IF 	M->C5_YTPOPER == "01" .AND. U_UReprese() //aScan(aGrupo, "000001" ) > 0 //GRUPO REPRESENTANTE
		_lMt410tok := PSSBLQPED()
	ENDIF
	//Função para executar o Gatilho do Volume dos pedidos da MMadeira 
	If Alltrim(Funname())== "A0501" 
		U_PSSVOLLIB()
	End  

	If Alltrim(Funname())== "NESA705" 
		M->C5_CONDPAG   := "001"
	End        

	If AlLTRIM(M->C5_CLIENTE) <> Alltrim(M->C5_CLIENT)
		M->C5_CLIENT := M->C5_CLIENTE
	EndIf    

	RESTAREA( _aGetArea )

	_lMt410tok := U_DetItem()

Return(_lMt410tok)

// Valida coluna Det. Item
USER FUNCTION DetItem()

	Local lRet := .T.	
	
	IF M->C5_YTPOPER $ "29,31"
		FOR nI := 1 TO Len(aCols)
			If Empty(gdFieldGet("C6_YDETPED",nI))
				ALERT("A coluna 'Motivo Assis' no item "+cValToChar(nI)+" precisa ser preenchida, se a operação do pedido for de 'Assistência técnica'. ")
				lRet := .F.
			EndIf
		NEXT nI
	EndIf

Return lRet

*------------------------------------------------------------------------------------------------
//ATUALIZA CAMPOS DIVERSOS, CONFORME A OPERAÇÃO INFORMADA PELO USUÁRIO. CAMPOS: TES, CFOP, TPOPER, ALIQUOTAS E ETC...
USER FUNCTION PSSTPOPER(lMsg,lLinha)

LOCAL _nI 		    := 0
LOCAL _aGetArea	    := GetArea()
LOCAL _nOldN		:= n
LOCAL _nOldREADVAR	:= __READVAR
DEFAULT lMsg 		:= .T.
DEFAULT lLinha		:= .F.
Private _nOper      := gdFieldGet("C6_OPER",n)
Private _cCondCli   := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE,"A1_COND")
IF FunName() == "MATA410"
	///LIMPAR OS CAMPOS
	//CriaVar(nOper,.F.)
	
	IF Empty(gdFieldGet("C6_PRODUTO",n))
		M->C5_DESC1 	:= 0
		M->C5_DESC2 	:= 0
		M->C5_DESC3 	:= 0
		M->C5_DESC4 	:= 0
		If !Empty(M->C5_CONDPAG).AND. Empty(_cCondCli).and. M->C5_TIPO == 'N'
			M->C5_CONDPAG   :="   "        
			M->C5_CLIENTE   :="      "
		EndIf
	Endif
	IF oGetDad:oBrowse <> NIL
		
		IF len(aCols) > 0
			
			_nInd := IIF(lLinha,n,1)
			
			IF ! EMPTY(gdFieldGet("C6_PRODUTO",_nInd))
				
				
				IF iif(lLinha,.T.,gdFieldGet("C6_OPER",_nInd) <> M->C5_YTPOPER) .OR. "C5_CLIENTE" $ readvar() .OR. "C5_LOJA" $ readvar()
					
					//	IF !lMsg .OR. apMsgNoYes("A operação foi modificada e poderá afetar os campos de todos os itens deste pedido. Confirme o processamento?")
					If M->C5_YTPOPER <> gdFieldGet("C6_OPER",_nInd) .and. !Empty(gdFieldGet("C6_OPER",_nInd)) // lMsg 
						Alert("A operação do pedido foi alterada. Informe os dados dos Campos novamente")
						If !Empty(M->C5_CONDPAG)
								M->C5_DESC1 := 0
								M->C5_DESC2 := 0
								M->C5_DESC3 := 0
								M->C5_DESC4 := 0

								M->C5_CONDPAG   :="   "
							//	M->C5_CLIENTE   :="      "
						EndIF
					EndIF
					//If !lMsg //.and. !Empty(gdFieldGet("C6_OPER",_nInd))
					   
						//	U_VLDLIOK()
						FOR _nI := _nInd TO Len(aCols)
							
							n				:= _nI
							M->C6_OPER      := gdFieldGet("C6_OPER",n)
							
							IF M->C6_OPER $ "28,29" .AND.  M->C5_YTPOPER <> M->C6_OPER
								gdFieldPut("C6_YDESC1", 0, n )
								__READVAR 	:= "M->C6_YDESC1"
								&(__READVAR )	:= 0
							ENDIF
							
							M->C6_OPER 		:= M->C5_YTPOPER
							__READVAR 		:= "M->C6_OPER"
							
							gdFieldPut("C6_OPER",M->C5_YTPOPER,n)
							
							M->C6_PRODUTO     := gdFieldGet("C6_PRODUTO",n)
							
							MaTesInt(2,,M->C5_CLIENT,M->C5_LOJAENT,If(M->C5_TIPO$'DB',"F","C"),M->C6_PRODUTO,"C6_TES")
							CodSitTri()
							
							gdFieldPut("C6_CODLAN",SF4->F4_CODLAN,n)
							
							IF lLinha
								EXIT
							ENDIF
							
						NEXT
						
						oGetDad:oBrowse:Refresh()
					//ENDIF
					
				ENDIF
				
			ENDIF
			
		ENDIF
		
	ENDIF
	
	IF M->C5_YTPOPER $ "28,30,29,31"
		M->C5_COMIS1 := 0
	ENDIF
	_nOper      := &(READVAR())
	__READVAR 	:= _nOldREADVAR
	n 			:= _nOldN
	U_nes008()
	
	RestArea(_aGetArea)
EndIf
RETURN M->C5_YTPOPER
*----------------------------------------------------------------------------------------------------------------------------------------------------------
//ATUALIZA CAMPOS C5_PESOL E C5_PBRUTO COM A SOMATÓRIA DAS QUANTIDADES LIBERADAS VEZES O PESO DE CADA ITEM
USER FUNCTION PSSPESLIB()

LOCAL _nI 		:= 0
LOCAL _aGetArea	:= GetArea()
LOCAL _aGetSB1 	:= SB1->( GetArea() )
LOCAL _nPeso		:= 0
LOCAL _nQtd		:= 0

IF oGetDad:oBrowse <> NIL
	
	IF len(aCols) > 0
		
		FOR _nI := 1 TO Len(aCols)
			
			IF !  GDDeleted(_nI)
				
				_cProduto := gdFieldGet("C6_PRODUTO",_nI)
				
				IF ! EMPTY( _cProduto  )
					
					IF Posicione("SB1",1,xfilial("SB1")+_cProduto, "FOUND()" )
						
						/*						IF _nI == n .AND. &(__READVAR) <> NIL
						_nQtdLib  := &(__READVAR)
						ELSE
						_nQtdLib	:= gdFieldGet("C6_QTDLIB",_nI)
						//_nQtdLib	:= IIF( _nQtdLib < 0, gdFieldGet("C6_QTDVEN",_nI), _nQtdLib )
						ENDIF
						*/
						IF _nI == n  .and. "C6_QTDLIB" $ __READVAR
							_nQtdLib  := &(__READVAR)
						ELSE
							_nQtdLib	:= gdFieldGet("C6_QTDLIB",_nI)
							
							//	_nQtdLib	:= IIF( _nQtdLib <= 0, gdFieldGet("C6_QTDVEN",_nI), _nQtdLib )
						ENDIF
						
						_nPeso 	+= ( SB1->B1_PESBRU * _nQtdLib )
						
					ENDIF
					
				ENDIF
			ENDIF
			
		NEXT
		
		M->C5_PESOL := M->C5_PBRUTO :=  _nPeso
		oGetPV:Refresh()
		
	ENDIF
ENDIF

RestArea(_aGetSB1)
RestArea(_aGetArea)

RETURN _nPeso
//ATUALIZA CAMPOS B1_YMEDM3, C5_YM3 COM A SOMATÓRIA DAS QUANTIDADES LIBERADAS VEZES O M3 DE CADA ITEM
USER FUNCTION PSSPEDM3()

LOCAL _aGetArea	:= GetArea()
LOCAL _aGetSB1 	:= SB1->( GetArea() )
LOCAL _Pedm3	:= 0
LOCAL _nQtd		:= 0

IF oGetDad:oBrowse <> NIL
	
	IF len(aCols) > 0
		
		FOR _nI := 1 TO Len(aCols)
			
			IF !  GDDeleted(_nI)
				
				_cProduto := gdFieldGet("C6_PRODUTO",_nI)
				
				IF ! EMPTY( _cProduto  )
					
					IF Posicione("SB1",1,xfilial("SB1")+_cProduto, "FOUND()" )
						
						/*						IF _nI == n .AND. &(__READVAR) <> NIL
						_nQtdLib  := &(__READVAR)
						ELSE
						_nQtdLib	:= gdFieldGet("C6_QTDLIB",_nI)
						//_nQtdLib	:= IIF( _nQtdLib < 0, gdFieldGet("C6_QTDVEN",_nI), _nQtdLib )
						ENDIF
						*/
						IF _nI == n  .and. "C6_QTDLIB" $ __READVAR
							_nQtdLib  := &(__READVAR)
						ELSE
							_nQtdLib	:= gdFieldGet("C6_QTDLIB",_nI)
							//_nQtdLib	:= IIF( _nQtdLib <= 0, gdFieldGet("C6_QTDVEN",_nI), _nQtdLib )
						ENDIF
						
						_Pedm3 	+= ( SB1->B1_YMEDM3 * _nQtdLib )
						
					ENDIF
					
				ENDIF
			ENDIF
			
		NEXT
		
		M->C5_YM3 := _Pedm3
		A410MultT()
		oGetPV:Refresh()
		
	ENDIF
ENDIF

RestArea(_aGetSB1)
RestArea(_aGetArea)

RETURN _Pedm3               

//ATUALIZA CAMPOS C5_COMIS1, COM A SOMATÓRIA COMISSÃO ATINGIDA.
USER FUNCTION PSSPEDCOM()

LOCAL _aGetArea	:= GetArea()
LOCAL _aGetSB1 	:= SB1->( GetArea() )
LOCAL _VComis	:= 0
LOCAL _VTotal	:= 0
LOCAL _nQtd		:= 0

IF oGetDad:oBrowse <> NIL
	
	IF len(aCols) > 0
		FOR _nI := 1 TO Len(aCols)
			
			IF !  GDDeleted(_nI)
				
				_cProduto := gdFieldGet("C6_PRODUTO",_nI)
				_cValor   := gdFieldGet("C6_VALOR",_nI)
				_cPercom  := gdFieldGet("C6_COMIS1",_nI)
				IF ! EMPTY( _cProduto  )
					
					IF Posicione("SB1",1,xfilial("SB1")+_cProduto, "FOUND()" )
						
						_VTotal     += ( _cValor)
						_VComis 	+= ( _cValor * (_cPercom/100) )
						
					ENDIF
					
				ENDIF
			ENDIF
			
		NEXT
		
		M->C5_COMIS1 := Round(((_VComis  / _VTotal)* 100),2)
		A410MultT()
		oGetPV:Refresh()
		
	ENDIF
ENDIF
	//MENSAGEM COM PERCETUAL DE COMISSAO
	If M->C5_COMIS1 > 0 .and. &(readvar())> 0
		MSGALERT( "A Comissao foi alterada para: "+ cValtochar(M->C5_COMIS1)+"%", 'Desconto Sacrifício')
	EndIf
	
RestArea(_aGetSB1)
RestArea(_aGetArea)

RETURN _VComis
*------------------------------------------------------------------------------------------------
//ATUALIZA CAMPOS C5_VOLUME1 COM A SOMATÓRIA DAS QUANTIDADES LIBERADAS VEZES A QUANTIDADE DE VOLUMES PARA CADA ITEM
USER FUNCTION PSSVOLLIB()

LOCAL _nI 		:= 0
LOCAL _aGetArea		:= GetArea()
LOCAL _aGetSB1 		:= SB1->( GetArea() )
LOCAL _aGetSG1 		:= SG1->( GetArea() )
LOCAL _nVolumes		:= 0
LOCAL _G1_QTDVOL 	:= 0
LOCAL _nQtdLib		:= 0
LOCAL _cProduto		:= ""

IF oGetDad:oBrowse <> NIL
	
	IF len(aCols) > 0
		
		FOR _nI := 1 TO Len(aCols)
			
			IF !  GDDeleted(_nI)
				
				_cProduto := gdFieldGet("C6_PRODUTO",_nI)
				_nQtdVen  := gdFieldGet("C6_QTDVEN",_nI)
				IF LEFT(_cProduto,1) == "5" .OR. ( LEFT(_cProduto,1) == "4" .AND. "V" $ _cProduto )
					
					IF ! EMPTY( _cProduto  )
						
						IF Posicione("SB1",1,xfilial("SB1")+_cProduto, "FOUND()" )
							
							IF _nI == n  .and. "C6_QTDLIB" $ __READVAR
								_nQtdLib  := &(__READVAR)
							ELSE
								// gdFieldPut("C6_QTDLIB",_nQtdVen,_nI) //aqui
								_nQtdLib	:= gdFieldGet("C6_QTDLIB",_nI)
								
								//_nQtdLib	:= IIF( _nQtdLib <= 0, gdFieldGet("C6_QTDVEN",_nI), _nQtdLib )
							ENDIF
							
							_G1_QTDVOL := IIF( LEFT(_cProduto,1)=='5',U_GetQtVol(_cProduto),1)
							_nVolumes  += ( _G1_QTDVOL * _nQtdLib )
							
						ENDIF
						
					ENDIF
				ENDIF
				
			ENDIF
			
		NEXT
		
		M->C5_VOLUME1 := IIF(_nVolumes > 0, _nVolumes,M->C5_VOLUME1 )
		
		oGetPV:Refresh()
	ENDIF
	
ENDIF

RestArea(_aGetSG1)
RestArea(_aGetSB1)
RestArea(_aGetArea)

RETURN M->C5_VOLUME1
*------------------------------------------------------------------------------------------------
USER FUNCTION GetQtVol(_cPro)

Local _cAlias	:= GetNextAlias()
Local _nQtdVol	:= 0

BeginSql Alias _cAlias
	
	SELECT COUNT(*) G1_QTDVOL
	FROM %Table:SG1% SG1
	WHERE G1_FILIAL = %xFilial:SG1%
	AND %notDel%
	AND G1_COD	= %Exp:_cPro%
	
EndSql

IF (_cAlias)->(! EOF())
	_nQtdVol := (_cAlias)->G1_QTDVOL
ENDIF

(_cAlias)->(dbCloseArea())

RETURN _nQtdVol
*------------------------------------------------------------------------------------------------
//BLOQUEIA O PEDIDO CONFORME POLÍTICA DE VENDA NESHER
STATIC FUNCTION PSSBLQPED()

LOCAL lPSSBLQPED 	:= .T.
LOCAL nTotalPed  	:= 0
LOCAL aCondPagto 	:= {}
LOCAL cMsg		:= ""
LOCAL nPedMin	:= GETMV("MV_YPEDMIN")
LOCAL nDPMinima	:= GETMV("MV_YDPMIN")

aEval(aCols, {|x,y| nTotalPed += gdFieldGet("C6_VALOR",y) } )
aCondPagto := Condicao( nTotalPed, M->C5_CONDPAG,, M->C5_EMISSAO)

IF nTotalPed  < nPedMin //PEDIDO MINIMO    R$ 1.000,00
	
	cMsg := "O total deste pedido é inferior ao mínimo exigido, conforme política comercial:" + chr(13) + chr(10)
	cMsg += "Total do Pedido:" + transform(nTotalPed,PesqPict("SC6","C6_VALOR")) + chr(13) + chr(10)
	cMsg += "Mínimo Exigido :" + transform(nPedMin,PesqPict("SC6","C6_VALOR"))+ chr(13) + chr(10)
	cMsg += "Solução: Eleve o valor do pedido para prosseguir."
	
	//		Aviso("Pedido Mínimo",cMsg,{"OK"})
	apMsgStop(cMsg)
	
	lPSSBLQPED := .f.
	
ELSEIF valtype(aCondPagto[1][2]) <> 'N'
	cMsg := "Condição de pagamento é obrigátório. Informe." + chr(13) + chr(10)
	apMsgStop(cMsg)
ELSEIF aCondPagto[1][2] < nDPMinima  //DUPLICATA MÍNIMA R$   500,00
	
	cMsg := "A duplicata não atingiu a parcela mínima exigida, conforme política comercial:" + chr(13) + chr(10)
	cMsg += "Valor da Parcela:" + transform(aCondPagto[1][2]	,PesqPict("SE1","E1_VALOR")) + chr(13) + chr(10)
	cMsg += "Parcela Mínima  :" + transform(nDPMinima		,PesqPict("SE1","E1_VALOR"))+ chr(13) + chr(10)
	cMsg += "Solução: Alterar o prazo para prosseguir."
	
	//		Aviso("Parcela Mínima",cMsg,{"OK"})
	apMsgStop(cMsg)
	
	lPSSBLQPED := .f.
	
ELSEIF M->C5_PERCFRE <= 0 .AND. M->C5_YTPOPER <> '29'//PERCENTUAL MÍNIMO
	
	cMsg := 'O campo "% Frete" não foi preenchido. É necessário o prenchimento para prosseguir."
	
	//		Aviso("Parcela Mínima",cMsg,{"OK"})
	apMsgStop(cMsg)
	
	lPSSBLQPED := .f.
	
ELSEIF EMPTY(M->C5_TPFRETE)  //EXIGE QUE O REPRESENTANTE INFORME O TIPO DE FRETE NEGOCIADO NA VENDA
	
	cMsg := 'O campo "Tipo Frete" não foi informado. É necessário informar para prosseguir."
	
	//		Aviso("Tipo de Frete",cMsg,{"OK"})
	apMsgStop(cMsg)
	
	lPSSBLQPED := .f.
ENDIF
If lPSSBLQPED                          
	U_nes009()
EndIf
RETURN lPSSBLQPED
*------------------------------------------------------------------------------------------------
//VERIFICA SE O USUÁRIO É UM REPRESENTANTE
USER FUNCTION UReprese()

LOCAL aGrupo := aClone( UsrRetGrp( __cUserId  ) )
RETURN aScan(aGrupo, GetNewPar("MV_YGRPREP","000001") ) > 0 //GRUPO REPRESENTANTE
*------------------------------------------------------------------------------------------------
USER FUNCTION MeuCliente(cMeuCli,lExibMsg)

Local lMeuCliente := .T.
Local cReprCli

Local cMeuCli	:= M->C5_CLIENTE//SA1->A1_COD
Local lExibMsg  := .T.

IF U_UReprese()
	
	cReprCli  	:= Posicione("SA1", 1, XFILIAL("SA1")+cMeuCli, "A1_VEND" )
	lMeuCliente := cReprCli == Posicione("SA3", 7, XFILIAL("SA3")+__cUserId, "A3_COD" )
	
	IF lExibMsg .AND. ! lMeuCliente
		Help(" ",1,"Help",,"Este cliente não é válido para o representante "+ALLTRIM(SA3->A3_NOME)+". Escolha um da sua carteira.",1,0)
	ENDIF
	
ENDIF

RETURN lMeuCliente
*------------------------------------------------------------------------------------------------

USER FUNCTION VLDESCONT()

LOCAL lVldDesc := .T.
LOCAL cMsg
LOCAL nPerMos	:= GETMV("MV_YLOPE28")

IF M->C5_YTPOPER <> "28"
	lVldDesc := U_VLDTABELA() .AND. U_NES003()
ELSE
	IF .NOT. ( lVldDesc := M->C5_DESC4 <= GETNEWPAR("MV_YLOPE28",30) ) //LIMITE DE DESCONTO PARA A OPERAÇÃO 28
		cMsg := 'Limite de desconto para a operação '+ Posicione("ZX5",1,M->C5_YTPOPER,"ALLTRIM(ZX5_DESCRI)")+" superior ao permitido (máximo: 30%)."
		//			Aviso("Desconto Excedido",cMsg,{"OK"})
		apMsgStop(cMsg)
	ELSE
		M->C5_DESC4	:= nPerMos
		lVldDesc    := U_VLDTABELA() .AND. U_NES003()
		
	ENDIF
ENDIF

RETURN lVldDesc

*------------------------------------------------------------------------------------------------
USER FUNCTION VLDPROD(_cPro)

Local _cAlias	:= GetNextAlias()
Local _nQtdVol	:= 0
Local LVldprod  :=.T.

BeginSql Alias _cAlias
	
	SELECT COUNT(*) G1_QTDVOL
	FROM %Table:SG1% SG1
	WHERE G1_FILIAL = %xFilial:SG1%
	AND %notDel%
	AND G1_COD	= %Exp:_cPro%
	
EndSql

IF (_cAlias)->(! EOF())
	_nQtdVol := (_cAlias)->G1_QTDVOL
	cMsg := 'O produto selecionado não possui estrutura"
	//			Aviso("Desconto Excedido",cMsg,{"OK"})
	apMsgStop(cMsg)
ENDIF
If _nQtdVol = 0
EndIf
(_cAlias)->(dbCloseArea())


RETURN VLDPROD
