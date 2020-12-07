#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function M261D3O()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := M261D3O
Empresa   := Biancogres Cerâmica S/A
Data      := 04/09/12
Uso       := PCP
Aplicação := E chamado na gravacao de cada registro de transferência de
.            origem no SD3
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Public zt_NSeqD3 := SD3->D3_NUMSEQ // Variável para o Programa BIA292

Return
