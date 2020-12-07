#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA461ROT
@author Tiago Rossini Coradini
@since 26/11/2018
@version 1.0
@description Ponto de entrada par adicionar rotinas no menu de faturamento de nostas fiscais de saida
@obs Ticket: 8329
@type Function
/*/

User function MA461ROT()
Local nPos := 0	

	// Altera a chamada padrão do menu para a rotina customizada
	// Tratamento necessario pois não existe ponto de entrada padrão
	// A rotina padrao é chamada dentro da rotina customizada
		
	// Busca posição do menu com a rotina de Prep Docs
	If (nPos := aScan(aRotina, {|x| AllTrim(Upper(x[2])) == "MA460NOTA" })) > 0
		
		// Altera a chamada da rotina padrao para a rotina customizada
		aRotina[nPos, 2] := "U_BIAF125"
		
	EndIf
	
Return()