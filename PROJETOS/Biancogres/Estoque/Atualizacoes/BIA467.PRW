#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA467()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA467     � Autor � WANISAY WILLIAM       � Data � 31/12/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � AXCADASTRO FORMATO X LINHA/COR                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
AXCADASTRO("ZZN","FORMATO X LINHA/COR")

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//-----------------------------------------------------------------------------------------------
// (Thiago Dantas - 09/04/14) - Traz a descri玢o da Linha + Formato para visualiza玢o.
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