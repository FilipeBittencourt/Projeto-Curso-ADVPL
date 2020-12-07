#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Uzg008()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CSTRING,LEND,NLASTKEY,CDESC1,CDESC2,CDESC3")
SetPrvt("TAMANHO,ARETURN,NOMEPROG,NOMEREL,TITULO,CABEC1")
SetPrvt("CABEC2,M_PAG,LI,CBTXT,CBCONT,BDTDEATE")
SetPrvt("BFODEATE,WDATADE,WDATAATE,WFORNDE,WFORNATE,BDRIVE")
SetPrvt("ACAMPOS,cTrb,WOLDFORN,WIMPLINHA,WQTDENT,WTFORNEC")
SetPrvt("WMEDATSO,WPRZMEDFRE,BFORNECE,BRECUSADO,WNOTAMES,WENTTOTAL")
SetPrvt("WENTNOPRZ,WNOTAQ,WFATOR,APERFILQ,APERFILP,WDIAATS")
SetPrvt("NDA_X_QEA,WENTATS,WNOTAP,WPOS,CINDSF1,CCHAVE")
SetPrvt("CFILTRO,CINDUZG,WOLDNOTA,WDIASATS,WDIASFRE,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ UZG008   ³ Autor ³ AUGUSTO C. DE OLIVEIRA ³ Data ³ 14/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Entrega de Materiais no Periodo (A)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST e SIGACOM                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ INICIALIZA VARIAVEIS DE TRABALHO³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cString  := "SF1"
   lEnd     := .F.
   nLastKey := 0
   cDesc1   := "Este programa tem como objetivo imprimir o Relatorio de Entrega"
   cDesc2   := "de Materiais conforme parametros informados."
   cDesc3   := ""
   Tamanho  := "M"
   aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 2,"",0 }
   NomeProg := NomeRel := "UZG008"
   nLastKey := 0
   Titulo   := "Pontualidade na Entrega de Materiais"
   cabec1   := "|FORNECEDOR                                 |PEDIDO|NOTA  |TOTAL DA NOTA|DATA DO |ENTREGA |EMISSAO |ENTRADA | ATRASO | PRZ FRETE |"
   cabec2   := "|CODIGO|NOME                                |COMPRA|FISCAL|FISCAL  (R$) |PEDIDO  |PREV.(A)|NF (B)  |NF (C)  |  (C-A) |   (C-B)   |"
   m_pag    := 1                                    // numero da pagina
   li       := 80
   cbtxt    := SPACE(10)
   cbcont   := 0
   bDtDeAte := {|pData |wDataDe <= pData  .AND. wDataAte >= pData}
   bFoDeAte := {|pForne|wFornDe <= pForne .AND. wFornAte >= pForne}
   NomeRel  := SetPrint(cString,NomeRel,NomeProg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
   
   SetDefault(aReturn,cString)
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ ATUALIZA PARAMETROS ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PERGUNTE("UZG008",.F.)

   If ( nLastKey == 27 ) .OR. ( LastKey() == 27 ) .OR. lEnd
      Return
   Endif

  
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿³
   //³³ INICIALIZA VARIAVEIS DE PARAMETROS        ³³
   //³ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ MV_PAR01 - Data DE            ?             ³
   //³ MV_PAR02 - Data Ate           ?             ³
   //³ MV_PAR03 - Fornecedor DE      ?             ³
   //³ MV_PAR04 - Fornecedor ATE     ?             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   
   wDataDe := MV_PAR01
   wDataAte:= MV_PAR02
   wFornDe := MV_PAR03
   wFornAte:= MV_PAR04
   bDrive  := {||IIF(RDDNAME()$"DBFCDX,DBFCDXAX",RDDNAME(),"DBFNTX")}

   fCriaArq()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SELECIONA ARQUIVOS E INDICE DE TRABALHO ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DBSELECTAREA("SF1")
   DBSETORDER(1)

   DBSELECTAREA("SD1")
   DBSETORDER(3)
   
   DBSELECTAREA("SA2")
   DBSETORDER(1)
   
   DBSELECTAREA("SC7")
   DBSETORDER(3)
   
   DBSELECTAREA("UZG")
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ GERA DADOS P/ IMPRIMIR       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Processa({|| fGeraDado() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    Processa({|| Execute(fGeraDado) })
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ IMPRIME ENTREGAS/OCORRENCIAS ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   RptStatus({|| fImprime() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    RptStatus({|| Execute(fImprime) })
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ IMPRIME RODAPE           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Roda(cbcont,cbtxt,"M")
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ APAGA INDICE TEMPORARIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("UZG")
   RetIndex("UZG")
   
   IF File(cIndUZG+".CDX")
      Ferase(cIndUZG+".CDX")
   ENDIF
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ APAGA INDICE TEMPORARIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("SF1")
   RetIndex("SF1")
   
   IF File(cIndSF1+".CDX")
      Ferase(cIndSF1+".CDX")
   ENDIF

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ APAGA INDICE TEMPORARIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("cTrb")
   DBCLOSEAREA()
   
   Ferase(cTrb+".DBF")
   Ferase(cTrb+".CDX")

   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ LIBERA PARA SPOOL        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   IF aReturn[5] == 1
      Set Printer To
      Commit
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ CHAMADA DO SPOOL DE IMPRESSAO     ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      ourspool(NomeRel)
   ENDIF
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ LIBERA FILA DE RELATORIOS EM SPOOL³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MS_FLUSH()
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ FIM DO PROGRAMA³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fCriaArq   ³ Cria arquivo temporario                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()

   aCampos := {}

   AADD( aCampos, {"COD"    ,"C", 6,0 } )
   AADD( aCampos, {"NOME"   ,"C",40,0 } )
   AADD( aCampos, {"LOJA"   ,"C", 2,0 } )
   AADD( aCampos, {"PEDIDO" ,"C", 6,0 } )
   AADD( aCampos, {"NFISCAL","C", 6,0 } )
   AADD( aCampos, {"VALBRUT","N",14,2 } )
   AADD( aCampos, {"EMISSNF","D", 8,0 } )
   AADD( aCampos, {"EMISSPE","D", 8,0 } )
   AADD( aCampos, {"DATPRF" ,"D", 8,0 } )
   AADD( aCampos, {"DTDIGIT","D", 8,0 } )
   AADD( aCampos, {"DIASATS","N", 6,0 } )
   AADD( aCampos, {"DIASFRE","N", 6,0 } )
   AADD( aCampos, {"OCORRE" ,"C",80,0 } )
   AADD( aCampos, {"QTDENT" ,"N",11,3 } )

   cTrb := CRIATRAB(aCampos,.T.)
   DbUseArea(.T.,,cTrb,"cTrb")
   INDEX ON COD+LOJA+PEDIDO+NFISCAL TO &cTrb

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImprime   ³ Relatorio de Entrega de Materiais no Periodo             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

   DBSELECTAREA("cTrb")
   DBGOTOP()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SETA REGUA DE CONTAGEM   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SetRegua(cTrb->(LASTREC()))

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ INICIALIZA VARIAVEIS PARA USO DESTA FUNCAO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   wOldForn := ""
   wImpLinha:= ""
   wQtdEnt  := wTFornec := wMedAtso := wPrzMedFre := 0
   bFornece := {||cTrb->COD+cTrb->LOJA}
   bRecusado:= {||LEFT(cTrb->NFISCAL,1) == "D"} //ENTREGA APONTADA SEM NF, POIS FOI RECUSADO ANTES DE DESCARREGAR
   wNotaMes := wEntTotal := wEntNoPrz := wQtdEnt := wTFornec := wMedAtso := wPrzMedFre := 0
   wNotaQ   := GETMV("MV_YNOTAQ") // NOTA MAXIMA QUE O FORNECEDOR PODERA RECEBER
   wFator   := GETMV("MV_YFATOR") // FATOR PARA USO NO CALCULO DA PONTUALIDADE
   aPerfilQ := {} //QUALIDADE    | PERFIL TRACADO PELO FORNECEDOR
   aPerfilP := {} //PONTUALIDADE | DURANTE O PERIODO

   WHILE !cTrb->(EOF())
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³INCREMENTA REGUA        ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IncRegua()
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³CABECALHO DA PAGINA     ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF li > 60
         li := Cabec(Titulo,Cabec1,Cabec2,NomeRel,Tamanho,15) + 1
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³VERIFICA SE MUDOU FORNECEDOR    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      wDiaAts := cTrb->DTDIGIT-cTrb->DATPRF
      wDiaAts := IIF(wDiaAts >0,wDiaAts,0)

      IF wOldForn #EVAL(bFornece)
         IF !EMPTY(wOldForn)
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³CALCULA NOTA/CONCEITO DO FORNECEDOR³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            //fCalcNota()
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³IMPRIME TOTAL DO FORNECEDOR ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            fImpTotal()
            wEntTotal := wEntNoPrz := wQtdEnt := wTFornec := wMedAtso := wPrzMedFre := 0
         ENDIF
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³POSICIONA FORNECEDOR    ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         IF ! SA2->(DBSEEK(xFILIAL("SA2")+cTrb->COD+cTrb->LOJA,.F.))
            DBSKIP()
            LOOP
         ENDIF
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³Imprime dados do fornecedor     ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         fImpForn()
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ATUALIZA VARIAVEIS DE CONTROLE E ACUMULA VALORES ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      wOldForn   := EVAL(bFornece)
      wQtdEnt    := wQtdEnt    + 1
      wTFornec   := wTFornec   + cTrb->VALBRUT
      wMedAtso   := wMedAtso   + cTrb->DIASATS
      wPrzMedFre := wPrzMedFre + cTrb->DIASFRE
      wEntNoPrz  := wEntNoPrz  + IIF(cTrb->DTDIGIT <= cTrb->DATPRF,1,0)

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³IMPRIME DETALHE  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      fImpDet()

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ADCIONA OCORRENCIA, PESO E QUANTIDADE A MATRIZ ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      fAddPerfil()
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA O PROXIMO REGISTRO³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      DBSELECTAREA("cTrb")
      DBSKIP()
   
   ENDDO

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³CALCULA NOTA/CONCEITO DO FORNECEDOR³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //FCALCNota()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³IMPRIME TOTAL DO FORNECEDOR ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   fImpTotal()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImpDet    ³ Imprime entrega do fornecedor                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpDet
Static FUNCTION fImpDet()
   IF !( LEN(wImpLinha) > 10 )
      wImpLinha:= SPACE(LEN(cTrb->COD+LEFT(cTrb->NOME,36))+1)+"|"
   ENDIF
   wImpLinha:= wImpLinha+cTrb->PEDIDO+"|"+cTrb->NFISCAL+"|"
   wImpLinha:= wImpLinha+TRANS(cTrb->VALBRUT,"@E 99,999,999.99")+"|"
   wImpLinha:= wImpLinha+DTOC(cTrb->EMISSPE)+"|"+DTOC(cTrb->DATPRF)+"|"
   wImpLinha:= wImpLinha+DTOC(cTrb->EMISSNF)+"|"+DTOC(cTrb->DTDIGIT)+"|"
   wImpLinha:= wImpLinha+STR(wDiaAts,8,0)+"|"
   wImpLinha:= wImpLinha+STR(cTrb->DTDIGIT-cTrb->EMISSNF,8,0)+ "    |"

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³IMPRIME LINHA DO RELATORIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   fImpLinha()

   wImpLinha := ""

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImpForn   ³ Imprime dados do fornecedor                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpForn
Static FUNCTION fImpForn()

   wImpLinha:= cTrb->COD
   wImpLinha:= wImpLinha+"|"+LEFT(cTrb->NOME,36)+"|"
   /*
   wImpLinha:= wImpLinha+"|"+cTrb->PEDIDO
   wImpLinha:= wImpLinha+"|"+cTrb->NFISCAL
   wImpLinha:= wImpLinha+"|"+TRANS(cTrb->VALBRUT,"@E 99,999,999.99")
   wImpLinha:= wImpLinha+"|"+DTOC(cTrb->EMISSPE) 
   wImpLinha:= wImpLinha+"|"+DTOC(cTrb->DATPRF)
   wImpLinha:= wImpLinha+"|"+DTOC(cTrb->EMISSNF)
   wImpLinha:= wImpLinha+"|"+DTOC(cTrb->DTDIGIT)
   wImpLinha:= wImpLinha+"|"+STR(wDiaAts,8,0)
   wImpLinha:= wImpLinha+"|"+STR(cTrb->DTDIGIT-cTrb->EMISSNF,8,0)+"     |"
   */
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³IMPRIME LINHA DO RELATORIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //fImpLinha()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImpTotal  ³ Imprime o Total do Fornecedor                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTotal
Static FUNCTION fImpTotal()

   wImpLinha:= SPACE(57)+"|"+TRANS(wTFornec,"@E 99,999,999.99")+"|"+SPACE(35)
   wImpLinha:= wImpLinha+"|"+STR(wMedAtso/wQtdEnt,8,0) 
   wImpLinha:= wImpLinha+"|"+STR(wPrzMedFre/wQtdEnt,8,0)+"    |"

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³IMPRIME LINHA DO RELATORIO  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   fImpLinha()

   //fImpNota()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImpLinha  ³ Imprime linha de dados                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpLinha
Static FUNCTION fImpLinha()
   @ li, 001 PSAY wImpLinha
   li := li + 1
RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fCalcNota  ³ Calcula nota(conceito) do fornecedor para o periodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCalcNota
Static FUNCTION fCalcNota()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³FORMULA: CALCULA NOTA P/ PONTUALIDADE     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   AEVAL(aPerfilP,{|x| Nda_x_Qea:=Nda_x_Qea+(X[1]*X[2])})
   wEntAts  := wQtdEnt - wEntNoPrz
   wNotaP   := ROUND((wEntNoPrz / wQtdEnt * 10) - (Nda_x_Qea/(EntAts*wFator)),2)

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fImpNota   ³ Imprime nota final do fornecedor                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpNota
Static FUNCTION fImpNota()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³MONTA PERFIL DE PONTUALIDADE              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   @ li,00 PSAY PADR("Conceito em pontualidade: "+TRANS(wNotaQ,"@E 99.99"),132)
   li := li + 1

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fAddPerfil ³ Adiciona ocorrencias ao perfil do fornecedor             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAddPerfil
Static FUNCTION fAddPerfil()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³MONTA PERFIL DE QUALIDADE                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //IF (wPos := ASCAN(aPerfilQ,{|x| x[1]==UZF->UZF_PESO})) > 0
   //   aPerfilQ[wPos][2] := aPerfilQ[wPos][2] + UZG->UZG_QTDOCO //QTD DO MESMO PRODUTO COM A MESMA OCORRENCIA
   //ELSE
   //   AADD(aPerfilQ,{UZF->UZF_PESO,UZG->UZG_QTDOCO})
   //ENDIF

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³MONTA PERFIL DE PONTUALIDADE              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //IF (wPos := ASCAN(aPerfilP,{|x| x[1]==EVAL(bDiasAts1)})) > 0
   //   aPerfilP[wPos][2] := aPerfilP[wPos][2] + 1 
   //ELSE
   //   AADD(aPerfilP,{EVAL(bDiasAts1),1})
   //ENDIF
   

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fGeraDado  ³ GERA DADOS P/ IMPRESSAO A PARTIR DOS ARQUIVOS SF1 E UZG  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGeraDado
Static FUNCTION fGeraDado()

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ LE OCORRENCIAS COM NF ACEITA                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DBSELECTAREA("SF1")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SET VARIAVEIS P/ INDREGUA³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cIndSF1 := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "F1_FORNECE+F1_LOJA+DTOS(F1_EMISSAO)"
   cFiltro := "EVAL(bFoDeAte,SF1->F1_FORNECE) .AND. EVAL(bDtDeAte,SF1->F1_EMISSAO) .AND. SF1->F1_TIPO == 'N'"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SELECIONA NFS'S          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   IndRegua("SF1",cIndSF1,cChave,,cFiltro,"Selecionando Entr...")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SETA REGUA DE CONTAGEM   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PROCREGUA(SF1->(LASTREC()))

   WHILE !SF1->(EOF())
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³INCREMENTA REGUA        ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IncProc()
      
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA NOTA FISCAL      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF ! SD1->(DBSEEK(xFILIAL("SD1")+DTOS(SF1->F1_EMISSAO)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         MSGALERT("ITENS  DA NF NAO ENCONTRADA "+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA INTEM DA NF ORIGINADO APARTIR DE UM PEDIDO DE COMPRA 				  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      wTmpPedido := ""
	  wChaveSF1  := SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE
      wChaveSD1  := {||SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE}
      
      WHILE  wChaveSF1 == EVAL(wChaveSD1) .AND. !EOF()
         IF ! EMPTY(SD1->D1_PEDIDO)
            wTmpPedido := SD1->D1_PEDIDO
         	EXIT
         ENDIF
         SD1->(DBSKIP())
      ENDDO
      
      IF EMPTY( wTmpPedido )
         DBSKIP()
         LOOP
      ENDIF
      
      IF !SC7->(DBSEEK(xFILIAL("SC7")+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_PEDIDO,.F.))
         DBSKIP()
         LOOP
      ENDIF

	
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA FORNECEDOR    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³GRAVA DADOS                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      fGravaSF1()
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA O PROXIMO REGISTRO³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      DBSELECTAREA("SF1")
      DBSKIP()
   
   ENDDO



   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ LE OCORRENCIAS COM NF RECUSADA                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DBSELECTAREA("UZG")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SET VARIAVEIS P/ INDREGUA³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cIndUZG := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "UZG_FORNE+UZG_LOJA+DTOS(UZG_DATA)"
   cFiltro := "EVAL(bFoDeAte,UZG->UZG_FORNE) .AND. EVAL(bDtDeAte,UZG->UZG_DATA) .AND. LEFT(UZG->UZG_NF,1) == 'D'"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SELECIONA NFS'S          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   IndRegua("UZG",cIndUZG,cChave,,cFiltro,"Selecionando Ocorr...")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ SETA REGUA DE CONTAGEM   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PROCREGUA(UZG->(LASTREC()))

   wOldNota := ""

   WHILE !UZG->(EOF())
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³INCREMENTA REGUA        ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IncProc()

      IF (wOldNota == cTrb->NFISCAL)
         DBSKIP()
         LOOP
      ENDIF
   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA FORNECEDORES     ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         MSGALERT("NF NAO ENCONTRADA "+UZG->UZG_FORNE+UZG->UZG_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA PEDIDO DE COMPRA ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF ! SC7->(DBSEEK(xFILIAL("SC7")+UZG->UZG_FORNE+UZG->UZG_LOJA+UZG->UZG_PEDIDO,.F.))
         DBSKIP()
         LOOP
      ELSE
         DBSKIP()
         LOOP
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA FORNECEDOR    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³GRAVA DADOS                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      fGravaUZG()

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³SET VARIAVEIS DE CONTROLE   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      wOldNota := cTrb->NFISCAL

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³POSICIONA O PROXIMO REGISTRO³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      DBSELECTAREA("UZG")
      DBSKIP()
   
   ENDDO

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fGravaSF1  ³ GRAVA DASDOS ORIGINARIOS DO SF1 - CABEC. DE NOTA FISCAL  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGravaSF1
Static FUNCTION fGravaSF1()

   wDiasAts := SF1->F1_DTDIGIT - SC7->C7_DATPRF
   wDiasFre := SF1->F1_DTDIGIT - SF1->F1_EMISSAO

   DBSELECTAREA("cTrb")

   WHILE ! RECLOCK("cTrb",.T.);ENDDO

   cTrb->COD     := SA2->A2_COD
   cTrb->LOJA    := SA2->A2_LOJA
   cTrb->NOME    := SA2->A2_NOME
   cTrb->PEDIDO  := SD1->D1_PEDIDO
   cTrb->NFISCAL := SF1->F1_DOC
   cTrb->VALBRUT := SF1->F1_VALBRUT
   cTrb->EMISSNF := SF1->F1_EMISSAO
   cTrb->EMISSPE := SC7->C7_EMISSAO
   cTrb->DATPRF  := SC7->C7_DATPRF
   cTrb->DTDIGIT := SF1->F1_DTDIGIT
   cTrb->DIASAts := IIF(wDiasAts > 0, wDiasAts, 0 )
   cTrb->DIASFRE := IIF(wDiasFre > 0, wDiasFre, 0 )

   MSUNLOCK()
   DBCOMMIT()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ fGravaUZG  ³ GRAVA DASDOS ORIGINARIOS DO UZG - OCORRENCIAS DA ENTREGA ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGravaUZG
Static FUNCTION fGravaUZG()

   wDiasAts := UZG->UZG_DTDIG - SC7->C7_DATPRF
   wDiasFre := UZG->UZG_DTDIG - UZG->UZG_DATA

   DBSELECTAREA("cTrb")

   WHILE ! RECLOCK("cTrb",.T.);ENDDO

   cTrb->COD     := UZG->UZG_FORNE
   cTrb->NOME    := SA1->A1_NOME
   cTrb->LOJA    := UZG->UZG_LOJA
   cTrb->PEDIDO  := UZG->UZG_PEDIDO
   cTrb->NFISCAL := UZG->UZG_NF
   cTrb->VALBRUT := UZG->UZG_VALBR
   cTrb->EMISSNF := UZG->UZG_DATA
   cTrb->EMISSPE := SC7->C7_EMISSAO
   cTrb->DATPRF  := SC7->C7_DATPRF
   cTrb->DTDIGIT := UZG->UZG_DTDIG
   cTrb->DIASAts := IIF(wDiasAts > 0, wDiasAts, 0 )
   cTrb->DIASFRE := IIF(wDiasFre > 0, wDiasFre, 0 )

   MSUNLOCK()
   DBCOMMIT()

RETURN(NIL)
*----------------------------------------------------------------------------
