#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA349()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA349
Empresa   := Biancogres Cerêmicas S/A
Data      := 14/11/14
Uso       := Faturamento
Aplicação := Impressão da DANFE padrão Totvs a partir do MENU
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Public aFilBrw := {,}

aFilBrw[1] := "SF2"
aFilBrw[2] := ""

SpedDanfe()

Return
