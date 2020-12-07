#include "rwmake.ch"
#include "topconn.ch"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MA020TOK ³ Autor ³ Gabriel          		 ³ Data ³ 29/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do campo CGC para fornecedor                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Fonte Descontinuado - MVC_CUSTOMERVENDOR

/*
User Function MA020TOK()
Local Iret := .T.

IF Alltrim(M->A2_EST) == "EX"
	IF Alltrim(M->A2_CGC) == "" .OR. Alltrim(M->A2_CGC) == "."
		lret := .T.
	ENDIF
ELSE
	IF Alltrim(M->A2_CGC) <> ""
		lret := .T.
	ELSE
		MSGBOX("ESTADO DIFERENTE DE EX FAVOR PREENCHER O CAMPO CNPJ/CPF PARA CONTINUAR","MA020TOK","STOP")
		lret := .F.
	ENDIF
ENDIF

IF ALLTRIM(M->A2_TIPO) <> "X" .AND. Alltrim(M->A2_EST) <> "EX" 
	IF EMPTY(M->A2_COD_MUN)
		MSGBOX("Favor preencher o Código do Município no cadastro de fornecedores.","MA020TOK","STOP")
		lret := .F.
	ENDIF
ENDIF

Return(lret)*/