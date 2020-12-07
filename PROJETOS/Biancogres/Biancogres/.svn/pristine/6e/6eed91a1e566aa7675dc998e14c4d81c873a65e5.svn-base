#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF101
@author Tiago Rossini Coradini
@since 28/03/2018
@version 1.0
@description Simula acao(Tab ou Enter) no TGet de codicao de pagamento
@description Utilizado para tratar BUG de refresh da aba de duplicatas na condicao de pagamento para conhecimento de frete 
@obs OS: 2070-17
@type Function
/*/

User Function BIAF101()
Local oWnd := GetWndDefault()
Local lLoop := .T.
Local nCount := 1	
	
	While nCount <= Len(oWnd:aControls) .And. lLoop
		
		If oWnd:aControls[nCount]:ClassName() == "TGET"
			
			If Upper(oWnd:aControls[nCount]:cReadVar) == "CCONDICAO"																
				
				// Seta focu no objeto
				oWnd:aControls[nCount]:SetFocus()							
			
				// Executa refresh na aba de duplicatas
				Eval(oFolder:bSetOption, 6)	
								
				lLoop := .F.
				
			EndIf
			
		EndIf	
		
		nCount++
		
	EndDo()
		
Return()
