#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA470A    � Autor � Wanisay William       � Data � 04.03.10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Prepara envio de e-mail de alteracoes de salarios e funcoes. ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
User Function BIA470A()

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA470 - BIANCOGRES")
Startjob("U_BIA470","SCHEDULE",.T.,"01")        
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA470 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA470 - INCESA")
Startjob("U_BIA470","SCHEDULE",.T.,"05")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA470 - INCESA")

RETURN .T.