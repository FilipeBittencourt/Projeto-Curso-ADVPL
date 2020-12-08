#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA467()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � BIA467     � Autor � WANISAY WILLIAM       � Data � 31/12/10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � AXCADASTRO FORMATO X LINHA/COR                               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Interpretador x Base                                         ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
AXCADASTRO("ZZN","FORMATO X LINHA/COR")

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//-----------------------------------------------------------------------------------------------
// (Thiago Dantas - 09/04/14) - Traz a descri��o da Linha + Formato para visualiza��o.
//-----------------------------------------------------------------------------------------------
User Function GetDescLC()
	cDescLin := ''
	If !Empty(M->ZZN_FORMAT) .And. !Empty(M->ZZN_LINHA)
	    //Linha/Cor + Formato
		cDescLin := AllTrim(ZZ7->ZZ7_DESC) + ' ' + AllTrim(ZZ6->ZZ6_DESC)
	EndIf
Return cDescLin
//-----------------------------------------------------------------------------------------------
User Function IniDescLC ()
	cDescLin := AllTrim(POSICIONE("ZZ7",1, XFILIAL("ZZ7")+ZZN->ZZN_LINHA,"ZZ7_DESC"))
	cDescLin += ' ' + AllTrim(POSICIONE("ZZ6",1, XFILIAL("ZZ6")+ZZN->ZZN_FORMAT,"ZZ6_DESC"))
Return cDescLin
//-----------------------------------------------------------------------------------------------