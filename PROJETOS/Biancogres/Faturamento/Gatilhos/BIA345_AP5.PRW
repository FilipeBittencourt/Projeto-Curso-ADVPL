#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

User Function BIA345()        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("WSYOUTDSC,WSMV,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA345   � Autor � Magnago               � Data � 09/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Bloqueia a Liberacao dos Pedidos de Vendas                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RDMAKE                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
IF ALLTRIM(FUNNAME()) <> "EECAP100"
	wsYoutDsc := M->C5_YPERC
	wLinha    := M->C5_YLINHA
	
	If wLinha == "1"
	   wsMV := GetMv("MV_YMAXPER")
	else
	   wsMV := GetMv("MV_YMXPER2")
	endif
	
	If wsYoutDsc > wsMV
	   MsgAlert("O Percentual Digitado e Maior do que o Limite de "+Str(wsMV)+"%")
	   wsYoutDsc := 0
	EndIf
ELSE
	wsYoutDsc := M->EE7_YPERC
	wLinha    := M->EE7_YLINHA
	
	If wLinha == "1"
	   wsMV := GetMv("MV_YMAXPER")
	else
	   wsMV := GetMv("MV_YMXPER2")
	endif
	
	If wsYoutDsc > wsMV
	   MsgAlert("O Percentual Digitado e Maior do que o Limite de "+Str(wsMV)+"%")
	   wsYoutDsc := 0
	EndIf

END IF
// Substituido pelo assistente de conversao do AP5 IDE em 24/05/02 ==> __Return(wsYoutDsc)
Return(wsYoutDsc)        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02