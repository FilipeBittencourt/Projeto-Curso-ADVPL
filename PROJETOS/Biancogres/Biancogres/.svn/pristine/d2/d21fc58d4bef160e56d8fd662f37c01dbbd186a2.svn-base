#INCLUDE "Mdtr715.ch"
#Include "Protheus.Ch"

/*/{Protheus.doc} MDTR715.PRW
@author Gabriel Rossi Mafioletti
@since 17/04/2018
@version 1.0
@description Relatório de odens de serviço da segurança do trabalho. Customizado para atender Ticket 1825
@type function
/*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  MDR715  ³ Autor ³Liber De Esteban O. P. ³ Data ³20/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Relat¢rio das ordens de servico da seguranca de trabalho    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MDTR7151()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena variaveis p/ devolucao (NGRIGHTCLICK) 				  		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aNGBEGINPRM := NGBEGINPRM()

Local cF3CC  := "SI3001"

Private nSizeCTT := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
PRIVATE cPerg := PADR( "MDT715" , Len( SX1->X1_GRUPO ) )
PRIVATE cTxtTit1 := STR0002
PRIVATE cTxtTit2 := STR0003
PRIVATE lPosTrab := .f.
PRIVATE lTOBDepto:= NGCADICBASE( "TOB_DEPTO" , "A" , "TOB" , .F. )
PRIVATE nIndTN0  := 5
PRIVATE nIndTOB  := 1
PRIVATE nIndTOC  := 1
PRIVATE cCodFu1  := "TN0->TN0_CODFUN"
PRIVATE cCodFu2  := "SRA->RA_CODFUNC"
PRIVATE cCodFu3  := "TOB->TOB_CODFUN"
PRIVATE cCodFu4  := "TOC->TOC_CODFUN"
PRIVATE cDesFu1  := "SRJ->RJ_DESC"
PRIVATE nSizeSRJ := If((TAMSX3("RJ_FUNCAO")[1]) < 1,5,(TAMSX3("RJ_FUNCAO")[1]))
PRIVATE cTabFun  := "SRJ"
Private strFuncao := STR0031 //"Funcao"
Private nSizeSI3      := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
Private nTa1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nTa1L := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeTD := nTa1+nTa1L

lDtDevol   := NGCADICBASE("TOC_DTFIM","A","TOC",.F.)
lSigaMdtPS    := SuperGetMv("MV_MDTPS",.F.,"N") == "S"

cAliasCC := "SI3"
cDescCC := "SI3->I3_DESC"

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cF3CC  := "CTT001"
	cAliasCC := "CTT"
	cDescCC := "CTT->CTT_DESC01"
Endif

/* Perguntas
MDT715    ¦01      ¦Tipo Impressao ?
MDT715    ¦02      ¦De Funcao ?
MDT715    ¦03      ¦Ate Funcao ?
MDT715    ¦04      ¦De Centro de Custo ?
MDT715    ¦05      ¦Ate Centro de Custo ?
MDT715    ¦06      ¦De Funcionario ?
MDT715    ¦07      ¦Ate Funcionario ?
MDT715    ¦08      ¦Periodo De: ?
MDT715    ¦09      ¦Periodo Ate: ?
MDT715    ¦10      ¦Responsavel empresa ?
MDT715    ¦11      ¦Descricao das Atividades
MDT715    ¦12      ¦Buscar Informações ?
MDT715    ¦13      ¦Quant. Agente ?
MDT715    ¦14      ¦Endereco:
*/

If lSigaMdtps

	/* Perguntas
	01       De Cliente ?
	02       Loja
	03       Até Cliente ?
	04       Loja
	MDT715    ¦05      ¦Tipo Impressao ?
	MDT715    ¦06      ¦De Funcao ?
	MDT715    ¦07      ¦Ate Funcao ?
	MDT715    ¦08      ¦De Centro de Custo ?
	MDT715    ¦09      ¦Ate Centro de Custo ?
	MDT715    ¦10      ¦De Funcionario ?
	MDT715    ¦11      ¦Ate Funcionario ?
	MDT715    ¦12      ¦Periodo De: ?
	MDT715    ¦13      ¦Periodo Ate: ?
	MDT715    ¦14      ¦Responsavel empresa ?
	MDT715    ¦15      ¦Descricao das Atividades
	MDT715    ¦16      ¦Buscar Informações ?
	MDT715    ¦17      ¦Quant. Agente ?
	*/
	cPerg    :=  "MDT715PS  "

Endif
fChkMDTSX1( cPerg )
If pergunte(cPerg,.t.)
	If lSigaMdtPs
		cMVDeCli   := mv_par01
		cMVDeLoj   := mv_par02
		cMVAteCli  := mv_par03
		cMVAteLoj  := mv_par04
		cMVTpImp   := mv_par05
		cMVDeFun   := mv_par06
		cMVAteFun  := mv_par07
		cMVDeCC    := mv_par08
		cMVAteCC   := mv_par09
		cMVDeFunc  := mv_par10
		cMVAtFunc  := mv_par11
		cMVDePer   := mv_par12
		cMVAtePer  := mv_par13
		cMVRespon  := mv_par14
		cMVDescAti := mv_par15
		cMVBuscInf := mv_par16
		cMVQntAgen := mv_par17
	Else
		cMVTpImp   := mv_par01
		cMVDeFun   := mv_par02
		cMVAteFun  := mv_par03
		cMVDeCC    := mv_par04
		cMVAteCC   := mv_par05
		cMVDeFunc  := mv_par06
		cMVAtFunc  := mv_par07
		cMVDePer   := mv_par08
		cMVAtePer  := mv_par09
		cMVRespon  := mv_par10
		cMVDescAti := mv_par11
		cMVBuscInf := mv_par12
		cMVQntAgen := mv_par13
		cMVEnderec := mv_par14
	EndIf

	dbSelectArea("SX1")
	dbSetOrder(1)
	If MsSeek( cPerg + "06" ) .AND. "De Departamento" $ X1Pergunt()
		cMVDeDep   := mv_par06
		cMvAteDep  := mv_par07
		cMVDeFunc  := mv_par08
		cMVAtFunc  := mv_par09
		cMVDePer   := mv_par10
		cMVAtePer  := mv_par11
		cMVRespon  := mv_par12
		cMVDescAti := mv_par13
		cMVBuscInf := mv_par14
		cMVQntAgen := mv_par15
		cMVEnderec := mv_par16
	EndIf
	MDT715IMP()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve variaveis armazenadas (NGRIGHTCLICK)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NGRETURNPRM(aNGBEGINPRM)

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MDT715IMP ³ Autor ³Liber De Esteban O. P. ³ Data ³20/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MDT715IMP()

Local oPrint
Private lin    := 0
Private lAgen  := IIF(!lSigaMdtps,cMVQntAgen == 1 , .F. )
Private oFont06,oFont07,oFont08,oFont09,oFont10p,oFont10r,oFont11,oFont11b,oFont11t,oFont12,oFont13,oFont14,oFont15
oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.F.,.F.)
oFont07	 := TFont():New("Arial",07,07,,.F.,,,,.F.,.F.)
oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.F.,.F.)
oFont09	 := TFont():New("Arial",09,09,,.T.,,,,.F.,.F.)
oFont10r := TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
oFont10p := TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
oFont11b := TFont():New("Arial",11,11,,.T.,,,,.F.,.F.)
oFont11t := TFont():New("Arial",11,11,,.F.,,,,.F.,.F.)
oFont11	 := TFont():New("Arial",11,11,,.T.,,,,.T.,.T.)
oFont12	 := TFont():New("Arial",12,12,,.T.,,,,.T.,.T.)
oFont13	 := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
oFont14	 := TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
oFont15  := TFont():New("Arial",15,15,,.T.,,,,.F.,.F.)
oFont15b := TFont():New("Arial",15,15,,.F.,,,,.F.,.F.)

