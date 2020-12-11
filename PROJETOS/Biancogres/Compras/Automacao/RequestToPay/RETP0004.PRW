#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

User Function RETP0004(_cNum)
	
	Local nI			:= 0
	Local aArea 		:= GetArea()
	Local oCPStruct		:= TCPStruct():New()
	Local cNumSC3		:= "" 
	Local lOk			:= .T.
	
	Conout('Executando função: RETP0004')	
	
	If (!Empty(_cNum))
		
		oLoadPC 			:= TLoadPedidoCompra():New()
		oPCResulStruct		:= oLoadPC:GetSC7(_cNum)
		
		If (oPCResulStruct:lOk)
			
			cNumSC3					:= GETSXENUM('SC3', 'C3_NUM')
			oCPStruct:cNumero		:= cNumero
			oCPStruct:dEmissao		:= dDataBase
			oCPStruct:cFornece		:= oPCResulStruct:oResult:cFornece
			oCPStruct:cLoja			:= oPCResulStruct:oResult:cLoja
			oCPStruct:cCond			:= oPCResulStruct:oResult:cCond
			oCPStruct:cContato		:= oPCResulStruct:oResult:cContato
			oCPStruct:cTipoFrete	:= oPCResulStruct:oResult:cTipoFrete
			oCPStruct:cMoeda		:= oPCResulStruct:oResult:cMoeda
			
			For nI := 1 To oPCResulStruct:oResult:oPcItens:GetCount()
				
				oItem := oPCResulStruct:oResult:oPcItens:GetItem(nI)
					
				oCPItemStruct	 			:= TCPItemStruct():New()
		
				oCPItemStruct:cItem	        := oItem:cItem
				oCPItemStruct:cCodTag       := oItem:cCodTag
				oCPItemStruct:cCodProd      := oItem:cCodProd 
				oCPItemStruct:cLocal        := oItem:cLocal	
				oCPItemStruct:nQuant		:= oItem:nQuant 	
				oCPItemStruct:nPreco	 	:= oItem:nPreco 
				oCPItemStruct:nTotal	 	:= oItem:nTotal
				oCPItemStruct:cTES          := oItem:cTES   	
				
				oCPItemStruct:cUM			:= oItem:cUM
				oCPItemStruct:cSegUM		:= oItem:cSegUM
				oCPItemStruct:cQtdSegUM		:= oItem:cQtdSegUM
				oCPItemStruct:cCC			:= oItem:cCC
				oCPItemStruct:cClVl			:= oItem:cClVl
					
				oCPStruct:oItens:Add(oCPItemStruct)
	
			Next nI
			
			
			oCP 			:= TCParceria():New()
			oCPResulStruct	:= oCP:Execute(oCPStruct)
			
			If (oCPResulStruct:lOk)
				MsgAlert('<p style="color:green">Contrato Parceria, Numero: '+cNumSC3+' inserido com sucesso.</p>', 'Sucesso')
				ConfirmSX8()
			Else
				MsgAlert('<p style="color:red">'+oCPResulStruct:cMensagem+'</p>', 'Erro')
				lOk := .F.
			EndIf
			
		Else
			MsgAlert('<p style="color:red">'+oPCResulStruct:cMensagem+'</p>', 'Erro')
			lOk := .F.
		EndIf
	
	Else
	
		MsgAlert('<p style="color:red">Contrato Parceria não informado.</p>', 'Erro')
		lOk := .F.
			
	EndIf
	
	
	RestArea(aArea)
	
Return lOk