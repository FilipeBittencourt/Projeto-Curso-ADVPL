#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function PARCRYS()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CALLCRYS  � Autora� M�rcia Tokura         � Data � 10/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exemplo da chamada de um relat�rio Crystal atrav�s do rdmake���
�������������������������������������������������������������������������Ĵ��
���Uso       �Advanced 407 e Protheus                                     ���
�������������������������������������������������������������������������Ĵ��
���SINTAXE DA�CALLCRYS(<creport>,<cparam>,<copcoes>) onde                 ���
���FUN��O    �<creport>= Nome do relat�rio Crystal,localizado no diret�rio���
���CALLCRYS  �          apontado por MV_CRYSTAL, sem a extens�o e path.   ���
���          �<cparam> = Par�metros passados para o Crystal, em vez de usar���
���          �          o SX1, separados por v�rgula ou ponto e v�rgula.  ���
���          �<copcoes>= Conjunto de op��es para nao mostrar a tela da    ���
���          �           SetPrint, composta por x;y;z;w, onde             ���
���          �                         x = v�deo(1) ou impressora(3)      ���
���          �                         y = Atualiza(0) ou n�o(1) os dados ���
���          �                         z = N�mero de c�pias               ���
���          �                         w = T�tulo do repo                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Private x:="1;0;1;TESTE DE PARAMETROS"
Emp := SM0->M0_NOME
Cod := SM0->M0_CODIGO
CALLCRYS("PARAM",Emp+";"+Cod,x)
Return

