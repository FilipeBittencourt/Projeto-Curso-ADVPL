#Include 'Protheus.ch'
#Include 'Parmtype.ch'

User Function MBROWSE1()

	Local cAlias  := "ZXV"
	Private cTitulo := "Cadastro de Contatos"
	Private aRotina := {}
	
	
	aRotina := {;
	{"Pesquisar" 	,"AxPesqui" , 0, 1},;     
	{"Visualizar"	,"AxVisual" , 0, 2},; 
	{"Incluir"		,"AxInclui" , 0, 3},;
	{"Alterar"		,"AxAltera" , 0, 4},;
	{"Excluir"		,"AxDeleta" , 0, 5},;
	{"OlaMundo"	,"U_OLAMUNDO" , 0, 6},;	 
	{"Legenda"    ,"AxPesqui" , 0, 2}}
	
	DbSelectArea(cAlias) // SELECT * FROM SB1
	cAlias->(DbSetOrder(1)) // order by pelo indice 1
	cAlias->(DbGoTop()) // Seleciona o primeiro registro
	mBrowse(,,,,cAlias)
	//mBrowse(6,1,22,75,cAlias)
	
Return Nil

