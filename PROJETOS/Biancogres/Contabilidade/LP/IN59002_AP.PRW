#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN59002()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CALIAS,WPREFIXO,WTITULO,WPARCELA,WTIPO,WCHEQUE")
SetPrvt("WRECNO,WORDER,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    쿔N59002   � Autor � Gustav Koblinger Jr   � Data � 31/08/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Execblock para permitir a contabilizacao 590 Cheque OffLine낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Especifico: CERAMICA INCESA                                낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Lancamento Padronizado ( Contas a Valor para Produto)
cAlias  := Alias()
wPrefixo:= SEF->EF_PREFIXO
wTitulo := SEF->EF_TITULO
wParcela:= SEF->EF_PARCELA
wTipo   := SEF->EF_TIPO
wCheque := ""

dbSelectArea("SEF")
dbSetOrder(3)
wRecno  := Recno()
wOrder  := IndexOrd()
If dbSeek(xFilial("SEF")+wPrefixo+wTitulo+wParcela+wTipo,.T.)
   wCheque := SEF->EF_NUM
EndIf

dbGoTo(wRecno)
dbSetOrder(wOrder)
dbSelectArea(cAlias)

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(wCheque)
Return(wCheque)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
