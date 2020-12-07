#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function PNFM0002(cChave, cPesage, cTipo, cSit, lJob)

	Local lRet			:= .T.
	Local oItem			:= Nil
	
	Default cTipo		:= "1"
	Default cSit		:= ""	
	Default lJob		:= .F.	
	
	If (!Empty(cChave))
			
		DbSelectArea("SF1")
		SF1->(DbSetOrder(8))
		
		If !SF1->(DbSeek(xFilial('SF1')+PADR(cChave, TamSx3("F1_CHVNFE")[1])))
			
			DbSelectArea('ZAA')
			ZAA->(DbSetOrder(1))
			
			cChave := PADR(cChave, TamSx3("ZAA_CHAVE")[1])
			
			If ZAA->(DbSeek(cChave+cTipo+cSit))
				
				oLoadXML 			:= TLoadXMLNFe():New(ZAA->ZAA_XML)
				oNFeResulStruct 	:= oLoadXML:GetNFe()
				
				If (oNFeResulStruct:lOk)
					
					If (oNFeResulStruct:oResult:oNotaItens:GetCount() == 1)
						
						If (!Empty(cPesage))
							
							DbSelectArea('Z11')
							Z11->(DbSetOrder(1))
							If Z11->(DbSeek(xFilial('Z11')+cPesage))
							
								//atualiza quantidade pode existir perda no caminhão
								oNFeResulStruct:oResult:oNotaItens:GetItem(1):nQuantTicket	:= (Z11->Z11_PESLIQ/1000)
								oNFeResulStruct:oResult:oNotaItens:GetItem(1):cNumTicket	:= cPesage
							
								
								oNotaEntrada 			:= TNotaEntrada():New()
								oNFeEntradaResultStruct	:= oNotaEntrada:Execute(oNFeResulStruct:oResult)
								
								If (oNFeEntradaResultStruct:lOk)
									MsgAlert('<p style="color:green">NFe importada com sucesso.</p>', 'Sucesso')
								Else
									MsgAlert('<p style="color:red">'+oNFeEntradaResultStruct:cMensagem+'</p>', 'Erro')
									lRet := .F.
								EndIf		
							
							EndIf
							
						EndIf
					Else
						
						MsgAlert('<p style="color:red" >A NFe de importação precisa ter apenas um item.</p>', 'Erro')
						lRet := .F.
						
					EndIf
					
				Else
				
					MsgAlert('<p style="color:red">'+oNFeResulStruct:cMensagem+'</p>', 'Erro')
					lRet := .F.
				EndIf
			Else
			
				MsgAlert('<p style="color:red" >Chave da NFe não encontrada no conexão NFe.</p>', 'Erro')
				lRet := .F.
				
			EndIf
		
		EndIf
			
			
	EndIf
	
Return lRet

