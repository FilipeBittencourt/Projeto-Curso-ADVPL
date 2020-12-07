#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0005(cChave, cNumero, cFornece, cLoja, dEmissao, lJob)
	
	Local lRet		:= .T.
	Default lJob	:= .F.
	
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
				MsgAlert('<p style="color:green">NF de serviço importada com sucesso.</p>', 'Sucesso')
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