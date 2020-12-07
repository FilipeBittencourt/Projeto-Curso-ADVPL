#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0041; Return()

/*
|-----------------------------------------------------------|
| Classe: | TBiaMensagemClienteNfeSefaz											|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 04/02/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação das mensagens de        |
| 				| clientes da nota fiscal eletrônica 							|
|-----------------------------------------------------------|
*/

Class TBiaMensagemClienteNfeSefaz From LongClassName
	
	Data cMensagem
	Data oDuplicata
			
	Method New(cParam, aParam) Constructor
	Method Update()
	
EndClass


Method New(cParam, aParam) Class TBiaMensagemClienteNfeSefaz
  
	::cMensagem := cParam
	
	::oDuplicata := TBiaDuplicataNfeSefaz():New(aParam)		
	
	// Atualiza informações da duplicata
	::oDuplicata:Update()
	
Return()


Method Update() Class TBiaMensagemClienteNfeSefaz
		
	If SFT->FT_TIPOMOV == "S"
		
		// Imprime o PEdido de Venda/Codigo do Cliente ou Fornecedor
		If !SF2->F2_TIPO $ "DB"
			
			::cMensagem += " PV: " + SC5->C5_NUM
			::cMensagem += " Código Cliente: "
			
		Else
			
			::cMensagem += " Código Fornecedor: "
			
		EndIf
		
		::cMensagem += SF2->F2_CLIENTE + "-" + SF2->F2_LOJA
		
				
  	// Mensagem para informacoes de titulo de ST para bonificacao quando ja nao for destacado na nota
  	If SF2->(FieldPos("F2_YVLGNRE")) > 0
			
			If (SF2->F2_YVLGNRE > 0) .And. ::oDuplicata:oLst:GetCount() > 0
				
				If !Empty(::cMensagem)
					::cMensagem += " "
				EndIf								
												
				::cMensagem += "Titulo Ref. ICMS ST Num: " + Alltrim(::oDuplicata:oLst:GetItem(1):cNumTit) + " no valor de R$" + Alltrim(TRANS((::oDuplicata:oLst:GetItem(1):nValor),"@E 999,999.99"))
				::cMensagem += " Vencimento: " + DtoC(::oDuplicata:oLst:GetItem(1):dDatVen)
				
			EndIf
			
		EndIf
		
		
		// Mensagem Padrao da Nota
		If !Empty(SF2->F2_YMENNOT)
			
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf
			
			::cMensagem += AllTrim(SF2->F2_YMENNOT) 
						
		EndIf
				
		// Tiago Rossini Coradini - OS: 1736-15 - Não imprime numero do pedido para a LM
		If !Empty(SC5->C5_YPC) .And. SF2->F2_TIPO == "N" .And. SF2->F2_CLIENTE <> "010064"
				
			If !Empty(::cMensagem)
				::cMensagem += " "
			EndIf			          
			
			::cMensagem += "Pedido de Compra: " + AllTrim(SC5->C5_YPC)
			
		EndIf
		
	EndIf
	
	//Retira caracteres especiais - Problema na NF 4.0
	::cMensagem := U_fDelTab(::cMensagem)
	 		
Return(::cMensagem)