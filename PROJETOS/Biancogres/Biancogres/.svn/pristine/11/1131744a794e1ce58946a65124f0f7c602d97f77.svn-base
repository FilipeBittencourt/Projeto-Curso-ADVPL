#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Matr230()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("TAMANHO,TITULO,CDESC1,CDESC2,CDESC3,CSTRING")
SetPrvt("AORD,WNREL,ARETURN,NLASTKEY,CPERG,NTIPO")
SetPrvt("CRODATXT,NCNTIMPR,NAC1,NAC2,NAG1,NAG2")
SetPrvt("NAT1,NAT2,NAP1,NAP2,DEMISSAO,LIMPRIME")
SetPrvt("NUNIT,CCVANT,CGRUPANT,CPRODANT,CCONTANT,CCAMPOCUS")
SetPrvt("LCONTINUA,LPASSOU1,LPASSOU2,LPASSOU3,CCOND,LI")
SetPrvt("M_PAG,CNOMARQ,NEWHEAD,CABEC1,CABEC2,LEND")

#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	#DEFINE PSAY SAY
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR230  ³ Autor ³ Eveli Morasco         ³ Data ³ 02/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Requisicoes para consumo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³05/12/97³09882A³Incl.perg.(Dt.Emiss.,Cod.Prod.,Tipo,Grupo)³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis obrigatorias dos programas de relatorio            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tamanho  := "M"
titulo   := "Requisicoes para Consumo"
cDesc1   := "Emite a relacao das requisicoes feitas para consumo , dividindo por"
cDesc2   := "Classe de Valor requisitante ou Conta Contabil.Este relatorio e' um"
cDesc3   := "pouco demorado porque ele cria o arquivo de indice na hora."
cString  := "SD3"
aOrd     := {" Classe de Valor "}
wnrel    := "MATR230"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey:= 0 ;cPerg := "MTR230"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // De  Classe de Valor                          ³
//³ mv_par02     // Ate Classe de Valor                          ³
//³ mv_par03     // Moeda Selecionada ( 1 a 5 )                  ³
//³ mv_par04     // De  Local                                    ³
//³ mv_par05     // Ate Local                                    ³
//³ mv_par06     // Da  Data                                     ³
//³ mv_par07     // Ate Data                                     ³
//³ mv_par08     // Do  Produto                                  ³
//³ mv_par09     // Ate Produto                                  ³
//³ mv_par10     // Do  Tipo                                     ³
//³ mv_par11     // Ate Tipo                                     ³
//³ mv_par12     // Do  Grupo                                    ³
//³ mv_par13     // Ate Grupo                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgSTOP("Necessário informar à TI que este programa está sendo executado para entendermos a finalidade - programa Matr230")

Return


wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|| C230Imp() })  // Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>         RptStatus({|| Execute(C230Imp) })
//      RptStatus({|lEnd| C230Imp(aOrd,@lEnd,wnRel,titulo,Tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C230IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 07.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR230                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function C230Imp
Static Function C230Imp()
*(aOrd,lEnd,WnRel,titulo,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo    := 0
cRodaTxt := "REGISTRO(S)"
nCntImpr := 0
nAc1:=0;nAc2:=0;nAg1:=0;nAg2:=0;nAt1:=0;nAt2:=0;nAp1:=0;nAp2:=0
dEmissao:=ctod("  ");lImprime:=.t.;nUnit:=0;cCVant:="";cGrupant:=""
cProdant:="";cContant:="";cCampoCus:="";lContinua:=.t.;lPassou1:=.f.
lPassou2:=.f.;lPassou3:=.f.
cCond := 'D3_FILIAL=="'+xFilial("SD3")+'" .And. D3_CLVL >= "'+mv_par01+'"'
cCond := cCond + '.And. D3_CLVL <= "'+mv_par02+'" .And. D3_LOCAL >= "'+mv_par04+'"'
cCond := cCond + '.And. D3_LOCAL <= "'+mv_par05+'"'
cCond := cCond + '.And. D3_COD >= "'+mv_par08+'" .And. D3_COD <= "'+mv_par09+'"'
cCond := cCond + '.And. D3_TIPO >= "'+mv_par10+'" .And. D3_TIPO <= "'+mv_par11+'"'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li := 80; m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso seja TOPCONNECT, soma o filtro na condicao da IndRegua³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If !Empty(aReturn[7])
		cCond:=cCond+" .And. "+aReturn[7]
	EndIf
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")#"U"
	NewHead := NewHead + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
Else
	Titulo  := Titulo + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
EndIf
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o campo a ser impresso no valor de acordo com a moeda selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCampoCus := "SD3->D3_CUSTO"+Str(mv_par03,1)

lContinua := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para controlar cursor de progressao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD3")
SetRegua(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := CriaTrab("",.F.)

If aReturn[8] == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o indice de trabalho                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CLVL+D3_GRUPO+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho de acordo com a ordem selecionada       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 :="C.VALOR   DESCRICAO                 CODIGO PRODUTO  DESCRICAO                 UM       QUANTIDADE          CUSTO        C U S T O"
	cabec2 :="                                                                                                        UNITARIO        T O T A L"
	*****      123456789 1234567890123456789012345 123456789012345 1234567890123456789012345 12 9999999999999.99 99999999999.99 9999999999999.99
	*****      0         1         2         3         4         5         6         7         8         9        10        11        12        13
	*****      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	
	Store 0 To nAt1,nAt2
	lPassou3 := .F.
	While lContinua .And. !EOF()
		cCVant := D3_CLVL
		Store 0 To nAc1,nAc2
		lImprime := .T.
		lPassou2 := .F.
		While lContinua .And. !EOF() .And. D3_FILIAL+D3_CLVL == xFilial("SD3")+cCVAnt
			cGrupant := D3_GRUPO
			Store 0 To nAg1,nAg2
			lPassou1 := .F.
			While lContinua .And. !EOF() .And. D3_FILIAL+D3_CLVL+D3_GRUPO == xFilial("SD3")+cCVAnt+cGrupAnt
				cProdant := D3_COD+D3_LOCAL
				Store 0 To nAp1,nAp2
				While lContinua .And. !EOF() .And. D3_FILIAL+D3_CLVL+D3_GRUPO+D3_COD+D3_LOCAL == xFilial("SD3")+cCVAnt+cGrupAnt+cProdAnt
					#IFNDEF WINDOWS
						If LastKey() = 286
							lEnd := .T.
						EndIf
					#ENDIF
					If lEnd
						@ PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
						lContinua := .F.
						Exit
					EndIf
					IncRegua()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ So' entra requisicao e devolucao                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr(D3_CF,2,1) != "E"
						dbSkip()
						Loop
					EndIf
					
					IF D3_EMISSAO < mv_par06 .OR. D3_EMISSAO > mv_par07
						dbSkip()
						Loop
					ENDIF
					
					IF D3_GRUPO < mv_par12 .OR. D3_GRUPO > mv_par13
						dbSkip()
						Loop
					ENDIF
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se tiver numero de OP nao e' para consumo , portanto  ³
					//³ nao deve entrar                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Retirado por Alberto em 26/09/11 para atender a nova sistemática de apontamento de produção com baixa automática.
					//If !Empty(D3_OP)
					//	dbSkip()
					//	Loop
					//EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Eu estou somando as requisicoes e subtraindo as  devolucoes ³
					//³porque este mapa tem o objetivo de totalizar os movimentos  ³
					//³internos,nao tem sentido mostrar um monte de valores negati-³
					//³vos ,sendo que as requisicoes normalmente serao maiores  que³
					//³as devolucoes.                                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If D3_TM <= "500"
						nAp1 := nAp1 - D3_QUANT
						nAp2 := nAp2 - &(cCampoCus)
					Else
						nAp1 := nAp1 + D3_QUANT
						nAp2 := nAp2 + &(cCampoCus)
					EndIf
					dbSkip()
				EndDo
				If nAp1 != 0 .Or. nAp2 != 0
					IF li > 58
						cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
						lImprime := .T.
					EndIf
					If lImprime
						@ li,000 PSay cCVant
						dbSelectArea("CTH")
						dbSeek(xFilial("CTH")+cCVant)
						@li,010 PSay SubStr(CTH_DESC01,1,25)
						lImprime := .F.
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona 1 ao contador de registros impressos         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nCntImpr := nCntImpr + 1
					dbSelectArea("SB1")
					dbSeek(xFilial("SB1")+cProdant)
					@li,036 PSay B1_COD
					@li,052 PSay Substr(B1_DESC,1,25)
					@li,078 PSay B1_UM
					@li,081 PSay nAp1 Picture PesqPictQt("D3_QUANT",16)
					dbSelectArea("SD3")
					IF nAp1 == 0
						nUnit := nAp2
					Else
						nUnit := nAp2/nAp1
					EndIf
					@li,098 PSay nUnit PicTure tm(nUnit,14,4)
					@li,113 PSay nAp2  PicTure tm(nAp2,16)
					li := li + 1
					nAg1 := nAg1 + nAp1
					nAg2 := nAg2 + nAp2
					lPassou1 := .T.
					dbSelectArea("SD3")
				EndIf
			EndDo
			If lPassou1
				li := li + 1
				@li,049 PSay "Total do Grupo "+cGrupant+Replicate(".",13)
				@li,081 PSay nAg1 Picture PesqPictQt("D3_QUANT",16)
				@li,113 PSay nAg2 PicTure tm(nAg2,16)
				li := li + 2
				nAc1 := nAc1 + nAg1
				nAc2 := nAc2 + nAg2
				lPassou2 := .T.
			EndIf
		EndDo
		If lPassou2
			@li,049 PSay "Total Classe de Valor "+cCVant+"."
			@li,081 PSay nAc1 Picture PesqPictQt("D3_QUANT",16)
			@li,113 PSay nAc2 PicTure tm(nAc2,16)
			li := li + 2
			nAt1 := nAt1 + nAc1
			nAt2 := nAt2 + nAc2
			lPassou3 := .T.
		EndIf
	EndDo
	If lPassou3
		IF li > 58
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ li,049 PSay "TOTAL GERAL....................."
		@ li,081 PSay nAt1 Picture PesqPictQt("D3_QUANT",16)
		@ li,113 PSay nAt2 PicTure tm(nAt2,16)
		li := li + 1
	EndIf
EndIf

If aReturn[8] == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o indice de trabalho                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CONTA+D3_CLVL+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o cabecalho de acordo com a ordem selecionada       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cabec1 := "  DATA  C L A S S E  D E   V A L O R        C O N T A   C O N T A B I L                        V A L O R"
	cabec2 := ""
	*****      123456789 1234567890123456789012345 123456789012345 1234567890123456789012345 12 9999999999999.99 99999999999.99 9999999999999.99
	*****      0         1         2         3         4         5         6         7         8         9        10        11        12        13
	*****      0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	
	While lContinua .And. !EOF()
		cContant := D3_CONTA
		Store 0 To nAc1
		While lContinua .And. !EOF() .And. D3_FILIAL+D3_CONTA == xFilial("SD3")+cContant
			cCVant := D3_CLVL
			Store 0 To nAc2
			While lContinua .And. !EOF() .And. D3_FILIAL+D3_CONTA+D3_CLVL == xFilial("SD3")+cContant+cCVant
				#IFNDEF WINDOWS
					If LastKey() = 286
						lEnd := .t.
					EndIf
				#ENDIF
				If lEnd
					@ PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
					lContinua := .F.
					Exit
				EndIf
				IncRegua()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ So' entra requisicao e devolucao                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SubStr(D3_CF,2,1) != "E"
					dbSkip()
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se tiver numero de OP nao e' para consumo , portanto  ³
				//³ nao deve entrar                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Retirado por Alberto em 26/09/11 para atender a nova sistemática de apontamento de produção com baixa automática.
				//If !Empty(D3_OP)
				//	dbSkip()
				//	Loop
				//EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Eu estou somando as requisicoes e subtraindo as  devolucoes ³
				//³porque este mapa tem o objetivo de totalizar os movimentos  ³
				//³internos,nao tem sentido mostrar um monte de valores negati-³
				//³vos ,sendo que as requisicoes normalmente serao maiores  que³
				//³as devolucoes.                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If D3_TM <= "500"
					nAc2 := nAc2 - &(cCampoCus)
				Else
					nAc2 := nAc2 + &(cCampoCus)
				EndIf
				dEmissao := D3_EMISSAO
				dbSkip()
			EndDo
			IF li > 58
				cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
			EndIf
			dbSelectArea("CTH")
			dbSeek(xFilial("CTH")+cCVant)
			dbSelectArea("CT1")
			dbSeek(xFilial("CT1")+cContant)
			dbSelectArea("SD3")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona 1 ao contador de registros impressos         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCntImpr := nCntImpr + 1
			@ li,000 PSay dEmissao
			@ li,009 PSay cCVant
			@ li,018 PSay CTH->CTH_DESC01
			@ li,045 PSay cContant
			@ li,060 PSay CT1->CT1_DESC01
			@ li,086 PSay nAc2 Picture TM(nAc2,18)
			nAc1 := nAc1 + nAc2
			li := li + 1
		EndDo
		@ li,000 PSay "Total da Conta --> "+cContant
		@ li,086 PSay nAc1 PicTure TM(nAc1,18)
		li := li + 2
		nAg1 := nAg1 + nAc1
	EndDo
	IF li > 58
		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		@ li,000 PSay "T O T A L --->"
		@ li,086 PSay nAg1 PicTure TM(nAg1,18)
		li := li + 2
	ENDIF
EndIf

IF li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SD3")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := cNomArq + OrdBagExt()
Delete File &(cNomArq)

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
