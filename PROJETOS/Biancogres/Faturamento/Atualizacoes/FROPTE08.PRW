#INCLUDE "PROTHEUS.CH"   
#INCLUDE "TOPCONN.CH"

//Posicoes do Vetor do GRID 1 (superior)
#DEFINE _NP1_MARCA	01
#DEFINE _NP1_PROD	02
#DEFINE _NP1_DESC	03
#DEFINE _NP1_LOTE	04
#DEFINE _NP1_RESTR	05
#DEFINE _NP1_SALDO	06
#DEFINE _NP1_EST	07
#DEFINE _NP1_OPNUM	08
#DEFINE _NP1_ETIQ	09
#DEFINE _NP1_SALOP	10
#DEFINE _NP1_RESOP	11
#DEFINE _NP1_LTOBS	12


//Posicoes do Vetor do GRID 2 (inferior)
#DEFINE _NP2_MARCA		01	
#DEFINE _NP2_OPNUM		02	
#DEFINE _NP2_EMISSA		03 
#DEFINE _NP2_PEDIDO		04 
#DEFINE _NP2_ITEM		05	
#DEFINE _NP2_PROD		06	
#DEFINE _NP2_SEG		07
#DEFINE _NP2_GRPVEN		08	
#DEFINE _NP2_CODCLI		09	
#DEFINE _NP2_NOMCLI		10	
#DEFINE _NP2_CATEG		11	
#DEFINE _NP2_REPRE		12	
#DEFINE _NP2_DTNECE		13
#DEFINE _NP2_QTDPED		14	
#DEFINE _NP2_SALDO		15	
#DEFINE _NP2_LOTE		16	
#DEFINE _NP2_FLAG		17	
#DEFINE _NP2_ERRO		18


/*/{Protheus.doc} FROPTE08
@description TELA DE PROCESSAMENTO DE DISTRIBUICAO E RESERVAS
@author Fernando Rocha
@since 06/01/2015
@version 1.0
@type function
/*/
User Function FROPTE08
	Local aArea 	:= GetArea() 

	Private aSize := MsAdvSize(,.F.)                                     
	Private cAlias1, cAlias2, cAlias1Det 
	Private cTRB2 := "TRBPED"+__CUSERID
	Private aWB1 := {}
	Private aWB1Det	:= {}
	Private aWB2 := {}                                
	Private aWB2Main   
	Private aWB2Pad
	Private oOk := LoadBitmap( GetResources(), "LBOK")
	Private oNo := LoadBitmap( GetResources(), "LBNO")

	Private lChkEmp	:= .T.
	Private lPrcEmpAut := SB1->(FieldPos("B1_YFOCO")) > 0 .And. SA1->(FieldPos("A1_YLOTRES")) > 0  //Se o processo de empenho automatico esta implantado
	Private oEmpPed := TBiaEmpenhoPedido():New()

	LoadDlg()

	//Recupera area de trabalho 
	If Select(cTRB2) > 0
		(cTRB2)->(DbCloseArea())
	EndIf

	RestArea(aArea)
Return  

Static Function LoadDlg()
	Local _lOk := .F.
	Local _nTpRot := 1
	Local aPergs 
	Local aRet := {}
	Local lProd := .T.

	aWB1 := {}
	aWB1Det	:= {}
	aWB2 := {}

	//Recupera area de trabalho 
	If Select(cTRB2) > 0
		(cTRB2)->(DbCloseArea())
	EndIf 

	//Retirado o U_BIAMsgRun para testar se eh isso que esta fazendo a tela da Micheli travar
	_lOk := PesqDist(lProd)
	If _lOk
		PesqRes(lProd)
		ShowDialog()
	EndIf

Return

Static Function PesqDist(lProd)
	Local aAux
	Local cSQL
	Local _cSP1Name := "FNC_ROP_SALDO_PENDENTE_END_"+AllTrim(CEMPANT)+"(1)"  //Consulta Sintetica 
	Local _cSP1NDet := "FNC_ROP_SALDO_PENDENTE_END_"+AllTrim(CEMPANT)+"(0)"  //Consulta Analitica

	Default lProd := .T.

	//Processar pendencias de enderecamento
	cAlias1Det := GetNextAlias()
	cSQL := "select * from "+_cSP1NDet+" order by DA_PRODUTO, DA_LOTECTL "
	TCQuery cSQL Alias (cAlias1Det) New

	While !(cAlias1Det)->(Eof())

		_nPos := aScan( aWB1, {|x|  x[_NP1_PROD] ==  (cAlias1Det)->DA_PRODUTO .And. x[_NP1_LOTE] ==  (cAlias1Det)->DA_LOTECTL .And.  x[_NP1_OPNUM] ==  (cAlias1Det)->D3_OP  } )

		If _nPos <= 0

			aAux := {}             
			aAdd(aAux,.F.)
			aAdd(aAux,(cAlias1Det)->DA_PRODUTO)  
			aAdd(aAux,(cAlias1Det)->B1_DESC) 
			aAdd(aAux,(cAlias1Det)->DA_LOTECTL) 
			aAdd(aAux,(cAlias1Det)->RESTRITO)
			aAdd(aAux,(cAlias1Det)->DA_SALDO) 
			aAdd(aAux,(cAlias1Det)->SALDO_EST)
			aAdd(aAux,(cAlias1Det)->D3_OP)
			aAdd(aAux,(cAlias1Det)->NUM_ETIQ) 
			aAdd(aAux,(cAlias1Det)->SALDO_OP)
			aAdd(aAux,(cAlias1Det)->RES_MAN_OP)
			aAdd(aAux,(cAlias1Det)->ZZ9_OBS)

			aAdd(aWB1, aAux)

		Else

			aWB1[_nPos][_NP1_SALDO] += (cAlias1Det)->DA_SALDO 
			aWB1[_nPos][_NP1_ETIQ] += (cAlias1Det)->NUM_ETIQ

		EndIf

		(cAlias1Det)->(DbSkip())
	EndDo 

	If Len(aWB1) <= 0

		MsgInfo("Não existe estoque pendente de distribuição!","DISTRIBUIÇÃO E RESERVA DE ESTOQUE")
		Return(.F.)

	EndIf

