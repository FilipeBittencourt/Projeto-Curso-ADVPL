#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia139A()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

If UPPER(ALLTRIM(FUNNAME())) == "EICDI154"
	Return ( "" )
EndIf

If IsInCallStack("MATA140")
	Return ( "" )
EndIf

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("XXN,XCCAMPO,WPROD,WCLVL,")

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � BIA139	  � Autor � MICROSIGA VITORIA 	  � Data � 11/06/99 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obriga a digitacao da Classe de Valor Solicitacao/Pedido 	���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Interpretador x Base 										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Private nPosProd, nPosCC

nPosProd := Ascan(aHeader,{|x| x[2] == "D1_COD    "})
nPosCLVL := Ascan(aHeader,{|x| x[2] == "D1_CLVL   "})

wProd := aCols[n,nPosProd]
wCLVL := aCols[n,nPosCC]

if Len(Alltrim(wProd)) == 7 .and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0	
        MsgStop("Para este Produto e obrigatorio a Classe de Valor...")
	    wCLVL := ""
endif
Return(wCLVL)