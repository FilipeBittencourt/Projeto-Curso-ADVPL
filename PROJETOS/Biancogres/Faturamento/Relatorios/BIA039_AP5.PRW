#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia039()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1,CABEC2")
SetPrvt("CCANCEL,M_PAG,WNREL,LRODAPE,WCONTA,LCONTINUA")
SetPrvt("NQTDNF,WTVLRNF,WTQTDNF,CBTXT,CBCONT,LI")
SetPrvt("LIMITE,NTIPO,LEND,WCLIENTE,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA039   ³ Autor ³ Gustav Koblinger Jr   ³ Data ³ 06/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio das Notas Fiscais Emitidas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Faturamento                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  cString  := "SF2"
  cDesc1   := "Este programa ira emitir um Relatorio das Notas Fiscais Emitidas "
  cDesc2   := ""
  cDesc3   := ""
  tamanho  := "M"
  aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
  nomeprog := "BIA039"
  aLinha   := { }
  nLastKey := 0
  titulo   := "Relatorio das Notas Fiscais Emitidas"
  cabec1   := "Nota Fiscal    Tipo    Emissao     Cliente                                     Valor Total NF    Qtde Total NF"
  cabec2   := ""
  //
  //Nota Fiscal    Tipo    Emissao     Cliente                                     Valor Total NF    Qtde Total NF
  //123456/123      1      12/12/12    123456/12-123456789012345678901234567890        1234567890       1234567890
  //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
  //          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
  //
  cCancel  := "***** CANCELADO PELO OPERADOR *****"
  m_pag    := 1                                    // numero da pagina
  wnrel    := "BIA039"                             // relatorio em disco
  lRodape  := .F.
  wConta   := 0
  lContinua:= .T.
  nQtdNF   := wTVlrNF := wTQtdNF := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  cbtxt    := SPACE(10)
  cbcont   := 0
  li       := 80
  limite   := 132
  m_pag    := 1
  nTipo    := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  SetPrint(cString,wnrel,"BIA039",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
  If  nLastKey == 27
      Set Filter To
      Return
  End
  SetDefault(aReturn,cString)
  If  nLastKey == 27
      Set Filter To
      Return
  End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  pergunte("BIA039",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                     ³
//³ mv_par01              Data De                                            ³
//³ mv_par02              Data Ate                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Arquivo                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  RptStatus({|| ImpDados() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>   RptStatus({|| Execute(ImpDados) })

  IF  lRodape
      If li + 6 > 55
         cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
      Endif

      While li <= 49 ; li := li + 1 ; End

      @ li,00 PSay "OBS: Esta relacao reflete todas as Notas Fiscais emitidas no Periodo de: "+dtoc(mv_par01)+" a "+dtoc(mv_par02)+". A qual a segunda via segue anexo"
      li := li + 4
      @li,00 PSay "_____________________                                                                                 ________________________"
      li := li + 1
      @li,00 PSay "Encarregado expedicao                                                                                 Encarregado Setor Fiscal"

      roda(cbcont,cbtxt,"M")
  Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//  dbSelectArea("SF2")
  Set Filter To
  dbSetOrder(1)
  Set Device To Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera spool de impressao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//  Set Filter to

  If  aReturn[5] == 1
      Set Printer To
      Commit
      ourspool(wnrel)    // Chamada do Spool de Impressao
  EndIf

  MS_FLUSH()             // Libera fila de relatorios em spool

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³ ImpDados   ³ Imprime o relatorio                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpDados
Static Function ImpDados()
dbSelectArea("SF2")
dbSetOrder(10) 
//dbSetOrder(11)
dbSeek(xFilial("SF2")+dtos(mv_par01),.T. )

SetRegua(RecCount())            // Total de Elementos da regua

While !Eof()       .And.    lContinua      .And. ;
   DtoS(SF2->F2_EMISSAO) <= DtoS(mv_par02) .And. ;
   xFilial()             == SF2->F2_FILIAL

   IncRegua()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   // Se nao esta dentro das datas limite ele salta.
   //³ Verifica se ha interrupcao                                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   #IFNDEF WINDOWS
      If  LastKey() == 286    //ALT_A
          lEnd := .t.
      End
   #ENDIF

   IF  lEnd
       @PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
       lContinua := .F.
       Return
   Endif

   IF  li > 55
       cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
       lRodape   := .T.
   Endif

   nQtdNF := 0

   dbSelectArea("SD2")
   dbSetOrder(3)
   dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
   While ! Eof()                         .And. ;
      SF2->F2_DOC     == SD2->D2_DOC     .And. ;
      SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
      SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
      SF2->F2_LOJA    == SD2->D2_LOJA
  
      If SF2->F2_TIPO <> "N"
         DbSkip()
         Loop
      EndIf

      If SD2->D2_CF == "599" .OR.;
         SD2->D2_CF == "699"
         DbSkip()
         Loop
      EndIf

      dbSelectArea("SF4")
      dbSetOrder(1)
      dbSeek(xFilial("SF4")+SD2->D2_TES,.T.)

      If SF4->F4_DUPLIC  <> "S"  .AND.;
         SF4->F4_ESTOQUE <> "S"
         DbSelectArea("SD2")
         dbSetOrder(3)
         DbSkip()
         Loop
      EndIf

      If SF2->F2_TIPO == "N"
         nQtdNF       := nQtdNF + SD2->D2_QUANT
      Else
         nQtdNF       := nQtdNF - SD2->D2_QUANT
      EndIF

      dbSelectArea("SD2")
      dbSetOrder(3)
      dbSkip()
   End

   wTQtdNF  := wTQtdNF + nQtdNF

   If Alltrim(SF2->F2_TIPO) $ "N_C_I_P"
      dbSelectArea("SA1")
      dbSetOrder(1)
      dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
      wCliente := Subs(SA1->A1_NOME,1,30)
      wTVlrNF  := wTVlrNF + SF2->F2_VALMERC
   Else
      dbSelectArea("SA2")
      dbSetOrder(1)
      dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
      wCliente := Subs(SA2->A2_NOME,1,30)
      wTVlrNF  := wTVlrNF - SF2->F2_VALMERC
   EndIf

   @li,000 PSAY SF2->F2_DOC+"/"+SF2->F2_SERIE
   @li,016 PSAY SF2->F2_TIPO
   @li,023 PSAY SF2->F2_EMISSAO
   @li,035 PSAY SF2->F2_CLIENTE+"/"+SF2->F2_LOJA+"-"+wCliente

   If SF2->F2_TIPO=="N"
      @li,081 PSAY SF2->F2_VALMERC       Picture PESQPICTQT("D2_QUANT",12)
   Else
      @li,081 PSAY -1*SF2->F2_VALMERC    Picture PESQPICTQT("D2_QUANT",12)
   EndIf

   @li,096 PSAY nQtdNF                   Picture PESQPICTQT("D2_TOTAL",14)

   li := li + 1
   dbSelectArea("SF2")
   dbSetOrder(6)
   dbSkip()
EndDo

li     := li + 1
@ li,000 PSAY Replicate("-",limite)
li     := li + 1
@li,081 PSAY wTVlrNF Picture PESQPICTQT("D2_QUANT",12)
@li,096 PSAY wTQtdNF Picture PESQPICTQT("D2_TOTAL",14)
li     := li + 1
@ li,000 PSAY Replicate("-",limite)
li     := li + 1

Return
