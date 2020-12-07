#include "protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} A200BOK
@author Marcos Alberto Soprani
@since 24/07/12
@version 1.0
@description Ponto de Entrada para validar as alterações da Estrutura
@type function
/*/

User Function A200BOK()

	Local ztRetOk  := .T.
	Local aRegs    := PARAMIXB[1]
	Local cCod     := PARAMIXB[2]
	Local xMnsg    := "Relação de possíveis erros na estrutura:"+CHR(13)+CHR(13)

	// Variável criada no P.E. MA200CAB
	If zy_NewRev

		// Encerra a Validade da(s) revisão(ões) da(s) Estrutura(s) anterior(es). SEMPRE UM DIA ANTES DO INICIO DA NOVA REVISÃO.
		If zy_Opcao <> 3

			AK001 := " UPDATE " + RetSqlName("SG1") + " SET G1_FIM = '" + dtos(xc_NDtIni-1) + "' "
			AK001 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
			AK001 += "    AND G1_COD = '" + cProduto + "' "
			AK001 += "    AND '" + dtos(xc_NDtIni) + "' >= G1_INI "
			AK001 += "    AND '" + dtos(xc_NDtIni) + "' <= G1_FIM "
			AK001 += "    AND G1_TRT NOT IN('   ','" + xc_NewRev + "') "
			AK001 += "    AND D_E_L_E_T_ = ' ' "
			TCSQLExec(AK001)

		EndIf

	EndIf

	A0001 := " SELECT COUNT(*) CONTAD "
	A0001 += "   FROM (SELECT G1_INI, G1_FIM, G1_REVINI, G1_REVFIM "
	A0001 += "           FROM " + RetSqlName("SG1")
	A0001 += "          WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
	A0001 += "            AND G1_COD = '" + cCod + "' "
	A0001 += "            AND G1_TRT = '" + cRevisao + "' "
	A0001 += "            AND D_E_L_E_T_ = ' ' "
	A0001 += "          GROUP BY G1_INI, G1_FIM, G1_REVINI, G1_REVFIM) ESTRUT "
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	If A001->CONTAD > 1
		xMnsg += "- Existe divergência nas datas de inicio e fim e/ou na revisão de até;"+CHR(13)+CHR(13)
		ztRetOk := .F.
	EndIf
	A001->(dbCloseArea())

	A0002 := " SELECT COUNT(*) CONTAD "
	A0002 += "   FROM (SELECT G1_REVINI, G1_REVFIM "
	A0002 += "           FROM " + RetSqlName("SG1")
	A0002 += "          WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
	A0002 += "            AND G1_COD = '" + cCod + "' "
	A0002 += "            AND '" + dtos(dDataBase) + "' >= G1_INI AND '" + dtos(dDataBase) + "' <= G1_FIM "
	A0002 += "            AND G1_REVINI = G1_TRT "
	A0002 += "            AND G1_REVFIM = G1_TRT "
	A0002 += "            AND D_E_L_E_T_ = ' ' "
	A0002 += "          GROUP BY G1_REVINI, G1_REVFIM) ESTRUT "
	TCQUERY A0002 New Alias "A002"
	dbSelectArea("A002")
	dbGoTop()
	If A002->CONTAD > 1
		xMnsg += "- Com as alterações efetuadas, mais de uma revisão ficará ativa para período de tempo concorrente. Isto não é permitido;"+CHR(13)+CHR(13)
		ztRetOk := .F.
	EndIf
	A002->(dbCloseArea())

	If !ztRetOk

		MsgINFO(xMnsg)

	EndIf

Return( ztRetOk )
