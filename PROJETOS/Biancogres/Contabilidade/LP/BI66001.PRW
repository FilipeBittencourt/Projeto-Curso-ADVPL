#include "rwmake.ch"

User Function BI66001()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BI66601    � Autor � MICROSIGA VITORIA     � Data � 16/01/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Historico da requisicao no lcto padrao 66001                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Altera玢o� Marcos Alberto Soprani - 31/01/12                            潮�
北�          � - Tratamento condicionado a existencia da Chave na Tabela    潮�
北�          � SD1                                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      �                                                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

chist := "UTILIZACAO N/DATA CONF REQ "+SD3->D3_DOC

If !Empty(SD3->D3_YCHAVE)
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(xFilial("SD1")+SD3->D3_YCHAVE))
		chist += " REF. NF " +SD1->D1_SERIE+"-"+ALLTRIM(SD1->D1_DOC)+" DE "+DTOC(SD1->D1_DTDIGIT)
	EndIf
EndIf

Return(chist)
