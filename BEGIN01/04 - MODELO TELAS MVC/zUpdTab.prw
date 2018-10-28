//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} zUpdTab
Função que cria tabelas, campos e índices para utilização nos exemplos de MVC
@type function
@author Atilio
@since 23/04/2016
@version 1.0
/*/

User Function zUpdTab()
	Local aArea := GetArea()
	
	Processa( {|| fAtualiza()}, "Processando...")
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fAtualiza                                                    |
 | Autor: Daniel Atilio                                                |
 | Data:  23/04/2016                                                   |
 | Desc:  Função que chama as rotinas para criação                     |
 *---------------------------------------------------------------------*/

Static Function fAtualiza()
	ProcRegua(6)
	
	//WW1 - Artistas
	IncProc('Atualizando WW1 - Artistas...')
	fAtuWW1()
	
	//WW2 - CDs
	IncProc('Atualizando WW2 - CDs...')
	fAtuWW2()
	
	//WW3 - Músicas do CD
	IncProc('Atualizando WW3 - Músicas do CD...')
	fAtuWW3()
	
	//WW4 - Venda de CDs
	IncProc('Atualizando WW4 - Venda de CDs...')
	fAtuWW4()
Return

/*---------------------------------------------------------------------*
 | Func:  fAtuWW1                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  23/04/2016                                                   |
 | Desc:  Função que cria a tabela WW1                                 |
 *---------------------------------------------------------------------*/

