#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT150OK
@author Tiago Rossini Coradini
@since 20/12/2016
@version 2.0
@description Ponto de entrada na validação dos dados da cotação de compra,  
@obs OS: XXXX-XX - Claudia Carvalho - Enviado via e-mail
@obs OS: 4638-16 - Claudia Carvalho
@type function
/*/

User Function MT150OK()
Local nOpc := ParamIxb[1]
Local lRet := .T.
		
	lRet := fVldTpFre(nOpc) .And. fVldDatCh(nOpc)
	 
Return(lRet)


Static Function fVldTpFre(nOpc)
Local lRet := .T.
	
	// 2=Novo Participante; 3=Atualizar; 4=Proposta
	If nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4

		If IsInCallStack("U_BIPROCCT")

			c150Frete := U_BIPRCTFR()

		EndIf
		
		If IsInCallStack("U_RETP0003")
			
			//varivel publica vindo da função U_RETP0003
			If (Type("_cTpFreteA") <> "U" .And. !Empty(_cTpFreteA) )
				c150Frete := _cTpFreteA
			EndIf
			
		EndIf
		
	
		If !Substr(c150Frete, 1, 1) $ "C/F/S"
			
			lRet := .F.
			
			MsgStop("Atenção, tipo de frete inválido, favor verificar a aba 'Frete/Despesas'!")
			AutoGrLog("Atenção, tipo de frete inválido, favor verificar a aba 'Frete/Despesas'!")
			
		EndIf
	
	EndIf
	
Return(lRet)


Static Function fVldDatCh(nOpc)
Local lRet := .T.
Local nCount := 1

	// 3=Atualizar; 4=Proposta		
	If (nOpc == 3 .Or. nOpc == 4) .And. !IsBlind()
	
		While nCount <= Len(aCols) .And. lRet
		
			If !GdDeleted(nCount)
				
				If Empty(GdFieldGet("C8_YDATCHE", nCount))
					
					lRet := .F.
					
					MsgStop("Atenção, o campo Data de Chegada do item: "+ GdFieldGet("C8_ITEM", nCount) + " não foi preenchido!", "Campo Obrigatório")
					AutoGrLog("Atenção, o campo Data de Chegada do item: "+ GdFieldGet("C8_ITEM", nCount) + " não foi preenchido!", "Campo Obrigatório")
					
				EndIf
				
			EndIf
			
			nCount++
			
		EndDo()
		
	EndIf
	
Return(lRet)