Return(.T.) 


Static Function PesqRes(lProd)
	Local aAux
	Local cSQL
	Local _cSP1Name := "FNC_ROP_RESERVA_PENDENTE_OP_"+AllTrim(CEMPANT)+"()"  //Consulta Analitica

	Default lProd := .T.

	//Processar pendencias de reserva de OP
	cAlias2 := GetNextAlias()

	cSQL := "select * from "+_cSP1Name+" ORDER BY PZ0_OPNUM, C6_PRODUTO, C6_YEMISSA, PRIRECGR, C6_CLI, C6_LOJA, RECNO, C6_NUM "

	TCQuery cSQL Alias (cAlias2) New

	DbSelectArea(cAlias2)
	ARQ := CriaTrab((cAlias2)->(DbStruct()))

	DbUseArea(.T.,,ARQ,cTRB2)
	DbSelectArea(cTRB2)

	Append from (cAlias2)
	(cAlias2)->(DbCloseArea())

	cIndex   := CriaTrab(nil,.F.)
	cChave   := "PZ0_OPNUM+C6_PRODUTO+C6_YEMISSA+STR(PRIRECGR,20)+C6_CLI+C6_LOJA+STR(RECNO,20)+C6_NUM+C6_ITEM"
	(cTRB2)->(DbCreateIndex( cIndex, cChave, {|| &cChave}, .F. ))
	(cTRB2)->(DbCommit()) 

	(cTRB2)->(DbSetOrder(1))
	(cTRB2)->(DbGoTop())   

	aWB2Pad := {.F.,"",CTOD(" "),"","","","","","","","","",CTOD(" "),0,0,"","",""}

	While !(cTRB2)->(Eof())  

		aAux := {}             
		aAdd(aAux,.T.)               
		aAdd(aAux,(cTRB2)->PZ0_OPNUM) 
		aAdd(aAux,DTOC(STOD((cTRB2)->C6_YEMISSA)))  
		aAdd(aAux,(cTRB2)->C6_NUM) 
		aAdd(aAux,(cTRB2)->C6_ITEM)
		aAdd(aAux,(cTRB2)->C6_PRODUTO) 
		aAdd(aAux,(cTRB2)->A1_YTPSEG) 
		aAdd(aAux,(cTRB2)->A1_GRPVEN)
		aAdd(aAux,(cTRB2)->C6_CLI+(cTRB2)->C6_LOJA)
		aAdd(aAux,(cTRB2)->A1_NOME)
		aAdd(aAux,(cTRB2)->A1_YCAT)
		aAdd(aAux,(cTRB2)->A3_NREDUZ)
		aAdd(aAux,DTOC(STOD((cTRB2)->C6_YDTNECE)))
		aAdd(aAux,(cTRB2)->C6_QTDVEN)
		aAdd(aAux,(cTRB2)->SALDO) 
		aAdd(aAux,"") //Lote vai ser preenchido no atendimento
		aAdd(aAux,"N") //Flag de processamento
		aAdd(aAux,"") //Mensagem de Erro de processamento

		aAdd(aWB2, aAux)

		(cTRB2)->(DbSkip())
	EndDo 

	aWB2Main := AClone(aWB2)  
	aWB2 := {}
	aADD(aWB2,AClone(aWB2Pad))

Return


Static Function ShowDialog()
	Local lProcOk := .F.
	Local oFont1 := TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)

	Private oButOk 
	Private oButLot
	Private oPanel1
	Private oPanel2
	Private oPanel3
	Private oDlg
	Private oWB1
	Private oWB2 



	DEFINE MSDIALOG oDlg TITLE "Distribuir e Reservar Produção" FROM aSize[7],000 TO aSize[6],aSize[5] COLORS 0, 16777215 PIXEL

	@ 000, 000 MSPANEL oPanel1 SIZE 400, 103 OF oDlg COLORS 0, 16777215 RAISED
	@ 229, 000 MSPANEL oPanel2 SIZE 400, 020 OF oDlg COLORS 0, 16777215 RAISED
	@ 103, 000 MSPANEL oPanel3 SIZE 400, 126 OF oDlg COLORS 0, 16777215 RAISED

	fWB1()
	fWB2()

	@ 000, 335 BUTTON oButOk PROMPT "PROCESSAR" SIZE 064, 019 OF oPanel2 PIXEL ACTION ( Processar(), lProcOk := .T., oDlg:End() )
	@ 000, 335 BUTTON oButLot PROMPT "VER.LOTES" SIZE 064, 019 OF oPanel2 PIXEL ACTION ( ChkLotes() ) 
	@ 000, 335 BUTTON oButXls PROMPT "IMP.EXCEL" SIZE 064, 019 OF oPanel2 PIXEL ACTION ( F_EXCEL(.T.) )

	If lPrcEmpAut

		@ 000, 335 CheckBox oChkEmp Var lChkEmp Prompt "Empenhar Automaticamente?" Size 150, 019 Font oFont1 Pixel Of oPanel2

	EndIf

	// Don't change the Align Order 
	oPanel1:Align := CONTROL_ALIGN_TOP
	oPanel2:Align := CONTROL_ALIGN_BOTTOM

	oButOk:Align := CONTROL_ALIGN_RIGHT
	oButLot:Align := CONTROL_ALIGN_RIGHT
	oButXls:Align := CONTROL_ALIGN_RIGHT

	If lPrcEmpAut

		oChkEmp:Align := CONTROL_ALIGN_RIGHT

	EndIf

	oWB1:Align := CONTROL_ALIGN_ALLCLIENT
	oPanel3:Align := CONTROL_ALIGN_ALLCLIENT
	oWB2:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTERED   

	If lProcOk
		LoadDlg()
	EndIf

