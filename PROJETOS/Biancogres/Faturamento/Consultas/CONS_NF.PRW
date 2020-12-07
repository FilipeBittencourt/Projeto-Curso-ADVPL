#INCLUDE "MATC090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CONS_NF  ³ Rev.  ³ BRUNO MADALENO        ³ Data ³25.05.2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta Nota Fiscal de Saida.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function CONS_NF()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aCores    := {}       

	//Variavel utilizada para filtrar as NF's de cada Representante.
	Local cFiltro	:= ""

	//Monta filtro
	cFiltro := "(F2_VEND1 = '"+cRepAtu+"' OR F2_VEND2 = '"+cRepAtu+"' OR F2_VEND3 = '"+cRepAtu+"' OR "
	cFiltro += " R_E_C_N_O_ IN 															"
	cFiltro += "     		(SELECT SF2.R_E_C_N_O_										"
	cFiltro += "			FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2	"
	cFiltro += "			WHERE	SF2.F2_FILIAL 	= '"+xFilial("SF2")+"'	AND			"
	cFiltro += "					SD2.D2_FILIAL	= '"+xFilial("SD2")+"' 	AND			"
	cFiltro += "					SF2.F2_DOC 		= SD2.D2_DOC 			AND 		"
	cFiltro += "					SF2.F2_SERIE 	= SD2.D2_SERIE 			AND 		"
	cFiltro += "					SF2.F2_CLIENTE 	= SD2.D2_CLIENTE 		AND 		"
	cFiltro += "					SF2.F2_LOJA 	= SD2.D2_LOJA 			AND 		"
	cFiltro += "					SF2.F2_EMISSAO	>= '"+Dtos(ddatabase - 90)+"' AND 	"
	cFiltro += "					SD2.D_E_L_E_T_ 	= '' 					AND 		"
	cFiltro += "					SF2.D_E_L_E_T_ 	= '' 					AND 		"
	cFiltro += "					SD2.D2_PEDIDO IN (SELECT C5_YPEDORI FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YEMPPED = '"+cEmpant+"' AND (C5_VEND1 = '"+cRepAtu+"' OR C5_VEND2 = '"+cRepAtu+"' OR C5_VEND3 = '"+cRepAtu+"') AND D_E_L_E_T_ = ''))) AND F2_EMISSAO >= '"+Dtos(ddatabase - 90)+"'  "

	IF cPaisLoc == "BRA"
		aCores    := {	{  'F2_TIPO=="N"'	, 'DISABLE'}	,;	// NF Normal
		{  'F2_TIPO=="P"'	, 'BR_AZUL'}	,;	// NF de Compl. IPI
		{  'F2_TIPO=="I"'	, 'BR_MARRON'}	,;	// NF de Compl. ICMS
		{  'F2_TIPO=="C"'	, 'BR_PINK'}	,;	// NF de Compl. Preco/Frete
		{  'F2_TIPO=="B"'	, 'BR_CINZA'}	,;	// NF de Beneficiamento
		{  'F2_TIPO=="D"'	, 'BR_AMARELO'} }	// NF de Devolucao
	Else
		AAdd(aCores,{	'F2_TIPO	==	"N" .And. F2_TIPODOC	==	"01"'	, 'DISABLE'})		// NF Normal
		AAdd(aCores,{  	'F2_TIPO	==	"C"	.And. F2_TIPODOC	$	"02/03"', 'BR_PINK'})		// NF de Compl. Preco/Frete
		AAdd(aCores,{  	'F2_TIPO	==	"B"	'								, 'BR_CINZA'})		// NF de Beneficiamento
		AAdd(aCores,{  	'F2_TIPO	==	"D"	.And. F2_TIPODOC	$	"06/07"', 'BR_AMARELO'}) 	// NF de Devolucao
		AAdd(aCores,{  	'F2_TIPO	==	"D"	.And. F2_TIPODOC	==	"61"' 	, 'BR_AZUL'})		// Remito de devolucao
		AAdd(aCores,{  	'F2_TIPO	==	"N"	.And. F2_TIPODOC	==	"50"' 	, 'BR_MARRON'})		// Remito 
		AAdd(aCores,{  	'F2_TIPO	==	"B"	.And. F2_TIPODOC	==	"54"'   , 'BR_PRETO'}) 		// Remito transferencia
	Endif

	Private aRotina := MenuDef()				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCadastro := IIf(cPaisLoc=="BRA",STR0004,STR0011) //"Consulta Nota Fiscal de Saida" ## "Consulta Documentos de Saida"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	mBrowse(6,1,22,75,"SF2",,,,,,aCores,,,,,,,,cFiltro)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mc090Visual³ Autor ³ Edson Maricate       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para visualizacao de NF de Saida.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void Mc090Visual(ExpC1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN2 = Numero do registro                                 ³±±
