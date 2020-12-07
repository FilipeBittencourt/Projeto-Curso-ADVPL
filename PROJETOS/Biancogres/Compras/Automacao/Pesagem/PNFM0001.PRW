#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function PNFM0001()

	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanel2			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGridNFS		:= Nil
	Private oGridCTe		:= Nil
	Private aFields			:= {'ZLL_CHNFE'}
	Private aFieldsNFS		:= {'ZLL_NUMERO', 'ZLL_FORNECE', 'ZLL_LOJA', 'ZLL_EMISSAO'}
	Private cGetNota 		:= Space(44)
	Private cCodigo			:= Z11->Z11_PESAGE
	Private lFreteServico	:= .F.
	Private oTFolder		:= Nil
	
	//TODO colocar trava apenas quando tiver saida
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
	oWindow:SetTitle("Entrada de NF de Massa")
	oWindow:SetEscClose(.T.)
	//oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:SetSize(aCoors[4]*.7, aCoors[3]*.6)
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	oWindow:AddButtons(;
		{;
		{'', 'Enviar E-mail', {|| EnviarMail() }, '','', .T., .T.},;
		{'', 'Excluir', {|| Processa( {|| Gravar('E')},"Aguarde...","Excluindo Registros...") }, '','', .T., .T.};
		};
	)
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
	
	oLayer:AddLine("LINHA_1", 30, .F.)
	oLayer:AddCollumn('COLUNA_1', 100, .T., 'LINHA_1')
	oLayer:AddWindow('COLUNA_1', 'JANELA_1', '', 100, .F. ,.T.,, 'LINHA_1', { || })	
	oPanel1 := oLayer:GetWinPanel('COLUNA_1', 'JANELA_1', 'LINHA_1')
	
	oLayer:AddLine("LINHA_2", 70, .F.)
	oLayer:AddCollumn('COLUNA_2', 100, .T., 'LINHA_2')
	oLayer:AddWindow('COLUNA_2', 'JANELA_2', '', 100, .F. ,.T.,, 'LINHA_2', { || })	
	oPanel2 := oLayer:GetWinPanel('COLUNA_2', 'JANELA_2', 'LINHA_2')
	
Return


