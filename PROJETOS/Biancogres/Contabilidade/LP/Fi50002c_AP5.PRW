#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Fi50002c()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CALIAS,CCONTA,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � 50002C   � Autor � Joao Carlos Andrade   � Data � 20/12/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Execblock para permitir a contabilizacao da implantacao    ���
���          � de titulos no contas a receber                             ���
���          � Lancamento Padronizado 50002 ( Conta a Credito )           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico: BIANCOGRES S/A                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
cAlias := Alias()
cConta := ""

DbSelectArea("SED")
If DbSeek(xFilial("SED")+SE1->E1_NATUREZ,.F.)
	cConta := SED->ED_YCTAREC
Endif

DbSelectArea(cAlias)

Return(cConta)