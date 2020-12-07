//#INCLUDE "MATR480.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR480  ³ Autor ³ Nereu Humberto Junior ³ Data ³ 16.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Controle de Materiais de Terceiros em nosso po-³±±
±±³          ³der e nosso Material em poder de Terceiros.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR480(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA450()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR480R3 ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12.05.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Controle de Materiais de Terceiros em nosso po-³±±
±±³          ³der e nosso Material em poder de Terceiros. (Antigo)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR480(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rodrigo     ³23/06/98³XXXXXX³Acerto no tamanho do documento para 12    ³±±
±±³            ³        ³      ³posicoes                                  ³±±
±±³Fernando J. ³08.12.98³3781A ³Substituir PesqPictQt por PescPict        ³±±
±±³CesarValadao³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³CesarValadao³04/05/99³21554A³Manutencao Lay-Out P Imprimir Quant c/ 17 ³±±
±±³CesarValadao³12/08/99³21421A³Manutencao Lay-Out P Imprimir NF Retorno  ³±±
±±³            ³        ³      ³Alinhada a NF de Origem                   ³±±
±±³Patricia Sal³13/12/99³14655A³Validacao p/Data Digitacao nas Devolucoes ³±±
±±³            ³        ³      ³Incl. Param Dt.Inicial/Final na CalcTerc()³±±
±±³Patricia Sal³20/12/99³XXXXXX³Conversao dos Campos Fornec./Cliente p/   ³±±
±±³            ³        ³      ³(20 posicoes) e Loja p/ 4 posicoes.       ³±±
±±³Iuspa       ³06/12/00³      ³Data de/ate para devolucoes               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Function Matr480R3()
LOCAL wnrel, nOrdem
LOCAL Tamanho := "G"
LOCAL cDesc1  := "Este programa ira emitir o Relatorio de Materiais"
LOCAL cDesc2  := "de Terceiros em nosso poder e/ou nosso Material em"
LOCAL cDesc3  := "poder de Terceiros."
LOCAL cString := "SB6"
LOCAL aOrd    := {" Produto/Local "," Cliente/Fornecedor "," Dt. Mov/Produto "}	

PRIVATE cCondCli, cCondFor
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }		
PRIVATE nomeprog:= "MATR480"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "MTR480"
PRIVATE Titulo  := "Relacao de materiais de Terceiros e em Terceiros"	
PRIVATE cabec1, cabec2, nTipo, CbTxt, CbCont
PRIVATE lListCustM := .T.
PRIVATE lCusFIFO   := GetMV('MV_CUSFIFO')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza variaveis static p/ Grupo de Fornec/Clientes(001) e de Loja(002)    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static aTamSXG, aTamSXG2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CbTxt := SPACE(10)
CbCont:= 00
li	  := 80
m_pag := 01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria a Pergunta Nova no Sx1                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PutSx1("MTR480","15","QTDE. na 2a. U.M. ?","CTD. EN 2a. U.M. ?","QTTY. in 2a. U.M. ?", "mv_chf", "N", 1, 0, 2,"C", "", "", "", "","mv_par15","Sim","Si","Yes", "","Nao","No","No", "", "", "", "", "", "", "", "", "", "", "", "", "")
PutSX1Help("P.MTR48015.",{'Imprime as Quantidades na 2a UM?        ', 'Sim=Utiliza a 2aUM na impressao         ', 'Nao=Utiliza a 1aUM na impressao(padrao) '}, {'Print the quantities at 2nd MU?         ', 'Yes=Uses 2nd MU at the print            ',  'No=Uses 1st MU at the print (defaut)    '}, {'¿Imprime las cantidades en la 2a UM?    ', 'Si=Utiliza la 2aUM en la impresion      ', 'No=Utiliza la 1aUM en la impresion(est.)'})

PutSx1('MTR480','16','Lista Custo        ?','¿Lista Costo       ?','List Cost          ?','mv_chg','N',01,0,1,'C','','','','','mv_par16','Medio','Promedio','Average','','FIFO/PEPS','FIFO/PEPS','FIFO','','','','','','','','','', {'Informe o tipo de custo a ser listado:  ', '1. Custo Medio                          ', '2. Custo FIFO/PEPS(p/"MV_CUSFIFO" ativo)'}, {'Inform the kind of cost to be listed:   ', '1. Average Cost                         ', '2. FIFO Cost (with "MV_CUSFIFO" active) '}, {'Informe el tipo de costo a ser listado: ', '1. Costo Promedio                       ', '2. Costo FIFO/PEPS(p/"MV_CUSFIFO"activo)'})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica conteudo da variavel p/ Grupo de Clientes/Forneced.(001) e Loja(002) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTamSXG  := If(aTamSXG  == NIL, TamSXG("001"), aTamSXG)
aTamSXG2 := If(aTamSXG2 == NIL, TamSXG("002"), aTamSXG2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("MTR480",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01   		// Cliente Inicial                		              ³
//³ mv_par02        // Cliente Final                       	              ³
//³ mv_par03        // Fornecedor Inicial                     	          ³
//³ mv_par04        // Fornecedor Final                          	      ³
//³ mv_par05        // Produto Inicial                              	  ³
//³ mv_par06        // Produto Final                         		      ³
//³ mv_par07        // Data Inicial                              	      ³
//³ mv_par08        // Data Final                                   	  ³
//³ mv_par09        // Situacao   (Todos / Em aberto)                     ³
//³ mv_par10        // Tipo   (De Terceiros / Em Terceiros / Ambos)		  ³
//³ mv_par11        // Custo em Qual Moeda  (1/2/3/4/5)             	  ³
//³ mv_par12        // Lista NF Devolucao  (Sim) (Nao)              	  ³
//³ mv_par13        // Devolucao data de                            	  ³
//³ mv_par14        // Devolucao data ate                           	  ³
//³ mv_par15        // QTDE. na 2a. U.M.? Sim / Nao                       ³
//³ mv_par16        // Lista Custo? Medio / Fifo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis p/ filtrar arquivo.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCondCli := "B6_CLIFOR   <= mv_par02 .And. B6_CLIFOR  >= mv_par01 .And."+;
			" B6_PRODUTO <= mv_par06 .And. B6_PRODUTO >= mv_par05 .And."+;
			" B6_DTDIGIT <= mv_par08 .And. B6_DTDIGIT >= mv_par07 .And."+;
			" B6_QUANT   <> 0 "
			
cCondFor := "B6_CLIFOR   <= mv_par04 .And. B6_CLIFOR  >= mv_par03 .And."+;
			" B6_PRODUTO <= mv_par06 .And. B6_PRODUTO >= mv_par05 .And."+;
			" B6_DTDIGIT <= mv_par08 .And. B6_DTDIGIT >= mv_par07 .And."+;
			" B6_QUANT   <> 0 "
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SetPrint                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "MATR480"

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Return .T.
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return .T.
Endif

RptStatus({|lEnd| R480Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 16.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R480Imp(lEnd,WnRel,cString,Tamanho)

nTipo:=IIF(aReturn[4]==1,15,18)

nOrdem := aReturn[8]

lListCustM := (mv_par16==1)

dbSelectArea("SB6")

If nOrdem == 1
	R480Prod(lEnd,Tamanho)
ElseIf nOrdem == 2
	R480CliFor(lEnd,Tamanho)
ElseIf nOrdem == 3
	R480Data(lEnd,Tamanho)
EndIf

dbSelectArea("SB6")
Set Filter To
dbSetOrder(1)

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480Prod ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Produto / LOCAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R480Prod(lEnd,Tamanho)
LOCAL cCliFor, cProdLOCAL := ""
LOCAL cQuebra,aSaldo:={}
LOCAL nCusTot := nQuant := nQuJe := nTotal := nTotDev := nTotQuant := nTotQuJe := nTotSaldo := 0
LOCAL nGerTot := nGerTotDev:=nGerCusTot:=0
LOCAL nSaldo  := 0
Local nCusto  := 0
Local nPrUnit := 0
LOCAL cSeek   := ""
LOCAL aAreaSB6:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par10 == 1
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - PRODUTO / LOCAL"
ElseIf mv_par10 == 2
	titulo := "RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - PRODUTO / LOCAL"
Else
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - PRODUTO / LOCAL"
EndIf

cabec1 := "            Cliente /        Loja  -  Documento  - Data de  Unid.de ---------------------- Quantidade ------------------- --------------- Valores -----------   Custo Prod. TM  Segunda    Quantidade      Data    Dt Ult.
cabec2 := "            Fornecedor              Numero  Serie  Emissao   Medida          Original      Ja' entregue             Saldo Total Nota Fiscal   Total Devolvido    na Moeda X     Un.Med.       Seg. UM    Lancto    Entrega
 		                	//  Cliente:XXXXXXXXXXXXXXXXXXXX XX    999999   XXX  99/99/9999   XX   99999999999999999 99999999999999999 99999999999999999 99999999999999999 99999999999999999 9999999999999  X    XX     999999999999  99/99/9999 99/99/9999
						  	//            1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
						  	//  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

dbSelectArea("SB6")
dbSetOrder(1)
dbSeek(xFilial()+mv_par05,.T.)

SetRegua(LastRec())

While !Eof() .And. B6_FILIAL == xFilial()
	
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	If !Empty(aReturn[7])
		If !&(aReturn[7])
			dbSkip()
			Loop
		EndIf
	EndIf	

	dbSelectArea("SF4")
	dbSeek(cFilial+SB6->B6_TES)
	If SF4->F4_PODER3 == "D"
		dbselectArea("SB6")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("SB6")
	
	IF	IIf(B6_TPCF == "C" , &cCondCli , &cCondFor )
		aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
		dbSelectArea("SB6")
		nSaldo  := aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
	Else
		dbSkip()
		Loop
	Endif
	
	If mv_par09 == 2 .And. nSaldo <= 0
		dbSkip()
		Loop
	EndIf
	If mv_par10 == 1 .And. B6_TIPO != "D"
		dbSkip()
		Loop
	ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
		dbSkip()
		Loop
	EndIf
	
	nCusTot:=0
	nQuant :=0
	nQuJe  :=0
	nTotal :=0
	nTotDev:=0
	nSaldo :=0
	aSaldo :={}
	nCusto :=0
	cQuebra:= B6_PRODUTO+B6_LOCAL
	
	While !Eof() .And. xFilial() == B6_FILIAL .And. cQuebra == B6_PRODUTO+B6_LOCAL
		
		IncRegua()
		
		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		If !Empty(aReturn[7])
			If !&(aReturn[7])
				dbSkip()
				Loop
			EndIf
		EndIf	

		dbSelectArea("SF4")
		dbSeek(cFilial+SB6->B6_TES)
		If SF4->F4_PODER3 == "D"
			dbselectArea("SB6")
			dbSkip()
			loop
		Endif
		
		dbSelectArea("SB6")
		
		IF	IIf(B6_TPCF == "C" , &cCondCli , &cCondFor )
			aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
			dbSelectArea("SB6")
			nSaldo  := aSaldo[1]
			nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
			If mv_par09 == 2 .And. nSaldo <= 0
				dbSkip()
				Loop
			EndIf
			If mv_par10 == 1 .And. B6_TIPO != "D"
				dbSkip()
				Loop
			ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
				dbSkip()
				Loop
			EndIf
			If cProdLOCAL != B6_PRODUTO+B6_LOCAL
				dbSelectArea("SB1")
				If dbSeek(cFilial+SB6->B6_PRODUTO)
					If !Empty(cProdLOCAL)
						li += 2
					EndIf
					If li > 55
						Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
					EndIf
					@ li,000 PSay "PRODUTO / LOCAL: "+B1_COD+" - "+Trim(Substr(B1_DESC,1,30))+" / "+SB6->B6_LOCAL		
					cProdLOCAL := SB6->B6_PRODUTO+SB6->B6_LOCAL
				Else
					Help(" ",1,"R480PRODUT")
					dbSelectArea("SB6")
					dbSetOrder(1)
					Return .F.
				EndIf
			EndIf
			dbSelectArea("SB6")
			
			If li > 55
				Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			EndIf
			
			If !Empty(cProdLocal)
				
				li++
				@ li,000 PSay IIf(B6_TPCF == "C","Clie:","Forn:")
				@ li,008 PSay (Substr(B6_CLIFOR,1,15))
				@ li,025 PSay B6_LOJA
				@ li,030 PSay B6_DOC
				@ li,045 PSay B6_SERIE
				@ li,050 PSay Dtoc(B6_EMISSAO)
				@ li,062 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
				
				// Quantidade Original
			    @ li,068 PSay If(mv_par15==1,ConvUM(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6","B6_QUANT",17)
				nQuant += If(mv_par15==1,ConvUM(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT)
				
				// Quantidade Ja Entregue
				@ li,086 PSay If(mv_par15==1,ConvUM(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo)) Picture PesqPict("SB6","B6_QUANT",17)
				nQuJe += If(mv_par15==1,ConvUM(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo))
				
				// Saldo
				@ li,104 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,nSaldo,0,2),nSaldo) Picture PesqPict("SB6", "B6_QUANT",17)
				
				// Total Nota Fiscal
			    @ li,122 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
			    nTotal += B6_QUANT * nPrUnit
			    nGerTot+= B6_QUANT * nPrUnit
				
				// Total Nota Fiscal Devolvido
				@ li,140 PSay Transform((B6_QUANT-nSaldo) * nPrUnit,'@E 99,999,999,999.99')
				nTotDev += (B6_QUANT-nSaldo) * nPrUnit
				nGerTotDev+=(B6_QUANT-nSaldo) * nPrUnit
				
				// Custo na Moeda

				nCusto := (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
				nCusTot+= nCusto
				nGerCusTot+=nCusto
				
				@ li,158 PSay Transform(nCusto,'@E 999,999,999.99')
				@ li,173 PSay B6_TIPO
				@ li,178 PSay B6_SEGUM
				@ li,184 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",12)
				@ li,199 PSay Dtoc(B6_DTDIGIT)
				@ li,210 PSay Dtoc(B6_UENT)
				
				// Lista as devolucoes da remessa
				If mv_par12 == 1 .And. ((B6_QUANT - nSaldo) > 0)
					aAreaSB6 := SB6->(GetArea())
					dbSetOrder(3)
					cSeek:=xFilial()+B6_IDENT+B6_PRODUTO+"D"
					If dbSeek(cSeek)
						li++
						@ li,000 PSay "Notas Fiscais de Retorno"
						Do While !Eof() .And. B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 == cSeek
							If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
								DbSelectArea("SB6")
								DbSkip()
								Loop
							Endif
							If li > 55
								Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
							EndIf									
							li++
							@ li,000 PSay IIf(B6_TPCF == "C","Clie:","Forn:")
							@ li,008 PSay (Substr(B6_CLIFOR,1,15))
							@ li,025 PSay B6_LOJA
							@ li,030 PSay B6_DOC
							@ li,045 PSay B6_SERIE
							@ li,050 PSay Dtoc(B6_EMISSAO)
							@ li,062 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
							// Quantidade Original
							@ li,068 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6", "B6_QUANT",17)
							
							// Total Nota Fiscal
							@ li,122 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
							@ li,173 PSay B6_TIPO
							@ li,178 PSay B6_SEGUM
							@ li,184 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",12)
							@ li,199 PSay Dtoc(B6_DTDIGIT)
							@ li,210 PSay Dtoc(B6_UENT)
							dbSkip()
						EndDo
						li++
					EndIf
					RestArea(aAreaSB6)
					dbSetOrder(1)
				EndIf
			EndIf
		EndIf
		dbSkip()
	EndDo
	If nQuant > 0
		li++
		@ li,000 PSay "TOTAL DESTE PRODUTO / LOCAL ------ >"
		@ li,068 PSay nQuant        		Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,086 PSay nQuje             	Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,104 PSay (nQuant - nQuJe)  	Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,122 PSay Transform(nTotal, '@E 99,999,999,999.99')
		@ li,140 PSay Transform(nTotDev,'@E 99,999,999,999.99')
		@ li,158 PSay Transform(nCusTot,'@E 999,999,999.99')
	    nTotQuant += nQuant
		nTotQuje  += nQuje
    	nTotSaldo += (nQuant - nQuJe)
	Endif
End

If nQuant > 0 .Or. nTotal > 0
	li++;li++
	@ li,000 PSay "T O T A L    G E R A L  ---------- >"
    @ li,068 PSay nTotQuant Picture PesqPict("SB6","B6_QUANT",17)
    @ li,086 PSay nTotQuJe Picture PesqPict("SB6","B6_QUANT",17)
    @ li,104 PSay nTotSaldo Picture PesqPict("SB6","B6_QUANT",17)
	@ li,122 PSay Transform(nGerTot	  ,'@E 99,999,999,999.99')
	@ li,140 PSay Transform(nGerTotDev,'@E 99,999,999,999.99')
	@ li,158 PSay Transform(nGerCusTot,'@E 999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480CliFor³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 12/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Cliente / Fornecedor.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R480CliFor(lEnd,Tamanho)
LOCAL cCliFor, cCliForAnt
LOCAL cQuebra,aSaldo:={}
LOCAL cIndex, cKey, nIndex, cNomeCliFor := "", cDescCliFor := ""
LOCAL cVar,cFilter
LOCAL nSaldo  := 0
LOCAL nCusto  := 0
LOCAL nPrUnit := 0
LOCAL nGerTot := nGerTotDev:=nGerCusTot:=0
LOCAL nCusTot := nQuant:=nQuJe:=nTotal:=nTotDev:= 0
LOCAL aAreaSB6:= {}
LOCAL nTotQuant := nTotQuJe := nTotSaldo := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho usando indice condicional.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB6")
cIndex  := CriaTrab(NIL,.F.)
cKey    := 'B6_FILIAL+B6_TPCF+B6_CLIFOR+B6_LOJA+B6_PRODUTO'
cFilter := SB6->(DbFilter())
If Empty( cFilter )
	cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'"'
Else
	cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'" .And. ' + cFilter
EndIf

IndRegua("SB6",cIndex,cKey,,cFilter," Criando Indice ...    ")
nIndex := RetIndex("SB6")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par10 == 1
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - CLIENTE / FORNECEDOR"
ElseIf mv_par10 == 2
	titulo := "RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - CLIENTE / FORNECEDOR"
Else
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - CLIENTE / FORNECEDOR"
EndIf
cabec1 := "                 -    Documento    -  Data de         Unid. de ---------------------- Quantidade ---------------------  ------------ Valores --------------  Custo do Prod. TM  Segunda   Quantidade     Data   Data da Ult.
cabec2 := "Produto          Numero        Serie  Emissao  Almox.  Medida        Original        Ja' entregue           Saldo       Total Nota Fiscal   Total Devolvido    na Moeda X       Unid. Med.   Seg. UM  Lancamento  Entrega
                        	// XXXXXXXXXXXXXXX  999999999999    XXX  99/99/9999 XX      XX    99999999999999999  99999999999999999  99999999999999999  99999999999999999 99999999999999999 99999999999999  X   XX      999999999999   99/99/99   99/99/99
                        	//           1         2         3         4         5         6         7         8         9         C         1         2         3         4         5         6         7         8         9         D       & 1         2
                        	// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

SetRegua(LastRec())

While !Eof()
	
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	
	dbSelectArea("SF4")
	dbSeek(cFilial+SB6->B6_TES)
	If SF4->F4_PODER3 == "D"
		dbselectArea("SB6")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("SB6")
	
	IF	IIf(B6_TPCF == "C" , &cCondCli , &cCondFor )
		aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
		dbSelectArea("SB6")
		nSaldo:= aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
	Else
		dbSkip()
		Loop
	EndIf
	
	If mv_par09 == 2 .And. nSaldo <= 0
		dbSkip()
		Loop
	EndIf
	If mv_par10 == 1 .And. B6_TIPO != "D"
		dbSkip()
		Loop
	ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
		dbSkip()
		Loop
	EndIf
	
    cQuebra  := B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF
	nCusTot  := 0
	nQuant	 := 0
	nQuJe	 := 0
	nTotal	 := 0
	nTotDev	 := 0
	
	Do While B6_CLIFOR+B6_LOJA+B6_PRODUTO+B6_TPCF == cQuebra

		IncRegua()		

		If	!(If(B6_TPCF == "C" , &cCondCli , &cCondFor ))
			dbSkip()
			Loop
		EndIf
		
		dbSelectArea("SF4")
		dbSeek(cFilial+SB6->B6_TES)
		If SF4->F4_PODER3 == "D"
			dbSelectArea("SB6")
			dbSkip()
			Loop
		Endif
		
		dbSelectArea("SB6")
		aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
		dbSelectArea("SB6")
		nSaldo:= aSaldo[1]
		
		If mv_par09 == 2 .And. nSaldo <= 0
			dbSkip()
			Loop
		EndIf
		
		If mv_par10 == 1 .And. B6_TIPO != "D"
			dbSkip()
			Loop
		ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
			dbSkip()
			Loop
		EndIf
		
		If Li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		If cCliForAnt != B6_TPCF .Or. cNomeCliFor != B6_CLIFOR+B6_LOJA
			dbSelectArea(IIf(B6_TPCF == "C" , "SA1" , "SA2" ) )
			dbSeek(cFilial+SB6->B6_CLIFOR+SB6->B6_LOJA)
			If Found()
				If !Empty(cDescCliFor)
					li++
				EndIf
				cDescCliFor	:= IIf(SB6->B6_TPCF == "C" , "CLIENTE / LOJA: " , "FORNECEDOR / LOJA: ")
				@ li,000 PSay cDescCliFor+Trim( IIf(SB6->B6_TPCF == "C" ,A1_COD+" - "+A1_NOME , A2_COD+" - "+A2_NOME )  )+" / "+IIf(SB6->B6_TPCF == "C" , A1_LOJA , A2_LOJA )
				cNomeCliFor := SB6->B6_CLIFOR+SB6->B6_LOJA
				cCliForAnt 	:= SB6->B6_TPCF
			Else
				Help(" ",1,"R480CLIFOR")
				RetIndex("SB6")
				dbSelectArea("SB6")
				dbSetOrder(1)
				cIndex += OrdBagExt()
				Ferase(cIndex)
				Return .F.
			EndIf
			dbSelectArea("SB6")
		EndIf
		
		If Li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		If Len(cNomeCliFor) != 0
			li++
			@ li,000 PSay B6_PRODUTO
			@ li,017 PSay B6_DOC
			@ li,033 PSay B6_SERIE
			@ li,038 PSay Dtoc(B6_EMISSAO)
			@ li,049 PSay B6_LOCAL
			@ li,057 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
			
			// Quantidade Original
		    @ li,063 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6", "B6_QUANT",17)
		    nQuant     += If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT)
			
			// localiza Saldo
			aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
			dbSelectArea("SB6")
			nSaldo  := aSaldo[1]
			nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
			
			// Quantidade Ja Entregue
		    @ li,082 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo)) Picture PesqPict("SB6", "B6_QUANT",17)
		    nQuJe     +=  If(mv_par15==1,ConvUm(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo))
			
			// Saldo
			@ li,101 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,nSaldo,0,2),nSaldo) Picture PesqPict("SB6", "B6_QUANT",17)
			
			// Total da Nota Fiscal
			@ li,120 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
			nTotal	+= B6_QUANT * nPrUnit
			nGerTot	+= B6_QUANT * nPrUnit
			
			// Total da Nota Fiscal Devolvido
			@ li,138 PSay Transform((B6_QUANT - nSaldo) * nPrUnit,'@E 99,999,999,999.99')
			nTotDev		+= (B6_QUANT - nSaldo) * nPrUnit
			nGerTotDev	+= (B6_QUANT - nSaldo) * nPrUnit
			nCusto 		:= (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
			nCusTot 	+= nCusto
			nGerCusTot 	+= nCusto
			
			@ li,156 PSay Transform(nCusto,'@E 999,999,999.99')
			@ li,172 PSay B6_TIPO
			@ li,176 PSay B6_SEGUM
			@ li,184 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",12)
			@ li,199 PSay Dtoc(B6_DTDIGIT)
			@ li,210 PSay Dtoc(B6_UENT)
		EndIf
		
		// Lista as devolucoes da remessa
		If mv_par12 == 1 .And. ((B6_QUANT - nSaldo) > 0)
			aAreaSB6 := SB6->(GetArea())
			dbSetOrder(3)
			cSeek:=xFilial()+B6_IDENT+B6_PRODUTO+"D"
			If dbSeek(cSeek)
				li++
				@ li,000 PSay "Notas Fiscais de Retorno"
				Do While !Eof() .And. B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 == cSeek
					If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
						DbSelectArea("SB6")
						DbSkip()
						Loop
					EndIf
					If li > 55
						Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
					EndIf					
					li++
					@ li,017 PSay B6_DOC
					@ li,033 PSay B6_SERIE
					@ li,038 PSay Dtoc(B6_EMISSAO)
					@ li,049 PSay B6_LOCAL
					@ li,057 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
					// Quantidade Original
					@ li,063 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6", "B6_QUANT",17)
					// Total da Nota Fiscal
					@ li,120 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
					// Total da Nota Fiscal Devolvido
					@ li,172 PSay B6_TIPO
					@ li,176 PSay B6_SEGUM
					@ li,184 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",12)
					@ li,199 PSay Dtoc(B6_DTDIGIT)
					@ li,210 PSay Dtoc(B6_UENT)
					dbSkip()
				EndDo
				li++
			EndIf
			RestArea(aAreaSB6)
			dbSetOrder(nIndex+1)
		EndIf
		
		dbSkip()
	EndDo
	If nQuant > 0
		li++
		dbSkip(-1)
		cVar:=IIF(B6_TPCF == "C" ,"CLIENTE ---->","FORNECEDOR --->")
		dbSkip();IncRegua()
		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		@ li,000 PSay "TOTAL DO PRODUTO NO " +cVar
		@ li,063 PSay nQuant					Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,082 PSay nQuje					Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,101 PSay (nQuant - nQuJe)	Picture PesqPict("SB6", "B6_QUANT",17)
		@ li,119 PSay Transform(nTotal ,'@E 999,999,999,999.99')
		@ li,137 PSay Transform(nTotDev,'@E 999,999,999,999.99')
		@ li,156 PSay Transform(nCusTot,'@E 999,999,999.99')
		li++
		nTotQuant += nQuant
		nTotQuJe  += nQuje
		nTotSaldo += (nQuant - nQuJe)
	Endif
End
If Len(cNomeCliFor) != 0
	li++
	@ li,000 PSay "T O T A L    G E R A L  ---------- >"
    @ li,063 PSay nTotQuant Picture PesqPict("SB6", "B6_QUANT",17)
    @ li,082 PSay nTotQuJe  Picture PesqPict("SB6", "B6_QUANT",17)
    @ li,101 PSay nTotSaldo Picture PesqPict("SB6", "B6_QUANT",17)
	@ li,119 PSay Transform(nGerTot	 ,'@E 999,999,999,999.99')
	@ li,137 PSay Transform(nGerTotDev,'@E 999,999,999,999.99')
	@ li,156 PSay Transform(nGerCusTot,'@E 999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SB6 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SB6")
dbSelectArea("SB6")
dbSetOrder(1)
cIndex += OrdBagExt()
Ferase(cIndex)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R480Data ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 13/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Por Ordem de Data do Movimento (B6_DTDIGIT).       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR480                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R480Data(lEnd,Tamanho)
LOCAL nCusTot := nQuant := nQuJe := nTotal := nTotDev := 0
LOCAL	nGerTot:=nGerTotDev:=nGerCusTot:=0
LOCAL cIndex, cKey, nIndex, cFilter
LOCAL cCondFiltr:=""
LOCAL aSaldo  := {}
Local nSaldo  := 0
Local nCusto  := 0
Local nPrUnit := 0
LOCAL cQuebra, lImprime:=.F.
LOCAL aAreaSB6:= {}
LOCAL nTotQuant := nTotQuJe := nTotSaldo := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho usando indice condicional.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB6")
cIndex  := CriaTrab(NIL,.F.)
cKey    := "B6_FILIAL+DTOS(B6_DTDIGIT)+B6_PRODUTO+B6_CLIFOR+B6_LOJA"
cFilter := SB6->(DbFilter())
If Empty( cFilter )
	cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'"'
Else
	cFilter := 'B6_FILIAL == "'+xFilial('SB6')+'" .And. ' + cFilter
EndIf
IndRegua("SB6",cIndex,cKey,,cFilter," Criando Indice ...    ")
nIndex := RetIndex("SB6")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho de acordo com o tipo de emissao            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par10 == 1
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - DATA DO MOVIMENTO"
ElseIf mv_par10 == 2
	titulo := "RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - DATA DO MOVIMENTO"
Else
	titulo := "RELACAO DE MATERIAIS DE TERCEIROS E EM TERCEIROS - DATA DO MOVIMENTO"
EndIf

cabec1 := "         Cliente /                             -   Documento   - Data de       UM --------------------- Quantidade ----------------- ------------ Valores ------------ Custo Produto TM Seg. Quantidade -       Data       -
cabec2 := "         Fornec.          Loja Produto         Numero      Serie Emissao  Almox           Original     Ja' entregue            Saldo Total Nota Fiscal Total Devolvido  na Moeda X      UM    Seg. UM   Lancamento   Entrega
                        // Forn:XXXXXXXXXXXXXXXXXXXX XXXX XXXXXXXXXXXXXXX 999999999999 xxx 99/99/9999 XX  XX 9999999999999999  999999999999999 9999999999999999 99999999999999999 999999999999999 99999999999999 X XX 99999999999 99/99/9999 99/99/9999
                        // Clie:     1         2         3         4         5         6         7         8         9         C         1         2         3         4         5         6         7         8         9         D         1         2
                        // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890



SetRegua(LastRec())

While !Eof()
	
	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	IF	!(Iif(B6_TPCF == "C" , &cCondCli , &cCondFor ))
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("SF4")
	dbSeek(cFilial+SB6->B6_TES)
	If SF4->F4_PODER3 == "D"
		dbselectArea("SB6")
		dbSkip()
		loop
	Endif
	
	dbSelectArea("SB6")
	aSaldo  := CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
	dbSelectArea("SB6")
	nSaldo  := aSaldo[1]
	nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
	
	If mv_par09 == 2 .And. nSaldo <= 0
		dbSkip()
		Loop
	ElseIf mv_par10 == 1 .And. B6_TIPO != "D"
		dbSkip()
		Loop
	ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
		dbSkip()
		Loop
	Endif
	nCusTot  := 0
	nQuant   := 0
	nQuJe    := 0
	nTotal   := 0
	nTotDev  := 0
	cQuebra  := dTos(B6_EMISSAO)+B6_PRODUTO
	lImprime := .T.
	While !Eof() .And. cQuebra == dTos(B6_EMISSAO)+B6_PRODUTO .And. B6_Filial == xFilial()
		
		IncRegua()
		
		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf
		
		IF	!(Iif(B6_TPCF == "C" , &cCondCli , &cCondFor ))
			dbSkip()
			Loop
		EndIf
		
		dbSelectArea("SF4")
		dbSeek(cFilial+SB6->B6_TES)
		If SF4->F4_PODER3 == "D"
			dbselectArea("SB6")
			dbSkip()
			loop
		Endif
		
		dbSelectArea("SB6")
		aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
		dbSelectArea("SB6")
		nSaldo  := aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
		
		If mv_par09 == 2 .And. nSaldo <= 0
			dbSkip()
			Loop
		ElseIf mv_par10 == 1 .And. B6_TIPO != "D"
			dbSkip()
			Loop
		ElseIf mv_par10 == 2 .And. B6_TIPO != "E"
			dbSkip()
			Loop
		Endif
		
		If lImprime
			li++
			@ li,000 PSay "DATA DE MOVIMENTACAO : " + dToc(B6_EMISSAO)
			lImprime := .F.
		Endif
		
		li++
		@ li,000 PSay IIf(B6_TPCF == "C" , "Clie:", "Forn:" )
		@ li,005 PSay (Substr(B6_CLIFOR,1,15))
		@ li,023 PSay B6_LOJA
		@ li,028 PSay B6_PRODUTO
		@ li,045 PSay B6_DOC
		@ li,060 PSay B6_SERIE
		@ li,064 PSay Dtoc(B6_EMISSAO)
		@ li,075 PSay B6_LOCAL
		@ li,079 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
		
		// Quantidade Original
		@ li,082 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6", "B6_QUANT",16)
		nQuant += If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT)
		
		// Localiza o Saldo
		aSaldo:=CalcTerc(SB6->B6_PRODUTO,SB6->B6_CLIFOR,SB6->B6_LOJA,SB6->B6_IDENT,SB6->B6_TES,,mv_par13,mv_par14)
		dbSelectArea("SB6")
		nSaldo  := aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,SB6->B6_PRUNIT,aSaldo[3])
		
		// Quantidade Ja Entregue
		@ li,100 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo)) Picture PesqPict("SB6", "B6_QUANT",15)
		nQuJe += If(mv_par15==1,ConvUm(B6_PRODUTO,(B6_QUANT - nSaldo),0,2),(B6_QUANT - nSaldo))
		
		// Saldo
		@ li,116 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,nSaldo,0,2),nSaldo) Picture PesqPict("SB6", "B6_QUANT",16)
		
		// Total da Nota Fiscal
		@ li,133 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
		nTotal += B6_QUANT * nPrUnit
		nGerTot+= B6_QUANT * nPrUnit
		
		// Total da Nota Fiscal Devolvido
		@ li,151 PSay Transform((B6_QUANT - nSaldo) * nPrUnit,'@E 999,999,999.99')
		nTotDev += (B6_QUANT - nSaldo) * nPrUnit
		nGerTotDev	+= (B6_QUANT - nSaldo) * nPrUnit
		nCusto := (&(If(lListCustM.Or.(!lListCustM.And.!lCusFIFO), 'B6_CUSTO', 'B6_CUSFF')+Str(mv_par11,1,0)) / B6_QUANT) * nSaldo
		nCusTot+= nCusto
		nGerCusTot+= nCusto
		
		@ li,167 PSay Transform(nCusto,'@E 999,999,999.99')
		@ li,182 PSay B6_TIPO
		@ li,184 PSay B6_SEGUM
		@ li,187 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",11)
		@ li,199 PSay Dtoc(B6_DTDIGIT)
		@ li,210 PSay Dtoc(B6_UENT)
		
		// Lista as devolucoes da remessa
		If mv_par12 == 1 .And. ((B6_QUANT - nSaldo) > 0)
			aAreaSB6 := SB6->(GetArea())
			dbSetOrder(3)
			cSeek:=xFilial()+B6_IDENT+B6_PRODUTO+"D"
			If dbSeek(cSeek)
				li++
				@ li,000 PSay "Notas Fiscais de Retorno"
				Do While !Eof() .And. B6_FILIAL+B6_IDENT+B6_PRODUTO+B6_PODER3 == cSeek
					If SB6->B6_DTDIGIT < mv_par13 .Or. SB6->B6_DTDIGIT > mv_par14
						DbSelectArea("SB6")
						DbSkip()
						Loop
					Endif
					If li > 55
						Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
					EndIf		
					li++					
					@ li,000 PSay IIf(B6_TPCF == "C" , "Clie:", "Forn:" )
					@ li,005 PSay (Substr(B6_CLIFOR,1,15))
					@ li,023 PSay B6_LOJA
					@ li,027 PSay B6_PRODUTO
					@ li,045 PSay B6_DOC
					@ li,060 PSay B6_SERIE
					@ li,064 PSay Dtoc(B6_EMISSAO)
					@ li,075 PSay B6_LOCAL
					@ li,079 PSay If(mv_par15==1,B6_SEGUM,B6_UM)
					// Quantidade Original
					@ li,082 PSay If(mv_par15==1,ConvUm(B6_PRODUTO,B6_QUANT,0,2),B6_QUANT) Picture PesqPict("SB6", "B6_QUANT",16)
					// Total da Nota Fiscal
					@ li,133 PSay Transform(B6_QUANT * nPrUnit,'@E 99,999,999,999.99')
					@ li,182 PSay B6_TIPO
					@ li,184 PSay B6_SEGUM
					@ li,187 PSay B6_QTSEGUM Picture PesqPict("SB6", "B6_QTSEGUM",11)
					@ li,199 PSay Dtoc(B6_DTDIGIT)
					@ li,210 PSay Dtoc(B6_UENT)
					dbSkip()
				EndDo
				li++
			EndIf
			RestArea(aAreaSB6)
			dbSetOrder(nIndex+1)
		EndIf
		
		dbSkip()
	EndDo
	If nQuant > 0
		li++
		@ li,000 PSay "TOTAL DO PRODUTO NA DATA --------- >"
		@ li,082 PSay nQuant 			 Picture PesqPict("SB6", "B6_QUANT",16)
		@ li,100 PSay nQuJe  			 Picture PesqPict("SB6", "B6_QUANT",15)
		@ li,116 PSay (nQuant - nQuJe) Picture PesqPict("SB6", "B6_QUANT",16)
		@ li,133 PSay Transform(nTotal, '@E 99,999,999,999.99')
		@ li,151 PSay Transform(nTotDev,'@E 999,999,999.99')
		@ li,167 PSay Transform(nCusTot,'@E 999,999,999.99')
		nTotQuant += nQuant
		nTotQuJe  += nQuJe
		nTotSaldo += (nQuant - nQuJe)
		li++
	Endif
