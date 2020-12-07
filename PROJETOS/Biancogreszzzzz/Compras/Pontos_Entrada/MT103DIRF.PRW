#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

User Function MT103DIRF()
/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Barbara Luan Gomes
Programa  := MT103DRF
Empresa   := Biancogres Cerâmica S/A
Data      := 24/01/19
Uso       := Compras
Aplicação := O ponto de entrada MT103DIRF, tem a finalidade de validar os       
.           códigos de retenção dos impostos.
.           Utilizando-o podemos abortar a operação de inclusão do 
.           documento de entrada, caso se verifique alguma inconsistência
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Local lRet := .T.
/*Local aCodR := {}
Local nX := 0

aCodR := aClone(PARAMIXB[1])

//validações do usuário
For nX := 1 to len(aCodR)
  //If aCodr[nX][2] == '' //Se o código de retenção estiver vazio, aborta inclusão da nota.

    MsgSTOP("Esta nota possui "+aCodr[nX][1]+" e o codigo de retenção é "+aCodr[nX][2], "MT103DIRF")
    lRet := .F.    
  //EndIf
Next nX*/

Return lRet