Return


Static Function fWB1()

	@ 000, 000 LISTBOX oWB1 Fields HEADER "","PRODUTO","DESCRICAO","LOTE","RESTRITO","SALDO.PEND.","ESTOQUE ATUAL","OP","N.ETIQ.","SALDO OP","RES.MAN.","OBS. LOTE" SIZE 399, 102 OF oPanel1 PIXEL ColSizes 50,50
	oWB1:SetArray(aWB1)
	oWB1:bLine := {|| {;
	If(aWB1[oWB1:nAT,	_NP1_MARCA	],oOk,oNo),;
	aWB1[oWB1:nAt,	_NP1_PROD	],;
	aWB1[oWB1:nAt,	_NP1_DESC	],;
	aWB1[oWB1:nAt,	_NP1_LOTE	],; 
	aWB1[oWB1:nAt,	_NP1_RESTR	],;
	aWB1[oWB1:nAt,	_NP1_SALDO	],; 
	aWB1[oWB1:nAt,	_NP1_EST	],; 
	aWB1[oWB1:nAt,	_NP1_OPNUM	],; 
	aWB1[oWB1:nAt,	_NP1_ETIQ	],;
	aWB1[oWB1:nAt,	_NP1_SALOP	],;
	aWB1[oWB1:nAt,	_NP1_RESOP	],;
	aWB1[oWB1:nAt,	_NP1_LTOBS	];
	}}
	// DoubleClick event
	oWB1:bLDblClick := {|| WB1Mark() }  

	oWB1:bHeaderClick := {|| WB1MkAll(oWB1:ColPos) }

Return   

Static Function WB1MkAll(nCol)  
	Local I 

	For I := 1 To Len(aWB1)
		aWB1[I][_NP1_MARCA] := !aWB1[I][_NP1_MARCA]
	Next I

	ProcMark()

	oWB1:Refresh()
	oDLG:Refresh()

Return 

Static Function WB1Mark()

	aWB1[oWB1:nAt,_NP1_MARCA] := !aWB1[oWB1:nAt,_NP1_MARCA]
	oWB1:DrawSelect()
	ProcMark()

Return

Static Function ProcMark()
	Local I  

	//Checkagem de Pedidos nao atendidos em OPs anteriores as selecionadas
	If !ChkPedAnt()
		Return
	EndIf

	//sempre ao mudar marcacao dos lotes limpa lotes dos pedidos para processar novamente
	aWB2 := {}

	(cTRB2)->(DbGoTop())
	While !(cTRB2)->(Eof())
		RecLock(cTRB2,.F.)
		(cTRB2)->C6_LOTECTL := ""
		(cTRB2)->(MsUnlock())  

		(cTRB2)->(DbSkip())
	EndDo


	FOR I := 1 To Len(aWB1)

		If aWB1[I][_NP1_MARCA] 

			If aWB1[I][_NP1_RESOP] > 0
				MsgAlert("ATENÇÃO! A OP: "+aWB1[I][_NP1_OPNUM]+" - Possui "+AllTrim(Str(aWB1[I][_NP1_RESOP]))+" m2 em Reserva Manual!","DISTRIBUIÇÃO E RESERVA DE ESTOQUE")		
			EndIf

			(cTRB2)->(DbGoTop())	
			If (cTRB2)->(DbSeek(aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD]))
				While !(cTRB2)->(Eof()) .And. (cTRB2)->(PZ0_OPNUM+C6_PRODUTO) == (aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD])

					_nPos2 := aScan( aWB2Main, {|x|  x[_NP2_PEDIDO] ==  (cTRB2)->C6_NUM .And. x[_NP2_ITEM] == (cTRB2)->C6_ITEM } )

					//Fernando/Facile: nao inserir no grid pedidos/items duplicados - 03/06 - teste com a Micheli
					_nPosPed := aScan( aWB2, {|x|  x[_NP2_PEDIDO] ==  (cTRB2)->C6_NUM .And. x[_NP2_ITEM] == (cTRB2)->C6_ITEM } )

					If _nPos2 > 0 .And. _nPosPed <= 0
						aADD(aWB2, AClone(aWB2Main[_nPos2]))
					EndIf
					(cTRB2)->(DbSkip())
				EndDo
			EndIf

		EndIf

	NEXT I

	If Len(aWB2) <= 0
		aADD(aWB2,AClone(aWB2Pad))
	EndIf

	LoadWB2()

