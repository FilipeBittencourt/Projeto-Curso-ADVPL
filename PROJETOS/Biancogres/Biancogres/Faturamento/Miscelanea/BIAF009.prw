#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF009																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 03/11/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Inclusão de Clientes   						   					   |
| 				|	Valida se o CGC do cliente já existe em alguma   |
| 				|	empresa do grupo                                 |
|------------------------------------------------------------|
*/

User Function BIAF009(cCgc, cEmpresa, cCliente, cLoja)
Local aArea := GetArea()
Local lRet := .F.
Local cSQL := ""
Local Qry := GetNextAlias()

	If Inclui
		
		cSQL := " SELECT 'BIANCO' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1010 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
		
		cSQL += " UNION ALL	"
		
		cSQL += " SELECT 'INCESA' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1050 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
		
		cSQL += " UNION ALL	"		
		
		cSQL += " SELECT 'LM COMERCIO' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1070 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
		
		cSQL += " UNION ALL	"
		
		cSQL += " SELECT 'ST GESTAO' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1120 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
		
		cSQL += " UNION ALL	"
		
		cSQL += " SELECT 'MUNDI' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1130 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
		
		cSQL += " UNION ALL	"	
		
		cSQL += " SELECT 'VITCER' AS EMPRESA, A1_COD, A1_NOME, A1_LOJA  "
		cSQL += " FROM SA1140 "		
		cSQL += " WHERE A1_CGC = "+ ValToSQL(cCGC)
		cSQL += " AND D_E_L_E_T_ = ''"
							
		TcQuery cSQL New Alias (Qry)
		
		If !Empty((Qry)->EMPRESA)
			
			lRet := .T.
			
			cEmpresa := (Qry)->EMPRESA
			cCliente := (Qry)->A1_COD +"-"+ AllTrim((Qry)->A1_NOME)
			cLoja := (Qry)->A1_LOJA
			
		EndIf
		
		(Qry)->(dbCloseArea())
		
	EndIf
	
	RestArea(aArea)
	
Return(lRet)