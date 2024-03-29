#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN65003V()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("WALIAS,CTES,CNOTA,CPROD,CTOTAL,CVALINSS")
SetPrvt("CVALIRF,CVALISS,CFRETE,CDESPESA,CVALMERC,CDESCONT")
SetPrvt("CCREDIPI,CVALOR,CVALORX,CVALORY,CVALORZ,CVALORI")
SetPrvt("CARQSF4,CINDSF4,CREGSF4,XGRUPO,XCALCIPI,")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � BI65003V � Autor � MICROSIGA VITORIA     � Data � 03/05/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Lancto 650 - Fornecedor                                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      �                                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
wAlias := Alias()

IF Val(SD1->D1_TES) < 501
   cTes := SD1->D1_TES
Else
   cTes := STRZERO((Val(alltrim(SD1->D1_TES))-500),3,0)
EndIF

cNota  := SD1->D1_DOC
cProd  := SD1->D1_COD
//cTotal   := SD1->D1_TOTAL+SD1->D1_VALIPI
cTotal   := SD1->D1_TOTAL
cValINSS := EXECBLOCK("IN650INS",.F.,.F.)
cValIRF  := EXECBLOCK("IN650IRF",.F.,.F.)
cValISS  := EXECBLOCK("IN650ISS",.F.,.F.)
cTotal   := cTotal - cValINSS - cValIRF - cValISS
cFrete   := SF1->F1_FRETE
cDespesa := SF1->F1_DESPESA
cValmerc := SF1->F1_VALMERC
cDescont := SF1->F1_DESCONT
cCredIpi := " "
cValor   := 0
cValorx  := 0
cValory  := 0
cValorz  := 0
cValori  := 0
DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()
DbSetOrder(1)
IF DbSeek(xFilial("SF4")+cTES,.F.)       // Pesquisa TES da NF de entrada
   xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

//ALERT(xGrupo)

Do Case
   Case xGrupo   == "010"
        cValor   := cTotal
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "015"
        cValor   := cTotal
            IF DbSeek(xFilial("SF4")+cTes,.F.)  // Pesquisa TES da NF de entrada
               xCalcIpi := F4_IPI               // Carrega variavel com o Grupo Contab.
               If xCalcIpi == "S"
                  cValori := SD1->D1_VALIPI
               Endif
            Endif
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory+cValori
   Case xGrupo   == "020"
        //cValor   := cTotal+SD1->D1_VALIPI
        cValor   := cTotal
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "030"
        cValor   := cTotal+SD1->D1_VALIPI
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "040"
        cValor   := cTotal+SD1->D1_VALIPI
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "090"
        cValorz  := cTotal
   Case xGrupo   == "050"
        cValor   := cTotal
            IF DbSeek(xFilial("SF4")+cTes,.F.)  // Pesquisa TES da NF de entrada
               xCalcIpi := F4_IPI               // Carrega variavel com o Grupo Contab.
               If xCalcIpi == "S"
                  cValori := SD1->D1_VALIPI
               Endif
            Endif
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory+cValori
EndCase

dbSelectArea(wAlias)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(cValorz)
Return(cValorz)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