End

If nQuant > 0 .Or. nTotal > 0
	li++;li++
	@ li,000 PSay "T O T A L    G E R A L  ---------- >"
    @ li,082 PSay nTotQuant Picture PesqPict("SB6", "B6_QUANT",16)
    @ li,100 PSay nTotQuJe  Picture PesqPict("SB6", "B6_QUANT",16)
    @ li,116 PSay nTotSaldo Picture PesqPict("SB6", "B6_QUANT",16)
	@ li,133 PSay Transform(nGerTot	 ,'@E 99,999,999,999.99')
	@ li,151 PSay Transform(nGerTotDev,'@E 999,999,999.99')
	@ li,167 PSay Transform(nGerCusTot,'@E 999,999,999.99')
	Roda(CbCont,CbTxt,Tamanho)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve condicao original ao SB6 e apaga arquivo de trabalho.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SB6")
dbSelectArea("SB6")
dbSetOrder(1)
cIndex += OrdBagExt()
Ferase(cIndex)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AjustaSX1 ºAutor³Nereu Humberto Junior º Data ³ 16/06/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR480                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX1()

PutSx1("MTR480","15","QTDE. na 2a. U.M. ?","CTD. EN 2a. U.M. ?","QTTY. in 2a. U.M. ?", "mv_chf", "N", 1, 0, 2,"C", "", "", "", "","mv_par15","Sim","Si","Yes", "","Nao","No","No", "", "", "", "", "", "", "", "", "", "", "", "", "")
PutSX1Help("P.MTR48015.",{'Imprime as Quantidades na 2a UM?        ', 'Sim=Utiliza a 2aUM na impressao         ', 'Nao=Utiliza a 1aUM na impressao(padrao) '}, {'Print the quantities at 2nd MU?         ', 'Yes=Uses 2nd MU at the print            ',  'No=Uses 1st MU at the print (defaut)    '}, {'¿Imprime las cantidades en la 2a UM?    ', 'Si=Utiliza la 2aUM en la impresion      ', 'No=Utiliza la 1aUM en la impresion(est.)'})

PutSx1('MTR480','16','Lista Custo        ?','¿Lista Costo       ?','List Cost          ?','mv_chg','N',01,0,1,'C','','','','','mv_par16','Medio','Promedio','Average','','FIFO/PEPS','FIFO/PEPS','FIFO','','','','','','','','','', {'Informe o tipo de custo a ser listado:  ', '1. Custo Medio                          ', '2. Custo FIFO/PEPS(p/"MV_CUSFIFO" ativo)'}, {'Inform the kind of cost to be listed:   ', '1. Average Cost                         ', '2. FIFO Cost (with "MV_CUSFIFO" active) '}, {'Informe el tipo de costo a ser listado: ', '1. Costo Promedio                       ', '2. Costo FIFO/PEPS(p/"MV_CUSFIFO"activo)'})

Return Nil