oPrint := FwMsPrinter():New(OemToAnsi(STR0001)) //"Ordem de serviço de segurança do trabalho"
oPrint:SetPortrait()

INDMDT715(oPrint)

If cMVTpImp = 2
	oPrint:Print()
	Else
		oPrint:Preview()
Endif

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} INDMDT715
Função responsavel pela impressão do Relatório

@type function

@source MDTR715.prx
@sample INDMDT715(oPrint)

@author Liber De Esteban O. P.
@since 02/04/2003
@version P11

@param oPrint, objeto, Objeto de impressão.

@return lógico, .T.
/*/
//---------------------------------------------------------------------
Static Function INDMDT715(oPrint)

Local nAltura	:= 0 //Altura do Logo
Local nLargura 	:= 0 //Largura do Logo
Local nLargMax	:= 0 //Largura máxima do Logo
Local nX		:= 0 //Contador 1
Local nY		:= 0 //Contador 2
Local nPrintStr := 0 //Tamanho da String parcial a ser impressa caso haja quebra de página
Local nLMemoAux := 0 //Contador de linhas auxiliar para impressão dos blocos da OS
Local nLINPIX	:= 30//Tamanho em pixel de uma linha para utilização do SayAlign
Local cSMCOD	:= If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
Local cSMFIL	:= If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
Local CONT
Local cEnd		:= ""
Local cBairro	:= ""
Local cCidade	:= ""
Local cMemoAux := ""
Local i, nCorta:= 0
Local lPrintDesc := .T.
Local aAgeAssAti := {} // Array dos Agentes Assosiados as Atividades
Local aBloco	 := {} // Array com as informações de cada bloco da O.S.
Local aParagrafo := {}
Local oBmp
Private cEPI

If lSigaMdtps
	//Consistencia da para impreção da descrição da função.
	If cMVDescAti == 2 .And. SRJ->(FieldPos("RJ_MEMOATI")) <= 0
		lPrintDesc := .F.
	EndIf

	dbselectarea("TOC")
	dbsetorder(4)  //TOC_FILIAL+TOC_CLIENT+TOC_LOJA+TOC_CODFUN+TOC_CC+TOC_MAT
	dbseek(xFilial("TOC")+cMVDeCli+cMVDeLoj,.T.)
	while !EOF() .And. TOC->TOC_Filial==xFilial("TOC") .And. TOC->(TOC_CLIENT+TOC_LOJA) <= cMVAteCli+cMVAteLoj

		If TOC->TOC_CODFUN < cMVDeFun .Or. TOC->TOC_CODFUN > cMVAteFun
			dbselectarea("TOC")
			dbskip()
			loop
		Endif

		If TOC->TOC_CC>cMVAteCC .Or. TOC->TOC_CC<cMVDeCC .Or. ;
				TOC->TOC_MAT>cMVAtFunc .Or. TOC->TOC_MAT<cMVDeFunc
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		If lDtDevol
			If !Empty(TOC->TOC_DTFIM) .And. TOC->TOC_DTFIM < cMVDePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf

			If TOC->TOC_DTENT > cMVAtePer .And. TOC->TOC_DTFIM > cMVAtePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf
		Else
			If TOC->TOC_DTENT < cMVDePer .Or. TOC->TOC_DTENT > cMVAtePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf
		EndIf

		cEPI:=" "
		dbselectarea("TOB")
		dbsetorder(5)  //TOB_FILIAL+TOB_CLIENT+TOB_LOJA+TOB_CODFUN+TOB_CC
		If !dbseek(xFilial("TOB")+TOC->(TOC_CLIENT+TOC_LOJA)+&(cCodFu4)+TOC->TOC_CC)
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		If TOB->TOB_DTELAB > cMVAtePer .Or. TOB->TOB_DTELAB < cMVDePer
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		dbselectarea("SRA")
		dbsetorder(01)
		If !dbseek(xFilial("SRA")+TOC->TOC_MAT)
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		Dbselectarea("SA1")
		Dbsetorder(1)
		If !Dbseek( xFilial("SA1")+TOC->(TOC_CLIENT+TOC_LOJA) )
			dbselectarea("TOC")
			dbskip()
			loop
		Endif

		lin := 100
		oPrint:StartPage()

		oPrint:Box(lin,50,940,2350)
		oPrint:Line(340,50,340,2350)
		oPrint:Line(400,50,400,2350)
		oPrint:Line(580,50,580,2350)
		oPrint:Line(640,50,640,2350)
		oPrint:Line(880,50,880,2350)
		oPrint:Line(220,1690,220,2350)

		oPrint:Line(lin,770,340,770)
		oPrint:Line(lin,1690,340,1690)
		oPrint:Line(400,1630,580,1630)
		oPrint:Line(640,1630,880,1630)
		//oPrint:Line(880,1125,940,1125)

		If File("LGRL"+cSMCOD+cSMFIL+".BMP")
			oPrint:SayBitMap(105,55,"LGRL"+cSMCOD+cSMFIL+".BMP",670,210)
		ElseIf File("LGRL"+cSMCOD+".BMP")
			oPrint:SayBitMap(105,55,"LGRL"+cSMCOD+".BMP",670,210)
		Endif

		oPrint:Say(130,930,cTxtTit1,oFont15)	     //"ORDEM DE SERVIÇO"
		oPrint:Say(190,920,cTxtTit2,oFont15)	 //"POR ATIVIDADE (O.S.)"
		oPrint:Say(270,850,STR0004,oFont15) //"SEGURANÇA DO TRABALHO"

		oPrint:Say(142,1705,STR0005,oFont11t)	 //"Data Elaboração:"
		oPrint:Say(142,2000,DTOC(TOB->TOB_DTELAB),oFont09)
		oPrint:Say(262,1705,STR0006,oFont11t) //"Última Revisão:"
		oPrint:Say(262,2000,DTOC(TOB->TOB_DTREVI),oFont09)

		oPrint:Say(350,1000,STR0007,oFont13) //"Dados da Empresa"

		oPrint:Say(420,65,STR0008,oFont11t)		 //"Razão Social/Nome:"
		oPrint:Say(470,65,STR0009,oFont11t) //"Endereço:"
		oPrint:Say(520,65,STR0010,oFont11t) //"Cidade:"

		oPrint:Say(420,1645,STR0011,oFont11t) //"CNPJ:"
		oPrint:Say(470,1645,STR0012,oFont11t) //"CNAE:"
		oPrint:Say(520,1645,STR0013,oFont11t) //"Bairro:"

		oPrint:Say(420,450,substr(SA1->A1_NOME,1,30),oFont09)
		oPrint:Say(470,450,substr(SA1->A1_END,1,36),oFont09)
		oPrint:Say(520,450,Alltrim(SA1->A1_MUN)+If(!Empty(SA1->A1_EST),"-"+SA1->A1_EST," "),oFont09)
		oPrint:Say(420,1775,SA1->A1_CGC,oFont09)
		oPrint:Say(470,1775,SA1->A1_ATIVIDA,oFont09)
		oPrint:Say(520,1775,substr(A1_BAIRRO,1,16),oFont09)

		oPrint:Say(590,960,STR0014,oFont13) //"Dados do Funcionário"

		oPrint:Say(660,65,STR0015,oFont11t)		 //"Nome:"
		oPrint:Say(660,350,SRA->RA_NOME,oFont09)

		dbselectarea(cAliasCC)
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cAliasCC)+SRA->RA_CC)
		Else
			dbSeek(xFilial(cAliasCC)+TOB->TOB_CC )
		Endif
		oPrint:Say(715,65,STR0016,oFont11t) //"Centro de Custo:"
		oPrint:Say(715,350,&(cDescCC),oFont09)

		dbselectarea(cTabFun)
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cTabFun)+&(cCodFu2))
		Else
			dbseek(xfilial(cTabFun)+&(cCodFu3))
		Endif

		oPrint:Say(770,65,STR0017,oFont11t) //"Função:"
		oPrint:Say(770,350,&(cDesFu1),oFont09)
		oPrint:Say(830,65,STR0018,oFont11t)	 //"CTPS:"
		oPrint:Say(830,350,SRA->RA_NUMCP + SRA->RA_SERCP,oFont09)

		oPrint:Say(660,1645,STR0019,oFont11t) //"Matrícula:"
		oPrint:Say(660,2120,SRA->RA_MAT,oFont09)
		oPrint:Say(715,1645,STR0020,oFont11t) //"Data Admissão:"
		oPrint:Say(715,2120,DTOC(SRA->RA_ADMISSA),oFont09)
		oPrint:Say(770,1645,STR0021,oFont11t) //"Data Nascimento:"
		oPrint:Say(770,2120,DTOC(SRA->RA_NASC),oFont09)
		oPrint:Say(830,1645,STR0022,oFont11t)	 //"RG:"
		oPrint:Say(830,2120,SRA->RA_RG,oFont09)

		dbselectarea(cTabFun)    //SRJ-Funcao ou ZZI-Posto de Trabalho
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cTabFun)+&(cCodFu2))
		Else
			dbseek(xfilial(cTabFun)+&(cCodFu3))
		Endif

		Somalinha()
		oPrint:Say(950,1000,"Dados da O.S.",oFont13) //"Dados da O.S."

		If lPrintDesc
			lin:=940
			oPrint:line(lin,50,lin,2350)
			oPrint:Say(lin+10,65,STR0023,oFont11t)	//"Descrição Função:"
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin-60,2350,lin+60,2350)
			oPrint:line(lin+60,50,lin+60,2350)
		Else
			lin:=820
		EndIf
		cMemo := " "
		If cMVDescAti == 1 //Cargo
			If lPosTrab
				cMemo := RTrim(ZZI->ZZI_ATIV)
			Else
				cMemo := RTrim(MSMM(SQ3->Q3_DESCDET))
			Endif
		ElseIf cMVDescAti == 2 //Função
			If SRJ->(FieldPos("RJ_MEMOATI")) > 0
				cMemo := RTrim(SRJ->RJ_MEMOATI)
			Endif
			cEpiFun := fGetEpiFun(SRJ->RJ_FUNCAO)
			cEPI += cEpiFun
		ElseIf cMVDescAti == 3 //Tarefa
			cMemo := RTrim(DescTarefa(TOC->(TOC_CLIENT+TOC_LOJA)))
		Endif
		//------------------------------------------------------
		//Chama Função que verifica os Epis do Centro de Custo
		//------------------------------------------------------
		If cMVBuscInf == 1
			cEPI += fGetEpiCen(SRA->RA_CC,cEPI)//Pesquisa os Epis relacionados ao centro de custo
		Else
			cEPI += fGetEpiCen(TOB->TOB_CC,cEPI)
		Endif

		//Busca a os Epis relacionados a tarefa.
		If  cMVAtePer == 3 .And. Len(aTarefas) > 0 //Tarefa
			cEPI += fGetEpiTar(aTarefas) //Busca os Epis relacionados a tarefa.
		EndIf

		nLMemo := MLCOUNT(cMemo,102)
		FOR CONT:=01 TO nlMemo
			If CONT=1
				Somalinha(oPrint,60)
			Else
				Somalinha(oPrint,50)
			EndIf
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin,2350,lin+60,2350)
			oPrint:Say(lin+10,65,Memoline(cMemo,102,CONT),oFont10p)
		NEXT CONT
		If cMVQntAgen == 1
			somalinha(oPrint,60)
			oPrint:Line(lin,50,lin,2350)
			oPrint:Say(lin+10,65,STR0024,oFont11t)	     //"Agentes Associados às Atividades:"
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin,2350,lin+60,2350)
			oPrint:line(lin+60,50,lin+60,2350)
		Endif

		//--------------------------------------
		// Funcao Funcionario //CC Funcionario
		//--------------------------------------
		aAgeAssAti := MDT715AR( RetDtRefer() )

		If Len(aAgeAssAti) > 0
			Somalinha(oPrint,60)
			oPrint:line(lin,50,lin+60,50)								//|
			oPrint:Say(lin+10,630,STR0062,oFont11b)					//|     Agente
			oPrint:line(lin,1300,lin+60,1300)              		//|     Agente     |
			oPrint:Say(lin+10,1460,STR0063,oFont11b)				//|     Agente     |     Quantidade
			oPrint:line(lin,1800,lin+60,1800)							//|     Agente     |     Quantidade     |
			oPrint:Say(lin+10,2025,STR0064,oFont11b)				//|     Agente     |     Quantidade     |     Unidade
			oPrint:line(lin,2350,lin+60,2350)							//|     Agente     |     Quantidade     |     Unidade     |
			oPrint:line(lin+60,50,lin+60,2350)							//_________________________________________________________

			Somalinha(oPrint,60)
			For CONT := 1 To Len(aAgeAssAti)
				oPrint:line(lin,50,lin+60,50)									//|
				oPrint:Say(lin+10,65,aAgeAssAti[CONT][1],oFont11t)	//|     Agente
				oPrint:line(lin,1300,lin+60,1300)								//|     Agente     |
				oPrint:Say(lin+10,1315,aAgeAssAti[CONT][2],oFont11t)	//|     Agente     |     Quantidade
				oPrint:line(lin,1800,lin+60,1800)								//|     Agente     |     Quantidade     |
				oPrint:Say(lin+10,1815,aAgeAssAti[CONT][3],oFont11t)	//|     Agente     |     Quantidade     |     Unidade
				oPrint:line(lin,2350,lin+60,2350)								//|     Agente     |     Quantidade     |     Unidade     |
				oPrint:line(lin+60,50,lin+60,2350)								//_________________________________________________________

				// É feito a verificação CONT <> Len(aAgeAssAti) para não ser impresso no ultimo
				// registro, se não ficará com um espaço em branco na tabela de impressao
				If( CONT <> Len(aAgeAssAti), Somalinha(oPrint,60), Nil )

			Next CONT
		EndIf

		somalinha(oPrint,60)
		oPrint:Line(lin,50,lin,2350)

		oPrint:Say(lin+10,65,STR0025,oFont11t)	     //"EPI`s de Uso Obrigatório: "
		oPrint:line(lin,50,lin+60,50)
		oPrint:line(lin,2350,lin+60,2350)
		oPrint:line(lin+60,50,lin+60,2350)
		If (nPosicao:=RAT(";",cEPI))>1
			cEPI:=substr(cEPI,1,nPosicao-1)+"."
		Endif
		cMemo:=RTrim(cEpi)
		nLMemo := MLCOUNT(cMemo,102)
		FOR CONT:=01 TO nlMemo
			If CONT=1
				Somalinha(oPrint,60)
			Else
				Somalinha(oPrint,50)
			EndIf
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin,2350,lin+60,2350)
			oPrint:Say(lin+10,65,Memoline(cMemo,102,CONT),oFont10p)
		NEXT CONT

		somalinha(oPrint,60)
		oPrint:Line(lin,50,lin,2350)

		oPrint:Say(lin+10,65,STR0026,oFont11t)	     //"Recomendações: "
		oPrint:line(lin,50,lin+60,50)
		oPrint:line(lin,2350,lin+60,2350)
		oPrint:line(lin+60,50,lin+60,2350)
		cMemo:=RTrim(TOB->TOB_TEXTO)
		nLMemo := MLCOUNT(cMemo,125)
		FOR CONT:=01 TO nlMemo
			If CONT == 1
				Somalinha(oPrint,60)
			Else
				Somalinha(oPrint,50)
			EndIf
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin,2350,lin+60,2350)
			oPrint:Say(lin+10,65,Memoline(cMemo,125,CONT),oFont10p)
		NEXT CONT

		somalinha(oPrint,60)
		oPrint:Line(lin,50,lin,2350)

		dbselectarea("TMZ")
		dbsetorder(01)
		dbseek(xFilial("TMZ")+TOB->TOB_TERMO)

		oPrint:Say(lin+10,65,STR0027,oFont11t)	     //"Termo de Responsabilidade: "
		oPrint:line(lin,50,lin+60,50)
		oPrint:line(lin,2350,lin+60,2350)
		oPrint:line(lin+60,50,lin+60,2350)
		cMemo:=RTrim(TMZ->TMZ_DESCRI)
		nLMemo := MLCOUNT(cMemo,125)
		FOR CONT:=01 TO nlMemo
			If CONT == 1
				Somalinha(oPrint,60)
			Else
				Somalinha(oPrint,50)
			EndIf
			oPrint:line(lin,50,lin+60,50)
			oPrint:line(lin,2350,lin+60,2350)
			oPrint:Say(lin+10,65,Memoline(cMemo,125,CONT),oFont10p)
		NEXT CONT

		somalinha(oPrint,60)
		oPrint:Line(lin,50,lin,2350)

		dbselectarea("TMK")
		dbsetorder(01)
		dbseek(xFilial("TMK")+TOB->TOB_CODRES)

		cNOMERES:=Alltrim(TMK->TMK_NOMUSU)
		nSize := If(len(cNOMERES) <= 34,len(cNOMERES),34)
		If len(cNOMERES) > 34
			cNOMERES := substr(cNOMERES,1,36)
		Endif
		nSize := 36 - nSize
		nTabu := 1
		If nSize > 1
			If (nSize % 2) != 0
				nSize++
				nTabu := (nSize / 2) - 1
			Else
				nTabu := nSize / 2
			Endif
		Endif
		cCRM:="  "
		nLin:=160
		If !Empty(TMK->TMK_NUMENT)
			cCRM:=If(Empty(TMK->TMK_ENTCLA),"CRM",Alltrim(TMK->TMK_ENTCLA))+": "+Alltrim(TMK->TMK_NUMENT)
			nLin:=200
		Endif
		nSize2 := If(len(cCRM) <= 34,len(cCRM),34)
		If len(cCRM) > 34
			cCRM := substr(cCRM,1,34)
		Endif
		nSize2 := 34 - nSize2
		nTabu2 := 1
		If nSize2 > 1
			If (nSize2 % 2) != 0
				nSize2++
				nTabu2 := (nSize2 / 2) - 1
			Else
				nTabu2 := nSize2 / 2
			Endif
		Endif

		oPrint:Say(lin+70,65,STR0028,oFont13)	     //"Aprovação: "
		oPrint:Say(lin+70,700,"__________________________________",oFont11t)
		oPrint:Say(lin+120,700,space(nTabu)+cNOMERES,oFont10r)
		oPrint:Say(lin+155,700,space(nTabu2)+cCRM,oFont10r)
		oPrint:Say(lin+75,1820,STR0029,oFont13) //"Data: "
		oPrint:Say(lin+75,1950,"  __/__/__  ",oFont15b)
		oPrint:line(lin,50,lin+nLin,50)
		oPrint:line(lin,2350,lin+nLin,2350)
		oPrint:Line(lin,1800,lin+nLin,1800)

		somalinha(oPrint,nLin)

		dbselectarea("SRA")
		dbsetorder(01)
		dbseek(xFilial("SRA")+cMVRespon)

		cNOMERES:=Alltrim(SRA->RA_NOME)
		nSize3 := If(len(cNOMERES) <= 34,len(cNOMERES),34)
		If len(cNOMERES) > 34
			cNOMERES := substr(cNOMERES,1,34)
		Endif
		nSize3 := 34 - nSize3
		nTabu3 := 1
		If nSize3 > 1
			If (nSize3 % 2) != 0
				nSize3++
				nTabu3 := (nSize3 / 2) - 1
			Else
				nTabu3 := nSize3 / 2
			Endif
		Endif

		oPrint:line(lin,50,lin,2350)
		oPrint:Say(lin+60,65,STR0030,oFont13)	     //"Responsável Empresa: "
		oPrint:Say(lin+70,700,"__________________________________",oFont11t)
		oPrint:Say(lin+120,700,space(nTabu3)+cNOMERES,oFont10r)
		oPrint:Say(lin+60,1820,STR0029,oFont13)           //"Data: "
		oPrint:Say(lin+60,1950,"  __/__/__  ",oFont15b)
		oPrint:line(lin,50,lin+160,50)
		oPrint:line(lin,2350,lin+160,2350)
		oPrint:Line(lin,1800,lin+160,1800)

		somalinha(oPrint,160)
		oPrint:Line(lin,50,lin,2350)

		oPrint:EndPage()
		lin := 100
		dbselectarea("TOC")
		dbskip()
	END

Else
	//Consistencia da para impreção da descrição da função.
	If cMVDescAti == 2 .And. SRJ->(FieldPos("RJ_MEMOATI")) <= 0
		lPrintDesc := .F.
	EndIf

	dbselectarea("TOC")
	dbsetorder(nIndTOC)
	dbseek(xFilial("TOC")+cMVDeFun,.T.)
	while !EOF() .And. TOC->TOC_Filial==xFilial("TOC") .And. &(cCodFu4) <=cMVAteFun

		If TOC->TOC_CC>cMVAteCC .Or. TOC->TOC_CC<cMVDeCC .Or. ;
				TOC->TOC_MAT>cMVAtFunc .Or. TOC->TOC_MAT<cMVDeFunc .Or. ;
				If(lTOBDepto,(TOC->TOC_DEPTO > mv_par07 .Or. TOC->TOC_DEPTO < mv_par06), .F.)
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		If lDtDevol
			If !Empty(TOC->TOC_DTFIM) .And. TOC->TOC_DTFIM < cMVDePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf

			If TOC->TOC_DTENT > cMVAtePer .And. TOC->TOC_DTFIM > cMVAtePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf

			If TOC->TOC_DTENT < cMVDePer
				If !Empty(TOC->TOC_DTFIM) .And. TOC->TOC_DTFIM < cMVDePer
					dbSelectArea("TOC")
					dbSkip()
					loop
				Endif
			EndIf
		Else
			If TOC->TOC_DTENT < cMVDePer .Or. TOC->TOC_DTENT > cMVAtePer
				dbSelectArea("TOC")
				dbSkip()
				loop
			EndIf
		EndIf

		If cMVEnderec == 1	//Se Cobrança usa os endereços de cobrança
			cEnd		:= SM0->M0_ENDCOB
			cBairro	:= SM0->M0_BAIRCOB
			cCidade	:= SM0->M0_CIDCOB
		Else					//Se Entidade usa os endereços de entidade
			cEnd		:= SM0->M0_ENDENT
			cBairro	:= SM0->M0_BAIRENT
			cCidade	:= SM0->M0_CIDENT
		EndIf

		cEPI:=""
		dbselectarea("TOB")
		dbsetorder(nIndTOB)
		If !dbseek(xFilial("TOB")+&(cCodFu4)+TOC->TOC_CC)
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		If TOB->TOB_DTELAB>cMVAtePer .Or. TOB->TOB_DTELAB<cMVDePer
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		dbselectarea("SRA")
		dbsetorder(01)
		If !dbseek(xFilial("SRA")+TOC->TOC_MAT)
			dbselectarea("TOC")
			dbskip()
			loop
		EndIf

		Dbselectarea("TM0")
		Dbsetorder(03)
		Dbseek(xFilial("TM0")+SRA->RA_MAT)

		lSA1 :=.f.
		If GetMv("MV_NGMDTPS") = "S" //Se o Cliente for prestadora de Servico
			Dbselectarea("SA1")
			Dbsetorder(1)
			If Dbseek(xFilial("SA1")+substr(SRA->RA_CC,1,6))
				lSA1 := .t.
			Else
				Dbselectarea("SA1")
				Dbsetorder(1)
				If Dbseek(xFilial("SA1")+substr(TM0->TM0_CC,1,6))
					lSA1 := .t.
				Else
					Dbselectarea("SA1")
					Dbsetorder(1)
					If Dbseek(xFilial("SA1")+TM0->TM0_Client)
						lSA1 := .t.
					Endif
				Endif
			Endif
		Endif

		lin := 100
		oPrint:StartPage()

		If lTOBDepto
			oPrint:Box(lin,100,1000,2200)
			oPrint:Line(340,100,340,2200)
			oPrint:Line(400,100,400,2200)
			oPrint:Line(580,100,580,2200)
			oPrint:Line(640,100,640,2200)
			oPrint:Line(940,100,940,2200)
			oPrint:Line(220,1690,220,2200)

			oPrint:Line(lin,770,340,770)
			oPrint:Line(lin,1690,340,1690)
			oPrint:Line(400,1630,580,1630)
			oPrint:Line(940,100,940,2200)
		Else
			oPrint:Box(lin,100,940,2200)
			oPrint:Line(340,100,340,2200)
			oPrint:Line(400,100,400,2200)
			oPrint:Line(580,100,580,2200)
			oPrint:Line(640,100,640,2200)
			oPrint:Line(220,1690,220,2200)

			oPrint:Line(lin,770,340,770)
			oPrint:Line(lin,1690,340,1690)
			oPrint:Line(400,1630,580,1630)
			oPrint:Line(640,1630,880,1630)
			oPrint:Line(880,100,880,2200)
		EndIf

		//Verifica o tamanho da imagem
		If FindFunction( "NGLocLogo" )
			oBmp := TBitmap():New(0,0,0,0,,,.F.,GetWndDefault(),,,,.F.,,,,,.T.)
			oBmp:Hide()
			If oBmp:Load(,NGLocLogo())
				oBmp:nClrPane := CLR_WHITE
				oBmp:lAutoSize    := .T.
				oBmp:lTransparent := .T.
				oBmp:Refresh()
				nLargura := oBmp:nClientWidth
				nAltura  := oBmp:nClientHeight
			EndIf
			oBmp:Free()

			//Altura e Largura máxima do Logo
			nLargMax := 660
			nAltuMax := 230

			If nLargura > nLargMax
				nAltura  := (nAltura * nLargMax) / nLargura
				nLargura := nLargMax
			EndIf
			If nAltura > nAltuMax
				nLargura := (nLargura * nAltuMax) / nAltura
				nAltura := nAltuMax
			EndIf

			If File( NGLocLogo() )
				oPrint:SayBitMap(105, 105 + ((nlargMax - nlargura)/2),NGLocLogo(),nLargura,nAltura)
		Endif
		EndIf

		oPrint:Say(150,980,cTxtTit1,oFont15)	//"ORDEM DE SERVIÇO"
		oPrint:Say(210,970,cTxtTit2,oFont15)	//"POR ATIVIDADE (O.S.)"
		oPrint:Say(290,900,STR0004,oFont15) 	//"SEGURANÇA DO TRABALHO"

		oPrint:Say(170,1755,STR0005,oFont11t)	//"Data Elaboração:"
		oPrint:Say(170,2000,DTOC(TOB->TOB_DTELAB),oFont09)
		oPrint:Say(290,1755,STR0006,oFont11t) 	//"Última Revisão:"
		oPrint:Say(290,2000,DTOC(TOB->TOB_DTREVI),oFont09)

		oPrint:Say(380,1050,STR0007,oFont13) 	//"Dados da Empresa"

		oPrint:Say(450,115,STR0008,oFont11t)	//"Razão Social/Nome:"
		oPrint:Say(500,115,STR0009,oFont11t) 	//"Endereço:"
		oPrint:Say(550,115,STR0010,oFont11t) 	//"Cidade:"

		oPrint:Say(450,1695,STR0011,oFont11t) 	//"CNPJ:"
		oPrint:Say(500,1695,STR0012,oFont11t) 	//"CNAE:"
		oPrint:Say(550,1695,STR0013,oFont11t) 	//"Bairro:"

		If lSA1
			oPrint:Say(450,370,substr(SA1->A1_NOME,1,30),oFont09)
			oPrint:Say(500,370,substr(SA1->A1_END,1,36),oFont09)
			oPrint:Say(550,370,Alltrim(SA1->A1_MUN)+If(!Empty(SA1->A1_EST),"-"+SA1->A1_EST," "),oFont09)
			oPrint:Say(450,1820,SA1->A1_CGC,oFont09)
			oPrint:Say(500,1820,SA1->A1_ATIVIDA,oFont09)
			oPrint:Say(550,1820,substr(A1_BAIRRO,1,16),oFont09)
		Else
			oPrint:Say(450,500,SM0->M0_NOMECOM,oFont09)
			oPrint:Say(500,500,cEnd,oFont09)
			oPrint:Say(550,500,Alltrim(cCidade)+If(!Empty(SM0->M0_ESTCOB),"-"+SM0->M0_ESTCOB," "),oFont09)
			oPrint:Say(450,1825,SM0->M0_CGC,oFont09)
			oPrint:Say(500,1825,SM0->M0_CNAE,oFont09)
			oPrint:Say(550,1825,cBairro,oFont09)
		EndIf

		oPrint:Say(620,1010,STR0014,oFont13) 	//"Dados do Funcionário"

		oPrint:Say(690,115,STR0015,oFont11t)	//"Nome:"
		oPrint:Say(690,450,SRA->RA_NOME,oFont09)

		dbselectarea(cAliasCC)
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cAliasCC)+SRA->RA_CC)
		Else
			dbSeek(xFilial(cAliasCC)+TOB->TOB_CC )
		Endif

		If lTOBDepto
			dbSelectArea("SQB")
			dbSetOrder( 1 ) //QB_FILIAL+QB_DEPTO
			If cMVBuscInf == 1
				dbseek(xFilial("SQB")+SRA->RA_DEPTO)
			Else
				dbSeek(xFilial("SQB")+TOB->TOB_DEPTO )
			Endif
		EndIf

		oPrint:Say(745,115,STR0016,oFont11t) 	//"Centro de Custo:"
		oPrint:Say(745,450,&(cDescCC),oFont09)

		dbselectarea(cTabFun)
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cTabFun)+&(cCodFu2))
		Else
			dbseek(xfilial(cTabFun)+&(cCodFu3))
		Endif

		If !lTOBDepto
			oPrint:Say(800,115,STR0017,oFont11t) //"Função:"
			oPrint:Say(800,450,&(cDesFu1),oFont09)
			oPrint:Say(860,115,STR0018,oFont11t) //"CTPS:"
			oPrint:Say(860,450,SRA->RA_NUMCP + SRA->RA_SERCP,oFont09)
		Else
			oPrint:Say(800,115,STR0077,oFont11t) //"Departamento:"
			oPrint:Say(800,450,SQB->QB_DESCRIC,oFont09)
			oPrint:Say(860,115,STR0017,oFont11t) //"Função:"
			oPrint:Say(860,450,&(cDesFu1),oFont09)
			oPrint:Say(920,115,STR0018,oFont11t) //"CTPS:"
			oPrint:Say(920,450,SRA->RA_NUMCP + SRA->RA_SERCP,oFont09)
		EndIf

		oPrint:Say(690,1695,STR0019,oFont11t) 	//"Matrícula:"
		oPrint:Say(690,2020,SRA->RA_MAT,oFont09)
		oPrint:Say(745,1695,STR0020,oFont11t) 	//"Data Admissão:"
		oPrint:Say(745,2020,DTOC(SRA->RA_ADMISSA),oFont09)
		oPrint:Say(800,1695,STR0021,oFont11t) 	//"Data Nascimento:"
		oPrint:Say(800,2020,DTOC(SRA->RA_NASC),oFont09)
		oPrint:Say(860,1695,STR0022,oFont11t)	//"RG:"
		oPrint:Say(860,2020,SRA->RA_RG,oFont09)

		dbselectarea(cTabFun)    //SRJ-Funcao ou ZZI-Posto de Trabalho
		dbsetorder(01)
		If cMVBuscInf == 1
			dbseek(xfilial(cTabFun)+&(cCodFu2))
		Else
			dbseek(xfilial(cTabFun)+&(cCodFu3))
		Endif

		If !lPosTrab
			dbselectarea("SQ3")
			dbsetorder(01)
			dbseek(xfilial("SQ3")+SRJ->RJ_CARGO)
		Endif

		If lTOBDepto
			oPrint:Say(980,1050,"Dados da O.S.",oFont13) //"Dados da O.S."
		Else
			oPrint:Say(920,1050,"Dados da O.S.",oFont13) //"Dados da O.S."
		EndIf

		cMemo := " "
		aBloco := {}
		If cMVDescAti == 1
			If lPosTrab
				cMemo := RTrim(ZZI->ZZI_ATIV)
			Else
				cMemo := RTrim(MSMM(SQ3->Q3_DESCDET))
			Endif
		ElseIf cMVDescAti == 2
			If SRJ->(FieldPos("RJ_MEMOATI")) > 0
				cMemo := RTrim(SRJ->RJ_MEMOATI)
			ElseIf !Empty(SRJ->RJ_DESCREQ)
				cMemo := RTrim(MSMM(SRJ->RJ_DESCREQ))
			Endif
			cEpiFun := fGetEpiFun(SRJ->RJ_FUNCAO)
			cEPI += cEpiFun
		ElseIf cMVDescAti == 3
			cMemo := RTrim(DescTarefa())
		Endif

		aAdd( aBloco , {STR0023 , cMemo} ) //"Descrição Função:"
		cMemo := ""

		//--------------------------------------
		// Funcao Funcionario //CC Funcionario
		//--------------------------------------
		aAgeAssAti := MDT715AR( RetDtRefer() )

		If Len(aAgeAssAti) > 0
			aAdd( aBloco , {STR0024 , aAgeAssAti} ) //"Agentes Associados às Atividades:"
		Else
			aAdd( aBloco , {} )
		EndIf

		//------------------------------------------------------
		//Chama Função que verifica os Epis do Centro de Custo
		//------------------------------------------------------
		If cMVBuscInf == 1
			cEPI += fGetEpiCen(SRA->RA_CC,cEPI)//Pesquisa os Epis relacionados ao centro de custo
		Else
			cEPI += fGetEpiCen(TOB->TOB_CC,cEPI)
		Endif
		aAdd( aBloco , {STR0025 , cEPI} ) //"EPI`s de Uso Obrigatório: "

		cMemo := RTrim(TOB->TOB_TEXTO)
		aAdd( aBloco , {STR0026 , cMemo} )  //"Recomendações: "
		cMemo := ""

		dbselectarea("TMZ")
		dbsetorder(01)
		dbseek(xFilial("TMZ")+TOB->TOB_TERMO)

		cMemo := RTrim(TMZ->TMZ_DESCRI)
		aAdd( aBloco , {STR0027 , cMemo} )  //"Termo de Responsabilidade: "

		//-----------------------------------------------------------------------
		// Realiza a impressão dos blocos Descrição Função, Agentes Associados,
		// EPI's obrigatórios, Recomendações e Termo de Responsabilidade.
		//-----------------------------------------------------------------------

		lin := If( lTOBDepto , 1000 , 940 )
		For nX := 1 to len(aBloco)
			If nX == 2
				If Empty(aBloco[nX])
					Loop
				EndIf
				aAgentes := aClone( aBloco[nX][2] )
				If Len(aAgentes) > 0
					oPrint:line(lin,100,lin+60,100)					//|
					oPrint:line(lin,1300,lin+60,1300)           	//|     	       |
					oPrint:line(lin,1800,lin+60,1800)				//|     	       |     		        |
					oPrint:line(lin,2200,lin+60,2200)				//|     	       |     		        |                 |

					oPrint:Say(lin+40,550,STR0062,oFont11b)			// Agente
					oPrint:Say(lin+40,1480,STR0063,oFont11b)		// Quantidade
					oPrint:Say(lin+40,1950,STR0064,oFont11b)		// Unidade

					Somalinha( oPrint, 60)
					oPrint:line(lin,100,lin,2200) 					//_________________________________________________________

					For nY := 1 To Len(aAgentes)
						oPrint:line(lin,100,lin+60,100)				//|
						oPrint:line(lin,1300,lin+60,1300)			//|                |
						oPrint:line(lin,1800,lin+60,1800)			//|                |                    |
						oPrint:line(lin,2200,lin+60,2200)			//|                |                    |                 |

						oPrint:Say(lin+40,115,aAgentes[nY][1],oFont11t) //Agente
						oPrint:Say(lin+40,1315,aAgentes[nY][2],oFont11t)//Quantidade
						oPrint:Say(lin+40,1815,aAgentes[nY][3],oFont11t)//Unidade

						oPrint:line(lin+60,100,lin+60,2200)				//_________________________________________________________

						Somalinha(oPrint,60)

					Next nY
				EndIf
			Else
				cTitle 	:= aBloco[nX][1]
				cMemo	:= aBloco[nX][2]

				//Título do bloco
				oPrint:Say(lin+40, 115, cTitle, oFont11t)
				oPrint:Line(lin, 0100, lin+60, 0100)
				oPrint:Line(lin, 2200, lin+60, 2200)
				somalinha(oPrint, 60)
				oPrint:Line(lin, 0100, lin, 2200)

				//Conteúdo do bloco
				If !Empty(cMemo)
					nLMemo := MLCOUNT(cMemo,125) * nLINPIX //Tamanho vertical que o Memo ocupará
					If (lin + nLMemo) >= 2900
						aParagrafo := StrTokArr( cMemo , CRLF ) //Pega array com paragrafos do Memo.
						cMemoAux := "" //String auxiliar com parte do Memo.
						For nY := 1 to Len(aParagrafo)
							cMemoAux += aParagrafo[nY] //Adiciona um paragrafo a string parcial
							nLMemoAux := MLCOUNT(cMemoAux,125) * nLINPIX //Conta espaço utilizado pela string parcial
								If (lin + nLMemoAux) >= 2900 //Verifica se ultrapassa final da página. Se sim, imprime até o paragrafo anterior e sai do for
									cMemoAux := SubStr( cMemoAux , 1 , nPrintStr )
									Exit
								EndIf
								nPrintStr := Len(cMemoAux)
								cMemoAux += CRLF + CRLF //Recoloca o token
						Next nY
						nLMemoAux := (MLCOUNT(cMemoAux,125) * nLINPIX)
						oPrint:SayAlign(lin+20, 115, cMemoAux, oFont10p, 2000, nLMemoAux, , 3, 0) //Imprime string parcial
						oPrint:Line(lin, 0100, lin+nLMemoAux, 0100)
						oPrint:Line(lin, 2200, lin+nLMemoAux, 2200)
						somalinha(oPrint , nLMemoAux)
						nLMemo := (nLMemo - nLMemoAux) + lin
					Else
						somalinha(oPrint, 20)
					EndIf
					oPrint:SayAlign(lin, 115, SubStr( cMemo , nPrintStr , len(cMemo) - nPrintStr ) , oFont10p, 2000, nLMemo, , 3, 0)
					oPrint:Line(lin-20, 0100, lin+nLMemo+20, 0100)
					oPrint:Line(lin-20, 2200, lin+nLMemo+20, 2200)
					somalinha(oPrint, nLMemo+20)
					oPrint:Line(lin, 0100, lin, 2200)
				EndIf
			EndIf
		Next nX

		dbselectarea("TMK")
		dbsetorder(01)
		dbseek(xFilial("TMK")+TOB->TOB_CODRES)

		oPrint:Line(lin,100,lin,2200)
		cNOMERES:=Alltrim(TMK->TMK_NOMUSU)
		nSize := If(len(cNOMERES) <= 34,len(cNOMERES),34)
		If len(cNOMERES) > 34
			cNOMERES := substr(cNOMERES,1,36)
		Endif
		nSize := 36 - nSize
		nTabu := 1
		If nSize > 1
			If (nSize % 2) != 0
				nSize++
				nTabu := (nSize / 2) - 1
			Else
				nTabu := nSize / 2
			Endif
		Endif
		cCRM:="  "
		nLin:=160
		If !Empty(TMK->TMK_NUMENT)
			cCRM:=If(Empty(TMK->TMK_ENTCLA),"CRM",Alltrim(TMK->TMK_ENTCLA))+": "+Alltrim(TMK->TMK_NUMENT)
			nLin:=200
		Endif
		nSize2 := If(len(cCRM) <= 34,len(cCRM),34)
		If len(cCRM) > 34
			cCRM := substr(cCRM,1,34)
		Endif
		nSize2 := 34 - nSize2
		nTabu2 := 1
		If nSize2 > 1
			If (nSize2 % 2) != 0
				nSize2++
				nTabu2 := (nSize2 / 2) - 1
			Else
				nTabu2 := nSize2 / 2
			Endif
		Endif

		oPrint:Say(lin+70,115,STR0028,oFont13)	     //"Aprovação: "
		oPrint:Say(lin+90,700,"__________________________________",oFont11t)
		oPrint:SayAlign(lin+140,650,space(nTabu)+cNOMERES,oFont10r,500,60,,2)
		oPrint:SayAlign(lin+175,650,space(nTabu2)+cCRM,oFont10r,500,60,,2)
		oPrint:Say(lin+100,1820,STR0029,oFont13) //"Data: "
		oPrint:Say(lin+100,1950,"  __/__/__  ",oFont15b)
		oPrint:line(lin,100,lin+nLin,100)
		oPrint:line(lin,2200,lin+nLin,2200)
		oPrint:Line(lin,1800,lin+nLin,1800)

		somalinha(oPrint,nLin)

		oPrint:Say(lin+70,115,STR0049,oFont13)	     //"Colaborador: "
		oPrint:Say(lin+100,700,"__________________________________",oFont11t)
		oPrint:SayAlign(lin+155,650,Space(nTabu)+SRA->RA_NOME,oFont10r,625,60,,2)
		oPrint:Say(lin+100,1820,STR0029,oFont13) //"Data: "
		oPrint:Say(lin+100,1950,"  __/__/__  ",oFont15b)
		oPrint:line(lin,100,lin+200,100)
		oPrint:line(lin,2200,lin+200,2200)
		oPrint:Line(lin,1800,lin+200,1800)

		oPrint:line(lin+30,100,lin+30,2200)

		somalinha(oPrint,200)

		dbselectarea("SRA")
		dbsetorder(01)
		dbseek(xFilial("SRA")+cMVRespon)

		cNOMERES:=Alltrim(SRA->RA_NOME)
		nSize3 := If(len(cNOMERES) <= 34,len(cNOMERES),34)
		If len(cNOMERES) > 34
			cNOMERES := substr(cNOMERES,1,34)
		Endif
		nSize3 := 34 - nSize3
		nTabu3 := 1
		If nSize3 > 1
			If (nSize3 % 2) != 0
				nSize3++
				nTabu3 := (nSize3 / 2) - 1
			Else
				nTabu3 := nSize3 / 2
			Endif
		Endif

		oPrint:line(lin,100,lin,2200)
		oPrint:Say(lin+60,115,STR0030,oFont13)	     //"Responsável Empresa: "
		oPrint:Say(lin+60,700,"__________________________________",oFont11t)
		oPrint:SayAlign(lin+110,650,space(nTabu3)+cNOMERES,oFont10r,500,60,,2)
		oPrint:Say(lin+100,1820,STR0029,oFont13)           //"Data: "
		oPrint:Say(lin+100,1950,"  __/__/__  ",oFont15b)
		oPrint:line(lin,100,lin+160,100)
		oPrint:line(lin,2200,lin+160,2200)
		oPrint:Line(lin,1800,lin+160,1800)

		somalinha(oPrint,160)
		oPrint:Line(lin,100,lin,2200)

		oPrint:EndPage()
		lin := 100
		dbselectarea("TOC")
		dbskip()
	END

Endif


Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Soamlinha ³ Autor ³Liber De Esteban O. P. ³ Data ³24/11/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicia nova pagina                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Somalinha(oPrint,nLinha)

lin += nLinha
If lin >= 2700
	oPrint:Line(lin,100,lin,2200)
	lin := 100
	oPrint:EndPage()
	oPrint:StartPage()
	oPrint:Line(lin,100,lin,2200)
Endif

Return .t.
//------------------------------------------------------------------
/*/{Protheus.doc} MDT715AR
Busca os riscos em que o funcionário está exposto

