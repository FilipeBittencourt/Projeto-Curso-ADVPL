#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA493A    ³ Autor ³ Wanisay William       ³ Data ³ 16.04.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara envio de e-mail SC em aberto e Pedidos nao entregues ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßß	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA493A

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA493 - BIANCOGRES")
Startjob("U_BIA493","SCHEDULE",.T.,"01")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA493 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA493 - INCESA")
Startjob("U_BIA493","SCHEDULE",.T.,"05")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA493 - INCESA")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA493 - LM")
Startjob("U_BIA493","SCHEDULE",.T.,"07")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA493 - LM")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA493 - MUNDI")
Startjob("U_BIA493","SCHEDULE",.T.,"13")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA493 - MUNDI")

RETURN .T.