#include "rwmake.ch"
#Include "TopConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPOS_CLI   บAutor  ณ MADALENO           บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ CONSULTA A POSICAO  DO CLIENTE NAS EMPRESAS BIANCO E 	  บฑฑ
ฑฑบ          ณ COMERCIAL MOENDAS                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP7 - FINANCEIRO                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION ABRUNO()
//VARIAVEIS RESPONSAVEIS PELOS PRIMEIROS CAMPOS
Private sCodigo		:= SPACE(20)
Private sLoja 		:= SPACE(15)
Private sNome 		:= SPACE(255)
//VARIAVEIS RESPONSAVEIS PELOS SEGUNDOS CAMPOS
Private sCGD_CPF	:= SPACE(20)
Private sTelefone	:= SPACE(15)
Private sVend_Ince	:= SPACE(100)
Private sVend_Bian	:= SPACE(100)

@ 96,42 TO 600,850 DIALOG oEntra TITLE "Autorizacao Para Desbloqueio de Tํtulos" //FRMULARIO
@ 02,03 TO 60 ,343   // PRIMEIRO FRAME FRAME

//*************** PRIMEIROS CAMPOS ******************
@ 010,007 SAY "C๓digo"   			; @ 019,006 GET sCodigo 		Size 72,20
@ 010,083 SAY "Loja"     			; @ 019,082 GET sLoja			Size 50,20
@ 010,136 SAY "Nome"     			; @ 019,135 GET sNome   		Size 205,20

//*************** SEGUNDOS CAMPOS *******************
@ 032,007 SAY "CGD/CPF"  			; @ 041,006 GET sCGD_CPF 		Size 72,20
@ 032,083 SAY "Telefone" 			; @ 041,082 GET sTelefone		Size 50,20
@ 032,136 SAY "Vendedor Incesa"     ; @ 041,135 GET sVend_Ince  	Size 100,20
@ 032,241 SAY "Vendedor Incesa"     ; @ 041,240 GET sVend_Bian  	Size 100,20

//*************** CRIANDO BOTOES *******************
@ 003,347 BUTTON "Tit. Aberto" 		SIZE 55,12 ACTION Close(oEntra)
@ 018,347 BUTTON "Tit. Recebidos"  	SIZE 55,12 ACTION Close(oEntra)
@ 033,347 BUTTON "Pedidos" 			SIZE 55,12 ACTION Close(oEntra)
@ 048,347 BUTTON "Faturamento"  	SIZE 55,12 ACTION Close(oEntra)

@ 57,03	To 113 ,343   // SEGUNDO FRAME FRAME

@ 64,140 SAY "INFORMAวีES GERAIS"   			


@ 120,345 BUTTON "Sair"  			SIZE 55,12 ACTION Close(oEntra)
ACTIVATE DIALOG oEntra CENTERED


RETURN