Return


Static Function fWB2()

	@ 000, 000 LISTBOX oWB2 Fields;
	HEADER "","OP","EMISSAO","PEDIDO","ITEM","PRODUTO","SEG","GRUPO","CLIENTE","NOME","CATEGORIA","REPRESENTANTE","DT.NECE.","QTD.PED","SALDO.PED","LOTE","OBS.";
	ColSizes 10,20,30,20,15,40,10,20,30,100,50,100,30,50,50,20,100;
	SIZE 399, 125 OF oPanel3 PIXEL
	LoadWB2()

	// DoubleClick event
	oWB2:bLDblClick := {|| aWB2[oWB2:nAt,_NP2_MARCA] := !aWB2[oWB2:nAt,_NP2_MARCA],;
	oWB2:DrawSelect()}

	oWB2:bHeaderClick := {|| WB2MkAll(oWB2:ColPos) }

Return 

Static Function WB2MkAll(nCol)  
	Local I 

	For I := 1 To Len(aWB2)
		aWB2[I][_NP2_MARCA] := !aWB2[I][_NP2_MARCA]
	Next I

	oWB2:Refresh()
	oDLG:Refresh()

Return

Static Function LoadWB2()

	If Len(aWB2) > 0

		oWB2:SetArray(aWB2)
		oWB2:bLine := {|| {;
		If(aWB2[oWB2:nAT,	_NP2_MARCA	],oOk,oNo),;
		aWB2[oWB2:nAt,	_NP2_OPNUM	],;
		aWB2[oWB2:nAt,	_NP2_EMISSA	],;
		aWB2[oWB2:nAt,	_NP2_PEDIDO	],;
		aWB2[oWB2:nAt,	_NP2_ITEM	],;
		aWB2[oWB2:nAt,	_NP2_PROD	],;
		aWB2[oWB2:nAt,	_NP2_SEG	],;
		aWB2[oWB2:nAt,	_NP2_GRPVEN	],;
		aWB2[oWB2:nAt,	_NP2_CODCLI	],;
		SubStr(aWB2[oWB2:nAt,	_NP2_NOMCLI	],1,30),;
		aWB2[oWB2:nAt,	_NP2_CATEG	],; 
		SubStr(aWB2[oWB2:nAt,	_NP2_REPRE	],1,20),;
		aWB2[oWB2:nAt,	_NP2_DTNECE	],;
		aWB2[oWB2:nAt,	_NP2_QTDPED	],;
		aWB2[oWB2:nAt,	_NP2_SALDO	],;
		aWB2[oWB2:nAt,	_NP2_LOTE	],;
		aWB2[oWB2:nAt,	_NP2_ERRO	];
		}}	
	EndIf
	oWB2:Refresh()
	oDLG:Refresh()  

Return


Static Function ChkLotes()
	U_BIAMsgRun("Aguarde... Verificando lotes e pedidos a serem atendidos.",,{|| ChkLotPrc() })
Return

