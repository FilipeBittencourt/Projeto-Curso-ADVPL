#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

User Function IN65001D()        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP6 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CALIAS,CTES,CCONTA,XGRUPO,")

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � AA65001D � Autor � Gustav Koblinger Jr   � Data � 21/09/98 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Execblock para permitir a contabilizacao baseado no grupo  낢�
굇�          � contabil do arquivo de tipo de entrada/saida (tes)         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Especifico: CERAMICA INCESA LTDA.                          낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Lancamento Padronizado ( Contas a Debito para ICMS )

cAlias := Alias()
IF Val(SD1->D1_TES) < 501
   cTes := SD1->D1_TES
Else
   cTes := STRZERO((Val(alltrim(SD1->D1_TES))-500),3,0)
EndIF
cConta := " "
xGrupo := " "

DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de saida
   xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

DbSelectArea(cAlias)

Do Case
   Case xGrupo == "010"
        cConta := "212020001"
   Case xGrupo == "015"
        cConta := "212020001"
   Case xGrupo == "020"
        cConta := "212020001"
   Case xGrupo == "030"
        cConta := "212020001"
   Case xGrupo == "040"
        cConta := "212020001"
   Case xGrupo == "090"
        cConta := SPACE(15)
EndCase

// Substituido pelo assistente de conversao do AP6 IDE em 08/03/04 ==> __Return(cConta)
Return(cConta)        // incluido pelo assistente de conversao do AP6 IDE em 08/03/04
