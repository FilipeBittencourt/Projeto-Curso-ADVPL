#include "rwmake.ch"

User Function BIA139()

SetPrvt("XXN,XCCAMPO,WPROD,WCLVL,")

/*�����������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � BIA139	  � Autor � MICROSIGA VITORIA 	  � Data � 11/06/99 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obriga a digitacao do Classe de Valor   Solicitacao/Pedido 	���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Interpretador x Base 										���
����������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Private nPosProd, nPosCLVL

nPosProd := Ascan(aHeader,{|x| x[2] == "D1_COD    "})
nPosCLVL := Ascan(aHeader,{|x| x[2] == "D1_CLVL   "})

wProd := aCols[n,nPosProd]
wCLVL := aCols[n,nPosCLVL]

If Len(Alltrim(wProd)) == 7 .and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0
	MsgStop("Para este Produto e obrigatorio a Classe de Valor...")
	wCLVL := ""
EndIf

Return(wCLVL)