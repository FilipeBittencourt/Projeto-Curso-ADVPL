#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} FR650FIL
@author Microsiga Vitoria
@since 22/10/01
@version 1.0
@description Utilizado para ajustar o posicionamento do Titulo, pesquisando pelo Prefixo+Numero+Parcela ou NossoNumero 
@type function
/*/

User Function FR650FIL()
Local lRet		:= .T.
Local nTipo		:= ""
Local nNsNum	:= ""

aArea	:= GetArea()

//Tipo do Titulo
If Alltrim(cTipo) == "01"
	nTipo := "NF"
ElseIf Alltrim(cTipo) == "06
	nTipo := "FT"
EndIf

//Busca o Numero
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT MAX(E1_PREFIXO+E1_NUM+E1_PARCELA) NUMERO
	FROM  %Table:SE1%
	WHERE 	E1_PREFIXO 	= %Exp:SUBSTR(cNumTit,1,1)% 	AND 
			E1_PARCELA	= %Exp:SUBSTR(cNumTit,10,1)% 	AND                                      
			E1_TIPO 	= %Exp:nTipo% 					AND
			(E1_NUM = %Exp:SUBSTR(cNumTit,4,6)% OR E1_NUM = %Exp:"000"+SUBSTR(cNumTit,4,6)%) AND 
			%NOTDEL%
EndSql
nNsNum	:= (cAliasTmp)->NUMERO
(cAliasTmp)->(dbCloseArea())

If Empty(cNossoNum)                  		
	MsgBox("Nosso N�mero n�o encontrado no retorno banc�rio. O sistema ir� realizar a pequisa atrav�s do PREFIXO+NUMERO+PARCELA.","FR650FIL","ALERT")
Else
	//POSICIONA ATRAVES DO NOSSO NUMERO
	SE1->(dbOrderNickName("YNOSSONUM")) 
	If SE1->(dbSeek(xFilial("SE1")+cNossoNum))
		lRet := .T.
	Else
	//POSICIONA ATRAVES DO PREFIXO+NUMERO+PARCELA+TIPO
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+nNsNum+nTipo))   
			lRet := .T.
		Else
			lRet := .F.
			RestArea(aArea)		
			MsgBox("O sistema n�o conseguiu encontrar o T�tulo "+cNumTit+". Favor verificar.","FR650FIL","ALERT")
		EndIf
	Endif
Endif

Return(lRet)