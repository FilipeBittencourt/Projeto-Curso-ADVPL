#include "rwmake.ch" 
#include "Topconn.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BIA805   ³ Autor ³ BRUNO MADALENO        ³ Data ³ 05/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PREENCHE O PRECO NO ORCAMENTO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION BIA805()

Local NFATOR_FINANCEIRO	:= POSICIONE("SE4",1,XFILIAL("SE4")+M->CJ_CONDPAG,"E4_YMAXDES")
Local NPRODUTO 			:= ALLTRIM(TMP1->CK_PRODUTO)
Local __DM 				:= "NAO"
Local _A1_YRECR			:= POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_YRECR")

If cempant == "05"
	If _A1_YRECR == "2" .OR. _A1_YRECR == "3"
		__DM := "SIM"
	EndIf 
EndIf 

//Busca Preco de Tabela
NPRE_TAB	:= U_FBUSCAPRECO(M->CJ_YLINHA,M->CJ_TABELA, NPRODUTO,DTOS(M->CJ_EMISSAO),M->CJ_CLIENTE,M->CJ_LOJA)

//Aplica Financeiro
NPRE_TAB 	:= (NPRE_TAB * NFATOR_FINANCEIRO)

//Aplica Politica (agora calculado pelo Representante)
NPRE_TAB	:= NPRE_TAB * ((100 - M->CJ_YDSCTOT) /100)		

//Aplica Desconto por Item
NPRE_TAB	:= NPRE_TAB * ((100 - TMP1->CK_YDESC) /100)		

//Soma o Valor do Frete
NPRE_TAB	:= NPRE_TAB  + M->CJ_YVLRFRE

If __DM == "SIM"	
	NPRE_TAB := NPRE_TAB * GetMV("MV_YRECR")
EndIf 

RETURN(NPRE_TAB)