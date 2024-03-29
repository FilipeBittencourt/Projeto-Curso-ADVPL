#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01
#INCLUDE "topconn.ch"

User Function BIA454()        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA454   � Autor � Microsiga             � Data � 25/03/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para atualizar o custo fixo dos produtos         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: BIANCOGRES S/A                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

IF INCLUI
	cFormato := M->ZZ6_COD
ELSE
	cFormato := ZZ6->ZZ6_COD
ENDIF


cSql := ""
cSql += "UPDATE SB1010 "
cSql += "SET B1_YCF = '" + ALLTRIM(STR(M->ZZ6_CF)) +" '"
cSql += "FROM SB1010 SB1, ZZ6010 ZZ6 "
cSql += "WHERE B1_YFORMAT = ZZ6_COD "
cSql += "AND B1_YFORMAT = '" + cFormato +" '"
cSql += "AND SB1.D_E_L_E_T_ = ' ' "
cSql += "AND ZZ6.D_E_L_E_T_ = ' ' "
TCSQLExec(cSql)

Return(M->ZZ6_CF)