@param dDtRefer  Date   Data a ser considerada como referência para busca dos riscos

@return aAgeAssAti Array Array contendo os agentes

@sample MDT715AR( '01/01/2015' )

@author Jackson Machado
@since 20/05/2015
/*/
//---------------------------------------------------------------------
Static Function MDT715AR( dDtRefer )

Local aAgeAssAti := {}

	Default dDtRefer := StoD( Space( 8 ) )

	If cMVBuscInf == 1
		MDTRETRIS( dDtRefer , , , { | | fGetAgent( @aAgeAssAti ) } , , , , .F. , .T. )
Else
		MDTRETRIS( dDtRefer , , , { | | fGetAgent( @aAgeAssAti ) } , , , , .F. )
			EndIf

Return aAgeAssAti
//------------------------------------------------------------------
/*/{Protheus.doc} fGetAgent
Salva os agentes e os epi's necessários para o risco

@param aAgeAssAti Array Array contendo os agentes

@return Nill

@sample fGetAgent( @{} )

@author Jackson Machado
@since 20/05/2015
/*/
//---------------------------------------------------------------------
Static Function fGetAgent( aAgeAssAti )

	Local nIdx := 1
	Local cSeek := "xFilial('TNX')+TN0->TN0_NUMRIS"
	Local cCondWhl := ".T."

	If lSigaMdtPs
		nIdx := 4
		cSeek := "xFilial('TNX')+cCliMdtps+TN0->TN0_NUMRIS"
		cCondWhl := "cCliMdtps == TNX->(TNX_CLIENT+TNX_LOJA)"
	EndIf

	dbSelectArea( "TMA" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "TMA" ) + TN0->TN0_AGENTE )

						If lAgen
			aAdd( aAgeAssAti , { 	Alltrim( TMA->TMA_NOMAGE ) , ;
				Alltrim( StrTran( Str( TN0->TN0_QTAGEN , 9 , 3 ) , "." , "," ) ) , ;
				Alltrim( TN0->TN0_UNIMED ) } )
						EndIf

		dbSelectArea( "TNX" )
		dbSetOrder( nIdx )
		dbSeek( &( cSeek ) )
		While TNX->( !Eof() ) .And. xFilial( "TNX" ) == TNX->TNX_FILIAL .And. ;
				TN0->TN0_NUMRIS == TNX->TNX_NUMRIS .And. &( cCondWhl )

			dbSelectArea( "SB1" )
			dbSetOrder( 1 )
			If dbseek( xFilial( "SB1" ) + TNX->TNX_EPI ) .And. !( AllTrim( SB1->B1_DESC ) $ cEPI )
				cEpi += AllTrim( SB1->B1_DESC ) + ";  "
								Endif

			dbSelectArea( "TNX" )
			dbSkip()
						End
Endif

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   |DescTarefa ³ Autor³ Denis Hyroshi         ³ Data  ³ 21/03/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³Busca descricao da tarefa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR715                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Static Function DescTarefa(cCliMdtps)

Local lNoJob := .t.
Local dtIni  := dDataBase
Local dtFim  := dDataBase+1
Local cRet   := ""

Local cSeekTN5	:= If(lSigaMdtPS,"xFilial('TN5')+cCliMdtps+TN6->TN6_CODTAR" , "xFilial('TN5')+TN6->TN6_CODTAR")
Local nIndexTN5	:= If(lSigaMdtPS, 3, 1 )

Dbselectarea("TN6")
Dbsetorder(2)
Dbseek(xFilial("TN6")+SRA->RA_MAT)
While !eof() .And. xFilial("TN6") == TN6->TN6_FILIAL .And. SRA->RA_MAT == TN6->TN6_MAT

    If TN6->TN6_DTINIC >= dtFim .Or. (TN6->TN6_DTTERM < dtIni .And. !Empty(TN6->TN6_DTTERM))
    	Dbselectarea("TN6")
    	Dbskip()
    	Loop
    Endif

	If TN6->TN6_DTINIC == dtIni
	    lStart  := .t.
	Elseif TN6->TN6_DTINIC < dtIni .And. (TN6->TN6_DTTERM >= dtIni  .Or. Empty(TN6->TN6_DTTERM))
		lStart  := .t.
	Endif

	If lStart
	    Dbselectarea("TN5")
	    Dbsetorder(nIndexTN5)  //TN5_FILIAL(+TN5_CLIENT+TN5_LOJA)+TN5_CODTAR
	    Dbseek(&cSeekTN5)
		If !lNoJob
			cRet += chr(13)+chr(10)
		Endif
		If TN5->(FieldPos("TN5_DESCRI")) > 0
			If !Empty(TN5->TN5_DESCRI)
			    cRet += Alltrim(TN5->TN5_DESCRI) + chr(13)+chr(10)
			Endif
		Else
			If !Empty(TN5->TN5_DESTAR)
			    cRet += Alltrim(TN5->TN5_DESTAR) + chr(13)+chr(10)
			Endif
			If !Empty(TN5->TN5_DESCR1)
				cRet += Alltrim(TN5->TN5_DESCR1) + chr(13)+chr(10)
			Endif
			If !Empty(TN5->TN5_DESCR2)
				cRet += Alltrim(TN5->TN5_DESCR2) + chr(13)+chr(10)
			Endif
			If !Empty(TN5->TN5_DESCR3)
				cRet += Alltrim(TN5->TN5_DESCR3) + chr(13)+chr(10)
			Endif
			If !Empty(TN5->TN5_DESCR4)
				cRet += Alltrim(TN5->TN5_DESCR4) + chr(13)+chr(10)
			Endif
		EndIf
		lNoJob := .f.
	Endif

	Dbselectarea("TN6")
	Dbskip()
End

Return cRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDT715SRA ³ Autor³ Denis Hyroshi         ³ Data  ³ 21/03/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida campo Codigo Representante                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR715                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Static Function MDT715SRA()

If !Empty(Mv_par14)
	If !ExCpoMDT('SRA',Mv_par14)
		Return .F.
	ElseIf lSigaMdtPS
		If Substr(SRA->RA_CC,1,nSizeTD) < Mv_par01+Mv_par02 .Or. Substr(SRA->RA_CC,1,nSizeTD) > Mv_par03+Mv_par04
			Help(" ",1,"REGNOIS")
			Return .F.
		Endif
	Endif
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} RetDtRefer
Define data de referencia para avaliacao dos riscos, a partir da data de Elaboracao e/ou Revisao.
Caso haja data de revisao, sera considerada prioritaria em relacao a de elaboracao.

@author Hugo R. Pereira
@since 08/10/2012
@version MP10
@return dDtRefer
/*/
//---------------------------------------------------------------------
Static Function RetDtRefer( nRecTOB )

