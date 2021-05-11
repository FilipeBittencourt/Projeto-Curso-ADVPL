#Include "Protheus.ch"
#Include "TOTVS.ch"


User Function PNFM0003(cChave, cTipo, cSit, lJob)
	
	Local lRet		:= .T.
	Local cArquivo	:= Nil
	Default cTipo	:= "2"
	Default cSit	:= ""	
	Default lJob	:= .F.
	
	Public __nAliqICMS := 0
	
	If (!Empty(cChave))
		
		cArquivo	:= GetArqChave(cChave)
			
		DbSelectArea("SF1")
		SF1->(DbSetOrder(8))
		
		If !SF1->(DbSeek(xFilial('SF1')+PADR(cChave, TamSx3("F1_CHVNFE")[1])))
		
			DbSelectArea('ZAA')
			ZAA->(DbSetOrder(1))
			
			cChave := PADR(cChave, TamSx3("ZAA_CHAVE")[1])
				
			If ZAA->(DbSeek(cChave+cTipo+cSit)) .Or. !Empty(cArquivo)
				
				If (!Empty(ZAA->ZAA_XML))
					oLoadXML 			:= TLoadXMLCTe():New(ZAA->ZAA_XML, 1)
				Else
					oLoadXML 			:= TLoadXMLCTe():New(cArquivo, 2)
				EndIf
				
				oCTeResulStruct 	:= oLoadXML:GetCTe()
				
				If (oCTeResulStruct:lOk)
					
					__nAliqICMS := oCTeResulStruct:oResult:nAliqICMS
					
					
					oCTEntrada 				:= TCTEntrada():New()
					oCTeEntradaResultStruct	:= oCTEntrada:Execute(oCTeResulStruct:oResult)
					
					If (oCTeEntradaResultStruct:lOk)
						MsgAlert('<p style="color:green">CTe importado com sucesso.</p>', 'Sucesso')
					Else
						MsgAlert('<p style="color:red">'+oCTeEntradaResultStruct:cMensagem+'</p>', 'Erro')
						lRet := .F.
					EndIf
					
				Else
				
					MsgAlert('<p style="color:red">'+oCTeResulStruct:cMensagem+'</p>', 'Erro')
					lRet := .F.
				EndIf
			Else
			
				MsgAlert('<p style="color:red" >Chave do CTe não encontrada no conexão NFe.</p>', 'Erro')
				lRet := .F.
			EndIf
					
		EndIf
		
	EndIf	
			
Return lRet

Static Function GetArqChave(cChave)

	Local aFiles := Directory("\"+GetMV('MV_XGTNFIN')+cChave+"*.*", "D")
	If (Len(aFiles) > 0)
		Return "\"+GetMV('MV_XGTNFIN')+aFiles[1, 1]
	EndIf
	
	aFiles := Directory("\"+GetMV('MV_XGTNFOU')+cChave+"*.*", "D")
	If (Len(aFiles) > 0)
		Return "\"+GetMV('MV_XGTNFOU')+aFiles[1, 1]
	EndIf

Return ""
