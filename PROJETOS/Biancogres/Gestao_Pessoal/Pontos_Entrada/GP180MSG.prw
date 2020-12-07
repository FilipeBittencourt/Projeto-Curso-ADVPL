#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function GP180MSG()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := GP180MSG
Empresa   := Biancogres Cerâmica S/A
Data      := 07/03/12
Uso       := Gestão de Pessoal
Aplicação := Apresenta Mensagem antes de confirmar a transferência.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local yj_RetFn := .T.

MsgSTOP("Favor verificar se o centro de custo para o qual o funcionário está sendo transferido possui adcionais de Insalubridade e Perculosidade","Atenção (GP180MSG)")
yj_RetFn := MsgYesNo("Favor conferir se a matrícula foi alterada corretamente! Deseja prosseguir? ","Atenção (GP180MSG)")


Return ( yj_RetFn )