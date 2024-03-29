#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA862
@author Ranisses A. Corona
@since 20/05/2011
@version 1
@description Amarra��o NCM x MVA'S" 
@obs Inclusao do novo cabecalho de fonte.
@type function
/*/

User Function BIA862()
Local bNoTTS  := {|| fMsg() }

AxCadastro("Z30","Amarra��o NCM x MVA'S",           ,          ,         ,     ,   ,      , bNoTTS, , ,         , , )          

Return                                              

/////////////////////////////////////////
Static Function fMsg
Local cMsg 	:= ""
Local Enter	:= CHR(13)+CHR(10)

cMsg := "Qualquer altera��o realizada na tabela de MVA, tem influ�ncia direta no Valor Total dos Pedidos que est�o em Carteira e com c�lculo de ICMS ST." + Enter
cMsg += " " + Enter
cMsg += "� necess�rio sempre comunicar ao Setor Comercial, solicitando o estorno ou refazimento dos Pedidos em Carteira, para que o sistema calcule novamente o valor do imposto!" + Enter
Msgbox(cMsg,"BIA862","STOP")

Return