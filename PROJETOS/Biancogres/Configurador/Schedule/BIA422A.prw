#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

User Function BIA422A()
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA422A    � Autor � Ranisses A. Corona    � Data � 02.12.08 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Analisa o credito de cliente de cada romaneio em aberto      罕�
北�          � Funcao utilizada para no schedule para chamar o fonte princ. 罕�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador xBase                                          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA422 - BIANCOGRES")
//Startjob("U_BIA422","SCHEDULE",.T.,"01")        
Startjob("U_BIA422","WANISAY",.T.,"01")        
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA422 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA422 - INCESA")
//Startjob("U_BIA422","SCHEDULE",.T.,"05")
Startjob("U_BIA422","WANISAY",.T.,"05")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA422 - INCESA")

//ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA442 - LM")
//Startjob("U_BIA422","SCHEDULE",.T.,"07")
//ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA442 - LM")

RETURN .T.