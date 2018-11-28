#Include 'Protheus.ch'
#Include 'Parmtype.ch'

User Function MBROWSE2()

	Local cAlias  		:= "ZXV"
	Local aCores			:= {}
	//Local cFiltra			:= "ZXV_FILIAL == '"+xFilial('ZXV')+"' .AND. ZXV_   "
	Private cCadastro		:= "Cadastro de Contatos"
	Private aRotina		:= {}
	Private aIndexZXV		:= {}
	Private bFiltraBrW	:= {}
	
	
	aRotina := {;
	{"Pesquisar" 	, "AxPesqui"  	, 0, 1},;     
	{"Visualizar"	, "AxVisual"  	, 0, 2},; 
	{"Incluir"		, "U_BInclui" 	, 0, 3},;
	{"Alterar"		, "U_BAltera" 	, 0, 4},;
	{"Excluir"		, "U_BDeleta" 	, 0, 5},;
	{"Legenda"	    , "U_BLegenda"	, 0, 6}};	 
	 
	//A CORES
	AADD(aCores,{"ZXV_STATUS == 'A'", "BR_VERDE" })
	AADD(aCores,{"ZXV_STATUS == 'D'", "BR_VERMELHO" }) 
	 
	
	DbSelectArea(cAlias) // SELECT * FROM SB1
	cAlias->(DbSetOrder(1)) // order by pelo indice 1
	cAlias->(DbGoTop()) // Seleciona o primeiro registro	
	mBrowse(6,1,22,75,cAlias,,,,,,aCores)
	
Return Nil

//------------------------------
//INCLUI
//------------------------------
User Function BInclui(cAlias, nReg, nOpc)
	Local nOpcao := 0
	nOpcao := AxInclui(cAlias, nReg, nOpc)
	If(nOpcao == 1)
		MsgInfo("Inclusão realizada com sucesso!")
	Else
		MsgAlert("Inclusão cancelada!")
	EndIf

Return


//------------------------------
//ALTERA
//------------------------------
User Function BAltera(cAlias, nReg, nOpc)
	Local nOpcao := 0
	nOpcao := AxAltera(cAlias, nReg, nOpc)
	If(nOpcao == 1)
		MsgInfo("Alteração realizada com sucesso!")
	Else
		MsgAlert("Alteração cancelada!")
	EndIf

Return


//------------------------------
//DELETA
//------------------------------
User Function BAltera(cAlias, nReg, nOpc)
	Local nOpcao := 0
	nOpcao := AxDeleta(cAlias, nReg, nOpc)
	If(nOpcao == 1)
		MsgInfo("Exclusão realizada com sucesso!")
	Else
		MsgAlert("Exclusão cancelada!")
	EndIf

Return




//------------------------------
//Legenda
//------------------------------
User Function BLegenda()
	Local aLegenda := {;
		{"BR_VERDE","Ativo"},;
		{"BR_VERMELHO","Bloqueado"};
	}
	BRWLegenda(cCadastro,"Legenda",aLegenda)

Return

