#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia203b()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CREF,LSN,_SALIAS,NORD,CCH,NTAMANHO")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    � BIA203B    � Autor � Marcelo Ventura Felix � Data �21/03/2000낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Atualiza B1_YVLCVP pela descricao                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Interpretador xBase                                          낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
cRef := alltrim(m->b1_desc)
Do While " " $ cRef
   If left (cRef,1) $ "0123456789"
      exit
   EndIf
   cRef := alltrim(substr(cRef,at(" ",cref)))
EndDo
cref := left(m->b1_desc,at(cref,m->b1_desc)-1)+left (cref,1)
lSN  := MsgBox ("Completar este Valor Custo Padrao para a"+chr(10)+"Referencia "+cRef+"?","Aten눯o","YesNo")
if lSN
   _sAlias := Alias()
   dbselectarea("SB1")
   MsUnLock()
   nOrd := indexord()
   cCh := SB1->B1_FILIAL+SB1->B1_COD
   Processa( {|| fAtua_Arq() },"Atualizando Custo Padrao!..." )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    Processa( {|| Execute(fAtua_Arq) },"Atualizando Custo Padrao!..." )
   DbSeek(cCh)
   DbSetOrder(nOrd)
   RecLock("SB1", .f. )
   dbSelectArea(_sAlias)
endif
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(M->B1_YVLCVP)
Return(M->B1_YVLCVP)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
 
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAtua_Arq
Static Function fAtua_Arq()
ProcRegua( SB1->( RecCount() ) )
cRef := SB1->B1_FILIAL+cRef
nTamanho := len(cRef)
DbSetOrder(3)
DbSeek(cRef)
Do While Left(SB1->B1_FILIAL+SB1->B1_DESC,nTamanho) == cRef
   RecLock("SB1", .f. )
   SB1->B1_YVLCVP   := M->B1_YVLCVP
   MsUnLock()
   IncProc()
   DbSkip()
EndDo
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return()
Return()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01