Local dDtRefer := CTOD("")
Local lRecno   := .F.

// Armazena areas de trabalho
Local aArea    := {}
Local aAreaTOB := {}

Default nRecTOB := 0

// Verifica se foi repassado recno
If ( lRecno := ( nRecTOB > 0 ) )

	aArea    := GetArea()
	aAreaTOB := TOB->(GetArea())

	dbSelectArea("TOB")
	dbgoto(nRecTOB)

Endif

// Caso haja data de revisao, desconsidera data de elaboracao
dDtRefer := If( !Empty(TOB->TOB_DTREVI), TOB->TOB_DTREVI, TOB->TOB_DTELAB )

// Retorna areas de trabalho apenas se houve passagem de recno
If lRecno
	RestArea(aAreaTOB)
	RestArea(aArea)
Endif

Return dDtRefer

//---------------------------------------------------------------------
/*{Protheus.doc} fGetEpiFun()
Define data de referencia para avaliacao dos riscos, a partir da data de Elaboracao e/ou Revisao.
Caso haja data de revisao, sera considerada prioritaria em relacao a de elaboracao.

@author Bruno L. Souza
@since 26/07/2013
@version MP11

*/
//---------------------------------------------------------------------
Static Function fGetEpiFun(cCodFun)
Local cEpiFun := ""
dbSelectArea("TNB")
dbSetOrder(2)
If dbSeek(xFilial("TNB")+cCodFun)
	While(xFilial("TNB") == TNB->TNB_FILIAL .And. cCodFun == TNB->TNB_CODFUN)
		cEpiFun += Alltrim(NGSEEK("SB1",TNB->TNB_CODEPI,1,"B1_DESC")) + "; "
		dbSkip()
	End
