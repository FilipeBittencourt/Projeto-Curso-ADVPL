#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF049
@author Tiago Rossini Coradini
@since 19/10/2016
@version 1.0
@description Rotina para exibir ultimas condições de pagamento utilizadas pelo cliente no pedido de venda. 
@obs OS: 3728-16 - Claudeir Fadini
@type function
/*/

User Function BIAF049(cCodCli, cLojCli, cLinha)
Local aArea := GetArea()
Local cCodCli := M->C5_CLIENTE
Local oWConPag := Nil
	
	If !AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC");
			.Or. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
	
		oWConPag := TWHistoricoCondicaoPagamento():New(cCodCli, cLojCli, cLinha)
		
		If Len(oWConPag:aFields) > 0 
		
			oWConPag:Activate()
			
			If !Empty(oWConPag:cCondPag)
				
				cCondPag := oWConPag:cCondPag					
				
			EndIf
		
		EndIf
	
	EndIf
	
	RestArea(aArea)
		
Return(cCodCli)