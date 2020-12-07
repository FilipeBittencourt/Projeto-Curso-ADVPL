#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} MA200FNI
@author Marcos Alberto Soprani
@since 31/05/17
@version 1.0
@description Ponto de Entrada executado após a rotina de recálculo dos níveis, no final da manutenção de estrutura do produto
.            Inicialmente utilizado para atualizar campos personalizados da tabela SG1.
@type function
/*/

User Function MA200FNI()

	// Implementada melhoria em 15/04/13 por Marcos Alberto Soprani, a fim de corrigir o erro da apresentação em tela das descrições
	QY005 := " UPDATE " + RetSqlName("SG1")
	QY005 += "    SET G1_YDESCCD = ISNULL(SUBSTRING(SB1.B1_DESC,1,70),' '), "
	QY005 += "        G1_YDESCCP = ISNULL(SUBSTRING(XB1.B1_DESC,1,70),' ') "
	QY005 += "   FROM " + RetSqlName("SG1") + " SG1 (NOLOCK) "
	QY005 += "   LEFT JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	QY005 += "                       AND SB1.B1_COD = G1_COD "
	QY005 += "                       AND SB1.D_E_L_E_T_ =  ' ' "
	QY005 += "   LEFT JOIN " + RetSqlName("SB1") + " XB1 (NOLOCK) ON XB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	QY005 += "                       AND XB1.B1_COD = G1_COMP "
	QY005 += "                       AND XB1.D_E_L_E_T_ =  ' ' "
	QY005 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
	QY005 += "    AND ( SUBSTRING(G1_YDESCCD,1,70) <> SUBSTRING(SB1.B1_DESC,1,70) OR SUBSTRING(G1_YDESCCP,1,70) <> SUBSTRING(XB1.B1_DESC,1,70) ) "
	QY005 += "    AND SG1.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Atualizando campos de descrição...",,{|| TCSQLExec(QY005)})

Return		