EndIf

Return cEpiFun

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetEpiCen
Função que busca os Epis relacionados ao Centro de Custo.

@author Guilherme Freudenburg
@since 29/08/2014
@sample MDTR715
@return cEpiFun
/*/
//---------------------------------------------------------------------
Static Function fGetEpiCen(cCentro,cEpi)

Local cEpiFun := ""
Local cVerEpi :=""

dbSelectArea("TOH")
dbSetOrder(1)
If dbSeek(xFilial("TOH")+cCentro)
	While TOH->(!Eof()) .And. xFilial("TOH") == TOH->TOH_FILIAL .And. cCentro == TOH->TOH_CC
		cVerEpi := Alltrim(NGSEEK("SB1",TOH->TOH_CODEPI,1,"B1_DESC")) + "; "
		If !(cVerEpi $ cEpi) .Or. Empty(cEpi)
			cEpiFun += cVerEpi
		Endif
		TOH->(dbSkip())
	End
EndIf

Return cEpiFun

//---------------------------------------------------------------------
/*/{Protheus.doc} fChkMDTSX1
Função que busca os Epis relacionados ao Centro de Custo.

@author Guilherme Benkendorf
@since 29/09/2015
@sample MDTR715
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fChkMDTSX1( cPerg )
	Local nTamSX1 := Len(SX1->X1_GRUPO)
	Local aPerg := {}

	dbSelectArea("TM0")
	If  TM0->(FieldPos("TM0_CODPOS")) > 0 .And. ;
			SRA->(FieldPos("RA_POSTO"))   > 0 .And. ;
			TN0->(FieldPos("TN0_CODPOS")) > 0 .And. ;
			(TAMSX3("ZZI_COD")[1])        > 0
		cTxtTit1 := "   PROCEDIMENTO"
		cTxtTit2 := "    DE SEGURANÇA"
		lPosTrab := .t.
		nIndTN0  := 8
		nIndTOB  := 4
		nIndTOC  := 3
		cCodFu1  := "TN0->TN0_CODPOS"
		cCodFu2  := "SRA->RA_POSTO"
		cCodFu3  := "TOB->TOB_CODPOS"
		cCodFu4  := "TOC->TOC_CODPOS"
		cDesFu1  := "ZZI->ZZI_DESC"
		nSizeSRJ := (TAMSX3("ZZI_COD")[1])
		cTabFun  := "ZZI"
		strFuncao := STR0048 //"Posto Trab."
	Endif

Return Nil