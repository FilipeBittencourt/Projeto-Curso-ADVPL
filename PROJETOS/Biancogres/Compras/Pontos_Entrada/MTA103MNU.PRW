#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"

/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    PONTO DE ENTRADA UTILIZADO PARA INSERIR NOVAS OPÇÕES NO ARRAY    # ||
|| #                   AROTINA EM DOCUMENTO DE ENTRADA                   # ||
\* ####################################################################### */

User Function MTA103MNU()
	
	//CONEXÃO NFE
	If FwIsInCallStack('U_GATI001')
		U_GTPE010()
	Else	
		aAdd(aRotina,{ "Processo de Devolução", "U_BIABC003(SF1->F1_DOC+SF1->F1_SERIE,'E')", 0 , 2, 0, .F.})
		aAdd(aRotina,{ "Copiar", "U_COPYDOCE()", 0 , 2, 0, .F.})
	Endif	
Return