#include "rwmake.ch"

User Function Bia147()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o		 � BIA147	    � Autor � Cesar Magnago         � Data � 22/11/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Verifica se o Classe de Valor for 8xxx o produto tem que ser 4潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 	 � SIGAEST												                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

SetPrvt("CROTINA,WCC,WCLVL,XXN,XCCAMPO,WSCOD,")

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa variaveis.												                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cRotina := upper(AllTrim(FunName()))
wsCod   := M->D3_COD

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO
IF Type("_IViaEAuto") <> "U"
	Return(wsCod)
ENDIF

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
IF Type("_ExecAutoII") <> "U"
	wsCod := Gdfieldget("D3_COD",n)
	RETURN(wsCod)
ENDIF

do case
	case cRotina == "MATA240" .or. cRotina == "BIA294"
		wsCod	:= M->D3_COD
		
	case cRotina == "MATA241"
		wsCod  := Gdfieldget("D3_COD",n)
endcase

DbSelectArea("SB1")
DbSetOrder(1)
SB1->(DbSeek(xFilial("SB1")+wsCod,.F.))

Return(wsCod)   
