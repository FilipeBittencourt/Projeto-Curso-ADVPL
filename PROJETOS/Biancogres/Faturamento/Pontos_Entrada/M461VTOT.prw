#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

User Function M461VTOT()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := M461VTOT
Empresa   := Biancogres Cer鈓ica S/A
Data      := 22/09/14
Uso       := Faturamento
Aplica玢o := Este ponto de entrada verifica o total da Nota Fiscal e a con-
.            di玢o de pagamento escolhida, antes de sua gera玢o.
.              Originalmente (22/09/14) este ponto de entrada somente foi
.            criado para gerar uma vari醰el p鷅lica com o total da nota a
.            fim de servir de base para c醠culo do rateio do ST no ponto de
.            entrada M460SOLI
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local aArea	  := GetArea()
Local lRet    := .T.

// Vari醰el criada especificamente pondera玢o do ICMS-ST do ponto de entrada M460SOLI - Por Marcos Alberto Soprani - 22/09/14
Public xVlFrtInf  := 0
Public xBiaVTotNf := PARAMIXB[1]

RestArea(aArea)

Return ( lRet )
