#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Funcao: | Pe01NfeSefaz																		|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 02/02/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Ponto de entrada localizado na função XmlNfeSef |
| 				| do rdmake NFESEFAZ. Através deste ponto 				|
| 				| é possível realizar manipulações nos dados 			|
| 				| do produto, mensagens adicionais, destinatário, |
| 				| dados da nota, pedido de venda ou compra, 			|
| 				| antes da montagem do XML, no momento da 				|
| 				| transmissão da NFe.															|
|-----------------------------------------------------------|
*/

User Function Pe01NfeSefaz()
Local aRet := {}
Local oNfeSefaz := TBiaNfeSefaz():New(ParamIxb)

	oNfeSefaz:Validate()
	
	aRet := oNfeSefaz:Update()

Return(aRet)