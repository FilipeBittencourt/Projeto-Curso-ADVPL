#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0006(cNumero, cFornece, cLoja, dEmissao, lJob)
	
	Local lRet		:= .T.
	Default lJob	:= .F.
	
	If (!Empty(cNumero) .And. !Empty(cFornece) .And. !Empty(cLoja))
		
		oNotaEntrada 			:= TNotaEntrada():New()
		oNFeEntradaResultStruct	:= oNotaEntrada:DelPorDocFor(cNumero, '',cFornece, cLoja, .T.)
		
		If (oNFeEntradaResultStruct:lOk)
			MsgAlert('<p style="color:green">Registro exluido com sucesso.</p>', 'Sucesso')
		Else
			MsgAlert('<p style="color:red">'+oNFeEntradaResultStruct:cMensagem+'</p>', 'Erro')
			lRet := .F.
		EndIf
		
	EndIf	
			
Return lRet