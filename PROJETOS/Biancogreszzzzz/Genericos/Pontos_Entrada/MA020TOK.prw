#include "rwmake.ch"
#include "topconn.ch"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北矲uncao    矼A020TOK � Autor � Gabriel          		 � Data � 29/10/05 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o � Validacao do campo CGC para fornecedor                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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
		MSGBOX("Favor preencher o C骴igo do Munic韕io no cadastro de fornecedores.","MA020TOK","STOP")
		lret := .F.
	ENDIF
ENDIF

Return(lret)*/