/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    � EXECUTADO DEPOIS QUE A PR�-NOTA � EXCLU�DA PARA FAZER O XML    # ||
|| #              VOLTAR PARA A TELA INICIAL DO IMPORTADOR               # ||
\* ####################################################################### */

User Function A140EXC()
	Local _lRet	:=	.T.
	//CONEX�O NFE
	If U_BIAFG127(SF1->(RECNO()))
		U_GTPE003()
	Else
		_lRet	:=	.F.
	EndIf
Return _lret