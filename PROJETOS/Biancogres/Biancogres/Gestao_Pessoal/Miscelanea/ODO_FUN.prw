#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � CAL_ODO_FUN� AUTOR � MADALENO              � DATA � 05/01/09 ���
���������������������������������������������������������������������������Ĵ��
���DESCRI��O � CALCULA O PLANO ODONTOLOGIOCO DO FUNCIONARIO                 ���
���������������������������������������������������������������������������Ĵ��
��� USO      � PROTHEUS R4                                                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
USER FUNCTION ODO_FUN()
PRIVATE CVERBA 			:= ""
PRIVATE NVAL 			:= 0


IF UPPER(ALLTRIM(FUNNAME())) <> "GPEM020" .AND. UPPER(ALLTRIM(FUNNAME())) <> "GPEM040"
	RETURN
END IF

NVAL	:= 0
IF SRA->RA_ASMEDIC = "E4" .OR. SRA->RA_ASMEDIC = "E5"
	NVAL 	:= 0.95
	CVERBA 	:= "532"
END IF

FGERAVERBA(CVERBA,NVAL,,,,,,,,,)



RETURN