Static Function ChkLotPrc()
	Local _nPos, _nPos2
	Local _nSalTot, _nSalPed 
	Local I     
	Local cAliasPal
	Local nQtdPal
	Local np1_PROD 	:= _NP1_PROD
	Local np1_LOTE	:= _NP1_LOTE
	Local _nPX
	Local aSldCli	:= {}
	Local _nSldPendCli
	Local _nSldAtCli

	FOR I := 1 To Len(aWB1)

		//Sempre limpar toas as marcacoes do Lote para redistribuir - Fernando em 12/09
		If (cTRB2)->(DbSeek(aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD])) 
			While !(cTRB2)->(Eof()) .And. (cTRB2)->(PZ0_OPNUM+C6_PRODUTO) == (aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD])

				_nPos2 := aScan( aWB2, {|x|  x[_NP2_PEDIDO] ==  (cTRB2)->C6_NUM .And. x[_NP2_ITEM] ==  (cTRB2)->C6_ITEM } )
				//limpa o lote no caso de desmarcacao
				if _nPos2 > 0 .And. !Empty(aWB2[_nPos2][_NP2_LOTE]) .And. AllTrim(aWB2[_nPos2][_NP2_LOTE]) == AllTrim(aWB1[I][_NP1_LOTE])
					RecLock(cTRB2,.F.)
					(cTRB2)->C6_LOTECTL := ""
					(cTRB2)->(MsUnlock())
					aWB2[_nPos2][_NP2_LOTE] := ""  
				endif

				(cTRB2)->(DbSkip())
			EndDo
		EndIf

		if !aWB1[I][_NP1_MARCA]  //se nao esta marcado o lote para distribuir pula
			loop
		endif

		//saldo total do lote para tentar gerar reservas
		_nSalTot := aWB1[I][_NP1_SALDO] + aWB1[I][_NP1_EST]

		//buscando quantidade por palete - verificacao de pontas
		cAliasPal := GetNextAlias()
		BeginSQL Alias cAliasPal
			%NOPARSER%

			select top 1
			QT_UM_PALLET = cast((ZZ9_DIVPA * B1_CONV) as decimal(15,2)) 
			from
			%TABLE:ZZ9% ZZ9
			join %TABLE:SB1% SB1 on B1_COD = ZZ9_PRODUT
			where
			ZZ9_PRODUT = %EXP:aWB1[I][np1_PROD]%
			and ZZ9_LOTE = %EXP:aWB1[I][np1_LOTE]%
			and ZZ9.D_E_L_E_T_ = ''
			and SB1.D_E_L_E_T_ = ''

		EndSQl

		(cAliasPal)->(DbGoTop())
		If (cAliasPal)->(Eof()) 
			MsgInfo("Lote: "+aWB1[I][_NP1_LOTE]+" - Cadastro ZZ9 nao encontrado!","DISTRIBUIÇÃO E RESERVA DE ESTOQUE")
			loop
		EndIf    

		nQtdPal := (cAliasPal)->QT_UM_PALLET 

		(cAliasPal)->(DbCloseArea())

		//procurar pedidos que serão atendidos
		(cTRB2)->(DbGoTop()) 

		If (cTRB2)->(DbSeek(aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD])) 

			While !(cTRB2)->(Eof()) .And. (cTRB2)->(PZ0_OPNUM+C6_PRODUTO) == (aWB1[I][_NP1_OPNUM]+aWB1[I][_NP1_PROD])

				_nPos2 := aScan( aWB2, {|x|  x[_NP2_PEDIDO] ==  (cTRB2)->C6_NUM .And. x[_NP2_ITEM] ==  (cTRB2)->C6_ITEM } )

				//se pedido e lote esta marcado e lote ainda nao preenchido
				if aWB2[_nPos2][_NP2_MARCA] .And. Empty(aWB2[_nPos2][_NP2_LOTE]) 

					//Verificar se pode atender o pedido  (engenharis / lote restriro / outros...)
					oEmpPed:cCliLjOri	:= (cTRB2)->C6_CLI+(cTRB2)->C6_LOJA
					oEmpPed:cProduto := (cTRB2)->C6_PRODUTO
					oEmpPed:Pedido := (cTRB2)->C6_NUM 
					oEmpPed:Item := (cTRB2)->C6_ITEM
					oEmpPed:Quantidade := (cTRB2)->SALDO
					oEmpPed:Lote := aWB1[I][_NP1_LOTE]

					If !(oEmpPed:ChkAtendimento())

						aWB2[_nPos2][_NP2_ERRO] := oEmpPed:cRegraNAtend

						(cTRB2)->(DbSkip())
						
						loop
						
					EndIf

					//saldo do pedido
					_nSalPed := (cTRB2)->SALDO  

					//saldo pendente do cliente		
					/*_nSldAtCli := 0
					_nPX := aScan(aSldCli, {|x| x[1] == (cTRB2)->C6_CLI+(cTRB2)->C6_LOJA})
					
					If _nPX > 0
						_nSldAtCli := aSldCli[_nPX][2]
					EndIf
					_nSldPendCli := ((cTRB2)->SLDCLI - _nSldAtCli)
					*/

					If !(_nSalTot >= _nSalPed) 

						aWB2[_nPos2][_NP2_ERRO] := "SALDO INSUFICIENTE"

					ElseIf !( (_nSalTot - _nSalPed) == 0 .Or. (_nSalTot - _nSalPed) >= nQtdPal ) //So atende pedidos que nao vai causar ponta no estoque

						aWB2[_nPos2][_NP2_ERRO] := "GERANDO PONTA"

					/*ElseIf ( (_nSalTot < _nSldPendCli) .Or. ( (_nSalTot - _nSldPendCli) > 0 .And. (_nSalTot - _nSldPendCli) < nQtdPal   ) )

						aWB2[_nPos2][_NP2_ERRO] := "SALDO NÃO ATENDE PEDIDOS DO CLIENTE"
					*/
					Else 

						RecLock(cTRB2,.F.)
						
						(cTRB2)->C6_LOTECTL := aWB1[I][_NP1_LOTE]
						(cTRB2)->(MsUnlock())

						//controle de saldo total do cliente
						/*_nPX := aScan(aSldCli, {|x| x[1] == (cTRB2)->C6_CLI+(cTRB2)->C6_LOJA})
						
						If _nPX > 0
							aSldCli[_nPX][2] += _nSalPed
						Else
							AAdd(aSldCli, {(cTRB2)->C6_CLI+(cTRB2)->C6_LOJA, _nSalPed})
						EndIf
						*/
						
						aWB2[_nPos2][_NP2_LOTE] := aWB1[I][_NP1_LOTE]
						aWB2[_nPos2][_NP2_ERRO] := ""

						_nSalTot -= _nSalPed 	

					EndIf
					
				Else                      

					//limpa o lote no caso de desmarcacao
					if !aWB2[_nPos2][_NP2_MARCA]

						RecLock(cTRB2,.F.)
						(cTRB2)->C6_LOTECTL := ""
						(cTRB2)->(MsUnlock())

						aWB2[_nPos2][_NP2_LOTE] := ""

					endif

				endif

				(cTRB2)->(DbSkip())
				
			EndDo

		EndIf

	Next I

	LoadWB2()

Return


