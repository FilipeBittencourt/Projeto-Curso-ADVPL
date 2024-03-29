#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 

/*/{Protheus.doc} SchedPCompras
Schedule de pedido de compras
@author henrique
@since 28/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function SchedPCompras(aParam)
	Local oSchedPCompras := SchedAcesso():New()
	
	Default aParam := {'08', '01'}
	
	oSchedPCompras:cEmp := aParam[1]
	oSchedPCompras:cFil := aParam[2]  
	
	PTInternal(1,"U_VIXA246_"+aParam[1])
	
	If oSchedPCompras:ControlJOB("U_VIXA246_"+aParam[1], 1) .AND. oSchedPCompras:ControlJOB("U_SolicComprasV246_"+aParam[1], 1)
	
		oSchedPCompras:IniciaAmb()
		CriaParam()
	
		If GetMv('MV_YCMPFIM') != dDatabase
			SetFunName('SchedPCompras')
			U_VIXA246()
		EndIf
						
		oSchedPCompras:FinalAmb()
	
	EndIf
	
	FreeObj(oSchedPCompras)

Return
              
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VIXA246   �Autor  �Ihorran Milholi     � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gera��o de solicita��o e pedidos de compra      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGACOM                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VIXA246(aParam,cFabric,cCurvaDe,cCurvaAte,nQdeDias)
	                       
	Local aErros 	:= {{},{}}
	 
	Private cMsgLog	:= ''
	Private lProcPC	:= UPPER(AllTrim(FunName()))$ UPPER('VIXA116')
	Private dDataSol
	
	Default aParam 	:= {}
	Default cFabric 	:= ''
	Default cCurvaDe	:= ''
	Default cCurvaAte	:= ''
	Default nQdeDias	:= 0
	
	//Inicia ambiente para schedule
	If !lProcPC .And. UPPER(AllTrim(FunName())) != UPPER('SchedPCompras')
		VA246IniAmb()	
		//Atualiza data para gera��o dos pedidos   
		dDataSol:= iif(substr(time(),1,4) > "12:00",dDatabase+1,dDatabase)
	Else
		dDataSol:= dDatabase
	EndIf
	
	AddMsgLog('Eliminando res�duos em aberto do fabricante.')
	
	//Rotina para eliminar residuo de solicita��es em aberto
	VA246ResSol(cFabric, cCurvaDe, cCurvaAte)
	
	AddMsgLog('Gerando solicita��es de compras.')
	
	//Rotina para gera��o das solicita��es de compra
	VA246GerSol(cFabric, cCurvaDe, cCurvaAte,nQdeDias)
	
	AddMsgLog('Gerando pedido de compras.')
	
	//Rotina para gera��o dos pedidos de compra
	VA246GerPed(@aErros, cFabric, cCurvaDe, cCurvaAte, nQdeDias)
	
	AddMsgLog('Analisando os produtos sem CRU.')
	
	//Rotina para analisar os produtos CRU que est�o sem pedido
	VA246CRUSemPC(@aErros, cFabric, cCurvaDe, cCurvaAte)
	
	AddMsgLog('Analisando filtro de pedido minimo.')
	
	//Rotina para analisar se tiveram pedidos com valor minimo n�o atendido
	VA246PedMin(@aErros, cFabric, cCurvaDe, cCurvaAte)
	
	//Fun��o para esperar finalizar os pedidos para o email sair corretamente
	While !VA246FimProcPed()
	     
		//Espera 30 segundos para tentar novamente
		Sleep(30000)
		
	EndDo
	
	//Chama rotina de envio de emails
	VA246Log(@aErros)
	
	If !lProcPC
		VA246Email(aErros[2])
	Endif
	
	If AllTrim(FunName())$ UPPER('SchedPCompras')
		
		//==================================================
		//Paramentro informando a data final da execu��o do 
		//schedule de pedido de compras
		//==================================================
		CriaParam()
		
		DbSelectarea("SX6")
		DbSetOrder(1)
		PutMv("MV_YCMPFIM",dDatabase)
		
	EndIf

	//Reseta ambiente para schedule
	If !lProcPC
		VA246ResiAmb()
	EndIf

Return cMsgLog

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AddMsgLog  �Henrique  � Data �  26/10/15          ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina de montagem da mensagem de retorno                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
Static Function AddMsgLog(cMensagem)

	If lProcPC .and. AllTrim(cMensagem) != ''
		cMsgLog += Time()+ ' - '+AllTrim(cMensagem)+CHR(13)+CHR(10)
	EndIf
	 
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246CRUSemPC�Autor  �Ihorran Milholi  � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para analisar os produtos CRU que est�o sem pedido   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/             
Static Function VA246CRUSemPC(aErros, cFabric, cCurvaDe, cCurvaAte)

	Local cAlias 	:= GetNextAlias()
	Local cPasta	:= "\COMPRAS\" 
	Local oExcel	:= FWMSEXCEL():New()
	
	MakeDir(cPasta)
	
	BeginSQL Alias cAlias
	
	SELECT	SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, SB1.B1_DESC, SB1.B1_FABRIC, SB1.B1_PROC, SC1.C1_QUANT, SB1.B1_CUSTD, SB1.B1_GRUPCOM
	
	FROM	%table:SC1% SC1
	
			INNER JOIN %table:SB1% SB1 ON	SB1.B1_FILIAL	= %xFilial:SB1%
										AND SB1.B1_COD		= SC1.C1_PRODUTO
										AND SB1.%NotDel%
										
			INNER JOIN %table:SZP% SZP ON	SZP.ZP_FILIAL	= %xFilial:SZP%	
										AND SZP.ZP_PRODUTO	= SC1.C1_PRODUTO
										AND SZP.%NotDel%
																	
			INNER JOIN %table:SZ1% SZ1 ON	SZ1.Z1_FILIAL	= %xFilial:SZ1%	
										AND SZ1.Z1_FABRIC	= SB1.B1_FABRIC	   
										AND SZ1.%NotDel%
										
			LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = C1_PRODUTO
																			
	WHERE	SC1.C1_FILIAL	= %xFilial:SC1%
		AND SC1.C1_PEDIDO	= %Exp:''%	
		AND SC1.C1_RESIDUO	= %Exp:''%	
		AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
		AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
		AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
		AND SB1.B1_PROC 	IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
		AND SC1.%NotDel%
		
	ORDER BY SC1.C1_NUM, SC1.C1_ITEM
	
	EndSql
	              
	//Nome do arquivo            
	cFile := cPasta+"CRUSEMPC"+cEmpAnt+cFilAnt+dtos(dDatabase)+".XML"
	
	oExcel:SetFontSize(9)
	oExcel:AddworkSheet("Produtos")
	
	oExcel:AddTable ("Produtos","Produtos sem CRU")
	
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_NUM"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_ITEM"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_PRODUTO"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_DESC"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_FABRIC"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_PROC"),1,1)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_QUANT"),3,2)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_CUSTD"),3,2)
	oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_GRUPCOM"),1,1)
	
	(cAlias)->(dbGoTop())     
	If (cAlias)->(Eof()) 
		
		AddMsgLog('N�o h� produtos CRU sem pedidos.')
		
		Return
		
	EndIf    
	     
	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())   
	
		oExcel:AddRow("Produtos","Produtos sem CRU",{	(cAlias)->C1_NUM,;
														(cAlias)->C1_ITEM,;
														(cAlias)->C1_PRODUTO,;
														(cAlias)->B1_DESC,;
														(cAlias)->B1_FABRIC,;
														(cAlias)->B1_PROC,;
														(cAlias)->C1_QUANT,;
														(cAlias)->B1_CUSTD,;
														POSICIONE("SAJ",1,xFilial("SAJ")+(cAlias)->B1_GRUPCOM,"AJ_US2NAME")})
	
		(cAlias)->(dbSkip())
		
	EndDo
	 
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
					
	FreeObj(oExcel)
	
	aAdd(aErros[2],cFile)

Return                                                                 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246ResSol�Autor  �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para eliminar residuo de solicita�oe em aberto       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/             
Static Function VA246ResSol(cFabric, cCurvaDe, cCurvaAte)
	
	Local cAliasSol 	:= GetNextAlias()
	Local cPedido		:= ''
	Local cDataSolic	:= DToS(dDataBase)
	
	BeginSql Alias cAliasSol
		SELECT NUMSC, COALESCE(DATFIM, '')
		FROM VIX_CMP_SC1 SC1
		WHERE FILIAL = %xFilial:SC1% AND DATINC = %Exp:cDataSolic%
	
	EndSql
	
	//Se j� existir uma solicita��o continua gravando nele	
	If !(cAliasSol)->(Eof())
		AddMsgLog('N�o h� residuo a ser eliminado.')
		Return
	EndIf
	
	(cAliasSol)->(DbCloseArea())
	
	BeginSQL Alias cAliasSol
	
	SELECT	SC1.R_E_C_N_O_ SC1RECNO
	
	FROM %table:SC1% SC1
	JOIN %table:SB1% SB1 ON SB1.%NotDel% AND SB1.B1_FILIAL = %xFilial:SB1% AND B1_COD = C1_PRODUTO
	LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC 
	LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = C1_PRODUTO
	WHERE	SC1.%NotDel%
		AND SC1.C1_FILIAL	= %xFilial:SC1%    
		AND SC1.C1_RESIDUO = %Exp:''%		
		//AND SC1.C1_EMISSAO	<> %Exp:dDataBase%
		AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
		AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
		AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
	ORDER BY SC1.C1_NUM, SC1.C1_ITEM
	
	EndSql
		
	(cAliasSol)->(dbGoTop())
	If (cAliasSol)->(Eof())
		AddMsgLog('N�o h� residuo a ser eliminado.')
	EndIf
	
	(cAliasSol)->(dbGoTop())
	While (cAliasSol)->(!Eof())                            
	
		SC1->(dbSetOrder(1))
		SC1->(dbGoto((cAliasSol)->SC1RECNO))
	                                      
		If SC1->C1_QUANT <> SC1->C1_QUJE .and. SC1->C1_QUJE > 0
				       
			SB2->(dbSetOrder(1))
			If SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
				RecLock("SB2",.F.)
				SB2->B2_SALPEDI -= (SC1->C1_QUANT-SC1->C1_QUJE)
				SB2->B2_SALPED2 -= (SC1->C1_QTSEGUM-SC1->C1_QUJE2)
			    SB2->(msUnLock())
			EndIf                               
			
			RecLock("SC1",.F.)
			SC1->C1_QUANT	:= SC1->C1_QUJE
			SC1->C1_QTSEGUM	:= SC1->C1_QUJE2
	    	SC1->(msUnLock())
	    	
		Else
			
			SB2->(dbSetOrder(1))
			If SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
				RecLock("SB2",.F.)
				SB2->B2_SALPEDI -= SC1->C1_QUANT          
				SB2->B2_SALPED2 -= SC1->C1_QTSEGUM
				SB2->(msUnLock())
			EndIf                               
		    
			RecLock("SC1",.F.)
			SC1->(dbDelete())
	  		SC1->(msUnLock())
	
		EndIf
		
		If AllTrim(cPedido) != SC1->C1_NUM
			AddMsgLog('Residuo eliminado. Pedido '+SC1->C1_NUM+ ' Produto: '+SC1->C1_PRODUTO)
			cPedido := SC1->C1_NUM
		EndIf
			
		(cAliasSol)->(dbSkip())
		
	EndDo
	(cAliasSol)->(dbCloseArea())

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246GerPed�Autor  �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gera��o de pedidos de compra                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246GerPed(aErros, cFabric, cCurvaDe, cCurvaAte, nQdeDias)
                
	Local cAliasSol := GetNextAlias()
	
	Local aAux		:= {}     
	Local aCab		:= {}
	Local aItensPed	:= {}
	Local cFornece	:= ""  
	Local cRet		:= ''
	Local cMsgErro	:= ''
	Local dPrzEntr
	Local nVlrMinPed:= iif(!lProcPC,150,0)
	Local nVlrPed	:= 0
	Local i
	Local oControlSched	:= Nil
	Local nTrheads		:= SuperGetMv("MV_YCMPTHR",.F.,40)-1	// Quantidade de Threads simultaneas
	
	BeginSQL Alias cAliasSol
	
	SELECT	SB1.B1_PROC, SB1.B1_FABRIC, SB1.B1_CUSTD, SB1.B1_IPI, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, (SC1.C1_QUANT-SC1.C1_QUJE) C1_QUANT, SC1.C1_LOCAL, SC1.C1_DATPRF
	FROM	%table:SC1% SC1
		JOIN %table:SB1% SB1 ON SB1.B1_FILIAL	= %xFilial:SB1% AND SB1.%NotDel% AND SC1.C1_PRODUTO	= SB1.B1_COD	
		LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC
		LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD		
	WHERE	SC1.%NotDel%
		AND SC1.C1_FILIAL	= %xFilial:SC1%
		AND SC1.C1_PEDIDO	= %Exp:''%
		AND SC1.C1_RESIDUO = %Exp:''%	
		AND SB1.B1_YCOMPRA IN ('1', ' ')
		AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
		AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
		AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
		AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0% 
		
	ORDER BY SB1.B1_PROC, SB1.B1_FABRIC, SB1.B1_COD, SC1.C1_NUM, SC1.C1_ITEM
	
	EndSql
	                            
	(cAliasSol)->(dbGoTop())
	
	If (cAliasSol)->(Eof())    
		AddMsgLog('N�o h� pedidos de compras a serem gerados')
	
	EndIf	
	
	//Analisa as cota��es geradas para incluir os pedidos de compra                                                         
	While (cAliasSol)->(!Eof())      
	
		aAux := {}
		
		If cFornece <> (cAliasSol)->B1_PROC
			dPrzEntr := MaioDtEntr((cAliasSol)->B1_PROC )		
		EndIf
			                                                                                                                    	 	                           
	   	cFornece:= (cAliasSol)->B1_PROC
	   	cFabric	:= (cAliasSol)->B1_FABRIC
	
		If (cAliasSol)->B1_CUSTD == 0
		
			cMsgErro := "N�o foi possivel gerar um pedido de compra para o produto "+AllTrim((cAliasSol)->C1_PRODUTO)+" pois encontra-se com o custo standard zerado." 	
			aAdd(aErros[1],cMsgErro)	
			AddMsgLog(cMsgErro)
		
		Else
		   	
			aAdd(aAux,{"C7_PRODUTO"	,(cAliasSol)->C1_PRODUTO,Nil})
			aAdd(aAux,{"C7_QUANT"	,(cAliasSol)->C1_QUANT	,Nil})
			aAdd(aAux,{"C7_LOCAL"	,(cAliasSol)->C1_LOCAL	,Nil})	
			aAdd(aAux,{"C7_PRECO"	,(cAliasSol)->B1_CUSTD	,Nil})
			aAdd(aAux,{"C7_NUMSC"	,(cAliasSol)->C1_NUM	,Nil})	
			aAdd(aAux,{"C7_ITEMSC"	,(cAliasSol)->C1_ITEM	,Nil})  
			aAdd(aAux,{"C7_QTDSOL"	,(cAliasSol)->C1_QUANT	,Nil})
			aAdd(aAux,{"C7_DATPRF"	,dPrzEntr				,Nil})
			aAdd(aAux,{"C7_OPER"	,'01'					,Nil})
			
			If SC7->(FieldPos("C7_YQTDLIB")) > 0 .AND. nQdeDias == 0
				aAdd(aAux,{"C7_YQTDLIB",(cAliasSol)->C1_QUANT,Nil})	
			EndIf
			
			If SC7->(FieldPos("C7_YTIPCMP")) > 0
				If !lProcPC
					aAdd(aAux,{"C7_YTIPCMP",'OT',Nil})
				ElseIf nQdeDias > 0
					aAdd(aAux,{"C7_YTIPCMP",'CO',Nil})
				Else
					aAdd(aAux,{"C7_YTIPCMP",'CD',Nil})
				EndIf
			EndIf
			
			aAdd(aItensPed,aAux)
			
			//incrementa para analisar o valor total do pedido
			nVlrPed += ((cAliasSol)->B1_CUSTD*(cAliasSol)->C1_QUANT)
			nVlrPed += ((cAliasSol)->B1_CUSTD*(cAliasSol)->C1_QUANT)*((cAliasSol)->B1_IPI/100)
			  
		EndIf
		
		(cAliasSol)->(dbSkip())                                                                                                
		
		If ((cAliasSol)->(Eof()) .or. cFornece+cFabric <> (cAliasSol)->B1_PROC+(cAliasSol)->B1_FABRIC) .and. Len(aItensPed) > 0
			      
			aCab 		:= {}
			lMsErroAuto	:= .f.
			
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+cFornece))		
				    
				aAdd(aCab,{"C7_EMISSAO"	, dDataSol												,Nil})
				aAdd(aCab,{"C7_FORNECE"	, cFornece												,Nil})
				aAdd(aCab,{"C7_LOJA"		, SA2->A2_LOJA											,Nil})		
				aAdd(aCab,{"C7_COND"		, IIF(Empty(SA2->A2_COND),"001",SA2->A2_COND)			,Nil}) 
				aAdd(aCab,{"C7_CONTATO"	, Posicione("SZ1",2,xFilial("SZ1")+cFabric,"Z1_REPRES")	,Nil})	
				aAdd(aCab,{"C7_FILENT"	, cFilAnt												,Nil})
				
				oControlSched := SchedAcesso():New()

				aParms := {}
				aAdd(aParms, cEmpAnt)
				aAdd(aParms, cFilAnt)
				aAdd(aParms, SM0->M0_CODIGO)
				aAdd(aParms, SM0->M0_CODFIL)
				aAdd(aParms, aCab)
				aAdd(aParms, aItensPed)
				aAdd(aParms, cFornece)
				aAdd(aParms, cFabric)
				aAdd(aParms, nVlrPed)
				aAdd(aParms, nVlrMinPed)
				aAdd(aParms,LPROCPC)

				Do While .T.
					If oControlSched:ControlJOB("U_PedidoComprasV246_"+cEmpAnt, nTrheads)
					
						//Transmiss�o da NF para SEFAZ e envio de notas entre grupo
						StartJob("u_V246PED",GetEnvServer(),.F.,aParms)

						//u_V246PED(aParms)
						Exit

					Else
						SLEEP(10000)	// 10 Segundos
					EndIf
				EndDo

				aItens	:= {}
				
			EndIf
			
			aItensPed 	:= {}
			aGrpComp	:= {}
			nVlrPed		:= 0
				
		EndIf
		
	EndDo
	
	(cAliasSol)->(dbCloseArea())
		
	//Fiz isso porque o protheus estava dando ACCESS VIOLETION na fun��o GetUserInfoArray
	//Ao executar a fun��o FreeObj, o sistema limpa a mem�ria dos dados do objeto
	If oControlSched <> NIL
		FreeObj(oControlSched)
	EndIf
	
	oControlSched := SchedAcesso():New()
	
	Do While .T. 
		
		If oControlSched:QdeJOBAtivos("U_PedidoComprasV246_"+cEmpAnt) == 0	
			Exit
			
		Else
			SLEEP(10000)	// 10 Segundos
			
		EndIf
		
	EndDo

Return

/*/{Protheus.doc} V246PED
(long_description)
@author henrique
@since 23/11/2017
@version 1.0
@param aParms, array, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function V246PED(aParms)
	Local aCab 		:= {}
	Local aErros		:= {{},{}}
	Local _cEmpresa 	:= aParms[1]
	Local _cFilial	:= aParms[2]
	Local cCodigo 	:= aParms[3]
	Local cCodFil		:= aParms[4]
	Local aCab			:= aParms[5]
	Local aItensPed 	:= aParms[6]
	Local cFornece	:= aParms[7]
	Local cFabric		:= aParms[8]
	Local nVlrPed 	:= aParms[9]
	Local nVlrMinPed	:= aParms[10]
	Local LcPROCPC := aParms[11]
	
	Local lIncEmp    	:= Type('cFilAnt') == 'U'

	Private lProcPC := .F.
	
	//altera informa��o da tread
	PTInternal(1,"U_PedidoComprasV246_"+_cEmpresa+"|")
		
	If lIncEmp
		Prepare Environment Empresa _cEmpresa Filial _cFilial
	EndIf				
			
	//verifica se o pedido � maior que o valor minimo
	If nVlrPed > nVlrMinPed

		cRet := u_VA246JobPed({cCodigo,cCodFil,aCab,aItensPed,cFornece,cFabric,.F.},@aErros)
   		
   		lProcPC := LcPROCPC
		If ValType(cRet) == 'C'
			AddMsgLog(cRet)
		EndIf		
			
	EndIf
	
	If lIncEmp
		Reset Environment
	EndIf 
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246PedMin�Autor  �Ihorran Milholi    � Data �  23/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gera��o de pedidos de compra                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246PedMin(aErros, cFabric, cCurvaDe, cCurvaAte)
                
	Local cAlias 	:= GetNextAlias()
	Local cPasta	:= "\COMPRAS\" 
	Local aCabec	:= {}
	Local aDados	:= {}
	Local cTXT		:= ""   
	Local cCrLf		:= Chr(13) + Chr(10)
	Local nHandle	:= 0
	Local i 		:= 0
	Local cChave	:= ''
	Local cEmailOut	:= SuperGetMv("MV_Y246EML",.F.,"clayton@grupouniaosa.com.br; leonardo.teixeira@grupouniaosa.com.br")
	Local cDestin	:= ""
	Local oExcel
	
	MakeDir(cPasta)
	
	//Nome do arquivo            
	cFile := cPasta+"PEDMIN"+cEmpAnt+cFilAnt+dtos(dDatabase)+".XML"
	
	BeginSQL Alias cAlias
	
	SELECT	SB1.B1_GRUPCOM, SB1.B1_PROC, SB1.B1_DESC, SB1.B1_FABRIC, SB1.B1_CUSTD, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, (SC1.C1_QUANT-SC1.C1_QUJE) C1_QUANT, SC1.C1_LOCAL, SC1.C1_DATPRF
	
	FROM	%table:SC1% SC1
	
			JOIN %table:SB1% SB1 ON SB1.B1_FILIAL	= %xFilial:SB1% AND SB1.%NotDel% AND SC1.C1_PRODUTO	= SB1.B1_COD	
			
			LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC
			
			LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD
					
	WHERE	SC1.%NotDel%
		AND SC1.C1_FILIAL	= %xFilial:SC1%
		AND SC1.C1_PEDIDO	= %Exp:''%
		AND SC1.C1_RESIDUO	= %Exp:''%	
		AND SB1.B1_YCOMPRA IN ('1', ' ')
		AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
		AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
		AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
		AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0% 
		
	ORDER BY SB1.B1_GRUPCOM, SB1.B1_FABRIC, SB1.B1_PROC, SB1.B1_COD, SC1.C1_NUM, SC1.C1_ITEM
	
	EndSql
	                            
	(cAlias)->(dbGoTop())     
	If (cAlias)->(Eof()) 
		AddMsgLog('N�o h� produtos n�o gerados por n�o ter atingido o valor minimo do pedido.')
	EndIf 
	
	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())
	
		cChave 	:= (cAlias)->B1_GRUPCOM
		oExcel	:= FWMSEXCEL():New()
		
		oExcel:SetFontSize(9)
		oExcel:AddworkSheet("Produtos")
		
		oExcel:AddTable ("Produtos","Faturamento Minimo")
		
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_FABRIC"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_PROC"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_NUM"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_ITEM"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_PRODUTO"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_DESC"),1,1)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_QUANT"),3,2)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_CUSTD"),3,2)
		oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C7_TOTAL"),3,2)
			
		While (cAlias)->(!Eof()) .and. (cAlias)->B1_GRUPCOM == cChave
	                         		
			oExcel:AddRow("Produtos","Faturamento Minimo",{	(cAlias)->B1_FABRIC,;
															(cAlias)->B1_PROC,;
															(cAlias)->C1_NUM,;
															(cAlias)->C1_ITEM,;
															(cAlias)->C1_PRODUTO,;
															(cAlias)->B1_DESC,;
															(cAlias)->C1_QUANT,;
															(cAlias)->B1_CUSTD,;
															(cAlias)->C1_QUANT*(cAlias)->B1_CUSTD})
			
			(cAlias)->(dbSkip())
		
		EndDo
		
		oExcel:Activate()
		oExcel:GetXMLFile(cFile)
					
		FreeObj(oExcel)
		
		//enviar email para o comprador
	    SAJ->(Dbsetorder(1))
		If SAJ->(DbSeek(xFilial("SAJ")+cChave))
			
			While SAJ->(!Eof()) .and. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+cChave
			
				SY1->(Dbsetorder(3))
				If SY1->(DbSeek(xFilial("SY1")+SAJ->AJ_USER)) .and. !Empty(SY1->Y1_EMAIL)
	
					//Envia arquivo para o comprador
					u_EnvEmail(cEmailOut + "; " + AllTrim(SY1->Y1_EMAIL),Upper(AllTrim(SAJ->AJ_US2NAME))+" - Pedidos recusados por valor minimo de faturamento","Segue anexo arquivo(s) de log gerados pela rotina de gera��o de pedidos de compra do dia "+dToc(dDatabase)+" as "+Time(),cFile)
					
				EndIf
	
				SAJ->(dbSkip())
				
			EndDo			
	
		EndIf
		
	EndDo

Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246JobPed�Autor  �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gera��o de pedidos de compra                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VA246JobPed(aParametros,aErros)

	Local cEmpJob	:= aParametros[1]
	Local cFilJob	:= aParametros[2]
	Local aCab 		:= aParametros[3]
	Local aItensPed	:= aParametros[4]
	Local cFornece	:= aParametros[5]
	Local cFabric	:= aParametros[6]
	Local lExecJob	:= aParametros[7]
	Local cRetorno	:= ''
	
	Private lMsErroAuto	:= .f.  
	
	If lExecJob
		RPCCLEARENV()
		//RPCSETTYPE(3)
		RPCSETENV(cEmpJob,cFilJob,,,"COM")
	EndIf
	
	MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aItensPed,3,.F.)
	
	If lMsErroAuto
	
		DisarmTransaction()
		
		cRetorno := "N�o foi possivel gerar um pedido de compra para o Fornecedor "+AllTrim(cFornece)+" e Fabricante "+AllTrim(cFabric)+" favor analisar o arquivo de log "
		
		aAdd(aErros[1],cRetorno+AllTrim(NomeAutoLog()))
				   	                  
		If aScan(aErros[2],"\SYSTEM\"+NomeAutoLog()) == 0
			aAdd(aErros[2],"\SYSTEM\"+NomeAutoLog())
		EndIf
		
	Else
		
	// rotina que inserie as rotas no PC caso o Fornecedor tenha
	cRetorno += U_VIX259CR(SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)	
	cRetorno += '  - Pedido "'+SC7->C7_NUM+'" gerado com sucesso. '		   	
	
	EndIf
	
	If lExecJob
		RPCCLEARENV()
	EndIf

Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246GerSol�Autor  �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gera��o de solicita��o                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246GerSol(cFabric, cCurvaDe, cCurvaAte, nQdeDias)

	Local cArqTrb	:= GetNextAlias()
	Local aParam	:= {}
		
	Local aQtdes    := {}
	Local aFornepad := {}
	Local aSolic    := {}
	
	Local cFornece  := ""
	Local cLoja     := ""
	Local cNumSolic := ""
	Local cItemSC	:= ""
	
	Local nPrazo    := 0
	Local nQuant    := 0
	Local nSaldo    := 0
	Local nNeces    := 0
	Local nEstSeg   := 0
	Local nAuxQuant := 0
	Local nSavSaldo := 0
	Local nSaldoMax := 0
	Local ny        := 0
	Local nSaldAux  := 0
	
	Local lNumSC    := .T.
	Local lEnvMail  := .T.
	Local cPedido	  := ''
	Local aControlItens := {}
	
	Local nBlocoRegs 	:= SuperGetMv("MV_YCMPREG",.F.,500)	// Quantidade de registros a serem processados por Thread	
	Local nTrheads	:= SuperGetMv("MV_YCMPTHR",.F.,40)-1	// Quantidade de Threads simultaneas	
	Local aItens		:= {}
	Local aParms		:= {}

	Local oControlSched := NIL
	Local cAliasAux	:= GetNextAlias()
	Local cDataSolic	:= DToS(dDataBase)
	Local cQuery		:= ''
	//Parametros para gera��o das solicita��es de compra   
	               
	aAdd(aParam,Replicate(" ",TamSX3("B1_COD")[1]))		//� mv_par01     // Produto de                  �
	aAdd(aParam,Replicate("Z",TamSX3("B1_COD")[1]))		//� mv_par02     // Produto ate                 � 
	aAdd(aParam,Replicate(" ",TamSX3("B1_GRUPO")[1]))	//� mv_par03     // Grupo de                    �
	aAdd(aParam,Replicate("Z",TamSX3("B1_GRUPO")[1]))	//� mv_par04     // Grupo ate                   �
	aAdd(aParam,"PA")											//� mv_par05     // Tipo de                     �
	aAdd(aParam,"PA")											//� mv_par06     // Tipo ate                    �
	aAdd(aParam,"01")											//� mv_par07     // Local de                    �
	aAdd(aParam,"01")											//� mv_par08     // Local ate                   �
	aAdd(aParam,1)											//� mv_par09     // Considera Necess Bruta 1 sim�  Pto Pedido
	aAdd(aParam,1)											//� mv_par10     // Saldo Neg Considera    1 sim�  Lot.Economico
	aAdd(aParam,GETMV("MV_ULMES"))							//� mv_par11     // Data limite p/ empenhos     �
	aAdd(aParam,2)											//� mv_par12     // Cons.Qtd. De 3os.? Sim / Nao�
	aAdd(aParam,2)											//� mv_par13     // Cons.Qtd. Em 3os.? Sim / Nao�
	aAdd(aParam,1)											//� mv_par14     // Ao atingir Estoque Maximo ? �  1=Qtde. Original; 2=Ajusta Est. Max
	aAdd(aParam,2)											//� mv_par15     // Quebra SC por Lote Econmico?�
	aAdd(aParam,2)											//� mv_par16 Qtd.PV nao Liberado?" Subtr/Ignora �
	aAdd(aParam,"01")											//� mv_par17     // Considera Saldo Armazem de  �
	aAdd(aParam,"01")											//� mv_par18     // Considera Saldo Armazem ate �
	aAdd(aParam,2)											//� mv_par19     // Seleciona Filiais? (Sim/Nao)�
	aAdd(aParam,2)											//� mv_par20     // Gera SC por produto(Sim/Nao)�
	aAdd(aParam,1)											//� mv_par21     // Considera Est. Seguranca ?  � (Sim / Nao)
	
	//Necessario a retirada da chamada da rotina padr�o devido o tempo de processamento do mesmo
		
	BeginSql Alias cAliasAux
		SELECT NUMSC, COALESCE(DATFIM, '') DATFIM
		FROM VIX_CMP_SC1 SC1
		WHERE FILIAL = %xFilial:SC1% AND DATINC = %Exp:cDataSolic%
	
	EndSql
	
	//Se j� existir uma solicita��o continua gravando nele
	If !(cAliasAux)->(Eof())
		If ! Empty((cAliasAux)->DATFIM)
			AddMsgLog('N�o h� solici��o de compras a ser gerado.')
			(cAliasAux)->(DbCloseArea())
			GravaSolicitacao(dDataSol)
			Return
		EndIf
	
		cNumSolic := (cAliasAux)->NUMSC
	
	Else
		cNumSolic := GetNumSC1(.T.)
		ConfirmSX8()
		
		cQuery := " INSERT VIX_CMP_SC1 ( "
		cQuery += "   FILIAL, NUMSC, DATINC, HORINC ) "
		cQuery += "	VALUES ('"+xFilial("SC1")+"','"+cNumSolic+"','"+ cDataSolic +"','"+ SubStr(Time(), 1, 8)+"')"
	
		TCSqlExec(cQuery)
		
	EndIf
	
	cQuery := " DELETE FROM VIX_CMP_SC1_ITENS "
	cQuery += " WHERE NUMSC <> '"+cNumSolic+"' AND EMISSAO < '"+ dtos(dDataSol) +"'"
	TCSqlExec(cQuery)
	
	(cAliasAux)->(DbCloseArea())
	
	BeginSql Alias cArqTrb
	
		SELECT	SB1.R_E_C_N_O_ SB1RECNO 
		
		FROM 	%table:SB1% SB1
				INNER JOIN	%table:SZ1% SZ1	ON	SZ1.Z1_FILIAL	= %xFilial:SZ1% 
											AND SZ1.Z1_ATACADO	IN (%Exp:'1'%,%Exp:'8'%)
											AND SZ1.Z1_FABRIC	= SB1.B1_FABRIC
											AND SZ1.%NotDel%
											
				LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD		
				LEFT JOIN VIX_CMP_SC1_ITENS CMP ON CMP.FILIAL = '01' AND CMP.PRODUTO = B1_COD AND CMP.EMISSAO = %Exp:dDataSol%				
		WHERE	SB1.B1_FILIAL	= %xFilial:SB1%
			AND	SB1.B1_COD		BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
			AND	SB1.B1_GRUPO	BETWEEN %Exp:aParam[3]% AND %Exp:aParam[4]%	
			AND	SB1.B1_TIPO		BETWEEN %Exp:aParam[5]% AND %Exp:aParam[6]%
			AND	SB1.B1_LOCPAD	BETWEEN %Exp:aParam[7]% AND %Exp:aParam[8]%
			AND	SB1.B1_CONTRAT	<> %Exp:'S'%
			AND SB1.B1_CONTRAT	<> %Exp:'A'%
			AND SB1.B1_TIPO		<> %Exp:'BN'%
			AND SB1.B1_YCOMPRA	IN ('1',' ')
			AND SB1.B1_MSBLQL	<> %Exp:'1'%
			AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
			AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
			AND SUBSTRING(SB1.B1_COD,1,3) <> %Exp:'MOD'%
			AND SB1.%NotDel% 
			
			AND NOT EXISTS(	SELECT	SC1.R_E_C_N_O_ SC1RECNO
							FROM	%table:SC1% SC1					
							WHERE	SC1.%NotDel%
								AND SC1.C1_FILIAL	= %xFilial:SC1%    
								AND SC1.C1_RESIDUO	= %Exp:''%		
								AND SC1.C1_EMISSAO	= %Exp:dDataBase%
								AND SC1.C1_QUJE 	= %Exp:0%
								AND SC1.C1_PRODUTO	= SB1.B1_COD)                            
		
			AND CMP.NUMSC IS NULL
		ORDER BY SB1.B1_COD
	
	EndSql
	
	If (cArqTrb)->(Eof())
		AddMsgLog('N�o h� solici��o de compras a ser gerado.')
		(cArqTrb)->(DbCloseArea())
		GravaSolicitacao(dDataSol)
		Return
	EndIf 

	DbSelectArea(cArqTrb)

	nReg := 0
	Count To nReg
	
	(cArqTrb)->(dbGoTop())
	While !(cArqTrb)->(Eof())
		AADD(aItens,(cArqTrb)->SB1RECNO)

		(cArqTrb)->(DbSkip())
		If Len(aItens) == nBlocoRegs .or. (cArqTrb)->(Eof())
			
			//Fiz isso porque o protheus estava dando ACCESS VIOLETION na fun��o GetUserInfoArray
			//Ao executar a fun��o FreeObj, o sistema limpa a mem�ria dos dados do objeto
			If oControlSched <> NIL
				FreeObj(oControlSched)
			EndIf
			
			oControlSched := SchedAcesso():New()

			aParms := {}
			aAdd(aParms, cEmpAnt)
			aAdd(aParms, cFilAnt)
			aAdd(aParms, cNumSolic)
			aAdd(aParms, aItens)
			aAdd(aParms, aParam)
			aAdd(aParms, nQdeDias)
			aAdd(aParms, dDataSol)
			
			Do While .T.
				If oControlSched:ControlJOB("U_SolicComprasV246_"+cEmpAnt, nTrheads)
				
					//Transmiss�o da NF para SEFAZ e envio de notas entre grupo
					StartJob("u_V246X",GetEnvServer(),.F.,aParms)
					
					//u_V246X(aParms)
					Exit
					
				Else
					SLEEP(10000)	// 10 Segundos
				EndIf
			EndDo
			
			aItens	:= {}
			
		EndIf

	EndDo
	
	//Fiz isso porque o protheus estava dando ACCESS VIOLETION na fun��o GetUserInfoArray
	//Ao executar a fun��o FreeObj, o sistema limpa a mem�ria dos dados do objeto
	If oControlSched <> NIL
		FreeObj(oControlSched)
	EndIf
	
	oControlSched := SchedAcesso():New()
	
	Do While .T. 
		
		If oControlSched:QdeJOBAtivos("U_SolicComprasV246_"+cEmpAnt) == 0	
			Exit
			
		Else
			SLEEP(10000)	// 10 Segundos
			
		EndIf
		
	EndDo
	
	cQuery := " UPDATE VIX_CMP_SC1 SET DATFIM = '"+ DToS(dDataBase) +"', HORFIM = '"+ SubStr(Time(), 1, 8)+"'"
	cQuery += " WHERE NUMSC = '"+cNumSolic+"'"
	TCSqlExec(cQuery)
	GravaSolicitacao(dDataSol)

Return	

/*/{Protheus.doc} V246X
(long_description)
@author henrique
@since 22/11/2017
@version 1.0
@param aParams, array, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function V246X(aParams)
	Local nI, nJ		:= 0
	Local cProduto 	:= ""
	Local cSegmento	:= ""
	Local nZZZ_REG	:= 0
	Local _cEmpresa	:= aParams[1]
	Local _cFilial	:= aParams[2]
	Local cNumSolic  	:= aParams[3]
	Local aParam    	:= aParams[5]
	Local lIncEmp    	:= Type('cFilAnt') == 'U'
	Local nQdeDias	:= aParams[6]
	Local dDataSol	:= aParams[7]
	Local aQtdes    	:= {}
	Local aFornepad 	:= {}
	Local nTentativas	:= 0
	Local nMaxTenta	:= 10
	Local cQuery		:= ''
	Local lMS170FOR 	:= (ExistBlock("MS170FOR"))
	Local lMT170Sld 	:= (ExistBlock("MT170SLD"))  
	Local aItens		:= {}
	Local nTamUser  := 15
	Local cCadastro	:= OemToAnsi("Solicita��o por Ponto de Pedido")

	//altera informa��o da tread
	PTInternal(1,"U_SolicComprasV246_"+_cEmpresa+"|")
	
	If lIncEmp
		Prepare Environment Empresa _cEmpresa Filial _cFilial
	EndIf
	 
	cEmail		:= SuperGetMv('MV_Y082EML',.F.,"clayton@grupouniaosa.com.br")

	SB1->(dbSetOrder(1))				
	SB2->(dbSetOrder(1))
	SG1->(dbSetOrder(1))
	
	aItens := aParams[4]

	For nI := 1 to Len(aItens)		
		SetFunName("VIXA246")
                        
		//Posiciona no produto
		SB1->(dbGoTo(aItens[nI]))
	       
		cFornece	:= Space(TamSx3("C1_FORNECE")[1])
		cLoja		:= Space(TamSx3("C1_LOJA")[1])
		aQtdes		:= {}		
		nSaldo		:= 0
		nQuant		:= 0  
		nNeces		:= 0
	
		//�����������������������������������������������������������Ŀ
		//� Filtra se produto possui estrutura                        �
		//�������������������������������������������������������������
		If SG1->(dbSeek(xFilial("SG1")+SB1->B1_COD))
			(cArqTrb)->(dbSkip())
			Loop
		EndIf
			
		//��������������������������������������������������������������������Ŀ
		//� Filtra se produto e sub-produto e deve ser alimentado via producao �
		//����������������������������������������������������������������������
		If FindFunction("IsNegEstr") .And. IsNegEstr(SB1->B1_COD)[1]
			(cArqTrb)->(dbSkip())
			Loop
		EndIf     
	                                                            
		//�������������������������������������������������Ŀ
		//� Calcula o saldo atual de todos os almoxarifados �
		//���������������������������������������������������
		SB2->( dbSeek( xFilial("SB2")+SB1->B1_COD , .T. ))
		
		While SB2->(!Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+SB1->B1_COD
		
			If SB2->B2_LOCAL < aParam[17] .Or. SB2->B2_LOCAL > aParam[18]
				SB2->(dbSkip())
				Loop             
			EndIf                                                                                 
		
			nSaldo += (SaldoSB2(NIL,NIL,If(Empty(aParam[11]),dDataBase,aParam[11]),aParam[12]==1,aParam[13]==1)+SB2->B2_SALPEDI+SB2->B2_QACLASS)
			
			If aParam[16] == 1
				nSaldo -= SB2->B2_QPEDVEN
			EndIf              
			
			If lMT170Sld
				nSaldAux := ExecBlock("MT170SLD",.F.,.F.,{nSaldo,SB2->B2_COD,SB2->B2_LOCAL})
				If ValType(nSaldAux) == 'N'
					nSaldo := nSaldAux
				EndIf
			Endif
			
			SB2->(dbSkip())                                              
			
		EndDo
	
		nSaldoMax := A711Sb1EstMax(SB1->B1_COD)
		nSavSaldo := nSaldo
		
		If aParam[21] == 1
			nEstSeg	:= CalcEstSeg(RetFldProd(SB1->B1_COD,"B1_ESTFOR","SB1"),"SB1")
			
			//========================================================================
			//Para alguns produtos, a fun��o CalcEstSeg est� alterando a posi��o da 
			//tabela SB1, foi adicionado o c�digo abaixo para contornar este problema
			//========================================================================
			If SB1->(Recno()) <> aItens[nI]
				SB1->(dbGoTo((aItens[nI])))
				nEstSeg := RetFldProd(SB1->B1_COD,"B1_ESTSEG","SB1")
			EndIf 
			
			nSaldo 	-= nEstSeg
		EndIf
	
		nAuxQuant := Execblock("MS170QTD",.F.,.F.,{nQuant, {'DIAS', nQdeDias}})
		If ValType(nAuxQuant) == "N"
			nQuant := nAuxQuant
			//-- Ajuste efetuado para compatibilizar a quantidade retorna pelo P.E
			aQtdes := {nQuant}
		EndIf
		
		If nQuant > 0
		
			For nY :=1 to Len(aQtdes)
	
				//���������������������������������������������Ŀ
				//� Efetua checagem do estoque maximo           �
				//�����������������������������������������������
				If nSaldoMax # 0 .And. aParam[14] == 2 .And. ((QtdComp(nSaldo)+QtdComp(aQtdes[ny])) > QtdComp(nSaldoMax))
					aQtdes[ny] := Max(0,QtdComp(nSaldoMax)-QtdComp(nSaldo))
				EndIf
	
				//���������������������������������������������Ŀ
				//� Pega o prazo de entrega do material         �
				//�����������������������������������������������
				nPrazo := CalcPrazo(SB1->B1_COD,aQtdes[nY])
	
				//�����������������������������������������������������������Ŀ
				//� PDE para grava��o de fornecedor na solicita��o de compra  �
				//�������������������������������������������������������������
				If lMS170FOR
					aFornepad := Execblock("MS170FOR",.f.,.f.)
					If ValType(aFornepad) == "A"
						cFornece := aFornepad[1]
						cLoja    := aFornepad[2]
					EndIf
				EndIf
				
				cFilSC1	:= xFilial("SC1")
				cFilEnt	:= xFilEnt(xFilial("SC1"))
				cLocal		:= RetFldProd(SB1->B1_COD,"B1_LOCPAD","SB1")
				nQdtSeg	:= ConvUm(SB1->B1_COD,aQtdes[ny],0,2)
				cSolicit	:= Substr(cUsuario,7,nTamUser)
				cDatPRF	:= DTOS(SomaPrazo(dDataSol,nPrazo))
				
				InclAux(cFilSC1, cFilEnt, cNumSolic, dDataSol, SB1->B1_COD, cLocal, SB1->B1_UM, SB1->B1_SEGUM, SB1->B1_DESC, aQtdes[nY],;
							SB1->B1_CONTA, SB1->B1_CC, SB1->B1_ITEMCC, SB1->B1_CLVL, nQdtSeg, cSolicit, cDatPRF, cCadastro, SB1->B1_IMPORT,;
							cFornece, cLoja, FunName())

				//��������������������������������������������������������������Ŀ
				//� Ajusta variavel do saldo item a item para checar est. maximo �
				//����������������������������������������������������������������
				nSaldo += aQtdes[nY]

			Next nY
		
		Else			
			cFilSC1	:= xFilial("SC1")
			cFilEnt	:= xFilEnt(xFilial("SC1"))
			cLocal		:= RetFldProd(SB1->B1_COD,"B1_LOCPAD","SB1")
			cSolicit	:= Substr(cUsuario,7,nTamUser)
				
			InclAux(cFilSC1, cFilEnt, cNumSolic, dDataSol, SB1->B1_COD, cLocal, SB1->B1_UM, SB1->B1_SEGUM, SB1->B1_DESC, 0,;
							SB1->B1_CONTA, SB1->B1_CC, SB1->B1_ITEMCC, SB1->B1_CLVL, 0, cSolicit, '', cCadastro, SB1->B1_IMPORT,;
							'', '', FunName())
		
		EndIf
	
	Next

	If lIncEmp
		Reset Environment
	EndIf 

Return

/*/{Protheus.doc} InclAux
Insere dados da tabela auxiliar VIX_CMP_SC1_ITENS
@author henrique
@since 23/11/2017
@version 1.0
@param 
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function InclAux(	cFilSC1, cFilEnt, cNumSolic, dDataSol, cProduto, cLocal, cUM, cSegUM, cDescricao, nQuant, ;
	cConta, cCC, cItemCTA, cCLVL, nQdtSeg, cSolicit, cDatPRF, cObs, cImport, cFornecedor, cLoja, cOrigem)
	Local cQuery := ''
		
	cDescricao	:= LEFT(cDescricao, 100)
	cDescricao	:= Replace(cDescricao, "'", "''''")
	cSolicit	:= LEFT(cSolicit, 14)
	cSolicit	:= Replace(cSolicit, "'", "''''")
	cObs		:= LEFT(cObs, 100)
	cObs		:= Replace(cObs, "'", "''''")
	
	//Coloquei as unidades de medidas porque tem um com "'P"
	cUM			:= Replace(cUM, "'", "''''")
	cSegUM		:= Replace(cSegUM, "'", "''''")

	cQuery := " INSERT VIX_CMP_SC1_ITENS ( "
	cQuery += "   FILIAL, FILENT, NUMSC, EMISSAO, PRODUTO, LOCAL, UM, SEGUM, DESCRI, QUANT, CONTA, CC "
	cQuery += " , ITEMCTA, CLVL, QTSEGUM, SOLICIT, DATPRF, OBS, IMPORT, FORNECE, LOJA, ORIGEM "
	cQuery += " ) "
	cQuery += "	VALUES ('"+cFilSC1+"','"+cFilEnt+"','"+cNumSolic+"','"+ DTOS( dDataSol )+"','"+cProduto+"','"
	cQuery += cLocal+"','"+ cUM+"','"+cSegUM+"','"+cDescricao+"',"
	cQuery += cValToChar(nQuant)+",'"+cConta+"','"+cCC+"','"+cItemCTA+"','"+cCLVL+"',"+cValToChar(nQdtSeg)+",'"
	cQuery += cSolicit+"','"+cDatPRF+" ','"+cObs+"','"+cImport+"','"+cFornecedor+"','"
	cQuery += cLoja+"','"+cOrigem+"')"

	TCSqlExec(cQuery)

Return

/*/{Protheus.doc} GravaSolicitacao
(long_description)
@author henrique
@since 22/11/2017
@version 1.0
@param dDataSol, data, (Data da emissao da SC1)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function GravaSolicitacao(dDataSol)
	Local cAlias 		:= GetNextAlias()
	Local lEnvMail	:= .T.
	Local cItemSC		:= ''
	Local nSaveSX8  	:= GetSX8Len()
	Local cPedido		:= ''
	Local lMT170SC1 	:= (ExistBlock("MT170SC1"))
	Local lMT170FIM 	:= (ExistBlock("MT170FIM"))
	Local cNumSoli	:= ''
	Local cQuery		:= ''
	
	BeginSql Alias cAlias
		SELECT 
			  FILIAL, FILENT, NUMSC, EMISSAO, PRODUTO, LOCAL, UM, SEGUM
			, DESCRI, QUANT, CONTA, CC, ITEMCTA, CLVL, QTSEGUM, SOLICIT
			, DATPRF, OBS, IMPORT, FORNECE, LOJA, ORIGEM
			, COALESCE((SELECT MAX(C1_ITEM) FROM %Table:SC1% A WHERE C1_FILIAL = %xFilial:SC1% AND 
				A.%NotDel% AND C1_NUM = NUMSC), '') ITEMSC
		FROM 
			VIX_CMP_SC1_ITENS ITENS	
			LEFT JOIN %Table:SC1% SC1 ON SC1.C1_FILIAL = %xFilial:SC1% AND SC1.%NotDel% AND ITENS.NUMSC = SC1.C1_NUM AND SC1.C1_PRODUTO = ITENS.PRODUTO AND ITENS.QUANT = SC1.C1_QUANT
		WHERE 
			FILIAL = %xFilial:SC1% 
			AND QUANT > 0
			AND EMISSAO = %Exp:dDataSol%
			AND SC1.C1_FILIAL IS NULL 
		ORDER BY NUMSC
	EndSql 
	
	//�����������������������������������������������������������Ŀ
	//� Inicializa a gravacao dos lancamentos do SIGAPCO          �
	//�������������������������������������������������������������
	PcoIniLan("000051")	
	lEnvMail := .T.
	
	(cAlias)->(DbGoTop())
	
	While !(cAlias)->(Eof())
		cNumSoli 	:= (cAlias)->NUMSC
		cItemSC	:= (cAlias)->ITEMSC
		
		If Empty(cItemSC)
			cItemSC   := StrZero(1,Len(SC1->C1_ITEM))
		EndIf
	
		While !(cAlias)->(Eof()) .AND. cNumSoli == (cAlias)->NUMSC
			
			Begin Transaction	
				cItemSC	:= Soma1(cItemSC)
					
				RecLock("SC1",.T.)		
				SC1->C1_FILIAL  	:= (cAlias)->FILIAL
				SC1->C1_FILENT  	:= (cAlias)->FILENT
				SC1->C1_NUM     	:= (cAlias)->NUMSC
				SC1->C1_ITEM    	:= cItemSC
				SC1->C1_EMISSAO 	:= STOD((cAlias)->EMISSAO)
				SC1->C1_PRODUTO 	:= (cAlias)->PRODUTO
				SC1->C1_LOCAL   	:= (cAlias)->LOCAL
				SC1->C1_UM      	:= (cAlias)->UM
				SC1->C1_SEGUM   	:= (cAlias)->SEGUM
				SC1->C1_DESCRI  	:= (cAlias)->DESCRI
				SC1->C1_QUANT   	:= (cAlias)->QUANT
				SC1->C1_CONTA   	:= (cAlias)->CONTA
				SC1->C1_CC      	:= (cAlias)->CC
				SC1->C1_ITEMCTA 	:= (cAlias)->ITEMCTA
				SC1->C1_CLVL    	:= (cAlias)->CLVL
				SC1->C1_QTSEGUM 	:= (cAlias)->QTSEGUM
				SC1->C1_SOLICIT 	:= (cAlias)->SOLICIT
				SC1->C1_DATPRF  	:= STOD((cAlias)->DATPRF)
				SC1->C1_OBS     	:= (cAlias)->OBS
				SC1->C1_IMPORT  	:= (cAlias)->IMPORT
				SC1->C1_FORNECE 	:= (cAlias)->FORNECE
				SC1->C1_LOJA    	:= (cAlias)->LOJA   
				SC1->C1_ORIGEM	:= (cAlias)->ORIGEM
				MaAvalSC("SC1",1)
				
				If lMt170SC1
					ExecBlock("MT170SC1",.f.,.f.)
				EndIf
				
				If lMt170FIM
					AAdd( aSolic, { SB1->B1_COD, cNumSolic } )
				EndIf
			
			End Transaction
			
			//��������������������������������������������������������������Ŀ
			//� Ajusta variavel do saldo item a item para checar est. maximo �
			//����������������������������������������������������������������
			//nSaldo += aQtdes[nY]
		
			(cAlias)->(DbSkip())
		EndDo
	
		//��������������������������������������Ŀ
		//� Envia e-mail na inclusao de SC's     �
		//����������������������������������������
		If lEnvMail
			MEnviaMail("035",{SC1->C1_NUM})
			lEnvMail := .F.
		EndIf     
		
		If AllTrim(cPedido) != SC1->C1_NUM
			AddMsgLog('Solicita��o de compras "'+SC1->C1_NUM+'" gerada.')
			cPedido := SC1->C1_NUM
		EndIf
	
	EndDo
	
	(cAlias)->(DbCloseArea())
	
Return	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246IniAmb �Autor �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicia ambiente para schedule                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
Static Function VA246IniAmb()

	//Separa as filiais em vetores
	SET(_SET_DELETED,.T.)
	dbUseArea(.T.,,"SIGAMAT.EMP","SM0",.T.,.F.) 
	dbSetIndex("SIGAMAT.IND") 
	
	//RPCSETType(3)	
	Prepare Environment Empresa "08" Filial "01"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246ResiAmb�Autor �Ihorran Milholi    � Data �  12/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Reseta ambiente para schedule                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246ResiAmb()

	Reset Environment 

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA039Email �Autor �Ihorran Milholi     � Data �  27/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para envio de email com os arquivos de log da rotina ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �VIXA246                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246Email(aArqLog)

Local cEmail	:= SuperGetMv("MV_Y246EML",.F.,"clayton@grupouniaosa.com.br; analistacompras@uniaovirtual.com.br; leonardo.teixeira@uniaovirtual.com.br")  
Local cArquivo	:= ""     
Local cAssunto	:= "Comunicado - Envio de Log de Pedidos de Compra Automaticos"
Local cMsg01	:= "Segue anexo arquivo(s) de log gerados pela rotina de gera��o de pedidos de compra do dia "+dToc(dDatabase)+" as "+Time()
Local cMsg02	:= "Rotina de Gera��o de Pedido de Compra Executada sem Erros no dia "+dToc(dDatabase)+" as "+Time()
Local i			:= 0

//Monta lista dos arquivos que ir�o em anexo
For i := 1 to Len(aArqLog)
	
	If i == Len(aArqLog)
		cArquivo += aArqLog[i]
	Else
		cArquivo += aArqLog[i]+","
	EndIf
Next

If !Empty(cArquivo)

	u_EnvEmail(cEmail,cAssunto,cMsg01,cArquivo)

Else
                                                  
	u_EnvEmail(cEmail,cAssunto,cMsg02)
	
EndIf
							
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246Log   �Autor �Ihorran Milholi     � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o para cria��o do log para analise da rotina           ���
�������������������������������������������������������������������������͹��
���Uso       �VIXA246                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246Log(aErros)

Local cLogFile	:= ""
Local nHandle	:= 0
Local aLogArq	:= {}
Local lRet		:= .f.
Local cPasta	:= "\COMPRAS\"
Local i, nX	:= 0
                 
MakeDir(cPasta)

Private lAutoErrNoFile := .T.

If Len(aErros[1]) > 0

	cLogFile := cPasta+"COM"+cEmpAnt+cFilAnt+dtos(dDatabase)+".LOG"

	// ---- Gera array Log
	AutoGrLog("-------------------------------------------------------------------------------------------------")	
	AutoGrLog(OemToAnsi("Pedidos de Compra gerados na Empresa\Filial "+cEmpAnt+"\"+cFilAnt))
	AutoGrLog(OemToAnsi("Log gerado em ")+DtoC(dDataBase)+OemToAnsi(", as ")+Time())                              
	AutoGrLog("-------------------------------------------------------------------------------------------------")		
	For i:= 1 to Len(aErros[1])
		
		AutoGrLog(OemToAnsi(aErros[1][i]))
		                                                  
	Next                                                                                                         
	AutoGrLog("-------------------------------------------------------------------------------------------------")	
	
	// ---- Grava Arquivo Log
	aLogArq := GetAutoGRLog()
	
	If	!File(cLogFile)
		If	(nHandle := MSFCreate(cLogFile,0)) <> -1
			lRet := .T.
		EndIf
	Else
		If	(nHandle := FOpen(cLogFile,2)) <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf
	
	If	lRet
		For nX := 1 To Len(aLogArq)
			FWrite(nHandle,aLogArq[nX]+CHR(13)+CHR(10))
		Next nX
		FClose(nHandle)
	EndIf

EndIf  

If !Empty(cLogFile)
	aAdd(aErros[2],cLogFile)
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VA246FimProcPed�Autor �Ihorran Milholi � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o para analisar termino do processamento do p. compra  ���
�������������������������������������������������������������������������͹��
���Uso       �VIXA246                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VA246FimProcPed()

	//Local nID		:= ThreadID()
	Local aInfo 	:= GetUserInfoArray()
	Local lRet		:= .T.
	Local cFuncProc	:= "VA246JOBPED"
	Local i            
	
	For i := 1 to Len(aInfo)
		
		If cFuncProc $ AllTrim(Upper(aInfo[i][11])) .or. cFuncProc $ AllTrim(Upper(aInfo[i][5]))
			
			lRet := .f.
			Exit
	
		EndIf	
	
	Next

Return lRet

//===================================================================================
//
//
//===================================================================================
Static Function MaioDtEntr(cFornecedor)
	Local aArea	:= GetArea()
	Local dRet 	:= nil 
	Local cAliasDt:= GetNextAlias()

	BeginSQL Alias cAliasDt
		SELECT	MAX(SC1.C1_DATPRF) C1_DATPRF
		FROM	%table:SC1% SC1
			JOIN %table:SB1% SB1 on SB1.%NotDel% AND SB1.B1_FILIAL	= %xFilial:SB1% AND SC1.C1_PRODUTO	= SB1.B1_COD
		WHERE	SC1.%NotDel%
			AND SC1.C1_FILIAL	= %xFilial:SC1%
			AND SC1.C1_PEDIDO	= %Exp:''%                                 
			AND SC1.C1_RESIDUO = %Exp:''%	
			AND SB1.B1_YCOMPRA IN ('1', ' ')
			AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
			AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
			AND SB1.B1_PROC = %Exp:cFornecedor%
	EndSql

	dRet := (cAliasDt)->C1_DATPRF
	
	RestArea(aArea)

	(cAliasDt)->(DbCloseArea())
	
Return dRet

/*/{Protheus.doc} CriaParam
Cria paramentro informando que o processamento do Schedule foi finalizado
@author henrique
@since 28/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaParam()
	
	Local cParam := 'MV_YCMPFIM'
	
	If !GetMV(cParam,.T.)

		RecLock( "SX6",.T. )
			SX6->X6_FIL     := xFilial( "SX6" )
			SX6->X6_VAR     := cParam
			SX6->X6_TIPO    := "D"	
			SX6->X6_DESCRIC := 'Parametro para informando a data da finaliza��o do'
			SX6->X6_DESC1   := 'processo'
			SX6->X6_DESC2   := ''
		  	SX6->X6_CONTEUD := ""
			SX6->X6_CONTSPA := ""
			SX6->X6_CONTENG := ""
		MsUnLock()
	EndIf    
Return