Static Function CreateView()

	Local aHeader		:= {}
	Local aCols			:= {}
	Local aAlterFields	:= {}
	
	Local aHeaderNFS	:= {}
	Local aColsNFS		:= {}
	Local aAlterNFS		:= {}
	
	Local aTFolder 		:= { 'CTe', 'Nota de serviço'}
	
	
	oTFolder := TFolder():New( 0,0, aTFolder,, oPanel2,,,,.T.,, 392, 90 )
	
	//oTFolder:HidePage(1)
	//oTFolder:aEnable(2, .F.)
	
	oSayNota := TSay():Create(oPanel1)
	oSayNota:cName 		:= "oSayNota"
	oSayNota:cCaption 	:= "Chave NFe: "
	oSayNota:nLeft 		:= 06
	oSayNota:nTop 		:= 07
	oSayNota:nWidth 	:= 100
	oSayNota:nHeight 	:= 30
	oSayNota:lReadOnly 	:= .T.
	oSayNota:cToolTip	:= "Chave NFe"
	
	oGetNota 			:= TGet():Create(oPanel1)
	oGetNota:cName 		:= "oGetNota"
	oGetNota:nLeft 		:= 70
	oGetNota:nTop 		:= 06
	oGetNota:nWidth 	:= 300
	oGetNota:nHeight 	:= 20
	oGetNota:cVariable 	:= "cGetNota"
	oGetNota:bSetGet 	:= bSetGet(cGetNota)
	oGetNota:bChange 	:= {|| }
	oGetNota:lHasButton := .T.
	oGetNota:cToolTip 	:= "Chave NFe"
	
	/*oChk 					:= TCheckBox():Create(oPanel1)
	oChk:cName 				:= 'oChkFreteServico'
	oChk:cCaption			:= "O Frete é Nota de Serviço?"
	oChk:nLeft 				:= 450
	oChk:nTop 				:= 07	
	oChk:nWidth 			:= 400
	oChk:nHeight 			:= 30
	oChk:lShowHint			:= .T.
	oChk:cVariable 			:= "lFreteServico"
	oChk:bSetGet 			:= bSetGet(lFreteServico)
	oChk:lVisibleControl	:= .T.
	oChk:bChange 			:= {|| UpdateFolder()}
	*/
	
		
	aHeader 				:= GetHeaderCTe()
	aAlterFields			:= AClone(aFields)

	oGridCTe 					:= MsNewGetDados():New( 0, 0, 0, 0,  GD_INSERT + GD_UPDATE + GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1", aAlterFields,, 999, "AllwaysTrue", .T., .T., oTFolder:aDialogs[1], aHeader, aCols)
	oGridCTe:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
	oGridCTe:oBrowse:lVScroll	:= .T.
	oGridCTe:oBrowse:lHScroll	:= .T.

	
	aHeaderNFS 					:= GetHeaderNFS()
	aAlterNFS					:= AClone(aFieldsNFS)
	
	oGridNFS 					:= MsNewGetDados():New( 0, 0, 0, 0,  GD_INSERT + GD_UPDATE + GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1", aAlterNFS,, 999, "AllwaysTrue", .T., .T., oTFolder:aDialogs[2], aHeaderNFS, aColsNFS)
	oGridNFS:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT
	oGridNFS:oBrowse:lVScroll	:= .T.
	oGridNFS:oBrowse:lHScroll	:= .T.

	LoadDados()
	
	//If (lFreteServico)
	//	oTFolder:SetOption(2)
	//EndIf
	
Return

Static Function UpdateFolder()
	
	If (lFreteServico) 
		oTFolder:SetOption(2)
		oTFolder:Refresh()
	Else
		oTFolder:SetOption(1)
		oTFolder:Refresh()
	EndIf

Return

Static Function GetHeaderCTe()

	Local aHeader := {}
	Local _oField := TGDField():New()

	_oField:AddField("ZLL_CHNFE")
	_oField:FieldName("ZLL_CHNFE"):cTitle	:= "CTe"
		
	aHeader := _oField:GetHeader()

Return aHeader


Static Function GetHeaderNFS()

	Local aHeader := {}
	Local _oField := TGDField():New()
	
	_oField:AddField("ZLL_NUMERO")
	_oField:FieldName("ZLL_NUMERO"):cTitle	:= "Numero"
	_oField:FieldName("ZLL_NUMERO"):cType	:= 'C'
	_oField:FieldName("ZLL_NUMERO"):nSize	:= 9
	
	_oField:AddField("ZLL_FORNECE")
	_oField:FieldName("ZLL_FORNECE"):cTitle	:= "Fornecedor"
	_oField:FieldName("ZLL_FORNECE"):cF3	:= 'SA2'
	_oField:FieldName("ZLL_FORNECE"):cType	:= 'C'
	_oField:FieldName("ZLL_FORNECE"):nSize	:= 6
	
	_oField:AddField("ZLL_LOJA")
	_oField:FieldName("ZLL_LOJA"):cTitle	:= "Loja"
	_oField:FieldName("ZLL_LOJA"):cType		:= 'C'
	_oField:FieldName("ZLL_LOJA"):nSize		:= 2
	
	_oField:AddField("ZLL_EMISSAO")
	_oField:FieldName("ZLL_EMISSAO"):cTitle	:= "Emissão"
	_oField:FieldName("ZLL_EMISSAO"):cType	:= 'D'
	_oField:FieldName("ZLL_EMISSAO"):nSize	:= 8
		
	aHeader := _oField:GetHeader()

Return aHeader

Static Function Gravar(cOper)
	
	If (ValidaGrid(cOper))
		
		
		
		ProcCommit(cOper)
	
	EndIf
	
Return

Static Function ValidaGrid(cOper)
	
	Local lRet := .T.
	
	If (cOper == 'S') //incluir/ Editar
		lRet := NotaTicket()
	EndIf
	
Return lRet


Static Function ProcCommit(cOper)

	Local lRet	:= .T.
	Local aArea	:= GetArea()
	
	Begin Transaction
	
		If (cOper == 'S') //incluir/ Editar
			lRet := ProcNovo()
		Else
			lRet := ProcDeleta()
		EndIf
	
		If (!lRet)
			DisarmTransaction()
		EndIf
		
	End Transaction 	
	
	If (lRet)
		oWindow:OOWNER:End()
	EndIf
	
	RestArea(aArea)		
	
Return(.T.)


Static Function ProcNovo()
	
	Local nI			:= 0
	Local cCte			:= ""
	Local aCols 		:= oGridCTe:aCols
	Local aColsNFS 		:= oGridNFS:aCols
	Local lRet			:= .T.
	Local cListaCte		:= ""
	Local cListaNFS		:= ""
	
	Local cNumDoc		:= ""
	Local cFornece		:= ""
	Local cLoja			:= ""
	Local dDtEmissao	:= ""
	
	Local lEdit	:= .T.
	
	
	///If (lFreteServico)
	//	aCols 		:= {}
	//Else
	//	aColsNFS	:= {}
	//EndIf
	
	
	cListaCte := ""
	
	For nI := 1 To Len(aCols)
		If (aCols[nI, Len(aCols[nI])] == .F.)	
			cCte	:= cvaltochar(aCols[nI][1])
			If (!Empty(cCte))
				
				If (!Empty(cListaCte))
					cListaCte += "|"
				EndIf
				
				cListaCte += cCte
				
			EndIf
		EndIf		
	Next nI
	
	For nI := 1 To Len(aColsNFS)
		If (aColsNFS[nI, Len(aColsNFS[nI])] == .F.)	
			
			cNumDoc		:= AllTrim(aColsNFS[nI][1])
			cFornece	:= aColsNFS[nI][2]
			cLoja		:= aColsNFS[nI][3]
			dDtEmissao	:= aColsNFS[nI][4]
			
			If (;
				!Empty(cNumDoc) 			.And. 	;
				!Empty(cFornece) 			.And. 	;
				!Empty(cLoja) 				.And. 	;
				!Empty(dtos(dDtEmissao))			;
				)
				
				cNumDoc := Right(REPLICATE("0", 9)+cNumDoc, 9)
				
				If (!Empty(cListaNFS))
					cListaNFS += "|"
				EndIf
				
				cListaNFS += cNumDoc+'#'+cFornece+'#'+cLoja+'#'+dtos(dDtEmissao)
				
			EndIf
		EndIf		
	Next nI
	
	
	DbSelectArea("ZLL")
	ZLL->(DbSetOrder(1))
	
	If (ZLL->(DbSeek(xFilial("ZLL")+cCodigo)))
		lEdit := .T.
	Else
		lEdit := .F.
	EndIf
	
	If (lEdit)
		If MsgNoYes("Deseja excluir as informações atuais e realizar uma nova importação?", "Confirma?")
			lRet := ProcDeleta()
			If (!lRet)
				Return .F.
			EndIf
		Else
			Return .T.
		EndIf
	EndIf
	
	If (lEdit)
		RecLock("ZLL", .F.)
	Else
		RecLock("ZLL", .T.)
	EndIf
	
	ZLL->ZLL_FILIAL		:= xFilial("ZLL")
	ZLL->ZLL_CHNFE		:= cGetNota
	ZLL->ZLL_PESAGE		:= cCodigo
	ZLL->ZLL_CHCTE		:= cListaCte 
	ZLL->ZLL_NFSERV		:= cListaNFS
	ZLL->ZLL_FRETSE		:= ''//IIF(lFreteServico, 'S', 'N')
	ZLL->(MsUnlock())
	
	U_BIAMsgRun("Importando a NFe: "+cGetNota+", Aguarde... ",, {|| lRet := U_PNFM0002(cGetNota, cCodigo) })

	If (lRet)
		
		//If MsgNoYes("Deseja realizar a importação dos CTe?", "Confirma?")
			
			For nI := 1 To Len(aCols)
				If (aCols[nI, Len(aCols[nI])] == .F.)	
					cCte	:= cvaltochar(aCols[nI][1])
					If (!Empty(cCte))
						U_BIAMsgRun("Importando a CTe: "+cCte+", Aguarde...",, {|| lRet := U_PNFM0003(cCte) })
						
						If (!lRet)
							Exit
						EndIf
						
					EndIf
				EndIf		
			Next nI
			
		//EndIf
		
				
		//If MsgNoYes("Deseja realizar a importação das notas fiscais de serviço?", "Confirma?")
		
			For nI := 1 To Len(aColsNFS)
				If (aColsNFS[nI, Len(aColsNFS[nI])] == .F.)	
					
					cNumDoc		:= AllTrim(aColsNFS[nI][1])
					cFornece	:= aColsNFS[nI][2]
					cLoja		:= aColsNFS[nI][3]
					dDtEmissao	:= aColsNFS[nI][4]
					
					If (;
						!Empty(cNumDoc) 			.And. 	;
						!Empty(cFornece) 			.And. 	;
						!Empty(cLoja) 				.And. 	;
						!Empty(dtos(dDtEmissao))			;
						)
						
						cNumDoc := Right(REPLICATE("0", 9)+cNumDoc, 9)
						
						U_BIAMsgRun("Importando a NF serviço: "+cNumDoc+'/'+cFornece+'/'+cLoja+", Aguarde...",, {|| lRet := U_PNFM0005(cGetNota, cNumDoc, cFornece, cLoja, dDtEmissao) })
					
						If (!lRet)
							Exit
						EndIf
				
					EndIf
				
				EndIf		
			Next nI	
			
		//EndIf	
				
	EndIf
	
	If (lRet)
		U_BIAMsgRun("Enviando e-mail, Aguarde...",, {|| U_PNFM0007(cCodigo, cGetNota, aCols, aColsNFS) })
	EndIf
			
Return lRet

Static Function EnviarMail()
	
	Local aCols 		:= oGridCTe:aCols
	Local aColsNFS 		:= oGridNFS:aCols
	//If (lFreteServico)
	//	aCols 		:= {}
	//Else
	//	aColsNFS	:= {}
	//EndIf
	
	U_BIAMsgRun("Enviando e-mail, Aguarde...",, {|| U_PNFM0007(cCodigo, cGetNota, aCols, aColsNFS) })
Return

Static Function ProcDeleta()
	
	Local nI			:= 0
	Local lRet			:= .T.
	
	Local cCte			:= ""
	Local cNumDoc		:= ""
	Local cFornece		:= ""
	Local cLoja			:= ""
	Local dDtEmissao	:= ""
	
	Local aList			:= {}
	Local aRegistro		:= {}
	
	DbSelectArea("ZLL")
	ZLL->(DbSetOrder(1))
		
	If (ZLL->(DbSeek(xFilial("ZLL")+cCodigo)))
			
		aList	:= StrTokArr(ZLL->ZLL_CHCTE, '|')
		For nI=1 To Len(aList)
			cCte	:= aList[nI]
			If (!Empty(cCte))
				U_BIAMsgRun("Excluindo a CTe: "+cCte+", Aguarde... ",, {|| lRet := U_PNFM0004(cCte) })
				
				If (!lRet)
					Exit
				EndIf
				
			EndIf
		Next nI
		
		aList	:= StrTokArr(ZLL->ZLL_NFSERV, '|')
		For nI=1 To Len(aList)
			aRegistro := StrTokArr(aList[nI], '#')
			If (Len(aRegistro) == 4)
			
				cNumDoc		:= aRegistro[1]
				cFornece	:= aRegistro[2]
				cLoja		:= aRegistro[3]
				dDtEmissao	:= aRegistro[4]
			
				If (;
					!Empty(cNumDoc) 			.And. 	;
					!Empty(cFornece) 			.And. 	;
					!Empty(cLoja) 				.And. 	;
					!Empty(dDtEmissao)					;
					)
					
					
					U_BIAMsgRun("Excluindo a NF serviço: "+cNumDoc+'/'+cFornece+'/'+cLoja+", Aguarde...",, {|| lRet := U_PNFM0006(cNumDoc, cFornece, cLoja, stod(dDtEmissao)) })
				
					If (!lRet)
						Exit
					EndIf
					
				EndIf
								
			EndIf
		Next nI
		
		If (lRet)
			U_BIAMsgRun("Excluindo a NFe: "+cGetNota+", Aguarde...",, {|| lRet := U_PNFM0004(cGetNota) })
		EndIf
		
		If (lRet)			
			RecLock("ZLL",.F.)
				ZLL->(DbDelete())
			ZLL->(MsUnlock())		
		EndIf
		
	EndIf
						
Return lRet


Static Function LoadDados()
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| ProcLoad() })
Return