±±³          ³ ExpN3 = Opcao da Mbrowse                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function Mc090Visual(cAlias,nReg,nOpc)

	Local aArea      := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSD2   := SD2->(GetArea())

	Local lQuery     := .F.
	Local cAliasSD2  := "SD2"
	Local hj

	#IFDEF TOP
	Local cQuery     := ""
	#ENDIF	

	IF ! SA1->(DBSEEK ( xFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		RETURN
	ENDIF

	IF SF2->F2_CLIENTE == '010064' .AND. DTOS(SF2->F2_EMISSAO) >= '20120101' 

		//Busca todos os pedidos
		aPedido := U_fBuscaPedido(SF2->F2_FILIAL,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA)

		//Roda todos pedidos
		For hj := 1 to Len(aPedido)
			If hj > 1
				nPedido := nPedido+","
			EndIf
			nPedido := "'"+aPedido[hj]+"'"
		Next hj	

		cQuery := ""
		cQuery := "SELECT MAX(C5_VEND1) AS C5_VEND1 FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI IN ("+nPedido+") AND C5_YEMPPED = '"+cEmpAnt+"' AND D_E_L_E_T_ = '' "
		IF chkfile("cTrab")
			dbSelectArea("cTrab")
			dbCloseArea()
		ENDIF
		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery ALIAS "cTrab" NEW
		cTrab->(dbGoTop())            

		IF !EMPTY(cTrab->C5_VEND1)
			IF SUBSTRING(CREPATU,1,1) == "1"
				IF CEMPANT == "01"
					IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
						ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA")
						RETURN
					ENDIF
				ELSE
					IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
						ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA")
						RETURN
					ENDIF		
				ENDIF	
			ELSE	
				IF cTrab->C5_VEND1 <> CREPATU
					ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA - LM")
					RETURN
				ENDIF
			ENDIF	    
		ELSE
			ALERT("CLIENTE NÃO ENCONTRADO NA EMPRESA LM")
			RETURN
		ENDIF
	ELSE
		// VERIFICANDO SE E O GERENTE // BRUNO MADALENO 
		IF SUBSTRING(CREPATU,1,1) = "1"
			IF CEMPANT == "01"
				IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
					ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA")
					RETURN
				ENDIF
			ELSE
				IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
					ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA")
					RETURN
				ENDIF		
			ENDIF	
		ELSE	
			IF SF2->F2_VEND1 <> CREPATU
				ALERT("CLIENTE NÃO PERTENCE A SUA CARTEIRA")
				RETURN
			ENDIF
		ENDIF	    
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a pilha da funcao fiscal                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()

	dbSelectArea("SD2")
	dbSetOrder(3)
	#IFDEF TOP

	If TcSrvType() <> "AS/400"

		cAliasSD2 := CriaTrab(,.F.)
		lQuery := .T.
		cQuery := "SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,R_E_C_N_O_ SD2RECNO "
		cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D2_DOC='"+SF2->F2_DOC+"' AND "
		cQuery += "SD2.D2_SERIE='"+SF2->F2_SERIE+"' AND "
		cQuery += "SD2.D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND "
		cQuery += "SD2.D2_LOJA='"+SF2->F2_LOJA+"' AND "
		cQuery += "SD2.D2_TIPO='"+SF2->F2_TIPO+"' AND "
		cQuery += "SD2.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	Else		
		#ENDIF
		MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		#IFDEF TOP
	Endif	
	#ENDIF

	While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
	SF2->F2_DOC == (cAliasSD2)->D2_DOC .And.;
	SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
	SF2->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
	SF2->F2_LOJA == (cAliasSD2)->D2_LOJA
		If SF2->F2_TIPO == (cAliasSD2)->D2_TIPO
			If lQuery
				SD2->(MsGoto((cAliasSD2)->SD2RECNO))
			EndIf
			A920NFSAI("SD2",SD2->(RecNo()),0)
			Exit
		EndIf
		dbSelectArea(cAliasSD2)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a pilha da funcao fiscal                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisRestore()
	RestArea(aAreaSD2)
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return (.T.)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MC090Legend³ Autor ³ Edson Maricate       ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATC090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function MC090Legend()
	If cPaisLoc == "BRA"
		BrwLegenda(cCadastro,STR0003,{{"DISABLE",STR0005} ,; //"Legenda"###"NF Normal"
		{"BR_AZUL",STR0006},; //"NF de Compl. IPI"
		{"BR_MARRON",STR0007},; //"NF de Compl. ICMS"
		{"BR_PINK",STR0008},; //"NF de Compl. Preco/Frete"
		{"BR_CINZA",STR0009},; //"NF de Beneficiamento"
		{"BR_AMARELO",STR0010 }} ) //"NF de Devolucao"
	Else
		LocxLegenda("SF2",.F.,STR0012)
	Endif
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

	Private aRotina := {	{ STR0001,"AxPesqui"		,0,1,0,.F.},;		// "Pesquisar"
	{ STR0002,"U_MC090Visual"	,0,2,0,NIL},;		// "Visualizar"
	{ STR0003,"MC090Legend"	,0,5,0,NIL} }	 	// "Legenda"

Return(aRotina)
