#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA774
@author Marcos Alberto Soprani
@since 15/05/17
@version 1.0
@description Responsável pela atualização de campos personalizados na tabela SRA para todas as vezes que for acessar o casdastro
.             de funcionários
@obs OS: 3338-16 - FRANCINE DIAS DE ABREU ARAÚJO
@type function
/*/

User Function BIA774()

	Local cfgrArea := GetArea()

	UP007 := " UPDATE " + RetSqlName("SRA") + " SET RA_YDCLVL = CTH_DESC01, RA_YDDEPTO = QB_DESCRIC
	UP007 += "   FROM " + RetSqlName("SRA") + " SRA
	UP007 += "  INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = RA_CLVL
	UP007 += "                       AND CTH.D_E_L_E_T_ = ' '
	UP007 += "  INNER JOIN " + RetSqlName("SQB") + " SQB ON QB_DEPTO = RA_DEPTO
	UP007 += "                       AND SQB.D_E_L_E_T_ = ' '
	UP007 += "  WHERE RA_FILIAL = '" + xFilial("SRA") + "'
	UP007 += "    AND RA_CLVL <> ''
	UP007 += "    AND RA_DEPTO <> ''
	UP007 += "    AND SRA.D_E_L_E_T_ = ' '
	U_BIAMsgRun("Aguarde... ",,{|| TCSQLExec(UP007) })

	RestArea(cfgrArea)

Return
