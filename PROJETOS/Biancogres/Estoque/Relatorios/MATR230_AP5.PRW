#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Matr230()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � MATR230  � Autor � Eveli Morasco         � Data � 02/03/93 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Requisicoes para consumo                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Generico                                                   낢�
굇쳐컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             낢�
굇쳐컴컴컴컴컴컫컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛rogramador � Data   � BOPS �  Motivo da Alteracao                     낢�
굇쳐컴컴컴컴컴컵컴컴컴컴탠컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿘arcelo Pim.�05/12/97�09882A쿔ncl.perg.(Dt.Emiss.,Cod.Prod.,Tipo,Grupo)낢�
굇쿎esar       �30/03/99쿦XXXXX쿘anutencao na SetPrint()                  낢�
굇읕컴컴컴컴컴컨컴컴컴컴좔컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis obrigatorias dos programas de relatorio            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Tamanho  := "M"
titulo   := "Requisicoes para Consumo"
cDesc1   := "Emite a relacao das requisicoes feitas para consumo , dividindo por"
cDesc2   := "Classe de Valor requisitante ou Conta Contabil.Este relatorio e' um"
cDesc3   := "pouco demorado porque ele cria o arquivo de indice na hora."
cString  := "SD3"
aOrd     := {" Classe de Valor "}
wnrel    := "MATR230"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis tipo Private padrao de todos os relatorios         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey:= 0 ;cPerg := "MTR230"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // De  Classe de Valor                          �
//� mv_par02     // Ate Classe de Valor                          �
//� mv_par03     // Moeda Selecionada ( 1 a 5 )                  �
//� mv_par04     // De  Local                                    �
//� mv_par05     // Ate Local                                    �
//� mv_par06     // Da  Data                                     �
//� mv_par07     // Ate Data                                     �
//� mv_par08     // Do  Produto                                  �
//� mv_par09     // Ate Produto                                  �
//� mv_par10     // Do  Tipo                                     �
//� mv_par11     // Ate Tipo                                     �
//� mv_par12     // Do  Grupo                                    �
//� mv_par13     // Ate Grupo                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte(cPerg,.F.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

MsgSTOP("Necess�rio informar � TI que este programa est� sendo executado para entendermos a finalidade - programa Matr230")

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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � C230IMP  � Autor � Rodrigo de A. Sartorio� Data � 07.12.95 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Chamada do Relatorio                                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � MATR230                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function C230Imp
Static Function C230Imp()
*(aOrd,lEnd,WnRel,titulo,Tamanho)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis locais exclusivas deste programa                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Contadores de linha e pagina                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
li := 80; m_pag := 1

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis locais exclusivas deste programa                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomArq := ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Caso seja TOPCONNECT, soma o filtro na condicao da IndRegua�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
#IFDEF TOP
	If !Empty(aReturn[7])
		cCond:=cCond+" .And. "+aReturn[7]
	EndIf
#ENDIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nTipo  := IIF(aReturn[4]==1,15,18)
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Adiciona a ordem escolhida ao titulo do relatorio          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If Type("NewHead")#"U"
	NewHead := NewHead + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
Else
	Titulo  := Titulo + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
EndIf
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define o campo a ser impresso no valor de acordo com a moeda selecionada �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cCampoCus := "SD3->D3_CUSTO"+Str(mv_par03,1)

lContinua := .T.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis para controlar cursor de progressao     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SD3")
SetRegua(LastRec())

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Pega o nome do arquivo de indice de trabalho             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomArq := CriaTrab("",.F.)

If aReturn[8] == 1
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria o indice de trabalho                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CLVL+D3_GRUPO+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria o cabecalho de acordo com a ordem selecionada       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//� So' entra requisicao e devolucao                      �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
					
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//� Se tiver numero de OP nao e' para consumo , portanto  �
					//� nao deve entrar                                       �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					// Retirado por Alberto em 26/09/11 para atender a nova sistem�tica de apontamento de produ豫o com baixa autom�tica.
					//If !Empty(D3_OP)
					//	dbSkip()
					//	Loop
					//EndIf
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//쿐u estou somando as requisicoes e subtraindo as  devolucoes �
					//쿾orque este mapa tem o objetivo de totalizar os movimentos  �
					//쿶nternos,nao tem sentido mostrar um monte de valores negati-�
					//퀆os ,sendo que as requisicoes normalmente serao maiores  que�
					//쿪s devolucoes.                                              �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//� Adiciona 1 ao contador de registros impressos         �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria o indice de trabalho                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CONTA+D3_CLVL+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Cria o cabecalho de acordo com a ordem selecionada       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� So' entra requisicao e devolucao                      �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				If SubStr(D3_CF,2,1) != "E"
					dbSkip()
					Loop
				EndIf
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Se tiver numero de OP nao e' para consumo , portanto  �
				//� nao deve entrar                                       �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				// Retirado por Alberto em 26/09/11 para atender a nova sistem�tica de apontamento de produ豫o com baixa autom�tica.
				//If !Empty(D3_OP)
				//	dbSkip()
				//	Loop
				//EndIf
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//쿐u estou somando as requisicoes e subtraindo as  devolucoes �
				//쿾orque este mapa tem o objetivo de totalizar os movimentos  �
				//쿶nternos,nao tem sentido mostrar um monte de valores negati-�
				//퀆os ,sendo que as requisicoes normalmente serao maiores  que�
				//쿪s devolucoes.                                              �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Adiciona 1 ao contador de registros impressos         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Devolve as ordens originais do arquivo                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RetIndex("SD3")
Set Filter to

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Apaga indice de trabalho                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomArq := cNomArq + OrdBagExt()
Delete File &(cNomArq)

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
