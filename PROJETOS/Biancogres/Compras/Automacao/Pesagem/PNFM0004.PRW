#Include "Protheus.ch"
#Include "TOTVS.ch"

User Function PNFM0004(cChave, lJob)
	
	Local lRet		:= .T.
	Default lJob	:= .F.
	
	If (!Empty(cChave))
		
		oNotaEntrada 			:= TNotaEntrada():New()
		oNFeEntradaResultStruct	:= oNotaEntrada:DelPorChave(cChave)
		
		If (oNFeEntradaResultStruct:lOk)
			MsgAlert('<p style="color:green">Registro exluido com sucesso.</p>', 'Sucesso')
		Else
			MsgAlert('<p style="color:red">'+oNFeEntradaResultStruct:cMensagem+'</p>', 'Erro')
			lRet := .F.
		EndIf
		
	EndIf	
			
Return lRet