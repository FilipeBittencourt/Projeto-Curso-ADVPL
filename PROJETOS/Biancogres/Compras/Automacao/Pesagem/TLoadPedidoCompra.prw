#Include "TOTVS.CH"
#Include "Protheus.CH"

Class TLoadPedidoCompra from LongClassName
	
	Public Data oPCResulStruct
	
	Public Method New() Constructor

	Public Method GetSC7()
		
EndClass

Method New() Class TLoadPedidoCompra
	
Return

Method GetSC7(cNum, cItem) Class TLoadPedidoCompra
	
	Local oPCStruct			:= TPCStruct():New()
	Local oPCResulStruct 	:= TPCResultStruct():New()
	Local lOk				:= .T.
	Local cMsgLog			:= ""
	Local bValid			:= {|| }
	Default cItem 			:= ""
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	
	cNum 	:= PADR(cNum, TamSx3("C7_NUM")[1])
	
	bValid	:= {|| SC7->C7_FILIAL+SC7->C7_NUM == xFilial('SC7')+cNum }
	
	If (!Empty(cItem))
		cItem	:= PADR(cItem, TamSx3("C7_ITEM")[1])
		bValid	:= {|| SC7->C7_FILIAL+SC7->C7_NUM+SC7->C7_ITEM == xFilial('SC7')+cNum+cItem }
	EndIf
		
	If SC7->(DbSeek(xFilial('SC7')+cNum+cItem))
		
		//oPCStruct:cNumero		:= ""
		//oPCStruct:dEmissao	:= ""
		oPCStruct:cFornece		:= SC7->C7_FORNECE
		oPCStruct:cLoja			:= SC7->C7_LOJA
		oPCStruct:cCond			:= SC7->C7_COND
		oPCStruct:cContato		:= SC7->C7_CONTATO
		oPCStruct:cTipoFrete	:= SC7->C7_TPFRETE
		oPCStruct:cMoeda		:= SC7->C7_MOEDA
		
		While ;
				!(SC7->(Eof())) .And. ; 
				Eval(bValid)
			
			oPCItemStruct	 			:= TPCItemStruct():New()
			
			oPCItemStruct:cNumSc        := SC7->C7_NUMSC
			oPCItemStruct:cItemSc       := SC7->C7_ITEMSC
			oPCItemStruct:nQuantSc		:= SC7->C7_QTDSOL 	
			oPCItemStruct:cCodTag       := SC7->C7_CODTAB
			oPCItemStruct:cCodProd      := SC7->C7_PRODUTO 
			oPCItemStruct:cLocal        := SC7->C7_LOCAL	
			oPCItemStruct:cDescProd     := SC7->C7_DESCRI 	
			oPCItemStruct:nQuant		:= SC7->C7_QUANT 	
			oPCItemStruct:nPreco	 	:= SC7->C7_PRECO 
			oPCItemStruct:nTotal	 	:= SC7->C7_TOTAL
			oPCItemStruct:cTES          := SC7->C7_TES	
			oPCItemStruct:cTransp		:= SC7->C7_YTRANSP
				
			oPCStruct:oPcItens:Add(oPCItemStruct)
				
			SC7->(DbSkip())	 	
		EndDo
	
	Else
		
		lOk			:= .F.
		cMsgLog 	:= "[Pedido Numero: "+cNum+"] => não encontrado."
		
	EndIf
		
	If (lOk)
		oPCResulStruct:Add(lOk, cMsgLog, oPCStruct)
	Else
		oPCResulStruct:Add(lOk, cMsgLog, Nil)
	EndIf
	
	::oPCResulStruct := oPCResulStruct

Return(oPCResulStruct)