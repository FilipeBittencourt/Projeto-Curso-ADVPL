#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
    #DEFINE PSAY SAY
#ENDIF

User Function finr130()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LEND,CDESC1,CDESC2,CDESC3,CSTRING,TITULO")
SetPrvt("CABEC1,CABEC2,ALINHA,ARETURN,CPERG,NJUROS")
SetPrvt("NLASTKEY,NOMEPROG,TAMANHO,WNREL,AORD,CBCONT")
SetPrvt("CBTXT,LIMITE,NORDEM,LCONTINUA,CCOND1,CCOND2")
SetPrvt("CCARANT,NTIT1,NTIT2,NTIT3,NTIT4,NTIT5")
SetPrvt("NTOTJ,NTOT1,NTOT2,NTOT3,NTOT4,NTOTTIT")
SetPrvt("NTOTJUR,ACAMPOS,ATAM,NATRASO,NTOTABAT,NSALDO")
SetPrvt("DDATAREAJ,CFILTRO,BFILTRO,DDATAANT,LQUEBRA,NMESTIT1")
SetPrvt("NMESTIT2,NMESTIT3,NMESTIT4,NMESTTIT,NMESTITJ,CMOEDA")
SetPrvt("DBAIXA,LI,M_PAG,CNOMEARQ,ACAMPO,CINDEX")
SetPrvt("CCHAVE,_CFIL,NINDEX,NMESTOT1,NMESTOT2,NMESTOT3")
SetPrvt("NMESTOT4,NMESTOTTIT,NMESTOTJ,ASITUACA,CALIAS,APERG")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     #DEFINE PSAY SAY
#ENDIF

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINR130  ³ Autor ³ Paulo Boschetti       ³ Data ³ 01.06.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posi‡„o dos Titulos a Receber                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR130(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alessandro ³05/12/97³13652A³ Incluir filtro no relatorio.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rdmake 2/406³ Autor  ³ Luiz Carlos Vieira      ³ Data ³ Fri  24/04/98  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Declaracao de variaveis                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lEnd     := .F.
cDesc1   := "Imprime a posi‡„o dos titulos a receber relativo a data ba-"
cDesc2   := "se do sistema."
cDesc3   := ""
cString  := "SE1"
titulo   :=""
cabec1   :=""
cabec2   :=""
aLinha   :={}
aReturn  :={ "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cPerg    :="FIN130"
nJuros   :=0
nLastKey :=0
nomeprog :="FINR130"
tamanho  :="G"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o dos cabe‡alhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "Posicao dos Titulos a Receber"
cabec1 := "Codigo Nome do Cliente      Prf-Numero   TP  Natureza    Data de  Vencto   Vencto  Banco  |        Titulos Vencidos         |    Titulos a Vencer     | Num       Valor dos juros ou   Dias  Historico     (Vencidos+Vencer)"
cabec2 := "                            Parcela                      Emissao  Titulo    Real          | Valor Nominal   Valor Corrigido |      Valor Nominal      | Banco      com  permanencia   Atraso                                "

//ajustasx1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("FIN130",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros   ³
//³ mv_par01         // Do Cliente         ³
//³ mv_par02         // Ate o Cliente      ³
//³ mv_par03         // Do Prefixo         ³
//³ mv_par04         // Ate o prefixo      ³
//³ mv_par05         // Do Titulo          ³
//³ mv_par06         // Ate o Titulo       ³
//³ mv_par07         // Do Banco           ³
//³ mv_par08         // Ate o Banco        ³
//³ mv_par09         // Do Vencimento      ³
//³ mv_par10         // Ate o Vencimento   ³
//³ mv_par11         // Da Natureza        ³
//³ mv_par12         // Ate a Natureza     ³
//³ mv_par13         // Da Emissao         ³
//³ mv_par14         // Ate a Emissao      ³
//³ mv_par15         // Qual Moeda         ³
//³ mv_par16         // Imprime provisorios³
//³ mv_par17         // Reajuste pelo vecto³
//³ mv_par18         // Impr Tit em Descont³
//³ mv_par19         // Relatorio Anal/Sint³
//³ mv_par20         // Cons Data Base     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a fun‡„o SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="FINR130"            //Nome Default do relatorio em Disco
aOrd :={"Por Cliente","Por Numero","Por Banco","Por Venc/Cli","Por Natureza","Por Emissao","Por Ven\Bco","Por Cod.Cli.","Banco/Situacao"}
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
End

RptStatus( {||FA130Imp()} )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> RptStatus( {||Execute(FA130Imp)} )
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function FA130Imp
Static Function FA130Imp()

CbCont    := 0
CbTxt     := ""
limite    := 220
nOrdem    := 0
lContinua := .T.
cCond1    := ""
cCond2    := ""
cCarAnt   := ""
nTit1     := 0
nTit2     := 0
nTit3     := 0
nTit4     := 0
nTit5     := 0
nTotJ     := 0
nTot1     := 0
nTot2     := 0
nTot3     := 0
nTot4     := 0
nTotTit   := 0
nTotJur   := 0
aCampos   := {}
aTam      := {}
nAtraso   := 0
nTotAbat  := 0
nSaldo    := 0
dDataReaj := CTOD("")
cFiltro   := ""
bFiltro   := NIL
dDataAnt  := dDataBase
lQuebra   := .F.
nMesTit1  := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
nOrdem    := aReturn[8]
cMoeda    := Str(mv_par15,1)
dBaixa    := dDataBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= "* indica titulo provisorio, P Indica Saldo Parcial"
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("SE1")
Set Softseek On

If Len( aReturn[7] ) > 0
        IF RDDNAME()=="TOPCONN"
		msFilter( aReturn[7] )
        ELSE
		cFiltro := "{|| "+aReturn[7] +"}"
		bFiltro := &cFiltro
		dbSetFilter(bFiltro)
        ENDIF
EndIf

IF nOrdem == 1
	aTam:=TamSX3("E1_FILIAL")
	AADD(aCampos,{"FILIAL" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PREFIXO")
	AADD(aCampos,{"PREFIXO","C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_NUM")
	AADD(aCampos,{"NUMERO" ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_PARCELA")
	AADD(aCampos,{"PARCELA","C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_TIPO")
	AADD(aCampos,{"TIPO"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_CLIENTE")
	AADD(aCampos,{"CLIENTE","C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_LOJA")
	AADD(aCampos,{"LOJA"   ,"C",aTam[1],aTam[2]})
	aTam:=TamSX3("E1_NOMCLI")
	AADD(aCampos,{"NOMECLI","C",aTam[1],aTam[2]})

	cNomeArq:=CriaTrab(aCampos)
	Use &cNomeArq Alias cNomeArq New
        IndRegua("cNomeArq",cNomeArq,"NOMECLI+CLIENTE+FILIAL+PREFIXO+NUMERO+PARCELA+TIPO",,,;
                              "Selecionando Registros...")
	dbSelectArea("SE1")
        dbSetOrder(2)
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Monta a linha da regua ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        SetRegua( LastRec() )

        dbSeek(xFilial("SE1")+mv_par01)
        While !EOF() .and. xFilial()==SE1->E1_FILIAL .and. SE1->E1_CLIENTE <= mv_par02
		 IF SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
                    SE1->E1_NUM     < mv_par05 .OR. SE1->E1_NUM     > mv_par06 .OR. ;
                    SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
                    SE1->E1_VENCREA < mv_par09 .OR. SE1->E1_VENCREA > mv_par10 .OR. ;
                    SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .or. ;
                    SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .or. ;
                    SE1->E1_EMISSAO > dDataBase
                    dbSkip()
                    Loop
		  EndIF
                  IncRegua()

                 If mv_par18 == 2 .and. E1_SITUACA $ "27"
                    dbSkip()
                    Loop
                 Endif

                 IF !Empty(SE1->E1_FATURA) .and. Substr(SE1->E1_FATURA,1,6) != "NOTFAT" .and. SE1->E1_DTFATUR <= dDataBase
                    dbSkip()
                    Loop
                 EndIf

                 If xFilial("SE1") != SE1->E1_FILIAL
                    dbSkip()
                    Loop
                 EndIf

                 RecLock("cNomeArq",.T.)
                 cNomeArq->FILIAL    := SE1->E1_FILIAL
                 cNomeArq->PREFIXO   := SE1->E1_PREFIXO
                 cNomeArq->NUMERO    := SE1->E1_NUM
                 cNomeArq->PARCELA   := SE1->E1_PARCELA
                 cNomeArq->TIPO      := SE1->E1_TIPO
                 cNomeArq->CLIENTE   := SE1->E1_CLIENTE
                 cNomeArq->LOJA      := SE1->E1_LOJA
                 cNomeArq->NOMECLI   := SE1->E1_NOMCLI
                 MsUnlock()
                 dbSelectArea("SE1")
                 dbSkip()
        EndDo

       cCond1 := "CLIENTE <= mv_par02"
       cCond2 := "CLIENTE + LOJA"
       titulo := titulo + " - Por Cliente"
Elseif nOrdem == 2
       dbSetOrder(1)
       dbSeek(xFilial()+mv_par03+mv_par05)
       cCond1 := "E1_NUM <= mv_par06"
       cCond2 := "E1_NUM"
       titulo := titulo + " - Por Numero"
Elseif nOrdem == 3
       dbSetOrder(4)
       dbSeek(xFilial("SE1")+mv_par07)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a linha da regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SetRegua( LastRec() )
       cCond1 := "E1_PORTADO <= mv_par08"
       cCond2 := "E1_PORTADO"
       titulo := titulo + " - Por Banco"
Elseif nOrdem == 4
       DbSetOrder(7)
       dbSeek(xFilial("SE1")+DTOS(mv_par09))
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a linha da regua ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SetRegua( LastRec() )
       cCond1 := "E1_VENCREA <= mv_par10"
       cCond2 := "E1_VENCREA"
       titulo := titulo + " - Por Data de Vencimento"
Elseif nOrdem == 5
       dbSetOrder(3)
       dbSeek(xFilial()+mv_par11)
       cCond1 := "E1_NATUREZ <= mv_par12"
       cCond2 := "E1_NATUREZ"
       titulo := titulo + " - Por Natureza"
Elseif nOrdem == 6
       DbSetOrder(6)
       Seek xFilial()+DTOS(mv_par13)
       cCond1 := "E1_EMISSAO <= mv_par14"
       cCond2 := "E1_EMISSAO"
       titulo := titulo + " - Por Emissao"
Elseif nOrdem == 7
       aCampo:= {}
       aTam  := {}
       aTam  := TamSX3("E1_FILIAL")
	  AADD(aCampos,{"FILIAL" ,"C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_PREFIXO")
	  AADD(aCampos,{"PREFIXO","C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_NUM")
	  AADD(aCampos,{"NUMERO" ,"C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_PARCELA")
	  AADD(aCampos,{"PARCELA","C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_TIPO")
	  AADD(aCampos,{"TIPO"   ,"C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_CLIENTE")
	  AADD(aCampos,{"CLIENTE","C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_LOJA")
	  AADD(aCampos,{"LOJA"   ,"C",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_VENCREA")
	  AADD(aCampos,{"VENCTO" ,"D",aTam[1],aTam[2]})
	  aTam:=TamSX3("E1_PORTADO")
	  AADD(aCampos,{"BANCO"  ,"C",aTam[1],aTam[2]})
	  cNomeArq:=CriaTrab(aCampos)

	  Use &cNomeArq Alias cNomeArq New
          IndRegua("cNomeArq",cNomeArq,"DtoS(VENCTO)+BANCO+FILIAL+PREFIXO+NUMERO+PARCELA+TIPO",,,;
                                  "Selecionando Registros...")
	  dbSelectArea("SE1")
	  dbSetOrder(7)
          dbSeek(xFilial()+DtoS(mv_par09))
          While !EOF() .and. xFilial()==SE1->E1_FILIAL .and. SE1->E1_VENCREA <= mv_par10
			IF SE1->E1_PREFIXO  < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
                           SE1->E1_NUM      < mv_par05 .OR. SE1->E1_NUM    > mv_par06 .OR. ;
                           SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
                           SE1->E1_VENCREA < mv_par09 .OR. SE1->E1_VENCREA > mv_par10 .OR. ;
                           SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .or. ;
                           SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .or. ;
                           SE1->E1_EMISSAO > dDataBase
                           dbSkip()
                           Loop
                         End

			IF !Empty(SE1->E1_FATURA) .and. Substr(SE1->E1_FATURA,1,6) != "NOTFAT" .and. SE1->E1_DTFATUR <= dDataBase
                           dbSkip()
                           Loop
			End

			If mv_par18 == 2 .and. E1_SITUACA $ "27"
                           dbSkip()
                           Loop
			End

			If xFilial("SE1") != SE1->E1_FILIAL
                           dbSkip()
                           Loop
                        EndIf

			RecLock("cNomeArq",.T.)
                        cNomeArq->FILIAL  := SE1->E1_FILIAL
                        cNomeArq->PREFIXO := SE1->E1_PREFIXO
                        cNomeArq->NUMERO  := SE1->E1_NUM
                        cNomeArq->PARCELA := SE1->E1_PARCELA
                        cNomeArq->TIPO    := SE1->E1_TIPO
                        cNomeArq->CLIENTE := SE1->E1_CLIENTE
                        cNomeArq->LOJA    := SE1->E1_LOJA
                        cNomeArq->VENCTO  := SE1->E1_VENCREA
                        cNomeArq->BANCO   := SE1->E1_PORTADO
                        MsUnlock()
			dbSelectArea("SE1")
                        dbSkip()
          Enddo
	  cCond1 := "VENCTO <= mv_par10"
	  cCond2 := "DtoS(VENCTO)+BANCO"
	  titulo := titulo + " - Por Vencto/Banco"

Elseif nOrdem == 8
     dbSetOrder(2)
     dbSeek(xFilial()+mv_par01,.T.)
     cCond1 := "E1_CLIENTE <= mv_par02"
     cCond2 := "E1_CLIENTE"
     titulo := titulo + " - Por Cod.Cliente"
Elseif nOrdem == 9
     dbSelectArea("SE1")
     cIndex := CriaTrab(nil,.f.)
     cChave := "E1_FILIAL+E1_PORTADO+E1_SITUACA+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
     _cFil := ""
     #IFNDEF TOP
         _cFil := 'E1_PORTADO>="'+mv_par07+'" .And. '
         _cFil := _cFil + 'E1_PORTADO<= "'+mv_par08+'"'
     #ELSE
         _cFil := 'E1_PORTADO>="'+mv_par07+'" .And. '
         _cFil := _cFil + 'E1_PORTADO<= "'+mv_par08+'"'
     #ENDIF
     IndRegua("SE1",cIndex,cChave,,_cFil,"Selecionando Registros...")
	  cCond1 := "E1_PORTADO <= mv_par08"
	  cCond2 := "E1_PORTADO+E1_SITUACA"
          titulo := titulo + " - Por Banco e Situacao"
	  nIndex := RetIndex("SE1")
	  #IFNDEF TOP
             dbSetIndex(cIndex)
	  #ENDIF
	  dbSetOrder(nIndex+1)
	  dbSeek(xFilial("SE1"))
Endif

If mv_par19 == 1
	titulo := titulo + " - Analitico"
Else
	titulo := titulo + " - Sintetico"
	 cabec1 := "                                                                                          |        Titulos Vencidos         |    Titulos a Vencer     |           Valor dos juros ou         Historico     (Vencidos+Vencer)"
	 cabec2 := "                                                                                          | Valor Nominal   Valor Corrigido |      Valor Nominal      |            com  permanencia                                         "
EndIf

 IF nOrdem == 1 .or. nOrdem == 7
	  dbSelectArea("cNomeArq")
	  dbGoTop()
 Else
	  dbSelectArea("SE1")
 EndIF

 Set Softseek Off

 SetRegua(RecCount())

 While &cCond1 .and. !Eof() .and. lContinua

	  IF nOrdem != 1 .and. nOrdem != 7
            IF E1_FILIAL != xFilial()
				 Exit
			End
	  End

	  #IFNDEF WINDOWS
	     Inkey()
          If LastKey() == 286
                lEnd := .t.
		  End
	  #ENDIF

	  IF	lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
			Exit
	  End

	  IncRegua()

	  dbSelectArea("SE1")
	  IF nOrdem == 1 .or. nOrdem == 7
			dbSetOrder(2)
            dbSeek(xFilial()+cNomeArq->CLIENTE+cNOmeArq->LOJA+cNomeArq->PREFIXO+cNomeArq->NUMERO+cNomeArq->PARCELA+cNomeArq->TIPO)
	  EndIF

	  Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5

	  IF nOrdem == 1 .or. nOrdem == 7
			dbSelectArea("cNomeArq")
	  Else
			dbSelectArea("SE1")
	  End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega data do registro para permitir ³
                //³ posterior analise de quebra por mes.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  dDataAnt := Iif(nOrdem == 6 , SE1->E1_EMISSAO,  SE1->E1_VENCREA)

	  cCarAnt := &cCond2

	  While &cCond2==cCarAnt .and. !Eof() .and. lContinua

			#IFNDEF WINDOWS
			   Inkey()
                           If LastKey() == 286
                              lEnd := .t.
                           End
			#ENDIF

			IF lEnd
                           @PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
                           lContinua := .F.
                           Exit
			EndIF

			dbSelectArea("SE1")

			IF nOrdem == 1 .or. nOrdem == 7
                           dbSetOrder(2)
                           dbSeek(xFilial()+cNomeArq->CLIENTE+cNOmeArq->LOJA+cNomeArq->PREFIXO+cNomeArq->NUMERO+cNomeArq->PARCELA+cNomeArq->TIPO)
			Endif

			If xFilial("SE1") != SE1->E1_FILIAL
                           dbSkip()
                           Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se trata-se de abatimento ou somente titulos³
                        //³ at‚ a data base.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        IF SubStr(SE1->E1_TIPO,3,1) == "-" .Or. SE1->E1_EMISSAO>dDataBase .or.;
				(nOrdem==3.and.Empty(SE1->E1_PORTADO)) .or. ;
				(!Empty(E1_FATURA).and.Substr(E1_FATURA,1,6)!="NOTFAT".and.SE1->E1_DTFATUR<=dDataBase)
				 IF nOrdem == 1 .or. nOrdem == 7
                                    dbSelectArea("cNomeArq")
				 Else
                                    dbSelectArea("SE1")
				 EndIF
				 dbSkip()
				 Loop
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ser  impresso titulos provis¢rios			³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF SubStr(E1_TIPO,1,2) == "PR" .and. mv_par16 == 2
                           IF nOrdem == 1 .or. nOrdem == 7
                              dbSelectArea("cNomeArq")
                           Else
                              dbSelectArea("SE1")
                           EndIF
                           dbSkip()
                           Loop
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //³ Verifica se ser  impresso RA CESAR                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        IF SubStr(E1_TIPO,1,2) == "RA" .OR. E1_TIPO == "NCC"                 
                           IF nOrdem == 1 .or. nOrdem == 7
                              dbSelectArea("cNomeArq")
                           Else
                              dbSelectArea("SE1")
                           EndIF
                           dbSkip()
                           Loop
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta dentro dos parametros ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SE1")
			IF SE1->E1_CLIENTE < mv_par01 .OR. SE1->E1_CLIENTE > mv_par02 .OR. ;
				 SE1->E1_PREFIXO < mv_par03 .OR. SE1->E1_PREFIXO > mv_par04 .OR. ;
				 SE1->E1_NUM	  < mv_par05 .OR. SE1->E1_NUM 	 > mv_par06 .OR. ;
				 SE1->E1_PORTADO < mv_par07 .OR. SE1->E1_PORTADO > mv_par08 .OR. ;
				 SE1->E1_VENCREA < mv_par09 .OR. SE1->E1_VENCREA > mv_par10 .OR. ;
				 SE1->E1_NATUREZ < mv_par11 .OR. SE1->E1_NATUREZ > mv_par12 .OR. ;
				 SE1->E1_EMISSAO < mv_par13 .OR. SE1->E1_EMISSAO > mv_par14 .OR. ;
				 SE1->E1_EMISSAO > dDataBase
				 If nOrdem == 1 .or. nOrdem == 7
                                    dbSelectArea("cNomeArq")
				 End
				 dbSkip()
				 Loop
			End

			If mv_par18 == 2 .and. E1_SITUACA $ "27"
                           IF nOrdem == 1 .or. nOrdem == 7
                              dbSelectArea("cNomeArq")
                           End
                           dbSkip()
                           Loop
			End

			If !Empty(SE1->E1_DTFATUR)		// Retroativo
                           nSaldo := xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,mv_par15,SE1->E1_VENCTO)
			Else
                           dDataReaj := IIF(mv_par17=1,dDataBase,E1_VENCTO)

                           If mv_par20 == 1
                              nSaldo:=SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par15,dDataReaj,,SE1->E1_LOJA)
                           Else
                              nSaldo:=xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,mv_par15,SE1->E1_VENCTO)
                           Endif

                           If SE1->E1_TIPO != "RA " .And. SE1->E1_TIPO != "NCC"
                              nSaldo := nSaldo - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1)
                           EndIf

                           nSaldo:=Round(NoRound(nSaldo,3),2)
			Endif

                        If nSaldo <= 0

                           IF nOrdem == 1 .or. nOrdem == 7
                              dbSelectArea("cNomeArq")
                           Else
                              dbSelectArea("SE1")
                           EndIF
                           dbSkip()
                           Loop
			Endif

			dbSelectArea("SA1")
                        dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA)
			dbSelectArea("SA6")
                        dbSeek(xFilial()+SE1->E1_PORTADO)
			dbSelectArea("SE1")

			IF li > 58
                           cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
			EndIF

			If mv_par19 == 1
				@li,	0 PSAY SE1->E1_CLIENTE
				@li,	7 PSAY SubStr( SE1->E1_NOMCLI, 1, 20 )
				@li, 28 PSAY SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" "+SE1->E1_TIPO
				@li, 45 PSAY SE1->E1_NATUREZ
				@li, 56 PSAY SE1->E1_EMISSAO
				@li, 65 PSAY SE1->E1_VENCTO
				@li, 74 PSAY SE1->E1_VENCREA
				@li, 84 PSAY ALLTRIM(SE1->E1_PORTADO)+" "+SE1->E1_SITUACA
			End

			If nOrdem == 1 	//Restaura ordens originais
				 dbSetOrder(2)
			ElseIf nOrdem == 2
				 dbSetOrder(1)
			ElseIf nOrdem == 3
				 dbSetOrder(4)
			ElseIf nOrdem == 4
				 dbSetOrder(7)
			ElseIf nOrdem == 5
				 dbSetOrder(3)
			ElseIf nOrdem == 7
				 dbSetOrder(7)
			ElseIf nOrdem == 8
				 dbSetOrder(2)
			End

			If dDataBase > E1_VENCREA	//vencidos

                           If mv_par19 == 1
                              @li, 92 PSAY nSaldo Picture tm ( nSaldo, 16 )
                           EndIf
                           nJuros:=0
                           fa070Juros(mv_par15)
                           dbSelectArea("SE1")
                           If mv_par19 == 1
                              @li,108 PSAY nSaldo+nJuros Picture tm(nSaldo+nJuros,16)
                           EndIf
                           If Subs(SE1->E1_TIPO,1,2)!="RA" .and. SE1->E1_TIPO != "NCC"
                              nTit1 := nTit1 + (nSaldo)
                              nTit2 := nTit2 + (nSaldo+nJuros)
                              nMesTit1 := nMesTit1 + (nSaldo)
                              nMesTit2 := nMesTit2 + (nSaldo+nJuros)
                           Else
                              nTit1 := nTit1 - (nSaldo)
                              nTit2 := nTit2 - (nSaldo+nJuros)
                              nMesTit1 := nMesTit1 - (nSaldo)
                              nMesTit2 := nMesTit2 - (nSaldo+nJuros)
                           Endif
                           nTotJur  := nTotJur  + nJuros
                           nMesTitj := nMesTitj + nJuros
			Else						//a vencer
                           If mv_par19 == 1
                              @li,126 PSAY nSaldo Picture tm ( nSaldo, 16 )
                           EndIf
                           If Subs(SE1->E1_TIPO,1,2)!="RA" .and. E1_TIPO != "NCC"
                              nTit3 := nTit3 + (nSaldo-nTotAbat)
                              nTit4 := nTit4 + (nSaldo-nTotAbat)
                              nMesTit3 := nMesTit3 + (nSaldo-nTotAbat)
                              nMesTit4 := nMesTit4 + (nSaldo-nTotAbat)
                           Else
                              nTit3 := nTit3 - (nSaldo-nTotAbat)
                              nTit4 := nTit4 - (nSaldo-nTotAbat)
                              nMesTit3 := nMesTit3 - (nSaldo-nTotAbat)
                              nMesTit4 := nMesTit4 - (nSaldo-nTotAbat)
                           Endif
			Endif

			If mv_par19 == 1
                           @ li, 153 PSAY SE1->E1_NUMBCO
			EndIf
			If nJuros > 0
                           If mv_par19 == 1
                              @ Li,164 PSAY nJuros Picture Tm(nJuros,16)
                           EndIf
                           nJuros := 0
			Endif

			IF dDataBase > SE1->E1_VENCREA
				 nAtraso:=dDataBase-SE1->E1_VENCTO
				 IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
					  IF Dow(dBaixa) == 2 .and. nAtraso <= 2
							nAtraso := 0
					  EndIF
				 EndIF
				 nAtraso:=IIF(nAtraso<0,0,nAtraso)
				 IF nAtraso>0
					If mv_par19 == 1
						  @li ,184 PSAY nAtraso Picture "9999"
					EndIf
				 EndIF
			EndIF
			If mv_par19 == 1
				 @li,190 PSAY SubStr(SE1->E1_HIST,1,25)+IIF(SubStr(E1_TIPO,1,2)=="PR","*"," ")+Iif(Empty(E1_BAIXA)," ","P")
			EndIf

			IF nOrdem == 1 .or. nOrdem == 7
				 dbSelectArea("cNomeArq")
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega data do registro para permitir ³
			//³ posterior an lise de quebra por mes.	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dDataAnt := Iif(nOrdem == 6, SE1->E1_EMISSAO, SE1->E1_VENCREA)
			dbSkip()
            nTotTit := nTotTit + 1
            nMesTTit := nMesTTit + 1
            nTit5  := nTit5 + 1
			If mv_par19 == 1
                li := li + 1
			EndIf
	  End

	  IF nTit5 > 0 .and. nOrdem != 2
            SubTot130()
			If mv_par19 == 1
                Li := Li + 1
			EndIf
	  End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica quebra por mˆs					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuebra := .F.
		If nOrdem == 4 .and. Month(SE1->E1_VENCREA) #Month(dDataAnt)
			lQuebra := .T.
		Elseif nOrdem == 6 .and. Month(SE1->E1_EMISSAO) #Month(dDataAnt)
			lQuebra := .T.
		Endif
		If lQuebra .and. nMesTTit #0
            nMesTot1   := nMesTit1
            nMesTot2   := nMesTit2
            nMesTot3   := nMesTit3
            nMesTot4   := nMesTit4
            nMesTotTit := nMesTTit
            nMesTotJ   := nMesTitJ
            ImpMes130()
			nMesTit1 := nMesTit2 := nMesTit3 := nMesTit4 := nMesTTit := nMesTitj := 0
		Endif

      nTot1 := nTot1 + nTit1
      nTot2 := nTot2 + nTit2
      nTot3 := nTot3 + nTit3
      nTot4 := nTot4 + nTit4
      nTotJ := nTotJ + nTotJur
	  Store 0 To nTit1,nTit2,nTit3,nTit4,nTit5,nTotJur,nTotAbat

 End

 IF li != 80
	  IF li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))
	  EndIF
      TotGer130()
	  roda(cbcont,cbtxt,"G")
 EndIF
 IF nOrdem == 1 .or. nOrdem == 7
	 dbSelectArea("cNomeArq")
	 dbCloseArea()
	 Ferase(cNomeArq+".DBF")    // Elimina arquivos de Trabalho
	 Ferase(cNomeArq+OrdBagExt()) 	// Elimina arquivos de Trabalho
 End

 Set Device To Screen
 dbSelectArea("SE1")
 Set Filter To
 dbSetOrder(1)

 If aReturn[5] == 1
	  Set Printer TO
	  dbCommitAll()
	  ourspool(wnrel)
 Endif
 MS_FLUSH()
 Return

 /*/
 ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
 ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
 ±±³Fun‡„o	  ³SubTot130 ³ Autor ³ Paulo Boschetti 		³ Data ³ 01.06.92 ³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Descri‡„o ³Imprimir SubTotal do Relatorio										³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Sintaxe e ³ SubTot130()																³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Parametros³																				³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³ Uso 	  ³ Generico																	³±±
 ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
 ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 /*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>  Function SubTot130
Static Function SubTot130()
 aSituaca := {"Carteira","Simples","Descontada","Caucionada",;
              "Vinculada","Advogado","Judicial","Cauc Desc"}
If mv_par19 == 1
     li := li + 1
EndIf
 If nOrdem == 1
	  @li,000 PSAY SA1->A1_NOME+" "+AllTrim(SA1->A1_TEL)
 Elseif nOrdem == 2 .or. nOrdem == 4 .or. nOrdem == 6
	  @li,000 PSAY "S U B - T O T A L ----> "
	  @li,030 PSAY cCarAnt
 Elseif nOrdem == 3
	  @li,000 PSAY "S U B - T O T A L ----> "
	  @li,030 PSAY SA6->A6_NREDUZ
 ElseIf nOrdem == 5
	  dbSelectArea("SED")
      dbSeek(xFilial()+cCarAnt)
	  @li,000 PSAY "S U B - T O T A L ----> "
	  @li,030 PSAY cCarAnt + " "+ED_DESCRIC
	  dbSelectArea("SE1")
Elseif nOrdem == 7
	  @li,000 PSAY "S U B - T O T A L ----> "
	  @li,030 PSAY SubStr(cCarAnt,7,2)+"/"+SubStr(cCarAnt,5,2)+"/"+SubStr(cCarAnt,3,2)+" - "+SubStr(cCarAnt,9,3)
ElseIf nOrdem == 8
	  @li,000 PSAY SA1->A1_COD+" "+SA1->A1_NOME+" "+AllTrim(SA1->A1_TEL)
ElseIf nOrdem == 9
	  @li,000 PSAY SubStr(cCarant,1,3)+" "+SA6->A6_NREDUZ + SubStr(cCarant,4,1) + " "+aSituaca[Val(SubStr(cCarant,4,1))+1]
End
 @li,092 PSAY nTit1		  Picture TM(nTit1,16)
 @li,108 PSAY nTit2		  Picture TM(nTit2,16)
 @li,126 PSAY nTit3		  Picture TM(nTit3,16)
 If nTotJur > 0
	  @li,164 PSAY nTotJur		Picture TM(nTotJur,16)
 Endif
 @li,204 PSAY nTit2+nTit3 Picture TM(nTit2+nTit3,16)
 li := li + 1
 Return

 /*/
 ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
 ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
 ±±³Fun‡„o	  ³ TotGer130³ Autor ³ Paulo Boschetti 		³ Data ³ 01.06.92 ³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Descri‡„o ³ Imprimir total do relatorio											³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Sintaxe e ³ TotGer130()																³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³Parametros³																				³±±
 ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
 ±±³ Uso 	  ³ Generico																	³±±
 ±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
 ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
 /*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>  Function TotGer130
Static Function TotGer130()

 li := li + 1
 @li,000 PSAY "T O T A L   G E R A L ----> "
 @li,030 PSAY "("+ALLTRIM(STR(nTotTit))+" "+IIF(nTotTit > 1,"TITULOS","TITULO")+")"
 @li,092 PSAY nTot1		  Picture TM(nTot1,16)
 @li,108 PSAY nTot2		  Picture TM(nTot2,16)
 @li,126 PSAY nTot3		  Picture TM(nTot3,16)
 @li,164 PSAY nTotJ		  Picture TM(nTotJ,16)
 @li,204 PSAY nTot2+nTot3 Picture TM(nTot2+nTot3,16)
 li := li + 2
 Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ImpMes130 ³ Autor ³ Vinicius Barreira	  ³ Data ³ 12.12.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³IMPRIMIR TOTAL DO RELATORIO - QUEBRA POR MES					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ ImpMes130() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpMes130
Static Function ImpMes130()
li := li + 1
@li,000 PSAY "T O T A L   D O  M E S ---> "
@li,030 PSAY "("+ALLTRIM(STR(nMesTTit))+" "+IIF(nMesTTit > 1,"TITULOS","TITULO")+")"
@li,092 PSAY nMesTot1	Picture TM(nMesTot1,16)
@li,108 PSAY nMesTot2	Picture TM(nMesTot2,16)
@li,126 PSAY nMesTot3	Picture TM(nMesTot3,16)
@li,164 PSAY nMesTotJ	Picture TM(nMesTotJ,16)
@li,204 PSAY nMesTot2+nMesTot3 Picture TM(nMesTot2+nMesTot3,16)
li := li + 2
Return

// Compatibiliza o SX1

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION AjustaSx1
Static FUNCTION AjustaSx1()
cAlias := Alias()
aPerg  := {}
cPerg  := "FIN130"

Aadd(aPerg,{"Considera Data Base ? ","N",1})

dbSelectArea("SX1")
If !dbSeek(cPerg+"20")
	RecLock("SX1",.T.)
    SX1->X1_GRUPO    := cPerg
    SX1->X1_ORDEM    := "20"
    SX1->X1_PERGUNT  := aPerg[1][1]
    SX1->X1_VARIAVL  := "mv_chj"
    SX1->X1_TIPO     := aPerg[1][2]
    SX1->X1_TAMANHO  := aPerg[1][3]
    SX1->X1_PRESEL   := 1
    SX1->X1_GSC      := "C"
    SX1->X1_VAR01    := "mv_par20"
    SX1->X1_DEF01    := "Sim"
    SX1->X1_DEF02    := "N„o"
EndIf
dbSelectArea(cAlias)
Return
