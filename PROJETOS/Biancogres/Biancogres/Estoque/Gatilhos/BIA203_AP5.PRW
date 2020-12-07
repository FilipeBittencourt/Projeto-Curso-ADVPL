#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia203()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CREF,LSN,_SALIAS,NORD,CCH,NTAMANHO")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA203     ³ Autor ³ Marcelo Ventura Felix ³ Data ³04/02/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza B1_YMONO pela descricao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
*cRef := alltrim(substr(M->B1_DESC,at(" ",M->B1_DESC)))
*cRef := trim(left(cRef,at(" ",cRef)))
*cRef := left(M->B1_DESC,at(cRef,M->B1_DESC)+1)+cRef
cRef := alltrim(m->b1_desc)
Do While " " $ cRef
   If left (cRef,1) $ "0123456789"
      exit
   EndIf
   cRef := alltrim(substr(cRef,at(" ",cref)))
EndDo
cref := left(m->b1_desc,at(cref,m->b1_desc)-1)
lSN  := MsgBox ("Completar esta Monoclassificacao para a"+chr(10)+"Referencia "+cRef+"?","Aten‡Æo","YesNo")
if lSN
   _sAlias := Alias()
   dbselectarea("SB1")
   MsUnLock()
   nOrd := indexord()
   cCh := SB1->B1_FILIAL+SB1->B1_COD
   Processa( {|| fAtua_Arq() },"Atualizando Referencia!..." )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    Processa( {|| Execute(fAtua_Arq) },"Atualizando Referencia!..." )
   DbSeek(cCh)
   DbSetOrder(nOrd)
   RecLock("SB1", .f. )
   dbSelectArea(_sAlias)
endif
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(M->B1_YMONO)
//Return(M->B1_YMONO)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
 
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAtua_Arq
/*
Static Function fAtua_Arq()
ProcRegua( SB1->( RecCount() ) )
cRef := SB1->B1_FILIAL+cRef
nTamanho := len(cRef)
DbSetOrder(3)
DbSeek(cRef)
Do While Left(SB1->B1_FILIAL+SB1->B1_DESC,nTamanho) == cRef
   RecLock("SB1", .f. )
   SB1->B1_YMONO    := M->B1_YMONO
   MsUnLock()
   IncProc()
   DbSkip()
EndDo
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return()
//Return()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01