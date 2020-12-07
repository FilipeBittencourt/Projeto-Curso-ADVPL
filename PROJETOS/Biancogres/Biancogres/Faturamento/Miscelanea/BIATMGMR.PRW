#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function BIATMGMR()

	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanel2			:= Nil
	Private oPanel3			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGridAtual		:= Nil
	Private oGridNovo		:= Nil
	Private lMD				:= .F.
	Private oSayTotal		:= Nil
	
	Private aFieldsAtual	:= {"MARK", "ZBM_VEND", "A3_NREDUZ", "ZBM_GRPCLI", "ZBM_FORMAT", "ZBM_QUANT", "ZBM_TOTAL"}
	Private aFieldsNovo		:= {"ZBM_VEND", "A3_NREDUZ", "ZBM_GRPCLI"}
	
	Private cAno			:= SPACE(TAMSX3("ZBM_ANOREF")[1]) 
	Private cVersao			:= SPACE(TAMSX3("ZBM_VERSAO")[1]) 
	Private cRevisa			:= SPACE(TAMSX3("ZBM_REVISA")[1])
	Private cSequen			:= SPACE(TAMSX3("ZBM_SEQUEN")[1]) 
	Private cMesDe			:= SPACE(TAMSX3("ZBM_PERIOD")[1])                                  
	Private cMesAte			:= SPACE(TAMSX3("ZBM_PERIOD")[1])
	Private cMarca			:= SPACE(TAMSX3("ZBM_MARCA")[1])                                  
	Private cCliDe			:= SPACE(TAMSX3("ZBM_GRPCLI")[1])                                  
	Private cCliAte			:= SPACE(TAMSX3("ZBM_GRPCLI")[1])  
	Private cVendDe			:= SPACE(TAMSX3("ZBM_VEND")[1])                                  
	Private cVendAte		:= SPACE(TAMSX3("ZBM_VEND")[1])  
	Private cUF				:= SPACE(TAMSX3("ZBM_ESTADO")[1])                                  
	Private cSeg			:= SPACE(TAMSX3("ZBM_TPSEG")[1])                                  
	
	
	
	LoadModal()
	LoadContainer()
	LoadLayer()
	
	CreateView()

	oWindow:Activate()
	
Return 


Static Function LoadModal()

	Local aCoors := MsAdvSize()

	oWindow := FWDialogModal():New()
	oWindow:SetBackground(.T.)
	oWindow:SetTitle("Transferir meta GMR")
	oWindow:SetEscClose(.T.)
	oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	//oWindow:addButtons({{'', 'Excluir', {|| }, '','', .T., .T.}})
	
	oWindow:AddOKButton({|| Processa( {|| Gravar('S')},"Aguarde...","Gravando Registros...") }, "Salvar")
	oWindow:AddCloseButton({|| oWindow:OOWNER:End()})

Return

Static Function LoadContainer()

	oContainer	:= FWFormContainer():New()
	cItemBox 	:= oContainer:CreateHorizontalBox(100)
	oContainer:Activate(oWindow:GetPanelMain(), .T.)

Return 


Static Function LoadLayer()

	oPanelConteiner := oContainer:GetPanel(cItemBox)	

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(oPanelConteiner, .F., .T.)
	
	oLayer:AddLine("LINHA_1", 20, .F.)
	oLayer:AddCollumn('COLUNA_1', 100, .T., 'LINHA_1')
	oLayer:AddWindow('COLUNA_1', 'JANELA_1', '', 100, .F. ,.T.,, 'LINHA_1', { || })	
	oPanel1 := oLayer:GetWinPanel('COLUNA_1', 'JANELA_1', 'LINHA_1')
	
	oLayer:AddLine("LINHA_2", 80, .F.)
	oLayer:AddCollumn('COLUNA_2', 60, .T., 'LINHA_2')
	oLayer:AddCollumn('COLUNA_3', 40, .T., 'LINHA_2')
	oLayer:AddWindow('COLUNA_2', 'JANELA_2', 'Atual', 100, .F. ,.T.,, 'LINHA_2', { || })	
	oLayer:AddWindow('COLUNA_3', 'JANELA_3', 'Novo', 100, .F. ,.T.,, 'LINHA_2', { || })	
	
	oPanel2 := oLayer:GetWinPanel('COLUNA_2', 'JANELA_2', 'LINHA_2')
	oPanel3 := oLayer:GetWinPanel('COLUNA_3', 'JANELA_3', 'LINHA_2')
	
