#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia040()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1,CABEC2")
SetPrvt("LRODAPE,CCANCEL,M_PAG,WNREL,WCONTA,LCONTINUA")
SetPrvt("LFIRST,NQTDLIB,NQTDORIG,NQTDDIS,NQTDFAT,CBTXT")
SetPrvt("CBCONT,LI,LIMITE,NTIPO,WROMANEIO,LEND")
SetPrvt("WQTDFAT,WDTNF,NTOTQTD,WQTDDISP,WTOTPROD,WTOT2UM")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � BIA040   � Autor � Gustav Koblinger Jr   � Data � 06/08/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Relatorio do Romaneio Gerado/Discrepancias                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Contabilidade                                              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
  cString  := "SZ9"
  cDesc1   := "Este programa ira emitir um Relatorio do Romaneio "
  cDesc2   := "Gerado / Discrepancias."
  cDesc3   := ""
  tamanho  := "M"
  aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
  nomeprog := "BIA040"
  aLinha   := { }
  nLastKey := 0
  titulo   := "Relatorio do Romaneio Gerado / Discrepancias"
  cabec1   := "Item  Produto     Descricao                       Pedido     UM   Qtd Liber    Qtd Orig  Discrepancia     Qtd Fat  NF/DOC  Data NF"
  cabec2   := ""
