#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

User Function MT103DIRF()
/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     := Barbara Luan Gomes
Programa  := MT103DRF
Empresa   := Biancogres Cer鈓ica S/A
Data      := 24/01/19
Uso       := Compras
Aplica玢o := O ponto de entrada MT103DIRF, tem a finalidade de validar os       
.           c骴igos de reten玢o dos impostos.
.           Utilizando-o podemos abortar a opera玢o de inclus鉶 do 
.           documento de entrada, caso se verifique alguma inconsist阯cia
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北*/
Local lRet := .T.
/*Local aCodR := {}
Local nX := 0

aCodR := aClone(PARAMIXB[1])

//valida珲es do usu醨io
For nX := 1 to len(aCodR)
  //If aCodr[nX][2] == '' //Se o c骴igo de reten玢o estiver vazio, aborta inclus鉶 da nota.

    MsgSTOP("Esta nota possui "+aCodr[nX][1]+" e o codigo de reten玢o � "+aCodr[nX][2], "MT103DIRF")
    lRet := .F.    
  //EndIf
Next nX*/

Return lRet