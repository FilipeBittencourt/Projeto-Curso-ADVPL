#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA484()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA484     � Autor � WANISAY               � Data � 25/11/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Gatilho CK_ENTREG                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � BIANCOGRES                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/                                                         
PRIVATE nPosEnt  := Ascan(aHeader,{|x| x[2] == "CK_ENTREG "})
PRIVATE dDataEnt := M->CK_ENTREG
//PRIVATE dDataEnt := aCols[n,nPosEnt]

//Valida a data de emissao e data de entrega do pedido
IF INCLUI
	IF M->CJ_EMISSAO < dDatabase
		Alert("A Data de Emissao do pedido n鉶 pode ser menor do que a data base do sistema!")
		dDataEnt := CTOD("  /  /  ")
	ENDIF
	IF TMP1->CK_ENTREG < dDatabase
		Alert("A Data de Entrega do item pedido n鉶 pode ser menor do que a Data de Emissao do pedido!")
		dDataEnt := CTOD("  /  /  ")
	ENDIF
ENDIF

IF TMP1->CK_ENTREG < M->CJ_EMISSAO
	Alert("A Data de Entrega do item pedido n鉶 pode ser menor do que a Data de Emissao do pedido!")
	dDataEnt := CTOD("  /  /  ")
ENDIF


If Alltrim(Funname()) <> "RPC"
	If !Empty(TMP1->CK_ENTREG)
		TMP1->CK_OBS := "DT. ENTREGA USUARIO"
	Else
		TMP1->CK_OBS := ""
	EndIf
EndIf

Return(dDataEnt)