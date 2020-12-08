#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Matr230()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR230  � Autor � Eveli Morasco         � Data � 02/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Requisicoes para consumo                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marcelo Pim.�05/12/97�09882A�Incl.perg.(Dt.Emiss.,Cod.Prod.,Tipo,Grupo)���
���Cesar       �30/03/99�XXXXXX�Manutencao na SetPrint()                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//��������������������������������������������������������������Ŀ
//� Variaveis obrigatorias dos programas de relatorio            �
//����������������������������������������������������������������
Tamanho  := "M"
titulo   := "Requisicoes para Consumo"
cDesc1   := "Emite a relacao das requisicoes feitas para consumo , dividindo por"
cDesc2   := "Classe de Valor requisitante ou Conta Contabil.Este relatorio e' um"
cDesc3   := "pouco demorado porque ele cria o arquivo de indice na hora."
cString  := "SD3"
aOrd     := {" Classe de Valor "}
wnrel    := "MATR230"

//��������������������������������������������������������������Ŀ
//� Variaveis tipo Private padrao de todos os relatorios         �
//����������������������������������������������������������������
aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey:= 0 ;cPerg := "MTR230"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
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
//����������������������������������������������������������������
pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C230IMP  � Autor � Rodrigo de A. Sartorio� Data � 07.12.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR230                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function C230Imp
Static Function C230Imp()
*(aOrd,lEnd,WnRel,titulo,Tamanho)

//��������������������������������������������������������������Ŀ
//� Variaveis locais exclusivas deste programa                   �
//����������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Contadores de linha e pagina                                 �
//����������������������������������������������������������������
li := 80; m_pag := 1

//��������������������������������������������������������������Ŀ
//� Variaveis locais exclusivas deste programa                   �
//����������������������������������������������������������������
cNomArq := ""

//������������������������������������������������������������Ŀ
//� Caso seja TOPCONNECT, soma o filtro na condicao da IndRegua�
//��������������������������������������������������������������
#IFDEF TOP
	If !Empty(aReturn[7])
		cCond:=cCond+" .And. "+aReturn[7]
	EndIf
#ENDIF

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
nTipo  := IIF(aReturn[4]==1,15,18)
/*/
//������������������������������������������������������������Ŀ
//� Adiciona a ordem escolhida ao titulo do relatorio          �
//��������������������������������������������������������������
If Type("NewHead")#"U"
	NewHead := NewHead + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
Else
	Titulo  := Titulo + " (Por "+AllTrim(aOrd[aReturn[8]])+" ,em "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))+")"
EndIf
/*/
//��������������������������������������������������������������������������Ŀ
//� Define o campo a ser impresso no valor de acordo com a moeda selecionada �
//����������������������������������������������������������������������������
cCampoCus := "SD3->D3_CUSTO"+Str(mv_par03,1)

lContinua := .T.

//��������������������������������������������������������������Ŀ
//� Inicializa variaveis para controlar cursor de progressao     �
//����������������������������������������������������������������
dbSelectArea("SD3")
SetRegua(LastRec())

//����������������������������������������������������������Ŀ
//� Pega o nome do arquivo de indice de trabalho             �
//������������������������������������������������������������
cNomArq := CriaTrab("",.F.)

If aReturn[8] == 1
	//����������������������������������������������������������Ŀ
	//� Cria o indice de trabalho                                �
	//������������������������������������������������������������
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CLVL+D3_GRUPO+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//����������������������������������������������������������Ŀ
	//� Cria o cabecalho de acordo com a ordem selecionada       �
	//������������������������������������������������������������
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
					//�������������������������������������������������������Ŀ
					//� So' entra requisicao e devolucao                      �
					//���������������������������������������������������������
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
					
					//�������������������������������������������������������Ŀ
					//� Se tiver numero de OP nao e' para consumo , portanto  �
					//� nao deve entrar                                       �
					//���������������������������������������������������������
					// Retirado por Alberto em 26/09/11 para atender a nova sistem�tica de apontamento de produ��o com baixa autom�tica.
					//If !Empty(D3_OP)
					//	dbSkip()
					//	Loop
					//EndIf
					//������������������������������������������������������������Ŀ
					//�Eu estou somando as requisicoes e subtraindo as  devolucoes �
					//�porque este mapa tem o objetivo de totalizar os movimentos  �
					//�internos,nao tem sentido mostrar um monte de valores negati-�
					//�vos ,sendo que as requisicoes normalmente serao maiores  que�
					//�as devolucoes.                                              �
					//��������������������������������������������������������������
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
					//�������������������������������������������������������Ŀ
					//� Adiciona 1 ao contador de registros impressos         �
					//���������������������������������������������������������
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
	//����������������������������������������������������������Ŀ
	//� Cria o indice de trabalho                                �
	//������������������������������������������������������������
	IndRegua("SD3",cNomArq,"D3_FILIAL+D3_CONTA+D3_CLVL+D3_COD",,cCond,"Selecionando Registros...")
	dbGoTop()
	
	//����������������������������������������������������������Ŀ
	//� Cria o cabecalho de acordo com a ordem selecionada       �
	//������������������������������������������������������������
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
				//�������������������������������������������������������Ŀ
				//� So' entra requisicao e devolucao                      �
				//���������������������������������������������������������
				If SubStr(D3_CF,2,1) != "E"
					dbSkip()
					Loop
				EndIf
				//�������������������������������������������������������Ŀ
				//� Se tiver numero de OP nao e' para consumo , portanto  �
				//� nao deve entrar                                       �
				//���������������������������������������������������������
				// Retirado por Alberto em 26/09/11 para atender a nova sistem�tica de apontamento de produ��o com baixa autom�tica.
				//If !Empty(D3_OP)
				//	dbSkip()
				//	Loop
				//EndIf
				//������������������������������������������������������������Ŀ
				//�Eu estou somando as requisicoes e subtraindo as  devolucoes �
				//�porque este mapa tem o objetivo de totalizar os movimentos  �
				//�internos,nao tem sentido mostrar um monte de valores negati-�
				//�vos ,sendo que as requisicoes normalmente serao maiores  que�
				//�as devolucoes.                                              �
				//��������������������������������������������������������������
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
			//�������������������������������������������������������Ŀ
			//� Adiciona 1 ao contador de registros impressos         �
			//���������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais do arquivo                       �
//����������������������������������������������������������������
RetIndex("SD3")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indice de trabalho                                     �
//����������������������������������������������������������������
cNomArq := cNomArq + OrdBagExt()
Delete File &(cNomArq)

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()