Static Function ProcLoad()

	Local aArea			:= GetArea()
	Local aDadosCTe		:= {}
	Local aDadosNFS		:= {}
	Local aList			:= {}
	Local aRegistro		:= {}
	Local nI			:= 0
	
	
	If (!Empty(cCodigo))
		DbSelectArea("ZLL")
		ZLL->(DbSetOrder(1))
		
		If (ZLL->(DbSeek(xFilial("ZLL")+cCodigo)))
			
			cGetNota		:= ZLL->ZLL_CHNFE
			//lFreteServico	:= (ZLL->ZLL_FRETSE == 'S')
			
			aList	:= StrTokArr(ZLL->ZLL_CHCTE, '|')
			For nI=1 To Len(aList)
				Aadd(aDadosCTe, {aList[nI], .F.})
			Next nI
			
			aList	:= StrTokArr(ZLL->ZLL_NFSERV, '|')
			For nI=1 To Len(aList)
				aRegistro := StrTokArr(aList[nI], '#')
				Aadd(aDadosNFS, {aRegistro[1], aRegistro[2], aRegistro[3], stod(aRegistro[4]), .F.})
			Next nI
			
		EndIf
	
	EndIf
	
	If (Len(aDadosCTe))
		oGridCTe:SetArray(aDadosCTe, .T.)
		oGridCTe:oBrowse:Refresh()
	EndIf
	
	If (Len(aDadosNFS))
		oGridNFS:SetArray(aDadosNFS, .T.)
		oGridNFS:oBrowse:Refresh()
	EndIf
	
	RestArea(aArea)
	
