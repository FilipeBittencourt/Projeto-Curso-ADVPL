#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF014																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 14/01/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina para validacao do codigo de barras para 	 |
| 				|	pagamento de boletos do banco do brasil  				 |
| 				|	Verifica se o conteudo do campo é valido e se o  |
| 				|	valor informado confere com o valor do titulo    |
|------------------------------------------------------------|
| OS:			|	1579-13 - Usuário: Mikaelly Gentil			 			 	 |
|------------------------------------------------------------|
*/

User Function BIAF014(cPar)
Local lRet := .T.
Local nVal := 0	
	
	If cPar == "CB" .And. !Empty(M->E2_CODBAR)
		nVal := Val(SubStr(SE2->E2_CODBAR, 10, 8) +"."+ SubStr(SE2->E2_CODBAR, 18, 2))
	ElseIf cPar == "LD" .And. !Empty(M->E2_YLINDIG)
 		nVal := Val(SubStr(M->E2_YLINDIG, 38, 8) +"."+ SubStr(M->E2_YLINDIG, 46, 2))
	EndIf

	If nVal > 0
		
		nVal := nVal - M->E2_CNABDES + M->E2_CNABACR
		
		If nVal <> M->E2_SALDO - M->E2_CNABDES + M->E2_CNABACR
			lRet := .F.			
			MsgInfo("Atenção, valor do código de barras ou linha digitável invalido!")
		EndIf
		
	EndIf	
	
Return(lRet)