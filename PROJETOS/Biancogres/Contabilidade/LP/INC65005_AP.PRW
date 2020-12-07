#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function INC65005()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CALIAS,_NINDIC,_NRECNO,CARQSB1,CARQSF4,WESTICM")
SetPrvt("WESTADO,WNORTE,CTES,CNOTA,CPROD,CESTADO")
SetPrvt("WCONS,_CARQSF4,_CINDSF4,_CREGSF4,XGRUPO,_CARQSB1")
SetPrvt("_CINDSB1,_CREGSF1,TTDIFICM,WDIFICM,WVALICM,WICM")
SetPrvt("_VALTIT,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA65005 ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 03/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lancto 650 - Diferenca de ICMS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
_cAlias := Alias()
_nIndic := IndexOrd()
_nRecno := Recno()

cArqSB1 := cArqSF4 := cArqSB1 := ""

IF UPPER(ALLTRIM(FUNNAME())) == "MATA115" // Frete c/diferencial aliquota
   //wESTICM:= GetMV("MV_FRETEST")
   wESTICM := "ES12"
Else
   //If SB1->B1_YCNV52 == "S"
   //   wESTICM := "ES11"
   //Else
      //wESTICM:= GetMV("MV_ESTICM")
      wESTICM := "ES17"
   //EndIf
EndIF
wESTADO := GetMV("MV_ESTADO")
wNORTE  := GetMV("MV_NORTE")
IF Val(SD1->D1_TES) < 501
   cTes := SD1->D1_TES
Else
   cTes := STRZERO((Val(alltrim(SD1->D1_TES))-500),3,0)
EndIF
cNota   := SD1->D1_DOC
cProd   := SD1->D1_COD
cEstado := SA2->A2_EST

wCONS   := "N"

DbSelectArea("SF4")
_cArqSF4 := Alias()
_cIndSF4 := IndexOrd()
_cRegSF4 := Recno()
DbSetOrder(1)

IF DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de entrada
   xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

DbSelectArea("SB1")
_cArqSB1 := Alias()
_cIndSB1 := IndexOrd()
_cRegSF1 := Recno()
DbSetOrder(1)

DbSeek(xFilial("SB1")+cProd,.F.)       // Pesquisa TES da NF de entrada

TtDifIcm := wDifIcm := wValIcm := wICM := 0

If SF4->F4_CREDICM == "N" .or. Subs(SF4->F4_CF,2,3) $ "551"
   If  cESTADO <> "ES" .And. SF4->F4_COMPL == "S"
       If  At(AllTrim(wESTADO),wNORTE) > 0
           wICM    := Val(Subs(wESTICM,At(Alltrim(wESTADO),wESTICM)+2,2))
           wValIcm := (SD1->D1_BASEICM * wICM) / 100
           wDifIcm := wValIcm - SD1->D1_VALICM
       EndIf
   EndIf
Endif
Do Case
   Case xGrupo == "010"
        TtDifIcm := wDifIcm
   Case xGrupo == "015"
        TtDifIcm := wDifIcm
   Case xGrupo == "020"
        TtDifIcm := wDifIcm
   Case xGrupo == "030"
        TtDifIcm := 0
   Case xGrupo == "040"
        TtDifIcm := 0
   Case xGrupo == "090"
        TtDifIcm := 0
EndCase

If alltrim(cArqSB1) <> ""
   dbSelectArea(_cArqSB1)
   dbSetOrder(_cIndSB1)
   dbGoTo(_cRegSB1)
EndIf
If alltrim(cArqSF4) <> ""
   dbSelectArea(_cArqSF4)
   dbSetOrder(_cIndSF4)
   dbGoTo(_cRegSF4)
EndIf

_valtit := xMoeda(TtDifIcm,1,2,ddatabase)

dbSelectArea(_cAlias)
dbSetOrder(_nIndic)
dbGoTo(_nRecno)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(_valtit)
Return(_valtit)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