/*/{Protheus.doc} F_EXCEL
@description Geração das reservas conforme marcação na Tela
@author Fernando Rocha
@type function
/*/
Static Function Processar()                                                         
	Local nSel := 0
	Local I

	If !MsgYesNo("Tem certeza que deseja PROCESSAR A DISTRIBUIÇÃO DOS LOTES SELECIONADOS?","DISTRIBUIÇÃO E RESERVA DE ESTOQUE")
		Return
	EndIf

	FOR I := 1 To len(aWB2) 

		If aWB2[I][_NP2_MARCA] .And. !Empty(aWB2[I][_NP2_LOTE])
			nSel++
		EndIf

	NEXT I 

	If Len(aWB2) > 0 .And. nSel <= 0
		If !MsgNoYes("NÃO FOI SELECIONADO nenhum pedido/lote para ser ATENDIDO."+CRLF+;
		"Os lotes distribuidos vão entrar para o ESTOQUE DISPONIVEL."+CRLF+CRLF+;
		"Tem certeza que deseja CONTINUAR?","DISTRIBUIÇÃO E RESERVA DE ESTOQUE")
			Return
		EndIf
	EndIf

	U_BIAMsgRun("Aguarde... Processando distribuicao e reservas.",,{|| ProcPrc() })
Return

Static Function ProcPrc()   
	Local zProduto
	Local zLoteCtl
	Local az_NmSeq
	Local zDataMOv
	Local zQtdeMov 
	Local sk_RuaZZ  
	Local zz_Item 
	Local aCabSDA    := {}
	Local aItSDB     := {}
	Local _aItensSDB := {}  
	Local _cLogTxt := ""   
	Local _cAliasAux := {}
	Local aRet

	Local _lSucesso := .F.
	Local _cFlag	:= ""
	Local _cErro	:= ""

	Private lMsErroAuto := .F.

	//Processando todas as distribuicoes marcadas
	(cAlias1Det)->(DbGoTop())
	While !(cAlias1Det)->(Eof()) 

		_nPos := aScan( aWB1, {|x|  x[_NP1_PROD] ==  (cAlias1Det)->DA_PRODUTO .And. x[_NP1_LOTE] ==  (cAlias1Det)->DA_LOTECTL } )

		//se lote esta marcado
		if _nPos > 0 .And. aWB1[_nPos][_NP1_MARCA]

			zProduto  := (cAlias1Det)->DA_PRODUTO
			zLoteCtl  := (cAlias1Det)->DA_LOTECTL
			az_NmSeq  := (cAlias1Det)->DA_NUMSEQ
			zDataMOv  := STOD((cAlias1Det)->DA_DATA)
			zQtdeMov  := (cAlias1Det)->DA_SALDO

			sk_RuaZZ := "ZZZZ"
			If "RET" $ Alltrim(zLoteCtl) .or. ( Right(Alltrim(zLoteCtl),1) == "R" .and. Substr((cAlias1Det)->DA_PRODUTO,1,2) == "AT" )
				sk_RuaZZ := "PAP"
			EndIf

			_cAliasAux := GetNextAlias()
			BeginSql Alias _cAliasAux
				select DB_ITEM = max(DB_ITEM) from %TABLE:SDB% where DB_FILIAL = '01' and DB_NUMSEQ = %EXP:az_NmSeq% and D_E_L_E_T_ = ''		
			EndSql

			If !(_cAliasAux)->(Eof())
				zz_Item := Soma1((_cAliasAux)->DB_ITEM,4)
			Else
				zz_Item := "0001"
			EndIf  
			(_cAliasAux)->(DbCloseArea())

			aCabSDA    := {}
			aItSDB     := {}
			_aItensSDB := {}
			aCabSDA := {	{"DA_PRODUTO" ,zProduto			         ,Nil},;
			{"DA_NUMSEQ"  ,az_NmSeq         	     ,Nil} }

			aItSDB := {		{"DB_ITEM"     ,zz_Item                  ,Nil},;
			{"DB_ESTORNO"  ," "                      ,Nil},;
			{"DB_LOCALIZ"  ,sk_RuaZZ                 ,Nil},;
			{"DB_DATA"     ,zDataMOv                 ,Nil},;
			{"DB_QUANT"    ,zQtdeMov                 ,Nil} }  

			aadd(_aItensSDB,aitSDB)
			MATA265( aCabSDA, _aItensSDB, 3)

			If lMsErroAuto

				MostraErro()

				//Grava log de erro para consulta posterior
				aAutoErro := GETAUTOGRLOG()
				_cLogTxt += XCONVERRLOG(aAutoErro)
				ConOut("ENDERECAR PRODUCAO -  ERRO: "+_cLogTxt)
				return({.F.,_cLogTxt})
			Else

			EndIf

		endif

		(cAlias1Det)->(DbSkip())
	EndDo 


	//Parametrizacao da classe de Empenhos
	oEmpPed:lCredito	:= .T.
	oEmpPed:lEstoque	:= .T.
	oEmpPed:lAvalCred	:= .T.	

	//Processando as reservas pendentes
	//procurar pedidos que serão atendidos
	(cTRB2)->(DbGoTop()) 
	While !(cTRB2)->(Eof())

		_nPos2 := aScan( aWB2, {|x|  x[_NP2_PEDIDO] ==  (cTRB2)->C6_NUM .And. x[_NP2_ITEM] ==  (cTRB2)->C6_ITEM } )

		//se pedido esta marcado
		if _nPos2 > 0 .And. aWB2[_nPos2][_NP2_MARCA]

			//tentar reservar estoque dos pedidos marcados
			If !Empty((cTRB2)->C6_LOTECTL) 

				Begin Transaction

					SC6->(DbSetOrder(1))
					SC6->(DbSeek(XFilial("SC6")+(cTRB2)->C6_NUM+(cTRB2)->C6_ITEM))               

					SC5->(DbSetOrder(1))
					SC5->(DbSeek(XFilial("SC6")+(cTRB2)->C6_NUM))

					_lSucesso 	:= .F.
					_cFlag		:= "N"
					_cErro		:= ""

					If ( lPrcEmpAut .And. lChkEmp )

						//verificando se é para gerar empenho automatico do pedido ao invés de Reserva de Estoque
						oEmpPed:cCliLjOri	:= (cTRB2)->C6_CLI+(cTRB2)->C6_LOJA
						oEmpPed:cProduto 	:= (cTRB2)->C6_PRODUTO

						oEmpPed:Pedido		:= (cTRB2)->C6_NUM 
						oEmpPed:Item		:= (cTRB2)->C6_ITEM
						oEmpPed:Quantidade	:= (cTRB2)->SALDO
						oEmpPed:Lote		:= (cTRB2)->C6_LOTECTL

						If ( oEmpPed:ChkEmpAuto() .And. ALLTRIM(SC5->C5_YCONF) == 'S')

							oEmpPed:Liberar()

							If ( oEmpPed:LibOk )

								_lSucesso 	:= .T.
								_cFlag		:= "P"
								_cErro		+= ""

							Else

								_lSucesso 	:= .F.
								_cFlag		:= "X"
								_cErro		+= IIf(!Empty(_cErro),";","") + oEmpPed:cErro

							EndIf

						Else

							_lSucesso 	:= .F.
							_cFlag		:= "X"
							_cErro		+= IIf(!Empty(_cErro),";","") + oEmpPed:cRegraNEmp

						EndIf

					EndIf

					If ( !_lSucesso )

						aRet := U_FRRT02IR((cTRB2)->C6_NUM, (cTRB2)->C6_ITEM, (cTRB2)->C6_PRODUTO, SC6->C6_LOCAL, (cTRB2)->SALDO, SC5->C5_VEND1, (cTRB2)->C6_LOTECTL,,CUSERNAME, .T., "PRD")

						If Len(aRet[2]) > 0

							_lSucesso 	:= .T.
							_cFlag		:= "E"							

						Else

							_lSucesso 	:= .F.
							_cFlag		:= "X"
							_cErro		+= IIf(!Empty(_cErro),";","") + "ERRO NA INCLUSÃO DE RESERVA"

						EndIf

					EndIf

					//se reservou estoque com sucesso apaga a reserva de OP
					If _lSucesso

						//Marcar o item como RESERVA DE ESTOQUE
						SC6->(DbSetOrder(1))
						If SC6->(DbSeek(XFilial("SC6")+(cTRB2)->C6_NUM+(cTRB2)->C6_ITEM))

							RecLock("SC6",.F.)
							SC6->C6_YTPEST := _cFlag
							SC6->C6_LOTECTL := (cTRB2)->C6_LOTECTL 
							SC6->(MsUnlock())

						EndIf

						//Apagar reservas de OP se existir - reservas definitivas pelo pedido
						PZ0->(DbSetOrder(2)) 
						If PZ0->(DbSeek(XFilial("PZ0")+(cTRB2)->C6_NUM+(cTRB2)->C6_ITEM))
							While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV)) == (XFilial("PZ0")+(cTRB2)->C6_NUM+(cTRB2)->C6_ITEM)

								U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"DISPRD","","PRD", "SISTEMA")

								RecLock("PZ0",.F.)
								PZ0->(DbDelete())
								PZ0->(MsUnlock())

								PZ0->(DbSkip())
							EndDo
						EndIf                                   

						//Posicoes do vetor virtuais para registro do retorno de cada linha
						aWB2[_nPos2][_NP2_FLAG] := _cFlag //reserva de estoque
						aWB2[_nPos2][_NP2_ERRO]	:= _cErro //mensagem de erro

					Else

						DisarmTransaction()

					EndIf

				End Transaction

			EndIf

		endif

		(cTRB2)->(DbSkip())
	EndDo 

	//Gerar Planilha
	F_EXCEL()

