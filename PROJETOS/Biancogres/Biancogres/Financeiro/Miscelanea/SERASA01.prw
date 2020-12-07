#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
Autor     := Luana Marin Ribeiro
Programa  := SERASA01
Empresa   := Biancogres Cer鈓ica S/A
Data      := 29/09/2015
Uso       := SERASA.PRW
Aplica玢o := PONTO DE ENTRADA DA GERA敲O DO ARQUIVO DE RELATO DO SERASA. SERVER PARA INCREMENTAR O FILTRO DO PE
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

User Function SERASA01() 
Local lRet 		:= .T.
Local cAlias	:= Paramixb[1]

//If SubStr(Alltrim((cAlias)->E1_PREFIXO),1,2)=="PR"
If (cAlias)->E1_PREFIXO == "PR1"
	//lRet := .F.
EndIf

Return(lRet)  