#include "rwmake.ch"
#include "topconn.ch"
#include "Ap5Mail.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA531A    ³ Autor ³ Wanisay William       ³ Data ³ 23.01.13      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail com pedidos aguardando aprovação 		             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador xBase                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA531A

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA531 - BIANCOGRES")
Startjob("U_BIA531","SCHEDULE",.T.,"01")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA531 - BIANCOGRES")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA531 - INCESA")
Startjob("U_BIA531","SCHEDULE",.T.,"05")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA531 - INCESA")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA531 - ST GESTAO")
Startjob("U_BIA531","SCHEDULE",.T.,"12")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA531 - ST GESTAO")

ConOut("HORA: "+TIME()+" - INICIANDO PROCESSO BIA531 - MUNDI")
Startjob("U_BIA531","SCHEDULE",.T.,"13")
ConOut("HORA: "+TIME()+" - FINALIZANDO PROCESSO BIA531 - MUNDI")

RETURN .T.