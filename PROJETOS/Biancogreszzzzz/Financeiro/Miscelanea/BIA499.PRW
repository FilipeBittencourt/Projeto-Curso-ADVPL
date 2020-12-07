#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function BIA499()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA425     ³ Autor ³ WANISAY WILLIAM       ³ Data ³ 19/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ AXCADASTRO RESUMO DAS COMISSÕES                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

	Local aArea			:= GetArea()
	Local cFiltro		:= ""
	Private cCadastro	:= "RESUMO DAS COMISSÕES"
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

	//AxCadastro("ZZX","RESUMO DAS COMISSÕES")

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01