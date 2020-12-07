#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

/*
|------------------------------------------------------------|
| PE:			| F190ICAN																				 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 17/09/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Ponto de entrada para validar o cancelamento do  |
| 				| cheques. Verifica se a data da baixa do cheque é |
| 				| deiferente da data do sistemas									 |
|------------------------------------------------------------|
*/

User Function F190ICAN()
Local lRet := .T.

	If SEF->EF_DATA <> dDataBase
		lRet := .F.
		MsgInfo("Data da Baixa Invalida. Não é permitido realizar o Cancelamento do Cheque com data diferente de "+dToC(SEF->EF_DATA)+", e a Data Base deverá ser a mesma da Data da Baixa do Cheque.", "DATA INVALIDA")
	EndIf

Return(lRet)