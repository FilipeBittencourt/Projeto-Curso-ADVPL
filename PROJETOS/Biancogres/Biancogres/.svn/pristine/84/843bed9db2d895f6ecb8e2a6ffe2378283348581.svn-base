#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M440STTS  ºAutor  ³Ranisses A. Corona  º Data ³  11/25/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Acerta/Bloqueia Liberacao de Pedidos de Vendas verificando  º±±
±±º          ³a situacao do cliente do cliente na outro empresa (01/05)	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento (Liberacao de Pedidos MATA440)                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M440STTS()
Local cSql := ""

//OS 3494-16 - Tania c/ aprovação do Fabio
If cEmpAnt == "02"
	Return(.T.)
EndIf

//Verifica se existem Itens com Bloqueio de Credito
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT COUNT(C9_BLCRED) BLCRED FROM %Table:SC9% WHERE C9_PEDIDO = %Exp:M->C5_NUM% AND C9_NFISCAL = ' ' AND (C9_BLCRED <> ' ' OR (C9_YDTBLCT <> '' AND C9_YDTLICT = '') ) AND %NOTDEL% 
EndSql
If (cAliasTmp)->BLCRED > 0
	If Type("nTpBlq") <> "U" 
		If nTpBlq == "01"
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois ultrapassa o Limite de Crédito.","M440STTS","STOP")
		ElseIf nTpBlq == "02"
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois não possui saldo de RA.","M440STTS","STOP")
		ElseIf nTpBlq == "03"
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois o Cliente possui Risco 'E'.","M440STTS","STOP")
		ElseIf nTpBlq == "04"
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois o Cliente está com o Limite de Crédito vencido.","M440STTS","STOP")
		ElseIf nTpBlq == "05"		
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois o Cliente possui títulos em atraso.","M440STTS","STOP")
		ElseIf nTpBlq == "061"		
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois teve alteração na data de entrega aprovada.","M440STTS","STOP")
		ElseIf nTpBlq == "062"		
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois teve alteração nos valores aprovados.","M440STTS","STOP")			
		ElseIf nTpBlq == "063"		
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois está sendo liberado antes da data de entrega.","M440STTS","STOP")
		ElseIf nTpBlq == "064"		
			Msgbox("Este pedido possui itens com  Bloqueio de Crédito, pois está com títulos de Contrato em atraso.","M440STTS","STOP")
		EndIf					
	Else
		Msgbox("Este pedido possui itens com  Bloqueio de Crédito.","M440STTS","STOP")
	EndIf
EndIf

//Verifica se existem Itens com Bloqueio de Estoque
cAliasTmp2 := GetNextAlias()
BeginSql Alias cAliasTmp2
	SELECT COUNT(C9_BLEST) BLEST FROM %Table:SC9% WHERE C9_PEDIDO = %Exp:M->C5_NUM% AND C9_NFISCAL = ' ' AND C9_BLEST <> ' ' AND %NOTDEL% 
EndSql
If (cAliasTmp2)->BLEST > 0
	Msgbox("Este pedido possui itens com  Bloqueio de Estoque.","M440STTS","STOP")
EndIf

(cAliasTmp)->(dbCloseArea())
(cAliasTmp2)->(dbCloseArea())

//Grava Status do RA na Liberação dos Pedidos

//Ticket 22041 -> comentado abaixo porque esta sendo usado no PE M440SC9I
//U_BIA859(M->C5_CLIENTE,M->C5_LOJACLI)

//If nRaStat <> "0"
//	cSql := "UPDATE "+RetSqlName("SC9")+" SET C9_YRASTAT = '"+nRaStat+"', C9_MSEXP = '' WHERE C9_PEDIDO = '"+M->C5_NUM+"' AND D_E_L_E_T_ = '' "
//	TcSQLExec(cSQL)
//EndIf

//Projeto reserva de OP - Fernando/Facile em 08/10/2014 - Apagar reservas e gerar novamento com o saldo pendente    
//Fernando em 07/01 - nao faz sentido fazer esse metodo para LM - nao deve ter reservas na LM nem alterar as reserva na origem
If M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. (AllTrim(CEMPANT) <> "07") .And. M->C5_YLINHA <> "4"

	//SC6->(DbSetOrder(1))
	//If !((AllTrim(CEMPANT) == "14") .And. SC6->(DbSeek(XFilial("SC6")+M->C5_NUM)) .And. !U_CHKRODA(SC6->C6_PRODUTO))
		U_FRRT02C9(M->C5_NUM)
	//EndIf
EndIf

Return