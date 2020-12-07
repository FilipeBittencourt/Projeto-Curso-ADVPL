/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    ESTE PONTO DE ENTRADA É UTILIZADO PARA ALTERAR A CONDIÇÃO DE     # ||
|| #                 PAGAMENTO NA NOTA FISCAL DE ENTRADA                 # ||
\* ####################################################################### */

User Function A103CND2()
	//irá chamar antes de abrir a tela do Documento de Entrada
	U_GTPE001()
Return Nil