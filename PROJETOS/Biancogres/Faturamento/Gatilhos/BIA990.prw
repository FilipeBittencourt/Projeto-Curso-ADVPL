#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function BIA990()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA990   ³ Autor ³ Ranisses A. Corona    ³ Data ³ 02/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueia cadastro pedido export. conf. parametro MV_YEXPORT³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExecBlock                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Codigo do Cliente                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Parametro que define se os pedidos de exportacao podem ser lancados pelo SIGAFAT
Local ret  := GETMV("MV_YEXPORT") 
Local cEst := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
Local cCli := M->C5_CLIENTE 

If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
	Return(M->C5_CLIENTE)
EndIf

If ret == "S" .and. Funname() = "MATA410" .and. cEst == "EX"
	MsgAlert("Pedido de Exportacao devem ser feitos pelo Modulo EEC.")
	cCli := SPACE(6)
EndIf

//Fernando/Facile em 05/09/16 - validacao para informar sobre importacao de proposta de engenharia
//Comentado abaixo - retirar comentario apos comercial validar processo de engenharia fase 2
/*IF ALLTRIM(FUNNAME()) == "MATA410"

	If SA1->A1_YTPSEG == "E" 
	
		If U_PENGCKCL()
	
			U_FROPMSG("Canal Engenharia", "Existem propostas aprovadas para este cliente. "+CRLF+;
			"Favor pesquisar e informar o número da proposta no campo 'Nr.Proposta' para vincular ao pedido.", {"OK"}, 2, "Verificando Propostas")
		
		Else
		
			U_FROPMSG("Canal Engenharia", "ATENÇÃO!"+CRLF+;
			"NÃO Existe proposta aprovada para este cliente."+CRLF+;
			"Para pedidos de volume maior que "+AllTrim(Str(GetNewPar("FA_VENGMAX",2000)))+" é obrigatório informar a proposta.", {"OK"}, 2, "Verificando Propostas")
		
		EndIf
	
	EndIf

ENDIF*/

Return(cCLi)