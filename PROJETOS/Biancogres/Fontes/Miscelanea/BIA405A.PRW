#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA405A    � Autor � Wanisay William       � Data � 08.02.08 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara envio de e-mail de pedidos nao aprovados.            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function BIA405A()

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA405 - BIANCOGRES")
Startjob("U_BIA405","SCHEDULE",.T.,"01")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA405 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA405 - INCESA")
Startjob("U_BIA405","SCHEDULE",.T.,"05")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA405 - INCESA")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA405 - LM")
Startjob("U_BIA405","SCHEDULE",.T.,"07")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA405 - LM")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA405 - ST-GESTAO")
Startjob("U_BIA405","SCHEDULE",.T.,"12")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA405 - ST-GESTAO")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA405 - MUNDI")
Startjob("U_BIA405","SCHEDULE",.T.,"13")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA405 - MUNDI")

RETURN .T.