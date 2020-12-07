#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function GP180MSG()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Marcos Alberto Soprani
Programa  := GP180MSG
Empresa   := Biancogres Cer鈓ica S/A
Data      := 07/03/12
Uso       := Gest鉶 de Pessoal
Aplica玢o := Apresenta Mensagem antes de confirmar a transfer阯cia.
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local yj_RetFn := .T.

MsgSTOP("Favor verificar se o centro de custo para o qual o funcion醨io est� sendo transferido possui adcionais de Insalubridade e Perculosidade","Aten玢o (GP180MSG)")
yj_RetFn := MsgYesNo("Favor conferir se a matr韈ula foi alterada corretamente! Deseja prosseguir? ","Aten玢o (GP180MSG)")


Return ( yj_RetFn )