Return


Static Function CreateView()

	Local aHeader		:= {}
	Local aCols			:= {}
	Local aAlterFields	:= {}
	Local oFont1 		:= TFont():New('Arial',, -16, .T., .T.)
	
	oChk 					:= TCheckBox():Create(oPanel1)
	oChk:cName 				:= 'oChk'
	oChk:cCaption			:= "Marcar/Desmarcar"
	oChk:nLeft 				:= 04
	oChk:nTop 				:= 20	
	oChk:nWidth 			:= 120
	oChk:nHeight 			:= 30
	oChk:lShowHint			:= .T.
	oChk:cVariable 			:= "lMD"
	oChk:bSetGet 			:= bSetGet(lMD)
	oChk:lVisibleControl	:= .T.
	oChk:bChange 			:= {|| MarDesmar()}
	
	oTButton1 := TButton():New( 04, 70,  "Trans. Vendedor", oPanel1, {|| TransVend()}, 60,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 04, 140, "Trans. Cliente", oPanel1, {|| TransCli()}, 60,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 := TButton():New( 04, 210, "Trans. Vend./Cli.", oPanel1, {|| TransVC()}, 60,16,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 := TButton():New( 04, 400, "Limpar Novo", oPanel1, {|| Limpar()}, 60,16,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oSayTotal				:= TSay():Create(oPanel1)
	oSayTotal:cName 		:= "oSayTotal"
	oSayTotal:cCaption 		:= "Total: "
	oSayTotal:nLeft 		:= 600
	oSayTotal:nTop 			:= 18
	oSayTotal:nWidth 		:= 200
	oSayTotal:nHeight 		:= 30
	oSayTotal:lReadOnly 	:= .T.
	oSayTotal:cToolTip		:= "Total"
	oSayTotal:oFont 		:= oFont1
		
	aHeader 					:= GetHeader(aFieldsAtual)
	aAlterFields				:= AClone(aFieldsAtual)

	oGridAtual 					:= MsNewGetDados():New( 0, 0, 0, 0,  , "AllwaysTrue", "AllwaysTrue", "+Field1", aAlterFields,, 999, "AllwaysTrue", .T., .T., oPanel2, aHeader, aCols)
	oGridAtual:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGridAtual:oBrowse:lVScroll	:= .T.
	oGridAtual:oBrowse:lHScroll	:= .T.
	oGridAtual:oBrowse:bLDblClick := {|| BrowserClick() }
	
	aHeader 					:= GetHeader(aFieldsNovo)
	aAlterFields				:= AClone(aFieldsNovo)

	oGridNovo 					:= MsNewGetDados():New( 0, 0, 0, 0,  , "AllwaysTrue", "AllwaysTrue", "+Field1", aAlterFields,, 999, "AllwaysTrue", .T., .T., oPanel3, aHeader, aCols)
	oGridNovo:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGridNovo:oBrowse:lVScroll	:= .T.
	oGridNovo:oBrowse:lHScroll	:= .T.
	
	Filtrar()
		
Return

Static Function BrowserClick()
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	
	If oGridAtual:aCols[oGridAtual:nAt, nPosAMark] == 'WFCHK'
		oGridAtual:aCols[oGridAtual:nAt, nPosAMark] := "WFUNCHK"
	Else
		oGridAtual:aCols[oGridAtual:nAt, nPosAMark] := 'WFCHK'
	EndIf			
	
	SomaTotal()
		
Return

Static Function SomaTotal() 
	
	Local nI 	:= 0
	Local nSoma	:= 0
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	Local nPosATotal	:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_TOTAL"})
	
	If Len(oGridAtual:aCols) > 0
		
		For nI := 1 To Len(oGridAtual:aCols)
			If oGridAtual:aCols[nI, nPosAMark] == 'WFCHK'
				nSoma += oGridAtual:aCols[nI, nPosATotal] 
			EndIf
		Next nI
		
		oSayTotal:SetText("Total: "+TRANSFORM(nSoma, '@E 99,999,999,999.99'))
		oSayTotal:CtrlRefresh()
		
	EndIf

Return()


Static Function MarDesmar() 
	
	Local nI := 0
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})

	If Len(oGridAtual:aCols) > 0
		
		For nI := 1 To Len(oGridAtual:aCols)
			If lMD
				oGridAtual:aCols[nI, nPosAMark] := 'WFCHK'
			Else
				oGridAtual:aCols[nI, nPosAMark] := "WFUNCHK"
			EndIf
		Next nI
			
		oGridAtual:oBrowse:Refresh()
		
		SomaTotal()
		
	EndIf

Return()

Static Function Limpar()
	
	Local nI	:=0
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	Local nPosAVend		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosANome		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosACli		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	Local nPosNVend		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosNNome		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosNCli		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	
	For nI := 1 To Len(oGridAtual:aCols)
		If oGridAtual:aCols[nI, nPosAMark] == 'WFCHK'
			oGridNovo:aCols[nI, nPosNVend]	:= SPACE(TAMSX3("ZBM_VEND")[1])
			oGridNovo:aCols[nI, nPosNNome]	:= SPACE(TAMSX3("A3_NREDUZ")[1])
			oGridNovo:aCols[nI, nPosNCli]	:= SPACE(TAMSX3("ZBM_GRPCLI")[1])
		EndIf
	Next nI
		
	oGridNovo:oBrowse:Refresh()

Return ()


Static Function TransVend() 
	
	Local nI 			:= 0
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	Local nPosAVend		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosANome		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosACli		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	Local nPosNVend		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosNNome		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosNCli		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	
	
	Local aPergsTrans		:= {}
	Local cRefPerTrans		:= 'BIATMGMRTV' + cEmpAnt
	Local cFileNTrans   	:= __cUserID +"_"+ cRefPerTrans
	Local aRetPTrans		:= {""}
	
	Local cCodVend			:= SPACE(TAMSX3("ZBM_VEND")[1]) 
	
	aAdd( aPergsTrans ,{1, "Novo Vendedor:"					,cCodVend  ,"",,"SA3",'.T.',50,.T.})
	
	If ParamBox(aPergsTrans ,"Transferir Vendedor", aRetPTrans,,,,,,,cRefPerTrans,.F.,.T.)
	
		cCodVend	:= aRetPTrans[1]
		
		If !(Empty(cCodVend))
			If Len(oGridAtual:aCols) > 0
				
				For nI := 1 To Len(oGridAtual:aCols)
					If oGridAtual:aCols[nI, nPosAMark] == 'WFCHK'
						
						oGridNovo:aCols[nI, nPosNVend]	:= cCodVend
						oGridNovo:aCols[nI, nPosNNome]	:= Posicione("SA3", 1, xFilial("SA3") + cCodVend, "A3_NREDUZ")
						oGridNovo:aCols[nI, nPosNCli]	:= oGridAtual:aCols[nI, nPosACli]//Clliente
						
					EndIf
				Next nI
					
				oGridNovo:oBrowse:Refresh()
				
			EndIf
		EndIf
		
	EndIf
	
Return()

Static Function TransCli() 
	
	Local nI 				:= 0
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	Local nPosAVend		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosANome		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosACli		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	Local nPosNVend		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosNNome		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosNCli		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	
	
	Local lReplicar			:= .F.
	Local aPergsTrans		:= {}
	Local cRefPerTrans		:= 'BIATMGMRTC' + cEmpAnt
	Local cFileNTrans   	:= __cUserID +"_"+ cRefPerTrans
	Local aRetPTrans		:= {""}
	
	Local cCodCli			:= SPACE(TAMSX3("ZBM_GRPCLI")[1]) 
	
	Local cUFCli			:= ""
	
	aAdd( aPergsTrans ,{1, "Novo Grp. Cli./Cliente:"					,cCodCli  ,"",,"",'.T.',50,.F.})
	
	If ParamBox(aPergsTrans ,"Transferir Grupo Cliente/Cliente", aRetPTrans,,,,,,,cRefPerTrans,.F.,.T.)
	
		cCodCli	:= aRetPTrans[1]
		
		lReplicar := .T.	
		
		If (Empty(cCodCli))
			lReplicar := .F.
			If (MSGYESNO("Replicar Vazio para todos registro(s) selecionado(s)?", "" ))
				lReplicar := .T.	
			EndIf
		Else
		
			If (SUBSTR(cCodCli, 1, 1) == 'C')
				If !(ExistCpo("SA1", SUBSTR(cCodCli, 3), 1))
					MsgInfo("Cliente: "+SUBSTR(cCodCli, 3)+" não encontrado.")
					lReplicar := .F.
				EndIf
				
				cUFCli := Posicione("SA1", 1, xFilial("SA1") + SUBSTR(cCodCli, 3), "A1_EST")
				If lReplicar .And. cUFCli <> cUF
					MsgInfo("A UF do cliente "+SUBSTR(cCodCli, 3)+" diferente do filtro: UF Cliente: "+cUFCli+" <=> UF Filtro: "+cUF+".")
					lReplicar := .F.
				EndIf
				
				
			EndIf
			
			If (SUBSTR(cCodCli, 1, 1) == 'G')
				If !(ExistCpo("ACY", SUBSTR(cCodCli, 3), 1))
					MsgInfo("Grupo Cliente: "+SUBSTR(cCodCli, 3)+" não encontrado.")
					lReplicar := .F.
				EndIf
			EndIf
			
		EndIf
		
		If (lReplicar .And. !Empty(cCodCli) .And. Len(cCodCli) <> 8)
			MsgInfo("Tamanho do campo Grp. Cli./Cliente deve ser 8 caracteres.")
			lReplicar := .F.
		EndIf
		
		If (lReplicar .And. SUBSTR(cCodCli, 1, 1) <> 'C' .And. SUBSTR(cCodCli, 1, 1) <> 'G')
			MsgInfo("Grp. Cli./Cliente devem começar com caracteres 'C' ou 'G', Ex.: C-000000 ou G-0000000.")
			lReplicar := .F.
		EndIf
		
		
		If (lReplicar)
			
			If Len(oGridAtual:aCols) > 0
			
				For nI := 1 To Len(oGridAtual:aCols)
					If oGridAtual:aCols[nI, nPosAMark] == 'WFCHK'
						
						oGridNovo:aCols[nI, nPosNVend] := oGridAtual:aCols[nI, nPosAVend]
						oGridNovo:aCols[nI, nPosNNome] := oGridAtual:aCols[nI, nPosANome]
						oGridNovo:aCols[nI, nPosNCli] := cCodCli
						
					EndIf
				Next nI
					
				oGridNovo:oBrowse:Refresh()
				
			EndIf
		
		EndIf 
		
		
	EndIf
	
Return()

Static Function TransVC() 
	
	Local nI 				:= 0
	Local lReplicar			:= .F.
	Local nPosAMark		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "MARK"})
	Local nPosAVend		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosANome		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosACli		:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	Local nPosNVend		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosNNome		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "A3_NREDUZ"})
	Local nPosNCli		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	

	Local aPergsTrans		:= {}
	Local cRefPerTrans		:= 'BIATMGMRTVC' + cEmpAnt
	Local cFileNTrans   	:= __cUserID +"_"+ cRefPerTrans
	Local aRetPTrans		:= {""}
	
	Local cCodVend			:= SPACE(TAMSX3("ZBM_VEND")[1]) 
	Local cCodCli			:= SPACE(TAMSX3("ZBM_GRPCLI")[1]) 
	
	Local cUFCli			:= ""
	
	aAdd( aPergsTrans ,{1, "Novo Vendedor:"								,cCodVend  ,"",,"SA3",'.T.',50,.T.})
	aAdd( aPergsTrans ,{1, "Novo Grp. Cli./Cliente:"					,cCodCli  ,"",,"",'.T.',50,.F.})
	
	If ParamBox(aPergsTrans ,"Transferir Vendedor/(Grupo Cliente/Cliente)", aRetPTrans,,,,,,,cRefPerTrans,.F.,.T.)
	
		cCodVend	:= aRetPTrans[1]
		cCodCli		:= aRetPTrans[2]
		
		lReplicar := .T.	
		
		If (Empty(cCodCli))
			lReplicar := .F.
			If (MSGYESNO("Replicar Vazio para todos registro(s) selecionado(s)?", "" ))
				lReplicar := .T.	
			EndIf
		Else
		
			If (SUBSTR(cCodCli, 1, 1) == 'C')
				If !(ExistCpo("SA1", SUBSTR(cCodCli, 3), 1))
					MsgInfo("Cliente: "+SUBSTR(cCodCli, 3)+" não encontrado.")
					lReplicar := .F.
				EndIf
				
				cUFCli := Posicione("SA1", 1, xFilial("SA1") + SUBSTR(cCodCli, 3), "A1_EST")
				If lReplicar .And. cUFCli <> cUF
					MsgInfo("A UF do cliente "+SUBSTR(cCodCli, 3)+" diferente do filtro: UF Cliente: "+cUFCli+" <=> UF Filtro: "+cUF+".")
					lReplicar := .F.
				EndIf
				
			EndIf
			
			If (SUBSTR(cCodCli, 1, 1) == 'G')
				If !(ExistCpo("ACY", SUBSTR(cCodCli, 3), 1))
					MsgInfo("Grupo Cliente: "+SUBSTR(cCodCli, 3)+" não encontrado.")
					lReplicar := .F.
				EndIf
			EndIf
			
		EndIf
		
		If (lReplicar .And. !Empty(cCodCli) .And. Len(cCodCli) <> 8)
			MsgInfo("Tamanho do campo Grp. Cli./Cliente deve ser 8 caracteres.")
			lReplicar := .F.
		EndIf
		
		If (lReplicar .And. SUBSTR(cCodCli, 1, 1) <> 'C' .And. SUBSTR(cCodCli, 1, 1) <> 'G')
			MsgInfo("Grp. Cli./Cliente devem começar com caracteres 'C' ou 'G', Ex.: C-000000 ou G-0000000.")
			lReplicar := .F.
		EndIf
		
		
		If (lReplicar)
			If Len(oGridAtual:aCols) > 0
				
				For nI := 1 To Len(oGridAtual:aCols)
					If oGridAtual:aCols[nI, nPosAMark] == 'WFCHK'
						
						oGridNovo:aCols[nI, nPosNVend]	:= cCodVend
						oGridNovo:aCols[nI, nPosNNome]	:= Posicione("SA3", 1, xFilial("SA3") + cCodVend, "A3_NREDUZ")
						oGridNovo:aCols[nI, nPosNCli]	:= cCodCli
						
					EndIf
				Next nI
					
				oGridNovo:oBrowse:Refresh()
				
			EndIf
		EndIf
		
	EndIf
	
