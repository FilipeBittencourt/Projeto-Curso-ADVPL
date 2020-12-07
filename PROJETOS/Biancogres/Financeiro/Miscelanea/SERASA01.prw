#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Luana Marin Ribeiro
Programa  := SERASA01
Empresa   := Biancogres Cerâmica S/A
Data      := 29/09/2015
Uso       := SERASA.PRW
Aplicação := PONTO DE ENTRADA DA GERAÇÃO DO ARQUIVO DE RELATO DO SERASA. SERVER PARA INCREMENTAR O FILTRO DO PE
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function SERASA01() 
Local lRet 		:= .T.
Local cAlias	:= Paramixb[1]

//If SubStr(Alltrim((cAlias)->E1_PREFIXO),1,2)=="PR"
If (cAlias)->E1_PREFIXO == "PR1"
	//lRet := .F.
EndIf

Return(lRet)  