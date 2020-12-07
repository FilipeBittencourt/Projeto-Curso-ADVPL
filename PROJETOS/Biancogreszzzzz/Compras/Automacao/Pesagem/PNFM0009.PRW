#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0009(_cNum, _cItem, lJob)
	
	Local lRet		:= .T.
	Local _nQuant	:= 10
	Default _cItem	:= ''
	Default lJob	:= .F.
		
	RpcSetEnv('01', '01', "FACILE", "TESTE02")
		
	If (!Empty(_cNum))
		
		oLoadPC 			:= TLoadPedidoCompra():New()
		oPCResulStruct		:= oLoadPC:GetSC7(_cNum, _cItem)
		
		If (oPCResulStruct:lOk)
			
			oPCResulStruct:oResult:cNumero	:= GetNumSC7()
			oPCResulStruct:oResult:dEmissao	:= dDataBase
			
			If (oPCResulStruct:oResult:oPcItens:GetCount() == 1)
				oPCResulStruct:oResult:oPcItens:GetItem(1):nQuant := _nQuant
			EndIf
			
			oPc 			:= TPedidoCompra():New()
			oPCResulStruct	:= oPc:Execute(oPCResulStruct:oResult, .T.)
			
			If (oPCResulStruct:lOk)
				MsgAlert('<p style="color:green">Pedido inserido com sucesso.</p>', 'Sucesso')
			Else
				MsgAlert('<p style="color:red">'+oPCResulStruct:cMensagem+'</p>', 'Erro')
				lRet := .F.
			EndIf
		Else
			MsgAlert('<p style="color:red">'+oPCResulStruct:cMensagem+'</p>', 'Erro')
			lRet := .F.
		EndIf
	
	Else
	
		MsgAlert('<p style="color:red">Numero do pedido informada.</p>', 'Erro')
		lRet := .F.
			
	EndIf
				
Return lRet