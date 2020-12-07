#include "rwmake.Ch"
#include "topconn.ch"
#include "tbiconn.ch" 
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณAGE_2_DIASบ Autor ณ MADALENO           บ Data ณ  14/04/09   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA A SER EXECUTADO NO SCHEDULE PARA A GERACAO DOS      บฑฑฒ
ฒฑฑบ          ณ WORKFLOW                                                   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8                                                        บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION AGE_2_DIAS()

// *****************************************************************************
// ********************** WORKFLOW DOS CLIENTES EM ATRASO   ********************
// *****************************************************************************
//Retirado a pedido do Claudeir no dia 11/06/12
//ConOut("HORA: "+TIME()+" - GERANDO WORKFLOW DOS CLIENTES EM ATRASO NA BIANCOGRES")
//Startjob("U_WORK_5DIAS_CLI","SCHEDULE",.T.,"01")
//ConOut("HORA: "+TIME()+" - FIM DO WORKFLOW DOS CLIENTES EM ATRASO NA BIANCOGRES")  
//
//ConOut("HORA: "+TIME()+" - GERANDO WORKFLOW DOS CLIENTES EM ATRASO NA INCESA")
//Startjob("U_WORK_5DIAS_CLI","SCHEDULE",.T.,"05")
//ConOut("HORA: "+TIME()+" - FIM DO WORKFLOW DOS CLIENTES EM ATRASO NA INCESA") 


ConOut("HORA: "+TIME()+" - GERANDO WORKFLOW DA LISTA DE INVESTIMENTO PENDENTES DA BIANCO")
Startjob("U_WORK_INVES","SCHEDULE",.T.,"01")
ConOut("HORA: "+TIME()+" - FIM DO WORKFLOW DA LISTA DE INVESTIMENTO PENDENTES DA BIANCO") 

ConOut("HORA: "+TIME()+" - GERANDO WORKFLOW DA LISTA DE INVESTIMENTO PENDENTES NA INCESA")
Startjob("U_WORK_INVES","SCHEDULE",.T.,"05")
ConOut("HORA: "+TIME()+" - FIM DO WORKFLOW  DA LISTA DE INVESTIMENTO PENDENTES NA INCESA") 

RETURN .T.