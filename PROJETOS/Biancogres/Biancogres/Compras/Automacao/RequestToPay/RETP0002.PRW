#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

User Function RETP0002()
	
	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanel2			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGrid			:= Nil
	Private cCodigo			:= SC3->C3_NUM
	Private cGetContrato	:= cCodigo
	Private oTFolder		:= Nil
	
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
	oWindow:SetTitle("Contrato - faixa de valores do item")
	oWindow:SetEscClose(.T.)
	//oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:SetSize(aCoors[4]*.7, aCoors[3]*.6)
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	oWindow:AddButtons(;
		{;
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
	
	oSayContrato := TSay():Create(oPanel1)
	oSayContrato:cName 		:= "oSayContrato"
	oSayContrato:cCaption 	:= "Contrato: "
	oSayContrato:nLeft 		:= 06
	oSayContrato:nTop 		:= 07
	oSayContrato:nWidth 	:= 100
	oSayContrato:nHeight 	:= 30
	oSayContrato:lReadOnly 	:= .T.
	oSayContrato:cToolTip	:= "Contrato"
	
	oGetContrato 			:= TGet():Create(oPanel1)
	oGetContrato:cName 		:= "oGetContrato"
	oGetContrato:nLeft 		:= 70
	oGetContrato:nTop 		:= 06
	oGetContrato:nWidth 	:= 300
	oGetContrato:nHeight 	:= 20
	oGetContrato:cVariable 	:= "cGetContrato"
	oGetContrato:bSetGet 	:= bSetGet(cGetContrato)
	oGetContrato:bChange 	:= {|| }
	oGetContrato:lHasButton := .T.
	oGetContrato:lReadOnly	:= .T.
	oGetContrato:cToolTip 	:= "Numero Contrato"
	
	
	aHeader 				:= GetHeader()
	aAlterFields			:= {'ZG3_ITEM', 'ZG3_TIPO', 'ZG3_VLINI', 'ZG3_VLFIN', 'ZG3_VALOR'}
	
	oGrid 					:= MsNewGetDados():New( 0, 0, 0, 0,  GD_INSERT + GD_UPDATE + GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+ZG3_SEQ", aAlterFields,, 999, "AllwaysTrue", .T., .T., oPanel2, aHeader, aCols)
	oGrid:oBrowse:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oGrid:oBrowse:lVScroll	:= .T.
	oGrid:oBrowse:lHScroll	:= .T.

	LoadDados()
	
Return

Static Function GetHeader()

	Local aHeader := {}
	Local _oField := TGDField():New()
	
	_oField:AddField("ZG3_SEQ")
	_oField:AddField("ZG3_ITEM")
	_oField:AddField("ZG3_TIPO")
	_oField:AddField("ZG3_VLINI")
	_oField:AddField("ZG3_VLFIN")
	_oField:AddField("ZG3_VALOR")
		
	aHeader := _oField:GetHeader()

Return aHeader

Static Function Gravar(cOper)
	
	If (ValidaGrid(cOper))
		ProcCommit(cOper)	
	EndIf
	
Return

Static Function ValidaGrid(cOper)
	
	Local lRet 			:= .T.
	Local nI			:= 0
	Local aCols 		:= oGrid:aCols
	Local lRet			:= .T.
	
	Local cSeq			:= ""
	Local cItem			:= ""
	Local cTipo			:= ""
	Local nVlIni		:= 0
	Local nVlFin		:= 0
	Local nValor		:= 0
	
	Local cUltItem		:= ''
	Local nUltValFim	:= 0
	Local cLogMsg		:= ''
	
	ASORT(aCols, , , { | x,y | x[1]+cvaltochar(x[3]) < y[1]+cvaltochar(y[3])} )
	
	For nI := 1 To Len(aCols)
		
		cSeq		:= aCols[nI][1]
		cItem		:= aCols[nI][2]
		cTipo		:= aCols[nI][3]
		nVlIni		:= aCols[nI][4]
		nVlFin		:= aCols[nI][5]
		nValor		:= aCols[nI][6]
		
	
		If (aCols[nI, Len(aCols[nI])] == .F.)	
			
			
			If (nVlFin < nVlIni)
				cLogMsg += "<p>Valor final: "+cvaltochar(nVlIni)+" do item: "+cItem+ ", deve ser maior que o inicial: "+cvaltochar(nVlFin)+". Linha: "+cvaltochar(nI)+"</p>" 
			EndIf
			
			If (!Empty(cUltItem) .And. AllTrim(cUltItem) == cItem)
				If (nVlIni < nUltValFim)
					cLogMsg += "<p>Valor inicial: "+cvaltochar(nVlIni)+" do item: "+cItem+ ", deve ser maior do que anterior: "+cvaltochar(nUltValFim)+". Linha: "+cvaltochar(nI)+"</p>" 
				EndIf
				
				If ((nVlIni-1) != nUltValFim)
					cLogMsg += "<p>Valor inicial: "+cvaltochar(nVlIni)+" do item: "+cItem+ ", a soma de 1 do anterior: "+cvaltochar(nUltValFim)+". Linha: "+cvaltochar(nI)+"</p>" 
				EndIf
				
			EndIf
					
			cUltItem 	:= cItem
			nUltValFim	:= nVlFin
						
		EndIf		
	Next nI
	
	If (!Empty(cLogMsg))
		MsgAlert(cLogMsg, '')
		Return .F.
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

Static Function ProcDeleta()
	
	Local lRet			:= .T.
	
	DbSelectArea("ZG3")
	ZG3->(DbSetOrder(1))
	ZG3->(DbSeek(xFilial("ZG3")+cCodigo))
	
	While (!ZG3->(Eof()) .And. AllTrim(ZG3->ZG3_FILIAL)+AllTrim(ZG3->ZG3_NUMERO) == AllTrim(xFilial('ZG3'))+AllTrim(cCodigo))
		
		RecLock("ZG3",.F.)
			ZG3->(DbDelete())
		ZG3->(MsUnlock())
			
		ZG3->(DbSkip())
	EndDo
							
Return lRet


Static Function ProcNovo()
	
	Local nI			:= 0
	Local aCols 		:= oGrid:aCols
	Local lRet			:= .T.
	Local cSeq			:= ""
	Local cItem			:= ""
	Local cTipo			:= ""
	Local nVlIni		:= 0
	Local nVlFin		:= 0
	Local nValor		:= 0
	
	For nI := 1 To Len(aCols)
		
		cSeq		:= aCols[nI][1]
		cItem		:= aCols[nI][2]
		cTipo		:= aCols[nI][3]
		nVlIni		:= aCols[nI][4]
		nVlFin		:= aCols[nI][5]
		nValor		:= aCols[nI][6]
		
		cChave 		:= xFilial("ZG3")+cCodigo+cSeq+cItem
		
		If (aCols[nI, Len(aCols[nI])] == .F.)	
			
			DbSelectArea("ZG3")
			ZG3->(DbSetOrder(2))
			
			If (ZG3->(DbSeek(cChave)))
				RecLock("ZG3", .F.)
				ZG3->ZG3_SEQ		:= cSeq
				ZG3->ZG3_ITEM		:= cItem
				ZG3->ZG3_TIPO		:= cTipo
				ZG3->ZG3_VLINI		:= nVlIni
				ZG3->ZG3_VLFIN		:= nVlFin
				ZG3->ZG3_VALOR		:= nValor
				ZG3->(MsUnlock())
			Else
				RecLock("ZG3", .T.)
				ZG3->ZG3_FILIAL		:= xFilial("ZG3")
				ZG3->ZG3_NUMERO		:= cCodigo
				ZG3->ZG3_SEQ		:= cSeq
				ZG3->ZG3_ITEM		:= cItem
				ZG3->ZG3_TIPO		:= cTipo
				ZG3->ZG3_VLINI		:= nVlIni
				ZG3->ZG3_VLFIN		:= nVlFin
				ZG3->ZG3_VALOR		:= nValor
				ZG3->(MsUnlock())
			EndIf
		Else
			DbSelectArea("ZG3")
			ZG3->(DbSetOrder(2))
			
			If (ZG3->(DbSeek(cChave)))
				RecLock("ZG3",.F.)
					ZG3->(DbDelete())
				ZG3->(MsUnlock())	
			EndIf
		EndIf		
	Next nI
			
Return lRet

Static Function LoadDados()
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| ProcLoad() })
Return

Static Function ProcLoad()

	Local aArea			:= GetArea()
	Local aDados		:= {}
	
	If (!Empty(cCodigo))
		DbSelectArea("ZG3")
		ZG3->(DbSetOrder(1))
		ZG3->(DbSeek(xFilial("ZG3")+cCodigo))
		
		While (!ZG3->(Eof()) .And. AllTrim(ZG3->ZG3_FILIAL)+AllTrim(ZG3->ZG3_NUMERO) == AllTrim(xFilial('ZG3'))+AllTrim(cCodigo))
			
			Aadd(aDados, {ZG3->ZG3_SEQ, ZG3->ZG3_ITEM, ZG3->ZG3_TIPO, ZG3->ZG3_VLINI, ZG3->ZG3_VLFIN, ZG3->ZG3_VALOR, .F.})
			ZG3->(DbSkip())
			
		EndDo
	
	EndIf
	
	If (Len(aDados))
		oGrid:SetArray(aDados, .T.)
		oGrid:oBrowse:Refresh()
	EndIf
	
	RestArea(aArea)
	
Return
