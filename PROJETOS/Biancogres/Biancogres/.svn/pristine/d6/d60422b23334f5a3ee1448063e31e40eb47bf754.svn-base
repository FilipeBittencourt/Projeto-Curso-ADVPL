#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

User Function M461VTOT()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := M461VTOT
Empresa   := Biancogres Cerâmica S/A
Data      := 22/09/14
Uso       := Faturamento
Aplicação := Este ponto de entrada verifica o total da Nota Fiscal e a con-
.            dição de pagamento escolhida, antes de sua geração.
.              Originalmente (22/09/14) este ponto de entrada somente foi
.            criado para gerar uma variável pública com o total da nota a
.            fim de servir de base para cálculo do rateio do ST no ponto de
.            entrada M460SOLI
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local aArea	  := GetArea()
Local lRet    := .T.

// Variável criada especificamente ponderação do ICMS-ST do ponto de entrada M460SOLI - Por Marcos Alberto Soprani - 22/09/14
Public xVlFrtInf  := 0
Public xBiaVTotNf := PARAMIXB[1]

RestArea(aArea)

Return ( lRet )