//Romaneio: 1234567890
//Cliente : 123456-1234567890123456789012345678901234567890
//Emissao : 12/12/12
//
//Item  Produto     Descricao                       Pedido     UM   Qtd Liber    Qtd Orig  Discrepancia     Qtd Fat  N.F.    Data NF
// 12   1234567890  123456789012345678901234567890  123456/12  12  1234567890  1234567890    1234567890  1234567890  123456  12/45/78
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
//
  lRodape  := .T.
  cCancel  := "***** CANCELADO PELO OPERADOR *****"
  m_pag    := 1                                    // numero da pagina
  wnrel    := "BIA040"                             // relatorio em disco
  wConta   := 0
  lContinua:= .T.
  lFirst   := .T.
  nQtdLib  := nQtdOrig := nQtdDis := nQtdFat := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
  cbtxt    := SPACE(10)
  cbcont   := 0
  li       := 80
  limite   := 132
  m_pag    := 1
  nTipo    := IIF(aReturn[4]==1,15,18)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Exibe janela padrao de relatorios                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
  SetPrint(cString,wnrel,"BIA040",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
  If  nLastKey == 27
      Set Filter To
      Return
  End
  SetDefault(aReturn,cString)
  If  nLastKey == 27
      Set Filter To
      Return
  End

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte("BIA040",.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                                     �
//� mv_par01              Do Romaneio                                        �
//� mv_par02              Ate o Romaneio                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime Arquivo                                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RptStatus({|| ImpDados() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> RptStatus({|| Execute(ImpDados) })

IF  lRodape
    roda(cbcont,cbtxt,"M")
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura a Integridade dos dados                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SZ9")
Set Filter To
dbSetOrder(1)
Set Device To Screen

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera spool de impressao                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Set Filter to

If  aReturn[5] == 1
    Set Printer To
    Commit
    ourspool(wnrel)    // Chamada do Spool de Impressao
EndIf

MS_FLUSH()             // Libera fila de relatorios em spool

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim do Programa                                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽굇
굇� ImpDados   � Imprime o relatorio                                      낢굇
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpDados
Static Function ImpDados()
dbSelectArea("SZ9")
dbSetOrder(1)
dbSeek( xFilial("SZ9")+mv_par01,.T. )

wRomaneio := SZ9->Z9_NUMERO
SetRegua(RecCount())            // Total de Elementos da regua

While !Eof()                       .And. ;
   lContinua                       .And. ;
   SZ9->Z9_NUMERO <= mv_par02      .And. ;
   xFilial()      == SZ9->Z9_FILIAL

   IncRegua()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�   // Se nao esta dentro das datas limite ele salta.
   //� Verifica se ha interrupcao                                            �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   #IFNDEF WINDOWS
      If  LastKey() == 286    //ALT_A
          lEnd := .t.
      End
   #ENDIF

   IF  lEnd
       @PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
       lContinua := .F.
       Exit
   Endif

   If wRomaneio <> SZ9->Z9_NUMERO
      li     := li + 1
      @ li,000 PSAY Replicate("-",limite)
      li     := li + 1
      @ li,000 PSAY " T O T A I S "
      @li,065 PSAY nQtdLib          Picture PESQPICTQT("Z9_QTDLIB",10)
      @li,077 PSAY nQtdOrig         Picture PESQPICTQT("Z9_QTDLIB",10)
      @li,091 PSAY nQtdDis          Picture PESQPICTQT("Z9_QTDLIB",10)
      @li,103 PSAY nQtdFat          Picture PESQPICTQT("Z9_QTDLIB",10)
      li     := li + 1
      @ li,000 PSAY Replicate("-",limite)
      li     := li + 1
      li     := 80
      lFirst := .T.
      nQtdLib  := nQtdOrig := nQtdDis := nQtdFat := 0
   EndIf

   IF  li > 55 .or. lFirst
       cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
       wRomaneio := SZ9->Z9_NUMERO
       lRodape   := .T.
   Endif

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Ler SC9                                                               �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   wQtdFat := 0
   wDtNF   := ctod("  /  /  ")

   dbSelectArea("SC9")
   dbSetOrder(1)
   If  dbSeek(xFilial("SC9")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM)
       While ! Eof()                       .And. ;
          xFilial("SC9") == SZ9->Z9_FILIAL .And. ;
          SC9->C9_PEDIDO == SZ9->Z9_PEDIDO .And. ;
          SC9->C9_ITEM   == SZ9->Z9_ITEM
          //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
          //� Acessa o Pedido                                                �
          //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
          dbSelectArea("SC5")
          dbSetOrder(1)
          dbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO)

          dbSelectArea("SC6")
          dbSetOrder(1)
          dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

          dbSelectArea("SF2")
          dbSetOrder(1)
          dbSeek(xFilial("SF2")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA)

          dbSelectArea("SD2")
          dbSetOrder(3)
          If dbSeek(xFilial("SD2")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_PRODUTO)
             wDtNF := SD2->D2_EMISSAO
             Do While ! Eof()                      .And.;
                SC9->C9_NFISCAL == SD2->D2_DOC     .And.;
                SC9->C9_SERIENF == SD2->D2_SERIE   .And.;
                SC9->C9_CLIENTE == SD2->D2_CLIENTE .And.;
                SC9->C9_LOJA    == SD2->D2_LOJA    .And.;
                SC9->C9_PRODUTO == SD2->D2_COD
                wQtdFat := wQtdFat + SD2->D2_QUANT
                dbSelectArea("SD2")
                dbSetOrder(3)
                dbSkip()
             EndDo
          EndIf
          //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
          //� Impressao do Cabecalho do Pedido                           �
          //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
          IF  li > 55
              cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
              lFirst := .t.
          Endif

          If  lFirst
              lFirst  := .F.
              nTotQtd := 0
             
              dbSelectArea("SA4")
              dbSeek(xFilial()+SC5->C5_TRANSP)
               
              dbSelectArea("SA1")
              dbSeek(xFilial()+SC9->C9_CLIENTE+SC9->C9_LOJA)
                
              @ li,000 PSAY "ROMANEIO : "+SZ9->Z9_NUMERO
              @ li,030 PSAY "EMISSAO : "+DTOC(SZ9->Z9_EMISSAO)
              li := li +1
              @ li,000 PSAY "CLIENTE : "+SC9->C9_CLIENTE+"/"+SC9->C9_LOJA+"-"+SA1->A1_NOME+" MUNICIPIO : "+SA1->A1_MUN+" UF : "+SA1->A1_EST
              li := li +1
              @ li,000 PSAY "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+SA4->A4_NREDUZ+"  "+"VIA : "+SA4->A4_VIA+" PLACA : " + SF2->F2_YPLACA +"    MOTORISTA : " + " SF2->F2_YMOTOR ? "
              li := li + 1
              @ li,000 PSAY Replicate("-",limite)
          Endif
          //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
          //� Imprime detalhes do Romaneio                                   �
          //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
          li := li + 1
          ImpItem()

          //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
          //� Proximo registro SC9                                           �
          //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
          dbSelectArea("SC9")
          dbSetOrder(1)
          dbSkip()
       EndDo
   Else
       //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
       //� Impressao do Cabecalho do Pedido                           �
       //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
       IF  li > 55
           cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
           lFirst := .t.
       Endif
       If  lFirst
           lFirst  := .F.
           nTotQtd := 0
             
           @ li,000 PSAY "ROMANEIO : "+SZ9->Z9_NUMERO
           @ li,030 PSAY "EMISSAO : "+DTOC(SZ9->Z9_EMISSAO)
           li := li +1
           @ li,000 PSAY "CLIENTE : "+SC9->C9_CLIENTE+"/"+SC9->C9_LOJA+"-"+SA1->A1_NOME+" MUNICIPIO : "+SA1->A1_MUN+" UF : "+SA1->A1_EST
           li := li +1
           @ li,000 PSAY "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+SA4->A4_NREDUZ+"  "+"VIA : "+SA4->A4_VIA+" PLACA : ________________"+"    MOTORISTA : ____________________"
           li := li + 1
           @ li,000 PSAY Replicate("-",limite)
       Endif
       li := li + 1
       RotMov()
   EndIf
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� Proximo registro SZ9                                                  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   dbSelectArea("SZ9")
   dbSetOrder(1)
   dbSkip()
EndDo
li     := li + 1
@ li,000 PSAY Replicate("-",limite)
li     := li + 1
@li,065 PSAY nQtdLib          Picture PESQPICTQT("Z9_QTDLIB",10)
@li,077 PSAY nQtdOrig         Picture PESQPICTQT("Z9_QTDLIB",10)
@li,091 PSAY nQtdDis          Picture PESQPICTQT("Z9_QTDLIB",10)
@li,103 PSAY nQtdFat          Picture PESQPICTQT("Z9_QTDLIB",10)
li     := li + 1
@ li,000 PSAY Replicate("-",limite)
li     := li + 1


Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � ImpItem  � Autor � Gilson do Nascimento  � Data � 05.10.93 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Impressao de Itens do Romaneio  de Despacho                낢�
굇�          � Ordem de Impressao : LOCALIZACAO NO ALMOXARIFADO           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ImpItem(void)                                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � BIA040                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpItem
Static Function ImpItem()

dbSelectArea("SB1")
dbSeek(xFilial()+SC6->C6_PRODUTO)
//nQtdLib  := nQtdOrig := nQtdDis := nQtdFat := 0
wQtdDisp := SZ9->Z9_QTDORI - SZ9->Z9_QTDLIB
@li,001 PSAY SZ9->Z9_ITEM
@li,006 PSAY SUBS(SC9->C9_PRODUTO,1,8)
@li,018 PSAY SUBS(SB1->B1_DESC,1,30)
@li,050 PSAY SZ9->Z9_PEDIDO+"/"+SZ9->Z9_ITEM
@li,061 PSAY SC6->C6_UM
@li,065 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("C9_QTDLIB",10)
@li,077 PSAY SZ9->Z9_QTDORI Picture PESQPICTQT("C9_QTDLIB",10)
@li,091 PSAY wQtdDisp       Picture PESQPICTQT("C9_QTDLIB",10)
@li,103 PSAY wQtdFat        Picture PESQPICTQT("C9_QTDLIB",10)
@li,115 PSAY SD2->D2_DOC
@li,123 PSAY If(!empty(wDtNF),DtoC(wDtNF)," ")

li := li + 1

nQtdLib := nQtdLib  + SZ9->Z9_QTDLIB
nQtdOrig:= nQtdOrig + SZ9->Z9_QTDORI
nQtdDis := nQtdDis  + wQtdDisp
nQtdFat := nQtdFat  + wQtdFat

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � RotMov   � Autor � Gustav Koblinger Jr   � Data � 05.08.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Movimentacao                                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � RotMov                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � BIA040                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function RotMov
Static Function RotMov()

dbSelectArea("SD3")
dbSetOrder(4)
dbSeek(xFilial()+SZ9->Z9_NUMSEQ)

dbSelectArea("SB1")
dbSeek(xFilial()+SD3->D3_COD)

wTotProd := 0
wTot2UM  := 0
wQtdDisp := SZ9->Z9_QTDORI - SZ9->Z9_QTDLIB

@li,001 PSAY SZ9->Z9_ITEM
@li,006 PSAY SUBS(SD3->D3_COD,1,8)
@li,018 PSAY SUBS(SB1->B1_DESC,1,30)
@li,050 PSAY " "
@li,061 PSAY SC6->C6_UM
@li,065 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("C9_QTDLIB",10)
@li,077 PSAY SZ9->Z9_QTDORI Picture PESQPICTQT("C9_QTDLIB",10)
@li,091 PSAY wQtdDisp       Picture PESQPICTQT("C9_QTDLIB",10)
@li,103 PSAY wQtdFat        Picture PESQPICTQT("C9_QTDLIB",10)
@li,115 PSAY SD3->D3_DOC
@li,123 PSAY If(!empty(wDtNF),DtoC(wDtNF)," ")
li := li + 1

nQtdLib := nQtdLib  + SZ9->Z9_QTDLIB
nQtdOrig:= nQtdOrig + SZ9->Z9_QTDORI
nQtdDis := nQtdDis  + wQtdDisp
nQtdFat := nQtdFat  + wQtdFat

Return
