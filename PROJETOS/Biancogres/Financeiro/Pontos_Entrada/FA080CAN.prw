#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA080CAN
@author Wlysses Cerqueira (Facile)
@since 19/07/2019
@project Automação Financeira
@version 1.0
@description O ponto de entrada FA080CAN sera executado no cancelamento 
de baixas do contas a pagar, apos gravar os dados no SE2 e antes de grava-los no SE5.
@type class
/*/

User Function FA080CAN()

	RecLock("SE2", .F.)
	SE2->E2_YBLQ := "01"
	SE2->(MSUnLock())
				
	DBSelectArea("ZL0")
	ZL0->(DBSetOrder(1)) // ZL0_FILIAL, ZL0_CODEMP, ZL0_CODFIL, ZL0_CART, ZL0_PREFIX, ZL0_NUM, ZL0_PARCEL, ZL0_TIPO, ZL0_CLIFOR, ZL0_LOJA, R_E_C_N_O_, D_E_L_E_T_
				
	If ZL0->(DBSeek(xFilial("ZL0") + cEmpAnt + cFilAnt + "P" + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)))
				
		RecLock("ZL0", .F.)
		ZL0->ZL0_STATUS := "2"
		ZL0->(MSUnLock())
				
	EndIf

Return()