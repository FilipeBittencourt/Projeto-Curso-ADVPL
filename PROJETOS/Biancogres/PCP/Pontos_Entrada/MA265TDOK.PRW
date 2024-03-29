#include "rwmake.ch"
#include "topconn.ch"

User Function MA265TDOK()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Wanisay
Autor(Man):= Marcos Alberto Soprani
Programa  := MT242TOK
Empresa   := Biancogres Ceramica S.A.
Data      := 16/05/08
Data(Man) := 04/03/13
Uso       := Estoque / Custo
Aplica玢o := Ponto de Entrada utilizado para analisar lote na Distribuicao
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Private lRet := .T.

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+M->DA_PRODUTO)

If SB1->B1_RASTRO == 'L' .AND. (SUBSTR(M->DA_LOTECTL,1,4) == "AUTO" .OR. EMPTY(M->DA_LOTECTL))
	MsgBox("Lote nao informado ou informado incorretamente: "+M->DA_LOTECTL,"STOP")
	lRet := .F.
EndIf

If !(SB1->B1_TIPO $ "PA#PP") .And. M->DA_LOCAL $ "02#04"
	MsgBox("Almoxarifado destino incorreto: " + M->DA_LOCAL,"A261TOK","STOP")
	zlRet := .F.			
EndIf
     
//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimenta珲es retroativas que poderiam
// acontecer pelo fato de o par鈓tro MV_ULMES necessitar permanecer em aberto at� que o fechamento de estoque esteja conclu韉o
If M->DA_DATA <= GetMv("MV_YULMES")
	MsgSTOP("Imposs韛el prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MA265TDOK")
	lRet := .F.
EndIf

Return(lRet)