return({.T.,""}) 

//CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
STATIC FUNCTION XCONVERRLOG(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CRLF
	NEXT nX
RETURN cRet


/*/{Protheus.doc} F_EXCEL
@description FUNCAO PARA RETORNAR O RELATORIO DO PROCESSAMENTO EM EXCEL
@author Fernando Rocha
@type function
/*/
Static Function F_EXCEL(lTodos)

	Default lTodos := .F.

	U_BIAMsgRun("Aguarde, gerando planilha...",, {|| ProcExcel(lTodos)  })

Return

Static Function ProcExcel(lTodos)

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := GetSrvProfString("Startpath", "")
	Local cFile := "RESERVAS_PEDIDO_EXCEL-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	Local cWorkSheet := ""
	Local cTable := ""
	Local cDirTmp := AllTrim(GetTempPath())  
	Local I

	Default lTodos := .F.

	cWorkSheet := "Processamento de Reservas de pedidos vinculados a OP"
	cTable := cWorkSheet + " - Data: "+DTOC(dDataBase)+" - Hora: "+SubStr(Time(),1,5)

	oFWExcel := FWMsExcel():New()
	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "OP", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Emissao", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Pedido", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Item", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Produto", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Tp.Seg", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Grupo", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Cod.Cli.", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Nome", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Categoria", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Representante", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Dt.Nece.", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Qtde", 1, 2)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Lote", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Status", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Obs.", 1, 1)

	FOR I := 1 To Len(aWB2)

		If !Empty(aWB2[I][_NP2_LOTE]) .Or. lTodos

			aAux := {}               
			AAdd(aAux, aWB2[I][_NP2_OPNUM	])
			AAdd(aAux, aWB2[I][_NP2_EMISSA	])
			AAdd(aAux, aWB2[I][_NP2_PEDIDO	])
			AAdd(aAux, aWB2[I][_NP2_ITEM	])
			AAdd(aAux, aWB2[I][_NP2_PROD	])
			AAdd(aAux, aWB2[I][_NP2_SEG		])
			AAdd(aAux, aWB2[I][_NP2_GRPVEN	])
			AAdd(aAux, aWB2[I][_NP2_CODCLI	])
			AAdd(aAux, aWB2[I][_NP2_NOMCLI	])
			AAdd(aAux, aWB2[I][_NP2_CATEG	])
			AAdd(aAux, aWB2[I][_NP2_REPRE	])
			AAdd(aAux, aWB2[I][_NP2_DTNECE	])
			AAdd(aAux, aWB2[I][_NP2_SALDO	])
			AAdd(aAux, aWB2[I][_NP2_LOTE	])

			If ( aWB2[I][_NP2_FLAG] == "X" )
				AAdd(aAux,"ERRO")
			ElseIf ( aWB2[I][_NP2_FLAG] == "E" )
				AAdd(aAux,"RESERVADO")
			ElseIf ( aWB2[I][_NP2_FLAG] == "P" )
				AAdd(aAux,"EMPENHADO")
			Else
				AAdd(aAux,aWB2[I][_NP2_FLAG])
			EndIf

			If !Empty(aWB2[I][_NP2_ERRO])
				AAdd(aAux,aWB2[I][_NP2_ERRO])
			Else     
				If ( aWB2[I][_NP2_FLAG] == "X" )
					AAdd(aAux,"ERRO NO PROCESSAMENTO")
				Else                                  
					AAdd(aAux,"SUCESSO")
				EndIf
			EndIf

			oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

		EndIf

	NEXT I

	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()

	If CpyS2T(cDir + cFile, cDirTmp, .T.)

		fErase(cDir + cFile)

		If ApOleClient('MsExcel')

			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()

		EndIf

	Else
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif

	RestArea(aArea)
