#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Uzg008()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

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
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � UZG008   � Autor � AUGUSTO C. DE OLIVEIRA � Data � 14/12/00 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio de Entrega de Materiais no Periodo (A)            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGAEST e SIGACOM                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
   //���������������������������������Ŀ
   //� INICIALIZA VARIAVEIS DE TRABALHO�
   //�����������������������������������
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
   
   //���������������������Ŀ
   //� ATUALIZA PARAMETROS �
   //�����������������������
   PERGUNTE("UZG008",.F.)

   If ( nLastKey == 27 ) .OR. ( LastKey() == 27 ) .OR. lEnd
      Return
   Endif

  
   //���������������������������������������������Ŀ
   //��������������������������������������������Ŀ�
   //�� INICIALIZA VARIAVEIS DE PARAMETROS        ��
   //���������������������������������������������ٳ
   //�����������������������������������������������
   //���������������������������������������������Ŀ
   //� MV_PAR01 - Data DE            ?             �
   //� MV_PAR02 - Data Ate           ?             �
   //� MV_PAR03 - Fornecedor DE      ?             �
   //� MV_PAR04 - Fornecedor ATE     ?             �
   //�����������������������������������������������
   
   wDataDe := MV_PAR01
   wDataAte:= MV_PAR02
   wFornDe := MV_PAR03
   wFornAte:= MV_PAR04
   bDrive  := {||IIF(RDDNAME()$"DBFCDX,DBFCDXAX",RDDNAME(),"DBFNTX")}

   fCriaArq()

   //�����������������������������������������Ŀ
   //� SELECIONA ARQUIVOS E INDICE DE TRABALHO �
   //�������������������������������������������
   DBSELECTAREA("SF1")
   DBSETORDER(1)

   DBSELECTAREA("SD1")
   DBSETORDER(3)
   
   DBSELECTAREA("SA2")
   DBSETORDER(1)
   
   DBSELECTAREA("SC7")
   DBSETORDER(3)
   
   DBSELECTAREA("UZG")
   
   //������������������������������Ŀ
   //� GERA DADOS P/ IMPRIMIR       �
   //��������������������������������
   Processa({|| fGeraDado() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    Processa({|| Execute(fGeraDado) })
   
   //������������������������������Ŀ
   //� IMPRIME ENTREGAS/OCORRENCIAS �
   //��������������������������������
   RptStatus({|| fImprime() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    RptStatus({|| Execute(fImprime) })
   
   //��������������������������Ŀ
   //� IMPRIME RODAPE           �
   //����������������������������
   Roda(cbcont,cbtxt,"M")
   
   //��������������������������Ŀ
   //� APAGA INDICE TEMPORARIO  �
   //����������������������������
   dbSelectArea("UZG")
   RetIndex("UZG")
   
   IF File(cIndUZG+".CDX")
      Ferase(cIndUZG+".CDX")
   ENDIF
   
   //��������������������������Ŀ
   //� APAGA INDICE TEMPORARIO  �
   //����������������������������
   dbSelectArea("SF1")
   RetIndex("SF1")
   
   IF File(cIndSF1+".CDX")
      Ferase(cIndSF1+".CDX")
   ENDIF

   //��������������������������Ŀ
   //� APAGA INDICE TEMPORARIO  �
   //����������������������������
   dbSelectArea("cTrb")
   DBCLOSEAREA()
   
   Ferase(cTrb+".DBF")
   Ferase(cTrb+".CDX")

   
   //��������������������������Ŀ
   //� LIBERA PARA SPOOL        �
   //����������������������������
   IF aReturn[5] == 1
      Set Printer To
      Commit
      //�����������������������������������Ŀ
      //� CHAMADA DO SPOOL DE IMPRESSAO     �
      //�������������������������������������
      ourspool(NomeRel)
   ENDIF
   
   //�����������������������������������Ŀ
   //� LIBERA FILA DE RELATORIOS EM SPOOL�
   //�������������������������������������
   MS_FLUSH()
   
   //����������������Ŀ
   //� FIM DO PROGRAMA�
   //������������������
RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fCriaArq   � Cria arquivo temporario                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImprime   � Relatorio de Entrega de Materiais no Periodo             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

   DBSELECTAREA("cTrb")
   DBGOTOP()

   //��������������������������Ŀ
   //� SETA REGUA DE CONTAGEM   �
   //����������������������������
   SetRegua(cTrb->(LASTREC()))

   //���������������������������������������������Ŀ
   //� INICIALIZA VARIAVEIS PARA USO DESTA FUNCAO  �
   //�����������������������������������������������
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
   
      //������������������������Ŀ
      //�INCREMENTA REGUA        �
      //��������������������������
      IncRegua()
   
      //������������������������Ŀ
      //�CABECALHO DA PAGINA     �
      //��������������������������
      IF li > 60
         li := Cabec(Titulo,Cabec1,Cabec2,NomeRel,Tamanho,15) + 1
      ENDIF

      //��������������������������������Ŀ
      //�VERIFICA SE MUDOU FORNECEDOR    �
      //����������������������������������
      wDiaAts := cTrb->DTDIGIT-cTrb->DATPRF
      wDiaAts := IIF(wDiaAts >0,wDiaAts,0)

      IF wOldForn #EVAL(bFornece)
         IF !EMPTY(wOldForn)
            //�����������������������������������Ŀ
            //�CALCULA NOTA/CONCEITO DO FORNECEDOR�
            //�������������������������������������
            //fCalcNota()
            //����������������������������Ŀ
            //�IMPRIME TOTAL DO FORNECEDOR �
            //������������������������������
            fImpTotal()
            wEntTotal := wEntNoPrz := wQtdEnt := wTFornec := wMedAtso := wPrzMedFre := 0
         ENDIF
         //������������������������Ŀ
         //�POSICIONA FORNECEDOR    �
         //��������������������������
         IF ! SA2->(DBSEEK(xFILIAL("SA2")+cTrb->COD+cTrb->LOJA,.F.))
            DBSKIP()
            LOOP
         ENDIF
         //��������������������������������Ŀ
         //�Imprime dados do fornecedor     �
         //����������������������������������
         fImpForn()
      ENDIF

      //�������������������������������������������������Ŀ
      //�ATUALIZA VARIAVEIS DE CONTROLE E ACUMULA VALORES �
      //���������������������������������������������������
      wOldForn   := EVAL(bFornece)
      wQtdEnt    := wQtdEnt    + 1
      wTFornec   := wTFornec   + cTrb->VALBRUT
      wMedAtso   := wMedAtso   + cTrb->DIASATS
      wPrzMedFre := wPrzMedFre + cTrb->DIASFRE
      wEntNoPrz  := wEntNoPrz  + IIF(cTrb->DTDIGIT <= cTrb->DATPRF,1,0)

      //�����������������Ŀ
      //�IMPRIME DETALHE  �
      //�������������������
      fImpDet()

      //�����������������������������������������������Ŀ
      //�ADCIONA OCORRENCIA, PESO E QUANTIDADE A MATRIZ �
      //�������������������������������������������������
      fAddPerfil()
   
      //����������������������������Ŀ
      //�POSICIONA O PROXIMO REGISTRO�
      //������������������������������
      DBSELECTAREA("cTrb")
      DBSKIP()
   
   ENDDO

   //�����������������������������������Ŀ
   //�CALCULA NOTA/CONCEITO DO FORNECEDOR�
   //�������������������������������������
   //FCALCNota()

   //����������������������������Ŀ
   //�IMPRIME TOTAL DO FORNECEDOR �
   //������������������������������
   fImpTotal()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImpDet    � Imprime entrega do fornecedor                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

   //����������������������������Ŀ
   //�IMPRIME LINHA DO RELATORIO  �
   //������������������������������
   fImpLinha()

   wImpLinha := ""

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImpForn   � Imprime dados do fornecedor                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
   //����������������������������Ŀ
   //�IMPRIME LINHA DO RELATORIO  �
   //������������������������������
   //fImpLinha()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImpTotal  � Imprime o Total do Fornecedor                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTotal
Static FUNCTION fImpTotal()

   wImpLinha:= SPACE(57)+"|"+TRANS(wTFornec,"@E 99,999,999.99")+"|"+SPACE(35)
   wImpLinha:= wImpLinha+"|"+STR(wMedAtso/wQtdEnt,8,0) 
   wImpLinha:= wImpLinha+"|"+STR(wPrzMedFre/wQtdEnt,8,0)+"    |"

   //����������������������������Ŀ
   //�IMPRIME LINHA DO RELATORIO  �
   //������������������������������
   fImpLinha()

   //fImpNota()

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImpLinha  � Imprime linha de dados                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpLinha
Static FUNCTION fImpLinha()
   @ li, 001 PSAY wImpLinha
   li := li + 1
RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fCalcNota  � Calcula nota(conceito) do fornecedor para o periodo      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCalcNota
Static FUNCTION fCalcNota()

   //������������������������������������������Ŀ
   //�FORMULA: CALCULA NOTA P/ PONTUALIDADE     �
   //��������������������������������������������
   AEVAL(aPerfilP,{|x| Nda_x_Qea:=Nda_x_Qea+(X[1]*X[2])})
   wEntAts  := wQtdEnt - wEntNoPrz
   wNotaP   := ROUND((wEntNoPrz / wQtdEnt * 10) - (Nda_x_Qea/(EntAts*wFator)),2)

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fImpNota   � Imprime nota final do fornecedor                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpNota
Static FUNCTION fImpNota()

   //������������������������������������������Ŀ
   //�MONTA PERFIL DE PONTUALIDADE              �
   //��������������������������������������������
   @ li,00 PSAY PADR("Conceito em pontualidade: "+TRANS(wNotaQ,"@E 99.99"),132)
   li := li + 1

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fAddPerfil � Adiciona ocorrencias ao perfil do fornecedor             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAddPerfil
Static FUNCTION fAddPerfil()

   //������������������������������������������Ŀ
   //�MONTA PERFIL DE QUALIDADE                 �
   //��������������������������������������������
   //IF (wPos := ASCAN(aPerfilQ,{|x| x[1]==UZF->UZF_PESO})) > 0
   //   aPerfilQ[wPos][2] := aPerfilQ[wPos][2] + UZG->UZG_QTDOCO //QTD DO MESMO PRODUTO COM A MESMA OCORRENCIA
   //ELSE
   //   AADD(aPerfilQ,{UZF->UZF_PESO,UZG->UZG_QTDOCO})
   //ENDIF

   //������������������������������������������Ŀ
   //�MONTA PERFIL DE PONTUALIDADE              �
   //��������������������������������������������
   //IF (wPos := ASCAN(aPerfilP,{|x| x[1]==EVAL(bDiasAts1)})) > 0
   //   aPerfilP[wPos][2] := aPerfilP[wPos][2] + 1 
   //ELSE
   //   AADD(aPerfilP,{EVAL(bDiasAts1),1})
   //ENDIF
   

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fGeraDado  � GERA DADOS P/ IMPRESSAO A PARTIR DOS ARQUIVOS SF1 E UZG  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGeraDado
Static FUNCTION fGeraDado()

   //��������������������������������������������������������������Ŀ
   //� LE OCORRENCIAS COM NF ACEITA                                 �
   //����������������������������������������������������������������
   DBSELECTAREA("SF1")

   //��������������������������Ŀ
   //� SET VARIAVEIS P/ INDREGUA�
   //����������������������������
   cIndSF1 := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "F1_FORNECE+F1_LOJA+DTOS(F1_EMISSAO)"
   cFiltro := "EVAL(bFoDeAte,SF1->F1_FORNECE) .AND. EVAL(bDtDeAte,SF1->F1_EMISSAO) .AND. SF1->F1_TIPO == 'N'"
   //��������������������������Ŀ
   //� SELECIONA NFS'S          �
   //����������������������������
   IndRegua("SF1",cIndSF1,cChave,,cFiltro,"Selecionando Entr...")

   //��������������������������Ŀ
   //� SETA REGUA DE CONTAGEM   �
   //����������������������������
   PROCREGUA(SF1->(LASTREC()))

   WHILE !SF1->(EOF())
   
      //������������������������Ŀ
      //�INCREMENTA REGUA        �
      //��������������������������
      IncProc()
      
      //���������������������������Ŀ
      //�POSICIONA NOTA FISCAL      �
      //�����������������������������
      IF ! SD1->(DBSEEK(xFILIAL("SD1")+DTOS(SF1->F1_EMISSAO)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         MSGALERT("ITENS  DA NF NAO ENCONTRADA "+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //���������������������������������������������������������������������������������Ŀ
      //�POSICIONA INTEM DA NF ORIGINADO APARTIR DE UM PEDIDO DE COMPRA 				  �
      //�����������������������������������������������������������������������������������
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

	
      //������������������������Ŀ
      //�POSICIONA FORNECEDOR    �
      //��������������������������
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //����������������������������Ŀ
      //�GRAVA DADOS                 �
      //������������������������������
      fGravaSF1()
   
      //����������������������������Ŀ
      //�POSICIONA O PROXIMO REGISTRO�
      //������������������������������
      DBSELECTAREA("SF1")
      DBSKIP()
   
   ENDDO



   //��������������������������������������������������������������Ŀ
   //� LE OCORRENCIAS COM NF RECUSADA                               �
   //����������������������������������������������������������������
   DBSELECTAREA("UZG")

   //��������������������������Ŀ
   //� SET VARIAVEIS P/ INDREGUA�
   //����������������������������
   cIndUZG := CriaTrab(,.F.) // Retorna um nome valido para um arq. temporario
   cChave  := "UZG_FORNE+UZG_LOJA+DTOS(UZG_DATA)"
   cFiltro := "EVAL(bFoDeAte,UZG->UZG_FORNE) .AND. EVAL(bDtDeAte,UZG->UZG_DATA) .AND. LEFT(UZG->UZG_NF,1) == 'D'"
   //��������������������������Ŀ
   //� SELECIONA NFS'S          �
   //����������������������������
   IndRegua("UZG",cIndUZG,cChave,,cFiltro,"Selecionando Ocorr...")

   //��������������������������Ŀ
   //� SETA REGUA DE CONTAGEM   �
   //����������������������������
   PROCREGUA(UZG->(LASTREC()))

   wOldNota := ""

   WHILE !UZG->(EOF())
   
      //������������������������Ŀ
      //�INCREMENTA REGUA        �
      //��������������������������
      IncProc()

      IF (wOldNota == cTrb->NFISCAL)
         DBSKIP()
         LOOP
      ENDIF
   
      //���������������������������Ŀ
      //�POSICIONA FORNECEDORES     �
      //�����������������������������
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         MSGALERT("NF NAO ENCONTRADA "+UZG->UZG_FORNE+UZG->UZG_LOJA)
         DBSKIP()
         LOOP
      ENDIF

      //���������������������������Ŀ
      //�POSICIONA PEDIDO DE COMPRA �
      //�����������������������������
      IF ! SC7->(DBSEEK(xFILIAL("SC7")+UZG->UZG_FORNE+UZG->UZG_LOJA+UZG->UZG_PEDIDO,.F.))
         DBSKIP()
         LOOP
      ELSE
         DBSKIP()
         LOOP
      ENDIF

      //������������������������Ŀ
      //�POSICIONA FORNECEDOR    �
      //��������������������������
      IF ! SA2->(DBSEEK(xFILIAL("SA2")+UZG->UZG_FORNE+UZG->UZG_LOJA,.F.))
         DBSKIP()
         LOOP
      ENDIF

      //����������������������������Ŀ
      //�GRAVA DADOS                 �
      //������������������������������
      fGravaUZG()

      //����������������������������Ŀ
      //�SET VARIAVEIS DE CONTROLE   �
      //������������������������������
      wOldNota := cTrb->NFISCAL

      //����������������������������Ŀ
      //�POSICIONA O PROXIMO REGISTRO�
      //������������������������������
      DBSELECTAREA("UZG")
      DBSKIP()
   
   ENDDO

RETURN(NIL)
*----------------------------------------------------------------------------
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fGravaSF1  � GRAVA DASDOS ORIGINARIOS DO SF1 - CABEC. DE NOTA FISCAL  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� fGravaUZG  � GRAVA DASDOS ORIGINARIOS DO UZG - OCORRENCIAS DA ENTREGA ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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