#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���PROGRAMA  � INC_OBS  � AUTOR � MADLENO               � DATA � 30/01/08 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O � INCLUI A OBSERVACAO NO CONTAS A RECEBER                    ���
�������������������������������������������������������������������������Ĵ��
���USO       � SIGAFIM                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER FUNCTION INC_OBS() 
PRIVATE WOBS := SPACE(25)

IF !(UPPER(ALLTRIM(FUNNAME())) $ "FINA040|FINA740")
	RETURN
END IF 

WOBS := SE1->E1_HIST

//��������������������������������������������������������������������������Ŀ
//� EXIBE JANELA COM DESCRITIVO DO PROGRAMA                                  �
//����������������������������������������������������������������������������
@ 96,42 TO 280,380 DIALOG ODLG5 TITLE "OBSERVA��O"
@ 8,10 TO 84,165

@ 16,12 SAY "ESTE PROGRAMA TEM POR FINALIDADE: "
@ 26,12 SAY "INCLUIR UMA OBSERVA��O NO CONTAS A RECEBER"
@ 40,12 GET WOBS SIZE 100,10 

@ 61,12 BMPBUTTON TYPE 1 ACTION OKPROC()
@ 61,130 BMPBUTTON TYPE 2 ACTION CLOSE(ODLG5)

ACTIVATE DIALOG ODLG5 CENTERED

RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    �OKPROC    � AUTOR � MADALENO              � DATA � 30.12.08 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O �CONFIRMA O PROCESSAMENTO                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION OKPROC()
PROCESSA( {|| RUNPROC() } )
CLOSE(ODLG5)
RETURN

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���FUN��O    �RUNPROC   � AUTOR � MADALENO              � DATA � 31.12.08 ���
�������������������������������������������������������������������������Ĵ��
���DESCRI��O �EXECUTA O PROCESSAMENTO                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION RUNPROC()
RECLOCK("SE1", .F.)
SE1->E1_HIST := WOBS
DBUNLOCK()
RETURN