Return

Static Function NotaTicket()
	
	Local aCols 		:= oGridCTe:aCols
	Local aColsNFS 		:= oGridNFS:aCols
	
	Local cLogMsg			:= ""
	Local cQuery			:= ""
	Local cAliasTemp		:= GetNextAlias()
	
	Local cChave			:= cGetNota
	Local cTicket			:= cCodigo
	
	//If (lFreteServico)
	//	aCols 		:= {}
	//Else
	//	aColsNFS	:= {}
	//EndIf
	
	cQuery	+= " select D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_YNUMTK from "+RetSQLName("SF1")+" SF1  (nolock) "
	cQuery	+= " JOIN "+RetSQLName("SD1")+" SD1 (nolock) ON F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA = D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA AND SD1.D_E_L_E_T_ = ''"
	cQuery	+= " where "
	cQuery	+= " F1_CHVNFE = '"+cChave+"' "
	cQuery	+= " AND SF1.D_E_L_E_T_ = '' "
	cQuery	+= " AND SD1.D1_YNUMTK <> '"+cTicket+"' "
	cQuery	+= " AND SD1.D1_YNUMTK <> '' "
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	While (!(cAliasTemp)->(EoF()))
		
		cLogMsg += "<p>Doc/Serie: "+(cAliasTemp)->D1_DOC+'/'+(cAliasTemp)->D1_SERIE+", Fornecedor/Loja: "+(cAliasTemp)->D1_FORNECE+'/'+(cAliasTemp)->D1_LOJA+" já atrelado ao ticket: "+(cAliasTemp)->D1_YNUMTK+"</p>"
		
		(cAliasTemp)->(DbSkip())
	EndDo
	
	
	(cAliasTemp)->(DbCloseArea())
	
	If (!Empty(cLogMsg))
		MsgAlert(cLogMsg, '')
		Return .F.
	EndIf
	
	cLogMsg			:= ""
	For nI := 1 To Len(aCols)
		If (aCols[nI, Len(aCols[nI])] == .F.)	
			cCte	:= cvaltochar(aCols[nI][1])
			If (!Empty(cCte))
				cAliasTemp		:= GetNextAlias()
				
				cQuery	:= " select ZLL_PESAGE from "+RetSQLName("ZLL")+" ZLL  (nolock) "
				cQuery	+= " where "
				cQuery	+= " cast(ZLL_CHCTE as varchar(max)) like '%"+cCte+"%' "
				cQuery	+= " AND ZLL.D_E_L_E_T_ = '' "
				cQuery	+= " AND ZLL.ZLL_PESAGE <> '"+cTicket+"' "
				
								
				TcQuery cQuery New Alias (cAliasTemp)
				
				If (!(cAliasTemp)->(EoF()))
					
					cLogMsg += "<p>CTe: "+cCte+" já atrelado ao ticket: "+(cAliasTemp)->ZLL_PESAGE+"</p>"
		
				EndIf
				
				conout(cQuery)
				
				(cAliasTemp)->(DbCloseArea())
				
			EndIf
		EndIf		
	Next nI
	
	If (!Empty(cLogMsg))
		MsgAlert(cLogMsg, '')
		Return .F.
	EndIf		
		
	
Return .T.
