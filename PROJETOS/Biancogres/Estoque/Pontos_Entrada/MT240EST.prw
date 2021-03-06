#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function MT240EST()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := MT240EST
Empresa   := Biancogres Ceramica S.A.
Data      := 20/02/13
Uso       := Estoque / Custo
Aplica玢o := Valida estorno do movimento - Internos Mod I
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local zlRet := .T.
Local oEntEPI := TEntregaEPI():New()

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimenta珲es retroativas que poderiam
// acontecer pelo fato de o par鈓tro MV_ULMES necessitar permanecer em aberto at� que o fechamento de estoque esteja conclu韉o
If SD3->D3_EMISSAO <= GetMv("MV_YULMES")
	MsgSTOP("Imposs韛el prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!", "MT240EST")
	zlRet := .F.
EndIf

	If zlRet
		
		// Deleta EPI associada a movimenta玢o interna
		oEntEPI:Delete(SD3->D3_NUMSEQ)
		
	EndIf

Return ( zlRet )
