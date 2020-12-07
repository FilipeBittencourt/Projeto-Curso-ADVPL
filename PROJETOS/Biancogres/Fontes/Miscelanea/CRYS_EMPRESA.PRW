#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

User Function PARCRYS()        // incluido pelo assistente de conversao do AP5 IDE em 02/07/02

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CALLCRYS  ³ Autora³ M rcia Tokura         ³ Data ³ 10/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exemplo da chamada de um relat¢rio Crystal atrav‚s do rdmake³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Advanced 407 e Protheus                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³SINTAXE DA³CALLCRYS(<creport>,<cparam>,<copcoes>) onde                 ³±±
±±³FUN€ÇO    ³<creport>= Nome do relatório Crystal,localizado no diretório³±±
±±³CALLCRYS  ³          apontado por MV_CRYSTAL, sem a extensão e path.   ³±±
±±³          ³<cparam> = Parƒmetros passados para o Crystal, em vez de usar³±±
±±³          ³          o SX1, separados por vírgula ou ponto e vírgula.  ³±±
±±³          ³<copcoes>= Conjunto de opções para nao mostrar a tela da    ³±±
±±³          ³           SetPrint, composta por x;y;z;w, onde             ³±±
±±³          ³                         x = vídeo(1) ou impressora(3)      ³±±
±±³          ³                         y = Atualiza(0) ou não(1) os dados ³±±
±±³          ³                         z = Número de cópias               ³±±
±±³          ³                         w = Título do repo                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Private x:="1;0;1;TESTE DE PARAMETROS"
Emp := SM0->M0_NOME
Cod := SM0->M0_CODIGO
CALLCRYS("PARAM",Emp+";"+Cod,x)
Return

