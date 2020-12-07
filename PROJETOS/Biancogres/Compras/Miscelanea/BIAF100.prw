#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF100
@author Tiago Rossini Coradini
@since 28/03/2018
@version 1.0
@description Funcao para adicionar validacao na data de emissao
@description Utilizado para tratar BUG de refresh da aba de duplicatas na condicao de pagamento para conhecimento de frete 
@obs OS: 2070-17
@type Function
/*/

User Function BIAF100()
Local oWnd := GetWndDefault()
	
	If Empty(GetCBSource(oWnd:bStart))
		
		oWnd:bStart := {|| fAddValid(Self) }
		
	EndIf
	
Return()


// Identifica TGet de Data de Emissao e adiciona validacao para executar o refresh na aba duplicatas
Static Function fAddValid(oWnd)
Local lLoop := .T.
Local nCount := 1	
	
	While nCount <= Len(oWnd:aControls) .And. lLoop
		
		If oWnd:aControls[nCount]:ClassName() == "TGET"
			
			If Upper(oWnd:aControls[nCount]:cReadVar) == "DDEMISSAO"																
				
				fAddBlock(@oWnd:aControls[nCount]:bValid)
				
				lLoop := .F.
				
			EndIf
			
		EndIf	
		
		nCount++
		
	EndDo()

Return()


// Adiciona funcao no bloco de codigo de validacao padrao 
Static Function fAddBlock(bBlock)
Local cBlock := ""

	cBlock := GetCBSource(bBlock)
	cBlock := StrTran(cBlock, "{", "")
	cBlock := StrTran(cBlock, "}", "")
	cBlock := StrTran(cBlock, "|", "")
	cBlock := StrTran(cBlock, Space(1), "")

	bBlock := &("{||" + cBlock + ".And. U_BIAF100A()" + "}")
	
Return()


// Refresh na aba de duplicatas
User Function BIAF100A()
	//Ticket 9134 - Esta condição foi feita para não ocorrer o erro ao passar pelo campo data de emissao na rotina MATA140
	if Alltrim(FunName()) != "MATA140"
		Eval(oFolder:bSetOption, 6)
	end if
Return(.T.)