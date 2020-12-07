#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function MA260EST()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := MA260EST
Empresa   := Biancogres Ceramica S.A.
Data      := 20/02/13
Uso       := Estoque / Custo
Aplica玢o := Valida estorno do movimento - Transferencia Mod I
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local zlRet := .T.

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimenta珲es retroativas que poderiam
// acontecer pelo fato de o par鈓tro MV_ULMES necessitar permanecer em aberto at� que o fechamento de estoque esteja conclu韉o
If dEmis260 <= GetMv("MV_YULMES")
	MsgSTOP("Imposs韛el prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MA260EST")
	zlRet := .F.
EndIf

Return ( zlRet )
