#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF016																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 27/04/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina para calculo do consumo mensal de produtos|
| 				|	comuns						 															 |
|------------------------------------------------------------|
| OS:			|	N/A - Usuário: Wanisay William 									 |
|------------------------------------------------------------|
*/

User Function BIAF016()
Local oParam := TParBIAF016():New()
Local oConPrdCom := TConsumoProdutoComum():New()

 	If cEmpAnt $ "05/14"
		
		If oParam:Box()
			
			U_BIAMsgRun("Calculando consumo mênsal...", "Aguarde!", {|| oConPrdCom:Get(oParam) })
			
			U_BIAMsgRun("Atualizando consumo mênsal...", "Aguarde!", {|| oConPrdCom:Set() })
						
			MsgInfo("Cálculo do consumo mênsal executado com sucesso!")
			
		EndIf
	
	Else	
		MsgInfo("Rotina não habilitada para esta empresa!")
	EndIf

Return()