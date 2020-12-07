#Include 'Protheus.ch'

/*/{Protheus.doc} MT103NPC
manipular o array de multiplas naturezas por título a partir da inclusão do Pedido de Compras no Documento de Entrada.
@type Function
@author Pontin
@since 08/08/2016
@version 1.0
/*/
User Function MT103NPC()

	Local nX		:= 0
	Local lMarcou	:= .F.
	
	If !IsBlind() .And. Type("aF4For") == "A"
		
		//|Foi definido em reunião com o compras que não pode conter pedidos de compras com 
		//|condições de pagamentos diferentes para a mesma Nota Fiscal de Entrada. |
		
		//|Posicionar corretamente no pedido de compra marcado
		For nX	:= 1 To Len(aF4For)
			
			If aF4For[nX][1]
			
				lMarcou	:= .T.
	
				DbSelectArea("SC7")
				SC7->(DbSetOrder(9))
				cSeek := ""
				cSeek += xFilEnt(xFilial("SC7"))+cA100For
				cSeek += aF4For[nx][2]+aF4For[nx][3]
				SC7->(MsSeek(cSeek))
				
				Exit
				
			EndIf
		Next   
		
		//|Protecao para nao dar erro com execauto |
		If AllTrim(Upper(FunName())) == "MATA103" .And. !Empty(SC7->C7_COND) .And. lMarcou
			
			//|Buscar a condicao de pagamento do Pedido de Compra |
			cCondicao	:= SC7->C7_COND	//|cCondicao variavel private na rotina MATA103
		
		EndIf
	
	EndIf

Return //|Esse ponto de entrada espera o retorno de um array para multiplas naturezas, porem nesse momento sera utilizado para outra finalidade. |

