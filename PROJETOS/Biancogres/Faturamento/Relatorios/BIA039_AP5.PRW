#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia039()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO,ARETURN")
SetPrvt("NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1,CABEC2")
SetPrvt("CCANCEL,M_PAG,WNREL,LRODAPE,WCONTA,LCONTINUA")
SetPrvt("NQTDNF,WTVLRNF,WTQTDNF,CBTXT,CBCONT,LI")
SetPrvt("LIMITE,NTIPO,LEND,WCLIENTE,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � BIA039   � Autor � Gustav Koblinger Jr   � Data � 06/08/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Relatorio das Notas Fiscais Emitidas                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Faturamento                                                낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
  pergunte("BIA039",.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                                     �
//� mv_par01              Data De                                            �
//� mv_par02              Data Ate                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime Arquivo                                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura a Integridade dos dados                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//  dbSelectArea("SF2")
  Set Filter To
  dbSetOrder(1)
  Set Device To Screen

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera spool de impressao                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//  Set Filter to

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
dbSelectArea("SF2")
dbSetOrder(10) 
//dbSetOrder(11)
dbSeek(xFilial("SF2")+dtos(mv_par01),.T. )

SetRegua(RecCount())            // Total de Elementos da regua

While !Eof()       .And.    lContinua      .And. ;
   DtoS(SF2->F2_EMISSAO) <= DtoS(mv_par02) .And. ;
   xFilial()             == SF2->F2_FILIAL

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
