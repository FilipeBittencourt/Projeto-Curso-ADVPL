/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    ESTE PONTO DE ENTRADA � UTILIZADO PARA ALTERAR A CONDI��O DE     # ||
|| #                 PAGAMENTO NA NOTA FISCAL DE ENTRADA                 # ||
\* ####################################################################### */

User Function A103CND2()
	//ir� chamar antes de abrir a tela do Documento de Entrada
	U_GTPE001()
Return Nil