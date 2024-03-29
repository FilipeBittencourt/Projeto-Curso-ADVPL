#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Uzg008()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿑un놹o    � UZG008   � Autor � AUGUSTO C. DE OLIVEIRA � Data � 14/12/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri놹o � Relatorio de Entrega de Materiais no Periodo (A)            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿢so       � SIGAEST e SIGACOM                                           낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� INICIALIZA VARIAVEIS DE TRABALHO�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
   
   //旼컴컴컴컴컴컴컴컴컴컴�
   //� ATUALIZA PARAMETROS �
   //읕컴컴컴컴컴컴컴컴컴컴�
   PERGUNTE("UZG008",.F.)

   If ( nLastKey == 27 ) .OR. ( LastKey() == 27 ) .OR. lEnd
      Return
   Endif

  
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //넬컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커�
   //납 INICIALIZA VARIAVEIS DE PARAMETROS        납
   //냅컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� MV_PAR01 - Data DE            ?             �
   //� MV_PAR02 - Data Ate           ?             �
   //� MV_PAR03 - Fornecedor DE      ?             �
   //� MV_PAR04 - Fornecedor ATE     ?             �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   
   wDataDe := MV_PAR01
   wDataAte:= MV_PAR02
   wFornDe := MV_PAR03
   wFornAte:= MV_PAR04
   bDrive  := {||IIF(RDDNAME()$"DBFCDX,DBFCDXAX",RDDNAME(),"DBFNTX")}

   fCriaArq()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� SELECIONA ARQUIVOS E INDICE DE TRABALHO �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   DBSELECTAREA("SF1")
   DBSETORDER(1)

   DBSELECTAREA("SD1")
   DBSETORDER(3)
   
   DBSELECTAREA("SA2")
   DBSETORDER(1)
   
   DBSELECTAREA("SC7")
   DBSETORDER(3)
   
   DBSELECTAREA("UZG")
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� GERA DADOS P/ IMPRIMIR       �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   Processa({|| fGeraDado() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    Processa({|| Execute(fGeraDado) })
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� IMPRIME ENTREGAS/OCORRENCIAS �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   RptStatus({|| fImprime() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    RptStatus({|| Execute(fImprime) })
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� IMPRIME RODAPE           �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   Roda(cbcont,cbtxt,"M")
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� APAGA INDICE TEMPORARIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   dbSelectArea("UZG")
   RetIndex("UZG")
   
   IF File(cIndUZG+".CDX")
      Ferase(cIndUZG+".CDX")
   ENDIF
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� APAGA INDICE TEMPORARIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   dbSelectArea("SF1")
   RetIndex("SF1")
   
   IF File(cIndSF1+".CDX")
      Ferase(cIndSF1+".CDX")
   ENDIF

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� APAGA INDICE TEMPORARIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   dbSelectArea("cTrb")
   DBCLOSEAREA()
   
   Ferase(cTrb+".DBF")
   Ferase(cTrb+".CDX")

   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� LIBERA PARA SPOOL        �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   IF aReturn[5] == 1
      Set Printer To
      Commit
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //� CHAMADA DO SPOOL DE IMPRESSAO     �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      ourspool(NomeRel)
   ENDIF
   
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� LIBERA FILA DE RELATORIOS EM SPOOL�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   MS_FLUSH()
   
   //旼컴컴컴컴컴컴컴커
   //� FIM DO PROGRAMA�
   //읕컴컴컴컴컴컴컴켸
RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fCriaArq   � Cria arquivo temporario                                  낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImprime   � Relatorio de Entrega de Materiais no Periodo             낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

   DBSELECTAREA("cTrb")
   DBGOTOP()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SETA REGUA DE CONTAGEM   �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   SetRegua(cTrb->(LASTREC()))

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //� INICIALIZA VARIAVEIS PARA USO DESTA FUNCAO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
   
      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿔NCREMENTA REGUA        �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IncRegua()
   
      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿎ABECALHO DA PAGINA     �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IF li > 60
         li := Cabec(Titulo,Cabec1,Cabec2,NomeRel,Tamanho,15) + 1
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿣ERIFICA SE MUDOU FORNECEDOR    �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      wDiaAts := cTrb->DTDIGIT-cTrb->DATPRF
      wDiaAts := IIF(wDiaAts >0,wDiaAts,0)

      IF wOldForn #EVAL(bFornece)
         IF !EMPTY(wOldForn)
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //쿎ALCULA NOTA/CONCEITO DO FORNECEDOR�
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //fCalcNota()
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //쿔MPRIME TOTAL DO FORNECEDOR �
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            fImpTotal()
            wEntTotal := wEntNoPrz := wQtdEnt := wTFornec := wMedAtso := wPrzMedFre := 0
         ENDIF
         //旼컴컴컴컴컴컴컴컴컴컴컴커
         //쿛OSICIONA FORNECEDOR    �
         //읕컴컴컴컴컴컴컴컴컴컴컴켸
         IF ! SA2->(DBSEEK(xFILIAL("SA2")+cTrb->COD+cTrb->LOJA,.F.))
            DBSKIP()
            LOOP
         ENDIF
         //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
         //쿔mprime dados do fornecedor     �
         //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
         fImpForn()
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿌TUALIZA VARIAVEIS DE CONTROLE E ACUMULA VALORES �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      wOldForn   := EVAL(bFornece)
      wQtdEnt    := wQtdEnt    + 1
      wTFornec   := wTFornec   + cTrb->VALBRUT
      wMedAtso   := wMedAtso   + cTrb->DIASATS
      wPrzMedFre := wPrzMedFre + cTrb->DIASFRE
      wEntNoPrz  := wEntNoPrz  + IIF(cTrb->DTDIGIT <= cTrb->DATPRF,1,0)

      //旼컴컴컴컴컴컴컴컴�
      //쿔MPRIME DETALHE  �
      //읕컴컴컴컴컴컴컴컴�
      fImpDet()

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿌DCIONA OCORRENCIA, PESO E QUANTIDADE A MATRIZ �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      fAddPerfil()
   
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿛OSICIONA O PROXIMO REGISTRO�
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      DBSELECTAREA("cTrb")
      DBSKIP()
   
   ENDDO

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //쿎ALCULA NOTA/CONCEITO DO FORNECEDOR�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
   //FCALCNota()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿔MPRIME TOTAL DO FORNECEDOR �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   fImpTotal()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImpDet    � Imprime entrega do fornecedor                            낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿔MPRIME LINHA DO RELATORIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   fImpLinha()

   wImpLinha := ""

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImpForn   � Imprime dados do fornecedor                              낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿔MPRIME LINHA DO RELATORIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   //fImpLinha()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImpTotal  � Imprime o Total do Fornecedor                            낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTotal
Static FUNCTION fImpTotal()

   wImpLinha:= SPACE(57)+"|"+TRANS(wTFornec,"@E 99,999,999.99")+"|"+SPACE(35)
   wImpLinha:= wImpLinha+"|"+STR(wMedAtso/wQtdEnt,8,0) 
   wImpLinha:= wImpLinha+"|"+STR(wPrzMedFre/wQtdEnt,8,0)+"    |"

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿔MPRIME LINHA DO RELATORIO  �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   fImpLinha()

   //fImpNota()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImpLinha  � Imprime linha de dados                                   낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpLinha
Static FUNCTION fImpLinha()
   @ li, 001 PSAY wImpLinha
   li := li + 1
RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fCalcNota  � Calcula nota(conceito) do fornecedor para o periodo      낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCalcNota
Static FUNCTION fCalcNota()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿑ORMULA: CALCULA NOTA P/ PONTUALIDADE     �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   AEVAL(aPerfilP,{|x| Nda_x_Qea:=Nda_x_Qea+(X[1]*X[2])})
   wEntAts  := wQtdEnt - wEntNoPrz
   wNotaP   := ROUND((wEntNoPrz / wQtdEnt * 10) - (Nda_x_Qea/(EntAts*wFator)),2)

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fImpNota   � Imprime nota final do fornecedor                         낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpNota
Static FUNCTION fImpNota()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿘ONTA PERFIL DE PONTUALIDADE              �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   @ li,00 PSAY PADR("Conceito em pontualidade: "+TRANS(wNotaQ,"@E 99.99"),132)
   li := li + 1

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fAddPerfil � Adiciona ocorrencias ao perfil do fornecedor             낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAddPerfil
Static FUNCTION fAddPerfil()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿘ONTA PERFIL DE QUALIDADE                 �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   //IF (wPos := ASCAN(aPerfilQ,{|x| x[1]==UZF->UZF_PESO})) > 0
   //   aPerfilQ[wPos][2] := aPerfilQ[wPos][2] + UZG->UZG_QTDOCO //QTD DO MESMO PRODUTO COM A MESMA OCORRENCIA
   //ELSE
   //   AADD(aPerfilQ,{UZF->UZF_PESO,UZG->UZG_QTDOCO})
   //ENDIF

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //쿘ONTA PERFIL DE PONTUALIDADE              �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   //IF (wPos := ASCAN(aPerfilP,{|x| x[1]==EVAL(bDiasAts1)})) > 0
   //   aPerfilP[wPos][2] := aPerfilP[wPos][2] + 1 
   //ELSE
   //   AADD(aPerfilP,{EVAL(bDiasAts1),1})
   //ENDIF
   

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fGeraDado  � GERA DADOS P/ IMPRESSAO A PARTIR DOS ARQUIVOS SF1 E UZG  낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGeraDado
Static FUNCTION fGeraDado()

   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� LE OCORRENCIAS COM NF ACEITA                                 �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   DBSELECTAREA("SF1")

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SET VARIAVEIS P/ INDREGUA�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   cIndSF1 := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "F1_FORNECE+F1_LOJA+DTOS(F1_EMISSAO)"
   cFiltro := "EVAL(bFoDeAte,SF1->F1_FORNECE) .AND. EVAL(bDtDeAte,SF1->F1_EMISSAO) .AND. SF1->F1_TIPO == 'N'"
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SELECIONA NFS'S          �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   IndRegua("SF1",cIndSF1,cChave,,cFiltro,"Selecionando Entr...")

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SETA REGUA DE CONTAGEM   �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   PROCREGUA(SF1->(LASTREC()))

   WHILE !SF1->(EOF())
   
      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿔NCREMENTA REGUA        �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IncProc()
      
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿛OSICIONA NOTA FISCAL      �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
      IF ! SD1->(DBSEEK(xFILIAL("SD1")+DTOS(SF1->F1_EMISSAO)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         MSGALERT("ITENS  DA NF NAO ENCONTRADA "+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿛OSICIONA INTEM DA NF ORIGINADO APARTIR DE UM PEDIDO DE COMPRA 				  �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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

	
      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿛OSICIONA FORNECEDOR    �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿒RAVA DADOS                 �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      fGravaSF1()
   
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿛OSICIONA O PROXIMO REGISTRO�
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      DBSELECTAREA("SF1")
      DBSKIP()
   
   ENDDO



   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� LE OCORRENCIAS COM NF RECUSADA                               �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   DBSELECTAREA("UZG")

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SET VARIAVEIS P/ INDREGUA�
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   cIndUZG := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "UZG_FORNE+UZG_LOJA+DTOS(UZG_DATA)"
   cFiltro := "EVAL(bFoDeAte,UZG->UZG_FORNE) .AND. EVAL(bDtDeAte,UZG->UZG_DATA) .AND. LEFT(UZG->UZG_NF,1) == 'D'"
   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SELECIONA NFS'S          �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   IndRegua("UZG",cIndUZG,cChave,,cFiltro,"Selecionando Ocorr...")

   //旼컴컴컴컴컴컴컴컴컴컴컴컴커
   //� SETA REGUA DE CONTAGEM   �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴켸
   PROCREGUA(UZG->(LASTREC()))

   wOldNota := ""

   WHILE !UZG->(EOF())
   
      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿔NCREMENTA REGUA        �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IncProc()

      IF (wOldNota == cTrb->NFISCAL)
         DBSKIP()
         LOOP
      ENDIF
   
      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿛OSICIONA FORNECEDORES     �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         MSGALERT("NF NAO ENCONTRADA "+UZG->UZG_FORNE+UZG->UZG_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
      //쿛OSICIONA PEDIDO DE COMPRA �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
      IF ! SC7->(DBSEEK(xFILIAL("SC7")+UZG->UZG_FORNE+UZG->UZG_LOJA+UZG->UZG_PEDIDO,.F.))
         DBSKIP()
         LOOP
      ELSE
         DBSKIP()
         LOOP
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴커
      //쿛OSICIONA FORNECEDOR    �
      //읕컴컴컴컴컴컴컴컴컴컴컴켸
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿒RAVA DADOS                 �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      fGravaUZG()

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿞ET VARIAVEIS DE CONTROLE   �
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      wOldNota := cTrb->NFISCAL

      //旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
      //쿛OSICIONA O PROXIMO REGISTRO�
      //읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
      DBSELECTAREA("UZG")
      DBSKIP()
   
   ENDDO

RETURN(NIL)
*----------------------------------------------------------------------------
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fGravaSF1  � GRAVA DASDOS ORIGINARIOS DO SF1 - CABEC. DE NOTA FISCAL  낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇� fGravaUZG  � GRAVA DASDOS ORIGINARIOS DO UZG - OCORRENCIAS DA ENTREGA 낢�
굇읕컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
