#include "rwmake.ch"

/*/{Protheus.doc} F650VAR
@author Microsiga Vitoria
@since 23/03/06
@version 1.0
@description Utilizado para correção de algunas variaveis do CNAB a Receber 
@type function
/*/

User Function F650VAR()        
Local aAreaSE1	:= SE1->(GetArea())
Local cArq		:= ""
Local cInd		:= 0
Local cReg		:= 0

//Armazena area de Trabalho
cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

//Executa as mesmas funcoes utilizadas no P.E. F200VAR
U_fAceJur()
U_fAceVal()

RestArea(aAreaSE1)

//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return 