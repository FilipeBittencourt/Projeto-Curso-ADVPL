#include "rwmake.ch"
#include "topconn.ch"

User Function FA330VLD()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � FA330VLD   � Autor � Ranisses A. Corona    � Data � 23/02/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Forca o usuario a posicionar sempre no Titulo								潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Financeiro                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

Local lRet	:= .T.

If (!Alltrim(aTitulos[1][4]) $ "RA_NCC" .OR. Alltrim(CTIPOTIT) == "RA_NCC") 
	MsgAlert("Favor posicionar sempre no T韙ulo (NF) a ser compensado!")
	lRet := .F.
EndIf

Return(lRet)