Return(cDir + cFile)

//CHECKAR SE TEM PEDIDO NAO ATENDIDO ANTERIOR A OP SELECIONA E ALERTAR
Static Function ChkPedAnt()
	Local lRet := .T.
	Local _cOp := ""          
	Local _cProduto := ""  
	Local _cAliasAux
	Local _cListOp := ""
	Local _nRes
	Local I

	FOR I := 1 To Len(aWB1)
		If aWB1[I][_NP1_MARCA]     

			_cOp := aWB1[I][_NP1_OPNUM]
			_cProduto := aWB1[I][_NP1_PROD]

			_cAliasAux := GetNextAlias()
			BeginSql Alias _cAliasAux
				%NOPARSER%

				with tab_op as (
				select DATA = case when C2_YDTDISP <> '' then C2_YDTDISP else C2_DATPRF end 
				, OP = C2_NUM
				from %TABLE:SC2%
				where 
				C2_FILIAL = %XFILIAL:SC2%
				and C2_PRODUTO = %EXP:_cProduto%
				and (select count(*) from %TABLE:PZ0% PZ0 where PZ0_FILIAL = C2_FILIAL and PZ0_OPNUM = C2_NUM and PZ0_CODPRO = C2_PRODUTO and PZ0.D_E_L_E_T_ = '') > 0
				and D_E_L_E_T_ = ''
				)
				,data_op as (select DATA = case when C2_YDTDISP <> '' then C2_YDTDISP else C2_DATPRF end from %TABLE:SC2% where C2_FILIAL = %XFILIAL:SC2% and C2_NUM = %EXP:_cOp% and C2_PRODUTO = %EXP:_cProduto% and D_E_L_E_T_='')
				select OP from tab_op where OP <> %EXP:_cOp% and DATA < isnull((select top 1 DATA from data_op),'')

			EndSql

			(_cAliasAux)->(DbGoTop())		
			If !(_cAliasAux)->(Eof())

				_cListOp := ""
				While !(_cAliasAux)->(Eof())
					If !Empty(_cListOp)
						_cListOp += ","
					EndIf
					_cListOp += (_cAliasAux)->OP
					(_cAliasAux)->(DbSkip())
				EndDo

				_nRes := U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Existem OP's com data anterior com pedidos reservados ainda não atendidos."+CRLF+"OP's: "+_cListOp+CRLF+"FAVOR VERIFICAR, pode estar atendendo pedidos fora da ordem.",{"CONTINUAR","CANCELAR"},,"PEDIDOS NÃO ATENDIDOS EM OP ANTERIOR DESTE PRODUTO")
				If _nRes <> 1
					lRet := .F.
					exit
				EndIf

			EndIf

			(_cAliasAux)->(DbCloseArea())

		EndIf
	NEXT I

	If !lRet
		FOR I := 1 To Len(aWB1)
			aWB1[I][_NP1_MARCA] := .F.
		NEXT I
		ProcMark()
		oWB1:Refresh()
		oDLG:Refresh()
	EndIf

Return(lRet)