#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT120VSC
@author Tiago Rossini Coradini
@since 06/07/2016
@version undefined
@description Manipula o Array em solicitação de Compras ou Contrato de Parceria
@description Este Ponto de Entrada tem por objetivo manipular os campos do array na rotina de seleção da Solicitação de Compras ou Contrato de Parceria - F4 no Pedido de Compras
@obs Projeto Demanda Compras: Ticket: 5055
@type function
/*/

User Function MT120VSC()
Local aCpo := Paramixb[1]
Local cTipo := Paramixb[2]
Local nPos := 0

	// Solicitacao de compra
	If cTipo == 1
	
		If (nPos := aScan(aCpo, {|x| Alltrim(x) == "C1_OK"})) > 0
		
			nPos++
			aIns(aCpo, nPos)
			aCpo[nPos] := "C1_YMSG"
			
			nPos++
			aIns(aCpo, nPos)
			aCpo[nPos] := "C1_YANX"
			
			nPos++
			aIns(aCpo, nPos)
			aCpo[nPos] := "C1_YATSERV"
			
			nPos++
			aIns(aCpo, nPos)
			aCpo[nPos] := "C1_LOCAL"
			
		EndIf

	EndIf
	
Return(aCpo)