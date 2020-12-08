#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA496A    � Autor � Wanisay William       � Data � 22.05.12      ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Envia o estoque da consulta F6 para os representantes             ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador xBase                                               ���
���������������������������������������������������������������������������������ı�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
/*/{Protheus.doc} BIA496A
@description Envia workflow de estoque disponivel para os representantes
@author NDA
@since 22/05/12
@version 1.0
@type function
/*/

User Function BIA496A()
Local aEmp := {}
Local nCount := 0
	
	aAdd(aEmp, "01")
	aAdd(aEmp, "05")
	aAdd(aEmp, "13")
	aAdd(aEmp, "07")
	
	For nCount := 1 To Len(aEmp)
			
		RpcSetType(3)
		RpcSetEnv(aEmp[nCount], "01")
			
			U_BIA496(aEmp[nCount])
			
			If (aEmp[nCount] != '07')
				// Envia WF de estoque de Amostra
				U_BIA496(aEmp[nCount], .T.)
			EndIf
			
		RpcClearEnv()

	Next

Return()