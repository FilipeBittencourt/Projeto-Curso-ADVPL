/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    PONTO DE ENTRADA UTILIZADO PARA INSERIR NOVAS OPÇÕES NO ARRAY    # ||
|| #               DE BOTÕES DENTRO DE DOCUMENTO DE ENTRADA              # ||
\* ####################################################################### */

User Function MA103BUT()
Local aButtons := {}

	aButtons := U_GTPE014()

Return aButtons
