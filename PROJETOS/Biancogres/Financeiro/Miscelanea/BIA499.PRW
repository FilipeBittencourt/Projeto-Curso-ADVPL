#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA499()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA425     � Autor � WANISAY WILLIAM       � Data � 19/09/12 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � AXCADASTRO RESUMO DAS COMISS誆S                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

	Local aArea			:= GetArea()
	Local cFiltro		:= ""
	Private cCadastro	:= "RESUMO DAS COMISS誆S"
	Private aRotina		:= { }

	AADD(aRotina, { "Pesquisar"		, "AxPesqui"			, 0, 1 })
	AADD(aRotina, { "Visualizar"	, "AxVisual"			, 0, 2 })
	AADD(aRotina, { "Incluir"		, "AxInclui"			, 0, 3 })
	AADD(aRotina, { "Alterar"		, "AxAltera"			, 0, 4 })
	AADD(aRotina, { "Excluir"		, "AxDeleta"			, 0, 5 })

	DbSelectArea("ZZX")
	ZZX->(DbSetOrder(1))
	
	cFiltro := " SUBSTRING(ZZX_EMP, 1, 4) = '"+cEmpAnt+cFilAnt+"'"
	
	MBrowse( 6, 1, 22, 75, "ZZX",,,,,, ,,,,,,,,cFiltro)
	
	RestArea(aArea)

	//AxCadastro("ZZX","RESUMO DAS COMISS誆S")

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01