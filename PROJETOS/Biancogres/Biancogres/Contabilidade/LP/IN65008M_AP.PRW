#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN65008M()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WALIAS,CTES,CNOTA,CPROD,CTOTAL,CFRETE")
SetPrvt("CDESPESA,CVALMERC,CDESCONT,CCREDIPI,CVALOR,CVALORX")
SetPrvt("CVALORY,CVALORZ,CVALORI,CARQSF4,CINDSF4,CREGSF4")
SetPrvt("XGRUPO,XCALCIPI,_VALTIT,_PERC,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BI65001M ³ Autor ³ MICROSIGA - VITORIA   ³ Data ³ 03/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lancto 650 - Valor Produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
wAlias   := Alias()
IF  Val(SD1->D1_TES) < 501
   cTes := SD1->D1_TES
Else
   cTes := STRZERO((Val(alltrim(SD1->D1_TES))-500),3,0)
EndIF

cNota    := SD1->D1_DOC
cProd    := SD1->D1_COD
cTotal   := SD1->D1_TOTAL+SD1->D1_VALIPI
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
IF DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de entrada
   xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

Do Case
   Case xGrupo   == "010"
        cValor   := cTotal+SD1->D1_ICMSRET
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "015"
        cValor   := cTotal-SD1->D1_VALICM-SD1->D1_ICMSRET
            IF DbSeek(xFilial("SF4")+cTes,.F.)  // Pesquisa TES da NF de entrada
               xCalcIpi := F4_IPI               // Carrega variavel com o Grupo Contab.
               If xCalcIpi == "R"
                  cValori := (2 * SD1->D1_VALIPI)
               Endif
               If xCalcIpi == "S"
                  cValori := SD1->D1_VALIPI
               Endif
            Endif
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory-cValori

   Case xGrupo   == "020"
        //cValor   := cTotal-SD1->D1_VALIPI+SD1->D1_ICMSRET
        cValor   := cTotal+SD1->D1_ICMSRET
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "030"
        cValor   := cTotal-SD1->D1_VALIPI-SD1->D1_VALICM
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "040"
        cValor   := cTotal+SD1->D1_VALIPI+SD1->D1_ICMSRET+SD1->D1_VALICM
        cValorx  := ((cDespesa+cFrete)/cValmerc)*cTotal
        cValory  := (cDescont/cValmerc)*cTotal
        cValorz  := cValor+cValorx-cValory
   Case xGrupo   == "090"
        cValorz  := cTotal
EndCase
_valtit := 0
DbSelectArea("SE2")
DbSetOrder(6)
DbSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC)
Do while .not. eof() .and. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
                           xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC
   _valtit := _valtit + xMoeda(SE2->E2_VALOR,1,4,SE2->E2_VENCREA)
   DbSkip()
EndDo
If _valtit > 0
   _perc := (cValorz / SF1->F1_VALMERC) 
   _valtit := _perc * _valtit
Else
   _valtit := xMoeda(cValorz,1,4,ddatabase)
EndIf
dbSelectArea(wAlias)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(_valtit)
Return(_valtit)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
