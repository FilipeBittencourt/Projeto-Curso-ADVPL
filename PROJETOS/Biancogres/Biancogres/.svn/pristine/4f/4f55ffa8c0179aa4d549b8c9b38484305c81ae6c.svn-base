#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA862
@author Ranisses A. Corona
@since 20/05/2011
@version 1
@description Amarração NCM x MVA'S" 
@obs Inclusao do novo cabecalho de fonte.
@type function
/*/

User Function BIA862()
Local bNoTTS  := {|| fMsg() }

AxCadastro("Z30","Amarração NCM x MVA'S",           ,          ,         ,     ,   ,      , bNoTTS, , ,         , , )          

Return                                              

/////////////////////////////////////////
Static Function fMsg
Local cMsg 	:= ""
Local Enter	:= CHR(13)+CHR(10)

cMsg := "Qualquer alteração realizada na tabela de MVA, tem influência direta no Valor Total dos Pedidos que estão em Carteira e com cálculo de ICMS ST." + Enter
cMsg += " " + Enter
cMsg += "É necessário sempre comunicar ao Setor Comercial, solicitando o estorno ou refazimento dos Pedidos em Carteira, para que o sistema calcule novamente o valor do imposto!" + Enter
Msgbox(cMsg,"BIA862","STOP")

Return