#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120FOL
@author Tiago Rossini Coradini
@since 14/01/2021
@version 1.0
@description Ponto de entrada  para adicionar objetos ao nova folder no pedido de compra
@obs Ticket: 25002
@type function
/*/

User function MT120FOL()
Local aArea := GetArea()
Local nOpc := PARAMIXB[1]
Local aPosGet := PARAMIXB[2]

	If nOpc == 4 .Or. nOpc == 2 // Visualizar ou Alterar
		
		M->C7_YCREINV := SC7->C7_YCREINV
		
	Else
		
		M->C7_YCREINV := 0
		
	EndIf

	If nOpc <> 1 // Não é pesquisar
	
		@ 006, aPosGet[1,1] SAY OemToAnsi('Crédito INVEST') OF oFolder:aDialogs[7] PIXEL SIZE 050, 009
		@ 005, aPosGet[1,2] MSGET M->C7_YCREINV PICTURE PesqPict('SC7','C7_YCREINV') OF oFolder:aDialogs[7] VALID Positivo() WHEN If (nOpc == 3 .Or. nOpc == 4, .T., .F.) PIXEL SIZE 080,009 HASBUTTON
	
	Endif

	RestArea(aArea)

Return()