Return()


Static Function Filtrar()
	
	Local nPos				:= 0
	Private aPergs			:= {}
	Private cRefPer		  	:= 'BIATMGMR' + cEmpAnt
	Private cFileName    	:= __cUserID +"_"+ cRefPer

	Private aRetPerg		:= {"","","", "","", "","", "","", "","", ""}
	
	Private aSeg			:= {'T=Todos','R=Revenda','E=Engenharia','H=HomeCenter','X=Exportação'}                                                                                
	Private aMeses			:= {;
								'01=Janeiro',;
								'02=Fevereiro',;
								'03=Março',;
								'04=Abril',;
								'05=Maio',;
								'06=Junho',;
								'07=Julho',;
								'08=Agosto',;
								'09=Setembro',;
								'10=Outubro',;
								'11=Novembro',;
								'12=Dezembro';
								}    
	
	aAdd( aPergs ,{1, "Versão:"					,cVersao  ,"",,"ZB5",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Revisao:"				,cRevisa  ,"",,"",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Ano:"					,cAno  ,"",,"",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Sequencia:"				,cSequen  ,"",,"",'.T.',50,.T.})
	
	aAdd( aPergs ,{2, "Mês de:"					,cMesDe  , aMeses, 50, ".T.",.T.})
	aAdd( aPergs ,{2, "Mês até:"				,cMesAte  ,aMeses, 50, ".T.",.T.})
	
	aAdd( aPergs ,{1, "Marca:"					,cMarca  ,"",,"Z37",'.T.',50,.T.})
	aAdd( aPergs ,{1, "Grp. Cli./Cliente de:"	,cCliDe  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1, "Grp. Cli./Cliente até:"	,cCliAte  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1, "Vendedor de:"			,cVendDe  ,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{1, "Vendedor até:"			,cVendAte  ,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{2, "Segmento:"				,cSeg, aSeg, 50, ".T.",.T.})
	aAdd( aPergs ,{1, "UF"						,cUF  ,"",,"",'.T.',50,.T.})
	
	If !ParamBox(aPergs ,"Filtro -  Transferir meta GMR", aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nPos	:= 1
	cVersao				:= ParamLoad(cFileName,,nPos++ 	, cVersao)
	cRevisa				:= ParamLoad(cFileName,,nPos++ 	, cRevisa)
	cAno				:= ParamLoad(cFileName,,nPos++ 	, cAno)
	cSequen				:= ParamLoad(cFileName,,nPos++ 	, cSequen)
	
	cMesDe				:= ParamLoad(cFileName,,nPos++ 	, cMesDe)
	cMesAte				:= ParamLoad(cFileName,,nPos++ 	, cMesAte)
	
	cMarca				:= ParamLoad(cFileName,,nPos++ 	, cMarca)
	 
	cCliDe				:= ParamLoad(cFileName,,nPos++ 	, cCliDe) 
	cCliAte 			:= ParamLoad(cFileName,,nPos++ 	, cCliAte) 
	cVendDe				:= ParamLoad(cFileName,,nPos++ 	, cVendDe) 
	cVendAte 			:= ParamLoad(cFileName,,nPos++ 	, cVendAte)
	cSeg				:= ParamLoad(cFileName,,nPos++ 	, cSeg) 
	cUF 				:= ParamLoad(cFileName,,nPos++ 	, cUF)
	
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| LoadDados() })
			
Return 

Static Function LoadDados()
	
	Local cQuery			:= ""
	Local cAliasTmp			:= GetNextAlias()
	Local aDadosAtual		:= {}
	Local aDadosNovo		:= {}
	Local aLinhaAtual		:= {}
	Local aLinhaNovo		:= {}
	
	cQuery := " SELECT ZBM_VEND, ZBM_GRPCLI, ZBM_FORMAT, ZBM_QUANT=SUM(ZBM_QUANT), ZBM_TOTAL=SUM(ZBM_TOTAL),								"
	cQuery += " A3_NOME=(SELECT TOP 1 A3_NREDUZ FROM " + RetSqlName("SA3") + " SA3 WHERE ZBM_VEND = SA3.A3_COD	AND SA3.D_E_L_E_T_= '') 	"
	cQuery += "   FROM " + RetSqlName("ZBM") + " ZBM 																						"
	cQuery += "   WHERE ZBM_FILIAL = '" + xFilial("ZBM") + "' 							 							"
	
	cQuery += "    AND ZBM_VERSAO = '" + cVersao + "' 																"
	cQuery += "    AND ZBM_REVISA = '" + cRevisa + "' 																"
	cQuery += "    AND ZBM_ANOREF = '" + cAno + "' 																	"
	cQuery += "    AND ZBM_SEQUEN = '" + cSequen + "' 																	"
	
	
	cQuery += "    AND ZBM_PERIOD BETWEEN 	'" + cMesDe + "' 	AND '" + cMesAte + "'								"
	cQuery += "    AND ZBM_VEND BETWEEN 	'" + cVendDe + "'	AND '" + cVendAte + "'								"
	cQuery += "    AND ZBM_GRPCLI BETWEEN 	'" + cCliDe + "' 	AND '" + cCliAte + "'								"
	
	cQuery += "    AND ZBM_MARCA = 	'" + cMarca + "'									 							"
	
	If(cSeg <> 'T')
		cQuery += "    AND ZBM_TPSEG = 	'" + cSeg + "'		 														"
	EndIf
	
	If(!Empty(cUF))
		cQuery += "    AND ZBM_ESTADO = '" + cUF + "' 																"
	EndIf
	
	
	cQuery += "    AND ZBM.D_E_L_E_T_ = '' 																			"
	
	cQuery += "  GROUP BY ZBM_VEND, ZBM_GRPCLI, ZBM_FORMAT															"
	cQuery += "  ORDER BY ZBM_VEND, ZBM_GRPCLI, ZBM_FORMAT															"
	
	TcQuery cQuery New Alias (cAliasTmp)
	
	While !(cAliasTmp)->(Eof()) 
		
		aLinhaAtual := {;
					'WFUNCHK',;
					(cAliasTmp)->ZBM_VEND,;
					(cAliasTmp)->A3_NOME,;
					(cAliasTmp)->ZBM_GRPCLI,;
					(cAliasTmp)->ZBM_FORMAT,;
					(cAliasTmp)->ZBM_QUANT,;
					(cAliasTmp)->ZBM_TOTAL,;
					.F.;
				}
	
		aLinhaNovo := {;
					SPACE(TAMSX3("ZBM_VEND")[1]),;
					SPACE(TAMSX3("A3_NREDUZ")[1]),;
					SPACE(TAMSX3("ZBM_GRPCLI")[1]),;
					.F.;
				} 
		
		Aadd(aDadosAtual, aLinhaAtual)
		Aadd(aDadosNovo, aLinhaNovo)
		
		(cAliasTmp)->(DbSkip())
	
	EndDo
	
	(cAliasTmp)->(DbCloseArea())
	
	oGridAtual:SetArray(aDadosAtual, .T.)
	oGridAtual:oBrowse:Refresh()
	
	oGridNovo:SetArray(aDadosNovo, .T.)
	oGridNovo:oBrowse:Refresh()

Return

Static Function GetHeader(aFields)

	Local aHeader	:= {}
	Local _oField	:= TGDField():New()
	Local nI		:= 0
	
	For nI=1 To Len(aFields)
		_oField:AddField(aFields[nI])
		_oField:FieldName(aFields[nI]):lObrigat	:= .F.
		
		
		If (aFields[nI] == "MARK")
			_oField:FieldName("MARK"):cTitle := "Marcar"
			_oField:FieldName("MARK"):cPict := "@BMP"
		EndIf
		
	Next nI
	
	aHeader := _oField:GetHeader()

Return aHeader

Static Function Gravar(cOper)
	
	If (ValidaGrid())
		ProcCommit(cOper)
	EndIf
	
Return

Static Function ValidaGrid()
		
Return .T.


Static Function ProcCommit(cOper)

	Local nI			:= 0
	Local cQuery 		:= ""
	Local cAliasTmp		:= Nil
	
	Local cCodAVend		:= ""
	Local cCodAGrpCli	:= ""
	Local cCodNVend		:= ""
	Local cCodNGrpCli	:= ""
	
	Local cCodFormat	:= ""
	
	Local nPosAFormat	:= aScan(oGridAtual:aHeader,	{|x| AllTrim(x[2]) == "ZBM_FORMAT"})
	Local nPosAVend		:= aScan(oGridAtual:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosACli		:= aScan(oGridAtual:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	
	Local nPosNVend		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_VEND"})
	Local nPosNCli		:= aScan(oGridNovo:aHeader,		{|x| AllTrim(x[2]) == "ZBM_GRPCLI"})
	
	
	Begin Transaction
		
		For nI := 1 To Len(oGridAtual:aCols)
			
			cCodAVend	:= oGridAtual:aCols[nI, nPosAVend]
			cCodAGrpCli	:= oGridAtual:aCols[nI, nPosACli]
			cCodFormat	:= oGridAtual:aCols[nI, nPosAFormat]
			
			cCodNVend	:= oGridNovo:aCols[nI, nPosNVend]
			cCodNGrpCli	:= oGridNovo:aCols[nI, nPosNCli]
			
			If (!Empty(cCodNVend))
			
				cQuery := " SELECT ID=R_E_C_N_O_ FROM " + RetSqlName("ZBM") + " WHERE										"
				cQuery += " D_E_L_E_T_ 	= 			''																		"
				cQuery += " AND ZBM_FILIAL  = 			'"+xFilial("ZBM")+"'												"
				cQuery += " AND ZBM_VERSAO 	= 			'"+cVersao+"'														"
				cQuery += " AND ZBM_REVISA 	= 			'"+cRevisa+"'														"
				cQuery += " AND ZBM_ANOREF	= 			'"+cAno+"'															"
				cQuery += " AND ZBM_SEQUEN 	= 			'"+cSequen+"'														"
				cQuery += " AND ZBM_MARCA 	= 			'"+cMarca+"'														"
				cQuery += " AND ZBM_VEND 	= 			'"+cCodAVend+"'														"
				cQuery += " AND ZBM_GRPCLI 	= 			'"+cCodAGrpCli+"'													"
				
				If(cSeg <> 'T')
					cQuery += " AND ZBM_TPSEG	= 			'"+cSeg+"'														"
				EndIf
				
				cQuery += " AND ZBM_ESTADO	= 			'"+cUF+"'															"
				cQuery += " AND ZBM_FORMAT 	= 			'"+cCodFormat+"'													"
				cQuery += " AND ZBM_PERIOD BETWEEN 	'" + cMesDe + "' 	AND '" + cMesAte + "'								"
	
				cAliasTmp := GetNextAlias()
				TcQuery cQuery New Alias (cAliasTmp)
				
				While !(cAliasTmp)->(Eof()) 
					
					DbSelectArea("ZBM")
					ZBM->(DbSetOrder(0))
					ZBM->(DbGoto((cAliasTmp)->ID))  
					
					If (!ZBM->(Eof()))
						
						//log campos alterados
						Reclock("ZLM",.T.)
							ZLM->ZLM_FILIAL	:= xFilial('ZLM')
							ZLM->ZLM_ID		:= cvaltochar((cAliasTmp)->ID)
							ZLM->ZLM_CAMPO	:= 'ZBM_VEND'
							ZLM->ZLM_VALOR	:= ZBM->ZBM_VEND
						ZLM->(MsUnlock())
						
						Reclock("ZLM",.T.)
							ZLM->ZLM_FILIAL	:= xFilial('ZLM')
							ZLM->ZLM_ID		:= cvaltochar((cAliasTmp)->ID)
							ZLM->ZLM_CAMPO	:= 'ZBM_GRPCLI'
							ZLM->ZLM_VALOR	:= ZBM->ZBM_GRPCLI
						ZLM->(MsUnlock())
						///fim logs
						
						Reclock("ZBM",.F.)
							ZBM->ZBM_VEND	:= cCodNVend
							ZBM->ZBM_GRPCLI	:= cCodNGrpCli
						ZBM->(MsUnlock())
						
					EndIf
					
					(cAliasTmp)->(DbSkip())
				
				EndDo
				
				(cAliasTmp)->(DbCloseArea())
			
			EndIf
			
		Next nI
					
	End Transaction 	
	
	oWindow:OOWNER:End()
	
Return(.T.)