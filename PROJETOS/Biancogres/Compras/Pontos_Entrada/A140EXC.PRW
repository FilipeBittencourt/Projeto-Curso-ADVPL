/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    É EXECUTADO DEPOIS QUE A PRÉ-NOTA É EXCLUÍDA PARA FAZER O XML    # ||
|| #              VOLTAR PARA A TELA INICIAL DO IMPORTADOR               # ||
\* ####################################################################### */

User Function A140EXC()
	Local _lRet	:=	.T.
	//CONEXÃO NFE
	If U_BIAFG127(SF1->(RECNO()))
		U_GTPE003()
	Else
		_lRet	:=	.F.
	EndIf
Return _lret