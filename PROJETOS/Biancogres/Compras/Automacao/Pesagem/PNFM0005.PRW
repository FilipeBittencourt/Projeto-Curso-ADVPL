#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0005(cChave, cNumero, cFornece, cLoja, dEmissao, nQuantidade, nValor, cNatureza, cTes, cCodNFe, nAliqISS, lJob)
	
	Local lRet			:= .T.
	Default	nValor 		:= 0
	Default cNatureza	:= "" 
	Default cTes		:= ""
	Default cChaveNFs	:= ""
	Default lJob		:= .F.
	
	If (!Empty(cChave))
		
		oLoadNota 			:= TLoadNotaEntrada():New()
		oNFeResulStruct		:= oLoadNota:GetSD2(cChave)
		
		If (oNFeResulStruct:lOk)
			
			oNFeResulStruct:oResult:cDoc	 		:= cNumero
			oNFeResulStruct:oResult:cFornece 		:= cFornece
			oNFeResulStruct:oResult:cLoja 			:= cLoja
			oNFeResulStruct:oResult:dDataEmissao	:= dEmissao
			oNFeResulStruct:oResult:cEspecie		:= "NFS"
					
			oNotaEntrada 			:= TNotaEntrada():New()
			oNFeEntradaResultStruct	:= oNotaEntrada:Execute(oNFeResulStruct:oResult, .T.)
			
			If (oNFeEntradaResultStruct:lOk)
				
				If (!Empty(cNatureza) .And. !Empty(cTes) .And. nValor > 0 .And. !Empty(cCodNFe))
					
					//tentar classificar a nota fiscal
					
					oNFeResulStruct:oResult:cNatureza	:= cNatureza
					oNFeResulStruct:oResult:cCodNFe		:= cCodNFe
					
					If (oNFeResulStruct:oResult:oNotaItens:GetCount() == 1)
						oNFeResulStruct:oResult:oNotaItens:GetItem(1):cTes			:= cTes
						oNFeResulStruct:oResult:oNotaItens:GetItem(1):nValor		:= nValor
						oNFeResulStruct:oResult:oNotaItens:GetItem(1):nQuantidade	:= nQuantidade
						oNFeResulStruct:oResult:oNotaItens:GetItem(1):nAliqISS		:= nAliqISS
					EndIf
					
					oNotaEntrada 			:= TNotaEntrada():New()
					oNFeEntradaResultStruct	:= oNotaEntrada:Classificar(oNFeResulStruct:oResult)
					If (oNFeEntradaResultStruct:lOk)
						MsgAlert('<p style="color:green">NF de serviço importada/classificada com sucesso.</p>', 'Sucesso')
					Else
						MsgAlert('<p style="color:red">'+oNFeEntradaResultStruct:cMensagem+'</p>', 'Erro')
						lRet := .F.
					EndIf
					
				Else
					MsgAlert('<p style="color:green">NF de serviço importada com sucesso.</p>', 'Sucesso')
				EndIf
			Else
				MsgAlert('<p style="color:red">'+oNFeEntradaResultStruct:cMensagem+'</p>', 'Erro')
				lRet := .F.
			EndIf
		Else
			MsgAlert('<p style="color:red">'+oNFeResulStruct:cMensagem+'</p>', 'Erro')
			lRet := .F.
		EndIf
	
	Else
	
		MsgAlert('<p style="color:red">Chave NFe não informada.</p>', 'Erro')
		lRet := .F.
			
	EndIf
				
Return lRet