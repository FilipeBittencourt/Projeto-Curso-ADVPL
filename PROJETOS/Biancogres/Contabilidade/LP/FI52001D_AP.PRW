#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function FI52001D()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CALIAS,NVALOR,NCONTA,CPREF,CNUM,CPARC")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � 52101D   � Autor � Cesar Magnago         � Data � 23/08/01 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Execblock para permitir a contabilizacao do valor exato    낢�
굇�          � dos Cheques que substituem os Titulos a Receber.           낢�
굇�          � Lancamento Padronizado 52101 ( Conta a Debito  )           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Especifico: INCESA                                         낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
cAlias  := Alias()
nValor  := 0

If SE5->E5_PREFIXO <> "CHQ" 

   nConta := SA6->A6_CONTA
   DbSelectArea(cAlias)
Return(nConta)
// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==>    __Return(nValor)
//Return(nValor)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

EndIf

If AllTrim(SE5->E5_TIPO) == "CH"
   cPref   := SE5->E5_PREFIXO
   cNum    := SE5->E5_NUMERO
   cParc   := SE5->E5_PARCELA

   DbSelectArea("SE1")
   DbSetOrder(1)

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      cPref   := SE1->E1_YPREFOR
      cNum    := SE1->E1_YNUMOR
      cParc   := SE1->E1_YPARCOR
   EndIf

   If DbSeek(xFilial("SE1")+cPref+cNum+cParc,.F.)
      fAchaConta()
   Else
      nConta := SA6->A6_CONTA
   Endif

   DbSelectArea(cAlias)
EndIf

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(nConta)
Return(nConta)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> Function fAchaConta
Static Function fAchaConta()

   nConta := SA6->A6_CONTA
   If SE1->E1_SITUACA == "0" .And. !Empty(SE1->E1_PORTADO)
      nConta := "111010001"
   EndIf

Return

