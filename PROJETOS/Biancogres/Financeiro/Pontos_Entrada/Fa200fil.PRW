#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} FA200FIL
@author Microsiga Vitoria
@since 22/10/01
@version 1.0
@description Utilizado para ajustar o posicionamento do Titulo, pesquisando pelo Prefixo+Numero+Parcela ou NossoNumero 
@history 21/11/2018, Ranisses A. Corona, Ajustes no declara��o de variaveis.
@type function
/*/

User Function FA200FIL()
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

If Empty(cNsNum)                  
	MsgBox("Nosso N�mero n�o encontrado no retorno banc�rio. O sistema ir� realizar a pequisa atrav�s do PREFIXO+NUMERO+PARCELA.","FA200FIL","ALERT")
Else
	//POSICIONA ATRAVES DO NOSSO NUMERO
	SE1->(dbOrderNickName("YNOSSONUM")) 
	If SE1->(dbSeek(xFilial("SE1")+cNsNum,.T.))
		lRet := .T.
	Else
		//POSICIONA ATRAVES DO PREFIXO+NUMERO+PARCELA+TIPO
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+nNsNum+nTipo,.T.))   		
			If Empty(Alltrim(SE1->E1_NUMBCO))
				lRet := .T.
			Else
				lRet := .F.
				RestArea(aArea)		
				MsgBox("Este titulo "+cNumTit+" j� possui NOSSO NUMERO gravado. Favor verificar.","FA200FIL","ALERT")
			EndIf			
		Else
			lRet := .F.
			RestArea(aArea)		
			MsgBox("O sistema n�o conseguiu encontrar o T�tulo "+cNumTit+". Favor verificar.","FA200FIL","ALERT")
		EndIf
	Endif
Endif

Return(lRet)