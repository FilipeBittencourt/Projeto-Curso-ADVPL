#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/*/{Protheus.doc} AxCadastro
Função para cadastro de CHAMADOS - PROJETOS DE CHAMADOS
@author FILPE
@since 27/10/2018
@version 1.0
	@return Nil, Função não tem retorno
	@example
	U_ZZD00001()
/*/
User Function ZZD00001()

	//AxCadastro("ZZD","Cadastro de chamados")
	Local aCores			:= {}
	Private cCadastro		:= "Cadastro de chamados"
	Private aRotina		:= {}
	
	aRotina := {;
	{"Pesquisar" 	, "AxPesqui"  	, 0, 1},;     
	{"Visualizar"	, "AxVisual"  	, 0, 2},; 
	{"Incluir"		, "AxInclui" 		, 0, 3},;
	{"Alterar"		, "AxAltera" 		, 0, 4},;
	{"Excluir"		, "AxDeleta" 		, 0, 5},;
	{"Legenda"	    , "U_ZZDLEGEN()" 	, 0, 6}}
	
	AADD(aCores,{"ZZD_STATUS == '1' .OR. Empty(ZZD->ZZD_STATUS)", "BR_VERDE" })
	AADD(aCores,{"ZZD_STATUS == '2'", "BR_AZUL" })
	AADD(aCores,{"ZZD_STATUS == '3'", "BR_AMARELO" })
	AADD(aCores,{"ZZD_STATUS == '4'", "BR_PRETO" })
	AADD(aCores,{"ZZD_STATUS == '5'", "BR_VERMELHO" })
	
	mBrowse(6,1,22,75,"ZZD",,,,,,aCores) 

Return


User Function ZZDLEGEN()

	Local aLegenda := {{"BR_VERDE","Aberto"},;
		{"BR_AZUL","Em atendimento"},;
		{"BR_AMARELO","Aguardando usuário"},;
		{"BR_PRETO","Encerrado"},;
		{"BR_VERMELHO","Atrasado"}}		
	   BrwLegenda(cCadastro, "Legenda", aLegenda)		
Return