Static Function fAtuWW1()
	Local aSX2 := {}
	Local aSX3 := {}
	Local aSIX := {}
	
	//Tabela
	//			01			02						03		04			05
	//			Chave		Descrição				Modo	Modo Un.	Modo Emp.
	aSX2 := {	'WW1',		'Artista',				'C',	'C',		'C'}
	
	//Campos
	//				01				02			03								04			05		06					07								08						09		10			11		12				13			14			15			16		17			18				19			20			21
	//				Campo			Filial?	Tamanho						Decimais	Tipo	Titulo				Descrição						Máscara				Nível	Vld.Usr	Usado	Ini.Padr.		Cons.F3	Visual		Contexto	Browse	Obrigat	Lista.Op		Mod.Edi	Ini.Brow	Pasta
	aAdd(aSX3,{	'WW1_FILIAL',	.T.,		FWSizeFilial(),				0,			'C',	"Filial",			"Filial do Sistema",			"",						1,		"",			.F.,	"",				"",			"",			"",			"N",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW1_COD',		.F.,		06,								0,			'C',	"Codigo",			"Codigo Artista",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW1_DESC',	.F.,		50,								0,			'C',	"Descricao",		"Descricao / Nome",			"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	
	//Índices
	//				01			02			03							04				05				06			07
	//				Índice		Ordem		Chave						Descrição		Propriedade	NickName	Mostr.Pesq
	aAdd(aSIX,{	"WW1",		"1",		"WW1_FILIAL+WW1_COD",	"Codigo",		"U",			"",			"S"})
		
	//Criando os dados
	u_zCriaTab(aSX2, aSX3, aSIX)
Return

/*---------------------------------------------------------------------*
 | Func:  fAtuWW2                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  23/04/2016                                                   |
 | Desc:  Função que cria a tabela WW2                                 |
 *---------------------------------------------------------------------*/

Static Function fAtuWW2()
	Local aSX2 := {}
	Local aSX3 := {}
	Local aSIX := {}
	
	//Tabela
	//			01			02						03		04			05
	//			Chave		Descrição				Modo	Modo Un.	Modo Emp.
	aSX2 := {	'WW2',		'CDs',					'C',	'C',		'C'}
	
	//Campos
	//				01				02			03								04			05		06					07								08						09		10			11		12				13			14			15			16		17			18				19			20			21
	//				Campo			Filial?	Tamanho						Decimais	Tipo	Titulo				Descrição						Máscara				Nível	Vld.Usr	Usado	Ini.Padr.		Cons.F3	Visual		Contexto	Browse	Obrigat	Lista.Op		Mod.Edi	Ini.Brow	Pasta
	aAdd(aSX3,{	'WW2_FILIAL',	.T.,		FWSizeFilial(),				0,			'C',	"Filial",			"Filial do Sistema",			"",						1,		"",			.F.,	"",				"",			"",			"",			"N",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_CODART',	.F.,		06,								0,			'C',	"Cod. Artista",	"Codigo Artista",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_CODCD',	.F.,		06,								0,			'C',	"Cod. CD",			"Codigo CD",					"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_DESC',	.F.,		50,								0,			'C',	"Descricao",		"Descricao / Nome",			"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_PRECO',	.F.,		06,								2,			'N',	"Preco",			"Preco",						"@E 999.99",			1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	
	//Índices
	//				01			02			03										04									05				06			07
	//				Índice		Ordem		Chave									Descrição							Propriedade	NickName	Mostr.Pesq
	aAdd(aSIX,{	"WW2",		"1",		"WW2_FILIAL+WW2_CODCD",				"Codigo CD",						"U",			"",			"S"})
	aAdd(aSIX,{	"WW2",		"2",		"WW2_FILIAL+WW2_CODART+WW2_CODCD",	"Codigo Artista + Codigo CD",	"U",			"",			"S"})
		
	//Criando os dados
	u_zCriaTab(aSX2, aSX3, aSIX)
Return

/*---------------------------------------------------------------------*
 | Func:  fAtuWW3                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  23/04/2016                                                   |
 | Desc:  Função que cria a tabela WW3                                 |
 *---------------------------------------------------------------------*/

Static Function fAtuWW3()
	Local aSX2 := {}
	Local aSX3 := {}
	Local aSIX := {}
	
	//Tabela
	//			01			02						03		04			05
	//			Chave		Descrição				Modo	Modo Un.	Modo Emp.
	aSX2 := {	'WW3',		'Musicas do CD',		'C',	'C',		'C'}
	
	//Campos
	//				01				02			03								04			05		06					07								08						09		10			11		12				13			14			15			16		17			18				19			20			21
	//				Campo			Filial?	Tamanho						Decimais	Tipo	Titulo				Descrição						Máscara				Nível	Vld.Usr	Usado	Ini.Padr.		Cons.F3	Visual		Contexto	Browse	Obrigat	Lista.Op		Mod.Edi	Ini.Brow	Pasta
	aAdd(aSX3,{	'WW3_FILIAL',	.T.,		FWSizeFilial(),				0,			'C',	"Filial",			"Filial do Sistema",			"",						1,		"",			.F.,	"",				"",			"",			"",			"N",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW3_CODART',	.F.,		06,								0,			'C',	"Cod. Artista",	"Codigo Artista",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW3_CODCD',	.F.,		06,								0,			'C',	"Cod. CD",			"Codigo CD",					"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW3_CODMUS',	.F.,		06,								0,			'C',	"Cod. Musica",	"Codigo Musica",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW3_DESC',	.F.,		50,								0,			'C',	"Descricao",		"Descricao / Nome",			"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	
	//Índices
	//				01			02			03													04													05				06			07
	//				Índice		Ordem		Chave												Descrição											Propriedade	NickName	Mostr.Pesq
	aAdd(aSIX,{	"WW3",		"1",		"WW3_FILIAL+WW3_CODCD+WW3_CODMUS",				"Codigo CD + Codigo Musica",					"U",			"",			"S"})
	aAdd(aSIX,{	"WW3",		"2",		"WW3_FILIAL+WW3_CODART+WW3_CODCD+WW3_CODMUS",	"Codigo Artista + Codigo CD + Codigo Musica",	"U",			"",			"S"})
		
	//Criando os dados
	u_zCriaTab(aSX2, aSX3, aSIX)
Return

/*---------------------------------------------------------------------*
 | Func:  fAtuWW4                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  23/04/2016                                                   |
 | Desc:  Função que cria a tabela WW4                                 |
 *---------------------------------------------------------------------*/

Static Function fAtuWW4()
	Local aSX2 := {}
	Local aSX3 := {}
	Local aSIX := {}
	
	//Tabela
	//			01			02						03		04			05
	//			Chave		Descrição				Modo	Modo Un.	Modo Emp.
	aSX2 := {	'WW4',		'Vendas dos CDs',		'C',	'C',		'C'}
	
	//Campos
	//				01				02			03								04			05		06					07								08						09		10			11		12				13			14			15			16		17			18				19			20			21
	//				Campo			Filial?	Tamanho						Decimais	Tipo	Titulo				Descrição						Máscara				Nível	Vld.Usr	Usado	Ini.Padr.		Cons.F3	Visual		Contexto	Browse	Obrigat	Lista.Op		Mod.Edi	Ini.Brow	Pasta
	aAdd(aSX3,{	'WW4_FILIAL',	.T.,		FWSizeFilial(),				0,			'C',	"Filial",			"Filial do Sistema",			"",						1,		"",			.F.,	"",				"",			"",			"",			"N",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW4_CODVEN',	.F.,		06,								0,			'C',	"Codigo",			"Codigo Venda",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW4_DESC',	.F.,		50,								0,			'C',	"Descricao",		"Descricao / Nome",			"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW4_CODCD',	.F.,		06,								0,			'C',	"Codigo CD",		"Codigo do CD",				"@!",					1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_QUANT',	.F.,		03,								0,			'N',	"Quantidade",		"Quantidade",					"@E 999",				1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_PRECO',	.F.,		06,								2,			'N',	"Preco",			"Preco",						"@E 999.99",			1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	aAdd(aSX3,{	'WW2_TOTAL',	.F.,		08,								2,			'N',	"Total",			"Total",						"@E 99,999.99",		1,		"",			.T.,	"",				"",			"A",		"R",		"S",	.T.,		"",				"",			"",			""})
	
	//Índices
	//				01			02			03							04				05				06			07
	//				Índice		Ordem		Chave						Descrição		Propriedade	NickName	Mostr.Pesq
	aAdd(aSIX,{	"WW4",		"1",		"WW4_FILIAL+WW4_CODVEN",	"Codigo",		"U",			"",			"S"})
		
	//Criando os dados
	u_zCriaTab(aSX2, aSX3, aSIX)
Return