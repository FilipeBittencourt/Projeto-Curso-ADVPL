#include "rwMake.ch"
#include "Topconn.ch"
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o    � FA330FLT   � Autor � Nilton                � Data � 25/11/04 潮�
北�          �            � Alter � Ranisses A. Corona    � Data � 29/10/09 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao �*Filtrar titulos na tela Compensacao CR                       潮�
北�          �*Filtrar apenas Titulos de Contrato                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Financeiro                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
User Function FA330FLT()

//Exibe Pergunta
Pergunte("FA330F", .T.)  

//Apos a migracao para versao MP10, desativamos o filtro de E1_PREFIXO <> RA. O 

If MV_PAR01 == 2
	//Filtro titulos com Forma de Pagamento = CT
	dbSelectArea("SE1")
	Set filter to SE1->E1_YFORMA == "4"
//	Set filter to !SE1->E1_PREFIXO == "RA" .And. SE1->E1_YFORMA == "4"
//Else
//	Filtro titulos com Prefixo <> RA
//	dbSelectArea("SE1")
//	Set filter to !SE1->E1_PREFIXO == "RA"
EndIf

Return