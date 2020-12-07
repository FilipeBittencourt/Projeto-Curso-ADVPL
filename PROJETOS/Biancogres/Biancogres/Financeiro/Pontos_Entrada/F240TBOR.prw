#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ 	F240TBOR    ³ AUTOR ³BRUNO MADALENO        ³ DATA ³ 22/06/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRI‡„O ³ APOS A GRAVACAO DO BORDERO GRAVA O SALDO NA TABVELA SEA010      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION F240TBOR()
PRIVATE CSQL := ""
PRIVATE ENTER := CHR(13) + CHR(10)

CSQL := "UPDATE "+RETSQLNAME("SEA")+" SET EA_YVALOR = E2_SALDO " + ENTER
CSQL += "FROM "+RETSQLNAME("SEA")+" SEA, "+RETSQLNAME("SE2")+" SE2 " + ENTER
CSQL += "WHERE	EA_NUMBOR = '"+SEA->EA_NUMBOR+"' AND " + ENTER
CSQL += "		EA_CART = 'P' AND " + ENTER
//CSQL += "		E2_PREFIXO+RTRIM(E2_NUM)+E2_PARCELA+E2_FORNECE+E2_LOJA = SEA.EA_PREFIXO+RTRIM(SEA.EA_NUM)+SEA.EA_PARCELA+SEA.EA_FORNECE+SEA.EA_LOJA AND  " + ENTER
//ALTERADO POR FERNANDO ROCHA - 03/08/2010 - NAO ESTAVA SELECIONANDO CORRETAMENTE OS TITULOS NO BORDERO NAO ATUALIZANDO O YVALOR CORRETAMENTE CAUSANDO MANUTENCAO MANUAL
//CSQL += "		EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA = E2_FILIAL+E2_NUMBOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA AND " + ENTER
CSQL += "		EA_FILIAL=E2_FILIAL AND EA_NUMBOR=E2_NUMBOR AND EA_PREFIXO=E2_PREFIXO AND EA_NUM=E2_NUM AND EA_PARCELA=E2_PARCELA AND EA_TIPO=E2_TIPO AND EA_FORNECE=E2_FORNECE AND EA_LOJA = E2_LOJA AND  " + ENTER
CSQL += "		SEA.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SE2.D_E_L_E_T_ = '' " + ENTER
TCSQLEXEC(CSQL)

RETURN()
