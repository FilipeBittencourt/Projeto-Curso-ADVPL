#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

User Function MT103DIRF()
/*��������������������������������������������������������������������������
Autor     := Barbara Luan Gomes
Programa  := MT103DRF
Empresa   := Biancogres Cer�mica S/A
Data      := 24/01/19
Uso       := Compras
Aplica��o := O ponto de entrada MT103DIRF, tem a finalidade de validar os       
.           c�digos de reten��o dos impostos.
.           Utilizando-o podemos abortar a opera��o de inclus�o do 
.           documento de entrada, caso se verifique alguma inconsist�ncia
��������������������������������������������������������������������������*/
Local lRet := .T.
/*Local aCodR := {}
Local nX := 0

aCodR := aClone(PARAMIXB[1])

//valida��es do usu�rio
For nX := 1 to len(aCodR)
  //If aCodr[nX][2] == '' //Se o c�digo de reten��o estiver vazio, aborta inclus�o da nota.

    MsgSTOP("Esta nota possui "+aCodr[nX][1]+" e o codigo de reten��o � "+aCodr[nX][2], "MT103DIRF")
    lRet := .F.    
  //EndIf
Next nX*/

Return lRet