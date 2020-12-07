#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA430FIG
@author Tiago Rossini Coradini
@since 22/03/2018
@version 1.0
@description Adiciona legendas e regras de cores na mbrowse da rotina de atualizacao de cotacoes
@obs Ticket: 1451
@type Function
/*/

User Function MT150LEG()
Local nOpc := ParamIxb[1]
Local aRet := {}

	If nOpc == 1 // Array de cores
		
		aAdd(aRet, {"C8_YFLAG == 'N' .And. Empty(C8_NUMPED) .And. C8_PRECO == 0", "BR_PRETO"})
		aAdd(aRet, {"C8_YFLAG == 'P' .And. Empty(C8_NUMPED) .And. C8_PRECO == 0", "BR_AZUL"}) 
	
	ElseIf nOpc == 2 // Array de legandas
		
		aAdd(aRet, {"BR_PRETO", "Não atendida"})
		aAdd(aRet, {"BR_AZUL", "Atendida parcialmente"})
		 
	EndIf
	
Return(aRet)