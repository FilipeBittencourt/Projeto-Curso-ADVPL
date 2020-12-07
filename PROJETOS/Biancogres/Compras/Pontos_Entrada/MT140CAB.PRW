/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    É EXECUTADO QUANDO A PRÉ-NOTA ESTÁ SENDO INCLUÍDA PARA COLOCAR   # ||
|| #     OS VALORES REFERENTES AS DESPESAS CONTIDAS NO XML               # ||
\* ####################################################################### */

User Function MT140CAB()
	//CONEXÃO NFE
	U_GTPE009()	
Return .T.