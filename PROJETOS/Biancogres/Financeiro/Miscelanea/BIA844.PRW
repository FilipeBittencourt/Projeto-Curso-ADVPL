#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
���������������������������������������������������������������������������
���������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ��
���Programa  � BIA844 �Autor  � Ranisses A. Corona � Data �  24/02/11   ���
�����������������������������������������������������������������������͹��
���Descr.    � Transfere todos as Localizacoes para Localizacao Padrao  ���
�����������������������������������������������������������������������͹��
���Uso       � Sigaest - Sera utilizado na migracao Ecosis              ���
�����������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������
���������������������������������������������������������������������������
*/
USER FUNCTION BIA844()
Local cSql	:= ""
Local cNome	:= ""
        
If !Empty(Alltrim(M->Z01_CNPJGR))
	cSql := "SELECT MAX(A1_NOME) NOME FROM SA1010 WHERE SUBSTRING(A1_CGC,1,8) = '"+M->Z01_CNPJGR+"' AND D_E_L_E_T_ = '' "
	If CHKFILE("_TMP")
		dbSelectArea("_TMP")
		dbCloseArea()
	EndIf
	TcQuery cSql ALIAS "_TMP" NEW

	cNome := _TMP->NOME                        

Else

	cNome := ""

EndIf
	
Return(cNome)